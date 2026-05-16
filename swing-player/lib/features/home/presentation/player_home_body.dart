import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../matches/controller/matches_controller.dart';
import '../../matches/domain/match_models.dart';
import '../../profile/controller/profile_controller.dart';
import '../controller/leaderboard_controller.dart';
import '../domain/leaderboard_models.dart';

// ── Brand palette ─────────────────────────────────────────────────────────────
const _clive     = Color(0xFFFF2D55); // hot red  — live
const _cupcoming = Color(0xFF5E5CE6); // electric indigo — upcoming
const _crecent   = Color(0xFFFF9F0A); // electric amber  — recent
const _cleader   = Color(0xFFBF5AF2); // electric purple — leaderboard
const _cfriends  = Color(0xFF00C7BE); // teal — friends
const _ctourneys = Color(0xFFFF375F); // hot pink — tournaments

// ─────────────────────────────────────────────────────────────────────────────

class PlayerHomeBody extends ConsumerStatefulWidget {
  const PlayerHomeBody({super.key, this.onFindMatch, this.onBook, this.onStore});
  final VoidCallback? onFindMatch;
  final VoidCallback? onBook;
  final VoidCallback? onStore;

  @override
  ConsumerState<PlayerHomeBody> createState() => _PlayerHomeBodyState();
}

class _PlayerHomeBodyState extends ConsumerState<PlayerHomeBody> {
  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final matchState   = ref.watch(matchesControllerProvider);

    final profile    = profileState.data;
    final ip         = profile?.rankProgress.impactPoints ?? 0;
    final rankLabel  = profile?.rankProgress.label ?? '';

    final visible = matchState.matches.where((m) {
      if (m.sectionType == MatchSectionType.tournament && !m.involvesPlayerTeam) {
        return false;
      }
      return true;
    }).toList();

    final liveMatches     = visible.where((m) => m.lifecycle == MatchLifecycle.live).toList();
    final upcomingMatches = visible.where((m) => m.lifecycle == MatchLifecycle.upcoming).toList();
    final recentMatches   = visible.where((m) => m.lifecycle == MatchLifecycle.past).take(5).toList();

    return RefreshIndicator(
      color: _cupcoming,
      onRefresh: () async {
        ref.read(profileControllerProvider.notifier).refresh();
        await ref.read(matchesControllerProvider.notifier).refresh();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Hero ──
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: _HeroStat(
                    ip: ip,
                    rankLabel: rankLabel,
                    isLoading: profileState.isLoading && profile == null,
                  ),
                ),
                Divider(height: 1, thickness: 0.5, color: context.stroke.withValues(alpha: 0.5)),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Matches ──
          SliverToBoxAdapter(
            child: _MatchSection(
              liveMatches: liveMatches,
              upcomingMatches: upcomingMatches,
              recentMatches: recentMatches,
              isLoading: matchState.isLoading && matchState.matches.isEmpty,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // ── Leaderboard preview ──
          const SliverToBoxAdapter(child: _LeaderboardSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // ── Discover ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('Discover'),
                  const SizedBox(height: 4),
                  _ActionRow(
                    icon: Icons.emoji_events_rounded,
                    color: _cleader,
                    title: 'Leaderboard',
                    subtitle: 'See where you rank',
                    onTap: () => context.push('/leaderboard'),
                  ),
                  _RowDivider(),
                  _ActionRow(
                    icon: Icons.group_add_rounded,
                    color: _cfriends,
                    title: 'Find Friends',
                    subtitle: 'People you may know',
                    onTap: () => context.push('/recommended-connections'),
                  ),
                  _RowDivider(),
                  _ActionRow(
                    icon: Icons.military_tech_rounded,
                    color: _ctourneys,
                    title: 'Tournaments',
                    subtitle: 'Compete in leagues',
                    onTap: () => context.push('/create-tournament'),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 64)),
        ],
      ),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────────

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.ip,
    required this.rankLabel,
    required this.isLoading,
  });
  final int ip;
  final String rankLabel;
  final bool isLoading;

  String _fmt(int v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : '$v';

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final ink    = isDark ? Colors.white : Colors.black;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Left column: label + number + rank ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      'IP',
                      style: TextStyle(
                        color: ink.withValues(alpha: 0.35),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isLoading)
                      Container(
                        width: 64,
                        height: 18,
                        decoration: BoxDecoration(
                          color: ink.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      )
                    else if (rankLabel.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: ink.withValues(alpha: isDark ? 0.08 : 0.06),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          rankLabel,
                          style: TextStyle(
                            color: ink.withValues(alpha: 0.75),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                if (isLoading)
                  Container(
                    width: 100,
                    height: 60,
                    decoration: BoxDecoration(
                      color: ink.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  )
                else
                  Text(
                    _fmt(ip),
                    style: TextStyle(
                      color: ink,
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -3.0,
                      height: 1.0,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),
          const _BannerCarousel(),
        ],
      ),
    );
  }
}

// ── Ad banner carousel ────────────────────────────────────────────────────────

class _BannerData {
  const _BannerData({
    required this.colors,
    required this.headline,
    required this.sub,
    required this.cta,
    required this.icon,
  });
  final List<Color> colors;
  final String headline;
  final String sub;
  final String cta;
  final IconData icon;
}

const _kBanners = [
  _BannerData(
    colors: [Color(0xFFFF6B35), Color(0xFFFF2D55)],
    headline: 'Cricket\nGear',
    sub: 'Up to 40% off',
    cta: 'Shop Now →',
    icon: Icons.sports_cricket,
  ),
  _BannerData(
    colors: [Color(0xFF5E5CE6), Color(0xFF3A38C8)],
    headline: 'Join an\nAcademy',
    sub: 'Train with pros',
    cta: 'Enroll →',
    icon: Icons.school_rounded,
  ),
  _BannerData(
    colors: [Color(0xFF00C7BE), Color(0xFF008F88)],
    headline: 'City\nTournament',
    sub: 'Registrations open',
    cta: 'Register →',
    icon: Icons.emoji_events_rounded,
  ),
  _BannerData(
    colors: [Color(0xFFBF5AF2), Color(0xFF8944C8)],
    headline: 'Swing\nPremium',
    sub: 'Unlock all features',
    cta: 'Upgrade →',
    icon: Icons.star_rounded,
  ),
];

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel();

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final _controller = PageController();
  int _page = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_page + 1) % _kBanners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (p) => setState(() => _page = p),
              itemCount: _kBanners.length,
              itemBuilder: (_, i) => _BannerCard(data: _kBanners[i]),
            ),
          ),
          // Dot indicators
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_kBanners.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: _page == i ? 14 : 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: _page == i ? 0.95 : 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.data});
  final _BannerData data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: data.colors,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(data.icon, size: 80, color: Colors.white.withValues(alpha: 0.12)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'AD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.headline,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.sub,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.cta,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
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
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.fg,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    );
  }
}

// ── Quick tile (Play section 3-up grid) ───────────────────────────────────────

// ── Discover action row ───────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: context.fgSub.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, indent: 60, color: context.stroke.withValues(alpha: 0.5));
  }
}

// ── Match section ─────────────────────────────────────────────────────────────

enum _MatchTab { live, recent, upcoming }

class _MatchSection extends StatefulWidget {
  const _MatchSection({
    required this.liveMatches,
    required this.upcomingMatches,
    required this.recentMatches,
    required this.isLoading,
  });
  final List<PlayerMatch> liveMatches;
  final List<PlayerMatch> upcomingMatches;
  final List<PlayerMatch> recentMatches;
  final bool isLoading;

  @override
  State<_MatchSection> createState() => _MatchSectionState();
}

class _MatchSectionState extends State<_MatchSection> {
  late _MatchTab _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.liveMatches.isNotEmpty ? _MatchTab.live : _MatchTab.recent;
  }

  @override
  void didUpdateWidget(_MatchSection old) {
    super.didUpdateWidget(old);
    if (_tab == _MatchTab.live && widget.liveMatches.isEmpty) {
      _tab = _MatchTab.recent;
    }
  }

  List<PlayerMatch> get _current {
    switch (_tab) {
      case _MatchTab.live:     return widget.liveMatches;
      case _MatchTab.upcoming: return widget.upcomingMatches;
      case _MatchTab.recent:   return widget.recentMatches;
    }
  }

  Color get _tabColor {
    switch (_tab) {
      case _MatchTab.live:     return _clive;
      case _MatchTab.upcoming: return _cupcoming;
      case _MatchTab.recent:   return _crecent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAny = widget.liveMatches.isNotEmpty ||
        widget.upcomingMatches.isNotEmpty ||
        widget.recentMatches.isNotEmpty;

    if (widget.isLoading) {
      return SizedBox(
        height: 240,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 2,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) {
            final isDark = context.isDark;
            final ink = isDark ? Colors.white : Colors.black;
            return Container(
              width: MediaQuery.of(context).size.width - 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [Colors.white.withValues(alpha: 0.09), Colors.white.withValues(alpha: 0.03)]
                      : [Colors.white, const Color(0xFFF0F4FF)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ink.withValues(alpha: isDark ? 0.08 : 0.06), width: 1),
              ),
            );
          },
        ),
      );
    }

    if (!hasAny) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Tabs — only show non-empty sections ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              if (widget.liveMatches.isNotEmpty) ...[
                _Tab(
                  label: 'Live',
                  color: const Color(0xFFC0392B),
                  active: _tab == _MatchTab.live,
                  onTap: () => setState(() => _tab = _MatchTab.live),
                  showLiveDot: true,
                ),
                const SizedBox(width: 20),
              ],
              if (widget.recentMatches.isNotEmpty) ...[
                _Tab(
                  label: 'Recent',
                  color: const Color(0xFF334155),
                  active: _tab == _MatchTab.recent,
                  onTap: () => setState(() => _tab = _MatchTab.recent),
                ),
                const SizedBox(width: 20),
              ],
              if (widget.upcomingMatches.isNotEmpty)
                _Tab(
                  label: 'Soon',
                  color: const Color(0xFF5BA4F5),
                  active: _tab == _MatchTab.upcoming,
                  onTap: () => setState(() => _tab = _MatchTab.upcoming),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Carousel ──
        if (_current.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: _tabColor.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'No matches here',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final isSingleLive = _tab == _MatchTab.live && _current.length == 1;
              final cardW = isSingleLive
                  ? constraints.maxWidth - 40
                  : (constraints.maxWidth - 120).clamp(200.0, 260.0);
              return SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const PageScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _current.length,
                  itemBuilder: (_, i) => Padding(
                    padding: EdgeInsets.only(right: i < _current.length - 1 ? 12 : 0),
                    child: _MatchCard(match: _current[i], width: cardW),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
    this.showLiveDot = false,
  });
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;
  final bool showLiveDot;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showLiveDot) ...[_BlinkDot(), const SizedBox(width: 5)],
              Text(
                label,
                style: TextStyle(
                  color: active ? color : (context.isDark ? Colors.white.withValues(alpha: 0.45) : context.fgSub.withValues(alpha: 0.45)),
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 2,
            width: active ? 20 : 0,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _BlinkDot extends StatefulWidget {
  const _BlinkDot();

  @override
  State<_BlinkDot> createState() => _BlinkDotState();
}

class _BlinkDotState extends State<_BlinkDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final ink = isDark ? Colors.white : Colors.black;
    return FadeTransition(
      opacity: Tween(begin: 0.25, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: ink,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ── Match card ────────────────────────────────────────────────────────────────

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match, this.width = 272});
  final PlayerMatch match;
  final double width;

  /// Returns the score string for a given team from parsed innings rows, or null.
  String? _findScore(List<(String, String)> rows, String? teamName, String? shortName) {
    for (final row in rows) {
      final lower = row.$1.toLowerCase();
      if (teamName != null && lower.contains(teamName.toLowerCase().split(' ').first)) {
        return row.$2.isEmpty ? null : row.$2;
      }
      if (shortName != null && lower.contains(shortName.toLowerCase())) {
        return row.$2.isEmpty ? null : row.$2;
      }
    }
    return null;
  }

  /// Splits scoreSummary into innings rows (teamName, score) + optional result line.
  /// Format per line: "Team Name  runs/wkts (overs ov)"  — 2+ spaces as separator.
  (List<(String, String)>, String?) _parseScore(String? summary) {
    if (summary == null || summary.trim().isEmpty) return ([], null);
    final lines = summary.trim().split('\n');
    final rows = <(String, String)>[];
    String? resultLine;
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (lower.contains(' won') || lower.contains('draw') ||
          lower.contains('tied') || lower.contains('abandoned') ||
          lower.contains('need') || lower.contains('require')) {
        resultLine = line.trim();
        continue;
      }
      final parts = line.trim().split(RegExp(r'\s{2,}'));
      if (parts.length >= 2) {
        rows.add((parts[0].trim(), parts[1].trim()));
      } else if (parts.length == 1 && parts[0].isNotEmpty) {
        rows.add((parts[0].trim(), ''));
      }
    }
    return (rows, resultLine);
  }


  @override
  Widget build(BuildContext context) {
    final isLive     = match.lifecycle == MatchLifecycle.live;
    final isUpcoming = match.lifecycle == MatchLifecycle.upcoming;

    final cardBg = isLive
        ? const Color(0xFFC0392B)
        : isUpcoming
            ? const Color(0xFF5BA4F5)
            : const Color(0xFF334155);

    const cardFg    = Colors.white;
    const cardFgSub = Color(0xCCFFFFFF);

    final badgeColor = isLive ? _clive : isUpcoming ? _cupcoming : _crecent;
    final badgeLabel = isLive ? 'Live' : isUpcoming ? 'Upcoming' : 'Completed';

    const resultColor = Colors.white;

    final parsed      = _parseScore(match.scoreSummary);
    final inningsRows = parsed.$1;
    final rawResult   = (parsed.$2?.isNotEmpty == true ? parsed.$2 : null) ??
        (match.statusLabel.toLowerCase() == badgeLabel.toLowerCase() ? null : match.statusLabel);
    final resultLine  = rawResult ?? '';

    final formatLabel = match.formatLabel ?? '';
    final venueDate   = [
      if (match.venueLabel?.isNotEmpty == true) match.venueLabel!,
      if (match.scheduledAt != null) DateFormat('d MMM').format(match.scheduledAt!),
    ].join(' · ');

    // notchY: top-padding(14) + badge-row(28) + gap(6) + venue-text(14) + gap(10)
    // drops to 52 when no venueDate; kept at a single value for the common case
    final notchY = venueDate.isNotEmpty ? 73.0 : 55.0;

    return GestureDetector(
      onTap: () => context.push('/match/${match.id}'),
      child: ClipPath(
        clipper: _TicketClipper(notchY: notchY),
        child: Container(
          width: width,
          color: cardBg,
          child: Stack(
            children: [
              // ── diagonal texture lines ──
              Positioned.fill(
                child: CustomPaint(painter: _CardLinesPainter()),
              ),
              // ── low-opacity background cricket icon ──
              Positioned(
                right: -14,
                bottom: 6,
                child: Transform.rotate(
                  angle: -0.25,
                  child: Icon(
                    Icons.sports_cricket,
                    size: 115,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              // ── card content ──
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row 1: badge · format · arrow
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLive) ...[const _BlinkDot(), const SizedBox(width: 5)],
                              Text(badgeLabel, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                        if (formatLabel.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(formatLabel, style: const TextStyle(color: cardFgSub, fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                        const Spacer(),
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.55),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.north_east_rounded, size: 13, color: cardFgSub),
                        ),
                      ],
                    ),

                    // Row 2: venue · date
                    if (venueDate.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(venueDate, style: const TextStyle(color: cardFgSub, fontSize: 11, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 10),

                    // ── ticket perforation line ──
                    _DashedLine(color: cardFg.withValues(alpha: 0.22)),

                    const SizedBox(height: 14),

                    // Teams
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _TeamCol(
                            url: match.playerTeamLogoUrl,
                            name: match.playerTeamShortName ?? match.playerTeamName,
                            score: _findScore(inningsRows, match.playerTeamName, match.playerTeamShortName),
                            yetToBat: isLive && inningsRows.isNotEmpty && _findScore(inningsRows, match.playerTeamName, match.playerTeamShortName) == null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 18, left: 6, right: 6),
                          child: Text('vs', style: TextStyle(color: cardFgSub, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                        Expanded(
                          child: _TeamCol(
                            url: match.opponentTeamLogoUrl,
                            name: match.opponentTeamShortName ?? match.opponentTeamName,
                            score: _findScore(inningsRows, match.opponentTeamName, match.opponentTeamShortName),
                            alignRight: true,
                            yetToBat: isLive && inningsRows.isNotEmpty && _findScore(inningsRows, match.opponentTeamName, match.opponentTeamShortName) == null,
                          ),
                        ),
                      ],
                    ),

                    // Bottom divider + info
                    const SizedBox(height: 10),
                    _DashedLine(color: cardFg.withValues(alpha: 0.15)),
                    Builder(builder: (_) {
                      String? infoText;
                      Color infoColor = cardFgSub;

                      if (isLive && inningsRows.length <= 1) {
                        infoText = match.tossWinner;
                      } else if (isLive && inningsRows.length >= 2 && resultLine.isNotEmpty) {
                        infoText = resultLine;
                      } else if (!isLive && !isUpcoming && resultLine.isNotEmpty) {
                        infoText = resultLine;
                        infoColor = resultColor;
                      }

                      if (infoText == null || infoText.isEmpty) return const SizedBox(height: 8);
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(infoText, style: TextStyle(color: infoColor, fontSize: 11, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper({required this.notchY, this.notchRadius = 11.0, this.cornerRadius = 22.0});
  final double notchY;
  final double notchRadius;
  final double cornerRadius;

  @override
  Path getClip(Size size) {
    final r  = cornerRadius;
    final nr = notchRadius;
    final ny = notchY;
    final w  = size.width;
    final h  = size.height;

    return Path()
      ..moveTo(r, 0)
      ..lineTo(w - r, 0)
      ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
      // right side → notch (arc curves INTO card = counterclockwise)
      ..lineTo(w, ny - nr)
      ..arcToPoint(Offset(w, ny + nr), radius: Radius.circular(nr), clockwise: false)
      ..lineTo(w, h - r)
      ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r))
      ..lineTo(r, h)
      ..arcToPoint(Offset(0, h - r), radius: Radius.circular(r))
      // left side ↑ → notch (arc curves INTO card = clockwise going upward)
      ..lineTo(0, ny + nr)
      ..arcToPoint(Offset(0, ny - nr), radius: Radius.circular(nr), clockwise: true)
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
      ..close();
  }

  @override
  bool shouldReclip(_TicketClipper old) =>
      old.notchY != notchY || old.notchRadius != notchRadius;
}

class _DashedLine extends StatelessWidget {
  const _DashedLine({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: CustomPaint(painter: _DashPainter(color: color)),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    double x = 0;
    const dashW = 5.0;
    const gap   = 4.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0.5), Offset((x + dashW).clamp(0, size.width), 0.5), paint);
      x += dashW + gap;
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

class _CardLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    const lineSpacing = 13.0;
    const dotW = 3.0;
    const dotGap = 5.0;
    double y = lineSpacing;
    while (y < size.height) {
      double x = 0;
      while (x < size.width) {
        final end = (x + dotW).clamp(0.0, size.width);
        canvas.drawLine(Offset(x, y), Offset(end, y), paint);
        x += dotW + dotGap;
      }
      y += lineSpacing;
    }
  }

  @override
  bool shouldRepaint(_CardLinesPainter _) => false;
}

class _TeamCol extends StatelessWidget {
  const _TeamCol({required this.url, required this.name, this.score, this.alignRight = false, this.yetToBat = false});
  final String? url;
  final String name;
  final String? score;
  final bool alignRight;
  final bool yetToBat;

  @override
  Widget build(BuildContext context) {
    final cross = alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final align = alignRight ? TextAlign.right : TextAlign.left;
    return Column(
      crossAxisAlignment: cross,
      children: [
        _TeamLogo(url: url, name: name, size: 38),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 11, fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: align,
        ),
        const SizedBox(height: 3),
        if (score != null && score!.isNotEmpty)
          Text(
            score!,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: -0.3),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: align,
          )
        else if (yetToBat)
          Text(
            'yet to bat',
            style: const TextStyle(color: Color(0xAAFFFFFF), fontSize: 10, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
            textAlign: align,
          ),
      ],
    );
  }
}

class _TeamLogo extends StatelessWidget {
  const _TeamLogo({required this.url, required this.name, this.size = 34});
  final String? url;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final ink    = isDark ? Colors.white : Colors.black;

    if (url != null && url!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: url!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _fallback(ink),
          errorWidget: (_, __, ___) => _fallback(ink),
        ),
      );
    }
    return _fallback(ink);
  }

  Widget _fallback(Color ink) {
    final initials = name.trim().isEmpty ? '?' : name.trim().substring(0, name.trim().length.clamp(0, 2)).toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: ink.withValues(alpha: 0.06), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(initials, style: TextStyle(color: ink.withValues(alpha: 0.45), fontSize: size * 0.32, fontWeight: FontWeight.w800)),
    );
  }
}

// ── Leaderboard preview section ───────────────────────────────────────────────

class _LeaderboardSection extends ConsumerWidget {
  const _LeaderboardSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(leaderboardProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const _SectionLabel('Leaderboard'),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/leaderboard'),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View more',
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(height: 2, width: 20, color: const Color(0xFF334155)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        async.when(
          loading: () => _LeaderboardShimmer(),
          error: (_, __) => const SizedBox.shrink(),
          data: (data) {
            if (data.entries.isEmpty) return const SizedBox.shrink();
            final top = data.entries.take(10).toList();
            return SizedBox(
              height: 154,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: top.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => _LeaderboardCard(entry: top[i], position: i + 1),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  const _LeaderboardCard({required this.entry, required this.position});
  final LeaderboardEntry entry;
  final int position;

  Color get _medalColor {
    if (position == 1) return const Color(0xFFFFD700);
    if (position == 2) return const Color(0xFFB8C4CC);
    if (position == 3) return const Color(0xFFCD8C52);
    return _cleader;
  }

  // Darkens any medal colour that's too light to read on a light panel background.
  Color get _readableMedalColor {
    final c = _medalColor;
    if (c.computeLuminance() > 0.30) {
      final hsl = HSLColor.fromColor(c);
      return hsl.withLightness((hsl.lightness - 0.28).clamp(0.0, 1.0)).toColor();
    }
    return c;
  }

  String _fmtIp(int v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : '$v';

  @override
  Widget build(BuildContext context) {
    // notchY = top-padding(12) + badge-height(16) + gap(4) = 32
    return GestureDetector(
      onTap: () => context.push('/player/${entry.playerId}'),
      child: ClipPath(
        clipper: const _TicketClipper(notchY: 32, notchRadius: 7, cornerRadius: 18),
        child: Container(
          width: 98,
          color: context.panel,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // position badge
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _readableMedalColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#$position',
                      style: TextStyle(color: _readableMedalColor, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // ticket perforation
                _DashedLine(color: context.stroke),
                const SizedBox(height: 7),
                // avatar
                _LeaderboardAvatar(url: entry.avatarUrl, name: entry.name, size: 42),
                const SizedBox(height: 6),
                // name
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: context.fg, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                // IP
                Text(
                  _fmtIp(entry.impactPoints),
                  style: TextStyle(color: _readableMedalColor, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                ),
                // rank
                Text(
                  entry.rankLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: context.fgSub, fontSize: 9, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaderboardAvatar extends StatelessWidget {
  const _LeaderboardAvatar({required this.url, required this.name, required this.size});
  final String? url;
  final String name;
  final double size;

  // Deterministic gradient palette — picked by name hash, never changes for a player
  static const _palettes = [
    [Color(0xFF667EEA), Color(0xFF764BA2)],
    [Color(0xFFF093FB), Color(0xFFF5576C)],
    [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    [Color(0xFF43E97B), Color(0xFF38F9D7)],
    [Color(0xFFFA709A), Color(0xFFFEE140)],
    [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
    [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
    [Color(0xFF96FBC4), Color(0xFFF9F586)],
  ];

  List<Color> get _gradient => _palettes[name.hashCode.abs() % _palettes.length];

  String get _initials {
    final words = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: url!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 200),
          placeholder: (_, __) => _gradientCircle(),
          errorWidget: (_, __, ___) => _gradientCircle(),
        ),
      );
    }
    return _gradientCircle();
  }

  Widget _gradientCircle() => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _gradient,
      ),
    ),
    alignment: Alignment.center,
    child: Text(
      _initials,
      style: TextStyle(color: Colors.white, fontSize: size * 0.34, fontWeight: FontWeight.w800),
    ),
  );
}

class _LeaderboardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 154,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, __) => Container(
          width: 98,
          decoration: BoxDecoration(
            color: context.panel,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
