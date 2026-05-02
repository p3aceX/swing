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

const _gold = Color(0xFFFFD700);
const _silver = Color(0xFFB8C4CC);
const _bronze = Color(0xFFCD8C52);

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

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
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: context.stroke),
        ),
      ),
      body: leaderboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (_, __) => Center(
          child: Text('Could not load',
              style: TextStyle(color: context.fgSub, fontWeight: FontWeight.w600)),
        ),
        data: (data) {
          final entries = data.entries;
          final me = data.me;

          if (entries.isEmpty) {
            return Center(
              child: Text('No data yet',
                  style: TextStyle(color: context.fgSub, fontWeight: FontWeight.w600)),
            );
          }

          final isInTop = me != null && entries.any((e) => e.playerId == me.playerId);

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () => ref.refresh(leaderboardProvider.future),
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: me != null && !isInTop ? 120 : 60),
                  itemCount: entries.length,
                  itemBuilder: (context, i) {
                    final entry = entries[i];
                    final position = i + 1;
                    if (position <= 3) {
                      return _TopCard(entry: entry, position: position);
                    }
                    return _RankRow(entry: entry, position: position);
                  },
                ),
              ),
              if (me != null && !isInTop)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _MyStickyRow(entry: me),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── My Sticky Row ─────────────────────────────────────────────────────────────

class _MyStickyRow extends StatelessWidget {
  const _MyStickyRow({required this.entry});
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final rankTier = resolveRankTierFlexible(rank: entry.rankBase, label: entry.rank);
    final rankTheme = resolveRankVisualTheme(rankTier.rank.toLowerCase());

    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(top: BorderSide(color: context.stroke, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: rankTheme.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: rankTheme.primary, width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: entry.avatarUrl != null
                  ? CachedNetworkImage(
                      imageUrl: entry.avatarUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _Initial(entry: entry, color: rankTheme.primary),
                    )
                  : _Initial(entry: entry, color: rankTheme.primary),
            ),
            const SizedBox(width: 12),
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
                  Text(
                    rankTier.label.toUpperCase(),
                    style: TextStyle(
                      color: rankTheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${entry.impactPoints}',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'IP',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
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

// ── Top 3 cards ───────────────────────────────────────────────────────────────

class _TopCard extends StatelessWidget {
  const _TopCard({required this.entry, required this.position});
  final LeaderboardEntry entry;
  final int position;

  Color get _medalColor => switch (position) {
        1 => _gold,
        2 => _silver,
        _ => _bronze,
      };

  @override
  Widget build(BuildContext context) {
    final rankTier = resolveRankTierFlexible(rank: entry.rankBase, label: entry.rank);
    final rankTheme = resolveRankVisualTheme(rankTier.rank.toLowerCase());
    final isFirst = position == 1;

    return GestureDetector(
      onTap: () => context.push('/player/${entry.playerId}'),
      child: Container(
        margin: EdgeInsets.fromLTRB(16, isFirst ? 16 : 10, 16, 0),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.stroke, width: 1),
        ),
        child: Stack(
          children: [
            // Ghost position number watermark
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  '$position',
                  style: TextStyle(
                    color: _medalColor.withValues(alpha: 0.18),
                    fontSize: 100,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -4,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Left: position + rank badge stacked
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '#$position',
                        style: TextStyle(
                          color: _medalColor,
                          fontSize: isFirst ? 34 : 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SvgPicture.asset(
                        rankTier.assetPath,
                        width: isFirst ? 42 : 34,
                        height: isFirst ? 42 : 34,
                      ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // Avatar
                  Container(
                    width: isFirst ? 64 : 52,
                    height: isFirst ? 64 : 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _medalColor, width: 2),
                      color: context.panel,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: entry.avatarUrl != null
                        ? CachedNetworkImage(
                            imageUrl: entry.avatarUrl!,
                            fit: BoxFit.cover,
                            memCacheWidth: 128,
                            memCacheHeight: 128,
                            errorWidget: (_, __, ___) =>
                                _Initial(entry: entry, color: rankTheme.primary),
                          )
                        : _Initial(entry: entry, color: rankTheme.primary),
                  ),

                  const SizedBox(width: 14),

                  // Name + rank label
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
                            fontSize: isFirst ? 17 : 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: rankTheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            rankTier.label.toUpperCase(),
                            style: TextStyle(
                              color: rankTheme.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // IP
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${entry.impactPoints}',
                        style: TextStyle(
                          color: context.fg,
                          fontSize: isFirst ? 20 : 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'IP',
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Medal color left strip
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: _medalColor,
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(20)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Others section header ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
      child: Row(
        children: [
          Text(
            'OTHERS',
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
    );
  }
}

// ── Flat list row (#4 onwards) ────────────────────────────────────────────────

class _RankRow extends StatelessWidget {
  const _RankRow({required this.entry, required this.position});
  final LeaderboardEntry entry;
  final int position;

  @override
  Widget build(BuildContext context) {
    final rankTier = resolveRankTierFlexible(rank: entry.rankBase, label: entry.rank);
    final rankTheme = resolveRankVisualTheme(rankTier.rank.toLowerCase());
    final isFirst4 = position == 4;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFirst4) _SectionHeader(),
        InkWell(
          onTap: () => context.push('/player/${entry.playerId}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '$position',
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.panel,
                    border: Border.all(
                        color: rankTheme.border.withValues(alpha: 0.45),
                        width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: entry.avatarUrl != null
                      ? CachedNetworkImage(
                          imageUrl: entry.avatarUrl!,
                          fit: BoxFit.cover,
                          memCacheWidth: 88,
                          memCacheHeight: 88,
                          errorWidget: (_, __, ___) =>
                              _Initial(entry: entry, color: rankTheme.primary),
                        )
                      : _Initial(entry: entry, color: rankTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          SvgPicture.asset(rankTier.assetPath, width: 13, height: 13),
                          const SizedBox(width: 5),
                          Text(
                            rankTier.label,
                            style: TextStyle(
                              color: rankTheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${entry.impactPoints}',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'IP',
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (position > 3)
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 72,
            endIndent: 20,
            color: context.stroke,
          ),
      ],
    );
  }
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
        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16),
      ),
    );
  }
}
