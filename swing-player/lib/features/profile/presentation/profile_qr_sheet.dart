import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../teams/controller/teams_controller.dart';
import '../domain/profile_models.dart';
import '../domain/rank_frame_resolver.dart';
import '../domain/rank_visual_theme.dart';

class ProfileQrSheet extends ConsumerStatefulWidget {
  const ProfileQrSheet({
    super.key,
    required this.data,
    this.initialIndex = 0,
  });

  final PlayerProfilePageData data;
  final int initialIndex;

  @override
  ConsumerState<ProfileQrSheet> createState() => _ProfileQrSheetState();
}

class _ProfileQrSheetState extends ConsumerState<ProfileQrSheet> {
  bool _handledScan = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialIndex.clamp(0, 1),
      child: SafeArea(
        top: true,
        child: Container(
          decoration: BoxDecoration(
            color: context.bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: context.stroke,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Player Flex Card',
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded, color: context.fgSub),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TabBar(
                  tabs: [
                    Tab(text: 'Flex Card'),
                    Tab(text: 'Scan'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: TabBarView(
                  children: [
                    _FlexCardTab(
                      data: widget.data,
                      qrPayload: _qrPayload,
                      deepLink: _deepLink,
                    ),
                    _ScanQrTab(onScan: _handleScan),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Deep / universal link — opens the app on Android & iOS if installed,
  /// falls back to the website (which can redirect to the store) otherwise.
  String get _deepLink {
    final swingId = widget.data.identity.swingId;
    return 'https://Swingcricketapp.com/player/@$swingId';
  }

  String get _qrPayload {
    return jsonEncode({
      'type': 'SWING_PLAYER_PROFILE',
      'profileId': widget.data.identity.id,
      'swingId': widget.data.identity.swingId,
      'name': widget.data.identity.fullName,
      // Deep link so scanning the card's QR opens the app directly.
      'publicUrl': _deepLink,
    });
  }

  Future<void> _handleScan(String rawValue) async {
    if (_handledScan || !mounted) return;
    _handledScan = true;

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is Map<String, dynamic>) {
        final type = decoded['type']?.toString();
        if (type == 'SWING_PLAYER_PROFILE') {
          final id = decoded['profileId']?.toString() ?? '';
          final name = decoded['name']?.toString() ?? 'Swing Player';
          final swingId = decoded['swingId']?.toString() ?? '';
          if (id.isNotEmpty) {
            await _showScanResultSheet(
              title: name,
              subtitle: swingId.isNotEmpty ? '@$swingId' : 'Player Profile',
              icon: Icons.person_rounded,
              actions: [
                _ScanAction(
                  label: 'View Profile',
                  icon: Icons.visibility_outlined,
                  onTap: () {
                    context.pop(); // Close result sheet
                    context.pop(); // Close QR sheet
                    context.push('/player/$id');
                  },
                ),
                _ScanAction(
                  label: 'Follow Player',
                  icon: Icons.person_add_outlined,
                  onTap: () async {
                    // We need profile controller for this, but can also use repository directly
                    // or just navigate to profile and let them follow there.
                    // For now, navigating to profile is a good primary action.
                    context.pop();
                    context.pop();
                    context.push('/player/$id');
                  },
                ),
              ],
            );
          }
        } else if (type == 'SWING_TEAM_INVITE') {
          final id = decoded['teamId']?.toString() ?? '';
          final name = decoded['teamName']?.toString() ?? 'Swing Team';
          if (id.isNotEmpty) {
            await _showScanResultSheet(
              title: name,
              subtitle: 'Team Invite',
              icon: Icons.groups_rounded,
              actions: [
                _ScanAction(
                  label: 'View Team Details',
                  icon: Icons.visibility_outlined,
                  onTap: () {
                    context.pop();
                    context.pop();
                    context.push('/team/$id');
                  },
                ),
                _ScanAction(
                  label: 'Join Team',
                  icon: Icons.group_add_outlined,
                  onTap: () async {
                    final ok = await ref
                        .read(teamsControllerProvider.notifier)
                        .joinTeam(id);
                    if (mounted) {
                      context.pop();
                      if (ok) {
                        context.pop();
                        context.push('/team/$id');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Successfully joined the team!')),
                        );
                      } else {
                        final error = ref.read(teamsControllerProvider).error;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(error ?? 'Could not join team.')),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          }
        }
      } else if (rawValue.startsWith('http')) {
        // Just show link
        await _showScanResultSheet(
          title: 'Link Detected',
          subtitle: rawValue,
          icon: Icons.link_rounded,
          actions: [
            _ScanAction(
              label: 'Open Link',
              icon: Icons.open_in_new_rounded,
              onTap: () {
                // Link handling logic if needed
                Navigator.pop(context);
              },
            ),
          ],
        );
      }
    } catch (e) {
      // Fallback for raw text
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: context.cardBg,
          title: const Text('Scanned QR'),
          content: Text(rawValue, style: TextStyle(color: context.fgSub)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }

    if (mounted) {
      setState(() => _handledScan = false);
    }
  }

  Future<void> _showScanResultSheet({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<_ScanAction> actions,
  }) async {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: context.accent, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: context.fg,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            ...actions.map((action) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: action.onTap,
                      style: FilledButton.styleFrom(
                        backgroundColor: context.panel,
                        foregroundColor: context.fg,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: context.stroke),
                        ),
                      ),
                      icon: Icon(action.icon, size: 20),
                      label: Text(
                        action.label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: context.fgSub,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  _ScanAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

// ══════════════════════════════════════════════════════════════════════════════
// FLEX CARD TAB
// ══════════════════════════════════════════════════════════════════════════════

class _FlexCardTab extends StatefulWidget {
  const _FlexCardTab({
    required this.data,
    required this.qrPayload,
    required this.deepLink,
  });

  final PlayerProfilePageData data;
  final String qrPayload;
  final String deepLink;

  @override
  State<_FlexCardTab> createState() => _FlexCardTabState();
}

class _FlexCardTabState extends State<_FlexCardTab> {
  final _screenshotController = ScreenshotController();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final rankTheme = resolveRankVisualTheme(data.rankProgress.rank);
    final tier = resolveRankTierFlexible(
      rank: data.rankProgress.rank,
      division: data.rankProgress.division,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      children: [
        // ── Card preview ─────────────────────────────────────────────────
        Screenshot(
          controller: _screenshotController,
          child: _FlexCard(
            data: data,
            rankTheme: rankTheme,
            tier: tier,
            qrPayload: widget.qrPayload,
            deepLink: widget.deepLink,
          ),
        ),

        const SizedBox(height: 20),

        // ── Action buttons ────────────────────────────────────────────────
        Row(
          children: [
            // Save Image
            Expanded(
              child: _ActionButton(
                icon: Icons.download_rounded,
                label: _isSaving ? 'Saving…' : 'Save Image',
                onTap: _isSaving ? null : _saveImage,
                rankTheme: rankTheme,
                outlined: true,
              ),
            ),
            const SizedBox(width: 10),
            // Share
            Expanded(
              child: _ActionButton(
                icon: Icons.ios_share_rounded,
                label: 'Share Card',
                onTap: _shareImage,
                rankTheme: rankTheme,
                outlined: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<File?> _captureCard() async {
    final image = await _screenshotController.capture(pixelRatio: 3.0);
    if (image == null) return null;
    final dir = await getTemporaryDirectory();
    final swingId =
        widget.data.identity.swingId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final file = File('${dir.path}/swing_flex_$swingId.png');
    await file.writeAsBytes(image);
    return file;
  }

  Future<void> _saveImage() async {
    setState(() => _isSaving = true);
    try {
      final file = await _captureCard();
      if (file == null || !mounted) return;
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        subject: 'My Swing Player Card',
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _shareImage() async {
    final file = await _captureCard();
    if (file == null || !mounted) return;
    final name = widget.data.identity.fullName;
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'image/png')],
      text:
          '🏏 $name on Swing Cricket.\nDownload the app from Play Store and challenge me: ${widget.deepLink}\nhttps://Swingcricketapp.com',
      subject: 'My Swing Player Card',
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FLEX CARD WIDGET  (this is what gets screenshot-ed)
// ══════════════════════════════════════════════════════════════════════════════

class _FlexCard extends StatelessWidget {
  const _FlexCard({
    required this.data,
    required this.rankTheme,
    required this.tier,
    required this.qrPayload,
    required this.deepLink,
  });

  final PlayerProfilePageData data;
  final RankVisualTheme rankTheme;
  final ResolvedRankTier tier;
  final String qrPayload;
  final String deepLink;

  @override
  Widget build(BuildContext context) {
    final identity = data.identity;
    final unifiedIdentity = data.unified.identity;
    final ranking = data.fullStats.ranking;
    final stats = data.unified.stats;
    final swingIndexLabel = data.unified.ranking.swingIndex.toStringAsFixed(1);
    final avatarCandidate =
        (unifiedIdentity.avatarUrl ?? identity.avatarUrl)?.trim();
    final cardAvatarUrl = (avatarCandidate == null || avatarCandidate.isEmpty)
        ? null
        : avatarCandidate;
    final role = (identity.primaryRole).toLowerCase();
    final isBowler = role.contains('bowl') && !role.contains('all');
    final isAllRounder = role.contains('all');
    final location = [identity.city, identity.state]
        .where((e) => e.trim().isNotEmpty)
        .join(', ');
    final computedWinRatePercent = ranking.matchesPlayed > 0
        ? (ranking.matchesWon / ranking.matchesPlayed) * 100
        : 0.0;
    final apiWinRatePercent =
        ranking.winRate <= 1 ? ranking.winRate * 100 : ranking.winRate;
    final winRatePercent =
        computedWinRatePercent > 0 ? computedWinRatePercent : apiWinRatePercent;
    final winRateLabel = '${winRatePercent.clamp(0, 100).toStringAsFixed(0)}%';

    // Adaptive top-3 stats
    final List<({String label, String value})> topStats;
    if (isBowler) {
      topStats = [
        (label: 'WICKETS', value: '${stats.bowling.wickets}'),
        (label: 'ECONOMY', value: stats.bowling.economy.toStringAsFixed(1)),
        (label: 'BEST', value: stats.bowling.bestBowling),
      ];
    } else if (isAllRounder) {
      topStats = [
        (label: 'RUNS', value: '${stats.batting.runs}'),
        (label: 'WICKETS', value: '${stats.bowling.wickets}'),
        (label: 'SR', value: stats.batting.strikeRate.toStringAsFixed(1)),
      ];
    } else {
      topStats = [
        (label: 'RUNS', value: '${stats.batting.runs}'),
        (label: 'SR', value: stats.batting.strikeRate.toStringAsFixed(1)),
        (label: 'AVG', value: stats.batting.average.toStringAsFixed(1)),
      ];
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: double.infinity,
        child: AspectRatio(
          aspectRatio: 9 / 14,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Layered background ──────────────────────────────────
              _CardBackground(
                rankTheme: rankTheme,
                avatarUrl: cardAvatarUrl,
              ),

              // ── Content ─────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: rankTheme.border.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            'SWING FLEX',
                            style: TextStyle(
                              color: rankTheme.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: rankTheme.border.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                tier.assetPath,
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                tier.rank.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      identity.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                        height: 1.05,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _ChipLabel(
                          icon: Icons.sports_cricket_rounded,
                          label: identity.primaryRole,
                        ),
                        if (identity.archetype.trim().isNotEmpty)
                          _ChipLabel(
                            icon: Icons.flash_on_rounded,
                            label: identity.archetype,
                          ),
                        _ChipLabel(
                          icon: Icons.tag_rounded,
                          label: '@${identity.swingId}',
                        ),
                      ],
                    ),
                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            location,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: topStats
                          .map((s) => Expanded(
                                child: _StatTile(
                                  label: s.label,
                                  value: s.value,
                                  rankTheme: rankTheme,
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.34),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: rankTheme.border.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _DataRail(
                              label: 'IMPACT',
                              value: _formatNumber(ranking.lifetimeIp),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                          Expanded(
                            child: _DataRail(
                              label: 'WIN RATE',
                              value: winRateLabel,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                          Expanded(
                            child: _DataRail(
                              label: 'SWING IDX',
                              value: swingIndexLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _BottomStrip(
                      swingId: identity.swingId,
                      qrPayload: qrPayload,
                      rankTheme: rankTheme,
                      deepLink: deepLink,
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

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

// ── Card background with layered rank-themed gradients ─────────────────────

class _CardBackground extends StatelessWidget {
  const _CardBackground({
    required this.rankTheme,
    required this.avatarUrl,
  });
  final RankVisualTheme rankTheme;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (avatarUrl != null && avatarUrl!.trim().isNotEmpty)
          Image.network(
            avatarUrl!,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => ColoredBox(color: rankTheme.deep),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return ColoredBox(color: rankTheme.deep);
            },
          )
        else
          ColoredBox(color: rankTheme.deep),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.78),
                Colors.black.withValues(alpha: 0.42),
                Colors.black.withValues(alpha: 0.88),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(rankTheme.deep, rankTheme.primary, 0.30)!
                    .withValues(alpha: 0.28),
                rankTheme.deep.withValues(alpha: 0.12),
                rankTheme.deep.withValues(alpha: 0.30),
              ],
              stops: const [0.0, 0.58, 1.0],
            ),
          ),
        ),
        // Glow radial at top-right
        Positioned(
          top: -90,
          right: -40,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.9,
                colors: [
                  rankTheme.glow.withValues(alpha: 0.26),
                  rankTheme.glow.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        // Subtle grid / noise texture
        CustomPaint(painter: _GridPainter(rankTheme.border)),
        // Accent edge line at top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.transparent,
                rankTheme.border.withValues(alpha: 0.7),
                rankTheme.border,
                rankTheme.border.withValues(alpha: 0.7),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        // Bottom fade
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  rankTheme.deep.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.04)
      ..strokeWidth = 0.5;
    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
}

// ── Single stat cell ──────────────────────────────────────────────────────

class _ChipLabel extends StatelessWidget {
  const _ChipLabel({
    required this.icon,
    required this.label,
  });
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.86)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.rankTheme,
  });
  final String label;
  final String value;
  final RankVisualTheme rankTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rankTheme.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: rankTheme.primary.withValues(alpha: 0.72),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _DataRail extends StatelessWidget {
  const _DataRail({
    required this.label,
    required this.value,
  });
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.9,
          ),
        ),
      ],
    );
  }
}

// ── Bottom strip ──────────────────────────────────────────────────────────

class _BottomStrip extends StatelessWidget {
  const _BottomStrip({
    required this.swingId,
    required this.qrPayload,
    required this.rankTheme,
    required this.deepLink,
  });
  final String swingId;
  final String qrPayload;
  final RankVisualTheme rankTheme;
  final String deepLink;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rankTheme.border.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // QR code
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: QrImageView(
              data: qrPayload,
              size: 88,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'I am part of the\nBiggest Cricket\nEcosystem.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Join Me.',
                  style: TextStyle(
                    color: rankTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '@$swingId · Swingcricketapp.com',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
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

class _ScanQrTab extends StatelessWidget {
  const _ScanQrTab({required this.onScan});
  final Future<void> Function(String value) onScan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            MobileScanner(
              onDetect: (capture) async {
                final codes = capture.barcodes;
                final code = codes.isEmpty ? null : codes.first.rawValue;
                if (code == null || code.isEmpty) return;
                await onScan(code);
              },
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: context.stroke),
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.cardBg.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'Scan another Swing player card.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.rankTheme,
    required this.outlined,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final RankVisualTheme rankTheme;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final bg = outlined
        ? rankTheme.primary.withValues(alpha: 0.1)
        : rankTheme.secondary;
    final fg = outlined ? rankTheme.primary : Colors.white;
    final border = outlined
        ? Border.all(color: rankTheme.border.withValues(alpha: 0.5))
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: border,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
