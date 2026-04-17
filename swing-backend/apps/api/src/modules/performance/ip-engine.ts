/**
 * IP Engine — team power + season lifecycle helpers on new IP state tables.
 *
 * Note:
 * Legacy match-level IP awarding helpers are intentionally retired.
 * Match processing must go through PerformanceService.processVerifiedMatch().
 */

import { prisma, Prisma, CompetitiveRankKey } from '@swing/db'
import {
  IP_RULES,
  FORMAT_IP_MULTIPLIER,
  MATCH_FORMAT_BASELINES,
  COMPETITIVE_RANK_CONFIG,
  RANK_DECAY,
  TEAM_POWER_SCORE,
} from './performance.config'

// ─── Types ────────────────────────────────────────────────────────────────────

export type PlayerMatchInput = {
  playerProfileId: string
  team:            string        // 'A' or 'B'
  runs:            number
  balls:           number
  fours:           number
  sixes:           number
  isOut:           boolean
  wickets:         number
  legalBallsBowled: number
  runsConceded:    number
  catches:         number
  stumpings:       number
  runOuts:         number
  isManOfMatch:    boolean
}

export type IpBreakdown = {
  playing:     number
  batting:     number
  srAdjust:    number
  milestones:  number
  bowling:     number
  econAdjust:  number
  hauls:       number
  fielding:    number
  result:      number
  mvp:         number
  subtotal:    number           // before format multiplier
  multiplier:  number
  total:       number           // after multiplier, clamped
}

export type IpResult = {
  playerProfileId: string
  ipDelta:         number
  breakdown:       IpBreakdown
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

function clamp(val: number, min: number, max: number) {
  return Math.max(min, Math.min(max, val))
}

function linearScale(
  value: number,
  fromLow: number,
  fromHigh: number,
  toLow: number,
  toHigh: number,
): number {
  if (fromHigh === fromLow) return toLow
  const t = (value - fromLow) / (fromHigh - fromLow)
  return toLow + t * (toHigh - toLow)
}

function strikeRate(runs: number, balls: number) {
  return balls > 0 ? (runs / balls) * 100 : 0
}

function economyRate(runsConceded: number, legalBalls: number) {
  return legalBalls > 0 ? (runsConceded / legalBalls) * 6 : 0
}

// ─── IP Calculation ──────────────────────────────────────────────────────────

export function calculatePlayerIp(
  player: PlayerMatchInput,
  format: string,
  winnerId: string | null,      // team letter ('A'/'B') or null if no result
): IpResult {
  const baseline  = MATCH_FORMAT_BASELINES[format] ?? MATCH_FORMAT_BASELINES['T20']
  const multiplier = FORMAT_IP_MULTIPLIER[format] ?? 1.0
  const rules      = IP_RULES

  let playing    = rules.playingBonus
  let batting    = 0
  let srAdjust   = 0
  let milestones = 0
  let bowling    = 0
  let econAdjust = 0
  let hauls      = 0
  let fielding   = 0
  let result     = 0
  let mvp        = 0

  // ── Batting ────────────────────────────────────────────────────────────────
  batting += player.runs  * rules.batting.perRun
  batting += player.fours * rules.batting.perFour
  batting += player.sixes * rules.batting.perSix

  // Duck / golden duck penalty
  if (player.isOut && player.runs === 0) {
    milestones += player.balls <= 1
      ? rules.batting.goldenDuck   // out first ball — worst outcome
      : rules.batting.duck
  }

  // Milestone bonuses
  if (player.runs >= 150)      milestones += rules.batting.milestones.oneFifty
  else if (player.runs >= 100) milestones += rules.batting.milestones.hundred
  else if (player.runs >= 50)  milestones += rules.batting.milestones.fifty

  // SR adjustment (only if ≥ minBalls faced)
  if (player.balls >= rules.batting.minBallsForSrAdjustment) {
    const sr     = strikeRate(player.runs, player.balls)
    const strong = baseline.strongStrikeRate
    const base   = baseline.baselineStrikeRate

    if (sr >= strong) {
      // Elite aggression
      srAdjust = rules.batting.srBonus.aboveStrong
    } else if (sr >= base) {
      // Linear bonus: baseline → strong
      srAdjust = Math.round(
        linearScale(sr, base, strong, rules.batting.srBonus.atBaseline, rules.batting.srBonus.aboveStrong)
      )
    } else if (sr < 50) {
      // Catastrophic — blocking the crease, dragging team total
      srAdjust = rules.batting.srPenalty.below50
    } else if (sr < 70) {
      // Very slow — damaging in any format
      srAdjust = rules.batting.srPenalty.below70
    } else if (sr < base * 0.70) {
      // Below 70% of format baseline (e.g. <84 in T20, <62 in ODI)
      srAdjust = rules.batting.srPenalty.belowBaselinePct.seventyPct
    } else if (sr < base * 0.85) {
      // Below 85% of format baseline (e.g. <102 in T20, <75 in ODI)
      srAdjust = rules.batting.srPenalty.belowBaselinePct.eightyFivePct
    } else {
      // 85–100% of baseline — slightly slow but acceptable, no penalty
      srAdjust = 0
    }
  }

  // ── Bowling ────────────────────────────────────────────────────────────────
  bowling += player.wickets * rules.bowling.perWicket

  // Haul bonuses
  if (player.wickets >= 10)     hauls += rules.bowling.hauls.tenWickets
  else if (player.wickets >= 5) hauls += rules.bowling.hauls.fiveWickets
  else if (player.wickets >= 3) hauls += rules.bowling.hauls.threeWickets

  // Economy adjustment (only if ≥ minBalls bowled)
  if (player.legalBallsBowled >= rules.bowling.minBallsForEconAdjustment) {
    const econ   = economyRate(player.runsConceded, player.legalBallsBowled)
    const strong = baseline.strongEconomy
    const base   = baseline.baselineEconomy

    if (econ <= strong) {
      // Miserly — hard to score against
      econAdjust = rules.bowling.econBonus.belowStrong
    } else if (econ <= base) {
      // Linear bonus: strong → baseline
      econAdjust = Math.round(
        linearScale(econ, strong, base, rules.bowling.econBonus.belowStrong, rules.bowling.econBonus.atBaseline)
      )
    } else if (econ > 12) {
      // Getting smashed every over — severe punishment
      econAdjust = rules.bowling.econPenalty.above12
    } else if (econ > 10) {
      // Very expensive — hurting team badly
      econAdjust = rules.bowling.econPenalty.above10
    } else if (econ > 8) {
      // Clearly above par in any format
      econAdjust = rules.bowling.econPenalty.above8
    } else {
      // Between baseline and 8 — minor drag
      econAdjust = Math.round(
        linearScale(econ, base, base * 1.1, 0, rules.bowling.econPenalty.aboveBaselinePct.tenPctAbove)
      )
    }
  }

  // ── Fielding ───────────────────────────────────────────────────────────────
  fielding += player.catches   * rules.fielding.perCatch
  fielding += player.stumpings * rules.fielding.perStumping
  fielding += player.runOuts   * rules.fielding.perRunOut

  // ── Match Result ───────────────────────────────────────────────────────────
  if (winnerId === null) {
    result = rules.result.noResult
  } else if (player.team === winnerId) {
    result = rules.result.win
  } else {
    result = rules.result.loss
  }

  // ── MVP ────────────────────────────────────────────────────────────────────
  if (player.isManOfMatch) mvp = rules.mvpBonus

  // ── Totals ─────────────────────────────────────────────────────────────────
  const subtotal = playing + batting + srAdjust + milestones + bowling + econAdjust + hauls + fielding + result + mvp
  const rawTotal = Math.round(subtotal * multiplier)
  const total    = clamp(rawTotal, IP_RULES.minIpPerMatch, IP_RULES.maxIpPerMatch)

  return {
    playerProfileId: player.playerProfileId,
    ipDelta: total,
    breakdown: {
      playing, batting, srAdjust, milestones,
      bowling, econAdjust, hauls, fielding,
      result, mvp, subtotal, multiplier, total,
    },
  }
}

// ─── Rank Resolution ─────────────────────────────────────────────────────────

export type RankPosition = {
  rankKey:  CompetitiveRankKey
  division: number
  floor:    number            // IP threshold to enter this division
  ceiling:  number            // IP threshold of the next division (or Infinity for APEX)
  label:    string
}

export function resolveRankFromIp(ip: number): RankPosition {
  // Walk from highest to lowest to find the right division
  for (let ti = COMPETITIVE_RANK_CONFIG.length - 1; ti >= 0; ti--) {
    const tier = COMPETITIVE_RANK_CONFIG[ti]
    for (let di = tier.divisions.length - 1; di >= 0; di--) {
      const div  = tier.divisions[di]
      if (ip >= div.threshold) {
        // Find ceiling
        let ceiling = Infinity
        if (di < tier.divisions.length - 1) {
          ceiling = tier.divisions[di + 1].threshold
        } else if (ti < COMPETITIVE_RANK_CONFIG.length - 1) {
          ceiling = COMPETITIVE_RANK_CONFIG[ti + 1].divisions[0].threshold
        }
        return {
          rankKey:  tier.key as CompetitiveRankKey,
          division: div.division,
          floor:    div.threshold,
          ceiling,
          label:    div.label,
        }
      }
    }
  }
  // Fallback: ROOKIE III
  const rookieDiv = COMPETITIVE_RANK_CONFIG[0].divisions[0]
  return {
    rankKey:  'ROOKIE' as CompetitiveRankKey,
    division: rookieDiv.division,
    floor:    0,
    ceiling:  COMPETITIVE_RANK_CONFIG[0].divisions[1]?.threshold ?? 100,
    label:    rookieDiv.label,
  }
}

// ─── Apply IP to Player ───────────────────────────────────────────────────────

export async function applyIpToPlayer(
  _playerProfileId: string,
  _ipDelta: number,
  _matchId: string,
  _reason: string,
) {
  throw new Error(
    'applyIpToPlayer is retired. Use PerformanceService.processVerifiedMatch() or rebuildPlayersFromCurrentFacts().',
  )
}

// ─── Revoke Match IP (call before deleting a match) ──────────────────────────

export async function revokeMatchIp(_matchId: string): Promise<void> {
  throw new Error(
    'revokeMatchIp is retired. Delete matches through MatchService.deleteMatch() which rebuilds derived state.',
  )
}

// ─── Full Match IP Award ──────────────────────────────────────────────────────

export async function awardMatchIp(
  _matchId: string,
  _winnerId: string | null,
  _options?: { force?: boolean; playerFilter?: string },
) {
  throw new Error(
    'awardMatchIp is retired. Use PerformanceService.processVerifiedMatch() to compute and persist state.',
  )
}

// ─── Team Power Score ─────────────────────────────────────────────────────────

export async function recalculateTeamPowerScore(teamId: string) {
  const team = await prisma.team.findUnique({ where: { id: teamId } })
  if (!team || team.playerIds.length === 0) return

  const score = await computePowerScore(team.playerIds)
  await prisma.team.update({
    where: { id: teamId },
    data:  { powerScore: score, powerScoreUpdatedAt: new Date() },
  })
  return score
}

export async function recalculateTeamPowerScoreByPlayerIds(playerIds: string[]) {
  if (playerIds.length === 0) return 0

  // Find teams that contain exactly these players (approximate — match by captain or playerIds overlap)
  const teams = await prisma.team.findMany({
    where: { playerIds: { hasSome: playerIds } },
  })

  await Promise.all(teams.map(t => recalculateTeamPowerScore(t.id)))
}

async function computePowerScore(playerIds: string[]): Promise<number> {
  const profiles = await prisma.$queryRaw<Array<{ rankProgressPoints: number }>>`
    SELECT "rankProgressPoints"
    FROM public.ip_player_state
    WHERE "playerId" IN (${Prisma.join(playerIds)})
  `

  if (profiles.length === 0) return 0

  // Sort descending by IP
  const sorted = profiles
    .map(p => p.rankProgressPoints)
    .sort((a, b) => b - a)

  const cfg        = TEAM_POWER_SCORE
  const topCount   = Math.min(cfg.topPlayersCount, sorted.length)
  const tailCount  = sorted.length - topCount

  const topIps     = sorted.slice(0, topCount)
  const tailIps    = sorted.slice(topCount)

  const topAvg     = topIps.reduce((s, v) => s + v, 0) / topCount
  const tailAvg    = tailCount > 0 ? tailIps.reduce((s, v) => s + v, 0) / tailCount : 0

  const weightedScore = topCount > 0 && tailCount > 0
    ? topAvg * cfg.topPlayersWeight + tailAvg * cfg.tailPlayersWeight
    : topAvg

  return Math.round(weightedScore)
}

// ─── Rank Decay (run via cron / weekly job) ───────────────────────────────────

export async function applyRankDecay() {
  const decayThreshold = new Date()
  decayThreshold.setDate(decayThreshold.getDate() - RANK_DECAY.inactiveDaysThreshold)

  const inactivePlayers = await prisma.$queryRaw<Array<{
    playerId: string
    lifetimeIp: number
    currentRankKey: string
    currentDivision: number
    rankProgressPoints: number
    currentDivisionFloor: number
    winStreak: number
    mvpCount: number
    lastRankedMatchAt: Date | null
    currentSeasonId: string | null
  }>>`
    SELECT
      "playerId",
      "lifetimeIp",
      "currentRankKey",
      "currentDivision",
      "rankProgressPoints",
      "currentDivisionFloor",
      "winStreak",
      "mvpCount",
      "lastRankedMatchAt",
      "currentSeasonId"
    FROM public.ip_player_state
    WHERE ("lastRankedMatchAt" < ${decayThreshold} OR "lastRankedMatchAt" IS NULL)
      AND "rankProgressPoints" > ${RANK_DECAY.minimumRankProgress}
  `

  const decayFactor = 1 - (RANK_DECAY.weeklyDecayPercent / 100)

  await Promise.all(
    inactivePlayers.map(async player => {
      const newProgress = Math.max(
        RANK_DECAY.minimumRankProgress,
        Math.round(player.rankProgressPoints * decayFactor),
      )
      const decayAmount = player.rankProgressPoints - newProgress
      if (decayAmount <= 0) return

      const newRankPos = resolveRankFromIp(newProgress)

      await prisma.$executeRaw`
        UPDATE public.ip_player_state
        SET "rankProgressPoints" = ${newProgress},
            "currentRankKey" = ${newRankPos.rankKey},
            "currentDivision" = ${newRankPos.division},
            "currentDivisionFloor" = ${newRankPos.floor},
            "updatedAt" = NOW()
        WHERE "playerId" = ${player.playerId}
      `

      await prisma.$executeRaw`
        INSERT INTO public.ip_event (
          "playerId",
          "seasonId",
          "eventType",
          "source",
          reason,
          "ipDelta",
          "rankBefore",
          "rankAfter",
          "divisionBefore",
          "divisionAfter",
          "externalRef",
          meta,
          "createdAt"
        )
        VALUES (
          ${player.playerId},
          ${player.currentSeasonId},
          'PENALTY'::ip_event_type,
          'MATCH_ENGINE'::ip_event_source,
          'RANK_DECAY',
          ${-decayAmount},
          ${player.currentRankKey},
          ${newRankPos.rankKey},
          ${player.currentDivision},
          ${newRankPos.division},
          ${`rank-decay:${player.playerId}:${Date.now()}`},
          ${JSON.stringify({ source: 'season_decay' })}::jsonb,
          NOW()
        )
      `
    }),
  )
}

// ─── Season Reset (every 90 days) ────────────────────────────────────────────
// rankProgressPoints → 60% of current value.
// lifetimeImpactPoints is never touched.
// Creates a new CompetitiveSeason and snapshots all players into PlayerSeasonProgress.

export const SEASON_RESET = {
  durationDays:    90,
  retainPercent:   0.60,   // keep 60% of rankProgressPoints after reset
  minimumRetained: 0,      // floor — never go below 0 on reset
} as const

export async function applySeasonReset(dryRun = false): Promise<{
  seasonClosed: string | null
  seasonCreated: string | null
  playersReset: number
  dryRun: boolean
}> {
  // Close current active season (if any)
  const activeSeason = await prisma.competitiveSeason.findFirst({
    where: { isActive: true },
  })

  if (!dryRun && activeSeason) {
    await prisma.competitiveSeason.update({
      where: { id: activeSeason.id },
      data:  { isActive: false, endAt: new Date() },
    })
  }

  const allProfiles = await prisma.$queryRaw<Array<{
    playerId: string
    lifetimeIp: number
    currentRankKey: string
    currentDivision: number
    rankProgressPoints: number
    currentDivisionFloor: number
    winStreak: number
    mvpCount: number
    currentSeasonId: string | null
  }>>`
    SELECT
      "playerId",
      "lifetimeIp",
      "currentRankKey",
      "currentDivision",
      "rankProgressPoints",
      "currentDivisionFloor",
      "winStreak",
      "mvpCount",
      "currentSeasonId"
    FROM public.ip_player_state
  `

  if (!dryRun && activeSeason) {
    await prisma.$executeRaw`
      INSERT INTO public.ip_season_state (
        "playerId",
        "seasonId",
        "seasonPoints",
        "mvpCount",
        "matchesPlayed",
        "createdAt",
        "updatedAt"
      )
      SELECT
        s."playerId",
        ${activeSeason.id},
        s."rankProgressPoints",
        s."mvpCount",
        COALESCE(existing."matchesPlayed", 0),
        NOW(),
        NOW()
      FROM public.ip_player_state s
      LEFT JOIN public.ip_season_state existing
        ON existing."playerId" = s."playerId"
       AND existing."seasonId" = ${activeSeason.id}
      ON CONFLICT ("playerId", "seasonId")
      DO UPDATE SET
        "seasonPoints" = EXCLUDED."seasonPoints",
        "mvpCount" = EXCLUDED."mvpCount",
        "updatedAt" = NOW()
    `
  }

  // Create new season
  const seasonStart = new Date()
  const seasonEnd   = new Date(seasonStart)
  seasonEnd.setDate(seasonEnd.getDate() + SEASON_RESET.durationDays)

  const seasonNumber = activeSeason
    ? Number(activeSeason.name.replace(/\D/g, '') || 0) + 1
    : 1

  let newSeason: { id: string; name: string } | null = null
  if (!dryRun) {
    newSeason = await prisma.competitiveSeason.create({
      data: {
        name:     `Season ${seasonNumber}`,
        startAt:  seasonStart,
        endAt:    seasonEnd,
        isActive: true,
      },
      select: { id: true, name: true },
    })
  }

  // Reset all players: rankProgressPoints → 60%, update rank, assign new season
  if (!dryRun) {
    await Promise.all(
      allProfiles.map(async p => {
        const newProgress = Math.max(
          SEASON_RESET.minimumRetained,
          Math.round(p.rankProgressPoints * SEASON_RESET.retainPercent),
        )
        const newRankPos = resolveRankFromIp(newProgress)
        const rankBefore = `${p.currentRankKey}:${p.currentDivision}`
        const rankAfter  = `${newRankPos.rankKey}:${newRankPos.division}`

        await prisma.$executeRaw`
          UPDATE public.ip_player_state
          SET "rankProgressPoints" = ${newProgress},
              "currentRankKey" = ${newRankPos.rankKey},
              "currentDivision" = ${newRankPos.division},
              "currentDivisionFloor" = ${newRankPos.floor},
              "winStreak" = 0,
              "currentSeasonId" = ${newSeason!.id},
              "updatedAt" = NOW()
          WHERE "playerId" = ${p.playerId}
        `

        await prisma.$executeRaw`
          INSERT INTO public.ip_event (
            "playerId",
            "seasonId",
            "eventType",
            "source",
            reason,
            "ipDelta",
            "rankBefore",
            "rankAfter",
            "divisionBefore",
            "divisionAfter",
            "externalRef",
            meta,
            "createdAt"
          )
          VALUES (
            ${p.playerId},
            ${newSeason!.id},
            'ADJUSTMENT'::ip_event_type,
            'MATCH_ENGINE'::ip_event_source,
            'SEASON_RESET',
            ${newProgress - p.rankProgressPoints},
            ${p.currentRankKey},
            ${newRankPos.rankKey},
            ${p.currentDivision},
            ${newRankPos.division},
            ${`season-reset:${p.playerId}:${newSeason!.id}`},
            ${JSON.stringify({ source: 'season_reset' })}::jsonb,
            NOW()
          )
        `
      })
    )
  }

  return {
    seasonClosed:  activeSeason?.id ?? null,
    seasonCreated: newSeason?.id ?? null,
    playersReset:  allProfiles.length,
    dryRun,
  }
}

// ─── Season Scheduler ─────────────────────────────────────────────────────────
// Call once at app startup. Checks daily if a reset is due.

export function startSeasonScheduler() {
  const CHECK_INTERVAL_MS = 24 * 60 * 60 * 1000 // once per day

  async function checkAndReset() {
    try {
      const activeSeason = await prisma.competitiveSeason.findFirst({
        where: { isActive: true },
        orderBy: { startAt: 'desc' },
      })

      const now = new Date()

      if (!activeSeason) {
        // No season running — bootstrap the first one
        console.log('[season] No active season found — running initial season reset')
        await applySeasonReset()
        return
      }

      if (now >= activeSeason.endAt) {
        console.log(`[season] Season "${activeSeason.name}" ended — applying reset`)
        await applySeasonReset()
      }
    } catch (err) {
      console.error('[season] Season reset check failed', err)
    }
  }

  // Run immediately on startup, then every 24h
  void checkAndReset()
  const timer = setInterval(() => void checkAndReset(), CHECK_INTERVAL_MS)
  timer.unref() // don't block process exit
}
