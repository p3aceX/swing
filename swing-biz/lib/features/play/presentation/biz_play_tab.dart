import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/me_providers.dart';
import '../../../core/router/app_router.dart';

class BizPlayTab extends ConsumerWidget {
  const BizPlayTab({super.key, this.currentCity});

  final String? currentCity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(meProvider).valueOrNull?.user.id;

    return HostPlayTab(
      currentCity: currentCity,
      currentUserId: currentUserId,
      callbacks: PlayTabCallbacks(
        onCreateTeam: (ctx) => ctx.push(AppRoutes.createTeam),
        onNavigateToTeam: (ctx, teamId, _) =>
            ctx.push('${AppRoutes.team}/${Uri.encodeComponent(teamId)}'),
        onCreateMatch: (ctx) => ctx.push(AppRoutes.createMatch),
        onNavigateToMatch: (ctx, matchId) =>
            ctx.push('${AppRoutes.match}/${Uri.encodeComponent(matchId)}'),
        onScoreMatch: (ctx, matchId) =>
            ctx.push('${AppRoutes.scoreMatch}/${Uri.encodeComponent(matchId)}'),
        onSetPlayingXI: (ctx, matchId, teamA, teamB) => ctx.push(
          '${AppRoutes.createMatch}?matchId=${Uri.encodeComponent(matchId)}'
          '&teamA=${Uri.encodeComponent(teamA)}'
          '&teamB=${Uri.encodeComponent(teamB)}',
        ),
        onCreateTournament: (ctx) => ctx.push(AppRoutes.createTournament),
        onNavigateToTournament: (ctx, tournamentId, slug, isHost) {
          ctx.push(
            '${AppRoutes.tournament}/${Uri.encodeComponent(slug ?? tournamentId)}',
            extra: {'isHost': isHost, 'tournamentId': tournamentId},
          );
        },
      ),
    );
  }
}
