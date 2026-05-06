import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/matches_controller.dart';
import '../domain/match_models.dart';

// ── Matches Tab ───────────────────────────────────────────────────────────────

class MatchesTab extends ConsumerStatefulWidget {
  const MatchesTab({super.key});

  @override
  ConsumerState<MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends ConsumerState<MatchesTab>
    with SingleTickerProviderStateMixin {
  static const _filters = [
    MatchTimelineFilter.all,
    MatchTimelineFilter.live,
    MatchTimelineFilter.upcoming,
    MatchTimelineFilter.past,
    MatchTimelineFilter.hosting,
  ];

  late final TabController _tabController;
  int _selectedFilter = 0;
  String _searchQuery = '';
  bool _searchOpen = false;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchesState = ref.watch(matchesControllerProvider);
    final all = matchesState.matches;
    final past = all.where((m) => m.lifecycle == MatchLifecycle.past).toList();
    final wins = past.where((m) => m.result == MatchResult.win).length;
    final losses = past.where((m) => m.result == MatchResult.loss).length;
    final live = all.where((m) => m.lifecycle == MatchLifecycle.live).length;

    final individualCount = all
        .where((m) => m.sectionType == MatchSectionType.individual)
        .length;
    final tournamentCount = all
        .where((m) =>
            m.sectionType == MatchSectionType.tournament &&
            m.involvesPlayerTeam)
        .length;

    final statLine = all.isEmpty
        ? null
        : [
            '${all.length} matches',
            '$wins won',
            '$losses lost',
          ].join('  ·  ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ───────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.stroke)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row — swaps to search when _searchOpen
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 160),
                crossFadeState: _searchOpen
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Row(
                  children: [
                    if (statLine != null)
                      Expanded(
                        child: Text(
                          statLine,
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                    // Search icon
                    GestureDetector(
                      onTap: () => setState(() => _searchOpen = true),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.search_rounded,
                            color: context.fgSub, size: 22),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _CreateMatchButton(
                      onTap: () => context.push('/create-match'),
                    ),
                  ],
                ),
                secondChild: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: TextStyle(
                      color: context.fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Team or venue…',
                    hintStyle:
                        TextStyle(color: context.fgSub, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: context.fgSub, size: 18),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() {
                          _searchQuery = '';
                          _searchOpen = false;
                        });
                      },
                      child: Icon(Icons.close_rounded,
                          color: context.fgSub, size: 18),
                    ),
                    filled: true,
                    fillColor: context.cardBg,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Filter chips with counts
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final selected = i == _selectedFilter;
                    final f = _filters[i];
                    return _FilterChip(
                      label: _filterLabel(f, all),
                      isLive: f == MatchTimelineFilter.live,
                      selected: selected,
                      onTap: () => setState(() => _selectedFilter = i),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Individual / Tournament toggle
              _SegmentedTabs(
                controller: _tabController,
                individualCount: individualCount,
                tournamentCount: tournamentCount,
              ),
            ],
          ),
        ),

        // ── Match lists ───────────────────────────────────────────────────
        Expanded(
          child: Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: [
                  _MatchesList(
                    sectionType: MatchSectionType.individual,
                    filter: _filters[_selectedFilter],
                    searchQuery: _searchQuery,
                  ),
                  _MatchesList(
                    sectionType: MatchSectionType.tournament,
                    filter: _filters[_selectedFilter],
                    searchQuery: _searchQuery,
                  ),
                ],
              ),
              // Gradient fade over the bottom of the list
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 200,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          context.bg.withValues(alpha: 0),
                          context.bg.withValues(alpha: 0.45),
                          context.bg.withValues(alpha: 0.78),
                          context.bg.withValues(alpha: 0.95),
                          context.bg,
                        ],
                        stops: const [0.0, 0.3, 0.55, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _filterLabel(MatchTimelineFilter f, List<PlayerMatch> all) {
    final n = switch (f) {
      MatchTimelineFilter.all => all.length,
      MatchTimelineFilter.live =>
        all.where((m) => m.lifecycle == MatchLifecycle.live).length,
      MatchTimelineFilter.upcoming =>
        all.where((m) => m.lifecycle == MatchLifecycle.upcoming).length,
      MatchTimelineFilter.past =>
        all.where((m) => m.lifecycle == MatchLifecycle.past).length,
      MatchTimelineFilter.hosting => all.where((m) => m.canScoreNow()).length,
    };
    final label = switch (f) {
      MatchTimelineFilter.all => 'All',
      MatchTimelineFilter.live => 'Live',
      MatchTimelineFilter.upcoming => 'Upcoming',
      MatchTimelineFilter.past => 'Past',
      MatchTimelineFilter.hosting => 'Hosting',
    };
    return '$n $label';
  }
}

// ── Create match button ───────────────────────────────────────────────────────

class _CreateMatchButton extends StatelessWidget {
  const _CreateMatchButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: context.accentBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: context.accent, size: 15),
            const SizedBox(width: 4),
            Text(
              'Create',
              style: TextStyle(
                color: context.accent,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Segmented tabs ────────────────────────────────────────────────────────────

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.controller,
    required this.individualCount,
    required this.tournamentCount,
  });
  final TabController controller;
  final int individualCount;
  final int tournamentCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.stroke),
      ),
      child: TabBar(
        controller: controller,
        padding: const EdgeInsets.all(4),
        indicator: BoxDecoration(
          color: context.accentBg,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: context.accent,
        unselectedLabelColor: context.fgSub,
        labelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: -0.2),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: [
          Tab(text: '$individualCount Individual'),
          Tab(text: '$tournamentCount Tournament'),
        ],
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isLive,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool isLive;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        decoration: BoxDecoration(
          color: selected ? context.accentBg : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? context.accent : context.stroke,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLive) ...[
              _PulsingDot(
                  color: selected ? const Color(0xFFFF3B30) : context.fgSub),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? context.accent : context.fgSub,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Matches list ──────────────────────────────────────────────────────────────

class _MatchesList extends ConsumerWidget {
  const _MatchesList({
    required this.sectionType,
    required this.filter,
    this.searchQuery = '',
  });

  final MatchSectionType sectionType;
  final MatchTimelineFilter filter;
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchesControllerProvider);
    final ctrl = ref.read(matchesControllerProvider.notifier);
    final visible = _sorted(state.matches.where(_include).toList());

    if (state.isLoading && state.matches.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.matches.isEmpty) {
      return _EmptyFeedback(
        icon: Icons.wifi_off_rounded,
        title: 'Could not load matches',
        message: state.error!,
        actionLabel: 'Retry',
        onAction: ctrl.load,
      );
    }

    if (visible.isEmpty) {
      if (filter == MatchTimelineFilter.upcoming ||
          filter == MatchTimelineFilter.past) {
        return Center(
          child: Text(
            'Nothing here yet',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: context.fgSub),
          ),
        );
      }
      if (filter == MatchTimelineFilter.hosting) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: context.stroke),
                  ),
                  child: Icon(Icons.shield_rounded,
                      color: context.gold, size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  "You're not hosting any matches",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Create a match to start hosting and scoring.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: context.fgSub),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => context.push('/create-match'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 11),
                    decoration: BoxDecoration(
                      color: context.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Create Match',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: ctrl.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
            _EmptyFeedback(
              icon: Icons.sports_cricket_rounded,
              title: 'No matches yet',
              message: 'Create a match to get started.',
              actionLabel: 'Create Match',
              onAction: () => context.push('/create-match'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: ctrl.refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
        itemCount: visible.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _MatchCard(match: visible[i]),
      ),
    );
  }

  bool _include(PlayerMatch m) {
    if (m.sectionType != sectionType) return false;
    if (sectionType == MatchSectionType.tournament && !m.involvesPlayerTeam) {
      return false;
    }
    final lifecycleOk = switch (filter) {
      MatchTimelineFilter.all => true,
      MatchTimelineFilter.live => m.lifecycle == MatchLifecycle.live,
      MatchTimelineFilter.upcoming => m.lifecycle == MatchLifecycle.upcoming,
      MatchTimelineFilter.past => m.lifecycle == MatchLifecycle.past,
      MatchTimelineFilter.hosting => m.canScoreNow(),
    };
    if (!lifecycleOk) return false;
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return true;
    return (m.playerTeamName.toLowerCase().contains(q)) ||
        (m.opponentTeamName.toLowerCase().contains(q)) ||
        (m.playerTeamShortName?.toLowerCase().contains(q) ?? false) ||
        (m.opponentTeamShortName?.toLowerCase().contains(q) ?? false) ||
        (m.venueLabel?.toLowerCase().contains(q) ?? false) ||
        (m.competitionLabel?.toLowerCase().contains(q) ?? false);
  }

  List<PlayerMatch> _sorted(List<PlayerMatch> ms) {
    ms.sort((a, b) {
      if (filter == MatchTimelineFilter.all) {
        final r = _rank(a.lifecycle) - _rank(b.lifecycle);
        if (r != 0) return r;
      }
      final aT = a.scheduledAt;
      final bT = b.scheduledAt;
      if (aT == null && bT == null) return 0;
      if (aT == null) return 1;
      if (bT == null) return -1;
      return (filter == MatchTimelineFilter.past ||
              (filter == MatchTimelineFilter.all &&
                  a.lifecycle == MatchLifecycle.past &&
                  b.lifecycle == MatchLifecycle.past))
          ? bT.compareTo(aT)
          : aT.compareTo(bT);
    });
    return ms;
  }

  int _rank(MatchLifecycle l) => switch (l) {
        MatchLifecycle.live => 0,
        MatchLifecycle.upcoming => 1,
        MatchLifecycle.past => 2,
      };
}

// ── Match card ────────────────────────────────────────────────────────────────

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});
  final PlayerMatch match;

  @override
  Widget build(BuildContext context) {
    final isLive = match.lifecycle == MatchLifecycle.live;
    final teamA =
        match.playerTeamName.isEmpty ? 'Team A' : match.playerTeamName;
    final teamB =
        match.opponentTeamName.isEmpty ? 'Team B' : match.opponentTeamName;
    final colA = _teamColor(teamA);
    final colB = _teamColor(teamB);
    final dateStr = match.scheduledAt == null
        ? null
        : DateFormat('d MMM · h:mm a').format(match.scheduledAt!);
    final detailPath =
        match.id.isEmpty ? null : '/match/${Uri.encodeComponent(match.id)}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: detailPath == null
            ? null
            : () => context.push(detailPath, extra: match),
        child: Ink(
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLive
                  ? context.accent.withValues(alpha: 0.40)
                  : context.stroke,
              width: isLive ? 1.4 : 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Teams row ─────────────────────────────────────────
                Row(
                  children: [
                    _TeamCrest(
                        name: teamA,
                        color: colA,
                        size: 36,
                        logoUrl: match.playerTeamLogoUrl),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        teamA,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'vs',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: context.fgSub,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        teamB,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _TeamCrest(
                        name: teamB,
                        color: colB,
                        size: 36,
                        logoUrl: match.opponentTeamLogoUrl),
                  ],
                ),

                // ── Score / summary ───────────────────────────────────
                if (match.scoreSummary != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    match.scoreSummary!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.fgSub,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],

                // ── Personal impact ───────────────────────────────────
                if (_hasImpact(match)) ...[
                  const SizedBox(height: 8),
                  Text(
                    _impactLine(match),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: context.accent,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],

                const SizedBox(height: 10),

                // ── Footer: status · ball type · venue · date ─────────
                Row(
                  children: [
                    _StatusPill(match: match),
                    if (match.ballType != null) ...[
                      const SizedBox(width: 6),
                      _BallTypePill(ballType: match.ballType!),
                    ],
                    if (match.venueLabel != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          match.venueLabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: context.fgSub),
                        ),
                      ),
                    ] else
                      const Spacer(),
                    if (dateStr != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: context.fgSub),
                      ),
                    ],
                  ],
                ),

                // ── Resume / Score button (hosting only) ──────────────
                if (match.canScoreNow() &&
                    match.lifecycle != MatchLifecycle.past) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        if (isLive) {
                          context.push(
                            '/score-match/${Uri.encodeComponent(match.id)}',
                          );
                        } else {
                          // Scheduled match → edit Playing 11 before starting
                          final teamA = Uri.encodeQueryComponent(
                              match.playerTeamName);
                          final teamB = Uri.encodeQueryComponent(
                              match.opponentTeamName);
                          final id = Uri.encodeQueryComponent(match.id);
                          context.push(
                            '/create-match?matchId=$id&teamA=$teamA&teamB=$teamB',
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isLive
                              ? context.accent
                              : context.accentBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: context.accent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isLive
                                  ? Icons.sports_cricket_rounded
                                  : Icons.play_arrow_rounded,
                              color: isLive ? Colors.white : context.accent,
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isLive ? 'Score Match' : 'Resume',
                              style: TextStyle(
                                color: isLive ? Colors.white : context.accent,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.match});
  final PlayerMatch match;

  String get _label => switch (match.lifecycle) {
        MatchLifecycle.live => 'LIVE',
        MatchLifecycle.upcoming => 'Upcoming',
        MatchLifecycle.past => switch (match.result) {
            MatchResult.win => 'Won',
            MatchResult.loss => 'Lost',
            MatchResult.draw => 'Draw',
            MatchResult.unknown => 'Completed',
          },
      };

  @override
  Widget build(BuildContext context) {
    final isLive = match.lifecycle == MatchLifecycle.live;
    final isUpcoming = match.lifecycle == MatchLifecycle.upcoming;

    final color = isLive
        ? const Color(0xFFFF3B30)
        : isUpcoming
            ? context.gold
            : context.fgSub;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLive)
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: _PulsingDot(color: color),
          )
        else
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        Text(
          _label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
        ),
      ],
    );
  }
}

// ── Ball type pill ────────────────────────────────────────────────────────────

class _BallTypePill extends StatelessWidget {
  const _BallTypePill({required this.ballType});
  final String ballType;

  @override
  Widget build(BuildContext context) {
    final isLeather = ballType.toUpperCase() == 'LEATHER';
    final color = isLeather
        ? const Color(0xFFB45309) // amber-brown for leather
        : const Color(0xFF16A34A); // green for tennis
    final label = isLeather ? 'Leather' : 'Tennis';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ── Hosting badge ─────────────────────────────────────────────────────────────

class _HostingBadge extends StatefulWidget {
  const _HostingBadge();

  @override
  State<_HostingBadge> createState() => _HostingBadgeState();
}

class _HostingBadgeState extends State<_HostingBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Text(
        'Hosting',
        style: TextStyle(
          color: context.gold,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Team crest ────────────────────────────────────────────────────────────────

class _TeamCrest extends StatelessWidget {
  const _TeamCrest({
    required this.name,
    required this.color,
    required this.size,
    this.logoUrl,
  });

  final String name;
  final Color color;
  final double size;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    final fontSize = size * 0.40;

    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          logoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initials(initial, fontSize),
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : _initials(initial, fontSize),
        ),
      );
    }

    return _initials(initial, fontSize);
  }

  Widget _initials(String initial, double fontSize) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.08),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1.5),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

// ── Empty / feedback state ────────────────────────────────────────────────────

class _EmptyFeedback extends StatelessWidget {
  const _EmptyFeedback({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.stroke),
            ),
            child: Icon(icon, color: context.fgSub, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: context.fgSub),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
              decoration: BoxDecoration(
                color: context.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pulsing dot ───────────────────────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});
  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 850))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ── Utilities ─────────────────────────────────────────────────────────────────

Color _teamColor(String name) {
  const palette = [
    Color(0xFF3FA66A),
    Color(0xFF5B8FD4),
    Color(0xFFD7A94B),
    Color(0xFFCC7A7A),
    Color(0xFF9B7FD4),
    Color(0xFF34B8A0),
    Color(0xFFE07B45),
  ];
  if (name.isEmpty) return palette[0];
  return palette[name.codeUnits.fold(0, (a, b) => a + b) % palette.length];
}

bool _hasImpact(PlayerMatch m) =>
    (m.playerRuns != null && m.playerRuns! > 0) ||
    (m.playerWickets != null && m.playerWickets! > 0) ||
    (m.playerCatches != null && m.playerCatches! > 0);

String _impactLine(PlayerMatch m) => [
      if (m.playerRuns != null) '${m.playerRuns}r',
      if (m.playerWickets != null && m.playerWickets! > 0)
        '${m.playerWickets}w',
      if (m.playerCatches != null && m.playerCatches! > 0)
        '${m.playerCatches}c',
    ].join(' · ');
