import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_host_core/host_ui.dart';
import '../domain/home_models.dart';

// ── Shared Components ─────────────────────────────────────────────────────────

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.onActionTap,
    this.actionLabel = 'See all',
  });

  final String title;
  final VoidCallback? onActionTap;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
          ),
          if (onActionTap != null)
            InkWell(
              onTap: onActionTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      actionLabel,
                      style: TextStyle(
                        color: context.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: context.accent, size: 10),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Tab Widgets ───────────────────────────────────────────────────────────────

class HomeTabSwitcher extends StatelessWidget {
  const HomeTabSwitcher({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.panel.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'For You',
            isSelected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _TabItem(
            label: 'Live',
            isSelected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: 200.ms,
          decoration: BoxDecoration(
            color: isSelected ? context.cardBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? context.fg : context.fgSub,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── For You Widgets ───────────────────────────────────────────────────────────

class FollowedMatchCard extends StatelessWidget {
  const FollowedMatchCard({super.key, required this.match});
  final FollowedMatch match;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: context.panel,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: match.playerAvatarUrl != null
                    ? Image.network(match.playerAvatarUrl!, fit: BoxFit.cover)
                    : Icon(Icons.person, size: 14, color: context.fgSub),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  match.playerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            match.matchTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          if (match.score != null)
            Text(
              match.score!,
              style: TextStyle(
                color: context.accent,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            match.status.toUpperCase(),
            style: TextStyle(
              color: context.fgSub,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeMarketingBanner extends StatelessWidget {
  const HomeMarketingBanner({super.key, required this.banner});
  final MarketingBanner banner;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 100,
      decoration: BoxDecoration(
        color: banner.bgColor ?? context.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (banner.imageUrl != null)
            Positioned.fill(
              child: Image.network(banner.imageUrl!, fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    banner.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (banner.ctaLabel != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      banner.ctaLabel!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
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

class PerformanceDayCard extends StatelessWidget {
  const PerformanceDayCard({super.key, required this.performance});
  final DailyPerformance performance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.panel,
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child:
                    Image.network(performance.userAvatarUrl, fit: BoxFit.cover),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      performance.userName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      performance.matchName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: context.fgSub, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PERFORMANCE',
                    style: TextStyle(
                        color: context.fgSub,
                        fontSize: 10,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    performance.statLine,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: context.gold, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+${performance.ipEarned} IP',
                      style: TextStyle(
                        color: context.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.news});
  final CricketNews news;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      news.source,
                      style: TextStyle(
                          color: context.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      news.timeAgo,
                      style: TextStyle(color: context.fgSub, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  news.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          if (news.imageUrl != null) ...[
            const SizedBox(width: 12),
            Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                color: context.panel,
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(news.imageUrl!, fit: BoxFit.cover),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Live Widgets ──────────────────────────────────────────────────────────────

class LiveMatchCard extends StatelessWidget {
  const LiveMatchCard({super.key, required this.match});
  final LiveMatchPreview match;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                match.league.toUpperCase(),
                style: TextStyle(
                    color: context.fgSub,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, color: context.danger, size: 8),
                    const SizedBox(width: 4),
                    Text(
                      match.status,
                      style: TextStyle(
                          color: context.danger,
                          fontSize: 10,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _LiveTeamInfo(name: match.teamA, logoUrl: match.teamALogo),
              Expanded(
                child: Text(
                  match.score,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5),
                ),
              ),
              _LiveTeamInfo(
                  name: match.teamB, logoUrl: match.teamBLogo, reverse: true),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: context.accent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('WATCH LIVE',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _LiveTeamInfo extends StatelessWidget {
  const _LiveTeamInfo({required this.name, this.logoUrl, this.reverse = false});
  final String name;
  final String? logoUrl;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: context.panel, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: logoUrl != null
          ? Image.network(logoUrl!, fit: BoxFit.cover)
          : Icon(Icons.shield_rounded, size: 20, color: context.fgSub),
    );

    return Column(
      children: [
        logo,
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
