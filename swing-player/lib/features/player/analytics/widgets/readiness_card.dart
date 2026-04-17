import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/widgets/profile_section_card.dart';
import '../models/growth_insights_model.dart';

class ReadinessCard extends StatelessWidget {
  const ReadinessCard({
    super.key,
    required this.readiness,
  });

  final ReadinessData? readiness;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Match Readiness',
      subtitle: 'Short-term signal before your next competitive load.',
      child: readiness == null
          ? _ReadinessEmptyState(
              onTap: () => context.push('/wellness-checkin'),
            )
          : Column(
              children: [
                SizedBox(
                  width: 220,
                  height: 132,
                  child: SfRadialGauge(
                    axes: [
                      RadialAxis(
                        minimum: 0,
                        maximum: 100,
                        startAngle: 180,
                        endAngle: 0,
                        showTicks: false,
                        showLabels: false,
                        axisLineStyle: const AxisLineStyle(
                          thickness: 0.18,
                          thicknessUnit: GaugeSizeUnit.factor,
                          cornerStyle: CornerStyle.bothFlat,
                        ),
                        ranges: [
                          GaugeRange(
                            startValue: 0,
                            endValue: 40,
                            color: context.danger,
                            sizeUnit: GaugeSizeUnit.factor,
                            startWidth: 0.18,
                            endWidth: 0.18,
                          ),
                          GaugeRange(
                            startValue: 40,
                            endValue: 70,
                            color: context.warn,
                            sizeUnit: GaugeSizeUnit.factor,
                            startWidth: 0.18,
                            endWidth: 0.18,
                          ),
                          GaugeRange(
                            startValue: 70,
                            endValue: 100,
                            color: context.success,
                            sizeUnit: GaugeSizeUnit.factor,
                            startWidth: 0.18,
                            endWidth: 0.18,
                          ),
                        ],
                        pointers: [
                          NeedlePointer(
                            value: readiness!.score.toDouble(),
                            needleLength: 0.62,
                            lengthUnit: GaugeSizeUnit.factor,
                            knobStyle: KnobStyle(
                              color: context.fg,
                              borderColor: context.bg,
                              borderWidth: 0.04,
                            ),
                            needleColor: context.fg,
                            tailStyle: TailStyle(
                              color: context.fg,
                              length: 0.14,
                              width: 4,
                            ),
                          ),
                        ],
                        annotations: [
                          GaugeAnnotation(
                            angle: 90,
                            positionFactor: 0.02,
                            widget: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${readiness!.score}%',
                                  style: TextStyle(
                                    color: context.fg,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'Match Readiness',
                                  style: TextStyle(
                                    color: context.fgSub,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ...readiness!.signals.take(4).map(
                      (signal) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Icon(
                              signal.positive
                                  ? Icons.check_circle_rounded
                                  : Icons.warning_amber_rounded,
                              color: signal.positive
                                  ? context.success
                                  : context.warn,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                signal.label,
                                style: TextStyle(
                                  color: context.fg,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
    );
  }
}

class _ReadinessEmptyState extends StatelessWidget {
  const _ReadinessEmptyState({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.panel.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.stroke.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Log your wellness to see your readiness score',
            style: TextStyle(
              color: context.fg,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sleep, soreness, stress, and pain/tightness are needed before your readiness signal can be computed.',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onTap,
            child: const Text('Log Wellness →'),
          ),
        ],
      ),
    );
  }
}
