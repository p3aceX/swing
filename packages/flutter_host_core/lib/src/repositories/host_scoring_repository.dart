import 'package:dio/dio.dart';

import '../contracts/host_path_config.dart';

class HostScoringRepository {
  HostScoringRepository(this._dio, this._paths);

  final Dio _dio;
  final HostPathConfig _paths;

  Future<Map<String, dynamic>> loadMatch(String matchId) async {
    final response = await _dio.get(_paths.match(matchId));
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> loadPlayers(String matchId) async {
    final response = await _dio.get(_paths.matchPlayers(matchId));
    return _asMap(response.data);
  }

  Future<void> recordBall(
    String matchId,
    int inningsNumber, {
    required Map<String, dynamic> payload,
  }) async {
    await _dio.post(
      _paths.inningsBall(matchId, inningsNumber),
      data: payload,
    );
  }

  Future<Map<String, dynamic>> patchInningsState(
    String matchId,
    int inningsNumber, {
    required Map<String, dynamic> payload,
  }) async {
    final response = await _dio.patch(
      _paths.inningsState(matchId, inningsNumber),
      data: payload,
    );
    return _asMap(response.data);
  }

  Future<void> completeInnings(String matchId, int inningsNumber) async {
    await _dio.post(_paths.inningsComplete(matchId, inningsNumber));
  }

  Future<void> continueInnings(String matchId) async {
    await _dio.post(_paths.matchContinueInnings(matchId));
  }

  Future<void> completeMatch(
    String matchId, {
    required String winnerId,
    required String? winMargin,
  }) async {
    await _dio.post(
      _paths.matchComplete(matchId),
      data: {'winnerId': winnerId, if (winMargin != null) 'winMargin': winMargin},
    );
  }

  Future<Map<String, dynamic>> undoLastBall(
      String matchId, int inningsNumber) async {
    final response =
        await _dio.delete(_paths.inningsUndo(matchId, inningsNumber));
    return _asMap(response.data);
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}
