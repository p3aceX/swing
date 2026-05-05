import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contracts/host_path_config.dart';
import '../../../providers/host_dio_provider.dart';
import '../../../repositories/host_match_repository.dart';
import '../../../repositories/host_player_repository.dart';
import '../../../repositories/host_scoring_repository.dart';
import '../../../repositories/host_tournament_repository.dart';
import '../domain/scoring_models.dart';

class HostScoringService {
  HostScoringService(
    this._repo,
    this._matchRepo,
    this._playerRepo,
    this._tournamentRepo,
  );

  final HostScoringRepository _repo;
  final HostMatchRepository _matchRepo;
  final HostPlayerRepository _playerRepo;
  final SharedTournamentRepository _tournamentRepo;

  Future<ScoringMatch> loadMatch(String matchId) async {
    final data = await _repo.loadMatch(matchId);
    final payload = _asMap(data['data'] ?? data);
    final tournamentId = '${payload['tournamentId'] ?? ''}'.trim();
    if (tournamentId.isNotEmpty) {
      try {
        final tournament = await _tournamentRepo.getTournament(tournamentId);
        final tFormat = '${tournament['format'] ?? ''}'.trim();
        final tOvers = _asInt(
          tournament['customOvers'] ??
              tournament['oversPerInnings'] ??
              tournament['overs'],
        );
        final mFormat = '${payload['format'] ?? ''}'.trim();
        final mOvers = _asInt(payload['customOvers']);
        final shouldOverrideFormat = tFormat.isNotEmpty &&
            (mFormat.isEmpty ||
                mFormat.toUpperCase() == 'T20' ||
                mFormat.toUpperCase() != tFormat.toUpperCase());
        final shouldOverrideOvers = tOvers > 0 && (mOvers <= 0);
        if (shouldOverrideFormat || shouldOverrideOvers) {
          final merged = Map<String, dynamic>.from(payload)
            ..['tournament'] = tournament;
          if (shouldOverrideFormat) merged['format'] = tFormat;
          if (shouldOverrideOvers) merged['customOvers'] = tOvers;
          return ScoringMatch.fromJson({'data': merged});
        }
      } catch (_) {
        // Best-effort fallback; keep existing match payload on tournament fetch
        // failure so setup remains usable offline.
      }
    }
    return ScoringMatch.fromJson(data);
  }

  Future<ScoringPlayersData> loadPlayers(String matchId) async {
    final data = await _repo.loadPlayers(matchId);
    return ScoringPlayersData.fromJson(data);
  }

  Future<void> recordBall(
    String matchId,
    int inningsNumber, {
    required String batterId,
    String? nonBatterId,
    required String bowlerId,
    required int overNumber,
    required int ballNumber,
    required String outcome,
    required int runs,
    required int extras,
    required bool isWicket,
    bool isOverthrow = false,
    int overthrowRuns = 0,
    String? dismissalType,
    String? dismissedPlayerId,
    String? fielderId,
    String? wagonZone,
    List<String> tags = const [],
  }) {
    return _repo.recordBall(
      matchId,
      inningsNumber,
      payload: {
        'overNumber': overNumber,
        'ballNumber': ballNumber,
        'batterId': batterId,
        if (nonBatterId != null && nonBatterId.isNotEmpty)
          'nonBatterId': nonBatterId,
        'bowlerId': bowlerId,
        'outcome': outcome,
        'runs': runs,
        'extras': extras,
        'isWicket': isWicket,
        'isOverthrow': isOverthrow,
        'overthrowRuns': overthrowRuns,
        if (dismissalType != null && dismissalType.isNotEmpty)
          'dismissalType': dismissalType,
        if (dismissedPlayerId != null && dismissedPlayerId.isNotEmpty)
          'dismissedPlayerId': dismissedPlayerId,
        if (fielderId != null && fielderId.isNotEmpty) 'fielderId': fielderId,
        if (wagonZone != null && wagonZone.isNotEmpty) 'wagonZone': wagonZone,
        if (tags.isNotEmpty) 'tags': tags,
      },
    );
  }

  Future<ScoringInnings> patchInningsState(
    String matchId,
    int inningsNumber, {
    required String strikerId,
    String? nonStrikerId,
    required String bowlerId,
  }) async {
    final data = await _repo.patchInningsState(
      matchId,
      inningsNumber,
      payload: {
        'strikerId': strikerId,
        'bowlerId': bowlerId,
        if (nonStrikerId != null && nonStrikerId.isNotEmpty)
          'nonStrikerId': nonStrikerId,
      },
    );
    return ScoringInnings.fromJson(_extractInningsState(data, inningsNumber));
  }

  Future<void> changeWicketKeeper(String matchId, String team, String playerId) =>
      _matchRepo.changeWicketKeeper(matchId, team, playerId);

  Future<void> startMatch(String matchId) => _matchRepo.startMatch(matchId);
  Future<void> updateMatchOvers(String matchId, int customOvers) =>
      _matchRepo.updateMatchOvers(matchId, customOvers);
  Future<void> updateMatchSchedule(String matchId, DateTime scheduledAt) =>
      _matchRepo.updateMatchSchedule(matchId, scheduledAt);
  Future<void> cancelMatch(String matchId) => _matchRepo.cancelMatch(matchId);
  Future<void> deleteMatch(String matchId) => _matchRepo.deleteMatch(matchId);
  Future<void> updateScorer(String matchId, String scorerId) =>
      _matchRepo.updateScorer(matchId, scorerId);
  Future<void> recordToss(
    String matchId,
    String tossWonBy,
    String tossDecision,
  ) =>
      _matchRepo.recordToss(
        matchId,
        tossWonBy: tossWonBy,
        tossDecision: tossDecision,
      );
  Future<void> continueInnings(String matchId) => _repo.continueInnings(matchId);
  Future<void> completeInnings(String matchId, int inningsNumber) =>
      _repo.completeInnings(matchId, inningsNumber);
  Future<void> completeMatch(
    String matchId,
    String winnerId,
    String? winMargin,
  ) =>
      _repo.completeMatch(
        matchId,
        winnerId: winnerId,
        winMargin: winMargin,
      );
  Future<Map<String, dynamic>> undoLastBall(
    String matchId,
    int inningsNumber,
  ) =>
      _repo.undoLastBall(matchId, inningsNumber);
  Future<List<ScoringMatchPlayer>> searchPlayers(String query) async {
    final results = await _playerRepo.searchPlayers(query);
    return results.map(ScoringMatchPlayer.fromJson).toList();
  }

  Map<String, dynamic> _extractInningsState(
    Map<String, dynamic> response,
    int inningsNumber,
  ) {
    Map<String, dynamic> asMap(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      return <String, dynamic>{};
    }

    final payload = asMap(response['data'] ?? response);
    final innings = payload['innings'];
    if (innings is Map) return Map<String, dynamic>.from(innings);
    final match = asMap(payload['match']);
    final rows = match['innings'];
    if (rows is List) {
      for (final row in rows) {
        final inningsMap = asMap(row);
        if ((inningsMap['inningsNumber'] as num?)?.toInt() == inningsNumber) {
          return inningsMap;
        }
      }
    }
    return payload;
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

final hostScoringServiceProvider = Provider<HostScoringService>((ref) {
  final dio = ref.watch(hostDioProvider);
  final paths = ref.watch(hostPathConfigProvider);
  return HostScoringService(
    HostScoringRepository(dio, paths),
    HostMatchRepository(dio, paths),
    HostPlayerRepository(dio, paths),
    SharedTournamentRepository(dio, paths),
  );
});
