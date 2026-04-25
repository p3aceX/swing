import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/profile_models.dart';
import '../../domain/rank_visual_theme.dart';

class FlexBadgeGrid extends StatelessWidget {
  const FlexBadgeGrid({
    super.key,
    required this.trophies,
    required this.rankTheme,
  });

  final List<PlayerTrophy> trophies;
  final RankVisualTheme rankTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FLEX 100 TROPHY WALL',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '${trophies.length} UNLOCKED',
                style: TextStyle(
                  color: rankTheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: 6, // Show top 6 for now
          itemBuilder: (context, index) {
            if (index < trophies.length) {
              return _BadgeTile(trophy: trophies[index], rankTheme: rankTheme);
            }
            return _LockedBadgeTile(rankTheme: rankTheme);
          },
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.trophy, required this.rankTheme});
  final PlayerTrophy trophy;
  final RankVisualTheme rankTheme;

  @override
  Widget build(BuildContext context) {
    final isElite = trophy.tone == TrophyTone.gold;

    return Container(
      decoration: BoxDecoration(
        color: rankTheme.deep,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isElite ? rankTheme.primary.withOpacity(0.5) : rankTheme.border.withOpacity(0.1),
          width: isElite ? 1.5 : 1,
        ),
        boxShadow: isElite ? [
          BoxShadow(
            color: rankTheme.primary.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: -2,
          )
        ] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.stars_rounded,
            color: isElite ? rankTheme.primary : rankTheme.secondary,
            size: 32,
          ).animate(onPlay: (c) => c.repeat())
           .shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              trophy.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.fg,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedBadgeTile extends StatelessWidget {
  const _LockedBadgeTile({required this.rankTheme});
  final RankVisualTheme rankTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Center(
        child: Icon(
          Icons.lock_outline_rounded,
          color: context.fgSub.withValues(alpha: 0.6),
          size: 24,
        ),
      ),
    );
  }
}
