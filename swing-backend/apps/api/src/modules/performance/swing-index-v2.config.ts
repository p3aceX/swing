export const SWING_INDEX_V2_FORMULA_VERSION = 'swing-index-v2' as const

export type SwingIndexRangeKey =
  | 'battingAverage'
  | 'runsPerInnings'
  | 'ballsPerDismissal'
  | 'scoringShotPct'
  | 'singlesPctBat'
  | 'fiftyPlusInningsPct'
  | 'thirtyToFiftyConversionPct'
  | 'consistencyIndex'
  | 'strikeRate'
  | 'boundaryPerBall'
  | 'ballsPerBoundary'
  | 'boundaryRunPct'
  | 'dotBallPctBat'
  | 'powerplaySR'
  | 'middleSR'
  | 'sixesPerInnings'
  | 'deathSR'
  | 'deathBoundaryPerBall'
  | 'maxBoundariesInInnings'
  | 'highestScore'
  | 'economyRate'
  | 'dotBallPctBowl'
  | 'controlBallPct'
  | 'boundaryConcededPct'
  | 'ballsPerBoundaryConceded'
  | 'legalDeliveriesPct'
  | 'widesPerOver'
  | 'noBallsPerOver'
  | 'wicketsPerInnings'
  | 'bowlingStrikeRate'
  | 'bowlingAverage'
  | 'wicketRate'
  | 'threeWicketHaulRate'
  | 'fourWicketHaulRate'
  | 'fiveWicketHaulRate'
  | 'bowledLbwPct'
  | 'ppEconomy'
  | 'middleEconomy'
  | 'deathEconomy'
  | 'deathWicketRate'
  | 'catchesPerMatch'
  | 'runOutInvolvementPerMatch'
  | 'stumpingsPerKeepingInnings'
  | 'dismissalInvolvementPerMatch'
  | 'missedChances'
  | 'dismissalInvolvementRate'
  | 'winPct'
  | 'chaseWinPct'
  | 'defendWinPct'
  | 'knockoutImpactAvg'
  | 'mvpRate'
  | 'matchesWonRate'
  | 'last5BatAvg'
  | 'last5BatSR'
  | 'last5Economy'
  | 'last10RunsPerMatch'
  | 'last10WicketsPerMatch'
  | 'runsStdDev'
  | 'wicketsStdDev'

export const SWING_INDEX_V2_NORMALIZATION_RANGES: Record<SwingIndexRangeKey, { min: number; max: number }> = {
  battingAverage: { min: 8, max: 75 },
  runsPerInnings: { min: 6, max: 85 },
  ballsPerDismissal: { min: 8, max: 90 },
  scoringShotPct: { min: 20, max: 80 },
  singlesPctBat: { min: 5, max: 45 },
  fiftyPlusInningsPct: { min: 0, max: 75 },
  thirtyToFiftyConversionPct: { min: 0, max: 100 },
  consistencyIndex: { min: 0, max: 100 },
  strikeRate: { min: 55, max: 230 },
  boundaryPerBall: { min: 0.03, max: 0.38 },
  ballsPerBoundary: { min: 2.5, max: 20 },
  boundaryRunPct: { min: 20, max: 90 },
  dotBallPctBat: { min: 20, max: 70 },
  powerplaySR: { min: 55, max: 220 },
  middleSR: { min: 55, max: 220 },
  sixesPerInnings: { min: 0, max: 4.5 },
  deathSR: { min: 60, max: 300 },
  deathBoundaryPerBall: { min: 0.02, max: 0.55 },
  maxBoundariesInInnings: { min: 0, max: 22 },
  highestScore: { min: 0, max: 220 },
  economyRate: { min: 3.2, max: 14.5 },
  dotBallPctBowl: { min: 18, max: 72 },
  controlBallPct: { min: 8, max: 80 },
  boundaryConcededPct: { min: 5, max: 45 },
  ballsPerBoundaryConceded: { min: 2.5, max: 16 },
  legalDeliveriesPct: { min: 80, max: 100 },
  widesPerOver: { min: 0, max: 1.6 },
  noBallsPerOver: { min: 0, max: 0.5 },
  wicketsPerInnings: { min: 0, max: 4.2 },
  bowlingStrikeRate: { min: 7, max: 52 },
  bowlingAverage: { min: 8, max: 62 },
  wicketRate: { min: 0, max: 0.12 },
  threeWicketHaulRate: { min: 0, max: 0.45 },
  fourWicketHaulRate: { min: 0, max: 0.3 },
  fiveWicketHaulRate: { min: 0, max: 0.2 },
  bowledLbwPct: { min: 0, max: 1 },
  ppEconomy: { min: 3.5, max: 14.5 },
  middleEconomy: { min: 3, max: 12.5 },
  deathEconomy: { min: 5, max: 18 },
  deathWicketRate: { min: 0, max: 0.25 },
  catchesPerMatch: { min: 0, max: 1.8 },
  runOutInvolvementPerMatch: { min: 0, max: 1.3 },
  stumpingsPerKeepingInnings: { min: 0, max: 1.2 },
  dismissalInvolvementPerMatch: { min: 0, max: 2.4 },
  missedChances: { min: 0, max: 8 },
  dismissalInvolvementRate: { min: 0, max: 2.4 },
  winPct: { min: 0, max: 100 },
  chaseWinPct: { min: 0, max: 1 },
  defendWinPct: { min: 0, max: 1 },
  knockoutImpactAvg: { min: 0, max: 140 },
  mvpRate: { min: 0, max: 0.45 },
  matchesWonRate: { min: 0, max: 1 },
  last5BatAvg: { min: 0, max: 90 },
  last5BatSR: { min: 50, max: 240 },
  last5Economy: { min: 3.5, max: 16 },
  last10RunsPerMatch: { min: 0, max: 80 },
  last10WicketsPerMatch: { min: 0, max: 4.5 },
  runsStdDev: { min: 0, max: 80 },
  wicketsStdDev: { min: 0, max: 3.5 },
}
