import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../theme/host_colors.dart';
import '../controller/team_detail_controller.dart';
import '../domain/team_models.dart';
import '../../match_detail/domain/match_models.dart';
import '../../match_detail/presentation/match_card.dart';

// ── Callbacks ─────────────────────────────────────────────────────────────────

class TeamDetailCallbacks {
  const TeamDetailCallbacks({
    this.onNavigateToMatch,
    this.onScoreMatch,
    this.onNavigateToPlayer,
    this.onUploadLogo,
    this.onNavigateBack,
  });

  final void Function(BuildContext ctx, String matchId)? onNavigateToMatch;
  final void Function(BuildContext ctx, String matchId)? onScoreMatch;
  final void Function(BuildContext ctx, String playerId)? onNavigateToPlayer;
  final Future<String?> Function(BuildContext ctx)? onUploadLogo;
  final void Function(BuildContext ctx)? onNavigateBack;
}

// ── Screen entry ──────────────────────────────────────────────────────────────

class HostTeamDetailScreen extends ConsumerStatefulWidget {
  const HostTeamDetailScreen({
    super.key,
    required this.teamId,
    required this.currentUserId,
    this.callbacks,
    this.autoJoin = false,
  });

  final String teamId;
  final String? currentUserId;
  final TeamDetailCallbacks? callbacks;
  final bool autoJoin;

  @override
  ConsumerState<HostTeamDetailScreen> createState() =>
      _HostTeamDetailScreenState();
}

class _HostTeamDetailScreenState extends ConsumerState<HostTeamDetailScreen> {
  bool _joinSheetScheduled = false;

  void _maybeShowJoinSheet(PlayerTeam team) {
    if (!widget.autoJoin || _joinSheetScheduled) return;
    _joinSheetScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => _JoinTeamSheet(
          team: team,
          teamId: widget.teamId,
          currentUserId: widget.currentUserId,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      teamDetailControllerProvider(
          (teamId: widget.teamId, currentUserId: widget.currentUserId)),
    );

    if (state.isLoading && !state.hasData) {
      return Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: context.fg, size: 18),
            onPressed: () {
              final cb = widget.callbacks?.onNavigateBack;
              if (cb != null) {
                cb(context);
              } else {
                Navigator.of(context).maybePop();
              }
            },
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null && !state.hasData) {
      return Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: context.fg, size: 18),
            onPressed: () {
              final cb = widget.callbacks?.onNavigateBack;
              if (cb != null) {
                cb(context);
              } else {
                Navigator.of(context).maybePop();
              }
            },
          ),
        ),
        body: Center(
          child: Text('Could not load team',
              style: TextStyle(color: context.fgSub)),
        ),
      );
    }

    final team = state.team!;
    _maybeShowJoinSheet(team);

    return _TeamScreen(
      team: team,
      state: state,
      teamId: widget.teamId,
      currentUserId: widget.currentUserId,
      callbacks: widget.callbacks,
    );
  }
}

// ── Main screen ───────────────────────────────────────────────────────────────

class _TeamScreen extends ConsumerWidget {
  const _TeamScreen({
    required this.team,
    required this.state,
    required this.teamId,
    required this.currentUserId,
    this.callbacks,
  });

  final PlayerTeam team;
  final TeamDetailState state;
  final String teamId;
  final String? currentUserId;
  final TeamDetailCallbacks? callbacks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: context.bg,
        body: NestedScrollView(
          headerSliverBuilder: (ctx, _) => [
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: context.fg, size: 18),
                onPressed: () {
                  if (callbacks?.onNavigateBack != null) {
                    callbacks!.onNavigateBack!(context);
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
              ),
              title: Text(
                team.name,
                style: TextStyle(
                    color: context.fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                if (team.isOwner)
                  IconButton(
                    icon: Icon(Icons.edit_rounded, color: context.fg, size: 20),
                    tooltip: 'Edit team',
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _EditTeamSheet(
                        team: team,
                        teamId: teamId,
                        currentUserId: currentUserId,
                        callbacks: callbacks,
                        onNavigateBack: () {
                          if (callbacks?.onNavigateBack != null) {
                            callbacks!.onNavigateBack!(context);
                          } else {
                            Navigator.of(context).maybePop();
                          }
                        },
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(Icons.qr_code_rounded,
                      color: context.fg, size: 20),
                  onPressed: () => _showTeamQrSheet(context, team),
                ),
                const SizedBox(width: 4),
              ],
            ),

            SliverToBoxAdapter(
              child: _TeamHeroHeader(
                team: team,
                state: state,
                teamId: teamId,
                currentUserId: currentUserId,
              ),
            ),

            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBar(
                TabBar(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  indicatorColor: context.accent,
                  indicatorWeight: 2,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: context.stroke,
                  labelColor: context.fg,
                  unselectedLabelColor: context.fgSub,
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Stats'),
                    Tab(text: 'Matches'),
                    Tab(text: 'Squad'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _OverviewTab(team: team, state: state),
              _StatsTab(team: team, state: state),
              _MatchesTab(
                teamId: team.id,
                state: state,
                callbacks: callbacks,
              ),
              _SquadTab(
                team: team,
                teamId: teamId,
                currentUserId: currentUserId,
                callbacks: callbacks,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero header ───────────────────────────────────────────────────────────────

class _TeamHeroHeader extends ConsumerWidget {
  const _TeamHeroHeader({
    required this.team,
    required this.state,
    required this.teamId,
    required this.currentUserId,
  });

  final PlayerTeam team;
  final TeamDetailState state;
  final String teamId;
  final String? currentUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = state.analytics;

    return ColoredBox(
      color: context.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Row(
              children: [
                // Logo
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: context.surf,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.stroke, width: 1.5),
                    image: team.logoUrl != null
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(team.logoUrl!),
                            fit: BoxFit.cover)
                        : null,
                  ),
                  child: team.logoUrl == null
                      ? Center(
                          child: Text(
                            _initials(team),
                            style: TextStyle(
                                color: context.fg,
                                fontSize: 22,
                                fontWeight: FontWeight.w900),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 5,
                        children: [
                          if (_hasText(team.city))
                            _Pill(team.city!, color: context.fgSub),
                          if (_hasText(team.teamType))
                            _Pill(team.teamType!, color: context.fgSub),
                          _Pill(
                            '${team.members.length} players',
                            color: context.fgSub,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (analytics != null && analytics.summary.matchesPlayed > 0)
            _HeroStatsStrip(analytics: analytics)
          else
            _HeroStatsStripFallback(
              team: team,
              matches: state.matches,
            ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _HeroStatsStrip extends StatelessWidget {
  const _HeroStatsStrip({required this.analytics});
  final TeamAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final s = analytics.summary;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          _HeroStat(
              value: '${s.matchesPlayed}',
              label: 'Played',
              color: context.fg),
          _HeroStatDivider(),
          _HeroStat(
              value: '${s.totalWins}',
              label: 'Won',
              color: context.success),
          _HeroStatDivider(),
          _HeroStat(
              value: '${s.totalLosses}',
              label: 'Lost',
              color: context.danger),
          _HeroStatDivider(),
          _HeroStat(
            value: '${(s.winRate * 100).toStringAsFixed(0)}%',
            label: 'Win Rate',
            color: context.fg,
          ),
          _HeroStatDivider(),
          _HeroStat(
            value: analytics.nrr >= 0
                ? '+${analytics.nrr.toStringAsFixed(2)}'
                : analytics.nrr.toStringAsFixed(2),
            label: 'NRR',
            color: analytics.nrr >= 0 ? context.success : context.danger,
          ),
        ],
      ),
    );
  }
}

class _HeroStatsStripFallback extends StatelessWidget {
  const _HeroStatsStripFallback({
    required this.team,
    required this.matches,
  });

  final PlayerTeam team;
  final List<PlayerMatch> matches;

  @override
  Widget build(BuildContext context) {
    final played =
        matches.where((m) => m.lifecycle == MatchLifecycle.past).toList();
    final wins = played.where((m) => m.result == MatchResult.win).length;
    final losses = played.where((m) => m.result == MatchResult.loss).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          _HeroStat(
              value: '${played.length}',
              label: 'Played',
              color: context.fg),
          _HeroStatDivider(),
          _HeroStat(value: '$wins', label: 'Won', color: context.success),
          _HeroStatDivider(),
          _HeroStat(value: '$losses', label: 'Lost', color: context.danger),
          _HeroStatDivider(),
          _HeroStat(
              value: '${team.members.length}',
              label: 'Players',
              color: context.fg),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat(
      {required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: context.fgSub,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _HeroStatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: context.stroke);
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, {required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Sticky tab bar delegate ───────────────────────────────────────────────────

class _StickyTabBar extends SliverPersistentHeaderDelegate {
  const _StickyTabBar(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(
      color: context.bg,
      child: Column(
        children: [
          Expanded(child: tabBar),
          Container(height: 1, color: context.stroke),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyTabBar old) => old.tabBar != tabBar;
}

// ── Overview tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.team, required this.state});

  final PlayerTeam team;
  final TeamDetailState state;

  @override
  Widget build(BuildContext context) {
    final analytics = state.analytics;
    final captain = _memberForRole(team, 'Captain');
    final viceCaptain = _memberForRole(team, 'Vice Captain');
    final wicketKeeper = _memberForRole(team, 'Wicketkeeper');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      children: [
        if (analytics != null && analytics.summary.matchesPlayed > 0) ...[
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(
                    icon: Icons.bolt_rounded,
                    title: 'Performance',
                    iconColor: context.gold),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _OverviewMetric(
                      value: '${analytics.powerScore.toStringAsFixed(0)}',
                      label: 'Power Score',
                      color: context.gold,
                    ),
                    _OverviewMetric(
                      value:
                          '${(analytics.summary.winRate * 100).toStringAsFixed(0)}%',
                      label: 'Win Rate',
                      color: context.success,
                    ),
                    _OverviewMetric(
                      value: analytics.nrr >= 0
                          ? '+${analytics.nrr.toStringAsFixed(2)}'
                          : analytics.nrr.toStringAsFixed(2),
                      label: 'NRR',
                      color: analytics.nrr >= 0
                          ? context.success
                          : context.danger,
                    ),
                    if (analytics.summary.winStreak > 0)
                      _OverviewMetric(
                        value: '${analytics.summary.winStreak}',
                        label: 'Streak 🔥',
                        color: context.fg,
                      ),
                  ],
                ),
                if (analytics.summary.recentForm.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Divider(color: context.stroke, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text('FORM',
                          style: TextStyle(
                              color: context.fgSub,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8)),
                      const Spacer(),
                      Wrap(
                        spacing: 6,
                        children: analytics.summary.recentForm
                            .take(5)
                            .map((f) => _FormBadge(result: f))
                            .toList(),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (analytics != null &&
            (analytics.topBatsmen.isNotEmpty ||
                analytics.topBowlers.isNotEmpty)) ...[
          _Card(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: _CardHeader(
                    icon: Icons.stars_rounded,
                    title: 'Key Players',
                    iconColor: context.gold,
                  ),
                ),
                if (analytics.topBatsmen.isNotEmpty) ...[
                  _SubHeader('BATTING', color: context.sky),
                  ...analytics.topBatsmen
                      .take(3)
                      .map((p) => _PerformerRow(player: p)),
                ],
                if (analytics.topBowlers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _SubHeader('BOWLING', color: context.accent),
                  ...analytics.topBowlers
                      .take(3)
                      .map((p) => _PerformerRow(player: p)),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (captain != null || viceCaptain != null || wicketKeeper != null) ...[
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(
                  icon: Icons.workspace_premium_rounded,
                  title: 'Leadership',
                  iconColor: context.gold,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (captain != null)
                      _RoleCard(
                        role: 'Captain',
                        member: captain,
                        icon: Icons.workspace_premium_rounded,
                        color: context.gold,
                      ),
                    if (viceCaptain != null)
                      _RoleCard(
                        role: 'Vice Captain',
                        member: viceCaptain,
                        icon: Icons.military_tech_rounded,
                        color: context.accent,
                      ),
                    if (wicketKeeper != null)
                      _RoleCard(
                        role: 'Wicketkeeper',
                        member: wicketKeeper,
                        icon: Icons.sports_baseball_rounded,
                        color: context.sky,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(
                icon: Icons.info_outline_rounded,
                title: 'About',
                iconColor: context.fgSub,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_hasText(team.city))
                    _InfoTag(Icons.location_on_outlined, team.city!),
                  if (_hasText(team.teamType))
                    _InfoTag(Icons.shield_outlined, team.teamType!),
                  if (_hasText(team.shortName))
                    _InfoTag(Icons.tag_rounded, team.shortName!),
                  if (team.averageSwingIndex != null)
                    _InfoTag(Icons.bolt_rounded,
                        'Avg SI ${team.averageSwingIndex!.toStringAsFixed(1)}'),
                  _InfoTag(Icons.people_outline_rounded,
                      '${team.members.length} players'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Stats tab ─────────────────────────────────────────────────────────────────

class _StatsTab extends StatelessWidget {
  const _StatsTab({required this.team, required this.state});

  final PlayerTeam team;
  final TeamDetailState state;

  @override
  Widget build(BuildContext context) {
    final a = state.analytics;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (a == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
        children: [
          _Card(
            child: Column(
              children: [
                Icon(Icons.analytics_outlined,
                    color: context.fgSub, size: 40),
                const SizedBox(height: 12),
                Text('Detailed stats unavailable',
                    style: TextStyle(
                        color: context.fg,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  'Analytics data will appear once the team has played matches.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: context.fgSub, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(
                    icon: Icons.people_outline_rounded,
                    title: 'Squad Overview',
                    iconColor: context.fgSub),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _BigStat(value: '${team.members.length}', label: 'Players'),
                    if (team.averageSwingIndex != null)
                      _BigStat(
                        value: team.averageSwingIndex!.toStringAsFixed(1),
                        label: 'Avg SI',
                        color: context.gold,
                      ),
                    _BigStat(
                      value:
                          '${team.membersByRuns.firstOrNull?.totalRuns ?? 0}',
                      label: 'Top Runs',
                      color: context.sky,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      children: [
        Row(
          children: [
            Expanded(
              child: _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('POWER SCORE',
                        style: TextStyle(
                            color: context.gold,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8)),
                    const SizedBox(height: 8),
                    Text(
                      a.powerScore.toStringAsFixed(0),
                      style: TextStyle(
                          color: context.gold,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NET RUN RATE',
                        style: TextStyle(
                            color: context.fgSub,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8)),
                    const SizedBox(height: 8),
                    Text(
                      a.nrr >= 0
                          ? '+${a.nrr.toStringAsFixed(3)}'
                          : a.nrr.toStringAsFixed(3),
                      style: TextStyle(
                          color:
                              a.nrr >= 0 ? context.success : context.danger,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(
                  icon: Icons.insights_rounded,
                  title: 'Summary',
                  iconColor: context.sky),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BigStat(
                      value: '${a.summary.matchesPlayed}', label: 'Matches'),
                  _BigStat(
                      value: '${a.summary.totalWins}',
                      label: 'Won',
                      color: context.success),
                  _BigStat(
                      value: '${a.summary.totalLosses}',
                      label: 'Lost',
                      color: context.danger),
                  _BigStat(
                      value:
                          '${(a.summary.winRate * 100).toStringAsFixed(0)}%',
                      label: 'Win Rate'),
                ],
              ),
              if (a.summary.recentForm.isNotEmpty) ...[
                const SizedBox(height: 16),
                Divider(color: context.stroke, height: 1),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text('RECENT FORM',
                        style: TextStyle(
                            color: context.fgSub,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8)),
                    const Spacer(),
                    Wrap(
                        spacing: 6,
                        children: a.summary.recentForm
                            .take(5)
                            .map((f) => _FormBadge(result: f))
                            .toList()),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardHeader(
                        icon: Icons.sports_cricket_rounded,
                        title: 'Batting',
                        iconColor: context.sky),
                    const SizedBox(height: 14),
                    _StatRow2('Avg Score',
                        a.batting.averageScore.toStringAsFixed(1)),
                    _StatRow2('High / Low',
                        '${a.batting.highestScore} / ${a.batting.lowestScore}'),
                    _StatRow2('Batting Avg',
                        a.batting.teamBattingAverage.toStringAsFixed(1)),
                    _StatRow2('Run Rate',
                        a.batting.scoringRate.toStringAsFixed(2)),
                    _StatRow2('Dot Ball %',
                        '${a.batting.dotBallPercentage.toStringAsFixed(0)}%'),
                    _StatRow2('4s / 6s',
                        '${a.batting.totalFours} / ${a.batting.totalSixes}'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardHeader(
                        icon: Icons.sports_baseball_rounded,
                        title: 'Bowling',
                        iconColor: context.accent),
                    const SizedBox(height: 14),
                    _StatRow2('Economy',
                        a.bowling.averageEconomy.toStringAsFixed(2)),
                    _StatRow2('Total Wkts', '${a.bowling.totalWickets}'),
                    _StatRow2('Wkts/Match',
                        a.bowling.averageWicketsPerMatch.toStringAsFixed(1)),
                    _StatRow2('Bowl Avg',
                        a.bowling.bowlingAverage.toStringAsFixed(1)),
                    _StatRow2('Dot Ball %',
                        '${a.bowling.dotBallPercentage.toStringAsFixed(0)}%'),
                    if (_hasText(a.bowling.bestBowling))
                      _StatRow2('Best', a.bowling.bestBowling!),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(
                  icon: Icons.psychology_alt_rounded,
                  title: 'Strategy',
                  iconColor: context.accent),
              const SizedBox(height: 14),
              _StatRow('Bat First Win %',
                  '${(a.strategy.battingFirstWinRate * 100).toStringAsFixed(0)}%'),
              _StatRow('Chase Win %',
                  '${(a.strategy.chasingWinRate * 100).toStringAsFixed(0)}%'),
              Divider(color: context.stroke, height: 20),
              _StatRow('Toss Win → Match Win',
                  '${(a.strategy.tossWinMatchWinRate * 100).toStringAsFixed(0)}%'),
              _StatRow('Toss Lost → Match Win',
                  '${(a.strategy.tossLossMatchWinRate * 100).toStringAsFixed(0)}%'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (a.topBatsmen.isNotEmpty || a.topBowlers.isNotEmpty)
          _Card(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: _CardHeader(
                      icon: Icons.stars_rounded,
                      title: 'Top Performers',
                      iconColor: context.gold),
                ),
                if (a.topBatsmen.isNotEmpty) ...[
                  _SubHeader('TOP SCORERS', color: context.sky),
                  ...a.topBatsmen.map((p) => _PerformerRow(player: p)),
                ],
                if (a.topBowlers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _SubHeader('WICKET TAKERS', color: context.accent),
                  ...a.topBowlers.map((p) => _PerformerRow(player: p)),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),

        if (a.venues.isNotEmpty) ...[
          const SizedBox(height: 12),
          _Card(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: _CardHeader(
                      icon: Icons.location_on_outlined,
                      title: 'Venue Performance',
                      iconColor: context.fgSub),
                ),
                ...a.venues.map((v) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(v.venueName,
                                style: TextStyle(
                                    color: context.fg, fontSize: 13)),
                          ),
                          Text('${v.matches} matches',
                              style: TextStyle(
                                  color: context.fgSub, fontSize: 11)),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: context.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${(v.winRate * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                  color: context.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Matches tab ───────────────────────────────────────────────────────────────

class _MatchesTab extends StatefulWidget {
  const _MatchesTab({
    required this.teamId,
    required this.state,
    this.callbacks,
  });

  final String teamId;
  final TeamDetailState state;
  final TeamDetailCallbacks? callbacks;

  @override
  State<_MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends State<_MatchesTab> {
  int? _filter;
  bool _userPicked = false;

  // Active filter selections.
  String? _venueFilter;
  String? _opponentFilter;
  String? _formatFilter;

  int _bestFilter(List<PlayerMatch> all) {
    if (all.any((m) => m.lifecycle == MatchLifecycle.live)) return 0;
    if (all.any((m) => m.lifecycle == MatchLifecycle.upcoming)) return 1;
    return 2;
  }

  List<PlayerMatch> _sort(List<PlayerMatch> list, bool newestFirst) {
    final copy = [...list];
    copy.sort((a, b) {
      final at = a.scheduledAt;
      final bt = b.scheduledAt;
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return newestFirst ? bt.compareTo(at) : at.compareTo(bt);
    });
    return copy;
  }

  List<PlayerMatch> _applyFilters(List<PlayerMatch> list) {
    return list.where((m) {
      if (_venueFilter != null && m.venueLabel != _venueFilter) return false;
      if (_opponentFilter != null && m.opponentTeamName != _opponentFilter) return false;
      if (_formatFilter != null && m.formatLabel != _formatFilter) return false;
      return true;
    }).toList();
  }

  int get _activeFilterCount =>
      [_venueFilter, _opponentFilter, _formatFilter].where((f) => f != null).length;

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
    final all = widget.state.matches;

    if (widget.state.isLoading && all.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_userPicked && all.isNotEmpty) {
      _filter = _bestFilter(all);
    }
    final filter = _filter ?? 2;

    final live = _sort(
        all.where((m) => m.lifecycle == MatchLifecycle.live).toList(), false);
    final upcoming = _sort(
        all.where((m) => m.lifecycle == MatchLifecycle.upcoming).toList(), false);
    final completed = _sort(
        all.where((m) => m.lifecycle == MatchLifecycle.past).toList(), true);

    final tabs = [
      (label: 'Live', color: context.success, list: live),
      (label: 'Upcoming', color: context.sky, list: upcoming),
      (label: 'Completed', color: context.fgSub, list: completed),
    ];

    final current = _applyFilters(tabs[filter].list);
    final hasFilters = _activeFilterCount > 0;

    return Column(
      children: [
        // ── Tabs row + filter icon ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
          child: Row(
            children: [
              ...List.generate(tabs.length, (i) {
                final t = tabs[i];
                final isSelected = i == filter;
                return GestureDetector(
                  onTap: () => setState(() { _filter = i; _userPicked = true; }),
                  child: Padding(
                    padding: EdgeInsets.only(right: i < tabs.length - 1 ? 24 : 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t.label,
                              style: TextStyle(
                                color: isSelected ? t.color : context.fgSub,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${t.list.length}',
                              style: TextStyle(
                                color: isSelected ? t.color : context.fgSub,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 2,
                          width: 32,
                          color: isSelected ? t.color : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const Spacer(),
              GestureDetector(
                onTap: () => _openFilters(context, all),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 20,
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
            ],
          ),
        ),
        Divider(height: 1, color: context.stroke),

        // ── Active filter chips ────────────────────────────────────────────
        if (hasFilters)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
            child: Row(
              children: [
                if (_formatFilter != null)
                  _FilterChip(
                    label: _formatFilter!,
                    onRemove: () => setState(() => _formatFilter = null),
                    context: context,
                  ),
                if (_opponentFilter != null)
                  _FilterChip(
                    label: 'vs $_opponentFilter',
                    onRemove: () => setState(() => _opponentFilter = null),
                    context: context,
                  ),
                if (_venueFilter != null)
                  _FilterChip(
                    label: _venueFilter!,
                    onRemove: () => setState(() => _venueFilter = null),
                    context: context,
                  ),
              ],
            ),
          ),

        // ── Match list ─────────────────────────────────────────────────────
        Expanded(
          child: current.isEmpty
              ? _EmptyMsg(hasFilters
                  ? 'No matches for selected filters.'
                  : switch (filter) {
                      0 => 'No live matches.',
                      1 => 'No upcoming matches.',
                      _ => 'No completed matches.',
                    })
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 48),
                  itemCount: current.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, indent: 20, color: context.stroke),
                  itemBuilder: (_, i) {
                    final m = current[i];
                    return HostMatchCard(
                      match: m,
                      onTap: m.id.isNotEmpty &&
                              widget.callbacks?.onNavigateToMatch != null
                          ? () => widget.callbacks!.onNavigateToMatch!(context, m.id)
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.onRemove,
    required this.context,
  });

  final String label;
  final VoidCallback onRemove;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
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
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.stroke,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
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
          // Scrollable content
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
          // Apply button
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
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
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

// ── Squad tab ─────────────────────────────────────────────────────────────────

class _SquadTab extends StatelessWidget {
  const _SquadTab({
    required this.team,
    required this.teamId,
    required this.currentUserId,
    this.callbacks,
  });

  final PlayerTeam team;
  final String teamId;
  final String? currentUserId;
  final TeamDetailCallbacks? callbacks;

  // Owner, Captain, or Vice Captain can manage the squad.
  bool get _canManage {
    if (currentUserId == null || currentUserId!.isEmpty) return false;
    if (team.isOwner) return true;
    return team.members.any((m) =>
        (m.profileId == currentUserId || m.userId == currentUserId) &&
        (m.roles.contains('Captain') || m.roles.contains('Vice Captain')));
  }

  void _openAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddPlayerSheet(
        team: team,
        teamId: teamId,
        currentUserId: currentUserId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canManage = _canManage;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SQUAD',
                      style: TextStyle(
                          color: context.fgSub,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                  const SizedBox(height: 3),
                  Text('${team.members.length} Players',
                      style: TextStyle(
                          color: context.fg,
                          fontSize: 20,
                          fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            // ── Add player button (owner / captain / VC only) ─────────────
            if (canManage)
              GestureDetector(
                onTap: () => _openAddSheet(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),

        // ── Role legend (always visible when there are members) ───────────
        if (team.members.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                _LegendDot(color: context.gold, label: 'C  Captain'),
                _LegendDot(color: context.sky, label: 'VC  Vice Captain'),
                _LegendDot(color: context.accent, label: 'WK  Keeper'),
              ],
            ),
          ),

        if (team.members.isEmpty)
          _EmptyMsg(
            'No players added yet.',
            action: canManage ? 'Add Player' : null,
            onAction: canManage ? () => _openAddSheet(context) : null,
          )
        else
          ...team.members.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MemberCard(
                  member: m,
                  canManage: canManage,
                  teamId: team.id,
                  currentUserId: currentUserId,
                  callbacks: callbacks,
                ),
              )),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: context.fgSub, fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _MemberCard extends ConsumerWidget {
  const _MemberCard({
    required this.member,
    this.canManage = false,
    this.teamId,
    this.currentUserId,
    this.callbacks,
  });

  final TeamMember member;
  final bool canManage;
  final String? teamId;
  final String? currentUserId;
  final TeamDetailCallbacks? callbacks;

  String get _removeId =>
      member.profileId.isNotEmpty ? member.profileId : member.userId;

  bool get _canRemove => teamId != null && _removeId.isNotEmpty;

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.surf,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Remove Player',
            style: TextStyle(
                color: context.fg, fontWeight: FontWeight.w700)),
        content: Text(
          'Remove ${member.name} from the team?',
          style: TextStyle(color: context.fgSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(color: context.fgSub)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Remove',
                style: TextStyle(color: context.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    final ctrl = ref.read(teamDetailControllerProvider(
        (teamId: teamId!, currentUserId: currentUserId)).notifier);
    final ok = await ctrl.removePlayer(_removeId);
    if (!ok && context.mounted) {
      final err = ref
              .read(teamDetailControllerProvider(
                  (teamId: teamId!, currentUserId: currentUserId)))
              .error ??
          'Could not remove player';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: member.profileId.isNotEmpty &&
              callbacks?.onNavigateToPlayer != null
          ? () => callbacks!.onNavigateToPlayer!(context, member.profileId)
          : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surf,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.stroke),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.panel,
                border: Border.all(color: context.stroke),
                image: member.avatarUrl != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(member.avatarUrl!),
                        fit: BoxFit.cover)
                    : null,
              ),
              child: member.avatarUrl == null
                  ? Center(
                      child: Text(
                        member.name.isNotEmpty
                            ? member.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                            color: context.fg,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        member.name,
                        style: TextStyle(
                            color: context.fg,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                      ...member.roles.map((r) => Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: _RoleBadge(r),
                          )),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [
                      if (member.battingStyle != null) member.battingStyle,
                      if (member.bowlingStyle != null) member.bowlingStyle,
                    ].whereType<String>().join(' · '),
                    style:
                        TextStyle(color: context.fgSub, fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (canManage && _canRemove)
                  GestureDetector(
                    onTap: () => _confirmRemove(context, ref),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: context.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.person_remove_outlined,
                          color: context.danger, size: 16),
                    ),
                  ),
                if (member.swingIndex != null) ...[
                  if (canManage && _canRemove) const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                          color: context.accent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'SI ${member.swingIndex!.toStringAsFixed(1)}',
                      style: TextStyle(
                          color: context.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
                if (member.matchesPlayed != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${member.matchesPlayed} matches',
                    style: TextStyle(color: context.fgSub, fontSize: 10),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge(this.role);

  final String role;

  @override
  Widget build(BuildContext context) {
    final color = switch (role) {
      'Captain' => context.gold,
      'Vice Captain' => context.sky,
      'Wicketkeeper' => context.accent,
      _ => context.fgSub,
    };
    final label = switch (role) {
      'Captain' => 'C',
      'Vice Captain' => 'VC',
      'Wicketkeeper' => 'WK',
      _ => role.isNotEmpty ? role[0] : '?',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800),
      ),
    );
  }
}

// ── Shared card widgets ───────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.stroke),
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader(
      {required this.icon, required this.title, required this.iconColor});

  final IconData icon;
  final String title;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                color: context.fg,
                fontSize: 13,
                fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _SubHeader extends StatelessWidget {
  const _SubHeader(this.label, {required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8)),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric(
      {required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: context.fgSub,
                  fontSize: 10,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  const _BigStat(
      {required this.value, required this.label, this.color});

  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color ?? context.fg,
                  fontSize: 22,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: context.fgSub,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(color: context.fgSub, fontSize: 13))),
          Text(value,
              style: TextStyle(
                  color: context.fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _StatRow2 extends StatelessWidget {
  const _StatRow2(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(label,
                style: TextStyle(color: context.fgSub, fontSize: 11),
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: TextStyle(
                    color: context.fg,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _PerformerRow extends StatelessWidget {
  const _PerformerRow({required this.player});

  final TopStatPlayer player;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: context.panel,
            backgroundImage: player.avatarUrl != null
                ? CachedNetworkImageProvider(player.avatarUrl!)
                : null,
            child: player.avatarUrl == null
                ? Icon(Icons.person, color: context.fgSub, size: 15)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.name,
                    style: TextStyle(
                        color: context.fg,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(player.secondary,
                    style: TextStyle(color: context.fgSub, fontSize: 11)),
              ],
            ),
          ),
          Text(player.value,
              style: TextStyle(
                  color: context.fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w900)),
          const SizedBox(width: 4),
          Text(player.label,
              style: TextStyle(color: context.fgSub, fontSize: 10)),
        ],
      ),
    );
  }
}

class _FormBadge extends StatelessWidget {
  const _FormBadge({required this.result});

  final String result;

  @override
  Widget build(BuildContext context) {
    final color = switch (result.toUpperCase()) {
      'W' => context.success,
      'L' => context.danger,
      'T' || 'D' => context.warn,
      _ => context.fgSub,
    };
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
      child: Center(
        child: Text(result.toUpperCase(),
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard(
      {required this.role,
      required this.member,
      required this.icon,
      required this.color});

  final String role;
  final TeamMember member;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(role,
                  style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
              Text(member.name,
                  style: TextStyle(
                      color: context.fg,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  const _InfoTag(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: context.fgSub),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: context.fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EmptyMsg extends StatelessWidget {
  const _EmptyMsg(this.message, {this.action, this.onAction});

  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.fgSub, fontSize: 14)),
            if (action != null && onAction != null) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 11),
                  decoration: BoxDecoration(
                    color: context.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(action!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Edit team sheet ───────────────────────────────────────────────────────────

class _EditTeamSheet extends ConsumerStatefulWidget {
  const _EditTeamSheet({
    required this.team,
    required this.teamId,
    required this.currentUserId,
    this.callbacks,
    required this.onNavigateBack,
  });

  final PlayerTeam team;
  final String teamId;
  final String? currentUserId;
  final TeamDetailCallbacks? callbacks;
  final VoidCallback onNavigateBack;

  @override
  ConsumerState<_EditTeamSheet> createState() => _EditTeamSheetState();
}

class _EditTeamSheetState extends ConsumerState<_EditTeamSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _shortNameCtrl;
  late final TextEditingController _cityCtrl;
  String? _selectedType;
  bool _saving = false;
  String? _error;
  String? _pendingLogoUrl;
  bool _uploadingLogo = false;

  static const _teamTypes = [
    'CLUB',
    'CORPORATE',
    'SCHOOL',
    'COLLEGE',
    'DISTRICT',
    'PROFESSIONAL',
    'AMATEUR',
    'RECREATIONAL',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.team.name);
    _shortNameCtrl =
        TextEditingController(text: widget.team.shortName ?? '');
    _cityCtrl = TextEditingController(text: widget.team.city ?? '');
    final raw =
        widget.team.teamType?.toUpperCase().replaceAll(' ', '_');
    _selectedType =
        raw != null && _teamTypes.contains(raw) ? raw : null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _shortNameCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    if (widget.callbacks?.onUploadLogo == null) return;
    setState(() => _uploadingLogo = true);
    try {
      final url = await widget.callbacks!.onUploadLogo!(context);
      if (mounted && url != null) {
        setState(() => _pendingLogoUrl = url);
      }
    } finally {
      if (mounted) setState(() => _uploadingLogo = false);
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Team name is required');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    final ctrl = ref.read(teamDetailControllerProvider(
        (teamId: widget.teamId, currentUserId: widget.currentUserId)).notifier);

    final ok = await ctrl.updateTeam(
      name: name,
      shortName: _shortNameCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      teamType: _selectedType,
      logoUrl: _pendingLogoUrl,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Team updated')));
    } else {
      setState(() => _error = ref
              .read(teamDetailControllerProvider(
                  (teamId: widget.teamId, currentUserId: widget.currentUserId)))
              .error ??
          'Could not update team');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLogo = _pendingLogoUrl != null ||
        (widget.team.logoUrl != null && widget.team.logoUrl!.isNotEmpty);
    final displayLogoUrl =
        _pendingLogoUrl ?? widget.team.logoUrl;
    final canUploadLogo = widget.callbacks?.onUploadLogo != null;

    return Padding(
      padding: EdgeInsets.only(
          top: 80, bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: context.bg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                        color: context.stroke,
                        borderRadius: BorderRadius.circular(999)),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Edit Team',
                    style: TextStyle(
                        color: context.fg,
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 20),

                // Logo picker
                if (canUploadLogo)
                  Center(
                    child: GestureDetector(
                      onTap: _saving ? null : _pickLogo,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: context.surf,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _pendingLogoUrl != null
                                    ? context.accent
                                    : context.stroke,
                                width: 2,
                              ),
                              image: hasLogo && displayLogoUrl != null
                                  ? DecorationImage(
                                      image:
                                          NetworkImage(displayLogoUrl),
                                      fit: BoxFit.cover)
                                  : null,
                            ),
                            child: (!hasLogo)
                                ? Icon(Icons.shield_rounded,
                                    color: context.fgSub, size: 36)
                                : null,
                          ),
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: context.accent,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: context.bg, width: 2),
                            ),
                            child: _uploadingLogo
                                ? const Padding(
                                    padding: EdgeInsets.all(5),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : const Icon(Icons.camera_alt_rounded,
                                    color: Colors.white, size: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (canUploadLogo && _pendingLogoUrl != null) ...[
                  const SizedBox(height: 6),
                  Center(
                    child: Text('New logo selected',
                        style:
                            TextStyle(color: context.fgSub, fontSize: 11)),
                  ),
                ],
                if (canUploadLogo) const SizedBox(height: 20),

                _FieldLabel('Team Name'),
                _HostTextField(
                    controller: _nameCtrl,
                    hint: 'e.g. Mumbai Warriors',
                    prefixIcon: Icons.shield_rounded),
                const SizedBox(height: 14),
                _FieldLabel('Short Name'),
                _HostTextField(
                    controller: _shortNameCtrl,
                    hint: 'e.g. MW',
                    prefixIcon: Icons.short_text_rounded),
                const SizedBox(height: 14),
                _FieldLabel('City'),
                _HostTextField(
                    controller: _cityCtrl,
                    hint: 'e.g. Mumbai',
                    prefixIcon: Icons.location_on_outlined),
                const SizedBox(height: 14),
                _FieldLabel('Team Type'),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.surf,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.stroke),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedType,
                      isExpanded: true,
                      dropdownColor: context.surf,
                      hint: Text('Select type',
                          style: TextStyle(
                              color: context.fgSub, fontSize: 14)),
                      items: [
                        DropdownMenuItem<String?>(
                            value: null,
                            child: Text('None',
                                style:
                                    TextStyle(color: context.fgSub))),
                        ..._teamTypes.map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                  t[0] + t.substring(1).toLowerCase(),
                                  style: TextStyle(color: context.fg)),
                            )),
                      ],
                      onChanged: (v) =>
                          setState(() => _selectedType = v),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: TextStyle(
                          color: context.danger, fontSize: 12)),
                ],
                const SizedBox(height: 24),

                GestureDetector(
                  onTap: _saving ? null : _save,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                        color: context.accent,
                        borderRadius: BorderRadius.circular(14)),
                    child: Center(
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Save Changes',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _saving ? null : _confirmDeleteTeam,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: context.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: context.danger.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            color: context.danger, size: 18),
                        const SizedBox(width: 8),
                        Text('Delete Team',
                            style: TextStyle(
                                color: context.danger,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteTeam() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.surf,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Team',
            style: TextStyle(
                color: context.fg, fontWeight: FontWeight.w700)),
        content: Text(
          'Permanently delete "${widget.team.name}"? This cannot be undone.',
          style: TextStyle(color: context.fgSub, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(color: context.fgSub)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: TextStyle(
                    color: context.danger,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _saving = true);
    final ctrl = ref.read(teamDetailControllerProvider(
        (teamId: widget.teamId, currentUserId: widget.currentUserId)).notifier);
    final ok = await ctrl.deleteTeam();
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.of(context).pop();
      widget.onNavigateBack();
    } else {
      setState(() => _error = ref
              .read(teamDetailControllerProvider(
                  (teamId: widget.teamId, currentUserId: widget.currentUserId)))
              .error ??
          'Could not delete team');
    }
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 7),
        child: Text(text,
            style: TextStyle(
                color: context.fgSub,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      );
}

// ── Minimal text field ────────────────────────────────────────────────────────

class _HostTextField extends StatelessWidget {
  const _HostTextField({
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.stroke),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: context.fg, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: context.fgSub),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: context.fgSub, size: 18)
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ── Add player sheet ──────────────────────────────────────────────────────────

class _AddPlayerSheet extends ConsumerStatefulWidget {
  const _AddPlayerSheet({
    required this.team,
    required this.teamId,
    required this.currentUserId,
  });

  final PlayerTeam team;
  final String teamId;
  final String? currentUserId;

  @override
  ConsumerState<_AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends ConsumerState<_AddPlayerSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  // Phone search tab
  final _phoneSearchCtrl = TextEditingController();
  List<TeamPlayerSearchResult> _results = const [];
  bool _searching = false;
  bool _addingSearch = false;
  String? _searchError;

  // Quick-add tab (no account)
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _quickAdding = false;
  String? _quickError;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _phoneSearchCtrl.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    final digits = _phoneSearchCtrl.text.replaceAll(RegExp(r'\D'), '');
    // Auto-search once a full number is entered (10+ digits)
    if (digits.length >= 10 && !_searching) _search();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _phoneSearchCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  TeamDetailController get _ctrl => ref.read(teamDetailControllerProvider(
      (teamId: widget.teamId, currentUserId: widget.currentUserId)).notifier);

  Future<void> _search() async {
    final q = _phoneSearchCtrl.text.trim();
    if (q.length < 2) {
      setState(() {
        _results = const [];
        _searchError = 'Enter a phone number';
      });
      return;
    }
    setState(() {
      _searching = true;
      _searchError = null;
      _results = const [];
    });
    final res = await _ctrl.searchPlayers(q);
    if (!mounted) return;
    setState(() {
      _searching = false;
      _results = res
          .where((p) => !widget.team.members.any((m) => m.userId == p.userId))
          .toList();
      if (_results.isEmpty) _searchError = 'No player found with this number';
    });
  }

  Future<void> _addSearch(TeamPlayerSearchResult player) async {
    setState(() {
      _addingSearch = true;
      _searchError = null;
    });
    final ok = await _ctrl.addPlayer(player.profileId);
    if (!mounted) return;
    setState(() => _addingSearch = false);
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${player.name} added')));
    } else {
      setState(() => _searchError = ref
              .read(teamDetailControllerProvider(
                  (teamId: widget.teamId, currentUserId: widget.currentUserId)))
              .error ??
          'Could not add player');
    }
  }

  Future<void> _quickAdd() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _quickError = 'Enter player name');
      return;
    }
    if (phone.isEmpty) {
      setState(() => _quickError = 'Enter phone number');
      return;
    }
    setState(() {
      _quickAdding = true;
      _quickError = null;
    });
    final ok = await _ctrl.quickAddPlayer(name: name, phone: phone);
    if (!mounted) return;
    setState(() => _quickAdding = false);
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$name added to squad')));
    } else {
      setState(() => _quickError = ref
              .read(teamDetailControllerProvider(
                  (teamId: widget.teamId, currentUserId: widget.currentUserId)))
              .error ??
          'Could not add player');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: 80, bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: context.bg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                        color: context.stroke,
                        borderRadius: BorderRadius.circular(999)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Player',
                        style: TextStyle(
                            color: context.fg,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: context.surf,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: context.stroke),
                      ),
                      child: TabBar(
                        controller: _tabs,
                        indicator: BoxDecoration(
                            color: context.accentBg,
                            borderRadius: BorderRadius.circular(10)),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: context.accent,
                        unselectedLabelColor: context.fgSub,
                        labelStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                        tabs: const [
                          Tab(text: 'By Phone'),
                          Tab(text: 'Quick Add')
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 300,
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    // By Phone
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Enter player\'s mobile number',
                              style: TextStyle(
                                  color: context.fgSub,
                                  fontSize: 12,
                                  height: 1.4)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _HostTextField(
                                    controller: _phoneSearchCtrl,
                                    hint: '10-digit mobile number',
                                    prefixIcon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: _searching || _addingSearch
                                    ? null
                                    : _search,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      color: context.accent,
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                  child: _searching
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white))
                                      : const Icon(
                                          Icons.search_rounded,
                                          color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          if (_searchError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(_searchError!,
                                  style: TextStyle(
                                      color: context.danger, fontSize: 12)),
                            ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: _results.isEmpty && !_searching
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.phone_outlined,
                                            size: 32, color: context.fgSub),
                                        const SizedBox(height: 8),
                                        Text(
                                            _searchError == null
                                                ? 'Player will appear here'
                                                : '',
                                            style: TextStyle(
                                                color: context.fgSub,
                                                fontSize: 13)),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: _results.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (_, i) {
                                      final p = _results[i];
                                      return _SearchTile(
                                          player: p,
                                          submitting: _addingSearch,
                                          onAdd: () => _addSearch(p));
                                    }),
                          ),
                        ],
                      ),
                    ),
                    // Quick add
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Add without an account.',
                              style: TextStyle(
                                  color: context.fgSub,
                                  fontSize: 12,
                                  height: 1.4)),
                          const SizedBox(height: 14),
                          _HostTextField(
                              controller: _nameCtrl,
                              hint: 'Player name',
                              prefixIcon: Icons.person_outline_rounded),
                          const SizedBox(height: 10),
                          _HostTextField(
                              controller: _phoneCtrl,
                              hint: 'Phone number',
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone),
                          if (_quickError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(_quickError!,
                                  style: TextStyle(
                                      color: context.danger,
                                      fontSize: 12)),
                            ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _quickAdding ? null : _quickAdd,
                            child: Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                  color: context.accent,
                                  borderRadius:
                                      BorderRadius.circular(14)),
                              child: Center(
                                child: _quickAdding
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : const Text('Add to Squad',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.w700)),
                              ),
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
    );
  }
}

class _SearchTile extends StatelessWidget {
  const _SearchTile(
      {required this.player,
      required this.submitting,
      required this.onAdd});

  final TeamPlayerSearchResult player;
  final bool submitting;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: context.accentBg,
            backgroundImage: player.avatarUrl != null
                ? CachedNetworkImageProvider(player.avatarUrl!)
                : null,
            child: player.avatarUrl == null
                ? Text(
                    player.name.isEmpty ? '?' : player.name[0].toUpperCase(),
                    style: TextStyle(
                        color: context.accent, fontWeight: FontWeight.w700))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.name,
                    style: TextStyle(
                        color: context.fg,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                if (_hasText(player.phone) || _hasText(player.playerRole))
                  Text(
                    [
                      if (_hasText(player.phone)) player.phone,
                      if (_hasText(player.playerRole)) player.playerRole
                    ].whereType<String>().join(' • '),
                    style:
                        TextStyle(color: context.fgSub, fontSize: 11),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: submitting ? null : onAdd,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.accentBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: context.accent.withValues(alpha: 0.2)),
              ),
              child: submitting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: context.accent))
                  : Text('Add',
                      style: TextStyle(
                          color: context.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Join team sheet ───────────────────────────────────────────────────────────

class _JoinTeamSheet extends ConsumerStatefulWidget {
  const _JoinTeamSheet({
    required this.team,
    required this.teamId,
    required this.currentUserId,
  });

  final PlayerTeam team;
  final String teamId;
  final String? currentUserId;

  @override
  ConsumerState<_JoinTeamSheet> createState() => _JoinTeamSheetState();
}

class _JoinTeamSheetState extends ConsumerState<_JoinTeamSheet> {
  bool _joining = false;

  Future<void> _join() async {
    setState(() => _joining = true);
    final ctrl = ref.read(teamDetailControllerProvider(
        (teamId: widget.teamId, currentUserId: widget.currentUserId)).notifier);
    final ok = await ctrl.joinTeam();
    if (!mounted) return;
    setState(() => _joining = false);
    Navigator.pop(context);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You joined ${widget.team.name}!')),
      );
    } else {
      final error = ref
          .read(teamDetailControllerProvider(
              (teamId: widget.teamId, currentUserId: widget.currentUserId)))
          .error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Could not join team.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.bg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                  color: context.stroke,
                  borderRadius: BorderRadius.circular(999)),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.accentBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.groups_rounded,
                  color: context.accent, size: 36),
            ),
            const SizedBox(height: 16),
            Text("You're invited!",
                style: TextStyle(
                    color: context.fg,
                    fontSize: 20,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text('Join ${widget.team.name} on Swing Cricket',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.fgSub, fontSize: 14)),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _joining ? null : _join,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                    color: context.accent,
                    borderRadius: BorderRadius.circular(14)),
                child: Center(
                  child: _joining
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Join Team',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Not now',
                    style: TextStyle(color: context.fgSub, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Team QR sheet ─────────────────────────────────────────────────────────────

class _TeamQrSheet extends StatefulWidget {
  const _TeamQrSheet({required this.team});

  final PlayerTeam team;

  @override
  State<_TeamQrSheet> createState() => _TeamQrSheetState();
}

class _TeamQrSheetState extends State<_TeamQrSheet> {
  bool _copied = false;

  Future<void> _copyLink(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final joinUrl = _teamJoinUrl(widget.team);

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.bg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                  color: context.stroke,
                  borderRadius: BorderRadius.circular(999)),
            ),
            const SizedBox(height: 18),
            Text(widget.team.name,
                style: TextStyle(
                    color: context.fg,
                    fontSize: 18,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('Scan or share to invite players',
                style: TextStyle(color: context.fgSub, fontSize: 12)),
            const SizedBox(height: 20),
            // Real QR code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20)),
              child: QrImageView(
                data: joinUrl,
                version: QrVersions.auto,
                size: 180,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            // Link row
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: context.surf,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.stroke),
              ),
              child: Row(
                children: [
                  Icon(Icons.link_rounded,
                      size: 16, color: context.fgSub),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      joinUrl,
                      style:
                          TextStyle(color: context.fgSub, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _copyLink(joinUrl),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _copied ? context.success.withValues(alpha: 0.12) : context.surf,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: _copied ? context.success : context.stroke),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _copied
                                  ? Icons.check_rounded
                                  : Icons.copy_rounded,
                              size: 16,
                              color: _copied ? context.success : context.fg,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _copied ? 'Copied!' : 'Copy Link',
                              style: TextStyle(
                                  color: _copied
                                      ? context.success
                                      : context.fg,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Share.share(
                      'Join ${widget.team.name} on Swing Cricket! $joinUrl',
                      subject: 'Join my cricket squad',
                    ),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                          color: context.accent,
                          borderRadius: BorderRadius.circular(14)),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.share_rounded,
                                size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            const Text('Share',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

void _showTeamQrSheet(BuildContext context, PlayerTeam team) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _TeamQrSheet(team: team),
  );
}

TeamMember? _memberForRole(PlayerTeam team, String role) {
  for (final m in team.members) {
    if (m.roles.contains(role)) return m;
  }
  return null;
}

bool _hasText(String? v) => v != null && v.trim().isNotEmpty;

String _initials(PlayerTeam team) {
  final src = _hasText(team.shortName) ? team.shortName! : team.name;
  return src.length >= 2
      ? src.substring(0, 2).toUpperCase()
      : src.toUpperCase();
}

String _teamJoinUrl(PlayerTeam team) =>
    'https://swingcricketapp.com/team/${team.id}/join';
