import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { prisma } from '@swing/db'
import { redis } from '../../lib/redis'
import { signOverlayToken } from '../../lib/overlay-token'
import { overlayFeedRoutes } from './overlay-feed.routes'

const LIVE_SESSION_TTL = 28800 // 8 hours
const sessionKey = (matchId: string) => `live:session:${matchId}`

export async function liveRoutes(app: FastifyInstance) {
  // Overlay feed (bootstrap + tick) — token-gated, mounted under /live
  await app.register(overlayFeedRoutes)

  // ─── 1. Validate match access ─────────────────────────────────────────────
  app.post('/validate-match', async (request, reply) => {
    const body = z
      .object({ matchId: z.string().min(1), pin: z.string().min(1) })
      .parse(request.body)

    const match = await prisma.match.findFirst({
      where: { liveCode: body.matchId },
      select: {
        id: true,
        teamAName: true,
        teamBName: true,
        tournamentId: true,
        status: true,
        scheduledAt: true,
        venueName: true,
        livePin: true,
      },
    })

    if (!match) {
      return reply.code(404).send({
        success: false,
        error: { code: 'MATCH_NOT_FOUND', message: 'Match not found' },
      })
    }

    if (!match.livePin || body.pin !== match.livePin) {
      return reply.code(401).send({
        success: false,
        error: { code: 'INVALID_PIN', message: 'Invalid PIN' },
      })
    }

    const activeSessionRaw = await redis.get(sessionKey(match.id))
    const activeSession = activeSessionRaw ? JSON.parse(activeSessionRaw) : null

    const overlayToken = signOverlayToken(match.id)

    return reply.send({
      success: true,
      data: {
        allowed: true,
        match: {
          id: match.id,
          title: `${match.teamAName} vs ${match.teamBName}`,
          teamA: match.teamAName,
          teamB: match.teamBName,
          tournamentId: match.tournamentId,
          status: match.status,
          scheduledAt: match.scheduledAt,
          ground: match.venueName ?? null,
        },
        overlay: {
          theme: 'basic',
          showScore: true,
          showOvers: true,
          showBatsmen: true,
          showBowler: true,
        },
        // Overlay JWT — pass as `Authorization: Bearer …` to
        // /live/matches/:matchId/bootstrap and /tick (or `?token=` for SSE).
        overlayToken,
        liveSession: activeSession,
      },
    })
  })

  // ─── 2. Validate tournament access ───────────────────────────────────────
  app.post('/validate-tournament', async (request, reply) => {
    const body = z
      .object({ tournamentId: z.string().min(1), pin: z.string().min(1) })
      .parse(request.body)

    const tournament = await prisma.tournament.findUnique({
      where: { id: body.tournamentId },
      select: { id: true, name: true, status: true, livePin: true },
    })

    if (!tournament) {
      return reply.code(404).send({
        success: false,
        error: { code: 'TOURNAMENT_NOT_FOUND', message: 'Tournament not found' },
      })
    }

    if (!tournament.livePin || body.pin !== tournament.livePin) {
      return reply.code(401).send({
        success: false,
        error: { code: 'INVALID_PIN', message: 'Invalid PIN' },
      })
    }

    return reply.send({
      success: true,
      data: {
        allowed: true,
        tournament: { id: tournament.id, name: tournament.name, status: tournament.status },
      },
    })
  })

  // ─── 3. Tournament matches ────────────────────────────────────────────────
  app.get('/tournaments/:tournamentId/matches', async (request, reply) => {
    const { tournamentId } = request.params as { tournamentId: string }

    const matches = await prisma.match.findMany({
      where: { tournamentId },
      orderBy: { scheduledAt: 'asc' },
      select: {
        id: true,
        teamAName: true,
        teamBName: true,
        status: true,
        scheduledAt: true,
        venueName: true,
      },
    })

    return reply.send({
      success: true,
      data: {
        matches: matches.map((m) => ({
          id: m.id,
          title: `${m.teamAName} vs ${m.teamBName}`,
          teamA: m.teamAName,
          teamB: m.teamBName,
          status: m.status,
          startTime: m.scheduledAt,
          ground: m.venueName ?? null,
        })),
      },
    })
  })

  // ─── 4. Overlay feed ──────────────────────────────────────────────────────
  // Removed legacy GET /matches/:matchId/overlay.
  // Use GET /live/matches/:matchId/bootstrap (snapshot) + /tick (SSE) — both
  // require the overlay JWT issued by POST /live/validate-match.

  // ─── 5. Start live session ────────────────────────────────────────────────
  app.post('/session/start', async (request, reply) => {
    const body = z
      .object({
        matchId: z.string().min(1),
        platform: z.enum(['youtube', 'hls']).default('hls'),
        broadcastId: z.string().optional(),
        rtmpsUrl: z.string().min(1).optional(),
        watchUrl: z.string().url().optional(),
        quality: z.string().default('1080p60'),
      })
      .parse(request.body)

    const match = await prisma.match.findUnique({
      where: { id: body.matchId },
      select: { id: true },
    })
    if (!match) {
      return reply.code(404).send({
        success: false,
        error: { code: 'MATCH_NOT_FOUND', message: 'Match not found' },
      })
    }

    const existingRaw = await redis.get(sessionKey(body.matchId))
    const existingSession = existingRaw ? JSON.parse(existingRaw) : null

    const session = {
      matchId: body.matchId,
      platform: body.platform,
      broadcastId: body.broadcastId ?? existingSession?.broadcastId ?? null,
      rtmpsUrl: body.rtmpsUrl ?? existingSession?.rtmpsUrl ?? null,
      watchUrl: body.watchUrl ?? existingSession?.watchUrl ?? null,
      quality: body.quality,
      startedAt: existingSession?.startedAt ?? new Date().toISOString(),
      lastHeartbeat: new Date().toISOString(),
      status: 'live',
    }

    await redis.setex(sessionKey(body.matchId), LIVE_SESSION_TTL, JSON.stringify(session))

    // Auto-set HLS watch URL so admin panel can embed the stream
    const apiBase = process.env.API_BASE_URL || 'https://swing-backend-nbid5gga4q-el.a.run.app'
    const hlsWatchUrl =
      body.watchUrl ??
      existingSession?.watchUrl ??
      `${apiBase}/studio/hls/${body.matchId}/index.m3u8`
    await prisma.match.update({
      where: { id: body.matchId },
      data: { youtubeUrl: hlsWatchUrl },
    })

    return reply.send({
      success: true,
      data: {
        sessionId: body.matchId,
        matchId: body.matchId,
        broadcastId: session.broadcastId,
        rtmpsUrl: session.rtmpsUrl,
        startedAt: session.startedAt,
        watchUrl: hlsWatchUrl,
        quality: session.quality,
        status: session.status,
      },
    })
  })

  // ─── 6. Heartbeat (every 15s from app) ───────────────────────────────────
  app.post('/session/heartbeat', async (request, reply) => {
    const body = z
      .object({
        matchId: z.string().min(1),
        quality: z.string().optional(),
        bitrateKbps: z.number().optional(),
        fps: z.number().optional(),
        droppedFrames: z.number().optional(),
        isConnected: z.boolean().optional(),
      })
      .parse(request.body)

    const raw = await redis.get(sessionKey(body.matchId))
    if (!raw) {
      return reply.code(404).send({
        success: false,
        error: { code: 'SESSION_NOT_FOUND', message: 'No active session' },
      })
    }

    const session = JSON.parse(raw)
    session.lastHeartbeat = new Date().toISOString()
    if (body.quality) session.quality = body.quality
    if (body.bitrateKbps !== undefined) session.bitrateKbps = body.bitrateKbps
    if (body.fps !== undefined) session.fps = body.fps
    if (body.droppedFrames !== undefined) session.droppedFrames = body.droppedFrames
    if (body.isConnected !== undefined) session.isConnected = body.isConnected

    await redis.setex(sessionKey(body.matchId), LIVE_SESSION_TTL, JSON.stringify(session))
    return reply.send({ success: true, data: { ok: true } })
  })

  // ─── 7. Stop live session ─────────────────────────────────────────────────
  app.post('/session/stop', async (request, reply) => {
    const body = z
      .object({
        matchId: z.string().min(1),
        totalDurationSeconds: z.number().optional(),
        averageQuality: z.string().optional(),
      })
      .parse(request.body)

    await redis.del(sessionKey(body.matchId))
    await redis.del(`live:overlay:bootstrap:${body.matchId}`)

    return reply.send({ success: true, data: { stopped: true } })
  })

  // ─── Bonus: session status (admin panel polling) ──────────────────────────
  app.get('/session/:matchId', async (request, reply) => {
    const { matchId } = request.params as { matchId: string }
    const raw = await redis.get(sessionKey(matchId))
    return reply.send({ success: true, data: raw ? JSON.parse(raw) : null })
  })
}
