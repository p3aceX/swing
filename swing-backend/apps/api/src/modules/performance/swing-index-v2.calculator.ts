import {
  SWING_INDEX_V2_FORMULA_VERSION,
  SWING_INDEX_V2_NORMALIZATION_RANGES,
  type SwingIndexRangeKey,
} from './swing-index-v2.config'
import {
  clampScore0to100,
  normalizeHigherBetter,
  normalizeLowerBetter,
  safeDivide,
} from './swing-index-v2.normalization'

type SwingMetricRecord = Record<string, number | null | undefined>
type Direction = 'U' | 'D'

export type SwingRoleTemplateKey =
  | 'pure_batter'
  | 'batting_all_rounder'
  | 'bowling_all_rounder'
  | 'pure_bowler'
  | 'keeper_batter'

export type SwingRoleWeights = {
  batting: number
  bowling: number
  fielding: number
  impact: number
}

export type SwingIndexRoleContext = {
  playerRole?: string | null
}

type ScoreComponent = {
  key: string
  weight: number
  value: number | null | undefined
  rangeKey?: SwingIndexRangeKey
  direction?: Direction
  include?: boolean
}

type ScoreBreakdown = {
  originalWeightSum: number
  usedWeightSum: number
  renormalized: boolean
  excludedComponents: string[]
  normalizedComponents: Record<string, number>
}

export type SwingIndexV2SubScores = {
  BR: number | null
  BE: number | null
  PW: number | null
  BV: number | null
  BC: number | null
  BT: number | null
  PB: number | null
  FI: number | null
  WI: number | null
  RF: number | null
  CS: number | null
  Reliability: number | null
  Power: number | null
  BattingImpact: number | null
  Control: number | null
  Threat: number | null
  BowlingImpact: number | null
  Impact: number | null
  TacticalImpact: number | null
  ResultImpact: number | null
  LeadershipTrust: number | null
  Captaincy: number | null
}

export type SwingIndexV2Composites = {
  BAT: number | null
  BOWL: number | null
  FI: number | null
  PW: number | null
  IMP: number | null
  CAP: number | null
}

export type SwingIndexV2Axes = {
  reliabilityAxis: number | null
  powerAxis: number | null
  bowlingAxis: number | null
  fieldingAxis: number | null
  impactAxis: number | null
  captaincyAxis: number | null
}

export type SwingIndexV2DerivedMetrics = {
  sixesPerInnings: number
  widesPerOver: number
  noBallsPerOver: number
  wicketRate: number
  bowledLbwPct: number
  chaseWinPct: number
  defendWinPct: number
  mvpRate: number
  dismissalInvolvementRate: number
  fieldingEvidenceFactor: number
  confidenceFactor: number
  swiRaw: number
  SWI: number
  SWI_raw: number
  Batting: number
  Reliability: number
  Power: number
  BattingImpact: number
  Bowling: number
  Control: number
  Threat: number
  BowlingImpact: number
  Impact: number
  Fielding: number
  FieldingRaw: number
  Captaincy: number | null
  roleTemplate: SwingRoleTemplateKey
  roleWeights: SwingRoleWeights
}

export type SwingIndexV2Result = {
  playerId: string
  formulaVersion: typeof SWING_INDEX_V2_FORMULA_VERSION
  swingIndexScore: number
  composites: SwingIndexV2Composites
  axes: SwingIndexV2Axes
  subScores: SwingIndexV2SubScores
  derivedMetrics: SwingIndexV2DerivedMetrics
  rawMetrics: Record<string, number>
  weightingMeta: {
    excludedSections: string[]
    renormalized: boolean
    details: Record<string, ScoreBreakdown>
  }

  // Required product-facing breakout fields
  SWI: number
  SWI_raw: number
  confidenceFactor: number
  Batting: number
  Reliability: number
  Power: number
  BattingImpact: number
  Bowling: number
  Control: number
  Threat: number
  BowlingImpact: number
  Impact: number
  Fielding: number
  FieldingRaw: number
  fieldingEvidenceFactor: number
  roleTemplate: SwingRoleTemplateKey
  roleWeights: SwingRoleWeights
  Captaincy: number | null
  TacticalImpact: number | null
  ResultImpact: number | null
  LeadershipTrust: number | null
}

export type SwingIndexV2Summary = {
  playerId: string
  formulaVersion: typeof SWING_INDEX_V2_FORMULA_VERSION
  swingIndexScore: number
  SWI: number
  SWI_raw: number
  confidenceFactor: number
  Batting: number
  Bowling: number
  Fielding: number
  Impact: number
  roleTemplate: SwingRoleTemplateKey
  roleWeights: SwingRoleWeights
  Captaincy: number | null
  axes: {
    reliabilityAxis: number
    powerAxis: number
    bowlingAxis: number
    fieldingAxis: number
    impactAxis: number
    captaincyAxis: number
  }
  strengths: Array<{ key: string; score: number }>
  weakestAreas: Array<{ key: string; score: number }>
  explanation: {
    headline: string
    detail: string
  }
}

function round(value: number, digits = 2) {
  const factor = 10 ** digits
  return Math.round(value * factor) / factor
}

function toFinite(value: number | null | undefined) {
  return typeof value === 'number' && Number.isFinite(value) ? value : null
}

function readMetric(metrics: SwingMetricRecord, key: string) {
  return toFinite(metrics[key])
}

function readMetric0(metrics: SwingMetricRecord, key: string) {
  return readMetric(metrics, key) ?? 0
}

function scoreOrNeutral(score: number | null) {
  return score === null ? 50 : score
}

const ROLE_WEIGHTS: Record<SwingRoleTemplateKey, SwingRoleWeights> = {
  pure_batter: { batting: 0.50, bowling: 0.00, fielding: 0.20, impact: 0.30 },
  batting_all_rounder: { batting: 0.40, bowling: 0.20, fielding: 0.15, impact: 0.25 },
  bowling_all_rounder: { batting: 0.25, bowling: 0.35, fielding: 0.15, impact: 0.25 },
  pure_bowler: { batting: 0.10, bowling: 0.50, fielding: 0.15, impact: 0.25 },
  keeper_batter: { batting: 0.45, bowling: 0.00, fielding: 0.25, impact: 0.30 },
}

const FIELDING_BASELINE = 35
const FIELDING_EVIDENCE_FULL_UNITS = 20
const CONFIDENCE_MATCH_HORIZON = 500

function normalizePlayerRole(input: string | null | undefined) {
  if (!input) return null
  const normalized = String(input).trim().toUpperCase()
  return normalized.length > 0 ? normalized : null
}

function chooseAllRounderTemplate(
  battingWorkload: number,
  bowlingWorkload: number,
  battingScore: number,
  bowlingScore: number,
): SwingRoleTemplateKey {
  if (battingWorkload <= 0 && bowlingWorkload <= 0) {
    return bowlingScore > battingScore ? 'bowling_all_rounder' : 'batting_all_rounder'
  }
  if (bowlingWorkload > battingWorkload * 1.1) return 'bowling_all_rounder'
  if (battingWorkload > bowlingWorkload * 1.1) return 'batting_all_rounder'
  return bowlingScore > battingScore + 2 ? 'bowling_all_rounder' : 'batting_all_rounder'
}

function resolveRoleTemplate(
  declaredRole: string | null | undefined,
  context: {
    battingAvailable: boolean
    bowlingAvailable: boolean
    keepingRelevant: boolean
    battingWorkload: number
    bowlingWorkload: number
    battingScore: number
    bowlingScore: number
  },
): SwingRoleTemplateKey {
  const normalizedRole = normalizePlayerRole(declaredRole)

  if (normalizedRole === 'BATSMAN') return 'pure_batter'
  if (normalizedRole === 'BOWLER') return 'pure_bowler'
  if (normalizedRole === 'WICKET_KEEPER' || normalizedRole === 'WICKET_KEEPER_BATSMAN') return 'keeper_batter'
  if (normalizedRole === 'ALL_ROUNDER') {
    return chooseAllRounderTemplate(
      context.battingWorkload,
      context.bowlingWorkload,
      context.battingScore,
      context.bowlingScore,
    )
  }

  if (context.keepingRelevant) return 'keeper_batter'
  if (context.bowlingAvailable && !context.battingAvailable) return 'pure_bowler'
  if (context.battingAvailable && !context.bowlingAvailable) return 'pure_batter'
  return chooseAllRounderTemplate(
    context.battingWorkload,
    context.bowlingWorkload,
    context.battingScore,
    context.bowlingScore,
  )
}

function resolveImpactByRole(
  roleTemplate: SwingRoleTemplateKey,
  battingImpact: number,
  bowlingImpact: number,
  evidence?: { batting: boolean; bowling: boolean },
) {
  if (evidence) {
    if (evidence.batting && !evidence.bowling) return battingImpact
    if (evidence.bowling && !evidence.batting) return bowlingImpact
  }

  if (roleTemplate === 'pure_batter' || roleTemplate === 'keeper_batter') {
    return battingImpact
  }
  if (roleTemplate === 'pure_bowler') {
    return bowlingImpact
  }
  if (roleTemplate === 'batting_all_rounder') {
    return (0.6 * battingImpact) + (0.4 * bowlingImpact)
  }
  if (roleTemplate === 'bowling_all_rounder') {
    return (0.4 * battingImpact) + (0.6 * bowlingImpact)
  }
  return (battingImpact + bowlingImpact) / 2
}

function normalizeRoleWeightsByEvidence(
  template: SwingRoleWeights,
  evidence: {
    batting: boolean
    bowling: boolean
    fielding: boolean
    impact: boolean
  },
): SwingRoleWeights {
  const masked = {
    batting: evidence.batting ? template.batting : 0,
    bowling: evidence.bowling ? template.bowling : 0,
    fielding: evidence.fielding ? template.fielding : 0,
    impact: evidence.impact ? template.impact : 0,
  }
  const sum = masked.batting + masked.bowling + masked.fielding + masked.impact
  if (sum <= 0) {
    return template
  }
  return {
    batting: round(masked.batting / sum, 4),
    bowling: round(masked.bowling / sum, 4),
    fielding: round(masked.fielding / sum, 4),
    impact: round(masked.impact / sum, 4),
  }
}

function calculateConfidenceFactor(matchesPlayed: number) {
  const matches = Math.max(0, matchesPlayed)
  if (matches === 0) return 0
  const normalized = Math.log1p(matches) / Math.log1p(CONFIDENCE_MATCH_HORIZON)
  return round(Math.min(1, normalized), 4)
}

function evaluateWeightedScore(components: ScoreComponent[]) {
  const originalWeightSum = components.reduce((sum, component) => sum + component.weight, 0)

  const excluded: string[] = []
  const normalizedComponents: Record<string, number> = {}
  const usable: Array<{ key: string; normalized: number; weight: number }> = []

  for (const component of components) {
    if (component.include === false) {
      excluded.push(component.key)
      continue
    }

    const numeric = toFinite(component.value)
    if (numeric === null) {
      excluded.push(component.key)
      continue
    }

    let normalized: number | null = clampScore0to100(numeric)
    if (component.rangeKey && component.direction) {
      const range = SWING_INDEX_V2_NORMALIZATION_RANGES[component.rangeKey]
      normalized = component.direction === 'U'
        ? normalizeHigherBetter(numeric, range.min, range.max) ?? null
        : normalizeLowerBetter(numeric, range.min, range.max) ?? null
      if (normalized === null) {
        excluded.push(component.key)
        continue
      }
    }

    normalizedComponents[component.key] = round(normalized, 4)
    usable.push({ key: component.key, normalized, weight: component.weight })
  }

  const usedWeightSum = usable.reduce((sum, component) => sum + component.weight, 0)
  const breakdown: ScoreBreakdown = {
    originalWeightSum: round(originalWeightSum, 4),
    usedWeightSum: round(usedWeightSum, 4),
    renormalized: usedWeightSum > 0 && Math.abs(usedWeightSum - originalWeightSum) > 1e-9,
    excludedComponents: excluded,
    normalizedComponents,
  }

  if (usedWeightSum <= 0) {
    return { score: null as number | null, breakdown }
  }

  const score = usable.reduce((sum, component) => sum + component.normalized * component.weight, 0) / usedWeightSum
  return { score: round(clampScore0to100(score), 2), breakdown }
}

function buildSummaryPayload(result: SwingIndexV2Result): SwingIndexV2Summary {
  const axes = {
    reliabilityAxis: round(result.axes.reliabilityAxis ?? 0, 1),
    powerAxis: round(result.axes.powerAxis ?? 0, 1),
    bowlingAxis: round(result.axes.bowlingAxis ?? 0, 1),
    fieldingAxis: round(result.axes.fieldingAxis ?? 0, 1),
    impactAxis: round(result.axes.impactAxis ?? 0, 1),
    captaincyAxis: round(result.axes.captaincyAxis ?? 0, 1),
  }

  const ranked = Object.entries(axes)
    .map(([key, score]) => ({ key, score }))
    .sort((a, b) => b.score - a.score)

  const strengths = ranked.slice(0, 2)
  const weakestAreas = [...ranked].reverse().slice(0, 2)
  const top = strengths[0]
  const low = weakestAreas[0]

  return {
    playerId: result.playerId,
    formulaVersion: result.formulaVersion,
    swingIndexScore: round(result.swingIndexScore, 1),
    SWI: round(result.SWI, 1),
    SWI_raw: round(result.SWI_raw, 2),
    confidenceFactor: round(result.confidenceFactor, 4),
    Batting: round(result.Batting, 2),
    Bowling: round(result.Bowling, 2),
    Fielding: round(result.Fielding, 2),
    Impact: round(result.Impact, 2),
    roleTemplate: result.roleTemplate,
    roleWeights: result.roleWeights,
    Captaincy: result.Captaincy === null ? null : round(result.Captaincy, 2),
    axes,
    strengths,
    weakestAreas,
    explanation: {
      headline: top
        ? `${top.key} is currently leading the profile`
        : 'Swing Index profile is available',
      detail: low
        ? `The biggest improvement opportunity is ${low.key}.`
        : 'More match samples will improve reliability.',
    },
  }
}

export function calculateSwingIndexV2(
  playerId: string,
  metrics: SwingMetricRecord,
  context: SwingIndexRoleContext = {},
): SwingIndexV2Result {
  const raw = {
    battingInnings: readMetric0(metrics, 'battingInnings'),
    totalBallsFaced: readMetric0(metrics, 'totalBallsFaced'),
    bowlingInnings: readMetric0(metrics, 'bowlingInnings'),
    totalBallsBowled: readMetric0(metrics, 'totalBallsBowled'),
    totalOvers: readMetric0(metrics, 'totalOvers'),
    totalWickets: readMetric0(metrics, 'totalWickets'),
    wides: readMetric0(metrics, 'wides'),
    noBalls: readMetric0(metrics, 'noBalls'),
    wicketsBowled: readMetric0(metrics, 'wicketsBowled'),
    wicketsLBW: readMetric0(metrics, 'wicketsLBW'),
    chaseWins: readMetric0(metrics, 'chaseWins'),
    chaseMatches: readMetric0(metrics, 'chaseMatches'),
    defendWins: readMetric0(metrics, 'defendWins'),
    defendMatches: readMetric0(metrics, 'defendMatches'),
    mvpCount: readMetric0(metrics, 'mvpCount'),
    matchesPlayed: readMetric0(metrics, 'matchesPlayed'),
    totalDismissalInvolvements: readMetric0(metrics, 'totalDismissalInvolvements'),
    matchesWon: readMetric0(metrics, 'matchesWon'),
    deathWickets: readMetric0(metrics, 'deathWickets'),
    deathBallsBowled: readMetric0(metrics, 'deathBallsBowled'),
    threeWicketHauls: readMetric0(metrics, 'threeWicketHauls'),
    fourWicketHauls: readMetric0(metrics, 'fourWicketHauls'),
    fiveWicketHauls: readMetric0(metrics, 'fiveWicketHauls'),
    battingAverage: readMetric0(metrics, 'battingAverage'),
    runsPerInnings: readMetric0(metrics, 'runsPerInnings'),
    ballsPerDismissal: readMetric0(metrics, 'ballsPerDismissal'),
    scoringShotPct: readMetric0(metrics, 'scoringShotPct'),
    singlesPctBat: readMetric0(metrics, 'singlesPctBat'),
    fiftyPlusInningsPct: readMetric0(metrics, 'fiftyPlusInningsPct'),
    thirtyToFiftyConversionPct: readMetric0(metrics, 'thirtyToFiftyConversionPct'),
    consistencyIndex: readMetric0(metrics, 'consistencyIndex'),
    strikeRate: readMetric0(metrics, 'strikeRate'),
    boundaryPerBall: readMetric0(metrics, 'boundaryPerBall'),
    ballsPerBoundary: readMetric0(metrics, 'ballsPerBoundary'),
    boundaryRunPct: readMetric0(metrics, 'boundaryRunPct'),
    dotBallPctBat: readMetric0(metrics, 'dotBallPctBat'),
    powerplaySR: readMetric0(metrics, 'powerplaySR'),
    middleSR: readMetric0(metrics, 'middleSR'),
    totalSixes: readMetric0(metrics, 'totalSixes'),
    deathSR: readMetric0(metrics, 'deathSR'),
    deathBoundaryPerBall: readMetric0(metrics, 'deathBoundaryPerBall'),
    maxBoundariesInInnings: readMetric0(metrics, 'maxBoundariesInInnings'),
    highestScore: readMetric0(metrics, 'highestScore'),
    economyRate: readMetric0(metrics, 'economyRate'),
    dotBallPctBowl: readMetric0(metrics, 'dotBallPctBowl'),
    controlBallPct: readMetric0(metrics, 'controlBallPct'),
    boundaryConcededPct: readMetric0(metrics, 'boundaryConcededPct'),
    ballsPerBoundaryConceded: readMetric0(metrics, 'ballsPerBoundaryConceded'),
    legalDeliveriesPct: readMetric0(metrics, 'legalDeliveriesPct'),
    wicketsPerInnings: readMetric0(metrics, 'wicketsPerInnings'),
    bowlingStrikeRate: readMetric0(metrics, 'bowlingStrikeRate'),
    bowlingAverage: readMetric0(metrics, 'bowlingAverage'),
    ppEconomy: readMetric0(metrics, 'ppEconomy'),
    middleEconomy: readMetric0(metrics, 'middleEconomy'),
    deathEconomy: readMetric0(metrics, 'deathEconomy'),
    catchesPerMatch: readMetric0(metrics, 'catchesPerMatch'),
    runOutInvolvementPerMatch: readMetric0(metrics, 'runOutInvolvementPerMatch'),
    stumpingsPerKeepingInnings: readMetric0(metrics, 'stumpingsPerKeepingInnings'),
    stumpings: readMetric0(metrics, 'stumpings'),
    dismissalInvolvementPerMatch: readMetric0(metrics, 'dismissalInvolvementPerMatch'),
    missedChances: readMetric0(metrics, 'missedChances'),
    winPct: readMetric0(metrics, 'winPct'),
    knockoutImpactAvg: readMetric0(metrics, 'knockoutImpactAvg'),
    last5BatAvg: readMetric0(metrics, 'last5BatAvg'),
    last5BatSR: readMetric0(metrics, 'last5BatSR'),
    last5Economy: readMetric0(metrics, 'last5Economy'),
    last10Runs: readMetric0(metrics, 'last10Runs'),
    last10Wickets: readMetric0(metrics, 'last10Wickets'),
    runsStdDev: readMetric0(metrics, 'runsStdDev'),
    wicketsStdDev: readMetric0(metrics, 'wicketsStdDev'),
    captainMatches: readMetric0(metrics, 'captainMatches'),
    captainWins: readMetric0(metrics, 'captainWins'),
    captainWinPct: readMetric0(metrics, 'captainWinPct'),
    captainSelectionRate: readMetric0(metrics, 'captainSelectionRate'),
    captainImpactAvg: readMetric0(metrics, 'captainImpactAvg'),
  }

  const derivedBase = {
    sixesPerInnings: round(safeDivide(raw.totalSixes, Math.max(raw.battingInnings, 1), 0), 4),
    widesPerOver: round(safeDivide(raw.wides, Math.max(raw.totalOvers, 1), 0), 4),
    noBallsPerOver: round(safeDivide(raw.noBalls, Math.max(raw.totalOvers, 1), 0), 4),
    wicketRate: round(safeDivide(raw.totalWickets, Math.max(raw.totalBallsBowled, 1), 0), 6),
    bowledLbwPct: round(safeDivide(raw.wicketsBowled + raw.wicketsLBW, Math.max(raw.totalWickets, 1), 0), 6),
    chaseWinPct: round(safeDivide(raw.chaseWins, Math.max(raw.chaseMatches, 1), 0), 6),
    defendWinPct: round(safeDivide(raw.defendWins, Math.max(raw.defendMatches, 1), 0), 6),
    mvpRate: round(safeDivide(raw.mvpCount, Math.max(raw.matchesPlayed, 1), 0), 6),
    dismissalInvolvementRate: round(safeDivide(raw.totalDismissalInvolvements, Math.max(raw.matchesPlayed, 1), 0), 6),
  }

  const matchesWonRate = safeDivide(raw.matchesWon, Math.max(raw.matchesPlayed, 1), 0)
  const deathWicketRate = safeDivide(raw.deathWickets, Math.max(raw.deathBallsBowled, 1), 0)
  const threeWicketHaulRate = safeDivide(raw.threeWicketHauls, Math.max(raw.bowlingInnings, 1), 0)
  const fourWicketHaulRate = safeDivide(raw.fourWicketHauls, Math.max(raw.bowlingInnings, 1), 0)
  const fiveWicketHaulRate = safeDivide(raw.fiveWicketHauls, Math.max(raw.bowlingInnings, 1), 0)
  const last10RunsPerMatch = safeDivide(raw.last10Runs, Math.max(raw.matchesPlayed, 1), 0)
  const last10WicketsPerMatch = safeDivide(raw.last10Wickets, Math.max(raw.matchesPlayed, 1), 0)

  const battingAvailable = raw.battingInnings > 0
  const bowlingAvailable = raw.bowlingInnings > 0 || raw.totalBallsBowled > 0 || raw.totalWickets > 0
  const fieldingAvailable = raw.matchesPlayed > 0
  const impactAvailable = raw.matchesPlayed > 0
  const keepingRelevant = raw.stumpings > 0 || raw.stumpingsPerKeepingInnings > 0
  const captaincyAvailable = raw.captainMatches > 0

  const scoreDetails: Record<string, ScoreBreakdown> = {}
  const excludedSections: string[] = []

  // Keep existing internal metric buckets to reuse current metric naming/data structures.
  const BRCalc = evaluateWeightedScore([
    { key: 'battingAverage', weight: 0.24, value: raw.battingAverage, rangeKey: 'battingAverage', direction: 'U', include: battingAvailable },
    { key: 'runsPerInnings', weight: 0.16, value: raw.runsPerInnings, rangeKey: 'runsPerInnings', direction: 'U', include: battingAvailable },
    { key: 'ballsPerDismissal', weight: 0.14, value: raw.ballsPerDismissal, rangeKey: 'ballsPerDismissal', direction: 'U', include: battingAvailable },
    { key: 'scoringShotPct', weight: 0.12, value: raw.scoringShotPct, rangeKey: 'scoringShotPct', direction: 'U', include: battingAvailable },
    { key: 'singlesPctBat', weight: 0.10, value: raw.singlesPctBat, rangeKey: 'singlesPctBat', direction: 'U', include: battingAvailable },
    { key: 'fiftyPlusInningsPct', weight: 0.10, value: raw.fiftyPlusInningsPct, rangeKey: 'fiftyPlusInningsPct', direction: 'U', include: battingAvailable },
    { key: 'thirtyToFiftyConversionPct', weight: 0.08, value: raw.thirtyToFiftyConversionPct, rangeKey: 'thirtyToFiftyConversionPct', direction: 'U', include: battingAvailable },
    { key: 'consistencyIndex', weight: 0.06, value: raw.consistencyIndex, rangeKey: 'consistencyIndex', direction: 'U', include: battingAvailable },
  ])
  scoreDetails.BR = BRCalc.breakdown

  const BECalc = evaluateWeightedScore([
    { key: 'strikeRate', weight: 0.30, value: raw.strikeRate, rangeKey: 'strikeRate', direction: 'U', include: battingAvailable },
    { key: 'boundaryPerBall', weight: 0.18, value: raw.boundaryPerBall, rangeKey: 'boundaryPerBall', direction: 'U', include: battingAvailable },
    { key: 'ballsPerBoundary', weight: 0.12, value: raw.ballsPerBoundary, rangeKey: 'ballsPerBoundary', direction: 'D', include: battingAvailable },
    { key: 'boundaryRunPct', weight: 0.12, value: raw.boundaryRunPct, rangeKey: 'boundaryRunPct', direction: 'U', include: battingAvailable },
    { key: 'dotBallPctBat', weight: 0.10, value: raw.dotBallPctBat, rangeKey: 'dotBallPctBat', direction: 'D', include: battingAvailable },
    { key: 'powerplaySR', weight: 0.10, value: raw.powerplaySR, rangeKey: 'powerplaySR', direction: 'U', include: battingAvailable },
    { key: 'middleSR', weight: 0.08, value: raw.middleSR, rangeKey: 'middleSR', direction: 'U', include: battingAvailable },
  ])
  scoreDetails.BE = BECalc.breakdown

  const PWCalc = evaluateWeightedScore([
    { key: 'strikeRate', weight: 0.26, value: raw.strikeRate, rangeKey: 'strikeRate', direction: 'U', include: battingAvailable },
    { key: 'boundaryPerBall', weight: 0.20, value: raw.boundaryPerBall, rangeKey: 'boundaryPerBall', direction: 'U', include: battingAvailable },
    { key: 'boundaryRunPct', weight: 0.14, value: raw.boundaryRunPct, rangeKey: 'boundaryRunPct', direction: 'U', include: battingAvailable },
    { key: 'sixesPerInnings', weight: 0.10, value: derivedBase.sixesPerInnings, rangeKey: 'sixesPerInnings', direction: 'U', include: battingAvailable },
    { key: 'deathSR', weight: 0.10, value: raw.deathSR, rangeKey: 'deathSR', direction: 'U', include: battingAvailable },
    { key: 'deathBoundaryPerBall', weight: 0.08, value: raw.deathBoundaryPerBall, rangeKey: 'deathBoundaryPerBall', direction: 'U', include: battingAvailable },
    { key: 'maxBoundariesInInnings', weight: 0.06, value: raw.maxBoundariesInInnings, rangeKey: 'maxBoundariesInInnings', direction: 'U', include: battingAvailable },
    { key: 'highestScore', weight: 0.06, value: raw.highestScore, rangeKey: 'highestScore', direction: 'U', include: battingAvailable },
  ])
  scoreDetails.PW = PWCalc.breakdown

  const BVCalc = evaluateWeightedScore([
    { key: 'powerplaySR', weight: 0.18, value: raw.powerplaySR, rangeKey: 'powerplaySR', direction: 'U', include: battingAvailable },
    { key: 'middleSR', weight: 0.18, value: raw.middleSR, rangeKey: 'middleSR', direction: 'U', include: battingAvailable },
    { key: 'deathSR', weight: 0.18, value: raw.deathSR, rangeKey: 'deathSR', direction: 'U', include: battingAvailable },
    { key: 'vsPaceSR', weight: 0.12, value: readMetric0(metrics, 'vsPaceSR'), rangeKey: 'strikeRate', direction: 'U', include: battingAvailable },
    { key: 'vsSpinSR', weight: 0.12, value: readMetric0(metrics, 'vsSpinSR'), rangeKey: 'strikeRate', direction: 'U', include: battingAvailable },
    { key: 'vsLeftArmPaceSR', weight: 0.08, value: readMetric0(metrics, 'vsLeftArmPaceSR'), rangeKey: 'strikeRate', direction: 'U', include: battingAvailable },
    { key: 'vsRightArmPaceSR', weight: 0.08, value: readMetric0(metrics, 'vsRightArmPaceSR'), rangeKey: 'strikeRate', direction: 'U', include: battingAvailable },
    { key: 'vsOffSpinSR', weight: 0.02, value: readMetric0(metrics, 'vsOffSpinSR'), rangeKey: 'strikeRate', direction: 'U', include: battingAvailable },
    { key: 'vsLegSpinSR', weight: 0.04, value: readMetric0(metrics, 'vsLegSpinSR'), rangeKey: 'strikeRate', direction: 'U', include: battingAvailable },
  ])
  scoreDetails.BV = BVCalc.breakdown

  const BCCalc = evaluateWeightedScore([
    { key: 'economyRate', weight: 0.26, value: raw.economyRate, rangeKey: 'economyRate', direction: 'D', include: bowlingAvailable },
    { key: 'dotBallPctBowl', weight: 0.18, value: raw.dotBallPctBowl, rangeKey: 'dotBallPctBowl', direction: 'U', include: bowlingAvailable },
    { key: 'controlBallPct', weight: 0.14, value: raw.controlBallPct, rangeKey: 'controlBallPct', direction: 'U', include: bowlingAvailable },
    { key: 'boundaryConcededPct', weight: 0.12, value: raw.boundaryConcededPct, rangeKey: 'boundaryConcededPct', direction: 'D', include: bowlingAvailable },
    { key: 'ballsPerBoundaryConceded', weight: 0.10, value: raw.ballsPerBoundaryConceded, rangeKey: 'ballsPerBoundaryConceded', direction: 'D', include: bowlingAvailable },
    { key: 'legalDeliveriesPct', weight: 0.08, value: raw.legalDeliveriesPct, rangeKey: 'legalDeliveriesPct', direction: 'U', include: bowlingAvailable },
    { key: 'widesPerOver', weight: 0.06, value: derivedBase.widesPerOver, rangeKey: 'widesPerOver', direction: 'D', include: bowlingAvailable },
    { key: 'noBallsPerOver', weight: 0.06, value: derivedBase.noBallsPerOver, rangeKey: 'noBallsPerOver', direction: 'D', include: bowlingAvailable },
  ])
  scoreDetails.BC = BCCalc.breakdown

  const BTCalc = evaluateWeightedScore([
    { key: 'wicketsPerInnings', weight: 0.24, value: raw.wicketsPerInnings, rangeKey: 'wicketsPerInnings', direction: 'U', include: bowlingAvailable },
    { key: 'bowlingStrikeRate', weight: 0.18, value: raw.bowlingStrikeRate, rangeKey: 'bowlingStrikeRate', direction: 'D', include: bowlingAvailable },
    { key: 'bowlingAverage', weight: 0.14, value: raw.bowlingAverage, rangeKey: 'bowlingAverage', direction: 'D', include: bowlingAvailable },
    { key: 'wicketRate', weight: 0.12, value: derivedBase.wicketRate, rangeKey: 'wicketRate', direction: 'U', include: bowlingAvailable },
    { key: 'threeWicketHaulRate', weight: 0.10, value: threeWicketHaulRate, rangeKey: 'threeWicketHaulRate', direction: 'U', include: bowlingAvailable },
    { key: 'fourWicketHaulRate', weight: 0.08, value: fourWicketHaulRate, rangeKey: 'fourWicketHaulRate', direction: 'U', include: bowlingAvailable },
    { key: 'fiveWicketHaulRate', weight: 0.06, value: fiveWicketHaulRate, rangeKey: 'fiveWicketHaulRate', direction: 'U', include: bowlingAvailable },
    { key: 'bowledLbwPct', weight: 0.04, value: derivedBase.bowledLbwPct, rangeKey: 'bowledLbwPct', direction: 'U', include: bowlingAvailable },
  ])
  scoreDetails.BT = BTCalc.breakdown

  const PBCalc = evaluateWeightedScore([
    { key: 'ppEconomy', weight: 0.28, value: raw.ppEconomy, rangeKey: 'ppEconomy', direction: 'D', include: bowlingAvailable },
    { key: 'middleEconomy', weight: 0.24, value: raw.middleEconomy, rangeKey: 'middleEconomy', direction: 'D', include: bowlingAvailable },
    { key: 'deathEconomy', weight: 0.24, value: raw.deathEconomy, rangeKey: 'deathEconomy', direction: 'D', include: bowlingAvailable },
    { key: 'deathWicketRate', weight: 0.12, value: deathWicketRate, rangeKey: 'deathWicketRate', direction: 'U', include: bowlingAvailable },
    { key: 'dotBallPctBowl', weight: 0.12, value: raw.dotBallPctBowl, rangeKey: 'dotBallPctBowl', direction: 'U', include: bowlingAvailable },
  ])
  scoreDetails.PB = PBCalc.breakdown

  const FICalc = evaluateWeightedScore([
    { key: 'catchesPerMatch', weight: 0.26, value: raw.catchesPerMatch, rangeKey: 'catchesPerMatch', direction: 'U', include: fieldingAvailable },
    { key: 'runOutInvolvementPerMatch', weight: 0.20, value: raw.runOutInvolvementPerMatch, rangeKey: 'runOutInvolvementPerMatch', direction: 'U', include: fieldingAvailable },
    { key: 'stumpingsPerKeepingInnings', weight: 0.12, value: raw.stumpingsPerKeepingInnings, rangeKey: 'stumpingsPerKeepingInnings', direction: 'U', include: fieldingAvailable && keepingRelevant },
    { key: 'dismissalInvolvementPerMatch', weight: 0.18, value: raw.dismissalInvolvementPerMatch, rangeKey: 'dismissalInvolvementPerMatch', direction: 'U', include: fieldingAvailable },
    { key: 'missedChances', weight: 0.12, value: raw.missedChances, rangeKey: 'missedChances', direction: 'D', include: fieldingAvailable },
    { key: 'dismissalInvolvementRate', weight: 0.12, value: derivedBase.dismissalInvolvementRate, rangeKey: 'dismissalInvolvementRate', direction: 'U', include: fieldingAvailable },
  ])
  scoreDetails.FI = FICalc.breakdown

  const WICalc = evaluateWeightedScore([
    { key: 'winPct', weight: 0.24, value: raw.winPct, rangeKey: 'winPct', direction: 'U', include: impactAvailable },
    { key: 'chaseWinPct', weight: 0.18, value: derivedBase.chaseWinPct, rangeKey: 'chaseWinPct', direction: 'U', include: impactAvailable },
    { key: 'defendWinPct', weight: 0.12, value: derivedBase.defendWinPct, rangeKey: 'defendWinPct', direction: 'U', include: impactAvailable },
    { key: 'knockoutImpactAvg', weight: 0.18, value: raw.knockoutImpactAvg, rangeKey: 'knockoutImpactAvg', direction: 'U', include: impactAvailable },
    { key: 'mvpRate', weight: 0.16, value: derivedBase.mvpRate, rangeKey: 'mvpRate', direction: 'U', include: impactAvailable },
    { key: 'matchesWonRate', weight: 0.12, value: matchesWonRate, rangeKey: 'matchesWonRate', direction: 'U', include: impactAvailable },
  ])
  scoreDetails.WI = WICalc.breakdown

  const RFCalc = evaluateWeightedScore([
    { key: 'last5BatAvg', weight: 0.24, value: raw.last5BatAvg, rangeKey: 'last5BatAvg', direction: 'U', include: impactAvailable },
    { key: 'last5BatSR', weight: 0.18, value: raw.last5BatSR, rangeKey: 'last5BatSR', direction: 'U', include: impactAvailable },
    { key: 'last5Economy', weight: 0.18, value: raw.last5Economy, rangeKey: 'last5Economy', direction: 'D', include: impactAvailable },
    { key: 'last10RunsPerMatch', weight: 0.16, value: last10RunsPerMatch, rangeKey: 'last10RunsPerMatch', direction: 'U', include: impactAvailable },
    { key: 'last10WicketsPerMatch', weight: 0.12, value: last10WicketsPerMatch, rangeKey: 'last10WicketsPerMatch', direction: 'U', include: impactAvailable },
    { key: 'consistencyIndex', weight: 0.12, value: raw.consistencyIndex, rangeKey: 'consistencyIndex', direction: 'U', include: impactAvailable },
  ])
  scoreDetails.RF = RFCalc.breakdown

  const CSCalc = evaluateWeightedScore([
    { key: 'consistencyIndex', weight: 0.50, value: raw.consistencyIndex, rangeKey: 'consistencyIndex', direction: 'U', include: impactAvailable },
    { key: 'runsStdDev', weight: 0.20, value: raw.runsStdDev, rangeKey: 'runsStdDev', direction: 'D', include: impactAvailable },
    { key: 'wicketsStdDev', weight: 0.20, value: raw.wicketsStdDev, rangeKey: 'wicketsStdDev', direction: 'D', include: impactAvailable },
    { key: 'fiftyPlusInningsPct', weight: 0.10, value: raw.fiftyPlusInningsPct, rangeKey: 'fiftyPlusInningsPct', direction: 'U', include: impactAvailable },
  ])
  scoreDetails.CS = CSCalc.breakdown

  // New product-intent pillars.
  const ReliabilityCalc = evaluateWeightedScore([
    { key: 'BR', weight: 0.65, value: BRCalc.score, include: battingAvailable },
    { key: 'BE', weight: 0.20, value: BECalc.score, include: battingAvailable },
    { key: 'CS', weight: 0.15, value: CSCalc.score, include: battingAvailable },
  ])
  scoreDetails.Reliability = ReliabilityCalc.breakdown

  const PowerCalc = evaluateWeightedScore([
    { key: 'PW', weight: 0.70, value: PWCalc.score, include: battingAvailable },
    { key: 'BV', weight: 0.30, value: BVCalc.score, include: battingAvailable },
  ])
  scoreDetails.Power = PowerCalc.breakdown

  const BattingImpactCalc = evaluateWeightedScore([
    { key: 'RF', weight: 0.45, value: RFCalc.score, include: battingAvailable },
    { key: 'WI', weight: 0.25, value: WICalc.score, include: battingAvailable },
    { key: 'PW', weight: 0.20, value: PWCalc.score, include: battingAvailable },
    { key: 'BE', weight: 0.10, value: BECalc.score, include: battingAvailable },
  ])
  scoreDetails.BattingImpact = BattingImpactCalc.breakdown

  const ControlCalc = evaluateWeightedScore([
    { key: 'BC', weight: 0.70, value: BCCalc.score, include: bowlingAvailable },
    { key: 'PB', weight: 0.30, value: PBCalc.score, include: bowlingAvailable },
  ])
  scoreDetails.Control = ControlCalc.breakdown

  const ThreatCalc = evaluateWeightedScore([
    { key: 'BT', weight: 0.75, value: BTCalc.score, include: bowlingAvailable },
    { key: 'PB', weight: 0.15, value: PBCalc.score, include: bowlingAvailable },
    { key: 'BC', weight: 0.10, value: BCCalc.score, include: bowlingAvailable },
  ])
  scoreDetails.Threat = ThreatCalc.breakdown

  const BowlingImpactCalc = evaluateWeightedScore([
    { key: 'PB', weight: 0.55, value: PBCalc.score, include: bowlingAvailable },
    { key: 'RF', weight: 0.25, value: RFCalc.score, include: bowlingAvailable },
    { key: 'WI', weight: 0.20, value: WICalc.score, include: bowlingAvailable },
  ])
  scoreDetails.BowlingImpact = BowlingImpactCalc.breakdown

  const Reliability = scoreOrNeutral(ReliabilityCalc.score)
  const Power = scoreOrNeutral(PowerCalc.score)
  const BattingImpact = scoreOrNeutral(BattingImpactCalc.score)
  const Control = scoreOrNeutral(ControlCalc.score)
  const Threat = scoreOrNeutral(ThreatCalc.score)
  const BowlingImpact = scoreOrNeutral(BowlingImpactCalc.score)

  const Batting = round(clampScore0to100((Reliability + Power + BattingImpact) / 3), 2)
  const Bowling = round(clampScore0to100((Control + Threat + BowlingImpact) / 3), 2)

  const FieldingRaw = scoreOrNeutral(FICalc.score)
  const fieldingEvidenceUnits = Math.max(0, raw.totalDismissalInvolvements + raw.missedChances)
  const fieldingEvidenceFactor = round(Math.min(1, safeDivide(fieldingEvidenceUnits, FIELDING_EVIDENCE_FULL_UNITS, 0)), 4)
  const Fielding = round(
    clampScore0to100(FIELDING_BASELINE + fieldingEvidenceFactor * (FieldingRaw - FIELDING_BASELINE)),
    2,
  )

  const TacticalImpactCalc = evaluateWeightedScore([
    {
      key: 'captainImpactAvg',
      weight: 1,
      value: raw.captainImpactAvg,
      rangeKey: 'knockoutImpactAvg',
      direction: 'U',
      include: captaincyAvailable,
    },
  ])
  scoreDetails.TacticalImpact = TacticalImpactCalc.breakdown

  const ResultImpactCalc = evaluateWeightedScore([
    {
      key: 'captainWinPct',
      weight: 1,
      value: raw.captainWinPct,
      rangeKey: 'winPct',
      direction: 'U',
      include: captaincyAvailable,
    },
  ])
  scoreDetails.ResultImpact = ResultImpactCalc.breakdown

  const LeadershipTrustCalc = evaluateWeightedScore([
    {
      key: 'captainSelectionRate',
      weight: 1,
      value: raw.captainSelectionRate,
      rangeKey: 'matchesWonRate',
      direction: 'U',
      include: captaincyAvailable,
    },
  ])
  scoreDetails.LeadershipTrust = LeadershipTrustCalc.breakdown

  const CaptaincyCalc = evaluateWeightedScore([
    { key: 'TacticalImpact', weight: 0.40, value: TacticalImpactCalc.score, include: captaincyAvailable },
    { key: 'ResultImpact', weight: 0.35, value: ResultImpactCalc.score, include: captaincyAvailable },
    { key: 'LeadershipTrust', weight: 0.25, value: LeadershipTrustCalc.score, include: captaincyAvailable },
  ])
  scoreDetails.Captaincy = CaptaincyCalc.breakdown

  const TacticalImpact = captaincyAvailable ? TacticalImpactCalc.score : null
  const ResultImpact = captaincyAvailable ? ResultImpactCalc.score : null
  const LeadershipTrust = captaincyAvailable ? LeadershipTrustCalc.score : null
  const Captaincy = captaincyAvailable ? CaptaincyCalc.score : null

  const battingWorkload = raw.totalBallsFaced + (raw.battingInnings * 18)
  const bowlingWorkload = raw.totalBallsBowled + (raw.bowlingInnings * 24)
  const roleTemplate = resolveRoleTemplate(context.playerRole, {
    battingAvailable,
    bowlingAvailable,
    keepingRelevant,
    battingWorkload,
    bowlingWorkload,
    battingScore: Batting,
    bowlingScore: Bowling,
  })
  const templateRoleWeights = ROLE_WEIGHTS[roleTemplate]
  const roleWeights = normalizeRoleWeightsByEvidence(templateRoleWeights, {
    batting: battingAvailable,
    bowling: bowlingAvailable,
    fielding: fieldingAvailable,
    impact: impactAvailable,
  })
  const showBowlingAsZero = !bowlingAvailable
  const ControlOutput = showBowlingAsZero ? 0 : Control
  const ThreatOutput = showBowlingAsZero ? 0 : Threat
  const BowlingImpactOutput = showBowlingAsZero ? 0 : BowlingImpact
  const BowlingOutput = showBowlingAsZero ? 0 : Bowling
  const Impact = round(
    clampScore0to100(
      resolveImpactByRole(roleTemplate, BattingImpact, BowlingImpact, {
        batting: battingAvailable,
        bowling: bowlingAvailable,
      }),
    ),
    2,
  )

  scoreDetails.RoleWeights = {
    originalWeightSum: 1,
    usedWeightSum: round(roleWeights.batting + roleWeights.bowling + roleWeights.fielding + roleWeights.impact, 4),
    renormalized:
      Math.abs(roleWeights.batting - templateRoleWeights.batting) > 1e-9
      || Math.abs(roleWeights.bowling - templateRoleWeights.bowling) > 1e-9
      || Math.abs(roleWeights.fielding - templateRoleWeights.fielding) > 1e-9
      || Math.abs(roleWeights.impact - templateRoleWeights.impact) > 1e-9,
    excludedComponents: [
      ...(battingAvailable ? [] : ['Batting']),
      ...(bowlingAvailable ? [] : ['Bowling']),
      ...(fieldingAvailable ? [] : ['Fielding']),
      ...(impactAvailable ? [] : ['Impact']),
    ],
    normalizedComponents: {
      Batting: roleWeights.batting,
      Bowling: roleWeights.bowling,
      Fielding: roleWeights.fielding,
      Impact: roleWeights.impact,
    },
  }

  const SWI_raw = round(
    clampScore0to100(
      (roleWeights.batting * Batting)
      + (roleWeights.bowling * Bowling)
      + (roleWeights.fielding * Fielding)
      + (roleWeights.impact * Impact),
    ),
    2,
  )
  const confidenceFactor = calculateConfidenceFactor(raw.matchesPlayed)
  const SWI = round(clampScore0to100(SWI_raw * confidenceFactor), 1)

  const subScores: SwingIndexV2SubScores = {
    BR: BRCalc.score,
    BE: BECalc.score,
    PW: PWCalc.score,
    BV: BVCalc.score,
    BC: BCCalc.score,
    BT: BTCalc.score,
    PB: PBCalc.score,
    FI: FICalc.score,
    WI: WICalc.score,
    RF: RFCalc.score,
    CS: CSCalc.score,
    Reliability,
    Power,
    BattingImpact,
    Control: ControlOutput,
    Threat: ThreatOutput,
    BowlingImpact: BowlingImpactOutput,
    Impact,
    TacticalImpact,
    ResultImpact,
    LeadershipTrust,
    Captaincy,
  }

  const composites: SwingIndexV2Composites = {
    BAT: Batting,
    BOWL: BowlingOutput,
    FI: Fielding,
    PW: Power,
    IMP: Impact,
    CAP: Captaincy,
  }

  if (!battingAvailable) excludedSections.push('BATTING_NO_EVIDENCE')
  if (!bowlingAvailable) excludedSections.push('BOWLING_NO_EVIDENCE')
  if (!fieldingAvailable || fieldingEvidenceFactor === 0) excludedSections.push('FIELDING_LOW_EVIDENCE')
  if (!captaincyAvailable) excludedSections.push('CAPTAINCY_NOT_APPLICABLE')

  const axes: SwingIndexV2Axes = {
    reliabilityAxis: Reliability,
    powerAxis: Power,
    bowlingAxis: BowlingOutput,
    fieldingAxis: Fielding,
    impactAxis: Impact,
    captaincyAxis: Captaincy,
  }

  const derivedMetrics: SwingIndexV2DerivedMetrics = {
    ...derivedBase,
    fieldingEvidenceFactor,
    confidenceFactor,
    swiRaw: SWI_raw,
    SWI,
    SWI_raw,
    Batting,
    Reliability,
    Power,
    BattingImpact,
    Bowling: BowlingOutput,
    Control: ControlOutput,
    Threat: ThreatOutput,
    BowlingImpact: BowlingImpactOutput,
    Impact,
    Fielding,
    FieldingRaw,
    Captaincy,
    roleTemplate,
    roleWeights,
  }

  const weightingMeta = {
    excludedSections,
    renormalized: Object.values(scoreDetails).some((detail) => detail.renormalized),
    details: scoreDetails,
  }

  return {
    playerId,
    formulaVersion: SWING_INDEX_V2_FORMULA_VERSION,
    swingIndexScore: SWI,
    composites,
    axes,
    subScores,
    derivedMetrics,
    rawMetrics: {
      battingInnings: raw.battingInnings,
      notOuts: readMetric0(metrics, 'notOuts'),
      totalRuns: readMetric0(metrics, 'totalRuns'),
      totalBallsFaced: raw.totalBallsFaced,
      totalFours: readMetric0(metrics, 'totalFours'),
      totalSixes: raw.totalSixes,
      totalBoundaries: readMetric0(metrics, 'totalBoundaries'),
      boundaryRuns: readMetric0(metrics, 'boundaryRuns'),
      highestScore: raw.highestScore,
      battingDismissals: readMetric0(metrics, 'battingDismissals'),
      battingAverage: raw.battingAverage,
      strikeRate: raw.strikeRate,
      runsPerInnings: raw.runsPerInnings,
      ballsPerDismissal: raw.ballsPerDismissal,
      boundaryPerBall: raw.boundaryPerBall,
      ballsPerBoundary: raw.ballsPerBoundary,
      boundaryRunPct: raw.boundaryRunPct,
      dotBallPctBat: raw.dotBallPctBat,
      singlesPctBat: raw.singlesPctBat,
      scoringShotPct: raw.scoringShotPct,
      fiftyPlusInningsPct: raw.fiftyPlusInningsPct,
      thirtyToFiftyConversionPct: raw.thirtyToFiftyConversionPct,
      powerplaySR: raw.powerplaySR,
      middleSR: raw.middleSR,
      deathSR: raw.deathSR,
      deathBoundaryPerBall: raw.deathBoundaryPerBall,
      vsPaceSR: readMetric0(metrics, 'vsPaceSR'),
      vsSpinSR: readMetric0(metrics, 'vsSpinSR'),
      vsLeftArmPaceSR: readMetric0(metrics, 'vsLeftArmPaceSR'),
      vsRightArmPaceSR: readMetric0(metrics, 'vsRightArmPaceSR'),
      vsOffSpinSR: readMetric0(metrics, 'vsOffSpinSR'),
      vsLegSpinSR: readMetric0(metrics, 'vsLegSpinSR'),
      bowlingInnings: raw.bowlingInnings,
      totalBallsBowled: raw.totalBallsBowled,
      totalOvers: raw.totalOvers,
      totalWickets: raw.totalWickets,
      wides: raw.wides,
      noBalls: raw.noBalls,
      legalDeliveriesPct: raw.legalDeliveriesPct,
      economyRate: raw.economyRate,
      bowlingStrikeRate: raw.bowlingStrikeRate,
      bowlingAverage: raw.bowlingAverage,
      wicketsPerInnings: raw.wicketsPerInnings,
      dotBallPctBowl: raw.dotBallPctBowl,
      boundaryConcededPct: raw.boundaryConcededPct,
      ballsPerBoundaryConceded: raw.ballsPerBoundaryConceded,
      controlBallPct: raw.controlBallPct,
      threeWicketHauls: raw.threeWicketHauls,
      fourWicketHauls: raw.fourWicketHauls,
      fiveWicketHauls: raw.fiveWicketHauls,
      wicketsBowled: raw.wicketsBowled,
      wicketsLBW: raw.wicketsLBW,
      ppEconomy: raw.ppEconomy,
      middleEconomy: raw.middleEconomy,
      deathEconomy: raw.deathEconomy,
      deathWickets: raw.deathWickets,
      catchesPerMatch: raw.catchesPerMatch,
      runOutInvolvementPerMatch: raw.runOutInvolvementPerMatch,
      stumpingsPerKeepingInnings: raw.stumpingsPerKeepingInnings,
      missedChances: raw.missedChances,
      dismissalInvolvementPerMatch: raw.dismissalInvolvementPerMatch,
      matchesPlayed: raw.matchesPlayed,
      matchesWon: raw.matchesWon,
      winPct: raw.winPct,
      chaseMatches: raw.chaseMatches,
      chaseWins: raw.chaseWins,
      defendMatches: raw.defendMatches,
      defendWins: raw.defendWins,
      knockoutImpactAvg: raw.knockoutImpactAvg,
      mvpCount: raw.mvpCount,
      last5BatAvg: raw.last5BatAvg,
      last5BatSR: raw.last5BatSR,
      last5Economy: raw.last5Economy,
      last10Runs: raw.last10Runs,
      last10Wickets: raw.last10Wickets,
      runsStdDev: raw.runsStdDev,
      wicketsStdDev: raw.wicketsStdDev,
      consistencyIndex: raw.consistencyIndex,
      captainMatches: raw.captainMatches,
      captainWins: raw.captainWins,
      captainWinPct: raw.captainWinPct,
      captainSelectionRate: raw.captainSelectionRate,
      captainImpactAvg: raw.captainImpactAvg,
    },
    weightingMeta,

    SWI,
    SWI_raw,
    confidenceFactor,
    Batting,
    Reliability,
    Power,
    BattingImpact,
    Bowling: BowlingOutput,
    Control: ControlOutput,
    Threat: ThreatOutput,
    BowlingImpact: BowlingImpactOutput,
    Impact,
    Fielding,
    FieldingRaw,
    fieldingEvidenceFactor,
    roleTemplate,
    roleWeights,
    Captaincy,
    TacticalImpact,
    ResultImpact,
    LeadershipTrust,
  }
}

export function calculateSwingIndexV2Summary(
  playerId: string,
  metrics: SwingMetricRecord,
  context: SwingIndexRoleContext = {},
): SwingIndexV2Summary {
  const detailed = calculateSwingIndexV2(playerId, metrics, context)
  return buildSummaryPayload(detailed)
}
