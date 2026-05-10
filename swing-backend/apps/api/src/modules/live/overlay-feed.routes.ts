import type { FastifyInstance, FastifyRequest } from 'fastify'
import { prisma } from '@swing/db'
import { redis } from '../../lib/redis'
import { requireOverlayToken } from '../../lib/overlay-token'

const BOOTSTRAP_CACHE_TTL = 60 // seconds
const TICK_INTERVAL_MS = 1000
const TICK_HEARTBEAT_MS = 15000

const bootstrapCacheKey = (matchId: string) => `live:overlay:bootstrap:${matchId}`

// ─── Bootstrap (heavy snapshot) ──────────────────────────────────────────────

async function buildBootstrap(matchId: string) {
  const match = await prisma.match.findUnique({
    where: { id: matchId },
    select: {
      id: true,
      matchType: true,
      format: true,
      status: true,
      teamAName: true,
      teamBName: true,
      teamAId: true,
      teamBId: true,
      teamAPlayerIds: true,
      teamBPlayerIds: true,
      teamACaptainId: true,
      teamBCaptainId: true,
      teamAViceCaptainId: true,
      teamBViceCaptainId: true,
      teamAWicketKeeperId: true,
      teamBWicketKeeperId: true,
      tossWonBy: true,
      tossDecision: true,
      scheduledAt: true,
      startedAt: true,
      completedAt: true,
      venueName: true,
      ballType: true,
      customOvers: true,
      tournamentId: true,
      winnerId: true,
      winMargin: true,
    },
  })
  if (!match) return null

  const [teamA, teamB, tournament] = await Promise.all([
    match.teamAId
      ? prisma.team.findUnique({ where: { id: match.teamAId } })
      : prisma.team.findFirst({
          where: { name: { equals: match.teamAName, mode: 'insensitive' } },
        }),
    match.teamBId
      ? prisma.team.findUnique({ where: { id: match.teamBId } })
      : prisma.team.findFirst({
          where: { name: { equals: match.teamBName, mode: 'insensitive' } },
        }),
    match.tournamentId
      ? prisma.tournament.findUnique({
          where: { id: match.tournamentId },
          select: { id: true, name: true, logoUrl: true, format: true },
        })
      : null,
  ])

  const allPlayerIds = [...match.teamAPlayerIds, ...match.teamBPlayerIds]
  const players = allPlayerIds.length
    ? await prisma.playerProfile.findMany({
        where: { id: { in: allPlayerIds } },
        include: {
          user: { select: { name: true, avatarUrl: true } },
        },
      })
    : []

  // competitive_profile is optional — the table may be missing on some
  // environments (DB drift). Fetch it best-effort and degrade gracefully.
  let competitiveByPlayerId = new Map<
    string,
    {
      currentRankKey: string
      currentDivision: number
      lifetimeImpactPoints: number
      rankProgressPoints: number
      winStreak: number
      mvpCount: number
      hasPremiumPass: boolean
    }
  >()
  if (allPlayerIds.length) {
    try {
      const competitive = await prisma.playerCompetitiveProfile.findMany({
        where: { playerId: { in: allPlayerIds } },
        select: {
          playerId: true,
          currentRankKey: true,
          currentDivision: true,
          lifetimeImpactPoints: true,
          rankProgressPoints: true,
          winStreak: true,
          mvpCount: true,
          hasPremiumPass: true,
        },
      })
      competitiveByPlayerId = new Map(
        competitive.map((c) => [c.playerId, c]),
      )
    } catch (e) {
      // Table missing or column drift — skip rank info. Logged for ops.
      // eslint-disable-next-line no-console
      console.warn('[overlay-feed] competitiveProfile fetch failed:', e instanceof Error ? e.message : e)
    }
  }

  const playerById = new Map(
    players.map((p) => [
      p.id,
      { ...p, competitiveProfile: competitiveByPlayerId.get(p.id) ?? null },
    ]),
  )

  const buildPlayer = (
    id: string,
    teamSide: 'A' | 'B',
    captaincy: { captain: string | null; vice: string | null; keeper: string | null },
  ) => {
    const p = playerById.get(id)
    if (!p) {
      return {
        id,
        teamSide,
        name: 'Unknown',
        username: null,
        photoUrl: null,
        jerseyNumber: null,
        role: null,
        battingStyle: null,
        bowlingStyle: null,
        isCaptain: id === captaincy.captain,
        isViceCaptain: id === captaincy.vice,
        isWicketKeeper: id === captaincy.keeper,
        career: null,
        swing: null,
        rank: null,
      }
    }
    return {
      id: p.id,
      teamSide,
      name: p.user.name,
      username: p.username,
      photoUrl: p.user.avatarUrl,
      jerseyNumber: p.jerseyNumber,
      role: p.playerRole,
      battingStyle: p.battingStyle,
      bowlingStyle: p.bowlingStyle,
      isCaptain: p.id === captaincy.captain,
      isViceCaptain: p.id === captaincy.vice,
      isWicketKeeper: p.id === captaincy.keeper,
      career: {
        matchesPlayed: p.matchesPlayed,
        matchesWon: p.matchesWon,
        runs: p.totalRuns,
        ballsFaced: p.totalBallsFaced,
        highestScore: p.highestScore,
        fifties: p.fifties,
        hundreds: p.hundreds,
        fours: p.fours,
        sixes: p.sixes,
        battingAverage: p.battingAverage,
        strikeRate: p.strikeRate,
        wickets: p.totalWickets,
        oversBowled: p.totalOversBowled,
        bestBowling: p.bestBowling,
        fiveWicketHauls: p.fiveWicketHauls,
        bowlingAverage: p.bowlingAverage,
        economyRate: p.economyRate,
        bowlingStrikeRate: p.bowlingStrikeRate,
      },
      swing: {
        index: p.swingIndex,
        batting: p.battingScore,
        bowling: p.bowlingScore,
        fielding: p.fieldingScore,
        fitness: p.fitnessScore,
        gameIntelligence: p.gameIntelligence,
        coachability: p.coachability,
      },
      rank: p.competitiveProfile
        ? {
            key: p.competitiveProfile.currentRankKey,
            division: p.competitiveProfile.currentDivision,
            lifetimeImpactPoints: p.competitiveProfile.lifetimeImpactPoints,
            rankProgressPoints: p.competitiveProfile.rankProgressPoints,
            winStreak: p.competitiveProfile.winStreak,
            mvpCount: p.competitiveProfile.mvpCount,
            hasPremiumPass: p.competitiveProfile.hasPremiumPass,
          }
        : null,
    }
  }

  const teamAPlayingXi = match.teamAPlayerIds.map((id) =>
    buildPlayer(id, 'A', {
      captain: match.teamACaptainId,
      vice: match.teamAViceCaptainId,
      keeper: match.teamAWicketKeeperId,
    }),
  )
  const teamBPlayingXi = match.teamBPlayerIds.map((id) =>
    buildPlayer(id, 'B', {
      captain: match.teamBCaptainId,
      vice: match.teamBViceCaptainId,
      keeper: match.teamBWicketKeeperId,
    }),
  )

  const tossDoneAt = match.tossWonBy && match.tossDecision ? match.startedAt : null

  return {
    match: {
      id: match.id,
      type: match.matchType,
      format: match.format,
      status: match.status,
      scheduledAt: match.scheduledAt,
      startedAt: match.startedAt,
      completedAt: match.completedAt,
      venue: match.venueName,
      ballType: match.ballType,
      customOvers: match.customOvers,
      winnerId: match.winnerId,
      winMargin: match.winMargin,
    },
    tournament: tournament
      ? { id: tournament.id, name: tournament.name, logoUrl: tournament.logoUrl, format: tournament.format }
      : null,
    toss: {
      done: !!(match.tossWonBy && match.tossDecision),
      wonBy: match.tossWonBy,
      decision: match.tossDecision,
      doneAt: tossDoneAt,
    },
    teamA: {
      id: teamA?.id ?? match.teamAId ?? null,
      name: match.teamAName,
      shortName: teamA?.shortName ?? null,
      logoUrl: teamA?.logoUrl ?? null,
      city: teamA?.city ?? null,
      motto: teamA?.motto ?? null,
      homeGround: teamA?.homeGroundName ?? null,
      foundedYear: teamA?.foundedYear ?? null,
      powerScore: teamA?.powerScore ?? null,
      credibilityScore: teamA?.credibilityScore ?? null,
      captainId: match.teamACaptainId,
      viceCaptainId: match.teamAViceCaptainId,
      wicketKeeperId: match.teamAWicketKeeperId,
      playingXi: teamAPlayingXi,
    },
    teamB: {
      id: teamB?.id ?? match.teamBId ?? null,
      name: match.teamBName,
      shortName: teamB?.shortName ?? null,
      logoUrl: teamB?.logoUrl ?? null,
      city: teamB?.city ?? null,
      motto: teamB?.motto ?? null,
      homeGround: teamB?.homeGroundName ?? null,
      foundedYear: teamB?.foundedYear ?? null,
      powerScore: teamB?.powerScore ?? null,
      credibilityScore: teamB?.credibilityScore ?? null,
      captainId: match.teamBCaptainId,
      viceCaptainId: match.teamBViceCaptainId,
      wicketKeeperId: match.teamBWicketKeeperId,
      playingXi: teamBPlayingXi,
    },
    generatedAt: new Date().toISOString(),
  }
}

// ─── Tick (live state — fast path) ───────────────────────────────────────────

async function buildTick(matchId: string) {
  const match = await prisma.match.findUnique({
    where: { id: matchId },
    select: {
      id: true,
      status: true,
      teamAName: true,
      teamBName: true,
      tossWonBy: true,
      tossDecision: true,
      winnerId: true,
      winMargin: true,
      innings: {
        orderBy: { inningsNumber: 'asc' },
        select: {
          id: true,
          inningsNumber: true,
          battingTeam: true,
          totalRuns: true,
          totalWickets: true,
          totalOvers: true,
          extras: true,
          isCompleted: true,
          isDeclared: true,
          currentStrikerId: true,
          currentNonStrikerId: true,
          currentBowlerId: true,
        },
      },
    },
  })
  if (!match) return null

  const currentInnings =
    match.innings.find((i) => !i.isCompleted) ??
    match.innings[match.innings.length - 1] ??
    null
  const prevInnings = match.innings.find((i) => i.isCompleted && i.inningsNumber === 1)

  // Fetch live ball events for the current innings + last 6 balls overall.
  const lastBalls = currentInnings
    ? await prisma.ballEvent.findMany({
        where: { inningsId: currentInnings.id },
        orderBy: [{ overNumber: 'desc' }, { ballNumber: 'desc' }],
        take: 6,
        select: {
          id: true,
          overNumber: true,
          ballNumber: true,
          batterId: true,
          nonBatterId: true,
          bowlerId: true,
          fielderId: true,
          outcome: true,
          runs: true,
          extras: true,
          totalRuns: true,
          isWicket: true,
          dismissalType: true,
          dismissedPlayerId: true,
          wagonZone: true,
          shotType: true,
          ballLine: true,
          ballLength: true,
          scoreAfterBall: true,
          scoredAt: true,
        },
      })
    : []

  const livePlayerIds = new Set<string>()
  if (currentInnings?.currentStrikerId) livePlayerIds.add(currentInnings.currentStrikerId)
  if (currentInnings?.currentNonStrikerId) livePlayerIds.add(currentInnings.currentNonStrikerId)
  if (currentInnings?.currentBowlerId) livePlayerIds.add(currentInnings.currentBowlerId)

  const liveStats = livePlayerIds.size
    ? await prisma.playerMatchStats.findMany({
        where: { matchId, playerProfileId: { in: [...livePlayerIds] } },
        select: {
          playerProfileId: true,
          runs: true,
          balls: true,
          fours: true,
          sixes: true,
          strikeRate: true,
          isOut: true,
          oversBowled: true,
          wickets: true,
          runsConceded: true,
          economy: true,
          wides: true,
          noBalls: true,
        },
      })
    : []
  const statsByPlayer = new Map(liveStats.map((s) => [s.playerProfileId, s]))

  const buildBatter = (id: string | null) => {
    if (!id) return null
    const s = statsByPlayer.get(id)
    return {
      playerId: id,
      runs: s?.runs ?? 0,
      balls: s?.balls ?? 0,
      fours: s?.fours ?? 0,
      sixes: s?.sixes ?? 0,
      strikeRate: s?.strikeRate ?? 0,
      isOut: s?.isOut ?? false,
    }
  }
  const buildBowler = (id: string | null) => {
    if (!id) return null
    const s = statsByPlayer.get(id)
    return {
      playerId: id,
      oversBowled: s?.oversBowled ?? 0,
      wickets: s?.wickets ?? 0,
      runsConceded: s?.runsConceded ?? 0,
      economy: s?.economy ?? 0,
      wides: s?.wides ?? 0,
      noBalls: s?.noBalls ?? 0,
    }
  }

  const target = prevInnings ? prevInnings.totalRuns + 1 : null
  let chase: {
    target: number
    runsNeeded: number
    ballsRemaining: number | null
    requiredRunRate: number | null
  } | null = null
  if (target && currentInnings && currentInnings.inningsNumber === 2) {
    const runsNeeded = Math.max(0, target - currentInnings.totalRuns)
    chase = {
      target,
      runsNeeded,
      ballsRemaining: null, // overs limit isn't passed here; bootstrap has format/customOvers
      requiredRunRate: null,
    }
  }

  return {
    matchId: match.id,
    status: match.status,
    toss: {
      done: !!(match.tossWonBy && match.tossDecision),
      wonBy: match.tossWonBy,
      decision: match.tossDecision,
    },
    inningsSummary: match.innings.map((i) => ({
      inningsNumber: i.inningsNumber,
      battingTeam: i.battingTeam,
      runs: i.totalRuns,
      wickets: i.totalWickets,
      overs: Number(i.totalOvers.toFixed(1)),
      isCompleted: i.isCompleted,
      isDeclared: i.isDeclared,
    })),
    current: currentInnings
      ? {
          inningsNumber: currentInnings.inningsNumber,
          battingTeam: currentInnings.battingTeam,
          runs: currentInnings.totalRuns,
          wickets: currentInnings.totalWickets,
          overs: Number(currentInnings.totalOvers.toFixed(1)),
          extras: currentInnings.extras,
          striker: buildBatter(currentInnings.currentStrikerId),
          nonStriker: buildBatter(currentInnings.currentNonStrikerId),
          bowler: buildBowler(currentInnings.currentBowlerId),
        }
      : null,
    chase,
    result:
      match.status === 'COMPLETED'
        ? { winnerId: match.winnerId, margin: match.winMargin }
        : null,
    lastBalls: lastBalls.reverse(),
    serverAt: new Date().toISOString(),
  }
}

// ─── Routes ──────────────────────────────────────────────────────────────────

export async function overlayFeedRoutes(app: FastifyInstance) {
  const overlayAuth = { preHandler: [requireOverlayToken] }

  // GET /live/matches/:matchId/bootstrap — heavy, cached 60s
  app.get(
    '/matches/:matchId/bootstrap',
    overlayAuth,
    async (request: FastifyRequest, reply) => {
      const { matchId } = request.params as { matchId: string }

      const cached = await redis.get(bootstrapCacheKey(matchId))
      if (cached) {
        return reply.send({ success: true, data: JSON.parse(cached), cached: true })
      }

      const data = await buildBootstrap(matchId)
      if (!data) {
        return reply.code(404).send({
          success: false,
          error: { code: 'MATCH_NOT_FOUND', message: 'Match not found' },
        })
      }

      await redis.setex(bootstrapCacheKey(matchId), BOOTSTRAP_CACHE_TTL, JSON.stringify(data))
      return reply.send({ success: true, data, cached: false })
    },
  )

  // GET /live/matches/:matchId/tick — SSE live state push
  app.get(
    '/matches/:matchId/tick',
    overlayAuth,
    async (request: FastifyRequest, reply) => {
      const { matchId } = request.params as { matchId: string }

      const initial = await buildTick(matchId)
      if (!initial) {
        return reply.code(404).send({
          success: false,
          error: { code: 'MATCH_NOT_FOUND', message: 'Match not found' },
        })
      }

      reply.raw.writeHead(200, {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache, no-transform',
        Connection: 'keep-alive',
        'X-Accel-Buffering': 'no',
      })
      reply.raw.write(`event: tick\ndata: ${JSON.stringify(initial)}\n\n`)

      let closed = false
      const tickTimer = setInterval(async () => {
        if (closed) return
        try {
          const data = await buildTick(matchId)
          if (!data) return
          reply.raw.write(`event: tick\ndata: ${JSON.stringify(data)}\n\n`)
        } catch {
          /* swallow — next tick will retry */
        }
      }, TICK_INTERVAL_MS)

      const heartbeatTimer = setInterval(() => {
        if (closed) return
        reply.raw.write(`event: heartbeat\ndata: {"t":${Date.now()}}\n\n`)
      }, TICK_HEARTBEAT_MS)

      const cleanup = () => {
        if (closed) return
        closed = true
        clearInterval(tickTimer)
        clearInterval(heartbeatTimer)
        try {
          reply.raw.end()
        } catch {
          /* ignore */
        }
      }
      request.raw.on('close', cleanup)
      request.raw.on('error', cleanup)
    },
  )
}
