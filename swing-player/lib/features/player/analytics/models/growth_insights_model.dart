class GrowthInsights {
  const GrowthInsights({
    required this.isPro,
    required this.locked,
    this.momentum,
    this.roleIndex,
    this.archetype,
    required this.growthVelocity,
    this.percentile,
    this.weakness,
    this.coachSuggestions = const [],
    this.readiness,
    this.upgradeMessage,
  });

  final bool isPro;
  final bool locked;
  final double? momentum;
  final double? roleIndex;
  final PlayerArchetype? archetype;
  final GrowthVelocity growthVelocity;
  final PercentileData? percentile;
  final WeaknessData? weakness;
  final List<CoachSuggestion> coachSuggestions;
  final ReadinessData? readiness;
  final String? upgradeMessage;

  factory GrowthInsights.fromJson(Map<String, dynamic> json) {
    return GrowthInsights(
      isPro: json['isPro'] == true,
      locked: json['locked'] == true,
      momentum: _nullableDouble(json['momentum']),
      roleIndex: _nullableDouble(json['roleIndex']),
      archetype: json['archetype'] is Map<String, dynamic>
          ? PlayerArchetype.fromJson(
              json['archetype'] as Map<String, dynamic>,
            )
          : null,
      growthVelocity: GrowthVelocity.fromJson(
        _asMap(json['growthVelocity']),
      ),
      percentile: json['percentile'] is Map<String, dynamic>
          ? PercentileData.fromJson(
              json['percentile'] as Map<String, dynamic>,
            )
          : null,
      weakness: json['weakness'] is Map<String, dynamic>
          ? WeaknessData.fromJson(
              json['weakness'] as Map<String, dynamic>,
            )
          : null,
      coachSuggestions: _asList(json['coachSuggestions'])
          .map(
            (item) => CoachSuggestion.fromJson(item),
          )
          .toList(),
      readiness: json['readiness'] is Map<String, dynamic>
          ? ReadinessData.fromJson(
              json['readiness'] as Map<String, dynamic>,
            )
          : null,
      upgradeMessage: _nullableString(json['upgradeMessage']),
    );
  }
}

class PlayerArchetype {
  const PlayerArchetype({
    required this.label,
    required this.description,
  });

  final String label;
  final String description;

  factory PlayerArchetype.fromJson(Map<String, dynamic> json) {
    return PlayerArchetype(
      label: _string(json['label']),
      description: _string(json['description']),
    );
  }
}

class GrowthVelocity {
  const GrowthVelocity({
    required this.trend,
    required this.deltaPercent,
    required this.windowMatches,
  });

  final String trend;
  final double deltaPercent;
  final int windowMatches;

  factory GrowthVelocity.fromJson(Map<String, dynamic> json) {
    return GrowthVelocity(
      trend: _string(json['trend'], fallback: 'INSUFFICIENT_DATA'),
      deltaPercent: _double(json['deltaPercent']),
      windowMatches: _int(json['windowMatches']),
    );
  }
}

class PercentileData {
  const PercentileData({
    required this.value,
    required this.label,
    required this.comparedTo,
  });

  final int value;
  final String label;
  final int comparedTo;

  factory PercentileData.fromJson(Map<String, dynamic> json) {
    return PercentileData(
      value: _int(json['value']),
      label: _string(json['label']),
      comparedTo: _int(json['comparedTo']),
    );
  }
}

class WeaknessData {
  const WeaknessData({
    required this.axis,
    required this.score,
    required this.insight,
    this.drills = const [],
  });

  final String axis;
  final double score;
  final String insight;
  final List<DrillRecommendation> drills;

  factory WeaknessData.fromJson(Map<String, dynamic> json) {
    return WeaknessData(
      axis: _string(json['axis']),
      score: _double(json['score']),
      insight: _string(json['insight']),
      drills: _asList(json['drills'])
          .map((item) => DrillRecommendation.fromJson(item))
          .toList(),
    );
  }
}

class DrillRecommendation {
  const DrillRecommendation({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.description,
    required this.targetUnit,
    required this.targetQuantity,
  });

  final String id;
  final String name;
  final String category;
  final String difficulty;
  final String description;
  final String targetUnit;
  final int targetQuantity;

  factory DrillRecommendation.fromJson(Map<String, dynamic> json) {
    return DrillRecommendation(
      id: _string(json['id']),
      name: _string(json['name']),
      category: _string(json['category']),
      difficulty: _string(json['difficulty']),
      description: _string(json['description']),
      targetUnit: _string(json['targetUnit']),
      targetQuantity: _int(json['targetQuantity']),
    );
  }
}

class CoachSuggestion {
  const CoachSuggestion({
    required this.coachId,
    required this.name,
    this.avatarUrl,
    this.specializations = const [],
    required this.rating,
    required this.totalSessions,
    required this.gigId,
    required this.gigTitle,
    required this.sessionPricePaise,
    required this.durationMins,
    required this.sessionType,
    required this.locationName,
    this.distanceKm,
  });

  final String coachId;
  final String name;
  final String? avatarUrl;
  final List<String> specializations;
  final double rating;
  final int totalSessions;
  final String gigId;
  final String gigTitle;
  final int sessionPricePaise;
  final int durationMins;
  final String sessionType;
  final String locationName;
  final double? distanceKm;

  factory CoachSuggestion.fromJson(Map<String, dynamic> json) {
    return CoachSuggestion(
      coachId: _string(json['coachId']),
      name: _string(json['name']),
      avatarUrl: _nullableString(json['avatarUrl']),
      specializations: _stringList(json['specializations']),
      rating: _double(json['rating']),
      totalSessions: _int(json['totalSessions']),
      gigId: _string(json['gigId']),
      gigTitle: _string(json['gigTitle']),
      sessionPricePaise: _int(json['sessionPricePaise']),
      durationMins: _int(json['durationMins']),
      sessionType: _string(json['sessionType']),
      locationName: _string(json['locationName']),
      distanceKm: _nullableDouble(json['distanceKm']),
    );
  }
}

class ReadinessData {
  const ReadinessData({
    required this.score,
    this.signals = const [],
  });

  final int score;
  final List<ReadinessSignal> signals;

  factory ReadinessData.fromJson(Map<String, dynamic> json) {
    return ReadinessData(
      score: _int(json['score']),
      signals: _asList(json['signals'])
          .map((item) => ReadinessSignal.fromJson(item))
          .toList(),
    );
  }
}

class ReadinessSignal {
  const ReadinessSignal({
    required this.label,
    required this.positive,
  });

  final String label;
  final bool positive;

  factory ReadinessSignal.fromJson(Map<String, dynamic> json) {
    return ReadinessSignal(
      label: _string(json['label']),
      positive: json['positive'] == true,
    );
  }
}

class SkillMatrix {
  const SkillMatrix({
    required this.batting,
    required this.bowling,
    required this.fielding,
    required this.fitness,
    required this.clutch,
    required this.consistency,
    this.captaincy,
  });

  final double batting;
  final double bowling;
  final double fielding;
  final double fitness;
  final double clutch;
  final double consistency;
  final double? captaincy;

  factory SkillMatrix.fromJson(Map<String, dynamic> json) {
    return SkillMatrix(
      batting: _double(json['batting']),
      bowling: _double(json['bowling']),
      fielding: _double(json['fielding']),
      fitness: _double(json['fitness']),
      clutch: _double(json['clutch'] ?? json['iq']),
      consistency: _double(json['consistency']),
      captaincy: _nullableDouble(json['captaincy']),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map<String, dynamic> ? value : <String, dynamic>{};

List<Map<String, dynamic>> _asList(dynamic value) {
  if (value is List) {
    return value.whereType<Map<String, dynamic>>().toList();
  }
  return const [];
}

String _string(dynamic value, {String fallback = ''}) {
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return fallback;
}

String? _nullableString(dynamic value) {
  final normalized = _string(value);
  return normalized.isEmpty ? null : normalized;
}

int _int(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
  }
  return 0;
}

double _double(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

double? _nullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) => _string(item))
        .where((item) => item.isNotEmpty)
        .toList();
  }
  return const [];
}
