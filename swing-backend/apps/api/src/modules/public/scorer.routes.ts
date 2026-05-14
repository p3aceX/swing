import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify'
import { z } from 'zod'
import { prisma } from '@swing/db'
import {
  completeMatchRequestSchema,
  inningsStateRequestSchema,
  recordBallRequestSchema,
} from '@swing/contracts'
import { MatchService } from '../matches/match.service'
import { signScorerToken, verifyScorerToken } from '../../lib/scorer-token'
import { AppError, Errors } from '../../lib/errors'

// Public scorer routes — used by the swing-web /score page so anyone with
// a match's liveCode + livePin can score from a phone browser without
// installing the Flutter app. Additive: every mutation goes through the
// exact same `MatchService` methods the in-app flow uses, so scoring
// logic stays single-sourced.

type ScorerActor = { userId: string; matchId: string }

async function resolveScorerActor(matchId: string): Promise<ScorerActor> {
  // Resolve a real userId to pass into `MatchService.authorizeMutation`.
  // The pin has already authenticated the caller, so we delegate to the
  // strongest role on the match: prefer the active scorer (matches the
  // in-app "who is currently scoring" notion), then the assigned scorer,
  // then fall back to the OWNER via MatchRole.
  const match = await prisma.match.findUnique({
    where: { id: matchId },
    select: { id: true, scorerId: true, activeScorerId: true },
  })
  if (!match) throw Errors.notFound('Match')

  const candidateProfileId = match.activeScorerId ?? match.scorerId ?? null
  if (candidateProfileId) {
    const profile = await prisma.playerProfile.findUnique({
      where: { id: candidateProfileId },
      select: { userId: true },
    })
    if (profile?.userId) return { userId: profile.userId, matchId }
  }

  const ownerRole = await prisma.matchRole.findFirst({
    where: { matchId, role: 'OWNER' },
    select: { profileId: true },
  })
  if (ownerRole?.profileId) {
    const owner = await prisma.playerProfile.findUnique({
      where: { id: ownerRole.profileId },
      select: { userId: true },
    })
    if (owner?.userId) return { userId: owner.userId, matchId }
  }

  throw new AppError(
    'SCORER_NO_ACTOR',
    'Match has no owner or scorer to attribute writes to.',
    409,
  )
}

function extractBearer(request: FastifyRequest): string | null {
  const header = request.headers.authorization ?? request.headers.Authorization
  if (!header || typeof header !== 'string') return null
  const [scheme, token] = header.split(' ')
  if (scheme?.toLowerCase() !== 'bearer' || !token) return null
  return token.trim()
}

async function scorerGuard(request: FastifyRequest, reply: FastifyReply) {
  const token = extractBearer(request)
  if (!token) {
    return reply.code(401).send({
      success: false,
      error: { code: 'SCORER_UNAUTHORIZED', message: 'Missing scorer token' },
    })
  }
  let payload
  try {
    payload = verifyScorerToken(token)
  } catch {
    return reply.code(401).send({
      success: false,
      error: { code: 'SCORER_UNAUTHORIZED', message: 'Invalid or expired scorer token' },
    })
  }
  const params = request.params as { id?: string }
  if (params?.id && params.id !== payload.matchId) {
    return reply.code(403).send({
      success: false,
      error: { code: 'SCORER_SCOPE_MISMATCH', message: 'Scorer token is scoped to a different match' },
    })
  }
  ;(request as any).scorer = payload
}

export async function publicScorerRoutes(app: FastifyInstance) {
  const svc = new MatchService()
  const guard = { preHandler: scorerGuard }

  // ── Auth ─────────────────────────────────────────────────────────────────
  // POST /public/scorer/auth — { liveCode, livePin } → { token, matchId, expiresIn }
  app.post('/auth', async (request, reply) => {
    const body = z.object({
      liveCode: z.string().trim().min(3).max(32),
      livePin: z.string().trim().min(3).max(32),
    }).parse(request.body)

    // Codes are issued lowercase (`swing#1234`) but we accept any casing
    // a user might paste from a share message.
    const raw = body.liveCode
    const match = await prisma.match.findFirst({
      where: {
        OR: [
          { liveCode: raw },
          { liveCode: raw.toLowerCase() },
          { liveCode: raw.toUpperCase() },
          { id: raw },
        ],
      },
      select: { id: true, livePin: true },
    })

    if (!match || !match.livePin) {
      return reply.code(401).send({
        success: false,
        error: { code: 'INVALID_CREDENTIALS', message: 'Match ID or PIN is incorrect' },
      })
    }
    if (match.livePin !== body.livePin) {
      return reply.code(401).send({
        success: false,
        error: { code: 'INVALID_CREDENTIALS', message: 'Match ID or PIN is incorrect' },
      })
    }

    const token = signScorerToken({ kind: 'scorer', matchId: match.id })
    return reply.send({
      success: true,
      data: { token, matchId: match.id, expiresIn: 4 * 60 * 60 },
    })
  })

  // ── Reads ────────────────────────────────────────────────────────────────
  // Mirror what the Flutter scoring screen pulls on load.
  app.get('/match/:id', guard, async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getMatch(id) })
  })

  app.get('/match/:id/players', guard, async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getPlayers(id) })
  })

  app.get('/match/:id/scorecard', guard, async (request, reply) => {
    const { id } = request.params as { id: string }
    return reply.send({ success: true, data: await svc.getScorecard(id) })
  })

  // ── Mutations ────────────────────────────────────────────────────────────
  // Thin wrappers — every call delegates to the existing service method
  // the in-app flow uses. No new scoring logic.
  app.post('/match/:id/innings/:num/ball', guard, async (request, reply) => {
    const { id, num } = request.params as { id: string; num: string }
    const actor = await resolveScorerActor(id)
    const body = recordBallRequestSchema.parse(request.body)
    return reply.send({
      success: true,
      data: await svc.recordBall(id, Number(num), actor.userId, body),
    })
  })

  app.delete('/match/:id/innings/:num/last-ball', guard, async (request, reply) => {
    const { id, num } = request.params as { id: string; num: string }
    const actor = await resolveScorerActor(id)
    return reply.send({
      success: true,
      data: await svc.undoLastBall(id, Number(num), actor.userId),
    })
  })

  app.post('/match/:id/innings/:num/reopen', guard, async (request, reply) => {
    const { id, num } = request.params as { id: string; num: string }
    const actor = await resolveScorerActor(id)
    return reply.send({
      success: true,
      data: await svc.reopenInnings(id, Number(num), actor.userId),
    })
  })

  app.post('/match/:id/innings/:num/complete', guard, async (request, reply) => {
    const { id, num } = request.params as { id: string; num: string }
    const actor = await resolveScorerActor(id)
    return reply.send({
      success: true,
      data: await svc.completeInnings(id, Number(num), actor.userId),
    })
  })

  app.patch('/match/:id/innings/:num/state', guard, async (request, reply) => {
    const { id, num } = request.params as { id: string; num: string }
    const actor = await resolveScorerActor(id)
    const body = inningsStateRequestSchema.parse(request.body)
    return reply.send({
      success: true,
      data: await svc.setInningsState(id, Number(num), actor.userId, body),
    })
  })

  app.post('/match/:id/complete', guard, async (request, reply) => {
    const { id } = request.params as { id: string }
    const actor = await resolveScorerActor(id)
    const body = completeMatchRequestSchema.parse(request.body)
    return reply.send({
      success: true,
      data: await svc.completeMatch(id, actor.userId, body.winnerId, body.winMargin),
    })
  })
}
