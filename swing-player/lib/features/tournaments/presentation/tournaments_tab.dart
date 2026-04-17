import "package:cached_network_image/cached_network_image.dart";
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/data/profile_repository.dart';
import '../data/tournaments_repository.dart';
import '../domain/tournament_models.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final _myTournamentsProvider =
    FutureProvider.autoDispose<List<PlayerTournament>>(
  (ref) => ref.watch(tournamentsRepositoryProvider).fetchMyTournaments(),
);

// My-tournaments local search (Participated + Hosted tabs)
final _myTournamentsSearchProvider =
    StateProvider.autoDispose<String>((_) => '');

// Explore state
final _exploreQueryProvider = StateProvider.autoDispose<String>((_) => '');
final _exploreFormatProvider = StateProvider.autoDispose<String>((_) => '');
final _exploreCityProvider = StateProvider.autoDispose<String>((_) => '');

final _exploreProvider =
    FutureProvider.autoDispose<List<PlayerTournament>>((ref) {
  final q = ref.watch(_exploreQueryProvider);
  final format = ref.watch(_exploreFormatProvider);
  final city = ref.watch(_exploreCityProvider);
  return ref.watch(tournamentsRepositoryProvider).fetchPublicTournaments(
        query: q.trim().isEmpty ? null : q.trim(),
        city: city.trim().isEmpty ? null : city.trim(),
        format: format.isEmpty ? null : format,
      );
});

// ── Tab ───────────────────────────────────────────────────────────────────────

class TournamentsTab extends ConsumerStatefulWidget {
  const TournamentsTab({super.key, this.currentCity});
  final String? currentCity;

  @override
  ConsumerState<TournamentsTab> createState() => _TournamentsTabState();
}

class _TournamentsTabState extends ConsumerState<TournamentsTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _profileRepo = ProfileRepository();
  String _locationLabel = 'Nearby';
  Timer? _searchDebounce;
  final _mySearchCtrl = TextEditingController();

  static const _formats = ['', 'T10', 'T20', 'ONE_DAY'];
  static const _formatLabels = ['All', 'T10', 'T20', 'ODI'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    if (widget.currentCity != null &&
        widget.currentCity!.isNotEmpty &&
        widget.currentCity != 'Fetching...') {
      _locationLabel = widget.currentCity!;
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchDebounce?.cancel();
    _mySearchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(_exploreQueryProvider.notifier).state = value;
    });
  }

  Future<void> _openLocationSheet() async {
    final searchCtrl = TextEditingController();
    final searchFocus = FocusNode();
    Timer? debounce;
    List<CitySuggestion> suggestions = const [];
    bool searching = false;
    var latestQuery = '';
    var sheetOpen = true;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          Future<void> handleQuery(String value) async {
            final query = value.trim();
            latestQuery = query;
            debounce?.cancel();
            if (query.length < 2) {
              if (!sheetOpen || !ctx.mounted) return;
              setSheet(() {
                suggestions = const [];
                searching = false;
              });
              return;
            }
            if (!sheetOpen || !ctx.mounted) return;
            setSheet(() => searching = true);
            debounce = Timer(const Duration(milliseconds: 220), () async {
              try {
                final results = await _profileRepo.searchCities(query);
                if (!mounted ||
                    !sheetOpen ||
                    !ctx.mounted ||
                    latestQuery != query) {
                  return;
                }
                setSheet(() {
                  suggestions = results;
                  searching = false;
                });
              } catch (_) {
                if (!mounted || !sheetOpen || !ctx.mounted) return;
                setSheet(() {
                  suggestions = const [];
                  searching = false;
                });
              }
            });
          }

          return Container(
            decoration: BoxDecoration(
              color: ctx.bg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: MediaQuery.of(ctx).size.height * 0.72,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: ctx.stroke.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Location',
                                style: TextStyle(
                                    color: ctx.fg,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5)),
                            const SizedBox(height: 6),
                            Text('Filter tournaments by city',
                                style:
                                    TextStyle(color: ctx.fgSub, fontSize: 14)),
                            const SizedBox(height: 24),
                            Container(
                              height: 52,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: ctx.panel.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search_rounded,
                                      color: ctx.fgSub, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: searchCtrl,
                                      focusNode: searchFocus,
                                      autofocus: true,
                                      onChanged: handleQuery,
                                      cursorColor: ctx.accent,
                                      style: TextStyle(
                                          color: ctx.fg,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                      decoration: InputDecoration(
                                        hintText: 'Search for a city...',
                                        hintStyle: TextStyle(
                                            color: ctx.fgSub
                                                .withValues(alpha: 0.5),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                        border: InputBorder.none,
                                        isCollapsed: true,
                                      ),
                                    ),
                                  ),
                                  if (searching)
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: ctx.accent),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: suggestions.isEmpty
                            ? Center(
                                child: Text(
                                  searching
                                      ? 'Searching...'
                                      : 'Type at least 2 letters to search',
                                  style:
                                      TextStyle(color: ctx.fgSub, fontSize: 12),
                                ),
                              )
                            : ListView.builder(
                                itemCount: suggestions.length,
                                itemBuilder: (_, i) {
                                  final s = suggestions[i];
                                  return ListTile(
                                    leading: Icon(Icons.location_on_rounded,
                                        color: ctx.accent, size: 18),
                                    title: Text(s.label,
                                        style: TextStyle(
                                            color: ctx.fg,
                                            fontWeight: FontWeight.w600)),
                                    onTap: () {
                                      setState(() => _locationLabel = s.label);
                                      ref
                                          .read(_exploreCityProvider.notifier)
                                          .state = s.label;
                                      Navigator.of(sheetCtx).pop();
                                    },
                                  );
                                },
                              ),
                      ),
                      if (suggestions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _locationLabel = 'Nearby');
                              ref.read(_exploreCityProvider.notifier).state =
                                  '';
                              Navigator.of(sheetCtx).pop();
                            },
                            child: Text('Clear location filter',
                                style:
                                    TextStyle(color: ctx.fgSub, fontSize: 13)),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    sheetOpen = false;
    debounce?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header: location + create ──────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.stroke)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Location row (mirrors booking page)
                  InkWell(
                    onTap: _openLocationSheet,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_rounded,
                              color: context.accent, size: 15),
                          const SizedBox(width: 5),
                          Text(
                            _locationLabel
                                .split(',')
                                .first
                                .trim()
                                .toUpperCase(),
                            style: TextStyle(
                              color: context.fg,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(Icons.keyboard_arrow_down_rounded,
                              color: context.fgSub, size: 15),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  _CreateButton(),
                ],
              ),
              const SizedBox(height: 16),
              // ── Tabs ──────────────────────────────────────────────────
              ref.watch(_myTournamentsProvider).when(
                    data: (all) {
                      final participatedCount = all
                          .where((t) => t.isParticipating && !t.isHost)
                          .length;
                      final hostedCount = all.where((t) => t.isHost).length;

                      return TabBar(
                        controller: _tabs,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorColor: context.accent,
                        indicatorWeight: 3,
                        indicatorSize: TabBarIndicatorSize.label,
                        dividerColor: Colors.transparent,
                        labelColor: context.fg,
                        unselectedLabelColor: context.fgSub,
                        labelPadding: const EdgeInsets.only(right: 28),
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                        tabs: [
                          Tab(text: '$participatedCount Participated'),
                          Tab(text: '$hostedCount Hosted'),
                          ref.watch(_exploreProvider).when(
                                data: (list) =>
                                    Tab(text: '${list.length} Explore'),
                                loading: () => const Tab(text: 'Explore'),
                                error: (_, __) => const Tab(text: 'Explore'),
                              ),
                        ],
                      );
                    },
                    loading: () => _TabBarPlaceholder(controller: _tabs),
                    error: (_, __) => _TabBarPlaceholder(controller: _tabs),
                  ),
            ],
          ),
        ),

        // ── Smart filter (Participated + Hosted only) ──────────────────
        AnimatedBuilder(
          animation: _tabs,
          builder: (_, __) {
            final show = _tabs.index < 2;
            return AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: show
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: _TournamentSearchBar(
                  controller: _mySearchCtrl,
                  onChanged: (v) =>
                      ref.read(_myTournamentsSearchProvider.notifier).state = v,
                ),
              ),
              secondChild: const SizedBox(width: double.infinity),
            );
          },
        ),

        // ── Tab content ────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _ParticipatedTab(),
              _HostedTab(),
              _ExploreTab(
                formats: _formats,
                formatLabels: _formatLabels,
                onSearchChanged: _onSearchChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabBarPlaceholder extends StatelessWidget {
  const _TabBarPlaceholder({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      tabs: const [
        Tab(text: 'Participated'),
        Tab(text: 'Hosted'),
        Tab(text: 'Explore'),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PARTICIPATED TAB
// ══════════════════════════════════════════════════════════════════════════════

class _ParticipatedTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_myTournamentsProvider);
    final q = ref.watch(_myTournamentsSearchProvider).trim().toLowerCase();
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) =>
          _ErrorState(onRetry: () => ref.invalidate(_myTournamentsProvider)),
      data: (all) {
        final list = all
            .where((t) => t.isParticipating && !t.isHost)
            .where((t) => _matchesQuery(t, q))
            .toList();
        if (list.isEmpty) {
          return _EmptyState(
            icon: Icons.sports_cricket_rounded,
            title: q.isEmpty ? 'Not in any tournament' : 'No results',
            message: q.isEmpty
                ? 'Join a tournament through the Explore tab'
                : 'No tournaments match "$q"',
            actionLabel: 'Explore',
            onAction: (_) {},
          );
        }
        return RefreshIndicator(
          color: context.accent,
          backgroundColor: context.surf,
          onRefresh: () async => ref.invalidate(_myTournamentsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _TournamentCard(tournament: list[i]),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HOSTED TAB
// ══════════════════════════════════════════════════════════════════════════════

class _HostedTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_myTournamentsProvider);
    final q = ref.watch(_myTournamentsSearchProvider).trim().toLowerCase();
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) =>
          _ErrorState(onRetry: () => ref.invalidate(_myTournamentsProvider)),
      data: (all) {
        final list = all
            .where((t) => t.isHost)
            .where((t) => _matchesQuery(t, q))
            .toList();
        if (list.isEmpty) {
          return _EmptyState(
            icon: Icons.emoji_events_rounded,
            title: q.isEmpty ? 'No hosted tournaments' : 'No results',
            message: q.isEmpty
                ? 'Create your first tournament and manage it here'
                : 'No tournaments match "$q"',
            actionLabel: 'Create Tournament',
            onAction: (context) => context.push('/create-tournament'),
          );
        }
        return RefreshIndicator(
          color: context.accent,
          backgroundColor: context.surf,
          onRefresh: () async => ref.invalidate(_myTournamentsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _TournamentCard(tournament: list[i]),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// EXPLORE TAB
// ══════════════════════════════════════════════════════════════════════════════

class _ExploreTab extends ConsumerStatefulWidget {
  const _ExploreTab({
    required this.formats,
    required this.formatLabels,
    required this.onSearchChanged,
  });
  final List<String> formats;
  final List<String> formatLabels;
  final ValueChanged<String> onSearchChanged;

  @override
  ConsumerState<_ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends ConsumerState<_ExploreTab> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exploreAsync = ref.watch(_exploreProvider);
    final selectedFormat = ref.watch(_exploreFormatProvider);

    return Column(
      children: [
        // ── Search bar ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.stroke),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(Icons.search_rounded, color: context.fgSub, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: widget.onSearchChanged,
                    style: TextStyle(
                        color: context.fg,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Search by name or city...',
                      hintStyle: TextStyle(color: context.fgSub, fontSize: 14),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                if (_searchCtrl.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      widget.onSearchChanged('');
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(Icons.close_rounded,
                          color: context.fgSub, size: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ── Format chips ─────────────────────────────────────────────
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: widget.formats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _FormatChip(
              label: widget.formatLabels[i],
              selected: selectedFormat == widget.formats[i],
              onTap: () => ref.read(_exploreFormatProvider.notifier).state =
                  widget.formats[i],
            ),
          ),
        ),

        // ── Results ──────────────────────────────────────────────────
        Expanded(
          child: exploreAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) =>
                _ErrorState(onRetry: () => ref.invalidate(_exploreProvider)),
            data: (list) {
              if (list.isEmpty) {
                return _ExploreEmpty(city: ref.watch(_exploreCityProvider));
              }
              return RefreshIndicator(
                color: context.accent,
                backgroundColor: context.surf,
                onRefresh: () async => ref.invalidate(_exploreProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _TournamentCard(tournament: list[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _CreateButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/create-tournament'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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

class _TournamentCard extends StatelessWidget {
  const _TournamentCard({required this.tournament});
  final PlayerTournament tournament;

  void _openTournament(BuildContext context, PlayerTournament t) {
    if (t.isHost) {
      context.push('/host-tournament/${t.id}');
      return;
    }
    context.push('/tournament/${t.slug ?? t.id}');
  }

  @override
  Widget build(BuildContext context) {
    final t = tournament;
    final statusColor = _statusColor(t.status, context);

    return GestureDetector(
      onTap: () => _openTournament(context, t),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.stroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.accentBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.stroke),
                    image: t.logoUrl != null
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(t.logoUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: t.logoUrl == null
                      ? Icon(Icons.emoji_events_rounded,
                          color: context.accent, size: 22)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          _FormatBadge(format: t.format),
                          const SizedBox(width: 6),
                          if (t.isHost)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: context.gold.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('Host',
                                  style: TextStyle(
                                      color: context.gold,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(_statusLabel(t.status),
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.groups_rounded, size: 13, color: context.fgSub),
                const SizedBox(width: 4),
                Text('${t.teamCount}/${t.maxTeams} teams',
                    style: TextStyle(color: context.fgSub, fontSize: 12)),
                if (t.city != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.location_on_rounded,
                      size: 12, color: context.fgSub),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      t.venueName != null
                          ? '${t.venueName}, ${t.city}'
                          : t.city!,
                      style: TextStyle(color: context.fgSub, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const Spacer(),
                if (t.entryFee != null && t.entryFee! > 0) ...[
                  const SizedBox(width: 8),
                  Text('₹${t.entryFee}',
                      style: TextStyle(
                          color: context.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _dateRange(t.startDate, t.endDate),
              style: TextStyle(color: context.fgSub, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

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
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? context.accent : context.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? context.accent : context.stroke),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : context.fgSub,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _FormatBadge extends StatelessWidget {
  const _FormatBadge({required this.format});
  final String format;

  String get _label => switch (format) {
        'ONE_DAY' => 'ODI',
        'TWO_INNINGS' => 'Test',
        _ => format,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: context.stroke),
      ),
      child: Text(_label,
          style: TextStyle(
              color: context.fgSub, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
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
  final void Function(BuildContext) onAction;

  @override
  Widget build(BuildContext context) {
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
              child: Icon(icon, color: context.fgSub, size: 28),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(message,
                style: TextStyle(color: context.fgSub, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => onAction(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                decoration: BoxDecoration(
                  color: context.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(actionLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreEmpty extends StatelessWidget {
  const _ExploreEmpty({required this.city});
  final String city;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, color: context.fgSub, size: 40),
          const SizedBox(height: 10),
          Text(
            city.isEmpty ? 'No tournaments found' : 'No tournaments in $city',
            style: TextStyle(
                color: context.fgSub,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text('Try a different search or format',
              style: TextStyle(color: context.fgSub, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Could not load tournaments',
              style: TextStyle(color: context.fgSub)),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// ── Tournament search bar ─────────────────────────────────────────────────────

class _TournamentSearchBar extends StatelessWidget {
  const _TournamentSearchBar(
      {required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search_rounded, color: context.fgSub, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(
                  color: context.fg, fontSize: 13, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Filter by name, venue or team…',
                hintStyle: TextStyle(color: context.fgSub, fontSize: 13),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child:
                    Icon(Icons.close_rounded, color: context.fgSub, size: 15),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Utilities ──────────────────────────────────────────────────────────────────

bool _matchesQuery(PlayerTournament t, String q) {
  if (q.isEmpty) return true;
  return t.name.toLowerCase().contains(q) ||
      (t.city?.toLowerCase().contains(q) ?? false) ||
      (t.venueName?.toLowerCase().contains(q) ?? false);
}

Color _statusColor(String status, BuildContext context) => switch (status) {
      'ONGOING' => context.success,
      'UPCOMING' => context.gold,
      'COMPLETED' => context.fgSub,
      _ => context.fgSub,
    };

String _statusLabel(String status) => switch (status) {
      'ONGOING' => 'Live',
      'UPCOMING' => 'Upcoming',
      'COMPLETED' => 'Completed',
      'CANCELLED' => 'Cancelled',
      _ => status,
    };

String _dateRange(DateTime start, DateTime? end) {
  final fmt = DateFormat('d MMM');
  if (end == null) return fmt.format(start);
  return '${fmt.format(start)} – ${fmt.format(end)}';
}
