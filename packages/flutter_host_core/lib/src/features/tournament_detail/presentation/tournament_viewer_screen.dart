import 'dart:convert';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../theme/host_colors.dart';
import '../data/tournament_detail_repository.dart';
import '../domain/tournament_detail_models.dart';

// ── Callbacks ─────────────────────────────────────────────────────────────────

class TournamentViewerCallbacks {
  const TournamentViewerCallbacks({
    this.onBack,
    this.onNavigateToMatch,
    this.onNavigateToTeam,
  });

  final VoidCallback? onBack;
  final void Function(String matchId)? onNavigateToMatch;
  final void Function(String teamId)? onNavigateToTeam;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class HostTournamentViewerScreen extends ConsumerStatefulWidget {
  const HostTournamentViewerScreen({
    super.key,
    required this.slug,
    this.callbacks = const TournamentViewerCallbacks(),
  });

  final String slug;
  final TournamentViewerCallbacks callbacks;

  @override
  ConsumerState<HostTournamentViewerScreen> createState() =>
      _HostTournamentViewerScreenState();
}

class _HostTournamentViewerScreenState
    extends ConsumerState<HostTournamentViewerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(hostTournamentDetailProvider(widget.slug));

    return Scaffold(
      backgroundColor: context.bg,
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorBody(
          onRetry: () => ref.invalidate(hostTournamentDetailProvider(widget.slug)),
        ),
        data: (tournament) => _DetailBody(
          tournament: tournament,
          slug: widget.slug,
          tabs: _tabs,
          callbacks: widget.callbacks,
        ),
      ),
    );
  }
}

// ── Detail body ───────────────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.tournament,
    required this.slug,
    required this.tabs,
    required this.callbacks,
  });
  final TournamentDetailModel tournament;
  final String slug;
  final TabController tabs;
  final TournamentViewerCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (ctx, _) => [
        SliverToBoxAdapter(
          child: _TournamentHeader(
            tournament: tournament,
            onBack: callbacks.onBack ?? () => Navigator.of(context).maybePop(),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(controller: tabs, bg: context.bg),
        ),
      ],
      body: TabBarView(
        controller: tabs,
        children: [
          _OverviewTab(tournament: tournament),
          _MatchesTab(slug: slug, tournament: tournament, callbacks: callbacks),
          _StandingsTab(slug: slug, tournament: tournament),
          _LeaderboardTab(
            slug: slug,
            tournamentName: tournament.name,
            tournamentStatus: tournament.status,
          ),
          _TeamsTab(tournament: tournament, callbacks: callbacks),
        ],
      ),
    );
  }
}

// ── Tab bar delegate ──────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate({required this.controller, required this.bg});
  final TabController controller;
  final Color bg;

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: context.stroke)),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: context.accent,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelColor: context.accent,
        unselectedLabelColor: context.fgSub,
        labelPadding: const EdgeInsets.only(right: 24, left: 4),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Matches'),
          Tab(text: 'Standings'),
          Tab(text: 'Leaderboard'),
          Tab(text: 'Teams'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate old) =>
      old.controller != controller;
}

// ── Tournament header ─────────────────────────────────────────────────────────

class _TournamentHeader extends StatelessWidget {
  const _TournamentHeader({required this.tournament, required this.onBack});
  final TournamentDetailModel tournament;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final t = tournament;
    final topPad = MediaQuery.of(context).padding.top;
    const coverH = 180.0;
    const logoSize = 72.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Cover ──────────────────────────────────────────────────────────
        SizedBox(
          height: coverH,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (t.coverUrl != null)
                Image.network(t.coverUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _accentGradient(context))
              else
                _accentGradient(context),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.35, 0.65, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.72),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: topPad + 8,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final shareText =
                            '🏆 ${t.name}\n📍 ${t.city ?? ''}\n📅 ${DateFormat('d MMM yyyy').format(t.startDate)}\n\nJoin on Swing!';
                        Share.share(shareText.trim());
                      },
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.ios_share_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Info below cover ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(0, -28),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.bg, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        image: t.logoUrl != null
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(t.logoUrl!),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: t.logoUrl == null
                          ? Icon(Icons.emoji_events_rounded,
                              color: context.accent, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            t.name,
                            style: TextStyle(
                              color: context.fg,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                              height: 1.15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  t.resolvedOrganiserName,
                                  style: TextStyle(
                                    color: context.fgSub,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (t.isVerified || t.isSwingOfficial) ...[
                                const SizedBox(width: 3),
                                Icon(Icons.verified_rounded,
                                    color: context.accent, size: 12),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _TournamentFollowButton(tournamentId: t.id),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -20),
                child: Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: [
                    _StatusBadge(status: t.status),
                    _FormatBadge(format: t.format),
                    _BallTypeBadge(ballType: t.ballType),
                    _TournamentFormatBadge(format: t.tournamentFormat),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -14),
                child: Row(
                  children: [
                    Icon(Icons.groups_rounded, size: 13, color: context.fgSub),
                    const SizedBox(width: 4),
                    Text('${t.confirmedTeamCount}/${t.maxTeams} teams',
                        style:
                            TextStyle(color: context.fgSub, fontSize: 12)),
                    if (t.city != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.location_on_rounded,
                          size: 12, color: context.fgSub),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          t.venueName != null
                              ? '${t.venueName}, ${t.city}'
                              : t.city!,
                          style:
                              TextStyle(color: context.fgSub, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      _dateRange(t.startDate, t.endDate),
                      style: TextStyle(
                          color: context.fgSub,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _accentGradient(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.accent.withValues(alpha: 0.35),
              context.accent.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );
}

// ── Follow button ─────────────────────────────────────────────────────────────

class _TournamentFollowButton extends ConsumerStatefulWidget {
  const _TournamentFollowButton({required this.tournamentId});
  final String tournamentId;

  @override
  ConsumerState<_TournamentFollowButton> createState() =>
      _TournamentFollowButtonState();
}

class _TournamentFollowButtonState
    extends ConsumerState<_TournamentFollowButton> {
  bool _isFollowing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    try {
      final repo = ref.read(hostTournamentDetailRepositoryProvider);
      final following = await repo.getFollowStatus(widget.tournamentId);
      if (mounted) setState(() { _isFollowing = following; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(hostTournamentDetailRepositoryProvider);
      if (_isFollowing) {
        await repo.unfollowTournament(widget.tournamentId);
        if (mounted) setState(() => _isFollowing = false);
      } else {
        await repo.followTournament(widget.tournamentId);
        if (mounted) setState(() => _isFollowing = true);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[TournamentFollow] error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update follow status')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.accent;
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _isFollowing ? context.accentBg : accent,
          borderRadius: BorderRadius.circular(20),
          border: _isFollowing ? Border.all(color: accent) : null,
        ),
        child: _isLoading
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _isFollowing ? accent : context.bg),
              )
            : Text(
                _isFollowing ? 'Following' : 'Follow',
                style: TextStyle(
                  color: _isFollowing ? accent : context.bg,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// OVERVIEW TAB
// ══════════════════════════════════════════════════════════════════════════════

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.tournament});
  final TournamentDetailModel tournament;

  @override
  Widget build(BuildContext context) {
    final t = tournament;
    final fmt = DateFormat('EEE, d MMM yyyy');

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      children: [
        if (t.status == 'UPCOMING' &&
            (t.entryFee != null || t.earlyBirdFee != null))
          _EntryFeeCard(tournament: t),
        _OverviewFactsCard(
          items: [
            _OverviewFact(
              icon: Icons.calendar_today_rounded,
              label: 'Start',
              value: fmt.format(t.startDate),
            ),
            if (t.endDate != null)
              _OverviewFact(
                icon: Icons.event_rounded,
                label: 'End',
                value: fmt.format(t.endDate!),
              ),
            if (t.venueName != null)
              _OverviewFact(
                icon: Icons.stadium_rounded,
                label: 'Venue',
                value: t.venueName!,
              ),
            if (t.city != null)
              _OverviewFact(
                icon: Icons.location_on_rounded,
                label: 'City',
                value: t.city!,
              ),
            _OverviewFact(
              icon: Icons.sports_cricket_rounded,
              label: 'Format',
              value: _formatLabel(t.format),
            ),
            _OverviewFact(
              icon: Icons.account_tree_rounded,
              label: 'Structure',
              value: _tournamentFormatLabel(t.tournamentFormat),
            ),
            _OverviewFact(
              icon: Icons.radio_button_checked_rounded,
              label: 'Ball',
              value: _ballTypeLabel(t.ballType),
            ),
          ],
        ),
        if (t.prizePool != null && t.prizePool!.isNotEmpty) ...[
          const SizedBox(height: 14),
          _PrizePoolCard(prizePool: t.prizePool!),
        ],
        if (t.description != null && t.description!.isNotEmpty) ...[
          const SizedBox(height: 14),
          _TextCard(title: 'About', body: t.description!),
        ],
        if (t.rules != null && t.rules!.isNotEmpty) ...[
          const SizedBox(height: 14),
          _TextCard(title: 'Rules', body: t.rules!),
        ],
        if (t.highlights.isNotEmpty) ...[
          const SizedBox(height: 14),
          _HighlightsSection(highlights: t.highlights),
        ],
        const SizedBox(height: 14),
        _OrganiserCard(tournament: t),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MATCHES TAB
// ══════════════════════════════════════════════════════════════════════════════

enum _MatchFilter { all, live, scheduled, completed }

(TournamentMatchInnings?, TournamentMatchInnings?) _resolveTeamInningsPair({
  required List<TournamentMatchInnings> innings,
  required String teamAName,
  required String teamBName,
}) {
  if (innings.isEmpty) return (null, null);

  final aNorm = _normalizeTeamName(teamAName);
  final bNorm = _normalizeTeamName(teamBName);

  final aScores = <int>[];
  final bScores = <int>[];
  for (final inn in innings) {
    aScores.add(_sideMatchScore(
        battingTeamRaw: inn.battingTeam,
        selfNorm: aNorm,
        otherNorm: bNorm,
        side: 'A'));
    bScores.add(_sideMatchScore(
        battingTeamRaw: inn.battingTeam,
        selfNorm: bNorm,
        otherNorm: aNorm,
        side: 'B'));
  }

  int bestA = -1, bestB = -1, bestScore = -1;
  for (var ai = 0; ai < innings.length; ai++) {
    for (var bi = 0; bi < innings.length; bi++) {
      if (ai == bi) continue;
      final score = aScores[ai] + bScores[bi];
      if (score > bestScore) {
        bestScore = score;
        bestA = ai;
        bestB = bi;
      }
    }
  }

  TournamentMatchInnings? a =
      bestA >= 0 && aScores[bestA] >= 40 ? innings[bestA] : null;
  TournamentMatchInnings? b =
      bestB >= 0 && bScores[bestB] >= 40 ? innings[bestB] : null;

  if (a == null && b == null && innings.length >= 2) {
    a = innings[0];
    b = innings[1];
  } else if (a != null && b == null) {
    b = innings.where((i) => i != a).firstOrNull;
  } else if (b != null && a == null) {
    a = innings.where((i) => i != b).firstOrNull;
  }

  return (a, b);
}

int _sideMatchScore({
  required String battingTeamRaw,
  required String selfNorm,
  required String otherNorm,
  required String side,
}) {
  final candidate = _normalizeTeamName(battingTeamRaw);
  if (candidate.isEmpty) return 0;
  final compact = candidate.replaceAll(' ', '');
  final isA = side == 'A';

  final sideAliases =
      isA ? const {'a', 'teama', 'team1', '1'} : const {'b', 'teamb', 'team2', '2'};
  if (sideAliases.contains(compact)) return 100;
  if (candidate == selfNorm) return 95;
  if (candidate == otherNorm) return 0;
  if (selfNorm.isNotEmpty &&
      (candidate.contains(selfNorm) || selfNorm.contains(candidate))) return 70;
  final selfWords = selfNorm.split(' ').where((w) => w.isNotEmpty).toSet();
  final candWords = candidate.split(' ').where((w) => w.isNotEmpty).toSet();
  final overlap = selfWords.intersection(candWords).length;
  if (overlap >= 2) return 55;
  if (overlap == 1) return 40;
  return 0;
}

String _normalizeTeamName(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

class _MatchesTab extends ConsumerStatefulWidget {
  const _MatchesTab(
      {required this.slug,
      required this.tournament,
      required this.callbacks});
  final String slug;
  final TournamentDetailModel tournament;
  final TournamentViewerCallbacks callbacks;

  @override
  ConsumerState<_MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends ConsumerState<_MatchesTab> {
  _MatchFilter _filter = _MatchFilter.all;
  String? _selectedTeam;

  bool _matchesFilter(TournamentMatchModel m) {
    final s = m.status.toUpperCase();
    return switch (_filter) {
      _MatchFilter.all => true,
      _MatchFilter.live => s == 'LIVE' || s == 'IN_PROGRESS',
      _MatchFilter.scheduled => s == 'UPCOMING' || s == 'SCHEDULED',
      _MatchFilter.completed => s == 'COMPLETED',
    };
  }

  bool _matchesTeamFilter(TournamentMatchModel m, String? teamName) {
    if (teamName == null || teamName.isEmpty) return true;
    return m.teamAName == teamName || m.teamBName == teamName;
  }

  Future<void> _openTeamSelector(
      BuildContext context, List<String> teams) async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          _TeamSelectorSheet(teams: teams, selectedTeam: _selectedTeam),
    );
    if (!mounted) return;
    setState(() => _selectedTeam = selected);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(hostTournamentMatchesProvider(widget.slug));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const _EmptyTab(
          icon: Icons.sports_cricket_rounded,
          message: 'No matches recorded yet'),
      data: (allMatches) {
        final teams = <String>{
          for (final m in allMatches) ...[m.teamAName.trim(), m.teamBName.trim()]
        }.where((n) => n.isNotEmpty).toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

        final selectedTeam =
            teams.contains(_selectedTeam) ? _selectedTeam : null;
        final matches = allMatches
            .where(_matchesFilter)
            .where((m) => _matchesTeamFilter(m, selectedTeam))
            .toList();
        final totalMatches = allMatches.length;

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.stroke),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.filter_alt_rounded,
                          size: 14, color: context.fgSub),
                      const SizedBox(width: 6),
                      Text(
                        'Matches: ${matches.length}/$totalMatches',
                        style: TextStyle(
                            color: context.fgSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      if (selectedTeam != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(selectedTeam,
                              style: TextStyle(
                                  color: context.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 8),
                      ],
                      GestureDetector(
                        onTap: teams.isEmpty
                            ? null
                            : () => _openTeamSelector(context, teams),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: context.bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.stroke),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.groups_rounded,
                                  size: 13, color: context.fgSub),
                              const SizedBox(width: 5),
                              Text('Team',
                                  style: TextStyle(
                                      color: context.fgSub,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(width: 4),
                              Icon(Icons.expand_more_rounded,
                                  size: 13, color: context.fgSub),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final f in _MatchFilter.values)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _MatchFilterChip(
                              label: switch (f) {
                                _MatchFilter.all => 'All',
                                _MatchFilter.live => 'Live',
                                _MatchFilter.scheduled => 'Scheduled',
                                _MatchFilter.completed => 'Completed',
                              },
                              selected: _filter == f,
                              isLive: f == _MatchFilter.live,
                              onTap: () => setState(() => _filter = f),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: matches.isEmpty
                  ? _EmptyTab(
                      icon: Icons.sports_cricket_rounded,
                      message: selectedTeam != null
                          ? 'No ${_filter.name} matches for $selectedTeam'
                          : _filter == _MatchFilter.all
                              ? (widget.tournament.status == 'UPCOMING'
                                  ? 'Matches will be announced soon'
                                  : 'No matches recorded yet')
                              : 'No ${_filter.name} matches',
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                      children: [
                        for (final entry in _grouped(matches).entries) ...[
                          _GroupHeader(label: entry.key),
                          const SizedBox(height: 8),
                          ...entry.value.map((m) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _MatchCard(
                                    match: m,
                                    onTap: widget.callbacks.onNavigateToMatch),
                              )),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Map<String, List<TournamentMatchModel>> _grouped(
      List<TournamentMatchModel> matches) {
    final grouped = <String, List<TournamentMatchModel>>{};
    for (final m in matches) {
      final key =
          m.groupName ?? (m.round != null ? 'Round ${m.round}' : 'Matches');
      grouped.putIfAbsent(key, () => []).add(m);
    }
    return grouped;
  }
}

class _MatchFilterChip extends StatelessWidget {
  const _MatchFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.isLive = false,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final activeColor = isLive ? context.danger : context.accent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? activeColor : context.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? activeColor : context.stroke),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLive && selected) ...[
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : context.fgSub,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamSelectorSheet extends StatefulWidget {
  const _TeamSelectorSheet(
      {required this.teams, required this.selectedTeam});
  final List<String> teams;
  final String? selectedTeam;

  @override
  State<_TeamSelectorSheet> createState() => _TeamSelectorSheetState();
}

class _TeamSelectorSheetState extends State<_TeamSelectorSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final teams = widget.teams
        .where((t) => _query.trim().isEmpty
            ? true
            : t.toLowerCase().contains(_query.trim().toLowerCase()))
        .toList();

    return SafeArea(
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        decoration: BoxDecoration(
          color: context.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: context.stroke,
                    borderRadius: BorderRadius.circular(99)),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text('Select Team',
                      style: TextStyle(
                          color: context.fg,
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text('${teams.length}',
                      style: TextStyle(
                          color: context.fgSub,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search team',
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: context.fgSub, size: 18),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.stroke)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.stroke)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                children: [
                  _TeamSelectorTile(
                    label: 'All Teams',
                    selected: widget.selectedTeam == null,
                    onTap: () => Navigator.of(context).pop<String?>(null),
                  ),
                  for (final team in teams)
                    _TeamSelectorTile(
                      label: team,
                      selected: widget.selectedTeam == team,
                      onTap: () => Navigator.of(context).pop<String?>(team),
                    ),
                  if (teams.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text('No team found',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: context.fgSub,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
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

class _TeamSelectorTile extends StatelessWidget {
  const _TeamSelectorTile(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials = label
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: selected
              ? context.accent.withValues(alpha: 0.14)
              : context.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected
                  ? context.accent.withValues(alpha: 0.4)
                  : context.stroke),
        ),
        child: Center(
          child: Text(initials.isEmpty ? '?' : initials,
              style: TextStyle(
                  color: selected ? context.accent : context.fgSub,
                  fontSize: 10,
                  fontWeight: FontWeight.w800)),
        ),
      ),
      title: Text(label,
          style: TextStyle(
              color: selected ? context.accent : context.fg,
              fontSize: 13,
              fontWeight: FontWeight.w700)),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: context.accent, size: 18)
          : Icon(Icons.circle_outlined, color: context.fgSub, size: 18),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match, this.onTap});
  final TournamentMatchModel match;
  final void Function(String matchId)? onTap;

  @override
  Widget build(BuildContext context) {
    final m = match;
    final (inningsA, inningsB) = _resolveTeamInningsPair(
      innings: m.innings,
      teamAName: m.teamAName,
      teamBName: m.teamBName,
    );
    final s = m.status.toUpperCase();
    final isLive = s == 'LIVE' || s == 'IN_PROGRESS';
    final isCompleted = s == 'COMPLETED';
    final isScheduled = s == 'UPCOMING' || s == 'SCHEDULED';

    String? resolvedResult = m.result;
    if (resolvedResult == null && isCompleted && inningsA != null && inningsB != null) {
      if (inningsB.totalRuns > inningsA.totalRuns) {
        resolvedResult = '${m.teamBName} won by ${10 - inningsB.totalWickets} wickets';
      } else if (inningsA.totalRuns > inningsB.totalRuns) {
        resolvedResult = '${m.teamAName} won by ${inningsA.totalRuns - inningsB.totalRuns} runs';
      } else {
        resolvedResult = 'Match tied';
      }
    }

    return GestureDetector(
      onTap: onTap != null ? () => onTap!(m.id) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLive
                ? context.danger.withValues(alpha: 0.4)
                : isScheduled
                    ? context.sky.withValues(alpha: 0.3)
                    : context.stroke,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (m.groupName != null || m.round != null)
                  Text(m.groupName ?? 'Round ${m.round}',
                      style: TextStyle(
                          color: context.fgSub,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(
                  isLive
                      ? 'LIVE'
                      : isCompleted
                          ? 'COMPLETED'
                          : isScheduled
                              ? 'SCHEDULED'
                              : s,
                  style: TextStyle(
                    color: isLive
                        ? context.danger
                        : isCompleted
                            ? context.success
                            : context.fgSub,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _SimpleTeamScoreRow(
                teamName: m.teamAName,
                innings: inningsA,
                isCompleted: isCompleted),
            const SizedBox(height: 6),
            _SimpleTeamScoreRow(
                teamName: m.teamBName,
                innings: inningsB,
                isCompleted: isCompleted),
            const SizedBox(height: 8),
            if (isCompleted && resolvedResult != null)
              Row(
                children: [
                  Expanded(
                    child: Text(resolvedResult,
                        style: TextStyle(
                            color: context.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _MatchResultShareSheet(match: m),
                    ),
                    child: Icon(Icons.ios_share_rounded,
                        size: 15, color: context.accent),
                  ),
                ],
              )
            else if (m.scheduledAt != null)
              Text(
                DateFormat('EEE d MMM · h:mm a').format(m.scheduledAt!),
                style: TextStyle(
                    color: context.fgSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
          ],
        ),
      ),
    );
  }
}

class _SimpleTeamScoreRow extends StatelessWidget {
  const _SimpleTeamScoreRow(
      {required this.teamName,
      required this.isCompleted,
      this.innings});
  final String teamName;
  final TournamentMatchInnings? innings;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final inn = innings;
    final score =
        inn != null ? '${inn.totalRuns}/${inn.totalWickets}' : (!isCompleted ? '—' : '-');
    final overs = inn != null ? '(${formatMatchOvers(inn.totalOvers)})' : null;

    return Row(
      children: [
        Expanded(
          child: Text(teamName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: context.fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ),
        Text(score,
            style: TextStyle(
                color: context.fg,
                fontSize: 13,
                fontWeight: FontWeight.w800)),
        if (overs != null) ...[
          const SizedBox(width: 6),
          Text(overs,
              style: TextStyle(
                  color: context.fgSub,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ],
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STANDINGS TAB
// ══════════════════════════════════════════════════════════════════════════════

enum _StandingsView { table, bracket }

class _StandingsTab extends ConsumerStatefulWidget {
  const _StandingsTab({required this.slug, required this.tournament});
  final String slug;
  final TournamentDetailModel tournament;

  @override
  ConsumerState<_StandingsTab> createState() => _StandingsTabState();
}

class _StandingsTabState extends ConsumerState<_StandingsTab> {
  _StandingsView _view = _StandingsView.table;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(hostTournamentStandingsProvider(widget.slug));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const _EmptyTab(
          icon: Icons.leaderboard_rounded,
          message: 'Standings will appear once matches are played'),
      data: (standings) {
        if (standings.isEmpty) {
          return const _EmptyTab(
              icon: Icons.leaderboard_rounded,
              message: 'Standings will appear once matches are played');
        }
        final grouped = <String?, List<TournamentStandingModel>>{};
        for (final s in standings) {
          grouped.putIfAbsent(s.groupName, () => []).add(s);
        }
        final ranked = [...standings]..sort((a, b) {
            final byPoints = b.points.compareTo(a.points);
            if (byPoints != 0) return byPoints;
            return b.netRunRate.compareTo(a.netRunRate);
          });
        return ListView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.stroke)),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _view = _StandingsView.table),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _view == _StandingsView.table
                              ? context.accent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text('Table',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: _view == _StandingsView.table
                                    ? context.bg
                                    : context.fgSub,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _view = _StandingsView.bracket),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _view == _StandingsView.bracket
                              ? context.accent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text('Bracket',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: _view == _StandingsView.bracket
                                    ? context.bg
                                    : context.fgSub,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_view == _StandingsView.table) ...[
              for (final entry in grouped.entries) ...[
                if (entry.key != null) _GroupHeader(label: entry.key!),
                const SizedBox(height: 8),
                _StandingsTable(standings: entry.value),
                const SizedBox(height: 16),
              ],
            ] else
              _StandingsBracketView(standings: ranked),
          ],
        );
      },
    );
  }
}

class _StandingsTable extends StatelessWidget {
  const _StandingsTable({required this.standings});
  final List<TournamentStandingModel> standings;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.stroke)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                    width: 28,
                    child: Text('#',
                        style: TextStyle(
                            color: context.fgSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w700))),
                Expanded(
                    child: Text('Team',
                        style: TextStyle(
                            color: context.fgSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w700))),
                for (final col in ['P', 'W', 'L', 'NR', 'NRR', 'Pts'])
                  SizedBox(
                    width: 36,
                    child: Text(col,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: context.fgSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: context.stroke),
          ...standings.asMap().entries.map((e) {
            final idx = e.key;
            final s = e.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                          width: 28,
                          child: Text('${idx + 1}',
                              style: TextStyle(
                                  color: context.fgSub,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700))),
                      Expanded(
                          child: Text(s.teamName,
                              style: TextStyle(
                                  color: context.fg,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                      for (final val in [
                        '${s.played}',
                        '${s.won}',
                        '${s.lost}',
                        '${s.noResult}',
                        s.netRunRate >= 0
                            ? '+${s.netRunRate.toStringAsFixed(2)}'
                            : s.netRunRate.toStringAsFixed(2),
                        '${s.points}',
                      ])
                        SizedBox(
                          width: 36,
                          child: Text(val,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: val == '${s.points}'
                                      ? context.accent
                                      : context.fg,
                                  fontSize: 12,
                                  fontWeight: val == '${s.points}'
                                      ? FontWeight.w800
                                      : FontWeight.w500)),
                        ),
                    ],
                  ),
                ),
                if (idx < standings.length - 1)
                  Divider(height: 1, color: context.stroke),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _StandingsBracketView extends StatelessWidget {
  const _StandingsBracketView({required this.standings});
  final List<TournamentStandingModel> standings;

  @override
  Widget build(BuildContext context) {
    if (standings.length < 4) {
      return const _EmptyTab(
          icon: Icons.account_tree_rounded,
          message: 'Bracket view appears once at least 4 teams are ranked.');
    }

    final seeds = standings.take(8).toList();
    final quarterPairs = <(TournamentStandingModel, TournamentStandingModel)>[];
    if (seeds.length >= 8) {
      quarterPairs.add((seeds[0], seeds[7]));
      quarterPairs.add((seeds[3], seeds[4]));
      quarterPairs.add((seeds[1], seeds[6]));
      quarterPairs.add((seeds[2], seeds[5]));
    } else {
      quarterPairs.add((seeds[0], seeds[3]));
      quarterPairs.add((seeds[1], seeds[2]));
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.stroke)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BracketColumn(
              title: quarterPairs.length == 4 ? 'Quarterfinals' : 'Semifinals',
              cards: quarterPairs
                  .map((p) => '${p.$1.teamName}  vs  ${p.$2.teamName}')
                  .toList(),
            ),
            const SizedBox(width: 14),
            _BracketColumn(
              title: quarterPairs.length == 4 ? 'Semifinals' : 'Final',
              cards: quarterPairs.length == 4
                  ? const ['Winner QF1 vs Winner QF2', 'Winner QF3 vs Winner QF4']
                  : const ['Winner SF1 vs Winner SF2'],
            ),
            if (quarterPairs.length == 4) ...[
              const SizedBox(width: 14),
              const _BracketColumn(
                  title: 'Final', cards: ['Winner SF1 vs Winner SF2']),
            ],
          ],
        ),
      ),
    );
  }
}

class _BracketColumn extends StatelessWidget {
  const _BracketColumn({required this.title, required this.cards});
  final String title;
  final List<String> cards;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: context.fgSub,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final card in cards) ...[
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                  color: context.bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.stroke)),
              child: Text(card,
                  style: TextStyle(
                      color: context.fg,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
            if (card != cards.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

// ── Highlights ────────────────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════════════════════
// LEADERBOARD TAB
// ══════════════════════════════════════════════════════════════════════════════

class _LeaderboardTab extends ConsumerStatefulWidget {
  const _LeaderboardTab({
    required this.slug,
    required this.tournamentName,
    required this.tournamentStatus,
  });
  final String slug;
  final String tournamentName;
  final String tournamentStatus;

  @override
  ConsumerState<_LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends ConsumerState<_LeaderboardTab> {
  int _section = 0;

  @override
  Widget build(BuildContext context) {
    final lbAsync = ref.watch(hostTournamentLeaderboardProvider(widget.slug));
    return lbAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.leaderboard_rounded, color: context.fgSub, size: 40),
            const SizedBox(height: 12),
            Text('IP leaderboard is being computed',
                style: TextStyle(
                    color: context.fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Updates after each match is scored',
                style: TextStyle(color: context.fgSub, fontSize: 13)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () =>
                  ref.invalidate(hostTournamentLeaderboardProvider(widget.slug)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (lb) {
        final hasData = lb.topBatsmen.isNotEmpty ||
            lb.topBowlers.isNotEmpty ||
            lb.topFielders.isNotEmpty ||
            lb.tournamentTotals.matchesPlayed > 0;
        if (!hasData) {
          return const _EmptyTab(
              icon: Icons.leaderboard_rounded,
              message: 'IP leaderboard updates as matches are scored');
        }
        return _LeaderboardBody(
          lb: lb,
          section: _section,
          onSectionChanged: (i) => setState(() => _section = i),
          tournamentName: widget.tournamentName,
          isProvisional:
              widget.tournamentStatus.toUpperCase() != 'COMPLETED',
        );
      },
    );
  }
}

class _TeamStat {
  String name;
  int played, totalRuns, highScore, totalWickets;
  _TeamStat(this.name)
      : played = 0,
        totalRuns = 0,
        highScore = 0,
        totalWickets = 0;
}

class _LeaderboardBody extends StatefulWidget {
  const _LeaderboardBody({
    required this.lb,
    required this.section,
    required this.onSectionChanged,
    required this.tournamentName,
    required this.isProvisional,
  });
  final TournamentLeaderboardModel lb;
  final int section;
  final ValueChanged<int> onSectionChanged;
  final String tournamentName;
  final bool isProvisional;

  @override
  State<_LeaderboardBody> createState() => _LeaderboardBodyState();
}

class _LeaderboardBodyState extends State<_LeaderboardBody> {
  void _shareCard({int? section}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LeaderboardShareSheet(
        lb: widget.lb,
        section: section ?? widget.section,
        tournamentName: widget.tournamentName,
        isProvisional: widget.isProvisional,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lb = widget.lb;
    final totals = lb.tournamentTotals;
    final sectionLabels = ['Overall', 'Batting', 'Bowling', 'Fielding'];

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.stroke)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Tournament Stats',
                      style: TextStyle(
                          color: context.fg,
                          fontSize: 12,
                          fontWeight: FontWeight.w800)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _FullTournamentShareSheet(
                        lb: lb,
                        tournamentName: widget.tournamentName,
                        isProvisional: widget.isProvisional,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: context.accentBg,
                          borderRadius: BorderRadius.circular(7)),
                      child: Icon(Icons.ios_share_rounded,
                          size: 13, color: context.accent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _StatTile(label: 'Matches', value: '${totals.matchesPlayed}'),
                  _StatTile(label: 'Runs', value: '${totals.totalRuns}'),
                  _StatTile(label: 'Wickets', value: '${totals.totalWickets}'),
                  _StatTile(
                      label: 'IP',
                      value: '${totals.totalIpAwarded}',
                      highlight: true),
                ],
              ),
              const SizedBox(height: 8),
              Text('4s ${totals.totalFours}  •  6s ${totals.totalSixes}',
                  style: TextStyle(
                      color: context.fgSub,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (widget.isProvisional) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: context.warn.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.warn.withValues(alpha: 0.28)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 13, color: context.warn),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Provisional: Rankings can change until tournament is completed.',
                    style: TextStyle(
                        color: context.warn,
                        fontSize: 10,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.stroke)),
          child: Row(
            children: [
              for (var i = 0; i < 4; i++)
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onSectionChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: widget.section == i
                            ? context.accent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(sectionLabels[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: widget.section == i
                                  ? context.bg
                                  : context.fgSub,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (widget.section == 0) ..._buildOverallIp(context, lb),
        if (widget.section == 1) ..._buildBatsmen(context, lb.topBatsmen),
        if (widget.section == 2) ..._buildBowlers(context, lb.topBowlers),
        if (widget.section == 3) ..._buildFielders(context, lb.topFielders),
      ],
    );
  }

  List<Widget> _buildOverallIp(
      BuildContext context, TournamentLeaderboardModel lb) {
    final seen = <String>{};
    final all = [
      ...lb.topBatsmen,
      ...lb.topBowlers,
      ...lb.topFielders,
    ].where((p) => seen.add(p.player.id)).toList()
      ..sort((a, b) => b.totalIp.compareTo(a.totalIp));

    if (all.isEmpty) {
      return [
        const _EmptyTab(
            icon: Icons.leaderboard_rounded,
            message: 'IP rankings will appear as matches are scored'),
      ];
    }
    return [
      _LeaderboardTableHeader(cols: const ['IP', 'Runs', 'Wkts']),
      ...all.take(10).toList().asMap().entries.map((e) => _LeaderboardRow(
            rank: e.key + 1,
            player: e.value,
            values: ['${e.value.totalIp}', '${e.value.runs}', '${e.value.wickets}'],
            ipHighlight: false,
            onShare: e.key == 0 ? () => _shareCard(section: 0) : null,
          )),
    ];
  }

  List<Widget> _buildBatsmen(
      BuildContext context, List<LeaderboardPlayerModel> list) {
    if (list.isEmpty) {
      return [const _EmptyTab(icon: Icons.sports_cricket_rounded, message: 'No batting stats yet')];
    }
    return [
      _LeaderboardTableHeader(cols: const ['Runs', 'SR', 'IP']),
      ...list.take(10).toList().asMap().entries.map((e) => _LeaderboardRow(
            rank: e.key + 1,
            player: e.value,
            values: [
              '${e.value.runs}',
              e.value.strikeRate.toStringAsFixed(1),
              '${e.value.totalIp}',
            ],
            ipHighlight: true,
            onShare: e.key == 0 ? () => _shareCard(section: 1) : null,
          )),
    ];
  }

  List<Widget> _buildBowlers(
      BuildContext context, List<LeaderboardPlayerModel> list) {
    if (list.isEmpty) {
      return [const _EmptyTab(icon: Icons.sports_cricket_rounded, message: 'No bowling stats yet')];
    }
    return [
      _LeaderboardTableHeader(cols: const ['Wkts', 'Econ', 'IP']),
      ...list.take(10).toList().asMap().entries.map((e) => _LeaderboardRow(
            rank: e.key + 1,
            player: e.value,
            values: [
              '${e.value.wickets}',
              e.value.economy.toStringAsFixed(1),
              '${e.value.totalIp}',
            ],
            ipHighlight: true,
            onShare: e.key == 0 ? () => _shareCard(section: 2) : null,
          )),
    ];
  }

  List<Widget> _buildFielders(
      BuildContext context, List<LeaderboardPlayerModel> list) {
    if (list.isEmpty) {
      return [const _EmptyTab(icon: Icons.sports_cricket_rounded, message: 'No fielding stats yet')];
    }
    return [
      _LeaderboardTableHeader(cols: const ['Dismissals', 'IP']),
      ...list.take(10).toList().asMap().entries.map((e) => _LeaderboardRow(
            rank: e.key + 1,
            player: e.value,
            values: ['${e.value.totalDismissals}', '${e.value.totalIp}'],
            ipHighlight: true,
            onShare: e.key == 0 ? () => _shareCard(section: 3) : null,
          )),
    ];
  }
}

class _LeaderboardTableHeader extends StatelessWidget {
  const _LeaderboardTableHeader({required this.cols});
  final List<String> cols;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final baseWidth = cols.length <= 3 ? 46.0 : 40.0;
        final availableForStats =
            (constraints.maxWidth - 32).clamp(0.0, double.infinity);
        final adaptiveWidth =
            cols.isEmpty ? baseWidth : availableForStats / cols.length;
        final colWidth = adaptiveWidth.clamp(34.0, baseWidth);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              SizedBox(
                  width: 24,
                  child: Text('#',
                      style: TextStyle(
                          color: context.fgSub,
                          fontSize: 11,
                          fontWeight: FontWeight.w700))),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: cols
                      .map((c) => SizedBox(
                            width: colWidth,
                            child: Text(c,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: context.fgSub,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.rank,
    required this.player,
    required this.values,
    this.ipHighlight = false,
    this.onShare,
  });
  final int rank;
  final LeaderboardPlayerModel player;
  final List<String> values;
  final bool ipHighlight;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final p = player.player;
    final isTopRank = rank == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isTopRank
            ? context.accent.withValues(alpha: 0.08)
            : context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTopRank
              ? context.accent.withValues(alpha: 0.45)
              : context.stroke,
          width: isTopRank ? 1.2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                  width: 24,
                  child: Text(isTopRank ? '👑' : '$rank',
                      style: TextStyle(
                          color: rank <= 3 ? context.gold : context.fgSub,
                          fontSize: isTopRank ? 13 : 12,
                          fontWeight: FontWeight.w800))),
              const SizedBox(width: 8),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isTopRank
                      ? context.accent.withValues(alpha: 0.18)
                      : context.accentBg,
                  borderRadius: BorderRadius.circular(8),
                  border: isTopRank
                      ? Border.all(
                          color: context.accent.withValues(alpha: 0.45))
                      : null,
                  image: p.avatarUrl != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(p.avatarUrl!),
                          fit: BoxFit.cover)
                      : null,
                ),
                child: p.avatarUrl == null
                    ? Icon(Icons.person_rounded, color: context.fgSub, size: 14)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        style: TextStyle(
                            color: isTopRank ? context.accent : context.fg,
                            fontSize: isTopRank ? 13 : 12,
                            fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (p.username != null && p.username!.isNotEmpty)
                      Text('@${p.username}',
                          style: TextStyle(
                              color: context.fgSub,
                              fontSize: 10,
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (isTopRank && onShare != null)
                GestureDetector(
                  onTap: onShare,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: context.accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(7)),
                    child: Icon(Icons.ios_share_rounded,
                        size: 13, color: context.accent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final colWidth = values.isEmpty
                  ? 72.0
                  : (constraints.maxWidth / values.length).clamp(58.0, 96.0);
              return Row(
                children: values.asMap().entries.map((e) {
                  final isLast = e.key == values.length - 1;
                  final highlighted = (isLast && ipHighlight) || isTopRank;
                  return SizedBox(
                    width: colWidth,
                    child: Text(e.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color:
                                highlighted ? context.accent : context.fg,
                            fontSize: 12,
                            fontWeight: highlighted
                                ? FontWeight.w800
                                : FontWeight.w600)),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PlayerOfTournamentCard extends StatelessWidget {
  const _PlayerOfTournamentCard({
    required this.player,
    required this.tournamentName,
    this.isProvisional = true,
  });
  final LeaderboardPlayerModel player;
  final String tournamentName;
  final bool isProvisional;

  void _share(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _PotShareSheet(player: player, tournamentName: tournamentName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = player.player;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.gold.withValues(alpha: 0.18),
            context.gold.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isProvisional)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: context.warn.withValues(alpha: 0.12),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                border: Border(
                    bottom: BorderSide(
                        color: context.warn.withValues(alpha: 0.2))),
              ),
              child: Row(
                children: [
                  Icon(Icons.hourglass_top_rounded,
                      size: 11, color: context.warn),
                  const SizedBox(width: 5),
                  Text('Provisional — tournament in progress',
                      style: TextStyle(
                          color: context.warn,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: context.accentBg,
                        borderRadius: BorderRadius.circular(14),
                        image: p.avatarUrl != null
                            ? DecorationImage(
                                image:
                                    CachedNetworkImageProvider(p.avatarUrl!),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: p.avatarUrl == null
                          ? Icon(Icons.person_rounded,
                              color: context.fgSub, size: 24)
                          : null,
                    ),
                    const Positioned(
                        top: -6,
                        right: -6,
                        child:
                            Text('👑', style: TextStyle(fontSize: 16))),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Player of the Tournament',
                          style: TextStyle(
                              color: context.gold,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3)),
                      const SizedBox(height: 2),
                      Text(p.name,
                          style: TextStyle(
                              color: context.fg,
                              fontSize: 16,
                              fontWeight: FontWeight.w900)),
                      if (p.username != null)
                        Text('@${p.username}',
                            style: TextStyle(
                                color: context.fgSub, fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => _share(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: context.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8)),
                        child: Icon(Icons.ios_share_rounded,
                            size: 14, color: context.gold),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('${player.totalIp}',
                        style: TextStyle(
                            color: context.gold,
                            fontSize: 22,
                            fontWeight: FontWeight.w900)),
                    Text('IP earned',
                        style:
                            TextStyle(color: context.fgSub, fontSize: 10)),
                    const SizedBox(height: 4),
                    _RankBadge(
                        rankKey: p.rankKey, division: p.rankDivision),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TEAMS TAB
// ══════════════════════════════════════════════════════════════════════════════

class _TeamsTab extends StatelessWidget {
  const _TeamsTab({required this.tournament, required this.callbacks});
  final TournamentDetailModel tournament;
  final TournamentViewerCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    final teams = tournament.teams;
    if (teams.isEmpty) {
      return const _EmptyTab(
          icon: Icons.groups_rounded, message: 'No teams registered yet');
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.4,
      ),
      itemCount: teams.length,
      itemBuilder: (_, i) => _TeamChip(
        team: teams[i],
        onNavigateToTeam: callbacks.onNavigateToTeam,
      ),
    );
  }
}

class _TeamChip extends StatelessWidget {
  const _TeamChip({required this.team, this.onNavigateToTeam});
  final TournamentTeamEntry team;
  final void Function(String teamId)? onNavigateToTeam;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (team.teamId != null && onNavigateToTeam != null)
          ? () => onNavigateToTeam!(team.teamId!)
          : null,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: team.isConfirmed
                  ? context.accent.withValues(alpha: 0.3)
                  : context.stroke),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.accentBg,
                borderRadius: BorderRadius.circular(8),
                image: team.teamLogoUrl != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(team.teamLogoUrl!),
                        fit: BoxFit.cover)
                    : null,
              ),
              child: team.teamLogoUrl == null
                  ? Icon(Icons.groups_rounded,
                      color: context.accent, size: 16)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(team.teamShortName ?? team.teamName,
                      style: TextStyle(
                          color: context.fg,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: team.isConfirmed
                              ? context.success
                              : context.warn,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        team.isConfirmed ? 'Confirmed' : 'Pending',
                        style: TextStyle(
                            color: team.isConfirmed
                                ? context.success
                                : context.fgSub,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (team.teamId != null && onNavigateToTeam != null)
              Icon(Icons.chevron_right_rounded,
                  color: context.fgSub, size: 16),
          ],
        ),
      ),
    );
  }
}

// ── Highlights ────────────────────────────────────────────────────────────────

class _HighlightsSection extends StatelessWidget {
  const _HighlightsSection({required this.highlights});
  final List<TournamentHighlightModel> highlights;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Highlights',
            style: TextStyle(
                color: context.fg,
                fontSize: 13,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        SizedBox(
          height: 126,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: highlights.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _HighlightCard(highlight: highlights[i]),
          ),
        ),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.highlight});
  final TournamentHighlightModel highlight;

  @override
  Widget build(BuildContext context) {
    final thumb = highlight.thumbnailUrl;
    return GestureDetector(
      onTap: () {
        final url = Uri.tryParse(highlight.youtubeUrl);
        if (url != null) launchUrl(url, mode: LaunchMode.externalApplication);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 196,
          child: Stack(
            fit: StackFit.expand,
            children: [
              thumb != null
                  ? Image.network(thumb,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: context.accentBg))
                  : Container(color: context.accentBg),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.72),
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 24),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 8,
                child: Text(
                  highlight.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Leaderboard Share Bottom Sheet ───────────────────────────────────────────

class _LeaderboardShareSheet extends StatefulWidget {
  const _LeaderboardShareSheet({
    required this.lb,
    required this.section,
    required this.tournamentName,
    required this.isProvisional,
  });
  final TournamentLeaderboardModel lb;
  final int section;
  final String tournamentName;
  final bool isProvisional;

  @override
  State<_LeaderboardShareSheet> createState() => _LeaderboardShareSheetState();
}

class _LeaderboardShareSheetState extends State<_LeaderboardShareSheet> {
  BuildContext? _captureBoundaryContext;
  bool _sharing = false;

  Future<void> _capture() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      await Future.delayed(const Duration(milliseconds: 80));
      final boundary =
          _captureBoundaryContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      await Share.shareXFiles(
        [XFile.fromData(bytes, mimeType: 'image/png', name: 'leaderboard.png')],
        text: '🏆 ${widget.tournamentName} — IP Leaderboard\n\nPosted via Swing',
      );
    } catch (e) {
      debugPrint('[LeaderboardShare] $e');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: context.stroke,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Share Leaderboard',
            style: TextStyle(
                color: context.fg, fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              _captureBoundaryContext = context;
              return RepaintBoundary(
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: _LeaderboardFlexCard(
                    lb: widget.lb,
                    section: widget.section,
                    tournamentName: widget.tournamentName,
                    isProvisional: widget.isProvisional,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _capture,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: context.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: _sharing
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: context.bg),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.ios_share_rounded,
                              color: context.bg, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Share as Image',
                            style: TextStyle(
                              color: context.bg,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
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
}

// ── Leaderboard Flex Card (shareable) ────────────────────────────────────────

class _LeaderboardFlexCard extends StatelessWidget {
  const _LeaderboardFlexCard({
    required this.lb,
    required this.section,
    required this.tournamentName,
    required this.isProvisional,
  });
  final TournamentLeaderboardModel lb;
  final int section;
  final String tournamentName;
  final bool isProvisional;

  List<LeaderboardPlayerModel> get _players {
    return switch (section) {
      0 => () {
          final seen = <String>{};
          return [
            ...lb.topBatsmen,
            ...lb.topBowlers,
            ...lb.topFielders,
          ].where((p) => seen.add(p.player.id)).toList()
            ..sort((a, b) => b.totalIp.compareTo(a.totalIp));
        }(),
      1 => [...lb.topBatsmen],
      2 => [...lb.topBowlers],
      3 => [...lb.topFielders],
      _ => <LeaderboardPlayerModel>[],
    }
        .take(5)
        .toList();
  }

  String get _sectionLabel =>
      ['Overall IP', 'Batting', 'Bowling', 'Fielding'][section];

  String _topMetric(LeaderboardPlayerModel p) => switch (section) {
        0 => '${p.totalIp} IP',
        1 => '${p.runs} Runs',
        2 => '${p.wickets} Wkts',
        3 => '${p.totalDismissals} Dismissals',
        _ => '${p.totalIp} IP',
      };

  String _topSubMetric(LeaderboardPlayerModel p) => switch (section) {
        0 => '${p.runs}R • ${p.wickets}W • ${p.totalDismissals}D',
        1 => 'SR ${p.strikeRate.toStringAsFixed(1)} • IP ${p.totalIp}',
        2 =>
          'Econ ${p.economy.toStringAsFixed(1)} • Ovs ${formatMatchOvers(p.oversBowled)} • IP ${p.totalIp}',
        3 => 'Ct ${p.catches} • RO ${p.runOuts} • IP ${p.totalIp}',
        _ => 'IP ${p.totalIp}',
      };

  String _listMetric(LeaderboardPlayerModel p) => switch (section) {
        0 => '${p.totalIp} IP',
        1 => '${p.runs}R • SR ${p.strikeRate.toStringAsFixed(1)}',
        2 => '${p.wickets}W • Econ ${p.economy.toStringAsFixed(1)}',
        3 => '${p.totalDismissals}D • IP ${p.totalIp}',
        _ => '${p.totalIp} IP',
      };

  @override
  Widget build(BuildContext context) {
    final players = _players;
    if (players.isEmpty) return const SizedBox.shrink();
    final top = players.first;
    final p = top.player;
    final rest = players.skip(1).take(4).toList();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0E1613),
            context.accent.withValues(alpha: 0.18),
            const Color(0xFF0E1613),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: context.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.leaderboard_rounded,
                      color: context.accent, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournamentName,
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '$_sectionLabel Leaderboard',
                        style: TextStyle(
                            color: context.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                      if (isProvisional)
                        Text(
                          'PROVISIONAL',
                          style: TextStyle(
                            color: context.warn,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  'SWING',
                  style: TextStyle(
                    color: context.accent.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.cardBg.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: context.accent.withValues(alpha: 0.45),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: context.accentBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.accent.withValues(alpha: 0.45),
                      width: 2,
                    ),
                    image: p.avatarUrl != null
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(p.avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: p.avatarUrl == null
                      ? Icon(Icons.person_rounded,
                          color: context.fgSub, size: 34)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('👑', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            '#1 TOPPER',
                            style: TextStyle(
                              color: context.gold,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      if (p.username != null && p.username!.isNotEmpty)
                        Text(
                          '@${p.username}',
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        _topMetric(top),
                        style: TextStyle(
                          color: context.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        _topSubMetric(top),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.cardBg.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.stroke.withValues(alpha: 0.75)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Top 5 ($_sectionLabel)',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < rest.length; i++) ...[
                  Row(
                    children: [
                      SizedBox(
                        width: 22,
                        child: Text(
                          '#${i + 2}',
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: context.accentBg,
                          shape: BoxShape.circle,
                          image: rest[i].player.avatarUrl != null
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      rest[i].player.avatarUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: rest[i].player.avatarUrl == null
                            ? Icon(Icons.person_rounded,
                                color: context.fgSub, size: 12)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rest[i].player.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _listMetric(rest[i]),
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (i != rest.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Divider(
                        color: context.stroke.withValues(alpha: 0.5),
                        height: 1,
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
}

class _FullTournamentShareSheet extends StatefulWidget {
  const _FullTournamentShareSheet({
    required this.lb,
    required this.tournamentName,
    required this.isProvisional,
  });
  final TournamentLeaderboardModel lb;
  final String tournamentName;
  final bool isProvisional;

  @override
  State<_FullTournamentShareSheet> createState() =>
      _FullTournamentShareSheetState();
}

class _FullTournamentShareSheetState extends State<_FullTournamentShareSheet> {
  BuildContext? _captureBoundaryContext;
  bool _sharing = false;

  Future<void> _capture() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      await Future.delayed(const Duration(milliseconds: 80));
      final boundary =
          _captureBoundaryContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final img = await boundary.toImage(pixelRatio: 3.0);
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      if (bd == null) return;
      await Share.shareXFiles(
        [
          XFile.fromData(bd.buffer.asUint8List(),
              mimeType: 'image/png', name: 'tournament_full_stats.png')
        ],
        text:
            '🏆 ${widget.tournamentName} — Tournament Highlights\n\nPosted via Swing',
      );
    } catch (e) {
      debugPrint('[FullShare] $e');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
                color: context.stroke, borderRadius: BorderRadius.circular(2)),
          ),
          Text('Share Tournament Highlights',
              style: TextStyle(
                  color: context.fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              _captureBoundaryContext = context;
              return RepaintBoundary(
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: _FullTournamentFlexCard(
                    lb: widget.lb,
                    tournamentName: widget.tournamentName,
                    isProvisional: widget.isProvisional,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _capture,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: context.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: _sharing
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: context.bg),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.ios_share_rounded,
                              color: context.bg, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Share as Image',
                            style: TextStyle(
                              color: context.bg,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
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
}

// ── Player of Tournament Share Sheet ─────────────────────────────────────────

class _PotShareSheet extends StatefulWidget {
  const _PotShareSheet({required this.player, required this.tournamentName});
  final LeaderboardPlayerModel player;
  final String tournamentName;

  @override
  State<_PotShareSheet> createState() => _PotShareSheetState();
}

class _PotShareSheetState extends State<_PotShareSheet> {
  final _cardKey = GlobalKey();
  bool _sharing = false;

  Future<void> _capture() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      await Future.delayed(const Duration(milliseconds: 80));
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      await Share.shareXFiles(
        [
          XFile.fromData(bytes,
              mimeType: 'image/png', name: 'player_of_tournament.png')
        ],
        text:
            '👑 ${widget.player.player.name} — Player of the Tournament\n🏆 ${widget.tournamentName}\n\nPosted via Swing',
      );
    } catch (e) {
      debugPrint('[PotShare] $e');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.player;
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: context.stroke,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Share Player of the Tournament',
            style: TextStyle(
                color: context.fg, fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          RepaintBoundary(
            key: _cardKey,
            child: _PotFlexCard(
              player: p,
              tournamentName: widget.tournamentName,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _capture,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: context.gold,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: _sharing
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: const Color(0xFF0E1613)),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.ios_share_rounded,
                              color: Color(0xFF0E1613), size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Share as Image',
                            style: TextStyle(
                              color: Color(0xFF0E1613),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
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
}

// ── PoT Flex Card ─────────────────────────────────────────────────────────────

class _PotFlexCard extends StatelessWidget {
  const _PotFlexCard({required this.player, required this.tournamentName});
  final LeaderboardPlayerModel player;
  final String tournamentName;

  @override
  Widget build(BuildContext context) {
    final p = player.player;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1200), Color(0xFF0E1613)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('👑  Player of the Tournament',
                  style: TextStyle(
                      color: context.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3)),
              Text('SWING',
                  style: TextStyle(
                      color: context.gold.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: context.accentBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: context.gold.withValues(alpha: 0.4), width: 2),
                  image: p.avatarUrl != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(p.avatarUrl!),
                          fit: BoxFit.cover)
                      : null,
                ),
                child: p.avatarUrl == null
                    ? Icon(Icons.person_rounded,
                        color: context.fgSub, size: 28)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        style: TextStyle(
                            color: context.fg,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5)),
                    if (p.username != null)
                      Text('@${p.username}',
                          style:
                              TextStyle(color: context.fgSub, fontSize: 12)),
                    const SizedBox(height: 4),
                    _RankBadge(rankKey: p.rankKey, division: p.rankDivision),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${player.totalIp}',
                      style: TextStyle(
                          color: context.gold,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          height: 1)),
                  Text('Impact Points',
                      style: TextStyle(color: context.fgSub, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: context.gold.withValues(alpha: 0.2)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _PotStat(label: 'Runs', value: '${player.runs}'),
              _PotStat(label: 'Wickets', value: '${player.wickets}'),
              _PotStat(
                  label: 'SR', value: player.strikeRate.toStringAsFixed(0)),
              _PotStat(
                  label: 'Economy', value: player.economy.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 12),
          Text(tournamentName,
              style: TextStyle(
                  color: context.fgSub.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontStyle: FontStyle.italic),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _PotStat extends StatelessWidget {
  const _PotStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: context.fg, fontSize: 16, fontWeight: FontWeight.w900)),
        Text(label, style: TextStyle(color: context.fgSub, fontSize: 10)),
      ],
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge(
      {required this.rankKey, required this.division, this.small = false});
  final String rankKey;
  final int division;
  final bool small;

  String get _label {
    final roman = ['I', 'II', 'III'][division > 3 ? 0 : (3 - division)];
    return '$rankKey $roman';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 4 : 6, vertical: small ? 1 : 2),
      decoration: BoxDecoration(
        color: context.accentBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(_label,
          style: TextStyle(
            color: context.accent,
            fontSize: small ? 9 : 10,
            fontWeight: FontWeight.w700,
          )),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(
      {required this.label, required this.value, this.highlight = false});
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                color: highlight ? context.accent : context.fg,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              )),
          Text(label, style: TextStyle(color: context.fgSub, fontSize: 9)),
        ],
      ),
    );
  }
}

// ── Overview cards ────────────────────────────────────────────────────────────

class _EntryFeeCard extends StatelessWidget {
  const _EntryFeeCard({required this.tournament});
  final TournamentDetailModel tournament;

  @override
  Widget build(BuildContext context) {
    final t = tournament;
    final isEarly = t.isEarlyBirdActive;
    final fee = t.effectiveEntryFee;
    final fmt = DateFormat('d MMM yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.accent.withValues(alpha: 0.15),
            context.accentBg,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sports_cricket_rounded,
                  color: context.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                isEarly ? 'Early Bird Open' : 'Registration Open',
                style: TextStyle(
                    color: context.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (fee != null && fee > 0) ...[
                Text('₹$fee',
                    style: TextStyle(
                        color: context.fg,
                        fontSize: 28,
                        fontWeight: FontWeight.w900)),
                if (isEarly && t.entryFee != null && t.entryFee! > fee) ...[
                  const SizedBox(width: 8),
                  Text('₹${t.entryFee}',
                      style: TextStyle(
                          color: context.fgSub,
                          fontSize: 16,
                          decoration: TextDecoration.lineThrough)),
                ],
              ] else
                Text('Free',
                    style: TextStyle(
                        color: context.fg,
                        fontSize: 28,
                        fontWeight: FontWeight.w900)),
              const Spacer(),
              if (isEarly && t.earlyBirdDeadline != null)
                Text('Until ${fmt.format(t.earlyBirdDeadline!)}',
                    style: TextStyle(
                        color: context.fgSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: context.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                fee != null && fee > 0 ? 'Register — ₹$fee' : 'Register Free',
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrganiserCard extends StatelessWidget {
  const _OrganiserCard({required this.tournament});
  final TournamentDetailModel tournament;

  @override
  Widget build(BuildContext context) {
    final t = tournament;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.accentBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              t.isSwingOfficial
                  ? Icons.verified_rounded
                  : Icons.person_outline_rounded,
              color: context.accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(t.resolvedOrganiserName,
                        style: TextStyle(
                            color: context.fg,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    if (t.isSwingOfficial || t.isVerified) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.verified_rounded,
                          color: context.accent, size: 14),
                    ],
                  ],
                ),
                Text(t.isSwingOfficial ? 'Official Organiser' : 'Organiser',
                    style: TextStyle(color: context.fgSub, fontSize: 12)),
              ],
            ),
          ),
          if (t.organiserPhone != null && t.organiserPhone!.isNotEmpty)
            IconButton(
              onPressed: () => launchUrl(Uri.parse('tel:${t.organiserPhone}')),
              icon: Icon(Icons.call_rounded, color: context.accent, size: 20),
            ),
        ],
      ),
    );
  }
}

class _OverviewFact {
  const _OverviewFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _OverviewFactsCard extends StatelessWidget {
  const _OverviewFactsCard({required this.items});
  final List<_OverviewFact> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.stroke),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final item in items) _OverviewFactTile(item: item),
        ],
      ),
    );
  }
}

class _OverviewFactTile extends StatelessWidget {
  const _OverviewFactTile({required this.item});
  final _OverviewFact item;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final tileWidth = ((width - 64) / 2).clamp(140.0, 260.0);

    return Container(
      width: tileWidth,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 14, color: context.fgSub),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextCard extends StatelessWidget {
  const _TextCard({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: context.fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(body,
              style:
                  TextStyle(color: context.fgSub, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}

class _PrizePoolCard extends StatelessWidget {
  const _PrizePoolCard({required this.prizePool});
  final String prizePool;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> parsed = {};
    try {
      parsed = Map<String, dynamic>.from((_tryParse(prizePool) ?? {}) as Map);
    } catch (_) {}

    final winner = parsed['winner'];
    final runnerUp = parsed['runnerUp'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: context.gold, size: 18),
              const SizedBox(width: 8),
              Text('Prize Pool',
                  style: TextStyle(
                      color: context.fg,
                      fontSize: 13,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          if (winner != null) ...[
            const SizedBox(height: 12),
            _PrizeLine(label: '🥇 Winner', value: '₹$winner'),
          ],
          if (runnerUp != null) ...[
            const SizedBox(height: 6),
            _PrizeLine(label: '🥈 Runner-up', value: '₹$runnerUp'),
          ],
          if (parsed['extras'] is List) ...[
            for (final extra in parsed['extras'] as List)
              if (extra is Map) ...[
                const SizedBox(height: 6),
                _PrizeLine(
                    label: '${extra['label'] ?? 'Prize'}',
                    value: '₹${extra['amount'] ?? ''}'),
              ],
          ],
        ],
      ),
    );
  }

  dynamic _tryParse(String s) {
    try {
      return jsonDecode(s);
    } catch (_) {
      return null;
    }
  }
}

class _PrizeLine extends StatelessWidget {
  const _PrizeLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: context.fg, fontSize: 13)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                color: context.gold,
                fontSize: 14,
                fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: context.fgSub,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.stroke),
              ),
              child: Icon(icon, color: context.fgSub, size: 26),
            ),
            const SizedBox(height: 12),
            Text(message,
                style: TextStyle(color: context.fgSub, fontSize: 14),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, color: context.fgSub, size: 40),
          const SizedBox(height: 12),
          Text('Tournament not found',
              style: TextStyle(
                  color: context.fg,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Check the link or try again',
              style: TextStyle(color: context.fgSub, fontSize: 13)),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// ── Badge widgets ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status, context);
    return _Chip(label: _statusLabel(status), color: color, filled: true);
  }
}

class _FormatBadge extends StatelessWidget {
  const _FormatBadge({required this.format});
  final String format;

  @override
  Widget build(BuildContext context) =>
      _Chip(label: _formatLabel(format), color: context.fgSub);
}

class _BallTypeBadge extends StatelessWidget {
  const _BallTypeBadge({required this.ballType});
  final String ballType;

  @override
  Widget build(BuildContext context) {
    final icon = switch (ballType) {
      'LEATHER' => '🔴',
      'TENNIS' => '🟡',
      'PLASTIC' => '⚪',
      _ => '🟤',
    };
    return _Chip(
        label: '$icon ${_ballTypeLabel(ballType)}', color: context.fgSub);
  }
}

class _TournamentFormatBadge extends StatelessWidget {
  const _TournamentFormatBadge({required this.format});
  final String format;

  @override
  Widget build(BuildContext context) =>
      _Chip(label: _tournamentFormatLabel(format), color: context.fgSub);
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, this.filled = false});
  final String label;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: filled
            ? color.withValues(alpha: 0.15)
            : Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(6),
        border:
            filled ? Border.all(color: color.withValues(alpha: 0.35)) : null,
      ),
      child: Text(label,
          style: TextStyle(
              color: filled ? color : Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700)),
    );
  }
}

// ── Utilities ─────────────────────────────────────────────────────────────────

Color _statusColor(String status, BuildContext context) => switch (status) {
      'ONGOING' => const Color(0xFF3FA66A),
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

String _formatLabel(String format) => switch (format) {
      'ONE_DAY' => 'ODI',
      'TWO_INNINGS' => 'Test',
      'BOX_CRICKET' => 'Box',
      _ => format,
    };

String _tournamentFormatLabel(String f) => switch (f) {
      'LEAGUE' => 'League',
      'KNOCKOUT' => 'Knockout',
      'GROUP_STAGE_KNOCKOUT' => 'Group + KO',
      'SERIES' => 'Series',
      'SUPER_LEAGUE' => 'Super League',
      'DOUBLE_ELIMINATION' => 'Double Elim',
      _ => f,
    };

String _ballTypeLabel(String b) => switch (b) {
      'LEATHER' => 'Leather',
      'TENNIS' => 'Tennis',
      'PLASTIC' => 'Plastic',
      'SOFT_BALL' => 'Soft Ball',
      _ => b,
    };

String _dateRange(DateTime start, DateTime? end) {
  final fmt = DateFormat('d MMM');
  if (end == null) return fmt.format(start);
  return '${fmt.format(start)} – ${fmt.format(end)}';
}

// ══════════════════════════════════════════════════════════════════════════════
// MATCH RESULT SHARE SHEET
// ══════════════════════════════════════════════════════════════════════════════

class _MatchResultShareSheet extends StatefulWidget {
  const _MatchResultShareSheet({required this.match});
  final TournamentMatchModel match;

  @override
  State<_MatchResultShareSheet> createState() => _MatchResultShareSheetState();
}

class _MatchResultShareSheetState extends State<_MatchResultShareSheet> {
  final _cardKey = GlobalKey();
  bool _sharing = false;

  Future<void> _capture() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      await Future.delayed(const Duration(milliseconds: 80));
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final img = await boundary.toImage(pixelRatio: 3.0);
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      if (bd == null) return;
      await Share.shareXFiles(
        [
          XFile.fromData(bd.buffer.asUint8List(),
              mimeType: 'image/png', name: 'match_result.png')
        ],
        text: '🏏 ${widget.match.result}\n\nPosted via Swing',
      );
    } catch (e) {
      debugPrint('[MatchShare] $e');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
                color: context.stroke, borderRadius: BorderRadius.circular(2)),
          ),
          Text('Share Match Result',
              style: TextStyle(
                  color: context.fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          RepaintBoundary(
            key: _cardKey,
            child: _MatchResultFlexCard(match: widget.match),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _capture,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                  color: context.accent,
                  borderRadius: BorderRadius.circular(16)),
              child: Center(
                child: _sharing
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: context.bg))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.ios_share_rounded,
                              color: context.bg, size: 16),
                          const SizedBox(width: 8),
                          Text('Share as Image',
                              style: TextStyle(
                                  color: context.bg,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchResultFlexCard extends StatelessWidget {
  const _MatchResultFlexCard({required this.match});
  final TournamentMatchModel match;

  @override
  Widget build(BuildContext context) {
    final m = match;
    final (inningsA, inningsB) = _resolveTeamInningsPair(
      innings: m.innings,
      teamAName: m.teamAName,
      teamBName: m.teamBName,
    );
    final isCompletedCard = m.status.toUpperCase() == 'COMPLETED';
    String? resolvedResult = m.result;
    if (resolvedResult == null &&
        isCompletedCard &&
        inningsA != null &&
        inningsB != null) {
      if (inningsB.totalRuns > inningsA.totalRuns) {
        resolvedResult =
            '${m.teamBName} won by ${10 - inningsB.totalWickets} wickets';
      } else if (inningsA.totalRuns > inningsB.totalRuns) {
        resolvedResult =
            '${m.teamAName} won by ${inningsA.totalRuns - inningsB.totalRuns} runs';
      } else {
        resolvedResult = 'Match tied';
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0E1613),
            context.accent.withValues(alpha: 0.15),
            const Color(0xFF0E1613)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.sports_cricket_rounded,
                    color: context.accent, size: 14),
                const SizedBox(width: 6),
                Text(
                    m.groupName ??
                        (m.round != null ? 'Round ${m.round}' : 'Match'),
                    style: TextStyle(
                        color: context.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ]),
              Text('SWING',
                  style: TextStyle(
                      color: context.accent.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 16),
          _MatchFlexTeamRow(
              teamName: m.teamAName, innings: inningsA, context: context),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              Expanded(
                  child: Divider(
                      color: context.stroke.withValues(alpha: 0.5))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('VS',
                    style: TextStyle(
                        color: context.fgSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
              ),
              Expanded(
                  child: Divider(
                      color: context.stroke.withValues(alpha: 0.5))),
            ]),
          ),
          _MatchFlexTeamRow(
              teamName: m.teamBName, innings: inningsB, context: context),
          if (resolvedResult != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events_rounded,
                      size: 13, color: context.accent),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(resolvedResult,
                        style: TextStyle(
                            color: context.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MatchFlexTeamRow extends StatelessWidget {
  const _MatchFlexTeamRow(
      {required this.teamName, required this.innings, required this.context});
  final String teamName;
  final TournamentMatchInnings? innings;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    final inn = innings;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: context.accentBg,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              teamName.trim().isNotEmpty
                  ? teamName.trim()[0].toUpperCase()
                  : '?',
              style: TextStyle(
                  color: context.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(teamName,
              style: TextStyle(
                  color: context.fg, fontSize: 14, fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        if (inn != null)
          Text(
            '${inn.totalRuns}/${inn.totalWickets} (${formatMatchOvers(inn.totalOvers)})',
            style: TextStyle(
                color: context.fg, fontSize: 14, fontWeight: FontWeight.w800),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TOURNAMENT STATS SHARE SHEET
// ══════════════════════════════════════════════════════════════════════════════

class _TournamentStatsShareSheet extends StatefulWidget {
  const _TournamentStatsShareSheet(
      {required this.totals, required this.tournamentName});
  final TournamentTotalsModel totals;
  final String tournamentName;

  @override
  State<_TournamentStatsShareSheet> createState() =>
      _TournamentStatsShareSheetState();
}

class _TournamentStatsShareSheetState
    extends State<_TournamentStatsShareSheet> {
  final _cardKey = GlobalKey();
  bool _sharing = false;

  Future<void> _capture() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      await Future.delayed(const Duration(milliseconds: 80));
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final img = await boundary.toImage(pixelRatio: 3.0);
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      if (bd == null) return;
      await Share.shareXFiles(
        [
          XFile.fromData(bd.buffer.asUint8List(),
              mimeType: 'image/png', name: 'tournament_stats.png')
        ],
        text:
            '🏆 ${widget.tournamentName} — Tournament Stats\n\nPosted via Swing',
      );
    } catch (e) {
      debugPrint('[StatsShare] $e');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
                color: context.stroke, borderRadius: BorderRadius.circular(2)),
          ),
          Text('Share Tournament Stats',
              style: TextStyle(
                  color: context.fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          RepaintBoundary(
            key: _cardKey,
            child: _TournamentStatsFlexCard(
              totals: widget.totals,
              tournamentName: widget.tournamentName,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _capture,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                  color: context.accent,
                  borderRadius: BorderRadius.circular(16)),
              child: Center(
                child: _sharing
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: context.bg))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.ios_share_rounded,
                              color: context.bg, size: 16),
                          const SizedBox(width: 8),
                          Text('Share as Image',
                              style: TextStyle(
                                  color: context.bg,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TournamentStatsFlexCard extends StatelessWidget {
  const _TournamentStatsFlexCard(
      {required this.totals, required this.tournamentName});
  final TournamentTotalsModel totals;
  final String tournamentName;

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('Matches', '${totals.matchesPlayed}', Icons.sports_cricket_rounded),
      ('Runs', '${totals.totalRuns}', Icons.bar_chart_rounded),
      ('Fours', '${totals.totalFours}', Icons.looks_4_rounded),
      ('Sixes', '${totals.totalSixes}', Icons.looks_6_rounded),
      ('Wickets', '${totals.totalWickets}', Icons.sports_baseball_rounded),
      ('IP Awarded', '${totals.totalIpAwarded}', Icons.bolt_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0E1613),
            context.accent.withValues(alpha: 0.14),
            const Color(0xFF0E1613)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.leaderboard_rounded,
                    color: context.accent, size: 14),
                const SizedBox(width: 6),
                Text('Tournament Stats',
                    style: TextStyle(
                        color: context.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ]),
              Text('SWING',
                  style: TextStyle(
                      color: context.accent.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 6),
          Text(tournamentName,
              style: TextStyle(
                  color: context.fg,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.7,
            children: stats
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: s.$1 == 'IP Awarded'
                            ? Border.all(
                                color: context.accent.withValues(alpha: 0.4))
                            : Border.all(color: context.stroke),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(s.$2,
                              style: TextStyle(
                                  color: s.$1 == 'IP Awarded'
                                      ? context.accent
                                      : context.fg,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900)),
                          Text(s.$1,
                              style: TextStyle(
                                  color: context.fgSub,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Text('Impact Points — play on Swing',
              style: TextStyle(
                  color: context.fgSub.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _FullTournamentFlexCard extends StatelessWidget {
  const _FullTournamentFlexCard({
    required this.lb,
    required this.tournamentName,
    required this.isProvisional,
  });
  final TournamentLeaderboardModel lb;
  final String tournamentName;
  final bool isProvisional;

  @override
  Widget build(BuildContext context) {
    final totals = lb.tournamentTotals;
    final overall = [
      ...lb.topBatsmen,
      ...lb.topBowlers,
      ...lb.topFielders,
    ]..sort((a, b) => b.totalIp.compareTo(a.totalIp));
    final topOverall = overall.isNotEmpty ? overall.first : null;
    final batter = lb.topBatsmen.isNotEmpty ? lb.topBatsmen[0] : null;
    final bowler = lb.topBowlers.isNotEmpty ? lb.topBowlers[0] : null;
    final fielder = lb.topFielders.isNotEmpty ? lb.topFielders[0] : null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0E1613),
            context.accent.withValues(alpha: 0.14),
            const Color(0xFF0E1613)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.leaderboard_rounded,
                    color: context.accent, size: 14),
                const SizedBox(width: 6),
                Text('Tournament Highlights',
                    style: TextStyle(
                        color: context.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ]),
              Text('SWING',
                  style: TextStyle(
                      color: context.accent.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 6),
          Text(tournamentName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          if (isProvisional) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.warn.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: context.warn.withValues(alpha: 0.35)),
              ),
              child: Text(
                'PROVISIONAL',
                style: TextStyle(
                  color: context.warn,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniStat(label: 'Matches', value: '${totals.matchesPlayed}'),
              _MiniStat(label: 'Runs', value: '${totals.totalRuns}'),
              _MiniStat(label: '4s', value: '${totals.totalFours}'),
              _MiniStat(label: '6s', value: '${totals.totalSixes}'),
              _MiniStat(label: 'Wkts', value: '${totals.totalWickets}'),
              _MiniStat(
                  label: 'IP',
                  value: '${totals.totalIpAwarded}',
                  highlight: true),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: context.stroke.withValues(alpha: 0.4), height: 1),
          const SizedBox(height: 12),
          if (topOverall != null)
            _TopCategoryCard(
              label: 'Overall #1',
              player: topOverall.player,
              detail: '${topOverall.totalIp} IP',
              emphasize: true,
            ),
          if (topOverall != null) const SizedBox(height: 8),
          if (batter != null)
            _TopCategoryCard(
              label: 'Batting #1',
              player: batter.player,
              detail:
                  '${batter.runs}R • SR ${batter.strikeRate.toStringAsFixed(1)}',
            ),
          if (batter != null) const SizedBox(height: 8),
          if (bowler != null)
            _TopCategoryCard(
              label: 'Bowling #1',
              player: bowler.player,
              detail:
                  '${bowler.wickets}W • Econ ${bowler.economy.toStringAsFixed(1)}',
            ),
          if (bowler != null) const SizedBox(height: 8),
          if (fielder != null)
            _TopCategoryCard(
              label: 'Fielding #1',
              player: fielder.player,
              detail: '${fielder.totalDismissals} dismissals',
            ),
          const Spacer(),
          Text('Impact Points — play on Swing',
              style: TextStyle(
                  color: context.fgSub.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.label, required this.value, this.highlight = false});
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: highlight ? context.accent : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900)),
        Text(label,
            style: TextStyle(
                color: context.fgSub,
                fontSize: 9,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _TopCategoryCard extends StatelessWidget {
  const _TopCategoryCard({
    required this.label,
    required this.player,
    required this.detail,
    this.emphasize = false,
  });

  final String label;
  final LeaderboardPlayerInfo player;
  final String detail;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: emphasize
            ? context.accent.withValues(alpha: 0.14)
            : context.cardBg.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: emphasize
              ? context.accent.withValues(alpha: 0.4)
              : context.stroke.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: emphasize
                  ? context.accent.withValues(alpha: 0.22)
                  : context.accentBg,
              shape: BoxShape.circle,
              image: player.avatarUrl != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(player.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: player.avatarUrl == null
                ? Icon(Icons.person_rounded, size: 15, color: context.fgSub)
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            detail,
            style: TextStyle(
              color: emphasize ? context.accent : context.fgSub,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
