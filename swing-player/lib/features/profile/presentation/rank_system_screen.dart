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
        foregroundColor: context.fg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Rank System',
          style: TextStyle(
            color: context.fg,
            fontWeight: FontWeight.w900,
            fontSize: 17,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          _CurrentRankCard(
            ranking: ranking,
            currentTier: currentTier,
            rankTheme: rankTheme,
          ),
          const SizedBox(height: 22),

          // Section: How it works
          _LabelHeader(text: 'HOW IT WORKS'),
          const SizedBox(height: 10),
          const _InfoRow(
            icon: Icons.bolt_rounded,
            title: 'Impact Points (IP)',
            text:
                'Earn IP from verified match contribution, results, milestones and consistency.',
          ),
          const SizedBox(height: 14),
          const _InfoRow(
            icon: Icons.trending_up_rounded,
            title: 'How rank moves',
            text:
                'As your IP grows, you climb the ladder. Better and repeat performances push you upward faster.',
          ),

          const SizedBox(height: 28),

          // Section: Rank ladder
          Row(
            children: [
              _LabelHeader(text: 'RANK LADDER'),
              const Spacer(),
              Text(
                '${tiers.length} tiers',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tiers.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.84,
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
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Hero — current rank card
// ═══════════════════════════════════════════════════════════════════════════

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
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            rankTheme.primary.withValues(alpha: 0.18),
            rankTheme.primary.withValues(alpha: 0.06),
            const Color(0xFFFFFFFF),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rankTheme.primary.withValues(alpha: 0.10),
              border: Border.all(
                color: rankTheme.primary.withValues(alpha: 0.35),
                width: 1.4,
              ),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              currentTier.assetPath,
              width: 70,
              height: 70,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTier.label.toUpperCase(),
                  style: TextStyle(
                    color: rankTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${ranking.impactPoints}',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.2,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'IP',
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Earn more by performing in verified matches.',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
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

// ═══════════════════════════════════════════════════════════════════════════
// Section labels + info rows
// ═══════════════════════════════════════════════════════════════════════════

class _LabelHeader extends StatelessWidget {
  const _LabelHeader({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.fgSub,
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.8,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: context.panel,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: context.fg),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: context.fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Rank ladder grid tile
// ═══════════════════════════════════════════════════════════════════════════

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: isCurrent ? theme.primary.withValues(alpha: 0.12) : context.surf,
        border: Border.all(
          color: isCurrent
              ? theme.primary.withValues(alpha: 0.55)
              : context.stroke,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: isCurrent || isPast ? 1.0 : 0.55,
            child: SvgPicture.asset(
              tier.assetPath,
              width: 46,
              height: 46,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            tier.rank,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isCurrent || isPast
                  ? context.fg
                  : context.fgSub.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tier.division ?? 'MAX',
            style: TextStyle(
              color: isCurrent
                  ? theme.primary
                  : context.fgSub.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          if (isCurrent) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'YOU',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
