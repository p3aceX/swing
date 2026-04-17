import assert from 'node:assert/strict'
import test from 'node:test'
import { prisma } from '@swing/db'
import { PerformanceService } from './performance.service'

test('recalculateSwingIndexV2ForPlayer persists computed score', async () => {
  const service = new PerformanceService() as any
  let persisted: { playerId: string; score: number } | null = null

  service.computeSwingIndexV2Artifacts = async () => ({
    stats120: {
      generatedAt: new Date('2026-04-11T00:00:00.000Z').toISOString(),
    },
    detailed: {
      playerId: 'player-1',
      formulaVersion: 'swing-index-v2',
      swingIndexScore: 78.4,
      composites: { BAT: 74.1, BOWL: 68.9, FI: 61.2, PW: 81.7, IMP: 76.0 },
      axes: {
        reliabilityAxis: 72.5,
        powerAxis: 81.7,
        bowlingAxis: 67.4,
        fieldingAxis: 61.2,
        impactAxis: 76.0,
      },
      subScores: {
        BR: 72,
        BE: 70,
        PW: 82,
        BV: 71,
        BC: 64,
        BT: 73,
        PB: 66,
        FI: 61,
        WI: 77,
        RF: 74,
        CS: 69,
      },
      derivedMetrics: {
        sixesPerInnings: 1.2,
        widesPerOver: 0.2,
        noBallsPerOver: 0.02,
        wicketRate: 0.08,
        bowledLbwPct: 0.41,
        chaseWinPct: 0.52,
        defendWinPct: 0.55,
        mvpRate: 0.18,
        dismissalInvolvementRate: 1.1,
      },
      rawMetrics: {},
      weightingMeta: { excludedSections: [], renormalized: false, details: {} },
    },
    summary: {
      playerId: 'player-1',
      formulaVersion: 'swing-index-v2',
      swingIndexScore: 78.4,
      axes: {
        reliabilityAxis: 72.5,
        powerAxis: 81.7,
        bowlingAxis: 67.4,
        fieldingAxis: 61.2,
        impactAxis: 76.0,
      },
      strengths: [{ key: 'powerAxis', score: 81.7 }],
      weakestAreas: [{ key: 'fieldingAxis', score: 61.2 }],
      explanation: {
        headline: 'powerAxis is currently leading the profile',
        detail: 'The biggest improvement opportunity is fieldingAxis.',
      },
    },
  })

  service.persistSwingIndexV2 = async (playerId: string, detailed: { swingIndexScore: number }) => {
    persisted = { playerId, score: detailed.swingIndexScore }
  }

  const result = await service.recalculateSwingIndexV2ForPlayer('player-1')
  assert.equal(result.updated, true)
  assert.equal(result.formulaVersion, 'swing-index-v2')
  assert.deepEqual(persisted, { playerId: 'player-1', score: 78.4 })
})

test('backfillSwingIndexV2 scans batches and reports failures', async () => {
  const service = new PerformanceService() as any
  const originalFindMany = prisma.playerProfile.findMany
  let calls = 0

  ;(prisma.playerProfile.findMany as any) = async () => {
    calls += 1
    if (calls === 1) return [{ id: 'player-a' }, { id: 'player-b' }]
    if (calls === 2) return [{ id: 'player-c' }]
    return []
  }

  service.recalculateSwingIndexV2ForPlayer = async (playerId: string) => {
    if (playerId === 'player-b') {
      return { playerId, updated: false, reason: 'PLAYER_NOT_FOUND' as const }
    }
    return { playerId, updated: true, swingIndexScore: 70, formulaVersion: 'swing-index-v2' }
  }

  try {
    const result = await service.backfillSwingIndexV2({ batchSize: 2 })
    assert.equal(result.formulaVersion, 'swing-index-v2')
    assert.equal(result.scanned, 3)
    assert.equal(result.updated, 2)
    assert.equal(result.failed, 1)
    assert.equal(result.failures[0]?.playerId, 'player-b')
  } finally {
    ;(prisma.playerProfile.findMany as any) = originalFindMany
  }
})
