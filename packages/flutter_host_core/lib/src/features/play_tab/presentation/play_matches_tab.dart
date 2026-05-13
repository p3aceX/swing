import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../repositories/host_match_repository.dart';
import '../../../theme/host_colors.dart';
import '../../create_match/data/create_match_repository.dart';
import '../../create_match/presentation/create_match_screen.dart';
import '../../match_detail/domain/match_models.dart';
import '../../match_detail/presentation/match_card.dart';
import '../controller/play_tab_controller.dart';
import 'play_search_field.dart';
import 'play_tab.dart';

class PlayMatchesTab extends ConsumerStatefulWidget {
  const PlayMatchesTab({super.key, required this.callbacks});

  final PlayTabCallbacks callbacks;

  @override
  ConsumerState<PlayMatchesTab> createState() => _PlayMatchesTabState();
}

class _PlayMatchesTabState extends ConsumerState<PlayMatchesTab>
    with SingleTickerProviderStateMixin {
  static const _filters = [
    MatchLifecycle.live,
    MatchLifecycle.upcoming,
    MatchLifecycle.past,
  ];

  late final TabController _tabController;
  int _selectedFilter = -1; // -1 = All
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  int _activeTabIndex = 0;

  // Attribute filters — apply to both Individual and Tournament tabs.
  String? _venueFilter;
  String? _opponentFilter;
  String? _formatFilter;
  String? _tournamentFilter; // tournament name
  String? _tournamentRoleFilter; // 'host' | 'participant' | null
  DateTime? _dateFilter; // exact day match
  // Month bucket — first day of month at 00:00, used as the comparison anchor.
  DateTime? _monthFilter;

  int get _activeFilterCount => [
        _venueFilter,
        _opponentFilter,
        _formatFilter,
        _tournamentFilter,
        _tournamentRoleFilter,
        _dateFilter,
        _monthFilter,
      ].where((f) => f != null).length;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _activeTabIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openFilters(BuildContext context, List<PlayerMatch> all) {
    final venues = all
        .map((m) => m.venueLabel)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
    final opponents = all
        .map((m) => m.opponentTeamName)
        .where((n) => n.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final formats = all
        .map((m) => m.formatLabel)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
    final tournaments = all
        .map((m) => m.tournamentName)
        .whereType<String>()
        .where((n) => n.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surf,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _FilterSheet(
        venues: venues,
        opponents: opponents,
        formats: formats,
        tournaments: tournaments,
        selectedVenue: _venueFilter,
        selectedOpponent: _opponentFilter,
        selectedFormat: _formatFilter,
        selectedTournament: _tournamentFilter,
        selectedTournamentRole: _tournamentRoleFilter,
        selectedDate: _dateFilter,
        selectedMonth: _monthFilter,
        onApply: (state) {
          setState(() {
            _venueFilter = state.venue;
            _opponentFilter = state.opponent;
            _formatFilter = state.format;
            _tournamentFilter = state.tournament;
            _tournamentRoleFilter = state.tournamentRole;
            _dateFilter = state.date;
            _monthFilter = state.month;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playMatchesControllerProvider);
    final ctrl = ref.read(playMatchesControllerProvider.notifier);
    final all = state.matches;

    final individualMatches = all
        .where((m) => m.sectionType == MatchSectionType.individual)
        .toList();
    final teamMatches = all
        .where((m) => m.sectionType == MatchSectionType.tournament &&
            (m.involvesPlayerTeam || m.myRole != null))
        .toList();

    final sectionAll = _activeTabIndex == 0 ? individualMatches : teamMatches;
    final liveCount     = sectionAll.where((m) => m.lifecycle == MatchLifecycle.live).length;
    final upcomingCount = sectionAll.where((m) => m.lifecycle == MatchLifecycle.upcoming).length;
    final pastCount     = sectionAll.where((m) => m.lifecycle == MatchLifecycle.past).length;

    final hasFilters = _activeFilterCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Search ──────────────────────────────────────────────────────────
        PlaySearchField(
          controller: _searchCtrl,
          value: _searchQuery,
          hintText: 'Search matches',
          onChanged: (v) => setState(() => _searchQuery = v),
          onClear: () => setState(() {
            _searchCtrl.clear();
            _searchQuery = '';
          }),
          trailing: PlaySearchTrailingButton(
            icon: Icons.tune_rounded,
            active: hasFilters,
            onTap: () => _openFilters(context, all),
          ),
        ),

        // ── Active attribute filters ─────────────────────────────────────────
        if (hasFilters) ...[
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (_tournamentRoleFilter != null)
                  _ActiveFilterChip(
                    label: _tournamentRoleFilter == 'host'
                        ? 'Hosting'
                        : 'Participated',
                    onRemove: () =>
                        setState(() => _tournamentRoleFilter = null),
                  ),
                if (_tournamentFilter != null)
                  _ActiveFilterChip(
                    label: _tournamentFilter!,
                    onRemove: () => setState(() => _tournamentFilter = null),
                  ),
                if (_formatFilter != null)
                  _ActiveFilterChip(
                    label: _formatFilter!,
                    onRemove: () => setState(() => _formatFilter = null),
                  ),
                if (_opponentFilter != null)
                  _ActiveFilterChip(
                    label: 'vs $_opponentFilter',
                    onRemove: () => setState(() => _opponentFilter = null),
                  ),
                if (_venueFilter != null)
                  _ActiveFilterChip(
                    label: _venueFilter!,
                    onRemove: () => setState(() => _venueFilter = null),
                  ),
                if (_dateFilter != null)
                  _ActiveFilterChip(
                    label: _formatDateChip(_dateFilter!),
                    onRemove: () => setState(() => _dateFilter = null),
                  ),
                if (_monthFilter != null)
                  _ActiveFilterChip(
                    label: _formatMonthChip(_monthFilter!),
                    onRemove: () => setState(() => _monthFilter = null),
                  ),
              ],
            ),
          ),
        ],

        // ── Lifecycle chips ──────────────────────────────────────────────────
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            children: [
              _FilterChip(
                label: '${sectionAll.length} All',
                selected: _selectedFilter == -1,
                isLive: false,
                onTap: () => setState(() => _selectedFilter = -1),
              ),
              const SizedBox(width: 8),
              ...List.generate(_filters.length, (i) {
                final f = _filters[i];
                final count = switch (f) {
                  MatchLifecycle.live => liveCount,
                  MatchLifecycle.upcoming => upcomingCount,
                  MatchLifecycle.past => pastCount,
                };
                final label = switch (f) {
                  MatchLifecycle.live => '$count Live',
                  MatchLifecycle.upcoming => '$count Upcoming',
                  MatchLifecycle.past => '$count Past',
                };
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: label,
                    isLive: f == MatchLifecycle.live,
                    selected: _selectedFilter == i,
                    onTap: () => setState(() => _selectedFilter = i),
                  ),
                );
              }),
            ],
          ),
        ),

        // ── Individual / Team segment ────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              padding: const EdgeInsets.all(3),
              indicator: BoxDecoration(
                color: context.accentBg,
                borderRadius: BorderRadius.circular(9),
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
                Tab(text: '${individualMatches.length} Individual'),
                Tab(text: '${teamMatches.length} Tournament'),
              ],
            ),
          ),
        ),

        // ── Match lists ─────────────────────────────────────────────────────
        Expanded(
          child: Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: [
                  _MatchList(
                    section: MatchSectionType.individual,
                    teamOnly: false,
                    filter: _selectedFilter,
                    searchQuery: _searchQuery,
                    venueFilter: _venueFilter,
                    opponentFilter: _opponentFilter,
                    formatFilter: _formatFilter,
                    tournamentFilter: _tournamentFilter,
                    tournamentRoleFilter: null,
                    dateFilter: _dateFilter,
                    monthFilter: _monthFilter,
                    callbacks: widget.callbacks,
                    onRefresh: ctrl.refresh,
                  ),
                  _MatchList(
                    section: MatchSectionType.individual,
                    teamOnly: true,
                    filter: _selectedFilter,
                    searchQuery: _searchQuery,
                    venueFilter: _venueFilter,
                    opponentFilter: _opponentFilter,
                    formatFilter: _formatFilter,
                    tournamentFilter: _tournamentFilter,
                    tournamentRoleFilter: _tournamentRoleFilter,
                    dateFilter: _dateFilter,
                    monthFilter: _monthFilter,
                    callbacks: widget.callbacks,
                    onRefresh: ctrl.refresh,
                  ),
                ],
              ),
              // Fade at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 140,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          context.bg.withValues(alpha: 0),
                          context.bg.withValues(alpha: 0.9),
                          context.bg,
                        ],
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
}

// ─── Match list ───────────────────────────────────────────────────────────────

class _MatchList extends ConsumerWidget {
  const _MatchList({
    required this.section,
    required this.teamOnly,
    required this.filter,
    required this.searchQuery,
    required this.venueFilter,
    required this.opponentFilter,
    required this.formatFilter,
    required this.tournamentFilter,
    required this.tournamentRoleFilter,
    required this.dateFilter,
    required this.monthFilter,
    required this.callbacks,
    required this.onRefresh,
  });

  final MatchSectionType section;
  final bool teamOnly; // true = team matches, false = individual (non-team) matches
  final int filter; // -1=all, 0=live, 1=upcoming, 2=past
  final String searchQuery;
  final String? venueFilter;
  final String? opponentFilter;
  final String? formatFilter;
  final String? tournamentFilter;
  /// 'host' | 'participant' | null — applied only in the Tournament tab.
  final String? tournamentRoleFilter;
  final DateTime? dateFilter;
  final DateTime? monthFilter;
  final PlayTabCallbacks callbacks;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playMatchesControllerProvider);

    if (state.isLoading && state.matches.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Could not load matches',
                style: TextStyle(color: context.fgSub)),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRefresh, child: const Text('Retry')),
          ],
        ),
      );
    }

    final visible = _filtered(state.matches);

    if (visible.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),
            Center(
              child: Text(
                'Nothing here yet',
                style: TextStyle(color: context.fgSub),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 6, 0, 110),
        itemCount: visible.length,
        itemBuilder: (_, i) {
          final m = visible[i];
          if ((m.canManage || m.isActiveScorer) && m.lifecycle != MatchLifecycle.past) {
            final canDelete = m.lifecycle != MatchLifecycle.live && m.canDelete;
            return _HostedMatchItem(
              match: m,
              callbacks: callbacks,
              canManage: m.canManage,
              onDelete: canDelete
                  ? () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete match?'),
                          content: const Text(
                              'This will permanently delete the match and cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                'Delete',
                                style: TextStyle(color: context.danger),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                      await ref
                          .read(hostMatchRepositoryProvider)
                          .deleteMatch(m.id);
                      await onRefresh();
                    }
                  : null,
            );
          }
          return HostMatchCard(
            match: m,
            onTap: callbacks.onNavigateToMatch != null && m.id.isNotEmpty
                ? () => callbacks.onNavigateToMatch!(context, m.id)
                : null,
          );
        },
      ),
    );
  }

  List<PlayerMatch> _filtered(List<PlayerMatch> all) {
    final dropped = <String>[];
    final kept = all.where((m) {
      if (teamOnly) {
        // Tournament tab: tournament matches where user's team is involved OR user is scorer
        if (m.sectionType != MatchSectionType.tournament) {
          dropped.add('${m.id}: not-tournament');
          return false;
        }
        if (!m.involvesPlayerTeam && m.myRole == null) {
          dropped.add('${m.id}: tournament-but-no-team-or-role');
          return false;
        }
      } else {
        // Individual tab: non-tournament matches only
        if (m.sectionType != MatchSectionType.individual) {
          dropped.add('${m.id}: not-individual');
          return false;
        }
      }

      final lifecycleOk = switch (filter) {
        -1 => true,
        0 => m.lifecycle == MatchLifecycle.live,
        1 => m.lifecycle == MatchLifecycle.upcoming,
        2 => m.lifecycle == MatchLifecycle.past,
        _ => true,
      };
      if (!lifecycleOk) {
        dropped.add('${m.id}: lifecycle=${m.lifecycle.name} filter=$filter');
        return false;
      }

      if (venueFilter != null && m.venueLabel != venueFilter) {
        dropped.add('${m.id}: venue!=$venueFilter');
        return false;
      }
      if (opponentFilter != null && m.opponentTeamName != opponentFilter) {
        dropped.add('${m.id}: opp!=$opponentFilter');
        return false;
      }
      if (formatFilter != null && m.formatLabel != formatFilter) {
        dropped.add('${m.id}: fmt!=$formatFilter');
        return false;
      }
      if (tournamentRoleFilter != null &&
          m.tournamentRole != tournamentRoleFilter) {
        dropped.add('${m.id}: tournamentRole!=$tournamentRoleFilter');
        return false;
      }
      if (tournamentFilter != null && m.tournamentName != tournamentFilter) {
        dropped.add('${m.id}: tournament!=$tournamentFilter');
        return false;
      }
      if (dateFilter != null) {
        final mDate = m.scheduledAt;
        if (mDate == null ||
            mDate.year != dateFilter!.year ||
            mDate.month != dateFilter!.month ||
            mDate.day != dateFilter!.day) {
          dropped.add('${m.id}: date!=${dateFilter}');
          return false;
        }
      }
      if (monthFilter != null) {
        final mDate = m.scheduledAt;
        if (mDate == null ||
            mDate.year != monthFilter!.year ||
            mDate.month != monthFilter!.month) {
          dropped.add('${m.id}: month!=${monthFilter}');
          return false;
        }
      }

      final q = searchQuery.trim().toLowerCase();
      if (q.isEmpty) return true;
      final matched = m.playerTeamName.toLowerCase().contains(q) ||
          m.opponentTeamName.toLowerCase().contains(q) ||
          m.title.toLowerCase().contains(q) ||
          (m.venueLabel?.toLowerCase().contains(q) ?? false);
      if (!matched) dropped.add('${m.id}: search-miss');
      return matched;
    }).toList();
    if (kDebugMode) {
      debugPrint('[PlayFilter] tab=${teamOnly ? "tournament" : "individual"} '
          'filter=$filter venue=$venueFilter opp=$opponentFilter fmt=$formatFilter '
          'q="$searchQuery" → kept=${kept.length}/${all.length}');
      for (final d in dropped.take(10)) {
        debugPrint('[PlayFilter]   drop $d');
      }
    }
    return kept
      ..sort((a, b) {
        final ar = _rank(a.lifecycle);
        final br = _rank(b.lifecycle);
        if (ar != br) return ar - br;
        final at = a.scheduledAt;
        final bt = b.scheduledAt;
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        if (a.lifecycle == MatchLifecycle.past) return bt.compareTo(at);
        return at.compareTo(bt);
      });
  }

  int _rank(MatchLifecycle l) => switch (l) {
        MatchLifecycle.live => 0,
        MatchLifecycle.upcoming => 1,
        MatchLifecycle.past => 2,
      };
}

// ─── Hosted match item ────────────────────────────────────────────────────────

/// Match card variant for hosted matches — shows the normal card plus a
/// contextual resume CTA based on where the match is in its lifecycle.
/// [onDelete] is provided only for non-live matches.
class _HostedMatchItem extends ConsumerWidget {
  const _HostedMatchItem({
    required this.match,
    required this.callbacks,
    required this.canManage,
    this.onDelete,
  });

  final PlayerMatch match;
  final PlayTabCallbacks callbacks;
  /// Owner or manager — can run setup/toss flow. Pure scorers get straight to scoring.
  final bool canManage;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLive = match.lifecycle == MatchLifecycle.live;
    final hasToss = (match.tossWinner ?? '').isNotEmpty;
    // Scorer-only users always see the direct scoring CTA; managers see the full setup flow labels.
    final phaseColor = isLive
        ? context.success
        : canManage && !hasToss
            ? context.warn
            : context.sky;
    final phaseLabel = isLive
        ? 'RESUME SCORING'
        : canManage && !hasToss
            ? 'SET UP MATCH'
            : 'START SCORING';
    final phaseIcon = isLive
        ? Icons.play_arrow_rounded
        : canManage && !hasToss
            ? Icons.tune_rounded
            : Icons.sports_cricket_rounded;

    final showScoringCta = match.canScoreFromList;
    final hasActionRow = showScoringCta || onDelete != null;
    return InkWell(
      onTap: callbacks.onNavigateToMatch != null && match.id.isNotEmpty
          ? () => callbacks.onNavigateToMatch!(context, match.id)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HostMatchCard(match: match),
          if (hasActionRow)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Row(
                children: [
                  if (showScoringCta)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onResume(context, ref),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: phaseColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: phaseColor.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(phaseIcon, color: phaseColor, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                phaseLabel,
                                style: TextStyle(
                                  color: phaseColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (onDelete != null) ...[
                    if (showScoringCta) const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: context.danger.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: context.danger.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: context.danger,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _onResume(BuildContext context, WidgetRef ref) {
    final hasToss = (match.tossWinner ?? '').isNotEmpty;
    final isLive = match.lifecycle == MatchLifecycle.live;
    final inSetupPhase = canManage && !hasToss && !isLive;

    if (inSetupPhase) {
      // Push the Match Review screen entirely from inside host_core — no
      // per-host callback wiring needed. The loader fetches the match
      // summary (including parent tournament context) and renders the
      // shared CreateMatchScreen in edit mode so every field is reviewable
      // before scoring starts.
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _MatchReviewLoader(matchId: match.id),
        ),
      );
      return;
    }
    callbacks.onScoreMatch?.call(context, match.id);
  }
}

/// Self-contained loader → Match Review screen. Lives in host_core so the
/// "Setup Match" CTA doesn't need any per-app routing. Fetches the match
/// summary (+ tournament context, when present), then renders the shared
/// CreateMatchScreen pre-filled in edit mode. Saving the edit pops back
/// to the Play tab.
class _MatchReviewLoader extends ConsumerStatefulWidget {
  const _MatchReviewLoader({required this.matchId});

  final String matchId;

  @override
  ConsumerState<_MatchReviewLoader> createState() => _MatchReviewLoaderState();
}

class _MatchReviewLoaderState extends ConsumerState<_MatchReviewLoader> {
  HostMatchSummary? _summary;
  String? _error;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final summary = await ref
          .read(hostCreateMatchRepositoryProvider)
          .getMatch(widget.matchId);
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _loaded = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final s = _summary;
    if (s == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Match Review')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _error ?? 'Could not load this match.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return CreateMatchScreen(
      onBack: () => Navigator.of(context).maybePop(),
      onTossCompleted: (ctx, _) => Navigator.of(ctx).maybePop(),
      editMatchId: s.id,
      onEditSaved: (ctx, _) => Navigator.of(ctx).maybePop(),
      initialPrefill: CreateMatchPrefill(
        teamAId: s.teamAId,
        teamAName: s.teamAName,
        teamALogoUrl: s.teamALogoUrl,
        teamACity: s.teamACity,
        teamBId: s.teamBId,
        teamBName: s.teamBName,
        teamBLogoUrl: s.teamBLogoUrl,
        teamBCity: s.teamBCity,
        format: s.format,
        category: s.category,
        ageGroup: s.ageGroup,
        ballType: s.ballType,
        venueId: s.venueId,
        venueName: s.venueName,
        venueCity: s.venueCity,
        scheduledAt: s.scheduledAt,
        customOvers: s.customOvers,
        hasImpactPlayer: s.hasImpactPlayer,
      ),
    );
  }
}


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
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? context.accent : context.stroke,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLive) ...[
              _PulsingDot(
                  color: selected
                      ? const Color(0xFFFF3B30)
                      : context.fgSub),
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

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onRemove,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: context.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: context.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.close_rounded, size: 12, color: context.accent),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Filter sheet ─────────────────────────────────────────────────────────────

String _formatDateChip(DateTime d) => DateFormat('d MMM y').format(d);
String _formatMonthChip(DateTime d) => DateFormat('MMM y').format(d);

class _FilterApplyState {
  const _FilterApplyState({
    this.venue,
    this.opponent,
    this.format,
    this.tournament,
    this.tournamentRole,
    this.date,
    this.month,
  });

  final String? venue;
  final String? opponent;
  final String? format;
  final String? tournament;
  final String? tournamentRole;
  final DateTime? date;
  final DateTime? month;
}

enum _FilterRow { tournamentRole, tournament, format, team, ground, date, month }

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.venues,
    required this.opponents,
    required this.formats,
    required this.tournaments,
    required this.selectedVenue,
    required this.selectedOpponent,
    required this.selectedFormat,
    required this.selectedTournament,
    required this.selectedTournamentRole,
    required this.selectedDate,
    required this.selectedMonth,
    required this.onApply,
  });

  final List<String> venues;
  final List<String> opponents;
  final List<String> formats;
  final List<String> tournaments;
  final String? selectedVenue;
  final String? selectedOpponent;
  final String? selectedFormat;
  final String? selectedTournament;
  final String? selectedTournamentRole; // 'host' | 'participant' | null
  final DateTime? selectedDate;
  final DateTime? selectedMonth;
  final void Function(_FilterApplyState state) onApply;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _venue;
  String? _opponent;
  String? _format;
  String? _tournament;
  String? _tournamentRole;
  DateTime? _date;
  DateTime? _month;
  // Which row is expanded — null = all collapsed (default).
  _FilterRow? _open;

  @override
  void initState() {
    super.initState();
    _venue = widget.selectedVenue;
    _opponent = widget.selectedOpponent;
    _format = widget.selectedFormat;
    _tournament = widget.selectedTournament;
    _tournamentRole = widget.selectedTournamentRole;
    _date = widget.selectedDate;
    _month = widget.selectedMonth;
  }

  int get _activeCount => [
        _venue,
        _opponent,
        _format,
        _tournament,
        _tournamentRole,
        _date,
        _month,
      ].where((v) => v != null).length;

  void _toggle(_FilterRow r) {
    setState(() => _open = _open == r ? null : r);
  }

  String _summary(_FilterRow r) {
    switch (r) {
      case _FilterRow.tournamentRole:
        return _tournamentRole == 'host'
            ? 'Hosting'
            : _tournamentRole == 'participant'
                ? 'Participated'
                : 'Any';
      case _FilterRow.tournament:
        return _tournament ?? 'Any';
      case _FilterRow.format:
        return _format ?? 'Any';
      case _FilterRow.team:
        return _opponent ?? 'Any';
      case _FilterRow.ground:
        return _venue ?? 'Any';
      case _FilterRow.date:
        return _date != null ? DateFormat('d MMM y').format(_date!) : 'Any';
      case _FilterRow.month:
        return _month != null ? DateFormat('MMM y').format(_month!) : 'Any';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.stroke,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // ── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Text(
                  'Filters',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (_activeCount > 0) ...[
                  const SizedBox(width: 6),
                  Text(
                    '($_activeCount)',
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const Spacer(),
                if (_activeCount > 0)
                  TextButton(
                    onPressed: () => setState(() {
                      _venue = null;
                      _opponent = null;
                      _format = null;
                      _tournament = null;
                      _tournamentRole = null;
                      _date = null;
                      _month = null;
                    }),
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        color: context.danger,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: context.stroke),
          // ── Rows ──────────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [
                _FilterListRow(
                  label: 'Tournament role',
                  value: _summary(_FilterRow.tournamentRole),
                  isOpen: _open == _FilterRow.tournamentRole,
                  onTap: () => _toggle(_FilterRow.tournamentRole),
                  expanded: _RolePills(
                    selected: _tournamentRole,
                    onSelect: (v) => setState(() => _tournamentRole = v),
                  ),
                ),
                _FilterListRow(
                  label: 'Tournament',
                  value: _summary(_FilterRow.tournament),
                  isOpen: _open == _FilterRow.tournament,
                  onTap: () => _toggle(_FilterRow.tournament),
                  expanded: _PillList(
                    options: widget.tournaments,
                    selected: _tournament,
                    onSelect: (v) => setState(() => _tournament = v),
                    emptyText: 'No tournaments yet',
                  ),
                ),
                _FilterListRow(
                  label: 'Format',
                  value: _summary(_FilterRow.format),
                  isOpen: _open == _FilterRow.format,
                  onTap: () => _toggle(_FilterRow.format),
                  expanded: _PillList(
                    options: widget.formats,
                    selected: _format,
                    onSelect: (v) => setState(() => _format = v),
                    emptyText: 'No formats yet',
                  ),
                ),
                _FilterListRow(
                  label: 'Team',
                  value: _summary(_FilterRow.team),
                  isOpen: _open == _FilterRow.team,
                  onTap: () => _toggle(_FilterRow.team),
                  expanded: _PillList(
                    options: widget.opponents,
                    selected: _opponent,
                    onSelect: (v) => setState(() => _opponent = v),
                    emptyText: 'No teams yet',
                  ),
                ),
                _FilterListRow(
                  label: 'Ground',
                  value: _summary(_FilterRow.ground),
                  isOpen: _open == _FilterRow.ground,
                  onTap: () => _toggle(_FilterRow.ground),
                  expanded: _PillList(
                    options: widget.venues,
                    selected: _venue,
                    onSelect: (v) => setState(() => _venue = v),
                    emptyText: 'No grounds yet',
                  ),
                ),
                _FilterListRow(
                  label: 'Date',
                  value: _summary(_FilterRow.date),
                  isOpen: false, // date opens picker directly
                  onTap: () async {
                    final initial = _date ?? DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: DateTime(initial.year - 5),
                      lastDate: DateTime(initial.year + 3),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                  onClear: _date == null
                      ? null
                      : () => setState(() => _date = null),
                ),
                _FilterListRow(
                  label: 'Month',
                  value: _summary(_FilterRow.month),
                  isOpen: false,
                  onTap: () async {
                    final initial = _month ?? DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(initial.year, initial.month),
                      firstDate: DateTime(initial.year - 5),
                      lastDate: DateTime(initial.year + 3),
                      helpText: 'Pick any day — only the month is used',
                    );
                    if (picked != null) {
                      setState(() =>
                          _month = DateTime(picked.year, picked.month));
                    }
                  },
                  onClear: _month == null
                      ? null
                      : () => setState(() => _month = null),
                ),
              ],
            ),
          ),
          // ── Apply button (sticky bottom) ─────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: context.bg,
              border: Border(top: BorderSide(color: context.stroke)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  widget.onApply(_FilterApplyState(
                    venue: _venue,
                    opponent: _opponent,
                    format: _format,
                    tournament: _tournament,
                    tournamentRole: _tournamentRole,
                    date: _date,
                    month: _month,
                  ));
                  Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: context.accent,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _activeCount == 0 ? 'Apply' : 'Apply ($_activeCount)',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One row in the filter list. Tapping toggles the inline expansion
/// (or for Date/Month, calls onTap directly to open a picker). When
/// `expanded` is null and `isOpen` is false, the row just shows the
/// label + current value + chevron — utility row, nothing fancy.
class _FilterListRow extends StatelessWidget {
  const _FilterListRow({
    required this.label,
    required this.value,
    required this.isOpen,
    required this.onTap,
    this.expanded,
    this.onClear,
  });

  final String label;
  final String value;
  final bool isOpen;
  final VoidCallback onTap;
  final Widget? expanded;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != 'Any';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: context.stroke, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: hasValue ? context.accent : context.fgSub,
                    fontSize: 13,
                    fontWeight:
                        hasValue ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (onClear != null && hasValue) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: onClear,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(Icons.close_rounded,
                          size: 14, color: context.fgSub),
                    ),
                  ),
                ] else if (expanded != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: context.fgSub,
                  ),
                ] else ...[
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded,
                      size: 18, color: context.fgSub),
                ],
              ],
            ),
          ),
        ),
        if (isOpen && expanded != null)
          Container(
            color: context.cardBg,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: expanded!,
          ),
      ],
    );
  }
}

class _RolePills extends StatelessWidget {
  const _RolePills({required this.selected, required this.onSelect});
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    Widget pill(String label, String? value) {
      final sel = selected == value;
      return GestureDetector(
        onTap: () => onSelect(sel ? null : value),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: sel
                ? context.accent.withValues(alpha: 0.12)
                : Colors.transparent,
            border: Border.all(
                color: sel ? context.accent : context.stroke),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: sel ? context.accent : context.fg,
              fontSize: 12.5,
              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        pill('Any', null),
        pill('Hosting', 'host'),
        pill('Participated', 'participant'),
      ],
    );
  }
}

class _PillList extends StatelessWidget {
  const _PillList({
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.emptyText,
  });
  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelect;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return Text(emptyText,
          style: TextStyle(color: context.fgSub, fontSize: 13));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final sel = opt == selected;
        return GestureDetector(
          onTap: () => onSelect(sel ? null : opt),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: sel
                  ? context.accent.withValues(alpha: 0.12)
                  : Colors.transparent,
              border: Border.all(
                  color: sel ? context.accent : context.stroke),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              opt,
              style: TextStyle(
                color: sel ? context.accent : context.fg,
                fontSize: 12.5,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

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
        margin: const EdgeInsets.only(right: 3),
        decoration:
            BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
