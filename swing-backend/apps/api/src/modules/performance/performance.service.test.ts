import assert from 'node:assert/strict'
import test from 'node:test'
import { prisma } from '@swing/db'
import { PerformanceService } from './performance.service'

test('snapshot aggregation updates last 5, last 10, season, and lifetime windows correctly', () => {
  const service = new PerformanceService() as any
  const activeSeason = {
    id: 'season-1',
    startAt: new Date('2026-03-03T00:00:00.000Z'),
    endAt: new Date('2026-04-30T23:59:59.999Z'),
  }

  const facts = Array.from({ length: 12 }, (_, index) => ({
    id: `fact-${index + 1}`,
    matchId: `match-${index + 1}`,
    playerId: 'player-1',
    matchDate: new Date(Date.UTC(2026, 2, index + 1)),
  }))

  const scoresByMatch = new Map(
    facts.map((fact, index) => [
      fact.matchId,
      {
        battingIndex: (index + 1) * 10,
        bowlingIndex: null,
        fieldingIndex: 40,
        consistencyContribution: 50,
        clutchIndex: 60,
        physicalIndex: 55,
        captaincyIndex: null,
        impactPoints: (index + 1) * 5,
        seasonPoints: (index + 1) * 10,
      },
    ]),
  )

  const snapshots = service.buildSnapshots(facts, new Map(), scoresByMatch, activeSeason) as Array<{
    snapshotType: string
    snapshotDate: Date
    battingIndex: number | null
    impactPoints: number | null
    seasonPoints: number | null
  }>

  const lastDate = facts[facts.length - 1].matchDate.getTime()
  const last5 = snapshots.find((item) => item.snapshotType === 'LAST_5' && item.snapshotDate.getTime() === lastDate)
  const last10 = snapshots.find((item) => item.snapshotType === 'LAST_10' && item.snapshotDate.getTime() === lastDate)
  const season = snapshots.find((item) => item.snapshotType === 'SEASON' && item.snapshotDate.getTime() === lastDate)
  const lifetime = snapshots.find((item) => item.snapshotType === 'LIFETIME' && item.snapshotDate.getTime() === lastDate)

  assert.equal(last5?.battingIndex, 100)
  assert.equal(last10?.battingIndex, 75)
  assert.equal(season?.battingIndex, 75)
  assert.equal(lifetime?.battingIndex, 65)
  assert.equal(lifetime?.impactPoints, 390)
  assert.equal(season?.seasonPoints, 750)
})

test('snapshot swingIndex uses role-aware weights so non-bowler role ignores bowling', () => {
  const service = new PerformanceService() as any
  const facts = Array.from({ length: 2 }, (_, index) => ({
    id: `fact-${index + 1}`,
    matchId: `match-${index + 1}`,
    playerId: 'player-1',
    matchDate: new Date(Date.UTC(2026, 2, index + 1)),
  }))

  const withNoBowling = new Map(
    facts.map((fact) => [
      fact.matchId,
      {
        battingIndex: 70,
        bowlingIndex: 50,
        fieldingIndex: 50,
        consistencyContribution: 50,
        clutchIndex: 60,
        physicalIndex: 50,
        captaincyIndex: null,
        impactPoints: 10,
        seasonPoints: 20,
      },
    ]),
  )

  const withBadBowling = new Map(
    facts.map((fact) => [
      fact.matchId,
      {
        battingIndex: 70,
        bowlingIndex: 0,
        fieldingIndex: 50,
        consistencyContribution: 50,
        clutchIndex: 60,
        physicalIndex: 50,
        captaincyIndex: null,
        impactPoints: 10,
        seasonPoints: 20,
      },
    ]),
  )

  const pureBatterWeights = { batting: 0.5, bowling: 0, fielding: 0.2, impact: 0.3 }
  const snapshotsNoBowling = service.buildSnapshots(facts, new Map(), withNoBowling, null, pureBatterWeights)
  const snapshotsBadBowling = service.buildSnapshots(facts, new Map(), withBadBowling, null, pureBatterWeights)

  const dateKey = facts[facts.length - 1].matchDate.getTime()
  const lifetimeNoBowling = snapshotsNoBowling.find((item: any) => item.snapshotType === 'LIFETIME' && item.snapshotDate.getTime() === dateKey)
  const lifetimeBadBowling = snapshotsBadBowling.find((item: any) => item.snapshotType === 'LIFETIME' && item.snapshotDate.getTime() === dateKey)

  assert.equal(lifetimeNoBowling?.swingIndex, lifetimeBadBowling?.swingIndex)
})

test('public profile summary exposes rank, division, swing index, and mvp count', async () => {
  const service = new PerformanceService() as any
  service.getPlayerStatsSummary = async () => ({
    competitive: {
      impactPoints: 4120,
      rank: 'Phantom I',
      rankKey: 'PHANTOM',
      division: 1,
      rankProgress: 120,
      rankProgressMax: 750,
      mvpCount: 6,
      matchesPlayed: 28,
    },
    season: {
      seasonId: 'season-1',
      seasonPoints: 820,
      passMultiplier: 2,
      seasonLeaderboardPosition: 5,
    },
    swingIndex: {
      currentSwingIndex: 71,
      battingIndex: 68,
      bowlingIndex: 73,
      fieldingIndex: 61,
      consistencyIndex: 69,
      clutchIndex: 66,
      physicalIndex: 64,
      captaincyIndex: null,
    },
  })

  const summary = await service.getPublicProfileSummary('player-1')

  assert.deepEqual(summary, {
    rank: 'Phantom I',
    rankKey: 'PHANTOM',
    division: 1,
    lifetimeImpactPoints: 4120,
    currentSwingIndex: 71,
    mvpCount: 6,
    selectedDisplayedMetrics: {
      battingIndex: 68,
      bowlingIndex: 73,
      fieldingIndex: 61,
      clutchIndex: 66,
    },
  })
})

test('player stats summary prefers Swing v2 persisted score when available', async () => {
  const service = new PerformanceService() as any
  const originalMatchFactCount = prisma.matchPlayerFact.count

  service.readIpPlayerState = async () => ({
    playerId: 'player-1',
    lifetimeIp: 1200,
    currentRankKey: 'ROOKIE',
    currentDivision: 2,
    rankProgressPoints: 150,
    currentDivisionFloor: 0,
    winStreak: 0,
    mvpCount: 3,
    lastRankedMatchAt: null,
    currentSeasonId: null,
    createdAt: new Date(),
    updatedAt: new Date(),
  })
  service.readSwingPlayerState = async () => ({
    playerId: 'player-1',
    formulaVersion: 'swing-index-v2',
    overallScore: 78.4,
    batScore: 65,
    bowlScore: 70,
    fieldingImpact: 58,
    powerScore: 61,
    impactScore: 66,
    axes: {},
    subScores: {},
    derivedMetrics: {},
    weightingMeta: {},
    sourceStatsVersion: null,
    sourceStatsComputedAt: null,
    computedAt: new Date(),
    updatedAt: new Date(),
  })
  service.readPlayerStatOverall = async () => ({
    playerId: 'player-1',
    matchesPlayed: 12,
    matchesWon: 8,
    mvpCount: 3,
    consistencyIndex: 62,
    computedAt: new Date(),
  })
  ;(prisma.matchPlayerFact.count as any) = async () => 12

  service.getActiveSeason = async () => null
  service.getCurrentSeasonProgress = async () => null
  service.getCurrentPassMultiplierForPlayer = async () => 1

  try {
    const stats = await service.getPlayerStatsSummary('player-1')
    assert.equal(stats.swingIndex.currentSwingIndex, 78.4)
  } finally {
    ;(prisma.matchPlayerFact.count as any) = originalMatchFactCount
  }
})
