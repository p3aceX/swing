import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../state/ball_event.dart';
import '../theme/premium_a_theme.dart';

/// Layer that watches the event stream and mounts a single transient flash
/// at a time (FOUR / SIX / WICKET / DUCK). Keeps a queue so back-to-back
/// events don't overlap visually.
///
/// Sits as a `Positioned.fill` child of the overlay root. Doesn't absorb
/// taps — overlay layer above wraps in `IgnorePointer`.
class EventFlashLayer extends StatefulWidget {
  const EventFlashLayer({super.key, required this.events});
  final Stream<OverlayEvent> events;

  @override
  State<EventFlashLayer> createState() => _EventFlashLayerState();
}

class _EventFlashLayerState extends State<EventFlashLayer> {
  StreamSubscription<OverlayEvent>? _sub;
  final List<_QueuedFlash> _queue = [];
  Widget? _current;
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    _sub = widget.events.listen(_onEvent);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onEvent(OverlayEvent e) {
    // Wicket flashes carry their own data — they're emitted on the same
    // ball as the corresponding BallLanded. We only want the WicketTaken
    // event to drive the flash, never the bare BallLanded (which would
    // otherwise show a "0" with no name).
    if (e is BallLanded) {
      if (e.ball.isWicket) return; // handled via WicketTaken
      if (e.ball.isSix) {
        _enqueue(_QueuedFlash(
          id: ++_seq,
          duration: const Duration(milliseconds: 2400),
          build: (onDone) => _SixFlash(onDone: onDone),
        ));
        return;
      }
      if (e.ball.isBoundary) {
        _enqueue(_QueuedFlash(
          id: ++_seq,
          duration: const Duration(milliseconds: 1800),
          build: (onDone) => _FourFlash(onDone: onDone),
        ));
        return;
      }
    } else if (e is WicketTaken) {
      _enqueue(_QueuedFlash(
        id: ++_seq,
        duration: const Duration(milliseconds: 2800),
        build: (onDone) => _WicketFlash(event: e, onDone: onDone),
      ));
    }
  }

  void _enqueue(_QueuedFlash q) {
    _queue.add(q);
    if (_current == null) _runNext();
  }

  void _runNext() {
    if (_queue.isEmpty) {
      setState(() => _current = null);
      return;
    }
    final next = _queue.removeAt(0);
    setState(() {
      _current = next.build(() {
        // Defer to avoid setState during an in-flight build.
        WidgetsBinding.instance.addPostFrameCallback((_) => _runNext());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: _current ?? const SizedBox.shrink(),
      ),
    );
  }
}

class _QueuedFlash {
  final int id;
  final Duration duration;
  final Widget Function(VoidCallback onDone) build;
  _QueuedFlash({required this.id, required this.duration, required this.build});
}

// ─────────────────────────────────────────────────────────────────────────
// Base lifecycle — in (220ms) · hold · out (260ms). All flashes share it.
// ─────────────────────────────────────────────────────────────────────────

mixin _FlashLifecycle<W extends StatefulWidget> on State<W>
    implements TickerProvider {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: totalDuration,
  );
  late final Animation<double> _fade;

  Duration get totalDuration;
  double get enterFraction => 220 / totalDuration.inMilliseconds;
  double get exitFraction  => 260 / totalDuration.inMilliseconds;

  VoidCallback get onDone;

  @override
  void initState() {
    super.initState();
    _fade = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: enterFraction * 100,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: (1 - enterFraction - exitFraction) * 100,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: exitFraction * 100,
      ),
    ]).animate(_ctrl);
    _ctrl.forward().whenComplete(onDone);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────
// FOUR — floating burgundy wordmark with a boundary-rope line that
// streaks across underneath. No band, no veil overlap with the camera.
// ─────────────────────────────────────────────────────────────────────────
class _FourFlash extends StatefulWidget {
  const _FourFlash({required this.onDone});
  final VoidCallback onDone;
  @override
  State<_FourFlash> createState() => _FourFlashState();
}

class _FourFlashState extends State<_FourFlash>
    with SingleTickerProviderStateMixin, _FlashLifecycle<_FourFlash> {
  @override
  Duration get totalDuration => const Duration(milliseconds: 1600);

  @override
  VoidCallback get onDone => widget.onDone;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, _) {
        final t = _ctrl.value;
        return Stack(
          children: [
            // Subtle camera dim — same intensity as SIX, just to make the
            // wordmark sit cleanly without competing with backgrounds.
            Container(color: Colors.black.withValues(alpha: 0.28 * _fade.value)),
            // Streak line behind the wordmark.
            Positioned.fill(
              child: CustomPaint(painter: _BoundaryLinePainter(progress: t)),
            ),
            // Wordmark.
            Center(
              child: Transform.scale(
                scale: _wordScale(t),
                child: Opacity(
                  opacity: _fade.value,
                  child: Text(
                    'FOUR',
                    style: TextStyle(
                      color: PremiumATheme.bone,
                      fontSize: 110,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                      height: 1.0,
                      shadows: [
                        Shadow(
                          color: PremiumATheme.burgundy.withValues(alpha: 0.85),
                          blurRadius: 22,
                        ),
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double _wordScale(double t) {
    if (t < enterFraction) {
      final u = (t / enterFraction).clamp(0.0, 1.0);
      final eased = Curves.easeOutBack.transform(u);
      return 0.85 + 0.15 * eased.clamp(0.0, 1.2);
    }
    return 1.0;
  }
}

/// Thin burgundy line that streaks across the screen behind the FOUR
/// wordmark — the boundary-rope metaphor. Draws faster than the
/// wordmark settles so the line "carries" the FOUR into place.
class _BoundaryLinePainter extends CustomPainter {
  _BoundaryLinePainter({required this.progress});
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    // Two-phase line: extends from left edge to right edge during entry,
    // holds, retracts during exit.
    final p = progress.clamp(0.0, 1.0);
    final visibleFrac = p < 0.18
        ? Curves.easeOutCubic.transform((p / 0.18))
        : p > 0.78
            ? 1 - Curves.easeInCubic.transform(((p - 0.78) / 0.22))
            : 1.0;
    final y = size.height * 0.62;
    final paint = Paint()
      ..color = PremiumATheme.burgundy.withValues(alpha: 0.9)
      ..strokeWidth = 4;
    final glow = Paint()
      ..color = PremiumATheme.burgundy.withValues(alpha: 0.35)
      ..strokeWidth = 14;
    final x1 = size.width * 0.5 - size.width * 0.5 * visibleFrac;
    final x2 = size.width * 0.5 + size.width * 0.5 * visibleFrac;
    canvas.drawLine(Offset(x1, y), Offset(x2, y), glow);
    canvas.drawLine(Offset(x1, y), Offset(x2, y), paint);
  }
  @override
  bool shouldRepaint(_BoundaryLinePainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────
// SIX — mustard radial burst + bone wordmark + confetti
// ─────────────────────────────────────────────────────────────────────────
class _SixFlash extends StatefulWidget {
  const _SixFlash({required this.onDone});
  final VoidCallback onDone;
  @override
  State<_SixFlash> createState() => _SixFlashState();
}

class _SixFlashState extends State<_SixFlash>
    with SingleTickerProviderStateMixin, _FlashLifecycle<_SixFlash> {
  @override
  Duration get totalDuration => const Duration(milliseconds: 2400);

  @override
  VoidCallback get onDone => widget.onDone;

  late final List<_Confetto> _confetti = List.generate(60, (_) => _Confetto.spawn());

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, _) {
        final t = _ctrl.value;
        return Stack(
          children: [
            Container(color: Colors.black.withValues(alpha: 0.30 * _fade.value)),
            // Radial burst painter (cheap, mustard).
            Positioned.fill(
              child: CustomPaint(painter: _RadialBurstPainter(progress: t)),
            ),
            // Confetti rain.
            Positioned.fill(
              child: CustomPaint(painter: _ConfettiPainter(items: _confetti, t: t)),
            ),
            // Wordmark.
            Center(
              child: Transform.scale(
                scale: _wordScale(t),
                child: Opacity(
                  opacity: _fade.value,
                  child: Text(
                    'SIX!',
                    style: TextStyle(
                      color: PremiumATheme.bone,
                      fontSize: 130,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                      height: 1.0,
                      shadows: [
                        Shadow(
                          color: PremiumATheme.mustard.withValues(alpha: 0.8),
                          blurRadius: 24,
                        ),
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double _wordScale(double t) {
    if (t < enterFraction) {
      final u = (t / enterFraction).clamp(0.0, 1.0);
      // bounce up to 1.15, settle to 1.0
      final eased = Curves.elasticOut.transform(u);
      return 0.7 + 0.3 * eased.clamp(0.0, 1.5);
    }
    return 1.0;
  }
}

class _Confetto {
  final double startX, dxRate, startY, dyRate, rot, rotRate, size;
  final Color color;
  _Confetto._({
    required this.startX, required this.dxRate,
    required this.startY, required this.dyRate,
    required this.rot, required this.rotRate,
    required this.size, required this.color,
  });
  factory _Confetto.spawn() {
    final rng = math.Random();
    final palette = [
      PremiumATheme.mustard,
      PremiumATheme.bone,
      PremiumATheme.burgundy,
      PremiumATheme.sage,
    ];
    return _Confetto._(
      startX: rng.nextDouble(),
      dxRate: (rng.nextDouble() - 0.5) * 0.4,
      startY: -0.1 - rng.nextDouble() * 0.3,
      dyRate: 0.6 + rng.nextDouble() * 0.8,
      rot: rng.nextDouble() * math.pi * 2,
      rotRate: (rng.nextDouble() - 0.5) * 12,
      size: 4 + rng.nextDouble() * 6,
      color: palette[rng.nextInt(palette.length)],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.items, required this.t});
  final List<_Confetto> items;
  final double t;
  @override
  void paint(Canvas canvas, Size size) {
    for (final c in items) {
      final x = (c.startX + c.dxRate * t) * size.width;
      final y = (c.startY + c.dyRate * t) * size.height;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(c.rot + c.rotRate * t);
      final paint = Paint()..color = c.color.withValues(alpha: 0.9);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: c.size, height: c.size * 0.5),
        paint,
      );
      canvas.restore();
    }
  }
  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}

class _RadialBurstPainter extends CustomPainter {
  _RadialBurstPainter({required this.progress});
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.sqrt(size.width * size.width + size.height * size.height) / 2;
    final p = Curves.easeOutQuart.transform(progress.clamp(0.0, 1.0));
    final r = maxR * p;
    final alpha = (1.0 - p).clamp(0.0, 1.0);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          PremiumATheme.mustard.withValues(alpha: 0.5 * alpha),
          PremiumATheme.mustard.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, paint);
  }
  @override
  bool shouldRepaint(_RadialBurstPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────
// OUT / DUCK — floating wordmark + dismissed batter line. Duck case
// adds the animated waddling-duck CustomPaint left of the wordmark.
// ─────────────────────────────────────────────────────────────────────────
class _WicketFlash extends StatefulWidget {
  const _WicketFlash({required this.event, required this.onDone});
  final WicketTaken event;
  final VoidCallback onDone;
  @override
  State<_WicketFlash> createState() => _WicketFlashState();
}

class _WicketFlashState extends State<_WicketFlash>
    with SingleTickerProviderStateMixin, _FlashLifecycle<_WicketFlash> {
  @override
  Duration get totalDuration => const Duration(milliseconds: 2400);

  @override
  VoidCallback get onDone => widget.onDone;

  @override
  Widget build(BuildContext context) {
    final ev = widget.event;
    final isDuck = ev.isDuck;
    final accent = isDuck ? PremiumATheme.mustard : PremiumATheme.burgundy;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, _) {
        final t = _ctrl.value;
        final holdT = t < enterFraction
            ? 0.0
            : ((t - enterFraction) / (1 - enterFraction)).clamp(0.0, 1.0);
        return Stack(
          children: [
            // Subtle dim — matches FOUR/SIX intensity.
            Container(color: Colors.black.withValues(alpha: 0.30 * _fade.value)),
            Center(
              child: Opacity(
                opacity: _fade.value,
                child: Transform.scale(
                  scale: _wordScale(t),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // The wordmark row — duck adds an animated character left of it.
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (isDuck) ...[
                            SizedBox(
                              width: 100,
                              height: 80,
                              child: CustomPaint(
                                painter: _DuckPainter(t: holdT),
                              ),
                            ),
                            const SizedBox(width: 22),
                          ],
                          Text(
                            isDuck ? 'DUCK' : 'OUT',
                            style: TextStyle(
                              color: PremiumATheme.bone,
                              fontSize: isDuck ? 96 : 120,
                              fontWeight: FontWeight.w900,
                              letterSpacing: isDuck ? 10 : 14,
                              height: 1.0,
                              shadows: [
                                Shadow(
                                  color: accent.withValues(alpha: 0.85),
                                  blurRadius: 24,
                                ),
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Dismissed batter line — small, no plate.
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ev.dismissed.name,
                            style: const TextStyle(
                              color: PremiumATheme.bone,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                              height: 1.0,
                              shadows: [
                                Shadow(
                                  color: Colors.black87,
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 1,
                            height: 12,
                            color: PremiumATheme.bone.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isDuck && ev.isGoldenDuck
                                ? 'GOLDEN DUCK · 0 (1)'
                                : '${ev.dismissed.runs} (${ev.dismissed.ballsFaced}) · ${ev.dismissalMethod}',
                            style: TextStyle(
                              color: PremiumATheme.bone.withValues(alpha: 0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              height: 1.0,
                              shadows: const [
                                Shadow(
                                  color: Colors.black87,
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double _wordScale(double t) {
    if (t < enterFraction) {
      final u = (t / enterFraction).clamp(0.0, 1.0);
      final eased = Curves.easeOutBack.transform(u);
      return 0.80 + 0.20 * eased.clamp(0.0, 1.2);
    }
    return 1.0;
  }
}

/// Flat-design duck. Body, head, bill, eye, two feet. Waddles: head and
/// body bob in sine, feet alternate up/down. All proportioned to fit in
/// a 88×70 canvas.
class _DuckPainter extends CustomPainter {
  _DuckPainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Two waddle cycles per second-ish during hold.
    final bob = math.sin(t * math.pi * 6) * 2.2;   // body Y bob
    final headBob = math.sin(t * math.pi * 6 + 0.4) * 3.0;
    // Feet step out of phase.
    final footPhase = math.sin(t * math.pi * 6);

    final bone = const Color(0xFFECE6D7);
    final body = const Color(0xFFC4942E);   // deep mustard body
    final bill = const Color(0xFFE0533F);   // orange-red bill
    final foot = const Color(0xFFE0533F);

    // Feet — two pill shapes.
    final footPaint = Paint()..color = foot;
    final leftFootY = h - 8 + (footPhase > 0 ? -3 : 0);
    final rightFootY = h - 8 + (footPhase > 0 ? 0 : -3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.32, leftFootY, 14, 6),
        const Radius.circular(3),
      ),
      footPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.52, rightFootY, 14, 6),
        const Radius.circular(3),
      ),
      footPaint,
    );

    // Body — fat oval.
    final bodyPaint = Paint()..color = body;
    final bodyRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.62 + bob),
      width: w * 0.78,
      height: h * 0.55,
    );
    canvas.drawOval(bodyRect, bodyPaint);

    // Body wing detail — slightly darker arc.
    final wingPaint = Paint()
      ..color = const Color(0xFFA67A1F)
      ..style = PaintingStyle.fill;
    final wingPath = Path()
      ..moveTo(w * 0.30, h * 0.60 + bob)
      ..quadraticBezierTo(w * 0.50, h * 0.40 + bob, w * 0.78, h * 0.62 + bob)
      ..quadraticBezierTo(w * 0.55, h * 0.78 + bob, w * 0.30, h * 0.60 + bob)
      ..close();
    canvas.drawPath(wingPath, wingPaint);

    // Head — circle.
    final headPaint = Paint()..color = body;
    final headCenter = Offset(w * 0.78, h * 0.34 + headBob);
    canvas.drawCircle(headCenter, h * 0.20, headPaint);

    // Neck — short rectangle blending head to body.
    canvas.drawRect(
      Rect.fromLTWH(
        headCenter.dx - h * 0.12,
        headCenter.dy + h * 0.04,
        h * 0.16,
        h * 0.30,
      ),
      headPaint,
    );

    // Eye — bone with a black dot.
    final eyeWhite = Paint()..color = bone;
    canvas.drawCircle(Offset(headCenter.dx + 3, headCenter.dy - 2), 3.2, eyeWhite);
    final pupil = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(headCenter.dx + 4, headCenter.dy - 2), 1.4, pupil);

    // Bill — triangle.
    final billPaint = Paint()..color = bill;
    final billPath = Path()
      ..moveTo(headCenter.dx + h * 0.18, headCenter.dy)
      ..lineTo(headCenter.dx + h * 0.40, headCenter.dy - 2)
      ..lineTo(headCenter.dx + h * 0.40, headCenter.dy + 5)
      ..close();
    canvas.drawPath(billPath, billPaint);
    // Bill upper/lower split line.
    final billLine = Paint()
      ..color = const Color(0xFFB23827)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(headCenter.dx + h * 0.18, headCenter.dy + 1.5),
      Offset(headCenter.dx + h * 0.40, headCenter.dy + 1.5),
      billLine,
    );

    // Small motion lines behind the duck — only visible while waddling.
    if (footPhase.abs() > 0.4) {
      final motionPaint = Paint()
        ..color = bone.withValues(alpha: 0.5)
        ..strokeWidth = 1.4;
      for (var i = 0; i < 2; i++) {
        final y = h * 0.55 + i * 6 + bob;
        canvas.drawLine(
          Offset(w * 0.06, y),
          Offset(w * 0.18, y),
          motionPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DuckPainter old) => old.t != t;
}
