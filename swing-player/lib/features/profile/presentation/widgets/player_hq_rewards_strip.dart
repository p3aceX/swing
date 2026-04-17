import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/profile_models.dart';

class PlayerHqRewardsStrip extends StatelessWidget {
  const PlayerHqRewardsStrip({
    super.key,
    required this.seasonProgress,
  });

  final SeasonProgress seasonProgress;

  @override
  Widget build(BuildContext context) {
    if (seasonProgress.milestones.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.stroke),
        ),
        child: Text(
          'Season rewards will show up here once progress starts landing.',
          style: TextStyle(
            color: context.fgSub,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 360;
              final details = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seasonProgress.title,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    seasonProgress.summary,
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              );
              final callout = _RewardCallout(
                label: 'Next Unlock',
                value: seasonProgress.nextRewardLabel,
              );

              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    details,
                    const SizedBox(height: 12),
                    callout,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: details),
                  const SizedBox(width: 12),
                  callout,
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: seasonProgress.progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: context.panel,
              valueColor: AlwaysStoppedAnimation<Color>(context.gold),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: seasonProgress.milestones.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final milestone = seasonProgress.milestones[index];
                return _RewardMilestoneCard(milestone: milestone);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardCallout extends StatelessWidget {
  const _RewardCallout({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 128),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.gold.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.fg,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardMilestoneCard extends StatelessWidget {
  const _RewardMilestoneCard({
    required this.milestone,
  });

  final SeasonMilestone milestone;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = milestone.isCurrent;
    final isUnlocked = milestone.isUnlocked;
    final tone = isUnlocked ? context.gold : context.accent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 156,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isHighlighted
            ? tone.withValues(alpha: 0.16)
            : context.panel.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted ? tone.withValues(alpha: 0.34) : context.stroke,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: tone.withValues(alpha: 0.14),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isUnlocked
                  ? Icons.workspace_premium_rounded
                  : Icons.lock_clock_outlined,
              size: 16,
              color: tone,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: milestone.label,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: '\n${milestone.requiredPoints} SP',
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
