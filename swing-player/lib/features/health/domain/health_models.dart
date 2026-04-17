// ignore_for_file: constant_identifier_names

class HealthDashboard {
  const HealthDashboard({
    required this.readiness,
    required this.recovery,
    required this.fatigue,
    required this.freshness,
    required this.workload,
    required this.wellness,
    this.bowlingLoad,
    this.battingLoad,
    this.insights = const [],
  });

  final SwingReadiness readiness;
  final RecoveryStats recovery;
  final FatigueStats fatigue;
  final FreshnessStats freshness;
  final WorkloadStats workload;
  final WellnessStats wellness;
  final BowlingLoad? bowlingLoad;
  final BattingLoad? battingLoad;
  final List<HealthInsight> insights;
}

class SwingReadiness {
  const SwingReadiness({
    required this.score,
    required this.label,
    required this.description,
    required this.color,
  });

  final int score;
  final String label;
  final String description;
  final String color;
}

class RecoveryStats {
  const RecoveryStats({
    required this.percentage,
    required this.label,
    required this.trend,
  });

  final int percentage;
  final String label;
  final String trend;
}

class FatigueStats {
  const FatigueStats({
    required this.level,
    required this.label,
    required this.description,
  });

  final int level; // 1-10
  final String label;
  final String description;
}

class FreshnessStats {
  const FreshnessStats({
    required this.score,
    required this.label,
    required this.description,
  });

  final int score;
  final String label;
  final String description;
}

class WorkloadStats {
  const WorkloadStats({
    required this.current7d,
    required this.baseline28d,
    required this.ratio,
    required this.label,
    required this.status,
  });

  final double current7d;
  final double baseline28d;
  final double ratio;
  final String label;
  final String status;
}

class WellnessStats {
  const WellnessStats({
    required this.score,
    required this.label,
    required this.soreness,
    required this.stress,
    required this.mood,
    this.lastCheckIn,
  });

  final int score;
  final String label;
  final int soreness;
  final int stress;
  final int mood;
  final DateTime? lastCheckIn;
}

class BowlingLoad {
  const BowlingLoad({
    required this.balls,
    required this.intensity,
    required this.label,
  });

  final int balls;
  final String intensity;
  final String label;
}

class BattingLoad {
  const BattingLoad({
    required this.balls,
    required this.intensity,
    required this.label,
  });

  final int balls;
  final String intensity;
  final String label;
}

class HealthInsight {
  const HealthInsight({
    required this.title,
    required this.message,
    required this.type,
  });

  final String title;
  final String message;
  final String type;
}

// ── Wellness Check-in Models ──────────────────────────────────────────────────

class WellnessCheckIn {
  const WellnessCheckIn({
    required this.soreness,
    required this.fatigue,
    required this.mood,
    required this.stress,
    required this.painTightness,
    required this.sleepQuality,
    this.date,
    this.notes,
  });

  final int soreness;
  final int fatigue;
  final int mood;
  final int stress;
  final int painTightness;
  final int sleepQuality;
  final DateTime? date;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'date': _healthDate(date ?? DateTime.now()),
        'soreness': soreness,
        'fatigue': fatigue,
        'mood': mood,
        'stress': stress,
        'painTightness': painTightness,
        'sleepQuality': sleepQuality,
        if (notes != null) 'notes': notes,
      };
}

// ── Workload Logging Models ───────────────────────────────────────────────────

enum WorkloadType {
  MATCH,
  BATTING_NETS,
  BOWLING_NETS,
  FIELDING,
  STRENGTH,
  RUNNING,
  CONDITIONING,
  MOBILITY,
  REHAB
}

class WorkloadEvent {
  const WorkloadEvent({
    required this.type,
    required this.durationMinutes,
    required this.intensity,
    this.oversBowled,
    this.ballsBowled,
    this.battingMinutes,
    this.ballsFaced,
    this.spellCount,
    this.source,
    this.sourceRefId,
    this.notes,
    this.occurredAt,
  });

  final WorkloadType type;
  final int durationMinutes;
  final int intensity; // 1-10
  final double? oversBowled;
  final int? ballsBowled;
  final int? battingMinutes;
  final int? ballsFaced;
  final int? spellCount;
  final String? source;
  final String? sourceRefId;
  final String? notes;
  final DateTime? occurredAt;

  Map<String, dynamic> toJson() => {
        'type': type.apiValue,
        'date': _healthDate(occurredAt ?? DateTime.now()),
        'durationMinutes': durationMinutes,
        'intensity': intensity,
        if (oversBowled != null) 'oversBowled': oversBowled,
        if (ballsBowled != null) 'ballsBowled': ballsBowled,
        if (battingMinutes != null) 'battingMinutes': battingMinutes,
        if (ballsFaced != null) 'ballsFaced': ballsFaced,
        if (spellCount != null) 'spellCount': spellCount,
        if (source != null) 'source': source,
        if (sourceRefId != null) 'sourceRefId': sourceRefId,
        if (notes != null) 'notes': notes,
      };
}

extension WorkloadTypeApi on WorkloadType {
  String get apiValue => switch (this) {
        WorkloadType.CONDITIONING => WorkloadType.RUNNING.name,
        _ => name,
      };
}

String _healthDate(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}
