import assert from 'node:assert/strict'
import test from 'node:test'
import {
  applyMvpBonusToImpactBreakdown,
  computeBattingIndex,
  computeBattingMetrics,
  computeImpactPointBreakdown,
  computeMatchIndexes,
  computeSwingIndex,
  computePhysicalProxy,
  resolveRankFromImpactPoints,
} from './performance.calculations'
import { IMPACT_POINT_RULES } from './performance.config'
import type { CompetitiveContext, CompetitivePlayerFactInput } from './performance.types'

function makeFact(overrides: Partial<CompetitivePlayerFactInput> = {}): CompetitivePlayerFactInput {
  return {
    matchId: 'match-1',
    playerId: 'player-1',
    teamId: 'Team A',
    opponentTeamId: 'Team B',
    inningsNo: 1,
    battingPosition: 3,
    didBat: true,
    runs: 32,
    ballsFaced: 24,
    fours: 3,
    sixes: 1,
    dismissalType: 'CAUGHT',
    wasNotOut: false,
    didBowl: false,
    ballsBowled: 0,
    oversBowled: null,
    maidens: 0,
    wickets: 0,
    runsConceded: 0,
    dotBalls: 0,
    wides: 0,
    noBalls: 0,
    catches: 0,
    runOuts: 0,
    stumpings: 0,
    fieldTimeSeconds: 2400,
    oversFielded: 14,
    isCaptain: false,
    result: 'WIN',
    matchFormat: 'T20',
    ballType: 'LEATHER',
    matchDate: new Date('2026-03-20T10:00:00.000Z'),
    ...overrides,
  }
}

function makeContext(overrides: Partial<CompetitiveContext> = {}): CompetitiveContext {
  return {
    matchFormat: 'T20',
    teamRuns: 150,
    teamWickets: 6,
    opponentRuns: 144,
    opponentWickets: 8,
    teamWon: true,
    closeMatch: true,
    chaseMatch: true,
    playersInMatch: 22,
    targetRuns: 145,
    ...overrides,
  }
}

test('swing index resolves with renamed V2 parameters', () => {
  const result = computeSwingIndex({
    reliabilityIndex: 80,
    powerIndex: 70,
    bowlingIndex: 40,
    fieldingIndex: 60,
    impactIndex: 75,
    physicalIndex: 0,
    captaincyIndex: null,
    didBat: true,
    didBowl: true,
    playerRole: 'ALL_ROUNDER',
  })
  assert.ok(result > 50 && result < 90)
})

test('batting index explains high run volume with weak strike-rate efficiency', () => {
  const fact = makeFact({
    runs: 54,
    ballsFaced: 62,
    fours: 4,
    sixes: 1,
    battingPosition: 3,
  })
  const context = makeContext({ teamRuns: 130, chaseMatch: false, targetRuns: null })

  const metrics = computeBattingMetrics(fact, context)
  const batting = computeBattingIndex(fact, metrics, context)

  assert.ok((batting.breakdown.runVolume ?? 0) >= 70)
  assert.ok((batting.breakdown.strikeRateEfficiency ?? 100) <= 55)
  assert.ok((batting.breakdown.boundaryRate ?? 100) <= 55)
  assert.equal(
    batting.insight,
    'You are scoring runs consistently, but your strike rate and boundary frequency are holding back your batting index.',
  )
})

test('simple live impact keeps a 3-wicket spell ahead of a tiny cameo', () => {
  const cameoFact = makeFact({
    playerId: 'cameo-1',
    runs: 8,
    ballsFaced: 4,
    fours: 2,
    sixes: 0,
    didBowl: false,
  })
  const bowlerFact = makeFact({
    playerId: 'bowler-1',
    didBat: false,
    runs: 0,
    ballsFaced: 0,
    fours: 0,
    sixes: 0,
    battingPosition: null,
    dismissalType: null,
    didBowl: true,
    ballsBowled: 18,
    oversBowled: 3,
    wickets: 3,
    runsConceded: 14,
    dotBalls: 10,
  })
  const liveContext = makeContext({
    teamRuns: 14,
    opponentRuns: 0,
    teamWon: false,
    closeMatch: false,
    chaseMatch: false,
    targetRuns: null,
  })

  const cameo = computeMatchIndexes({
    fact: cameoFact,
    context: liveContext,
    recentGameInfluence: [],
    passMultiplier: 1,
  })
  const bowler = computeMatchIndexes({
    fact: bowlerFact,
    context: liveContext,
    recentGameInfluence: [],
    passMultiplier: 1,
  })

  assert.ok(cameo.impactBreakdown.playingPoints > 0)
  assert.equal(cameo.impactBreakdown.winBonusPoints, 0)
  assert.ok(cameo.impactBreakdown.battingPoints > 0)
  assert.ok(bowler.impactBreakdown.bowlingPoints > cameo.impactBreakdown.battingPoints)
  assert.ok(bowler.impactPoints > cameo.impactPoints)
})

test('bowling-heavy player with DNB still earns strong impact points and can top MVP race', () => {
  const bowlingFact = makeFact({
    playerId: 'bowler-1',
    didBat: false,
    runs: 0,
    ballsFaced: 0,
    fours: 0,
    sixes: 0,
    dismissalType: null,
    wasNotOut: false,
    battingPosition: null,
    didBowl: true,
    ballsBowled: 24,
    oversBowled: 4,
    maidens: 1,
    wickets: 4,
    runsConceded: 18,
    dotBalls: 13,
  })
  const batterFact = makeFact({
    playerId: 'batter-1',
    didBat: true,
    runs: 31,
    ballsFaced: 24,
    fours: 3,
    sixes: 1,
    didBowl: false,
    wickets: 0,
  })
  const context = makeContext({ opponentWickets: 6 })

  const bowler = computeMatchIndexes({
    fact: bowlingFact,
    context,
    recentGameInfluence: [66, 69, 72],
    passMultiplier: 1,
  })
  const batter = computeMatchIndexes({
    fact: batterFact,
    context,
    recentGameInfluence: [60, 61, 62],
    passMultiplier: 1,
  })

  assert.equal(bowler.reliability.score, null)
  assert.ok(bowler.impactPoints >= 70)
  assert.ok(bowler.impactPoints > batter.impactPoints)
})

test('official impact adds only the team-win bonus, while MVP bonus is applied separately', () => {
  const fact = makeFact({
    didBowl: true,
    ballsBowled: 24,
    oversBowled: 4,
    wickets: 3,
    runsConceded: 18,
    dotBalls: 12,
  })
  const wonContext = makeContext({ teamWon: true })
  const lostContext = makeContext({ teamWon: false })

  const wonBreakdown = computeImpactPointBreakdown(fact, wonContext)
  const lostBreakdown = computeImpactPointBreakdown(fact, lostContext)
  const mvpBreakdown = applyMvpBonusToImpactBreakdown(wonBreakdown)

  assert.equal(
    wonBreakdown.totalImpactPoints - lostBreakdown.totalImpactPoints,
    wonBreakdown.winBonusPoints,
  )
  assert.equal(wonBreakdown.winBonusPoints, IMPACT_POINT_RULES.bonuses.teamWinPoints)
  assert.equal(
    mvpBreakdown.totalImpactPoints,
    Math.min(IMPACT_POINT_RULES.maxImpactPoints, wonBreakdown.totalImpactPoints + IMPACT_POINT_RULES.bonuses.mvpPoints),
  )
  assert.equal(mvpBreakdown.mvpBonusPoints, IMPACT_POINT_RULES.bonuses.mvpPoints)
})

test('pass users keep identical impact points and receive boosted season points only', () => {
  const fact = makeFact({
    didBowl: true,
    ballsBowled: 24,
    oversBowled: 4,
    wickets: 3,
    runsConceded: 20,
    dotBalls: 12,
  })
  const context = makeContext()

  const withoutPass = computeMatchIndexes({
    fact,
    context,
    recentGameInfluence: [64, 67],
    passMultiplier: 1,
  })
  const withPass = computeMatchIndexes({
    fact,
    context,
    recentGameInfluence: [64, 67],
    passMultiplier: 2,
  })

  assert.equal(withoutPass.impactPoints, withPass.impactPoints)
  assert.equal(withPass.seasonPoints, withoutPass.seasonPoints * 2)
})

test('rank progression resolves from impact points only, not from season point boosts', () => {
  const fact = makeFact({
    didBowl: true,
    ballsBowled: 24,
    oversBowled: 4,
    wickets: 2,
    runsConceded: 21,
    dotBalls: 10,
  })
  const context = makeContext()

  const withoutPass = computeMatchIndexes({
    fact,
    context,
    recentGameInfluence: [58, 60, 63],
    passMultiplier: 1,
  })
  const withPass = computeMatchIndexes({
    fact,
    context,
    recentGameInfluence: [58, 60, 63],
    passMultiplier: 3,
  })

  const baseImpactPoints = 5590
  const rankWithoutPass = resolveRankFromImpactPoints(baseImpactPoints + withoutPass.impactPoints)
  const rankWithPass = resolveRankFromImpactPoints(baseImpactPoints + withPass.impactPoints)

  assert.equal(rankWithoutPass.label, rankWithPass.label)
  assert.equal(rankWithoutPass.label, 'Dominion II')
  assert.notEqual(withPass.seasonPoints, withoutPass.seasonPoints)
})

test('physical index can be computed from match proxy signals without wearable data', () => {
  const fact = makeFact({
    didBat: false,
    ballsFaced: 0,
    runs: 0,
    didBowl: true,
    ballsBowled: 30,
    oversBowled: 5,
    wickets: 2,
    runsConceded: 24,
    dotBalls: 15,
    fieldTimeSeconds: 5400,
    oversFielded: 20,
    catches: 1,
  })

  const proxy = computePhysicalProxy(fact)
  const context: CompetitiveContext = { 
    matchFormat: fact.matchFormat, 
    opponentWickets: 10, 
    teamWon: true, 
    closeMatch: false, 
    chaseMatch: false,
    teamRuns: 150,
    teamWickets: 5,
    opponentRuns: 120,
    playersInMatch: 22,
    targetRuns: null
  }
  assert.ok(proxy.workload >= 70)
  assert.ok((proxy.movement ?? 0) >= 90)
})
