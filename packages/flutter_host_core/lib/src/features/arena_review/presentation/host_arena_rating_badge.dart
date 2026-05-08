import 'package:flutter/material.dart';

import '../../../theme/host_colors.dart';

/// Compact star + count badge: "★ 4.6 · 23" — used on result tiles, match
/// detail sheets, and the biz arena dashboard. Hides itself entirely when
/// [count] is null or below [minVisibleCount] (3 by default), surfacing
/// "New ground" instead so a couple of early reviews can't shape the user's
/// impression of an arena that's still being measured.
///
/// Stays small on purpose — meant to ride alongside the format/price line
/// in a Discover tile, not be a hero element.
class HostArenaRatingBadge extends StatelessWidget {
  const HostArenaRatingBadge({
    super.key,
    required this.average,
    required this.count,
    this.minVisibleCount = 3,
    this.showNewBadge = true,
  });

  final double? average;
  final int? count;
  final int minVisibleCount;
  final bool showNewBadge;

  @override
  Widget build(BuildContext context) {
    if (count == null || count! < minVisibleCount) {
      if (!showNewBadge) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: context.sky.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'NEW GROUND',
          style: TextStyle(
            color: context.sky,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
      );
    }
    final avg = (average ?? 0).clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: 13, color: context.gold),
        const SizedBox(width: 2),
        Text(
          avg.toStringAsFixed(1),
          style: TextStyle(
            color: context.fg,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '· $count',
          style: TextStyle(
            color: context.fgSub,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
