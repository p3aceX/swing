import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/elite_models.dart';

class EliteRepository {
  final Dio _dio;

  EliteRepository(this._dio);

  Future<EliteProfile> fetchProfile(String playerId) async {
    final response = await _dio.get(ApiEndpoints.elitePlayerProfile(playerId));
    final data = response.data as Map<String, dynamic>;
    final body = _asMap(data['data'] ?? data);

    // Debug full body
    debugPrint('[EliteRepo] body: $body');

    return EliteProfile.fromJson(body);
  }

  Future<ApexState> fetchApexState(String playerId) async {
    final response = await _dio.get(ApiEndpoints.elitePlayerApexState(playerId));
    final data = response.data as Map<String, dynamic>;
    debugPrint('[EliteRepo] ApexState raw: ${jsonEncode(data)}');
    return ApexState.fromJson(data);
  }

  Map<String, dynamic> _asMap(dynamic val) =>
      (val is Map) ? Map<String, dynamic>.from(val) : <String, dynamic>{};

  List<dynamic> _asList(dynamic val) => (val is List) ? val : const [];

  // ── My Plan ──────────────────────────────────────────────────────────────────

  /// Returns null gracefully when backend endpoint doesn't exist yet.
  Future<MyPlan?> fetchMyPlan() async {
    try {
      final response = await _dio.get(ApiEndpoints.eliteMyPlan);
      final data = _asMap(response.data);
      debugPrint('[EliteRepo] MyPlan GET response: ${jsonEncode(data)}');
      if (_isWeeklyPlanEnvelope(data)) {
        final weekly = WeeklyPlan.fromJson(data);
        return _legacyPlanFromWeekly(weekly);
      }
      return MyPlan.fromJson(data);
    } on DioException catch (e) {
      debugPrint(
          '[EliteRepo] MyPlan GET FAILED: status=${e.response?.statusCode}, body=${e.response?.data}');
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> saveMyPlan(MyPlan plan) async {
    final payload = _buildWeeklyPayloadFromLegacyPlan(plan);
    debugPrint('[EliteRepo] Saving MyPlan: ${jsonEncode(payload)}');
    try {
      final existing = await getMyPlan();
      final response = existing == null
          ? await _dio.post(ApiEndpoints.eliteMyPlan, data: payload)
          : await _dio.patch(ApiEndpoints.eliteMyPlan, data: payload);
      debugPrint('[EliteRepo] MyPlan SAVE response: ${response.data}');
    } on DioException catch (e) {
      debugPrint(
          '[EliteRepo] MyPlan SAVE FAILED: status=${e.response?.statusCode}, body=${e.response?.data}');
      rethrow;
    }
  }

  bool _isWeeklyPlanEnvelope(Map<String, dynamic> raw) {
    final data = _asMap(raw['data']);
    final plan = _asMap(data['plan']);
    return plan.isNotEmpty && _asList(plan['days']).isNotEmpty;
  }

  Set<int> _defaultDaysForCount(int count) {
    final safe = count < 1 ? 1 : (count > 7 ? 7 : count);
    switch (safe) {
      case 1:
        return {3};
      case 2:
        return {2, 5};
      case 3:
        return {1, 3, 5};
      case 4:
        return {1, 2, 4, 6};
      case 5:
        return {1, 2, 3, 5, 6};
      case 6:
        return {1, 2, 3, 4, 5, 6};
      case 7:
        return {1, 2, 3, 4, 5, 6, 7};
      default:
        return {3};
    }
  }

  Set<int> _daysForActivity(PlannedActivity activity) {
    final fromModel = activity.days.where((d) => d >= 1 && d <= 7).toSet();
    if (fromModel.isNotEmpty) return fromModel;
    return _defaultDaysForCount(activity.timesPerWeek);
  }

  MyPlan _legacyPlanFromWeekly(WeeklyPlan weekly) {
    final daySets = <ActivityCategory, Set<int>>{
      ActivityCategory.nets: <int>{},
      ActivityCategory.skillWork: <int>{},
      ActivityCategory.conditioning: <int>{},
      ActivityCategory.gym: <int>{},
      ActivityCategory.match: <int>{},
      ActivityCategory.recovery: <int>{},
    };

    for (var i = 0; i < weekly.days.length; i++) {
      final day = weekly.days[i];
      final dayIndex = i + 1;

      if (day.netsMinutes > 0) {
        daySets[ActivityCategory.nets]!.add(dayIndex);
      }

      final drills = day.drillsMinutes;
      final hasMatch = drills >= 90;
      final hasSkill = drills > 0 && (drills < 90 || drills % 90 != 0);
      if (hasSkill) {
        daySets[ActivityCategory.skillWork]!.add(dayIndex);
      }
      if (hasMatch) {
        daySets[ActivityCategory.match]!.add(dayIndex);
      }

      final fitness = day.fitnessMinutes;
      if (fitness >= 75) {
        daySets[ActivityCategory.conditioning]!.add(dayIndex);
        daySets[ActivityCategory.gym]!.add(dayIndex);
      } else if (fitness >= 45) {
        daySets[ActivityCategory.gym]!.add(dayIndex);
      } else if (fitness > 0) {
        daySets[ActivityCategory.conditioning]!.add(dayIndex);
      }

      if (day.recoveryMinutes > 0) {
        daySets[ActivityCategory.recovery]!.add(dayIndex);
      }
    }

    const ordered = [
      ActivityCategory.nets,
      ActivityCategory.skillWork,
      ActivityCategory.conditioning,
      ActivityCategory.gym,
      ActivityCategory.match,
      ActivityCategory.recovery,
    ];

    final activities = <PlannedActivity>[];
    for (final category in ordered) {
      final days = (daySets[category] ?? <int>{}).toList()..sort();
      if (days.isEmpty) continue;
      activities.add(
        PlannedActivity(
          category: category,
          timesPerWeek: days.length,
          days: days,
        ),
      );
    }

    final hasDays = weekly.days.isNotEmpty;
    final sleepAvg = hasDays
        ? weekly.days.map((d) => d.sleepTargetHours).reduce((a, b) => a + b) /
            weekly.days.length
        : 8.0;
    final hydrationAvg = hasDays
        ? weekly.days
                .map((d) => d.hydrationTargetLiters)
                .reduce((a, b) => a + b) /
            weekly.days.length
        : 3.0;

    return MyPlan(
      name: weekly.name,
      activities: activities,
      sleepTargetHours: sleepAvg,
      hydrationTargetLiters: hydrationAvg,
    );
  }

  Map<String, dynamic> _buildWeeklyPayloadFromLegacyPlan(MyPlan plan) {
    final buckets = List.generate(
      7,
      (_) => {
        'netsMinutes': 0,
        'drillsMinutes': 0,
        'fitnessMinutes': 0,
        'recoveryMinutes': 0,
      },
    );

    for (final activity in plan.activities) {
      final days = _daysForActivity(activity);
      for (final day in days) {
        final idx = day - 1;
        if (idx < 0 || idx >= buckets.length) continue;
        switch (activity.category) {
          case ActivityCategory.nets:
            buckets[idx]['netsMinutes'] =
                (buckets[idx]['netsMinutes'] as int) + 60;
            break;
          case ActivityCategory.skillWork:
            buckets[idx]['drillsMinutes'] =
                (buckets[idx]['drillsMinutes'] as int) + 30;
            break;
          case ActivityCategory.conditioning:
            buckets[idx]['fitnessMinutes'] =
                (buckets[idx]['fitnessMinutes'] as int) + 30;
            break;
          case ActivityCategory.gym:
            buckets[idx]['fitnessMinutes'] =
                (buckets[idx]['fitnessMinutes'] as int) + 45;
            break;
          case ActivityCategory.match:
            buckets[idx]['drillsMinutes'] =
                (buckets[idx]['drillsMinutes'] as int) + 90;
            break;
          case ActivityCategory.recovery:
            buckets[idx]['recoveryMinutes'] =
                (buckets[idx]['recoveryMinutes'] as int) + 30;
            break;
        }
      }
    }

    const weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final sleep = plan.sleepTargetHours <= 0 ? 8.0 : plan.sleepTargetHours;
    final hydration =
        plan.hydrationTargetLiters <= 0 ? 3.0 : plan.hydrationTargetLiters;

    final daysPayload = List.generate(7, (index) {
      final day = buckets[index];
      return {
        'weekday': weekdays[index],
        'netsMinutes': day['netsMinutes'],
        'drillsMinutes': day['drillsMinutes'],
        'fitnessMinutes': day['fitnessMinutes'],
        'recoveryMinutes': day['recoveryMinutes'],
        'sleepTargetHours': sleep,
        'hydrationTargetLiters': hydration,
      };
    });

    final name = plan.name.trim().isEmpty ? 'My Weekly Plan' : plan.name.trim();
    return {
      'name': name,
      'isActive': true,
      'days': daysPayload,
    };
  }

  Future<void> deleteMyPlan() async {
    try {
      await _dio.delete(ApiEndpoints.eliteMyPlan);
      debugPrint('[EliteRepo] WeeklyPlan DELETE successful');
    } on DioException catch (e) {
      debugPrint('[EliteRepo] WeeklyPlan DELETE FAILED: status=${e.response?.statusCode}');
      rethrow;
    }
  }

  Future<WeeklyPlan?> getMyPlan() async {
    try {
      final response = await _dio.get(ApiEndpoints.eliteMyPlan);
      final data = _asMap(response.data);
      debugPrint('[EliteRepo] WeeklyPlan GET response: ${jsonEncode(data)}');

      final body = _asMap(data['data']);
      final plan = _asMap(body['plan']);
      if (plan.isEmpty) return null;
      return WeeklyPlan.fromJson(data);
    } on DioException catch (e) {
      debugPrint(
          '[EliteRepo] WeeklyPlan GET FAILED: status=${e.response?.statusCode}, body=${e.response?.data}');
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<WeeklyPlan> createMyPlan(WeeklyPlan plan) async {
    final payload = Map<String, dynamic>.from(plan.toJson())..remove('id');
    debugPrint('[EliteRepo] WeeklyPlan CREATE payload: ${jsonEncode(payload)}');
    final response = await _dio.post(ApiEndpoints.eliteMyPlan, data: payload);
    final data = _asMap(response.data);
    debugPrint('[EliteRepo] WeeklyPlan CREATE response: ${jsonEncode(data)}');
    final body = _asMap(data['data']);
    final planMap = _asMap(body['plan']);
    if (planMap.isNotEmpty) {
      return WeeklyPlan.fromJson(data);
    }
    return plan;
  }

  Future<WeeklyPlan> updateMyPlan(WeeklyPlan plan) async {
    final payload = Map<String, dynamic>.from(plan.toJson())..remove('id');
    debugPrint('[EliteRepo] WeeklyPlan UPDATE payload: ${jsonEncode(payload)}');
    final response = await _dio.patch(ApiEndpoints.eliteMyPlan, data: payload);
    final data = _asMap(response.data);
    debugPrint('[EliteRepo] WeeklyPlan UPDATE response: ${jsonEncode(data)}');
    final body = _asMap(data['data']);
    final planMap = _asMap(body['plan']);
    if (planMap.isNotEmpty) {
      return WeeklyPlan.fromJson(data);
    }
    return plan;
  }

  Future<void> submitActivityJournal(
      String playerId, ActivityJournalEntry entry) async {
    final payload = entry.toApiJson();
    debugPrint('[EliteRepo] Submitting activity journal for $playerId');
    try {
      await _dio.post(ApiEndpoints.elitePlayerJournal(playerId), data: payload);
      debugPrint('[EliteRepo] Activity journal submitted successfully');
    } catch (e) {
      debugPrint('[EliteRepo] Activity journal FAILED: $e');
      if (e is DioException) debugPrint('[EliteRepo] ${e.response?.data}');
      rethrow;
    }
  }

  Future<void> submitPerformanceLog(
      String playerId, ElitePerformanceLog log) async {
    // Mapping Performance Audit Log UI state to the verified Journal API structure
    final entry = EliteJournalEntry(
      date: log.date.toUtc(),
      activityType:
          log.type == LogType.TRAINING && (log.sessions?.isNotEmpty ?? false)
              ? log.sessions!.first.type
              : log.type.name,
      durationMinutes:
          log.type == LogType.TRAINING && (log.sessions?.isNotEmpty ?? false)
              ? log.sessions!.first.actualDuration
              : 60,
      intensity:
          log.type == LogType.TRAINING && (log.sessions?.isNotEmpty ?? false)
              ? log.sessions!.first.actualIntensity
              : log.dayState.motivation,
      drillIds:
          log.type == LogType.TRAINING && (log.sessions?.isNotEmpty ?? false)
              ? log.sessions!.first.drills.map((d) => d.drillId).toList()
              : [],
      notes: log.dayTakeaway,
      mental: EliteMentalStats(
        confidence: log.dayState.motivation,
        focus: log.dayState.mentalFreshness,
        resilience: log.dayState.mentalFreshness,
      ),
      context: EliteContextStats(
        sleepQuality: log.dayState.sleepQuality,
        hydrationLiters: log.dayState.hydrationLiters,
        soreness: log.dayState.soreness,
        fatigue: log.dayState.fatigue,
        mood: log.dayState.motivation,
        stress: (10 - log.dayState.mentalFreshness).toInt(),
      ),
    );

    final payload = entry.toJson();
    debugPrint('[EliteRepo] Submitting via Journal API for $playerId');
    debugPrint('[EliteRepo] Payload: ${jsonEncode(payload)}');
    try {
      await _dio.post(
        ApiEndpoints.elitePlayerJournal(playerId),
        data: payload,
      );
      debugPrint('[EliteRepo] Journal submitted successfully');
    } catch (e) {
      debugPrint('[EliteRepo] Submission FAILED: $e');
      if (e is DioException) {
        debugPrint('[EliteRepo] Response: ${e.response?.data}');
      }
      rethrow;
    }
  }

  // ── Plan → Execution ────────────────────────────────────────────────────────

  Future<DayLog> fetchDayLog(String date) async {
    final response = await _dio.get(ApiEndpoints.eliteDayLog(date));
    final data = response.data as Map<String, dynamic>;
    return DayLog.fromJson(data);
  }

  Future<ApexDayLog> getDayLog(String date) async {
    final response = await _dio.get(ApiEndpoints.eliteDayLog(date));
    final data = _asMap(response.data);
    return ApexDayLog.fromJson(data);
  }

  Future<void> updateDayPlan(String date, DayPlanUpdate plan) async {
    await _dio.patch(
      ApiEndpoints.eliteDayLogPlan(date),
      data: plan.toJson(),
    );
  }

  Future<ApexDayLog> updateApexDayPlan(
      String date, ApexDayPlanPatch patch) async {
    final response = await _dio.patch(
      ApiEndpoints.eliteDayLogPlan(date),
      data: patch.toJson(),
    );
    final data = _asMap(response.data);
    final envelope = _asMap(data['data']);
    final dayLog = _asMap(envelope['dayLog']);
    if (dayLog.isNotEmpty) {
      return ApexDayLog.fromJson(data);
    }
    return getDayLog(date);
  }

  Future<DayLog> submitExecution(
      String date, ExecutionSubmission submission) async {
    final response = await _dio.post(
      ApiEndpoints.eliteDayLogExecute(date),
      data: submission.toJson(),
    );
    final data = response.data as Map<String, dynamic>;
    return DayLog.fromJson(data);
  }

  Future<ApexDayLog> submitDayExecution(
      String date, ApexDayExecutionSubmit submission) async {
    final response = await _dio.post(
      ApiEndpoints.eliteDayLogExecute(date),
      data: submission.toJson(),
    );
    final data = _asMap(response.data);
    final envelope = _asMap(data['data']);
    final dayLog = _asMap(envelope['dayLog']);
    if (dayLog.isNotEmpty) {
      return ApexDayLog.fromJson(data);
    }
    return getDayLog(date);
  }

  Future<List<ExecutionStreakEntry>> fetchExecutionStreak() async {
    try {
      final response = await _dio.get(ApiEndpoints.eliteExecutionStreak);
      final data = response.data as Map<String, dynamic>;
      final list = (data['data'] is List)
          ? data['data'] as List
          : (data is List ? data as List : []);
      return list
          .map((e) => ExecutionStreakEntry.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint(
            '[EliteRepo] execution-streak endpoint missing (404). Returning empty list.');
        return const [];
      }
      rethrow;
    }
  }

  Future<JournalConsistency> fetchJournalStreak(
    String playerId, {
    int days = 30,
  }) async {
    final safeDays = days <= 0 ? 30 : days;
    try {
      final response = await _dio.get(
        ApiEndpoints.elitePlayerJournalStreak(playerId, days: safeDays),
      );
      final raw = response.data;
      final data =
          (raw is Map) ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
      return JournalConsistency.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint(
            '[EliteRepo] journal-streak endpoint missing (404). Returning empty state.');
        return const JournalConsistency(
          summary: JournalSummary(),
          days: [],
          weekly: JournalWeekly(),
        );
      }
      rethrow;
    }
  }

  Future<void> saveWeeklyTemplate(WeeklyPlanTemplate template) async {
    await _dio.post(
      ApiEndpoints.eliteWeeklyTemplates,
      data: template.toJson(),
    );
  }

  Future<void> saveApexGoal(String playerId, ApexGoal goal) async {
    // Trimming and normalizing payload to ensure backend compatibility
    final payload = {
      'targetRole': goal.targetRole,
      'targetFormat': goal.targetFormat,
      'styleIdentity': goal.styleIdentity,
      'targetLevel': goal.targetLevel,
      'timeline': goal.timeline,
      'focusAreas': goal.focusAreas.take(3).toList(),
      'commitmentStatement': goal.commitmentStatement,
    };

    debugPrint('[EliteRepo] Saving Apex Goal for $playerId');
    debugPrint('[EliteRepo] Payload: ${jsonEncode(payload)}');
    try {
      await _dio.post(
        ApiEndpoints.elitePlayerGoal(playerId),
        data: payload,
      );
      debugPrint('[EliteRepo] Goal saved successfully');
    } catch (e) {
      debugPrint('[EliteRepo] Goal save FAILED: $e');
      if (e is DioException) {
        debugPrint('[EliteRepo] Response: ${e.response?.data}');
      }
      rethrow;
    }
  }
}
