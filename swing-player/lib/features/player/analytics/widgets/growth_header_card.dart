import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/widgets/profile_section_card.dart';
import '../models/growth_insights_model.dart';

class GrowthHeaderCard extends StatelessWidget {
  const GrowthHeaderCard({
    super.key,
    required this.insights,
    this.forceUnlocked = false,
  });

  final GrowthInsights insights;
  final bool forceUnlocked;

  @override
  Widget build(BuildContext context) {
    final archetype = insights.archetype;
    return ProfileSectionCard(
      title: 'Growth Snapshot',
      subtitle: 'Current form, playing identity and momentum.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (archetype != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _archetypeColor(archetype.label).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏏', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    archetype.label,
                    style: TextStyle(
                      color: _archetypeColor(archetype.label),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 18),
          Center(
            child: insights.locked && !forceUnlocked
                ? _LockedMomentumGauge(message: insights.upgradeMessage)
                : _MomentumGauge(value: insights.momentum ?? 0),
          ),
          if (archetype != null) ...[
            const SizedBox(height: 16),
            Text(
              archetype.description,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 13,
                fontStyle: FontStyle.italic,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MomentumGauge extends StatelessWidget {
  const _MomentumGauge({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 100).toDouble();
    return SizedBox(
      width: 140,
      height: 140,
      child: SfRadialGauge(
        axes: [
          RadialAxis(
            minimum: 0,
            maximum: 100,
            showTicks: false,
            showLabels: false,
            axisLineStyle: AxisLineStyle(
              thickness: 0.14,
              thicknessUnit: GaugeSizeUnit.factor,
              color: context.panel,
            ),
            pointers: [
              RangePointer(
                value: clamped,
                width: 0.14,
                sizeUnit: GaugeSizeUnit.factor,
                color: _momentumColor(clamped),
                cornerStyle: CornerStyle.bothCurve,
              ),
            ],
            annotations: [
              GaugeAnnotation(
                angle: 90,
                positionFactor: 0.08,
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      clamped.toStringAsFixed(1),
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Momentum',
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
    );
  }
}

class _LockedMomentumGauge extends StatelessWidget {
  const _LockedMomentumGauge({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.panel,
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_rounded, color: context.fgSub, size: 32),
          const SizedBox(height: 8),
          Text(
            'Locked',
            style: TextStyle(
              color: context.fg,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

Color _momentumColor(double value) {
  if (value > 70) return Colors.green;
  if (value >= 40) return Colors.amber;
  return Colors.red;
}

Color _archetypeColor(String label) {
  final normalized = label.toLowerCase();
  if (normalized.contains('clutch') || normalized.contains('assassin')) {
    return const Color(0xFF3F63FF);
  }
  if (normalized.contains('enforcer') || normalized.contains('pressure')) {
    return const Color(0xFF5E5CE6);
  }
  if (normalized.contains('war')) {
    return const Color(0xFF7F56D9);
  }
  if (normalized.contains('iron') || normalized.contains('guardian')) {
    return const Color(0xFF16A39A);
  }
  if (normalized.contains('anchor') || normalized.contains('steady')) {
    return const Color(0xFF2E9E5B);
  }
  return const Color(0xFFE38834);
}
