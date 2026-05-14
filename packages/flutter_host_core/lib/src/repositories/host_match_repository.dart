import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

  Future<void> updateMatchOvers(String matchId, int customOvers) async {
    await _dio.patch(
      _paths.matchOvers(matchId),
      data: {'customOvers': customOvers},
    );
  }

  Future<void> updateMatchSchedule(String matchId, DateTime scheduledAt) async {
    await _dio.patch(
      _paths.match(matchId),
      data: {'scheduledAt': scheduledAt.toUtc().toIso8601String()},
    );
  }

  Future<void> changeWicketKeeper(String matchId, String team, String wicketKeeperId) async {
    await _dio.patch(
      _paths.matchWicketkeeper(matchId),
      data: {'team': team, 'wicketKeeperId': wicketKeeperId},
    );
  }

  Future<void> updateScorer(String matchId, String scorerId) async {
    await _dio.patch(
      _paths.matchScorer(matchId),
      data: {'scorerId': scorerId},
    );
  }

  /// Owner/manager-only. Pins `targetProfileId` as the active scorer for
  /// this match and locks the auto-shift on innings transitions. Use this
  /// to give a non-captain (or a specific captain) the gloves when the
  /// default rule isn't right for the match.
  Future<void> assignScorer(String matchId, String targetProfileId) async {
    await _dio.post(
      '${_paths.match(matchId)}/assign-scorer',
      data: {'profileId': targetProfileId},
    );
  }

  /// Owner/manager-only. Clears the explicit scorer assignment, lets the
  /// auto-shift take over again on the next innings transition.
  Future<void> revokeScorer(String matchId) async {
    await _dio.delete('${_paths.match(matchId)}/scorer');
  }

  Future<void> recordToss(
    String matchId, {
    required String tossWonBy,
    required String tossDecision,
  }) async {
    final url = _paths.matchToss(matchId);
    debugPrint('[recordToss] POST $url  tossWonBy=$tossWonBy tossDecision=$tossDecision');
    try {
      final resp = await _dio.post(
        url,
        data: {
          'tossWonBy': tossWonBy,
          'tossDecision': tossDecision,
        },
      );
      debugPrint('[recordToss] ✓ status=${resp.statusCode}');
    } on DioException catch (e) {
      debugPrint('[recordToss] ✗ status=${e.response?.statusCode} '
          'body=${e.response?.data} '
          'headers=${e.response?.headers.map}');
      rethrow;
    }
  }

  /// Umpire-awarded penalty runs (1-5). `awardedTo` is the team whose
  /// effective total moves. `direction` decides which way:
  ///   ADD      → +runs (bowling-side infraction → batting side benefits)
  ///   SUBTRACT → -runs (batting-side infraction → batting side loses runs)
  /// `inningsNumber` defaults to the active innings on the server when omitted.
  Future<void> awardPenalty(
    String matchId, {
    required String awardedTo,
    required int runs,
    String direction = 'ADD',
    String? reason,
    int? inningsNumber,
  }) async {
    await _dio.post(
      _paths.matchPenalty(matchId),
      data: {
        'awardedTo': awardedTo,
        'runs': runs,
        'direction': direction,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
        if (inningsNumber != null) 'inningsNumber': inningsNumber,
      },
    );
  }

  /// Reverses the most recently recorded penalty award for the match.
  Future<void> undoLastPenalty(String matchId) async {
    await _dio.delete(_paths.matchPenaltyLast(matchId));
  }

  Future<({String liveCode, String livePin, String teamAName, String teamBName})>
      fetchLiveCreds(String matchId) async {
    final res = await _dio.get(_paths.match(matchId));
    final raw = res.data is Map
        ? res.data as Map<String, dynamic>
        : <String, dynamic>{};
    final data =
        raw['data'] is Map ? raw['data'] as Map<String, dynamic> : raw;
    return (
      liveCode: (data['liveCode'] as String?) ?? '',
      livePin: (data['livePin'] as String?) ?? '',
      teamAName: (data['teamAName'] as String?) ?? '',
      teamBName: (data['teamBName'] as String?) ?? '',
    );
  }
}

final hostMatchRepositoryProvider = Provider<HostMatchRepository>(
  (ref) => HostMatchRepository(
    ref.watch(hostDioProvider),
    ref.watch(hostPathConfigProvider),
  ),
);
