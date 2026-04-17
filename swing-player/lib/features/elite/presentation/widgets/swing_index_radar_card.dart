import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/widgets/profile_section_card.dart';
import '../../domain/swing_index_summary.dart';

const int _swingRadarTickCount = 10;

enum SwingIndexCardState {
  ready,
  loading,
  empty,
  error,
}

class SwingIndexRadarCard extends StatelessWidget {
  const SwingIndexRadarCard({
    super.key,
    required this.summary,
    this.title = 'Swing Index',
    this.scoreLabel = 'APEX SCORE',
    this.subtitle = 'Updated from latest performance',
    this.showInsights = true,
    this.useCustomPainterFallback = false,
  })  : state = SwingIndexCardState.ready,
        errorMessage = null,
        onRetry = null;

  const SwingIndexRadarCard.loading({
    super.key,
    this.title = 'Swing Index',
  })  : state = SwingIndexCardState.loading,
        summary = null,
        errorMessage = null,
        onRetry = null,
        subtitle = null,
        scoreLabel = 'APEX SCORE',
        showInsights = true,
        useCustomPainterFallback = false;

  const SwingIndexRadarCard.empty({
    super.key,
    this.title = 'Swing Index',
    this.subtitle,
  })  : state = SwingIndexCardState.empty,
        summary = null,
        errorMessage = null,
        onRetry = null,
        scoreLabel = 'APEX SCORE',
        showInsights = true,
        useCustomPainterFallback = false;

  const SwingIndexRadarCard.error({
    super.key,
    this.title = 'Swing Index',
    required this.errorMessage,
    this.onRetry,
  })  : state = SwingIndexCardState.error,
        summary = null,
        subtitle = null,
        scoreLabel = 'APEX SCORE',
        showInsights = true,
        useCustomPainterFallback = false;

  final SwingIndexSummary? summary;
  final SwingIndexCardState state;
  final String title;
  final String scoreLabel;
  final String? subtitle;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool showInsights;
  final bool useCustomPainterFallback;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      SwingIndexCardState.loading => ProfileSectionCard(
          title: title,
          child: const _SwingIndexLoadingBody(),
        ),
      SwingIndexCardState.empty => ProfileSectionCard(
          title: title,
          subtitle: subtitle,
          child: const _SwingIndexEmptyBody(),
        ),
      SwingIndexCardState.error => ProfileSectionCard(
          title: title,
          child: _SwingIndexErrorBody(
            message: errorMessage,
            onRetry: onRetry,
          ),
        ),
      SwingIndexCardState.ready => _buildReadyCard(context),
    };
  }

  Widget _buildReadyCard(BuildContext context) {
    final data = summary;
    if (data == null || !data.hasAxisData) {
      return ProfileSectionCard(
        title: title,
        subtitle: subtitle,
        child: const _SwingIndexEmptyBody(),
      );
    }

    final orderedAxes = data.orderedAxes();
    final score = data.swingIndexScore.clamp(0, 100).toDouble();
    final strengths = showInsights
        ? _topStrengths(data, orderedAxes)
        : const <SwingIndexInsight>[];
    final weakAreas = showInsights
        ? _topWeakAreas(data, orderedAxes)
        : const <SwingIndexInsight>[];

    return ProfileSectionCard(
      title: title,
      subtitle: subtitle,
      child: Column(
        children: [
          Semantics(
            label: '$scoreLabel ${score.toStringAsFixed(1)} out of 100',
            child: _ScoreBanner(
              scoreLabel: scoreLabel,
              score: score,
            ),
          ),
          const SizedBox(height: 18),
          Semantics(
            label: _chartSummaryLabel(orderedAxes),
            child: ExcludeSemantics(
              child: _RadarSurface(
                axes: orderedAxes,
                useCustomPainterFallback: useCustomPainterFallback,
              ),
            ),
          ),
          if (showInsights &&
              (strengths.isNotEmpty || weakAreas.isNotEmpty)) ...[
            const SizedBox(height: 18),
            _InsightsSection(
              strengths: strengths,
              weakAreas: weakAreas,
            ),
          ],
        ],
      ),
    );
  }

  List<SwingIndexInsight> _topStrengths(
    SwingIndexSummary data,
    Map<String, double> orderedAxes,
  ) {
    final fromBackend = data.strengths;
    if (fromBackend != null && fromBackend.isNotEmpty) {
      final sorted = [...fromBackend]
        ..sort((a, b) => b.score.compareTo(a.score));
      return sorted.take(2).toList(growable: false);
    }

    final fallback = orderedAxes.entries
        .map((entry) => SwingIndexInsight(key: entry.key, score: entry.value))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return fallback.take(2).toList(growable: false);
  }

  List<SwingIndexInsight> _topWeakAreas(
    SwingIndexSummary data,
    Map<String, double> orderedAxes,
  ) {
    final fromBackend = data.weakestAreas;
    if (fromBackend != null && fromBackend.isNotEmpty) {
      final sorted = [...fromBackend]
        ..sort((a, b) => a.score.compareTo(b.score));
      return sorted.take(2).toList(growable: false);
    }

    final fallback = orderedAxes.entries
        .map((entry) => SwingIndexInsight(key: entry.key, score: entry.value))
        .toList()
      ..sort((a, b) => a.score.compareTo(b.score));
    return fallback.take(2).toList(growable: false);
  }

  String _chartSummaryLabel(Map<String, double> orderedAxes) {
    final parts = orderedAxes.entries
        .map(
          (entry) =>
              '${swingIndexAxisLabel(entry.key)} ${entry.value.toStringAsFixed(1)}',
        )
        .join(', ');
    return 'Swing Index radar chart. $parts.';
  }
}

class _ScoreBanner extends StatelessWidget {
  const _ScoreBanner({
    required this.scoreLabel,
    required this.score,
  });

  final String scoreLabel;
  final double score;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _SwingIndexColors.scoreGradientStart,
            _SwingIndexColors.scoreGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _SwingIndexColors.scoreBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              scoreLabel,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
          Text(
            '${score.toStringAsFixed(1)} / 100',
            style: TextStyle(
              color: context.fg,
              fontSize: 27,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarSurface extends StatelessWidget {
  const _RadarSurface({
    required this.axes,
    required this.useCustomPainterFallback,
  });

  final Map<String, double> axes;
  final bool useCustomPainterFallback;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 370;
        final chartSize = compact ? 220.0 : 260.0;

        return SizedBox(
          width: double.infinity,
          child: Center(
            child: SizedBox(
              width: chartSize,
              height: chartSize,
              child: useCustomPainterFallback
                  ? _RadarFallback(axes: axes)
                  : _FlRadarChart(
                      axes: axes,
                      compact: compact,
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _FlRadarChart extends StatelessWidget {
  const _FlRadarChart({
    required this.axes,
    required this.compact,
  });

  final Map<String, double> axes;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final baselineEntries = SwingIndexAxisKeys.ordered
        .map((_) => const RadarEntry(value: 0))
        .toList(growable: false);
    final referenceEntries = SwingIndexAxisKeys.ordered
        .map((_) => const RadarEntry(value: 100))
        .toList(growable: false);
    final actualEntries = SwingIndexAxisKeys.ordered
        .map((key) => RadarEntry(value: (axes[key] ?? 0).toDouble()))
        .toList(growable: false);

    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        tickCount: _swingRadarTickCount,
        ticksTextStyle: const TextStyle(color: Colors.transparent),
        radarBackgroundColor: Colors.transparent,
        radarBorderData: BorderSide(
          color: context.stroke.withValues(alpha: 0.52),
          width: 1,
        ),
        gridBorderData: BorderSide(
          color: context.stroke.withValues(alpha: 0.24),
          width: 1,
        ),
        titleTextStyle: TextStyle(
          color: context.fgSub,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w700,
        ),
        titlePositionPercentageOffset: compact ? 0.24 : 0.2,
        getTitle: (index, angle) {
          if (index >= SwingIndexAxisKeys.ordered.length) {
            return const RadarChartTitle(text: '');
          }
          final key = SwingIndexAxisKeys.ordered[index];
          return RadarChartTitle(
            text: swingIndexAxisLabel(key),
            angle: angle,
          );
        },
        dataSets: [
          // Invisible baseline dataset to lock radar minimum to 0.
          RadarDataSet(
            fillColor: Colors.transparent,
            borderColor: Colors.transparent,
            borderWidth: 0,
            entryRadius: 0,
            dataEntries: baselineEntries,
          ),
          // Invisible reference dataset to lock radar scale to 0-100.
          RadarDataSet(
            fillColor: Colors.transparent,
            borderColor: Colors.transparent,
            borderWidth: 0,
            entryRadius: 0,
            dataEntries: referenceEntries,
          ),
          RadarDataSet(
            fillColor: _SwingIndexColors.polygonFill,
            borderColor: _SwingIndexColors.polygonStroke,
            borderWidth: 2.2,
            entryRadius: 3.8,
            dataEntries: actualEntries,
          ),
        ],
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _RadarFallback extends StatelessWidget {
  const _RadarFallback({required this.axes});

  final Map<String, double> axes;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RadarFallbackPainter(
        axes: axes,
        stroke: context.stroke,
        label: context.fgSub,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _RadarFallbackPainter extends CustomPainter {
  _RadarFallbackPainter({
    required this.axes,
    required this.stroke,
    required this.label,
  });

  final Map<String, double> axes;
  final Color stroke;
  final Color label;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 28;
    final angleStep = (math.pi * 2) / SwingIndexAxisKeys.ordered.length;

    final ringPaint = Paint()
      ..color = stroke.withValues(alpha: 0.26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = stroke.withValues(alpha: 0.36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final fillPaint = Paint()
      ..color = _SwingIndexColors.polygonFill
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = _SwingIndexColors.polygonStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final dotPaint = Paint()..color = _SwingIndexColors.polygonStroke;

    for (var ring = 1; ring <= _swingRadarTickCount; ring++) {
      final ringPath = Path();
      final ringRadius = radius * (ring / _swingRadarTickCount);
      for (var i = 0; i < SwingIndexAxisKeys.ordered.length; i++) {
        final angle = -math.pi / 2 + (angleStep * i);
        final point = Offset(
          center.dx + math.cos(angle) * ringRadius,
          center.dy + math.sin(angle) * ringRadius,
        );
        if (i == 0) {
          ringPath.moveTo(point.dx, point.dy);
        } else {
          ringPath.lineTo(point.dx, point.dy);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, ringPaint);
    }

    for (var i = 0; i < SwingIndexAxisKeys.ordered.length; i++) {
      final angle = -math.pi / 2 + (angleStep * i);
      final endpoint = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.drawLine(center, endpoint, axisPaint);
    }

    final dataPath = Path();
    for (var i = 0; i < SwingIndexAxisKeys.ordered.length; i++) {
      final key = SwingIndexAxisKeys.ordered[i];
      final normalizedValue = ((axes[key] ?? 0).clamp(0, 100)) / 100;
      final angle = -math.pi / 2 + (angleStep * i);
      final point = Offset(
        center.dx + math.cos(angle) * radius * normalizedValue,
        center.dy + math.sin(angle) * radius * normalizedValue,
      );

      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
      canvas.drawCircle(point, 3.8, dotPaint);

      final labelOffset = Offset(
        center.dx + math.cos(angle) * (radius + 16),
        center.dy + math.sin(angle) * (radius + 16),
      );
      final labelPainter = TextPainter(
        text: TextSpan(
          text: swingIndexAxisLabel(key),
          style: TextStyle(
            color: label,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      labelPainter.paint(
        canvas,
        Offset(
          labelOffset.dx - (labelPainter.width / 2),
          labelOffset.dy - (labelPainter.height / 2),
        ),
      );
    }

    dataPath.close();
    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarFallbackPainter oldDelegate) {
    return oldDelegate.axes != axes ||
        oldDelegate.stroke != stroke ||
        oldDelegate.label != label;
  }
}

class _InsightsSection extends StatelessWidget {
  const _InsightsSection({
    required this.strengths,
    required this.weakAreas,
  });

  final List<SwingIndexInsight> strengths;
  final List<SwingIndexInsight> weakAreas;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 520;
        if (wide) {
          return Row(
            children: [
              Expanded(
                child: _InsightGroup(
                  title: 'Top Strengths',
                  items: strengths,
                  tone: _SwingIndexColors.strengthTone,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InsightGroup(
                  title: 'Needs Focus',
                  items: weakAreas,
                  tone: _SwingIndexColors.focusTone,
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            _InsightGroup(
              title: 'Top Strengths',
              items: strengths,
              tone: _SwingIndexColors.strengthTone,
            ),
            const SizedBox(height: 10),
            _InsightGroup(
              title: 'Needs Focus',
              items: weakAreas,
              tone: _SwingIndexColors.focusTone,
            ),
          ],
        );
      },
    );
  }
}

class _InsightGroup extends StatelessWidget {
  const _InsightGroup({
    required this.title,
    required this.items,
    required this.tone,
  });

  final String title;
  final List<SwingIndexInsight> items;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.panel.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.stroke.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: tone,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      swingIndexAxisLabel(item.key),
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    item.score.toStringAsFixed(1),
                    style: TextStyle(
                      color: tone,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
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

class _SwingIndexLoadingBody extends StatelessWidget {
  const _SwingIndexLoadingBody();

  @override
  Widget build(BuildContext context) {
    final skeletonColor = context.panel.withValues(alpha: 0.7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 68,
          decoration: BoxDecoration(
            color: skeletonColor,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: skeletonColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 76,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 76,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SwingIndexEmptyBody extends StatelessWidget {
  const _SwingIndexEmptyBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
      decoration: BoxDecoration(
        color: context.panel.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.stroke.withValues(alpha: 0.46)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.query_stats_rounded,
            color: context.fgSub,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            'No Swing Index data available yet.',
            style: TextStyle(
              color: context.fg,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SwingIndexErrorBody extends StatelessWidget {
  const _SwingIndexErrorBody({
    required this.message,
    required this.onRetry,
  });

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: context.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.danger.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline_rounded,
                  color: context.danger, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message ?? 'Could not load Swing Index right now.',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

class _SwingIndexColors {
  static const Color scoreGradientStart = Color(0xFF132B23);
  static const Color scoreGradientEnd = Color(0xFF0D1B17);
  static const Color scoreBorder = Color(0xFF2D5A4B);
  static const Color polygonFill = Color(0x3346D38C);
  static const Color polygonStroke = Color(0xFF46D38C);
  static const Color strengthTone = Color(0xFF6EDDA8);
  static const Color focusTone = Color(0xFFF2A65A);
}
