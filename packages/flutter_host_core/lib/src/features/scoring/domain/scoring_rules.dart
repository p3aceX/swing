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
