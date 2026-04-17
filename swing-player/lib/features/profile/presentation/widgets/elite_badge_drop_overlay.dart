import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/rank_visual_theme.dart';

class EliteBadgeDropOverlay extends StatelessWidget {
  const EliteBadgeDropOverlay({
    super.key,
    required this.badgeName,
    required this.rankTheme,
    required this.onDismiss,
  });

  final String badgeName;
  final RankVisualTheme rankTheme;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    // Trigger haptic impact
    HapticFeedback.heavyImpact();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Blur background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.7)),
            ),
          ),
          
          // Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge Icon
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: rankTheme.primary.withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.stars_rounded,
                    color: rankTheme.primary,
                    size: 100,
                  ),
                ).animate()
                 .slideY(begin: -2, end: 0, duration: 800.ms, curve: Curves.bounceOut)
                 .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1))
                 .shimmer(delay: 800.ms, duration: 1.seconds),

                const SizedBox(height: 40),

                // Badge Name
                Text(
                  'ACHIEVEMENT UNLOCKED',
                  style: TextStyle(
                    color: rankTheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 1, end: 0),

                const SizedBox(height: 12),

                Text(
                  badgeName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.8, 0.8)),

                const SizedBox(height: 60),

                // Reward
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: rankTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: rankTheme.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, color: rankTheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '+50 IMPACT POINTS',
                        style: TextStyle(
                          color: rankTheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 1200.ms).slideY(begin: 2, end: 0),

                const SizedBox(height: 40),

                TextButton(
                  onPressed: onDismiss,
                  child: Text(
                    'TAP TO DISMISS',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                  ),
                ).animate().fadeIn(delay: 2.seconds),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
