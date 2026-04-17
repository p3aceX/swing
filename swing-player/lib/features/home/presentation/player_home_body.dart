import "package:cached_network_image/cached_network_image.dart";
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/home_controller.dart';
import '../controller/leaderboard_controller.dart';
import '../domain/home_models.dart';
import '../domain/leaderboard_models.dart';
import '../data/leaderboard_repository.dart';
import '../../matches/controller/matches_controller.dart';
import '../../matches/domain/match_models.dart';
import '../../profile/domain/rank_frame_resolver.dart';
import '../../profile/domain/rank_visual_theme.dart';

class PlayerHomeBody extends ConsumerStatefulWidget {
  const PlayerHomeBody({super.key});

  @override
  ConsumerState<PlayerHomeBody> createState() => _PlayerHomeBodyState();
}

class _PlayerHomeBodyState extends ConsumerState<PlayerHomeBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(matchesControllerProvider.notifier).refresh();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Container(
              color: context.bg,
              child: TabBar(
                controller: _tabController,
                indicatorColor: context.accent,
                labelColor: context.accent,
                unselectedLabelColor: context.fgSub,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                indicatorWeight: 3,
                dividerColor: context.stroke.withValues(alpha: 0.5),
                tabs: const [
                  Tab(text: 'Fixtures'),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.leaderboard_rounded, size: 16),
                        SizedBox(width: 8),
                        Text('Leaderboard'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          if (_tabController.index == 0)
            const _FixturesContent()
          else
            const _LeaderboardContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          const SliverToBoxAdapter(child: _MarketingCarousel()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          const SliverToBoxAdapter(child: _RecommendedConnections()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _MarketingCarousel extends StatefulWidget {
  const _MarketingCarousel();

  @override
  State<_MarketingCarousel> createState() => _MarketingCarouselState();
}

class _MarketingCarouselState extends State<_MarketingCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.93);
  int _currentPage = 0;

  final items = [
    (
      title: 'SWING PRO',
      subtitle: 'ACCESS ELITE PERFORMANCE INSIGHTS',
      icon: Icons.auto_awesome_rounded,
      colors: [const Color(0xFF1A1625), const Color(0xFF2E2442)],
      accent: const Color(0xFF9D59FF),
    ),
    (
      title: 'THE STORE',
      subtitle: 'PREMIUM GEAR FOR THE MODERN ATHLETE',
      icon: Icons.shopping_bag_rounded,
      colors: [const Color(0xFF141E26), const Color(0xFF1C2D3A)],
      accent: const Color(0xFF3B82F6),
    ),
    (
      title: 'COLLECTIBLES',
      subtitle: 'UNLOCK EXCLUSIVE DIGITAL MEMORABILIA',
      icon: Icons.token_rounded,
      colors: [const Color(0xFF25161C), const Color(0xFF3D242E)],
      accent: const Color(0xFFFF7EE2),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 90,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: item.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: item.accent.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Abstract "Glow" shape
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.accent.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child:
                                  Icon(item.icon, color: item.accent, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.6),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: item.accent.withValues(alpha: 0.5),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            items.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 3,
              width: _currentPage == index ? 20 : 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? items[index].accent
                    : context.stroke.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FixturesContent extends ConsumerStatefulWidget {
  const _FixturesContent();

  @override
  ConsumerState<_FixturesContent> createState() => _FixturesContentState();
}

class _FixturesContentState extends ConsumerState<_FixturesContent> {
  MatchTimelineFilter _filter = MatchTimelineFilter.live;

  @override
  Widget build(BuildContext context) {
    final matchesState = ref.watch(matchesControllerProvider);
    final relevantMatches = matchesState.matches.where(_includeOnHome).toList();
    final liveMatches = _sorted(
      relevantMatches.where((m) => m.lifecycle == MatchLifecycle.live).toList(),
      filter: MatchTimelineFilter.live,
    );
    final upcomingMatches = _sorted(
      relevantMatches
          .where((m) => m.lifecycle == MatchLifecycle.upcoming)
          .toList(),
      filter: MatchTimelineFilter.upcoming,
    );

    final visibleMatches =
        _filter == MatchTimelineFilter.live ? liveMatches : upcomingMatches;

    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Matches',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
              ),
              const Spacer(),
              _MatchTabSwitcher(
                current: _filter,
                onChanged: (f) => setState(() => _filter = f),
                liveCount: liveMatches.length,
                upcomingCount: upcomingMatches.length,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (matchesState.isLoading && matchesState.matches.isEmpty)
          const _MatchLoadingScroll()
        else if (matchesState.error != null && matchesState.matches.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _FixturesError(message: matchesState.error!),
          )
        else if (visibleMatches.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _EmptyFixtures(isLive: _filter == MatchTimelineFilter.live),
          )
        else
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: visibleMatches.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: _MatchCard(match: visibleMatches[index]),
              ),
            ),
          ),
      ]),
    );
  }

  bool _includeOnHome(PlayerMatch match) {
    if (match.sectionType == MatchSectionType.tournament &&
        !match.involvesPlayerTeam) {
      return false;
    }
    return match.lifecycle == MatchLifecycle.live ||
        match.lifecycle == MatchLifecycle.upcoming;
  }

  List<PlayerMatch> _sorted(List<PlayerMatch> matches,
      {required MatchTimelineFilter filter}) {
    final copy = [...matches];
    copy.sort((a, b) {
      final aTime = a.scheduledAt;
      final bTime = b.scheduledAt;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return filter == MatchTimelineFilter.past
          ? bTime.compareTo(aTime)
          : aTime.compareTo(bTime);
    });
    return copy;
  }
}

class _LeaderboardContent extends ConsumerWidget {
  const _LeaderboardContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return leaderboardAsync.when(
      loading: () => const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Could not load leaderboard',
            style: TextStyle(
                color: context.fgSub,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'No leaderboard data yet',
                style: TextStyle(
                    color: context.fgSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _LeaderboardRow(
                      entry: entries[index], position: index + 1),
                );
              },
              childCount: entries.length,
            ),
          ),
        );
      },
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry, required this.position});
  final LeaderboardEntry entry;
  final int position;

  @override
  Widget build(BuildContext context) {
    final rankTier =
        resolveRankTierFlexible(rank: entry.rankBase, label: entry.rank);
    final rankTheme = resolveRankVisualTheme(rankTier.rank.toLowerCase());

    final posColor = switch (position) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => context.fgSub,
    };
    final isTop3 = position <= 3;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/player/${entry.playerId}'),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: context.panel.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isTop3
                  ? posColor.withValues(alpha: 0.3)
                  : context.stroke.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              // ── Position ──
              SizedBox(
                width: 32,
                child: Text(
                  '#$position',
                  style: TextStyle(
                    color: posColor,
                    fontSize: isTop3 ? 16 : 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // ── Avatar ──
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isTop3
                          ? posColor.withValues(alpha: 0.4)
                          : context.stroke.withValues(alpha: 0.2)),
                  image: entry.avatarUrl != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(entry.avatarUrl!),
                          fit: BoxFit.cover)
                      : null,
                ),
                child: entry.avatarUrl == null
                    ? Center(
                        child: Text(
                            entry.name.isNotEmpty
                                ? entry.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                                color: context.accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 13)))
                    : null,
              ),
              const SizedBox(width: 12),

              // ── Name ──
              Expanded(
                child: Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),

              // ── Rank badge ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rankTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: rankTheme.border.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      rankTier.assetPath,
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      rankTier.label.toUpperCase(),
                      style: TextStyle(
                        color: rankTheme.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // ── IP ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.impactPoints}',
                    style: TextStyle(
                      color: context.gold,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'POINTS',
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Match Tab Switcher ────────────────────────────────────────────────────────

class _MatchTabSwitcher extends StatelessWidget {
  const _MatchTabSwitcher({
    required this.current,
    required this.onChanged,
    required this.liveCount,
    required this.upcomingCount,
  });

  final MatchTimelineFilter current;
  final ValueChanged<MatchTimelineFilter> onChanged;
  final int liveCount;
  final int upcomingCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.cardBg.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabItem(
            selected: current == MatchTimelineFilter.live,
            label: 'LIVE',
            count: liveCount,
            isLive: true,
            onTap: () => onChanged(MatchTimelineFilter.live),
          ),
          _TabItem(
            selected: current == MatchTimelineFilter.upcoming,
            label: 'UPCOMING',
            count: upcomingCount,
            isLive: false,
            onTap: () => onChanged(MatchTimelineFilter.upcoming),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.selected,
    required this.label,
    required this.count,
    required this.isLive,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final int count;
  final bool isLive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? context.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: context.accent.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            if (isLive && count > 0) ...[
              _PulsingLiveDot(color: selected ? Colors.black : const Color(0xFF00FF95)),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black : context.fgSub,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: selected
                      ? Colors.black.withValues(alpha: 0.6)
                      : context.fgSub.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
                child: Text('$count'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Match Card ────────────────────────────────────────────────────────────────

class _TeamLogo extends StatelessWidget {
  const _TeamLogo({required this.url, required this.name, this.size = 24});
  final String? url;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(url!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallback(context)),
      );
    }
    return _fallback(context);
  }

  Widget _fallback(BuildContext context) {
    final ch = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(ch,
          style: TextStyle(
            color: context.accent,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          )),
    );
  }
}

class _MatchCard extends ConsumerWidget {
  const _MatchCard({required this.match});

  final PlayerMatch match;

  String _teamLabel(String? shortName, String fullName) =>
      (shortName != null && shortName.isNotEmpty) ? shortName : fullName;

  String _getCountdown(DateTime? date) {
    if (date == null) return "UPCOMING";
    final diff = date.difference(DateTime.now());
    if (diff.isNegative) return "UPCOMING";
    if (diff.inDays > 1) return "IN ${diff.inDays} DAYS";
    if (diff.inDays == 1) return "TOMORROW";
    if (diff.inHours > 0) return "${diff.inHours}H ${diff.inMinutes % 60}M";
    if (diff.inMinutes > 0) return "${diff.inMinutes} MINS";
    return "SOON";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLive = match.lifecycle == MatchLifecycle.live;
    final colorA = _teamColor(match.playerTeamName);
    final colorB = _teamColor(match.opponentTeamName);

    final centerAsync =
        isLive ? ref.watch(matchCenterProvider(match.id)) : null;
    final center = centerAsync?.valueOrNull;

    final formatText = match.formatLabel ?? match.competitionLabel ?? 'T20';
    final dateText = _getCountdown(match.scheduledAt);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorA.withValues(alpha: 0.18),
            colorB.withValues(alpha: 0.12),
            const Color(0xFF0A0A0A),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
        border: Border.all(
          color: isLive
              ? context.accent.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
          width: isLive ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Abstract background accents
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorA.withValues(alpha: 0.08),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          formatText.toUpperCase(),
                          style: TextStyle(
                            color: context.fg.withValues(alpha: 0.7),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      if (isLive)
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _PulsingLiveDot(color: Color(0xFF00FF95)),
                            SizedBox(width: 6),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Color(0xFF00FF95),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          dateText,
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                    ],
                  ),

                  const Spacer(),

                  // Teams
                  Row(
                    children: [
                      // Team A
                      Expanded(
                        child: Column(
                          children: [
                            _TeamLogo(
                              url: match.playerTeamLogoUrl,
                              name: match.playerTeamName,
                              size: 48,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _teamLabel(match.playerTeamShortName,
                                      match.playerTeamName)
                                  .toUpperCase(),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // VS / Score
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: isLive && center != null
                            ? Column(
                                children: [
                                  Text(
                                    "${_resolvePlayerTeamScore(center)}-${_resolveOpponentTeamScore(center)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "CRR: ${center.currentRunRate ?? '0.0'}",
                                    style: TextStyle(
                                      color: context.accent.withValues(alpha: 0.8),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "VS",
                                  style: TextStyle(
                                    color: context.fgSub.withValues(alpha: 0.5),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                      ),

                      // Team B
                      Expanded(
                        child: Column(
                          children: [
                            _TeamLogo(
                              url: match.opponentTeamLogoUrl,
                              name: match.opponentTeamName,
                              size: 48,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _teamLabel(match.opponentTeamShortName,
                                      match.opponentTeamName)
                                  .toUpperCase(),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Footer Actions & Info
                  Row(
                    children: [
                      if (match.venueLabel != null)
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.location_on_rounded,
                                  size: 11, color: context.fgSub.withValues(alpha: 0.7)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  match.venueLabel!.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: context.fgSub.withValues(alpha: 0.7),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Action Button
                      GestureDetector(
                        onTap: () => context.push('/match/${Uri.encodeComponent(match.id)}'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: context.accent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: context.accent.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'MATCH CENTER',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _resolvePlayerTeamScore(MatchCenter center) {
    final playerName = match.playerTeamName.toLowerCase().trim();
    final teamAName = center.teamAName.toLowerCase().trim();
    if (playerName == teamAName ||
        (match.playerTeamShortName ?? '').toLowerCase().trim() ==
            (center.teamAShortName ?? '').toLowerCase().trim()) {
      return center.teamAScore.isEmpty ? '-' : center.teamAScore;
    }
    return center.teamBScore.isEmpty ? '-' : center.teamBScore;
  }

  String _resolveOpponentTeamScore(MatchCenter center) {
    final playerName = match.playerTeamName.toLowerCase().trim();
    final teamAName = center.teamAName.toLowerCase().trim();
    if (playerName == teamAName ||
        (match.playerTeamShortName ?? '').toLowerCase().trim() ==
            (center.teamAShortName ?? '').toLowerCase().trim()) {
      return center.teamBScore.isEmpty ? '-' : center.teamBScore;
    }
    return center.teamAScore.isEmpty ? '-' : center.teamAScore;
  }
}

Color _teamColor(String name) {
  const palette = [
    Color(0xFF3FA66A), // Emerald
    Color(0xFF5B8FD4), // Blue
    Color(0xFFD7A94B), // Gold
    Color(0xFFCC7A7A), // Rose
    Color(0xFF9B7FD4), // Purple
    Color(0xFF34B8A0), // Teal
    Color(0xFFE07B45), // Orange
  ];
  if (name.isEmpty) return palette[0];
  return palette[name.codeUnits.fold(0, (a, b) => a + b) % palette.length];
}

// ── Hero Section ──────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.hero, required this.others});
  final DailyPerformance hero;
  final List<DailyPerformance> others;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  context.accent.withValues(alpha: 0.15),
                  context.cardBg.withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: context.accent.withValues(alpha: 0.25),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.accent.withValues(alpha: 0.05),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Subtle decorative background elements
                Positioned(
                  right: -20,
                  top: -20,
                  child: Icon(
                    Icons.star_rounded,
                    size: 140,
                    color: context.accent.withValues(alpha: 0.03),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    children: [
                      // Sexy Avatar with double ring
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.accent.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [context.accent, context.accent.withValues(alpha: 0.4)],
                              ),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.cardBg,
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(hero.userAvatarUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: context.accent,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.bolt_rounded,
                                  color: Colors.black, size: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 18),
                      
                      // Hero Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: context.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'HERO OF THE DAY',
                                style: TextStyle(
                                  color: context.accent,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              hero.userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hero.statLine,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.fgSub,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // IP Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '+${hero.ipEarned}',
                              style: TextStyle(
                                color: context.accent,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'IP',
                              style: TextStyle(
                                color: context.accent.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (others.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: others.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) =>
                  _PerformanceMiniCard(performance: others[index]),
            ),
          ),
        ],
      ],
    );
  }
}

class _PerformanceMiniCard extends StatelessWidget {
  const _PerformanceMiniCard({required this.performance});
  final DailyPerformance performance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            performance.userName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            performance.statLine,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: context.fgSub,
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                '+${performance.ipEarned} IP',
                style: TextStyle(
                    color: context.gold,
                    fontWeight: FontWeight.w900,
                    fontSize: 12),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: context.fgSub.withValues(alpha: 0.3), size: 10),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Components ────────────────────────────────────────────────────────────────

class _PulsingLiveDot extends StatefulWidget {
  const _PulsingLiveDot({required this.color});
  final Color color;
  @override
  State<_PulsingLiveDot> createState() => _PulsingLiveDotState();
}

class _PulsingLiveDotState extends State<_PulsingLiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl),
      child: Container(
          width: 6,
          height: 6,
          decoration:
              BoxDecoration(color: widget.color, shape: BoxShape.circle)),
    );
  }
}

class _FixturesError extends StatelessWidget {
  const _FixturesError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded,
              color: context.fgSub.withValues(alpha: 0.4), size: 28),
          const SizedBox(height: 8),
          Text(
            'Could not load matches',
            style: TextStyle(
                color: context.fgSub,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmptyFixtures extends StatelessWidget {
  const _EmptyFixtures({required this.isLive});
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_cricket_rounded,
              color: context.fgSub.withValues(alpha: 0.3), size: 32),
          const SizedBox(height: 8),
          Text(
            isLive
                ? 'No live matches right now'
                : 'No upcoming matches scheduled',
            style: TextStyle(
                color: context.fgSub,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _MatchLoadingScroll extends StatelessWidget {
  const _MatchLoadingScroll();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => Container(
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
              color: context.cardBg, borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}

class _RecommendedConnections extends ConsumerWidget {
  const _RecommendedConnections();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(recommendationsProvider);

    return recsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(), // hide silently — not critical
      data: (entries) {
        if (entries.isEmpty)
          return const SizedBox
              .shrink(); // no section if backend returns nothing
        final visible = entries.take(4).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'People You May Know',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          fontSize: 16,
                        ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/recommended-connections'),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'View all',
                      style: TextStyle(
                        color: context.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: visible.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final entry = visible[index];
                  return _RecommendationCard(entry: entry);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecommendationCard extends ConsumerStatefulWidget {
  const _RecommendationCard({required this.entry});
  final LeaderboardEntry entry;

  @override
  ConsumerState<_RecommendationCard> createState() =>
      _RecommendationCardState();
}

class _RecommendationCardState extends ConsumerState<_RecommendationCard> {
  bool _isFollowing = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return GestureDetector(
      onTap: () => context.push('/player/${entry.playerId}'),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.stroke),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: context.accent.withValues(alpha: 0.15),
              backgroundImage: entry.avatarUrl != null
                  ? CachedNetworkImageProvider(entry.avatarUrl!)
                  : null,
              child: entry.avatarUrl == null
                  ? Text(
                      entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                      style: TextStyle(
                          color: context.accent,
                          fontSize: 18,
                          fontWeight: FontWeight.w800))
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            if (entry.rank.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                entry.rankLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: context.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700),
              ),
            ],
            const SizedBox(height: 1),
            Text(
              '${entry.impactPoints} IP',
              style: TextStyle(
                  color: context.fgSub,
                  fontSize: 10,
                  fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 30,
              child: ElevatedButton(
                onPressed: _loading ? null : _toggleFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isFollowing ? Colors.transparent : context.accent,
                  foregroundColor: _isFollowing ? context.fg : Colors.black,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  side: _isFollowing
                      ? BorderSide(color: context.stroke)
                      : BorderSide.none,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _loading
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, 
                            color: _isFollowing ? context.fg : Colors.black))
                    : Text(
                        _isFollowing ? 'Following' : 'Follow',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _isFollowing ? context.fg : Colors.black,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFollow() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(leaderboardRepositoryProvider);
      if (_isFollowing) {
        await repo.unfollowPlayer(widget.entry.playerId);
      } else {
        await repo.followPlayer(widget.entry.playerId);
      }
      if (mounted) setState(() => _isFollowing = !_isFollowing);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
