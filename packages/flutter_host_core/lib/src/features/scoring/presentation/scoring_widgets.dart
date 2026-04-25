import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/host_colors.dart';
import '../domain/scoring_models.dart';

// ─── Wagon Wheel ─────────────────────────────────────────────────────────────

class ScoringWagonWheel extends StatelessWidget {
  const ScoringWagonWheel({
    super.key,
    this.selectedZone,
    this.onZoneTap,
  });

  final String? selectedZone;
  final void Function(String zone)? onZoneTap;

  static const _zones = [
    'FINE_LEG',
    'SQUARE_LEG',
    'MID_WICKET',
    'MID_ON',
    'MID_OFF',
    'STRAIGHT',
    'EXTRA_COVER',
    'COVER',
    'POINT',
    'THIRD_MAN',
  ];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              if (onZoneTap == null) return;
              final center = Offset(w / 2, h / 2);
              final radius = math.min(w, h) / 2;
              final zone = _zoneForTap(details.localPosition, center, radius);
              if (zone != null) onZoneTap!(zone);
            },
            child: CustomPaint(
              painter: _WheelPainter(selectedZone: selectedZone),
            ),
          );
        },
      ),
    );
  }

  static String? _zoneForTap(Offset tap, Offset center, double radius) {
    final delta = tap - center;
    final dist = delta.distance;
    if (dist > radius || dist < radius * 0.08) return null;
    var angle = math.atan2(delta.dy, delta.dx) + math.pi / 2;
    angle = angle % (2 * math.pi);
    if (angle < 0) angle += 2 * math.pi;
    final idx = (angle / (2 * math.pi / 10)).floor() % 10;
    return _zones[idx];
  }
}

class _WheelPainter extends CustomPainter {
  const _WheelPainter({this.selectedZone});

  final String? selectedZone;

  static const _zones = ScoringWagonWheel._zones;

  static const _labels = {
    'FINE_LEG': 'Fine\nLeg',
    'SQUARE_LEG': 'Sq\nLeg',
    'MID_WICKET': 'Mid\nWkt',
    'MID_ON': 'Mid\nOn',
    'MID_OFF': 'Mid\nOff',
    'STRAIGHT': 'Straight',
    'EXTRA_COVER': 'Ex\nCov',
    'COVER': 'Cover',
    'POINT': 'Point',
    'THIRD_MAN': '3rd\nMan',
  };

  double _startAngle(int i) => -math.pi / 2 + i * 2 * math.pi / 10;
  double _midAngle(int i) => _startAngle(i) + math.pi / 10;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2 - 2;
    final innerR = r * 0.62;

    canvas.drawCircle(c, r, Paint()..color = const Color(0xFF1A4B5A));
    canvas.drawCircle(c, innerR, Paint()..color = const Color(0xFF1D5C38));

    final selIdx =
        selectedZone != null ? _zones.indexOf(selectedZone!) : -1;
    if (selIdx >= 0) {
      final sPaint = Paint()..color = Colors.white.withValues(alpha: 0.22);
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        _startAngle(selIdx),
        2 * math.pi / 10,
        true,
        sPaint,
      );
      canvas.drawCircle(c, innerR, Paint()..color = const Color(0xFF1D5C38));
    }

    final divPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 1.2;
    for (int i = 0; i < 10; i++) {
      final a = _startAngle(i);
      canvas.drawLine(
        c + Offset(math.cos(a) * innerR * 0.25, math.sin(a) * innerR * 0.25),
        c + Offset(math.cos(a) * r, math.sin(a) * r),
        divPaint,
      );
    }

    _drawDashedCircle(canvas, c, r, Colors.white.withValues(alpha: 0.45));

    canvas.drawCircle(
      c,
      innerR,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );

    for (int i = 0; i < 10; i++) {
      final mid = _midAngle(i);
      final lr = (innerR + r) / 2;
      final lx = c.dx + math.cos(mid) * lr;
      final ly = c.dy + math.sin(mid) * lr;
      final label = _labels[_zones[i]] ?? _zones[i];
      final isSelected = i == selIdx;
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.75),
            fontSize: 10,
            fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
            height: 1.2,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
    }

    _drawStumps(canvas, c);
  }

  void _drawDashedCircle(
      Canvas canvas, Offset c, double r, Color color) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const n = 36;
    const sweep = 2 * math.pi / n;
    for (int i = 0; i < n; i += 2) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        i * sweep,
        sweep * 0.65,
        false,
        p,
      );
    }
  }

  void _drawStumps(Canvas canvas, Offset c) {
    final p = Paint()
      ..color = const Color(0xFFD4A55A)
      ..style = PaintingStyle.fill;
    for (int i = -1; i <= 1; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(c.dx + i * 5.5, c.dy + 2),
            width: 3,
            height: 22,
          ),
          const Radius.circular(1.5),
        ),
        p,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx, c.dy - 9),
          width: 17,
          height: 2.5,
        ),
        const Radius.circular(1),
      ),
      p,
    );
  }

  @override
  bool shouldRepaint(_WheelPainter old) =>
      old.selectedZone != selectedZone;
}

// ─── Over Dots ───────────────────────────────────────────────────────────────

class OverDotsRow extends StatelessWidget {
  const OverDotsRow({
    super.key,
    required this.overBalls,
  });

  final List<ScoringBall> overBalls;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        if (i >= overBalls.length) {
          return _OverDot.empty();
        }
        final b = overBalls[i];
        return _OverDot(
          outcome: b.outcome,
          runs: b.runs,
          extras: b.extras,
          isWicket: b.isWicket,
        );
      }),
    );
  }
}

class _OverDot extends StatelessWidget {
  const _OverDot({
    required this.outcome,
    this.runs = 0,
    this.extras = 0,
    this.isWicket = false,
  });

  factory _OverDot.empty() => const _OverDot(outcome: null);

  final String? outcome;
  final int runs;
  final int extras;
  final bool isWicket;

  @override
  Widget build(BuildContext context) {
    if (outcome == null) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: context.stroke.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
      );
    }

    final (bg, label) = _resolve();
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  (Color, String) _resolve() {
    if (isWicket) return (const Color(0xFFDC2626), 'W');
    switch (outcome) {
      case 'WIDE':
        return (const Color(0xFF92400E), 'Wd');
      case 'NO_BALL':
        return (const Color(0xFF92400E), 'Nb');
      case 'DOT':
        return (const Color(0xFF374151), '·');
      case 'FOUR':
        return (const Color(0xFF1D4ED8), '4');
      case 'SIX':
        return (const Color(0xFF7C3AED), '6');
      default:
        final total = runs + extras;
        return (const Color(0xFF374151), '$total');
    }
  }
}

// ─── Batter Row ──────────────────────────────────────────────────────────────

class BatterRow extends StatelessWidget {
  const BatterRow({
    super.key,
    required this.name,
    required this.runs,
    required this.balls,
    required this.strikeRate,
    this.isStriker = false,
    this.onTap,
  });

  final String name;
  final int runs;
  final int balls;
  final double strikeRate;
  final bool isStriker;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: isStriker
                  ? Icon(Icons.sports_cricket,
                      size: 16, color: context.accent)
                  : null,
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit, size: 14, color: context.fgSub),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: context.fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: '$runs',
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text: ' ($balls)',
                    style: TextStyle(color: context.fgSub, fontSize: 13),
                  ),
                  TextSpan(
                    text: '  SR ${strikeRate.toStringAsFixed(1)}',
                    style: TextStyle(color: context.fgSub, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bowler Row ──────────────────────────────────────────────────────────────

class BowlerRow extends StatelessWidget {
  const BowlerRow({
    super.key,
    required this.name,
    required this.overs,
    required this.runs,
    required this.wickets,
    required this.economy,
    this.onTap,
  });

  final String name;
  final String overs;
  final int runs;
  final int wickets;
  final String economy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const SizedBox(width: 26),
            Icon(Icons.edit, size: 14, color: context.fgSub),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: context.fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'O   R   W   Eco',
                  style: TextStyle(color: context.fgSub, fontSize: 10),
                ),
                const SizedBox(height: 2),
                Text(
                  '$overs   $runs   $wickets   $economy',
                  style: TextStyle(
                    color: context.fg,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
