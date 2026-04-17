import "package:cached_network_image/cached_network_image.dart";
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../profile/controller/profile_controller.dart';
import '../../profile/domain/profile_models.dart';
import '../../profile/domain/rank_visual_theme.dart';
import 'models/growth_insights_model.dart';
import 'providers/analytics_provider.dart';

class AnalyticsTab extends ConsumerStatefulWidget {
  const AnalyticsTab({super.key, required this.profileId});
  final String profileId;

  @override
  ConsumerState<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends ConsumerState<AnalyticsTab>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabController _tab;
  TabController? _outerTab;
  bool _requestedLoad = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final outer = DefaultTabController.of(context);
    if (outer == _outerTab) return;
    _outerTab?.removeListener(_handleOuterTab);
    _outerTab = outer;
    _outerTab?.addListener(_handleOuterTab);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoad());
  }

  @override
  void dispose() {
    _tab.dispose();
    _outerTab?.removeListener(_handleOuterTab);
    super.dispose();
  }

  void _handleOuterTab() {
    if (!(_outerTab?.indexIsChanging ?? true)) _maybeLoad();
  }

  void _maybeLoad() {
    if (_requestedLoad) return;
    if ((_outerTab?.index ?? -1) != 2) return;
    _requestedLoad = true;
    ref.read(analyticsProvider(widget.profileId).notifier).loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final profileData = ref.watch(profileControllerProvider).data;
    final analyticsState = ref.watch(analyticsProvider(widget.profileId));
    final ranking = profileData?.unified.ranking;
    final rankTheme = resolveRankVisualTheme(ranking?.rank ?? '');

    // insights — bypass locked entirely, render whatever is returned
    final insights = analyticsState.insights;

    return Column(
      children: [
        const SizedBox(height: 16),
        _TabPills(controller: _tab, rankTheme: rankTheme),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _OverviewTab(
                insights: insights,
                profileData: profileData,
                rankTheme: rankTheme,
                isLoading: analyticsState.isLoading && insights == null,
                onRetry: _retry,
              ),
              _IndexTab(
                insights: insights,
                profileData: profileData,
                rankTheme: rankTheme,
                isLoading: analyticsState.isLoading && insights == null,
                onRetry: _retry,
              ),
              _GrowthTab(
                insights: insights,
                rankTheme: rankTheme,
                isLoading: analyticsState.isLoading && insights == null,
                onRetry: _retry,
              ),
              _FocusTab(
                insights: insights,
                rankTheme: rankTheme,
                isLoading: analyticsState.isLoading && insights == null,
                onRetry: _retry,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _retry() =>
      ref.read(analyticsProvider(widget.profileId).notifier).loadAnalytics();
}

// ─── Tab pill bar ─────────────────────────────────────────────────────────────

class _TabPills extends StatefulWidget {
  const _TabPills({required this.controller, required this.rankTheme});
  final TabController controller;
  final RankVisualTheme rankTheme;

  @override
  State<_TabPills> createState() => _TabPillsState();
}

class _TabPillsState extends State<_TabPills> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    const labels = ['OVERVIEW', 'INDEX', 'GROWTH', 'FOCUS'];
    const icons = [
      Icons.person_rounded,
      Icons.radar_rounded,
      Icons.trending_up_rounded,
      Icons.track_changes_rounded,
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = widget.controller.index == i;
          return GestureDetector(
            onTap: () => widget.controller.animateTo(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(right: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? widget.rankTheme.primary
                    : widget.rankTheme.deep,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: selected
                      ? widget.rankTheme.primary
                      : widget.rankTheme.border.withValues(alpha: 0.2),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: widget.rankTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(icons[i],
                      size: 13,
                      color: selected ? Colors.black : Colors.white54),
                  const SizedBox(width: 6),
                  Text(
                    labels[i],
                    style: TextStyle(
                      color: selected ? Colors.black : Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── OVERVIEW tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.insights,
    required this.profileData,
    required this.rankTheme,
    required this.isLoading,
    required this.onRetry,
  });

  final GrowthInsights? insights;
  final PlayerProfilePageData? profileData;
  final RankVisualTheme rankTheme;
  final bool isLoading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _LoadingShimmer();

    final archetype = insights?.archetype;
    final readiness = insights?.readiness;
    final swing = profileData?.fullStats.swingIndex;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        children: [
          // Archetype + Swing Index hero
          _Card(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ARCHETYPE',
                          style: TextStyle(
                              color: rankTheme.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      Text(
                        archetype?.label ?? 'Calculating...',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1.2),
                      ),
                      if (archetype != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          archetype.description,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 13,
                              height: 1.4),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Swing Index ring
                Column(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: SfRadialGauge(
                        axes: [
                          RadialAxis(
                            minimum: 0,
                            maximum: 100,
                            showTicks: false,
                            showLabels: false,
                            axisLineStyle: AxisLineStyle(
                              thickness: 0.16,
                              thicknessUnit: GaugeSizeUnit.factor,
                              color: Colors.white.withValues(alpha: 0.07),
                            ),
                            pointers: [
                              RangePointer(
                                value: (swing?.overall ?? 0).toDouble()
                                    .clamp(0, 100),
                                width: 0.16,
                                sizeUnit: GaugeSizeUnit.factor,
                                color: rankTheme.primary,
                                cornerStyle: CornerStyle.bothCurve,
                              ),
                            ],
                            annotations: [
                              GaugeAnnotation(
                                angle: 90,
                                positionFactor: 0.1,
                                widget: Text(
                                  '${swing?.overall ?? 0}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      height: 1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('SWING IDX',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Readiness gauge + signals
          if (readiness != null) ...[
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MATCH READINESS',
                      style: TextStyle(
                          color: rankTheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Circular readiness ring
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: SfRadialGauge(
                          axes: [
                            RadialAxis(
                              minimum: 0,
                              maximum: 100,
                              showTicks: false,
                              showLabels: false,
                              axisLineStyle: AxisLineStyle(
                                thickness: 0.14,
                                thicknessUnit: GaugeSizeUnit.factor,
                                color: Colors.white.withValues(alpha: 0.07),
                              ),
                              pointers: [
                                RangePointer(
                                  value: readiness.score
                                      .toDouble()
                                      .clamp(0, 100),
                                  width: 0.14,
                                  sizeUnit: GaugeSizeUnit.factor,
                                  color: _readinessColor(readiness.score),
                                  cornerStyle: CornerStyle.bothCurve,
                                ),
                              ],
                              annotations: [
                                GaugeAnnotation(
                                  angle: 90,
                                  positionFactor: 0.08,
                                  widget: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('${readiness.score}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.w900,
                                              height: 1)),
                                      Text('%',
                                          style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.4),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Signals list
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: readiness.signals.map((signal) {
                            final isPositive = signal.positive;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    isPositive
                                        ? Icons.check_circle_rounded
                                        : Icons.warning_amber_rounded,
                                    size: 14,
                                    color: isPositive
                                        ? const Color(0xFF3FA66A)
                                        : const Color(0xFFD7A94B),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      signal.label,
                                      style: TextStyle(
                                          color: isPositive
                                              ? const Color(0xFF3FA66A)
                                              : const Color(0xFFD7A94B),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else
            _Card(
              child: Row(
                children: [
                  Icon(Icons.directions_run_rounded,
                      color: Colors.white.withValues(alpha: 0.2), size: 20),
                  const SizedBox(width: 12),
                  Text('Readiness data not available yet.',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 13)),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─── INDEX tab ────────────────────────────────────────────────────────────────

class _IndexTab extends StatelessWidget {
  const _IndexTab({
    required this.insights,
    required this.profileData,
    required this.rankTheme,
    required this.isLoading,
    required this.onRetry,
  });

  final GrowthInsights? insights;
  final PlayerProfilePageData? profileData;
  final RankVisualTheme rankTheme;
  final bool isLoading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _LoadingShimmer();

    final roleIndex = insights?.roleIndex ?? 0;
    final percentile = insights?.percentile;
    final weaknessAxis = insights?.weakness?.axis ?? '';
    final axes = profileData?.skillAxes ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        children: [
          // Role Index hero
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ROLE INDEX',
                    style: TextStyle(
                        color: rankTheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2)),
                const SizedBox(height: 8),
                Text(
                  roleIndex.toStringAsFixed(1),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                      height: 1),
                ),
                const SizedBox(height: 12),
                // Horizontal bar for role index
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (roleIndex / 100).clamp(0.0, 1.0),
                    minHeight: 12,
                    backgroundColor: Colors.white.withValues(alpha: 0.07),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(rankTheme.primary),
                  ),
                ),
                if (percentile != null) ...[
                  const SizedBox(height: 14),
                  // Percentile "social proof" badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: rankTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: rankTheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      percentile.label.isNotEmpty
                          ? percentile.label
                          : 'Top ${percentile.value}% · ${percentile.comparedTo} players',
                      style: TextStyle(
                          color: rankTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Skill axes radar
          if (axes.isNotEmpty)
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SKILL AXES',
                      style: TextStyle(
                          color: rankTheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: RadarChart(
                      RadarChartData(
                        radarShape: RadarShape.polygon,
                        tickCount: 4,
                        ticksTextStyle: const TextStyle(
                            color: Colors.transparent, fontSize: 10),
                        radarBorderData: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1)),
                        gridBorderData: BorderSide(
                            color: Colors.white.withValues(alpha: 0.05)),
                        radarBackgroundColor: Colors.transparent,
                        borderData: FlBorderData(show: false),
                        titleTextStyle: TextStyle(
                            color: rankTheme.secondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                        titlePositionPercentageOffset: 0.2,
                        getTitle: (i, angle) {
                          if (i >= axes.length) {
                            return const RadarChartTitle(text: '');
                          }
                          return RadarChartTitle(
                              text: axes[i].label, angle: angle);
                        },
                        dataSets: [
                          RadarDataSet(
                            fillColor:
                                rankTheme.primary.withValues(alpha: 0.18),
                            borderColor: rankTheme.primary,
                            entryRadius: 4,
                            borderWidth: 2,
                            dataEntries: axes
                                .map((e) => RadarEntry(
                                    value: (e.value ?? 0)
                                        .clamp(0, 100)
                                        .toDouble()))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ).animate().scale(
                      duration: 500.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 16),
                  // Skill bars
                  ...axes.map((axis) {
                    final isWeakness = weaknessAxis.isNotEmpty &&
                        axis.key
                            .toLowerCase()
                            .contains(weaknessAxis.toLowerCase());
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 82,
                            child: Row(
                              children: [
                                if (isWeakness)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(Icons.arrow_downward_rounded,
                                        size: 11,
                                        color: Color(0xFFE05C6A)),
                                  ),
                                Expanded(
                                  child: Text(
                                    axis.label,
                                    style: TextStyle(
                                        color: isWeakness
                                            ? const Color(0xFFE05C6A)
                                            : Colors.white
                                                .withValues(alpha: 0.55),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: ((axis.value ?? 0) / 100)
                                    .clamp(0.0, 1.0),
                                minHeight: 8,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.07),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    isWeakness
                                        ? const Color(0xFFE05C6A)
                                        : rankTheme.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 34,
                            child: Text(
                              (axis.value ?? 0).toStringAsFixed(0),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: isWeakness
                                      ? const Color(0xFFE05C6A)
                                      : rankTheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 300.ms),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── GROWTH tab ───────────────────────────────────────────────────────────────

class _GrowthTab extends StatelessWidget {
  const _GrowthTab({
    required this.insights,
    required this.rankTheme,
    required this.isLoading,
    required this.onRetry,
  });

  final GrowthInsights? insights;
  final RankVisualTheme rankTheme;
  final bool isLoading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _LoadingShimmer();
    if (insights == null) return const _ComingSoonCard();

    final velocity = insights!.growthVelocity;
    final momentum = insights!.momentum ?? 0;
    final delta = velocity.deltaPercent;
    final trend = velocity.trend;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        children: [
          // Trend + delta hero
          _Card(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Trend arrow icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _trendColor(trend).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color:
                                _trendColor(trend).withValues(alpha: 0.3)),
                      ),
                      child: Icon(
                        _trendIcon(trend),
                        color: _trendColor(trend),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _trendLabel(trend),
                          style: TextStyle(
                              color: _trendColor(trend),
                              fontSize: 16,
                              fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'over ${velocity.windowMatches} matches',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Delta pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (delta >= 0
                                ? const Color(0xFF3FA66A)
                                : const Color(0xFFE05C6A))
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (delta >= 0
                                  ? const Color(0xFF3FA66A)
                                  : const Color(0xFFE05C6A))
                              .withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)}%',
                        style: TextStyle(
                            color: delta >= 0
                                ? const Color(0xFF3FA66A)
                                : const Color(0xFFE05C6A),
                            fontSize: 15,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Momentum gauge
          _Card(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('MOMENTUM',
                        style: TextStyle(
                            color: rankTheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2)),
                    Text(momentum.toStringAsFixed(0),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 160,
                  height: 160,
                  child: SfRadialGauge(
                    axes: [
                      RadialAxis(
                        minimum: 0,
                        maximum: 100,
                        showTicks: false,
                        showLabels: false,
                        axisLineStyle: AxisLineStyle(
                          thickness: 0.14,
                          thicknessUnit: GaugeSizeUnit.factor,
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                        pointers: [
                          RangePointer(
                            value: momentum.clamp(0, 100),
                            width: 0.14,
                            sizeUnit: GaugeSizeUnit.factor,
                            color: _momentumColor(momentum),
                            cornerStyle: CornerStyle.bothCurve,
                          ),
                        ],
                        annotations: [
                          GaugeAnnotation(
                            angle: 90,
                            positionFactor: 0.08,
                            widget: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(momentum.toStringAsFixed(0),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                        fontWeight: FontWeight.w900,
                                        height: 1)),
                                Text('MOMENTUM',
                                    style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.35),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─── FOCUS tab ────────────────────────────────────────────────────────────────

class _FocusTab extends StatelessWidget {
  const _FocusTab({
    required this.insights,
    required this.rankTheme,
    required this.isLoading,
    required this.onRetry,
  });

  final GrowthInsights? insights;
  final RankVisualTheme rankTheme;
  final bool isLoading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _LoadingShimmer();
    if (insights == null) return const _ComingSoonCard();

    final weakness = insights!.weakness;
    final coaches = insights!.coachSuggestions;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        children: [
          // Weakness callout
          if (weakness != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE05C6A).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFE05C6A).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.crisis_alert_rounded,
                          color: Color(0xFFE05C6A), size: 16),
                      const SizedBox(width: 8),
                      Text('FOCUS AREA · ${weakness.axis.toUpperCase()}',
                          style: const TextStyle(
                              color: Color(0xFFE05C6A),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(weakness.insight,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 14,
                          height: 1.5)),
                  const SizedBox(height: 12),
                  // Score bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (weakness.score / 100).clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.07),
                            valueColor: const AlwaysStoppedAnimation(
                                Color(0xFFE05C6A)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(weakness.score.toStringAsFixed(0),
                          style: const TextStyle(
                              color: Color(0xFFE05C6A),
                              fontSize: 14,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Drill cards
            if (weakness.drills.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text('DRILL RECOMMENDATIONS',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2)),
              ),
              const SizedBox(height: 10),
              ...weakness.drills.map((drill) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DrillCard(drill: drill, rankTheme: rankTheme),
                  )),
            ],
          ] else
            _Card(
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: const Color(0xFF3FA66A).withValues(alpha: 0.7),
                      size: 20),
                  const SizedBox(width: 12),
                  Text('No critical weaknesses detected yet.',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13)),
                ],
              ),
            ),
          // Coach suggestions
          if (coaches.isNotEmpty) ...[
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('RECOMMENDED COACHES',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2)),
            ),
            const SizedBox(height: 10),
            ...coaches.take(3).map((coach) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CoachCard(coach: coach, rankTheme: rankTheme),
                )),
          ],
        ],
      ),
    );
  }
}

// ─── Drill card ───────────────────────────────────────────────────────────────

class _DrillCard extends StatelessWidget {
  const _DrillCard({required this.drill, required this.rankTheme});
  final DrillRecommendation drill;
  final RankVisualTheme rankTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(drill.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(drill.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                        height: 1.4)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Chip(drill.difficulty),
                    const SizedBox(width: 6),
                    _Chip('${drill.targetQuantity} ${drill.targetUnit}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: rankTheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('Start',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Coach card ───────────────────────────────────────────────────────────────

class _CoachCard extends StatelessWidget {
  const _CoachCard({required this.coach, required this.rankTheme});
  final CoachSuggestion coach;
  final RankVisualTheme rankTheme;

  @override
  Widget build(BuildContext context) {
    final price =
        '₹${(coach.sessionPricePaise / 100).toStringAsFixed(0)}';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: rankTheme.deep,
            backgroundImage: coach.avatarUrl != null
                ? CachedNetworkImageProvider(coach.avatarUrl!)
                : null,
            child: coach.avatarUrl == null
                ? Text(coach.name.isNotEmpty ? coach.name[0] : 'C',
                    style: TextStyle(
                        color: rankTheme.primary,
                        fontWeight: FontWeight.w900))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(coach.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(coach.locationName,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 13, color: Color(0xFFD7A94B)),
                    const SizedBox(width: 3),
                    Text(coach.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            color: Color(0xFFD7A94B),
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 10),
                    Text(price,
                        style: TextStyle(
                            color: rankTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800)),
                    Text('/${coach.durationMins}min',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: Colors.white38, size: 20),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }
}

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        children: List.generate(
          3,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: i == 0 ? 200 : 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(24),
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(
                    duration: 1400.ms,
                    color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_graph_rounded,
                size: 48, color: Colors.white.withValues(alpha: 0.15)),
            const SizedBox(height: 16),
            const Text('Coming Soon',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
              'Play more matches to unlock\ndeep growth analytics.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 14,
                  height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Color _readinessColor(int score) {
  if (score >= 75) return const Color(0xFF3FA66A);
  if (score >= 45) return const Color(0xFFD7A94B);
  return const Color(0xFFE05C6A);
}

Color _momentumColor(double v) {
  if (v > 70) return const Color(0xFF3FA66A);
  if (v >= 40) return const Color(0xFFD7A94B);
  return const Color(0xFFE05C6A);
}

Color _trendColor(String trend) {
  switch (trend.toUpperCase()) {
    case 'RAPIDLY_IMPROVING':
    case 'IMPROVING':
      return const Color(0xFF3FA66A);
    case 'DECLINING':
    case 'RAPIDLY_DECLINING':
      return const Color(0xFFE05C6A);
    default:
      return const Color(0xFFD7A94B);
  }
}

IconData _trendIcon(String trend) {
  switch (trend.toUpperCase()) {
    case 'RAPIDLY_IMPROVING':
      return Icons.keyboard_double_arrow_up_rounded;
    case 'IMPROVING':
      return Icons.trending_up_rounded;
    case 'DECLINING':
      return Icons.trending_down_rounded;
    case 'RAPIDLY_DECLINING':
      return Icons.keyboard_double_arrow_down_rounded;
    default:
      return Icons.trending_flat_rounded;
  }
}

String _trendLabel(String trend) {
  switch (trend.toUpperCase()) {
    case 'RAPIDLY_IMPROVING':
      return 'Rapidly Improving';
    case 'IMPROVING':
      return 'Improving';
    case 'DECLINING':
      return 'Declining';
    case 'RAPIDLY_DECLINING':
      return 'Rapidly Declining';
    case 'INSUFFICIENT_DATA':
      return 'Not enough data';
    default:
      return 'Stable';
  }
}

// ignore: unused_element
class _ArcPainter extends CustomPainter {
  const _ArcPainter(
      {required this.progress, required this.accent, required this.base});
  final double progress;
  final Color accent;
  final Color base;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 4, size.width, size.height * 1.9);
    const start = math.pi * 0.85;
    const sweep = math.pi * 1.3;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    canvas.drawArc(rect, start, sweep, false, paint..color = base);
    canvas.drawArc(
        rect, start, sweep * progress, false, paint..color = accent);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.progress != progress || old.accent != accent;
}
