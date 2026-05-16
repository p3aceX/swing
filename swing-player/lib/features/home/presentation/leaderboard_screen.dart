import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/domain/rank_frame_resolver.dart';
import '../../profile/domain/rank_visual_theme.dart';
import '../controller/leaderboard_controller.dart';
import '../domain/leaderboard_models.dart';

const _ipBadgeColor = Color(0xFFFF9F0A);

// Podium platform colours
const _p1Color = Color(0xFF5E5CE6);
const _p2Color = Color(0xFFE8997E);
const _p3Color = Color(0xFFDC8B6A);

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.fg, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Leaderboard',
          style: TextStyle(
            color: context.fg,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(47),
          child: Column(
            children: [
              Container(height: 0.5, color: context.stroke),
              TabBar(
                controller: _tab,
                labelColor: context.fg,
                unselectedLabelColor: context.fgSub,
                labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                indicatorColor: context.accent,
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Global Board'),
                  Tab(text: 'Season Board'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _LeaderboardTabView(),
          _SeasonComingSoon(),
        ],
      ),
    );
  }
}

// ── Tab body ──────────────────────────────────────────────────────────────────

class _LeaderboardTabView extends ConsumerWidget {
  const _LeaderboardTabView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(leaderboardProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, __) => Center(
        child: Text('Could not load',
            style: TextStyle(color: context.fgSub, fontWeight: FontWeight.w600)),
      ),
      data: (data) {
        final entries  = data.entries;
        final me       = data.me;

        if (entries.isEmpty) {
          return Center(
            child: Text('No data yet',
                style: TextStyle(color: context.fgSub, fontWeight: FontWeight.w600)),
          );
        }

        final top3     = entries.take(3).toList();
        final rest     = entries.skip(3).toList();
        final isInTop  = me != null && entries.any((e) => e.playerId == me.playerId);

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => ref.refresh(leaderboardProvider.future),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Podium
                  SliverToBoxAdapter(child: _Podium(top3: top3)),

                  // "Rankings" label
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                      child: Row(
                        children: [
                          Text(
                            'RANKINGS',
                            style: TextStyle(
                              color: context.fgSub,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Divider(color: context.stroke, height: 1)),
                        ],
                      ),
                    ),
                  ),

                  // Flat list (#4+)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _RankRow(entry: rest[i], position: i + 4),
                      childCount: rest.length,
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(height: me != null && !isInTop ? 120 : 60),
                  ),
                ],
              ),
            ),
            if (me != null && !isInTop)
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: _MyStickyRow(entry: me),
              ),
          ],
        );
      },
    );
  }
}

// ── Podium ────────────────────────────────────────────────────────────────────

class _Podium extends StatelessWidget {
  const _Podium({required this.top3});
  final List<LeaderboardEntry> top3;

  @override
  Widget build(BuildContext context) {
    if (top3.isEmpty) return const SizedBox.shrink();
    final first  = top3[0];
    final second = top3.length > 1 ? top3[1] : null;
    final third  = top3.length > 2 ? top3[2] : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (second != null)
            Expanded(child: _PodiumSlot(entry: second, position: 2, platformH: 72)),
          const SizedBox(width: 8),
          Expanded(child: _PodiumSlot(entry: first, position: 1, platformH: 104)),
          const SizedBox(width: 8),
          if (third != null)
            Expanded(child: _PodiumSlot(entry: third, position: 3, platformH: 56))
          else
            const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  const _PodiumSlot({
    required this.entry,
    required this.position,
    required this.platformH,
  });

  final LeaderboardEntry entry;
  final int position;
  final double platformH;

  Color get _color => switch (position) {
        1 => _p1Color,
        2 => _p2Color,
        _ => _p3Color,
      };

  double get _avatarSize => position == 1 ? 70.0 : 54.0;

  String _fmtIp(int v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : '$v';

  @override
  Widget build(BuildContext context) {
    final rankTier  = resolveRankTierFlexible(rank: entry.rankBase, label: entry.rank);
    final rankTheme = resolveRankVisualTheme(rankTier.rank.toLowerCase());

    return GestureDetector(
      onTap: () => context.push('/player/${entry.playerId}'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // First name only (space is tight)
          Text(
            entry.name.split(' ').first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.fg,
              fontSize: position == 1 ? 13 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),

          // Avatar
          Container(
            width: _avatarSize,
            height: _avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _color, width: 2.5),
            ),
            child: ClipOval(
              child: entry.avatarUrl != null
                  ? CachedNetworkImage(
                      imageUrl: entry.avatarUrl!,
                      width: _avatarSize,
                      height: _avatarSize,
                      fit: BoxFit.cover,
                      memCacheWidth: 140,
                      memCacheHeight: 140,
                      errorWidget: (_, __, ___) =>
                          _Initial(entry: entry, color: rankTheme.primary),
                    )
                  : _Initial(entry: entry, color: rankTheme.primary),
            ),
          ),
          const SizedBox(height: 5),

          // IP badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _ipBadgeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, size: 11, color: Colors.white),
                const SizedBox(width: 3),
                Text(
                  _fmtIp(entry.impactPoints),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Platform
          Container(
            width: double.infinity,
            height: platformH,
            decoration: BoxDecoration(
              color: _color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$position',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 52,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rank row (#4+) ────────────────────────────────────────────────────────────

class _RankRow extends StatelessWidget {
  const _RankRow({required this.entry, required this.position});
  final LeaderboardEntry entry;
  final int position;

  @override
  Widget build(BuildContext context) {
    final rankTier  = resolveRankTierFlexible(rank: entry.rankBase, label: entry.rank);
    final rankTheme = resolveRankVisualTheme(rankTier.rank.toLowerCase());

    return InkWell(
      onTap: () => context.push('/player/${entry.playerId}'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                // Position — zero-padded 2 digits
                SizedBox(
                  width: 28,
                  child: Text(
                    position.toString().padLeft(2, '0'),
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Avatar
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: rankTheme.border.withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: entry.avatarUrl != null
                        ? CachedNetworkImage(
                            imageUrl: entry.avatarUrl!,
                            width: 46,
                            height: 46,
                            fit: BoxFit.cover,
                            memCacheWidth: 92,
                            memCacheHeight: 92,
                            errorWidget: (_, __, ___) =>
                                _Initial(entry: entry, color: rankTheme.primary),
                          )
                        : _Initial(entry: entry, color: rankTheme.primary),
                  ),
                ),
                const SizedBox(width: 12),

                // Name + rank badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: context.panel,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              rankTier.assetPath,
                              width: 13,
                              height: 13,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              rankTier.label,
                              style: TextStyle(
                                color: _readableRankColor(rankTheme.primary),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // IP + star
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${entry.impactPoints}',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star_rounded,
                        size: 16, color: _ipBadgeColor),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 72,
            endIndent: 20,
            color: context.stroke,
          ),
        ],
      ),
    );
  }
}

// ── Sticky "You" row ──────────────────────────────────────────────────────────

class _MyStickyRow extends StatelessWidget {
  const _MyStickyRow({required this.entry});
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final rankTier  = resolveRankTierFlexible(rank: entry.rankBase, label: entry.rank);
    final rankTheme = resolveRankVisualTheme(rankTier.rank.toLowerCase());

    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(top: BorderSide(color: context.stroke, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 10, 20, 10 + MediaQuery.of(context).padding.bottom),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: rankTheme.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // Position badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: context.panel,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                entry.position != null ? '#${entry.position}' : 'YOU',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Avatar
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: rankTheme.primary, width: 1.5),
              ),
              child: ClipOval(
                child: entry.avatarUrl != null
                    ? CachedNetworkImage(
                        imageUrl: entry.avatarUrl!,
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            _Initial(entry: entry, color: rankTheme.primary),
                      )
                    : _Initial(entry: entry, color: rankTheme.primary),
              ),
            ),
            const SizedBox(width: 10),

            // Name + rank
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    rankTier.label,
                    style: TextStyle(
                      color: _readableRankColor(rankTheme.primary),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // IP + star
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${entry.impactPoints}',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.star_rounded, size: 15, color: _ipBadgeColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Season coming soon ────────────────────────────────────────────────────────

class _SeasonComingSoon extends StatelessWidget {
  const _SeasonComingSoon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.military_tech_rounded, size: 64, color: context.fgSub.withValues(alpha: 0.35)),
            const SizedBox(height: 20),
            Text(
              'Season Pass',
              style: TextStyle(
                color: context.fg,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: TextStyle(
                color: context.accent,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Compete in limited-time seasons and earn exclusive rewards.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Darkens a rank colour that's too light to read on a panel background.
Color _readableRankColor(Color c) {
  if (c.computeLuminance() > 0.30) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - 0.28).clamp(0.0, 1.0)).toColor();
  }
  return c;
}

class _Initial extends StatelessWidget {
  const _Initial({required this.entry, required this.color});
  final LeaderboardEntry entry;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      ),
    );
  }
}
