bool scoringDeliveryIsLegal(
  String outcome, {
  String? dismissalType,
}) {
  // Retirements (hurt or retired-out) are not legal deliveries — no ball
  // was bowled. The server applies the same rule; mirror it here so the
  // client's over strip / batter-balls / bowler-overs all agree.
  if (dismissalType == 'RETIRED_HURT' || dismissalType == 'RETIRED_OUT') {
    return false;
  }
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

int scoringBowlerRunsConceded({
  required String outcome,
  required int runs,
  required int extras,
}) {
  switch (outcome) {
    case 'BYE':
    case 'LEG_BYE':
      return 0;
    default:
      return runs + extras;
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
