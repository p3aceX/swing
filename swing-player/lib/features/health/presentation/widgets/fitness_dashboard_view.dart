import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/fitness_models.dart';
import '../../domain/health_models.dart';

class FitnessDashboardView extends StatelessWidget {
  const FitnessDashboardView({
    super.key,
    required this.dashboard,
    required this.summary,
  });

  final HealthDashboard dashboard;
  final FitnessSummary summary;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _TrainingHero(dashboard: dashboard, summary: summary),
          const SizedBox(height: 12),
          _TrainingLoadCard(dashboard: dashboard, summary: summary),
          const SizedBox(height: 12),
          _SessionListCard(sessions: summary.sessions),
          const SizedBox(height: 12),
          _MuscleCoverageCard(summary: summary),
          const SizedBox(height: 12),
          _FitnessInsightsCard(dashboard: dashboard),
        ]),
      ),
    );
  }
}

class _TrainingHero extends StatelessWidget {
  const _TrainingHero({required this.dashboard, required this.summary});

  final HealthDashboard dashboard;
  final FitnessSummary summary;

  @override
  Widget build(BuildContext context) {
    final exerciseCount = summary.sessions.fold<int>(
      0,
      (sum, session) => sum + session.exercises.length,
    );
    final totalMinutes = summary.sessions.fold<int>(
      0,
      (sum, session) => sum + session.totalDuration,
    );
    final readiness = dashboard.readiness.score.clamp(0, 100);

    return _FitnessCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s training',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exerciseCount == 0
                          ? 'Log your first session to track load.'
                          : '$exerciseCount exercise${exerciseCount == 1 ? '' : 's'} logged today.',
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _ReadinessBadge(score: readiness),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _HeroMetric(
                label: 'Sessions',
                value: '${summary.sessions.length}',
                icon: Icons.event_available_rounded,
                color: context.accent,
              ),
              const SizedBox(width: 8),
              _HeroMetric(
                label: 'Exercises',
                value: '$exerciseCount',
                icon: Icons.fitness_center_rounded,
                color: context.gold,
              ),
              const SizedBox(width: 8),
              _HeroMetric(
                label: 'Minutes',
                value: '${totalMinutes}m',
                icon: Icons.timer_rounded,
                color: context.sky,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadinessBadge extends StatelessWidget {
  const _ReadinessBadge({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 70
        ? context.success
        : score >= 45
            ? context.gold
            : context.danger;
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$score',
            style: TextStyle(
              color: color,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'ready',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: context.fg,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingLoadCard extends StatelessWidget {
  const _TrainingLoadCard({required this.dashboard, required this.summary});

  final HealthDashboard dashboard;
  final FitnessSummary summary;

  @override
  Widget build(BuildContext context) {
    final current = dashboard.workload.current7d;
    final baseline = dashboard.workload.baseline28d;
    final ratio = baseline > 0 ? (current / baseline).clamp(0.0, 1.5) : 0.0;
    final status = dashboard.workload.label.isEmpty
        ? 'No load yet'
        : dashboard.workload.label;
    final statusColor = dashboard.workload.status == 'high' ||
            dashboard.workload.status == 'overload'
        ? context.danger
        : dashboard.workload.status == 'optimal'
            ? context.success
            : context.gold;

    return _FitnessCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            icon: Icons.show_chart_rounded,
            title: 'Training load',
            color: statusColor,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${current.toStringAsFixed(0)} / ${baseline.toStringAsFixed(0)}',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ProgressBar(value: ratio / 1.5, color: statusColor),
          const SizedBox(height: 12),
          Row(
            children: [
              _LoadPill(
                label: 'Fatigue',
                value: summary.totalFatigueImpact.toStringAsFixed(1),
                color: context.warn,
              ),
              const SizedBox(width: 8),
              _LoadPill(
                label: 'Recovery',
                value: summary.totalRecoveryLoad.toStringAsFixed(1),
                color: context.sky,
              ),
              const SizedBox(width: 8),
              _LoadPill(
                label: 'Freshness',
                value: '${dashboard.freshness.score}',
                color: context.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadPill extends StatelessWidget {
  const _LoadPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionListCard extends StatelessWidget {
  const _SessionListCard({required this.sessions});
  final List<WorkoutSession> sessions;

  @override
  Widget build(BuildContext context) {
    return _FitnessCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            icon: Icons.receipt_long_rounded,
            title: 'Logged sessions',
            color: Colors.transparent,
          ),
          const SizedBox(height: 12),
          if (sessions.isEmpty)
            _EmptyTrainingLog()
          else
            ...sessions.map(
              (session) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SessionRow(session: session),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyTrainingLog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.panel.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.stroke.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Icon(Icons.add_task_rounded, color: context.fgSub, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'No exercises selected yet. Log a session to see sets, reps, duration, and load here.',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session});
  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final exerciseNames =
        session.exercises.take(2).map((e) => e.exercise.name).join(', ');
    final extra =
        session.exercises.length > 2 ? ' +${session.exercises.length - 2}' : '';
    final time = TimeOfDay.fromDateTime(session.loggedAt).format(context);
    final color = switch (session.intensity) {
      SessionIntensity.low => context.sky,
      SessionIntensity.moderate => context.gold,
      SessionIntensity.intense => context.danger,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.panel.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.stroke.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.fitness_center_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exerciseNames.isEmpty
                      ? 'Training session'
                      : '$exerciseNames$extra',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${session.exercises.length} exercise${session.exercises.length == 1 ? '' : 's'}'
                  ' • ${session.totalDuration} min'
                  ' • ${session.intensity.name}',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleCoverageCard extends StatelessWidget {
  const _MuscleCoverageCard({required this.summary});
  final FitnessSummary summary;

  @override
  Widget build(BuildContext context) {
    final coverage = _coverage(summary);
    return _FitnessCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            icon: Icons.accessibility_new_rounded,
            title: 'Body coverage',
            color: context.accent,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _CoverageTile(
                label: 'Upper',
                value: coverage.$1,
                color: context.sky,
              ),
              const SizedBox(width: 8),
              _CoverageTile(
                label: 'Core',
                value: coverage.$2,
                color: context.gold,
              ),
              const SizedBox(width: 8),
              _CoverageTile(
                label: 'Lower',
                value: coverage.$3,
                color: context.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  (double, double, double) _coverage(FitnessSummary summary) {
    if (summary.muscleCoverage.isNotEmpty) {
      double read(String key) => (summary.muscleCoverage[key] ?? 0).clamp(0, 1);
      return (read('Upper'), read('Core'), read('Lower'));
    }

    final tags = summary.sessions
        .expand((session) => session.exercises)
        .expand((entry) => entry.exercise.bodyAreaTags)
        .map((tag) => tag.toLowerCase())
        .toList();
    if (tags.isEmpty) return (0, 0, 0);

    double score(List<String> needles) {
      return tags.where((tag) => needles.any(tag.contains)).length.clamp(0, 3) /
          3;
    }

    return (
      score(['upper', 'shoulder', 'chest', 'back', 'arm']),
      score(['core', 'abs', 'trunk']),
      score(['lower', 'leg', 'hip', 'glute', 'hamstring', 'quad'])
    );
  }
}

class _CoverageTile extends StatelessWidget {
  const _CoverageTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            _ProgressBar(value: value, color: color, height: 5),
            const SizedBox(height: 7),
            Text(
              label,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FitnessInsightsCard extends StatelessWidget {
  const _FitnessInsightsCard({required this.dashboard});
  final HealthDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final insights = dashboard.insights;
    return _FitnessCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            icon: Icons.lightbulb_rounded,
            title: 'Coaching notes',
            color: context.gold,
          ),
          const SizedBox(height: 12),
          if (insights.isEmpty)
            Text(
              'Log training and wellness together to unlock better readiness notes.',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 12,
                height: 1.4,
              ),
            )
          else
            ...insights.take(3).map(
                  (insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      insight.message.isNotEmpty
                          ? insight.message
                          : insight.title,
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _FitnessCard extends StatelessWidget {
  const _FitnessCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.stroke.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tone = color == Colors.transparent ? context.accent : color;
    return Row(
      children: [
        Icon(icon, color: tone, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: context.fg,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.value,
    required this.color,
    this.height = 7,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: context.stroke.withValues(alpha: 0.5),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
