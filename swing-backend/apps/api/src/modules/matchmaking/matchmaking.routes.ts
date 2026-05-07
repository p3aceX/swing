import { FastifyInstance } from 'fastify'
import { z } from 'zod'
import { MatchmakingService, MatchmakingFormat } from './matchmaking.service'
import { AppError } from '../../lib/errors'

export async function matchmakingRoutes(app: FastifyInstance) {
  const svc = new MatchmakingService()
  const auth = { onRequest: [(app as any).authenticate] }

  // 'ANY' is the Discover-flow "All formats" wildcard — accepted on create
  // + filter; service matching treats it as match-all.
  const formatSchema = z.enum(['T10', 'T20', 'ODI', 'Test', 'Custom', 'ANY'])

  app.get('/grounds', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = z.object({
      q: z.string().optional(),
      date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
      format: formatSchema,
      teamId: z.string().optional(),
      overs: z.coerce.number().int().min(1).max(100).optional(),
    }).parse(request.query)
    const data = await svc.searchGrounds(user.userId, {
      q: q.q,
      date: q.date,
      format: q.format as MatchmakingFormat,
      teamId: q.teamId,
      overs: q.overs,
    })
    return reply.send({ success: true, data })
  })

  app.post('/lobbies', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const ballTypeSchema = z.enum(['LEATHER', 'TENNIS', 'TAPE', 'RUBBER']).optional()
    const timeWindowVal = z.enum(['MORNING', 'AFTERNOON', 'EVENING', 'NIGHT', 'LATE_NIGHT'])
    const body = z.object({
      teamId: z.string(),
      format: formatSchema,
      ballType: ballTypeSchema,
      date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
      // Picks are optional now — when omitted, the lobby is a preference-lobby
      // (windowsRanked/timeWindow becomes required in that case; validated in service).
      picks: z.array(z.object({
        groundId: z.string(),
        slotTime: z.string().regex(/^\d{2}:\d{2}$/),
      })).max(3).optional(),
      // V2 ranked preferences (preferred). Order = preference; first is strongest.
      windowsRanked: z.array(timeWindowVal).min(1).optional(),
      groundsRanked: z.array(z.string()).max(3).optional(),
      // Back-compat: old clients submit `timeWindow` (single) or `timeWindows`
      // (multi, unranked). When `windowsRanked` is absent, normalise from
      // these into a ranked array.
      timeWindow: timeWindowVal.optional(),
      timeWindows: z.array(timeWindowVal).optional(),
      preferredArenaId: z.string().optional(),
      preferredArenaIds: z.array(z.string()).max(3).optional(),
    }).parse(request.body)

    const windowsRanked = body.windowsRanked
      ?? (body.timeWindows && body.timeWindows.length > 0
        ? body.timeWindows
        : (body.timeWindow ? [body.timeWindow] : []))
    const groundsRanked = body.groundsRanked
      ?? body.preferredArenaIds
      ?? (body.preferredArenaId ? [body.preferredArenaId] : [])

    const data = await svc.createLobby(user.userId, {
      teamId: body.teamId,
      format: body.format as MatchmakingFormat,
      ballType: body.ballType ?? null,
      date: body.date,
      picks: body.picks ?? [],
      timeWindow: body.timeWindow ?? null,
      windowsRanked,
      preferredArenaId: body.preferredArenaId ?? null,
      preferredArenaIds: body.preferredArenaIds ?? [],
      groundsRanked,
    })
    return reply.code(201).send({ success: true, data })
  })

  app.get('/lobbies/active', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const data = await svc.getMyActiveLobby(user.userId)
    return reply.send({ success: true, data })
  })

  // Returns which time-window buckets have at least one matching arena
  // (by operating hours overlap) for the given date. Used by the Discover
  // Setup "When" step to hide impossible chips (e.g. NIGHT in cities
  // without floodlit grounds).
  //
  // arenaIds (comma-separated) optionally narrows to a specific set of
  // grounds the user pre-picked; omit for all active arenas.
  app.get('/available-buckets', auth, async (request, reply) => {
    const q = z.object({
      date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
      arenaIds: z.string().optional(),
      format: z.string().optional(),
    }).parse(request.query)
    const ids = q.arenaIds
      ? q.arenaIds.split(',').filter((s) => s.length > 0)
      : []
    const data = await svc.availableBuckets(q.date, ids, q.format)
    return reply.send({ success: true, data })
  })

  // Discover-flow: returns one active lobby per team the caller belongs to.
  // Used by the team-switcher chip to show which of the user's teams are
  // currently searching.
  app.get('/lobbies/active-all', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const data = await svc.listMyActiveLobbies(user.userId)
    return reply.send({ success: true, data })
  })

  // Discover-flow: ensures the team's active lobby (find/update/create), runs
  // a scored search across open lobbies, returns ranked closest + alternatives.
  app.post('/discover', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const ballTypeSchema = z.enum(['LEATHER', 'TENNIS', 'TAPE', 'RUBBER']).optional()
    const timeWindowVal = z.enum(['MORNING', 'AFTERNOON', 'EVENING', 'NIGHT', 'LATE_NIGHT'])
    const body = z.object({
      teamId: z.string(),
      filters: z.object({
        date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
        format: formatSchema,
        ballType: ballTypeSchema,
        // V2 ranked arrays (preferred). At least one window required when
        // windowsRanked is supplied; groundsRanked is up to 3 (empty = any).
        windowsRanked: z.array(timeWindowVal).min(1).optional(),
        groundsRanked: z.array(z.string()).max(3).optional(),
        // Legacy unranked / single-pref fallbacks. Normalised into
        // windowsRanked / groundsRanked below.
        timeWindow: timeWindowVal.optional(),
        timeWindows: z.array(timeWindowVal).optional(),
        preferredArenaId: z.string().optional(),
        preferredArenaIds: z.array(z.string()).max(3).optional(),
      }),
      context: z
        .object({
          lat: z.number().optional(),
          lng: z.number().optional(),
        })
        .optional(),
    }).parse(request.body)

    const f = body.filters
    const windowsRanked = f.windowsRanked
      ?? (f.timeWindows && f.timeWindows.length > 0
        ? f.timeWindows
        : (f.timeWindow ? [f.timeWindow] : []))
    if (windowsRanked.length === 0) {
      throw new AppError(
        'INVALID_INPUT',
        'At least one time window is required',
        400,
      )
    }
    const groundsRanked = f.groundsRanked
      ?? f.preferredArenaIds
      ?? (f.preferredArenaId ? [f.preferredArenaId] : [])

    const data = await svc.discoverLobbies(user.userId, {
      teamId: body.teamId,
      filters: {
        date: f.date,
        format: f.format as MatchmakingFormat,
        ballType: f.ballType ?? null,
        windowsRanked,
        groundsRanked,
        // Pass-through legacy fields for any service-side back-compat reads.
        timeWindows: windowsRanked,
        preferredArenaId: f.preferredArenaId ?? (groundsRanked[0] ?? null),
        preferredArenaIds: groundsRanked,
      },
      context: body.context,
    })
    return reply.send({ success: true, data })
  })

  app.get('/lobbies/:lobbyId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { lobbyId } = request.params as { lobbyId: string }
    const data = await svc.getLobbyStatus(user.userId, lobbyId)
    return reply.send({ success: true, data })
  })

  app.get('/lobbies/:lobbyId/stream', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { lobbyId } = request.params as { lobbyId: string }
    await svc.assertLobbyOwnership(user.userId, lobbyId)

    reply.raw.setHeader('Content-Type', 'text/event-stream')
    reply.raw.setHeader('Cache-Control', 'no-cache')
    reply.raw.setHeader('Connection', 'keep-alive')
    reply.raw.flushHeaders?.()

    const write = async () => {
      const payload = await svc.getLobbyStatus(user.userId, lobbyId)
      reply.raw.write(`data: ${JSON.stringify(payload)}\n\n`)
    }

    await write()
    const timer = setInterval(() => void write(), 5000)
    request.raw.on('close', () => {
      clearInterval(timer)
      reply.raw.end()
    })
  })

  app.get('/lobbies', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const timeWindowSchema = z.enum(['MORNING', 'AFTERNOON', 'EVENING', 'NIGHT', 'LATE_NIGHT']).optional()
    const q = z.object({
      date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
      format: formatSchema.optional(),
      ageGroup: z.string().optional(),
      arenaId: z.string().optional(),
      // Discover-flow filters (additive — old callers ignore these):
      timeWindow: timeWindowSchema,
      preferredArenaId: z.string().optional(),
    }).parse(request.query)
    const data = await svc.listOpenLobbies(user.userId, {
      date: q.date,
      format: q.format as MatchmakingFormat | undefined,
      ageGroup: q.ageGroup,
      arenaId: q.arenaId,
      timeWindow: q.timeWindow,
      preferredArenaId: q.preferredArenaId,
    })
    return reply.send({ success: true, data })
  })

  app.post('/lobbies/:lobbyId/join', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { lobbyId } = request.params as { lobbyId: string }
    const body = z.object({ teamId: z.string() }).parse(request.body)
    try {
      const data = await svc.joinOpenLobby(user.userId, lobbyId, body.teamId)
      return reply.code(201).send({ success: true, data })
    } catch (err) {
      // eslint-disable-next-line no-console
      console.error('[matchmaking] joinOpenLobby error:', err)
      throw err
    }
  })

  app.post('/lobbies/:lobbyId/accept', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { lobbyId } = request.params as { lobbyId: string }
    const body = z.object({ arenaId: z.string(), slotTime: z.string().optional() }).parse(request.body)
    const data = await svc.acceptLobbyAsOwner(user.userId, lobbyId, body.arenaId, body.slotTime)
    return reply.send({ success: true, data })
  })

  app.post('/lobbies/:lobbyId/assign', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { lobbyId } = request.params as { lobbyId: string }
    const body = z.object({ teamId: z.string(), teamName: z.string().optional() }).parse(request.body)
    const data = await svc.assignOpponentToLobby(user.userId, lobbyId, body)
    return reply.code(201).send({ success: true, data })
  })

  app.post('/matches/:matchId/confirm', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { matchId } = request.params as { matchId: string }
    const body = z.object({ lobbyId: z.string() }).parse(request.body)
    const data = await svc.confirmMatchLobby(user.userId, matchId, body.lobbyId)
    return reply.send({ success: true, data })
  })

  app.post('/matches/:matchId/decline', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { matchId } = request.params as { matchId: string }
    const body = z.object({ lobbyId: z.string() }).parse(request.body)
    const data = await svc.declineMatchLobby(user.userId, matchId, body.lobbyId)
    return reply.send({ success: true, data })
  })

  app.delete('/lobbies/:lobbyId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { lobbyId } = request.params as { lobbyId: string }
    await svc.leaveLobby(user.userId, lobbyId)
    return reply.code(204).send()
  })

  app.get('/matches', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const q = z.object({ arenaId: z.string().optional() }).parse(request.query)
    const data = q.arenaId
      ? await svc.listArenaMatches(user.userId, q.arenaId)
      : await svc.listMyConfirmedMatches(user.userId)
    return reply.send({ success: true, data })
  })

  // Player-side free-confirm. Used when the match's confirmation fee is 0
  // (test mode) so the opponent can finalize without Razorpay.
  app.post('/matches/:matchId/confirm-free', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { matchId } = request.params as { matchId: string }
    const body = z.object({ lobbyId: z.string() }).parse(request.body)
    const data = await svc.confirmMatchFree(user.userId, matchId, body.lobbyId)
    return reply.send({ success: true, data })
  })

  app.post('/matches/:matchId/mark-paid', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { matchId } = request.params as { matchId: string }
    const body = z.object({ lobbyId: z.string() }).parse(request.body)
    console.log('[mark-paid] userId=%s matchId=%s lobbyId=%s', user.userId, matchId, body.lobbyId)
    try {
      const data = await svc.markMatchPaidOffline(user.userId, matchId, body.lobbyId)
      console.log('[mark-paid] success:', data)
      return reply.send({ success: true, data })
    } catch (err: any) {
      console.error('[mark-paid] ERROR code=%s msg=%s', err.code, err.message, err)
      throw err
    }
  })

  // Arena owner: cancel (delete) a matchmaking match at their venue
  app.delete('/matches/:matchId', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { matchId } = request.params as { matchId: string }
    const data = await svc.cancelMatchAsArenaOwner(user.userId, matchId)
    return reply.send({ success: true, data })
  })

  // Player: cancel an active match-up (own team's side). Refuses MATCH_IN_PROGRESS.
  // Response includes wasPostPayment so the client can warn before submit.
  app.post('/matches/:matchId/cancel-by-player', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { matchId } = request.params as { matchId: string }
    const body = z.object({ lobbyId: z.string() }).parse(request.body)
    const data = await svc.cancelMatchAsPlayer(user.userId, matchId, body.lobbyId)
    return reply.send({ success: true, data })
  })

  // Arena owner: start match once both advances received. Returns linkedMatchId
  // so client can navigate scorer to the scoring screen.
  app.post('/matches/:matchId/start', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { matchId } = request.params as { matchId: string }
    const data = await svc.startMatchAsArenaOwner(user.userId, matchId)
    return reply.send({ success: true, data })
  })

  // ── Plan B / V2 — first-to-pay matchmaking ───────────────────────────────

  // B5 surface: arena owner views all interests on a lobby. Used by the biz
  // Find Team Manage sheet.
  app.get('/lobbies/:lobbyId/interests', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { lobbyId } = request.params as { lobbyId: string }
    const data = await svc.listLobbyInterestsAsArenaOwner(user.userId, lobbyId)
    return reply.send({ success: true, data })
  })

  // B1: Player expresses interest in an open lobby. Idempotent per (lobby,team).
  app.post('/lobbies/:lobbyId/express-interest', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { lobbyId } = request.params as { lobbyId: string }
    const body = z.object({ teamId: z.string().min(1) }).parse(request.body)
    const data = await svc.expressInterest(user.userId, lobbyId, body.teamId)
    return reply.code(201).send({ success: true, data })
  })

  // B2: Acquire 120s payment lock + create Razorpay order. LOCK_TAKEN if
  // another team already holds the slot.
  app.post('/interests/:interestId/lock-and-pay', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { interestId } = request.params as { interestId: string }
    const data = await svc.acquireLockAndCreateOrder(user.userId, interestId)
    return reply.send({ success: true, data })
  })

  // B3: Verify Razorpay payment → promote winner, create match, mark losers.
  app.post('/interests/:interestId/verify-payment', auth, async (request, reply) => {
    const user = (request as any).user as { userId: string }
    const { interestId } = request.params as { interestId: string }
    const body = z.object({
      razorpayOrderId: z.string().min(1),
      razorpayPaymentId: z.string().min(1),
      razorpaySignature: z.string().min(1),
    }).parse(request.body)
    const data = await svc.verifyInterestPayment(
      user.userId,
      interestId,
      body.razorpayOrderId,
      body.razorpayPaymentId,
      body.razorpaySignature,
    )
    return reply.send({ success: true, data })
  })

  // B3 housekeeping: idempotent sweep of expired interest locks. Called by a
  // BullMQ delayed job / cron — also exposed for manual recovery.
  app.post('/interests/release-expired-locks', auth, async (_request, reply) => {
    const data = await svc.releaseExpiredInterestLocks()
    return reply.send({ success: true, data })
  })
}
