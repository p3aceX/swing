import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';

class RankFramedAvatar extends StatelessWidget {
  const RankFramedAvatar({
    super.key,
    required this.frameAsset,
    required this.displayName,
    this.avatarUrl,
    this.size = 148,
    this.glowColor,
  });

  final String frameAsset;
  final String displayName;
  final String? avatarUrl;
  final double size;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    // Opening in the rank frames is typically slightly above center
    final avatarSize = size * 0.58;
    final frameGlow = glowColor ?? context.accent.withValues(alpha: 0.26);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background Glow
          Positioned(
            top: size * 0.15,
            child: Container(
              width: size * 0.65,
              height: size * 0.65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: frameGlow.withValues(alpha: 0.4),
                    blurRadius: size * 0.2,
                    spreadRadius: size * 0.05,
                  ),
                ],
              ),
            ),
          ),

          // Avatar Image
          Align(
            alignment: const Alignment(0, -0.12), // Frames are weighted top-heavy
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.panel,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _AvatarCore(
                displayName: displayName,
                avatarUrl: avatarUrl,
                size: avatarSize,
              ),
            ),
          ),

          // Rank Frame SVG
          Positioned.fill(
            child: SvgPicture.asset(
              frameAsset,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarCore extends StatelessWidget {
  const _AvatarCore({
    required this.displayName,
    required this.avatarUrl,
    required this.size,
  });

  final String displayName;
  final String? avatarUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = _buildInitials(displayName);

    if (avatarUrl == null || avatarUrl!.trim().isEmpty) {
      return _AvatarFallback(initials: initials, size: size);
    }

    return Image.network(
      avatarUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _AvatarFallback(initials: initials, size: size),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _AvatarFallback(initials: initials, size: size, loading: true);
      },
    );
  }

  String _buildInitials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({
    required this.initials,
    required this.size,
    this.loading = false,
  });

  final String initials;
  final double size;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.panel,
            context.cardBg,
          ],
        ),
      ),
      child: Center(
        child: loading
            ? SizedBox(
                width: size * 0.2,
                height: size * 0.2,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.accent,
                ),
              )
            : Text(
                initials,
                style: TextStyle(
                  color: context.fg,
                  fontSize: size * 0.38,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
      ),
    );
  }
}
