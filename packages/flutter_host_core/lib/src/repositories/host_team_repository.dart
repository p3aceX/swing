import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../contracts/host_path_config.dart';
import '../providers/host_dio_provider.dart';

/// Roster view used when preparing Playing 11 for a match.
class HostTeamRoster {
  const HostTeamRoster({
    required this.players,
    this.captainId,
    this.viceCaptainId,
    this.wicketKeeperId,
  });

  final List<Map<String, dynamic>> players;
  final String? captainId;
  final String? viceCaptainId;
  final String? wicketKeeperId;
}

class HostTeamRepository {
  HostTeamRepository(this._dio, this._paths);

  final Dio _dio;
  final HostPathConfig _paths;

  Future<List<Map<String, dynamic>>> searchTeams(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final response = await _dio.get(
      _paths.teamSearch,
      queryParameters: {'q': q, 'limit': 20},
    );
    return _normalizeList(response.data);
  }

  Future<List<Map<String, dynamic>>> getMyTeams() async {
    final response = await _dio.get(_paths.myTeams);
    return _normalizeList(response.data);
  }

  Future<List<Map<String, dynamic>>> getTeamPlayers(String teamId) async {
    final response = await _dio.get(_paths.teamPlayers(teamId));
    return _normalizeList(response.data);
  }

  /// Full roster detail — players plus the team's preferred captain, vice
  /// captain and wicket keeper. Useful for pre-filling match role pickers.
  Future<HostTeamRoster> getTeamRoster(String teamId) async {
    final response = await _dio.get(_paths.teamPlayers(teamId));
    final root = _normalizeMap(response.data);
    final data = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'] as Map)
        : root;
    final rawPlayers = (data['players'] ?? const []) as Object?;
    final players = rawPlayers is List
        ? rawPlayers
            .whereType<Map>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList()
        : const <Map<String, dynamic>>[];
    final roles = data['roleAssignments'] is Map
        ? Map<String, dynamic>.from(data['roleAssignments'] as Map)
        : <String, dynamic>{};
    String? stringOrNull(Object? value) {
      final s = '${value ?? ''}'.trim();
      return s.isEmpty ? null : s;
    }

    return HostTeamRoster(
      players: players,
      captainId: stringOrNull(roles['captainId']),
      viceCaptainId: stringOrNull(roles['viceCaptainId']),
      wicketKeeperId: stringOrNull(roles['wicketKeeperId']),
    );
  }

  Future<Map<String, dynamic>> quickAddPlayer(
    String teamId, {
    String? profileId,
    String? name,
    String? phone,
    String? swingId,
  }) async {
    final response = await _dio.post(
      _paths.teamQuickAdd(teamId),
      data: {
        if ((profileId ?? '').trim().isNotEmpty) 'profileId': profileId!.trim(),
        if ((name ?? '').trim().isNotEmpty) 'name': name!.trim(),
        if ((phone ?? '').trim().isNotEmpty) 'phone': phone!.trim(),
        if ((swingId ?? '').trim().isNotEmpty) 'swingId': swingId!.trim(),
      },
    );
    return _normalizeMap(response.data);
  }

  Future<void> removePlayer(String teamId, String playerId) async {
    final readPath = _paths.teamPlayer(teamId, playerId);
    final mutationPath = _paths.teamMember(teamId, playerId);
    try {
      debugPrint('[TeamRepo.removePlayer] DELETE $readPath');
      await _dio.delete(readPath);
      debugPrint('[TeamRepo.removePlayer] OK $readPath');
      return;
    } on DioException catch (e1) {
      debugPrint(
        '[TeamRepo.removePlayer] FAIL $readPath '
        'status=${e1.response?.statusCode} body=${e1.response?.data}',
      );
      try {
        debugPrint('[TeamRepo.removePlayer] DELETE $mutationPath');
        await _dio.delete(mutationPath);
        debugPrint('[TeamRepo.removePlayer] OK $mutationPath');
        return;
      } on DioException catch (e2) {
        debugPrint(
          '[TeamRepo.removePlayer] FAIL $mutationPath '
          'status=${e2.response?.statusCode} body=${e2.response?.data}',
        );
        throw Exception(
          'removePlayer failed for id=$playerId '
          '(read:${e1.response?.statusCode}, mutate:${e2.response?.statusCode})',
        );
      }
    }
  }

  List<Map<String, dynamic>> _normalizeList(Object? data) {
    final root = _normalizeMap(data);
    final payload = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : root;
    final rows = payload['data'] ??
        payload['teams'] ??
        payload['players'] ??
        payload['results'] ??
        const [];
    if (rows is! List) return const [];
    return rows
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  Map<String, dynamic> _normalizeMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }
}

final hostTeamRepositoryProvider = Provider<HostTeamRepository>(
  (ref) => HostTeamRepository(
    ref.watch(hostDioProvider),
    ref.watch(hostPathConfigProvider),
  ),
);
