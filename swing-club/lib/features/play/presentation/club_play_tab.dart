import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';

class ClubPlayTab extends ConsumerWidget {
  const ClubPlayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(authProvider).userId;

    return SafeArea(
      bottom: false,
      child: HostPlayTab(
      currentUserId: currentUserId,
      callbacks: PlayTabCallbacks(
        onCreateTeam: (ctx) => ctx.push('/play/create-team'),
        onNavigateToTeam: (ctx, teamId, _) =>
            ctx.push('/play/teams/${Uri.encodeComponent(teamId)}'),
        onCreateMatch: (ctx) => ctx.push('/play/create-match'),
        onNavigateToMatch: (ctx, matchId) =>
            ctx.push('/play/matches/${Uri.encodeComponent(matchId)}'),
        onScoreMatch: (ctx, matchId) =>
            ctx.push('/play/score/${Uri.encodeComponent(matchId)}'),
        onSetPlayingXI: (ctx, matchId, teamA, teamB) => ctx.push(
          '/play/create-match'
          '?matchId=${Uri.encodeComponent(matchId)}'
          '&teamA=${Uri.encodeComponent(teamA)}'
          '&teamB=${Uri.encodeComponent(teamB)}',
        ),
        onCreateTournament: (ctx) => ctx.push('/play/create-tournament'),
        onNavigateToTournament: (ctx, tournamentId, slug, isHost) {
          ctx.push(
            '/play/tournaments/${Uri.encodeComponent(slug ?? tournamentId)}',
            extra: {'isHost': isHost, 'tournamentId': tournamentId},
          );
        },
      ),
      ),
    );
  }
}
