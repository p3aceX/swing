import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../teams/data/teams_repository.dart';
import '../data/matchmaking_repository.dart';
import '../domain/matchmaking_models.dart';

// ignore: avoid_print
void _mmLog(String msg) => debugPrint('[MM:provider] $msg');

final matchmakingRepositoryProvider = Provider<MatchmakingRepository>(
  (_) => MatchmakingRepository(),
);

/// User's teams, mapped to MmTeam. Cached for the session.
final mmTeamsProvider = FutureProvider<List<MmTeam>>((ref) async {
  _mmLog('mmTeamsProvider → loading');
  try {
    final repo = TeamsRepository();
    final result = await repo.loadTeamsByOwnership();
    final all = [...result.mySquads, ...result.playingFor];
    final mapped = all.map(MmTeam.fromPlayerTeam).toList();
    _mmLog('mmTeamsProvider → mySquads=${result.mySquads.length} playingFor=${result.playingFor.length} total=${mapped.length}');
    for (final t in mapped) {
      _mmLog('  team: id=${t.id} name=${t.name}');
    }
    return mapped;
  } catch (e, st) {
    _mmLog('mmTeamsProvider ERROR: $e\n$st');
    rethrow;
  }
});

typedef MmGroundsQuery = ({String date, String format, String? teamId, int? overs});

/// Grounds with opponent signals for a given date+format.
/// Fetched fresh each time the Add-Ground sheet opens.
final mmGroundsProvider =
    FutureProvider.family<List<MmGround>, MmGroundsQuery>((ref, q) async {
  final repo = ref.read(matchmakingRepositoryProvider);
  return repo.searchGrounds(date: q.date, format: q.format, teamId: q.teamId, overs: q.overs);
});

typedef MmLobbiesQuery = ({String? date, String? format});

/// Open lobbies for the Lobbies tab. autoDispose so it re-fetches on every visit.
final mmOpenLobbiesProvider =
    FutureProvider.autoDispose.family<List<MmOpenLobby>, MmLobbiesQuery>((ref, q) async {
  _mmLog('mmOpenLobbiesProvider → q=(date=${q.date}, format=${q.format})');
  try {
    final repo = ref.read(matchmakingRepositoryProvider);
    final result = await repo.listOpenLobbies(date: q.date, format: q.format);
    _mmLog('mmOpenLobbiesProvider → got ${result.length} lobbies');
    return result;
  } catch (e, st) {
    _mmLog('mmOpenLobbiesProvider ERROR: $e\n$st');
    rethrow;
  }
});
