import "package:cached_network_image/cached_network_image.dart";
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/storage/supabase_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controller/profile_controller.dart';
import '../../domain/profile_models.dart';
import '../../domain/rank_frame_resolver.dart';
import '../../domain/rank_visual_theme.dart';
import 'rank_framed_avatar.dart';

class ProfileIdentityLayout extends ConsumerStatefulWidget {
  const ProfileIdentityLayout({
    super.key,
    required this.data,
    required this.isOwnProfile,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
    required this.onTertiaryAction,
  });

  final PlayerProfilePageData data;
  final bool isOwnProfile;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSecondaryAction;
  final VoidCallback onTertiaryAction;

  @override
  ConsumerState<ProfileIdentityLayout> createState() =>
      _ProfileIdentityLayoutState();
}

class _ProfileIdentityLayoutState extends ConsumerState<ProfileIdentityLayout> {
  final _picker = ImagePicker();
  final _storage = SupabaseStorageService();

  bool _isUploadingAvatar = false;

  static const double _coverHeight = 200.0;
  static const double _avatarSize = 120.0;
  static const double _avatarLeft = 20.0;

  @override
  Widget build(BuildContext context) {
    final theme = resolveRankVisualTheme(widget.data.rankProgress.rank);
    final rankAsset = resolveRankFrameAsset(
      rank: widget.data.rankProgress.rank,
      division: widget.data.rankProgress.division,
    );
    final ranking = widget.data.fullStats.ranking;
    final batting = widget.data.fullStats.batting;
    final bowling = widget.data.fullStats.bowling;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.deep,
            context.bg,
            theme.deep.withValues(alpha: 0.92),
          ],
          stops: const [0.0, 0.42, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 220,
            right: -80,
            child: _PageGlow(
              size: 220,
              color: theme.primary.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            top: 460,
            left: -70,
            child: _PageGlow(
              size: 180,
              color: theme.glow.withValues(alpha: 0.08),
            ),
          ),
          Column(
            children: [
              // ── Header ─────────────────────────────────────────────
              _buildHeader(context, theme, rankAsset),
              // ── Body ───────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                        title: 'Stats',
                        subtitle: 'Core profile snapshot',
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _StatsGrid(
                        items: [
                          _StatItem(
                            label: 'Career IP',
                            value:
                                _compact(widget.data.rankProgress.impactPoints),
                            icon: Icons.bolt_rounded,
                            theme: theme,
                            highlighted: true,
                          ),
                          _StatItem(
                            label: 'Matches',
                            value: '${ranking.matchesPlayed}',
                            icon: Icons.sports_cricket_rounded,
                            theme: theme,
                          ),
                          _StatItem(
                            label: 'Win Rate',
                            value: '${ranking.winRate.toStringAsFixed(0)}%',
                            icon: Icons.show_chart_rounded,
                            theme: theme,
                          ),
                          _StatItem(
                            label: 'Runs',
                            value: '${batting.runs}',
                            icon: Icons.sports_baseball_rounded,
                            theme: theme,
                          ),
                          _StatItem(
                            label: 'Wickets',
                            value: '${bowling.wickets}',
                            icon: Icons.adjust_rounded,
                            theme: theme,
                          ),
                          _StatItem(
                            label: 'Followers',
                            value:
                                _compact(widget.data.identity.followersCount),
                            icon: Icons.groups_2_outlined,
                            theme: theme,
                          ),
                        ],
                      ),
                      if (widget.data.showcase.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        _SectionTitle(
                          title: 'Flex',
                          subtitle: 'Pinned proof and social showcase',
                          theme: theme,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 196,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.data.showcase.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final item = widget.data.showcase[index];
                              return _ShowcaseCard(
                                item: item,
                                theme: theme,
                              );
                            },
                          ),
                        ),
                      ],
                      if (widget.data.recentPerformances.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        _SectionTitle(
                          title: 'Recent',
                          subtitle: 'Last verified appearances',
                          theme: theme,
                        ),
                        const SizedBox(height: 12),
                        ...widget.data.recentPerformances.take(3).map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _RecentPerformanceTile(
                                  item: item,
                                  theme: theme,
                                ),
                              ),
                            ),
                      ],
                      if (widget.isOwnProfile &&
                          widget.data.notificationSummary != null) ...[
                        const SizedBox(height: 22),
                        _SectionTitle(
                          title: 'Inbox',
                          subtitle: 'Unread notifications and chat activity',
                          theme: theme,
                        ),
                        const SizedBox(height: 12),
                        _NotificationSummaryCard(
                          summary: widget.data.notificationSummary!,
                          theme: theme,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    RankVisualTheme theme,
    String rankAsset,
  ) {
    final identity = widget.data.identity;
    final rank = widget.data.rankProgress;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover zone ───────────────────────────────────────
            SizedBox(
              height: _coverHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _HeroBackground(
                    imageUrl: identity.coverUrl,
                    theme: theme,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.primary.withValues(alpha: 0.28),
                          theme.secondary.withValues(alpha: 0.12),
                          Colors.black.withValues(alpha: 0.52),
                        ],
                        stops: const [0.0, 0.32, 1.0],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      MediaQuery.paddingOf(context).top + 8,
                      12,
                      0,
                    ),
                    child: _TopBar(
                      title: identity.fullName,
                      isOwnProfile: widget.isOwnProfile,
                      theme: theme,
                      onEditPressed: widget.onPrimaryAction,
                      onScanPressed: widget.onTertiaryAction,
                    ),
                  ),
                ],
              ),
            ),

            // ── Identity zone (below cover) ──────────────────────
            ColoredBox(
              color: theme.deep.withValues(alpha: 0.20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rank pill row — sits to the right of the avatar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      _avatarLeft + _avatarSize + 10,
                      10,
                      16,
                      0,
                    ),
                    child: Row(
                      children: [
                        _RankPill(label: rank.label, theme: theme),
                        if (rank.hasPremiumPass) ...[
                          const SizedBox(width: 8),
                          const _PremiumPill(),
                        ],
                      ],
                    ),
                  ),
                  // Space to clear the bottom half of the straddled avatar
                  const SizedBox(height: 36),
                  // Full-width identity content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: _IdentityContent(
                      data: widget.data,
                      theme: theme,
                      isOwnProfile: widget.isOwnProfile,
                      onPrimaryAction: widget.onPrimaryAction,
                      onSecondaryAction: widget.onSecondaryAction,
                      onTertiaryAction: widget.onTertiaryAction,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ── Rank framed avatar (straddling cover / identity fold) ─
        Positioned(
          top: _coverHeight - _avatarSize / 2,
          left: _avatarLeft,
          child: _AvatarWithUpload(
            frameAsset: rankAsset,
            identity: identity,
            theme: theme,
            isOwnProfile: widget.isOwnProfile,
            isUploading: _isUploadingAvatar,
            onTap: widget.isOwnProfile ? _pickAndUploadMedia : null,
          ),
        ),
      ],
    );
  }

  // ── Sheet & upload ──────────────────────────────────────────────────────────

  Future<void> _pickAndUploadMedia() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 86,
      maxWidth: 1200,
    );
    if (file == null || !mounted) return;

    setState(() => _isUploadingAvatar = true);

    final currentUrl = widget.data.identity.coverUrl;

    try {
      final uploadedUrl = await _storage.uploadUserCoverImage(
        userId: widget.data.identity.id,
        file: file,
      );

      await _evictImage(currentUrl);
      await _evictImage(uploadedUrl);

      ref.read(profileControllerProvider.notifier).patchCover(uploadedUrl);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _evictImage(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    await CachedNetworkImageProvider(url).evict();
  }
}

// ── Avatar with upload camera badge ──────────────────────────────────────────

class _AvatarWithUpload extends StatelessWidget {
  const _AvatarWithUpload({
    required this.frameAsset,
    required this.identity,
    required this.theme,
    required this.isOwnProfile,
    required this.isUploading,
    this.onTap,
  });

  final String frameAsset;
  final PlayerIdentity identity;
  final RankVisualTheme theme;
  final bool isOwnProfile;
  final bool isUploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          RankFramedAvatar(
            frameAsset: frameAsset,
            displayName: identity.fullName,
            avatarUrl: identity.avatarUrl,
            size: 120,
            glowColor: theme.glow.withValues(alpha: 0.38),
          ),
          if (isOwnProfile)
            Positioned(
              bottom: 6,
              right: 2,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: theme.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.bg, width: 2.5),
                ),
                child: Center(
                  child: isUploading
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Identity content ──────────────────────────────────────────────────────────

class _IdentityContent extends StatelessWidget {
  const _IdentityContent({
    required this.data,
    required this.theme,
    required this.isOwnProfile,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
    required this.onTertiaryAction,
  });

  final PlayerProfilePageData data;
  final RankVisualTheme theme;
  final bool isOwnProfile;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSecondaryAction;
  final VoidCallback onTertiaryAction;

  @override
  Widget build(BuildContext context) {
    final identity = data.identity;
    final rank = data.rankProgress;

    final roleLine = [identity.primaryRole.trim(), identity.archetype.trim()]
        .where((s) => s.isNotEmpty)
        .join(' · ');
    final cityLine = [identity.city.trim(), identity.state.trim()]
        .where((s) => s.isNotEmpty)
        .join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name
        Text(
          identity.fullName,
          style: TextStyle(
            color: context.fg,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 5),

        // @handle · Role · Archetype
        Row(
          children: [
            Text(
              '@${_handle(identity.swingId)}',
              style: TextStyle(
                color: theme.secondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (roleLine.isNotEmpty) ...[
              Text(
                '  ·  ',
                style: TextStyle(color: context.fgSub, fontSize: 13),
              ),
              Flexible(
                child: Text(
                  roleLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),

        // Bio
        if (identity.bio.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            identity.bio,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.fg.withValues(alpha: 0.84),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],

        // City
        if (cityLine.isNotEmpty) ...[
          const SizedBox(height: 7),
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 13, color: context.fgSub),
              const SizedBox(width: 4),
              Text(
                cityLine,
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 14),

        // IP progress strip
        _IpProgressStrip(rank: rank, theme: theme),

        const SizedBox(height: 14),

        // Fans · Following
        Row(
          children: [
            _CountItem(
              value: _compact(identity.followersCount),
              label: 'fans',
              theme: theme,
            ),
            const SizedBox(width: 20),
            _CountItem(
              value: _compact(identity.followingCount),
              label: 'following',
              theme: theme,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: _ProfileActionButton(
                label: isOwnProfile
                    ? 'Edit Profile'
                    : ((data.viewerContext?.following ?? false)
                        ? 'Following'
                        : 'Follow'),
                filled: true,
                theme: theme,
                onPressed: onPrimaryAction,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ProfileActionButton(
                label: isOwnProfile ? 'Stats' : 'Message',
                filled: false,
                theme: theme,
                onPressed: onSecondaryAction,
              ),
            ),
            const SizedBox(width: 10),
            _SquareProfileAction(
              icon: isOwnProfile
                  ? Icons.qr_code_2_rounded
                  : Icons.query_stats_rounded,
              theme: theme,
              onPressed: onTertiaryAction,
            ),
          ],
        ),
      ],
    );
  }
}

// ── IP progress strip ─────────────────────────────────────────────────────────

class _IpProgressStrip extends StatelessWidget {
  const _IpProgressStrip({required this.rank, required this.theme});

  final PlayerRankProgress rank;
  final RankVisualTheme theme;

  @override
  Widget build(BuildContext context) {
    final progress = rank.progress.clamp(0.0, 1.0);
    final hasNext = rank.nextRankLabel.trim().isNotEmpty &&
        rank.nextRankLabel.trim() != rank.label.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, size: 15, color: theme.primary),
              const SizedBox(width: 6),
              Text(
                '${_compact(rank.impactPoints)} IP',
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (hasNext)
                Text(
                  '${rank.pointsToNextRank} to ${rank.nextRankLabel}',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: theme.deep.withValues(alpha: 0.42),
              valueColor: AlwaysStoppedAnimation<Color>(theme.secondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShowcaseCard extends StatelessWidget {
  const _ShowcaseCard({
    required this.item,
    required this.theme,
  });

  final ProfileShowcaseItem item;
  final RankVisualTheme theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.tryParse(item.url);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        width: 164,
        decoration: BoxDecoration(
          color: theme.deep.withValues(alpha: 0.56),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: theme.border.withValues(alpha: 0.20)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.thumbnailUrl != null)
              Image.network(
                item.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.28),
                    Colors.black.withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.isPinned)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'PINNED',
                        style: TextStyle(
                          color: theme.glow,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    item.title ?? _showcaseLabel(item.type),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  if ((item.caption ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.caption!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentPerformanceTile extends StatelessWidget {
  const _RecentPerformanceTile({
    required this.item,
    required this.theme,
  });

  final PlayerRecentPerformance item;
  final RankVisualTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.deep.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.border.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.insights_rounded, color: theme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.opponent,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            item.impactPoints == 0 ? '--' : '${item.impactPoints} IP',
            style: TextStyle(
              color: theme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationSummaryCard extends StatelessWidget {
  const _NotificationSummaryCard({
    required this.summary,
    required this.theme,
  });

  final ProfileNotificationSummary summary;
  final RankVisualTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _NotificationPill(
            label: 'Alerts',
            value: '${summary.unreadNotificationCount}',
            theme: theme,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _NotificationPill(
            label: 'Chats',
            value: '${summary.unreadConversationCount}',
            theme: theme,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _NotificationPill(
            label: 'Msgs',
            value: '${summary.unreadMessageCount}',
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class _NotificationPill extends StatelessWidget {
  const _NotificationPill({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final RankVisualTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: context.fg,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rank pill ─────────────────────────────────────────────────────────────────

class _RankPill extends StatelessWidget {
  const _RankPill({required this.label, required this.theme});

  final String label;
  final RankVisualTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.border.withValues(alpha: 0.28)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: theme.glow,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Premium pass pill ─────────────────────────────────────────────────────────

class _PremiumPill extends StatelessWidget {
  const _PremiumPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: context.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded, size: 11, color: context.gold),
          const SizedBox(width: 4),
          Text(
            'PASS',
            style: TextStyle(
              color: context.gold,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Count item ────────────────────────────────────────────────────────────────

class _CountItem extends StatelessWidget {
  const _CountItem({
    required this.value,
    required this.label,
    required this.theme,
  });

  final String value;
  final String label;
  final RankVisualTheme theme;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$value ',
            style: TextStyle(
              color: theme.glow,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: label,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action buttons (theme-aware) ──────────────────────────────────────────────

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({
    required this.label,
    required this.filled,
    required this.theme,
    required this.onPressed,
  });

  final String label;
  final bool filled;
  final RankVisualTheme theme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? theme.secondary : theme.deep.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color:
              filled ? theme.secondary : theme.border.withValues(alpha: 0.36),
          width: 1.4,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 44,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: filled ? Colors.white : theme.glow,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SquareProfileAction extends StatelessWidget {
  const _SquareProfileAction({
    required this.icon,
    required this.theme,
    required this.onPressed,
  });

  final IconData icon;
  final RankVisualTheme theme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.deep.withValues(alpha: 0.28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.border.withValues(alpha: 0.34),
          width: 1.4,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 46,
          height: 44,
          child: Center(
            child: Icon(icon, size: 20, color: theme.primary),
          ),
        ),
      ),
    );
  }
}

// ── Cover background ──────────────────────────────────────────────────────────

class _HeroBackground extends StatelessWidget {
  const _HeroBackground({required this.imageUrl, required this.theme});

  final String? imageUrl;
  final RankVisualTheme theme;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _HeroFallback(theme: theme),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _HeroFallback(theme: theme);
        },
      );
    }
    return _HeroFallback(theme: theme);
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback({required this.theme});

  final RankVisualTheme theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.primary.withValues(alpha: 0.42),
            theme.secondary.withValues(alpha: 0.22),
            theme.deep,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -70,
            top: 60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            left: -50,
            bottom: 40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.glow.withValues(alpha: 0.10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.isOwnProfile,
    required this.theme,
    required this.onEditPressed,
    required this.onScanPressed,
  });

  final String title;
  final bool isOwnProfile;
  final RankVisualTheme theme;
  final VoidCallback onEditPressed;
  final VoidCallback onScanPressed;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Row(
      children: [
        if (canPop)
          _OverlayIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            theme: theme,
            onPressed: () => Navigator.of(context).maybePop(),
          )
        else
          const SizedBox(width: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (isOwnProfile) ...[
          _TopActionPill(
            icon: Icons.qr_code_scanner_rounded,
            theme: theme,
            onPressed: onScanPressed,
          ),
          const SizedBox(width: 8),
          _TopActionPill(
            icon: Icons.edit_outlined,
            theme: theme,
            onPressed: onEditPressed,
          ),
        ],
      ],
    );
  }
}

class _TopActionPill extends StatelessWidget {
  const _TopActionPill({
    required this.icon,
    required this.theme,
    required this.onPressed,
  });

  final IconData icon;
  final RankVisualTheme theme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.deep.withValues(alpha: 0.48),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Center(
            child: Icon(icon, color: Colors.white, size: 19),
          ),
        ),
      ),
    );
  }
}

class _OverlayIconButton extends StatelessWidget {
  const _OverlayIconButton({
    required this.icon,
    required this.theme,
    required this.onPressed,
  });

  final IconData icon;
  final RankVisualTheme theme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.deep.withValues(alpha: 0.44),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Icon(icon, color: Colors.white, size: 21),
          ),
        ),
      ),
    );
  }
}

class _PageGlow extends StatelessWidget {
  const _PageGlow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: size * 0.45,
              spreadRadius: size * 0.08,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats section (body) ──────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.theme,
  });

  final String title;
  final String subtitle;
  final RankVisualTheme theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: theme.glow,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: theme.border.withValues(alpha: 0.84),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.theme,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final RankVisualTheme theme;
  final bool highlighted;
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.items});

  final List<_StatItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map(
                (item) => SizedBox(
                  width: tileWidth,
                  child: _StatCard(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.highlighted
            ? item.theme.primary.withValues(alpha: 0.10)
            : item.theme.deep.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.highlighted
              ? item.theme.border.withValues(alpha: 0.28)
              : item.theme.border.withValues(alpha: 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: item.theme.deep.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.highlighted
                  ? item.theme.primary.withValues(alpha: 0.16)
                  : item.theme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 18,
              color: item.highlighted ? item.theme.secondary : context.fgSub,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: item.highlighted ? item.theme.primary : context.fg,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: item.theme.border.withValues(alpha: 0.86),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _handle(String swingId) {
  final raw = swingId.trim();
  if (raw.isEmpty) return 'swingplayer';
  return raw.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '').toLowerCase();
}

String _compact(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K';
  }
  return '$value';
}

String _showcaseLabel(String type) {
  switch (type) {
    case 'INSTAGRAM_REEL':
      return 'Instagram Reel';
    case 'YOUTUBE_SHORT':
      return 'YouTube Short';
    case 'MATCH_HIGHLIGHT':
      return 'Match Highlight';
    default:
      return type
          .toLowerCase()
          .split('_')
          .map((part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}')
          .join(' ');
  }
}
