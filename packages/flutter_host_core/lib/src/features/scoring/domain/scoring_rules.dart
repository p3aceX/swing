bool scoringDeliveryIsLegal(
  String outcome, {
  String? dismissalType,
}) {
  switch (outcome) {
    case 'WIDE':
    case 'NO_BALL':
      return false;
    default:
      return true;
  }
}

int scoringBatterRuns({
  required String outcome,
  required int runs,
}) {
  switch (outcome) {
    case 'WIDE':
    case 'BYE':
    case 'LEG_BYE':
      return 0;
    default:
      return runs;
  }
}

/// Runs charged to the bowler from a single ball.
///
///   WIDE     → 1 (extras beyond the 1 wide penalty are byes off the wide).
///   NO_BALL  → 1 + bat runs. Bye / leg-bye tagged extras on a no-ball
///              are NOT charged to the bowler.
///   BYE / LEG_BYE → 0
///   default  → bat runs.
///
/// Mirrors backend `bowlerRunsConcededFromBall` in `scoring-rules.ts`
/// so the in-screen bowler card matches the server scorecard exactly.
int scoringBowlerRunsConceded({
  required String outcome,
  required int runs,
  required int extras,
  List<String> tags = const [],
}) {
  switch (outcome) {
    case 'WIDE':
      return 1;
    case 'NO_BALL':
      final nbExtraIsBye = tags.any(
        (t) =>
            t.startsWith('no_ball_extra:bye') ||
            t.startsWith('no_ball_extra:leg_bye'),
      );
      return nbExtraIsBye ? 1 : 1 + runs;
    case 'BYE':
    case 'LEG_BYE':
      return 0;
    default:
      return runs;
  }
}

bool scoringDismissalCountsAsInningsWicket({
  required bool isWicket,
  String? dismissalType,
}) {
  if (!isWicket) return false;
  switch (dismissalType) {
    case 'RETIRED_HURT':
    case 'NOT_OUT':
    case null:
      return false;
    default:
      return true;
  }
}

bool scoringDismissalCountsAsBowlerWicket(String? dismissalType) {
  switch (dismissalType) {
    case 'RUN_OUT':
    case 'RETIRED_HURT':
    case 'RETIRED_OUT':
    case 'OBSTRUCTING_FIELD':
    case null:
      return false;
    default:
      return true;
  }
}
