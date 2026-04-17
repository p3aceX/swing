import type { CompetitiveRankKey } from '@swing/db'
import type { CompetitiveRankDivisionConfig, CompetitiveRankTierConfig, PlayerIndexAxis } from '@swing/types'
import {
  COMPETITIVE_RANK_CONFIG,
  IMPACT_POINT_RULES,
  MATCH_FORMAT_BASELINES,
} from './performance.config'
import type {
  AxisScoreResult,
  CompetitiveContext,
  CompetitivePlayerFactInput,
  DerivedMetricRecord,
  ImpactPointBreakdown,
  MatchIndexComputation,
  RankResolution,
} from './performance.types'

function clamp(value: number, min: number, max: number) {
  return Math.min(max, Math.max(min, value))
}

function round(value: number, digits = 1) {
  const factor = 10 ** digits
  return Math.round(value * factor) / factor
}

function average(values: Array<number | null | undefined>) {
  const filtered = values.filter((value): value is number => typeof value === 'number' && Number.isFinite(value))
  if (filtered.length === 0) return null
  return filtered.reduce((sum, value) => sum + value, 0) / filtered.length
}

function weightedAverage(values: Array<{ value: number | null; weight: number }>) {
  const usable = values.filter((item): item is { value: number; weight: number } => item.value !== null)
  if (usable.length === 0) return null
  const totalWeight = usable.reduce((sum, item) => sum + item.weight, 0)
  if (!totalWeight) return null
  return usable.reduce((sum, item) => sum + item.value * item.weight, 0) / totalWeight
}

function normalizeHigh(value: number, baseline: number, strong: number) {
  if (strong <= baseline) return clamp(value, 0, 100)
  const pct = ((value - baseline) / (strong - baseline)) * 100
  return clamp(pct, 0, 100)
}

function normalizeLow(value: number, strong: number, baseline: number) {
  if (baseline <= strong) return clamp(100 - value, 0, 100)
  const pct = ((baseline - value) / (baseline - strong)) * 100
  return clamp(pct, 0, 100)
}

function formatBaseline(format: string | null) {
  return MATCH_FORMAT_BASELINES[format ?? 'CUSTOM'] ?? MATCH_FORMAT_BASELINES.CUSTOM
}

function computeContributionBonus(runs: number, teamRuns: number) {
  if (teamRuns <= 0 || runs <= 0) return 0
  const share = (runs / teamRuns) * 100
  if (share >= 35) return 8
  if (share >= 25) return 5
  if (share >= 15) return 2
  return 0
}

function computeStrikeRateAdjustment(fact: CompetitivePlayerFactInput, context: CompetitiveContext) {
  if (!fact.didBat || fact.ballsFaced < IMPACT_POINT_RULES.batting.minBallsForStrikeRateAdjustment) return 0
  const strikeRate = fact.ballsFaced > 0 ? (fact.runs / fact.ballsFaced) * 100 : 0
  const baseline = formatBaseline(context.matchFormat)

  if (strikeRate >= baseline.strongStrikeRate + 20) return 6
  if (strikeRate >= baseline.strongStrikeRate) return 4
  if (strikeRate >= baseline.baselineStrikeRate) return 2
  if (fact.ballsFaced >= 12 && strikeRate < baseline.baselineStrikeRate * 0.75) return -6
  if (strikeRate < baseline.baselineStrikeRate) return -3
  return 0
}

function computeEconomyAdjustment(fact: CompetitivePlayerFactInput, context: CompetitiveContext) {
  if (!fact.didBowl || fact.ballsBowled < IMPACT_POINT_RULES.bowling.minBallsForEconomyAdjustment) return 0
  const oversBowled = fact.oversBowled ?? (fact.ballsBowled > 0 ? fact.ballsBowled / 6 : 0)
  if (oversBowled <= 0) return 0

  const economy = fact.runsConceded / oversBowled
  const baseline = formatBaseline(context.matchFormat)

  if (economy <= baseline.strongEconomy) return 8
  if (economy <= baseline.baselineEconomy) return 4
  if (economy >= baseline.baselineEconomy + 3) return -8
  if (economy > baseline.baselineEconomy) return -4
  return 0
}

function getRankSteps(config: CompetitiveRankTierConfig[] = COMPETITIVE_RANK_CONFIG) {
  return config
    .flatMap((tier) =>
      tier.divisions.map((division) => ({
        key: tier.key,
        tierLabel: tier.label,
        division: division.division,
        threshold: division.threshold,
        label: division.label,
      })),
    )
    .sort((left, right) => left.threshold - right.threshold)
}

function pickLowest(values: Array<[string, number | null]>) {
  const filtered = values.filter((entry): entry is [string, number] => entry[1] !== null)
  filtered.sort((left, right) => left[1] - right[1])
  return filtered[0] ?? null
}

function pickHighest(values: Array<[string, number | null]>) {
  const filtered = values.filter((entry): entry is [string, number] => entry[1] !== null)
  filtered.sort((left, right) => right[1] - left[1])
  return filtered[0] ?? null
}

function buildInsight(
  axis: PlayerIndexAxis,
  score: number | null,
  breakdown: Record<string, number | null>,
  preferredPositive?: string,
  preferredNegative?: string,
) {
  if (score === null) {
    if (axis === 'captaincy') return 'Captaincy data will appear once you lead verified matches.'
    return `More verified match data is needed before ${axis} insights become reliable.`
  }

  const strongest = pickHighest(Object.entries(breakdown))
  const weakest = pickLowest(Object.entries(breakdown))
  const strongLabel = preferredPositive ?? strongest?.[0] ?? axis
  const weakLabel = preferredNegative ?? weakest?.[0] ?? axis

  if (axis === 'reliability') {
    const runVolume = breakdown.runVolume
    const strikeRateEfficiency = breakdown.strikeRateEfficiency
    const boundaryRate = breakdown.boundaryRate
    if ((runVolume ?? 0) >= 70 && (strikeRateEfficiency ?? 100) <= 55 && (boundaryRate ?? 100) <= 55) {
      return 'You are scoring runs consistently, but your strike rate and boundary frequency are holding back your reliability index.'
    }
  }

  if (axis === 'bowling' && (breakdown.wicketThreat ?? 0) >= 70 && (breakdown.economyControl ?? 100) <= 55) {
    return 'You are creating wicket chances, but tighter control would lift your bowling index further.'
  }

  if ((strongest?.[1] ?? 0) >= 70 && (weakest?.[1] ?? 100) <= 55) {
    return `Your ${strongLabel} is a clear strength, but ${weakLabel} is the biggest drag on this index right now.`
  }

  if ((strongest?.[1] ?? 0) >= 72) {
    return `Your ${strongLabel} is currently leading this index.`
  }

  if ((weakest?.[1] ?? 100) <= 52) {
    return `Improving ${weakLabel} is the clearest way to raise this index.`
  }

  return `This ${axis} score is steady overall, with room to sharpen ${weakLabel}.`
}

export function getRankConfig() {
  return COMPETITIVE_RANK_CONFIG
}

export function resolveRankFromImpactPoints(
  lifetimeImpactPoints: number,
  config: CompetitiveRankTierConfig[] = COMPETITIVE_RANK_CONFIG,
): RankResolution {
  const steps = getRankSteps(config)
  let current = steps[0]
  let nextThreshold: number | null = null

  for (let index = 0; index < steps.length; index += 1) {
    const step = steps[index]
    if (lifetimeImpactPoints >= step.threshold) {
      current = step
      nextThreshold = steps[index + 1]?.threshold ?? null
      continue
    }
    nextThreshold = step.threshold
    break
  }

  return {
    rankKey: current.key as CompetitiveRankKey,
    division: current.division,
    label: current.label,
    threshold: current.threshold,
    nextThreshold,
  }
}

export function formatRankLabel(rankKey: CompetitiveRankKey, division: number) {
  const tier = COMPETITIVE_RANK_CONFIG.find((item) => item.key === rankKey)
  if (!tier) return rankKey
  return tier.divisions.find((item) => item.division === division)?.label ?? tier.label
}

export function mapCompetitiveRankToLegacyTier(rankKey: CompetitiveRankKey) {
  switch (rankKey) {
    case 'ROOKIE':
      return 'GULLY' as const
    case 'STRIKER':
      return 'CLUB_RANK' as const
    case 'VANGUARD':
      return 'DISTRICT' as const
    case 'PHANTOM':
      return 'STATE' as const
    case 'DOMINION':
    case 'ASCENDANT':
      return 'NATIONAL' as const
    case 'IMMORTAL':
    case 'APEX':
    default:
      return 'LEGEND' as const
  }
}

export function computeBattingMetrics(fact: CompetitivePlayerFactInput, context: CompetitiveContext): DerivedMetricRecord {
  const strikeRate = fact.didBat && fact.ballsFaced > 0 ? round((fact.runs / fact.ballsFaced) * 100, 2) : null
  const boundaryRuns = fact.fours * 4 + fact.sixes * 6
  const boundaryRatePerBall = fact.didBat && fact.ballsFaced > 0 ? round((fact.fours + fact.sixes) / fact.ballsFaced, 4) : null
  const boundaryRunsPct = fact.didBat && fact.runs > 0 ? round((boundaryRuns / fact.runs) * 100, 2) : null
  const scoringContributionPct = fact.didBat && context.teamRuns > 0 ? round((fact.runs / context.teamRuns) * 100, 2) : null

  let dismissalStabilityMetric: number | null = null
  if (fact.didBat) {
    dismissalStabilityMetric = fact.wasNotOut
      ? clamp(70 + fact.ballsFaced * 0.8, 0, 100)
      : clamp(42 + fact.ballsFaced * 0.55 + fact.runs * 0.18 - (fact.battingPosition ?? 7) * 1.5, 0, 100)
  }

  let pressureBattingMetric: number | null = null
  if (fact.didBat) {
    const contribution = scoringContributionPct ?? 0
    const srValue = strikeRate ?? 0
    const clutchBoost = context.closeMatch ? 10 : 0
    const chaseBoost = context.chaseMatch ? 8 : 0
    const winBoost = context.teamWon ? 8 : 0
    pressureBattingMetric = clamp(contribution * 0.55 + srValue * 0.18 + clutchBoost + chaseBoost + winBoost, 0, 100)
  }

  return {
    strikeRate,
    boundaryRatePerBall,
    boundaryRunsPct,
    scoringContributionPct,
    dismissalStabilityMetric: dismissalStabilityMetric === null ? null : round(dismissalStabilityMetric, 2),
    pressureBattingMetric: pressureBattingMetric === null ? null : round(pressureBattingMetric, 2),
    economyRate: null,
    ballsPerWicket: null,
    dotBallPct: null,
    wicketContributionPct: null,
    spellQualityMetric: null,
    phaseDifficultyMetric: null,
    fieldingInvolvementMetric: null,
    physicalWorkloadMetric: null,
    captaincyInfluenceMetric: null,
  }
}

export function computeBowlingMetrics(fact: CompetitivePlayerFactInput, context: CompetitiveContext): DerivedMetricRecord {
  const economyRate = fact.didBowl && fact.oversBowled ? round(fact.runsConceded / fact.oversBowled, 2) : null
  const ballsPerWicket = fact.didBowl && fact.wickets > 0 ? round(fact.ballsBowled / fact.wickets, 2) : null
  const dotBallPct = fact.didBowl && fact.ballsBowled > 0 ? round((fact.dotBalls / fact.ballsBowled) * 100, 2) : null
  
  // Fix: If opponent wickets > 0, calculate contribution. If 0, and player bowled, contribution is 0 (failure to take wickets).
  const wicketContributionPct = fact.didBowl 
    ? (context.opponentWickets > 0 ? round((fact.wickets / context.opponentWickets) * 100, 2) : 0)
    : null

  const spellQualityMetric = fact.didBowl
    ? clamp(
        fact.wickets * 16 +
        fact.maidens * 8 +
        fact.dotBalls * 0.8 -
        fact.wides * 3 -
        fact.noBalls * 4 -
        fact.runsConceded * 0.18,
        0,
        100,
      )
    : null
  const phaseDifficultyMetric = fact.didBowl
    ? clamp(
        (fact.oversBowled ?? 0) * 10 +
        (context.closeMatch ? 12 : 0) +
        (context.chaseMatch ? 8 : 0) +
        (context.teamWon ? 6 : 0),
        0,
        100,
      )
    : null

  return {
    strikeRate: null,
    boundaryRatePerBall: null,
    boundaryRunsPct: null,
    scoringContributionPct: null,
    dismissalStabilityMetric: null,
    pressureBattingMetric: null,
    economyRate,
    ballsPerWicket,
    dotBallPct,
    wicketContributionPct,
    spellQualityMetric: spellQualityMetric === null ? null : round(spellQualityMetric, 2),
    phaseDifficultyMetric: phaseDifficultyMetric === null ? null : round(phaseDifficultyMetric, 2),
    fieldingInvolvementMetric: null,
    physicalWorkloadMetric: null,
    captaincyInfluenceMetric: null,
  }
}

export function computeFieldingMetrics(fact: CompetitivePlayerFactInput, context: CompetitiveContext): DerivedMetricRecord {
  const fieldingEvents = fact.catches + fact.runOuts + fact.stumpings
  const fieldingInvolvementMetric = clamp(
    45 + // Baseline participation boost
    (fact.fieldTimeSeconds ? fact.fieldTimeSeconds / 180 : 0) +
    fieldingEvents * 14 +
    (context.closeMatch ? 4 : 0),
    0,
    100,
  )

  return {
    strikeRate: null,
    boundaryRatePerBall: null,
    boundaryRunsPct: null,
    scoringContributionPct: null,
    dismissalStabilityMetric: null,
    pressureBattingMetric: null,
    economyRate: null,
    ballsPerWicket: null,
    dotBallPct: null,
    wicketContributionPct: null,
    spellQualityMetric: null,
    phaseDifficultyMetric: null,
    fieldingInvolvementMetric: round(fieldingInvolvementMetric, 2),
    physicalWorkloadMetric: null,
    captaincyInfluenceMetric: null,
  }
}

export function computePhysicalProxy(fact: CompetitivePlayerFactInput) {
  const workload = clamp(
    fact.ballsBowled * 1.1 +
    fact.ballsFaced * 0.75 +
    (fact.fieldTimeSeconds ?? 0) / 45 +
    (fact.catches + fact.runOuts + fact.stumpings) * 10,
    0,
    100,
  )
  const movement = fact.oversFielded !== null
    ? clamp((fact.oversFielded / 20) * 100, 0, 100)
    : fact.fieldTimeSeconds !== null
      ? clamp((fact.fieldTimeSeconds / 5400) * 100, 0, 100)
      : null
  const repeatedInvolvement = clamp(
    fact.ballsFaced * 0.8 + fact.ballsBowled * 0.9 + (fact.catches + fact.runOuts + fact.stumpings) * 14,
    0,
    100,
  )

  return {
    workload: round(workload, 2),
    movement: movement === null ? null : round(movement, 2),
    repeatedInvolvement: round(repeatedInvolvement, 2),
  }
}

export function computeCaptaincyProxy(fact: CompetitivePlayerFactInput, context: CompetitiveContext) {
  if (!fact.isCaptain) {
    return {
      captaincyInfluenceMetric: null,
      winControl: null,
      closeMatchControl: null,
      chaseControl: null,
    }
  }

  const captaincyInfluenceMetric = clamp(
    50 +
    (context.teamWon ? 18 : 0) +
    (context.closeMatch ? 10 : 0) +
    (context.chaseMatch ? 8 : 0),
    0,
    100,
  )

  return {
    captaincyInfluenceMetric: round(captaincyInfluenceMetric, 2),
    winControl: context.teamWon ? 84 : 58,
    closeMatchControl: context.closeMatch ? (context.teamWon ? 80 : 60) : 64,
    chaseControl: context.chaseMatch ? (context.teamWon ? 78 : 56) : 62,
  }
}

export function computeBattingIndex(
  fact: CompetitivePlayerFactInput,
  metrics: DerivedMetricRecord,
  context: CompetitiveContext,
): AxisScoreResult {
  // DNB is intentionally neutral here. Competitive scoring should not punish
  // lower-order batters for having no batting sample in a verified match.
  if (!fact.didBat) {
    return {
      score: null,
      breakdown: {
        runVolume: null,
        strikeRateEfficiency: null,
        boundaryRate: null,
        contributionShare: null,
        dismissalStability: null,
        pressureBatting: null,
      },
      insight: 'No batting sample was recorded in this match, so batting is not penalized here.',
    }
  }

  const baseline = formatBaseline(context.matchFormat)
  const runVolume = normalizeHigh(fact.runs, baseline.expectedTeamRuns * 0.15, baseline.expectedTeamRuns * 0.42)
  const strikeRateEfficiency = metrics.strikeRate === null
    ? null
    : normalizeHigh(metrics.strikeRate, baseline.baselineStrikeRate, baseline.strongStrikeRate)
  const boundaryRate = metrics.boundaryRatePerBall === null
    ? null
    : normalizeHigh(metrics.boundaryRatePerBall, 0.08, 0.24)
  const contributionShare = metrics.scoringContributionPct === null
    ? null
    : normalizeHigh(metrics.scoringContributionPct, 10, 35)
  const dismissalStability = metrics.dismissalStabilityMetric === null
    ? null
    : clamp(metrics.dismissalStabilityMetric, 0, 100)
  const pressureBatting = metrics.pressureBattingMetric === null
    ? null
    : clamp(metrics.pressureBattingMetric, 0, 100)

  const score = weightedAverage([
    { value: runVolume, weight: 0.32 },
    { value: strikeRateEfficiency, weight: 0.20 },
    { value: boundaryRate, weight: 0.14 },
    { value: contributionShare, weight: 0.16 },
    { value: dismissalStability, weight: 0.08 },
    { value: pressureBatting, weight: 0.10 },
  ])

  const breakdown = {
    runVolume: round(runVolume, 1),
    strikeRateEfficiency: strikeRateEfficiency === null ? null : round(strikeRateEfficiency, 1),
    boundaryRate: boundaryRate === null ? null : round(boundaryRate, 1),
    contributionShare: contributionShare === null ? null : round(contributionShare, 1),
    dismissalStability: dismissalStability === null ? null : round(dismissalStability, 1),
    pressureBatting: pressureBatting === null ? null : round(pressureBatting, 1),
  }

  return {
    score: score === null ? null : round(score, 1),
    breakdown,
    insight: buildInsight('reliability', score, breakdown),
  }
}

export function computeBowlingIndex(
  fact: CompetitivePlayerFactInput,
  metrics: DerivedMetricRecord,
  context: CompetitiveContext,
): AxisScoreResult {
  // Specialist bowlers stay valid MVP candidates because a missing batting sample
  // is not treated as a failed batting performance.
  if (!fact.didBowl) {
    return {
      score: null,
      breakdown: {
        wicketThreat: null,
        economyControl: null,
        dotBallPressure: null,
        spellQuality: null,
        phaseDifficulty: null,
        pressureOvers: null,
      },
      insight: 'No bowling sample was recorded in this match, so bowling is not penalized here.',
    }
  }

  const baseline = formatBaseline(context.matchFormat)
  const wicketThreat = clamp(
    ((metrics.wicketContributionPct ?? 0) * 0.65) +
    (metrics.ballsPerWicket === null ? 0 : normalizeLow(metrics.ballsPerWicket, baseline.strongBallsPerWicket, baseline.strongBallsPerWicket * 2.5) * 0.35),
    0,
    100,
  )
  const economyControl = metrics.economyRate === null
    ? null
    : normalizeLow(metrics.economyRate, baseline.strongEconomy, baseline.baselineEconomy)
  const dotBallPressure = metrics.dotBallPct === null ? null : normalizeHigh(metrics.dotBallPct, 28, 62)
  const spellQuality = metrics.spellQualityMetric === null ? null : clamp(metrics.spellQualityMetric, 0, 100)
  const phaseDifficulty = metrics.phaseDifficultyMetric === null ? null : clamp(metrics.phaseDifficultyMetric, 0, 100)
  const pressureOvers = phaseDifficulty === null
    ? null
    : clamp(phaseDifficulty + (context.closeMatch ? 8 : 0) + (context.teamWon ? 4 : 0), 0, 100)

  const score = weightedAverage([
    { value: wicketThreat, weight: 0.28 },
    { value: economyControl, weight: 0.20 },
    { value: dotBallPressure, weight: 0.16 },
    { value: spellQuality, weight: 0.18 },
    { value: phaseDifficulty, weight: 0.10 },
    { value: pressureOvers, weight: 0.08 },
  ])

  const breakdown = {
    wicketThreat: round(wicketThreat, 1),
    economyControl: economyControl === null ? null : round(economyControl, 1),
    dotBallPressure: dotBallPressure === null ? null : round(dotBallPressure, 1),
    spellQuality: spellQuality === null ? null : round(spellQuality, 1),
    phaseDifficulty: phaseDifficulty === null ? null : round(phaseDifficulty, 1),
    pressureOvers: pressureOvers === null ? null : round(pressureOvers, 1),
  }

  return {
    score: score === null ? null : round(score, 1),
    breakdown,
    insight: buildInsight('bowling', score, breakdown),
  }
}

export function computeFieldingIndex(
  fact: CompetitivePlayerFactInput,
  metrics: DerivedMetricRecord,
): AxisScoreResult {
  const catchImpact = clamp(fact.catches * 28, 0, 100)
  const runOutImpact = clamp(fact.runOuts * 36, 0, 100)
  const stumpingImpact = clamp(fact.stumpings * 34, 0, 100)
  const fieldingInvolvement = metrics.fieldingInvolvementMetric === null
    ? clamp((fact.fieldTimeSeconds ?? 0) / 180, 35, 55)
    : clamp(metrics.fieldingInvolvementMetric, 0, 100)

  const score = weightedAverage([
    { value: catchImpact, weight: 0.28 },
    { value: runOutImpact, weight: 0.26 },
    { value: stumpingImpact, weight: 0.20 },
    { value: fieldingInvolvement, weight: 0.26 },
  ])

  const breakdown = {
    catchImpact: round(catchImpact, 1),
    runOutImpact: round(runOutImpact, 1),
    stumpingImpact: round(stumpingImpact, 1),
    fieldingInvolvement: round(fieldingInvolvement, 1),
  }

  return {
    score: score === null ? null : round(score, 1),
    breakdown,
    insight: buildInsight('fielding', score, breakdown),
  }
}

export function computeConsistencyIndex(recentGameInfluence: number[], currentGameInfluence: number | null): AxisScoreResult {
  if (currentGameInfluence === null) {
    return {
      score: null,
      breakdown: { recentStability: null, repeatContribution: null, sampleDepth: null },
      insight: 'Consistency opens up once enough verified match samples are available.',
    }
  }

  const history = [...recentGameInfluence, currentGameInfluence]
  const mean = history.reduce((sum, value) => sum + value, 0) / history.length
  const variance = history.reduce((sum, value) => sum + (value - mean) ** 2, 0) / history.length
  const stdDev = Math.sqrt(variance)
  const recentStability = normalizeLow(stdDev, 6, 24)
  const repeatContribution = normalizeHigh(mean, 42, 78)
  const sampleDepth = clamp(history.length * 20, 0, 100)
  const score = weightedAverage([
    { value: recentStability, weight: 0.48 },
    { value: repeatContribution, weight: 0.40 },
    { value: sampleDepth, weight: 0.12 },
  ])

  const breakdown = {
    recentStability: round(recentStability, 1),
    repeatContribution: round(repeatContribution, 1),
    sampleDepth: round(sampleDepth, 1),
  }

  return {
    score: score === null ? null : round(score, 1),
    breakdown,
    insight: buildInsight('power', score, breakdown),
  }
}

export function computeClutchIndex(
  fact: CompetitivePlayerFactInput,
  metrics: DerivedMetricRecord,
  context: CompetitiveContext,
  battingIndex: number | null,
  bowlingIndex: number | null,
): AxisScoreResult {
  const closeMatchPerformance = context.closeMatch
    ? clamp(((battingIndex ?? 50) * 0.55) + ((bowlingIndex ?? 50) * 0.45) + (context.teamWon ? 10 : 0), 0, 100)
    : clamp(((battingIndex ?? 45) * 0.5) + ((bowlingIndex ?? 45) * 0.5), 0, 100)
  const chaseImpact = context.chaseMatch
    ? clamp(((metrics.pressureBattingMetric ?? battingIndex ?? 45) * 0.75) + (context.teamWon ? 12 : 0), 0, 100)
    : clamp((metrics.pressureBattingMetric ?? battingIndex ?? 45) * 0.7, 0, 100)
  const pressurePlays = clamp(
    ((metrics.phaseDifficultyMetric ?? bowlingIndex ?? 45) * 0.55) +
    ((fact.catches + fact.runOuts + fact.stumpings) * 10) +
    (context.closeMatch ? 10 : 0),
    0,
    100,
  )

  const score = weightedAverage([
    { value: closeMatchPerformance, weight: 0.42 },
    { value: chaseImpact, weight: 0.30 },
    { value: pressurePlays, weight: 0.28 },
  ])

  const breakdown = {
    closeMatchPerformance: round(closeMatchPerformance, 1),
    chaseImpact: round(chaseImpact, 1),
    pressurePlays: round(pressurePlays, 1),
  }

  return {
    score: score === null ? null : round(score, 1),
    breakdown,
    insight: buildInsight('impact', score, breakdown),
  }
}

export function computeCaptaincyIndex(
  fact: CompetitivePlayerFactInput,
  captaincyProxy: ReturnType<typeof computeCaptaincyProxy>,
): AxisScoreResult {
  if (!fact.isCaptain || captaincyProxy.captaincyInfluenceMetric === null) {
    return {
      score: null,
      breakdown: {
        winControl: null,
        closeMatchControl: null,
        chaseControl: null,
        captaincyInfluence: null,
      },
      insight: 'Captaincy hooks are ready, but this player did not captain this verified match.',
    }
  }

  const score = weightedAverage([
    { value: captaincyProxy.winControl, weight: 0.32 },
    { value: captaincyProxy.closeMatchControl, weight: 0.24 },
    { value: captaincyProxy.chaseControl, weight: 0.18 },
    { value: captaincyProxy.captaincyInfluenceMetric, weight: 0.26 },
  ])

  const breakdown = {
    winControl: round(captaincyProxy.winControl ?? 0, 1),
    closeMatchControl: round(captaincyProxy.closeMatchControl ?? 0, 1),
    chaseControl: round(captaincyProxy.chaseControl ?? 0, 1),
    captaincyInfluence: round(captaincyProxy.captaincyInfluenceMetric, 1),
  }

  return {
    score: score === null ? null : round(score, 1),
    breakdown,
    insight: buildInsight('captaincy', score, breakdown),
  }
}

export function computeSwingIndex(scores: {
  reliabilityIndex: number | null
  bowlingIndex: number | null
  fieldingIndex: number | null
  powerIndex: number | null
  impactIndex: number | null
  physicalIndex: number | null
  captaincyIndex: number | null
  didBat?: boolean
  didBowl?: boolean
  isKeeper?: boolean
  playerRole?: string | null
}) {
  type RoleTemplate = 'pure_batter' | 'batting_all_rounder' | 'bowling_all_rounder' | 'pure_bowler' | 'keeper_batter'
  const roleWeights: Record<RoleTemplate, { batting: number; bowling: number; fielding: number; impact: number }> = {
    pure_batter: { batting: 0.50, bowling: 0.00, fielding: 0.20, impact: 0.30 },
    batting_all_rounder: { batting: 0.40, bowling: 0.20, fielding: 0.15, impact: 0.25 },
    bowling_all_rounder: { batting: 0.25, bowling: 0.35, fielding: 0.15, impact: 0.25 },
    pure_bowler: { batting: 0.10, bowling: 0.50, fielding: 0.15, impact: 0.25 },
    keeper_batter: { batting: 0.45, bowling: 0.00, fielding: 0.25, impact: 0.30 },
  }

  const normalizedRole = scores.playerRole?.trim().toUpperCase()
  let roleTemplate: RoleTemplate

  if (normalizedRole === 'BATSMAN') {
    roleTemplate = 'pure_batter'
  } else if (normalizedRole === 'BOWLER') {
    roleTemplate = 'pure_bowler'
  } else if (normalizedRole === 'WICKET_KEEPER' || normalizedRole === 'WICKET_KEEPER_BATSMAN') {
    roleTemplate = 'keeper_batter'
  } else if (normalizedRole === 'ALL_ROUNDER') {
    roleTemplate = (scores.bowlingIndex ?? 50) > (scores.reliabilityIndex ?? 50)
      ? 'bowling_all_rounder'
      : 'batting_all_rounder'
  } else if (scores.isKeeper) {
    roleTemplate = 'keeper_batter'
  } else if (scores.didBat && !scores.didBowl) {
    roleTemplate = 'pure_batter'
  } else if (scores.didBowl && !scores.didBat) {
    roleTemplate = 'pure_bowler'
  } else {
    roleTemplate = (scores.bowlingIndex ?? 50) > (scores.reliabilityIndex ?? 50)
      ? 'bowling_all_rounder'
      : 'batting_all_rounder'
  }

  const weights = roleWeights[roleTemplate]
  const battingEvidence = Boolean(scores.didBat || scores.reliabilityIndex !== null)
  const bowlingEvidence = Boolean(scores.didBowl || scores.bowlingIndex !== null)
  const fieldingEvidence = scores.fieldingIndex !== null
  const impactEvidence = scores.impactIndex !== null || scores.powerIndex !== null

  const maskedWeights = {
    batting: battingEvidence ? weights.batting : 0,
    bowling: bowlingEvidence ? weights.bowling : 0,
    fielding: fieldingEvidence ? weights.fielding : 0,
    impact: impactEvidence ? weights.impact : 0,
  }
  const activeWeightSum = maskedWeights.batting + maskedWeights.bowling + maskedWeights.fielding + maskedWeights.impact
  const effectiveWeights = activeWeightSum > 0
    ? {
      batting: maskedWeights.batting / activeWeightSum,
      bowling: maskedWeights.bowling / activeWeightSum,
      fielding: maskedWeights.fielding / activeWeightSum,
      impact: maskedWeights.impact / activeWeightSum,
    }
    : weights

  const batting = scores.reliabilityIndex ?? 50
  const bowling = scores.bowlingIndex ?? 50
  const fielding = scores.fieldingIndex ?? 50
  const battingImpact = scores.impactIndex ?? scores.powerIndex ?? scores.reliabilityIndex ?? 50
  const bowlingImpact = scores.impactIndex ?? scores.powerIndex ?? scores.bowlingIndex ?? 50

  const impact = (() => {
    if (battingEvidence && !bowlingEvidence) return battingImpact
    if (bowlingEvidence && !battingEvidence) return bowlingImpact
    if (roleTemplate === 'pure_batter' || roleTemplate === 'keeper_batter') return battingImpact
    if (roleTemplate === 'pure_bowler') return bowlingImpact
    if (roleTemplate === 'batting_all_rounder') return (0.6 * battingImpact) + (0.4 * bowlingImpact)
    return (0.4 * battingImpact) + (0.6 * bowlingImpact)
  })()

  return round(
    clamp(
      (effectiveWeights.batting * batting)
      + (effectiveWeights.bowling * bowling)
      + (effectiveWeights.fielding * fielding)
      + (effectiveWeights.impact * impact),
      0,
      100,
    ),
    1,
  )
}

export function computeImpactPointBreakdown(
  fact: CompetitivePlayerFactInput,
  context: CompetitiveContext,
  options: {
    includePlayingPoints?: boolean
    includeWinBonus?: boolean
    mvpBonusPoints?: number
  } = {},
): ImpactPointBreakdown {
  const playingPoints = options.includePlayingPoints === false ? 0 : IMPACT_POINT_RULES.playingPoints

  const battingDetails = {
    runsPoints: fact.didBat ? fact.runs * IMPACT_POINT_RULES.batting.runPoint : 0,
    boundaryBonusPoints: fact.didBat
      ? (fact.fours * IMPACT_POINT_RULES.batting.fourBonus) + (fact.sixes * IMPACT_POINT_RULES.batting.sixBonus)
      : 0,
    strikeRateBonusPoints: computeStrikeRateAdjustment(fact, context),
    contributionBonusPoints: fact.didBat ? computeContributionBonus(fact.runs, context.teamRuns) : 0,
  }
  const battingPoints = Object.values(battingDetails).reduce((sum, value) => sum + value, 0)

  // Wicket haul bonus — mirrors ip-engine.ts haul bonuses so MVP scoring is consistent
  const haulBonus = (() => {
    if (!fact.didBowl) return 0
    if (fact.wickets >= 5) return 30
    if (fact.wickets >= 3) return 15
    return 0
  })()

  const bowlingDetails = {
    wicketPoints: fact.didBowl ? fact.wickets * IMPACT_POINT_RULES.bowling.wicketPoints : 0,
    dotBallPoints: fact.didBowl ? fact.dotBalls * IMPACT_POINT_RULES.bowling.dotBallPoints : 0,
    maidenPoints: fact.didBowl ? fact.maidens * IMPACT_POINT_RULES.bowling.maidenPoints : 0,
    economyBonusPoints: computeEconomyAdjustment(fact, context),
    haulBonusPoints: haulBonus,
  }
  const bowlingPoints = Object.values(bowlingDetails).reduce((sum, value) => sum + value, 0)

  const fieldingDetails = {
    catchPoints: fact.catches * IMPACT_POINT_RULES.fielding.catchPoints,
    runOutPoints: fact.runOuts * IMPACT_POINT_RULES.fielding.runOutPoints,
    stumpingPoints: fact.stumpings * IMPACT_POINT_RULES.fielding.stumpingPoints,
  }
  const fieldingPoints = Object.values(fieldingDetails).reduce((sum, value) => sum + value, 0)

  const baseImpactPoints = playingPoints + battingPoints + bowlingPoints + fieldingPoints
  const winBonusPoints = options.includeWinBonus === false
    ? 0
    : context.teamWon
      ? IMPACT_POINT_RULES.bonuses.teamWinPoints
      : 0
  const mvpBonusPoints = options.mvpBonusPoints ?? 0
  const totalImpactPoints = clamp(
    baseImpactPoints + winBonusPoints + mvpBonusPoints,
    0,
    IMPACT_POINT_RULES.maxImpactPoints,
  )

  return {
    baseImpactPoints,
    totalImpactPoints,
    playingPoints,
    battingPoints,
    bowlingPoints,
    fieldingPoints,
    winBonusPoints,
    mvpBonusPoints,
    battingDetails,
    bowlingDetails,
    fieldingDetails,
  }
}

export function applyMvpBonusToImpactBreakdown(
  breakdown: ImpactPointBreakdown,
  bonusPoints = IMPACT_POINT_RULES.bonuses.mvpPoints,
): ImpactPointBreakdown {
  return {
    ...breakdown,
    mvpBonusPoints: breakdown.mvpBonusPoints + bonusPoints,
    totalImpactPoints: clamp(
      breakdown.totalImpactPoints + bonusPoints,
      0,
      IMPACT_POINT_RULES.maxImpactPoints,
    ),
  }
}

export function computeMatchIndexes(args: {
  fact: CompetitivePlayerFactInput
  context: CompetitiveContext
  recentGameInfluence: number[]
  passMultiplier: number
}) : MatchIndexComputation {
  const battingMetrics = computeBattingMetrics(args.fact, args.context)
  const bowlingMetrics = computeBowlingMetrics(args.fact, args.context)
  const fieldingMetrics = computeFieldingMetrics(args.fact, args.context)
  const physicalProxy = computePhysicalProxy(args.fact)
  const captaincyProxy = computeCaptaincyProxy(args.fact, args.context)

  const reliability = computeBattingIndex(args.fact, battingMetrics, args.context)
  const bowling = computeBowlingIndex(args.fact, bowlingMetrics, args.context)
  const fielding = computeFieldingIndex(args.fact, fieldingMetrics)
  const power = computeConsistencyIndex(args.recentGameInfluence, weightedAverage([
    { value: reliability.score, weight: 0.45 },
    { value: bowling.score, weight: 0.45 },
    { value: fielding.score, weight: 0.10 },
  ]))
  const impactMetrics: DerivedMetricRecord = {
    ...battingMetrics,
    ...bowlingMetrics,
    pressureBattingMetric: battingMetrics.pressureBattingMetric,
    phaseDifficultyMetric: bowlingMetrics.phaseDifficultyMetric,
  }
  const impact = computeClutchIndex(args.fact, impactMetrics, args.context, reliability.score, bowling.score)
  const captaincy = computeCaptaincyIndex(args.fact, captaincyProxy)

  const swingIndex = computeSwingIndex({
    reliabilityIndex: reliability.score,
    bowlingIndex: bowling.score,
    fieldingIndex: fielding.score,
    powerIndex: power.score,
    impactIndex: impact.score,
    physicalIndex: 0,
    captaincyIndex: captaincy.score,
    didBat: args.fact.didBat,
    didBowl: args.fact.didBowl,
    isKeeper: args.fact.stumpings > 0,
  })

  const gameInfluenceIndex = weightedAverage([
    { value: reliability.score, weight: 0.36 },
    { value: bowling.score, weight: 0.36 },
    { value: fielding.score, weight: 0.12 },
    { value: impact.score, weight: 0.10 },
    { value: captaincy.score, weight: 0.06 },
  ])

  const impactBreakdown = computeImpactPointBreakdown(args.fact, args.context)

  return {
    reliability,
    power,
    bowling,
    fielding,
    impact,
    captaincy,
    swingIndex,
    gameInfluenceIndex: gameInfluenceIndex === null ? 0 : round(gameInfluenceIndex, 1),
    performanceScore: impactBreakdown.totalImpactPoints,
    impactPoints: impactBreakdown.totalImpactPoints,
    impactBreakdown,
    // SP is intentionally derived after IP so premium/pass boosts never change
    // the fair competitive currency used for MVPs and rank progression.
    seasonPoints: Math.round(impactBreakdown.totalImpactPoints * args.passMultiplier),
    passMultiplierApplied: args.passMultiplier,
  }
}

export function averageAxisValues(values: Array<number | null | undefined>) {
  const avg = average(values)
  return avg === null ? null : round(avg, 1)
}

export function averageBreakdownEntries<T extends Record<string, number | null>>(items: T[]) {
  const keys = new Set(items.flatMap((item) => Object.keys(item)))
  const result: Record<string, number | null> = {}
  for (const key of keys) {
    result[key] = average(items.map((item) => item[key]))
    if (typeof result[key] === 'number') {
      result[key] = round(result[key] as number, 1)
    }
  }
  return result
}
