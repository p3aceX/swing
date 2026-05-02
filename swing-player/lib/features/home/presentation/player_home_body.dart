import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/leaderboard_controller.dart';
import '../domain/leaderboard_models.dart';
import '../../matches/controller/matches_controller.dart';
import '../../matches/domain/match_models.dart';
import '../domain/home_models.dart';
import '../../profile/domain/rank_frame_resolver.dart';
import '../../profile/domain/rank_visual_theme.dart';

class PlayerHomeBody extends ConsumerStatefulWidget {
  const PlayerHomeBody({super.key, this.onFindMatch});
  final VoidCallback? onFindMatch;

  @override
  ConsumerState<PlayerHomeBody> createState() => _PlayerHomeBodyState();
}

class _PlayerHomeBodyState extends ConsumerState<PlayerHomeBody> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(matchesControllerProvider.notifier).refresh();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverToBoxAdapter(child: _MatchEntry(onFindMatch: widget.onFindMatch)),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          const _FixturesContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          const SliverToBoxAdapter(
              child: RepaintBoundary(child: _MarketingCarousel())),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ── Match Entry ───────────────────────────────────────────────────────────────

class _MatchEntry extends StatelessWidget {
  const _MatchEntry({this.onFindMatch});
  final VoidCallback? onFindMatch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find a Match',
            style: TextStyle(
              color: context.fg,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Get paired with a team in seconds.',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MatchTypeButton(
                  label: 'Team Match',
                  icon: Icons.groups_rounded,
                  primary: true,
                  onTap: onFindMatch,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MatchTypeButton(
                  label: 'Play Solo',
                  icon: Icons.person_rounded,
                  primary: false,
                  onTap: onFindMatch,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatchTypeButton extends StatelessWidget {
  const _MatchTypeButton({
    required this.label,
    required this.icon,
    required this.primary,
    this.onTap,
  });
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = primary ? context.ctaBg : context.panel;
    final fg = primary ? context.ctaFg : context.fg;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fg, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section header — minimal flat title ──────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: context.fg,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MarketingCarousel extends StatefulWidget {
  const _MarketingCarousel();

  @override
  State<_MarketingCarousel> createState() => _MarketingCarouselState();
}

class _MarketingItem {
  const _MarketingItem({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.icon,
    required this.bgColors,
    required this.darkBgColors,
    required this.bgStops,
    required this.ink,
    required this.darkInk,
    required this.accent,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String cta;
  final IconData icon;
  final List<Color> bgColors;
  final List<Color> darkBgColors;
  final List<double> bgStops;
  final Color ink;
  final Color darkInk;
  final Color accent;
}

class _MarketingCarouselState extends State<_MarketingCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  static const _items = <_MarketingItem>[
    _MarketingItem(
      eyebrow: 'SWING PRO',
      title: 'Unlock elite\nperformance.',
      subtitle: 'Deep stats, Apex AI insights and pro tools.',
      cta: 'Try free',
      icon: Icons.auto_awesome_rounded,
      bgColors: [Color(0xFFF6EFFF), Color(0xFFE8DAFF), Color(0xFFD2BBFA)],
      darkBgColors: [Color(0xFF1A0F2E), Color(0xFF2A1956), Color(0xFF3D2280)],
      bgStops: [0.0, 0.55, 1.0],
      ink: Color(0xFF2D1A55),
      darkInk: Color(0xFFF1E7FF),
      accent: Color(0xFF7C3AED),
    ),
    _MarketingItem(
      eyebrow: 'THE STORE',
      title: 'New season,\nfresh kit.',
      subtitle: 'Bats, balls, gloves and more — pro-grade gear.',
      cta: 'Shop now',
      icon: Icons.shopping_bag_rounded,
      bgColors: [Color(0xFFEAF3FF), Color(0xFFD9E8FC), Color(0xFFBED6F8)],
      darkBgColors: [Color(0xFF0B162E), Color(0xFF112752), Color(0xFF1A3A82)],
      bgStops: [0.0, 0.55, 1.0],
      ink: Color(0xFF132B57),
      darkInk: Color(0xFFE3EEFF),
      accent: Color(0xFF1D4ED8),
    ),
    _MarketingItem(
      eyebrow: 'COLLECTIBLES',
      title: 'Own the\nmoment.',
      subtitle: 'Limited edition cards from your favourite players.',
      cta: 'Browse drops',
      icon: Icons.token_rounded,
      bgColors: [Color(0xFFFFEDF7), Color(0xFFFFD6EA), Color(0xFFFFB8D6)],
      darkBgColors: [Color(0xFF260918), Color(0xFF4A1133), Color(0xFF7A1F55)],
      bgStops: [0.0, 0.55, 1.0],
      ink: Color(0xFF5B0F38),
      darkInk: Color(0xFFFFDDF0),
      accent: Color(0xFFDB2777),
    ),
    _MarketingItem(
      eyebrow: 'BOOK A TURF',
      title: 'Play tonight.\nBook in 30s.',
      subtitle: 'Cricket nets, futsal and more — near you.',
      cta: 'Find slots',
      icon: Icons.place_rounded,
      bgColors: [Color(0xFFE8FBEF), Color(0xFFBEEDD0), Color(0xFF8DDDB1)],
      darkBgColors: [Color(0xFF062012), Color(0xFF0F3B23), Color(0xFF195A36)],
      bgStops: [0.0, 0.55, 1.0],
      ink: Color(0xFF0E3D27),
      darkInk: Color(0xFFD9F5E5),
      accent: Color(0xFF15803D),
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
          height: 168,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _items.length,
            itemBuilder: (ctx, index) => _MarketingCard(item: _items[index]),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _items.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 4,
              width: _currentPage == index ? 20 : 4,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? _items[index].accent
                    : context.stroke,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MarketingCard extends StatelessWidget {
  const _MarketingCard({required this.item});
  final _MarketingItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.isDark ? item.darkBgColors : item.bgColors;
    final ink = context.isDark ? item.darkInk : item.ink;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
            stops: item.bgStops,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Decorative glow circles — lift the card without shadow chrome
            Positioned(
              right: -32,
              top: -32,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.accent.withValues(alpha: 0.18),
                ),
              ),
            ),
            Positioned(
              right: 18,
              bottom: -28,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.accent.withValues(alpha: 0.10),
                ),
              ),
            ),
            // Big icon — graphic anchor on the right
            Positioned(
              right: 20,
              top: 20,
              child: Icon(item.icon,
                  color: item.accent.withValues(alpha: 0.85), size: 38),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.eyebrow,
                    style: TextStyle(
                      color: item.accent,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.8,
                    ),
                  ),
                  Text(
                    item.title,
                    style: TextStyle(
                      color: ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                      height: 1.1,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: ink.withValues(alpha: 0.75),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _CtaPill(label: item.cta, ink: ink),
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
}

class _CtaPill extends StatelessWidget {
  const _CtaPill({required this.label, required this.ink});
  final String label;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    // Pill bg = the card's ink color; foreground = the opposite.
    final fg = context.isDark ? Colors.black : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: ink,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.arrow_forward_rounded, color: fg, size: 13),
        ],
      ),
    );
  }
}

class _FixturesContent extends ConsumerStatefulWidget {
  const _FixturesContent();

  @override
  ConsumerState<_FixturesContent> createState() => _FixturesContentState();
}

enum _FixturesTab { live, upcoming, recent }

class _FixturesContentState extends ConsumerState<_FixturesContent> {
  _FixturesTab _tab = _FixturesTab.live;

  @override
  Widget build(BuildContext context) {
    final matchesState = ref.watch(matchesControllerProvider);
    final relevantMatches = matchesState.matches.where(_visibleOnHome).toList();
    final live = _sorted(
      relevantMatches.where((m) => m.lifecycle == MatchLifecycle.live).toList(),
      ascending: true,
    );
    final upcoming = _sorted(
      relevantMatches.where((m) => m.lifecycle == MatchLifecycle.upcoming).toList(),
      ascending: true,
    );
    final recent = _sorted(
      relevantMatches.where((m) => m.lifecycle == MatchLifecycle.past).toList(),
      ascending: false,
    ).take(3).toList();

    if (matchesState.isLoading && matchesState.matches.isEmpty) {
      return const SliverToBoxAdapter(child: _MatchLoadingScroll());
    }
    if (matchesState.error != null && matchesState.matches.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _FixturesError(message: matchesState.error!),
        ),
      );
    }
    if (live.isEmpty && upcoming.isEmpty && recent.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _EmptyFixtures(isLive: false),
        ),
      );
    }

    // Smart default tab
    var effectiveTab = _tab;
    if (effectiveTab == _FixturesTab.live && live.isEmpty) {
      effectiveTab = upcoming.isNotEmpty ? _FixturesTab.upcoming : _FixturesTab.recent;
    } else if (effectiveTab == _FixturesTab.upcoming && upcoming.isEmpty) {
      effectiveTab = live.isNotEmpty ? _FixturesTab.live : _FixturesTab.recent;
    } else if (effectiveTab == _FixturesTab.recent && recent.isEmpty) {
      effectiveTab = live.isNotEmpty ? _FixturesTab.live : _FixturesTab.upcoming;
    }

    final visible = switch (effectiveTab) {
      _FixturesTab.live     => live,
      _FixturesTab.upcoming => upcoming,
      _FixturesTab.recent   => recent,
    };

    return SliverToBoxAdapter(
      child: RepaintBoundary(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MatchTabPills(
              current: effectiveTab,
              hasLive: live.isNotEmpty,
              hasUpcoming: upcoming.isNotEmpty,
              hasRecent: recent.isNotEmpty,
              onChanged: (t) => setState(() => _tab = t),
            ),
            const SizedBox(height: 12),
            _FixturesCarousel(tab: effectiveTab, matches: visible),
          ],
        ),
      ),
    );
  }

  bool _visibleOnHome(PlayerMatch match) {
    if (match.sectionType == MatchSectionType.tournament &&
        !match.involvesPlayerTeam) {
      return false;
    }
    return true;
  }

  List<PlayerMatch> _sorted(List<PlayerMatch> matches,
      {required bool ascending}) {
    final copy = [...matches];
    copy.sort((a, b) {
      final aTime = a.scheduledAt;
      final bTime = b.scheduledAt;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return ascending ? aTime.compareTo(bTime) : bTime.compareTo(aTime);
    });
    return copy;
  }
}

class _MatchTabPills extends StatelessWidget {
  const _MatchTabPills({
    required this.current,
    required this.hasLive,
    required this.hasUpcoming,
    required this.hasRecent,
    required this.onChanged,
  });

  final _FixturesTab current;
  final bool hasLive;
  final bool hasUpcoming;
  final bool hasRecent;
  final ValueChanged<_FixturesTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (hasLive)
            _Pill(
              icon: Icons.circle,
              label: 'Live',
              selected: current == _FixturesTab.live,
              selectedColor: context.success,
              onTap: () => onChanged(_FixturesTab.live),
              isLive: true,
            ),
          if (hasLive && (hasUpcoming || hasRecent)) const SizedBox(width: 8),
          if (hasUpcoming)
            _Pill(
              icon: Icons.schedule_rounded,
              label: 'Next',
              selected: current == _FixturesTab.upcoming,
              selectedColor: context.accent,
              onTap: () => onChanged(_FixturesTab.upcoming),
            ),
          if (hasUpcoming && hasRecent) const SizedBox(width: 8),
          if (hasRecent)
            _Pill(
              icon: Icons.check_circle_outline_rounded,
              label: 'Done',
              selected: current == _FixturesTab.recent,
              selectedColor: context.accent,
              onTap: () => onChanged(_FixturesTab.recent),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
    this.isLive = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? selectedColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? selectedColor.withValues(alpha: 0.4) : context.stroke,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLive && selected)
              _PulsingLiveDot(color: selectedColor)
            else
              Icon(icon, size: 13, color: selected ? selectedColor : context.fgSub),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: selected ? selectedColor : context.fgSub,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Horizontal carousel of match tiles ───────────────────────────────────────

class _FixturesCarousel extends StatefulWidget {
  const _FixturesCarousel({required this.tab, required this.matches});
  final _FixturesTab tab;
  final List<PlayerMatch> matches;

  @override
  State<_FixturesCarousel> createState() => _FixturesCarouselState();
}

class _FixturesCarouselState extends State<_FixturesCarousel> {
  @override
  Widget build(BuildContext context) {
    if (widget.matches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: _EmptyFixtures(isLive: widget.tab == _FixturesTab.live),
      );
    }
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, right: 8),
        itemCount: widget.matches.length,
        itemBuilder: (ctx, i) => _MatchTile(match: widget.matches[i], tab: widget.tab),
      ),
    );
  }
}

// ── Section eyebrow (LIVE / UPCOMING) — flat hairline header ─────────────────


// ── Match card ────────────────────────────────────────────────────────────────

class _MatchTile extends ConsumerWidget {
  const _MatchTile({required this.match, required this.tab});
  final PlayerMatch match;
  final _FixturesTab tab;

  String _short(String? s, String full) => (s != null && s.isNotEmpty) ? s : full;

  String _scheduleLine() {
    final d = match.scheduledAt;
    if (d == null) return '';
    const mo = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
    return '${mo[d.month - 1]} ${d.day}  ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
  }

  String _countdown(DateTime? date) {
    if (date == null) return 'UPCOMING';
    final diff = date.difference(DateTime.now());
    if (diff.isNegative) return 'STARTING';
    if (diff.inDays > 1) return 'IN ${diff.inDays}D';
    if (diff.inDays == 1) return 'TOMORROW';
    if (diff.inHours > 0) return 'IN ${diff.inHours}H ${diff.inMinutes % 60}M';
    if (diff.inMinutes > 0) return 'IN ${diff.inMinutes}M';
    return 'SOON';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLive = match.lifecycle == MatchLifecycle.live;
    final centerAsync = isLive ? ref.watch(matchCenterProvider(match.id)) : null;
    final center = centerAsync?.valueOrNull;
    final isDark = context.isDark;

    final formatText = match.formatLabel ?? 'T20';
    final compText = match.competitionLabel?.trim().isNotEmpty == true
        ? match.competitionLabel!
        : (match.title.trim().isNotEmpty ? match.title : 'Match');

    final teamA = _short(match.playerTeamShortName, match.playerTeamName);
    final teamB = _short(match.opponentTeamShortName, match.opponentTeamName);
    final scoreA = isLive && center != null ? _resolveTeamA(center) : '';
    final scoreB = isLive && center != null ? _resolveTeamB(center) : '';

    final raw = match.statusLabel.trim();
    final lower = raw.toLowerCase();
    final isJustLive = lower == 'live' || lower == 'match in progress' || lower == 'in progress' || lower == 'in_progress';
    final statusLine = (raw.isNotEmpty && !isJustLive) ? raw : '';
    final isPast = tab == _FixturesTab.recent;
    final bottomLine = isPast
        ? _cleanResultLine(match.scoreSummary ?? statusLine)
        : (statusLine.isNotEmpty ? statusLine : _scheduleLine());

    // Soft gradient from card bg → rank accent tinted — matches theme automatically
    final accent = context.accent;

    // Foreground colors on card
    final fg = context.fg;
    final fgSub = context.fgSub;

    return Container(
      width: 290,
      margin: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () => context.push('/match/${Uri.encodeComponent(match.id)}'),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: Simple & Clean ──────────────────────────
              Row(
                children: [
                  if (tab == _FixturesTab.live)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PulsingLiveDot(color: context.success),
                          const SizedBox(width: 6),
                          Text('LIVE',
                              style: TextStyle(
                                  color: context.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0)),
                        ],
                      ),
                    )
                  else
                    Text(
                      compText.toUpperCase(),
                      style: TextStyle(
                        color: accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  const Spacer(),
                  if (tab == _FixturesTab.upcoming)
                    Text(_countdown(match.scheduledAt),
                        style: TextStyle(
                            color: fgSub.withValues(alpha: 0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.w800))
                  else if (tab == _FixturesTab.recent)
                    _ResultChip(result: match.result),
                ],
              ),

              const Spacer(),

              // ── Teams: Focused ─────────────────────────────────────────────────
              _CardTeamRow(
                logoUrl: match.playerTeamLogoUrl,
                name: teamA,
                score: scoreA,
                showScore: isLive,
                fg: fg,
                fgSub: fgSub,
              ),

              const SizedBox(height: 12),

              _CardTeamRow(
                logoUrl: match.opponentTeamLogoUrl,
                name: teamB,
                score: scoreB,
                showScore: isLive,
                fg: fg,
                fgSub: fgSub,
              ),

              const Spacer(),

              // ── Footer: Minimalist ──────────────────────────────────────────
              if (bottomLine.isNotEmpty)
                Text(
                  bottomLine.toUpperCase(),
                  style: TextStyle(
                      color: fgSub.withValues(alpha: 0.4),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _cleanResultLine(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return '';
    const dup = ' won the match won the match';
    final i = text.toLowerCase().indexOf(dup);
    return i != -1 ? '${text.substring(0, i)} won the match'.trim() : text;
  }

  String _resolveTeamA(MatchCenter c) {
    final pName = match.playerTeamName.toLowerCase().trim();
    if (pName == c.teamAName.toLowerCase().trim() ||
        (match.playerTeamShortName ?? '').toLowerCase().trim() == (c.teamAShortName ?? '').toLowerCase().trim()) {
      return c.teamAScore.isEmpty ? '-' : c.teamAScore;
    }
    return c.teamBScore.isEmpty ? '-' : c.teamBScore;
  }

  String _resolveTeamB(MatchCenter c) {
    final pName = match.playerTeamName.toLowerCase().trim();
    if (pName == c.teamAName.toLowerCase().trim() ||
        (match.playerTeamShortName ?? '').toLowerCase().trim() == (c.teamAShortName ?? '').toLowerCase().trim()) {
      return c.teamBScore.isEmpty ? '-' : c.teamBScore;
    }
    return c.teamAScore.isEmpty ? '-' : c.teamAScore;
  }
}

class _CardTeamRow extends StatelessWidget {
  const _CardTeamRow({
    required this.logoUrl,
    required this.name,
    required this.score,
    required this.showScore,
    required this.fg,
    required this.fgSub,
  });
  final String? logoUrl;
  final String name;
  final String score;
  final bool showScore;
  final Color fg;
  final Color fgSub;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TeamLogo(url: logoUrl, name: name, size: 48),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fg,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        ),
        if (showScore && score.isNotEmpty)
          Text(
            score,
            style: TextStyle(
              color: fg,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
      ],
    );
  }
}

class _ResultChip extends StatelessWidget {
  const _ResultChip({required this.result});
  final MatchResult result;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (result) {
      MatchResult.win => ('WON', context.success),
      MatchResult.loss => ('LOST', context.danger),
      MatchResult.draw => ('DRAW', context.fgSub),
      MatchResult.unknown => ('—', context.fgSub),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _TeamScoreRow extends StatelessWidget {
  const _TeamScoreRow({
    required this.logoUrl,
    required this.shortName,
    required this.score,
    required this.showScore,
  });

  final String? logoUrl;
  final String shortName;
  final String score;
  final bool showScore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TeamLogo(url: logoUrl, name: shortName, size: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            shortName.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.fg,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
        ),
        if (showScore && score.isNotEmpty)
          Text(
            score,
            style: TextStyle(
              color: context.fg,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
      ],
    );
  }
}

class _MatchTeam extends StatelessWidget {
  const _MatchTeam({
    required this.logoUrl,
    required this.shortName,
    required this.alignEnd,
  });

  final String? logoUrl;
  final String shortName;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _TeamLogo(url: logoUrl, name: shortName, size: 72),
        const SizedBox(height: 8),
        SizedBox(
          width: 90,
          child: Text(
            shortName.toUpperCase(),
            textAlign: alignEnd ? TextAlign.right : TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.fg,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardContent extends ConsumerStatefulWidget {
  const _LeaderboardContent();

  @override
  ConsumerState<_LeaderboardContent> createState() =>
      _LeaderboardContentState();
}

class _LeaderboardContentState extends ConsumerState<_LeaderboardContent> {
  void _openLeaderboard() => context.push('/leaderboard');

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return leaderboardAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: SizedBox(height: 132),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            'Could not load leaderboard',
            style: TextStyle(
                color: context.fgSub,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
      data: (data) {
        final entries = data.entries;
        if (entries.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        return SliverToBoxAdapter(
          child: RepaintBoundary(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Row(
                    children: [
                      Text(
                        'Leaderboard',
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _openLeaderboard,
                        child: Row(
                          children: [
                            Text(
                              'See more',
                              style: TextStyle(
                                color: context.fgSub,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.chevron_right_rounded,
                                size: 16, color: context.fgSub),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 132,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: entries.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (ctx, i) {
                      if (i == entries.length) {
                        return _SeeMoreCard(onTap: _openLeaderboard);
                      }
                      return _LeaderCard(entry: entries[i], position: i + 1);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Compact horizontal player card ───────────────────────────────────────────

class _LeaderCard extends StatelessWidget {
  const _LeaderCard({required this.entry, required this.position});
  final LeaderboardEntry entry;
  final int position;

  @override
  Widget build(BuildContext context) {
    final posColor = switch (position) {
      1 => const Color(0xFFE6B400),
      2 => const Color(0xFF8E96A0),
      3 => const Color(0xFFB97A3F),
      _ => context.fgSub,
    };
    return GestureDetector(
      onTap: () => context.push('/player/${entry.playerId}'),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 96,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Avatar with rank badge overlay
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.panel,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: entry.avatarUrl != null
                      ? CachedNetworkImage(
                          imageUrl: entry.avatarUrl!,
                          fit: BoxFit.cover,
                          memCacheWidth: 168, // 56 * 3
                          memCacheHeight: 168,
                          placeholder: (context, url) =>
                              Container(color: context.panel),
                          errorWidget: (context, url, error) => Center(
                            child: Text(
                              entry.name.isNotEmpty
                                  ? entry.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: context.fgSub,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            entry.name.isNotEmpty
                                ? entry.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: context.fgSub,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: posColor,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: context.surf, width: 1.5),
                    ),
                    child: Text(
                      '$position',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.fg,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${entry.impactPoints} IP',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── See more terminal card ──────────────────────────────────────────────────

class _SeeMoreCard extends StatelessWidget {
  const _SeeMoreCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 96,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: context.isDark
                      ? const [Color(0xFF3A2D0A), Color(0xFF6B4F12)]
                      : const [Color(0xFFFFF1D6), Color(0xFFFFD980)],
                ),
              ),
              child: Icon(Icons.arrow_forward_rounded,
                  size: 22,
                  color: context.isDark
                      ? const Color(0xFFFFD980)
                      : const Color(0xFFB07A1A)),
            ),
            const SizedBox(height: 14),
            Text(
              'See more',
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.fg,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Full ranks',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
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
                  color: context.panel,
                ),
                clipBehavior: Clip.antiAlias,
                child: entry.avatarUrl != null
                    ? CachedNetworkImage(
                        imageUrl: entry.avatarUrl!,
                        fit: BoxFit.cover,
                        memCacheWidth: 108, // 36 * 3
                        memCacheHeight: 108,
                        placeholder: (context, url) =>
                            Container(color: context.panel),
                        errorWidget: (context, url, error) => Center(
                          child: Text(
                            entry.name.isNotEmpty
                                ? entry.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: context.accent,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          entry.name.isNotEmpty
                              ? entry.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: context.accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // ── Name ──
              Expanded(
                child: Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: context.fg,
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
              _PulsingLiveDot(
                  color: selected
                      ? Theme.of(context).colorScheme.onPrimary
                      : context.success),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Theme.of(context).colorScheme.onPrimary
                    : context.fgSub,
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
                      ? Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: 0.6)
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
    final hasLogo = url != null && url!.isNotEmpty;

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: context.panel.withValues(alpha: 0.1),
      backgroundImage: hasLogo ? CachedNetworkImageProvider(url!) : null,
      child: !hasLogo ? _fallback(context) : null,
    );
  }

  Widget _fallback(BuildContext context) {
    final ch = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Text(
      ch,
      style: TextStyle(
        color: context.accent.withValues(alpha: 0.5),
        fontSize: size * 0.45,
        fontWeight: FontWeight.w900,
      ),
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
            colorA.withValues(alpha: 0.16),
            colorB.withValues(alpha: 0.10),
            context.cardBg,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
        border: Border.all(
          color:
              isLive ? context.accent.withValues(alpha: 0.55) : context.stroke,
          width: isLive ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.fg.withValues(alpha: 0.05),
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _PulsingLiveDot(color: context.success),
                            const SizedBox(width: 6),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: context.success,
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
                              size: 84,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _teamLabel(match.playerTeamShortName,
                                      match.playerTeamName)
                                  .toUpperCase(),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.fg,
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
                                    style: TextStyle(
                                      color: context.fg,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "CRR: ${center.currentRunRate ?? '0.0'}",
                                    style: TextStyle(
                                      color:
                                          context.accent.withValues(alpha: 0.8),
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
                                  color: context.fg.withValues(alpha: 0.04),
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
                              size: 84,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _teamLabel(match.opponentTeamShortName,
                                      match.opponentTeamName)
                                  .toUpperCase(),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.fg,
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
                                  size: 11,
                                  color: context.fgSub.withValues(alpha: 0.7)),
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
                        onTap: () => context
                            .push('/match/${Uri.encodeComponent(match.id)}'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: context.ctaBg,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: context.ctaBg.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'OPEN',
                                style: TextStyle(
                                  color: context.ctaFg,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: context.ctaFg,
                                size: 12,
                              ),
                            ],
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
                                colors: [
                                  context.accent,
                                  context.accent.withValues(alpha: 0.4)
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.cardBg,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: CachedNetworkImage(
                                imageUrl: hero.userAvatarUrl,
                                fit: BoxFit.cover,
                                memCacheWidth: 186, // 62 * 3
                                memCacheHeight: 186,
                                placeholder: (context, url) =>
                                    Container(color: context.panel),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.person, color: context.fgSub),
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
                              child: Icon(Icons.bolt_rounded,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  size: 14),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: context.fg.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.stroke),
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
      error: (_, __) => const SizedBox.shrink(),
      data: (entries) {
        if (entries.isEmpty) return const SizedBox.shrink();
        final visible = entries.take(8).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Text(
                    'People you may know',
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push('/recommended-connections'),
                    child: Row(
                      children: [
                        Text(
                          'See all',
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.chevron_right_rounded,
                            size: 16, color: context.fgSub),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 196,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: visible.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (ctx, i) =>
                    _RecommendationCard(entry: visible[i], seedIndex: i),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecommendationCard extends ConsumerStatefulWidget {
  const _RecommendationCard({required this.entry, required this.seedIndex});
  final LeaderboardEntry entry;
  final int seedIndex;

  @override
  ConsumerState<_RecommendationCard> createState() =>
      _RecommendationCardState();
}

class _RecommendationCardState extends ConsumerState<_RecommendationCard> {
  bool _isFollowing = false;
  bool _loading = false;

  // Soft pastel banners (light) + paired dark variants for dark theme.
  static const _bannersLight = <(Color, Color)>[
    (Color(0xFFE8EFFF), Color(0xFFC0CDFF)), // periwinkle
    (Color(0xFFFFE8D6), Color(0xFFFFB89C)), // peach
    (Color(0xFFEFEAFD), Color(0xFFC8B6F4)), // lavender
    (Color(0xFFE8FBEF), Color(0xFFA9E1C0)), // mint
    (Color(0xFFFFEDF7), Color(0xFFFFB8D6)), // rose
    (Color(0xFFFFF6D9), Color(0xFFFFD980)), // butter
  ];
  static const _bannersDark = <(Color, Color)>[
    (Color(0xFF1B2240), Color(0xFF2C3868)), // deep periwinkle
    (Color(0xFF3A1F18), Color(0xFF5C3326)), // deep peach
    (Color(0xFF1F1738), Color(0xFF3A2D63)), // deep lavender
    (Color(0xFF112B1E), Color(0xFF1F4030)), // deep mint
    (Color(0xFF36172A), Color(0xFF5A2942)), // deep rose
    (Color(0xFF362B0C), Color(0xFF5A4A19)), // deep butter
  ];

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final banners = context.isDark ? _bannersDark : _bannersLight;
    final banner = banners[widget.seedIndex % banners.length];

    return GestureDetector(
      onTap: () => context.push('/player/${entry.playerId}'),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 144,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Banner with overlapping avatar ─────────────────────────
            SizedBox(
              height: 86,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [banner.$1, banner.$2],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.surf,
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: context.panel,
                          child: ClipOval(
                            child: entry.avatarUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: entry.avatarUrl!,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    memCacheWidth: 168,
                                    memCacheHeight: 168,
                                    placeholder: (context, url) =>
                                        Container(color: context.panel),
                                    errorWidget: (context, url, error) =>
                                        Center(
                                      child: Text(
                                        entry.name.isNotEmpty
                                            ? entry.name[0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          color: context.fgSub,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      entry.name.isNotEmpty
                                          ? entry.name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: context.fgSub,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // ── Name ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                entry.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 2),
            // ── Meta: rank · IP ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                _meta(entry),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            const Spacer(),
            // ── Follow button ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
              child: SizedBox(
                width: double.infinity,
                height: 30,
                child: ElevatedButton(
                  onPressed: _loading ? null : _toggleFollow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isFollowing ? Colors.transparent : context.ctaBg,
                    foregroundColor: _isFollowing ? context.fg : context.ctaFg,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    side: _isFollowing
                        ? BorderSide(color: context.stroke)
                        : BorderSide.none,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999)),
                  ),
                  child: _loading
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _isFollowing ? context.fg : context.ctaFg))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isFollowing
                                  ? Icons.check_rounded
                                  : Icons.add_rounded,
                              size: 14,
                              color: _isFollowing ? context.fg : context.ctaFg,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isFollowing ? 'Following' : 'Follow',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.1,
                                color:
                                    _isFollowing ? context.fg : context.ctaFg,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _meta(LeaderboardEntry entry) {
    final parts = <String>[];
    if (entry.rank.isNotEmpty) parts.add(entry.rankLabel);
    parts.add('${entry.impactPoints} IP');
    return parts.join(' · ');
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

// ── Quick Links — minimal flat row below top bar ─────────────────────────────

class _QuickLinks extends StatelessWidget {
  const _QuickLinks();

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String)>[
      (Icons.add_circle_outline_rounded, 'Create match', '/create-match'),
      (Icons.place_outlined, 'Book facility', '/booking'),
      (Icons.storefront_outlined, 'Visit store', '/store'),
    ];

    return Container(
      color: context.surf,
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  Expanded(
                    child: _QuickLinkCell(
                      icon: items[i].$1,
                      label: items[i].$2,
                      onTap: () => context.push(items[i].$3),
                    ),
                  ),
                  if (i < items.length - 1)
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: context.stroke,
                      indent: 14,
                      endIndent: 14,
                    ),
                ],
              ],
            ),
          ),
          Container(height: 1, color: context.stroke),
        ],
      ),
    );
  }
}

class _QuickLinkCell extends StatelessWidget {
  const _QuickLinkCell({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: context.fg),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: context.fg,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

