import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';

import '../hooks/play_callbacks.dart';

class CoachPlayTabScreen extends StatelessWidget {
  const CoachPlayTabScreen({super.key, this.currentUserId, this.currentCity});

  final String? currentUserId;
  final String? currentCity;

  @override
  Widget build(BuildContext context) {
    return HostPlayTab(
      currentCity: currentCity,
      currentUserId: currentUserId,
      callbacks: buildPlayCallbacks(),
    );
  }
}
