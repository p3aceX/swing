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

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.surf,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.fg),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Leaderboard',
          style: TextStyle(
            color: context.fg,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.stroke, height: 1),
        ),
      ),
      body: leaderboardAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (_, __) => Center(
          child: Text(
            'Could not load leaderboard',
            style: TextStyle(color: context.fgSub, fontWeight: FontWeight.w600),
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Text(
                'No leaderboard data yet',
                style: TextStyle(
                    color: context.fgSub, fontWeight: FontWeight.w600),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(leaderboardProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _LeaderboardListRow(
                entry: entries[index],
                position: index + 1,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LeaderboardListRow extends StatelessWidget {
  const _LeaderboardListRow({
    required this.entry,
    required this.position,
  });

  final LeaderboardEntry entry;
  final int position;

  @override
  Widget build(BuildContext context) {
    final rankTier =
        resolveRankTierFlexible(rank: entry.rankBase, label: entry.rank);
    final rankTheme = resolveRankVisualTheme(rankTier.rank.toLowerCase());
    final posColor = switch (position) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => context.fgSub,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/player/${entry.playerId}'),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.stroke.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                child: Text(
                  '#$position',
                  style: TextStyle(
                    color: posColor,
                    fontSize: position <= 3 ? 18 : 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _Avatar(entry: entry, color: posColor),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: rankTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: rankTheme.border.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(rankTier.assetPath,
                              width: 16, height: 16),
                          const SizedBox(width: 5),
                          Text(
                            rankTier.label.toUpperCase(),
                            style: TextStyle(
                              color: rankTheme.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.impactPoints}',
                    style: TextStyle(
                      color: context.gold,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'IP',
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.entry, required this.color});

  final LeaderboardEntry entry;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
        color: context.panel,
      ),
      clipBehavior: Clip.antiAlias,
      child: entry.avatarUrl != null
          ? CachedNetworkImage(
              imageUrl: entry.avatarUrl!,
              fit: BoxFit.cover,
              memCacheWidth: 132,
              memCacheHeight: 132,
              errorWidget: (_, __, ___) => _Initial(entry: entry),
            )
          : _Initial(entry: entry),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
        style: TextStyle(
          color: context.accent,
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      ),
    );
  }
}
