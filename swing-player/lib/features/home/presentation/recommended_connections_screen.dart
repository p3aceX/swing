import "package:cached_network_image/cached_network_image.dart";
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/leaderboard_controller.dart';
import '../data/leaderboard_repository.dart';
import '../domain/leaderboard_models.dart';

class RecommendedConnectionsScreen extends ConsumerWidget {
  const RecommendedConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(recommendationsProvider);

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
          'People You May Know',
          style: TextStyle(
            color: context.fg,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.stroke, height: 1),
        ),
      ),
      body: recsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => Center(
          child: Text('Could not load recommendations',
            style: TextStyle(color: context.fgSub, fontSize: 14)),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Text('No recommendations yet',
                style: TextStyle(color: context.fgSub, fontSize: 14)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _ConnectionRow(entry: entry);
            },
          );
        },
      ),
    );
  }
}

class _ConnectionRow extends ConsumerStatefulWidget {
  const _ConnectionRow({required this.entry});
  final LeaderboardEntry entry;

  @override
  ConsumerState<_ConnectionRow> createState() => _ConnectionRowState();
}

class _ConnectionRowState extends ConsumerState<_ConnectionRow> {
  bool _isFollowing = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/player/${entry.playerId}'),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: context.accent.withValues(alpha: 0.15),
            backgroundImage: entry.avatarUrl != null
                ? CachedNetworkImageProvider(entry.avatarUrl!)
                : null,
            child: entry.avatarUrl == null
                ? Text(entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                    style: TextStyle(color: context.accent, fontSize: 16, fontWeight: FontWeight.w800))
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  '${entry.rankLabel} • ${entry.impactPoints} IP',
                  style: TextStyle(
                    color: context.fgSub, fontSize: 12, fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            height: 36,
            child: ElevatedButton(
              onPressed: _loading ? null : _toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFollowing ? Colors.transparent : context.accent,
                foregroundColor: _isFollowing ? context.fg : Colors.black,
                elevation: 0,
                padding: EdgeInsets.zero,
                side: _isFollowing ? BorderSide(color: context.stroke) : BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _loading
                  ? SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, 
                        color: _isFollowing ? context.fg : Colors.black))
                  : Text(
                      _isFollowing ? 'Following' : 'Follow',
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800,
                        color: _isFollowing ? context.fg : Colors.black,
                      ),
                    ),
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }

  Future<void> _toggleFollow() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(leaderboardRepositoryProvider);
      if (_isFollowing) {
        await repo.unfollowPlayer(widget.entry.playerId);
      } else {
        await repo.followPlayer(widget.entry.playerId);
      }
      if (mounted) setState(() => _isFollowing = !_isFollowing);
    } catch (_) {} finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
