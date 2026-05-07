import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:go_router/go_router.dart';

class CoachCreateTournamentScreen extends StatelessWidget {
  const CoachCreateTournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HostCreateTournamentScreen(
      onTournamentCreated: (ctx, tournament) {
        final id = '${tournament['id'] ?? ''}'.trim();
        if (id.isEmpty) {
          ctx.pop();
          return;
        }
        ctx.push('/play/host-tournament/$id', extra: tournament);
      },
    );
  }
}
