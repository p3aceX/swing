import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/health_integration_controller.dart';
import '../domain/health_integration_models.dart';
import '../domain/health_models.dart';
import 'widgets/metric_widgets.dart';

class RecoveryTab extends ConsumerWidget {
  final HealthDashboard dashboard;
  const RecoveryTab({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthData = ref.watch(recentHealthDataProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Physiology Overview'),
        _RecoveryStatusHero(dashboard: dashboard),
        const SizedBox(height: 24),

        healthData.when(
          data: (payload) => _VitalsGrid(payload: payload),
          loading: () => const Center(child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          )),
          error: (e, _) => Center(child: Text('Error loading vitals: $e')),
        ),
        const SizedBox(height: 24),

        const SectionHeader(title: 'Activity Breakdown'),
        healthData.when(
          data: (payload) => _ActivitySnapshot(payload: payload),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _RecoveryStatusHero extends StatelessWidget {
  final HealthDashboard dashboard;
  const _RecoveryStatusHero({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HeroMetric(label: 'HRV', value: '64', unit: 'ms'),
              Container(width: 1, height: 40, color: context.stroke),
              _HeroMetric(label: 'Resting HR', value: '52', unit: 'bpm'),
              Container(width: 1, height: 40, color: context.stroke),
              _HeroMetric(label: 'Sleep', value: '7.5', unit: 'hrs'),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Physiological markers indicate a state of high readiness. Your heart rate variability is 12% above your 7-day baseline.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.fgSub, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  const _HeroMetric({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: context.fgSub, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: TextStyle(color: context.fg, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(width: 2),
            Text(unit, style: TextStyle(color: context.fgSub, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

class _VitalsGrid extends StatelessWidget {
  final HealthDataPayload payload;
  const _VitalsGrid({required this.payload});

  @override
  Widget build(BuildContext context) {
    // Basic aggregation
    double totalSteps = 0;
    double totalCals = 0;
    for (var m in payload.metrics) {
      if (m.type.contains('STEPS')) totalSteps += m.value;
      if (m.type.contains('CALORIES') || m.type.contains('ENERGY')) totalCals += m.value;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        HealthMetricCard(
          title: 'Steps Today',
          value: totalSteps > 0 ? '${totalSteps.toInt()}' : '--',
          subtitle: 'Active movement',
          icon: Icons.directions_walk_rounded,
          color: Colors.teal,
        ),
        HealthMetricCard(
          title: 'Active Energy',
          value: totalCals > 0 ? '${totalCals.toInt()}' : '--',
          subtitle: 'Calories burned',
          icon: Icons.local_fire_department_rounded,
          color: Colors.orange,
        ),
      ],
    );
  }
}

class _ActivitySnapshot extends StatelessWidget {
  final HealthDataPayload payload;
  const _ActivitySnapshot({required this.payload});

  @override
  Widget build(BuildContext context) {
    if (payload.workouts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.panel,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('No synced activity found for today.', textAlign: TextAlign.center),
      );
    }

    return Column(
      children: payload.workouts.map((w) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.stroke),
        ),
        child: Row(
          children: [
            Icon(Icons.watch_rounded, color: context.accent),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(w.type, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${w.durationMinutes} mins', style: TextStyle(color: context.fgSub, fontSize: 12)),
                ],
              ),
            ),
            Text(
              '${w.timestamp.hour}:${w.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: context.fgSub, fontSize: 12),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
