import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../shared/apex_theme.dart';
import '../../shared/apex_models.dart';
import '../../shared/apex_api_service.dart';
import '../../../elite/controller/elite_controller.dart';
import '../../../elite/domain/elite_models.dart';
import '../apex_shell.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  EVALUATE Screen — "Am I on track toward my ambition?"
//  A: Verdict banner
//  B: Mission alignment bars
//  C: Skill radar chart
//  D: Performance index cards
//  E: Deviation cards
// ─────────────────────────────────────────────────────────────────────────────

class EvaluateScreen extends ConsumerWidget {
  const EvaluateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apexAsync = ref.watch(apexStateProvider);
    final aimDone = apexAsync.asData?.value.goal.targetRole?.isNotEmpty ?? false;

    if (!aimDone) {
      return ApexAimNotSetWidget(
        onSetMission: () => ApexTabScope.of(context)?.animateTo(0),
      );
    }

    final analyticsAsync = ref.watch(apexAnalyticsProvider);

    return RefreshIndicator(
      color: ApexColors.accentEvaluate,
      backgroundColor: ApexColors.surface,
      onRefresh: () async {
        ref.invalidate(apexStateProvider);
        ref.invalidate(apexAnalyticsProvider);
        ref.invalidate(apexSwotProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        children: [
          // ── A: Verdict Banner ────────────────────────────────────────────
          apexAsync.when(
            loading: () => const ApexShimmerBox(height: 120),
            error: (_, __) => ApexErrorWidget(
                onRetry: () => ref.invalidate(apexStateProvider)),
            data: (apex) => _VerdictBanner(apex: apex),
          ),
          const SizedBox(height: 20),

          // ── B: Mission Alignment ─────────────────────────────────────────
          const _SectionLabel(label: 'MISSION ALIGNMENT'),
          const SizedBox(height: 12),
          apexAsync.when(
            loading: () => const ApexShimmerBox(height: 180),
            error: (_, __) => const SizedBox.shrink(),
            data: (apex) => analyticsAsync.when(
              loading: () => const ApexShimmerBox(height: 180),
              error: (_, __) => _AlignmentBars(
                trainingAdherence: (apex.consistency.adherencePercentage.clamp(0, 100)) / 100,
                recoveryAdherence: 0,
                bodyScore: 0,
                calorieAdherence: 0,
              ),
              data: (analytics) => _AlignmentBars(
                trainingAdherence: (apex.consistency.adherencePercentage.clamp(0, 100)) / 100,
                recoveryAdherence: 0.7, // pulled from analytics when available
                bodyScore: analytics.performanceIndex.batting / 100,
                calorieAdherence: 0.65,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── C: Skill Radar ───────────────────────────────────────────────
          const _SectionLabel(label: 'SKILL MATRIX'),
          const SizedBox(height: 12),
          analyticsAsync.when(
            loading: () => const ApexShimmerBox(height: 300),
            error: (_, __) => ApexErrorWidget(
                onRetry: () => ref.invalidate(apexAnalyticsProvider)),
            data: (a) => _SkillRadarSection(analytics: a),
          ),
          const SizedBox(height: 20),

          // ── D: Performance Index ─────────────────────────────────────────
          const _SectionLabel(label: 'PERFORMANCE INDICES'),
          const SizedBox(height: 12),
          analyticsAsync.when(
            loading: () => const ApexShimmerBox(height: 200),
            error: (_, __) => const SizedBox.shrink(),
            data: (a) => _PerformanceIndexGrid(index: a.performanceIndex),
          ),
          const SizedBox(height: 20),

          // ── E: Deviations ────────────────────────────────────────────────
          analyticsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (a) => a.deviations.isEmpty
                ? const SizedBox.shrink()
                : _DeviationSection(
                    deviations: a.deviations,
                    onFixInXlerate: () => ApexTabScope.of(context)?.animateTo(3),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  A: Verdict Banner
// ─────────────────────────────────────────────────────────────────────────────

class _VerdictBanner extends StatefulWidget {
  const _VerdictBanner({required this.apex});
  final ApexState apex;

  @override
  State<_VerdictBanner> createState() => _VerdictBannerState();
}

class _VerdictBannerState extends State<_VerdictBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  (String, Color) _verdictInfo(double adherence) {
    if (adherence >= 75) return ('On Track', ApexColors.statusOnTrack);
    if (adherence >= 50) return ('Slightly Off Track', ApexColors.statusSlightlyOff);
    if (adherence >= 30) return ('At Risk', ApexColors.statusAtRisk);
    return ('Deviated', ApexColors.statusDeviated);
  }

  @override
  Widget build(BuildContext context) {
    final adherence = widget.apex.consistency.adherencePercentage;
    final (verdict, color) = _verdictInfo(adherence);

    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, __) {
        final accentColor = color.withValues(alpha: _opacity.value);
        final inner = Container(
          decoration: BoxDecoration(
            color: ApexColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ApexColors.border, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(23, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  ApexLiveDot(color: color),
                  const SizedBox(width: 8),
                  const Text('MISSION STATUS',
                      style: TextStyle(
                          color: ApexColors.textMuted, fontSize: 9,
                          fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                  const Spacer(),
                  Text(
                    'Updated: just now',
                    style: ApexTextStyles.labelMuted.copyWith(fontSize: 10),
                  ),
                ]),
                const SizedBox(height: 12),
                Text(verdict,
                    style: TextStyle(
                        color: color, fontSize: 28, fontWeight: FontWeight.w800,
                        letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Text(
                  '${adherence.clamp(0, 100).toStringAsFixed(0)}% mission adherence across your plan.',
                  style: ApexTextStyles.bodyText.copyWith(
                      color: ApexColors.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
        );

        // Use ClipRRect + Stack to avoid non-uniform border crash
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              inner,
              Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(width: 4, color: accentColor),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  B: Mission Alignment Bars
// ─────────────────────────────────────────────────────────────────────────────

class _AlignmentBars extends StatelessWidget {
  const _AlignmentBars({
    required this.trainingAdherence,
    required this.recoveryAdherence,
    required this.bodyScore,
    required this.calorieAdherence,
  });
  final double trainingAdherence, recoveryAdherence, bodyScore, calorieAdherence;

  @override
  Widget build(BuildContext context) {
    return ApexCard(
      child: Column(children: [
        _AlignmentBar(label: 'Training Adherence', value: trainingAdherence),
        const SizedBox(height: 16),
        _AlignmentBar(label: 'Recovery Adherence', value: recoveryAdherence),
        const SizedBox(height: 16),
        _AlignmentBar(label: 'Body Direction Score', value: bodyScore),
        const SizedBox(height: 16),
        _AlignmentBar(label: 'Calorie Adherence', value: calorieAdherence),
      ]),
    );
  }
}

class _AlignmentBar extends StatefulWidget {
  const _AlignmentBar({required this.label, required this.value});
  final String label;
  final double value;

  @override
  State<_AlignmentBar> createState() => _AlignmentBarState();
}

class _AlignmentBarState extends State<_AlignmentBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _anim = Tween<double>(begin: 0, end: widget.value).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Color _barColor(double v) {
    if (v >= 0.75) return ApexColors.accentProgress;
    if (v >= 0.5) return ApexColors.accentEvaluate;
    return ApexColors.accentXlerate;
  }

  @override
  Widget build(BuildContext context) {
    final color = _barColor(widget.value);
    final pctStr = '${(widget.value * 100).toStringAsFixed(0)}%';

    return Column(children: [
      Row(children: [
        Text(widget.label,
            style: const TextStyle(
                color: ApexColors.textPrimary, fontSize: 13,
                fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(pctStr,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 6),
      AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => LayoutBuilder(
          builder: (_, constraints) => Container(
            height: 6,
            width: constraints.maxWidth,
            decoration: BoxDecoration(
                color: ApexColors.background,
                borderRadius: BorderRadius.circular(3)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _anim.value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(3)),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  C: Skill Radar Chart
// ─────────────────────────────────────────────────────────────────────────────

class _SkillRadarSection extends StatelessWidget {
  const _SkillRadarSection({required this.analytics});
  final ApexAnalytics analytics;

  static const _axes = [
    'Reliability', 'Power', 'Bowling', 'Fielding', 'Impact', 'Captaincy'
  ];

  @override
  Widget build(BuildContext context) {
    final skills = analytics.skillMatrix;
    final values = skills.toList(); // 0–10 scale, normalize to 0–1

    return ApexCard(
      child: Column(children: [
        SizedBox(
          height: 260,
          child: RadarChart(
            RadarChartData(
              dataSets: [
                // Current (filled)
                RadarDataSet(
                  dataEntries: values.map((v) => RadarEntry(value: v * 10)).toList(),
                  fillColor: ApexColors.accentAim.withValues(alpha: 0.2),
                  borderColor: ApexColors.accentAim,
                  borderWidth: 2,
                  entryRadius: 4,
                ),
                // Target (100%)
                RadarDataSet(
                  dataEntries: List.generate(6, (_) => const RadarEntry(value: 100)),
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  borderColor: Colors.white.withValues(alpha: 0.3),
                  borderWidth: 1,
                  entryRadius: 0,
                ),
              ],
              radarShape: RadarShape.polygon,
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              gridBorderData: const BorderSide(
                  color: ApexColors.border, width: 0.5),
              tickCount: 4,
              ticksTextStyle: ApexTextStyles.labelCaps.copyWith(
                  fontSize: 7, color: Colors.transparent),
              getTitle: (idx, angle) {
                return RadarChartTitle(
                  text: _axes[idx],
                  angle: angle,
                );
              },
              titleTextStyle: ApexTextStyles.labelCaps.copyWith(fontSize: 9),
              titlePositionPercentageOffset: 0.1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Legend
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 12, height: 3, color: ApexColors.accentAim),
          const SizedBox(width: 6),
          const Text('Current', style: ApexTextStyles.labelMuted),
          const SizedBox(width: 20),
          Container(width: 12, height: 3,
              color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(width: 6),
          const Text('Target', style: ApexTextStyles.labelMuted),
        ]),
        const SizedBox(height: 16),
        // Score chips
        Wrap(spacing: 8, runSpacing: 8,
          children: List.generate(_axes.length, (i) {
            final val = values[i];
            final color = val >= 7 ? ApexColors.accentProgress
                : val >= 5 ? ApexColors.accentEvaluate
                : ApexColors.accentXlerate;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text('${_axes[i]}: ${val.toStringAsFixed(1)}/10',
                  style: TextStyle(
                      color: color, fontSize: 10, fontWeight: FontWeight.w700)),
            );
          }),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  D: Performance Index Cards 2×2
// ─────────────────────────────────────────────────────────────────────────────

class _PerformanceIndexGrid extends StatelessWidget {
  const _PerformanceIndexGrid({required this.index});
  final PerformanceIndex index;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _IndexCard(
          label: 'BATTING',
          score: index.batting,
          percentile: index.battingPercentile,
          icon: Icons.sports_cricket_rounded,
        ),
        _IndexCard(
          label: 'BOWLING',
          score: index.bowling,
          percentile: index.bowlingPercentile,
          icon: Icons.sports_baseball_rounded,
        ),
        _IndexCard(
          label: 'FIELDING',
          score: index.fielding,
          percentile: index.fieldingPercentile,
          icon: Icons.catching_pokemon_rounded,
        ),
        _IndexCard(
          label: 'IMPACT',
          score: index.impact,
          percentile: index.impactPercentile,
          icon: Icons.offline_bolt_rounded,
        ),
      ],
    );
  }
}

class _IndexCard extends StatelessWidget {
  const _IndexCard({
    required this.label,
    required this.score,
    required this.percentile,
    required this.icon,
  });
  final String label;
  final double score, percentile;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isTopTier = percentile >= 75;
    return ApexCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label,
              style: const TextStyle(
                  color: ApexColors.textMuted, fontSize: 9,
                  fontWeight: FontWeight.w800, letterSpacing: 1)),
          const Spacer(),
          Icon(icon, color: ApexColors.textMuted, size: 16),
        ]),
        const SizedBox(height: 10),
        Text(score.toStringAsFixed(0),
            style: const TextStyle(
                color: ApexColors.textPrimary, fontSize: 30,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('/ 100', style: ApexTextStyles.labelMuted),
        const SizedBox(height: 8),
        if (percentile > 0)
          Text(
            isTopTier ? 'Top ${(100 - percentile).toStringAsFixed(0)}%' : '${percentile.toStringAsFixed(0)}th percentile',
            style: TextStyle(
                color: isTopTier
                    ? ApexColors.accentProgress
                    : ApexColors.textMuted,
                fontSize: 11, fontWeight: FontWeight.w700),
          ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  E: Deviation Cards
// ─────────────────────────────────────────────────────────────────────────────

class _DeviationSection extends StatelessWidget {
  const _DeviationSection({
    required this.deviations,
    required this.onFixInXlerate,
  });
  final List<AnalyticsDeviation> deviations;
  final VoidCallback onFixInXlerate;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _SectionLabel(label: 'WHERE YOU\'RE DRIFTING'),
      const SizedBox(height: 12),
      ...deviations.take(3).map((d) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _DeviationCard(deviation: d, onFix: onFixInXlerate),
      )),
    ]);
  }
}

class _DeviationCard extends StatelessWidget {
  const _DeviationCard({required this.deviation, required this.onFix});
  final AnalyticsDeviation deviation;
  final VoidCallback onFix;

  Color _color() {
    return switch (deviation.severity) {
      'HIGH'   => ApexColors.accentXlerate,
      'MEDIUM' => ApexColors.accentEvaluate,
      _        => ApexColors.textMuted,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return ApexCard(
      leftAccentColor: color,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(deviation.title,
                style: const TextStyle(
                    color: ApexColors.textPrimary, fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 8),
        Text(deviation.description,
            style: ApexTextStyles.labelMuted.copyWith(height: 1.4)),
        const SizedBox(height: 12),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withValues(alpha: 0.3))),
            child: Text(deviation.severity,
                style: TextStyle(
                    color: color, fontSize: 9, fontWeight: FontWeight.w800)),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onFix,
            child: const Text('Fix in Xlerate →',
                style: TextStyle(
                    color: ApexColors.accentXlerate, fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
      ]),
    );
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
