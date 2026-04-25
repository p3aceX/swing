import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../contracts/host_path_config.dart';
import '../providers/host_dio_provider.dart';

class HostMatchRepository {
  HostMatchRepository(this._dio, this._paths);

  final Dio _dio;
  final HostPathConfig _paths;

  Future<void> startMatch(String matchId) async {
    await _dio.post(_paths.matchStart(matchId));
  }

  Future<void> cancelMatch(String matchId) async {
    await _dio.post(_paths.matchCancel(matchId));
  }

  Future<void> deleteMatch(String matchId) async {
    await _dio.delete(_paths.match(matchId));
  }

  Future<void> updateScorer(String matchId, String scorerId) async {
    await _dio.patch(
      _paths.matchScorer(matchId),
      data: {'scorerId': scorerId},
    );
  }

  Future<void> recordToss(
    String matchId, {
    required String tossWonBy,
    required String tossDecision,
  }) async {
    await _dio.post(
      _paths.matchToss(matchId),
      data: {
        'tossWonBy': tossWonBy,
        'tossDecision': tossDecision,
      },
    );
  }
}

final hostMatchRepositoryProvider = Provider<HostMatchRepository>(
  (ref) => HostMatchRepository(
    ref.watch(hostDioProvider),
    ref.watch(hostPathConfigProvider),
  ),
);
