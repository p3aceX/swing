import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Full-screen "DUCK!" celebration shown when a batter is dismissed for 0.
/// Self-disposing — runs once and removes itself when complete.
class DuckAnimation extends StatefulWidget {
  const DuckAnimation({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<DuckAnimation> createState() => _DuckAnimationState();
}

class _DuckAnimationState extends State<DuckAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _walk;
  late final AnimationController _stamp;

  @override
  void initState() {
    super.initState();
    _walk = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );
    _stamp = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _walk.forward();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _stamp.forward();
    });
    Future.delayed(const Duration(milliseconds: 2700), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _walk.dispose();
    _stamp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Dim flash
          AnimatedBuilder(
            animation: _stamp,
            builder: (_, __) => Container(
              color: Colors.black.withOpacity(0.55 * (1 - _stamp.value).clamp(0, 1) * 0.4 + 0.15 * _stamp.value),
            ),
          ),
          // DUCK! stamp
          Center(
            child: AnimatedBuilder(
              animation: _stamp,
              builder: (_, __) {
                final t = Curves.elasticOut.transform(_stamp.value.clamp(0.0, 1.0));
                final scale = 0.2 + 0.8 * t;
                final opacity = (_stamp.value * 4).clamp(0.0, 1.0) *
                    (1 - ((_stamp.value - 0.85).clamp(0.0, 0.15) / 0.15));
                return Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _DuckStamp(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Walking duck
          AnimatedBuilder(
            animation: _walk,
            builder: (_, __) {
              final size = MediaQuery.of(context).size;
              final t = Curves.easeInOut.transform(_walk.value);
              final dx = -120 + (size.width + 240) * t;
              final waddle = math.sin(_walk.value * math.pi * 8) * 6;
              return Positioned(
                left: dx,
                bottom: size.height * 0.18 + waddle,
                child: const _WalkingDuck(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DuckStamp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC107),
        border: Border.all(color: Colors.black, width: 6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🦆', style: TextStyle(fontSize: 72)),
          SizedBox(width: 16),
          Text(
            'DUCK!',
            style: TextStyle(
              fontSize: 84,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: Colors.black,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _WalkingDuck extends StatelessWidget {
  const _WalkingDuck();
  @override
  Widget build(BuildContext context) =>
      const Text('🦆', style: TextStyle(fontSize: 96));
}
