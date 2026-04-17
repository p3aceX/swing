import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ProfileMetricCard extends StatelessWidget {
  const ProfileMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.caption,
    this.accent = false,
    this.isLocked = false,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;
  final String? caption;
  final bool accent;
  final bool isLocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tone = accent && !isLocked ? context.accent : context.fg;
    final card = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    isLocked ? Icons.lock_outline_rounded : icon,
                    size: 16,
                    color: isLocked ? context.fgSub : tone,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isLocked)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Upgrade to Pro',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          else
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: tone,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );

    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}
