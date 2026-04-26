import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/host_dio_provider.dart';
import '../domain/tournament_detail_models.dart';

class HostTournamentDetailRepository {
  HostTournamentDetailRepository(this._dio);

  final Dio _dio;

  Future<TournamentDetailModel> fetchDetail(String slug) async {
    if (kDebugMode) debugPrint('[HTD] fetching detail slug=$slug');
    final response = await _dio.get('/public/tournament/$slug');
    final data = response.data;
    final root = data is Map ? data as Map<String, dynamic> : <String, dynamic>{};
    final inner = root['data'] is Map ? root['data'] as Map<String, dynamic> : root;
    return TournamentDetailModel.fromJson(inner);
  }

  Future<List<TournamentMatchModel>> fetchMatches(String slug) async {
    try {
      final response = await _dio.get('/public/tournament/$slug/matches');
      final data = response.data;
      final root = data is Map ? data as Map<String, dynamic> : <String, dynamic>{};
      final list = root['data'] is List ? root['data'] as List : [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(TournamentMatchModel.fromJson)
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[HTD] matches error: $e slug=$slug');
      return [];
    }
  }

  Future<List<TournamentStandingModel>> fetchStandings(String slug) async {
    try {
      final response = await _dio.get('/public/tournament/$slug/standings');
      final data = response.data;
      final root = data is Map ? data as Map<String, dynamic> : <String, dynamic>{};
      final list = root['data'] is List ? root['data'] as List : [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(TournamentStandingModel.fromJson)
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[HTD] standings error: $e slug=$slug');
      return [];
    }
  }

  Future<TournamentLeaderboardModel> fetchLeaderboard(String slug) async {
    try {
      final response = await _dio.get('/public/tournament/$slug/leaderboard');
      final data = response.data;
      final root = data is Map ? data as Map<String, dynamic> : <String, dynamic>{};
      final inner = root['data'] is Map ? root['data'] as Map<String, dynamic> : root;
      return TournamentLeaderboardModel.fromJson(inner);
    } catch (e) {
      if (kDebugMode) debugPrint('[HTD] leaderboard error: $e slug=$slug');
      return const TournamentLeaderboardModel(
        topBatsmen: [],
        topBowlers: [],
        topFielders: [],
        tournamentTotals: TournamentTotalsModel(),
      );
    }
  }

  Future<bool> getFollowStatus(String tournamentId) async {
    try {
      final res = await _dio.get('/player/follow/tournament/$tournamentId/status');
      final data = res.data;
      final map = data is Map ? data as Map<String, dynamic> : <String, dynamic>{};
      final inner = map['data'] is Map ? map['data'] as Map<String, dynamic> : map;
      return inner['following'] == true || inner['isFollowing'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> followTournament(String tournamentId) async {
    await _dio.post('/player/follow/tournament/$tournamentId');
  }

  Future<void> unfollowTournament(String tournamentId) async {
    await _dio.delete('/player/follow/tournament/$tournamentId');
  }
}

final hostTournamentDetailRepositoryProvider =
    Provider<HostTournamentDetailRepository>(
  (ref) => HostTournamentDetailRepository(ref.watch(hostDioProvider)),
);

// ── Providers for detail data ─────────────────────────────────────────────────

final hostTournamentDetailProvider =
    FutureProvider.autoDispose.family<TournamentDetailModel, String>(
  (ref, slug) =>
      ref.watch(hostTournamentDetailRepositoryProvider).fetchDetail(slug),
);

final hostTournamentMatchesProvider =
    FutureProvider.autoDispose.family<List<TournamentMatchModel>, String>(
  (ref, slug) =>
      ref.watch(hostTournamentDetailRepositoryProvider).fetchMatches(slug),
);

final hostTournamentStandingsProvider =
    FutureProvider.autoDispose.family<List<TournamentStandingModel>, String>(
  (ref, slug) =>
      ref.watch(hostTournamentDetailRepositoryProvider).fetchStandings(slug),
);

final hostTournamentLeaderboardProvider =
    FutureProvider.autoDispose.family<TournamentLeaderboardModel, String>(
  (ref, slug) =>
      ref.watch(hostTournamentDetailRepositoryProvider).fetchLeaderboard(slug),
);
