import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart'
    show HostCreateTournamentScreen;

class CreateTournamentScreen extends StatelessWidget {
  const CreateTournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HostCreateTournamentScreen(
      onTournamentCreated: (_, __) {},
    );
  }
}
