import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/apex_theme.dart';
import '../../shared/apex_models.dart';
import '../../shared/apex_api_service.dart';
import '../../../elite/controller/elite_controller.dart';
import '../apex_shell.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  XLERATE Screen — "What's the fastest path to improve?"
//  A: AI insight cards carousel
//  B: Recommended actions list
//  C: Priority focus areas
//  D: Coach drill assignments
//  E: Benchmark snapshot
// ─────────────────────────────────────────────────────────────────────────────

class XlerateScreen extends ConsumerWidget {
  const XlerateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apexAsync = ref.watch(apexStateProvider);
    final aimDone = apexAsync.asData?.value.goal.targetRole?.isNotEmpty ?? false;

    if (!aimDone) {
      return ApexAimNotSetWidget(
        onSetMission: () => ApexTabScope.of(context)?.animateTo(0),
      );
    }

    final weeklyReview = ref.watch(apexWeeklyReviewProvider);
    final signals      = ref.watch(apexSignalsProvider);
    final benchmarks   = ref.watch(apexBenchmarksProvider);
    final drills       = ref.watch(apexDrillAssignmentsProvider);
    final analytics    = ref.watch(apexAnalyticsProvider);

    return RefreshIndicator(
      color: ApexColors.accentXlerate,
      backgroundColor: ApexColors.surface,
      onRefresh: () async {
        ref.invalidate(apexWeeklyReviewProvider);
        ref.invalidate(apexSignalsProvider);
        ref.invalidate(apexBenchmarksProvider);
        ref.invalidate(apexDrillAssignmentsProvider);
        ref.invalidate(apexAnalyticsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        children: [
          // ── A: Insights Carousel ─────────────────────────────────────────
          const _SectionLabel(label: 'THIS WEEK\'S INSIGHTS'),
          const SizedBox(height: 12),
          _InsightsCarouselSection(
            weeklyReview: weeklyReview,
            signalsAsync: signals,
          ),
          const SizedBox(height: 24),

          // ── B: Recommendations ───────────────────────────────────────────
          const _SectionLabel(label: 'RECOMMENDED ACTIONS'),
          const SizedBox(height: 12),
          weeklyReview.when(
            loading: () => const ApexShimmerBox(height: 200),
            error: (_, __) => ApexErrorWidget(
                onRetry: () => ref.invalidate(apexWeeklyReviewProvider)),
            data: (wr) => _RecommendationsList(recommendations: wr.recommendations),
          ),
          const SizedBox(height: 24),

          // ── C: Priority Focus Areas ──────────────────────────────────────
          const _SectionLabel(label: 'PRIORITY FOCUS AREAS'),
          const SizedBox(height: 12),
          analytics.when(
            loading: () => const ApexShimmerBox(height: 240),
            error: (_, __) => const SizedBox.shrink(),
            data: (a) => apexAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (apex) => _PriorityFocusSection(
                analytics: a,
                playerRole: apex.goal.targetRole ?? '',
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── D: Drill Assignments ─────────────────────────────────────────
          drills.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (d) {
              if (d.isEmpty) return const SizedBox.shrink();
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const _SectionLabel(label: 'COACH ASSIGNMENTS'),
                const SizedBox(height: 4),
                Text('${d.length} active drills from your coach',
                    style: ApexTextStyles.labelMuted),
                const SizedBox(height: 12),
                _DrillAssignmentsList(
                  assignments: d,
                  onLog: (id, reps, mins) async {
                    await ref.read(apexApiServiceProvider)
                        .logDrillProgress(id, reps: reps, minutes: mins);
                    ref.invalidate(apexDrillAssignmentsProvider);
                  },
                ),
                const SizedBox(height: 24),
              ]);
            },
          ),

          // ── E: Benchmarks ────────────────────────────────────────────────
          benchmarks.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (b) {
              if (b.entries.isEmpty) return const SizedBox.shrink();
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const _SectionLabel(label: 'VS PEERS'),
                const SizedBox(height: 12),
                _BenchmarkGrid(benchmarks: b),
              ]);
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  A: Insights Carousel
// ─────────────────────────────────────────────────────────────────────────────

class _InsightsCarouselSection extends ConsumerStatefulWidget {
  const _InsightsCarouselSection({
    required this.weeklyReview,
    required this.signalsAsync,
  });
  final AsyncValue<WeeklyReview> weeklyReview;
  final AsyncValue<List<Signal>> signalsAsync;

  @override
  ConsumerState<_InsightsCarouselSection> createState() =>
      _InsightsCarouselSectionState();
}

class _InsightsCarouselSectionState
    extends ConsumerState<_InsightsCarouselSection> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.weeklyReview.isLoading || widget.signalsAsync.isLoading;
    if (isLoading) return const ApexShimmerBox(height: 180);

    final allSignals = [
      ...widget.weeklyReview.asData?.value.insights ?? [],
      ...widget.signalsAsync.asData?.value ?? [],
    ].take(5).toList();

    if (allSignals.isEmpty) {
      return ApexCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: const [
              Icon(Icons.insights_rounded, color: ApexColors.textMuted, size: 32),
              SizedBox(height: 12),
              Text('No insights yet — keep logging',
                  style: ApexTextStyles.labelMuted),
            ]),
          ),
        ),
      );
    }

    return Column(children: [
      SizedBox(
        height: 200,
        child: PageView.builder(
          controller: _controller,
          itemCount: allSignals.length,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (_, i) => Padding(
            padding: EdgeInsets.only(right: i < allSignals.length - 1 ? 12 : 0),
            child: _InsightCard(signal: allSignals[i]),
          ),
        ),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(allSignals.length, (i) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: i == _page ? 20 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: i == _page
                  ? ApexColors.accentXlerate
                  : ApexColors.border,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    ]);
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.signal});
  final Signal signal;

  Color _categoryColor() {
    return switch (signal.category.toLowerCase()) {
      'body' => ApexColors.accentAim,
      'batting' => ApexColors.accentProgress,
      'bowling' => ApexColors.accentEvaluate,
      _ => ApexColors.accentXlerate,
    };
  }

  (String, Color) _flagInfo() {
    return switch (signal.flag) {
      'LOOKING_GOOD' => ('Looking Good', ApexColors.accentProgress),
      'WATCH_CLOSELY' => ('Watch Closely', ApexColors.accentXlerate),
      _ => ('Needs Work', ApexColors.accentEvaluate),
    };
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor();
    final (flagLabel, flagColor) = _flagInfo();

    return ApexCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: catColor.withValues(alpha: 0.3)),
              ),
              child: Text(signal.category.toUpperCase(),
                  style: TextStyle(
                      color: catColor, fontSize: 9, fontWeight: FontWeight.w800,
                      letterSpacing: 0.8)),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: flagColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(flagLabel,
                  style: TextStyle(
                      color: flagColor, fontSize: 9, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 12),
          Text(signal.headline,
              style: const TextStyle(
                  color: ApexColors.textPrimary, fontSize: 16,
                  fontWeight: FontWeight.w700, height: 1.2)),
          const SizedBox(height: 8),
          Text(signal.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: ApexColors.textMuted, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  B: Recommendations List
// ─────────────────────────────────────────────────────────────────────────────

class _RecommendationsList extends StatefulWidget {
  const _RecommendationsList({required this.recommendations});
  final List<Recommendation> recommendations;

  @override
  State<_RecommendationsList> createState() => _RecommendationsListState();
}

class _RecommendationsListState extends State<_RecommendationsList> {
  final _noted = <String>{};

  @override
  Widget build(BuildContext context) {
    if (widget.recommendations.isEmpty) {
      return const ApexCard(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('No recommendations yet',
              style: ApexTextStyles.labelMuted)),
        ),
      );
    }

    return Column(
      children: widget.recommendations.map((r) {
        final isNoted = _noted.contains(r.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _RecommendationTile(
            recommendation: r,
            isNoted: isNoted,
            onMarkNoted: () {
              HapticFeedback.selectionClick();
              setState(() => _noted.add(r.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Marked as noted'),
                  backgroundColor: ApexColors.surface,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({
    required this.recommendation,
    required this.isNoted,
    required this.onMarkNoted,
  });
  final Recommendation recommendation;
  final bool isNoted;
  final VoidCallback onMarkNoted;

  Color _priorityColor() {
    return switch (recommendation.priority) {
      1 => ApexColors.accentXlerate,
      2 => ApexColors.accentEvaluate,
      _ => ApexColors.textMuted,
    };
  }

  (String, Color) _impactInfo() {
    return switch (recommendation.impact) {
      'HIGH'     => ('High Impact', ApexColors.accentProgress),
      'LOW'      => ('Quick Win', ApexColors.accentAim),
      _          => ('Medium', ApexColors.accentEvaluate),
    };
  }

  @override
  Widget build(BuildContext context) {
    final pColor = _priorityColor();
    final (impactLabel, impactColor) = _impactInfo();

    return GestureDetector(
      onLongPress: onMarkNoted,
      child: AnimatedOpacity(
        opacity: isNoted ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: ApexCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            // Priority badge
            Container(
              width: 32, height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: pColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('P${recommendation.priority}',
                  style: TextStyle(
                      color: pColor, fontSize: 11, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(recommendation.text,
                    style: const TextStyle(
                        color: ApexColors.textPrimary, fontSize: 13,
                        fontWeight: FontWeight.w600, height: 1.3)),
                const SizedBox(height: 4),
                Row(children: [
                  Text(recommendation.category,
                      style: ApexTextStyles.labelMuted.copyWith(fontSize: 11)),
                  if (recommendation.category.isNotEmpty)
                    const Text(' · ', style: TextStyle(
                        color: ApexColors.textMuted, fontSize: 11)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: impactColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(impactLabel,
                        style: TextStyle(
                            color: impactColor, fontSize: 9,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),
              ]),
            ),
            const SizedBox(width: 8),
            Icon(
              isNoted ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: isNoted ? ApexColors.accentXlerate : ApexColors.textMuted,
              size: 20,
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  C: Priority Focus Areas
// ─────────────────────────────────────────────────────────────────────────────

class _PriorityFocusSection extends StatelessWidget {
  const _PriorityFocusSection({
    required this.analytics,
    required this.playerRole,
  });
  final ApexAnalytics analytics;
  final String playerRole;

  bool get _hasBowling {
    final role = playerRole.toLowerCase();
    return role.contains('bowl') || role.contains('all');
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Batting Focus
      _PriorityFocusCard(
        icon: Icons.sports_cricket_rounded,
        category: 'BATTING',
        accentColor: ApexColors.accentProgress,
        title: analytics.battingWeakness ?? 'Review your batting approach',
        metric: 'Batting Index: ${analytics.performanceIndex.batting.toStringAsFixed(0)}/100',
        ctaLabel: 'View Drills →',
        onCta: () {},
      ),
      const SizedBox(height: 12),

      // Body & Fitness Focus
      _PriorityFocusCard(
        icon: Icons.fitness_center_rounded,
        category: 'FITNESS',
        accentColor: ApexColors.accentAim,
        title: 'Maintain your recovery consistency',
        metric: 'Recovery adherence needs attention',
        ctaLabel: 'Log Recovery →',
        onCta: () {},
      ),

      // Bowling (conditional)
      if (_hasBowling) ...[
        const SizedBox(height: 12),
        _PriorityFocusCard(
          icon: Icons.sports_baseball_rounded,
          category: 'BOWLING',
          accentColor: ApexColors.accentEvaluate,
          title: analytics.bowlingWeakness ?? 'Focus on bowling variety',
          metric: 'Bowling Index: ${analytics.performanceIndex.bowling.toStringAsFixed(0)}/100',
          ctaLabel: 'View Drills →',
          onCta: () {},
        ),
      ],
    ]);
  }
}

class _PriorityFocusCard extends StatelessWidget {
  const _PriorityFocusCard({
    required this.icon,
    required this.category,
    required this.accentColor,
    required this.title,
    required this.metric,
    required this.ctaLabel,
    required this.onCta,
  });
  final IconData icon;
  final String category, title, metric, ctaLabel;
  final Color accentColor;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    return ApexCard(
      leftAccentColor: accentColor,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(category,
                style: TextStyle(
                    color: accentColor, fontSize: 9,
                    fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            const SizedBox(height: 6),
            Text(title,
                style: const TextStyle(
                    color: ApexColors.textPrimary, fontSize: 14,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(metric, style: ApexTextStyles.labelMuted),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onCta,
              child: Text(ctaLabel,
                  style: TextStyle(
                      color: accentColor, fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
        Icon(icon, color: accentColor.withValues(alpha: 0.5), size: 28),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  D: Drill Assignments
// ─────────────────────────────────────────────────────────────────────────────

class _DrillAssignmentsList extends StatefulWidget {
  const _DrillAssignmentsList({required this.assignments, required this.onLog});
  final List<DrillAssignment> assignments;
  final Future<void> Function(String id, int? reps, int? mins) onLog;

  @override
  State<_DrillAssignmentsList> createState() => _DrillAssignmentsListState();
}

class _DrillAssignmentsListState extends State<_DrillAssignmentsList> {
  String? _loggingId;
  final _logController = TextEditingController();

  @override
  void dispose() {
    _logController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.assignments.map((d) {
        final isLogging = _loggingId == d.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ApexCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(d.name,
                      style: const TextStyle(
                          color: ApexColors.textPrimary, fontSize: 14,
                          fontWeight: FontWeight.w700)),
                ),
                if (d.assignedDate.isNotEmpty)
                  Text(d.assignedDate,
                      style: ApexTextStyles.labelMuted.copyWith(fontSize: 10)),
              ]),
              const SizedBox(height: 6),
              Text(
                [
                  if (d.targetReps > 0) '${d.targetReps} reps target',
                  if (d.targetMinutes > 0) '${d.targetMinutes} mins target',
                ].join(' · '),
                style: ApexTextStyles.labelMuted,
              ),
              const SizedBox(height: 10),
              // Progress bar
              LayoutBuilder(builder: (_, c) => Container(
                height: 4,
                width: c.maxWidth,
                decoration: BoxDecoration(
                    color: ApexColors.background,
                    borderRadius: BorderRadius.circular(2)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: d.progress,
                  child: Container(
                    decoration: BoxDecoration(
                        color: d.progress >= 1.0
                            ? ApexColors.accentProgress
                            : ApexColors.accentXlerate,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
              )),
              const SizedBox(height: 10),
              if (isLogging)
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _logController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          color: ApexColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'reps or mins',
                        hintStyle: TextStyle(
                            color: ApexColors.textMuted, fontSize: 12),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: ApexColors.border),
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: ApexColors.accentXlerate),
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        filled: true,
                        fillColor: ApexColors.background,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final val = int.tryParse(_logController.text.trim());
                      await widget.onLog(
                        d.id,
                        d.targetReps > 0 ? val : null,
                        d.targetMinutes > 0 ? val : null,
                      );
                      _logController.clear();
                      setState(() => _loggingId = null);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: ApexColors.accentXlerate,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('LOG',
                          style: TextStyle(
                              color: Colors.white, fontSize: 11,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _loggingId = null),
                    child: const Icon(Icons.close_rounded,
                        color: ApexColors.textMuted, size: 18),
                  ),
                ])
              else
                GestureDetector(
                  onTap: () => setState(() {
                    _loggingId = d.id;
                    _logController.clear();
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: ApexColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: ApexColors.accentXlerate.withValues(alpha: 0.4)),
                    ),
                    child: const Text('Log Progress',
                        style: TextStyle(
                            color: ApexColors.accentXlerate, fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  E: Benchmark Snapshot 2×2
// ─────────────────────────────────────────────────────────────────────────────

class _BenchmarkGrid extends StatelessWidget {
  const _BenchmarkGrid({required this.benchmarks});
  final Benchmarks benchmarks;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: benchmarks.entries.take(4).map((e) =>
        _BenchmarkCard(entry: e)).toList(),
    );
  }
}

class _BenchmarkCard extends StatelessWidget {
  const _BenchmarkCard({required this.entry});
  final BenchmarkEntry entry;

  @override
  Widget build(BuildContext context) {
    final maxVal = [entry.yourValue, entry.cityAvg, entry.top10Percent]
        .reduce((a, b) => a > b ? a : b);

    barWidth(double v) => maxVal > 0 ? (v / maxVal) : 0.0;

    return ApexCard(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(entry.metric,
            style: const TextStyle(
                color: ApexColors.textMuted, fontSize: 9,
                fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 12),
        _BenchmarkBar(
            label: 'You',
            value: entry.yourValue,
            widthFactor: barWidth(entry.yourValue),
            color: ApexColors.accentAim),
        const SizedBox(height: 6),
        _BenchmarkBar(
            label: 'City',
            value: entry.cityAvg,
            widthFactor: barWidth(entry.cityAvg),
            color: ApexColors.textMuted),
        const SizedBox(height: 6),
        _BenchmarkBar(
            label: 'Top 10%',
            value: entry.top10Percent,
            widthFactor: barWidth(entry.top10Percent),
            color: ApexColors.accentProgress),
      ]),
    );
  }
}

class _BenchmarkBar extends StatelessWidget {
  const _BenchmarkBar({
    required this.label,
    required this.value,
    required this.widthFactor,
    required this.color,
  });
  final String label;
  final double value, widthFactor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 36,
        child: Text(label,
            style: ApexTextStyles.labelCaps.copyWith(fontSize: 8)),
      ),
      Expanded(
        child: LayoutBuilder(builder: (_, c) => Container(
          height: 4,
          width: c.maxWidth,
          decoration: BoxDecoration(
              color: ApexColors.background,
              borderRadius: BorderRadius.circular(2)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: widthFactor.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2)),
            ),
          ),
        )),
      ),
      const SizedBox(width: 6),
      Text(value.toStringAsFixed(0),
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    ]);
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            color: ApexColors.textMuted, fontSize: 11,
            fontWeight: FontWeight.w800, letterSpacing: 1.5));
  }
}
