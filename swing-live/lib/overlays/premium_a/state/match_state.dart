import 'package:flutter/foundation.dart';

/// Immutable snapshot of a cricket match at one moment in time. Drives the
/// `premium_a` overlay. Same shape regardless of feed (dummy runner today,
/// `/live/matches/:id/tick` SSE later).
@immutable
class MatchState {
  final TeamMeta teamA;
  final TeamMeta teamB;
  final String groundName;
  final String matchLabel; // e.g. "1st T20I"

  final InningsSide battingSide;
  final int score;
  final int wickets;
  final int balls; // legal balls bowled in current innings

  /// Target to chase, null in 1st innings.
  final int? target;

  final BatterSnapshot striker;
  final BatterSnapshot nonStriker;
  final BowlerSnapshot bowler;

  /// Most recent legal+extras balls of the current over (max 6 legal).
  final List<BallOutcome> currentOver;

  final MatchPhase phase;
  final WinnerCard? winner;

  const MatchState({
    required this.teamA,
    required this.teamB,
    required this.groundName,
    required this.matchLabel,
    required this.battingSide,
    required this.score,
    required this.wickets,
    required this.balls,
    required this.target,
    required this.striker,
    required this.nonStriker,
    required this.bowler,
    required this.currentOver,
    required this.phase,
    required this.winner,
  });

  /// `24.3` means 24 overs and 3 balls.
  String get oversDisplay {
    final overs = balls ~/ 6;
    final inOver = balls % 6;
    return '$overs.$inOver';
  }

  /// Current run rate (runs per over). Returns 0 when no balls bowled.
  double get crr {
    if (balls == 0) return 0;
    return score / (balls / 6);
  }

  /// Required run rate (runs per over) when chasing. Null in 1st innings.
  double? get rrr {
    final t = target;
    if (t == null) return null;
    final ballsLeft = (matchTotalBalls - balls).clamp(0, matchTotalBalls);
    if (ballsLeft == 0) return null;
    final runsNeeded = (t - score).clamp(0, 1 << 30);
    return runsNeeded / (ballsLeft / 6);
  }

  /// Runs still required to win, when chasing.
  int? get runsNeeded => target == null ? null : (target! - score).clamp(0, 1 << 30);

  /// Balls remaining in the innings — by default we assume a 20-over match.
  /// Override via the runner if you need 50-over later.
  int get matchTotalBalls => 120;
  int get ballsRemaining => matchTotalBalls - balls;

  TeamMeta get battingTeam =>
      battingSide == InningsSide.teamA ? teamA : teamB;
  TeamMeta get bowlingTeam =>
      battingSide == InningsSide.teamA ? teamB : teamA;

  MatchState copyWith({
    int? score,
    int? wickets,
    int? balls,
    int? target,
    BatterSnapshot? striker,
    BatterSnapshot? nonStriker,
    BowlerSnapshot? bowler,
    List<BallOutcome>? currentOver,
    MatchPhase? phase,
    WinnerCard? winner,
  }) {
    return MatchState(
      teamA: teamA,
      teamB: teamB,
      groundName: groundName,
      matchLabel: matchLabel,
      battingSide: battingSide,
      score: score ?? this.score,
      wickets: wickets ?? this.wickets,
      balls: balls ?? this.balls,
      target: target ?? this.target,
      striker: striker ?? this.striker,
      nonStriker: nonStriker ?? this.nonStriker,
      bowler: bowler ?? this.bowler,
      currentOver: currentOver ?? this.currentOver,
      phase: phase ?? this.phase,
      winner: winner ?? this.winner,
    );
  }
}

@immutable
class TeamMeta {
  final String shortCode; // "IND"
  final String fullName;  // "India"
  final int accentColor;  // hex int, e.g. 0xFF0B6FF0
  const TeamMeta({
    required this.shortCode,
    required this.fullName,
    required this.accentColor,
  });
}

@immutable
class BatterSnapshot {
  final String name;
  final int runs;
  final int ballsFaced;
  final int fours;
  final int sixes;
  const BatterSnapshot({
    required this.name,
    required this.runs,
    required this.ballsFaced,
    required this.fours,
    required this.sixes,
  });

  double get strikeRate {
    if (ballsFaced == 0) return 0;
    return (runs / ballsFaced) * 100;
  }
}

@immutable
class BowlerSnapshot {
  final String name;
  final int legalBallsBowled;
  final int maidens;
  final int runsConceded;
  final int wickets;
  const BowlerSnapshot({
    required this.name,
    required this.legalBallsBowled,
    required this.maidens,
    required this.runsConceded,
    required this.wickets,
  });

  String get oversDisplay {
    final o = legalBallsBowled ~/ 6;
    final b = legalBallsBowled % 6;
    return '$o.$b';
  }

  double get economy {
    if (legalBallsBowled == 0) return 0;
    return runsConceded / (legalBallsBowled / 6);
  }
}

/// What happened on a single ball. Used for the over visualisation strip
/// and for transient flash events.
@immutable
class BallOutcome {
  final int runsFromBat;
  final int extras;
  final ExtraKind? extraKind;
  final bool isWicket;
  final bool isBoundary; // 4
  final bool isSix;
  final bool wasLegal; // false for wide / no-ball
  const BallOutcome({
    required this.runsFromBat,
    required this.extras,
    required this.extraKind,
    required this.isWicket,
    required this.isBoundary,
    required this.isSix,
    required this.wasLegal,
  });

  int get totalRuns => runsFromBat + extras;

  /// Short display token shown in the over strip: "0", "1", "4", "6", "W", "WD", "NB".
  String get token {
    if (isWicket) return 'W';
    switch (extraKind) {
      case ExtraKind.wide:
        return runsFromBat + extras > 1 ? 'WD$extras' : 'WD';
      case ExtraKind.noBall:
        return 'NB${runsFromBat + extras - 1}';
      case ExtraKind.bye:
        return 'B$extras';
      case ExtraKind.legBye:
        return 'LB$extras';
      case null:
        if (isSix) return '6';
        if (isBoundary) return '4';
        return runsFromBat.toString();
    }
  }
}

enum ExtraKind { wide, noBall, bye, legBye }
enum InningsSide { teamA, teamB }
enum MatchPhase { intro, powerplay, middle, death, inningsBreak, ended }

@immutable
class WinnerCard {
  final TeamMeta winner;
  final String marginText; // "WON BY 7 WICKETS" / "WON BY 32 RUNS"
  final String potm; // Player of the Match
  const WinnerCard({
    required this.winner,
    required this.marginText,
    required this.potm,
  });
}
