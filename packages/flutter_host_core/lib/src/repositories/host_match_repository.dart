import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../contracts/host_contracts.dart';
import '../providers/host_dio_provider.dart';

class HostMatchRepository {
  HostMatchRepository(this._dio);

  final Dio _dio;

  Future<void> startMatch(String matchId) async {
    await _dio.post('${HostContracts.match(matchId)}/start');
  }

  Future<void> cancelMatch(String matchId) async {
    await _dio.post('${HostContracts.match(matchId)}/cancel');
  }

  Future<void> deleteMatch(String matchId) async {
    await _dio.delete(HostContracts.match(matchId));
  }

  Future<void> updateScorer(String matchId, String scorerId) async {
    await _dio.patch(
      HostContracts.matchScorer(matchId),
      data: {'scorerId': scorerId},
    );
  }

  Future<void> recordToss(
    String matchId, {
    required String tossWonBy,
    required String tossDecision,
  }) async {
    await _dio.post(
      HostContracts.matchToss(matchId),
      data: {
        'tossWonBy': tossWonBy,
        'tossDecision': tossDecision,
      },
    );
  }
}

final hostMatchRepositoryProvider = Provider<HostMatchRepository>(
  (ref) => HostMatchRepository(ref.watch(hostDioProvider)),
);
