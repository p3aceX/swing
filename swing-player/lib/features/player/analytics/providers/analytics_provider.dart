import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/growth_insights_model.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(ApiClient.instance.dio);
});

final analyticsProvider = StateNotifierProvider.autoDispose
    .family<AnalyticsNotifier, AnalyticsState, String>((ref, profileId) {
  return AnalyticsNotifier(
    ref.watch(analyticsRepositoryProvider),
    profileId: profileId,
  );
});

class AnalyticsState {
  const AnalyticsState({
    this.insights,
    this.skillMatrix,
    this.coaches = const [],
    this.isLoading = false,
    this.isLoadingCoaches = false,
    this.error,
    this.hasLoaded = false,
  });

  final GrowthInsights? insights;
  final SkillMatrix? skillMatrix;
  final List<CoachSuggestion> coaches;
  final bool isLoading;
  final bool isLoadingCoaches;
  final String? error;
  final bool hasLoaded;

  AnalyticsState copyWith({
    GrowthInsights? insights,
    SkillMatrix? skillMatrix,
    List<CoachSuggestion>? coaches,
    bool? isLoading,
    bool? isLoadingCoaches,
    String? error,
    bool? hasLoaded,
  }) {
    return AnalyticsState(
      insights: insights ?? this.insights,
      skillMatrix: skillMatrix ?? this.skillMatrix,
      coaches: coaches ?? this.coaches,
      isLoading: isLoading ?? this.isLoading,
      isLoadingCoaches: isLoadingCoaches ?? this.isLoadingCoaches,
      error: error,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier(this._repository, {required this.profileId})
      : super(const AnalyticsState());

  final AnalyticsRepository _repository;
  final String profileId;

  Future<void> loadAnalytics() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait<dynamic>([
        _repository.fetchGrowthInsights(),
        _repository.fetchSkillMatrix(profileId),
      ]);
      final insights = results[0] as GrowthInsights;
      final skillMatrix = results[1] as SkillMatrix;
      state = state.copyWith(
        insights: insights,
        skillMatrix: skillMatrix,
        coaches: insights.coachSuggestions,
        isLoading: false,
        hasLoaded: true,
        error: null,
      );
      unawaited(_loadNearbyCoaches());
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _repository.messageFor(error),
      );
    }
  }

  Future<void> _loadNearbyCoaches() async {
    state = state.copyWith(isLoadingCoaches: true, error: state.error);
    try {
      final coaches = await _repository.fetchNearbyCoaches();
      state = state.copyWith(
        coaches: coaches.isEmpty ? state.coaches : coaches,
        isLoadingCoaches: false,
        error: state.error,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingCoaches: false,
        error: state.error,
      );
    }
  }
}

class AnalyticsRepository {
  AnalyticsRepository(this._client);

  final Dio _client;

  Future<GrowthInsights> fetchGrowthInsights() async {
    final response = await _client.get(ApiEndpoints.playerGrowthInsights);
    return GrowthInsights.fromJson(_unwrapMap(response));
  }

  Future<SkillMatrix> fetchSkillMatrix(String profileId) async {
    final response =
        await _client.get(ApiEndpoints.elitePlayerProfile(profileId));
    final data = _unwrapMap(response);
    return SkillMatrix.fromJson(_asMap(data['skillMatrix']));
  }

  Future<List<CoachSuggestion>> fetchNearbyCoaches() async {
    final response = await _client.get(ApiEndpoints.playerNearbyCoaches);
    final data = response.data;
    final list = data is Map<String, dynamic> && data['data'] is List
        ? data['data'] as List
        : data is List
            ? data
            : const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(CoachSuggestion.fromJson)
        .toList();
  }

  String messageFor(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      if (status == 401) return 'Session expired. Please log in again.';
      if (status == 404) return 'Analytics is not available yet.';
      if (error.type == DioExceptionType.connectionError) {
        return 'Could not reach analytics right now.';
      }
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        if (data['message'] is String) return data['message'] as String;
        final nested = data['error'];
        if (nested is Map<String, dynamic> && nested['message'] is String) {
          return nested['message'] as String;
        }
      }
    }
    return 'Could not load analytics right now.';
  }

  Map<String, dynamic> _unwrapMap(Response<dynamic> response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is Map<String, dynamic>) return inner;
      return data;
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> _asMap(dynamic value) =>
      value is Map<String, dynamic> ? value : <String, dynamic>{};
}
