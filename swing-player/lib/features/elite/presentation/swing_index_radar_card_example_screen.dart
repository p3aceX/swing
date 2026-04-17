import 'package:flutter/material.dart';

import '../domain/swing_index_summary.dart';
import 'widgets/swing_index_radar_card.dart';

class SwingIndexRadarCardExampleScreen extends StatelessWidget {
  const SwingIndexRadarCardExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockSummary = SwingIndexSummary.fromJson(
      const {
        'swingIndexScore': 58.3,
        'axes': {
          'reliabilityAxis': 67.4,
          'powerAxis': 61.0,
          'bowlingAxis': 48.5,
          'fieldingAxis': 72.2,
          'impactAxis': 57.8,
        },
        'strengths': [
          {'key': 'fieldingAxis', 'score': 72.2},
          {'key': 'reliabilityAxis', 'score': 67.4},
        ],
        'weakestAreas': [
          {'key': 'bowlingAxis', 'score': 48.5},
          {'key': 'impactAxis', 'score': 57.8},
        ],
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Swing Index Radar Card')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwingIndexRadarCard(summary: mockSummary),
          const SizedBox(height: 16),
          const SwingIndexRadarCard.loading(),
          const SizedBox(height: 16),
          const SwingIndexRadarCard.empty(),
          const SizedBox(height: 16),
          SwingIndexRadarCard.error(
            errorMessage: 'Unable to fetch latest swing index summary.',
            onRetry: () {},
          ),
        ],
      ),
    );
  }
}
