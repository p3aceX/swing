import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/host_dio_provider.dart';
import '../domain/host_arena_review_analytics.dart';
import '../domain/host_arena_review_models.dart';

/// Submits a captain's arena review against the matchmaking endpoint.
///
/// The path is hardcoded under `/matchmaking` because only the player app
/// (the only app with captain-side matchmaking flows today) consumes it.
/// Add to HostPathConfig if a second host needs to call this.
class HostArenaReviewRepository {
  HostArenaReviewRepository(this._dio);

  final Dio _dio;

  /// Loads the biz arena dashboard analytics for an arena. Owner-only.
  /// Path is hardcoded under `/arenas` because that's where the existing
  /// arena routes live; if the host adopts namespaced paths, lift to
  /// HostPathConfig.
  Future<HostArenaReviewAnalytics> loadAnalytics(String arenaId) async {
    final resp = await _dio.get('/arenas/$arenaId/match-review-analytics');
    final raw = resp.data;
    final data = raw is Map<String, dynamic> && raw['data'] is Map<String, dynamic>
        ? raw['data'] as Map<String, dynamic>
        : (raw is Map<String, dynamic> ? raw : const <String, dynamic>{});
    return HostArenaReviewAnalytics.fromJson(data);
  }

  Future<HostArenaReviewResult> submitReview({
    required String matchId,
    required String teamId,
    required HostArenaReviewDraft draft,
  }) async {
    final resp = await _dio.post(
      '/matchmaking/matches/$matchId/review',
      data: {
        'teamId': teamId,
        'stars': draft.stars,
        if (draft.tags.isNotEmpty) 'tags': draft.tags,
        if (draft.comment != null && draft.comment!.trim().isNotEmpty)
          'comment': draft.comment!.trim(),
      },
    );
    final raw = resp.data;
    final data = raw is Map<String, dynamic> && raw['data'] is Map<String, dynamic>
        ? raw['data'] as Map<String, dynamic>
        : (raw is Map<String, dynamic> ? raw : const <String, dynamic>{});
    return HostArenaReviewResult.fromJson(data);
  }
}

final hostArenaReviewRepositoryProvider =
    Provider<HostArenaReviewRepository>((ref) {
  final dio = ref.watch(hostDioProvider);
  return HostArenaReviewRepository(dio);
});
