import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import {
  completeMatchRequestSchema,
  createMatchRequestSchema,
  inningsStateRequestSchema,
  recordBallRequestSchema,
  tossRequestSchema,
} from '@swing/contracts'
import { MatchService } from './match.service'
import { ViewTrackingService } from '../player/view-tracking.service'

export async function matchRoutes(app: FastifyInstance) {
  const svc = new MatchService()
  const viewTrackingSvc = new ViewTrackingService()
  const auth = { onRequest: [(app as any).authenticate] }

  app.post('/', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const body = createMatchRequestSchema.parse(request.body)
    return reply.code(201).send({ success: true, data: await svc.createMatch(user.userId, body) })
  })

  app.post('/:id/toss', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = tossRequestSchema.parse(request.body)
    return reply.send({ success: true, data: await svc.recordToss(id, user.userId, body.tossWonBy, body.tossDecision) })
  })

  app.post('/:id/start', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.startMatch(id, user.userId) })
  })

  app.patch('/:id/overs', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const { customOvers } = z.object({ customOvers: z.number().int().positive() }).parse(request.body)
    return reply.send({ success: true, data: await svc.updateMatchOvers(id, user.userId, customOvers) })
  })

  app.patch('/:id/cancel', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.cancelMatch(id, user.userId) })
  })

  app.delete('/:id', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.deleteMatch(id, user.userId) })
  })

  app.patch('/:id/scorer', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = z
      .object({
        scorerId: z.string().min(1),
      })
      .parse(request.body)
    return reply.send({
      success: true,
      data: await svc.updateScorer(id, user.userId, body.scorerId),
    })
  })

  app.post('/:id/innings/:num/ball', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id, num } = request.params as { id: string; num: string }
    const body = recordBallRequestSchema.parse(request.body)
    return reply.send({ success: true, data: await svc.recordBall(id, Number(num), user.userId, body) })
  })

  app.delete('/:id/innings/:num/last-ball', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id, num } = request.params as { id: string; num: string }
    return reply.send({ success: true, data: await svc.undoLastBall(id, Number(num), user.userId) })
  })

  app.post('/:id/innings/:num/complete', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id, num } = request.params as { id: string; num: string }
    return reply.send({ success: true, data: await svc.completeInnings(id, Number(num), user.userId) })
  })

  // Alias for UI intent wording: "Declare Innings"
  app.post('/:id/innings/:num/declare', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id, num } = request.params as { id: string; num: string }
    return reply.send({ success: true, data: await svc.completeInnings(id, Number(num), user.userId) })
  })

  // Continue next innings in TWO_INNINGS / TEST flow when follow-on is not enforced
  app.post('/:id/continue-innings', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.continueInnings(id, user.userId) })
  })

  // Resume batting by reopening a completed innings
  app.post('/:id/innings/:num/reopen', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id, num } = request.params as { id: string; num: string }
    return reply.send({ success: true, data: await svc.reopenInnings(id, Number(num), user.userId) })
  })

  app.post('/:id/complete', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const body = completeMatchRequestSchema.parse(request.body)
    return reply.send({ success: true, data: await svc.completeMatch(id, user.userId, body.winnerId, body.winMargin) })
  })

  app.patch('/:id/innings/:num/state', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id, num } = request.params as { id: string; num: string }
    const body = inningsStateRequestSchema.parse(request.body)
    return reply.send({ success: true, data: await svc.setInningsState(id, Number(num), user.userId, body) })
  })

  app.post('/:id/followon', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.enforceFollowOn(id, user.userId) })
  })

  app.post('/:id/superover', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.createSuperOver(id, user.userId) })
  })

  app.get('/:id', async (request, reply) => {
    const { id } = request.params as { id: string }
    const user = (request as any).user as { userId: string } | undefined
    const data = await svc.getMatch(id)
    viewTrackingSvc.trackMatchView(id, user?.userId ?? null).catch(() => {})
    return reply.send({ success: true, data })
  })

  // ── Match Preview ──────────────────────────────────────────────────────────
  app.get('/:id/preview', async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getPreview(id) })
  })

  // ── Scorecard: live-computed from ball events ──────────────────────────────
  app.get('/:id/scorecard', async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getScorecard(id) })
  })

  // ── Key Highlights ─────────────────────────────────────────────────────────
  app.get('/:id/highlights', async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getHighlights(id) })
  })

  // ── Ball-by-ball commentary ────────────────────────────────────────────────
  app.get('/:id/commentary', async (request, reply) => {
    const { id } = request.params as { id: string }
    const q = request.query as { innings?: string; over?: string; limit?: string; offset?: string }
    return reply.send({
      success: true,
      data: await svc.getCommentary(id, {
        inningsNum: q.innings !== undefined ? Number(q.innings) : undefined,
        overNum: q.over !== undefined ? Number(q.over) : undefined,
        limit: q.limit !== undefined ? Number(q.limit) : undefined,
        offset: q.offset !== undefined ? Number(q.offset) : undefined,
      }),
    })
  })

  // ── Match Analysis: over stats + wagon wheel ──────────────────────────────
  app.get('/:id/analysis', async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getAnalysis(id) })
  })

  app.get('/:id/players', auth, async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getPlayers(id) })
  })

  app.get('/:id/innings/:num/over/:overNum', async (request, reply) => {
    const { id, num, overNum } = request.params as { id: string; num: string; overNum: string }
    return reply.send({ success: true, data: await svc.getOverSummary(id, Number(num), Number(overNum)) })
  })

  app.post('/:id/verify', auth, async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.verifyMatch(id) })
  })

  app.get('/recommended', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { limit } = z
      .object({
        limit: z.coerce.number().int().min(1).max(50).default(10),
      })
      .parse(request.query)

    return reply.send({
      success: true,
      data: await svc.getRecommendedMatches(user.userId, limit),
    })
  })

  app.post('/schedule', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const teamSchema = z.object({
      playerIds: z.array(z.string()),
      captainId: z.string().nullable().optional(),
      viceCaptainId: z.string().nullable().optional(),
      wicketKeeperId: z.string().nullable().optional(),
      impactPlayerId: z.string().nullable().optional(),
    })

    const body = z
      .object({
        matchType: z.enum(['FRIENDLY', 'COMPETITIVE', 'RANKED']),
        format: z.enum(['T10', 'T20', 'ONE_DAY', 'TWO_INNINGS', 'BOX_CRICKET', 'CUSTOM', 'TEST']),
        ballType: z.string(),
        scheduledAt: z.string(),
        venueName: z.string().nullable().optional(),
        facilityId: z.string().nullable().optional(),
        tournamentId: z.string().nullable().optional(),
        hasImpactPlayer: z.boolean().optional(),
        teamAName: z.string(),
        teamBName: z.string(),
        teamAId: z.string().optional(),
        teamA: teamSchema.optional(),
        teamB: teamSchema.optional(),
      })
      .parse(request.body)

    const match = await svc.scheduleMatch(user.userId, body)
    return reply.code(201).send({
      success: true,
      data: {
        id: match.id,
        status: match.status,
        scheduledAt: match.scheduledAt,
        teamAName: match.teamAName,
        teamBName: match.teamBName,
        format: match.format,
        venueName: match.venueName,
      },
    })
  })

  app.put('/:id/players', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { id } = request.params as { id: string }
    const teamSchema = z.object({
      playerIds: z.array(z.string()),
      captainId: z.string().nullable().optional(),
      viceCaptainId: z.string().nullable().optional(),
      wicketKeeperId: z.string().nullable().optional(),
      impactPlayerId: z.string().nullable().optional(),
    })

    const body = z
      .object({
        teamA: teamSchema,
        teamB: teamSchema,
      })
      .parse(request.body)

    const data = await svc.updateMatchPlayers(id, user.userId, body)
    return reply.send({ success: true, data })
  })
}
