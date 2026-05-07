import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:go_router/go_router.dart';

import '../navigation/play_routes.dart';

PlayTabCallbacks buildPlayCallbacks() {
  return PlayTabCallbacks(
    onCreateTeam: (ctx) => ctx.push(PlayRoutes.createTeam),
    onNavigateToTeam: (ctx, teamId, _) =>
        ctx.push('${PlayRoutes.team}/${Uri.encodeComponent(teamId)}'),
    onCreateMatch: (ctx) => ctx.push(PlayRoutes.createMatch),
    onNavigateToMatch: (ctx, matchId) =>
        ctx.push('${PlayRoutes.match}/${Uri.encodeComponent(matchId)}'),
    onScoreMatch: (ctx, matchId) =>
        ctx.push('${PlayRoutes.scoreMatch}/${Uri.encodeComponent(matchId)}'),
    onSetPlayingXI: (ctx, matchId, teamA, teamB) => ctx.push(
      '${PlayRoutes.createMatch}?matchId=${Uri.encodeComponent(matchId)}'
      '&teamA=${Uri.encodeComponent(teamA)}'
      '&teamB=${Uri.encodeComponent(teamB)}',
    ),
    onCreateTournament: (ctx) => ctx.push(PlayRoutes.createTournament),
    onNavigateToTournament: (ctx, tournamentId, slug, isHost) {
      ctx.push(
        '${PlayRoutes.tournament}/${Uri.encodeComponent(slug ?? tournamentId)}',
        extra: {'isHost': isHost, 'tournamentId': tournamentId},
      );
    },
  );
}
