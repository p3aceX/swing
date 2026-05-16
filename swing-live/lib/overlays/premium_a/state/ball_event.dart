import 'package:flutter/foundation.dart';

import 'match_state.dart';

/// Transient events the overlay reacts to with one-shot animations.
/// They never live in [MatchState] — they're the *delta*, not the state.
@immutable
sealed class OverlayEvent {
  const OverlayEvent();
}

class BallLanded extends OverlayEvent {
  final BallOutcome ball;
  const BallLanded(this.ball);
}

/// Fired in addition to [BallLanded] when a wicket falls — carries the
/// dismissed batter's snapshot BEFORE replacement so we can show their
/// name, runs (for the duck flag), and balls faced.
class WicketTaken extends OverlayEvent {
  final BatterSnapshot dismissed;
  final String dismissalMethod; // e.g. "c STARC b BUMRAH"
  final String bowlerName;
  bool get isDuck => dismissed.runs == 0;
  bool get isGoldenDuck => isDuck && dismissed.ballsFaced <= 1;
  const WicketTaken({
    required this.dismissed,
    required this.dismissalMethod,
    required this.bowlerName,
  });
}

class StrikeRotated extends OverlayEvent {
  const StrikeRotated();
}

class OverEnded extends OverlayEvent {
  final List<BallOutcome> balls;
  final int runs;
  final int wickets;
  final String bowlerName;
  final int overNumber;
  const OverEnded({
    required this.balls,
    required this.runs,
    required this.wickets,
    required this.bowlerName,
    required this.overNumber,
  });
}

class InningsEnded extends OverlayEvent {
  const InningsEnded();
}

class MatchEnded extends OverlayEvent {
  final WinnerCard winner;
  const MatchEnded(this.winner);
}
