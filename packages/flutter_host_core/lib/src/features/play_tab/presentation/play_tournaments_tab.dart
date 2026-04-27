import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/host_colors.dart';
import '../controller/play_tab_controller.dart';
import '../domain/play_tab_models.dart';
import 'play_tab.dart';
import 'tournament_card.dart';

// Status buckets
const _live = {'ONGOING', 'LIVE', 'IN_PROGRESS'};

bool _isLive(String s) => _live.contains(s.toUpperCase());
bool _isUpcoming(String s) => s.toUpperCase() == 'UPCOMING';
bool _isCompleted(String s) => s.toUpperCase() == 'COMPLETED';

class PlayTournamentsTab extends ConsumerStatefulWidget {
  const PlayTournamentsTab({
    super.key,
    required this.callbacks,
    this.currentCity,
  });

  final PlayTabCallbacks callbacks;
  final String? currentCity;

  @override
  ConsumerState<PlayTournamentsTab> createState() => _PlayTournamentsTabState();
}

class _PlayTournamentsTabState extends ConsumerState<PlayTournamentsTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = ''; // '' | 'LIVE' | 'UPCOMING' | 'COMPLETED'
  Timer? _exploreDebounce;
  bool _hasAutoSwitched = false;

  static const _formats = ['', 'T10', 'T20', 'ONE_DAY'];
  static const _formatLabels = ['All', 'T10', 'T20', 'ODI'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    _exploreDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    setState(() => _searchQuery = q);
    if (_tabs.index == 1) {
      _exploreDebounce?.cancel();
      _exploreDebounce = Timer(const Duration(milliseconds: 300), () {
        ref.read(playTournamentsControllerProvider.notifier).setExploreQuery(q);
      });
    }
  }

  void _closeSearch() {
    _searchCtrl.clear();
    setState(() => _searchQuery = '');
    ref.read(playTournamentsControllerProvider.notifier).setExploreQuery('');
  }

  List<PlayTournament> _applyFilters(List<PlayTournament> list) {
    var result = list;
    if (_searchQuery.isNotEmpty && _tabs.index < 1) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((t) {
        return t.name.toLowerCase().contains(q) ||
            (t.city?.toLowerCase().contains(q) ?? false) ||
            (t.venueName?.toLowerCase().contains(q) ?? false);
      }).toList();
    }
    if (_statusFilter.isNotEmpty) {
      result = result.where((t) => switch (_statusFilter) {
            'LIVE' => _isLive(t.status),
            'UPCOMING' => _isUpcoming(t.status),
            'COMPLETED' => _isCompleted(t.status),
            _ => true,
          }).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playTournamentsControllerProvider);

    // Auto-jump to Explore when data first loads and user has no participation
    if (!_hasAutoSwitched && !state.isLoading && state.participated.isEmpty) {
      _hasAutoSwitched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _tabs.index == 0) _tabs.animateTo(1);
      });
    }

    final currentList = switch (_tabs.index) {
      0 => state.participated,
      _ => state.publicTournamentsWithHostFlag,
    };
    final liveCount = currentList.where((t) => _isLive(t.status)).length;
    final upcomingCount =
        currentList.where((t) => _isUpcoming(t.status)).length;
    final completedCount =
        currentList.where((t) => _isCompleted(t.status)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Search ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              style: TextStyle(
                  color: context.fg, fontSize: 14, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: _tabs.index == 1
                    ? 'Search by name or city…'
                    : 'Search tournaments…',
                hintStyle: TextStyle(color: context.fgSub, fontSize: 14),
                prefixIcon:
                    Icon(Icons.search_rounded, color: context.fgSub, size: 18),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: _closeSearch,
                        child: Icon(Icons.close_rounded,
                            color: context.fgSub, size: 18),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        // ── Status filter chips ──────────────────────────────────────────────
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            children: [
              _FilterChip(
                label: '${currentList.length} All',
                selected: _statusFilter == '',
                isLive: false,
                onTap: () => setState(() => _statusFilter = ''),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: '$liveCount Live',
                selected: _statusFilter == 'LIVE',
                isLive: true,
                onTap: () => setState(
                    () => _statusFilter = _statusFilter == 'LIVE' ? '' : 'LIVE'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: '$upcomingCount Upcoming',
                selected: _statusFilter == 'UPCOMING',
                isLive: false,
                onTap: () => setState(() =>
                    _statusFilter = _statusFilter == 'UPCOMING' ? '' : 'UPCOMING'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: '$completedCount Completed',
                selected: _statusFilter == 'COMPLETED',
                isLive: false,
                onTap: () => setState(() => _statusFilter =
                    _statusFilter == 'COMPLETED' ? '' : 'COMPLETED'),
              ),
            ],
          ),
        ),

        // ── Participating / Explore tabs ─────────────────────────────────────
        TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: context.accent,
          indicatorWeight: 2,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          labelColor: context.fg,
          unselectedLabelColor: context.fgSub,
          labelPadding: const EdgeInsets.fromLTRB(20, 0, 4, 0),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
          tabs: [
            _TabLabel(
                label: 'Participating',
                count: state.participated.length,
                loading: state.isLoading),
            _TabLabel(
                label: 'Explore',
                count: state.publicTournaments.length,
                loading: state.isLoading),
          ],
        ),

        // ── Format filter (Explore only) ─────────────────────────────────────
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _tabs.index == 1
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity, height: 0),
          secondChild: SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _formats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _FormatChip(
                label: _formatLabels[i],
                selected: state.exploreFormat == _formats[i],
                onTap: () => ref
                    .read(playTournamentsControllerProvider.notifier)
                    .setExploreFormat(_formats[i]),
              ),
            ),
          ),
        ),

        // ── Content ─────────────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _TournamentList(
                tournaments: _applyFilters(state.participated),
                isLoading: state.isLoading,
                error: state.error,
                emptyIcon: Icons.sports_cricket_rounded,
                emptyTitle: _searchQuery.isEmpty && _statusFilter.isEmpty
                    ? 'Not in any tournament'
                    : 'No results',
                emptyMessage: _searchQuery.isEmpty && _statusFilter.isEmpty
                    ? 'Join a tournament from Explore'
                    : 'Try a different search or filter',
                onRefresh: () async => ref
                    .read(playTournamentsControllerProvider.notifier)
                    .refresh(),
                callbacks: widget.callbacks,
                showCreate: true,
                onCreateTournament: widget.callbacks.onCreateTournament != null
                    ? () => widget.callbacks.onCreateTournament!(context)
                    : null,
              ),
              _TournamentList(
                tournaments: _applyFilters(state.publicTournamentsWithHostFlag),
                isLoading: state.isLoading,
                error: state.error,
                emptyIcon: Icons.explore_rounded,
                emptyTitle: 'No tournaments found',
                emptyMessage: 'Try a different format or search term',
                onRefresh: () async => ref
                    .read(playTournamentsControllerProvider.notifier)
                    .refresh(),
                callbacks: widget.callbacks,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Tournament list ──────────────────────────────────────────────────────────

class _TournamentList extends StatelessWidget {
  const _TournamentList({
    required this.tournaments,
    required this.isLoading,
    required this.error,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.onRefresh,
    required this.callbacks,
    this.showCreate = false,
    this.onCreateTournament,
  });

  final List<PlayTournament> tournaments;
  final bool isLoading;
  final String? error;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final Future<void> Function() onRefresh;
  final PlayTabCallbacks callbacks;
  final bool showCreate;
  final VoidCallback? onCreateTournament;

  @override
  Widget build(BuildContext context) {
    if (isLoading && tournaments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null && tournaments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Could not load', style: TextStyle(color: context.fgSub)),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRefresh, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (tournaments.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),
            _EmptyState(
              icon: emptyIcon,
              title: emptyTitle,
              message: emptyMessage,
              actionLabel: showCreate ? 'Create Tournament' : null,
              onAction: showCreate ? onCreateTournament : null,
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: tournaments.length,
        itemBuilder: (_, i) => TournamentCard(
          tournament: tournaments[i],
          isAlternate: i.isOdd,
          onTap: callbacks.onNavigateToTournament != null
              ? () => callbacks.onNavigateToTournament!(
                    context,
                    tournaments[i].id,
                    tournaments[i].slug,
                    tournaments[i].isHost,
                  )
              : null,
        ),
      ),
    );
  }
}

// ─── Tab label ────────────────────────────────────────────────────────────────

class _TabLabel extends StatelessWidget {
  const _TabLabel(
      {required this.label, required this.count, required this.loading});
  final String label;
  final int count;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (!loading && count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: context.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                    color: context.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Filter chip (same style as match tab) ────────────────────────────────────

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
        padding: const EdgeInsets.symmetric(horizontal: 14),
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
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Format chip ──────────────────────────────────────────────────────────────

class _FormatChip extends StatelessWidget {
  const _FormatChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? context.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: selected ? context.accent : context.stroke),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? context.ctaFg : context.fgSub,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── Pulsing dot ──────────────────────────────────────────────────────────────

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

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: context.accentBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: context.accent, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: context.fg,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: TextStyle(color: context.fgSub, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
