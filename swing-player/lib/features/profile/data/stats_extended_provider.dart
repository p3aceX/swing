import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import 'profile_payload_models.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class StatsExtendedState {
  const StatsExtendedState({
    this.metrics = const {},
    this.metricItems = const [],
    this.metricCount = 0,
    this.isLoading = false,
    this.error,
    this.isLocked = false,
    this.lockMessage,
    this.payload,
    this.captaincyApplicable = false,
    this.hasLoaded = false,
  });

  final Map<String, Object?> metrics;
  final List<EliteExtendedMetricItem> metricItems;
  final int metricCount;
  final bool isLoading;
  final String? error;
  final bool isLocked;
  final String? lockMessage;
  final EliteStatsExtendedPayload? payload;
  final bool captaincyApplicable;
  final bool hasLoaded;

  StatsExtendedState copyWith({
    Map<String, Object?>? metrics,
    List<EliteExtendedMetricItem>? metricItems,
    int? metricCount,
    bool? isLoading,
    String? error,
    bool? isLocked,
    String? lockMessage,
    EliteStatsExtendedPayload? payload,
    bool? captaincyApplicable,
    bool? hasLoaded,
  }) {
    return StatsExtendedState(
      metrics: metrics ?? this.metrics,
      metricItems: metricItems ?? this.metricItems,
      metricCount: metricCount ?? this.metricCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isLocked: isLocked ?? this.isLocked,
      lockMessage: lockMessage ?? (isLocked == false ? null : this.lockMessage),
      payload: payload ?? this.payload,
      captaincyApplicable: captaincyApplicable ?? this.captaincyApplicable,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final statsExtendedProvider = StateNotifierProvider.autoDispose
    .family<StatsExtendedNotifier, StatsExtendedState, String>(
  (ref, profileId) => StatsExtendedNotifier(
    ApiClient.instance.dio,
    profileId: profileId,
  ),
);

// ─── Notifier ─────────────────────────────────────────────────────────────────

class StatsExtendedNotifier extends StateNotifier<StatsExtendedState> {
  StatsExtendedNotifier(this._dio, {required this.profileId})
      : super(const StatsExtendedState());

  final Dio _dio;
  final String profileId;

  Future<void> load({bool force = false}) async {
    if (state.isLoading || (state.hasLoaded && !force)) return;
    final previous = state;

    state = state.copyWith(
      isLoading: true,
      error: null,
      isLocked: false,
      lockMessage: null,
    );
    try {
      final response = await _dio.get(
        ApiEndpoints.elitePlayerStatsExtended(profileId),
      );
      final body = response.data;
      final data = body is Map<String, dynamic> && body['data'] is Map
          ? body['data'] as Map<String, dynamic>
          : body is Map<String, dynamic>
              ? body
              : <String, dynamic>{};

      final payload = EliteStatsExtendedPayload.fromJson(data);
      final metrics = payload.metrics;
      final hasMetrics = metrics.isNotEmpty;
      if (!hasMetrics) {
        final lockMessage = payload.error.trim().isNotEmpty
            ? payload.error.trim()
            : 'Unlock the APEX Pack to view detailed metrics.';
        state = state.copyWith(
          metrics: const {},
          metricItems: const [],
          metricCount: 0,
          isLoading: false,
          hasLoaded: true,
          isLocked: true,
          lockMessage: lockMessage,
          payload: payload,
          captaincyApplicable: false,
          error: null,
        );
        return;
      }

      final metricItems = payload.toMetricItems();
      final captaincyApplicable = metricItems.any(
        (metric) =>
            metric.category == EliteMetricCategory.captaincy &&
            metric.hasEvidence,
      );

      state = state.copyWith(
        metrics: metrics,
        metricItems: metricItems,
        metricCount: metricItems.length,
        isLoading: false,
        hasLoaded: true,
        isLocked: false,
        lockMessage: null,
        payload: payload,
        captaincyApplicable: captaincyApplicable,
        error: null,
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      state = previous.copyWith(
        isLoading: false,
        hasLoaded: true,
        isLocked: false,
        lockMessage: null,
        error: status == 404
            ? 'Stats not available yet.'
            : 'Could not load stats.',
      );
    } catch (_) {
      state = previous.copyWith(
        isLoading: false,
        hasLoaded: true,
        isLocked: false,
        lockMessage: null,
        error: 'Could not load stats.',
      );
    }
  }

  Future<void> refresh() => load(force: true);
}
