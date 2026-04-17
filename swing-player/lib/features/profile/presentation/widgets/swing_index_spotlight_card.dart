import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/profile_models.dart';
import 'profile_section_card.dart';

class SwingIndexSpotlightCard extends StatelessWidget {
  const SwingIndexSpotlightCard({
    super.key,
    required this.swingIndex,
    required this.axes,
  });

  final int swingIndex;
  final List<PlayerSkillAxis> axes;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Swing Index',
      subtitle:
          'Current profile signal across batting, pressure, and repeatability.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 380;

          return Column(
            children: [
              if (compact) ...[
                _IndexHeadline(
                  swingIndex: swingIndex,
                  axisCount: axes.length,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 230,
                  child: _SwingRadar(
                    axes: axes,
                    overall: swingIndex,
                  ),
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: _IndexHeadline(
                        swingIndex: swingIndex,
                        axisCount: axes.length,
                      ),
                    ),
                    const SizedBox(width: 18),
                    SizedBox(
                      width: 210,
                      height: 210,
                      child: _SwingRadar(
                        axes: axes,
                        overall: swingIndex,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 18),
              Column(
                children: axes
                    .map(
                      (axis) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _AxisBar(axis: axis),
                      ),
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _IndexHeadline extends StatelessWidget {
  const _IndexHeadline({
    required this.swingIndex,
    required this.axisCount,
  });

  final int swingIndex;
  final int axisCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$swingIndex',
            style: TextStyle(
              color: context.fg,
              fontSize: 46,
              fontWeight: FontWeight.w800,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Overall Swing Index',
            style: TextStyle(
              color: context.gold,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$axisCount live axes feeding your current competitive profile.',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _AxisBar extends StatelessWidget {
  const _AxisBar({
    required this.axis,
  });

  final PlayerSkillAxis axis;

  @override
  Widget build(BuildContext context) {
    final value = ((axis.value ?? 0).clamp(0, 100)) / 100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  axis.label,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (axis.delta != null)
                _DeltaPill(
                  value: axis.delta!,
                ),
              const SizedBox(width: 8),
              Text(
                '${axis.value}',
                style: TextStyle(
                  color: context.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: context.bg.withValues(alpha: 0.68),
              valueColor: AlwaysStoppedAnimation<Color>(context.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeltaPill extends StatelessWidget {
  const _DeltaPill({
    required this.value,
  });

  final int value;

  @override
  Widget build(BuildContext context) {
    final positive = value >= 0;
    final tone = positive ? context.accent : context.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${positive ? '+' : ''}$value',
        style: TextStyle(
          color: tone,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SwingRadar extends StatelessWidget {
  const _SwingRadar({
    required this.axes,
    required this.overall,
  });

  final List<PlayerSkillAxis> axes;
  final int overall;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SwingRadarPainter(
        axes: axes,
        stroke: context.stroke,
        accent: context.accent,
        label: context.fgSub,
        panel: context.panel,
        text: context.fg,
        overall: overall,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _SwingRadarPainter extends CustomPainter {
  _SwingRadarPainter({
    required this.axes,
    required this.stroke,
    required this.accent,
    required this.label,
    required this.panel,
    required this.text,
    required this.overall,
  });

  final List<PlayerSkillAxis> axes;
  final Color stroke;
  final Color accent;
  final Color label;
  final Color panel;
  final Color text;
  final int overall;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 26;
    final step = (math.pi * 2) / axes.length;

    final gridPaint = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final fillPaint = Paint()
      ..color = accent.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = accent.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final dotPaint = Paint()..color = accent;

    for (var ring = 1; ring <= 4; ring++) {
      final ringRadius = radius * (ring / 4);
      final path = Path();
      for (var i = 0; i < axes.length; i++) {
        final angle = -math.pi / 2 + (step * i);
        final point = Offset(
          center.dx + math.cos(angle) * ringRadius,
          center.dy + math.sin(angle) * ringRadius,
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (var i = 0; i < axes.length; i++) {
      final angle = -math.pi / 2 + (step * i);
      final end = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.drawLine(center, end, gridPaint);
    }

    final dataPath = Path();
    final labelStyle = TextStyle(
      color: label,
      fontSize: 10,
      fontWeight: FontWeight.w700,
    );

    for (var i = 0; i < axes.length; i++) {
      final angle = -math.pi / 2 + (step * i);
      final normalized = ((axes[i].value ?? 0).clamp(0, 100)) / 100;
      final point = Offset(
        center.dx + math.cos(angle) * radius * normalized,
        center.dy + math.sin(angle) * radius * normalized,
      );

      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
      canvas.drawCircle(point, 4, dotPaint);

      final labelOffset = Offset(
        center.dx + math.cos(angle) * (radius + 18),
        center.dy + math.sin(angle) * (radius + 18),
      );
      final painter = TextPainter(
        text: TextSpan(
          text: _compactLabel(axes[i].label),
          style: labelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(
          labelOffset.dx - (painter.width / 2),
          labelOffset.dy - (painter.height / 2),
        ),
      );
    }

    dataPath.close();
    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, linePaint);

    final centerFill = Paint()..color = panel;
    canvas.drawCircle(center, 34, centerFill);
    canvas.drawCircle(
      center,
      34,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final valuePainter = TextPainter(
      text: TextSpan(
        text: '$overall',
        style: TextStyle(
          color: text,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    valuePainter.paint(
      canvas,
      Offset(center.dx - valuePainter.width / 2, center.dy - 18),
    );

    final labelPainter = TextPainter(
      text: TextSpan(
        text: 'index',
        style: TextStyle(
          color: label,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelPainter.paint(
      canvas,
      Offset(center.dx - labelPainter.width / 2, center.dy + 6),
    );
  }

  String _compactLabel(String value) {
    return switch (value) {
      'Batting' => 'BAT',
      'Bowling' => 'BOWL',
      'Fielding' => 'FIELD',
      'Fitness' => 'FIT',
      'Consistency' => 'CONS',
      'Clutch' => 'CLUTCH',
      'Captaincy' => 'CAPT',
      _ => value.toUpperCase(),
    };
  }

  @override
  bool shouldRepaint(covariant _SwingRadarPainter oldDelegate) {
    return oldDelegate.axes != axes || oldDelegate.overall != overall;
  }
}
