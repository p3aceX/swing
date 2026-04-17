import { prisma, Prisma, type CompetitiveRankKey } from '@swing/db'
import type {
  CompetitiveSummary,
  PlayerIndexAxis,
  PlayerIndexBreakdownResponse,
  PlayerIndexTrendPoint,
  PlayerPhysicalSummary,
  SeasonSummary,
  SwingIndexSummary,
} from '@swing/types'
import { buildMatchPlayerStats } from '../matches/match-stats'
import {
  IMPACT_POINT_RULES,
  COMPETITIVE_SEASON_MILESTONES,
  DAILY_FIELD_SECONDS_PER_LEGAL_BALL,
  DEFAULT_PLAYER_PASS_MULTIPLIER,
} from './performance.config'
import {
  applyMvpBonusToImpactBreakdown,
  averageAxisValues,
  averageBreakdownEntries,
  computeBattingMetrics,
  computeBowlingMetrics,
  computeImpactPointBreakdown,
  computeFieldingMetrics,
  computeMatchIndexes,
  computePhysicalProxy,
  formatRankLabel,
  getRankConfig,
  mapCompetitiveRankToLegacyTier,
  resolveRankFromImpactPoints,
} from './performance.calculations'
import { ChallengeDetectorService } from './challenge-detector.service'
import { EliteAnalyticsService } from './elite-analytics.service'
import { EliteStatsExtendedService } from './elite-stats-extended.service'
import { JournalStreakService } from './journal-streak.service'
import {
  getAxisNumber,
  getIpPlayerState,
  getIpSeasonState,
  getPlayerStatOverall,
  getSubScoreNumber,
  getSwingPlayerState,
} from './state-read.repository'
import {
  replaceMatchEngineIpEvents,
  updateIpSeasonLeaderboard,
  upsertIpPlayerState,
  upsertIpSeasonState,
  upsertPlayerStatOverallFromStats120,
  upsertSwingPlayerState,
} from './state-write.repository'
import {
  calculateSwingIndexV2,
  calculateSwingIndexV2Summary,
  type SwingRoleWeights,
  type SwingIndexV2Result,
  type SwingIndexV2Summary,
} from './swing-index-v2.calculator'
import { SWING_INDEX_V2_FORMULA_VERSION } from './swing-index-v2.config'
import type {
  CompetitiveContext,
  CompetitivePlayerFactInput,
  DerivedMetricRecord,
  ImpactPointBreakdown,
} from './performance.types'

type MatchWithScoring = Awaited<ReturnType<PerformanceService['getMatchForProcessing']>>

type RankWindow = 'MATCH' | 'LAST_5' | 'LAST_10' | 'SEASON' | 'LIFETIME'
type CompetitiveActivityEvent = {
  id: string
  type: string
  title: string
  subtitle: string
  iconType: string
  impactPoints: number | null
  seasonPoints: number | null
  createdAt: Date
}

function unique<T>(values: T[]) {
  return Array.from(new Set(values))
}

function toDateOnlyKey(value: Date) {
  return value.toISOString().slice(0, 10)
}

function round(value: number, digits = 1) {
  const factor = 10 ** digits
  return Math.round(value * factor) / factor
}

function clamp(value: number, min: number, max: number) {
  return Math.min(max, Math.max(min, value))
}

function average(values: Array<number | null | undefined>) {
  const filtered = values.filter((value): value is number => typeof value === 'number' && Number.isFinite(value))
  if (filtered.length === 0) return null
  return filtered.reduce((sum, value) => sum + value, 0) / filtered.length
}

function safeLabel(value: string) {
  return value
    .replace(/([a-z])([A-Z])/g, '$1 $2')
    .replace(/_/g, ' ')
    .replace(/\b\w/g, (letter) => letter.toUpperCase())
}

function toInputJsonObject(value?: Record<string, unknown>) {
  return value as Prisma.InputJsonObject | undefined
}

const DEFAULT_SNAPSHOT_ROLE_WEIGHTS: SwingRoleWeights = {
  batting: 0.40,
  bowling: 0.20,
  fielding: 0.15,
  impact: 0.25,
}

export class PerformanceService {
  private challengeDetector = new ChallengeDetectorService()
  public eliteAnalytics = new EliteAnalyticsService()
  private eliteStatsExtended = new EliteStatsExtendedService()
  private journalStreak = new JournalStreakService()

  private getValidatedPassMultiplier() {
    return Number.isFinite(DEFAULT_PLAYER_PASS_MULTIPLIER) && DEFAULT_PLAYER_PASS_MULTIPLIER > 1
      ? DEFAULT_PLAYER_PASS_MULTIPLIER
      : 2
  }

  private async readIpPlayerState(playerId: string) {
    return getIpPlayerState(playerId)
  }

  private async readIpSeasonState(playerId: string, seasonId?: string | null) {
    return getIpSeasonState(playerId, seasonId)
  }

  private async readSwingPlayerState(playerId: string) {
    return getSwingPlayerState(playerId)
  }

  private async readPlayerStatOverall(playerId: string) {
    return getPlayerStatOverall(playerId)
  }

  async processVerifiedMatch(matchId: string, options: { allowUnverified?: boolean } = {}) {
    const match = await this.getMatchForProcessing(matchId)
    if (!match) return { processed: false, reason: 'MATCH_NOT_FOUND' }
    if (match.status !== 'COMPLETED') return { processed: false, reason: 'MATCH_NOT_COMPLETED' }
    if (match.verificationLevel === 'UNVERIFIED' && !options.allowUnverified) {
      return { processed: false, reason: 'MATCH_NOT_VERIFIED' }
    }

    const refreshedPlayerMatchStats = await this.upsertPlayerMatchStats(match)
    const processingMatch = {
      ...match,
      playerMatchStats: refreshedPlayerMatchStats,
    } as NonNullable<MatchWithScoring>

    const roster = await this.resolveMatchRosters(processingMatch)
    if (roster.overlappingPlayerIds.length > 0) {
      console.error('[match-processor] CRITICAL: overlapping playing XI detected', {
        matchId,
        overlappingPlayerIds: roster.overlappingPlayerIds,
      })
      return { processed: false, reason: 'OVERLAPPING_PLAYING_XI' }
    }
    const playerIds = unique([...roster.teamA, ...roster.teamB].map((item) => item.id))
    if (playerIds.length === 0) return { processed: false, reason: 'NO_PLAYERS' }

    const [activeSeason, passMultiplierByPlayer, recentScores] = await Promise.all([
      this.getActiveSeason(processingMatch.completedAt ?? new Date()),
      this.getPassMultiplierMap(playerIds, processingMatch.completedAt ?? new Date()),
      prisma.matchPlayerIndexScore.findMany({
        where: { playerId: { in: playerIds }, NOT: { matchId } },
        include: { match: { select: { completedAt: true } } },
        orderBy: [{ match: { completedAt: 'desc' } }, { createdAt: 'desc' }],
      }),
    ])

    const facts = this.buildCompetitiveFacts(processingMatch, roster)
    if (facts.length === 0) return { processed: false, reason: 'NO_FACTS' }

    const factsByMatchAndPlayer = new Map<string, CompetitivePlayerFactInput>()
    for (const fact of facts) {
      factsByMatchAndPlayer.set(`${fact.matchId}:${fact.playerId}`, fact)
    }

    const groupedRecentScores = new Map<string, typeof recentScores>()
    for (const score of recentScores) {
      const list = groupedRecentScores.get(score.playerId) ?? []
      list.push(score)
      groupedRecentScores.set(score.playerId, list)
    }

    const metricRecords: Array<{
      matchId: string
      playerId: string
      record: DerivedMetricRecord
    }> = []
    const indexRecords: Array<{
      matchId: string
      playerId: string
      battingIndex: number | null
      bowlingIndex: number | null
      fieldingIndex: number | null
      consistencyContribution: number | null
      clutchIndex: number | null
      physicalIndex: number | null
      captaincyIndex: number | null
      gameInfluenceIndex: number | null
      performanceScore: number
      impactPoints: number
      impactBreakdown: ImpactPointBreakdown
      seasonPoints: number
      passMultiplierApplied: number
      isMvp: boolean
    }> = []
    const physicalSamples: Array<{
      playerId: string
      sourceRefId: string
      sampleStartAt: Date
      sampleEndAt: Date
      activeMinutes: number | null
      workloadScore: number | null
      distanceMeters: number | null
      sprintCount: number | null
      rawPayload: Record<string, unknown>
    }> = []
    const leadershipSamples: Array<{
      playerId: string
      matchId: string
      wasCaptain: boolean
      teamWin: boolean
      closeMatch: boolean
      chaseMatch: boolean
      captaincyInfluenceScore: number | null
    }> = []
    const workloadEvents: Array<{
      playerId: string
      type: string
      date: Date
      durationMinutes: number
      intensity: number
      oversBowled: number | null
      ballsBowled: number | null
      battingMinutes: number | null
      ballsFaced: number | null
      source: string
      sourceRefId: string
    }> = []

    for (const fact of facts) {
      const context = this.buildCompetitiveContext(fact, facts)
      const battingMetrics = computeBattingMetrics(fact, context)
      const bowlingMetrics = computeBowlingMetrics(fact, context)
      const fieldingMetrics = computeFieldingMetrics(fact, context)
      const physicalProxy = computePhysicalProxy(fact)
      const recentGameInfluence = (groupedRecentScores.get(fact.playerId) ?? [])
        .slice(0, 4)
        .map((score) => score.gameInfluenceIndex ?? score.performanceScore)
        .reverse()
      const computed = computeMatchIndexes({
        fact,
        context,
        recentGameInfluence,
        passMultiplier: passMultiplierByPlayer.get(fact.playerId) ?? 1,
      })

      metricRecords.push({
        matchId: fact.matchId,
        playerId: fact.playerId,
        record: {
          ...battingMetrics,
          economyRate: bowlingMetrics.economyRate,
          ballsPerWicket: bowlingMetrics.ballsPerWicket,
          dotBallPct: bowlingMetrics.dotBallPct,
          wicketContributionPct: bowlingMetrics.wicketContributionPct,
          spellQualityMetric: bowlingMetrics.spellQualityMetric,
          phaseDifficultyMetric: bowlingMetrics.phaseDifficultyMetric,
          fieldingInvolvementMetric: fieldingMetrics.fieldingInvolvementMetric,
          physicalWorkloadMetric: physicalProxy.workload,
          captaincyInfluenceMetric: computed.captaincy.breakdown.captaincyInfluence ?? null,
        },
      })

      indexRecords.push({
        matchId: fact.matchId,
        playerId: fact.playerId,
        battingIndex: computed.reliability.score,
        bowlingIndex: computed.bowling.score,
        fieldingIndex: computed.fielding.score,
        consistencyContribution: computed.power.score,
        clutchIndex: computed.impact.score,
        physicalIndex: 0,
        captaincyIndex: computed.captaincy.score,
        gameInfluenceIndex: computed.gameInfluenceIndex,
        performanceScore: computed.performanceScore,
        impactPoints: computed.impactPoints,
        impactBreakdown: computed.impactBreakdown,
        seasonPoints: computed.seasonPoints,
        passMultiplierApplied: computed.passMultiplierApplied,
        isMvp: false,
      })

      physicalSamples.push({
        playerId: fact.playerId,
        sourceRefId: fact.matchId,
        sampleStartAt: processingMatch.startedAt ?? processingMatch.scheduledAt,
        sampleEndAt: processingMatch.completedAt ?? processingMatch.scheduledAt,
        activeMinutes: fact.fieldTimeSeconds === null ? null : round(fact.fieldTimeSeconds / 60, 2),
        workloadScore: physicalProxy.workload,
        distanceMeters: fact.oversFielded === null ? null : round(fact.oversFielded * 60, 2),
        sprintCount: fact.catches + fact.runOuts + fact.stumpings,
        rawPayload: {
          oversFielded: fact.oversFielded,
          fieldTimeSeconds: fact.fieldTimeSeconds,
          ballsBowled: fact.ballsBowled,
          ballsFaced: fact.ballsFaced,
        },
      })

      leadershipSamples.push({
        playerId: fact.playerId,
        matchId: fact.matchId,
        wasCaptain: fact.isCaptain,
        teamWin: fact.result === 'WIN',
        closeMatch: context.closeMatch,
        chaseMatch: context.chaseMatch,
        captaincyInfluenceScore: computed.captaincy.breakdown.captaincyInfluence ?? null,
      })

      workloadEvents.push({
        playerId: fact.playerId,
        type: 'MATCH',
        date: fact.matchDate,
        durationMinutes: fact.fieldTimeSeconds ? Math.round(fact.fieldTimeSeconds / 60) : 0,
        intensity: 8,
        oversBowled: fact.oversBowled,
        ballsBowled: fact.ballsBowled,
        battingMinutes: fact.fieldTimeSeconds ? Math.round(fact.fieldTimeSeconds / 60) : 0,
        ballsFaced: fact.ballsFaced,
        source: 'MATCH_PROXY',
        sourceRefId: fact.matchId,
      })
    }

    const mvp = [...indexRecords].sort((left, right) =>
      right.impactPoints - left.impactPoints ||
      right.performanceScore - left.performanceScore ||
      (right.gameInfluenceIndex ?? 0) - (left.gameInfluenceIndex ?? 0) ||
      left.playerId.localeCompare(right.playerId),
    )[0]
    if (mvp) {
      const entry = indexRecords.find((record) => record.playerId === mvp.playerId)
      if (entry) {
        entry.isMvp = true
        entry.impactBreakdown = applyMvpBonusToImpactBreakdown(entry.impactBreakdown)
        entry.impactPoints = entry.impactBreakdown.totalImpactPoints
        entry.seasonPoints = Math.round(entry.impactPoints * entry.passMultiplierApplied)
      }
    }

    await prisma.$transaction(async (tx) => {
      await Promise.all([
        tx.matchPlayerFact.deleteMany({ where: { matchId } }),
        tx.matchPlayerMetric.deleteMany({ where: { matchId } }),
        tx.matchPlayerIndexScore.deleteMany({ where: { matchId } }),
        tx.playerLeadershipSample.deleteMany({ where: { matchId } }),
        tx.playerPhysicalSample.deleteMany({
          where: { sourceType: 'MATCH_PROXY', sourceRefId: matchId },
        }),
        tx.playerWorkloadEvent.deleteMany({
          where: { source: 'MATCH_PROXY', sourceRefId: matchId },
        }),
      ])

      if (facts.length > 0) {
        await tx.matchPlayerFact.createMany({
          data: facts.map((fact) => ({
            matchId: fact.matchId,
            playerId: fact.playerId,
            teamId: fact.teamId,
            opponentTeamId: fact.opponentTeamId,
            inningsNo: fact.inningsNo,
            battingPosition: fact.battingPosition,
            didBat: fact.didBat,
            runs: fact.runs,
            ballsFaced: fact.ballsFaced,
            fours: fact.fours,
            sixes: fact.sixes,
            dismissalType: fact.dismissalType as any,
            wasNotOut: fact.wasNotOut,
            didBowl: fact.didBowl,
            ballsBowled: fact.ballsBowled,
            oversBowled: fact.oversBowled,
            maidens: fact.maidens,
            wickets: fact.wickets,
            runsConceded: fact.runsConceded,
            dotBalls: fact.dotBalls,
            wides: fact.wides,
            noBalls: fact.noBalls,
            catches: fact.catches,
            runOuts: fact.runOuts,
            stumpings: fact.stumpings,
            fieldTimeSeconds: fact.fieldTimeSeconds,
            oversFielded: fact.oversFielded,
            isCaptain: fact.isCaptain,
            result: fact.result as any,
            matchFormat: fact.matchFormat as any,
            ballType: fact.ballType ?? 'LEATHER',
            matchDate: fact.matchDate,
          })),
        })
      }

      if (metricRecords.length > 0) {
        await tx.matchPlayerMetric.createMany({
          data: metricRecords.map((item) => ({
            matchId: item.matchId,
            playerId: item.playerId,
            ...item.record,
          })),
        })
      }

      if (indexRecords.length > 0) {
        await tx.matchPlayerIndexScore.createMany({
          data: indexRecords.map(({ impactBreakdown: _impactBreakdown, ...record }) => record),
        })
      }

      if (leadershipSamples.length > 0) {
        await tx.playerLeadershipSample.createMany({ data: leadershipSamples })
      }

      if (physicalSamples.length > 0) {
        await tx.playerPhysicalSample.createMany({
          data: physicalSamples.map((sample) => ({
            playerId: sample.playerId,
            sourceType: 'MATCH_PROXY',
            sourceRefId: sample.sourceRefId,
            sampleStartAt: sample.sampleStartAt,
            sampleEndAt: sample.sampleEndAt,
            activeMinutes: sample.activeMinutes,
            workloadScore: sample.workloadScore,
            distanceMeters: sample.distanceMeters,
            sprintCount: sample.sprintCount,
            rawPayload: toInputJsonObject(sample.rawPayload),
          })),
        })
      }

      if (workloadEvents.length > 0) {
        await tx.playerWorkloadEvent.createMany({
          data: workloadEvents,
        })
      }

      await tx.playerMatchStats.updateMany({
        where: { matchId },
        data: { isManOfMatch: false },
      })
      if (mvp) {
        await tx.playerMatchStats.updateMany({
          where: { matchId, playerProfileId: mvp.playerId },
          data: { isManOfMatch: true },
        })
      }
    })

    for (const playerId of playerIds) {
      await this.rebuildPlayerState(playerId, activeSeason)
      // Award 'Flex 100' badges
      await this.challengeDetector.detectAndAwardBadges(matchId, playerId)

      // Update Team Power Scores for this player's teams
      const playerTeams = await prisma.team.findMany({
        where: { playerIds: { has: playerId } },
        select: { id: true }
      })
      for (const team of playerTeams) {
        await this.eliteAnalytics.recalculateTeamPowerScore(team.id)
      }
    }

    if (activeSeason) {
      await this.recalculateSeasonLeaderboard(activeSeason.id)
    }

    return {
      processed: true,
      players: playerIds.length,
      mvpPlayerId: mvp?.playerId ?? null,
      seasonId: activeSeason?.id ?? null,
    }
  }

  async rebuildPlayersFromCurrentFacts(playerIds: string[]) {
    const normalizedPlayerIds = unique(playerIds.map((playerId) => playerId.trim()).filter(Boolean))
    if (normalizedPlayerIds.length === 0) {
      return { rebuiltPlayers: 0, seasonId: null as string | null }
    }

    const activeSeason = await this.getActiveSeason()

    for (const playerId of normalizedPlayerIds) {
      await this.rebuildPlayerState(playerId, activeSeason)
      await this.challengeDetector.rebuildPlayerBadges(playerId)

      const playerTeams = await prisma.team.findMany({
        where: { playerIds: { has: playerId } },
        select: { id: true },
      })
      for (const team of playerTeams) {
        await this.eliteAnalytics.recalculateTeamPowerScore(team.id)
      }
    }

    if (activeSeason) {
      await this.recalculateSeasonLeaderboard(activeSeason.id)
    }

    return {
      rebuiltPlayers: normalizedPlayerIds.length,
      seasonId: activeSeason?.id ?? null,
    }
  }

  async getPlayerStatsSummary(playerId: string) {
    const [ipState, swingState, statsOverall, activeSeason, passMultiplier] = await Promise.all([
      this.readIpPlayerState(playerId),
      this.readSwingPlayerState(playerId),
      this.readPlayerStatOverall(playerId),
      this.getActiveSeason(),
      this.getCurrentPassMultiplierForPlayer(playerId),
    ])
    const seasonLookupId = activeSeason?.id ?? ipState?.currentSeasonId ?? null
    const seasonProgress = seasonLookupId
      ? await this.readIpSeasonState(playerId, seasonLookupId)
      : null

    const lifetimeImpactPoints = ipState?.lifetimeIp ?? 0
    const fallbackRank = resolveRankFromImpactPoints(lifetimeImpactPoints)
    const rankKey = (ipState?.currentRankKey as CompetitiveRankKey | undefined) ?? fallbackRank.rankKey
    const division = rankKey === 'APEX'
      ? null
      : (ipState?.currentDivision ?? fallbackRank.division)
    const rankConfig = getRankConfig()
    const tierIndex = rankConfig.findIndex((item) => item.key === rankKey)
    const tier = tierIndex === -1 ? null : rankConfig[tierIndex]
    const currentStep = tier == null || division == null
      ? null
      : tier.divisions.find((item) => item.division === division) ?? null
    const currentThreshold = currentStep?.threshold ?? fallbackRank.threshold
    const nextThreshold = currentStep == null
      ? fallbackRank.nextThreshold
      : tier?.divisions.find((item) => item.threshold > currentStep.threshold)?.threshold
          ?? rankConfig[tierIndex + 1]?.divisions[0]?.threshold
          ?? null
    const rankProgress = ipState?.rankProgressPoints
      ?? Math.max(0, lifetimeImpactPoints - currentThreshold)

    const reliabilityAxis = getAxisNumber(swingState?.axes, 'reliabilityAxis')
    const powerAxis = getAxisNumber(swingState?.axes, 'powerAxis')
    const bowlingAxis = getAxisNumber(swingState?.axes, 'bowlingAxis')
    const impactAxis = getAxisNumber(swingState?.axes, 'impactAxis')
    const fieldingAxis = getAxisNumber(swingState?.axes, 'fieldingAxis')
    const captaincyAxis = getAxisNumber(swingState?.axes, 'captaincyAxis')

    const competitive: CompetitiveSummary = {
      impactPoints: lifetimeImpactPoints,
      rank: division == null ? 'Apex' : formatRankLabel(rankKey, division),
      rankKey,
      division,
      rankProgress,
      rankProgressMax: nextThreshold === null ? 0 : Math.max(0, nextThreshold - currentThreshold),
      mvpCount: ipState?.mvpCount ?? statsOverall?.mvpCount ?? 0,
      matchesPlayed: seasonProgress?.matchesPlayed
        ?? statsOverall?.matchesPlayed
        ?? (await prisma.matchPlayerFact.count({ where: { playerId } })),
    }

    const season: SeasonSummary = {
      seasonId: activeSeason?.id ?? null,
      seasonPoints: seasonProgress?.seasonPoints ?? 0,
      passMultiplier,
      seasonLeaderboardPosition: seasonProgress?.leaderboardPosition ?? null,
    }

    const swingIndex: SwingIndexSummary = {
      currentSwingIndex: swingState?.overallScore ?? 0,
      reliabilityIndex: reliabilityAxis ?? 0,
      powerIndex: powerAxis ?? 0,
      bowlingIndex: bowlingAxis ?? 0,
      fieldingIndex: fieldingAxis ?? 0,
      impactIndex: impactAxis ?? 0,
      captaincyIndex: captaincyAxis,
    }

    return { competitive, season, swingIndex, legacyRankLabel: fallbackRank.label }
  }

  async getPlayerIndex(playerId: string) {
    const [swingState, statsOverall, trendDelta] = await Promise.all([
      this.readSwingPlayerState(playerId),
      this.readPlayerStatOverall(playerId),
      this.getIndexTrendDelta(playerId),
    ])
    const reliabilityAxis = getAxisNumber(swingState?.axes, 'reliabilityAxis')
    const powerAxis = getAxisNumber(swingState?.axes, 'powerAxis')
    const bowlingAxis = getAxisNumber(swingState?.axes, 'bowlingAxis')
    const impactAxis = getAxisNumber(swingState?.axes, 'impactAxis')
    const fieldingAxis = getAxisNumber(swingState?.axes, 'fieldingAxis')
    const captaincyAxis = getAxisNumber(swingState?.axes, 'captaincyAxis')

    const current = {
      currentSwingIndex: swingState?.overallScore ?? 0,
      reliabilityIndex: reliabilityAxis ?? 0,
      powerIndex: powerAxis ?? 0,
      bowlingIndex: bowlingAxis ?? 0,
      fieldingIndex: fieldingAxis ?? 0,
      impactIndex: impactAxis ?? 0,
      captaincyIndex: captaincyAxis,
    }

    const radar = [
      { label: 'Reliability', value: current.reliabilityIndex },
      { label: 'Power', value: current.powerIndex },
      { label: 'Bowling', value: current.bowlingIndex },
      { label: 'Fielding', value: current.fieldingIndex },
      { label: 'Impact', value: current.impactIndex },
      { label: 'Captaincy', value: current.captaincyIndex ?? 0 },
    ]

    const sorted = [...radar].sort((left, right) => right.value - left.value)

    return {
      current,
      radar,
      strengths: sorted.slice(0, 2).map((item) => item.label),
      workOns: sorted.slice(-2).reverse().map((item) => item.label),
      trendDelta,
    }
  }

  async getPlayerIndexTrend(playerId: string, days = 30): Promise<PlayerIndexTrendPoint[]> {
    const since = new Date(Date.now() - days * 24 * 60 * 60 * 1000)
    const snapshots = await prisma.playerIndexSnapshot.findMany({
      where: {
        playerId,
        snapshotType: { in: ['DAILY', 'MATCH'] },
        snapshotDate: { gte: since },
      },
      orderBy: [{ snapshotDate: 'asc' }, { createdAt: 'asc' }],
    })

    return snapshots.map((snapshot) => ({
      snapshotType: snapshot.snapshotType,
      snapshotDate: snapshot.snapshotDate.toISOString(),
      reliabilityIndex: snapshot.reliabilityIndex,
      powerIndex: snapshot.powerIndex,
      bowlingIndex: snapshot.bowlingIndex,
      fieldingIndex: snapshot.fieldingIndex,
      impactIndex: snapshot.impactIndex,
      captaincyIndex: snapshot.captaincyIndex,
      swingIndex: snapshot.swingIndex,
      impactPoints: snapshot.impactPoints,
      seasonPoints: snapshot.seasonPoints,
      rankKey: snapshot.rankKey as CompetitiveRankKey | null,
      division: snapshot.division,
      rankLabel: snapshot.rankKey && snapshot.division
        ? formatRankLabel(snapshot.rankKey as CompetitiveRankKey, snapshot.division)
        : snapshot.rankKey
          ? formatRankLabel(snapshot.rankKey as CompetitiveRankKey, 1)
          : null,
    }))
  }

  async getPlayerIndexBreakdown(
    playerId: string,
    axis: PlayerIndexAxis,
    window: RankWindow = 'LAST_10',
  ): Promise<PlayerIndexBreakdownResponse> {
    const windowRows = await this.getWindowRows(playerId, window)
    const breakdowns = windowRows.map((row, index) => {
      const recentScores = windowRows
        .slice(Math.max(0, index - 4), index)
        .map((entry) => entry.score.gameInfluenceIndex ?? entry.score.performanceScore)
      const combined = this.computeSingleMatchArtifacts(row.fact, row.allFacts, recentScores, row.passMultiplier)
      switch (axis) {
        case 'reliability':
          return combined.reliability
        case 'power':
          return combined.power
        case 'bowling':
          return combined.bowling
        case 'fielding':
          return combined.fielding
        case 'impact':
          return combined.impact
        case 'captaincy':
          return combined.captaincy
        default:
          return combined.reliability
      }
    })

    const score = averageAxisValues(breakdowns.map((item) => item.score))
    const averagedBreakdown = averageBreakdownEntries(breakdowns.map((item) => item.breakdown))

    return {
      axis,
      window,
      score,
      matchesSampled: windowRows.length,
      breakdown: averagedBreakdown,
      insight: this.buildWindowInsight(axis, score, averagedBreakdown),
    }
  }

  async getPlayerPhysical(playerId: string): Promise<PlayerPhysicalSummary> {
    const samples = await prisma.playerPhysicalSample.findMany({
      where: { playerId },
      orderBy: [{ sampleStartAt: 'desc' }, { createdAt: 'desc' }],
      take: 10,
    })
    const latest = samples[0]

    return {
      currentPhysicalIndex: latest?.workloadScore ?? 0,
      recentSamples: samples.map((sample) => ({
        id: sample.id,
        sourceType: sample.sourceType,
        sampleStartAt: sample.sampleStartAt.toISOString(),
        sampleEndAt: sample.sampleEndAt.toISOString(),
        workloadScore: sample.workloadScore,
        recoveryScore: sample.recoveryScore,
        distanceMeters: sample.distanceMeters,
        sprintCount: sample.sprintCount,
        activeMinutes: sample.activeMinutes,
        caloriesBurned: sample.caloriesBurned,
        averageHeartRate: sample.averageHeartRate,
        maxHeartRate: sample.maxHeartRate,
      })),
    }
  }

  async ingestWearableSample(
    userId: string,
    payload: {
      sourceRefId?: string
      sampleStartAt: string
      sampleEndAt: string
      caloriesBurned?: number
      averageHeartRate?: number
      maxHeartRate?: number
      distanceMeters?: number
      sprintCount?: number
      activeMinutes?: number
      workloadScore?: number
      recoveryScore?: number
      sleepHours?: number
      hydrationMetric?: number
      steps?: number
      hrv?: number
      sleepStartAt?: string
      sleepEndAt?: string
      weightKg?: number
      source?: string
      rawPayload?: Record<string, unknown>
    },
  ) {
    const player = await prisma.playerProfile.findUnique({ where: { userId } })
    if (!player) throw new Error('Player profile not found')

    // Physical samples are deliberately split from match proxies so wearable integrations
    // can arrive later without redesigning the match-performance schema.
    return prisma.playerPhysicalSample.create({
      data: {
        playerId: player.id,
        sourceType: 'WEARABLE',
        sourceRefId: payload.sourceRefId,
        sampleStartAt: new Date(payload.sampleStartAt),
        sampleEndAt: new Date(payload.sampleEndAt),
        caloriesBurned: payload.caloriesBurned,
        averageHeartRate: payload.averageHeartRate,
        maxHeartRate: payload.maxHeartRate,
        distanceMeters: payload.distanceMeters,
        sprintCount: payload.sprintCount,
        activeMinutes: payload.activeMinutes,
        workloadScore: payload.workloadScore,
        recoveryScore: payload.recoveryScore,
        sleepHours: payload.sleepHours,
        hydrationMetric: payload.hydrationMetric,
        steps: payload.steps,
        hrv: payload.hrv,
        sleepStartAt: payload.sleepStartAt ? new Date(payload.sleepStartAt) : null,
        sleepEndAt: payload.sleepEndAt ? new Date(payload.sleepEndAt) : null,
        weightKg: payload.weightKg,
        source: payload.source,
        rawPayload: toInputJsonObject(payload.rawPayload),
      },
    })
  }

  async ingestWellnessCheckin(
    payload: {
      playerId: string
      date: string | Date
      soreness: number
      fatigue: number
      mood: number
      stress: number
      painTightness: number
      sleepQuality: number
      notes?: string
    },
  ) {
    const { playerId, date: dateInput, ...ratings } = payload
    const date = new Date(dateInput)
    date.setUTCHours(0, 0, 0, 0)

    const notes = ratings.notes?.trim() || null

    const record = await prisma.playerWellnessCheckin.upsert({
      where: {
        playerId_date: {
          playerId,
          date,
        },
      },
      create: {
        playerId,
        date,
        soreness: ratings.soreness,
        fatigue: ratings.fatigue,
        mood: ratings.mood,
        stress: ratings.stress,
        painTightness: ratings.painTightness,
        sleepQuality: ratings.sleepQuality,
        notes,
      },
      update: {
        soreness: ratings.soreness,
        fatigue: ratings.fatigue,
        mood: ratings.mood,
        stress: ratings.stress,
        painTightness: ratings.painTightness,
        sleepQuality: ratings.sleepQuality,
        notes,
      },
    })

    await this.journalStreak.refreshRollingWindow(playerId)
    return record
  }

  async getLatestWellnessCheckin(playerId: string) {
    return prisma.playerWellnessCheckin.findFirst({
      where: { playerId },
      orderBy: { date: 'desc' },
    })
  }

  async getWellnessHistory(playerId: string, days = 7) {
    const since = new Date()
    since.setUTCDate(since.getUTCDate() - days)
    since.setUTCHours(0, 0, 0, 0)

    return prisma.playerWellnessCheckin.findMany({
      where: {
        playerId,
        date: { gte: since },
      },
      orderBy: { date: 'desc' },
    })
  }

  async ingestWorkloadEvent(
    payload: {
      playerId: string
      type: string
      date: string | Date
      durationMinutes: number
      intensity?: number
      oversBowled?: number
      ballsBowled?: number
      battingMinutes?: number
      ballsFaced?: number
      spellCount?: number
      source?: string
      sourceRefId?: string
      notes?: string
    },
  ) {
    const { playerId, date: dateInput, ...details } = payload
    const date = new Date(dateInput)
    const notes = details.notes?.trim() || null

    const record = await prisma.playerWorkloadEvent.create({
      data: {
        playerId,
        type: details.type,
        date,
        durationMinutes: details.durationMinutes,
        intensity: details.intensity,
        oversBowled: details.oversBowled,
        ballsBowled: details.ballsBowled,
        battingMinutes: details.battingMinutes,
        ballsFaced: details.ballsFaced,
        spellCount: details.spellCount,
        source: details.source,
        sourceRefId: details.sourceRefId,
        notes,
      },
    })

    await this.journalStreak.refreshRollingWindow(playerId)
    return record
  }

  async getRecentWorkloadEvents(playerId: string, limit = 10) {
    return prisma.playerWorkloadEvent.findMany({
      where: { playerId },
      orderBy: { date: 'desc' },
      take: limit,
    })
  }

  async getWorkloadHistory(playerId: string, type?: string, days = 7) {
    const since = new Date()
    since.setUTCDate(since.getUTCDate() - days)
    since.setUTCHours(0, 0, 0, 0)

    return prisma.playerWorkloadEvent.findMany({
      where: {
        playerId,
        ...(type ? { type } : {}),
        date: { gte: since },
      },
      orderBy: { date: 'desc' },
    })
  }

  async getWorkloadSummary(playerId: string, days = 7) {
    const since = new Date()
    since.setUTCDate(since.getUTCDate() - days)
    since.setUTCHours(0, 0, 0, 0)

    const events = await prisma.playerWorkloadEvent.findMany({
      where: {
        playerId,
        date: { gte: since },
      },
    })

    const summary = {
      totalEvents: events.length,
      totalDurationMinutes: 0,
      totalOversBowled: 0,
      totalBallsBowled: 0,
      totalBattingMinutes: 0,
      totalBallsFaced: 0,
      groupedByType: {} as Record<string, number>,
    }

    for (const event of events) {
      summary.totalDurationMinutes += event.durationMinutes
      summary.totalOversBowled += event.oversBowled ?? 0
      summary.totalBallsBowled += event.ballsBowled ?? 0
      summary.totalBattingMinutes += event.battingMinutes ?? 0
      summary.totalBallsFaced += event.ballsFaced ?? 0
      summary.groupedByType[event.type] = (summary.groupedByType[event.type] || 0) + 1
    }

    // Round overs to 1 decimal
    summary.totalOversBowled = round(summary.totalOversBowled, 1)

    return summary
  }

  async getHealthDashboard(playerId: string) {
    const now = new Date()
    const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
    const twentyEightDaysAgo = new Date(now.getTime() - 28 * 24 * 60 * 60 * 1000)

    const [
      wellness,
      recentWorkload,
      historicalWorkload,
      latestPhysical,
    ] = await Promise.all([
      prisma.playerWellnessCheckin.findFirst({
        where: { playerId },
        orderBy: { date: 'desc' },
      }),
      prisma.playerWorkloadEvent.findMany({
        where: { playerId, date: { gte: sevenDaysAgo } },
      }),
      prisma.playerWorkloadEvent.findMany({
        where: { playerId, date: { gte: twentyEightDaysAgo } },
      }),
      prisma.playerPhysicalSample.findFirst({
        where: { playerId },
        orderBy: { sampleStartAt: 'desc' },
      }),
    ])

    // --- WORKLOAD AGGREGATES ---

    const buildSummary = (events: any[]) => {
      const summary = {
        totalDuration: 0,
        totalOvers: 0,
        totalBalls: 0,
        totalBattingMinutes: 0,
        totalBallsFaced: 0,
        intensityAvg: 0,
        typeCounts: {} as Record<string, number>,
      }
      if (events.length === 0) return summary

      let intensitySum = 0
      let intensityCount = 0

      for (const e of events) {
        summary.totalDuration += e.durationMinutes
        summary.totalOvers += e.oversBowled ?? 0
        summary.totalBalls += e.ballsBowled ?? 0
        summary.totalBattingMinutes += e.battingMinutes ?? 0
        summary.totalBallsFaced += e.ballsFaced ?? 0
        summary.typeCounts[e.type] = (summary.typeCounts[e.type] || 0) + 1
        if (e.intensity) {
          intensitySum += e.intensity
          intensityCount++
        }
      }
      summary.intensityAvg = intensityCount > 0 ? round(intensitySum / intensityCount, 1) : 0
      summary.totalOvers = round(summary.totalOvers, 1)
      return summary
    }

    const summary7d = buildSummary(recentWorkload)
    const summary28d = buildSummary(historicalWorkload)

    // --- SCORING LOGIC ---

    // 1. Workload Status (ACWR: Acute Chronic Workload Ratio)
    // Acute = load in last 7 days. Chronic = average weekly load in last 28 days.
    const acuteLoad = recentWorkload.reduce((sum, e) => sum + (e.durationMinutes * (e.intensity ?? 5)), 0)
    const chronicLoad = (historicalWorkload.reduce((sum, e) => sum + (e.durationMinutes * (e.intensity ?? 5)), 0) || 1) / 4
    const acwr = acuteLoad / chronicLoad

    let workloadStatus: 'OPTIMAL' | 'ELEVATED' | 'OVERLOAD' | 'UNDERLOAD' = 'OPTIMAL'
    if (acwr > 1.5) workloadStatus = 'OVERLOAD'
    else if (acwr > 1.3) workloadStatus = 'ELEVATED'
    else if (acwr < 0.8 && chronicLoad > 100) workloadStatus = 'UNDERLOAD'

    // 2. Readiness Score (0-100)
    let readinessScore = 70 // Default
    if (wellness) {
      const wellnessAvg = (wellness.soreness + wellness.fatigue + wellness.mood + wellness.stress + wellness.sleepQuality) / 5
      readinessScore = round(wellnessAvg * 10, 0)
    }
    // Adjust readiness based on ACWR
    if (workloadStatus === 'OVERLOAD') readinessScore = clamp(readinessScore - 15, 0, 100)
    else if (workloadStatus === 'OPTIMAL') readinessScore = clamp(readinessScore + 5, 0, 100)

    // 3. Freshness Score (0-100)
    // Freshness is readiness minus current acute fatigue proxy
    const fatigueProxy = clamp((acuteLoad / (chronicLoad * 2 || 1)) * 20, 0, 30)
    let freshnessScore = clamp(readinessScore - fatigueProxy, 0, 100)
    if (wellness && wellness.soreness > 7) freshnessScore = clamp(freshnessScore - 10, 0, 100)

    // 4. Recovery Status
    let recoveryStatus: 'GOOD' | 'MODERATE' | 'LOW' = 'MODERATE'
    if (wellness) {
      if (wellness.sleepQuality >= 8 && wellness.soreness <= 3) recoveryStatus = 'GOOD'
      else if (wellness.sleepQuality <= 4 || wellness.soreness >= 8 || wellness.fatigue >= 8) recoveryStatus = 'LOW'
    }

    // --- INSIGHTS ---

    const insights: string[] = []
    if (workloadStatus === 'OVERLOAD') insights.push('Workload is significantly above your recent average. High injury risk.')
    if (workloadStatus === 'UNDERLOAD') insights.push('Workload is low. Consider increasing intensity to build fitness.')
    if (wellness && wellness.sleepQuality < 5) insights.push('Poor sleep quality is hindering your recovery.')
    if (summary7d.totalOvers > (summary28d.totalOvers / 4) * 1.5) insights.push('High bowling volume detected this week.')
    if (recoveryStatus === 'GOOD' && workloadStatus === 'OPTIMAL') insights.push('You are in an optimal state for high-intensity training.')
    if (wellness && wellness.soreness > wellness.fatigue + 3) insights.push('Localized soreness is high. Focus on mobility and active recovery.')

    return {
      playerId,
      latestPhysicalSample: latestPhysical,
      latestWellness: wellness,
      workload7d: summary7d,
      workload28d: summary28d,
      readinessScore,
      freshnessScore,
      workloadStatus,
      recoveryStatus,
      currentPhysicalIndex: latestPhysical?.workloadScore ?? 0,
      insights: insights.slice(0, 3), // Top 3 insights
    }
  }

  async getPlayerSeason(playerId: string) {
    const [season, progress, multiplier] = await Promise.all([
      this.getActiveSeason(),
      this.getCurrentSeasonProgress(playerId),
      this.getCurrentPassMultiplierForPlayer(playerId),
    ])

    return {
      seasonId: season?.id ?? null,
      seasonName: season?.name ?? null,
      startAt: season?.startAt.toISOString() ?? null,
      endAt: season?.endAt.toISOString() ?? null,
      seasonPoints: progress?.seasonPoints ?? 0,
      mvpCount: progress?.mvpCount ?? 0,
      matchesPlayed: progress?.matchesPlayed ?? 0,
      leaderboardPosition: progress?.currentLeaderboardPosition ?? null,
      passMultiplier: multiplier,
    }
  }

  async getRankConfigPayload() {
    return {
      tiers: getRankConfig(),
      passMultiplier: this.getValidatedPassMultiplier(),
      seasonMilestones: [...COMPETITIVE_SEASON_MILESTONES],
    }
  }

  async getCompetitiveEvents(playerId: string, limit: number) {
    const [scores, matchSnapshots] = await Promise.all([
      prisma.matchPlayerIndexScore.findMany({
        where: { playerId },
        include: { match: { select: { completedAt: true, teamAName: true, teamBName: true } } },
        orderBy: [{ match: { completedAt: 'desc' } }, { createdAt: 'desc' }],
        take: Math.max(limit, 10),
      }),
      prisma.playerIndexSnapshot.findMany({
        where: { playerId, snapshotType: 'MATCH' },
        orderBy: [{ snapshotDate: 'desc' }, { createdAt: 'desc' }],
        take: Math.max(limit * 2, 10),
      }),
    ])

    const rankEvents: CompetitiveActivityEvent[] = []

    const orderedSnapshots = [...matchSnapshots].sort((left, right) => left.snapshotDate.getTime() - right.snapshotDate.getTime())
    for (let index = 1; index < orderedSnapshots.length; index += 1) {
      const previous = orderedSnapshots[index - 1]
      const current = orderedSnapshots[index]
      if (previous.rankKey !== current.rankKey || previous.division !== current.division) {
        rankEvents.push({
          id: `rank:${current.id}`,
          type: 'RANK_PROMOTION',
          title: `Promoted to ${formatRankLabel((current.rankKey ?? 'ROOKIE') as CompetitiveRankKey, current.division ?? 1)}`,
          subtitle: 'Competitive rank updated from verified match results',
          iconType: 'chevron-up',
          impactPoints: null,
          seasonPoints: null,
          createdAt: current.snapshotDate,
        })
      }
    }

    for (let index = 1; index < orderedSnapshots.length; index += 1) {
      const previous = orderedSnapshots[index - 1]
      const current = orderedSnapshots[index]
      for (const milestone of COMPETITIVE_SEASON_MILESTONES) {
        if ((previous.seasonPoints ?? 0) < milestone && (current.seasonPoints ?? 0) >= milestone) {
          rankEvents.push({
            id: `season:${current.id}:${milestone}`,
            type: 'SEASON_MILESTONE',
            title: `Season milestone reached: ${milestone} SP`,
            subtitle: 'Season progression milestone unlocked',
            iconType: 'flag',
            impactPoints: null,
            seasonPoints: milestone,
            createdAt: current.snapshotDate,
          })
        }
      }
    }

    const scoreEvents = scores.flatMap<CompetitiveActivityEvent>((score) => {
      const completedAt = score.match.completedAt ?? score.createdAt
      const events: CompetitiveActivityEvent[] = [
        {
          id: `impact:${score.id}`,
          type: 'IMPACT_POINTS_MATCH',
          title: `Earned ${score.impactPoints} Impact Points`,
          subtitle: `${score.match.teamAName} vs ${score.match.teamBName}`,
          iconType: 'bolt',
          impactPoints: score.impactPoints,
          seasonPoints: null,
          createdAt: completedAt,
        },
        {
          id: `season:${score.id}`,
          type: 'SEASON_POINTS_MATCH',
          title: `Earned ${score.seasonPoints} Season Points`,
          subtitle: `${score.match.teamAName} vs ${score.match.teamBName}`,
          iconType: 'star',
          impactPoints: null,
          seasonPoints: score.seasonPoints,
          createdAt: completedAt,
        },
      ]
      if (score.isMvp) {
        events.push({
          id: `mvp:${score.id}`,
          type: 'MVP_AWARD',
          title: `MVP bonus +${IMPACT_POINT_RULES.bonuses.mvpPoints} Impact Points`,
          subtitle: `${score.match.teamAName} vs ${score.match.teamBName}`,
          iconType: 'trophy',
          impactPoints: IMPACT_POINT_RULES.bonuses.mvpPoints,
          seasonPoints: null,
          createdAt: completedAt,
        })
      }
      return events
    })

    return [...scoreEvents, ...rankEvents]
      .sort((left, right) => right.createdAt.getTime() - left.createdAt.getTime())
      .slice(0, limit)
  }

  async getPointLedger(playerId: string, page: number, limit: number) {
    const events = await this.getCompetitiveEvents(playerId, 200)
    const start = (page - 1) * limit
    const paged = events.slice(start, start + limit)
    return {
      data: paged.map((event) => ({
        id: event.id,
        type: event.type,
        label: event.type.includes('IMPACT') || event.type === 'MVP_AWARD' || event.type === 'RANK_PROMOTION'
          ? 'Impact Points'
          : 'Season Points',
        title: event.title,
        subtitle: event.subtitle,
        impactPoints: event.impactPoints,
        seasonPoints: event.seasonPoints,
        createdAt: event.createdAt.toISOString(),
      })),
      meta: {
        page,
        limit,
        total: events.length,
        totalPages: Math.max(1, Math.ceil(events.length / limit)),
      },
    }
  }

  async getPublicProfileSummary(playerId: string) {
    const stats = await this.getPlayerStatsSummary(playerId)
    return {
      rank: stats.competitive.rank,
      rankKey: stats.competitive.rankKey,
      division: stats.competitive.division,
      lifetimeImpactPoints: stats.competitive.impactPoints,
      currentSwingIndex: stats.swingIndex.currentSwingIndex,
      mvpCount: stats.competitive.mvpCount,
      selectedDisplayedMetrics: {
        reliabilityIndex: stats.swingIndex.reliabilityIndex,
        bowlingIndex: stats.swingIndex.bowlingIndex,
        fieldingIndex: stats.swingIndex.fieldingIndex,
        impactIndex: stats.swingIndex.impactIndex,
      },
    }
  }

  async getCardPerformanceSummary(playerId: string) {
    const [index, reliabilityBreakdown, bowlingBreakdown] = await Promise.all([
      this.getPlayerIndex(playerId),
      this.getPlayerIndexBreakdown(playerId, 'reliability', 'LAST_5'),
      this.getPlayerIndexBreakdown(playerId, 'bowling', 'LAST_5'),
    ])

    return {
      radar: index.radar,
      strengths: index.strengths,
      workOns: index.workOns,
      trendDelta: index.trendDelta,
      insights: {
        reliability: reliabilityBreakdown.insight,
        bowling: bowlingBreakdown.insight,
      },
    }
  }

  async getMatchCompetitiveSummary(matchId: string) {
    const match = await this.getMatchForProcessing(matchId)
    if (!match) {
      return {
        source: 'UNAVAILABLE',
        isOfficial: false,
        isProvisional: false,
        mvp: null,
        leaderboard: [],
        info: this.getImpactCalculationInfo(false),
      }
    }

    const roster = await this.resolveMatchRosters(match)
    const rosterPlayerIds = unique([...roster.teamA, ...roster.teamB].map((item) => item.id))
    if (rosterPlayerIds.length === 0) {
      return {
        source: 'UNAVAILABLE',
        isOfficial: false,
        isProvisional: false,
        mvp: null,
        leaderboard: [],
        info: this.getImpactCalculationInfo(false),
      }
    }

    const playerProfiles = await prisma.playerProfile.findMany({
      where: { id: { in: rosterPlayerIds } },
      include: { user: { select: { name: true } } },
    })
    const playerById = new Map(playerProfiles.map((player) => [player.id, player]))

    const officialScores = match.status === 'COMPLETED' && match.verificationLevel !== 'UNVERIFIED'
      ? await prisma.matchPlayerIndexScore.findMany({
          where: { matchId },
          orderBy: [
            { impactPoints: 'desc' },
            { performanceScore: 'desc' },
            { gameInfluenceIndex: 'desc' },
            { playerId: 'asc' },
          ],
        })
      : []

    if (officialScores.length > 0) {
      const facts = await prisma.matchPlayerFact.findMany({ where: { matchId } })
      const factByPlayerId = new Map(facts.map((fact) => [fact.playerId, fact]))
      const typedFacts = facts as CompetitivePlayerFactInput[]

      const leaderboard = officialScores.map((score) => {
        const player = playerById.get(score.playerId)
        const fact = factByPlayerId.get(score.playerId)
        const context = fact
          ? this.buildCompetitiveContext(fact as CompetitivePlayerFactInput, typedFacts)
          : null
        let breakdown = fact && context
          ? computeImpactPointBreakdown(fact as CompetitivePlayerFactInput, context)
          : this.buildEmptyImpactBreakdown(true)
        if (score.isMvp) {
          breakdown = applyMvpBonusToImpactBreakdown(breakdown)
        }
        return {
          playerId: score.playerId,
          playerName: player?.user.name ?? 'Player',
          teamName: fact?.teamId ?? this.resolveTeamNameForPlayer(score.playerId, match, roster),
          impactPoints: score.impactPoints,
          performanceScore: score.performanceScore,
          isMvp: score.isMvp,
          summary: this.buildImpactSummary(breakdown),
          breakdown,
        }
      })
      const mvp = leaderboard.find((item) => item.isMvp) ?? leaderboard[0] ?? null

      return {
        source: 'OFFICIAL',
        isOfficial: true,
        isProvisional: false,
        mvp,
        leaderboard,
        info: this.getImpactCalculationInfo(true),
      }
    }

    const hasLiveAction = match.innings.some((innings) => innings.ballEvents.length > 0)
    if (!hasLiveAction) {
      const includePlayingPoints = match.status !== 'SCHEDULED'
      const leaderboard = rosterPlayerIds
        .map((playerId) => {
          const breakdown = this.buildEmptyImpactBreakdown(includePlayingPoints)
          return {
            playerId,
            playerName: playerById.get(playerId)?.user.name ?? 'Player',
            teamName: this.resolveTeamNameForPlayer(playerId, match, roster),
            impactPoints: breakdown.totalImpactPoints,
            performanceScore: breakdown.totalImpactPoints,
            isMvp: false,
            summary: includePlayingPoints ? this.buildImpactSummary(breakdown) : 'No impact sample yet.',
            breakdown,
          }
        })
        .sort((left, right) => left.teamName.localeCompare(right.teamName) || left.playerName.localeCompare(right.playerName))

      return {
        source: 'PROVISIONAL',
        isOfficial: false,
        isProvisional: true,
        mvp: null,
        leaderboard,
        info: this.getImpactCalculationInfo(false),
      }
    }

    const liveStatsMap = buildMatchPlayerStats(
      match.innings.map((innings) => ({
        battingTeam: innings.battingTeam,
        balls: innings.ballEvents,
      })),
    )

    const transientMatch = {
      ...match,
      playerMatchStats: Array.from(liveStatsMap.values()).map(({ legalBallsBowled, milestones, ...persisted }) => persisted),
    } as NonNullable<MatchWithScoring>

    const facts = this.buildCompetitiveFacts(transientMatch, roster)
    const provisionalEntries = facts.map((fact) => {
      const context = this.buildCompetitiveContext(fact, facts)
      const computed = computeMatchIndexes({
        fact,
        context,
        recentGameInfluence: [],
        passMultiplier: 1,
      })
      return {
        playerId: fact.playerId,
        playerName: playerById.get(fact.playerId)?.user.name ?? 'Player',
        teamName: fact.teamId,
        impactPoints: computed.impactPoints,
        performanceScore: computed.performanceScore,
        gameInfluenceIndex: computed.gameInfluenceIndex,
        breakdown: computed.impactBreakdown,
        summary: this.buildImpactSummary(computed.impactBreakdown),
      }
    })

    const sorted = [...provisionalEntries].sort((left, right) =>
      right.impactPoints - left.impactPoints ||
      right.performanceScore - left.performanceScore ||
      (right.gameInfluenceIndex ?? 0) - (left.gameInfluenceIndex ?? 0) ||
      left.playerId.localeCompare(right.playerId),
    )

    const mvpPlayerId = sorted[0]?.playerId ?? null
    const leaderboard = sorted.map((entry) => ({
      playerId: entry.playerId,
      playerName: entry.playerName,
      teamName: entry.teamName,
      impactPoints: entry.impactPoints,
      performanceScore: entry.performanceScore,
      isMvp: entry.playerId === mvpPlayerId,
      summary: entry.summary,
      breakdown: entry.breakdown,
    }))

    return {
      source: 'PROVISIONAL',
      isOfficial: false,
      isProvisional: true,
      mvp: leaderboard[0] ?? null,
      leaderboard,
      info: this.getImpactCalculationInfo(false),
    }
  }

  async logHealthActivity(
    playerId: string,
    payload: {
      type: 'HYDRATION' | 'GYM' | 'NETS' | 'SPRINTS' | 'WEIGHT'
      value: number
      notes?: string
      date?: string | Date
    },
  ) {
    const date = payload.date ? new Date(payload.date) : new Date()
    const notes = payload.notes?.trim() || null

    switch (payload.type) {
      case 'HYDRATION':
        return prisma.playerPhysicalSample.create({
          data: {
            playerId,
            sourceType: 'MANUAL',
            sampleStartAt: date,
            sampleEndAt: date,
            hydrationMetric: payload.value, // litres
          },
        })
      case 'WEIGHT':
        return prisma.playerPhysicalSample.create({
          data: {
            playerId,
            sourceType: 'MANUAL',
            sampleStartAt: date,
            sampleEndAt: date,
            weightKg: payload.value,
          },
        })
      case 'GYM':
      case 'NETS':
      case 'SPRINTS': {
        const workload = await prisma.playerWorkloadEvent.create({
          data: {
            playerId,
            type: payload.type,
            date,
            durationMinutes: payload.type === 'SPRINTS' ? 0 : Math.round(payload.value),
            spellCount: payload.type === 'SPRINTS' ? Math.round(payload.value) : null,
            notes,
            source: 'MANUAL_LOGGER',
          },
        })
        await this.journalStreak.refreshRollingWindow(playerId)
        return workload
      }
      default:
        throw new Error('Invalid activity type')
    }
  }

  private async getMatchForProcessing(matchId: string) {
    return prisma.match.findUnique({
      where: { id: matchId },
      include: {
        innings: {
          include: { ballEvents: { orderBy: [{ overNumber: 'asc' }, { ballNumber: 'asc' }] } },
          orderBy: { inningsNumber: 'asc' },
        },
        playerMatchStats: {
          select: {
            id: true, matchId: true, playerProfileId: true, team: true, runs: true, balls: true, 
            fours: true, sixes: true, strikeRate: true, isOut: true, dismissalType: true, 
            battingPosition: true, oversBowled: true, wickets: true, runsConceded: true, 
            wides: true, noBalls: true, economy: true, catches: true, stumpings: true, 
            runOuts: true, isManOfMatch: true
          }
        },
      },
    })
  }

  private resolveTeamNameForPlayer(
    playerId: string,
    match: NonNullable<MatchWithScoring>,
    roster: Awaited<ReturnType<PerformanceService['resolveMatchRosters']>>,
  ) {
    if (roster.teamA.some((player) => player.id === playerId)) return match.teamAName
    if (roster.teamB.some((player) => player.id === playerId)) return match.teamBName
    return 'Team'
  }

  private buildEmptyImpactBreakdown(includePlayingPoints: boolean) {
    const playingPoints = includePlayingPoints ? IMPACT_POINT_RULES.playingPoints : 0
    return {
      baseImpactPoints: playingPoints,
      totalImpactPoints: playingPoints,
      playingPoints,
      battingPoints: 0,
      bowlingPoints: 0,
      fieldingPoints: 0,
      winBonusPoints: 0,
      mvpBonusPoints: 0,
      battingDetails: {
        runsPoints: 0,
        boundaryBonusPoints: 0,
        strikeRateBonusPoints: 0,
        contributionBonusPoints: 0,
      },
      bowlingDetails: {
        wicketPoints: 0,
        dotBallPoints: 0,
        maidenPoints: 0,
        economyBonusPoints: 0,
        haulBonusPoints: 0,
      },
      fieldingDetails: {
        catchPoints: 0,
        runOutPoints: 0,
        stumpingPoints: 0,
      },
    } satisfies ImpactPointBreakdown
  }

  private getImpactCalculationInfo(isOfficial: boolean) {
    return {
      title: 'How Impact Points Work',
      items: [
        `Playing XI: +${IMPACT_POINT_RULES.playingPoints} IP`,
        `Batting: +${IMPACT_POINT_RULES.batting.runPoint} per run, +${IMPACT_POINT_RULES.batting.fourBonus} per four, +${IMPACT_POINT_RULES.batting.sixBonus} per six`,
        `Batting bonus: strike-rate adjustment after ${IMPACT_POINT_RULES.batting.minBallsForStrikeRateAdjustment}+ balls and contribution bonus for a big share of team runs`,
        `Bowling: +${IMPACT_POINT_RULES.bowling.wicketPoints} per wicket, +${IMPACT_POINT_RULES.bowling.dotBallPoints} per dot ball, +${IMPACT_POINT_RULES.bowling.maidenPoints} per maiden`,
        `Bowling bonus: economy adjustment after ${IMPACT_POINT_RULES.bowling.minBallsForEconomyAdjustment}+ balls`,
        `Fielding: +${IMPACT_POINT_RULES.fielding.catchPoints} per catch, +${IMPACT_POINT_RULES.fielding.runOutPoints} per run-out, +${IMPACT_POINT_RULES.fielding.stumpingPoints} per stumping`,
        isOfficial
          ? `Verified result adds +${IMPACT_POINT_RULES.bonuses.teamWinPoints} IP for a team win and +${IMPACT_POINT_RULES.bonuses.mvpPoints} IP for the MVP.`
          : `Live IP is provisional. Team-win and MVP bonuses are added only after the match is completed and verified.`,
      ],
    }
  }

  private buildImpactSummary(breakdown: ImpactPointBreakdown | undefined) {
    if (!breakdown) return 'Impact is loading.'

    const segments = [
      breakdown.playingPoints > 0 ? `${breakdown.playingPoints} playing` : null,
      breakdown.battingPoints > 0 ? `${breakdown.battingPoints} batting` : null,
      breakdown.bowlingPoints > 0 ? `${breakdown.bowlingPoints} bowling` : null,
      breakdown.fieldingPoints > 0 ? `${breakdown.fieldingPoints} fielding` : null,
      breakdown.winBonusPoints > 0 ? `${breakdown.winBonusPoints} win` : null,
      breakdown.mvpBonusPoints > 0 ? `${breakdown.mvpBonusPoints} MVP` : null,
    ].filter((segment): segment is string => Boolean(segment))

    return segments.length > 0 ? segments.join(' + ') : 'Impact sample building'
  }

  private async upsertPlayerMatchStats(match: NonNullable<MatchWithScoring>) {
    const statsMap = buildMatchPlayerStats(
      match.innings.map((innings) => ({
        battingTeam: innings.battingTeam,
        balls: innings.ballEvents,
      })),
    )
    const existingByPlayerId = new Map(
      match.playerMatchStats.map((stats) => [stats.playerProfileId, stats]),
    )
    const refreshedStats: NonNullable<MatchWithScoring>['playerMatchStats'] = []

    for (const [, stats] of statsMap) {
      const { legalBallsBowled, milestones, ...persisted } = stats
      // Patch: remove any IP/XP columns that might cause DB mismatch
      delete (persisted as any).xpAwarded
      delete (persisted as any).rankXpAwarded
      const existing = existingByPlayerId.get(stats.playerProfileId)
      refreshedStats.push({
        id: existing?.id ?? `${match.id}:${stats.playerProfileId}`,
        matchId: match.id,
        playerProfileId: stats.playerProfileId,
        team: stats.team as 'A' | 'B',
        runs: stats.runs,
        balls: stats.balls,
        fours: stats.fours,
        sixes: stats.sixes,
        strikeRate: stats.strikeRate,
        isOut: stats.isOut,
        dismissalType: stats.dismissalType,
        battingPosition: stats.battingPosition,
        oversBowled: stats.oversBowled,
        wickets: stats.wickets,
        runsConceded: stats.runsConceded,
        wides: stats.wides,
        noBalls: stats.noBalls,
        economy: stats.economy,
        catches: stats.catches,
        stumpings: stats.stumpings,
        runOuts: stats.runOuts,
        isManOfMatch: existing?.isManOfMatch ?? false,
      })
      await prisma.playerMatchStats.upsert({
        where: {
          matchId_playerProfileId: {
            matchId: match.id,
            playerProfileId: stats.playerProfileId,
          },
        },
        create: {
          matchId: match.id,
          ...persisted,
        },
        update: persisted,
      })
    }

    return refreshedStats
  }

  private async resolveMatchRosters(match: NonNullable<MatchWithScoring>) {
    const requestedIds = unique([...match.teamAPlayerIds, ...match.teamBPlayerIds])
    const players = await prisma.playerProfile.findMany({
      where: {
        OR: [
          { id: { in: requestedIds } },
          { userId: { in: requestedIds } },
        ],
      },
      include: { user: { select: { id: true } } },
    })

    const map = new Map<string, { id: string; userId: string }>()
    for (const player of players) {
      map.set(player.id, { id: player.id, userId: player.userId })
      map.set(player.userId, { id: player.id, userId: player.userId })
      map.set(player.user.id, { id: player.id, userId: player.userId })
    }

    const teamAPlayerIds = unique(
      match.teamAPlayerIds.map((id) => map.get(id)?.id).filter((id): id is string => Boolean(id)),
    )
    const teamBPlayerIds = unique(
      match.teamBPlayerIds.map((id) => map.get(id)?.id).filter((id): id is string => Boolean(id)),
    )
    const overlappingPlayerIds = teamAPlayerIds.filter((id) => teamBPlayerIds.includes(id))
    const playingXiPlayerIds = new Set([...teamAPlayerIds, ...teamBPlayerIds])
    const statsOutsidePlayingXi = unique(
      match.playerMatchStats
        .map((stat) => stat.playerProfileId)
        .filter((playerId) => !playingXiPlayerIds.has(playerId)),
    )

    if (statsOutsidePlayingXi.length > 0) {
      console.error('[match-processor] Skipping stats for players outside playing XI', {
        matchId: match.id,
        playerIds: statsOutsidePlayingXi,
      })
    }

    return {
      teamA: teamAPlayerIds.map((id) => ({ id })),
      teamB: teamBPlayerIds.map((id) => ({ id })),
      overlappingPlayerIds,
      statsOutsidePlayingXi,
    }
  }

  private buildCompetitiveFacts(
    match: NonNullable<MatchWithScoring>,
    roster: Awaited<ReturnType<PerformanceService['resolveMatchRosters']>>,
  ): CompetitivePlayerFactInput[] {
    const statsByPlayerId = new Map(match.playerMatchStats.map((stat) => [stat.playerProfileId, stat]))
    const maidenByPlayer = this.getMaidenOvers(match)
    const dotBallsByPlayer = this.getDotBalls(match)
    
    // Determine each team's batting innings
    const teamAInningsNo = match.innings.find(i => i.battingTeam === 'A')?.inningsNumber ?? null
    const teamBInningsNo = match.innings.find(i => i.battingTeam === 'B')?.inningsNumber ?? null

    const fieldingWorkloads = this.getFieldingWorkloads(match)
    const resultByTeam = this.getResultByTeam(match)

    const buildFactsForTeam = (
      players: Array<{ id: string }>,
      teamSide: 'A' | 'B',
      teamName: string,
      opponentName: string,
      captainId: string | null | undefined,
    ) => players.map((player) => {
      const stat = statsByPlayerId.get(player.id)
      const inningsNo = teamSide === 'A' ? teamAInningsNo : teamBInningsNo
      const ballsBowledFromEvents = this.getBallsBowled(match, player.id, teamSide === 'A' ? 'B' : 'A')
      
      // Fall back to PlayerMatchStats when ball-by-ball events are absent (manual stat entry)
      let statBallsBowled = 0
      if (stat && stat.oversBowled != null) {
        const completedOvers = Math.floor(stat.oversBowled)
        const partialBalls = Math.round((stat.oversBowled - completedOvers) * 10)
        statBallsBowled = (completedOvers * 6) + partialBalls
      }
      
      const ballsBowled = ballsBowledFromEvents > 0 ? ballsBowledFromEvents : statBallsBowled
      const didBat = Boolean(stat && (stat.battingPosition !== null || stat.balls > 0 || stat.runs > 0 || stat.isOut))
      const didBowl = ballsBowled > 0
        || Boolean(stat && (stat.wickets > 0 || stat.runsConceded > 0 || stat.wides > 0 || stat.noBalls > 0))

      return {
        matchId: match.id,
        playerId: player.id,
        teamId: teamName,
        opponentTeamId: opponentName,
        inningsNo,
        battingPosition: stat?.battingPosition ?? null,
        didBat,
        runs: stat?.runs ?? 0,
        ballsFaced: stat?.balls ?? 0,
        fours: stat?.fours ?? 0,
        sixes: stat?.sixes ?? 0,
        dismissalType: stat?.dismissalType ?? null,
        wasNotOut: didBat ? !(stat?.isOut ?? false) : false,
        didBowl,
        ballsBowled,
        oversBowled: stat?.oversBowled ?? (ballsBowled > 0 ? round(Math.floor(ballsBowled / 6) + (ballsBowled % 6) / 10, 1) : null),
        maidens: maidenByPlayer.get(player.id) ?? 0,
        wickets: stat?.wickets ?? 0,
        runsConceded: stat?.runsConceded ?? 0,
        dotBalls: dotBallsByPlayer.get(player.id) ?? 0,
        wides: stat?.wides ?? 0,
        noBalls: stat?.noBalls ?? 0,
        catches: stat?.catches ?? 0,
        runOuts: stat?.runOuts ?? 0,
        stumpings: stat?.stumpings ?? 0,
        fieldTimeSeconds: fieldingWorkloads.get(player.id)?.fieldTimeSeconds ?? null,
        oversFielded: fieldingWorkloads.get(player.id)?.oversFielded ?? null,
        isCaptain: captainId === player.id,
        result: resultByTeam[teamSide],
        matchFormat: match.format,
        ballType: match.ballType,
        matchDate: match.completedAt ?? match.scheduledAt,
      } satisfies CompetitivePlayerFactInput
    })

    return [
      ...buildFactsForTeam(roster.teamA, 'A', match.teamAName, match.teamBName, match.teamACaptainId),
      ...buildFactsForTeam(roster.teamB, 'B', match.teamBName, match.teamAName, match.teamBCaptainId),
    ]
  }

  private buildCompetitiveContext(fact: CompetitivePlayerFactInput, allFacts: CompetitivePlayerFactInput[]): CompetitiveContext {
    const teamFacts = allFacts.filter((item) => item.teamId === fact.teamId)
    const opponentFacts = allFacts.filter((item) => item.teamId === fact.opponentTeamId)
    const teamRuns = teamFacts.reduce((sum, item) => sum + item.runs, 0)
    const opponentRuns = opponentFacts.reduce((sum, item) => sum + item.runs, 0)
    const teamWickets = teamFacts.filter((item) => item.didBat && !item.wasNotOut).length
    const opponentWickets = opponentFacts.filter((item) => item.didBat && !item.wasNotOut).length
    const closeMatch = this.isCloseMatchFromFacts(teamRuns, opponentRuns, teamWickets, opponentWickets)
    const battingSecondTeam = this.getBattingSecondTeam(allFacts)
    const chaseMatch = battingSecondTeam === fact.teamId
    const firstInningsTeam = teamFacts
      .filter((item) => item.inningsNo === 1)
      .length > 0
      ? fact.teamId
      : fact.opponentTeamId
    const firstInningsRuns = allFacts
      .filter((item) => item.teamId === firstInningsTeam)
      .reduce((sum, item) => sum + item.runs, 0)

    return {
      matchFormat: fact.matchFormat,
      teamRuns,
      teamWickets,
      opponentRuns,
      opponentWickets,
      teamWon: fact.result === 'WIN',
      closeMatch,
      chaseMatch,
      playersInMatch: allFacts.length,
      targetRuns: chaseMatch ? firstInningsRuns + 1 : null,
    }
  }

  private computeSingleMatchArtifacts(
    fact: CompetitivePlayerFactInput,
    allFacts: CompetitivePlayerFactInput[],
    recentGameInfluence: number[],
    passMultiplier: number,
  ) {
    return computeMatchIndexes({
      fact,
      context: this.buildCompetitiveContext(fact, allFacts),
      recentGameInfluence,
      passMultiplier,
    })
  }

  private normalizeSwingMetrics(metrics: Record<string, unknown>) {
    const normalized: Record<string, number | null | undefined> = {}
    for (const [key, value] of Object.entries(metrics)) {
      normalized[key] = typeof value === 'number' && Number.isFinite(value) ? value : null
    }
    return normalized
  }

  private async computeSwingIndexV2Artifacts(playerId: string) {
    const stats120 = await this.eliteStatsExtended.getStats120(playerId)
    if (!stats120) return null

    const normalizedMetrics = this.normalizeSwingMetrics(stats120.metrics as Record<string, unknown>)
    const roleContext = {
      playerRole: typeof (stats120 as any).source?.playerRole === 'string'
        ? String((stats120 as any).source.playerRole)
        : null,
    }
    return {
      stats120,
      detailed: calculateSwingIndexV2(playerId, normalizedMetrics, roleContext),
      summary: calculateSwingIndexV2Summary(playerId, normalizedMetrics, roleContext),
    }
  }

  private async persistSwingIndexV2(
    playerId: string,
    result: SwingIndexV2Result,
    options?: {
      sourceStatsVersion?: string | null
      sourceStatsComputedAt?: Date | null
    },
  ) {
    await upsertSwingPlayerState({
      playerId,
      formulaVersion: result.formulaVersion,
      overallScore: result.swingIndexScore,
      batScore: result.composites.BAT ?? 0,
      bowlScore: result.composites.BOWL ?? 0,
      fieldingImpact: result.composites.FI ?? 0,
      powerScore: result.composites.PW ?? 0,
      impactScore: result.composites.IMP ?? 0,
      axes: result.axes as unknown as Record<string, unknown>,
      subScores: result.subScores as unknown as Record<string, unknown>,
      derivedMetrics: result.derivedMetrics as unknown as Record<string, unknown>,
      weightingMeta: result.weightingMeta as unknown as Record<string, unknown>,
      sourceStatsVersion: options?.sourceStatsVersion ?? null,
      sourceStatsComputedAt: options?.sourceStatsComputedAt ?? null,
      computedAt: new Date(),
    })
  }

  async getPlayerSwingIndexDetailed(playerId: string) {
    const artifacts = await this.computeSwingIndexV2Artifacts(playerId)
    if (!artifacts) {
      throw new Error('Player not found')
    }

    return artifacts.detailed
  }

  async getPlayerSwingIndexSummary(playerId: string): Promise<SwingIndexV2Summary> {
    const artifacts = await this.computeSwingIndexV2Artifacts(playerId)
    if (!artifacts) {
      throw new Error('Player not found')
    }

    return artifacts.summary
  }

  async recalculateSwingIndexV2ForPlayer(playerId: string) {
    const artifacts = await this.computeSwingIndexV2Artifacts(playerId)
    if (!artifacts) {
      return {
        playerId,
        updated: false as const,
        reason: 'PLAYER_NOT_FOUND' as const,
      }
    }

    await this.persistSwingIndexV2(playerId, artifacts.detailed, {
      sourceStatsVersion: 'stats-120-v1',
      sourceStatsComputedAt: new Date(artifacts.stats120.generatedAt),
    })
    return {
      playerId,
      updated: true as const,
      swingIndexScore: artifacts.detailed.swingIndexScore,
      formulaVersion: artifacts.detailed.formulaVersion,
    }
  }

  async backfillSwingIndexV2(options: { batchSize?: number; limit?: number; playerIds?: string[] } = {}) {
    const batchSize = Math.max(1, Math.min(options.batchSize ?? 100, 1000))
    const limit = typeof options.limit === 'number' && options.limit > 0 ? options.limit : null
    const explicitPlayerIds = unique(
      (options.playerIds ?? [])
        .map((playerId) => playerId.trim())
        .filter(Boolean),
    )

    let scanned = 0
    let updated = 0
    let failed = 0
    const failures: Array<{ playerId: string; error: string }> = []

    const processPlayer = async (playerId: string) => {
      scanned += 1
      try {
        const result = await this.recalculateSwingIndexV2ForPlayer(playerId)
        if (result.updated) {
          updated += 1
          return
        }
        failed += 1
        failures.push({
          playerId,
          error: result.reason,
        })
      } catch (error) {
        failed += 1
        failures.push({
          playerId,
          error: error instanceof Error ? error.message : 'Unknown error',
        })
      }
    }

    if (explicitPlayerIds.length > 0) {
      for (const playerId of explicitPlayerIds) {
        if (limit !== null && scanned >= limit) break
        await processPlayer(playerId)
      }
      return {
        formulaVersion: SWING_INDEX_V2_FORMULA_VERSION,
        scanned,
        updated,
        failed,
        failures,
      }
    }

    let cursor: string | null = null
    while (true) {
      if (limit !== null && scanned >= limit) break
      const remaining = limit === null ? batchSize : Math.min(batchSize, limit - scanned)
      if (remaining <= 0) break

      const players: Array<{ id: string }> = await prisma.playerProfile.findMany({
        where: cursor ? { id: { gt: cursor } } : undefined,
        select: { id: true },
        orderBy: { id: 'asc' },
        take: remaining,
      })

      if (players.length === 0) break

      for (const player of players) {
        await processPlayer(player.id)
      }

      cursor = players[players.length - 1]?.id ?? null
    }

    return {
      formulaVersion: SWING_INDEX_V2_FORMULA_VERSION,
      scanned,
      updated,
      failed,
      failures,
    }
  }

  private async rebuildPlayerState(
    playerId: string,
    activeSeason: { id: string; startAt: Date; endAt: Date } | null,
  ) {
    const [facts, metrics, scores] = await Promise.all([
      prisma.matchPlayerFact.findMany({
        where: { playerId },
        orderBy: [{ matchDate: 'asc' }, { createdAt: 'asc' }],
      }),
      prisma.matchPlayerMetric.findMany({
        where: { playerId },
        orderBy: [{ createdAt: 'asc' }],
      }),
      prisma.matchPlayerIndexScore.findMany({
        where: { playerId },
        include: { match: { select: { completedAt: true } } },
        orderBy: [{ match: { completedAt: 'asc' } }, { createdAt: 'asc' }],
      }),
    ])

    const metricsByMatch = new Map(metrics.map((item) => [item.matchId, item]))
    const scoresByMatch = new Map(scores.map((item) => [item.matchId, item]))
    const validFacts = facts.filter((fact) => scoresByMatch.has(fact.matchId))
    const verifiedImpactPoints = scores.reduce((sum, item) => sum + item.impactPoints, 0)
    const mvpCount = scores.filter((item) => item.isMvp).length
    const matchesPlayed = validFacts.length
    const matchesWon = validFacts.filter((fact) => fact.result === 'WIN').length
    const totalRuns = validFacts.reduce((sum, fact) => sum + fact.runs, 0)
    const totalBallsFaced = validFacts.reduce((sum, fact) => sum + fact.ballsFaced, 0)
    const highestScore = validFacts.reduce((max, fact) => Math.max(max, fact.runs), 0)
    const fifties = validFacts.filter((fact) => fact.runs >= 50 && fact.runs < 100).length
    const hundreds = validFacts.filter((fact) => fact.runs >= 100).length
    const totalFours = validFacts.reduce((sum, fact) => sum + fact.fours, 0)
    const totalSixes = validFacts.reduce((sum, fact) => sum + fact.sixes, 0)
    const battingDismissals = validFacts.filter((fact) => fact.didBat && !fact.wasNotOut).length
    const battingAverage = battingDismissals > 0 ? round(totalRuns / battingDismissals, 2) : totalRuns
    const strikeRate = totalBallsFaced > 0 ? round((totalRuns / totalBallsFaced) * 100, 2) : 0
    const totalWickets = validFacts.reduce((sum, fact) => sum + fact.wickets, 0)
    const totalBallsBowled = validFacts.reduce((sum, fact) => sum + fact.ballsBowled, 0)
    const totalOversBowled = round(Math.floor(totalBallsBowled / 6) + (totalBallsBowled % 6) / 10, 1)
    const totalRunsConceded = validFacts.reduce((sum, fact) => sum + fact.runsConceded, 0)
    const bestBowlingFact = validFacts
      .filter((fact) => fact.didBowl)
      .sort((left, right) => right.wickets - left.wickets || left.runsConceded - right.runsConceded)[0]
    const bestBowling = bestBowlingFact ? `${bestBowlingFact.wickets}/${bestBowlingFact.runsConceded}` : null
    const fiveWicketHauls = validFacts.filter((fact) => fact.wickets >= 5).length
    const bowlingAverage = totalWickets > 0 ? round(totalRunsConceded / totalWickets, 2) : 0
    const economyRate = totalBallsBowled > 0 ? round((totalRunsConceded / totalBallsBowled) * 6, 2) : 0
    const bowlingStrikeRate = totalWickets > 0 ? round(totalBallsBowled / totalWickets, 2) : 0
    const catches = validFacts.reduce((sum, fact) => sum + fact.catches, 0)
    const stumpings = validFacts.reduce((sum, fact) => sum + fact.stumpings, 0)
    const runOuts = validFacts.reduce((sum, fact) => sum + fact.runOuts, 0)
    const fallbackRank = resolveRankFromImpactPoints(verifiedImpactPoints)
    const latestRankedMatchAt = validFacts.length > 0
      ? validFacts[validFacts.length - 1]?.matchDate ?? null
      : null
    const competitiveState = {
      lifetimeImpactPoints: verifiedImpactPoints,
      currentRankKey: fallbackRank.rankKey,
      currentDivision: fallbackRank.division,
      rankProgressPoints: Math.max(0, verifiedImpactPoints - fallbackRank.threshold),
      currentDivisionFloor: fallbackRank.threshold,
      lastRankedMatchAt: latestRankedMatchAt,
    }

    let winStreak = 0
    for (let index = validFacts.length - 1; index >= 0; index -= 1) {
      if (validFacts[index].result === 'WIN') {
        winStreak += 1
        continue
      }
      break
    }

    const seasonFacts = activeSeason
      ? validFacts.filter((fact) => fact.matchDate >= activeSeason.startAt && fact.matchDate <= activeSeason.endAt)
      : []
    const seasonPoints = seasonFacts.reduce((sum, fact) => sum + (scoresByMatch.get(fact.matchId)?.seasonPoints ?? 0), 0)
    const seasonMvpCount = seasonFacts.reduce((sum, fact) => sum + (scoresByMatch.get(fact.matchId)?.isMvp ? 1 : 0), 0)

    await upsertIpPlayerState({
      playerId,
      lifetimeIp: competitiveState.lifetimeImpactPoints,
      currentRankKey: competitiveState.currentRankKey,
      currentDivision: competitiveState.currentDivision,
      rankProgressPoints: competitiveState.rankProgressPoints,
      currentDivisionFloor: competitiveState.currentDivisionFloor,
      winStreak,
      mvpCount,
      lastRankedMatchAt: competitiveState.lastRankedMatchAt,
      currentSeasonId: activeSeason?.id ?? null,
    }).catch((error) => {
      console.error('[performance] failed to upsert ip_player_state', {
        playerId,
        error: error instanceof Error ? error.message : 'unknown',
      })
    })

    if (activeSeason) {
      await upsertIpSeasonState({
        playerId,
        seasonId: activeSeason.id,
        seasonPoints,
        mvpCount: seasonMvpCount,
        matchesPlayed: seasonFacts.length,
      }).catch((error) => {
        console.error('[performance] failed to upsert ip_season_state', {
          playerId,
          seasonId: activeSeason.id,
          error: error instanceof Error ? error.message : 'unknown',
        })
      })
    }

    let runningIp = 0
    const matchEngineEvents = validFacts
      .map((fact) => {
        const score = scoresByMatch.get(fact.matchId)
        if (!score) return null
        const ipBefore = runningIp
        const ipDelta = score.impactPoints ?? 0
        runningIp += ipDelta
        const ipAfter = runningIp
        const rankBefore = resolveRankFromImpactPoints(ipBefore)
        const rankAfter = resolveRankFromImpactPoints(ipAfter)
        const seasonId = activeSeason && fact.matchDate >= activeSeason.startAt && fact.matchDate <= activeSeason.endAt
          ? activeSeason.id
          : null
        return {
          playerId,
          seasonId,
          matchId: fact.matchId,
          reason: ipDelta >= 0 ? 'MATCH_IMPACT' : 'MATCH_PENALTY',
          ipDelta,
          ipBefore,
          ipAfter,
          rankBefore: rankBefore.rankKey,
          rankAfter: rankAfter.rankKey,
          divisionBefore: rankBefore.division,
          divisionAfter: rankAfter.division,
          createdAt: score.match?.completedAt ?? fact.matchDate,
        }
      })
      .filter((event): event is NonNullable<typeof event> => Boolean(event))

    await replaceMatchEngineIpEvents(playerId, matchEngineEvents).catch((error) => {
      console.error('[performance] failed to rebuild ip_event rows', {
        playerId,
        error: error instanceof Error ? error.message : 'unknown',
      })
    })

    const swingArtifacts = await this.computeSwingIndexV2Artifacts(playerId)
    const swingDetailed = swingArtifacts?.detailed ?? calculateSwingIndexV2(playerId, {})

    await prisma.playerIndexSnapshot.deleteMany({ where: { playerId } })
    const snapshots = this.buildSnapshots(
      validFacts,
      metricsByMatch,
      scoresByMatch,
      activeSeason,
      swingDetailed.roleWeights,
    )
    if (snapshots.length > 0) {
      await prisma.playerIndexSnapshot.createMany({
        data: snapshots.map((snapshot) => ({
          playerId,
          snapshotType: snapshot.snapshotType as any,
          snapshotDate: snapshot.snapshotDate,
          reliabilityIndex: snapshot.battingIndex,
          bowlingIndex: snapshot.bowlingIndex,
          fieldingIndex: snapshot.fieldingIndex,
          powerIndex: snapshot.consistencyIndex,
          clutchIndex: snapshot.clutchIndex,
          physicalIndex: snapshot.physicalIndex,
          captaincyIndex: snapshot.captaincyIndex,
          swingIndex: snapshot.swingIndex,
          impactPoints: snapshot.impactPoints,
          seasonPoints: snapshot.seasonPoints,
          rankKey: snapshot.rankKey as any,
          division: snapshot.division,
        })),
      })
    }

    const latestLast10 = [...snapshots]
      .reverse()
      .find((snapshot) => snapshot.snapshotType === 'LAST_10')
    const latestLifetime = [...snapshots]
      .reverse()
      .find((snapshot) => snapshot.snapshotType === 'LIFETIME')
    const current = latestLast10 ?? latestLifetime
    const currentSwingIndex = swingDetailed.swingIndexScore

    await upsertSwingPlayerState({
      playerId,
      formulaVersion: swingDetailed.formulaVersion,
      overallScore: swingDetailed.swingIndexScore,
      batScore: swingDetailed.composites.BAT ?? 0,
      bowlScore: swingDetailed.composites.BOWL ?? 0,
      fieldingImpact: swingDetailed.composites.FI ?? 0,
      powerScore: swingDetailed.composites.PW ?? 0,
      impactScore: swingDetailed.composites.IMP ?? 0,
      axes: swingDetailed.axes as unknown as Record<string, unknown>,
      subScores: swingDetailed.subScores as unknown as Record<string, unknown>,
      derivedMetrics: swingDetailed.derivedMetrics as unknown as Record<string, unknown>,
      weightingMeta: swingDetailed.weightingMeta as unknown as Record<string, unknown>,
      sourceStatsVersion: swingArtifacts?.stats120 ? 'stats-120-v1' : null,
      sourceStatsComputedAt: swingArtifacts?.stats120 ? new Date(swingArtifacts.stats120.generatedAt) : null,
      computedAt: new Date(),
    }).catch((error) => {
      console.error('[performance] failed to upsert swing_player_state', {
        playerId,
        error: error instanceof Error ? error.message : 'unknown',
      })
    })

    if (swingArtifacts?.stats120) {
      await upsertPlayerStatOverallFromStats120(playerId, swingArtifacts.stats120).catch((error) => {
        console.error('[performance] failed to upsert PlayerStatOverall', {
          playerId,
          error: error instanceof Error ? error.message : 'unknown',
        })
      })
    }

    await prisma.playerProfile.update({
      where: { id: playerId },
      data: {
        matchesPlayed,
        matchesWon,
        totalRuns,
        totalBallsFaced,
        highestScore,
        fifties,
        hundreds,
        fours: totalFours,
        sixes: totalSixes,
        battingAverage,
        strikeRate,
        totalWickets,
        totalOversBowled,
        bestBowling,
        fiveWicketHauls,
        bowlingAverage,
        economyRate,
        bowlingStrikeRate,
        catches,
        stumpings,
        runOuts,
        swingIndex: currentSwingIndex,
        battingScore: current?.battingIndex ?? 0,
        bowlingScore: current?.bowlingIndex ?? 0,
        fieldingScore: current?.fieldingIndex ?? 0,
        fitnessScore: current?.physicalIndex ?? 0,
        gameIntelligence: current?.consistencyIndex ?? 0,
        coachability: current?.clutchIndex ?? 0,
      },
    }).catch(() => undefined)
  }

  private buildSnapshots(
    facts: Awaited<ReturnType<typeof prisma.matchPlayerFact.findMany>>,
    metricsByMatch: Map<string, Awaited<ReturnType<typeof prisma.matchPlayerMetric.findMany>>[number]>,
    scoresByMatch: Map<string, Awaited<ReturnType<typeof prisma.matchPlayerIndexScore.findMany>>[number]>,
    activeSeason: { id: string; startAt: Date; endAt: Date } | null,
    roleWeights: SwingRoleWeights = DEFAULT_SNAPSHOT_ROLE_WEIGHTS,
  ) {
    const snapshots: Array<{
      snapshotType: 'MATCH' | 'LAST_5' | 'LAST_10' | 'SEASON' | 'LIFETIME' | 'DAILY'
      snapshotDate: Date
      battingIndex: number | null
      bowlingIndex: number | null
      fieldingIndex: number | null
      consistencyIndex: number | null
      clutchIndex: number | null
      physicalIndex: number | null
      captaincyIndex: number | null
      swingIndex: number | null
      impactPoints: number | null
      seasonPoints: number | null
      rankKey: CompetitiveRankKey | null
      division: number | null
    }> = []

    const dailyLatest = new Map<string, typeof snapshots[number]>()
    let runningImpact = 0
    let runningSeasonPoints = 0

    for (let index = 0; index < facts.length; index += 1) {
      const fact = facts[index]
      const score = scoresByMatch.get(fact.matchId)
      if (!score) continue

      runningImpact += score.impactPoints
      if (activeSeason && fact.matchDate >= activeSeason.startAt && fact.matchDate <= activeSeason.endAt) {
        runningSeasonPoints += score.seasonPoints
      }

      const matchRows = facts.slice(Math.max(0, index - 4), index + 1)
      const lastTenRows = facts.slice(Math.max(0, index - 9), index + 1)
      const seasonRows = activeSeason
        ? facts.filter((item) => item.matchDate >= activeSeason.startAt && item.matchDate <= activeSeason.endAt && item.matchDate <= fact.matchDate)
        : []
      const lifetimeRows = facts.slice(0, index + 1)
      const rank = resolveRankFromImpactPoints(runningImpact)

      const buildWindowSnapshot = (
        snapshotType: 'MATCH' | 'LAST_5' | 'LAST_10' | 'SEASON' | 'LIFETIME',
        rows: typeof facts,
      ) => {
        const rowScores = rows.map((item) => scoresByMatch.get(item.matchId)).filter((item): item is NonNullable<typeof item> => Boolean(item))
        const battingIndex = averageAxisValues(rowScores.map((item) => item.battingIndex))
        const bowlingIndex = averageAxisValues(rowScores.map((item) => item.bowlingIndex))
        const fieldingIndex = averageAxisValues(rowScores.map((item) => item.fieldingIndex))
        const consistencyIndex = averageAxisValues(rowScores.map((item) => item.consistencyContribution))
        const clutchIndex = averageAxisValues(rowScores.map((item) => item.clutchIndex))
        const physicalIndex = averageAxisValues(rowScores.map((item) => item.physicalIndex))
        const captaincyIndex = averageAxisValues(rowScores.map((item) => item.captaincyIndex))

        const swingRaw = clamp(
          (roleWeights.batting * (battingIndex ?? 50))
          + (roleWeights.bowling * (bowlingIndex ?? 50))
          + (roleWeights.fielding * (fieldingIndex ?? 50))
          + (roleWeights.impact * (clutchIndex ?? 50)),
          0,
          100,
        )
        const confidenceFactor = Math.min(1, rowScores.length / 6)
        const swingIndex = rowScores.length === 0
          ? null
          : round(clamp(swingRaw * confidenceFactor, 0, 100), 1)

        return {
          snapshotType,
          snapshotDate: fact.matchDate,
          battingIndex,
          bowlingIndex,
          fieldingIndex,
          consistencyIndex,
          clutchIndex,
          physicalIndex,
          captaincyIndex,
          swingIndex,
          impactPoints: snapshotType === 'MATCH'
            ? score.impactPoints
            : runningImpact,
          seasonPoints: activeSeason ? runningSeasonPoints : null,
          rankKey: rank.rankKey,
          division: rank.rankKey === 'APEX' ? 1 : rank.division,
        } as const
      }

      const matchSnapshot = buildWindowSnapshot('MATCH', [fact])
      const last5Snapshot = buildWindowSnapshot('LAST_5', matchRows)
      const last10Snapshot = buildWindowSnapshot('LAST_10', lastTenRows)
      const lifetimeSnapshot = buildWindowSnapshot('LIFETIME', lifetimeRows)

      snapshots.push(matchSnapshot, last5Snapshot, last10Snapshot, lifetimeSnapshot)
      if (seasonRows.length > 0) {
        snapshots.push(buildWindowSnapshot('SEASON', seasonRows))
      }

      dailyLatest.set(toDateOnlyKey(fact.matchDate), {
        snapshotType: 'DAILY',
        snapshotDate: fact.matchDate,
        battingIndex: last10Snapshot.battingIndex,
        bowlingIndex: last10Snapshot.bowlingIndex,
        fieldingIndex: last10Snapshot.fieldingIndex,
        consistencyIndex: last10Snapshot.consistencyIndex,
        clutchIndex: last10Snapshot.clutchIndex,
        physicalIndex: last10Snapshot.physicalIndex,
        captaincyIndex: last10Snapshot.captaincyIndex,
        swingIndex: last10Snapshot.swingIndex,
        impactPoints: runningImpact,
        seasonPoints: activeSeason ? runningSeasonPoints : null,
        rankKey: rank.rankKey,
        division: rank.rankKey === 'APEX' ? 1 : rank.division,
      })
    }

    snapshots.push(...dailyLatest.values())
    return snapshots
  }

  private async recalculateSeasonLeaderboard(seasonId: string) {
    await updateIpSeasonLeaderboard(seasonId).catch((error) => {
      console.error('[performance] failed to recalculate ip_season_state leaderboard', {
        seasonId,
        error: error instanceof Error ? error.message : 'unknown',
      })
    })
  }

  private async getActiveSeason(referenceDate = new Date()) {
    return prisma.competitiveSeason.findFirst({
      where: {
        isActive: true,
        startAt: { lte: referenceDate },
        endAt: { gte: referenceDate },
      },
      orderBy: { startAt: 'desc' },
    })
  }

  private async getCurrentSeasonProgress(playerId: string) {
    const activeSeason = await this.getActiveSeason()
    if (!activeSeason) return null
    const state = await this.readIpSeasonState(playerId, activeSeason.id)
    if (!state) return null
    return {
      id: String(state.id),
      playerId: state.playerId,
      seasonId: state.seasonId,
      seasonPoints: state.seasonPoints,
      mvpCount: state.mvpCount,
      matchesPlayed: state.matchesPlayed,
      currentLeaderboardPosition: state.leaderboardPosition,
      createdAt: state.createdAt,
      updatedAt: state.updatedAt,
    }
  }

  private async getPassMultiplierMap(playerIds: string[], referenceDate: Date) {
    const players = await prisma.playerProfile.findMany({
      where: { id: { in: playerIds } },
      select: { id: true, userId: true },
    })
    const subscriptions = await prisma.subscription.findMany({
      where: {
        userId: { in: players.map((player) => player.userId) },
        status: 'ACTIVE',
        expiresAt: { gte: referenceDate },
      },
    })
    const playersWithPass = new Set(
      subscriptions
        .filter((subscription) => {
          const entityType = subscription.entityType.toUpperCase()
          return entityType.includes('PASS') || entityType.includes('PLAYER')
        })
        .map((subscription) => subscription.userId),
    )
    const multiplier = this.getValidatedPassMultiplier()
    return new Map(players.map((player) => [
      player.id,
      playersWithPass.has(player.userId) ? multiplier : 1,
    ]))
  }

  private async getCurrentPassMultiplierForPlayer(playerId: string) {
    const player = await prisma.playerProfile.findUnique({ where: { id: playerId }, select: { userId: true } })
    if (!player) return 1
    const subscriptions = await prisma.subscription.findMany({
      where: {
        userId: player.userId,
        status: 'ACTIVE',
        expiresAt: { gte: new Date() },
      },
    })
    const hasPass = subscriptions.some((subscription) => {
      const entityType = subscription.entityType.toUpperCase()
      return entityType.includes('PASS') || entityType.includes('PLAYER')
    })
    return hasPass ? this.getValidatedPassMultiplier() : 1
  }

  private getResultByTeam(match: NonNullable<MatchWithScoring>) {
    const teamAWon = match.winnerId === 'A' || match.winnerId?.toLowerCase() === match.teamAName.toLowerCase()
    const teamBWon = match.winnerId === 'B' || match.winnerId?.toLowerCase() === match.teamBName.toLowerCase()
    if (!match.winnerId) {
      return { A: 'NO_RESULT', B: 'NO_RESULT' } as const
    }
    if (teamAWon) return { A: 'WIN', B: 'LOSS' } as const
    if (teamBWon) return { A: 'LOSS', B: 'WIN' } as const
    if (String(match.winMargin ?? '').toLowerCase().includes('tied')) {
      return { A: 'TIE', B: 'TIE' } as const
    }
    return { A: 'NO_RESULT', B: 'NO_RESULT' } as const
  }

  private getBallsBowled(match: NonNullable<MatchWithScoring>, playerId: string, bowlingTeam: 'A' | 'B') {
    let count = 0
    for (const innings of match.innings) {
      if (innings.battingTeam === bowlingTeam) continue
      for (const ball of innings.ballEvents) {
        if (ball.bowlerId === playerId && !['WIDE', 'NO_BALL'].includes(ball.outcome)) {
          count += 1
        }
      }
    }
    return count
  }

  private getMaidenOvers(match: NonNullable<MatchWithScoring>) {
    const maidens = new Map<string, number>()
    for (const innings of match.innings) {
      const overs = new Map<string, { legalBalls: number; runs: number }>()
      for (const ball of innings.ballEvents) {
        const key = `${ball.bowlerId}:${innings.id}:${ball.overNumber}`
        const current = overs.get(key) ?? { legalBalls: 0, runs: 0 }
        if (!['WIDE', 'NO_BALL'].includes(ball.outcome)) {
          current.legalBalls += 1
        }
        current.runs += ball.totalRuns
        overs.set(key, current)
      }
      for (const [key, summary] of overs) {
        if (summary.legalBalls === 6 && summary.runs === 0) {
          const playerId = key.split(':')[0]
          maidens.set(playerId, (maidens.get(playerId) ?? 0) + 1)
        }
      }
    }
    return maidens
  }

  private getDotBalls(match: NonNullable<MatchWithScoring>) {
    const dots = new Map<string, number>()
    for (const innings of match.innings) {
      for (const ball of innings.ballEvents) {
        if (!['WIDE', 'NO_BALL'].includes(ball.outcome) && ball.totalRuns === 0) {
          dots.set(ball.bowlerId, (dots.get(ball.bowlerId) ?? 0) + 1)
        }
      }
    }
    return dots
  }

  private getFirstBattingInnings(match: NonNullable<MatchWithScoring>) {
    const inningsByPlayer = new Map<string, number>()
    for (const innings of match.innings) {
      for (const ball of innings.ballEvents) {
        if (!inningsByPlayer.has(ball.batterId)) {
          inningsByPlayer.set(ball.batterId, innings.inningsNumber)
        }
      }
    }
    return inningsByPlayer
  }

  private getFieldingWorkloads(match: NonNullable<MatchWithScoring>) {
    const workloads = new Map<string, { fieldTimeSeconds: number; oversFielded: number }>()
    const teamA = unique(match.teamAPlayerIds)
    const teamB = unique(match.teamBPlayerIds)

    for (const innings of match.innings) {
      const fieldingTeam = innings.battingTeam === 'A' ? teamB : teamA
      let legalBalls = 0
      for (const ball of innings.ballEvents) {
        if (!['WIDE', 'NO_BALL'].includes(ball.outcome)) {
          legalBalls += 1
        }
      }
      const oversFielded = legalBalls / 6
      const fieldTimeSeconds = legalBalls * DAILY_FIELD_SECONDS_PER_LEGAL_BALL
      for (const playerId of fieldingTeam) {
        const current = workloads.get(playerId) ?? { fieldTimeSeconds: 0, oversFielded: 0 }
        current.fieldTimeSeconds += fieldTimeSeconds
        current.oversFielded += oversFielded
        workloads.set(playerId, current)
      }
    }

    return workloads
  }

  private isCloseMatchFromFacts(teamRuns: number, opponentRuns: number, teamWickets: number, opponentWickets: number) {
    const runGap = Math.abs(teamRuns - opponentRuns)
    const wicketGap = Math.abs(teamWickets - opponentWickets)
    return runGap <= 12 || wicketGap <= 2
  }

  private getBattingSecondTeam(allFacts: CompetitivePlayerFactInput[]) {
    const inningsTwoFact = allFacts.find((fact) => fact.inningsNo === 2)
    return inningsTwoFact?.teamId ?? null
  }

  private async getWindowRows(playerId: string, window: RankWindow) {
    const facts = await prisma.matchPlayerFact.findMany({
      where: { playerId },
      orderBy: [{ matchDate: 'desc' }, { createdAt: 'desc' }],
    })
    const activeSeason = window === 'SEASON' ? await this.getActiveSeason() : null
    const filteredFacts = (() => {
      switch (window) {
        case 'MATCH':
          return facts.slice(0, 1)
        case 'LAST_5':
          return facts.slice(0, 5)
        case 'LAST_10':
          return facts.slice(0, 10)
        case 'SEASON':
          if (!activeSeason) return []
          return facts.filter((fact) => fact.matchDate >= activeSeason.startAt && fact.matchDate <= activeSeason.endAt)
        case 'LIFETIME':
        default:
          return facts
      }
    })().reverse()

    const matchIds = filteredFacts.map((fact) => fact.matchId)
    const [metrics, scores] = await Promise.all([
      prisma.matchPlayerMetric.findMany({ where: { playerId, matchId: { in: matchIds } } }),
      prisma.matchPlayerIndexScore.findMany({ where: { playerId, matchId: { in: matchIds } } }),
    ])
    const metricsByMatch = new Map(metrics.map((item) => [item.matchId, item]))
    const scoresByMatch = new Map(scores.map((item) => [item.matchId, item]))
    const allFactsByMatch = new Map<string, CompetitivePlayerFactInput[]>()
    const relatedFacts = await prisma.matchPlayerFact.findMany({ where: { matchId: { in: matchIds } } })
    for (const fact of relatedFacts) {
      const list = allFactsByMatch.get(fact.matchId) ?? []
      list.push({
        matchId: fact.matchId,
        playerId: fact.playerId,
        teamId: fact.teamId,
        opponentTeamId: fact.opponentTeamId,
        inningsNo: fact.inningsNo,
        battingPosition: fact.battingPosition,
        didBat: fact.didBat,
        runs: fact.runs,
        ballsFaced: fact.ballsFaced,
        fours: fact.fours,
        sixes: fact.sixes,
        dismissalType: fact.dismissalType,
        wasNotOut: fact.wasNotOut,
        didBowl: fact.didBowl,
        ballsBowled: fact.ballsBowled,
        oversBowled: fact.oversBowled,
        maidens: fact.maidens,
        wickets: fact.wickets,
        runsConceded: fact.runsConceded,
        dotBalls: fact.dotBalls,
        wides: fact.wides,
        noBalls: fact.noBalls,
        catches: fact.catches,
        runOuts: fact.runOuts,
        stumpings: fact.stumpings,
        fieldTimeSeconds: fact.fieldTimeSeconds,
        oversFielded: fact.oversFielded,
        isCaptain: fact.isCaptain,
        result: fact.result as CompetitivePlayerFactInput['result'],
        matchFormat: fact.matchFormat,
        ballType: fact.ballType,
        matchDate: fact.matchDate,
      })
      allFactsByMatch.set(fact.matchId, list)
    }

    const passMultiplier = await this.getCurrentPassMultiplierForPlayer(playerId)
    return filteredFacts
      .map((fact) => {
        const score = scoresByMatch.get(fact.matchId)
        if (!score) return null
        return {
          fact: {
            matchId: fact.matchId,
            playerId: fact.playerId,
            teamId: fact.teamId,
            opponentTeamId: fact.opponentTeamId,
            inningsNo: fact.inningsNo,
            battingPosition: fact.battingPosition,
            didBat: fact.didBat,
            runs: fact.runs,
            ballsFaced: fact.ballsFaced,
            fours: fact.fours,
            sixes: fact.sixes,
            dismissalType: fact.dismissalType,
            wasNotOut: fact.wasNotOut,
            didBowl: fact.didBowl,
            ballsBowled: fact.ballsBowled,
            oversBowled: fact.oversBowled,
            maidens: fact.maidens,
            wickets: fact.wickets,
            runsConceded: fact.runsConceded,
            dotBalls: fact.dotBalls,
            wides: fact.wides,
            noBalls: fact.noBalls,
            catches: fact.catches,
            runOuts: fact.runOuts,
            stumpings: fact.stumpings,
            fieldTimeSeconds: fact.fieldTimeSeconds,
            oversFielded: fact.oversFielded,
            isCaptain: fact.isCaptain,
            result: fact.result as CompetitivePlayerFactInput['result'],
            matchFormat: fact.matchFormat,
            ballType: fact.ballType,
            matchDate: fact.matchDate,
          },
          metric: metricsByMatch.get(fact.matchId),
          score,
          allFacts: allFactsByMatch.get(fact.matchId) ?? [],
          passMultiplier,
        }
      })
      .filter((item): item is NonNullable<typeof item> => Boolean(item))
  }

  private buildWindowInsight(axis: PlayerIndexAxis, score: number | null, breakdown: Record<string, number | null>) {
    const strongest = Object.entries(breakdown)
      .filter((entry): entry is [string, number] => typeof entry[1] === 'number')
      .sort((left, right) => right[1] - left[1])[0]
    const weakest = Object.entries(breakdown)
      .filter((entry): entry is [string, number] => typeof entry[1] === 'number')
      .sort((left, right) => left[1] - right[1])[0]

    if (score === null) {
      return `More verified ${axis} data is needed before this window can be explained cleanly.`
    }

    if (axis === 'reliability' && (breakdown.runVolume ?? 0) >= 70 && (breakdown.strikeRateEfficiency ?? 100) <= 55) {
      return 'You are producing runs, but strike rate efficiency is the clearest limiter in this window.'
    }

    if (strongest && weakest && strongest[0] !== weakest[0]) {
      return `Across this ${axis} window, ${safeLabel(strongest[0])} is strongest while ${safeLabel(weakest[0])} needs the most attention.`
    }

    return `This ${axis} window is stable overall, with no single metric dominating yet.`
  }

  private async getIndexTrendDelta(playerId: string) {
    const snapshots = await prisma.playerIndexSnapshot.findMany({
      where: { playerId, snapshotType: 'LAST_5' },
      orderBy: [{ snapshotDate: 'desc' }, { createdAt: 'desc' }],
      take: 2,
    })
    const [current, previous] = snapshots
    if (!current || !previous) {
      return {
        swingIndex: null,
        reliabilityIndex: null,
        powerIndex: null,
        bowlingIndex: null,
        fieldingIndex: null,
        impactIndex: null,
        captaincyIndex: null,
      }
    }

    return {
      swingIndex: round((current.swingIndex ?? 0) - (previous.swingIndex ?? 0), 1),
      reliabilityIndex: round((current.reliabilityIndex ?? 0) - (previous.reliabilityIndex ?? 0), 1),
      powerIndex: round((current.powerIndex ?? 0) - (previous.powerIndex ?? 0), 1),
      bowlingIndex: round((current.bowlingIndex ?? 0) - (previous.bowlingIndex ?? 0), 1),
      fieldingIndex: round((current.fieldingIndex ?? 0) - (previous.fieldingIndex ?? 0), 1),
      impactIndex: round((current.impactIndex ?? 0) - (previous.impactIndex ?? 0), 1),
      captaincyIndex: current.captaincyIndex === null || previous.captaincyIndex === null
        ? null
        : round(current.captaincyIndex - previous.captaincyIndex, 1),
    }
  }
}
