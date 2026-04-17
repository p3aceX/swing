import 'dart:math' as math;

class EliteProfilePayload {
  const EliteProfilePayload({
    required this.identity,
    required this.ranking,
    required this.stats,
    required this.skillMatrix,
    required this.badges,
    required this.precision,
    required this.wellness,
    required this.teams,
    required this.isFollowing,
    this.directConversationId,
  });

  final EliteProfileIdentityPayload identity;
  final EliteProfileRankingPayload ranking;
  final EliteProfileStatsPayload stats;
  final EliteSkillMatrixPayload skillMatrix;
  final List<EliteProfileBadgePayload> badges;
  final EliteProfilePrecisionPayload precision;
  final EliteProfileWellnessPayload wellness;
  final List<EliteProfileTeamPayload> teams;
  final bool isFollowing;
  final String? directConversationId;

  factory EliteProfilePayload.fromJson(Map<String, dynamic> json) {
    return EliteProfilePayload(
      identity: EliteProfileIdentityPayload.fromJson(_asMap(json['identity'])),
      ranking: EliteProfileRankingPayload.fromJson(_asMap(json['ranking'])),
      stats: EliteProfileStatsPayload.fromJson(_asMap(json['stats'])),
      skillMatrix:
          EliteSkillMatrixPayload.fromJson(_asMap(json['skillMatrix'])),
      badges: _asList(json['badges'])
          .map((item) => EliteProfileBadgePayload.fromJson(_asMap(item)))
          .toList(growable: false),
      precision:
          EliteProfilePrecisionPayload.fromJson(_asMap(json['precision'])),
      wellness: EliteProfileWellnessPayload.fromJson(_asMap(json['wellness'])),
      teams: _asList(json['teams'])
          .map((item) => EliteProfileTeamPayload.fromJson(_asMap(item)))
          .toList(growable: false),
      isFollowing: _toBool(json['isFollowing']),
      directConversationId:
          _string(json['directConversationId'], fallback: '').ifEmptyToNull(),
    );
  }
}

class EliteProfileIdentityPayload {
  const EliteProfileIdentityPayload({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.bio,
    required this.city,
    required this.state,
    required this.playerRole,
    required this.battingStyle,
    required this.bowlingStyle,
    required this.level,
    required this.fans,
    required this.following,
    this.dateOfBirth,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final String bio;
  final String city;
  final String state;
  final String playerRole;
  final String battingStyle;
  final String bowlingStyle;
  final String level;
  final int fans;
  final int following;
  final String? dateOfBirth;

  factory EliteProfileIdentityPayload.fromJson(Map<String, dynamic> json) {
    return EliteProfileIdentityPayload(
      id: _string(json['id'], fallback: ''),
      name: _string(
        _firstNonEmpty([
          json['name'],
          json['fullName'],
        ]),
      ),
      avatarUrl: _string(json['avatarUrl'], fallback: '').ifEmptyToNull(),
      bio: _string(json['bio']),
      city: _string(json['city']),
      state: _string(json['state']),
      playerRole: _string(json['playerRole']),
      battingStyle: _string(json['battingStyle']),
      bowlingStyle: _string(json['bowlingStyle']),
      level: _string(json['level']),
      fans: _toInt(
        _firstNonEmpty([
          json['fans'],
          json['followersCount'],
          json['followers'],
        ]),
      ),
      following: _toInt(
        _firstNonEmpty([
          json['following'],
          json['followingCount'],
        ]),
      ),
      dateOfBirth:
          _string(json['dateOfBirth'], fallback: '').trim().ifEmptyToNull(),
    );
  }
}

class EliteProfileRankingPayload {
  const EliteProfileRankingPayload({
    required this.rank,
    required this.label,
    required this.division,
    required this.impactPoints,
    required this.swingIndex,
    required this.progress,
  });

  final String rank;
  final String label;
  final int division;
  final int impactPoints;
  final double swingIndex;
  final int progress;

  factory EliteProfileRankingPayload.fromJson(Map<String, dynamic> json) {
    final rank = _string(json['rank']);
    final division = _toInt(json['division']);
    final rawLabel = _string(json['label'], fallback: '');
    final fallbackLabel = '$rank $division'.trim();

    return EliteProfileRankingPayload(
      rank: rank,
      label: rawLabel.trim().isNotEmpty ? rawLabel : fallbackLabel,
      division: division,
      impactPoints: _toInt(json['impactPoints']),
      swingIndex: _toDouble(json['swingIndex']).clamp(0, 100).toDouble(),
      progress: _toInt(json['progress']).clamp(0, 100).toInt(),
    );
  }
}

class EliteProfileStatsPayload {
  const EliteProfileStatsPayload({
    required this.matches,
    required this.batting,
    required this.bowling,
    required this.fielding,
  });

  final EliteProfileMatchStatsPayload matches;
  final EliteProfileBattingSummaryPayload batting;
  final EliteProfileBowlingSummaryPayload bowling;
  final EliteProfileFieldingPayload fielding;

  factory EliteProfileStatsPayload.fromJson(Map<String, dynamic> json) {
    final battingNode = _asMap(json['batting']);
    final bowlingNode = _asMap(json['bowling']);
    return EliteProfileStatsPayload(
      matches: EliteProfileMatchStatsPayload.fromJson(_asMap(json['matches'])),
      batting: EliteProfileBattingSummaryPayload.fromJson(
        _asMap(battingNode['summary']).isNotEmpty
            ? _asMap(battingNode['summary'])
            : battingNode,
      ),
      bowling: EliteProfileBowlingSummaryPayload.fromJson(
        _asMap(bowlingNode['summary']).isNotEmpty
            ? _asMap(bowlingNode['summary'])
            : bowlingNode,
      ),
      fielding: EliteProfileFieldingPayload.fromJson(_asMap(json['fielding'])),
    );
  }
}

class EliteProfileMatchStatsPayload {
  const EliteProfileMatchStatsPayload({
    required this.total,
    required this.wins,
    required this.losses,
    required this.winPct,
  });

  final int total;
  final int wins;
  final int losses;
  final double winPct;

  factory EliteProfileMatchStatsPayload.fromJson(Map<String, dynamic> json) {
    final total = _toInt(json['total']);
    final wins = _toInt(json['wins']);
    final lossesFromPayload = _toInt(json['losses']);
    final losses =
        lossesFromPayload > 0 ? lossesFromPayload : math.max(0, total - wins);
    final winPctFromPayload = _toDouble(json['winPct']);
    final computedWinPct = total > 0 ? (wins / total) * 100 : 0.0;
    final winPct = winPctFromPayload > 0 ? winPctFromPayload : computedWinPct;

    return EliteProfileMatchStatsPayload(
      total: total,
      wins: wins,
      losses: losses,
      winPct: winPct,
    );
  }
}

class EliteProfileBattingSummaryPayload {
  const EliteProfileBattingSummaryPayload({
    required this.totalRuns,
    required this.totalBallsFaced,
    required this.average,
    required this.strikeRate,
    required this.highestScore,
    required this.thirties,
    required this.fifties,
    required this.hundreds,
    required this.fours,
    required this.sixes,
    required this.ducks,
  });

  final int totalRuns;
  final int totalBallsFaced;
  final double average;
  final double strikeRate;
  final int highestScore;
  final int thirties;
  final int fifties;
  final int hundreds;
  final int fours;
  final int sixes;
  final int ducks;

  factory EliteProfileBattingSummaryPayload.fromJson(
      Map<String, dynamic> json) {
    return EliteProfileBattingSummaryPayload(
      totalRuns: _toInt(json['totalRuns']),
      totalBallsFaced: _toInt(
        _firstNonEmpty([json['totalBallsFaced'], json['totalBalls']]),
      ),
      average: _toDouble(json['average']),
      strikeRate: _toDouble(json['strikeRate']),
      highestScore: _toInt(json['highestScore']),
      thirties: _toInt(json['thirties']),
      fifties: _toInt(json['fifties']),
      hundreds: _toInt(json['hundreds']),
      fours: _toInt(json['fours']),
      sixes: _toInt(json['sixes']),
      ducks: _toInt(json['ducks']),
    );
  }
}

class EliteProfileBowlingSummaryPayload {
  const EliteProfileBowlingSummaryPayload({
    required this.totalWickets,
    required this.totalBallsBowled,
    required this.average,
    required this.economy,
    required this.strikeRate,
    required this.bestBowling,
    required this.threeWicketHauls,
    required this.fiveWicketHauls,
    required this.maidens,
    required this.dotBalls,
  });

  final int totalWickets;
  final int totalBallsBowled;
  final double average;
  final double economy;
  final double strikeRate;
  final String bestBowling;
  final int threeWicketHauls;
  final int fiveWicketHauls;
  final int maidens;
  final int dotBalls;

  factory EliteProfileBowlingSummaryPayload.fromJson(
      Map<String, dynamic> json) {
    return EliteProfileBowlingSummaryPayload(
      totalWickets: _toInt(json['totalWickets']),
      totalBallsBowled: _toInt(json['totalBallsBowled']),
      average: _toDouble(json['average']),
      economy: _toDouble(json['economy']),
      strikeRate: _toDouble(json['strikeRate']),
      bestBowling: _string(json['bestBowling']),
      threeWicketHauls: _toInt(json['threeWicketHauls']),
      fiveWicketHauls: _toInt(json['fiveWicketHauls']),
      maidens: _toInt(json['maidens']),
      dotBalls: _toInt(json['dotBalls']),
    );
  }
}

class EliteProfileFieldingPayload {
  const EliteProfileFieldingPayload({
    required this.catches,
    required this.stumpings,
    required this.runOuts,
  });

  final int catches;
  final int stumpings;
  final int runOuts;

  factory EliteProfileFieldingPayload.fromJson(Map<String, dynamic> json) {
    return EliteProfileFieldingPayload(
      catches: _toInt(json['catches']),
      stumpings: _toInt(json['stumpings']),
      runOuts: _toInt(json['runOuts']),
    );
  }
}

class EliteSkillMatrixPayload {
  const EliteSkillMatrixPayload({
    required this.batting,
    required this.bowling,
    required this.fielding,
    required this.clutch,
    required this.consistency,
    required this.fitness,
    this.captaincy,
  });

  final double batting;
  final double bowling;
  final double fielding;
  final double clutch;
  final double consistency;
  final double fitness;
  final double? captaincy;

  factory EliteSkillMatrixPayload.fromJson(Map<String, dynamic> json) {
    final clutch = _toDouble(_firstNonEmpty([json['clutch'], json['iq']]));
    return EliteSkillMatrixPayload(
      batting: _toDouble(json['batting']).clamp(0, 100).toDouble(),
      bowling: _toDouble(json['bowling']).clamp(0, 100).toDouble(),
      fielding: _toDouble(json['fielding']).clamp(0, 100).toDouble(),
      clutch: clutch.clamp(0, 100).toDouble(),
      consistency: _toDouble(json['consistency']).clamp(0, 100).toDouble(),
      fitness: _toDouble(json['fitness']).clamp(0, 100).toDouble(),
      captaincy: _toNullableDouble(json['captaincy']),
    );
  }
}

class EliteProfileBadgePayload {
  const EliteProfileBadgePayload({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.isUnlocked,
    this.iconUrl,
    required this.xpReward,
    required this.isRare,
    this.awardedAt,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final bool isUnlocked;
  final String? iconUrl;
  final int xpReward;
  final bool isRare;
  final String? awardedAt;

  factory EliteProfileBadgePayload.fromJson(Map<String, dynamic> json) {
    return EliteProfileBadgePayload(
      id: _string(json['id'], fallback: ''),
      name: _string(json['name']),
      description: _string(json['description']),
      category: _string(json['category']),
      isUnlocked: _toBool(json['isUnlocked']),
      iconUrl: _string(json['iconUrl'], fallback: '').ifEmptyToNull(),
      xpReward: _toInt(json['xpReward']),
      isRare: _toBool(json['isRare']),
      awardedAt: _string(json['awardedAt'], fallback: '').ifEmptyToNull(),
    );
  }
}

class EliteProfilePrecisionPayload {
  const EliteProfilePrecisionPayload({
    required this.powerplaySR,
    required this.middleOversSR,
    required this.deathOversSR,
    required this.paceSR,
    required this.spinSR,
  });

  final double powerplaySR;
  final double middleOversSR;
  final double deathOversSR;
  final double paceSR;
  final double spinSR;

  factory EliteProfilePrecisionPayload.fromJson(Map<String, dynamic> json) {
    final phases = _asMap(json['phases']);
    final matchups = _asMap(json['matchups']);
    return EliteProfilePrecisionPayload(
      powerplaySR: _toDouble(phases['powerplaySR']),
      middleOversSR: _toDouble(phases['middleOversSR']),
      deathOversSR: _toDouble(phases['deathOversSR']),
      paceSR: _toDouble(matchups['paceSR']),
      spinSR: _toDouble(matchups['spinSR']),
    );
  }
}

class EliteProfileWellnessPayload {
  const EliteProfileWellnessPayload({
    required this.recoveryScore,
    required this.oversBowledPastMonth,
    required this.trainingHoursWeekly,
    required this.fatigueLevel,
  });

  final double recoveryScore;
  final double oversBowledPastMonth;
  final double trainingHoursWeekly;
  final int fatigueLevel;

  factory EliteProfileWellnessPayload.fromJson(Map<String, dynamic> json) {
    return EliteProfileWellnessPayload(
      recoveryScore: _toDouble(json['recoveryScore']),
      oversBowledPastMonth: _toDouble(json['oversBowledPastMonth']),
      trainingHoursWeekly: _toDouble(
        _firstNonEmpty([
          json['totalTrainingHoursWeekly'],
          json['trainingHoursWeekly'],
        ]),
      ),
      fatigueLevel: _toInt(json['fatigueLevel']),
    );
  }
}

class EliteProfileTeamPayload {
  const EliteProfileTeamPayload({
    required this.id,
    required this.name,
    required this.powerScore,
  });

  final String id;
  final String name;
  final double powerScore;

  factory EliteProfileTeamPayload.fromJson(Map<String, dynamic> json) {
    return EliteProfileTeamPayload(
      id: _string(json['id'], fallback: ''),
      name: _string(json['name']),
      powerScore: _toDouble(json['powerScore']),
    );
  }
}

class EliteStatsExtendedPayload {
  const EliteStatsExtendedPayload({
    required this.playerId,
    required this.isApex,
    required this.metrics,
    required this.error,
  });

  final String playerId;
  final bool isApex;
  final Map<String, Object?> metrics;
  final String error;

  bool get isPremiumLocked {
    final msg = error.toLowerCase();
    if (msg.isEmpty) return false;
    return msg.contains('unlock') &&
        (msg.contains('apex pack') || msg.contains('apex'));
  }

  List<EliteExtendedMetricItem> toMetricItems() {
    final items = metrics.entries
        .where((entry) => entry.key.trim().isNotEmpty)
        .map((entry) {
      final node = _asMap(entry.value);
      final key = entry.key.trim();
      final labelFromPayload = _string(node['label'], fallback: '').trim();
      final rawValue = _firstNonEmpty([
        node['value'],
        node['metricValue'],
        node['score'],
        node['displayValue'],
        node['rawValue'],
        entry.value,
      ]);
      final hasEvidence = _resolveExtendedMetricEvidence(
        value: rawValue,
        node: node,
      );
      final unit = _extendedMetricUnit(node);
      return EliteExtendedMetricItem(
        key: key,
        label: labelFromPayload.isNotEmpty
            ? labelFromPayload
            : _formatExtendedMetricLabel(key),
        category: _resolveExtendedMetricCategory(
          key: key,
          categoryRaw: node['category'],
        ),
        value: _formatExtendedMetricValue(
          rawValue,
          hasEvidence: hasEvidence,
        ),
        unit: unit,
        isPremium: _toBool(node['isPremium'] ?? node['premium'] ?? true),
        hasEvidence: hasEvidence,
      );
    }).toList(growable: false)
      ..sort((left, right) {
        final categoryOrder =
            left.category.index.compareTo(right.category.index);
        if (categoryOrder != 0) return categoryOrder;
        return left.label.toLowerCase().compareTo(right.label.toLowerCase());
      });

    return items;
  }

  factory EliteStatsExtendedPayload.fromJson(Map<String, dynamic> json) {
    final metricsNode = _asMap(json['metrics']);
    return EliteStatsExtendedPayload(
      playerId: _string(json['playerId'], fallback: ''),
      isApex: _toBool(json['isApex']),
      metrics: metricsNode.map(
        (key, value) => MapEntry(key, value),
      ),
      error: _string(json['error'], fallback: ''),
    );
  }
}

enum EliteMetricCategory {
  batting,
  bowling,
  fielding,
  captaincy,
}

extension EliteMetricCategoryX on EliteMetricCategory {
  String get key {
    switch (this) {
      case EliteMetricCategory.batting:
        return 'batting';
      case EliteMetricCategory.bowling:
        return 'bowling';
      case EliteMetricCategory.fielding:
        return 'fielding';
      case EliteMetricCategory.captaincy:
        return 'captaincy';
    }
  }

  String get label {
    switch (this) {
      case EliteMetricCategory.batting:
        return 'Batting';
      case EliteMetricCategory.bowling:
        return 'Bowling';
      case EliteMetricCategory.fielding:
        return 'Fielding';
      case EliteMetricCategory.captaincy:
        return 'Captaincy';
    }
  }
}

class EliteExtendedMetricItem {
  const EliteExtendedMetricItem({
    required this.key,
    required this.label,
    required this.category,
    required this.value,
    required this.unit,
    required this.isPremium,
    required this.hasEvidence,
  });

  final String key;
  final String label;
  final EliteMetricCategory category;
  final String value;
  final String unit;
  final bool isPremium;
  final bool hasEvidence;
}

const Set<String> _battingMetricKeys = <String>{
  'battingInnings',
  'notOuts',
  'totalRuns',
  'totalBallsFaced',
  'totalFours',
  'totalSixes',
  'totalBoundaries',
  'boundaryRuns',
  'highestScore',
  'battingDismissals',
  'battingAverage',
  'strikeRate',
  'runsPerInnings',
  'ballsPerDismissal',
  'boundaryPerBall',
  'ballsPerBoundary',
  'boundaryRunPct',
  'dotBallPctBat',
  'singlesPctBat',
  'scoringShotPct',
  'thirties',
  'forties',
  'fifties',
  'hundreds',
  'ducks',
  'fiftyPlusInningsPct',
  'hundredConversionFromFiftyPct',
  'thirtyToFiftyConversionPct',
  'fiftyToHundredConversionPct',
  'maxBoundariesInInnings',
  'powerplayRuns',
  'powerplayBalls',
  'powerplaySR',
  'middleRuns',
  'middleBalls',
  'middleSR',
  'deathRuns',
  'deathBalls',
  'deathSR',
  'deathBoundaryPerBall',
  'vsPaceRuns',
  'vsPaceBalls',
  'vsPaceSR',
  'vsSpinRuns',
  'vsSpinBalls',
  'vsSpinSR',
  'vsLeftArmPaceSR',
  'vsRightArmPaceSR',
  'vsOffSpinSR',
  'vsLegSpinSR',
  'last5Runs',
  'last5BatAvg',
  'last5BatSR',
  'last10Runs',
  'runsStdDev',
};

const Set<String> _bowlingMetricKeys = <String>{
  'bowlingInnings',
  'totalBallsBowled',
  'totalOvers',
  'totalWickets',
  'totalRunsConceded',
  'maidens',
  'dotBallsBowled',
  'wides',
  'noBalls',
  'legalDeliveriesPct',
  'bowlingAverage',
  'economyRate',
  'bowlingStrikeRate',
  'wicketsPerMatch',
  'wicketsPerInnings',
  'dotBallPctBowl',
  'boundariesConceded',
  'boundaryConcededPct',
  'ballsPerBoundaryConceded',
  'controlBallPct',
  'bestBowlingWickets',
  'bestBowlingRuns',
  'bestBowlingFigure',
  'threeWicketHauls',
  'fourWicketHauls',
  'fiveWicketHauls',
  'wicketsBowled',
  'wicketsLBW',
  'wicketsCaught',
  'otherWickets',
  'ppBallsBowled',
  'ppRunsConceded',
  'ppEconomy',
  'middleBallsBowled',
  'middleRunsConceded',
  'middleEconomy',
  'deathBallsBowled',
  'deathRunsConceded',
  'deathEconomy',
  'deathWickets',
  'last5Wickets',
  'last5Economy',
  'last10Wickets',
  'wicketsStdDev',
};

const Set<String> _fieldingMetricKeys = <String>{
  'catches',
  'runOutDirect',
  'runOutAssist',
  'stumpings',
  'totalDismissalInvolvements',
  'catchesPerMatch',
  'runOutInvolvementPerMatch',
  'stumpingsPerKeepingInnings',
  'missedChances',
  'dismissalInvolvementPerMatch',
};

EliteMetricCategory _resolveExtendedMetricCategory({
  required String key,
  required dynamic categoryRaw,
}) {
  final normalizedCategory = _string(categoryRaw, fallback: '').toLowerCase();
  if (normalizedCategory == 'batting') return EliteMetricCategory.batting;
  if (normalizedCategory == 'bowling') return EliteMetricCategory.bowling;
  if (normalizedCategory == 'fielding') return EliteMetricCategory.fielding;
  if (normalizedCategory == 'captaincy') return EliteMetricCategory.captaincy;

  if (_battingMetricKeys.contains(key)) return EliteMetricCategory.batting;
  if (_bowlingMetricKeys.contains(key)) return EliteMetricCategory.bowling;
  if (_fieldingMetricKeys.contains(key)) return EliteMetricCategory.fielding;

  final lowerKey = key.toLowerCase();
  if (lowerKey.contains('captain') ||
      lowerKey.contains('leadership') ||
      lowerKey.contains('tactical') ||
      lowerKey.contains('wincontrol') ||
      lowerKey.contains('resultimpact') ||
      lowerKey.contains('chasecontrol')) {
    return EliteMetricCategory.captaincy;
  }
  if (lowerKey.contains('bowl') ||
      lowerKey.contains('wicket') ||
      lowerKey.contains('economy') ||
      lowerKey.contains('conceded') ||
      lowerKey.contains('wide') ||
      lowerKey.contains('noball') ||
      lowerKey.contains('lbw') ||
      lowerKey.contains('maiden')) {
    return EliteMetricCategory.bowling;
  }
  if (lowerKey.contains('field') ||
      lowerKey.contains('catch') ||
      lowerKey.contains('stumping') ||
      lowerKey.contains('runout') ||
      lowerKey.contains('dismissal') ||
      lowerKey.contains('missed')) {
    return EliteMetricCategory.fielding;
  }
  return EliteMetricCategory.batting;
}

String _extendedMetricUnit(Map<String, dynamic> node) {
  final unit = _string(
    _firstNonEmpty([node['unit'], node['uom'], node['suffix']]),
    fallback: '',
  ).trim();
  if (unit == '-' || unit.isEmpty) return '';
  return unit;
}

bool _resolveExtendedMetricEvidence({
  required dynamic value,
  required Map<String, dynamic> node,
}) {
  final explicit = node['hasEvidence'];
  if (explicit is bool) return explicit;

  final evidenceCount = node['evidenceCount'];
  if (evidenceCount != null) {
    return _toInt(evidenceCount) > 0;
  }

  final evidenceList = node['evidence'];
  if (evidenceList is List) {
    return evidenceList.isNotEmpty;
  }

  if (value == null) return false;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty ||
        normalized == '-' ||
        normalized == 'n/a' ||
        normalized == 'na' ||
        normalized == 'null' ||
        normalized == 'none' ||
        normalized == 'no evidence') {
      return false;
    }
  }
  if (value is List) return value.isNotEmpty;
  if (value is Map) return value.isNotEmpty;
  return true;
}

String _formatExtendedMetricValue(
  dynamic value, {
  required bool hasEvidence,
}) {
  if (!hasEvidence) return 'N/A';
  if (value == null) return 'N/A';
  if (value is num) return _formatMetricNumber(value);
  if (value is bool) return value ? 'Yes' : 'No';
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'N/A' : trimmed;
  }
  if (value is List) {
    if (value.isEmpty) return 'N/A';
    return value.map((item) => '$item').join(', ');
  }
  final text = '$value'.trim();
  return text.isEmpty ? 'N/A' : text;
}

String _formatMetricNumber(num value) {
  final asDouble = value.toDouble();
  if (asDouble == asDouble.roundToDouble()) {
    return asDouble.toStringAsFixed(0);
  }
  final raw = asDouble.abs() >= 100
      ? asDouble.toStringAsFixed(1)
      : asDouble.toStringAsFixed(2);
  return raw.replaceFirst(RegExp(r'\.?0+$'), '');
}

String _formatExtendedMetricLabel(String raw) {
  final spaced = raw
      .replaceAll('_', ' ')
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (match) => '${match.group(1)} ${match.group(2)}',
      )
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (spaced.isEmpty) return '-';
  return spaced.split(' ').map((word) {
    final lower = word.toLowerCase();
    switch (lower) {
      case 'sr':
      case 'pp':
      case 'lbw':
      case 'mvp':
        return lower.toUpperCase();
      case 'vs':
        return 'vs';
      default:
        if (lower.isEmpty) return lower;
        return '${lower[0].toUpperCase()}${lower.substring(1)}';
    }
  }).join(' ');
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return const <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) {
    return value;
  }
  return const <dynamic>[];
}

String _string(dynamic value, {String fallback = '-'}) {
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) return trimmed;
  }
  return fallback;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
  }
  return 0;
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

double? _toNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return false;
}

dynamic _firstNonEmpty(List<dynamic> values) {
  for (final value in values) {
    if (value == null) continue;
    if (value is String) {
      if (value.trim().isNotEmpty) return value.trim();
      continue;
    }
    return value;
  }
  return null;
}

extension on String {
  String? ifEmptyToNull() => trim().isEmpty ? null : this;
}
