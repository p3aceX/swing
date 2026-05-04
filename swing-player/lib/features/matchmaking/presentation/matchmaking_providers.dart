import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../teams/data/teams_repository.dart';
import '../data/matchmaking_repository.dart';
import '../domain/matchmaking_models.dart';

final matchmakingRepositoryProvider = Provider<MatchmakingRepository>(
  (_) => MatchmakingRepository(),
);

/// User's teams, mapped to MmTeam. Cached for the session.
final mmTeamsProvider = FutureProvider<List<MmTeam>>((ref) async {
  final repo = TeamsRepository();
  final result = await repo.loadTeamsByOwnership();
  final all = [...result.mySquads, ...result.playingFor];
  return all.map(MmTeam.fromPlayerTeam).toList();
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
  final repo = ref.read(matchmakingRepositoryProvider);
  return repo.listOpenLobbies(date: q.date, format: q.format);
});
