class ResolvedRankTier {
  const ResolvedRankTier({
    required this.rank,
    required this.division,
    required this.label,
    required this.assetPath,
    required this.stepIndex,
  });

  final String rank;
  final String? division;
  final String label;
  final String assetPath;
  final int stepIndex;

  bool get isApex => rank == 'Apex';
}

class _RankFrameStep {
  const _RankFrameStep(
    this.rank,
    this.division,
    this.assetKey,
  );

  final String rank;
  final String? division;
  final String assetKey;

  String get label => division == null ? rank : '$rank $division';
}

const String _defaultRankFrameAsset = 'assets/ui/rank_frames/rookie_i.svg';

const List<_RankFrameStep> _rankSteps = [
  _RankFrameStep('Rookie', 'III', 'rookie_iii'),
  _RankFrameStep('Rookie', 'II', 'rookie_ii'),
  _RankFrameStep('Rookie', 'I', 'rookie_i'),
  _RankFrameStep('Striker', 'III', 'striker_iii'),
  _RankFrameStep('Striker', 'II', 'striker_ii'),
  _RankFrameStep('Striker', 'I', 'striker_i'),
  _RankFrameStep('Vanguard', 'III', 'vanguard_iii'),
  _RankFrameStep('Vanguard', 'II', 'vanguard_ii'),
  _RankFrameStep('Vanguard', 'I', 'vanguard_i'),
  _RankFrameStep('Dominion', 'III', 'dominion_iii'),
  _RankFrameStep('Dominion', 'II', 'dominion_ii'),
  _RankFrameStep('Dominion', 'I', 'dominion_i'),
  _RankFrameStep('Ascendant', 'III', 'ascendant_iii'),
  _RankFrameStep('Ascendant', 'II', 'ascendant_ii'),
  _RankFrameStep('Ascendant', 'I', 'ascendant_i'),
  _RankFrameStep('Immortal', 'III', 'immortal_iii'),
  _RankFrameStep('Immortal', 'II', 'immortal_ii'),
  _RankFrameStep('Immortal', 'I', 'immortal_i'),
  _RankFrameStep('Phantom', 'III', 'phantom_iii'),
  _RankFrameStep('Phantom', 'II', 'phantom_ii'),
  _RankFrameStep('Phantom', 'I', 'phantom_i'),
  _RankFrameStep('Apex', null, 'apex'),
];

const List<int> _tierThresholds = [
  0,
  100,
  250,
  450,
  700,
  1000,
  1350,
  1750,
  2200,
  2750,
  3350,
  4000,
  4750,
  5600,
  6500,
  7500,
  8600,
  9800,
  11100,
  12500,
  14000,
  16000,
];

ResolvedRankTier resolveRankTier({
  required String? rank,
  required String? division,
}) {
  final index = _findRankStepIndex(rank: rank, division: division);
  if (index == -1) {
    return const ResolvedRankTier(
      rank: 'Rookie',
      division: 'I',
      label: 'Rookie I',
      assetPath: _defaultRankFrameAsset,
      stepIndex: 2,
    );
  }

  final step = _rankSteps[index];
  return ResolvedRankTier(
    rank: step.rank,
    division: step.division,
    label: step.label,
    assetPath: _assetPathFor(step.assetKey),
    stepIndex: index,
  );
}

ResolvedRankTier resolveRankTierFlexible({
  String? rank,
  String? label,
  String? division,
}) {
  final attempts = <(String?, String?)>[
    (rank, division),
    (label, null),
    (label, division),
    (rank, null),
  ];

  for (final attempt in attempts) {
    final index = _findRankStepIndex(rank: attempt.$1, division: attempt.$2);
    if (index != -1) {
      final step = _rankSteps[index];
      return ResolvedRankTier(
        rank: step.rank,
        division: step.division,
        label: step.label,
        assetPath: _assetPathFor(step.assetKey),
        stepIndex: index,
      );
    }
  }

  return const ResolvedRankTier(
    rank: 'Rookie',
    division: 'I',
    label: 'Rookie I',
    assetPath: _defaultRankFrameAsset,
    stepIndex: 2,
  );
}

int _findRankStepIndex({
  required String? rank,
  required String? division,
}) {
  final parsed = _splitRank(rank, division);
  final normalizedRank = _normalizeRank(parsed.$1);
  final normalizedDivision = _normalizeDivision(parsed.$2);

  return _rankSteps.indexWhere(
    (step) =>
        _normalizeRank(step.rank) == normalizedRank &&
        _normalizeDivision(step.division) == normalizedDivision,
  );
}

String resolveRankFrameAsset({
  required String? rank,
  required String? division,
}) {
  return resolveRankTier(rank: rank, division: division).assetPath;
}

TierProgress tierProgress({
  required ResolvedRankTier tier,
  required int impactPoints,
}) {
  final idx = tier.stepIndex.clamp(0, _tierThresholds.length - 1);
  final floor = _tierThresholds[idx];
  final ceiling = idx >= _tierThresholds.length - 1
      ? floor
      : _tierThresholds[idx + 1];
  final range = (ceiling - floor).toDouble();
  final progress = range <= 0
      ? 1.0
      : ((impactPoints - floor) / range).clamp(0.0, 1.0);
  return TierProgress(floor: floor, ceiling: ceiling, progress: progress);
}

class TierProgress {
  const TierProgress({
    required this.floor,
    required this.ceiling,
    required this.progress,
  });

  final int floor;
  final int ceiling;
  final double progress;
}

ResolvedRankTier nextRankTier(ResolvedRankTier current) {
  final nextIndex = current.stepIndex >= _rankSteps.length - 1
      ? current.stepIndex
      : current.stepIndex + 1;
  final next = _rankSteps[nextIndex];
  return ResolvedRankTier(
    rank: next.rank,
    division: next.division,
    label: next.label,
    assetPath: _assetPathFor(next.assetKey),
    stepIndex: nextIndex,
  );
}

List<ResolvedRankTier> allRankTiers() {
  return List<ResolvedRankTier>.unmodifiable(
    _rankSteps.asMap().entries.map(
      (entry) {
        final step = entry.value;
        return ResolvedRankTier(
          rank: step.rank,
          division: step.division,
          label: step.label,
          assetPath: _assetPathFor(step.assetKey),
          stepIndex: entry.key,
        );
      },
    ),
  );
}

String _assetPathFor(String assetKey) {
  return 'assets/ui/rank_frames/$assetKey.svg';
}

(String?, String?) _splitRank(String? rank, String? division) {
  final rawRank = (rank ?? '').trim();
  if (rawRank.isEmpty) return (rank, division);
  final normalized = rawRank.replaceAll(RegExp(r'[_-]+'), ' ');

  final match = RegExp(
    r'^([A-Za-z ]+?)\s*(III|II|I)$',
    caseSensitive: false,
  ).firstMatch(normalized);
  if (match == null || (division ?? '').trim().isNotEmpty) {
    return (rank, division);
  }

  return (match.group(1), match.group(2));
}

String _normalizeRank(String? rank) {
  final value = (rank ?? '')
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  return switch (value) {
    'rookie' => 'rookie',
    'striker' => 'striker',
    'vanguard' => 'vanguard',
    'dominion' => 'dominion',
    'ascendant' => 'ascendant',
    'immortal' => 'immortal',
    'phantom' => 'phantom',
    'apex' => 'apex',
    _ => '',
  };
}

String _normalizeDivision(String? division) {
  final value = (division ?? '')
      .trim()
      .toUpperCase()
      .replaceAll(RegExp(r'[^A-Z0-9]+'), '');

  return switch (value) {
    '1' || 'I' => 'I',
    '2' || 'II' => 'II',
    '3' || 'III' => 'III',
    _ => '',
  };
}
