export type BallOutcomeLike =
  | "DOT"
  | "SINGLE"
  | "DOUBLE"
  | "TRIPLE"
  | "FOUR"
  | "FIVE"
  | "SIX"
  | "WIDE"
  | "NO_BALL"
  | "WICKET"
  | "BYE"
  | "LEG_BYE";

export type DismissalTypeLike =
  | "BOWLED"
  | "CAUGHT"
  | "CAUGHT_BEHIND"
  | "CAUGHT_AND_BOWLED"
  | "LBW"
  | "RUN_OUT"
  | "STUMPED"
  | "HIT_WICKET"
  | "HIT_BALL_TWICE"
  | "RETIRED_HURT"
  | "RETIRED_OUT"
  | "OBSTRUCTING_FIELD"
  | "NOT_OUT";

export type ScoringBallLike = {
  outcome: string;
  runs?: number | null;
  extras?: number | null;
  isWicket?: boolean | null;
  dismissalType?: string | null;
  dismissedPlayerId?: string | null;
  bowlerId?: string | null;
  fielderId?: string | null;
  tags?: string[] | null;
};

const FREE_HIT_ALLOWED_DISMISSALS = new Set<DismissalTypeLike>([
  "RUN_OUT",
  "OBSTRUCTING_FIELD",
  "HIT_BALL_TWICE",
]);

const BOWLER_CREDITED_WICKET_DISMISSALS = new Set<DismissalTypeLike>([
  "BOWLED",
  "CAUGHT",
  "CAUGHT_BEHIND",
  "CAUGHT_AND_BOWLED",
  "LBW",
  "STUMPED",
  "HIT_WICKET",
]);

const STRIKER_ONLY_DISMISSALS = new Set<DismissalTypeLike>([
  "BOWLED",
  "CAUGHT",
  "CAUGHT_BEHIND",
  "CAUGHT_AND_BOWLED",
  "LBW",
  "STUMPED",
  "HIT_WICKET",
  "HIT_BALL_TWICE",
]);

const RETIREMENT_DISMISSALS = new Set<DismissalTypeLike>([
  "RETIRED_HURT",
  "RETIRED_OUT",
]);

const WIDE_DISMISSALS = new Set<DismissalTypeLike>([
  "RUN_OUT",
  "STUMPED",
  "OBSTRUCTING_FIELD",
]);

const NO_BALL_DISMISSALS = new Set<DismissalTypeLike>([
  "RUN_OUT",
  "OBSTRUCTING_FIELD",
  "HIT_BALL_TWICE",
]);

const BYE_DISMISSALS = new Set<DismissalTypeLike>([
  "RUN_OUT",
  "OBSTRUCTING_FIELD",
  "HIT_WICKET",
]);

export const WAGON_WHEEL_ZONES = [
  "third_man",
  "point",
  "cover",
  "long_off",
  "long_on",
  "mid_wicket",
  "square_leg",
  "fine_leg",
] as const;

const WAGON_ZONE_ALIAS_MAP = new Map<string, (typeof WAGON_WHEEL_ZONES)[number]>([
  ["thirdman", "third_man"],
  ["third_man", "third_man"],
  ["third_man_region", "third_man"],
  ["deep_third", "third_man"],
  ["point", "point"],
  ["deep_point", "point"],
  ["backward_point", "point"],
  ["gully", "point"],
  ["cover", "cover"],
  ["deep_cover", "cover"],
  ["extra_cover", "cover"],
  ["cover_drive", "cover"],
  ["mid_off", "long_off"],
  ["long_off", "long_off"],
  ["deep_off", "long_off"],
  ["off_side", "long_off"],
  ["mid_on", "long_on"],
  ["long_on", "long_on"],
  ["deep_on", "long_on"],
  ["on_side", "long_on"],
  ["straight", "long_on"],
  ["straight_drive", "long_on"],
  ["down_the_ground", "long_on"],
  ["mid_wicket", "mid_wicket"],
  ["midwicket", "mid_wicket"],
  ["cow_corner", "mid_wicket"],
  ["square_leg", "square_leg"],
  ["squareleg", "square_leg"],
  ["fine_leg", "fine_leg"],
  ["fineleg", "fine_leg"],
]);

const NORMAL_DISMISSALS = new Set<DismissalTypeLike>([
  "BOWLED",
  "CAUGHT",
  "CAUGHT_BEHIND",
  "CAUGHT_AND_BOWLED",
  "LBW",
  "RUN_OUT",
  "STUMPED",
  "HIT_WICKET",
  "HIT_BALL_TWICE",
  "OBSTRUCTING_FIELD",
]);

function normalizeWagonZoneToken(zone: string) {
  return zone
    .trim()
    .toLowerCase()
    .replace(/^zone:/, "")
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
}

export function normalizeWagonZone(zone: string | null | undefined) {
  if (zone == null) return null;
  const token = normalizeWagonZoneToken(zone);
  if (!token) return null;

  if ((WAGON_WHEEL_ZONES as readonly string[]).includes(token)) {
    return token as (typeof WAGON_WHEEL_ZONES)[number];
  }

  return WAGON_ZONE_ALIAS_MAP.get(token) ?? null;
}

export function resolveBallSelections(params: {
  batterId?: string | null;
  nonBatterId?: string | null;
  bowlerId?: string | null;
  currentStrikerId?: string | null;
  currentNonStrikerId?: string | null;
  currentBowlerId?: string | null;
}) {
  const currentStrikerId = params.currentStrikerId ?? null;
  const currentNonStrikerId = params.currentNonStrikerId ?? null;
  const currentBowlerId = params.currentBowlerId ?? null;

  const batterId = params.batterId ?? currentStrikerId ?? currentNonStrikerId ?? null;
  let nonBatterId = params.nonBatterId ?? null;

  if (!nonBatterId && batterId) {
    if (currentStrikerId && currentNonStrikerId) {
      if (batterId === currentStrikerId) nonBatterId = currentNonStrikerId;
      else if (batterId === currentNonStrikerId) nonBatterId = currentStrikerId;
      else nonBatterId = currentStrikerId;
    } else if (currentStrikerId && batterId !== currentStrikerId) {
      nonBatterId = currentStrikerId;
    } else if (currentNonStrikerId && batterId !== currentNonStrikerId) {
      nonBatterId = currentNonStrikerId;
    }
  }

  if (batterId && nonBatterId && batterId === nonBatterId) {
    nonBatterId = null;
  }

  const bowlerId = params.bowlerId ?? currentBowlerId ?? null;

  return {
    batterId,
    nonBatterId,
    bowlerId,
  };
}

function normalizedOutcome(outcome: string): BallOutcomeLike {
  return (outcome || "DOT") as BallOutcomeLike;
}

function normalizedDismissalType(
  dismissalType: string | null | undefined,
): DismissalTypeLike | null {
  return dismissalType ? (dismissalType as DismissalTypeLike) : null;
}

function hasTag(ball: ScoringBallLike, prefix: string) {
  return (ball.tags ?? []).some((tag) => `${tag}`.startsWith(prefix));
}

export function isLegalDelivery(
  outcome: string,
  dismissalType?: string | null,
) {
  const normalized = normalizedOutcome(outcome);
  if (isRetirementDismissal(dismissalType)) return false;
  return normalized !== "WIDE" && normalized !== "NO_BALL";
}

export function isRetirementDismissal(dismissalType: string | null | undefined) {
  const normalized = normalizedDismissalType(dismissalType);
  return normalized != null && RETIREMENT_DISMISSALS.has(normalized);
}

export function isBowlerCreditedWicket(
  dismissalType: string | null | undefined,
) {
  const normalized = normalizedDismissalType(dismissalType);
  return normalized != null && BOWLER_CREDITED_WICKET_DISMISSALS.has(normalized);
}

export function isInningsWicket(ball: ScoringBallLike) {
  const dismissalType = normalizedDismissalType(ball.dismissalType);
  if (!ball.isWicket) return false;
  if (dismissalType == null) return true;
  return dismissalType !== "NOT_OUT" && dismissalType !== "RETIRED_HURT";
}

export function dismissalChoicesForDelivery(params: {
  outcome: string;
  isFreeHit: boolean;
}) {
  const outcome = normalizedOutcome(params.outcome);
  if (params.isFreeHit) {
    return [...FREE_HIT_ALLOWED_DISMISSALS];
  }

  if (outcome === "WIDE") return [...WIDE_DISMISSALS];
  if (outcome === "NO_BALL") return [...NO_BALL_DISMISSALS];
  if (outcome === "BYE" || outcome === "LEG_BYE") return [...BYE_DISMISSALS];
  return [...NORMAL_DISMISSALS];
}

export function isDismissalValidForDelivery(params: {
  outcome: string;
  dismissalType: string | null | undefined;
  isFreeHit: boolean;
}) {
  const dismissalType = normalizedDismissalType(params.dismissalType);
  if (dismissalType == null) return true;
  if (dismissalType === "NOT_OUT") return true;
  if (RETIREMENT_DISMISSALS.has(dismissalType)) return true;
  return dismissalChoicesForDelivery(params).includes(dismissalType);
}

export function validateDismissalForDelivery(params: {
  outcome: string;
  dismissalType: string | null | undefined;
  isFreeHit: boolean;
}) {
  if (
    !isDismissalValidForDelivery({
      outcome: params.outcome,
      dismissalType: params.dismissalType,
      isFreeHit: params.isFreeHit,
    })
  ) {
    const dismissalType = params.dismissalType ?? "UNKNOWN";
    const choices = dismissalChoicesForDelivery({
      outcome: params.outcome,
      isFreeHit: params.isFreeHit,
    }).join(", ");
    throw new Error(
      `Illegal dismissal ${dismissalType} for ${params.outcome}${params.isFreeHit ? " on a free hit" : ""}. Allowed: ${choices}`,
    );
  }
}

export function batterRunsFromBall(ball: ScoringBallLike) {
  const outcome = normalizedOutcome(ball.outcome);
  const runs = ball.runs ?? 0;

  if (outcome === "WIDE" || outcome === "BYE" || outcome === "LEG_BYE") {
    return 0;
  }

  return runs;
}

export function bowlerRunsConcededFromBall(ball: ScoringBallLike) {
  const outcome = normalizedOutcome(ball.outcome);
  const runs = ball.runs ?? 0;
  const extras = ball.extras ?? 0;

  if (outcome === "WIDE") return extras;
  if (outcome === "NO_BALL") return runs + extras;
  if (outcome === "BYE" || outcome === "LEG_BYE") return 0;
  return runs;
}

export function completedRunsForStrike(ball: ScoringBallLike) {
  const outcome = normalizedOutcome(ball.outcome);
  const runs = ball.runs ?? 0;
  const extras = ball.extras ?? 0;

  switch (outcome) {
    case "WIDE":
      return extras > 0 ? extras - 1 : 0;
    case "NO_BALL":
      return runs + (extras > 0 ? extras - 1 : 0);
    case "BYE":
    case "LEG_BYE":
      return extras;
    default:
      return runs + extras;
  }
}

export function activeDismissedPlayerId(params: {
  ball: ScoringBallLike;
  strikerId: string | null;
  nonStrikerId: string | null;
}) {
  const dismissalType = normalizedDismissalType(params.ball.dismissalType);
  const dismissedPlayerId = params.ball.dismissedPlayerId ?? null;

  if (
    dismissedPlayerId &&
    (isInningsWicket(params.ball) || isRetirementDismissal(dismissalType))
  ) {
    return dismissedPlayerId;
  }

  if (!isInningsWicket(params.ball) || dismissalType == null) return null;
  if (dismissalType === "RUN_OUT") return params.strikerId ?? params.nonStrikerId;
  if (STRIKER_ONLY_DISMISSALS.has(dismissalType)) return params.strikerId;
  if (dismissalType === "OBSTRUCTING_FIELD") {
    return params.strikerId ?? params.nonStrikerId;
  }
  return null;
}

export function nextBallIsFreeHit(params: {
  previousBallWasFreeHit: boolean;
  currentOutcome: string;
  dismissalType?: string | null;
}) {
  if (isRetirementDismissal(params.dismissalType)) {
    return params.previousBallWasFreeHit;
  }
  const outcome = normalizedOutcome(params.currentOutcome);
  if (outcome === "NO_BALL") return true;
  if (params.previousBallWasFreeHit && outcome === "WIDE") return true;
  return false;
}

export function isRetiredHurt(ball: ScoringBallLike) {
  const dismissalType = normalizedDismissalType(ball.dismissalType);
  return dismissalType === "RETIRED_HURT";
}

export function isPlayerUnavailableForReplacement(ball: ScoringBallLike) {
  // Retired hurt players may re-enter at any point — only permanent wickets block replacement
  return isInningsWicket(ball);
}

export function validateBallShape(ball: ScoringBallLike) {
  const outcome = normalizedOutcome(ball.outcome);
  const runs = ball.runs ?? 0;
  const extras = ball.extras ?? 0;
  const dismissalType = normalizedDismissalType(ball.dismissalType);

  if (runs < 0 || extras < 0) {
    throw new Error("Runs and extras must be non-negative");
  }

  if (outcome === "WIDE" && runs !== 0) {
    throw new Error("Wide deliveries cannot have batter runs");
  }

  if ((outcome === "BYE" || outcome === "LEG_BYE") && runs !== 0) {
    throw new Error(`${outcome} deliveries cannot credit batter runs`);
  }

  if (["DOT", "SINGLE", "DOUBLE", "TRIPLE", "FOUR", "FIVE", "SIX", "WICKET"]
      .includes(outcome) &&
      extras !== 0 &&
      !hasTag(ball, "overthrow:extras")) {
    throw new Error(`${outcome} cannot have extras unless explicitly tagged`);
  }

  if ((outcome === "WIDE" || outcome === "NO_BALL" || outcome === "BYE" || outcome === "LEG_BYE") && extras <= 0) {
    throw new Error(`${outcome} must record at least one extra`);
  }

  if (isRetirementDismissal(dismissalType) && (runs !== 0 || extras !== 0)) {
    throw new Error("Retirement events cannot add runs or extras");
  }

  if (ball.isWicket && dismissalType == null) {
    throw new Error("Wicket deliveries must include a dismissal type");
  }

  if (!ball.isWicket && dismissalType != null && !RETIREMENT_DISMISSALS.has(dismissalType)) {
    throw new Error("Only retirement dismissals may be recorded without a wicket");
  }

  if (
    dismissalType === "CAUGHT_AND_BOWLED" &&
    ball.fielderId &&
    ball.bowlerId &&
    ball.fielderId !== ball.bowlerId
  ) {
    throw new Error("Caught and bowled must credit the bowler as the fielder");
  }
}

export function validateBallAgainstInningsState(params: {
  currentLegalBalls: number;
  maxLegalBalls: number;
  currentWickets: number;
  currentRuns: number;
  targetRuns?: number | null;
  ball: ScoringBallLike;
}) {
  if (params.currentLegalBalls >= params.maxLegalBalls) {
    throw new Error("The innings has already reached the legal-ball limit");
  }
  if (params.currentWickets >= 10) {
    throw new Error("The innings is already all out");
  }
  if (params.targetRuns != null && params.currentRuns >= params.targetRuns) {
    throw new Error("The chase is already complete");
  }

  if (
    isLegalDelivery(params.ball.outcome, params.ball.dismissalType) &&
    params.currentLegalBalls + 1 > params.maxLegalBalls
  ) {
    throw new Error("This delivery would exceed the innings over limit");
  }
}
