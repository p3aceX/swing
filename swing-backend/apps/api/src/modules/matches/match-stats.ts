import type { BallEvent, DismissalType } from "@swing/db";
import {
  batterRunsFromBall,
  bowlerRunsConcededFromBall,
  isBowlerCreditedWicket,
  isInningsWicket,
  isLegalDelivery,
} from "./scoring-rules";

type BallEventLike = Pick<
  BallEvent,
  | "batterId"
  | "bowlerId"
  | "fielderId"
  | "outcome"
  | "runs"
  | "extras"
  | "totalRuns"
  | "isWicket"
  | "dismissalType"
  | "dismissedPlayerId"
>;

type BasePlayerStats = {
  playerProfileId: string;
  team: string;
  runs: number;
  balls: number;
  fours: number;
  sixes: number;
  strikeRate: number;
  isOut: boolean;
  dismissalType: DismissalType | null;
  battingPosition: number | null;
  oversBowled: number;
  legalBallsBowled: number;
  wickets: number;
  runsConceded: number;
  wides: number;
  noBalls: number;
  economy: number;
  catches: number;
  stumpings: number;
  runOuts: number;
  milestones: ("FIFTY" | "HUNDRED")[];
};

export type AggregatedPlayerStats = BasePlayerStats;

export type LiveBatterStats = Pick<
  BasePlayerStats,
  | "playerProfileId"
  | "runs"
  | "balls"
  | "fours"
  | "sixes"
  | "strikeRate"
  | "isOut"
  | "dismissalType"
  | "battingPosition"
  | "milestones"
>;

export type LiveBowlerStats = {
  playerProfileId: string;
  overs: number;
  legalBalls: number;
  wickets: number;
  runs: number;
  wides: number;
  noBalls: number;
  economy: number;
};

export function toOvers(legalBalls: number) {
  return Math.floor(legalBalls / 6) + (legalBalls % 6) / 10;
}

function strikeRate(runs: number, balls: number) {
  return balls > 0 ? parseFloat(((runs / balls) * 100).toFixed(1)) : 0;
}

function economyRate(runsConceded: number, legalBalls: number) {
  return legalBalls > 0
    ? parseFloat(((runsConceded / legalBalls) * 6).toFixed(2))
    : 0;
}

function createStats(playerProfileId: string, team: string): BasePlayerStats {
  return {
    playerProfileId,
    team,
    runs: 0,
    balls: 0,
    fours: 0,
    sixes: 0,
    strikeRate: 0,
    isOut: false,
    dismissalType: null,
    battingPosition: null,
    oversBowled: 0,
    legalBallsBowled: 0,
    wickets: 0,
    runsConceded: 0,
    wides: 0,
    noBalls: 0,
    economy: 0,
    catches: 0,
    stumpings: 0,
    runOuts: 0,
    milestones: [],
  };
}

export function buildInningsPlayerStats({
  balls,
  battingTeam,
  currentStrikerId,
  currentNonStrikerId,
  currentBowlerId,
}: {
  balls: BallEventLike[];
  battingTeam: string;
  currentStrikerId?: string | null;
  currentNonStrikerId?: string | null;
  currentBowlerId?: string | null;
}) {
  const bowlingTeam = battingTeam === "A" ? "B" : "A";
  const playerStats = new Map<string, BasePlayerStats>();
  let battingPositionCounter = 0;

  const getOrInit = (playerId: string, team: string) => {
    const existing = playerStats.get(playerId);
    if (existing) return existing;

    const created = createStats(playerId, team);
    playerStats.set(playerId, created);
    return created;
  };

  for (const ball of balls) {
    const batter = getOrInit(ball.batterId, battingTeam);
    if (batter.battingPosition === null) {
      battingPositionCounter += 1;
      batter.battingPosition = battingPositionCounter;
    }

    if (isLegalDelivery(ball.outcome, ball.dismissalType)) {
      batter.balls += 1;
    }
    batter.runs += batterRunsFromBall(ball);
    if (ball.outcome === "FOUR") batter.fours += 1;
    if (ball.outcome === "SIX") batter.sixes += 1;
    if (ball.dismissedPlayerId === ball.batterId) {
      if (isInningsWicket(ball) || ball.dismissalType === "RETIRED_OUT") {
        batter.isOut = true;
      }
      if (ball.dismissalType != null) {
        batter.dismissalType = ball.dismissalType ?? null;
      }
    }

    const bowler = getOrInit(ball.bowlerId, bowlingTeam);
    if (ball.outcome === "WIDE") {
      bowler.wides += ball.extras;
    } else if (ball.outcome === "NO_BALL") {
      bowler.noBalls += ball.extras > 0 ? 1 : 0;
    } else if (isLegalDelivery(ball.outcome, ball.dismissalType)) {
      bowler.legalBallsBowled += 1;
    }
    bowler.runsConceded += bowlerRunsConcededFromBall(ball);
    if (isInningsWicket(ball) && isBowlerCreditedWicket(ball.dismissalType ?? null)) {
      bowler.wickets += 1;
    }

    if (ball.fielderId) {
      const fielder = getOrInit(ball.fielderId, bowlingTeam);
      if (ball.dismissalType === "CAUGHT") fielder.catches += 1;
      else if (ball.dismissalType === "STUMPED") fielder.stumpings += 1;
      else if (ball.dismissalType === "RUN_OUT") fielder.runOuts += 1;
    }
  }

  const batterStats = new Map<string, LiveBatterStats>();
  const bowlerStats = new Map<string, LiveBowlerStats>();
  const activeBatterIds: string[] = [];

  for (const [playerId, stats] of playerStats.entries()) {
    stats.strikeRate = strikeRate(stats.runs, stats.balls);
    stats.oversBowled = toOvers(stats.legalBallsBowled);
    stats.economy = economyRate(stats.runsConceded, stats.legalBallsBowled);

    if (stats.runs >= 100) stats.milestones.push("HUNDRED");
    else if (stats.runs >= 50) stats.milestones.push("FIFTY");

    if (stats.team === battingTeam && stats.battingPosition !== null) {
      batterStats.set(playerId, {
        playerProfileId: playerId,
        runs: stats.runs,
        balls: stats.balls,
        fours: stats.fours,
        sixes: stats.sixes,
        strikeRate: stats.strikeRate,
        isOut: stats.isOut,
        dismissalType: stats.dismissalType,
        battingPosition: stats.battingPosition,
        milestones: [...stats.milestones],
      });
      if (!stats.isOut) {
        activeBatterIds.push(playerId);
      }
    }

    if (
      stats.team === bowlingTeam &&
      (stats.legalBallsBowled > 0 ||
        stats.wides > 0 ||
        stats.noBalls > 0 ||
        stats.runsConceded > 0)
    ) {
      bowlerStats.set(playerId, {
        playerProfileId: playerId,
        overs: stats.oversBowled,
        legalBalls: stats.legalBallsBowled,
        wickets: stats.wickets,
        runs: stats.runsConceded,
        wides: stats.wides,
        noBalls: stats.noBalls,
        economy: stats.economy,
      });
    }
  }

  const resolvedStrikerId =
    currentStrikerId ??
    activeBatterIds.find((playerId) => playerId !== currentNonStrikerId) ??
    activeBatterIds[0] ??
    null;
  const resolvedNonStrikerId =
    currentNonStrikerId ??
    activeBatterIds.find((playerId) => playerId !== resolvedStrikerId) ??
    null;
  const resolvedBowlerId =
    currentBowlerId ?? balls[balls.length - 1]?.bowlerId ?? null;

  return {
    playerStats,
    batterStats,
    bowlerStats,
    activeBatterIds,
    strikerId: resolvedStrikerId,
    nonStrikerId: resolvedNonStrikerId,
    currentBowlerId: resolvedBowlerId,
  };
}

export function buildMatchPlayerStats(
  inningsCollection: Array<{
    battingTeam: string;
    balls: BallEventLike[];
  }>,
) {
  const merged = new Map<string, BasePlayerStats>();

  for (const innings of inningsCollection) {
    const inningsStats = buildInningsPlayerStats({
      balls: innings.balls,
      battingTeam: innings.battingTeam,
    });

    for (const [playerId, stats] of inningsStats.playerStats.entries()) {
      const current = merged.get(playerId);
      if (!current) {
        merged.set(playerId, { ...stats, milestones: [...stats.milestones] });
        continue;
      }

      current.runs += stats.runs;
      current.balls += stats.balls;
      current.fours += stats.fours;
      current.sixes += stats.sixes;
      current.isOut = current.isOut || stats.isOut;
      current.dismissalType = current.dismissalType ?? stats.dismissalType;
      current.battingPosition = current.battingPosition ?? stats.battingPosition;
      current.legalBallsBowled += stats.legalBallsBowled;
      current.runsConceded += stats.runsConceded;
      current.wides += stats.wides;
      current.noBalls += stats.noBalls;
      current.wickets += stats.wickets;
      current.catches += stats.catches;
      current.stumpings += stats.stumpings;
      current.runOuts += stats.runOuts;
    }
  }

  for (const stats of merged.values()) {
    stats.strikeRate = strikeRate(stats.runs, stats.balls);
    stats.oversBowled = toOvers(stats.legalBallsBowled);
    stats.economy = economyRate(stats.runsConceded, stats.legalBallsBowled);
    stats.milestones = [];
    if (stats.runs >= 100) stats.milestones.push("HUNDRED");
    else if (stats.runs >= 50) stats.milestones.push("FIFTY");
  }

  return merged;
}
