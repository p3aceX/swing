import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../domain/health_models.dart';
import 'widgets/metric_widgets.dart';
import 'widgets/wellness_checkin_sheet.dart';
import 'widgets/workload_log_sheet.dart';

class LogTab extends StatelessWidget {
  const LogTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Manual Logging'),
        _LogActionCard(
          title: 'Wellness Check-in',
          subtitle: 'Daily soreness, mood, and stress',
          icon: Icons.edit_note_rounded,
          color: context.accent,
          onTap: () => _showWellnessSheet(context),
        ),
        const SizedBox(height: 12),
        _LogActionCard(
          title: 'Log Workload',
          subtitle: 'Skill session, match, or gym',
          icon: Icons.add_rounded,
          color: context.gold,
          onTap: () => _showWorkloadSheet(context),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  void _showWellnessSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const WellnessCheckInSheet(),
    );
  }

  void _showWorkloadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const WorkloadLogSheet(),
    );
  }
}

class _LogActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _LogActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.stroke),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: context.fgSub, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.fgSub),
          ],
        ),
      ),
    );
  }
}
