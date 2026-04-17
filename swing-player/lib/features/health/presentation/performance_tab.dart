import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../domain/health_models.dart';
import 'widgets/metric_widgets.dart';
import 'widgets/wellness_checkin_sheet.dart';
import 'widgets/workload_log_sheet.dart';

class PerformanceTab extends StatelessWidget {
  const PerformanceTab({super.key, required this.dashboard});

  final HealthDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        _PremiumReadinessHero(dashboard: dashboard),
        const SizedBox(height: 18),
        _QuickActionRow(),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Daily Signals'),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.96,
          children: [
            HealthMetricCard(
              title: 'Recovery',
              value: '${dashboard.recovery.percentage}%',
              subtitle: dashboard.recovery.label,
              icon: Icons.battery_charging_full_rounded,
              color: context.success,
            ),
            FreshnessCard(freshness: dashboard.freshness),
            HealthMetricCard(
              title: 'Wellness',
              value: '${dashboard.wellness.score}',
              subtitle: dashboard.wellness.label,
              icon: Icons.self_improvement_rounded,
              color: context.sky,
            ),
            FatigueCard(fatigue: dashboard.fatigue),
          ],
        ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'What Matters Every Day'),
        _NonNegotiablesCard(dashboard: dashboard),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Load Monitor'),
        _LoadMonitorCard(dashboard: dashboard),
        if (dashboard.bowlingLoad != null || dashboard.battingLoad != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              if (dashboard.bowlingLoad != null)
                Expanded(
                  child: _SkillLoadCard(
                    title: 'Bowling Load',
                    value: '${dashboard.bowlingLoad!.balls}',
                    unit: 'balls',
                    label: dashboard.bowlingLoad!.label,
                    intensity: dashboard.bowlingLoad!.intensity,
                    icon: Icons.sports_baseball_rounded,
                    color: context.warn,
                  ),
                ),
              if (dashboard.bowlingLoad != null &&
                  dashboard.battingLoad != null)
                const SizedBox(width: 12),
              if (dashboard.battingLoad != null)
                Expanded(
                  child: _SkillLoadCard(
                    title: 'Batting Load',
                    value: '${dashboard.battingLoad!.balls}',
                    unit: 'balls',
                    label: dashboard.battingLoad!.label,
                    intensity: dashboard.battingLoad!.intensity,
                    icon: Icons.sports_cricket_rounded,
                    color: context.gold,
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        const SectionHeader(title: 'Athlete Insights'),
        if (dashboard.insights.isEmpty)
          const _EmptyState(
            message:
                'No insights yet. Log wellness and session load consistently to unlock coaching-grade guidance.',
          )
        else
          ...dashboard.insights.map((i) => _InsightItem(insight: i)),
      ],
    );
  }
}

class _PremiumReadinessHero extends StatelessWidget {
  const _PremiumReadinessHero({required this.dashboard});

  final HealthDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.accent.withValues(alpha: 0.95),
            Color.alphaBlend(
                context.sky.withValues(alpha: 0.28), context.panel),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: context.accent.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ATHLETE READINESS',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.84),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dashboard.readiness.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dashboard.readiness.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.28)),
                ),
                child: Center(
                  child: Text(
                    '${dashboard.readiness.score}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroPill(
                icon: Icons.favorite_rounded,
                label: 'Recovery ${dashboard.recovery.percentage}%',
              ),
              _HeroPill(
                icon: Icons.auto_awesome_rounded,
                label: 'Freshness ${dashboard.freshness.score}%',
              ),
              _HeroPill(
                icon: Icons.show_chart_rounded,
                label: 'Load ${dashboard.workload.label}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.self_improvement_rounded,
            label: 'Morning Check-In',
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const WellnessCheckInSheet(),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.bolt_rounded,
            label: 'Log Session',
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const WorkloadLogSheet(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.stroke),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: context.accent, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NonNegotiablesCard extends StatelessWidget {
  const _NonNegotiablesCard({required this.dashboard});

  final HealthDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SignalTile(
                  label: 'Soreness',
                  value: '${dashboard.wellness.soreness}/10',
                  icon: Icons.accessibility_new_rounded,
                  color: context.warn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SignalTile(
                  label: 'Stress',
                  value: '${dashboard.wellness.stress}/10',
                  icon: Icons.psychology_alt_rounded,
                  color: context.sky,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SignalTile(
                  label: 'Mood',
                  value: '${dashboard.wellness.mood}/10',
                  icon: Icons.sentiment_satisfied_rounded,
                  color: context.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SignalTile(
                  label: 'Last Check-In',
                  value: _lastCheckInLabel(dashboard.wellness.lastCheckIn),
                  icon: Icons.schedule_rounded,
                  color: context.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _lastCheckInLabel(DateTime? value) {
    if (value == null) return 'Pending';
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(value.year, value.month, value.day))
        .inDays;
    if (days <= 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return '${days}d ago';
  }
}

class _SignalTile extends StatelessWidget {
  const _SignalTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: context.fg,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadMonitorCard extends StatelessWidget {
  const _LoadMonitorCard({required this.dashboard});

  final HealthDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final ratio = dashboard.workload.ratio;
    final progress = ratio <= 0 ? 0.0 : (ratio / 1.8).clamp(0.0, 1.0);
    final tone = dashboard.workload.status == 'high'
        ? context.warn
        : dashboard.workload.status == 'optimal'
            ? context.success
            : context.sky;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.show_chart_rounded, color: tone),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acute vs Chronic Workload',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dashboard.workload.label,
                      style: TextStyle(
                        color: tone,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                ratio == 0 ? '--' : ratio.toStringAsFixed(2),
                style: TextStyle(
                  color: context.fg,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: context.panel,
              valueColor: AlwaysStoppedAnimation<Color>(tone),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _LoadStat(
                  label: 'Last 7d',
                  value: dashboard.workload.current7d.toStringAsFixed(0),
                ),
              ),
              Expanded(
                child: _LoadStat(
                  label: 'Baseline 28d',
                  value: dashboard.workload.baseline28d.toStringAsFixed(0),
                ),
              ),
              Expanded(
                child: _LoadStat(
                  label: 'Status',
                  value: dashboard.workload.status.toUpperCase(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadStat extends StatelessWidget {
  const _LoadStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.fgSub,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: context.fg,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SkillLoadCard extends StatelessWidget {
  const _SkillLoadCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.label,
    required this.intensity,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String unit;
  final String label;
  final String intensity;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Text(
                intensity,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  const _InsightItem({required this.insight});

  final HealthInsight insight;

  @override
  Widget build(BuildContext context) {
    final color = insight.type == 'warning' ? context.warn : context.success;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(
            insight.type == 'warning'
                ? Icons.warning_amber_rounded
                : Icons.lightbulb_outline_rounded,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  insight.message,
                  style: TextStyle(color: context.fgSub, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: context.fgSub, fontSize: 13),
      ),
    );
  }
}
