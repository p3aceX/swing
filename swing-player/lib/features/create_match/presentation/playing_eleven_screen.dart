import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart' as fhc;
import 'package:go_router/go_router.dart';

/// Player-side wrapper around the shared [fhc.PlayingElevenScreen]. Wires
/// `go_router` so the post-toss landing is the scoring screen.
class PlayingElevenScreen extends StatelessWidget {
  const PlayingElevenScreen({
    super.key,
    required this.matchId,
    required this.teamAId,
    required this.teamAName,
    required this.teamBId,
    required this.teamBName,
    this.hasImpactPlayer = false,
  });

  final String matchId;
  final String teamAId;
  final String teamAName;
  final String teamBId;
  final String teamBName;
  final bool hasImpactPlayer;

  @override
  Widget build(BuildContext context) {
    return fhc.PlayingElevenScreen(
      matchId: matchId,
      teamAId: teamAId,
      teamAName: teamAName,
      teamBId: teamBId,
      teamBName: teamBName,
      hasImpactPlayer: hasImpactPlayer,
      onTossCompleted: (ctx, id) =>
          ctx.go('/score-match/${Uri.encodeComponent(id)}'),
      onBack: () => context.pop(),
    );
  }
}
