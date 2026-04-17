import 'package:flutter/foundation.dart';

enum HealthSyncStatus {
  disconnected,
  syncing,
  synced,
  error,
  permissionsDenied,
}

class HealthSyncState {
  final HealthSyncStatus status;
  final DateTime? lastSync;
  final String? errorMessage;

  const HealthSyncState({
    required this.status,
    this.lastSync,
    this.errorMessage,
  });

  factory HealthSyncState.initial() => const HealthSyncState(status: HealthSyncStatus.disconnected);

  HealthSyncState copyWith({
    HealthSyncStatus? status,
    DateTime? lastSync,
    String? errorMessage,
  }) {
    return HealthSyncState(
      status: status ?? this.status,
      lastSync: lastSync ?? this.lastSync,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class HealthMetric {
  final String type;
  final double value;
  final String unit;
  final DateTime timestamp;

  const HealthMetric({
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
  });
}

class SleepData {
  final DateTime start;
  final DateTime end;
  final int durationMinutes;

  const SleepData({
    required this.start,
    required this.end,
    required this.durationMinutes,
  });
}

class HealthDataPayload {
  final List<HealthMetric> metrics;
  final List<SleepData> sleep;
  final List<WorkoutData> workouts;

  const HealthDataPayload({
    this.metrics = const [],
    this.sleep = const [],
    this.workouts = const [],
  });
}

class WorkoutData {
  final String type;
  final int durationMinutes;
  final double calories;
  final DateTime timestamp;

  const WorkoutData({
    required this.type,
    required this.durationMinutes,
    required this.calories,
    required this.timestamp,
  });
}

class BodyComposition {
  final double weight;
  final double height;
  final double? bodyFatPercent; // optional — athlete-specific metric
  final DateTime updatedAt;

  const BodyComposition({
    required this.weight,
    required this.height,
    this.bodyFatPercent,
    required this.updatedAt,
  });

  double get bmi {
    final meters = height / 100;
    if (meters == 0) return 0;
    return weight / (meters * meters);
  }

  String get bmiCategory {
    final val = bmi;
    if (val < 18.5) return 'Underweight';
    if (val < 25) return 'Normal';
    if (val < 30) return 'Overweight';
    return 'Obese';
  }

  /// Lean mass in kg — only available when body fat % is set.
  double? get leanMassKg {
    final bf = bodyFatPercent;
    if (bf == null) return null;
    return weight * (1 - bf / 100);
  }
}
