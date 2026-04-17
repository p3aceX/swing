import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/growth_insights_model.dart';

class RoleIndexPercentileRow extends StatelessWidget {
  const RoleIndexPercentileRow({
    super.key,
    required this.roleIndex,
    required this.percentile,
    required this.playerRole,
    required this.city,
  });

  final double? roleIndex;
  final PercentileData? percentile;
  final String playerRole;
  final String city;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniAnalyticsCard(
            child: _RoleIndexCard(
              roleIndex: roleIndex,
              playerRole: playerRole,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniAnalyticsCard(
            child: _PercentileCard(
              percentile: percentile,
              playerRole: playerRole,
              city: city,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniAnalyticsCard extends StatelessWidget {
  const _MiniAnalyticsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.stroke),
      ),
      child: child,
    );
  }
}

class _RoleIndexCard extends StatelessWidget {
  const _RoleIndexCard({
    required this.roleIndex,
    required this.playerRole,
  });

  final double? roleIndex;
  final String playerRole;

  @override
  Widget build(BuildContext context) {
    final value = (roleIndex ?? 0).clamp(0, 100).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role Index',
          style: TextStyle(
            color: context.fg,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            color: context.fg,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Scored as ${_displayRole(playerRole)}',
          style: TextStyle(
            color: context.fgSub,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 62,
          width: double.infinity,
          child: CustomPaint(
            painter: _RoleIndexArcPainter(
              progress: value / 100,
              accent: context.accent,
              base: context.panel,
            ),
          ),
        ),
      ],
    );
  }
}

class _PercentileCard extends StatelessWidget {
  const _PercentileCard({
    required this.percentile,
    required this.playerRole,
    required this.city,
  });

  final PercentileData? percentile;
  final String playerRole;
  final String city;

  @override
  Widget build(BuildContext context) {
    if (percentile == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'City Rank',
            style: TextStyle(
              color: context.fg,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Icon(Icons.public_off_rounded, color: context.fgSub, size: 22),
          const SizedBox(height: 10),
          Text(
            'Not enough data in your city yet',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    final betterThan = (100 - percentile!.value).clamp(0, 100) / 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'City Rank',
          style: TextStyle(
            color: context.fg,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Top ${percentile!.value}%',
          style: TextStyle(
            color: context.fg,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'of ${_displayRole(playerRole).toLowerCase()}s',
          style: TextStyle(
            color: context.fg,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${city.isEmpty ? 'Your city' : city} · ${percentile!.comparedTo} players',
          style: TextStyle(
            color: context.fgSub,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: betterThan,
            backgroundColor: context.panel,
            valueColor: AlwaysStoppedAnimation<Color>(context.accent),
          ),
        ),
      ],
    );
  }
}

class _RoleIndexArcPainter extends CustomPainter {
  const _RoleIndexArcPainter({
    required this.progress,
    required this.accent,
    required this.base,
  });

  final double progress;
  final Color accent;
  final Color base;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 2, size.width, size.height * 1.9);
    const startAngle = math.pi * 0.85;
    const sweepAngle = math.pi * 1.3;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;

    stroke.color = base;
    canvas.drawArc(rect, startAngle, sweepAngle, false, stroke);

    stroke.color = accent;
    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle * progress.clamp(0, 1),
      false,
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _RoleIndexArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accent != accent ||
        oldDelegate.base != base;
  }
}

String _displayRole(String raw) {
  final normalized = raw.replaceAll('_', ' ').trim();
  if (normalized.isEmpty) return 'Player';
  return normalized
      .split(' ')
      .map((word) => word.isEmpty
          ? word
          : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
      .join(' ');
}
