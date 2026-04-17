import 'package:dio/dio.dart';

import '../contracts/host_contracts.dart';

class HostScoringRepository {
  HostScoringRepository(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> loadMatch(String matchId) async {
    final response = await _dio.get(HostContracts.match(matchId));
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> loadPlayers(String matchId) async {
    final response = await _dio.get(HostContracts.matchPlayers(matchId));
    return _asMap(response.data);
  }

  Future<void> recordBall(
    String matchId,
    int inningsNumber, {
    required Map<String, dynamic> payload,
  }) async {
    await _dio.post(HostContracts.inningsBall(matchId, inningsNumber), data: payload);
  }

  Future<Map<String, dynamic>> patchInningsState(
    String matchId,
    int inningsNumber, {
    required Map<String, dynamic> payload,
  }) async {
    final response = await _dio.patch(
      HostContracts.inningsState(matchId, inningsNumber),
      data: payload,
    );
    return _asMap(response.data);
  }

  Future<void> completeInnings(String matchId, int inningsNumber) async {
    await _dio.post(HostContracts.inningsComplete(matchId, inningsNumber));
  }

  Future<void> continueInnings(String matchId) async {
    await _dio.post('${HostContracts.match(matchId)}/continue-innings');
  }

  Future<void> completeMatch(
    String matchId, {
    required String winnerId,
    required String? winMargin,
  }) async {
    await _dio.post(
      '${HostContracts.match(matchId)}/complete',
      data: {'winnerId': winnerId, if (winMargin != null) 'winMargin': winMargin},
    );
  }

  Future<Map<String, dynamic>> undoLastBall(String matchId, int inningsNumber) async {
    final response = await _dio.delete(HostContracts.inningsUndo(matchId, inningsNumber));
    return _asMap(response.data);
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}
