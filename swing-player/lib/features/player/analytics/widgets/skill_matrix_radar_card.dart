import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/widgets/profile_section_card.dart';
import '../models/growth_insights_model.dart';

class SkillMatrixRadarCard extends StatelessWidget {
  const SkillMatrixRadarCard({
    super.key,
    required this.skillMatrix,
    required this.playerRole,
  });

  final SkillMatrix skillMatrix;
  final String playerRole;

  @override
  Widget build(BuildContext context) {
    final axes = _skillAxes(skillMatrix, playerRole);
    return ProfileSectionCard(
      title: 'Skill Matrix',
      subtitle: 'Based on last 10 matches',
      child: Column(
        children: [
          SizedBox(
            width: 260,
            height: 260,
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                tickCount: 4,
                ticksTextStyle:
                    const TextStyle(color: Colors.transparent, fontSize: 10),
                radarBorderData: BorderSide(
                  color: context.stroke.withValues(alpha: 0.55),
                ),
                gridBorderData: BorderSide(
                  color: context.stroke.withValues(alpha: 0.28),
                ),
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                titleTextStyle: TextStyle(
                  color: context.fgSub,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                titlePositionPercentageOffset: 0.18,
                getTitle: (index, angle) {
                  if (index >= axes.length) {
                    return const RadarChartTitle(text: '');
                  }
                  return RadarChartTitle(
                    text: axes[index].shortLabel,
                    angle: angle,
                  );
                },
                dataSets: [
                  RadarDataSet(
                    fillColor: context.accent.withValues(alpha: 0.25),
                    borderColor: context.accent,
                    entryRadius: 4,
                    borderWidth: 2.4,
                    dataEntries: axes
                        .map((axis) => RadarEntry(value: axis.value))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: axes
                .map(
                  (axis) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: axis.isMuted
                          ? context.panel.withValues(alpha: 0.4)
                          : context.panel.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: axis.isMuted
                            ? context.stroke.withValues(alpha: 0.45)
                            : context.stroke.withValues(alpha: 0.7),
                      ),
                    ),
                    child: Text(
                      '${axis.label} ${axis.display}',
                      style: TextStyle(
                        color: axis.isMuted ? context.fgSub : context.fg,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          if (axes
              .any((axis) => axis.label == 'Captaincy' && axis.isMuted)) ...[
            const SizedBox(height: 14),
            Text(
              'No captain data yet',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SkillAxisDisplay {
  const _SkillAxisDisplay({
    required this.label,
    required this.shortLabel,
    required this.value,
    required this.display,
    this.isMuted = false,
  });

  final String label;
  final String shortLabel;
  final double value;
  final String display;
  final bool isMuted;
}

List<_SkillAxisDisplay> _skillAxes(SkillMatrix matrix, String playerRole) {
  final normalizedRole = playerRole.toUpperCase();
  final bowlingMuted = normalizedRole == 'BATSMAN' ||
      normalizedRole == 'WK_BATSMAN' ||
      normalizedRole == 'WICKET_KEEPER' ||
      normalizedRole == 'WICKET_KEEPER_BATSMAN';

  return [
    _SkillAxisDisplay(
      label: 'Batting',
      shortLabel: 'Batting',
      value: matrix.batting.clamp(0, 100).toDouble(),
      display: matrix.batting.toStringAsFixed(1),
    ),
    _SkillAxisDisplay(
      label: 'Bowling',
      shortLabel: 'Bowling',
      value: bowlingMuted ? 0 : matrix.bowling.clamp(0, 100).toDouble(),
      display: bowlingMuted ? '--' : matrix.bowling.toStringAsFixed(1),
      isMuted: bowlingMuted,
    ),
    _SkillAxisDisplay(
      label: 'Fielding',
      shortLabel: 'Fielding',
      value: matrix.fielding.clamp(0, 100).toDouble(),
      display: matrix.fielding.toStringAsFixed(1),
    ),
    _SkillAxisDisplay(
      label: 'Fitness',
      shortLabel: 'Fitness',
      value: matrix.fitness.clamp(0, 100).toDouble(),
      display: matrix.fitness.toStringAsFixed(1),
    ),
    _SkillAxisDisplay(
      label: 'Clutch',
      shortLabel: 'Clutch',
      value: matrix.clutch.clamp(0, 100).toDouble(),
      display: matrix.clutch.toStringAsFixed(1),
    ),
    _SkillAxisDisplay(
      label: 'Consistency',
      shortLabel: 'Consistency',
      value: matrix.consistency.clamp(0, 100).toDouble(),
      display: matrix.consistency.toStringAsFixed(1),
    ),
    _SkillAxisDisplay(
      label: 'Captaincy',
      shortLabel: 'Captaincy',
      value: (matrix.captaincy ?? 0).clamp(0, 100).toDouble(),
      display: matrix.captaincy == null
          ? '--'
          : matrix.captaincy!.toStringAsFixed(1),
      isMuted: matrix.captaincy == null,
    ),
  ];
}
