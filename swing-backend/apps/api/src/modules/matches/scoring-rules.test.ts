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
  validateImpactPlayerSwap,
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

test('bowler conceded: only the 1-run wide / NB penalty + bat runs', () => {
  // Byes / leg-byes — never charged to the bowler.
  assert.equal(bowlerRunsConcededFromBall(ball({ outcome: 'BYE', extras: 2, totalRuns: 2 })), 0)
  assert.equal(bowlerRunsConcededFromBall(ball({ outcome: 'LEG_BYE', extras: 3, totalRuns: 3 })), 0)
  // Wide: always exactly 1 to the bowler. Extras beyond the 1 wide
  // penalty are byes off the wide and don't inflate bowler figures.
  assert.equal(bowlerRunsConcededFromBall(ball({ outcome: 'WIDE', extras: 1, totalRuns: 1 })), 1)
  assert.equal(bowlerRunsConcededFromBall(ball({ outcome: 'WIDE', extras: 3, totalRuns: 3 })), 1)
  // No-ball OFF THE BAT: 1 NB penalty + bat runs.
  assert.equal(
    bowlerRunsConcededFromBall(ball({ outcome: 'NO_BALL', runs: 4, extras: 1, totalRuns: 5 })),
    5,
  )
  // No-ball BYE / LEG_BYE: only the 1 NB penalty — byes don't go to bowler.
  assert.equal(
    bowlerRunsConcededFromBall(
      ball({ outcome: 'NO_BALL', runs: 0, extras: 3, totalRuns: 3, tags: ['no_ball_extra:bye:2'] }),
    ),
    1,
  )
  assert.equal(
    bowlerRunsConcededFromBall(
      ball({ outcome: 'NO_BALL', runs: 0, extras: 4, totalRuns: 4, tags: ['no_ball_extra:leg_bye:3'] }),
    ),
    1,
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

// ─── Super Over caps ────────────────────────────────────────────────────────

test('super over caps wickets at 2 instead of 10', () => {
  assert.throws(
    () =>
      validateBallAgainstInningsState({
        currentLegalBalls: 3,
        maxLegalBalls: 6,
        currentWickets: 2,
        maxWickets: 2,
        currentRuns: 14,
        ball: ball({ outcome: 'DOT' }),
      }),
    /all out/,
  )

  // 1 wicket and 5 legal balls should still allow one more delivery.
  assert.doesNotThrow(() =>
    validateBallAgainstInningsState({
      currentLegalBalls: 5,
      maxLegalBalls: 6,
      currentWickets: 1,
      maxWickets: 2,
      currentRuns: 12,
      ball: ball({ outcome: 'SINGLE', runs: 1 }),
    }),
  )
})

test('super over caps legal deliveries at 6 (one over per side)', () => {
  assert.throws(
    () =>
      validateBallAgainstInningsState({
        currentLegalBalls: 6,
        maxLegalBalls: 6,
        currentWickets: 0,
        maxWickets: 2,
        currentRuns: 8,
        ball: ball({ outcome: 'DOT' }),
      }),
    /legal-ball limit/,
  )
})

test('super over allows wides mid-over without increasing the legal-ball count', () => {
  // 5 legal balls bowled, 6 max. A WIDE is not a legal delivery, so it
  // should not be rejected as "would exceed the legal-ball limit".
  assert.doesNotThrow(() =>
    validateBallAgainstInningsState({
      currentLegalBalls: 5,
      maxLegalBalls: 6,
      currentWickets: 0,
      maxWickets: 2,
      currentRuns: 7,
      ball: ball({ outcome: 'WIDE', extras: 1 }),
    }),
  )
})

test('super over chase ends the moment the target is reached', () => {
  assert.throws(
    () =>
      validateBallAgainstInningsState({
        currentLegalBalls: 3,
        maxLegalBalls: 6,
        currentWickets: 0,
        maxWickets: 2,
        currentRuns: 15,
        targetRuns: 15,
        ball: ball({ outcome: 'SINGLE', runs: 1 }),
      }),
    /chase is already complete/,
  )
})

// ─── Extras breakdown ──────────────────────────────────────────────────────

test('innings snapshot tracks wides, no-balls, byes, and leg-byes separately', () => {
  const service = new MatchService()
  const snapshot = service.buildInningsSnapshot([
    ball({ id: 'w1', outcome: 'WIDE', extras: 2 }),
    ball({ id: 'n1', outcome: 'NO_BALL', runs: 0, extras: 1 }),
    ball({ id: 'b1', outcome: 'BYE', extras: 4 }),
    ball({ id: 'lb1', outcome: 'LEG_BYE', extras: 1 }),
  ])

  assert.equal(snapshot.extras, 8)
  assert.deepEqual(snapshot.extrasBreakdown, {
    wides: 2,
    noBalls: 1,
    byes: 4,
    legByes: 1,
    penalty: 0,
  })
})

// ─── Impact Player swap validation ─────────────────────────────────────────

type _SwapArgs = Parameters<typeof validateImpactPlayerSwap>[0]
const baseSwap = (overrides: Partial<_SwapArgs> = {}): _SwapArgs => ({
  hasImpactPlayer: true,
  matchStatus: 'IN_PROGRESS',
  maxOversPerSide: 20,
  alreadyUsed: false,
  namedSubs: ['sub-1', 'sub-2', 'sub-3', 'sub-4'],
  xi: ['p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7', 'p8', 'p9', 'p10', 'p11'],
  outgoingPlayerId: 'p11',
  incomingPlayerId: 'sub-1',
  liveInnings: {
    legalBalls: 6, // start of new over
    lastBallWasWicket: false,
    strikerId: 'p1',
    nonStrikerId: 'p2',
  },
  ...overrides,
})

test('impact player swap is rejected when the rule is off', () => {
  assert.throws(
    () => validateImpactPlayerSwap(baseSwap({ hasImpactPlayer: false })),
    /IMPACT_PLAYER_DISABLED/,
  )
})

test('impact player swap is rejected when match is not in progress', () => {
  assert.throws(
    () => validateImpactPlayerSwap(baseSwap({ matchStatus: 'SCHEDULED' })),
    /MATCH_NOT_IN_PROGRESS/,
  )
  assert.throws(
    () => validateImpactPlayerSwap(baseSwap({ matchStatus: 'COMPLETED' })),
    /MATCH_NOT_IN_PROGRESS/,
  )
})

test('impact player swap is suspended under 10 overs per side', () => {
  assert.throws(
    () => validateImpactPlayerSwap(baseSwap({ maxOversPerSide: 6 })),
    /IMPACT_PLAYER_NOT_ALLOWED_UNDER_10_OVERS/,
  )
  // Exactly 10 overs is allowed.
  assert.doesNotThrow(() =>
    validateImpactPlayerSwap(baseSwap({ maxOversPerSide: 10 })),
  )
})

test('each team can only use the Impact Player substitution once', () => {
  assert.throws(
    () => validateImpactPlayerSwap(baseSwap({ alreadyUsed: true })),
    /IMPACT_PLAYER_ALREADY_USED/,
  )
})

test('incoming player must be in the pre-declared named-4 list', () => {
  assert.throws(
    () =>
      validateImpactPlayerSwap(
        baseSwap({ incomingPlayerId: 'random-not-named' }),
      ),
    /IMPACT_PLAYER_NOT_NAMED/,
  )
})

test('outgoing player must be in the current XI', () => {
  assert.throws(
    () =>
      validateImpactPlayerSwap(
        baseSwap({ outgoingPlayerId: 'someone-else' }),
      ),
    /IMPACT_PLAYER_OUTGOING_INVALID/,
  )
})

test('incoming player cannot already be in the XI', () => {
  assert.throws(
    () =>
      validateImpactPlayerSwap(
        baseSwap({
          namedSubs: ['p3'],
          incomingPlayerId: 'p3',
        }),
      ),
    /IMPACT_PLAYER_DUPLICATE/,
  )
})

test('swap window is start-of-over OR fall-of-wicket', () => {
  // Mid-over, no wicket — rejected.
  assert.throws(
    () =>
      validateImpactPlayerSwap(
        baseSwap({
          liveInnings: {
            legalBalls: 3,
            lastBallWasWicket: false,
            strikerId: 'p1',
            nonStrikerId: 'p2',
          },
        }),
      ),
    /IMPACT_PLAYER_WINDOW/,
  )

  // Mid-over, BUT last ball was a wicket — allowed.
  assert.doesNotThrow(() =>
    validateImpactPlayerSwap(
      baseSwap({
        liveInnings: {
          legalBalls: 3,
          lastBallWasWicket: true,
          strikerId: 'p1',
          nonStrikerId: 'p2',
        },
      }),
    ),
  )

  // Start of over (legalBalls multiple of 6) — allowed.
  assert.doesNotThrow(() =>
    validateImpactPlayerSwap(
      baseSwap({
        liveInnings: {
          legalBalls: 12,
          lastBallWasWicket: false,
          strikerId: 'p1',
          nonStrikerId: 'p2',
        },
      }),
    ),
  )
})

test('outgoing player cannot be at the crease', () => {
  assert.throws(
    () =>
      validateImpactPlayerSwap(
        baseSwap({
          outgoingPlayerId: 'p1', // currently striking
        }),
      ),
    /IMPACT_PLAYER_OUTGOING_ACTIVE/,
  )
  assert.throws(
    () =>
      validateImpactPlayerSwap(
        baseSwap({
          outgoingPlayerId: 'p2', // currently non-striker
        }),
      ),
    /IMPACT_PLAYER_OUTGOING_ACTIVE/,
  )
})

test('no live innings (between innings) treats the swap as start-of-over', () => {
  // Mid-over check is skipped when there's no live innings.
  assert.doesNotThrow(() =>
    validateImpactPlayerSwap(
      baseSwap({
        liveInnings: null,
      }),
    ),
  )
})

test('no-ball with a bye tag splits the extras between NB and B', () => {
  const service = new MatchService()
  const snapshot = service.buildInningsSnapshot([
    ball({
      id: 'nb-bye',
      outcome: 'NO_BALL',
      runs: 0,
      extras: 3, // 1 no-ball + 2 byes
      tags: ['no_ball_extra:bye:2'],
    }),
  ])

  assert.equal(snapshot.extrasBreakdown.noBalls, 1)
  assert.equal(snapshot.extrasBreakdown.byes, 2)
  assert.equal(snapshot.extrasBreakdown.legByes, 0)
})
