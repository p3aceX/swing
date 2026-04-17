import assert from 'node:assert/strict'
import test from 'node:test'
import { calculateSwingIndexV2, calculateSwingIndexV2Summary } from './swing-index-v2.calculator'

function buildMetrics(overrides: Record<string, number | null | undefined> = {}) {
  return {
    battingInnings: 0,
    totalBallsFaced: 0,
    totalRuns: 0,
    notOuts: 0,
    totalFours: 0,
    totalSixes: 0,
    totalBoundaries: 0,
    boundaryRuns: 0,
    highestScore: 0,
    battingDismissals: 0,
    battingAverage: 0,
    strikeRate: 0,
    runsPerInnings: 0,
    ballsPerDismissal: 0,
    boundaryPerBall: 0,
    ballsPerBoundary: 0,
    boundaryRunPct: 0,
    dotBallPctBat: 0,
    singlesPctBat: 0,
    scoringShotPct: 0,
    fiftyPlusInningsPct: 0,
    thirtyToFiftyConversionPct: 0,
    powerplaySR: 0,
    middleSR: 0,
    deathSR: 0,
    deathBoundaryPerBall: 0,
    maxBoundariesInInnings: 0,
    vsPaceSR: 0,
    vsSpinSR: 0,
    vsLeftArmPaceSR: 0,
    vsRightArmPaceSR: 0,
    vsOffSpinSR: 0,
    vsLegSpinSR: 0,
    bowlingInnings: 0,
    totalBallsBowled: 0,
    totalOvers: 0,
    totalWickets: 0,
    wides: 0,
    noBalls: 0,
    legalDeliveriesPct: 0,
    economyRate: 0,
    bowlingStrikeRate: 0,
    bowlingAverage: 0,
    wicketsPerInnings: 0,
    dotBallPctBowl: 0,
    boundaryConcededPct: 0,
    ballsPerBoundaryConceded: 0,
    controlBallPct: 0,
    threeWicketHauls: 0,
    fourWicketHauls: 0,
    fiveWicketHauls: 0,
    wicketsBowled: 0,
    wicketsLBW: 0,
    ppEconomy: 0,
    middleEconomy: 0,
    deathEconomy: 0,
    deathWickets: 0,
    deathBallsBowled: 0,
    catchesPerMatch: 0,
    runOutInvolvementPerMatch: 0,
    stumpingsPerKeepingInnings: 0,
    stumpings: 0,
    dismissalInvolvementPerMatch: 0,
    missedChances: 0,
    totalDismissalInvolvements: 0,
    matchesPlayed: 0,
    matchesWon: 0,
    winPct: 0,
    chaseMatches: 0,
    chaseWins: 0,
    defendMatches: 0,
    defendWins: 0,
    knockoutImpactAvg: 0,
    mvpCount: 0,
    last5BatAvg: 0,
    last5BatSR: 0,
    last5Economy: 0,
    last10Runs: 0,
    last10Wickets: 0,
    runsStdDev: 0,
    wicketsStdDev: 0,
    consistencyIndex: 0,
    captainMatches: 0,
    captainWins: 0,
    captainWinPct: 0,
    captainSelectionRate: 0,
    captainImpactAvg: 0,
    ...overrides,
  }
}

test('batter-only profile does not penalize SWI and surfaces bowling as zero when no bowling evidence exists', () => {
  const result = calculateSwingIndexV2('player-batter', buildMetrics({
    battingInnings: 22,
    totalBallsFaced: 410,
    totalRuns: 612,
    battingDismissals: 18,
    battingAverage: 34,
    runsPerInnings: 28,
    strikeRate: 149,
    ballsPerDismissal: 22,
    boundaryPerBall: 0.17,
    ballsPerBoundary: 5.9,
    boundaryRunPct: 51,
    dotBallPctBat: 38,
    powerplaySR: 145,
    middleSR: 136,
    deathSR: 184,
    deathBoundaryPerBall: 0.26,
    maxBoundariesInInnings: 11,
    highestScore: 87,
    singlesPctBat: 23,
    scoringShotPct: 58,
    fiftyPlusInningsPct: 18,
    thirtyToFiftyConversionPct: 54,
    totalSixes: 26,
    totalDismissalInvolvements: 5,
    catchesPerMatch: 0.22,
    dismissalInvolvementPerMatch: 0.22,
    matchesPlayed: 22,
    matchesWon: 13,
    winPct: 59.09,
    chaseMatches: 11,
    chaseWins: 6,
    defendMatches: 11,
    defendWins: 7,
    mvpCount: 4,
    consistencyIndex: 64,
    last5BatAvg: 37,
    last5BatSR: 153,
    last10Runs: 241,
    runsStdDev: 18,
  }), { playerRole: 'BATSMAN' })

  assert.equal(result.Bowling, 0)
  assert.equal(result.Control, 0)
  assert.equal(result.Threat, 0)
  assert.equal(result.roleTemplate, 'pure_batter')
  assert.equal(result.roleWeights.bowling, 0)
  assert.equal(result.weightingMeta.excludedSections.includes('BOWLING_NO_EVIDENCE'), true)
  assert.equal(Number.isFinite(result.swingIndexScore), true)
})

test('bowler-only profile keeps batting neutral instead of penalizing missing batting role', () => {
  const result = calculateSwingIndexV2('player-bowler', buildMetrics({
    bowlingInnings: 18,
    totalBallsBowled: 366,
    totalOvers: 61,
    totalWickets: 28,
    wicketsPerInnings: 1.56,
    economyRate: 6.42,
    bowlingStrikeRate: 13.07,
    bowlingAverage: 15.8,
    dotBallPctBowl: 43,
    controlBallPct: 54,
    boundaryConcededPct: 14,
    ballsPerBoundaryConceded: 7.4,
    legalDeliveriesPct: 96,
    wides: 9,
    noBalls: 2,
    threeWicketHauls: 4,
    fourWicketHauls: 2,
    fiveWicketHauls: 0,
    wicketsBowled: 9,
    wicketsLBW: 6,
    ppEconomy: 5.8,
    middleEconomy: 6.1,
    deathEconomy: 7.3,
    deathWickets: 8,
    deathBallsBowled: 102,
    catchesPerMatch: 0.3,
    runOutInvolvementPerMatch: 0.12,
    dismissalInvolvementPerMatch: 0.42,
    totalDismissalInvolvements: 8,
    matchesPlayed: 18,
    matchesWon: 10,
    winPct: 55.56,
    chaseMatches: 8,
    chaseWins: 5,
    defendMatches: 10,
    defendWins: 5,
    mvpCount: 3,
    consistencyIndex: 62,
    last5Economy: 6.4,
    last10Wickets: 17,
    wicketsStdDev: 0.9,
  }), { playerRole: 'BOWLER' })

  assert.equal(result.Batting, 50)
  assert.equal(result.roleTemplate, 'pure_bowler')
  assert.equal(result.roleWeights.batting, 0)
  assert.equal(result.weightingMeta.excludedSections.includes('BATTING_NO_EVIDENCE'), true)
  assert.equal(Number.isFinite(result.swingIndexScore), true)
})

test('explicit non-bowler role ignores bowling in final SWI weighting', () => {
  const base = buildMetrics({
    battingInnings: 18,
    totalBallsFaced: 320,
    totalRuns: 490,
    battingDismissals: 14,
    battingAverage: 35,
    runsPerInnings: 27.22,
    strikeRate: 153.12,
    ballsPerDismissal: 22.86,
    boundaryPerBall: 0.19,
    ballsPerBoundary: 5.3,
    boundaryRunPct: 55,
    dotBallPctBat: 35,
    scoringShotPct: 63,
    singlesPctBat: 22,
    powerplaySR: 151,
    middleSR: 143,
    deathSR: 184,
    deathBoundaryPerBall: 0.28,
    maxBoundariesInInnings: 12,
    totalSixes: 31,
    totalDismissalInvolvements: 8,
    catchesPerMatch: 0.35,
    dismissalInvolvementPerMatch: 0.44,
    matchesPlayed: 18,
    matchesWon: 10,
    winPct: 55.56,
    chaseMatches: 9,
    chaseWins: 5,
    defendMatches: 9,
    defendWins: 5,
    mvpCount: 4,
    consistencyIndex: 66,
    last5BatAvg: 40,
    last5BatSR: 158,
    last10Runs: 290,
    runsStdDev: 16,
  })

  const withNoBowling = calculateSwingIndexV2('role-batter-a', base, { playerRole: 'BATSMAN' })
  const withBadBowling = calculateSwingIndexV2('role-batter-b', {
    ...base,
    bowlingInnings: 4,
    totalBallsBowled: 72,
    totalOvers: 12,
    totalWickets: 1,
    wicketsPerInnings: 0.25,
    economyRate: 11.8,
    bowlingStrikeRate: 72,
    bowlingAverage: 85,
    dotBallPctBowl: 12,
    controlBallPct: 10,
    boundaryConcededPct: 55,
    ballsPerBoundaryConceded: 1.6,
    legalDeliveriesPct: 82,
    ppEconomy: 12.5,
    middleEconomy: 11.4,
    deathEconomy: 14.2,
    deathWickets: 0,
    deathBallsBowled: 18,
  }, { playerRole: 'BATSMAN' })

  assert.equal(withNoBowling.roleTemplate, 'pure_batter')
  assert.equal(withBadBowling.roleTemplate, 'pure_batter')
  assert.equal(withNoBowling.roleWeights.bowling, 0)
  assert.equal(withNoBowling.SWI, withBadBowling.SWI)
  assert.equal(withNoBowling.SWI_raw, withBadBowling.SWI_raw)
})

test('no fielding evidence keeps fielding near conservative baseline using evidence factor', () => {
  const result = calculateSwingIndexV2('player-neutral-fielding', buildMetrics({
    battingInnings: 10,
    totalBallsFaced: 180,
    totalRuns: 220,
    battingAverage: 24,
    strikeRate: 122,
    runsPerInnings: 22,
    ballsPerDismissal: 15,
    boundaryPerBall: 0.11,
    ballsPerBoundary: 8.7,
    boundaryRunPct: 41,
    scoringShotPct: 50,
    singlesPctBat: 20,
    bowlingInnings: 8,
    totalBallsBowled: 132,
    totalOvers: 22,
    totalWickets: 10,
    wicketsPerInnings: 1.25,
    economyRate: 7.2,
    bowlingStrikeRate: 13.2,
    bowlingAverage: 15.8,
    dotBallPctBowl: 34,
    controlBallPct: 39,
    legalDeliveriesPct: 94,
    ppEconomy: 6.9,
    middleEconomy: 7.1,
    deathEconomy: 8.4,
    totalDismissalInvolvements: 0,
    catchesPerMatch: 0,
    runOutInvolvementPerMatch: 0,
    dismissalInvolvementPerMatch: 0,
    missedChances: 0,
    matchesPlayed: 10,
    matchesWon: 5,
    winPct: 50,
    chaseMatches: 5,
    chaseWins: 2,
    defendMatches: 5,
    defendWins: 3,
  }))

  assert.equal(result.fieldingEvidenceFactor, 0)
  assert.equal(result.Fielding, 35)
  assert.equal(result.derivedMetrics.Fielding, 35)
})

test('confidence factor suppresses SWI for tiny sample sizes', () => {
  const lowSample = calculateSwingIndexV2('player-low-sample', buildMetrics({
    battingInnings: 2,
    totalBallsFaced: 54,
    totalRuns: 77,
    battingAverage: 38.5,
    runsPerInnings: 38.5,
    strikeRate: 142.59,
    ballsPerDismissal: 27,
    boundaryPerBall: 0.18,
    ballsPerBoundary: 5.6,
    boundaryRunPct: 55,
    scoringShotPct: 61,
    singlesPctBat: 20,
    powerplaySR: 146,
    middleSR: 137,
    deathSR: 175,
    totalSixes: 5,
    bowlingInnings: 2,
    totalBallsBowled: 48,
    totalOvers: 8,
    totalWickets: 5,
    wicketsPerInnings: 2.5,
    economyRate: 6.5,
    bowlingStrikeRate: 9.6,
    bowlingAverage: 12.4,
    dotBallPctBowl: 41,
    controlBallPct: 52,
    legalDeliveriesPct: 96,
    ppEconomy: 6.1,
    middleEconomy: 6.7,
    deathEconomy: 7.4,
    deathWickets: 2,
    deathBallsBowled: 18,
    catchesPerMatch: 0.5,
    dismissalInvolvementPerMatch: 0.5,
    totalDismissalInvolvements: 1,
    matchesPlayed: 2,
    matchesWon: 2,
    winPct: 100,
    chaseMatches: 1,
    chaseWins: 1,
    defendMatches: 1,
    defendWins: 1,
    mvpCount: 1,
    consistencyIndex: 66,
    last5BatAvg: 38.5,
    last5BatSR: 142.59,
    last5Economy: 6.5,
    last10Runs: 77,
    last10Wickets: 5,
    runsStdDev: 3,
    wicketsStdDev: 0.5,
  }))

  const established = calculateSwingIndexV2('player-established', buildMetrics({
    ...lowSample.rawMetrics,
    battingInnings: 12,
    bowlingInnings: 12,
    totalBallsFaced: 324,
    totalRuns: 462,
    totalBallsBowled: 288,
    totalOvers: 48,
    totalWickets: 30,
    matchesPlayed: 12,
    matchesWon: 12,
    winPct: 100,
    chaseMatches: 6,
    chaseWins: 6,
    defendMatches: 6,
    defendWins: 6,
    mvpCount: 6,
    totalDismissalInvolvements: 6,
    last10Runs: 385,
    last10Wickets: 24,
  }))

  assert.equal(lowSample.confidenceFactor, 0.1767)
  assert.equal(established.confidenceFactor, 0.4126)
  assert.equal(lowSample.SWI < established.SWI, true)
  assert.equal(lowSample.SWI <= lowSample.SWI_raw, true)
})

test('strong bowling + weak batting profile is reflected in pillar split', () => {
  const result = calculateSwingIndexV2('player-bowling-heavy', buildMetrics({
    battingInnings: 14,
    totalBallsFaced: 170,
    totalRuns: 124,
    battingAverage: 12.4,
    runsPerInnings: 8.9,
    strikeRate: 72.9,
    ballsPerDismissal: 10.3,
    boundaryPerBall: 0.05,
    ballsPerBoundary: 20,
    boundaryRunPct: 26,
    dotBallPctBat: 57,
    scoringShotPct: 33,
    singlesPctBat: 11,
    powerplaySR: 70,
    middleSR: 68,
    deathSR: 86,
    totalSixes: 2,
    bowlingInnings: 14,
    totalBallsBowled: 312,
    totalOvers: 52,
    totalWickets: 30,
    wicketsPerInnings: 2.14,
    economyRate: 5.7,
    bowlingStrikeRate: 10.4,
    bowlingAverage: 9.8,
    dotBallPctBowl: 47,
    controlBallPct: 58,
    boundaryConcededPct: 10,
    ballsPerBoundaryConceded: 10,
    legalDeliveriesPct: 97,
    ppEconomy: 5.3,
    middleEconomy: 5.9,
    deathEconomy: 6.8,
    deathWickets: 11,
    deathBallsBowled: 96,
    totalDismissalInvolvements: 4,
    catchesPerMatch: 0.2,
    dismissalInvolvementPerMatch: 0.28,
    matchesPlayed: 14,
    matchesWon: 9,
    winPct: 64.29,
    chaseMatches: 6,
    chaseWins: 4,
    defendMatches: 8,
    defendWins: 5,
    mvpCount: 4,
    consistencyIndex: 51,
    last5Economy: 5.6,
    last10Wickets: 26,
    wicketsStdDev: 0.8,
  }))

  assert.equal(result.Bowling > result.Batting, true)
  assert.equal(result.subScores.Threat !== null, true)
  assert.equal(Number.isFinite(result.swingIndexScore), true)
})

test('all-round profile scores strongly across batting and bowling pillars', () => {
  const result = calculateSwingIndexV2('player-all-round', buildMetrics({
    battingInnings: 24,
    totalBallsFaced: 562,
    totalRuns: 865,
    battingAverage: 52,
    runsPerInnings: 45,
    strikeRate: 175,
    ballsPerDismissal: 34,
    boundaryPerBall: 0.24,
    ballsPerBoundary: 4.2,
    boundaryRunPct: 64,
    dotBallPctBat: 28,
    scoringShotPct: 70,
    singlesPctBat: 22,
    fiftyPlusInningsPct: 45,
    thirtyToFiftyConversionPct: 70,
    powerplaySR: 170,
    middleSR: 160,
    deathSR: 230,
    deathBoundaryPerBall: 0.35,
    maxBoundariesInInnings: 17,
    highestScore: 121,
    totalSixes: 75,
    vsPaceSR: 178,
    vsSpinSR: 162,
    vsLeftArmPaceSR: 170,
    vsRightArmPaceSR: 180,
    vsOffSpinSR: 158,
    vsLegSpinSR: 166,
    bowlingInnings: 20,
    totalBallsBowled: 420,
    totalOvers: 70,
    totalWickets: 34,
    wicketsPerInnings: 1.7,
    economyRate: 6.12,
    bowlingStrikeRate: 12.35,
    bowlingAverage: 14.8,
    dotBallPctBowl: 44,
    controlBallPct: 55,
    boundaryConcededPct: 12,
    ballsPerBoundaryConceded: 8.8,
    legalDeliveriesPct: 97,
    ppEconomy: 5.8,
    middleEconomy: 6.2,
    deathEconomy: 7.1,
    deathWickets: 10,
    deathBallsBowled: 114,
    catchesPerMatch: 0.58,
    runOutInvolvementPerMatch: 0.22,
    dismissalInvolvementPerMatch: 0.8,
    totalDismissalInvolvements: 15,
    matchesPlayed: 24,
    matchesWon: 15,
    winPct: 62.5,
    chaseMatches: 11,
    chaseWins: 7,
    defendMatches: 13,
    defendWins: 8,
    mvpCount: 8,
    knockoutImpactAvg: 76,
    consistencyIndex: 78,
    last5BatAvg: 60,
    last5BatSR: 185,
    last5Economy: 6.2,
    last10Runs: 520,
    last10Wickets: 17,
    runsStdDev: 12,
    wicketsStdDev: 0.7,
  }))

  assert.equal(result.Batting > 60, true)
  assert.equal(result.Bowling > 60, true)
  assert.equal(result.SWI > 30, true)
  assert.equal(result.SWI < result.SWI_raw, true)
})

test('captaincy stays separate: non-captain is null, captain has computed score', () => {
  const nonCaptain = calculateSwingIndexV2('player-non-captain', buildMetrics({
    matchesPlayed: 16,
    battingInnings: 12,
    bowlingInnings: 8,
    totalBallsFaced: 240,
    totalRuns: 320,
    totalBallsBowled: 180,
    totalOvers: 30,
    totalWickets: 12,
    catchesPerMatch: 0.3,
    dismissalInvolvementPerMatch: 0.3,
    totalDismissalInvolvements: 5,
  }))

  const captain = calculateSwingIndexV2('player-captain', buildMetrics({
    matchesPlayed: 16,
    battingInnings: 12,
    bowlingInnings: 8,
    totalBallsFaced: 240,
    totalRuns: 320,
    totalBallsBowled: 180,
    totalOvers: 30,
    totalWickets: 12,
    catchesPerMatch: 0.3,
    dismissalInvolvementPerMatch: 0.3,
    totalDismissalInvolvements: 5,
    captainMatches: 10,
    captainWins: 7,
    captainWinPct: 70,
    captainSelectionRate: 0.625,
    captainImpactAvg: 82,
  }))

  assert.equal(nonCaptain.Captaincy, null)
  assert.equal(nonCaptain.weightingMeta.excludedSections.includes('CAPTAINCY_NOT_APPLICABLE'), true)
  assert.equal(captain.Captaincy !== null, true)
  assert.equal((captain.Captaincy ?? 0) > 0, true)
  assert.equal(captain.SWI_raw, nonCaptain.SWI_raw)
})

test('zero and missing data never produce NaN or Infinity', () => {
  const result = calculateSwingIndexV2('player-zero', buildMetrics({
    last5Economy: null,
    runsStdDev: null,
    wicketsStdDev: null,
    consistencyIndex: null,
  }))

  assert.equal(Number.isFinite(result.swingIndexScore), true)
  assert.equal(Number.isFinite(result.SWI_raw), true)
  assert.equal(Number.isFinite(result.Fielding), true)
  assert.equal(result.SWI, 0)
  assert.equal(result.SWI_raw, 47.75)
  assert.equal(result.derivedMetrics.SWI_raw, 47.75)
})

test('summary payload exposes confidence and pillar outputs for UI', () => {
  const summary = calculateSwingIndexV2Summary('player-summary', buildMetrics({
    battingInnings: 12,
    totalBallsFaced: 260,
    battingAverage: 32,
    runsPerInnings: 26,
    strikeRate: 148,
    boundaryPerBall: 0.17,
    ballsPerBoundary: 6.1,
    boundaryRunPct: 50,
    powerplaySR: 146,
    middleSR: 133,
    deathSR: 176,
    totalSixes: 18,
    bowlingInnings: 10,
    totalBallsBowled: 216,
    totalOvers: 36,
    totalWickets: 15,
    wicketsPerInnings: 1.5,
    economyRate: 6.8,
    bowlingStrikeRate: 14.4,
    bowlingAverage: 16.4,
    dotBallPctBowl: 38,
    controlBallPct: 45,
    ppEconomy: 6.3,
    middleEconomy: 7,
    deathEconomy: 8,
    deathWickets: 5,
    deathBallsBowled: 66,
    catchesPerMatch: 0.35,
    dismissalInvolvementPerMatch: 0.35,
    totalDismissalInvolvements: 4,
    matchesPlayed: 12,
    matchesWon: 7,
    winPct: 58.33,
    chaseMatches: 6,
    chaseWins: 3,
    defendMatches: 6,
    defendWins: 4,
    mvpCount: 3,
    consistencyIndex: 63,
    last5BatAvg: 30,
    last5BatSR: 151,
    last5Economy: 6.9,
    last10Runs: 225,
    last10Wickets: 13,
    runsStdDev: 17,
    wicketsStdDev: 1.1,
  }))

  assert.equal(summary.formulaVersion, 'swing-index-v2')
  assert.equal(summary.swingIndexScore >= 0 && summary.swingIndexScore <= 100, true)
  assert.equal(Number.isFinite(summary.confidenceFactor), true)
  assert.equal(typeof summary.roleTemplate, 'string')
  assert.equal(summary.roleWeights.batting + summary.roleWeights.bowling + summary.roleWeights.fielding + summary.roleWeights.impact, 1)
  assert.equal(summary.Batting >= 0 && summary.Batting <= 100, true)
  assert.equal(summary.Bowling >= 0 && summary.Bowling <= 100, true)
  assert.equal(summary.Fielding >= 0 && summary.Fielding <= 100, true)
})

test('all-rounder archetype selection chooses batting or bowling weighted template', () => {
  const battingHeavy = calculateSwingIndexV2('allrounder-bat', buildMetrics({
    battingInnings: 16,
    totalBallsFaced: 420,
    totalRuns: 520,
    bowlingInnings: 12,
    totalBallsBowled: 96,
    totalOvers: 16,
    totalWickets: 7,
    wicketsPerInnings: 0.58,
    economyRate: 7.8,
    bowlingStrikeRate: 13.7,
    bowlingAverage: 20.5,
    catchesPerMatch: 0.35,
    dismissalInvolvementPerMatch: 0.35,
    totalDismissalInvolvements: 6,
    matchesPlayed: 16,
  }), { playerRole: 'ALL_ROUNDER' })

  const bowlingHeavy = calculateSwingIndexV2('allrounder-bowl', buildMetrics({
    battingInnings: 14,
    totalBallsFaced: 120,
    totalRuns: 170,
    bowlingInnings: 16,
    totalBallsBowled: 420,
    totalOvers: 70,
    totalWickets: 25,
    wicketsPerInnings: 1.56,
    economyRate: 6.3,
    bowlingStrikeRate: 16.8,
    bowlingAverage: 17.6,
    catchesPerMatch: 0.3,
    dismissalInvolvementPerMatch: 0.3,
    totalDismissalInvolvements: 5,
    matchesPlayed: 16,
  }), { playerRole: 'ALL_ROUNDER' })

  assert.equal(battingHeavy.roleTemplate, 'batting_all_rounder')
  assert.equal(bowlingHeavy.roleTemplate, 'bowling_all_rounder')
  assert.equal(battingHeavy.roleWeights.batting, 0.4)
  assert.equal(bowlingHeavy.roleWeights.bowling, 0.35)
})

test('all-rounder without bowling evidence drops bowling weight and renormalizes active pillars', () => {
  const result = calculateSwingIndexV2('allrounder-no-bowl', buildMetrics({
    battingInnings: 8,
    totalBallsFaced: 140,
    totalRuns: 160,
    battingDismissals: 7,
    battingAverage: 22.86,
    runsPerInnings: 20,
    strikeRate: 114.29,
    boundaryPerBall: 0.08,
    ballsPerBoundary: 12.5,
    boundaryRunPct: 28,
    catchesPerMatch: 0.25,
    dismissalInvolvementPerMatch: 0.25,
    totalDismissalInvolvements: 2,
    matchesPlayed: 8,
    matchesWon: 4,
    winPct: 50,
    chaseMatches: 4,
    chaseWins: 2,
    defendMatches: 4,
    defendWins: 2,
    consistencyIndex: 52,
  }), { playerRole: 'ALL_ROUNDER' })

  assert.equal(result.Bowling, 0)
  assert.equal(result.roleWeights.bowling, 0)
  assert.equal(result.roleWeights.batting + result.roleWeights.bowling + result.roleWeights.fielding + result.roleWeights.impact, 1)
})
