import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/host_colors.dart';
import '../domain/scoring_models.dart';
import '../domain/scoring_rules.dart';

// ─── Wagon Wheel ─────────────────────────────────────────────────────────────

class ScoringWagonWheel extends StatelessWidget {
  const ScoringWagonWheel({
    super.key,
    this.selectedZone,
    this.onZoneTap,
  });

  final String? selectedZone;
  final void Function(String zone)? onZoneTap;

  // 8 zones clockwise from Fine Leg (top)
  static const _zones = [
    'FINE_LEG',
    'SQUARE_LEG',
    'MID_WICKET',
    'LONG_ON',
    'LONG_OFF',
    'COVER',
    'POINT',
    'THIRD_MAN',
  ];

  static const _zoneCount = 8;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final radius = math.min(w, h) / 2;
          final innerR = radius * 0.58;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              final center = Offset(w / 2, h / 2);
              final delta = details.localPosition - center;
              final dist = delta.distance;
              if (dist > radius || dist < innerR) return;
              if (onZoneTap == null) return;
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
    if (dist > radius) return null;
    var angle = math.atan2(delta.dy, delta.dx) + math.pi / 2;
    angle = angle % (2 * math.pi);
    if (angle < 0) angle += 2 * math.pi;
    final idx = (angle / (2 * math.pi / _zoneCount)).floor() % _zoneCount;
    return _zones[idx];
  }
}

class _WheelPainter extends CustomPainter {
  const _WheelPainter({this.selectedZone});

  final String? selectedZone;

  static const _zones = ScoringWagonWheel._zones;
  static const _zoneCount = ScoringWagonWheel._zoneCount;

  static const _labels = {
    'FINE_LEG': 'Fine\nLeg',
    'SQUARE_LEG': 'Sq\nLeg',
    'MID_WICKET': 'Mid\nWkt',
    'LONG_ON': 'Long\nOn',
    'LONG_OFF': 'Long\nOff',
    'COVER': 'Cover',
    'POINT': 'Point',
    'THIRD_MAN': '3rd\nMan',
  };

  static const _sweep = 2 * math.pi / _zoneCount;

  double _startAngle(int i) => -math.pi / 2 + i * _sweep;
  double _midAngle(int i) => _startAngle(i) + _sweep / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2 - 2;
    final innerR = r * 0.58;
    final midR = (innerR + r) / 2;

    // Outer field
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFF1A4B5A));
    // Inner pitch
    canvas.drawCircle(c, innerR, Paint()..color = const Color(0xFF1D5C38));

    // Selected zone highlight
    final selIdx = selectedZone != null ? _zones.indexOf(selectedZone!) : -1;
    if (selIdx >= 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        _startAngle(selIdx),
        _sweep,
        true,
        Paint()..color = Colors.white.withValues(alpha: 0.25),
      );
      canvas.drawCircle(c, innerR, Paint()..color = const Color(0xFF1D5C38));
    }

    // Zone dividers
    final divPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..strokeWidth = 1.2;
    for (int i = 0; i < _zoneCount; i++) {
      final a = _startAngle(i);
      canvas.drawLine(
        c + Offset(math.cos(a) * innerR * 0.3, math.sin(a) * innerR * 0.3),
        c + Offset(math.cos(a) * r, math.sin(a) * r),
        divPaint,
      );
    }

    _drawDashedCircle(canvas, c, r, Colors.white.withValues(alpha: 0.4));

    canvas.drawCircle(
      c,
      innerR,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );

    // OFF / LEG watermarks flanking the pitch in the inner circle
    _drawWatermark(canvas, 'LEG', Offset(c.dx + innerR * 0.50, c.dy - innerR * 0.15));
    _drawWatermark(canvas, 'OFF', Offset(c.dx - innerR * 0.50, c.dy - innerR * 0.15));

    // Zone labels in outer ring
    for (int i = 0; i < _zoneCount; i++) {
      final mid = _midAngle(i);
      final lx = c.dx + math.cos(mid) * midR;
      final ly = c.dy + math.sin(mid) * midR;
      final label = _labels[_zones[i]] ?? _zones[i];
      final isSelected = i == selIdx;
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.80),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            height: 1.2,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
    }

    _drawPitchArea(canvas, c, innerR);
  }

  void _drawWatermark(Canvas canvas, String text, Offset pos) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.12),
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  void _drawBat(Canvas canvas, Offset pos) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.50)
      ..style = PaintingStyle.fill;
    // Blade (wider)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(pos.dx, pos.dy + 4), width: 7, height: 13),
        const Radius.circular(1.5),
      ),
      p,
    );
    // Handle (thin)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(pos.dx, pos.dy - 6), width: 2.5, height: 8),
        const Radius.circular(1),
      ),
      p,
    );
  }

  void _drawBall(Canvas canvas, Offset pos) {
    const ballR = 7.0;
    canvas.drawCircle(
      pos,
      ballR,
      Paint()..color = const Color(0xFFCC2200).withValues(alpha: 0.72),
    );
    final seamP = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: pos, radius: ballR * 0.55),
      -math.pi * 0.4,
      math.pi * 0.8,
      false,
      seamP,
    );
    canvas.drawArc(
      Rect.fromCircle(center: pos, radius: ballR * 0.55),
      math.pi * 0.6,
      math.pi * 0.8,
      false,
      seamP,
    );
  }

  void _drawDashedCircle(Canvas canvas, Offset c, double r, Color color) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const n = 40;
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

  void _drawPitchArea(Canvas canvas, Offset c, double innerR) {
    final pitchW = innerR * 0.13;
    final pitchH = innerR * 1.10;
    final halfH = pitchH / 2;
    final creaseOff = halfH * 0.70;

    // ── Pitch strip (tan) ──────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: pitchW, height: pitchH),
        const Radius.circular(2.5),
      ),
      Paint()..color = const Color(0xFFCBA882),
    );

    // Crease lines
    final creasePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.60)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (final dy in [-creaseOff, creaseOff]) {
      canvas.drawLine(
        Offset(c.dx - pitchW / 2 - 2, c.dy + dy),
        Offset(c.dx + pitchW / 2 + 2, c.dy + dy),
        creasePaint,
      );
    }

    // ── Bat at top (bowling end) ───────────────────────────────────────────
    _drawBat(canvas, Offset(c.dx, c.dy - halfH - 10));

    // ── Stumps at center ───────────────────────────────────────────────────
    final stumpPaint = Paint()
      ..color = const Color(0xFFD4A55A)
      ..style = PaintingStyle.fill;
    for (int i = -1; i <= 1; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(c.dx + i * 4.0, c.dy + 2),
            width: 2.5,
            height: 16,
          ),
          const Radius.circular(1),
        ),
        stumpPaint,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(c.dx, c.dy - 5.5), width: 12, height: 1.8),
        const Radius.circular(1),
      ),
      stumpPaint,
    );

    // ── Ball at bottom (batting end) ───────────────────────────────────────
    _drawBall(canvas, Offset(c.dx, c.dy + halfH + 10));
  }

  @override
  bool shouldRepaint(_WheelPainter old) => old.selectedZone != selectedZone;
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
      mainAxisSize: MainAxisSize.min,
      children: [
        ...overBalls.map(
          (b) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: _OverDot(
              outcome: b.outcome,
              runs: b.runs,
              extras: b.extras,
              isWicket: b.isWicket,
            ),
          ),
        ),
        // Empty slots up to 6 legal balls
        ...List.generate(
          (6 - overBalls.where((b) => scoringDeliveryIsLegal(b.outcome)).length)
              .clamp(0, 6),
          (_) => const Padding(
            padding: EdgeInsets.only(right: 4),
            child: _OverDot.placeholder(),
          ),
        ),
      ],
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

  const _OverDot.placeholder() : this(outcome: null);

  final String? outcome;
  final int runs;
  final int extras;
  final bool isWicket;

  @override
  Widget build(BuildContext context) {
    if (outcome == null) {
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: context.stroke.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
      );
    }

    final (bg, label) = _resolve();
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: label.length > 2 ? 9 : 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  (Color, String) _resolve() {
    if (isWicket) return (const Color(0xFFDC2626), 'W');
    switch (outcome) {
      case 'WIDE':
        final wideExtra = extras > 1 ? '+${extras - 1}' : '';
        return (const Color(0xFF92400E), 'Wd$wideExtra');
      case 'NO_BALL':
        final nbRuns = runs > 0 ? '+$runs' : '';
        return (const Color(0xFF92400E), 'Nb$nbRuns');
      case 'BYE':
        return (const Color(0xFF374151), 'B$extras');
      case 'LEG_BYE':
        return (const Color(0xFF374151), 'Lb$extras');
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
