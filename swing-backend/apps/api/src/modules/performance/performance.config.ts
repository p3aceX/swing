import type { CompetitiveRankTierConfig } from '@swing/types'

// ============================================================
// COMPETITIVE RANK TIERS
// IP = Impact Points — the only currency. Rank goes UP and DOWN.
// lifetimeImpactPoints never decreases (career legacy).
// rankProgressPoints drives current rank — can go negative → demote.
// ============================================================

export const COMPETITIVE_RANK_CONFIG: CompetitiveRankTierConfig[] = [
  {
    key: 'ROOKIE',
    label: 'Rookie',
    divisions: [
      { division: 3, threshold: 0,   label: 'Rookie III' },
      { division: 2, threshold: 100, label: 'Rookie II'  },
      { division: 1, threshold: 250, label: 'Rookie I'   },
    ],
  },
  {
    key: 'STRIKER',
    label: 'Striker',
    divisions: [
      { division: 3, threshold: 450,  label: 'Striker III' },
      { division: 2, threshold: 700,  label: 'Striker II'  },
      { division: 1, threshold: 1000, label: 'Striker I'   },
    ],
  },
  {
    key: 'VANGUARD',
    label: 'Vanguard',
    divisions: [
      { division: 3, threshold: 1350, label: 'Vanguard III' },
      { division: 2, threshold: 1750, label: 'Vanguard II'  },
      { division: 1, threshold: 2200, label: 'Vanguard I'   },
    ],
  },
  {
    key: 'PHANTOM',
    label: 'Phantom',
    divisions: [
      { division: 3, threshold: 2750, label: 'Phantom III' },
      { division: 2, threshold: 3350, label: 'Phantom II'  },
      { division: 1, threshold: 4000, label: 'Phantom I'   },
    ],
  },
  {
    key: 'DOMINION',
    label: 'Dominion',
    divisions: [
      { division: 3, threshold: 4750, label: 'Dominion III' },
      { division: 2, threshold: 5600, label: 'Dominion II'  },
      { division: 1, threshold: 6500, label: 'Dominion I'   },
    ],
  },
  {
    key: 'ASCENDANT',
    label: 'Ascendant',
    divisions: [
      { division: 3, threshold: 7500, label: 'Ascendant III' },
      { division: 2, threshold: 8600, label: 'Ascendant II'  },
      { division: 1, threshold: 9800, label: 'Ascendant I'   },
    ],
  },
  {
    key: 'IMMORTAL',
    label: 'Immortal',
    divisions: [
      { division: 3, threshold: 11100, label: 'Immortal III' },
      { division: 2, threshold: 12500, label: 'Immortal II'  },
      { division: 1, threshold: 14000, label: 'Immortal I'   },
    ],
  },
  {
    key: 'APEX',
    label: 'Apex',
    divisions: [
      { division: 1, threshold: 16000, label: 'Apex' },
    ],
  },
]

export const COMPETITIVE_SEASON_MILESTONES = [100, 250, 500, 1000, 2000, 3500] as const

// ============================================================
// FORMAT MULTIPLIERS
// Longer formats reward more IP — a 5W in a Test match > a T10 5W.
// ============================================================

export const FORMAT_IP_MULTIPLIER: Record<string, number> = {
  T10:          0.7,
  BOX_CRICKET:  0.8,
  T20:          1.0,
  CUSTOM:       1.0,
  ONE_DAY:      1.3,
  TWO_INNINGS:  1.6,
  TEST:         1.8,
}

// ============================================================
// FORMAT BASELINES
// All SR/economy bonuses and penalties are relative to these.
// ============================================================

export const MATCH_FORMAT_BASELINES: Record<string, {
  expectedTeamRuns:   number
  strongStrikeRate:   number
  baselineStrikeRate: number
  baselineEconomy:    number
  strongEconomy:      number
  strongBallsPerWicket: number
}> = {
  T10: {
    expectedTeamRuns:     110,
    strongStrikeRate:     165,
    baselineStrikeRate:   125,
    baselineEconomy:      9.4,
    strongEconomy:        6.6,
    strongBallsPerWicket: 12,
  },
  T20: {
    expectedTeamRuns:     155,
    strongStrikeRate:     150,
    baselineStrikeRate:   120,
    baselineEconomy:      8.1,
    strongEconomy:        6.2,
    strongBallsPerWicket: 16,
  },
  ONE_DAY: {
    expectedTeamRuns:     260,
    strongStrikeRate:     110,
    baselineStrikeRate:   88,
    baselineEconomy:      5.8,
    strongEconomy:        4.2,
    strongBallsPerWicket: 24,
  },
  TWO_INNINGS: {
    expectedTeamRuns:     320,
    strongStrikeRate:     72,
    baselineStrikeRate:   56,
    baselineEconomy:      3.9,
    strongEconomy:        2.9,
    strongBallsPerWicket: 36,
  },
  TEST: {
    expectedTeamRuns:     320,
    strongStrikeRate:     72,
    baselineStrikeRate:   56,
    baselineEconomy:      3.9,
    strongEconomy:        2.9,
    strongBallsPerWicket: 36,
  },
  BOX_CRICKET: {
    expectedTeamRuns:     85,
    strongStrikeRate:     170,
    baselineStrikeRate:   130,
    baselineEconomy:      10.5,
    strongEconomy:        7.5,
    strongBallsPerWicket: 10,
  },
  CUSTOM: {
    expectedTeamRuns:     140,
    strongStrikeRate:     145,
    baselineStrikeRate:   115,
    baselineEconomy:      8.0,
    strongEconomy:        6.0,
    strongBallsPerWicket: 16,
  },
}

// ============================================================
// IP RULES
// Every value here is BEFORE applying the format multiplier.
// ============================================================

export const IP_RULES = {

  // ── PLAYING ──────────────────────────────────────────────
  playingBonus: 10,           // just being in the XI

  // ── BATTING ──────────────────────────────────────────────
  batting: {
    perRun:   1,              // +1 IP per run scored
    perFour:  1,              // +1 IP per boundary
    perSix:   2,              // +2 IP per six

    // Minimum balls faced before SR adjustment kicks in.
    // Protects number 11 batters / pinch hitters.
    minBallsForSrAdjustment: 8,

    // Strike rate bonus (linear scale between baseline → strong)
    srBonus: {
      aboveStrong: 25,        // SR ≥ strongStrikeRate  → +25 IP
      atBaseline:   0,        // SR = baselineStrikeRate → 0
    },

    // Strike rate penalties — tiered, absolute SR thresholds
    // Applied when balls faced ≥ minBallsForSrAdjustment
    srPenalty: {
      below50:          -35,  // SR < 50   — dead weight, blocking crease
      below70:          -22,  // SR 50-69  — very slow, hurts team scoring
      belowBaselinePct: {
        seventyPct:     -14,  // SR < 70% of baseline (e.g. <84 in T20)
        eightyFivePct:   -7,  // SR < 85% of baseline (e.g. <102 in T20)
      },
    },

    // Milestone bonuses
    milestones: {
      fifty:    15,
      hundred:  35,
      oneFifty: 60,
    },

    // Penalties
    duck:       -12,          // out for 0 — embarrassing, costs the team
    goldenDuck: -20,          // out first ball for 0 — worst outcome
  },

  // ── BOWLING ──────────────────────────────────────────────
  bowling: {
    perWicket:  18,           // +18 IP per wicket
    perDotBall:  1,           // +1 IP per dot ball
    perMaiden:   8,           // +8 IP per maiden over

    // Minimum legal balls bowled before economy adjustment kicks in.
    minBallsForEconAdjustment: 12,

    // Economy bonus (linear scale)
    econBonus: {
      belowStrong: 25,        // economy ≤ strongEconomy  → +25 IP
      atBaseline:   0,        // economy = baselineEconomy → 0
    },

    // Economy penalties — tiered, absolute economy thresholds
    // Applied when legal balls ≥ minBallsForEconAdjustment
    econPenalty: {
      above12:         -35,   // economy > 12 — getting smashed every over
      above10:         -22,   // economy 10-12 — very expensive
      above8:          -12,   // economy 8-10 — clearly above par
      aboveBaselinePct: {
        tenPctAbove:    -6,   // economy 0-10% above baseline
      },
    },

    // Haul bonuses (on top of perWicket)
    hauls: {
      threeWickets: 15,
      fiveWickets:  30,
      tenWickets:   50,       // match haul (Test)
    },
  },

  // ── FIELDING ─────────────────────────────────────────────
  fielding: {
    perCatch:    8,
    perRunOut:   10,
    perStumping: 10,
  },

  // ── MATCH RESULT ─────────────────────────────────────────
  result: {
    win:      15,             // team wins  → +15 IP (increased from 10)
    loss:    -15,             // team loses → -15 IP (increased from -5, makes rank meaningful)
    tie:       5,             // draw is still a decent result
    noResult:  0,
  },

  // ── MVP ──────────────────────────────────────────────────
  mvpBonus: 50,

  // ── CAPS ─────────────────────────────────────────────────
  maxIpPerMatch:  200,        // a single match can't give more than 200 IP
  minIpPerMatch:  -60,        // a terrible match can cost up to 60 IP

} as const

// ============================================================
// RANK DECAY
// Inactive players slowly lose rankProgressPoints.
// lifetimeImpactPoints is never affected.
// ============================================================

export const RANK_DECAY = {
  inactiveDaysThreshold: 60,  // no ranked match for 60 days → decay starts
  weeklyDecayPercent:    2,    // lose 2% of rankProgressPoints per week
  minimumRankProgress:   0,   // can't decay below 0 (ROOKIE III floor)
} as const

// ============================================================
// TEAM POWER SCORE
// Weighted average IP of the 11 players.
// Top 6 counted at 60%, bottom 5 at 40%.
// ============================================================

export const TEAM_POWER_SCORE = {
  topPlayersCount:   6,
  topPlayersWeight:  0.6,
  tailPlayersWeight: 0.4,
} as const

// ============================================================
// MATCHMAKING TOLERANCE
// ±15% power score range for fair matchmaking.
// ============================================================

export const MATCHMAKING_POWER_TOLERANCE_PCT = 15

// ============================================================
// SWING INDEX WEIGHTS (diagnostic, not rank)
// ============================================================

export const SWING_INDEX_WEIGHTS = {
  batting:     0.24,
  bowling:     0.24,
  fielding:    0.14,
  consistency: 0.12,
  clutch:      0.12,
  physical:    0.10,
  captaincy:   0.04,
} as const

export const DEFAULT_PLAYER_PASS_MULTIPLIER = Number(process.env.SWING_PASS_SP_MULTIPLIER ?? 2)
export const DAILY_FIELD_SECONDS_PER_LEGAL_BALL = 40

// ============================================================
// BACKWARDS-COMPAT ALIAS
// performance.calculations.ts uses the old field names.
// Map them to the new IP_RULES so both files stay in sync.
// ============================================================

export const IMPACT_POINT_RULES = {
  playingPoints: IP_RULES.playingBonus,
  batting: {
    runPoint:                       IP_RULES.batting.perRun,
    fourBonus:                      IP_RULES.batting.perFour,
    sixBonus:                       IP_RULES.batting.perSix,
    minBallsForStrikeRateAdjustment: IP_RULES.batting.minBallsForSrAdjustment,
  },
  bowling: {
    wicketPoints:               IP_RULES.bowling.perWicket,
    dotBallPoints:              IP_RULES.bowling.perDotBall,
    maidenPoints:               IP_RULES.bowling.perMaiden,
    minBallsForEconomyAdjustment: IP_RULES.bowling.minBallsForEconAdjustment,
  },
  fielding: {
    catchPoints:    IP_RULES.fielding.perCatch,
    runOutPoints:   IP_RULES.fielding.perRunOut,
    stumpingPoints: IP_RULES.fielding.perStumping,
  },
  bonuses: {
    teamWinPoints: IP_RULES.result.win,
    mvpPoints:     IP_RULES.mvpBonus,
  },
  maxImpactPoints: IP_RULES.maxIpPerMatch,
} as const
