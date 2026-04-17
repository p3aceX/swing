class SwingIndexSummary {
  const SwingIndexSummary({
    required this.swingIndexScore,
    required this.axes,
    this.strengths,
    this.weakestAreas,
  });

  final double swingIndexScore;
  final Map<String, double> axes;
  final List<SwingIndexInsight>? strengths;
  final List<SwingIndexInsight>? weakestAreas;

  factory SwingIndexSummary.fromJson(Map<String, dynamic> json) {
    return SwingIndexSummary(
      swingIndexScore: _toDouble(json['swingIndexScore']).clamp(0, 100),
      axes: _parseAxes(json['axes']),
      strengths: _parseInsights(json['strengths']),
      weakestAreas: _parseInsights(json['weakestAreas']),
    );
  }

  Map<String, double> orderedAxes() {
    return {
      for (final key in SwingIndexAxisKeys.ordered)
        key: _sanitizeScore(axes[key]),
    };
  }

  bool get hasAxisData => orderedAxes().values.any((value) => value > 0);

  static Map<String, double> _parseAxes(dynamic raw) {
    if (raw is! Map) {
      return const <String, double>{};
    }
    final parsed = <String, double>{};
    for (final entry in raw.entries) {
      final key = '${entry.key}'.trim();
      if (!SwingIndexAxisKeys.ordered.contains(key)) {
        continue;
      }
      parsed[key] = _sanitizeScore(_toDouble(entry.value));
    }
    return parsed;
  }

  static List<SwingIndexInsight>? _parseInsights(dynamic raw) {
    if (raw is! List) {
      return null;
    }
    final parsed = raw
        .whereType<Map>()
        .map(
          (item) => SwingIndexInsight.fromJson(
            Map<String, dynamic>.from(item.cast<Object?, Object?>()),
          ),
        )
        .toList(growable: false);
    if (parsed.isEmpty) {
      return null;
    }
    return parsed;
  }

  static double _sanitizeScore(double? value) {
    return (value ?? 0).clamp(0, 100).toDouble();
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }
}

class SwingIndexInsight {
  const SwingIndexInsight({
    required this.key,
    required this.score,
  });

  final String key;
  final double score;

  factory SwingIndexInsight.fromJson(Map<String, dynamic> json) {
    return SwingIndexInsight(
      key: '${json['key'] ?? ''}'.trim(),
      score: _toDouble(json['score']).clamp(0, 100),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }
}

class SwingIndexAxisKeys {
  static const String reliabilityAxis = 'reliabilityAxis';
  static const String powerAxis = 'powerAxis';
  static const String bowlingAxis = 'bowlingAxis';
  static const String fieldingAxis = 'fieldingAxis';
  static const String impactAxis = 'impactAxis';

  static const List<String> ordered = <String>[
    reliabilityAxis,
    powerAxis,
    bowlingAxis,
    fieldingAxis,
    impactAxis,
  ];
}

String swingIndexAxisLabel(String key) {
  return switch (key) {
    SwingIndexAxisKeys.reliabilityAxis => 'Reliability',
    SwingIndexAxisKeys.powerAxis => 'Power',
    SwingIndexAxisKeys.bowlingAxis => 'Bowling',
    SwingIndexAxisKeys.fieldingAxis => 'Fielding',
    SwingIndexAxisKeys.impactAxis => 'Impact',
    _ => key,
  };
}
