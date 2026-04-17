import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/health_integration_models.dart';
import '../domain/health_models.dart';

class HealthRepository {
  final _client = ApiClient.instance.dio;

  Future<HealthDashboard> getDashboard() async {
    try {
      debugPrint(
          'Fetching health dashboard from: ${ApiEndpoints.healthDashboard}');
      final response = await _client.get(ApiEndpoints.healthDashboard);

      final data = _unwrapMapResponse(response.data);
      return _mapDashboard(data);
    } catch (e, stack) {
      debugPrint('HealthRepository.getDashboard error: $e');
      if (e is DioException && e.response?.statusCode == 404) {
        debugPrint(
            'Backend dashboard not found (404). Returning structural empty state.');
        return _emptyDashboard();
      }
      debugPrint('$stack');
      rethrow;
    }
  }

  HealthDashboard _emptyDashboard() {
    return const HealthDashboard(
      readiness: SwingReadiness(
        score: 0,
        label: 'No Data',
        description:
            'Log your first wellness and training session to see your readiness.',
        color: 'grey',
      ),
      recovery: RecoveryStats(
        percentage: 0,
        label: 'Pending',
        trend: 'stable',
      ),
      fatigue: FatigueStats(
        level: 0,
        label: 'Unknown',
        description: 'Sync health data to analyze fatigue.',
      ),
      freshness: FreshnessStats(
        score: 0,
        label: 'Unknown',
        description: 'Complete a session to track freshness.',
      ),
      workload: WorkloadStats(
        current7d: 0,
        baseline28d: 0,
        ratio: 0,
        label: 'No Data',
        status: 'unknown',
      ),
      wellness: WellnessStats(
        score: 0,
        label: 'Pending',
        soreness: 0,
        stress: 0,
        mood: 0,
        lastCheckIn: null,
      ),
      insights: [],
    );
  }

  Future<void> submitWellness(WellnessCheckIn checkIn) async {
    try {
      await _client.post(ApiEndpoints.wellness, data: checkIn.toJson());
    } catch (e) {
      debugPrint('HealthRepository.submitWellness error: $e');
      rethrow;
    }
  }

  Future<void> submitWorkload(WorkloadEvent event) async {
    try {
      await _client.post(ApiEndpoints.workload, data: event.toJson());
    } catch (e) {
      debugPrint('HealthRepository.submitWorkload error: $e');
      rethrow;
    }
  }

  Future<void> ingestWearableData(HealthDataPayload payload) async {
    final summary = _summarizePayload(payload);
    if (!summary.hasData) return;

    try {
      await _client.post(ApiEndpoints.wearablesIngest, data: summary.toJson());
    } catch (e) {
      debugPrint('HealthRepository.ingestWearableData error: $e');
      if (e is DioException && e.response?.statusCode == 404) {
        return;
      }
      rethrow;
    }
  }

  // ── Mappers ────────────────────────────────────────────────────────────────

  HealthDashboard _mapDashboard(Map<String, dynamic> json) {
    if (json.containsKey('readinessScore') ||
        json.containsKey('latestWellness') ||
        json.containsKey('workload7d')) {
      return _mapFlatDashboard(json);
    }

    final readiness = _map(json['readiness']);
    final recovery = _map(json['recovery']);
    final fatigue = _map(json['fatigue']);
    final freshness = _map(json['freshness']);
    final workload = _map(json['workload']);
    final wellness = _map(json['wellness']);
    final bowling =
        json['bowlingLoad'] != null ? _map(json['bowlingLoad']) : null;
    final batting =
        json['battingLoad'] != null ? _map(json['battingLoad']) : null;
    final insights = _list(json['insights']);

    return HealthDashboard(
      readiness: SwingReadiness(
        score: _int(readiness['score']),
        label: _string(readiness['label']),
        description: _string(readiness['description']),
        color: _string(readiness['color']),
      ),
      recovery: RecoveryStats(
        percentage: _int(recovery['percentage']),
        label: _string(recovery['label']),
        trend: _string(recovery['trend']),
      ),
      fatigue: FatigueStats(
        level: _int(fatigue['level']),
        label: _string(fatigue['label']),
        description: _string(fatigue['description']),
      ),
      freshness: FreshnessStats(
        score: _int(freshness['score']),
        label: _string(freshness['label']),
        description: _string(freshness['description']),
      ),
      workload: WorkloadStats(
        current7d: _double(workload['current7d']),
        baseline28d: _double(workload['baseline28d']),
        ratio: _double(workload['ratio']),
        label: _string(workload['label']),
        status: _string(workload['status']),
      ),
      wellness: WellnessStats(
        score: _int(wellness['score']),
        label: _string(wellness['label']),
        soreness: _int(wellness['soreness']),
        stress: _int(wellness['stress']),
        mood: _int(wellness['mood']),
        lastCheckIn: _date(wellness['lastCheckIn']),
      ),
      bowlingLoad: bowling != null
          ? BowlingLoad(
              balls: _int(bowling['balls']),
              intensity: _string(bowling['intensity']),
              label: _string(bowling['label']),
            )
          : null,
      battingLoad: batting != null
          ? BattingLoad(
              balls: _int(batting['balls']),
              intensity: _string(batting['intensity']),
              label: _string(batting['label']),
            )
          : null,
      insights: insights
          .map((i) => HealthInsight(
                title: _string(i['title']),
                message: _string(i['message']),
                type: _string(i['type']),
              ))
          .toList(),
    );
  }

  HealthDashboard _mapFlatDashboard(Map<String, dynamic> json) {
    final latestWellness = _map(json['latestWellness']);
    final latestPhysical = _map(json['latestPhysicalSample']);
    final workload7d = _map(json['workload7d']);
    final workload28d = _map(json['workload28d']);
    final readinessScore = _int(json['readinessScore']);
    final freshnessScore = _int(json['freshnessScore']);
    final workloadStatus = _string(json['workloadStatus']).toUpperCase();
    final recoveryStatus = _string(json['recoveryStatus']).toUpperCase();
    final rawInsights = _list(json['insights']);

    final currentLoad = _loadUnits(workload7d);
    final baselineLoad = _loadUnits(workload28d) / 4;
    final ratio = baselineLoad > 0 ? currentLoad / baselineLoad : 0.0;
    final soreness = _int(latestWellness['soreness']);
    final stress = _int(latestWellness['stress']);
    final mood = _int(latestWellness['mood']);
    final fatigue = _int(latestWellness['fatigue']);
    final sleepQuality = _int(latestWellness['sleepQuality']);
    final wellnessInputs = [soreness, fatigue, mood, stress, sleepQuality]
        .where((value) => value > 0)
        .toList();
    final wellnessScore = wellnessInputs.isEmpty
        ? readinessScore
        : (wellnessInputs.reduce((left, right) => left + right) /
                wellnessInputs.length *
                10)
            .round();
    final insightMessages = rawInsights
        .map((item) => item?.toString() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();

    return HealthDashboard(
      readiness: SwingReadiness(
        score: readinessScore,
        label: _readinessLabel(readinessScore),
        description: insightMessages.isNotEmpty
            ? insightMessages.first
            : _readinessDescription(readinessScore, workloadStatus),
        color: _readinessColor(readinessScore),
      ),
      recovery: RecoveryStats(
        percentage: _recoveryPercentage(recoveryStatus, latestPhysical),
        label: _titleCase(recoveryStatus.isEmpty ? 'MODERATE' : recoveryStatus),
        trend: 'stable',
      ),
      fatigue: FatigueStats(
        level: fatigue > 0
            ? fatigue
            : _fatigueLevel(freshnessScore, workloadStatus),
        label: _fatigueLabel(fatigue > 0
            ? fatigue
            : _fatigueLevel(freshnessScore, workloadStatus)),
        description: _fatigueDescription(workloadStatus, insightMessages),
      ),
      freshness: FreshnessStats(
        score: freshnessScore,
        label: _freshnessLabel(freshnessScore),
        description: _freshnessDescription(freshnessScore),
      ),
      workload: WorkloadStats(
        current7d: currentLoad,
        baseline28d: baselineLoad,
        ratio: ratio,
        label: _titleCase(workloadStatus.isEmpty ? 'OPTIMAL' : workloadStatus),
        status: workloadStatus.toLowerCase(),
      ),
      wellness: WellnessStats(
        score: wellnessScore,
        label: latestWellness.isEmpty ? 'Pending' : 'Logged',
        soreness: soreness,
        stress: stress,
        mood: mood,
        lastCheckIn: _date(latestWellness['date']),
      ),
      bowlingLoad: (workload7d['totalBalls'] != null ||
              workload7d['totalOvers'] != null)
          ? BowlingLoad(
              balls: _int(workload7d['totalBalls']) > 0
                  ? _int(workload7d['totalBalls'])
                  : (_double(workload7d['totalOvers']) * 6).round(),
              intensity: _intensityLabel(_double(workload7d['intensityAvg'])),
              label: _titleCase(
                  workloadStatus.isEmpty ? 'OPTIMAL' : workloadStatus),
            )
          : null,
      battingLoad: _int(workload7d['totalBallsFaced']) > 0
          ? BattingLoad(
              balls: _int(workload7d['totalBallsFaced']),
              intensity: _intensityLabel(_double(workload7d['intensityAvg'])),
              label: _titleCase(
                  workloadStatus.isEmpty ? 'OPTIMAL' : workloadStatus),
            )
          : null,
      insights: insightMessages
          .map((message) => HealthInsight(
                title: _insightTitle(message),
                message: message,
                type: _insightType(message),
              ))
          .toList(),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Map<String, dynamic> _unwrapMapResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data')) return _map(data['data']);
      return data;
    }
    return const {};
  }

  String _string(dynamic v) => v?.toString() ?? '';
  int _int(dynamic v) => v is num ? v.toInt() : int.tryParse(_string(v)) ?? 0;
  double _double(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse(_string(v)) ?? 0.0;
  DateTime? _date(dynamic v) =>
      v == null ? null : DateTime.tryParse(_string(v));
  List<dynamic> _list(dynamic v) => v is List ? v : [];
  Map<String, dynamic> _map(dynamic v) =>
      v is Map ? v.cast<String, dynamic>() : {};

  double _loadUnits(Map<String, dynamic> summary) {
    final duration = _double(summary['totalDuration']);
    final intensity = _double(summary['intensityAvg']);
    return intensity > 0 ? duration * intensity : duration;
  }

  int _recoveryPercentage(String status, Map<String, dynamic> latestPhysical) {
    final rawScore = _double(latestPhysical['recoveryScore']);
    if (rawScore > 0) return rawScore.round();
    return switch (status) {
      'GOOD' => 84,
      'LOW' => 38,
      _ => 62,
    };
  }

  String _readinessLabel(int score) {
    if (score >= 85) return 'Peak Ready';
    if (score >= 70) return 'Ready';
    if (score >= 55) return 'Caution';
    return 'Recovery';
  }

  String _readinessDescription(int score, String workloadStatus) {
    if (workloadStatus == 'OVERLOAD') {
      return 'Recent load is high. Pull volume down and protect recovery.';
    }
    if (score >= 75) {
      return 'You are in a solid state for quality training today.';
    }
    if (score >= 55) {
      return 'Keep intensity controlled and monitor soreness closely.';
    }
    return 'Prioritize recovery inputs before another hard session.';
  }

  String _readinessColor(int score) {
    if (score >= 85) return 'green';
    if (score >= 70) return 'sky';
    if (score >= 55) return 'amber';
    return 'red';
  }

  int _fatigueLevel(int freshnessScore, String workloadStatus) {
    if (workloadStatus == 'OVERLOAD') return 8;
    if (freshnessScore >= 75) return 3;
    if (freshnessScore >= 55) return 5;
    return 7;
  }

  String _fatigueLabel(int level) {
    if (level >= 8) return 'High';
    if (level >= 5) return 'Moderate';
    return 'Low';
  }

  String _fatigueDescription(String workloadStatus, List<String> insights) {
    if (insights.isNotEmpty) return insights.first;
    if (workloadStatus == 'OVERLOAD') {
      return 'Acute load is above baseline. Recovery quality matters right now.';
    }
    if (workloadStatus == 'UNDERLOAD') {
      return 'Recent training volume is light compared with your baseline.';
    }
    return 'Fatigue is being tracked from wellness and recent training load.';
  }

  String _freshnessLabel(int score) {
    if (score >= 80) return 'Sharp';
    if (score >= 60) return 'Balanced';
    return 'Heavy';
  }

  String _freshnessDescription(int score) {
    if (score >= 80) return 'Body is responding well to recent work.';
    if (score >= 60) return 'Training load is manageable today.';
    return 'Recovery is lagging behind recent work.';
  }

  String _intensityLabel(double value) {
    if (value >= 8) return 'High';
    if (value >= 5) return 'Moderate';
    if (value > 0) return 'Low';
    return 'Unknown';
  }

  String _insightTitle(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('injury')) return 'Risk Alert';
    if (lower.contains('sleep')) return 'Sleep';
    if (lower.contains('bowling')) return 'Bowling Load';
    if (lower.contains('workload')) return 'Workload';
    return 'Coach Note';
  }

  String _insightType(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('injury') ||
        lower.contains('poor') ||
        lower.contains('high')) {
      return 'warning';
    }
    return 'info';
  }

  String _titleCase(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    final lower = trimmed.toLowerCase();
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }

  _WearableIngestSummary _summarizePayload(HealthDataPayload payload) {
    double calories = 0;
    double distanceMeters = 0;
    double exerciseMinutes = 0;
    double steps = 0;
    double hrvTotal = 0;
    int hrvCount = 0;
    double heartRateTotal = 0;
    int heartRateCount = 0;
    double maxHeartRate = 0;
    HealthMetric? latestWeight;
    DateTime? firstSampleAt;
    DateTime? lastSampleAt;

    void includeTimestamp(DateTime value) {
      if (firstSampleAt == null || value.isBefore(firstSampleAt!)) {
        firstSampleAt = value;
      }
      if (lastSampleAt == null || value.isAfter(lastSampleAt!)) {
        lastSampleAt = value;
      }
    }

    for (final metric in payload.metrics) {
      final type = metric.type.toUpperCase();
      includeTimestamp(metric.timestamp);

      if (type.contains('STEPS')) {
        steps += metric.value;
      } else if (type.contains('ACTIVE_ENERGY') ||
          type.contains('TOTAL_CALORIES')) {
        calories += metric.value;
      } else if (type.contains('DISTANCE')) {
        distanceMeters += metric.value;
      } else if (type.contains('EXERCISE_TIME')) {
        exerciseMinutes += metric.value;
      } else if (type.contains('RESTING_HEART_RATE')) {
        heartRateTotal += metric.value;
        heartRateCount += 1;
        if (metric.value > maxHeartRate) maxHeartRate = metric.value;
      } else if (type.contains('HEART_RATE') && !type.contains('VARIABILITY')) {
        heartRateTotal += metric.value;
        heartRateCount += 1;
        if (metric.value > maxHeartRate) maxHeartRate = metric.value;
      } else if (type.contains('VARIABILITY') || type.contains('HRV')) {
        hrvTotal += metric.value;
        hrvCount += 1;
      } else if (type.contains('WEIGHT')) {
        if (latestWeight == null ||
            metric.timestamp.isAfter(latestWeight.timestamp)) {
          latestWeight = metric;
        }
      }
    }

    for (final sleep in payload.sleep) {
      includeTimestamp(sleep.start);
      includeTimestamp(sleep.end);
    }

    for (final workout in payload.workouts) {
      includeTimestamp(workout.timestamp);
      if (workout.calories > 0) calories += workout.calories;
      exerciseMinutes += workout.durationMinutes;
    }

    final sleepMinutes =
        payload.sleep.fold<int>(0, (sum, item) => sum + item.durationMinutes);
    final sleepStartAt = payload.sleep.isEmpty
        ? null
        : payload.sleep
            .map((item) => item.start)
            .reduce((a, b) => a.isBefore(b) ? a : b);
    final sleepEndAt = payload.sleep.isEmpty
        ? null
        : payload.sleep
            .map((item) => item.end)
            .reduce((a, b) => a.isAfter(b) ? a : b);

    return _WearableIngestSummary(
      sampleStartAt: firstSampleAt,
      sampleEndAt: lastSampleAt,
      caloriesBurned: calories > 0 ? calories : null,
      averageHeartRate:
          heartRateCount > 0 ? heartRateTotal / heartRateCount : null,
      maxHeartRate: maxHeartRate > 0 ? maxHeartRate : null,
      distanceMeters: distanceMeters > 0 ? distanceMeters : null,
      activeMinutes: exerciseMinutes > 0 ? exerciseMinutes : null,
      sleepHours: sleepMinutes > 0 ? sleepMinutes / 60 : null,
      steps: steps > 0 ? steps.round() : null,
      hrv: hrvCount > 0 ? hrvTotal / hrvCount : null,
      sleepStartAt: sleepStartAt,
      sleepEndAt: sleepEndAt,
      weightKg: latestWeight?.value,
      rawPayload: {
        'metricCount': payload.metrics.length,
        'sleepCount': payload.sleep.length,
        'workoutCount': payload.workouts.length,
      },
    );
  }
}

class _WearableIngestSummary {
  const _WearableIngestSummary({
    required this.sampleStartAt,
    required this.sampleEndAt,
    required this.caloriesBurned,
    required this.averageHeartRate,
    required this.maxHeartRate,
    required this.distanceMeters,
    required this.activeMinutes,
    required this.sleepHours,
    required this.steps,
    required this.hrv,
    required this.sleepStartAt,
    required this.sleepEndAt,
    required this.weightKg,
    required this.rawPayload,
  });

  final DateTime? sampleStartAt;
  final DateTime? sampleEndAt;
  final double? caloriesBurned;
  final double? averageHeartRate;
  final double? maxHeartRate;
  final double? distanceMeters;
  final double? activeMinutes;
  final double? sleepHours;
  final int? steps;
  final double? hrv;
  final DateTime? sleepStartAt;
  final DateTime? sleepEndAt;
  final double? weightKg;
  final Map<String, dynamic> rawPayload;

  bool get hasData =>
      caloriesBurned != null ||
      averageHeartRate != null ||
      distanceMeters != null ||
      activeMinutes != null ||
      sleepHours != null ||
      steps != null ||
      hrv != null ||
      weightKg != null;

  Map<String, dynamic> toJson() => {
        'sampleStartAt': (sampleStartAt ?? DateTime.now()).toIso8601String(),
        'sampleEndAt': (sampleEndAt ?? DateTime.now()).toIso8601String(),
        if (caloriesBurned != null) 'caloriesBurned': caloriesBurned,
        if (averageHeartRate != null) 'averageHeartRate': averageHeartRate,
        if (maxHeartRate != null) 'maxHeartRate': maxHeartRate,
        if (distanceMeters != null) 'distanceMeters': distanceMeters,
        if (activeMinutes != null) 'activeMinutes': activeMinutes,
        if (sleepHours != null) 'sleepHours': sleepHours,
        if (steps != null) 'steps': steps,
        if (hrv != null) 'hrv': hrv,
        if (sleepStartAt != null)
          'sleepStartAt': sleepStartAt!.toIso8601String(),
        if (sleepEndAt != null) 'sleepEndAt': sleepEndAt!.toIso8601String(),
        if (weightKg != null) 'weightKg': weightKg,
        'source': 'HEALTH_CONNECT',
        'rawPayload': rawPayload,
      };
}
