import 'package:flutter/material.dart';
import '../../domain/rank_visual_theme.dart';
import '../../domain/profile_models.dart';

class ElitePrecisionCard extends StatelessWidget {
  const ElitePrecisionCard({
    super.key,
    required this.elite,
    required this.rankTheme,
  });

  final BattingPrecision elite;
  final RankVisualTheme rankTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: rankTheme.deep,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: rankTheme.border.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: rankTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'PRECISION ANALYTICS',
                style: TextStyle(
                  color: rankTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'DEATH OVERS SR',
                  value: elite.deathOversSR.toStringAsFixed(1),
                  rankTheme: rankTheme,
                  isHighlight: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  label: 'VS SPIN SR',
                  value: elite.spinSR.toStringAsFixed(1),
                  rankTheme: rankTheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  label: 'VS PACE SR',
                  value: elite.paceSR.toStringAsFixed(1),
                  rankTheme: rankTheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.rankTheme,
    this.isHighlight = false,
  });

  final String label;
  final String value;
  final RankVisualTheme rankTheme;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isHighlight ? rankTheme.primary.withOpacity(0.1) : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? rankTheme.primary : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: rankTheme.secondary.withOpacity(0.6),
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
