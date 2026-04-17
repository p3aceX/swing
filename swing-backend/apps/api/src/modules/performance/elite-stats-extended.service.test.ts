import assert from 'node:assert/strict'
import test from 'node:test'
import { prisma } from '@swing/db'
import { EliteStatsExtendedService } from './elite-stats-extended.service'

test('getStats120 keeps metrics nested and supports team-name winners for chase/defend', async () => {
  const service = new EliteStatsExtendedService()

  const originalPlayerProfileFindUnique = prisma.playerProfile.findUnique
  const originalMatchPlayerFactFindMany = prisma.matchPlayerFact.findMany
  const originalMatchPlayerIndexScoreFindMany = prisma.matchPlayerIndexScore.findMany
  const originalMatchFindMany = prisma.match.findMany
  const originalBallEventFindMany = prisma.ballEvent.findMany
  const originalInningsFindMany = prisma.innings.findMany

  ;(prisma.playerProfile.findUnique as any) = async () => ({ id: 'player-1' })
  ;(prisma.matchPlayerFact.findMany as any) = async () => []
  ;(prisma.matchPlayerIndexScore.findMany as any) = async () => [{ matchId: 'match-1', impactPoints: 50, isMvp: true }]
  ;(prisma.match.findMany as any) = async () => [
    {
      id: 'match-1',
      round: null,
      winnerId: 'Warriors',
      teamAName: 'Warriors',
      teamBName: 'Titans',
      completedAt: new Date('2026-03-20T10:00:00.000Z'),
      scheduledAt: new Date('2026-03-20T08:00:00.000Z'),
      teamAPlayerIds: ['player-1'],
      teamBPlayerIds: ['player-2'],
    },
  ]
  ;(prisma.ballEvent.findMany as any) = async () => []
  ;(prisma.innings.findMany as any) = async () => [{ matchId: 'match-1', inningsNumber: 1, battingTeam: 'Titans' }]

  try {
    const result = await service.getStats120('player-1')
    assert.ok(result)

    assert.equal((result as any).matchesPlayed, undefined)
    assert.equal((result as any).chaseWins, undefined)
    assert.ok(result!.metrics)
    assert.equal(result!.metrics.matchesPlayed, 1)
    assert.equal(result!.metrics.matchesWon, 1)
    assert.equal(result!.metrics.winPct, 100)
    assert.equal(result!.metrics.chaseMatches, 1)
    assert.equal(result!.metrics.chaseWins, 1)
    assert.equal(result!.metrics.defendMatches, 0)
    assert.equal(result!.metrics.defendWins, 0)
    assert.equal(result!.metricCount, Object.keys(result!.metrics).length)
  } finally {
    ;(prisma.playerProfile.findUnique as any) = originalPlayerProfileFindUnique
    ;(prisma.matchPlayerFact.findMany as any) = originalMatchPlayerFactFindMany
    ;(prisma.matchPlayerIndexScore.findMany as any) = originalMatchPlayerIndexScoreFindMany
    ;(prisma.match.findMany as any) = originalMatchFindMany
    ;(prisma.ballEvent.findMany as any) = originalBallEventFindMany
    ;(prisma.innings.findMany as any) = originalInningsFindMany
  }
})
