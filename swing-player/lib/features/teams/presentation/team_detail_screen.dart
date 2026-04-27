import "package:cached_network_image/cached_network_image.dart";
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/storage/supabase_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../create_match/presentation/form_widgets.dart';
import '../../matches/data/matches_repository.dart';
import '../../matches/domain/match_models.dart';
import '../controller/teams_controller.dart';
import '../domain/team_models.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final teamPerformanceProvider =
    FutureProvider.autoDispose.family<TeamPerformanceSummary, PlayerTeam>((
  ref,
  team,
) async {
  final matches = await MatchesRepository().loadMyMatches();
  return TeamPerformanceSummary.from(team: team, matches: matches);
});

final publicTeamProvider = FutureProvider.autoDispose
    .family<PlayerTeam, ({String teamId, PlayerTeam? initialTeam})>((
  ref,
  args,
) async {
  try {
    final dio = ApiClient.instance.dio;
    final res = await dio.get(ApiEndpoints.playerTeamPublic(args.teamId));
    final body = res.data;
    final raw = body is Map<String, dynamic>
        ? (body['data'] ?? body['team'] ?? body) as Map<String, dynamic>
        : <String, dynamic>{};

    String s(String k, {String fb = ''}) =>
        (raw[k]?.toString().trim().isNotEmpty == true)
            ? raw[k].toString().trim()
            : fb;

    List<dynamic> players = [];
    final playersNode = raw['players'] ?? raw['squad'] ?? raw['members'];
    if (playersNode is List) players = playersNode;

    final members = players.whereType<Map<String, dynamic>>().map((p) {
      final user = p['user'] is Map<String, dynamic>
          ? p['user'] as Map<String, dynamic>
          : <String, dynamic>{};
      String us(String k) => (user[k]?.toString().trim() ?? '');
      final name = us('name').isNotEmpty
          ? us('name')
          : (p['name']?.toString() ?? 'Player');
      return TeamMember(
        profileId: (p['id'] ?? p['profileId'] ?? '').toString(),
        userId:
            us('id').isNotEmpty ? us('id') : (p['userId']?.toString() ?? ''),
        name: name,
        avatarUrl: us('avatarUrl').isNotEmpty
            ? us('avatarUrl')
            : (p['avatarUrl']?.toString().isNotEmpty == true
                ? p['avatarUrl'].toString()
                : null),
        battingStyle: (p['battingStyle'] as String?)?.replaceAll('_', ' '),
        bowlingStyle: (p['bowlingStyle'] as String?)?.replaceAll('_', ' '),
        swingIndex: (p['swingIndex'] as num?)?.toDouble(),
        totalXp: (p['totalXp'] as num?)?.toInt(),
        swingRank: p['swingRank'] as String?,
        totalRuns: (p['totalRuns'] as num?)?.toInt(),
        totalWickets: (p['totalWickets'] as num?)?.toInt(),
        matchesPlayed: (p['matchesPlayed'] as num?)?.toInt(),
        matchesWon: (p['matchesWon'] as num?)?.toInt(),
      );
    }).toList();

    return PlayerTeam(
      id: s('id').isNotEmpty
          ? s('id')
          : s('_id').isNotEmpty
              ? s('_id')
              : s('teamId', fb: args.teamId),
      name: s('name', fb: args.initialTeam?.name ?? 'Team'),
      shortName: s('shortName').isNotEmpty
          ? s('shortName')
          : args.initialTeam?.shortName,
      logoUrl:
          s('logoUrl').isNotEmpty ? s('logoUrl') : args.initialTeam?.logoUrl,
      city: s('city').isNotEmpty ? s('city') : args.initialTeam?.city,
      teamType: s('teamType').isNotEmpty
          ? s('teamType').replaceAll('_', ' ')
          : args.initialTeam?.teamType,
      members: members,
      isOwner: false,
    );
  } catch (e) {
    debugPrint('[PublicTeam] error: $e');
    if (args.initialTeam != null) return args.initialTeam!;
    rethrow;
  }
});

final teamMatchesProvider = FutureProvider.autoDispose
    .family<List<PlayerMatch>, String>((ref, teamId) async {
  try {
    return await MatchesRepository().loadTeamMatches(teamId);
  } catch (e) {
    debugPrint('[TeamMatches] failed: $e');
    return [];
  }
});

final teamAnalyticsProvider =
    FutureProvider.autoDispose.family<TeamAnalytics, String>((ref, teamId) async {
  debugPrint('[TeamAnalytics] → GET analytics for team $teamId');
  final dio = ApiClient.instance.dio;
  try {
    final res = await dio.get(ApiEndpoints.eliteTeamAnalytics(teamId));
    debugPrint('[TeamAnalytics] ← ${res.statusCode}');
    final body = res.data;
    final top = body is Map<String, dynamic> ? body : <String, dynamic>{};
    debugPrint('[TeamAnalytics] top-level keys: ${top.keys.toList()}');
    final raw = (top['data'] ?? top['analytics'] ?? top) as Map<String, dynamic>;
    debugPrint('[TeamAnalytics] raw keys: ${raw.keys.toList()} | powerScore=${raw['powerScore']}');
    debugPrint('[TeamAnalytics] matchContext: ${raw['matchContext']}');
    debugPrint('[TeamAnalytics] FULL RESPONSE: $raw');
    return TeamAnalytics.fromJson(raw);
  } catch (e) {
    debugPrint('[TeamAnalytics] ERROR: $e');
    rethrow;
  }
});

// ── Screen entry ──────────────────────────────────────────────────────────────

class TeamDetailScreen extends ConsumerStatefulWidget {
  const TeamDetailScreen({
    super.key,
    required this.teamId,
    this.initialTeam,
    this.autoJoin = false,
  });

  final String teamId;
  final PlayerTeam? initialTeam;
  /// When true (opened via a WhatsApp invite link) the join sheet fires
  /// automatically once the team data is available.
  final bool autoJoin;

  static AppBar buildLoadingAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _kBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 18),
        onPressed: () => context.pop(),
      ),
    );
  }

  @override
  ConsumerState<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends ConsumerState<TeamDetailScreen> {
  bool _joinSheetScheduled = false;

  void _maybeShowJoinSheet(PlayerTeam team) {
    if (!widget.autoJoin || _joinSheetScheduled) return;
    _joinSheetScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => _JoinTeamSheet(team: team),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamsControllerProvider);
    final ownedTeam = _findTeamById(state.teams, widget.teamId);

    if (ownedTeam != null) {
      return _TeamScreen(team: ownedTeam, isOwnTeam: ownedTeam.isOwner);
    }

    final asyncTeam = ref.watch(
      publicTeamProvider((teamId: widget.teamId, initialTeam: widget.initialTeam)),
    );
    return asyncTeam.when(
      loading: () => Scaffold(
        backgroundColor: _kBg,
        appBar: TeamDetailScreen.buildLoadingAppBar(context),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: _kBg,
        appBar: TeamDetailScreen.buildLoadingAppBar(context),
        body: Center(
          child: Text('Could not load team',
              style: TextStyle(color: context.fgSub)),
        ),
      ),
      data: (team) {
        _maybeShowJoinSheet(team);
        return _TeamScreen(team: team);
      },
    );
  }
}

const _kBg = Color(0xFF0A0A0A);
const _kCard = Color(0xFF141414);
const _kBorder = Color(0xFF232323);

// ── Main screen ───────────────────────────────────────────────────────────────

class _TeamScreen extends ConsumerWidget {
  const _TeamScreen({required this.team, this.isOwnTeam = false});
  final PlayerTeam team;
  final bool isOwnTeam;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: _kBg,
        body: NestedScrollView(
          headerSliverBuilder: (ctx, _) => [
            // ── AppBar (edit button lives here — always visible) ──────────
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: _kBg,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
                onPressed: () => context.pop(),
              ),
              title: Text(
                team.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                if (isOwnTeam)
                  IconButton(
                    icon: const Icon(Icons.edit_rounded,
                        color: Colors.white, size: 20),
                    tooltip: 'Edit team',
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _EditTeamSheet(team: team),
                    ),
                  ),
                if (isOwnTeam) ...[
                  IconButton(
                    icon: const Icon(Icons.qr_code_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () {
                      final matches = ref.read(teamMatchesProvider(team.id)).asData?.value ?? [];
                      final played = matches.where((m) => m.lifecycle == MatchLifecycle.past).toList();
                      _showTeamQrSheet(
                        context,
                        team,
                        played: played.length,
                        wins: played.where((m) => m.result == MatchResult.win).length,
                        losses: played.where((m) => m.result == MatchResult.loss).length,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => _shareViaWhatsApp(team),
                  ),
                ],
                const SizedBox(width: 4),
              ],
            ),

            // ── Hero header ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _TeamHeroHeader(
                team: team,
                isOwnTeam: isOwnTeam,
              ),
            ),

            // ── Sticky tab bar ────────────────────────────────────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBar(
                TabBar(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  indicatorColor: Colors.white,
                  indicatorWeight: 2,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: _kBorder,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white38,
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
              _OverviewTab(team: team),
              _StatsTab(team: team),
              _MatchesTab(teamId: team.id),
              _SquadTab(team: team, isOwnTeam: isOwnTeam),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero header ───────────────────────────────────────────────────────────────

class _TeamHeroHeader extends ConsumerWidget {
  const _TeamHeroHeader({required this.team, required this.isOwnTeam});
  final PlayerTeam team;
  final bool isOwnTeam;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(teamAnalyticsProvider(team.id));
    final analytics = analyticsAsync.asData?.value;

    return Container(
      color: _kBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team identity row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Row(
              children: [
                // Logo
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _kBorder, width: 1.5),
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
                            style: const TextStyle(
                                color: Colors.white,
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
                        style: const TextStyle(
                          color: Colors.white,
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
                            _Pill(team.city!, color: Colors.white30),
                          if (_hasText(team.teamType))
                            _Pill(team.teamType!, color: Colors.white30),
                          _Pill(
                            '${team.members.length} players',
                            color: Colors.white24,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Stats strip
          if (analytics != null && analytics.summary.matchesPlayed > 0)
            _HeroStatsStrip(analytics: analytics)
          else
            _HeroStatsStripFallback(team: team, ref: ref, isOwnTeam: isOwnTeam),

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
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          _HeroStat(value: '${s.matchesPlayed}', label: 'Played'),
          _HeroStatDivider(),
          _HeroStat(
              value: '${s.totalWins}', label: 'Won', color: const Color(0xFF4CAF50)),
          _HeroStatDivider(),
          _HeroStat(
              value: '${s.totalLosses}', label: 'Lost', color: const Color(0xFFEF5350)),
          _HeroStatDivider(),
          _HeroStat(
            value: '${(s.winRate * 100).toStringAsFixed(0)}%',
            label: 'Win Rate',
            color: Colors.white,
          ),
          _HeroStatDivider(),
          _HeroStat(
            value: analytics.nrr >= 0
                ? '+${analytics.nrr.toStringAsFixed(2)}'
                : analytics.nrr.toStringAsFixed(2),
            label: 'NRR',
            color: analytics.nrr >= 0
                ? const Color(0xFF4CAF50)
                : const Color(0xFFEF5350),
          ),
        ],
      ),
    );
  }
}

class _HeroStatsStripFallback extends StatelessWidget {
  const _HeroStatsStripFallback(
      {required this.team, required this.ref, required this.isOwnTeam});
  final PlayerTeam team;
  final WidgetRef ref;
  final bool isOwnTeam;

  @override
  Widget build(BuildContext context) {
    final matchesAsync = ref.watch(teamMatchesProvider(team.id));
    final matches = matchesAsync.asData?.value ?? [];
    final played =
        matches.where((m) => m.lifecycle == MatchLifecycle.past).toList();
    final wins = played.where((m) => m.result == MatchResult.win).length;
    final losses = played.where((m) => m.result == MatchResult.loss).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          _HeroStat(value: '${played.length}', label: 'Played'),
          _HeroStatDivider(),
          _HeroStat(
              value: '$wins', label: 'Won', color: const Color(0xFF4CAF50)),
          _HeroStatDivider(),
          _HeroStat(
              value: '$losses', label: 'Lost', color: const Color(0xFFEF5350)),
          _HeroStatDivider(),
          _HeroStat(value: '${team.members.length}', label: 'Players'),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat(
      {required this.value, required this.label, this.color = Colors.white});
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
              style: const TextStyle(
                  color: Colors.white38,
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
      Container(width: 1, height: 28, color: _kBorder);
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
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 48,
      color: _kBg,
      child: Column(
        children: [
          Expanded(child: tabBar),
          Container(height: 1, color: _kBorder),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyTabBar old) => old.tabBar != tabBar;
}

// ── Overview tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({required this.team});
  final PlayerTeam team;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(teamAnalyticsProvider(team.id));
    final analytics = analyticsAsync.asData?.value;
    final captain = _memberForRole(team, 'Captain');
    final viceCaptain = _memberForRole(team, 'Vice Captain');
    final wicketKeeper = _memberForRole(team, 'Wicketkeeper');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      children: [
        // ── Performance block ────────────────────────────────────────────
        if (analytics != null && analytics.summary.matchesPlayed > 0) ...[
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(
                    icon: Icons.bolt_rounded,
                    title: 'Performance',
                    iconColor: const Color(0xFFFFB300)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _OverviewMetric(
                      value:
                          '${analytics.powerScore.toStringAsFixed(0)}',
                      label: 'Power Score',
                      color: const Color(0xFFFFB300),
                    ),
                    _OverviewMetric(
                      value:
                          '${(analytics.summary.winRate * 100).toStringAsFixed(0)}%',
                      label: 'Win Rate',
                      color: const Color(0xFF4CAF50),
                    ),
                    _OverviewMetric(
                      value: analytics.nrr >= 0
                          ? '+${analytics.nrr.toStringAsFixed(2)}'
                          : analytics.nrr.toStringAsFixed(2),
                      label: 'NRR',
                      color: analytics.nrr >= 0
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFEF5350),
                    ),
                    if (analytics.summary.winStreak > 0)
                      _OverviewMetric(
                        value: '${analytics.summary.winStreak}',
                        label: 'Streak 🔥',
                        color: Colors.white,
                      ),
                  ],
                ),
                if (analytics.summary.recentForm.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Divider(color: _kBorder, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Text('FORM',
                          style: TextStyle(
                              color: Colors.white38,
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

        // ── Key players ──────────────────────────────────────────────────
        if (analytics != null &&
            (analytics.topBatsmen.isNotEmpty ||
                analytics.topBowlers.isNotEmpty)) ...[
          _Card(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: _CardHeader(
                    icon: Icons.stars_rounded,
                    title: 'Key Players',
                    iconColor: Color(0xFFFFB300),
                  ),
                ),
                if (analytics.topBatsmen.isNotEmpty) ...[
                  const _SubHeader('BATTING', color: Color(0xFF5B8FD4)),
                  ...analytics.topBatsmen
                      .take(3)
                      .map((p) => _PerformerRow(player: p)),
                ],
                if (analytics.topBowlers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const _SubHeader('BOWLING', color: Color(0xFF9B7FD4)),
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

        // ── Leadership ───────────────────────────────────────────────────
        if (captain != null || viceCaptain != null || wicketKeeper != null) ...[
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardHeader(
                  icon: Icons.workspace_premium_rounded,
                  title: 'Leadership',
                  iconColor: Color(0xFFFFB300),
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
                        color: const Color(0xFFFFB300),
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
                        color: const Color(0xFF5B8FD4),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── About ────────────────────────────────────────────────────────
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CardHeader(
                icon: Icons.info_outline_rounded,
                title: 'About',
                iconColor: Colors.white54,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_hasText(team.city))
                    _InfoTag(
                        Icons.location_on_outlined, team.city!),
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

class _StatsTab extends ConsumerWidget {
  const _StatsTab({required this.team});
  final PlayerTeam team;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAnalytics = ref.watch(teamAnalyticsProvider(team.id));

    return asyncAnalytics.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) {
        // Error: show what we know from local team data
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
          children: [
            _Card(
              child: Column(
                children: [
                  Icon(Icons.analytics_outlined,
                      color: Colors.white24, size: 40),
                  const SizedBox(height: 12),
                  const Text('Detailed stats unavailable',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(
                    'Analytics data will appear once the team has played matches.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white38, fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Still show member count, avg swing from local data
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CardHeader(
                      icon: Icons.people_outline_rounded,
                      title: 'Squad Overview',
                      iconColor: Colors.white54),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _BigStat(
                        value: '${team.members.length}',
                        label: 'Players',
                      ),
                      if (team.averageSwingIndex != null)
                        _BigStat(
                          value:
                              team.averageSwingIndex!.toStringAsFixed(1),
                          label: 'Avg SI',
                          color: const Color(0xFFFFB300),
                        ),
                      _BigStat(
                        value: '${team.membersByRuns.firstOrNull?.totalRuns ?? 0}',
                        label: 'Top Runs',
                        color: const Color(0xFF5B8FD4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
      data: (a) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
        children: [
          // ── Power + NRR ─────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('POWER SCORE',
                          style: TextStyle(
                              color: Color(0xFFFFB300),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 8),
                      Text(
                        a.powerScore.toStringAsFixed(0),
                        style: const TextStyle(
                            color: Color(0xFFFFB300),
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
                      const Text('NET RUN RATE',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 8),
                      Text(
                        a.nrr >= 0
                            ? '+${a.nrr.toStringAsFixed(3)}'
                            : a.nrr.toStringAsFixed(3),
                        style: TextStyle(
                            color: a.nrr >= 0
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFEF5350),
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

          // ── Summary & form ──────────────────────────────────────────
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardHeader(
                    icon: Icons.insights_rounded,
                    title: 'Summary',
                    iconColor: Color(0xFF5B8FD4)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _BigStat(
                        value: '${a.summary.matchesPlayed}',
                        label: 'Matches'),
                    _BigStat(
                        value: '${a.summary.totalWins}',
                        label: 'Won',
                        color: const Color(0xFF4CAF50)),
                    _BigStat(
                        value: '${a.summary.totalLosses}',
                        label: 'Lost',
                        color: const Color(0xFFEF5350)),
                    _BigStat(
                        value:
                            '${(a.summary.winRate * 100).toStringAsFixed(0)}%',
                        label: 'Win Rate'),
                  ],
                ),
                if (a.summary.recentForm.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Divider(color: _kBorder, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Text('RECENT FORM',
                          style: TextStyle(
                              color: Colors.white38,
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

          // ── Batting / Bowling side by side ──────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _CardHeader(
                          icon: Icons.sports_cricket_rounded,
                          title: 'Batting',
                          iconColor: Color(0xFF5B8FD4)),
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
                      const _CardHeader(
                          icon: Icons.sports_baseball_rounded,
                          title: 'Bowling',
                          iconColor: Color(0xFF9B7FD4)),
                      const SizedBox(height: 14),
                      _StatRow2('Economy',
                          a.bowling.averageEconomy.toStringAsFixed(2)),
                      _StatRow2('Total Wkts',
                          '${a.bowling.totalWickets}'),
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

          // ── Strategy ────────────────────────────────────────────────
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardHeader(
                    icon: Icons.psychology_alt_rounded,
                    title: 'Strategy',
                    iconColor: Color(0xFF9B7FD4)),
                const SizedBox(height: 14),
                _StatRow('Bat First Win %',
                    '${(a.strategy.battingFirstWinRate * 100).toStringAsFixed(0)}%'),
                _StatRow('Chase Win %',
                    '${(a.strategy.chasingWinRate * 100).toStringAsFixed(0)}%'),
                Divider(color: _kBorder, height: 20),
                _StatRow('Toss Win → Match Win',
                    '${(a.strategy.tossWinMatchWinRate * 100).toStringAsFixed(0)}%'),
                _StatRow('Toss Lost → Match Win',
                    '${(a.strategy.tossLossMatchWinRate * 100).toStringAsFixed(0)}%'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Top performers ──────────────────────────────────────────
          if (a.topBatsmen.isNotEmpty || a.topBowlers.isNotEmpty)
            _Card(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: _CardHeader(
                        icon: Icons.stars_rounded,
                        title: 'Top Performers',
                        iconColor: Color(0xFFFFB300)),
                  ),
                  if (a.topBatsmen.isNotEmpty) ...[
                    const _SubHeader('TOP SCORERS',
                        color: Color(0xFF5B8FD4)),
                    ...a.topBatsmen.map((p) => _PerformerRow(player: p)),
                  ],
                  if (a.topBowlers.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const _SubHeader('WICKET TAKERS',
                        color: Color(0xFF9B7FD4)),
                    ...a.topBowlers.map((p) => _PerformerRow(player: p)),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),

          // ── Venue performance ────────────────────────────────────────
          if (a.venues.isNotEmpty) ...[
            const SizedBox(height: 12),
            _Card(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: _CardHeader(
                        icon: Icons.location_on_outlined,
                        title: 'Venue Performance',
                        iconColor: Colors.white54),
                  ),
                  ...a.venues.map((v) => Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(v.venueName,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                            ),
                            Text('${v.matches} matches',
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 11)),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${(v.winRate * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                    color: Color(0xFF4CAF50),
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
      ),
    );
  }
}

// ── Matches tab ───────────────────────────────────────────────────────────────

class _MatchesTab extends ConsumerStatefulWidget {
  const _MatchesTab({required this.teamId});
  final String teamId;

  @override
  ConsumerState<_MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends ConsumerState<_MatchesTab> {
  int _filter = 1; // 0=Live  1=Upcoming  2=Completed

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

  @override
  Widget build(BuildContext context) {
    final asyncMatches = ref.watch(teamMatchesProvider(widget.teamId));

    return asyncMatches.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const _EmptyMsg('Could not load matches.'),
      data: (all) {
        final live = _sort(
            all.where((m) => m.lifecycle == MatchLifecycle.live).toList(),
            false);
        final upcoming = _sort(
            all.where((m) => m.lifecycle == MatchLifecycle.upcoming).toList(),
            false);
        final completed = _sort(
            all.where((m) => m.lifecycle == MatchLifecycle.past).toList(),
            true);

        final tabs = [
          (label: 'Live', color: const Color(0xFF4CAF50), list: live),
          (
            label: 'Upcoming',
            color: const Color(0xFF5B8FD4),
            list: upcoming
          ),
          (label: 'Completed', color: Colors.white54, list: completed),
        ];

        final current = tabs[_filter].list;

        return Column(
          children: [
            // ── Sub-tab selector ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                children: List.generate(tabs.length, (i) {
                  final t = tabs[i];
                  final isSelected = i == _filter;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = i),
                      child: Container(
                        margin: EdgeInsets.only(
                            right: i < tabs.length - 1 ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? t.color.withValues(alpha: 0.14)
                              : _kCard,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: isSelected
                                ? t.color.withValues(alpha: 0.45)
                                : _kBorder,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t.label,
                              style: TextStyle(
                                color: isSelected ? t.color : Colors.white38,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${t.list.length}',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white30,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ── Match list ──────────────────────────────────────────────
            Expanded(
              child: current.isEmpty
                  ? _EmptyMsg(switch (_filter) {
                      0 => 'No live matches.',
                      1 => 'No upcoming matches.',
                      _ => 'No completed matches.',
                    })
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 48),
                      itemCount: current.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, i) =>
                          _MatchCard(match: current[i]),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});
  final PlayerMatch match;

  @override
  Widget build(BuildContext context) {
    final isLive = match.lifecycle == MatchLifecycle.live;
    final isUpcoming = match.lifecycle == MatchLifecycle.upcoming;
    final isPast = match.lifecycle == MatchLifecycle.past;

    final resultColor = switch (match.result) {
      MatchResult.win  => const Color(0xFF4CAF50),
      MatchResult.loss => const Color(0xFFEF5350),
      MatchResult.draw => const Color(0xFFFFB300),
      MatchResult.unknown => Colors.white24,
    };
    final resultLabel = switch (match.result) {
      MatchResult.win  => 'WON',
      MatchResult.loss => 'LOST',
      MatchResult.draw => 'DRAW',
      MatchResult.unknown => isLive ? 'LIVE' : '–',
    };
    final accentColor = isLive
        ? const Color(0xFF4CAF50)
        : isPast ? resultColor : const Color(0xFF5B8FD4);

    final teamA = match.playerTeamName.isNotEmpty
        ? match.playerTeamName
        : match.title.split(' vs ').firstOrNull ?? match.title;
    final teamB = match.opponentTeamName.isNotEmpty
        ? match.opponentTeamName
        : (match.title.contains(' vs ')
            ? match.title.split(' vs ').last
            : '');

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: match.id.isNotEmpty
            ? () => context.push(
                '/match/${Uri.encodeComponent(match.id)}', extra: match)
            : null,
        child: Container(
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: accentColor.withValues(alpha: isPast ? 0.25 : 0.18),
              width: isLive ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Colored accent strip ─────────────────────────────────
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.7),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18)),
                ),
              ),

              // ── Header row ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Row(
                  children: [
                    // Status pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLive) ...[
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                          ],
                          Text(
                            isUpcoming ? 'UPCOMING' : resultLabel,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Format badge
                    if (_hasText(match.formatLabel))
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          match.formatLabel!.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6),
                        ),
                      ),
                    const Spacer(),
                    if (match.scheduledAt != null)
                      Text(
                        DateFormat('d MMM yyyy').format(match.scheduledAt!),
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10),
                      ),
                  ],
                ),
              ),

              // ── Teams vs row ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Our team
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teamA,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          const Text('Your Team',
                              style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    // VS divider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          Text(
                            'vs',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.25),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                    // Opponent
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            teamB.isNotEmpty ? teamB : 'TBD',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          const Text('Opponent',
                              style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Score summary ────────────────────────────────────────
              if (_hasText(match.scoreSummary)) ...[
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.07)),
                  ),
                  child: Text(
                    match.scoreSummary!,
                    style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              // ── Footer: venue + competition + chevron ────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                child: Row(
                  children: [
                    if (_hasText(match.venueLabel)) ...[
                      const Icon(Icons.location_on_outlined,
                          color: Colors.white24, size: 11),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          match.venueLabel!,
                          style: const TextStyle(
                              color: Colors.white30, fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else if (_hasText(match.competitionLabel)) ...[
                      const Icon(Icons.emoji_events_outlined,
                          color: Colors.white24, size: 11),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          match.competitionLabel!,
                          style: const TextStyle(
                              color: Colors.white30, fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else
                      const Spacer(),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Text(
                          'Scorecard',
                          style: TextStyle(
                              color: accentColor.withValues(alpha: 0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.arrow_forward_ios_rounded,
                            color: accentColor.withValues(alpha: 0.7),
                            size: 9),
                      ],
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

// ── Squad tab ─────────────────────────────────────────────────────────────────

class _SquadTab extends StatelessWidget {
  const _SquadTab({required this.team, this.isOwnTeam = false});
  final PlayerTeam team;
  final bool isOwnTeam;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      children: [
        // Header row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SQUAD',
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                  const SizedBox(height: 3),
                  Text('${team.members.length} Players',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            if (isOwnTeam)
              GestureDetector(
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _AddPlayerSheet(team: team),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: context.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: context.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_add_alt_1_rounded,
                          color: context.accent, size: 16),
                      const SizedBox(width: 7),
                      Text('Add Player',
                          style: TextStyle(
                              color: context.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        if (team.members.isEmpty)
          const _EmptyMsg('No players added yet.')
        else
          ...team.members.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MemberCard(
                    member: m, isOwnTeam: isOwnTeam, teamId: team.id),
              )),
      ],
    );
  }
}

class _MemberCard extends ConsumerWidget {
  const _MemberCard({
    required this.member,
    this.isOwnTeam = false,
    this.teamId,
  });
  final TeamMember member;
  final bool isOwnTeam;
  final String? teamId;

  // Best ID to use for the remove API call — profileId first, userId as fallback
  String get _removeId =>
      member.profileId.isNotEmpty ? member.profileId : member.userId;

  bool get _canRemove => teamId != null && _removeId.isNotEmpty;

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Player',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text(
          'Remove ${member.name} from the team?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    debugPrint('[MemberCard] removing profileId=${member.profileId} userId=${member.userId} using id=$_removeId');
    final ok = await ref
        .read(teamsControllerProvider.notifier)
        .removePlayerFromTeam(teamId: teamId!, profileId: _removeId);
    if (!ok && context.mounted) {
      final err =
          ref.read(teamsControllerProvider).error ?? 'Could not remove player';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: member.profileId.isNotEmpty
          ? () => context.push('/player/${member.profileId}')
          : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white10,
                border: Border.all(color: _kBorder),
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
                        style: const TextStyle(
                            color: Colors.white70,
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
                        style: const TextStyle(
                            color: Colors.white,
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
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isOwnTeam && _canRemove)
                  GestureDetector(
                    onTap: () => _confirmRemove(context, ref),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person_remove_outlined,
                          color: Colors.redAccent, size: 16),
                    ),
                  ),
                if (member.swingIndex != null) ...[
                  if (isOwnTeam && _canRemove) const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
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
                    style: const TextStyle(
                        color: Colors.white24, fontSize: 10),
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
      'Captain' => const Color(0xFFFFB300),
      'Vice Captain' => const Color(0xFF5B8FD4),
      'Wicketkeeper' => const Color(0xFF9B7FD4),
      _ => Colors.white38,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role == 'Vice Captain' ? 'VC' : role[0],
        style: TextStyle(
            color: color, fontSize: 9, fontWeight: FontWeight.w800),
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
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder),
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader(
      {required this.icon,
      required this.title,
      required this.iconColor});
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
            style: const TextStyle(
                color: Colors.white,
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
              style: const TextStyle(
                  color: Colors.white38,
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
      {required this.value, required this.label, this.color = Colors.white});
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
                  color: color, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
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
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 13))),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
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
                style: const TextStyle(color: Colors.white38, fontSize: 11),
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                    color: Colors.white,
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
            backgroundColor: Colors.white10,
            backgroundImage: player.avatarUrl != null
                ? CachedNetworkImageProvider(player.avatarUrl!)
                : null,
            child: player.avatarUrl == null
                ? const Icon(Icons.person, color: Colors.white38, size: 15)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(player.secondary,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Text(player.value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900)),
          const SizedBox(width: 4),
          Text(player.label,
              style: const TextStyle(
                  color: Colors.white38, fontSize: 10)),
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
      'W' => const Color(0xFF4CAF50),
      'L' => const Color(0xFFEF5350),
      'T' || 'D' => const Color(0xFFFFB300),
      _ => Colors.white24,
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
                  style: const TextStyle(
                      color: Colors.white,
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
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white38),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EmptyMsg extends StatelessWidget {
  const _EmptyMsg(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Text(message,
            textAlign: TextAlign.center,
            style:
                const TextStyle(color: Colors.white38, fontSize: 14)),
      ),
    );
  }
}

// ── Team follow button ────────────────────────────────────────────────────────

class _TeamFollowButton extends StatefulWidget {
  const _TeamFollowButton({required this.teamId});
  final String teamId;

  @override
  State<_TeamFollowButton> createState() => _TeamFollowButtonState();
}

class _TeamFollowButtonState extends State<_TeamFollowButton> {
  bool _isFollowing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    try {
      final res = await ApiClient.instance.dio
          .get(ApiEndpoints.teamFollowStatus(widget.teamId));
      final following = _extractFollowing(res.data);
      if (mounted) setState(() { _isFollowing = following; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _extractFollowing(dynamic payload) {
    final maps = <Map<dynamic, dynamic>>[];
    if (payload is Map) {
      maps.add(payload);
      if (payload['data'] is Map) maps.add(payload['data'] as Map);
    }
    for (final map in maps) {
      final raw = map['following'] ?? map['isFollowing'];
      if (raw is bool) return raw;
    }
    return false;
  }

  Future<void> _toggle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final dio = ApiClient.instance.dio;
      if (_isFollowing) {
        await dio.delete(ApiEndpoints.teamFollow(widget.teamId));
        if (mounted) setState(() => _isFollowing = false);
      } else {
        await dio.post(ApiEndpoints.teamFollow(widget.teamId));
        if (mounted) setState(() => _isFollowing = true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update follow status')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _isFollowing ? Colors.transparent : context.accent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isFollowing
                ? context.accent.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _isFollowing ? context.accent : Colors.black))
            : Text(
                _isFollowing ? 'Following' : 'Follow',
                style: TextStyle(
                    color: _isFollowing ? context.accent : Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),      ),
    );
  }
}

// ── Edit team sheet ───────────────────────────────────────────────────────────

class _EditTeamSheet extends ConsumerStatefulWidget {
  const _EditTeamSheet({required this.team});
  final PlayerTeam team;

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

  // Logo state
  XFile? _logoFile;
  bool _uploadingLogo = false;

  static const _teamTypes = [
    'CLUB', 'CORPORATE', 'SCHOOL', 'COLLEGE',
    'DISTRICT', 'PROFESSIONAL', 'AMATEUR', 'RECREATIONAL',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.team.name);
    _shortNameCtrl = TextEditingController(text: widget.team.shortName ?? '');
    _cityCtrl = TextEditingController(text: widget.team.city ?? '');
    final raw = widget.team.teamType?.toUpperCase().replaceAll(' ', '_');
    _selectedType = raw != null && _teamTypes.contains(raw) ? raw : null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _shortNameCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 85);
    if (file != null) setState(() => _logoFile = file);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Team name is required');
      return;
    }
    setState(() { _saving = true; _error = null; });

    // Upload logo first if one was picked
    String? uploadedLogoUrl;
    if (_logoFile != null) {
      setState(() => _uploadingLogo = true);
      try {
        uploadedLogoUrl = await SupabaseStorageService()
            .uploadTeamLogoForTeam(widget.team.id, _logoFile!);
      } catch (e) {
        if (mounted) {
          setState(() {
            _uploadingLogo = false;
            _saving = false;
            _error = 'Logo upload failed: ${e.toString()}';
          });
        }
        return;
      }
      if (mounted) setState(() => _uploadingLogo = false);
    }

    final ok = await ref.read(teamsControllerProvider.notifier).updateTeam(
          teamId: widget.team.id,
          name: name,
          shortName: _shortNameCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          teamType: _selectedType,
          logoUrl: uploadedLogoUrl,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Team updated')));
    } else {
      setState(() => _error =
          ref.read(teamsControllerProvider).error ?? 'Could not update team');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Current logo: show newly picked file preview or existing URL
    final hasExistingLogo = widget.team.logoUrl != null &&
        widget.team.logoUrl!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
          top: 80, bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: context.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                    width: 44, height: 5,
                    decoration: BoxDecoration(
                        color: context.stroke,
                        borderRadius: BorderRadius.circular(999)),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Edit Team',
                    style: TextStyle(color: context.fg, fontSize: 20,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 20),

                // ── Logo picker ───────────────────────────────────────────
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
                            color: _kCard,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _logoFile != null
                                  ? context.accent
                                  : _kBorder,
                              width: 2,
                            ),
                            image: _logoFile != null
                                ? DecorationImage(
                                    image: FileImage(
                                        File(_logoFile!.path)),
                                    fit: BoxFit.cover)
                                : hasExistingLogo
                                    ? DecorationImage(
                                        image: NetworkImage(
                                            widget.team.logoUrl!),
                                        fit: BoxFit.cover)
                                    : null,
                          ),
                          child: (_logoFile == null && !hasExistingLogo)
                              ? Icon(Icons.shield_rounded,
                                  color: Colors.white24, size: 36)
                              : null,
                        ),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: context.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: context.bg, width: 2),
                          ),
                          child: _uploadingLogo
                              ? const Padding(
                                  padding: EdgeInsets.all(5),
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.camera_alt_rounded,
                                  color: Colors.white, size: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_logoFile != null) ...[
                  const SizedBox(height: 6),
                  const Center(
                    child: Text('New logo selected',
                        style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ),
                ],
                const SizedBox(height: 20),

                _FieldLabel('Team Name'),
                SwingTextField(controller: _nameCtrl, hint: 'e.g. Mumbai Warriors',
                    prefixIcon: Icons.shield_rounded),
                const SizedBox(height: 14),
                _FieldLabel('Short Name'),
                SwingTextField(controller: _shortNameCtrl, hint: 'e.g. MW',
                    prefixIcon: Icons.short_text_rounded),
                const SizedBox(height: 14),
                _FieldLabel('City'),
                SwingTextField(controller: _cityCtrl, hint: 'e.g. Mumbai',
                    prefixIcon: Icons.location_on_outlined),
                const SizedBox(height: 14),
                _FieldLabel('Team Type'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.stroke),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedType,
                      isExpanded: true,
                      dropdownColor: context.cardBg,
                      hint: Text('Select type',
                          style: TextStyle(color: context.fgSub, fontSize: 14)),
                      items: [
                        DropdownMenuItem<String?>(
                            value: null,
                            child: Text('None',
                                style: TextStyle(color: context.fgSub))),
                        ..._teamTypes.map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t[0] + t.substring(1).toLowerCase(),
                                  style: TextStyle(color: context.fg)),
                            )),
                      ],
                      onChanged: (v) => setState(() => _selectedType = v),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: TextStyle(color: context.danger, fontSize: 12)),
                ],
                const SizedBox(height: 24),
                // ── Save button ───────────────────────────────────────────
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
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Save Changes',
                              style: TextStyle(color: Colors.white,
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),

                // ── Delete team ───────────────────────────────────────────
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _saving ? null : _confirmDeleteTeam,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            color: Colors.redAccent, size: 18),
                        SizedBox(width: 8),
                        Text('Delete Team',
                            style: TextStyle(
                                color: Colors.redAccent,
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
        backgroundColor: _kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Team',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text(
          'Permanently delete "${widget.team.name}"? This cannot be undone.',
          style: const TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _saving = true);
    final ok = await ref
        .read(teamsControllerProvider.notifier)
        .deleteTeam(widget.team.id);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      // Close the sheet and pop the team detail screen
      Navigator.of(context).pop();
      if (context.mounted) context.pop();
    } else {
      setState(() => _error =
          ref.read(teamsControllerProvider).error ?? 'Could not delete team');
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

// ── Add player sheet ──────────────────────────────────────────────────────────

class _AddPlayerSheet extends ConsumerStatefulWidget {
  const _AddPlayerSheet({required this.team});
  final PlayerTeam team;

  @override
  ConsumerState<_AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends ConsumerState<_AddPlayerSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _searchCtrl = TextEditingController();
  List<TeamPlayerSearchResult> _results = const [];
  bool _searching = false;
  bool _addingSearch = false;
  String? _searchError;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _quickAdding = false;
  String? _quickError;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _searchCtrl.text.trim();
    if (q.length < 2) {
      setState(() { _results = const []; _searchError = 'Enter at least 2 characters'; });
      return;
    }
    setState(() { _searching = true; _searchError = null; });
    final res = await ref.read(teamsControllerProvider.notifier).searchPlayers(q);
    if (!mounted) return;
    setState(() {
      _searching = false;
      _results = res.where((p) =>
          !widget.team.members.any((m) => m.userId == p.userId)).toList();
      if (_results.isEmpty) _searchError = 'No matching users found';
    });
  }

  Future<void> _addSearch(TeamPlayerSearchResult player) async {
    setState(() { _addingSearch = true; _searchError = null; });
    final ok = await ref.read(teamsControllerProvider.notifier).addPlayerToTeam(
        teamId: widget.team.id, playerIdOrUserId: player.userId);
    if (!mounted) return;
    setState(() => _addingSearch = false);
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${player.name} added')));
    } else {
      setState(() => _searchError =
          ref.read(teamsControllerProvider).error ?? 'Could not add player');
    }
  }

  Future<void> _quickAdd() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty) { setState(() => _quickError = 'Enter player name'); return; }
    if (phone.isEmpty) { setState(() => _quickError = 'Enter phone number'); return; }
    setState(() { _quickAdding = true; _quickError = null; });
    final ok = await ref.read(teamsControllerProvider.notifier).quickAddPlayer(
          teamId: widget.team.id, name: name, phone: phone);
    if (!mounted) return;
    setState(() => _quickAdding = false);
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$name added to squad')));
    } else {
      setState(() => _quickError =
          ref.read(teamsControllerProvider).error ?? 'Could not add player');
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                    width: 44, height: 5,
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
                        style: TextStyle(color: context.fg, fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: context.cardBg,
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
                        tabs: const [Tab(text: 'Search'), Tab(text: 'Quick Add')],
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
                    // Search
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SwingTextField(
                                    controller: _searchCtrl,
                                    hint: 'Search by name or phone',
                                    prefixIcon: Icons.search_rounded),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: _searching || _addingSearch ? null : _search,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      color: context.accent,
                                      borderRadius: BorderRadius.circular(14)),
                                  child: _searching
                                      ? const SizedBox(width: 18, height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2, color: Colors.white))
                                      : const Icon(Icons.arrow_forward_rounded,
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
                            child: _results.isEmpty
                                ? Center(
                                    child: Text('Results appear here.',
                                        style: TextStyle(
                                            color: context.fgSub,
                                            fontSize: 13)))
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
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Add without an account.',
                              style: TextStyle(
                                  color: context.fgSub,
                                  fontSize: 12,
                                  height: 1.4)),
                          const SizedBox(height: 14),
                          SwingTextField(controller: _nameCtrl,
                              hint: 'Player name',
                              prefixIcon: Icons.person_outline_rounded),
                          const SizedBox(height: 10),
                          SwingTextField(controller: _phoneCtrl,
                              hint: 'Phone number',
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone),
                          if (_quickError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(_quickError!,
                                  style: TextStyle(
                                      color: context.danger, fontSize: 12)),
                            ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _quickAdding ? null : _quickAdd,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                  color: context.accent,
                                  borderRadius: BorderRadius.circular(14)),
                              child: Center(
                                child: _quickAdding
                                    ? const SizedBox(width: 20, height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2, color: Colors.white))
                                    : const Text('Add to Squad',
                                        style: TextStyle(color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700)),
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
      {required this.player, required this.submitting, required this.onAdd});
  final TeamPlayerSearchResult player;
  final bool submitting;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.cardBg,
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
                ? Text(player.name.isEmpty ? '?' : player.name[0].toUpperCase(),
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
                    [if (_hasText(player.phone)) player.phone,
                      if (_hasText(player.playerRole)) player.playerRole]
                        .whereType<String>().join(' • '),
                    style: TextStyle(color: context.fgSub, fontSize: 11),
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
                      width: 16, height: 16,
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

// ── QR sheet ──────────────────────────────────────────────────────────────────

// ── Join-team sheet (opened via WhatsApp deep link) ───────────────────────────

class _JoinTeamSheet extends ConsumerStatefulWidget {
  const _JoinTeamSheet({required this.team});
  final PlayerTeam team;

  @override
  ConsumerState<_JoinTeamSheet> createState() => _JoinTeamSheetState();
}

class _JoinTeamSheetState extends ConsumerState<_JoinTeamSheet> {
  bool _joining = false;

  Future<void> _join() async {
    setState(() => _joining = true);
    final ok = await ref.read(teamsControllerProvider.notifier).joinTeam(widget.team.id);
    if (!mounted) return;
    setState(() => _joining = false);
    Navigator.pop(context);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You joined ${widget.team.name}!')),
      );
    } else {
      final error = ref.read(teamsControllerProvider).error;
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44, height: 5,
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
              child: Icon(Icons.groups_rounded, color: context.accent, size: 36),
            ),
            const SizedBox(height: 16),
            Text("You're invited!",
                style: TextStyle(color: context.fg, fontSize: 20, fontWeight: FontWeight.w900)),
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
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Join Team',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
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
  const _TeamQrSheet({
    required this.team,
    this.played = 0,
    this.wins = 0,
    this.losses = 0,
  });
  final PlayerTeam team;
  final int played;
  final int wins;
  final int losses;

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
    final team = widget.team;
    final joinUrl = _teamJoinUrl(team);
    final payload = jsonEncode({
      'type': 'SWING_TEAM_INVITE',
      'teamId': team.id,
      'teamName': team.name,
      'joinUrl': joinUrl,
    });
    final initials = _initials(team);
    final memberCount = team.members.length;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: context.stroke,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              decoration: BoxDecoration(
                color: context.accentBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: context.accent,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: team.logoUrl != null
                        ? Image.network(team.logoUrl!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _initialsWidget(initials))
                        : _initialsWidget(initials),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    team.name,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$memberCount ${memberCount == 1 ? 'player' : 'players'}',
                    style: TextStyle(color: context.fgSub, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Performance strip
            if (widget.played > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: context.panel,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _QrStat(value: '${widget.played}', label: 'Played', color: context.fg),
                      _QrStatDivider(),
                      _QrStat(value: '${widget.wins}', label: 'Won', color: context.success),
                      _QrStatDivider(),
                      _QrStat(value: '${widget.losses}', label: 'Lost', color: context.danger),
                      _QrStatDivider(),
                      _QrStat(
                        value: '${((widget.wins / widget.played) * 100).round()}%',
                        label: 'Win Rate',
                        color: context.accent,
                      ),
                    ],
                  ),
                ),
              ),

            // QR code
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: QrImageView(
                    data: payload,
                    version: QrVersions.auto,
                    size: 190,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _copyLink(joinUrl),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _copied
                              ? context.success.withValues(alpha: 0.1)
                              : context.panel,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _copied ? context.success : context.stroke,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _copied ? Icons.check_rounded : Icons.copy_rounded,
                              size: 16,
                              color: _copied ? context.success : context.fg,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _copied ? 'Copied!' : 'Copy Link',
                              style: TextStyle(
                                color: _copied ? context.success : context.fg,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _shareViaWhatsApp(team);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'WhatsApp',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
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
          ],
        ),
        ),
      ),
    );
  }

  Widget _initialsWidget(String initials) => Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
}

class _QrStat extends StatelessWidget {
  const _QrStat({required this.value, required this.label, required this.color});
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
                  color: color, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  color: context.fgSub, fontSize: 10,
                  fontWeight: FontWeight.w600, letterSpacing: 0.2)),
        ],
      ),
    );
  }
}

class _QrStatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: context.stroke);
  }
}

// ── TeamPerformanceSummary ────────────────────────────────────────────────────

class TeamPerformanceSummary {
  const TeamPerformanceSummary({
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.topBatter,
    required this.topBowler,
    required this.matches,
    required this.tournaments,
  });

  final int totalMatches;
  final int wins;
  final int losses;
  final int draws;
  final TeamMember? topBatter;
  final TeamMember? topBowler;
  final List<PlayerMatch> matches;
  final List<String> tournaments;

  factory TeamPerformanceSummary.from({
    required PlayerTeam team,
    required List<PlayerMatch> matches,
    bool skipTeamFilter = false,
  }) {
    final relevant = <PlayerMatch>[];
    final seen = <String>{};
    for (final m in matches) {
      if (!skipTeamFilter && !_sameTeam(team, m.playerTeamName)) continue;
      if (seen.add(m.id)) relevant.add(m);
    }
    relevant.sort((a, b) {
      final r = _lRank(a.lifecycle).compareTo(_lRank(b.lifecycle));
      if (r != 0) return r;
      final at = a.scheduledAt;
      final bt = b.scheduledAt;
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return a.lifecycle == MatchLifecycle.past
          ? bt.compareTo(at)
          : at.compareTo(bt);
    });

    final tournaments = relevant
        .where((m) => m.sectionType == MatchSectionType.tournament)
        .map((m) => m.competitionLabel?.trim() ?? '')
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    TeamMember? topBatter;
    for (final m in team.membersByRuns) {
      if ((m.totalRuns ?? 0) > 0) { topBatter = m; break; }
    }
    TeamMember? topBowler;
    for (final m in team.membersByWickets) {
      if ((m.totalWickets ?? 0) > 0) { topBowler = m; break; }
    }

    return TeamPerformanceSummary(
      totalMatches: relevant.length,
      wins: relevant.where((m) => m.result == MatchResult.win).length,
      losses: relevant.where((m) => m.result == MatchResult.loss).length,
      draws: relevant.where((m) => m.result == MatchResult.draw).length,
      topBatter: topBatter,
      topBowler: topBowler,
      matches: relevant,
      tournaments: tournaments,
    );
  }

  static bool _sameTeam(PlayerTeam team, String name) {
    final n = _norm(name);
    if (n.isEmpty) return false;
    return {
      _norm(team.name),
      if (_hasText(team.shortName)) _norm(team.shortName!)
    }.contains(n);
  }

  static String _norm(String v) =>
      v.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ');

  static int _lRank(MatchLifecycle l) => switch (l) {
        MatchLifecycle.live => 0,
        MatchLifecycle.upcoming => 1,
        MatchLifecycle.past => 2
      };
}

// ── Helpers ───────────────────────────────────────────────────────────────────

void _showTeamQrSheet(
  BuildContext context,
  PlayerTeam team, {
  int played = 0,
  int wins = 0,
  int losses = 0,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.88,
    ),
    builder: (_) => _TeamQrSheet(
      team: team,
      played: played,
      wins: wins,
      losses: losses,
    ),
  );
}

PlayerTeam? _findTeamById(List<PlayerTeam> teams, String id) {
  for (final t in teams) { if (t.id == id) return t; }
  return null;
}

TeamMember? _memberForRole(PlayerTeam team, String role) {
  for (final m in team.members) { if (m.roles.contains(role)) return m; }
  return null;
}

bool _hasText(String? v) => v != null && v.trim().isNotEmpty;

String _initials(PlayerTeam team) {
  final src = _hasText(team.shortName) ? team.shortName! : team.name;
  return src.length >= 2 ? src.substring(0, 2).toUpperCase() : src.toUpperCase();
}

String _teamJoinUrl(PlayerTeam team) =>
    'https://Swingcricketapp.com/team/${team.id}/join';

String _inviteText(PlayerTeam team) =>
    'You\'re invited to join *${team.name}* on Swing Cricket! '
    'Tap to join: ${_teamJoinUrl(team)}';

Future<void> _shareViaWhatsApp(PlayerTeam team) async {
  final text = Uri.encodeComponent(_inviteText(team));
  final uri = Uri.parse('https://wa.me/?text=$text');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    // Fallback to generic share if WhatsApp not installed
    Share.share(_inviteText(team));
  }
}
