import assert from 'node:assert/strict'
import test from 'node:test'
import type { BallEvent } from '@swing/db'

import { MatchService } from './match.service'
import {
  batterRunsFromBall,
  bowlerRunsConcededFromBall,
  dismissalChoicesForDelivery,
  isBowlerCreditedWicket,
  isDismissalValidForDelivery,
  normalizeWagonZone,
  resolveBallSelections,
  WAGON_WHEEL_ZONES,
  validateBallShape,
  nextBallIsFreeHit,
  validateBallAgainstInningsState,
} from './scoring-rules'
import { buildInningsPlayerStats } from './match-stats'

type TestBall = Pick<
  BallEvent,
  | 'batterId'
  | 'bowlerId'
  | 'fielderId'
  | 'outcome'
  | 'runs'
  | 'extras'
  | 'totalRuns'
  | 'isWicket'
  | 'dismissalType'
  | 'dismissedPlayerId'
> & {
  id: string
  nonBatterId: string
  overNumber: number
  ballNumber: number
  scoredAt: Date
  tags: string[]
}

function ball(overrides: Partial<TestBall> = {}): TestBall {
  return {
    id: `ball-${Math.random()}`,
    batterId: 'bat-1',
    nonBatterId: 'bat-2',
    bowlerId: 'bowl-1',
    outcome: 'DOT',
    runs: 0,
    extras: 0,
    totalRuns: 0,
    isWicket: false,
    dismissalType: null,
    dismissedPlayerId: null,
    fielderId: null,
    overNumber: 0,
    ballNumber: 1,
    scoredAt: new Date('2026-04-01T10:00:00.000Z'),
    tags: [],
    ...overrides,
  }
}

test('free hit wicket rules only allow run out, obstructing field, and hit ball twice', () => {
  assert.equal(
    isDismissalValidForDelivery({
      outcome: 'WICKET',
      dismissalType: 'CAUGHT',
      isFreeHit: true,
    }),
    false,
  )
  assert.equal(
    isDismissalValidForDelivery({
      outcome: 'WICKET',
      dismissalType: 'BOWLED',
      isFreeHit: true,
    }),
    false,
  )
  assert.equal(
    isDismissalValidForDelivery({
      outcome: 'WICKET',
      dismissalType: 'RUN_OUT',
      isFreeHit: true,
    }),
    true,
  )
  assert.deepEqual(dismissalChoicesForDelivery({ outcome: 'WICKET', isFreeHit: true }), [
    'RUN_OUT',
    'OBSTRUCTING_FIELD',
    'HIT_BALL_TWICE',
  ])
})

test('wide dismissal matrix allows stumped and run out but not bowled', () => {
  assert.equal(
    isDismissalValidForDelivery({
      outcome: 'WIDE',
      dismissalType: 'STUMPED',
      isFreeHit: false,
    }),
    true,
  )
  assert.equal(
    isDismissalValidForDelivery({
      outcome: 'WIDE',
      dismissalType: 'RUN_OUT',
      isFreeHit: false,
    }),
    true,
  )
  assert.equal(
    isDismissalValidForDelivery({
      outcome: 'WIDE',
      dismissalType: 'BOWLED',
      isFreeHit: false,
    }),
    false,
  )
  assert.equal(
    isDismissalValidForDelivery({
      outcome: 'WIDE',
      dismissalType: 'CAUGHT_BEHIND',
      isFreeHit: false,
    }),
    false,
  )
})

test('no-ball dismissal matrix allows run out but blocks caught and stumped', () => {
  assert.equal(
    isDismissalValidForDelivery({
      outcome: 'NO_BALL',
      dismissalType: 'CAUGHT',
      isFreeHit: false,
    }),
    false,
  )
  assert.equal(
    isDismissalValidForDelivery({
      outcome: 'NO_BALL',
      dismissalType: 'RUN_OUT',
      isFreeHit: false,
    }),
    true,
  )
  assert.equal(
    isDismissalValidForDelivery({
      outcome: 'NO_BALL',
      dismissalType: 'STUMPED',
      isFreeHit: false,
    }),
    false,
  )
})

test('bye and leg-bye dismissal matrix allows run out and hit wicket but blocks bowled', () => {
  assert.equal(
    isDismissalValidForDelivery({
      outcome: 'BYE',
      dismissalType: 'RUN_OUT',
      isFreeHit: false,
    }),
    true,
  )
  assert.equal(
    isDismissalValidForDelivery({
      outcome: 'LEG_BYE',
      dismissalType: 'HIT_WICKET',
      isFreeHit: false,
    }),
    true,
  )
  assert.equal(
    isDismissalValidForDelivery({
      outcome: 'BYE',
      dismissalType: 'BOWLED',
      isFreeHit: false,
    }),
    false,
  )
})

test('bowler conceded excludes byes and leg byes but includes wides and no-balls', () => {
  assert.equal(bowlerRunsConcededFromBall(ball({ outcome: 'BYE', extras: 2, totalRuns: 2 })), 0)
  assert.equal(bowlerRunsConcededFromBall(ball({ outcome: 'LEG_BYE', extras: 3, totalRuns: 3 })), 0)
  assert.equal(bowlerRunsConcededFromBall(ball({ outcome: 'WIDE', extras: 2, totalRuns: 2 })), 2)
  assert.equal(
    bowlerRunsConcededFromBall(ball({ outcome: 'NO_BALL', runs: 4, extras: 1, totalRuns: 5 })),
    5,
  )
})

test('overthrow attribution follows the submitted batter/extras split', () => {
  assert.equal(
    batterRunsFromBall(ball({ outcome: 'FOUR', runs: 6, extras: 0, totalRuns: 6 })),
    6,
  )
  assert.equal(
    batterRunsFromBall(ball({ outcome: 'NO_BALL', runs: 3, extras: 1, totalRuns: 4 })),
    3,
  )
  assert.equal(
    batterRunsFromBall(ball({ outcome: 'LEG_BYE', runs: 0, extras: 4, totalRuns: 4 })),
    0,
  )
  assert.equal(
    bowlerRunsConcededFromBall(ball({ outcome: 'FOUR', runs: 6, extras: 0, totalRuns: 6 })),
    6,
  )
})

test('caught behind and caught and bowled are normal-delivery dismissals credited to the bowler', () => {
  assert.equal(
    isDismissalValidForDelivery({
      outcome: 'WICKET',
      dismissalType: 'CAUGHT_BEHIND',
      isFreeHit: false,
    }),
    true,
  )
  assert.equal(
    isDismissalValidForDelivery({
      outcome: 'WICKET',
      dismissalType: 'CAUGHT_AND_BOWLED',
      isFreeHit: false,
    }),
    true,
  )
  assert.equal(isBowlerCreditedWicket('CAUGHT_BEHIND'), true)
  assert.equal(isBowlerCreditedWicket('CAUGHT_AND_BOWLED'), true)
})

test('build innings snapshot keeps over notation legal with wides and no-balls ignored for legal-ball count', () => {
  const service = new MatchService()
  const snapshot = service.buildInningsSnapshot([
    ball({ id: 'b1', overNumber: 0, ballNumber: 1, outcome: 'DOT' }),
    ball({ id: 'b2', overNumber: 0, ballNumber: 2, outcome: 'WIDE', extras: 1, totalRuns: 1 }),
    ball({ id: 'b3', overNumber: 0, ballNumber: 2, outcome: 'DOT' }),
    ball({ id: 'b4', overNumber: 0, ballNumber: 3, outcome: 'NO_BALL', extras: 1, runs: 1, totalRuns: 2 }),
    ball({ id: 'b5', overNumber: 0, ballNumber: 3, outcome: 'DOT' }),
    ball({ id: 'b6', overNumber: 0, ballNumber: 4, outcome: 'DOT' }),
    ball({ id: 'b7', overNumber: 0, ballNumber: 5, outcome: 'DOT' }),
    ball({ id: 'b8', overNumber: 0, ballNumber: 6, outcome: 'DOT' }),
    ball({ id: 'b9', overNumber: 1, ballNumber: 1, outcome: 'DOT' }),
  ])

  assert.equal(snapshot.legalBalls, 7)
  assert.equal(snapshot.totalOvers, 1.1)
})

test('over-limit protection blocks the 61st legal delivery in a 10-over innings', () => {
  assert.throws(
    () =>
      validateBallAgainstInningsState({
        currentLegalBalls: 60,
        maxLegalBalls: 60,
        currentWickets: 6,
        currentRuns: 147,
        ball: ball({ outcome: 'DOT' }),
      }),
    /legal-ball limit/,
  )
})

test('free hit remains active through a wide and ends after the next legal ball', () => {
  assert.equal(
    nextBallIsFreeHit({
      previousBallWasFreeHit: false,
      currentOutcome: 'NO_BALL',
    }),
    true,
  )
  assert.equal(
    nextBallIsFreeHit({
      previousBallWasFreeHit: true,
      currentOutcome: 'WIDE',
    }),
    true,
  )
  assert.equal(
    nextBallIsFreeHit({
      previousBallWasFreeHit: true,
      currentOutcome: 'DOT',
    }),
    false,
  )
})

test('retired hurt removes batter from active state without adding a wicket', () => {
  const service = new MatchService()
  const snapshot = service.buildInningsSnapshot([
    ball({
      id: 'retired-hurt',
      outcome: 'DOT',
      dismissalType: 'RETIRED_HURT',
      dismissedPlayerId: 'bat-1',
      isWicket: false,
    }),
  ])

  assert.equal(snapshot.totalWickets, 0)
  assert.equal(snapshot.legalBalls, 0)
  assert.equal(snapshot.currentStrikerId, null)
})

test('retired hurt cannot add runs or clear a pending free hit', () => {
  assert.throws(
    () =>
      validateBallShape(
        ball({
          outcome: 'DOT',
          dismissalType: 'RETIRED_HURT',
          isWicket: false,
          runs: 1,
        }),
      ),
    /cannot add runs or extras/,
  )

  assert.equal(
    nextBallIsFreeHit({
      previousBallWasFreeHit: true,
      currentOutcome: 'DOT',
      dismissalType: 'RETIRED_HURT',
    }),
    true,
  )
})

test('caught and bowled cannot assign a different fielder than the bowler', () => {
  assert.throws(
    () =>
      validateBallShape(
        ball({
          outcome: 'WICKET',
          isWicket: true,
          dismissalType: 'CAUGHT_AND_BOWLED',
          bowlerId: 'bowler-a',
          fielderId: 'fielder-b',
        }),
      ),
    /bowler as the fielder/,
  )
})

test('build innings snapshot replays by chronology instead of stale stored over numbers', () => {
  const service = new MatchService()
  const snapshot = service.buildInningsSnapshot([
    ball({
      id: 'first',
      overNumber: 3,
      ballNumber: 4,
      scoredAt: new Date('2026-04-01T10:00:00.000Z'),
      bowlerId: 'bowler-a',
      outcome: 'DOT',
    }),
    ball({
      id: 'second',
      overNumber: 0,
      ballNumber: 1,
      scoredAt: new Date('2026-04-01T10:00:01.000Z'),
      bowlerId: 'bowler-b',
      outcome: 'SINGLE',
      runs: 1,
      totalRuns: 1,
      batterId: 'bat-2',
      nonBatterId: 'bat-3',
    }),
  ])

  assert.equal(snapshot.legalBalls, 2)
  assert.equal(snapshot.currentBowlerId, 'bowler-b')
})

test('rebuilding stats from delivery history preserves the previous over bowler after an undo-like rollback', () => {
  const allBalls = [
    ball({ id: 'o1b1', overNumber: 0, ballNumber: 1, bowlerId: 'bowler-a', outcome: 'DOT' }),
    ball({ id: 'o1b2', overNumber: 0, ballNumber: 2, bowlerId: 'bowler-a', outcome: 'FOUR', runs: 4, totalRuns: 4 }),
    ball({ id: 'o1b3', overNumber: 0, ballNumber: 3, bowlerId: 'bowler-a', outcome: 'DOT' }),
    ball({ id: 'o1b4', overNumber: 0, ballNumber: 4, bowlerId: 'bowler-a', outcome: 'DOT' }),
    ball({ id: 'o1b5', overNumber: 0, ballNumber: 5, bowlerId: 'bowler-a', outcome: 'DOT' }),
    ball({ id: 'o1b6', overNumber: 0, ballNumber: 6, bowlerId: 'bowler-a', outcome: 'WICKET', isWicket: true, dismissalType: 'BOWLED', dismissedPlayerId: 'bat-1' }),
    ball({ id: 'o2b1', overNumber: 1, ballNumber: 1, bowlerId: 'bowler-b', batterId: 'bat-3', nonBatterId: 'bat-4', outcome: 'SINGLE', runs: 1, totalRuns: 1 }),
  ]

  const beforeUndo = buildInningsPlayerStats({
    battingTeam: 'A',
    balls: allBalls,
  })
  const afterUndo = buildInningsPlayerStats({
    battingTeam: 'A',
    balls: allBalls.slice(0, -1),
  })

  assert.deepEqual(beforeUndo.bowlerStats.get('bowler-a'), afterUndo.bowlerStats.get('bowler-a'))
  assert.equal(beforeUndo.bowlerStats.get('bowler-b')?.legalBalls, 1)
  assert.equal(afterUndo.bowlerStats.get('bowler-b'), undefined)
})

test('run out and obstructing field do not count as bowler wickets', () => {
  const stats = buildInningsPlayerStats({
    battingTeam: 'A',
    balls: [
      ball({
        id: 'run-out',
        outcome: 'WICKET',
        isWicket: true,
        dismissalType: 'RUN_OUT',
        dismissedPlayerId: 'bat-1',
      }),
      ball({
        id: 'obstruct',
        outcome: 'WICKET',
        isWicket: true,
        dismissalType: 'OBSTRUCTING_FIELD',
        dismissedPlayerId: 'bat-2',
      }),
      ball({
        id: 'bowled',
        outcome: 'WICKET',
        isWicket: true,
        dismissalType: 'BOWLED',
        dismissedPlayerId: 'bat-3',
        batterId: 'bat-3',
      }),
    ],
  })

  assert.equal(stats.bowlerStats.get('bowl-1')?.wickets, 1)
  assert.equal(isBowlerCreditedWicket('RUN_OUT'), false)
  assert.equal(isBowlerCreditedWicket('OBSTRUCTING_FIELD'), false)
  assert.equal(isBowlerCreditedWicket('BOWLED'), true)
})

test('resolveBallSelections carries non-striker from current innings state when omitted', () => {
  const resolved = resolveBallSelections({
    batterId: 'bat-1',
    nonBatterId: undefined,
    bowlerId: 'bowl-1',
    currentStrikerId: 'bat-1',
    currentNonStrikerId: 'bat-2',
    currentBowlerId: 'bowl-1',
  })

  assert.equal(resolved.batterId, 'bat-1')
  assert.equal(resolved.nonBatterId, 'bat-2')
  assert.equal(resolved.bowlerId, 'bowl-1')
})

test('resolveBallSelections supports post-runout replacement with one active prior batter', () => {
  const resolved = resolveBallSelections({
    batterId: 'bat-3',
    nonBatterId: undefined,
    bowlerId: 'bowl-2',
    currentStrikerId: 'bat-1',
    currentNonStrikerId: null,
    currentBowlerId: null,
  })

  assert.equal(resolved.batterId, 'bat-3')
  assert.equal(resolved.nonBatterId, 'bat-1')
  assert.equal(resolved.bowlerId, 'bowl-2')
})

test('wagon wheel zone normalization enforces 8 canonical segments', () => {
  assert.equal(WAGON_WHEEL_ZONES.length, 8)
  assert.equal(normalizeWagonZone('cover'), 'cover')
  assert.equal(normalizeWagonZone('zone:third-man'), 'third_man')
  assert.equal(normalizeWagonZone('mid off'), 'long_off')
  assert.equal(normalizeWagonZone('straight'), 'long_on')
  assert.equal(normalizeWagonZone('unknown-zone'), null)
})
