import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/profile_controller.dart';
import '../data/stats_extended_provider.dart';
import '../domain/profile_models.dart';
import '../domain/rank_frame_resolver.dart';
import '../domain/rank_visual_theme.dart';
import '../../chat/data/chat_repository.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../matches/controller/matches_controller.dart';
import '../../matches/data/matches_repository.dart';
import '../../matches/domain/match_models.dart';
import 'edit_profile_screen.dart';
import 'rank_system_screen.dart';
import 'profile_stats_screen.dart';
import 'profile_qr_sheet.dart';
import 'widgets/badges_tab.dart';

final publicPlayerMatchesProvider = FutureProvider.autoDispose
    .family<List<PlayerMatch>, String>((ref, playerId) async {
  return MatchesRepository().loadPublicPlayerMatches(playerId);
});

final profileSocialCountsProvider = FutureProvider.autoDispose
    .family<({int followers, int following}), String>((ref, profileId) async {
  ref.watch(followGraphRefreshTickProvider);
  final dio = ApiClient.instance.dio;

  Future<int> loadCount(String endpoint, {required String mode}) async {
    try {
      final response = await dio.get(
        endpoint,
        queryParameters: {'playerId': profileId},
      );
      return _extractFollowCount(response.data, mode: mode);
    } catch (_) {
      return -1;
    }
  }

  final followers =
      await loadCount(ApiEndpoints.playerFollowers, mode: 'followers');
  final following =
      await loadCount(ApiEndpoints.playerFollowing, mode: 'following');

  return (followers: followers, following: following);
});

int _extractFollowCount(dynamic body, {required String mode}) {
  if (body is List) return body.length;
  if (body is! Map<String, dynamic>) return 0;

  int parseNumeric(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  int extractNumeric(Map<String, dynamic> map) {
    final keys = mode == 'followers'
        ? ['followersCount', 'followers', 'count', 'total', 'totalCount']
        : ['followingCount', 'following', 'count', 'total', 'totalCount'];

    for (final key in keys) {
      final value = map[key];
      if (value is num || value is String) return parseNumeric(value);
    }

    final meta = map['meta'];
    if (meta is Map<String, dynamic>) {
      for (final key in ['count', 'total', 'totalCount']) {
        final value = meta[key];
        if (value is num || value is String) return parseNumeric(value);
      }
    }

    final pagination = map['pagination'];
    if (pagination is Map<String, dynamic>) {
      for (final key in ['count', 'total', 'totalCount']) {
        final value = pagination[key];
        if (value is num || value is String) return parseNumeric(value);
      }
    }

    return -1;
  }

  int extractListLen(Map<String, dynamic> map) {
    final dataNode = map['data'];
    if (dataNode is List) return dataNode.length;
    if (dataNode is Map<String, dynamic>) {
      final inner = dataNode['data'] ??
          dataNode[mode] ??
          dataNode['players'] ??
          dataNode['items'] ??
          dataNode['results'];
      if (inner is List) return inner.length;
    }

    final root = map[mode] ?? map['players'] ?? map['items'] ?? map['results'];
    if (root is List) return root.length;
    return 0;
  }

  final explicit = extractNumeric(body);
  final fromList = extractListLen(body);
  if (explicit < 0) return fromList;
  return explicit > fromList ? explicit : fromList;
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, this.profileId});

  final String? profileId;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Silently re-fetch every time the profile screen is opened.
    // Keeps existing data visible — no loading flash.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.profileId == null) {
        ref.read(profileControllerProvider.notifier).silentRefresh();
      } else {
        ref
            .read(playerProfileProvider(widget.profileId!).notifier)
            .silentRefresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOwnProfile = widget.profileId == null;
    final state = isOwnProfile
        ? ref.watch(profileControllerProvider)
        : ref.watch(playerProfileProvider(widget.profileId!));

    if (state.isLoading && state.data == null) {
      return Scaffold(
        backgroundColor: context.bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final data = state.data;
    if (data == null) {
      return Scaffold(
        backgroundColor: context.bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    color: context.fgSub, size: 34),
                const SizedBox(height: 10),
                Text(
                  state.error?.trim().isNotEmpty == true
                      ? state.error!.trim()
                      : 'Could not open profile.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.fgSub, fontSize: 13.5),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () {
                    if (widget.profileId == null) {
                      ref.read(profileControllerProvider.notifier).load();
                    } else {
                      ref
                          .read(
                              playerProfileProvider(widget.profileId!).notifier)
                          .load();
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final rankTheme = resolveRankVisualTheme(data.unified.ranking.rank);
    final profileId = widget.profileId ?? data.identity.id;
    final tabs = <Tab>[
      const Tab(text: 'OVERVIEW'),
      const Tab(text: 'STATS'),
      const Tab(text: 'BADGES'),
      const Tab(text: 'MATCHES'),
    ];
    final tabViews = <Widget>[
      _OverviewTab(data: data, rankTheme: rankTheme),
      _StatsTab(data: data, rankTheme: rankTheme),
      _BadgesTab(data: data, rankTheme: rankTheme),
      _MatchesTab(profileId: profileId, isOwnProfile: isOwnProfile),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: context.bg,
        body: RefreshIndicator(
          onRefresh: () async {
            String? refreshProfileId = widget.profileId;
            if (refreshProfileId == null || refreshProfileId.trim().isEmpty) {
              refreshProfileId =
                  ref.read(profileControllerProvider).data?.identity.id;
            }

            if (widget.profileId == null) {
              await ref.read(profileControllerProvider.notifier).refresh();
            } else {
              await ref
                  .read(playerProfileProvider(widget.profileId!).notifier)
                  .refresh();
            }

            if (refreshProfileId == null || refreshProfileId.trim().isEmpty) {
              refreshProfileId =
                  ref.read(profileControllerProvider).data?.identity.id;
            }
            if (refreshProfileId != null &&
                refreshProfileId.trim().isNotEmpty) {
              ref.invalidate(statsExtendedProvider(refreshProfileId.trim()));
            }
          },
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _EliteSliverAppBar(
                  data: data,
                  isOwnProfile: isOwnProfile,
                  rankTheme: rankTheme,
                  ref: ref,
                  profileId: widget.profileId,
                ),
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        isScrollable: true,
                        labelColor: rankTheme.primary,
                        unselectedLabelColor: Colors.white54,
                        indicatorColor: rankTheme.primary,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1),
                        tabs: tabs,
                      ),
                      rankTheme.deep,
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(children: tabViews),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this.bgColor);

  final TabBar _tabBar;
  final Color bgColor;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: bgColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.data, required this.rankTheme});
  final PlayerProfilePageData data;
  final RankVisualTheme rankTheme;

  @override
  Widget build(BuildContext context) {
    final identity = data.unified.identity;
    return Builder(
      builder: (context) => CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionHeader(title: 'BIO', rankTheme: rankTheme),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    identity.bio.isEmpty ? 'No bio added yet.' : identity.bio,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        height: 1.5),
                  ),
                ),
                const SizedBox(height: 12),
                _SectionHeader(title: 'PERSONAL DETAILS', rankTheme: rankTheme),
                _InfoTile(label: 'Full Name', value: identity.name),
                _InfoTile(label: 'Date of Birth', value: 'Feb 11, 2010'),
                _InfoTile(label: 'City', value: identity.city),
                _InfoTile(label: 'State', value: identity.state),
                const SizedBox(height: 24),
                _SectionHeader(title: 'CRICKET PROFILE', rankTheme: rankTheme),
                _InfoTile(label: 'Primary Role', value: identity.playerRole),
                _InfoTile(label: 'Batting Style', value: identity.battingStyle),
                _InfoTile(label: 'Bowling Style', value: identity.bowlingStyle),
                _InfoTile(label: 'Player Level', value: identity.level),
                const SizedBox(height: 12),
                _SectionHeader(title: 'SKILL MATRIX', rankTheme: rankTheme),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SkillPill(
                        label: 'Batting',
                        value: data.skillMatrix.batting,
                        rankTheme: rankTheme,
                      ),
                      _SkillPill(
                        label: 'Bowling',
                        value: data.skillMatrix.bowling,
                        rankTheme: rankTheme,
                      ),
                      _SkillPill(
                        label: 'Fielding',
                        value: data.skillMatrix.fielding,
                        rankTheme: rankTheme,
                      ),
                      _SkillPill(
                        label: 'Clutch',
                        value: data.skillMatrix.clutch,
                        rankTheme: rankTheme,
                      ),
                      _SkillPill(
                        label: 'Consistency',
                        value: data.skillMatrix.consistency,
                        rankTheme: rankTheme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 13)),
          Text(value.isEmpty ? '-' : value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SkillPill extends StatelessWidget {
  const _SkillPill({
    required this.label,
    required this.value,
    required this.rankTheme,
  });

  final String label;
  final double value;
  final RankVisualTheme rankTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: rankTheme.deep.withOpacity(0.36),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: rankTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.68),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toStringAsFixed(1),
            style: TextStyle(
              color: rankTheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  const _StatsTab({required this.data, required this.rankTheme});
  final PlayerProfilePageData data;
  final RankVisualTheme rankTheme;

  @override
  Widget build(BuildContext context) {
    // Stats has its own inner tab controller — wrap in SafeArea padding only,
    // no CustomScrollView needed (Column+Expanded fills the viewport height).
    return Builder(
      builder: (context) {
        final handle = NestedScrollView.sliverOverlapAbsorberHandleFor(context);
        return Padding(
          padding: EdgeInsets.only(top: handle.layoutExtent ?? 0),
          child: ProfileStatsContent(
            data: data,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          ),
        );
      },
    );
  }
}

class _BadgesTab extends StatelessWidget {
  const _BadgesTab({required this.data, required this.rankTheme});
  final PlayerProfilePageData data;
  final RankVisualTheme rankTheme;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => BadgesTab(
        badges: data.unified.badges,
        rankTheme: rankTheme,
        overlapHandle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      ),
    );
  }
}

class _MatchesTab extends ConsumerWidget {
  const _MatchesTab({
    required this.profileId,
    this.isOwnProfile = false,
  });
  final String profileId;
  final bool isOwnProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handle = NestedScrollView.sliverOverlapAbsorberHandleFor(context);
    final topPad = handle.layoutExtent ?? 0;

    if (isOwnProfile) {
      // Own profile: use the private /player/matches endpoint
      final state = ref.watch(matchesControllerProvider);
      if (state.isLoading && state.matches.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(top: topPad),
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      if (state.error != null && state.matches.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(top: topPad + 32),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    color: context.fgSub, size: 32),
                const SizedBox(height: 10),
                Text(
                  state.error!,
                  style: TextStyle(color: context.fgSub, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      ref.read(matchesControllerProvider.notifier).load(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }
      return _buildMatchList(
        context,
        handle: handle,
        topPad: topPad,
        matches: state.matches,
      );
    }

    // Other player's profile: use the public /player/profile/$id/matches endpoint
    final matchesAsync = ref.watch(publicPlayerMatchesProvider(profileId));
    return matchesAsync.when(
      loading: () => Padding(
        padding: EdgeInsets.only(top: topPad),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) {
        final isNotFound = e is PlayerNotFoundException;
        return Padding(
          padding: EdgeInsets.only(top: topPad + 32),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isNotFound
                      ? Icons.person_off_outlined
                      : Icons.error_outline_rounded,
                  color: context.fgSub,
                  size: 32,
                ),
                const SizedBox(height: 10),
                Text(
                  isNotFound ? 'Player not found.' : 'Could not load matches.',
                  style: TextStyle(color: context.fgSub, fontSize: 13),
                ),
                if (!isNotFound) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        ref.invalidate(publicPlayerMatchesProvider(profileId)),
                    child: const Text('Retry'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      data: (matches) => _buildMatchList(
        context,
        handle: handle,
        topPad: topPad,
        matches: matches,
      ),
    );
  }

  Widget _buildMatchList(
    BuildContext context, {
    required SliverOverlapAbsorberHandle handle,
    required double topPad,
    required List<PlayerMatch> matches,
  }) {
    if (matches.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: topPad + 48),
        child: Center(
          child: Text('No matches yet.',
              style: TextStyle(color: context.fgSub, fontSize: 14)),
        ),
      );
    }
    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(handle: handle),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _MatchCard(match: matches[i]),
              childCount: matches.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});
  final PlayerMatch match;

  static const _win = Color(0xFF4CAF50);
  static const _loss = Color(0xFFEF5350);
  static const _draw = Color(0xFFFFB300);
  static const _unknown = Color(0xFF78909C);

  Color get _resultColor => switch (match.result) {
        MatchResult.win => _win,
        MatchResult.loss => _loss,
        MatchResult.draw => _draw,
        MatchResult.unknown => _unknown,
      };

  String get _resultLabel => switch (match.result) {
        MatchResult.win => 'W',
        MatchResult.loss => 'L',
        MatchResult.draw => 'D',
        MatchResult.unknown => '–',
      };

  String get _resultWord => switch (match.result) {
        MatchResult.win => 'Won',
        MatchResult.loss => 'Lost',
        MatchResult.draw => 'Draw',
        MatchResult.unknown => match.statusLabel,
      };

  @override
  Widget build(BuildContext context) {
    final accent = _resultColor;
    final detailPath =
        match.id.isEmpty ? null : '/match/${Uri.encodeComponent(match.id)}';
    final teamA = match.playerTeamShortName ?? match.playerTeamName;
    final teamB = match.opponentTeamShortName ?? match.opponentTeamName;
    final dateStr = match.scheduledAt == null
        ? null
        : _formatDate(match.scheduledAt!);
    final isLive = match.lifecycle == MatchLifecycle.live;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: detailPath == null
              ? null
              : () => context.push(detailPath, extra: match),
          child: Ink(
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isLive
                    ? accent.withValues(alpha: 0.5)
                    : context.stroke,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: result + teams + date ──────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Result badge
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _resultLabel,
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Teams
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$teamA vs $teamB',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.fg,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  _resultWord,
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (match.competitionLabel != null) ...[
                                  Text(
                                    '  ·  ',
                                    style: TextStyle(
                                        color: context.fgSub, fontSize: 11.5),
                                  ),
                                  Expanded(
                                    child: Text(
                                      match.competitionLabel!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: context.fgSub,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Date + chevron
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (dateStr != null)
                            Text(
                              dateStr,
                              style: TextStyle(
                                color: context.fgSub,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          if (match.formatLabel != null)
                            Text(
                              match.formatLabel!,
                              style: TextStyle(
                                color: context.fgSub,
                                fontSize: 10.5,
                              ),
                            ),
                        ],
                      ),
                      if (detailPath != null) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded,
                            color: context.fgSub, size: 18),
                      ],
                    ],
                  ),
                ),

                // ── Score summary ────────────────────────────────────
                if (match.scoreSummary != null) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      match.scoreSummary!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                // ── Personal stats + venue ────────────────────────────
                if (_hasPersonalStats || match.venueLabel != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: context.panel,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        if (match.playerRuns != null) ...[
                          _InlineStat(
                            icon: Icons.sports_cricket_rounded,
                            label:
                                '${match.playerRuns}${match.playerBalls != null ? ' (${match.playerBalls})' : ''}',
                            color: const Color(0xFF4FC3F7),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (match.playerWickets != null &&
                            match.playerWickets! > 0) ...[
                          _InlineStat(
                            icon: Icons.remove_circle_outline_rounded,
                            label: '${match.playerWickets}W',
                            color: const Color(0xFFCE93D8),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (match.playerCatches != null &&
                            match.playerCatches! > 0) ...[
                          _InlineStat(
                            icon: Icons.back_hand_outlined,
                            label: '${match.playerCatches}ct',
                            color: const Color(0xFF80CBC4),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (match.venueLabel != null)
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.location_on_rounded,
                                    size: 11,
                                    color: context.fgSub
                                        .withValues(alpha: 0.6)),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    match.venueLabel!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: context.fgSub,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ] else
                  const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _hasPersonalStats =>
      match.playerRuns != null ||
      (match.playerWickets != null && match.playerWickets! > 0) ||
      (match.playerCatches != null && match.playerCatches! > 0);
}

class _InlineStat extends StatelessWidget {
  const _InlineStat({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 11),
        ),
      ],
    );
  }
}

String _formatDate(DateTime dt) {
  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${dt.day} ${months[dt.month - 1]}';
}

class _EliteSliverAppBar extends StatelessWidget {
  const _EliteSliverAppBar({
    required this.data,
    required this.isOwnProfile,
    required this.rankTheme,
    required this.ref,
    this.profileId,
  });

  final PlayerProfilePageData data;
  final bool isOwnProfile;
  final RankVisualTheme rankTheme;
  final WidgetRef ref;
  final String? profileId;

  @override
  Widget build(BuildContext context) {
    final ranking = data.unified.ranking;
    final identity = data.unified.identity;
    final socialCountsAsync =
        ref.watch(profileSocialCountsProvider(data.identity.id));
    final socialCounts = socialCountsAsync.asData?.value;
    final resolvedFans = (socialCounts != null && socialCounts.followers >= 0)
        ? socialCounts.followers
        : identity.fans;
    final resolvedFollowing =
        (socialCounts != null && socialCounts.following >= 0)
            ? socialCounts.following
            : identity.following;

    final rankTier = resolveRankTierFlexible(
      rank: ranking.rank,
      label: ranking.label,
      division: ranking.division.toString(),
    );

    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      stretch: true,
      backgroundColor: rankTheme.deep,
      leadingWidth: 40,
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 8),
          _AvatarCircle(
            url: identity.avatarUrl,
            radius: 16,
            fallbackLetter: identity.name.isNotEmpty ? identity.name[0] : '?',
            backgroundColor: rankTheme.primary.withOpacity(0.2),
            fontSize: 12,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              identity.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (identity.avatarUrl != null)
              Image.network(
                identity.avatarUrl!,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              )
            else
              Container(color: rankTheme.deep),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.85),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.95),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(color: Colors.transparent),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _AvatarWithGauge(data: data, rankTheme: rankTheme),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SocialCount(
                            label: 'FANS',
                            count: resolvedFans,
                            onTap: () => context
                                .push('/player/${data.identity.id}/followers'),
                          ),
                          const SizedBox(width: 12),
                          Container(
                              width: 1, height: 10, color: Colors.white24),
                          const SizedBox(width: 12),
                          _SocialCount(
                            label: 'FOLLOWING',
                            count: resolvedFollowing,
                            onTap: () => context
                                .push('/player/${data.identity.id}/following'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _openRankSystem(context),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: rankTheme.primary.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1.2, 1.2),
                              duration: 2.seconds,
                            ),
                        SvgPicture.asset(
                          rankTier.assetPath,
                          width: 100,
                          height: 100,
                        ).animate(onPlay: (c) => c.repeat()).shimmer(
                              duration: 3.seconds,
                              color: Colors.white.withOpacity(0.2),
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
      actions: [
        if (!isOwnProfile && profileId != null) ...[
          _MessageButton(profileId: profileId!),
          _FollowButton(data: data, profileId: profileId!, ref: ref),
        ],
        if (isOwnProfile) ...[
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white, size: 20),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(profileControllerProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded,
                color: Colors.white, size: 20),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => ProfileQrSheet(data: data, initialIndex: 1),
            ),
          ),
          IconButton(
            icon:
                const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                  builder: (_) => EditProfileScreen(data: data)),
            ),
          ),
          IconButton(
            icon:
                const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
            tooltip: 'Logout',
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      backgroundColor: rankTheme.deep,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: rankTheme.primary.withOpacity(0.18),
                        ),
                      ),
                      title: const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      content: const Text(
                        'Do you want to log out from this account?',
                        style: TextStyle(color: Colors.white70, height: 1.4),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  ) ??
                  false;
              if (!shouldLogout) return;
              await ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
        const SizedBox(width: 8),
      ],
    );
  }

  void _openRankSystem(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RankSystemScreen(
          ranking: data.unified.ranking,
        ),
      ),
    );
  }
}

// ── Message button (opens DM on public profiles) ─────────────────────────────

class _MessageButton extends StatefulWidget {
  const _MessageButton({required this.profileId});
  final String profileId;

  @override
  State<_MessageButton> createState() => _MessageButtonState();
}

class _MessageButtonState extends State<_MessageButton> {
  bool _loading = false;

  Future<void> _openDm() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final conversation = await ChatRepository().getOrCreateDirect(
        widget.profileId,
      );
      final convId = conversation.id.trim();
      if (mounted && convId.isNotEmpty) {
        context.push('/chat/$convId', extra: conversation);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open chat')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.chat_bubble_outline_rounded,
              color: Colors.white, size: 20),
      tooltip: 'Message',
      onPressed: _openDm,
    );
  }
}

// ── Follow button (public profiles only) ─────────────────────────────────────

class _FollowButton extends StatelessWidget {
  const _FollowButton({
    required this.data,
    required this.profileId,
    required this.ref,
  });

  final PlayerProfilePageData data;
  final String profileId;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final isFollowing = data.viewerContext?.following ?? false;
    final isLoading =
        ref.watch(playerProfileProvider(profileId)).isActionLoading;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Center(
        child: GestureDetector(
          onTap: isLoading
              ? null
              : () => ref
                  .read(playerProfileProvider(profileId).notifier)
                  .toggleFollow(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: isFollowing
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(20),
              border: isFollowing
                  ? Border.all(color: Colors.white.withValues(alpha: 0.25))
                  : null,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isFollowing ? 'Following' : 'Follow',
                    style: TextStyle(
                      color: isFollowing
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SocialCount extends StatelessWidget {
  const _SocialCount({
    required this.label,
    required this.count,
    this.onTap,
  });
  final String label;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            '$count',
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class _AvatarWithGauge extends StatelessWidget {
  const _AvatarWithGauge({required this.data, required this.rankTheme});
  final PlayerProfilePageData data;
  final RankVisualTheme rankTheme;

  @override
  Widget build(BuildContext context) {
    final ranking = data.unified.ranking;
    final identity = data.unified.identity;
    final progress = (ranking.progress / 100).clamp(0.0, 1.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor: Colors.white.withOpacity(0.05),
            valueColor: AlwaysStoppedAnimation<Color>(rankTheme.primary),
          ),
        ).animate().rotate(duration: 1.seconds),
        _AvatarCircle(
          url: identity.avatarUrl,
          radius: 60,
          fallbackLetter: identity.name.isNotEmpty ? identity.name[0] : '?',
          backgroundColor: rankTheme.deep,
          fontSize: 32,
        ),
        Positioned(
          bottom: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: rankTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${ranking.impactPoints} IP',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.62),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.14)),
                ),
                child: Text(
                  'SI ${ranking.swingIndex.toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.rankTheme});
  final String title;
  final RankVisualTheme rankTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(width: 4, height: 16, color: rankTheme.primary),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5)),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.url,
    required this.radius,
    required this.fallbackLetter,
    required this.backgroundColor,
    required this.fontSize,
  });

  final String? url;
  final double radius;
  final String fallbackLetter;
  final Color backgroundColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: ClipOval(
        child: url != null
            ? Image.network(
                url!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() => Text(
        fallbackLetter,
        style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white),
      );
}
