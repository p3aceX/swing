import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { prisma } from '@swing/db'
import { redis } from '../../lib/redis'

const LIVE_SESSION_TTL = 28800 // 8 hours
const sessionKey = (matchId: string) => `live:session:${matchId}`

// ─── Overlay builder ─────────────────────────────────────────────────────────
async function buildOverlay(matchId: string) {
  const match = await prisma.match.findUnique({
    where: { id: matchId },
    include: {
      innings: {
        orderBy: { inningsNumber: 'asc' },
      },
    },
  })
  if (!match) return null

  const teams = await prisma.team.findMany({
    where: {
      OR: [
        { name: { equals: match.teamAName, mode: 'insensitive' } },
        { name: { equals: match.teamBName, mode: 'insensitive' } },
      ],
    },
    select: { name: true, shortName: true, logoUrl: true },
  })
  const findTeamMeta = (name: string) =>
    teams.find((team) => team.name.trim().toLowerCase() === name.trim().toLowerCase()) ?? null
  const teamAMeta = findTeamMeta(match.teamAName)
  const teamBMeta = findTeamMeta(match.teamBName)
  const teamAShortName = teamAMeta?.shortName ?? match.teamAName
  const teamBShortName = teamBMeta?.shortName ?? match.teamBName

  const currentInnings =
    match.innings.find((i) => !i.isCompleted) ??
    match.innings[match.innings.length - 1]
  const prevInnings = match.innings.find(
    (i) => i.isCompleted && i.inningsNumber === 1
  )

  // Resolve player names for striker / non-striker / bowler
  async function resolvePlayer(playerId: string | null) {
    if (!playerId) return null
    const p = await prisma.playerProfile.findUnique({
      where: { id: playerId },
      include: { user: { select: { name: true } } },
    })
    if (!p) return null
    const stats = await prisma.playerMatchStats.findFirst({
      where: { matchId, playerProfileId: playerId },
    })
    return {
      name: p.user.name,
      runs: stats?.runs ?? 0,
      balls: stats?.balls ?? 0,
      wickets: stats?.wickets ?? 0,
      runsConceded: stats?.runsConceded ?? 0,
      oversBowled: stats?.oversBowled ?? 0,
    }
  }

  const [striker, nonStriker, bowler] = await Promise.all([
    resolvePlayer(currentInnings?.currentStrikerId ?? null),
    resolvePlayer(currentInnings?.currentNonStrikerId ?? null),
    resolvePlayer(currentInnings?.currentBowlerId ?? null),
  ])

  let tournamentName: string | null = null
  if (match.tournamentId) {
    const t = await prisma.tournament.findUnique({
      where: { id: match.tournamentId },
      select: { name: true },
    })
    tournamentName = t?.name ?? null
  }

  return {
    matchId,
    teamA: match.teamAName,
    teamB: match.teamBName,
    teamAName: match.teamAName,
    teamAShortName,
    teamALogoUrl: teamAMeta?.logoUrl ?? null,
    teamBName: match.teamBName,
    teamBShortName,
    teamBLogoUrl: teamBMeta?.logoUrl ?? null,
    tournamentName,
    status: match.status,
    currentInnings: currentInnings
      ? {
          battingTeam: currentInnings.battingTeam,
          teamName: currentInnings.battingTeam === 'A' ? match.teamAName : match.teamBName,
          teamShortName:
            currentInnings.battingTeam === 'A' ? teamAShortName : teamBShortName,
          teamLogoUrl:
            currentInnings.battingTeam === 'A'
              ? teamAMeta?.logoUrl ?? null
              : teamBMeta?.logoUrl ?? null,
          runs: currentInnings.totalRuns,
          wickets: currentInnings.totalWickets,
          overs: currentInnings.totalOvers.toFixed(1),
        }
      : null,
    target: prevInnings ? prevInnings.totalRuns + 1 : null,
    striker,
    nonStriker,
    bowler,
    lastUpdated: new Date().toISOString(),
  }
}

export async function liveRoutes(app: FastifyInstance) {
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

  // ─── 4. Overlay live data (cached 10s) ───────────────────────────────────
  app.get('/matches/:matchId/overlay', async (request, reply) => {
    const { matchId } = request.params as { matchId: string }

    const cached = await redis.get(`live:overlay:${matchId}`)
    if (cached) {
      return reply.send({ success: true, data: JSON.parse(cached) })
    }

    const overlay = await buildOverlay(matchId)
    if (!overlay) {
      return reply.code(404).send({
        success: false,
        error: { code: 'MATCH_NOT_FOUND', message: 'Match not found' },
      })
    }

    await redis.setex(`live:overlay:${matchId}`, 10, JSON.stringify(overlay))
    return reply.send({ success: true, data: overlay })
  })

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
    await redis.del(`live:overlay:${body.matchId}`)

    return reply.send({ success: true, data: { stopped: true } })
  })

  // ─── Bonus: session status (admin panel polling) ──────────────────────────
  app.get('/session/:matchId', async (request, reply) => {
    const { matchId } = request.params as { matchId: string }
    const raw = await redis.get(sessionKey(matchId))
    return reply.send({ success: true, data: raw ? JSON.parse(raw) : null })
  })
}
