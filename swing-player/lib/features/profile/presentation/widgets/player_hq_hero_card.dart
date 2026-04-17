import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/profile_models.dart';
import '../../domain/rank_frame_resolver.dart';
import 'rank_framed_avatar.dart';

class PlayerHqHeroCard extends StatelessWidget {
  const PlayerHqHeroCard({
    super.key,
    required this.identity,
    required this.rankProgress,
    required this.frameAsset,
    required this.onQrPressed,
    this.onAvatarPressed,
  });

  final PlayerIdentity identity;
  final PlayerRankProgress rankProgress;
  final String frameAsset;
  final VoidCallback onQrPressed;
  final VoidCallback? onAvatarPressed;

  @override
  Widget build(BuildContext context) {
    final resolvedTier = resolveRankTier(
      rank: rankProgress.rank,
      division: rankProgress.division,
    );
    final rankLabel = rankProgress.label.trim().isEmpty
        ? resolvedTier.label
        : rankProgress.label.trim();
    final subtitleParts = [
      identity.primaryRole.trim(),
      identity.archetype.trim(),
    ].where((part) => part.isNotEmpty).toList();
    final subtitle =
        subtitleParts.isEmpty ? 'Swing Player' : subtitleParts.join(' · ');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: context.stroke.withValues(alpha: 0.8)),
        color: context.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Premium Background Layers
          Positioned.fill(
            child: _PremiumHeroBackground(tier: resolvedTier),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                // 1. Centered Framed Avatar
                Stack(
                  alignment: Alignment.center,
                  children: [
                    RankFramedAvatar(
                      frameAsset: frameAsset,
                      displayName: identity.fullName,
                      avatarUrl: identity.avatarUrl,
                      size: 160,
                      glowColor: resolvedTier.isApex
                          ? context.gold.withValues(alpha: 0.3)
                          : context.accent.withValues(alpha: 0.2),
                    ),
                    if (onAvatarPressed != null)
                      Positioned(
                        right: 15,
                        bottom: 15,
                        child: HeroActionButton(
                          icon: Icons.camera_alt_rounded,
                          tooltip: 'Update photo',
                          onPressed: onAvatarPressed!,
                          mini: true,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // 2. Identity Text
                Text(
                  identity.fullName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      identity.swingId,
                      style: TextStyle(
                        color: context.gold.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _HeroActionChip(
                      label: 'QR',
                      onPressed: onQrPressed,
                      icon: Icons.qr_code_2_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Rank Tier Label
                _RankTierBadge(label: rankLabel, isApex: resolvedTier.isApex),

                const SizedBox(height: 24),

                // 4. Hero Stat Chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HeroStatChip(
                      label: 'IP',
                      value: '${rankProgress.impactPoints}',
                      icon: Icons.bolt_rounded,
                      tone: context.accent,
                    ),
                    const SizedBox(width: 10),
                    HeroStatChip(
                      label: 'SP',
                      value: '${rankProgress.seasonPoints}',
                      icon: Icons.stars_rounded,
                    ),
                    const SizedBox(width: 10),
                    HeroStatChip(
                      label: 'MVPs',
                      value: '${rankProgress.mvpCount}',
                      icon: Icons.emoji_events_rounded,
                      tone: context.gold,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 5. Rank Progress
                RankProgressSection(
                  rankProgress: rankProgress,
                  currentLabel: rankLabel,
                ),

                if (rankProgress.hasPremiumPass) ...[
                  const SizedBox(height: 16),
                  _PremiumPassBadge(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumHeroBackground extends StatelessWidget {
  const _PremiumHeroBackground({required this.tier});

  final ResolvedRankTier tier;

  @override
  Widget build(BuildContext context) {
    final accentColor = tier.isApex ? context.gold : context.accent;

    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.surf.withValues(alpha: 0.8),
                context.cardBg,
              ],
            ),
          ),
        ),

        // Glow orbs
        Positioned(
          top: -100,
          left: -50,
          child: _HeroGlowOrb(
            size: 300,
            color: accentColor.withValues(alpha: 0.08),
          ),
        ),
        Positioned(
          bottom: -80,
          right: -40,
          child: _HeroGlowOrb(
            size: 250,
            color: context.gold.withValues(alpha: 0.04),
          ),
        ),

        // Subtle stadium feel texture (abstract)
        Positioned.fill(
          child: Opacity(
            opacity: 0.03,
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const NetworkImage(
                      'https://www.transparenttextures.com/patterns/carbon-fibre.png'),
                  repeat: ImageRepeat.repeat,
                  colorFilter: ColorFilter.mode(context.fg, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RankTierBadge extends StatelessWidget {
  const _RankTierBadge({required this.label, required this.isApex});

  final String label;
  final bool isApex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: (isApex ? context.gold : context.accent).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: (isApex ? context.gold : context.accent).withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: isApex ? context.gold : context.accent,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class HeroStatChip extends StatelessWidget {
  const HeroStatChip({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.tone,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final accentTone = tone ?? context.fg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.panel.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.stroke.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: accentTone),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: accentTone,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class RankProgressSection extends StatelessWidget {
  const RankProgressSection({
    super.key,
    required this.rankProgress,
    required this.currentLabel,
  });

  final PlayerRankProgress rankProgress;
  final String currentLabel;

  @override
  Widget build(BuildContext context) {
    final progress = rankProgress.progress.clamp(0.0, 1.0);
    final hasNextRank = rankProgress.nextRankLabel.trim().isNotEmpty &&
        rankProgress.nextRankLabel.trim() != currentLabel;
    
    final helperText = hasNextRank
        ? rankProgress.pointsToNextRank > 0
            ? '${rankProgress.pointsToNextRank} IP to ${rankProgress.nextRankLabel}'
            : 'Promotion threshold reached.'
        : 'Top rank secured.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              currentLabel,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              hasNextRank ? rankProgress.nextRankLabel : 'Peak',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 10,
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.bg.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: context.stroke.withValues(alpha: 0.3)),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: progress,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.accent,
                        context.accent.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: context.accent.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            helperText,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroActionChip extends StatelessWidget {
  const _HeroActionChip({
    required this.label,
    required this.onPressed,
    required this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: context.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.accent.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: context.accent),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: context.accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumPassBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.gold.withValues(alpha: 0.15),
            context.gold.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded, size: 16, color: context.gold),
          const SizedBox(width: 8),
          Text(
            'PASS ACTIVE',
            style: TextStyle(
              color: context.gold,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class HeroActionButton extends StatelessWidget {
  const HeroActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.accent = false,
    this.mini = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool accent;
  final bool mini;

  @override
  Widget build(BuildContext context) {
    final size = mini ? 36.0 : 44.0;
    final foreground = accent ? context.accent : context.fg;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: accent
            ? context.accentBg.withValues(alpha: 0.9)
            : context.panel.withValues(alpha: 0.95),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: accent
                    ? context.accent.withValues(alpha: 0.3)
                    : context.stroke.withValues(alpha: 0.5),
              ),
            ),
            child: Icon(icon, size: mini ? 16 : 20, color: foreground),
          ),
        ),
      ),
    );
  }
}

class _HeroGlowOrb extends StatelessWidget {
  const _HeroGlowOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
