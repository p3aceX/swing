import 'package:flutter/material.dart';

/// Generic short-burst centered text overlay used for SIX / FOUR / WICKET.
/// Scales in, holds, fades. ~1.4s total.
class BurstAnimation extends StatefulWidget {
  const BurstAnimation({
    super.key,
    required this.text,
    required this.color,
    required this.onComplete,
    this.emoji,
  });

  final String text;
  final String? emoji;
  final Color color;
  final VoidCallback onComplete;

  @override
  State<BurstAnimation> createState() => _BurstAnimationState();
}

class _BurstAnimationState extends State<BurstAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..forward();
    Future.delayed(const Duration(milliseconds: 1450), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, _) {
              final t = _c.value;
              final scale = t < 0.3
                  ? Curves.elasticOut.transform((t / 0.3).clamp(0.0, 1.0)) * 1.0
                  : 1.0;
              final opacity = t < 0.75 ? 1.0 : (1 - (t - 0.75) / 0.25);
              return Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.2 + 0.8 * scale,
                  // FittedBox scales the burst down on narrow screens
                  // (preview frame, portrait phones) so it never overflows.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.emoji != null) ...[
                            Text(widget.emoji!,
                                style: const TextStyle(fontSize: 56)),
                            const SizedBox(width: 12),
                          ],
                          Text(
                            widget.text,
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 4,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
