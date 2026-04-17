import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/health_controller.dart';
import '../domain/health_models.dart';

class HealthDashboardScreen extends ConsumerWidget {
  const HealthDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(healthDashboardProvider);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: const Text('Health & Performance'),
        actions: [
          IconButton(
            onPressed: () => ref.read(healthDashboardProvider.notifier).load(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: state.when(
        data: (dashboard) => _DashboardBody(dashboard: dashboard),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load health data', style: TextStyle(color: context.fg)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(healthDashboardProvider.notifier).load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.dashboard});
  final HealthDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ReadinessHero(readiness: dashboard.readiness),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Recovery',
                value: '${dashboard.recovery.percentage}%',
                subtitle: dashboard.recovery.label,
                icon: Icons.battery_charging_full_rounded,
                color: context.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Freshness',
                value: '${dashboard.freshness.score}',
                subtitle: dashboard.freshness.label,
                icon: Icons.auto_awesome_rounded,
                color: context.sky,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _WorkloadCard(workload: dashboard.workload),
        const SizedBox(height: 12),
        _WellnessCard(wellness: dashboard.wellness),
        const SizedBox(height: 12),
        if (dashboard.bowlingLoad != null || dashboard.battingLoad != null)
          _TrainingLoadRow(
            bowling: dashboard.bowlingLoad,
            batting: dashboard.battingLoad,
          ),
        const SizedBox(height: 12),
        if (dashboard.insights.isNotEmpty) ...[
          Text(
            'Performance Insights',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...dashboard.insights.map((i) => _InsightCard(insight: i)),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/wellness-checkin'),
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text('Wellness'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/workload-log'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Log Workload'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _ReadinessHero extends StatelessWidget {
  const _ReadinessHero({required this.readiness});
  final SwingReadiness readiness;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.accent,
            context.accent.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.accent.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Swing Readiness',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    readiness.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${readiness.score}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            readiness.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: context.fg,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkloadCard extends StatelessWidget {
  const _WorkloadCard({required this.workload});
  final WorkloadStats workload;

  @override
  Widget build(BuildContext context) {
    final progress = (workload.current7d / workload.baseline28d).clamp(0.0, 1.0);
    final statusColor = workload.status == 'optimal'
        ? context.accent
        : (workload.status == 'high' ? context.danger : context.warn);

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chronic Workload',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  workload.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '${workload.current7d.toInt()}',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                ' / ${workload.baseline28d.toInt()} units',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: context.panel,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            workload.label,
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

class _WellnessCard extends StatelessWidget {
  const _WellnessCard({required this.wellness});
  final WellnessStats wellness;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.gold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite_rounded, color: context.gold, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wellness Score',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  wellness.label,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${wellness.score}',
            style: TextStyle(
              color: context.gold,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainingLoadRow extends StatelessWidget {
  const _TrainingLoadRow({this.bowling, this.batting});
  final BowlingLoad? bowling;
  final BattingLoad? batting;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (bowling != null)
          Expanded(
            child: _LoadItem(
              title: 'Bowling',
              value: '${bowling!.balls}',
              unit: 'balls',
              intensity: bowling!.intensity,
              color: context.sky,
            ),
          ),
        if (bowling != null && batting != null) const SizedBox(width: 12),
        if (batting != null)
          Expanded(
            child: _LoadItem(
              title: 'Batting',
              value: '${batting!.balls}',
              unit: 'balls',
              intensity: batting!.intensity,
              color: context.warn,
            ),
          ),
      ],
    );
  }
}

class _LoadItem extends StatelessWidget {
  const _LoadItem({
    required this.title,
    required this.value,
    required this.unit,
    required this.intensity,
    required this.color,
  });

  final String title;
  final String value;
  final String unit;
  final String intensity;
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
          Text(
            title,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: context.fg,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            intensity,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});
  final HealthInsight insight;

  @override
  Widget build(BuildContext context) {
    final color = insight.type == 'warning'
        ? context.warn
        : (insight.type == 'success' ? context.accent : context.sky);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            insight.type == 'warning'
                ? Icons.warning_amber_rounded
                : Icons.tips_and_updates_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.message,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
