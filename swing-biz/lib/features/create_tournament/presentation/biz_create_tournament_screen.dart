import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';

class BizCreateTournamentScreen extends StatelessWidget {
  const BizCreateTournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HostCreateTournamentScreen(
      onTournamentCreated: (ctx, tournament) {
        final id = '${tournament['id'] ?? ''}'.trim();
        if (id.isEmpty) {
          ctx.pop();
          return;
        }
        ctx.go('${AppRoutes.hostTournament}/$id', extra: tournament);
      },
    );
  }
}
