import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/profile_models.dart';
import '../domain/rank_frame_resolver.dart';
import '../domain/rank_visual_theme.dart';

class RankSystemScreen extends StatelessWidget {
  const RankSystemScreen({
    super.key,
    required this.ranking,
  });

  final ProfileRanking ranking;

  @override
  Widget build(BuildContext context) {
    final currentTier = resolveRankTierFlexible(
      rank: ranking.rank,
      label: ranking.label,
      division: ranking.division.toString(),
    );
    final rankTheme = resolveRankVisualTheme(currentTier.rank);
    final tiers = allRankTiers();

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Rank System',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CurrentRankCard(
              ranking: ranking,
              currentTier: currentTier,
              rankTheme: rankTheme,
            ),
            const SizedBox(height: 12),
            const _InfoCard(
              title: 'Impact Points',
              text:
                  'Impact Points (IP) are earned from verified match contribution, results, milestones, and sustained consistency.',
            ),
            const SizedBox(height: 12),
            const _InfoCard(
              title: 'How Rank Moves',
              text:
                  'As your IP grows, you climb the rank ladder. Better and repeat performances push you upward faster.',
            ),
            const SizedBox(height: 16),
            Text(
              'Rank Ladder',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tiers.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.92,
              ),
              itemBuilder: (context, index) {
                final tier = tiers[index];
                return _RankTile(
                  tier: tier,
                  isCurrent: tier.label == currentTier.label,
                  isPast: tier.stepIndex < currentTier.stepIndex,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentRankCard extends StatelessWidget {
  const _CurrentRankCard({
    required this.ranking,
    required this.currentTier,
    required this.rankTheme,
  });

  final ProfileRanking ranking;
  final ResolvedRankTier currentTier;
  final RankVisualTheme rankTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rankTheme.deep,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: rankTheme.primary.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rankTheme.primary.withValues(alpha: 0.08),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              currentTier.assetPath,
              width: 76,
              height: 76,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTier.label,
                  style: TextStyle(
                    color: rankTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${ranking.impactPoints} IP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rank is driven by Impact Points earned.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile({
    required this.tier,
    required this.isCurrent,
    required this.isPast,
  });

  final ResolvedRankTier tier;
  final bool isCurrent;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final theme = resolveRankVisualTheme(tier.rank);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color:
            isCurrent ? theme.primary.withValues(alpha: 0.1) : context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? theme.primary.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            tier.assetPath,
            width: 44,
            height: 44,
          ),
          const SizedBox(height: 8),
          Text(
            tier.rank,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white
                  .withValues(alpha: isPast || isCurrent ? 0.92 : 0.72),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tier.division ?? 'MAX',
            style: TextStyle(
              color: isCurrent
                  ? theme.primary
                  : Colors.white.withValues(alpha: 0.45),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
