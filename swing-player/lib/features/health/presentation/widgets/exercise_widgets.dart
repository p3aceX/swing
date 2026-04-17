import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ExerciseCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String count;
  final Color color;
  final VoidCallback onTap;

  const ExerciseCategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.stroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                color: context.fg,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecentWorkoutCard extends StatelessWidget {
  final String type;
  final String duration;
  final String date;
  final String intensity;

  const RecentWorkoutCard({
    super.key,
    required this.type,
    required this.duration,
    required this.date,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.panel,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.fitness_center_rounded, color: context.accent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    color: context.fg,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '$duration · $intensity intensity',
                  style: TextStyle(color: context.fgSub, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: TextStyle(color: context.fgSub, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
