const scoringWagonZones = <String>[
  'THIRD_MAN',
  'POINT',
  'COVER',
  'EXTRA_COVER',
  'MID_OFF',
  'STRAIGHT',
  'MID_ON',
  'MID_WICKET',
  'SQUARE_LEG',
  'FINE_LEG',
];

String? canonicalizeWagonZone(String? raw) {
  final value = raw?.trim().toUpperCase().replaceAll(' ', '_');
  if (value == null || value.isEmpty) return null;
  return scoringWagonZones.contains(value) ? value : null;
}
