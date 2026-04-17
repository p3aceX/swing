export type CompetitiveRankKey =
  | 'ROOKIE'
  | 'STRIKER'
  | 'VANGUARD'
  | 'PHANTOM'
  | 'DOMINION'
  | 'ASCENDANT'
  | 'IMMORTAL'
  | 'APEX'

export type PlayerIndexAxis =
  | 'reliability'
  | 'power'
  | 'bowling'
  | 'fielding'
  | 'impact'
  | 'captaincy'

export interface CompetitiveRankDivisionConfig {
  division: number
  threshold: number
  label: string
}

export interface CompetitiveRankTierConfig {
  key: CompetitiveRankKey
  label: string
  divisions: CompetitiveRankDivisionConfig[]
}

export interface CompetitiveSummary {
  impactPoints: number
  rank: string
  rankKey: CompetitiveRankKey
  division: number | null
  rankProgress: number
  rankProgressMax: number
  mvpCount: number
  matchesPlayed: number
}

export interface SeasonSummary {
  seasonId: string | null
  seasonPoints: number
  passMultiplier: number
  seasonLeaderboardPosition: number | null
}

export interface SwingIndexSummary {
  currentSwingIndex: number
  reliabilityIndex: number
  powerIndex: number
  bowlingIndex: number
  fieldingIndex: number
  impactIndex: number
  captaincyIndex: number | null
}

export interface PlayerIndexBreakdownResponse {
  axis: PlayerIndexAxis
  window: 'MATCH' | 'LAST_5' | 'LAST_10' | 'SEASON' | 'LIFETIME'
  score: number | null
  matchesSampled: number
  breakdown: Record<string, number | null>
  insight: string
}

export interface PlayerIndexTrendPoint {
  snapshotType: string
  snapshotDate: string
  reliabilityIndex: number | null
  powerIndex: number | null
  bowlingIndex: number | null
  fieldingIndex: number | null
  impactIndex: number | null
  captaincyIndex: number | null
  swingIndex: number | null
  impactPoints: number | null
  seasonPoints: number | null
  rankKey: CompetitiveRankKey | null
  division: number | null
  rankLabel: string | null
}

export interface PlayerPhysicalSummary {
  currentPhysicalIndex: number
  recentSamples: Array<{
    id: string
    sourceType: string
    sampleStartAt: string
    sampleEndAt: string
    workloadScore: number | null
    recoveryScore: number | null
    distanceMeters: number | null
    sprintCount: number | null
    activeMinutes: number | null
    caloriesBurned: number | null
    averageHeartRate: number | null
    maxHeartRate: number | null
  }>
}
