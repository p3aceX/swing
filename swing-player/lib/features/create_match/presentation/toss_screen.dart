import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart' as fhc;
import 'package:go_router/go_router.dart';

/// Player-side wrapper around the shared [fhc.TossScreen]. Wires `go_router`
/// so a successful toss lands the user in the scoring screen.
class TossScreen extends StatelessWidget {
  const TossScreen({
    super.key,
    required this.matchId,
    required this.teamAName,
    required this.teamBName,
  });

  final String matchId;
  final String teamAName;
  final String teamBName;

  @override
  Widget build(BuildContext context) {
    return fhc.TossScreen(
      matchId: matchId,
      teamAName: teamAName,
      teamBName: teamBName,
      onCompleted: (ctx, id) =>
          ctx.go('/score-match/${Uri.encodeComponent(id)}'),
      onBack: () => context.pop(),
    );
  }
}
