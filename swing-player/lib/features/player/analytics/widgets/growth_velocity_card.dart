import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/widgets/profile_section_card.dart';
import '../models/growth_insights_model.dart';

class GrowthVelocityCard extends StatelessWidget {
  const GrowthVelocityCard({
    super.key,
    required this.insights,
    this.showChart = true,
  });

  final GrowthInsights insights;
  final bool showChart;

  @override
  Widget build(BuildContext context) {
    final velocity = insights.growthVelocity;
    final trendColor = _trendColor(context, velocity.trend);
    final recentValue =
        (insights.roleIndex ?? insights.momentum ?? 0).clamp(0, 100).toDouble();
    final previousValue = _previousValue(recentValue, velocity.deltaPercent);
    final hasEnoughData = velocity.trend != 'INSUFFICIENT_DATA';
    final deltaText = velocity.windowMatches > 0
        ? '${_signed(velocity.deltaPercent)}% vs prev ${velocity.windowMatches} matches'
        : '${_signed(velocity.deltaPercent)}% trend shift';

    return ProfileSectionCard(
      title: 'Growth Trajectory',
      subtitle: 'Your recent role movement and direction of travel.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: trendColor.withValues(alpha: 0.25)),
                ),
                child: Text(
                  _trendLabel(velocity.trend),
                  style: TextStyle(
                    color: trendColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                deltaText,
                style: TextStyle(
                  color: velocity.deltaPercent >= 0
                      ? context.success
                      : context.danger,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (!hasEnoughData)
            _InsufficientTrendState(showChart: showChart)
          else if (!showChart)
            Text(
              'Trend is building fast. Unlock Swing Pro to see the full trajectory chart.',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 13,
                height: 1.45,
              ),
            )
          else
            SizedBox(
              height: 170,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 1,
                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 25,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: context.stroke.withValues(alpha: 0.28),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 25,
                        getTitlesWidget: (value, _) => Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, _) => Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            value == 0 ? 'Previous' : 'Recent',
                            style: TextStyle(
                              color: context.fgSub,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: trendColor,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: trendColor.withValues(alpha: 0.15),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                          radius: 5,
                          color: trendColor,
                          strokeWidth: 2,
                          strokeColor: context.bg,
                        ),
                      ),
                      spots: [
                        FlSpot(0, previousValue),
                        FlSpot(1, recentValue),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InsufficientTrendState extends StatelessWidget {
  const _InsufficientTrendState({required this.showChart});

  final bool showChart;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.panel.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.stroke.withValues(alpha: 0.55)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.sports_cricket_rounded,
            color: context.fgSub,
            size: 28,
          ),
          const SizedBox(height: 10),
          Text(
            showChart
                ? 'Play at least 3 matches to see your trend'
                : 'Play at least 3 matches to unlock your full trajectory',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

double _previousValue(double recentValue, double deltaPercent) {
  if (deltaPercent == -100) return 0;
  final denominator = 1 + (deltaPercent / 100);
  if (denominator <= 0) return 0;
  final previous = recentValue / denominator;
  return math.max(0, math.min(100, previous));
}

String _signed(double value) {
  final formatted = value.toStringAsFixed(0);
  if (value > 0) return '+$formatted';
  return formatted;
}

String _trendLabel(String trend) {
  return switch (trend) {
    'RAPIDLY_IMPROVING' => '↑↑ Rapidly Improving',
    'IMPROVING' => '↑ Improving',
    'STABLE' => '→ Stable',
    'DECLINING' => '↓ Declining',
    'SLIPPING' => '↓↓ Slipping',
    _ => 'Play more matches',
  };
}

Color _trendColor(BuildContext context, String trend) {
  return switch (trend) {
    'RAPIDLY_IMPROVING' => context.success,
    'IMPROVING' => const Color(0xFF88C77B),
    'STABLE' => context.fgSub,
    'DECLINING' => context.warn,
    'SLIPPING' => context.danger,
    _ => context.fgSub,
  };
}
