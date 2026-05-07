import 'package:flutter/material.dart';

import 'coach_play_tab_screen.dart';

class CoachPlayEntryScreen extends StatelessWidget {
  const CoachPlayEntryScreen({required this.currentUserId, super.key});

  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: CoachPlayTabScreen(currentUserId: currentUserId)),
    );
  }
}
