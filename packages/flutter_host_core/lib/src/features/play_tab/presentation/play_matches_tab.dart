import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/host_colors.dart';
import '../../match_detail/domain/match_models.dart';
import '../../match_detail/presentation/match_card.dart';
import '../controller/play_tab_controller.dart';
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
  bool _searchOpen = false;
  final _searchCtrl = TextEditingController();

  // Attribute filters
  String? _venueFilter;
  String? _opponentFilter;
  String? _formatFilter;

  int get _activeFilterCount =>
      [_venueFilter, _opponentFilter, _formatFilter].where((f) => f != null).length;

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
        selectedVenue: _venueFilter,
        selectedOpponent: _opponentFilter,
        selectedFormat: _formatFilter,
        onApply: (venue, opponent, format) {
          setState(() {
            _venueFilter = venue;
            _opponentFilter = opponent;
            _formatFilter = format;
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

    final statLine = all.isEmpty
        ? null
        : [
            '${all.length} matches',
            '${all.where((m) => m.lifecycle == MatchLifecycle.live).length} live',
          ].join('  ·  ');

    final individualCount =
        all.where((m) => m.sectionType == MatchSectionType.individual).length;
    final tournamentCount =
        all.where((m) => m.sectionType == MatchSectionType.tournament && m.involvesPlayerTeam).length;

    final hasFilters = _activeFilterCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ─────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.stroke)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    GestureDetector(
                      onTap: () => _openFilters(context, all),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              size: 22,
                              color: hasFilters ? context.accent : context.fgSub,
                            ),
                            if (hasFilters)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: context.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$_activeFilterCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => setState(() => _searchOpen = true),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.search_rounded,
                            color: context.fgSub, size: 22),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _CreateButton(
                      onTap: widget.callbacks.onCreateMatch != null
                          ? () => widget.callbacks.onCreateMatch!(context)
                          : null,
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
                    hintStyle: TextStyle(color: context.fgSub, fontSize: 14),
                    prefixIcon:
                        Icon(Icons.search_rounded, color: context.fgSub, size: 18),
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

              // ── Active filter chips ──────────────────────────────────────
              if (hasFilters) ...[
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
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
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // ── Lifecycle filter chips ───────────────────────────────────
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                      label: '${all.length} All',
                      selected: _selectedFilter == -1,
                      isLive: false,
                      onTap: () => setState(() => _selectedFilter = -1),
                    ),
                    const SizedBox(width: 8),
                    ...List.generate(_filters.length, (i) {
                      final f = _filters[i];
                      final count = switch (f) {
                        MatchLifecycle.live =>
                          all.where((m) => m.lifecycle == MatchLifecycle.live).length,
                        MatchLifecycle.upcoming =>
                          all.where((m) => m.lifecycle == MatchLifecycle.upcoming).length,
                        MatchLifecycle.past =>
                          all.where((m) => m.lifecycle == MatchLifecycle.past).length,
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
                    _FilterChip(
                      label: '${all.where((m) => m.canScore).length} Hosting',
                      selected: _selectedFilter == 99,
                      isLive: false,
                      onTap: () => setState(() => _selectedFilter = 99),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ── Segment tabs ─────────────────────────────────────────────
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
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
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2),
                  unselectedLabelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                  tabs: [
                    Tab(text: '$individualCount Individual'),
                    Tab(text: '$tournamentCount Tournament'),
                  ],
                ),
              ),
            ],
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
                    filter: _selectedFilter,
                    searchQuery: _searchQuery,
                    venueFilter: _venueFilter,
                    opponentFilter: _opponentFilter,
                    formatFilter: _formatFilter,
                    callbacks: widget.callbacks,
                    onRefresh: ctrl.refresh,
                  ),
                  _MatchList(
                    section: MatchSectionType.tournament,
                    filter: _selectedFilter,
                    searchQuery: _searchQuery,
                    venueFilter: _venueFilter,
                    opponentFilter: _opponentFilter,
                    formatFilter: _formatFilter,
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
    required this.filter,
    required this.searchQuery,
    required this.venueFilter,
    required this.opponentFilter,
    required this.formatFilter,
    required this.callbacks,
    required this.onRefresh,
  });

  final MatchSectionType section;
  final int filter; // -1=all, 0=live, 1=upcoming, 2=past, 99=hosting
  final String searchQuery;
  final String? venueFilter;
  final String? opponentFilter;
  final String? formatFilter;
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

    if (filter == 99) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 110),
          itemCount: visible.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, thickness: 1, color: context.stroke),
          itemBuilder: (_, i) => _HostedMatchItem(
            match: visible[i],
            callbacks: callbacks,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 110),
        itemCount: visible.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          thickness: 1,
          color: context.stroke,
        ),
        itemBuilder: (_, i) => HostMatchCard(
          match: visible[i],
          onTap: callbacks.onNavigateToMatch != null && visible[i].id.isNotEmpty
              ? () => callbacks.onNavigateToMatch!(context, visible[i].id)
              : null,
        ),
      ),
    );
  }

  List<PlayerMatch> _filtered(List<PlayerMatch> all) {
    return all.where((m) {
      if (m.sectionType != section) return false;
      if (section == MatchSectionType.tournament && !m.involvesPlayerTeam) {
        return false;
      }

      final lifecycleOk = switch (filter) {
        -1 => true,
        0 => m.lifecycle == MatchLifecycle.live,
        1 => m.lifecycle == MatchLifecycle.upcoming,
        2 => m.lifecycle == MatchLifecycle.past,
        // Hosting tab: owned + not yet completed (live or upcoming only)
        99 => m.canScore && m.lifecycle != MatchLifecycle.past,
        _ => true,
      };
      if (!lifecycleOk) return false;

      if (venueFilter != null && m.venueLabel != venueFilter) return false;
      if (opponentFilter != null && m.opponentTeamName != opponentFilter) return false;
      if (formatFilter != null && m.formatLabel != formatFilter) return false;

      final q = searchQuery.trim().toLowerCase();
      if (q.isEmpty) return true;
      return m.playerTeamName.toLowerCase().contains(q) ||
          m.opponentTeamName.toLowerCase().contains(q) ||
          m.title.toLowerCase().contains(q) ||
          (m.venueLabel?.toLowerCase().contains(q) ?? false);
    }).toList()
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
class _HostedMatchItem extends StatelessWidget {
  const _HostedMatchItem({required this.match, required this.callbacks});

  final PlayerMatch match;
  final PlayTabCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    final isLive = match.lifecycle == MatchLifecycle.live;
    final hasToss = (match.tossWinner ?? '').isNotEmpty;
    final phaseColor = isLive
        ? context.success
        : hasToss
            ? context.sky
            : context.warn;
    final phaseLabel =
        isLive ? 'RESUME SCORING' : hasToss ? 'START SCORING' : 'SET UP MATCH';
    final phaseIcon = isLive
        ? Icons.play_arrow_rounded
        : hasToss
            ? Icons.sports_cricket_rounded
            : Icons.tune_rounded;

    return InkWell(
      onTap: callbacks.onNavigateToMatch != null && match.id.isNotEmpty
          ? () => callbacks.onNavigateToMatch!(context, match.id)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HostMatchCard(match: match),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: GestureDetector(
              onTap: () => _onResume(context),
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
        ],
      ),
    );
  }

  void _onResume(BuildContext context) {
    // Scoring screen is the single entry point for all non-completed hosted
    // matches — it handles toss recording, match review, and live scoring.
    callbacks.onScoreMatch?.call(context, match.id);
  }
}


// ─── Sub widgets ──────────────────────────────────────────────────────────────

class _CreateButton extends StatelessWidget {
  const _CreateButton({this.onTap});
  final VoidCallback? onTap;

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
            Text('Create',
                style: TextStyle(
                    color: context.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ],
        ),
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

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.venues,
    required this.opponents,
    required this.formats,
    required this.selectedVenue,
    required this.selectedOpponent,
    required this.selectedFormat,
    required this.onApply,
  });

  final List<String> venues;
  final List<String> opponents;
  final List<String> formats;
  final String? selectedVenue;
  final String? selectedOpponent;
  final String? selectedFormat;
  final void Function(String? venue, String? opponent, String? format) onApply;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _venue;
  String? _opponent;
  String? _format;

  @override
  void initState() {
    super.initState();
    _venue = widget.selectedVenue;
    _opponent = widget.selectedOpponent;
    _format = widget.selectedFormat;
  }

  @override
  Widget build(BuildContext context) {
    final hasAny = _venue != null || _opponent != null || _format != null;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollController) => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.stroke,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
            child: Row(
              children: [
                Text(
                  'Filter Matches',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                if (hasAny)
                  TextButton(
                    onPressed: () => setState(() {
                      _venue = null;
                      _opponent = null;
                      _format = null;
                    }),
                    child: Text(
                      'Clear all',
                      style: TextStyle(
                        color: context.danger,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: context.stroke),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (widget.formats.isNotEmpty) ...[
                  _SectionHeader(title: 'Match Type', context: context),
                  _OptionGroup(
                    options: widget.formats,
                    selected: _format,
                    onSelect: (v) => setState(() => _format = _format == v ? null : v),
                    context: context,
                  ),
                ],
                if (widget.opponents.isNotEmpty) ...[
                  _SectionHeader(title: 'Opponent', context: context),
                  _OptionGroup(
                    options: widget.opponents,
                    selected: _opponent,
                    onSelect: (v) => setState(() => _opponent = _opponent == v ? null : v),
                    context: context,
                  ),
                ],
                if (widget.venues.isNotEmpty) ...[
                  _SectionHeader(title: 'Ground', context: context),
                  _OptionGroup(
                    options: widget.venues,
                    selected: _venue,
                    onSelect: (v) => setState(() => _venue = _venue == v ? null : v),
                    context: context,
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  widget.onApply(_venue, _opponent, _format);
                  Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: context.accent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.context});
  final String title;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: context.fgSub,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _OptionGroup extends StatelessWidget {
  const _OptionGroup({
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.context,
  });

  final List<String> options;
  final String? selected;
  final void Function(String) onSelect;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((opt) {
          final isSelected = opt == selected;
          return GestureDetector(
            onTap: () => onSelect(opt),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.accent.withValues(alpha: 0.12)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected ? context.accent : context.stroke,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                opt,
                style: TextStyle(
                  color: isSelected ? context.accent : context.fg,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
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
