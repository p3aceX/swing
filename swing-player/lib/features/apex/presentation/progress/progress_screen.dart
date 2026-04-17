import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../shared/apex_theme.dart';
import '../../shared/apex_models.dart';
import '../../shared/apex_api_service.dart';
import '../../../elite/controller/elite_controller.dart';
import '../../../elite/domain/elite_models.dart';
import '../apex_shell.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  PROGRESS Screen — "Plan vs Execution"
//
//  Data sources (CORRECT):
//    • journalConsistencyProvider(30) → real plan vs execution heatmap
//    • apexHealthDashboardProvider    → calorie/sleep/hydration KPIs
//    • eliteProfileProvider           → goal targets (calorie/sleep/hydration)
// ─────────────────────────────────────────────────────────────────────────────

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(eliteProfileProvider);
    final aimDone = profileAsync.asData?.value.goal?.targetRole.isNotEmpty ?? false;

    if (profileAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          ApexShimmerBox(height: 160),
          SizedBox(height: 16),
          ApexShimmerBox(height: 220),
        ]),
      );
    }

    if (!aimDone) {
      return ApexAimNotSetWidget(
        onSetMission: () => ApexTabScope.of(context)?.animateTo(0),
      );
    }

    final consistencyAsync = ref.watch(journalConsistencyProvider(30));
    final health = ref.watch(apexHealthDashboardProvider);

    return RefreshIndicator(
      color: ApexColors.accentProgress,
      backgroundColor: ApexColors.surface,
      onRefresh: () async {
        ref.invalidate(journalConsistencyProvider(30));
        ref.invalidate(apexHealthDashboardProvider);
        ref.invalidate(eliteProfileProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        children: [
          // ── A: Plan vs Execution Heatmap (PRIMARY) ───────────────────────
          consistencyAsync.when(
            loading: () => const ApexShimmerBox(height: 200),
            error: (_, __) => ApexErrorWidget(
              onRetry: () => ref.invalidate(journalConsistencyProvider(30)),
            ),
            data: (c) => _JournalConsistencyHeatmap(consistency: c),
          ),
          const SizedBox(height: 16),

          // ── B: This Week Adherence (from journalConsistency) ─────────────
          consistencyAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (c) => c.weekly.adherence.isNotEmpty
                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _SectionHeading(label: 'THIS WEEK — PLAN vs EXECUTION'),
                    const SizedBox(height: 10),
                    _AdherenceGrid(weekly: c.weekly),
                    const SizedBox(height: 16),
                  ])
                : const SizedBox.shrink(),
          ),

          // ── C: KPI Cards ─────────────────────────────────────────────────
          _SectionHeading(label: 'HEALTH METRICS'),
          const SizedBox(height: 12),
          health.when(
            loading: () => const ApexShimmerBox(height: 280),
            error: (_, __) => const _HealthMetricsEmpty(),
            data: (h) {
              final goal = profileAsync.asData?.value.goal;
              return _KpiGrid(
                health: h,
                summary: null,
                calorieGoal: goal?.dailyCalorieTarget?.toDouble() ?? h.caloriesGoal,
                sleepGoal: goal?.dailySleepHoursGoal ?? h.sleepGoalHours,
                hydrationGoal: goal?.dailyHydrationLitresGoal ?? h.hydrationGoalLitres,
                trainingGoal: goal?.trainingDaysPerWeek ?? h.trainingDaysGoal,
              );
            },
          ),
          const SizedBox(height: 20),

          // ── D: Body Direction ────────────────────────────────────────────
          health.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (h) => h.weightHistory.isEmpty
                ? const SizedBox.shrink()
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _SectionHeading(label: 'BODY DIRECTION'),
                    const SizedBox(height: 12),
                    _BodyDirectionChart(
                      data: h.weightHistory,
                      targetWeight: profileAsync.asData?.value.goal?.targetWeight,
                      bodyTransform: profileAsync.asData?.value.goal?.bodyTransformDirection,
                    ),
                  ]),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  A: Journal Consistency Heatmap (primary — uses real journalConsistency data)
// ─────────────────────────────────────────────────────────────────────────────

class _JournalConsistencyHeatmap extends StatelessWidget {
  const _JournalConsistencyHeatmap({required this.consistency});
  final JournalConsistency consistency;

  @override
  Widget build(BuildContext context) {
    final summary = consistency.summary;
    final days = consistency.days;
    final streak = summary.currentStreak;
    final pct = summary.planVsExecutionPct.clamp(0, 100);
    final pctColor = pct >= 75 ? ApexColors.accentProgress
        : pct >= 50 ? ApexColors.accentEvaluate
        : ApexColors.accentXlerate;

    return ApexCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          const _SectionHeadingInline(label: 'CONSISTENCY'),
          const Spacer(),
          Text('${days.length} days',
              style: ApexTextStyles.labelMuted.copyWith(fontSize: 10)),
        ]),
        const SizedBox(height: 12),

        // Stats row
        Row(children: [
          _ConsistencyStat(
            label: 'STREAK',
            value: '🔥 $streak days',
            color: ApexColors.accentProgress,
          ),
          const SizedBox(width: 20),
          Container(width: 0.5, height: 32, color: ApexColors.border),
          const SizedBox(width: 20),
          _ConsistencyStat(
            label: 'EXECUTION',
            value: '${pct.toStringAsFixed(0)}%',
            color: pctColor,
          ),
          const SizedBox(width: 20),
          Container(width: 0.5, height: 32, color: ApexColors.border),
          const SizedBox(width: 20),
          _ConsistencyStat(
            label: 'LOGGED DAYS',
            value: '${summary.executedDays}/${summary.plannedDays}',
            color: ApexColors.textPrimary,
          ),
        ]),
        const SizedBox(height: 16),

        // Dot grid — 5 weeks × 7 days
        if (days.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No journal entries yet.\nTap LOG TODAY to start.',
                  style: ApexTextStyles.labelMuted, textAlign: TextAlign.center),
            ),
          )
        else
          _ConsistencyDotGrid(days: days),

        const SizedBox(height: 12),

        // Legend
        Row(children: [
          _LegendDot(color: ApexColors.accentProgress, label: 'Done'),
          const SizedBox(width: 10),
          _LegendDot(color: ApexColors.accentEvaluate, label: 'Partial'),
          const SizedBox(width: 10),
          _LegendDot(color: const Color(0xFF2A1A1A), label: 'Missed'),
          const SizedBox(width: 10),
          _LegendDot(color: const Color(0xFF111418), label: 'Rest'),
        ]),
      ]),
    );
  }
}

class _ConsistencyStat extends StatelessWidget {
  const _ConsistencyStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: ApexTextStyles.labelCaps),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(
          color: color, fontSize: 14, fontWeight: FontWeight.w800)),
    ]);
  }
}

class _ConsistencyDotGrid extends StatelessWidget {
  const _ConsistencyDotGrid({required this.days});
  final List<JournalDay> days;

  Color _cellColor(JournalDay d) {
    if (!d.isPlannedDay) return const Color(0xFF111418);
    if (d.isExecutedDay) {
      if (d.executionScore >= 80) return ApexColors.accentProgress;
      if (d.executionScore >= 50) return const Color(0xFF1D6B3A);
      return const Color(0xFF1A3A25);
    }
    if (d.hasWorkload || d.actualActivityCount > 0) return ApexColors.accentEvaluate;
    return const Color(0xFF2A1A1A);
  }

  @override
  Widget build(BuildContext context) {
    final recent = days.reversed.take(35).toList().reversed.toList();

    return Wrap(
      spacing: 4, runSpacing: 4,
      children: recent.map((d) {
        final color = _cellColor(d);
        return Tooltip(
          message: DateFormat('d MMM').format(d.date),
          child: Container(
            width: 14, height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── B: Adherence Grid (per activity type from journalWeekly) ─────────────────

class _AdherenceGrid extends StatelessWidget {
  const _AdherenceGrid({required this.weekly});
  final JournalWeekly weekly;

  @override
  Widget build(BuildContext context) {
    final entries = weekly.adherence.entries.toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      children: entries.take(6).map((e) {
        final pct = e.value.completionPct.clamp(0, 100);
        final color = pct >= 75 ? ApexColors.accentProgress
            : pct >= 50 ? ApexColors.accentEvaluate
            : ApexColors.accentXlerate;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(e.key.toUpperCase(),
                  style: const TextStyle(
                      color: ApexColors.textPrimary, fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${e.value.actual} / ${e.value.planned}',
                  style: TextStyle(color: color, fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 4),
            LayoutBuilder(builder: (_, constraints) => Stack(children: [
              Container(
                height: 5,
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                    color: ApexColors.background,
                    borderRadius: BorderRadius.circular(3)),
              ),
              FractionallySizedBox(
                widthFactor: (pct / 100).clamp(0.0, 1.0),
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3)),
                ),
              ),
            ])),
          ]),
        );
      }).toList(),
    );
  }
}

class _HealthMetricsEmpty extends StatelessWidget {
  const _HealthMetricsEmpty();

  @override
  Widget build(BuildContext context) {
    return const ApexCard(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.monitor_heart_outlined,
                color: ApexColors.textDim, size: 28),
            SizedBox(height: 10),
            Text('Log daily activities to see\nhealth metrics here.',
                style: ApexTextStyles.labelMuted, textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  B: KPI Cards 2×2 grid
// ─────────────────────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({
    required this.health,
    this.summary,
    required this.calorieGoal,
    required this.sleepGoal,
    required this.hydrationGoal,
    required this.trainingGoal,
  });
  final HealthDashboard health;
  final ExecuteSummary? summary;
  final double calorieGoal, sleepGoal, hydrationGoal;
  final int trainingGoal;

  @override
  Widget build(BuildContext context) {
    final calPct = calorieGoal > 0
        ? (health.caloriesConsumedToday / calorieGoal).clamp(0.0, 1.1)
        : 0.0;
    final sleepPct = sleepGoal > 0
        ? (health.sleepAvgHours / sleepGoal).clamp(0.0, 1.0)
        : 0.0;
    final hydroPct = hydrationGoal > 0
        ? (health.hydrationAvgLitres / hydrationGoal).clamp(0.0, 1.0)
        : 0.0;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _CalorieCard(
          consumed: health.caloriesConsumedToday,
          goal: calorieGoal,
          pct: calPct,
        ),
        _HydrationCard(
          litres: health.hydrationAvgLitres,
          goal: hydrationGoal,
          pct: hydroPct,
        ),
        _SleepCard(
          hours: health.sleepAvgHours,
          goal: sleepGoal,
          pct: sleepPct,
        ),
        _TrainingDaysCard(
          done: health.trainingDaysThisWeek,
          goal: trainingGoal,
          summary: summary,   // nullable ok
        ),
      ],
    );
  }
}

Color _adherenceColor(double pct) {
  if (pct >= 0.8) return ApexColors.accentProgress;
  if (pct >= 0.5) return ApexColors.accentEvaluate;
  return ApexColors.accentXlerate;
}

class _CalorieCard extends StatelessWidget {
  const _CalorieCard({
    required this.consumed,
    required this.goal,
    required this.pct,
  });
  final double consumed, goal, pct;

  @override
  Widget build(BuildContext context) {
    final color = _adherenceColor(pct.clamp(0.0, 1.0));
    return ApexCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('CALORIES', style: ApexTextStyles.labelCaps),
        const Spacer(),
        SizedBox.square(
          dimension: 64,
          child: CustomPaint(
            painter: _DonutPainter(value: pct.clamp(0.0, 1.0), color: color),
            child: Center(
              child: Text('${(pct * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                      color: color, fontSize: 14, fontWeight: FontWeight.w800)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('${consumed.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} kcal',
            style: ApexTextStyles.labelMuted),
      ]),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.value, required this.color});
  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 6.0;
    final rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
        size.width - strokeWidth, size.height - strokeWidth);

    final bg = Paint()
      ..color = ApexColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, math.pi * 2, false, bg);

    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, fg);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.value != value;
}

class _HydrationCard extends StatelessWidget {
  const _HydrationCard({required this.litres, required this.goal, required this.pct});
  final double litres, goal, pct;

  @override
  Widget build(BuildContext context) {
    final color = _adherenceColor(pct);
    return ApexCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('HYDRATION', style: ApexTextStyles.labelCaps),
        const Spacer(),
        Text('${litres.toStringAsFixed(1)} L',
            style: ApexTextStyles.kpiNumber.copyWith(fontSize: 28, color: color)),
        const SizedBox(height: 4),
        Text('of ${goal.toStringAsFixed(1)} L goal',
            style: ApexTextStyles.labelMuted),
        const SizedBox(height: 10),
        _ProgressBar(value: pct, color: color),
      ]),
    );
  }
}

class _SleepCard extends StatelessWidget {
  const _SleepCard({required this.hours, required this.goal, required this.pct});
  final double hours, goal, pct;

  @override
  Widget build(BuildContext context) {
    final color = _adherenceColor(pct);
    return ApexCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('SLEEP', style: ApexTextStyles.labelCaps),
        const Spacer(),
        Text('${hours.toStringAsFixed(1)} hrs',
            style: ApexTextStyles.kpiNumber.copyWith(fontSize: 24, color: color)),
        const SizedBox(height: 4),
        Text('avg · ${goal.toStringAsFixed(1)} hr goal',
            style: ApexTextStyles.labelMuted),
        const SizedBox(height: 10),
        _ProgressBar(value: pct, color: color),
      ]),
    );
  }
}

class _TrainingDaysCard extends StatelessWidget {
  const _TrainingDaysCard({
    required this.done,
    required this.goal,
    this.summary,
  });
  final int done, goal;
  final ExecuteSummary? summary;

  @override
  Widget build(BuildContext context) {
    final color = _adherenceColor(goal > 0 ? done / goal : 0);
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return ApexCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('TRAINING', style: ApexTextStyles.labelCaps),
        const Spacer(),
        Text('$done / $goal days',
            style: ApexTextStyles.kpiNumber.copyWith(fontSize: 22, color: color)),
        const SizedBox(height: 4),
        const Text('this week', style: ApexTextStyles.labelMuted),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final active = i < done;
            return Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: active ? color : ApexColors.background,
                shape: BoxShape.circle,
                border: Border.all(
                    color: active ? color : ApexColors.border, width: 0.5),
              ),
              child: Center(
                child: Text(days[i],
                    style: TextStyle(
                        color: active ? Colors.white : ApexColors.textMuted,
                        fontSize: 9, fontWeight: FontWeight.w700)),
              ),
            );
          }),
        ),
      ]),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value, required this.color});
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      return Container(
        height: 6,
        width: constraints.maxWidth,
        decoration: BoxDecoration(
          color: ApexColors.background,
          borderRadius: BorderRadius.circular(3),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  D: Body Direction Chart
// ─────────────────────────────────────────────────────────────────────────────

class _BodyDirectionChart extends StatelessWidget {
  const _BodyDirectionChart({
    required this.data,
    this.targetWeight,
    this.bodyTransform,
  });
  final List<WeightDataPoint> data;
  final double? targetWeight;
  final String? bodyTransform;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const ApexCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No weight data yet', style: ApexTextStyles.labelMuted),
          ),
        ),
      );
    }

    final weights = data.map((d) => d.weightKg).toList();
    final minW = weights.reduce(math.min) - 3;
    final maxW = weights.reduce(math.max) + 3;

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weightKg);
    }).toList();

    final firstW = weights.first;
    final lastW  = weights.last;
    final diff   = lastW - firstW;
    final isGoingWell = (bodyTransform == 'LOSE_FAT' && diff <= 0) ||
        (bodyTransform == 'BUILD_MUSCLE' && diff >= 0) ||
        bodyTransform == 'MAINTAIN';
    final lineColor = isGoingWell ? ApexColors.accentProgress : ApexColors.accentXlerate;

    return ApexCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const _SectionHeadingInline(label: 'WEIGHT TREND'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: lineColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: lineColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              diff >= 0 ? '↑ ${diff.abs().toStringAsFixed(1)} kg' : '↓ ${diff.abs().toStringAsFixed(1)} kg',
              style: TextStyle(color: lineColor, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: LineChart(
            LineChartData(
              backgroundColor: Colors.transparent,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (v, _) => Text(
                      v.toStringAsFixed(0),
                      style: ApexTextStyles.labelCaps.copyWith(fontSize: 9),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 20,
                    interval: math.max(1, (spots.length / 4).floor()).toDouble(),
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                      try {
                        final date = DateTime.parse(data[idx].date);
                        return Text(DateFormat('d/M').format(date),
                            style: ApexTextStyles.labelCaps.copyWith(fontSize: 8));
                      } catch (_) {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ),
              minY: minW,
              maxY: maxW,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: lineColor,
                  barWidth: 2,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: lineColor.withValues(alpha: 0.06),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared local widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            color: ApexColors.textMuted, fontSize: 11,
            fontWeight: FontWeight.w800, letterSpacing: 1.5));
  }
}

class _SectionHeadingInline extends StatelessWidget {
  const _SectionHeadingInline({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            color: ApexColors.textMuted, fontSize: 10,
            fontWeight: FontWeight.w800, letterSpacing: 1.5));
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 8, height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(label, style: ApexTextStyles.labelMuted.copyWith(fontSize: 10)),
    ]);
  }
}


