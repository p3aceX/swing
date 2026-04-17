import type { CompetitiveRankKey } from '@swing/db'
import type { PlayerIndexAxis } from '@swing/types'

export interface CompetitivePlayerFactInput {
  matchId: string
  playerId: string
  teamId: string
  opponentTeamId: string
  inningsNo: number | null
  battingPosition: number | null
  didBat: boolean
  runs: number
  ballsFaced: number
  fours: number
  sixes: number
  dismissalType: string | null
  wasNotOut: boolean
  didBowl: boolean
  ballsBowled: number
  oversBowled: number | null
  maidens: number
  wickets: number
  runsConceded: number
  dotBalls: number
  wides: number
  noBalls: number
  catches: number
  runOuts: number
  stumpings: number
  fieldTimeSeconds: number | null
  oversFielded: number | null
  isCaptain: boolean
  result: 'WIN' | 'LOSS' | 'TIE' | 'NO_RESULT'
  matchFormat: string | null
  ballType: string | null
  matchDate: Date
}

export interface CompetitiveContext {
  matchFormat: string | null
  teamRuns: number
  teamWickets: number
  opponentRuns: number
  opponentWickets: number
  teamWon: boolean
  closeMatch: boolean
  chaseMatch: boolean
  playersInMatch: number
  targetRuns: number | null
}

export interface AxisScoreResult {
  score: number | null
  breakdown: Record<string, number | null>
  insight: string
}

export interface DerivedMetricRecord {
  strikeRate: number | null
  boundaryRatePerBall: number | null
  boundaryRunsPct: number | null
  scoringContributionPct: number | null
  dismissalStabilityMetric: number | null
  pressureBattingMetric: number | null
  economyRate: number | null
  ballsPerWicket: number | null
  dotBallPct: number | null
  wicketContributionPct: number | null
  spellQualityMetric: number | null
  phaseDifficultyMetric: number | null
  fieldingInvolvementMetric: number | null
  physicalWorkloadMetric: number | null
  captaincyInfluenceMetric: number | null
}

export interface ImpactPointBreakdown {
  baseImpactPoints: number
  totalImpactPoints: number
  playingPoints: number
  battingPoints: number
  bowlingPoints: number
  fieldingPoints: number
  winBonusPoints: number
  mvpBonusPoints: number
  battingDetails: {
    runsPoints: number
    boundaryBonusPoints: number
    strikeRateBonusPoints: number
    contributionBonusPoints: number
  }
  bowlingDetails: {
    wicketPoints: number
    dotBallPoints: number
    maidenPoints: number
    economyBonusPoints: number
    haulBonusPoints: number
  }
  fieldingDetails: {
    catchPoints: number
    runOutPoints: number
    stumpingPoints: number
  }
}

export interface MatchIndexComputation {
  reliability: AxisScoreResult
  power: AxisScoreResult
  bowling: AxisScoreResult
  fielding: AxisScoreResult
  impact: AxisScoreResult
  captaincy: AxisScoreResult
  swingIndex: number
  gameInfluenceIndex: number
  performanceScore: number
  impactPoints: number
  impactBreakdown: ImpactPointBreakdown
  seasonPoints: number
  passMultiplierApplied: number
}

export interface RankResolution {
  rankKey: CompetitiveRankKey
  division: number
  label: string
  threshold: number
  nextThreshold: number | null
}

export interface BreakdownWindowInput {
  axis: PlayerIndexAxis
  facts: CompetitivePlayerFactInput[]
  metrics: DerivedMetricRecord[]
  indexScores: Array<{
    reliabilityIndex: number | null
    powerIndex: number | null
    bowlingIndex: number | null
    fieldingIndex: number | null
    impactIndex: number | null
    captaincyIndex: number | null
  }>
}
