import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/rank_visual_theme.dart';
import '../../domain/profile_models.dart';

class EliteRadarChart extends StatelessWidget {
  const EliteRadarChart({
    super.key,
    required this.skillAxes,
    required this.rankTheme,
  });

  final List<PlayerSkillAxis> skillAxes;
  final RankVisualTheme rankTheme;

  @override
  Widget build(BuildContext context) {
    final lockedAxes = skillAxes.where((axis) => axis.isLocked).toList();
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.1,
          child: RadarChart(
            RadarChartData(
              radarShape: RadarShape.circle,
              dataSets: [
                RadarDataSet(
                  fillColor: rankTheme.primary.withValues(alpha: 0.2),
                  borderColor: rankTheme.primary,
                  entryRadius: 3,
                  dataEntries: skillAxes
                      .map((e) => RadarEntry(value: (e.value ?? 0).toDouble()))
                      .toList(),
                ),
              ],
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData: BorderSide(
                color: rankTheme.border.withValues(alpha: 0.3),
                width: 1,
              ),
              titlePositionPercentageOffset: 0.24,
              titleTextStyle: TextStyle(
                color: rankTheme.secondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              getTitle: (index, angle) {
                if (index >= skillAxes.length) {
                  return const RadarChartTitle(text: '');
                }
                return RadarChartTitle(
                  text: skillAxes[index].label.toUpperCase(),
                  angle: angle,
                );
              },
              tickCount: 5,
              ticksTextStyle:
                  const TextStyle(color: Colors.transparent, fontSize: 10),
              gridBorderData: BorderSide(
                color: rankTheme.border.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: skillAxes
              .map(
                (axis) => _SkillAxisChip(
                  axis: axis,
                  rankTheme: rankTheme,
                ),
              )
              .toList(),
        ),
        if (lockedAxes.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            lockedAxes.first.lockedText ?? 'No captain data yet',
            style: TextStyle(
              color: rankTheme.secondary.withValues(alpha: 0.76),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _SkillAxisChip extends StatelessWidget {
  const _SkillAxisChip({
    required this.axis,
    required this.rankTheme,
  });

  final PlayerSkillAxis axis;
  final RankVisualTheme rankTheme;

  @override
  Widget build(BuildContext context) {
    final value = axis.value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: axis.isLocked
            ? rankTheme.deep.withValues(alpha: 0.42)
            : rankTheme.deep.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: axis.isLocked
              ? rankTheme.border.withValues(alpha: 0.35)
              : rankTheme.border.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (axis.isLocked) ...[
            Icon(
              Icons.lock_outline_rounded,
              size: 14,
              color: rankTheme.secondary.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            axis.label,
            style: TextStyle(
              color: axis.isLocked
                  ? rankTheme.secondary.withValues(alpha: 0.7)
                  : rankTheme.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            axis.isLocked ? '--' : _formatAxisValue(value),
            style: TextStyle(
              color: axis.isLocked
                  ? rankTheme.secondary.withValues(alpha: 0.7)
                  : rankTheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatAxisValue(double? value) {
  if (value == null) return '--';
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}
