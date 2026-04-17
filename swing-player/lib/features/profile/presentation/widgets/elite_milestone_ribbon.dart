import 'package:flutter/material.dart';
import '../../domain/rank_visual_theme.dart';
import '../../domain/profile_models.dart';

class EliteMilestoneRibbon extends StatelessWidget {
  const EliteMilestoneRibbon({
    super.key,
    required this.elite,
    required this.fullStats,
    required this.rankTheme,
  });

  final EliteAnalytics elite;
  final FullCricketStats fullStats;
  final RankVisualTheme rankTheme;

  @override
  Widget build(BuildContext context) {
    final milestones = [
      _Milestone(label: 'Hundreds', value: elite.milestones.hundreds.toString()),
      _Milestone(label: 'Fifties', value: elite.milestones.fifties.toString()),
      _Milestone(label: 'Thirties', value: elite.milestones.thirties.toString()),
      _Milestone(label: 'Highest', value: fullStats.batting.highestScore.toString()),
      _Milestone(label: 'B.B.', value: fullStats.bowling.bestBowling),
      _Milestone(label: '3w Hauls', value: elite.milestones.threeWicketHauls.toString()),
      _Milestone(label: 'Ducks', value: elite.milestones.ducks.toString()),
    ];

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: milestones.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final m = milestones[index];
          return Container(
            width: 90,
            decoration: BoxDecoration(
              color: rankTheme.deep,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: rankTheme.border.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  m.value,
                  style: TextStyle(
                    color: rankTheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  m.label.toUpperCase(),
                  style: TextStyle(
                    color: rankTheme.secondary.withOpacity(0.7),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Milestone {
  const _Milestone({required this.label, required this.value});
  final String label;
  final String value;
}
