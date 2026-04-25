import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/profile_models.dart';
import 'profile_section_card.dart';

class TrophyShelfSection extends StatelessWidget {
  const TrophyShelfSection({
    super.key,
    required this.trophies,
  });

  final List<PlayerTrophy> trophies;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Trophy Shelf',
      subtitle:
          'Pinned moments and profile collectibles from your current season.',
      child: trophies.isEmpty
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.panel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: context.stroke),
              ),
              child: Text(
                'Your first collectible lands as soon as matches and profile milestones start stacking up.',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            )
          : SizedBox(
              height: 154,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: trophies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final trophy = trophies[index];
                  return _TrophyCard(trophy: trophy);
                },
              ),
            ),
    );
  }
}

class _TrophyCard extends StatelessWidget {
  const _TrophyCard({
    required this.trophy,
  });

  final PlayerTrophy trophy;

  @override
  Widget build(BuildContext context) {
    final tone = _toneColor(context, trophy.tone);

    return Container(
      width: 138,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tone.withValues(alpha: 0.26)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.panel,
            tone.withValues(alpha: 0.12),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _iconFor(trophy.iconKey),
              color: tone,
              size: 18,
            ),
          ),
          const Spacer(),
          Text(
            trophy.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.fg,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            trophy.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Color _toneColor(BuildContext context, TrophyTone tone) {
    return switch (tone) {
      TrophyTone.gold => context.gold,
      TrophyTone.emerald => context.accent,
      TrophyTone.steel => context.fg.withValues(alpha: 0.72),
    };
  }

  IconData _iconFor(String iconKey) {
    return switch (iconKey) {
      'rank' => Icons.workspace_premium_rounded,
      'radar' => Icons.radar_rounded,
      'fire' => Icons.local_fire_department_rounded,
      'bat' => Icons.sports_cricket_rounded,
      'ball' => Icons.adjust_rounded,
      'field' => Icons.back_hand_outlined,
      'crown' => Icons.emoji_events_rounded,
      'target' => Icons.track_changes_rounded,
      _ => Icons.stars_rounded,
    };
  }
}
