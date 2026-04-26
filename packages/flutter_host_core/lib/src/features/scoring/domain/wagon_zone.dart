const scoringWagonZones = <String>[
  'FINE_LEG',
  'SQUARE_LEG',
  'MID_WICKET',
  'LONG_ON',
  'LONG_OFF',
  'COVER',
  'POINT',
  'THIRD_MAN',
];

String? canonicalizeWagonZone(String? raw) {
  final value = raw?.trim().toUpperCase().replaceAll(' ', '_');
  if (value == null || value.isEmpty) return null;
  return scoringWagonZones.contains(value) ? value : null;
}
