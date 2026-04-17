import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../contracts/host_contracts.dart';
import '../providers/host_dio_provider.dart';

class HostTeamRepository {
  HostTeamRepository(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> searchTeams(String query) async {
    if (query.trim().isEmpty) {
      return getMyTeams();
    }
    final response = await _dio.get(
      HostContracts.teamSearch,
      queryParameters: {
        'q': query.trim(),
        'limit': 20,
      },
    );
    return _normalizeList(response.data);
  }

  Future<List<Map<String, dynamic>>> getMyTeams() async {
    final response = await _dio.get(HostContracts.myTeams);
    return _normalizeList(response.data);
  }

  Future<List<Map<String, dynamic>>> getTeamPlayers(String teamId) async {
    final response = await _dio.get(HostContracts.teamPlayers(teamId));
    return _normalizeList(response.data);
  }

  Future<Map<String, dynamic>> quickAddPlayer(
    String teamId, {
    String? profileId,
    String? name,
    String? phone,
    String? swingId,
  }) async {
    final response = await _dio.post(
      HostContracts.teamQuickAdd(teamId),
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
    await _dio.delete(HostContracts.teamPlayer(teamId, playerId));
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
  (ref) => HostTeamRepository(ref.watch(hostDioProvider)),
);
