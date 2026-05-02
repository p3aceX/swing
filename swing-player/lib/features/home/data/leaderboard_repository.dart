import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/base_repository.dart';
import '../domain/leaderboard_models.dart';

class LeaderboardRepository extends BaseRepository {
  final _client = ApiClient.instance.dio;

  /// GET /player/leaderboard
  Stream<LeaderboardData> loadLeaderboardStream({
    int page = 1,
    int limit = 20,
  }) async* {
    final cacheKey = generateCacheKey(
      ApiEndpoints.playerLeaderboard,
      queryParameters: {'page': page, 'limit': limit},
    );

    final cached = getCached(cacheKey);
    if (cached != null) {
      yield _parseLeaderboardData(cached);
    }

    try {
      final response = await _client.get(
        ApiEndpoints.playerLeaderboard,
        queryParameters: {'page': page, 'limit': limit},
        options: Options(extra: {'refresh': true}),
      );
      yield _parseLeaderboardData(response.data);
    } catch (e) {
      if (cached == null) rethrow;
    }
  }

  /// GET /player/leaderboard (for legacy Future compatibility)
  Future<LeaderboardData> loadLeaderboard({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get(
      ApiEndpoints.playerLeaderboard,
      queryParameters: {'page': page, 'limit': limit},
    );
    return _parseLeaderboardData(response.data);
  }

  /// GET /player/recommendations
  Stream<List<LeaderboardEntry>> loadRecommendationsStream({int limit = 10}) async* {
    final cacheKey = generateCacheKey(
      ApiEndpoints.playerRecommendations,
      queryParameters: {'limit': limit},
    );

    final cached = getCached(cacheKey);
    if (cached != null) {
      yield _parseEntries(cached);
    }

    try {
      final response = await _client.get(
        ApiEndpoints.playerRecommendations,
        queryParameters: {'limit': limit},
      );
      yield _parseEntries(response.data);
    } catch (e) {
      if (cached == null) rethrow;
    }
  }

  /// GET /player/recommendations
  Future<List<LeaderboardEntry>> loadRecommendations({int limit = 10}) async {
    final response = await _client.get(
      ApiEndpoints.playerRecommendations,
      queryParameters: {'limit': limit},
    );
    return _parseEntries(response.data);
  }

  /// Follow a player – reuses existing endpoint
  Future<void> followPlayer(String playerId) async {
    await _client.post('/player/follow/player/$playerId');
  }

  /// Unfollow a player
  Future<void> unfollowPlayer(String playerId) async {
    await _client.delete('/player/follow/player/$playerId');
  }

  // ── Parsing helpers ────────────────────────────────────────────────────────

  LeaderboardData _parseLeaderboardData(dynamic data) {
    final entries = _parseEntries(data);
    LeaderboardEntry? me;

    if (data is Map<String, dynamic>) {
      final meRaw = data['me'];
      if (meRaw is Map<String, dynamic>) {
        me = _mapEntry(meRaw);
      }
    }

    return LeaderboardData(entries: entries, me: me);
  }

  List<LeaderboardEntry> _parseEntries(dynamic data) {
    final items = _unwrapList(data);
    return items.map(_mapEntry).toList();
  }

  LeaderboardEntry _mapEntry(Map<String, dynamic> raw) {
    return LeaderboardEntry(
      playerId: _string(raw['playerId']),
      name: _string(raw['name']),
      avatarUrl: _nullIfEmpty(_string(raw['avatarUrl'])),
      impactPoints: _int(raw['impactPoints']),
      rank: _string(raw['rank']),
      position: _intOrNull(raw['position'] ?? raw['rankNumber'] ?? raw['pos']),
      profileUrl: _nullIfEmpty(_string(raw['profileUrl'])),
    );
  }

  int? _intOrNull(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  List<Map<String, dynamic>> _unwrapList(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is List) {
        return inner.whereType<Map<String, dynamic>>().toList();
      }
      if (inner is Map<String, dynamic>) {
        final nested = inner['data'];
        if (nested is List) {
          return nested.whereType<Map<String, dynamic>>().toList();
        }
        for (final key in const ['players', 'items', 'results', 'rows']) {
          final nested = inner[key];
          if (nested is List) {
            return nested.whereType<Map<String, dynamic>>().toList();
          }
        }
      }
      for (final key in const ['players', 'items', 'results', 'rows']) {
        final nested = data[key];
        if (nested is List) {
          return nested.whereType<Map<String, dynamic>>().toList();
        }
      }
    }
    return const [];
  }

  String _string(dynamic v) =>
      (v is String && v.trim().isNotEmpty) ? v.trim() : '';

  String? _nullIfEmpty(String s) => s.isEmpty ? null : s;

  int _int(dynamic v) {
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
