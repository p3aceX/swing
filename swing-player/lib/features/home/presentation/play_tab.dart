import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/token_storage.dart';

final _currentUserIdProvider = FutureProvider<String?>((ref) async {
  return TokenStorage.getUserId();
});

class PlayTab extends ConsumerWidget {
  const PlayTab({super.key, this.currentCity});
  final String? currentCity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(_currentUserIdProvider).valueOrNull;
    return HostPlayTab(
      currentCity: currentCity,
      currentUserId: userId,
      callbacks: PlayTabCallbacks(
        onCreateTeam: (ctx) => ctx.push('/create-team'),
        onNavigateToTeam: (ctx, teamId, _) =>
            ctx.push('/team/${Uri.encodeComponent(teamId)}'),
        onCreateMatch: (ctx) => ctx.push('/create-match'),
        onNavigateToMatch: (ctx, matchId) =>
            ctx.push('/match/${Uri.encodeComponent(matchId)}'),
        onScoreMatch: (ctx, matchId) =>
            ctx.push('/score-match/${Uri.encodeComponent(matchId)}'),
        onSetPlayingXI: (ctx, matchId, teamA, teamB) => ctx.push(
          '/create-match?matchId=${Uri.encodeComponent(matchId)}'
          '&teamA=${Uri.encodeComponent(teamA)}'
          '&teamB=${Uri.encodeComponent(teamB)}',
        ),
        onCreateTournament: (ctx) => ctx.push('/create-tournament'),
        onNavigateToTournament: (ctx, tournamentId, slug, isHost) {
          debugPrint('[Tournament] nav id=$tournamentId slug=$slug isHost=$isHost');
          ctx.push(
            '/tournament/${Uri.encodeComponent(slug ?? tournamentId)}',
            extra: {'isHost': isHost, 'tournamentId': tournamentId},
          );
        },
      ),
    );
  }
}
