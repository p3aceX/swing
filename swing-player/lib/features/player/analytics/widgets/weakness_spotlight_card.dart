import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/widgets/profile_section_card.dart';
import '../models/growth_insights_model.dart';

class WeaknessSpotlightCard extends StatelessWidget {
  const WeaknessSpotlightCard({
    super.key,
    required this.skillMatrix,
    required this.weakness,
    required this.playerRole,
  });

  final SkillMatrix? skillMatrix;
  final WeaknessData? weakness;
  final String playerRole;

  @override
  Widget build(BuildContext context) {
    final axisRows = _buildAxisRows(skillMatrix, playerRole, weakness?.axis);

    return ProfileSectionCard(
      title: 'Biggest Opportunity',
      subtitle: 'Where the fastest next gain is likely to come from.',
      trailing: weakness == null
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: context.danger.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _displayAxis(weakness!.axis),
                style: TextStyle(
                  color: context.danger,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            weakness?.insight ??
                'Play more verified matches to reveal your biggest growth opportunity.',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 13,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 18),
          ...axisRows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 94,
                    child: Text(
                      row.label,
                      style: TextStyle(
                        color: row.isWeakest ? context.danger : context.fgSub,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: (row.score / 100).clamp(0.0, 1.0),
                        backgroundColor: context.panel,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          row.isWeakest
                              ? context.danger
                              : context.accent.withValues(alpha: 0.78),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 34,
                    child: Text(
                      row.score.toStringAsFixed(1),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: row.isWeakest ? context.danger : context.fg,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if ((weakness?.drills ?? const []).isNotEmpty) ...[
            Divider(
              height: 28,
              color: context.stroke.withValues(alpha: 0.55),
            ),
            Text(
              'Recommended Drills',
              style: TextStyle(
                color: context.fg,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ...weakness!.drills.take(3).map(
                  (drill) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: context.panel.withValues(alpha: 0.58),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: context.stroke.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _MetaChip(label: _prettyEnum(drill.category)),
                              _MetaChip(label: _prettyEnum(drill.difficulty)),
                              _MetaChip(
                                label:
                                    '${drill.targetQuantity} ${drill.targetUnit.toLowerCase()}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            drill.name,
                            style: TextStyle(
                              color: context.fg,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (drill.description.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              drill.description,
                              style: TextStyle(
                                color: context.fgSub,
                                fontSize: 12,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.stroke.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: context.fgSub,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AxisRow {
  const _AxisRow({
    required this.label,
    required this.score,
    required this.isWeakest,
  });

  final String label;
  final double score;
  final bool isWeakest;
}

List<_AxisRow> _buildAxisRows(
  SkillMatrix? matrix,
  String playerRole,
  String? weakestAxis,
) {
  if (matrix == null) {
    return const [
      _AxisRow(label: 'Batting', score: 0, isWeakest: false),
      _AxisRow(label: 'Bowling', score: 0, isWeakest: false),
      _AxisRow(label: 'Fielding', score: 0, isWeakest: false),
      _AxisRow(label: 'Fitness', score: 0, isWeakest: false),
      _AxisRow(label: 'Clutch', score: 0, isWeakest: false),
      _AxisRow(label: 'Consistency', score: 0, isWeakest: false),
    ];
  }

  final normalizedRole = playerRole.toUpperCase();
  final hideBowling = normalizedRole == 'BATSMAN' ||
      normalizedRole == 'WK_BATSMAN' ||
      normalizedRole == 'WICKET_KEEPER' ||
      normalizedRole == 'WICKET_KEEPER_BATSMAN';

  final rows = <_AxisRow>[
    _AxisRow(
      label: 'Batting',
      score: matrix.batting,
      isWeakest: weakestAxis == 'batting',
    ),
    _AxisRow(
      label: 'Bowling',
      score: hideBowling ? 0 : matrix.bowling,
      isWeakest: weakestAxis == 'bowling',
    ),
    _AxisRow(
      label: 'Fielding',
      score: matrix.fielding,
      isWeakest: weakestAxis == 'fielding',
    ),
    _AxisRow(
      label: 'Fitness',
      score: matrix.fitness,
      isWeakest: weakestAxis == 'fitness',
    ),
    _AxisRow(
      label: 'Clutch',
      score: matrix.clutch,
      isWeakest: weakestAxis == 'clutch',
    ),
    _AxisRow(
      label: 'Consistency',
      score: matrix.consistency,
      isWeakest: weakestAxis == 'consistency',
    ),
  ];

  if (matrix.captaincy != null) {
    rows.add(
      _AxisRow(
        label: 'Captaincy',
        score: matrix.captaincy!,
        isWeakest: weakestAxis == 'captaincy',
      ),
    );
  }

  return rows;
}

String _displayAxis(String axis) {
  if (axis.isEmpty) return 'Opportunity';
  return '${axis[0].toUpperCase()}${axis.substring(1).toLowerCase()}';
}

String _prettyEnum(String value) {
  return value
      .split('_')
      .map((part) => part.isEmpty
          ? part
          : '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
      .join(' ');
}
