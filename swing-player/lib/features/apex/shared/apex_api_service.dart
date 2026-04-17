import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../elite/domain/elite_models.dart';
import '../../profile/controller/profile_controller.dart';
import 'apex_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  APEX API Service
// ─────────────────────────────────────────────────────────────────────────────

class ApexApiService {
  ApexApiService(this._dio);

  final Dio _dio;

  static ApexApiService get instance => ApexApiService(ApiClient.instance.dio);

  // ── AIM ──────────────────────────────────────────────────────────────────

  Future<EliteProfile> fetchEliteProfile(String playerId) async {
    final res = await _dio.get(ApiEndpoints.elitePlayerProfile(playerId));
    final data = _asMap(res.data['data'] ?? res.data);
    return EliteProfile.fromJson(data);
  }

  Future<void> saveApexGoal(String playerId, AimGoalPayload payload) async {
    await _dio.post(
      ApiEndpoints.elitePlayerGoal(playerId),
      data: payload.toJson(),
    );
  }

  // ── PROGRESS ─────────────────────────────────────────────────────────────

  Future<ExecuteSummary> fetchExecuteSummary(String playerId, String range) async {
    final res = await _dio.get(
      ApiEndpoints.elitePlayerExecuteSummary(playerId),
      queryParameters: {'range': range},
    );
    return ExecuteSummary.fromJson(_asMap(res.data));
  }

  Future<HealthDashboard> fetchHealthDashboard() async {
    final res = await _dio.get(ApiEndpoints.healthDashboard);
    return HealthDashboard.fromJson(_asMap(res.data));
  }

  Future<JournalStreak> fetchJournalStreak(String playerId) async {
    final res = await _dio.get(
      ApiEndpoints.elitePlayerJournalStreak(playerId),
    );
    return JournalStreak.fromJson(_asMap(res.data));
  }

  // ── EVALUATE ─────────────────────────────────────────────────────────────

  Future<ApexState> fetchApexState(String playerId) async {
    final res = await _dio.get(ApiEndpoints.elitePlayerApexState(playerId));
    return ApexState.fromJson(_asMap(res.data));
  }

  Future<ApexAnalytics> fetchAnalytics(
    String playerId, {
    String? format,
    String timeframe = '30d',
  }) async {
    final res = await _dio.get(
      ApiEndpoints.elitePlayerAnalytics(playerId),
      queryParameters: {
        if (format != null) 'format': format,
        'timeframe': timeframe,
      },
    );
    return ApexAnalytics.fromJson(_asMap(res.data));
  }

  Future<EliteSwot> fetchSwot(String playerId) async {
    final res = await _dio.get(ApiEndpoints.elitePlayerSwot(playerId));
    final data = _asMap(res.data['data'] ?? res.data);
    return EliteSwot.fromJson(data);
  }

  // ── XLERATE ───────────────────────────────────────────────────────────────

  Future<WeeklyReview> fetchWeeklyReview() async {
    final res = await _dio.get(ApiEndpoints.playerWeeklyReview);
    return WeeklyReview.fromJson(_asMap(res.data));
  }

  Future<List<Signal>> fetchSignals(String playerId) async {
    final res = await _dio.get(ApiEndpoints.elitePlayerSignals(playerId));
    final data = _asMap(res.data);
    final list = (data['data'] ?? data['signals']) as List? ?? [];
    return list.map((e) => Signal.fromJson(_asMap(e))).toList();
  }

  Future<Benchmarks> fetchBenchmarks(String playerId) async {
    final res = await _dio.get(ApiEndpoints.elitePlayerBenchmarks(playerId));
    return Benchmarks.fromJson(_asMap(res.data));
  }

  Future<List<DrillAssignment>> fetchDrillAssignments() async {
    final res = await _dio.get(ApiEndpoints.playerDrillAssignments);
    final data = _asMap(res.data);
    final list = (data['data'] ?? data['assignments'] ?? res.data) as List? ?? [];
    return list.map((e) => DrillAssignment.fromJson(_asMap(e))).toList();
  }

  Future<void> logDrillProgress(String id, {int? reps, int? minutes}) async {
    await _dio.post(
      ApiEndpoints.drillLog(id),
      data: {
        if (reps != null) 'reps': reps,
        if (minutes != null) 'minutes': minutes,
      },
    );
  }
}

Map<String, dynamic> _asMap(dynamic v) =>
    (v is Map) ? Map<String, dynamic>.from(v) : {};

// ─────────────────────────────────────────────────────────────────────────────
//  Convenience provider for playerId
// ─────────────────────────────────────────────────────────────────────────────

final apexPlayerIdProvider = Provider<String?>((ref) {
  final profile = ref.watch(profileControllerProvider);
  return profile.data?.identity.id;
});

final apexApiServiceProvider = Provider<ApexApiService>((ref) {
  return ApexApiService(ApiClient.instance.dio);
});

// ─────────────────────────────────────────────────────────────────────────────
//  PROGRESS Providers
// ─────────────────────────────────────────────────────────────────────────────

final apexExecuteSummary84dProvider =
    FutureProvider.autoDispose<ExecuteSummary>((ref) async {
  final id = ref.watch(apexPlayerIdProvider);
  if (id == null) throw Exception('No player ID');
  return ref.read(apexApiServiceProvider).fetchExecuteSummary(id, '84d');
});

final apexExecuteSummary7dProvider =
    FutureProvider.autoDispose<ExecuteSummary>((ref) async {
  final id = ref.watch(apexPlayerIdProvider);
  if (id == null) throw Exception('No player ID');
  return ref.read(apexApiServiceProvider).fetchExecuteSummary(id, '7d');
});

final apexHealthDashboardProvider =
    FutureProvider.autoDispose<HealthDashboard>((ref) async {
  return ref.read(apexApiServiceProvider).fetchHealthDashboard();
});

final apexJournalStreakProvider =
    FutureProvider.autoDispose<JournalStreak>((ref) async {
  final id = ref.watch(apexPlayerIdProvider);
  if (id == null) throw Exception('No player ID');
  return ref.read(apexApiServiceProvider).fetchJournalStreak(id);
});

// ─────────────────────────────────────────────────────────────────────────────
//  EVALUATE Providers
// ─────────────────────────────────────────────────────────────────────────────

// Re-export the existing apex state provider from elite_controller is handled
// by direct imports in each screen.

final apexAnalyticsProvider =
    FutureProvider.autoDispose<ApexAnalytics>((ref) async {
  final id = ref.watch(apexPlayerIdProvider);
  if (id == null) throw Exception('No player ID');
  return ref.read(apexApiServiceProvider).fetchAnalytics(id, timeframe: '30d');
});

final apexSwotProvider =
    FutureProvider.autoDispose<EliteSwot>((ref) async {
  final id = ref.watch(apexPlayerIdProvider);
  if (id == null) throw Exception('No player ID');
  return ref.read(apexApiServiceProvider).fetchSwot(id);
});

// ─────────────────────────────────────────────────────────────────────────────
//  XLERATE Providers
// ─────────────────────────────────────────────────────────────────────────────

final apexWeeklyReviewProvider =
    FutureProvider.autoDispose<WeeklyReview>((ref) async {
  return ref.read(apexApiServiceProvider).fetchWeeklyReview();
});

final apexSignalsProvider =
    FutureProvider.autoDispose<List<Signal>>((ref) async {
  final id = ref.watch(apexPlayerIdProvider);
  if (id == null) throw Exception('No player ID');
  return ref.read(apexApiServiceProvider).fetchSignals(id);
});

final apexBenchmarksProvider =
    FutureProvider.autoDispose<Benchmarks>((ref) async {
  final id = ref.watch(apexPlayerIdProvider);
  if (id == null) throw Exception('No player ID');
  return ref.read(apexApiServiceProvider).fetchBenchmarks(id);
});

final apexDrillAssignmentsProvider =
    FutureProvider.autoDispose<List<DrillAssignment>>((ref) async {
  return ref.read(apexApiServiceProvider).fetchDrillAssignments();
});
