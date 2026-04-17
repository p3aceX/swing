import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/health_controller.dart';
import '../controller/health_integration_controller.dart';
import '../domain/health_integration_models.dart';
import '../domain/health_models.dart';
import 'performance_tab.dart';
import 'exercise_tab.dart';
import 'log_tab.dart';
import 'diet_screen.dart';
import 'widgets/metric_widgets.dart';

class HealthModuleScreen extends ConsumerStatefulWidget {
  const HealthModuleScreen({super.key});

  @override
  ConsumerState<HealthModuleScreen> createState() => _HealthModuleScreenState();
}

class _HealthModuleScreenState extends ConsumerState<HealthModuleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final healthState = ref.watch(healthDashboardProvider);
    final syncState = ref.watch(healthIntegrationProvider);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health',
              style: TextStyle(
                color: context.fg,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Diet · Fitness · Vitals',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          _SyncStatusButton(state: syncState),
          const SizedBox(width: 12),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: context.accent,
              unselectedLabelColor: context.fgSub,
              indicatorColor: context.accent,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: 'Diet'),
                Tab(text: 'Performance'),
                Tab(text: 'Training'),
                Tab(text: 'Vitals'),
                Tab(text: 'Log'),
              ],
            ),
          ),
        ),
      ),
      body: healthState.when(
        data: (dashboard) => TabBarView(
          controller: _tabController,
          children: [
            const DietScreen(),
            PerformanceTab(dashboard: dashboard),
            const ExerciseTab(), // This file should be renamed to training_tab.dart eventually
            _VitalsTab(dashboard: dashboard),
            const LogTab(),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load dashboard',
                  style: TextStyle(color: context.fg)),
              TextButton(
                onPressed: () =>
                    ref.read(healthDashboardProvider.notifier).load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncStatusButton extends ConsumerWidget {
  final HealthSyncState state;
  const _SyncStatusButton({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSyncing = state.status == HealthSyncStatus.syncing;
    final isError = state.status == HealthSyncStatus.error ||
        state.status == HealthSyncStatus.permissionsDenied;
    final label = switch (state.status) {
      HealthSyncStatus.synced => 'Synced',
      HealthSyncStatus.syncing => 'Syncing',
      HealthSyncStatus.permissionsDenied => 'Connect',
      HealthSyncStatus.error => 'Retry',
      HealthSyncStatus.disconnected => 'Connect',
    };
    final icon = switch (state.status) {
      HealthSyncStatus.synced => Icons.favorite_rounded,
      HealthSyncStatus.syncing => Icons.sync_rounded,
      HealthSyncStatus.permissionsDenied => Icons.lock_open_rounded,
      HealthSyncStatus.error => Icons.sync_problem_rounded,
      HealthSyncStatus.disconnected => Icons.health_and_safety_rounded,
    };
    final tint = isError
        ? context.warn
        : state.status == HealthSyncStatus.synced
            ? context.success
            : context.accent;

    return TextButton.icon(
      onPressed: () {
        if (state.status == HealthSyncStatus.disconnected ||
            state.status == HealthSyncStatus.permissionsDenied) {
          ref.read(healthIntegrationProvider.notifier).connect();
        } else {
          ref.read(healthIntegrationProvider.notifier).sync();
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: tint,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        backgroundColor: tint.withValues(alpha: 0.08),
      ),
      icon: isSyncing
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: tint,
              ),
            )
          : Icon(icon, color: tint, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

class _VitalsTab extends ConsumerWidget {
  final HealthDashboard dashboard;
  const _VitalsTab({required this.dashboard});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthData = ref.watch(recentHealthDataProvider);
    final manualBodyComp = ref.watch(manualBodyCompProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Body Composition'),
        _BodyCompCard(manualBodyComp: manualBodyComp),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Synced Vitals'),
        healthData.when(
          data: (payload) => _VitalsGrid(payload: payload),
          loading: () => const Center(
              child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          )),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _BodyCompCard extends ConsumerWidget {
  final BodyComposition? manualBodyComp;
  const _BodyCompCard({this.manualBodyComp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weight = manualBodyComp?.weight ?? 75.0;
    final height = manualBodyComp?.height ?? 175.0;
    final bmi = weight / ((height / 100) * (height / 100));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CompStat(
                  label: 'Weight',
                  value: weight.toStringAsFixed(1),
                  unit: 'kg'),
              _CompStat(
                  label: 'Height',
                  value: height.toInt().toString(),
                  unit: 'cm'),
              _CompStat(
                  label: 'BMI',
                  value: bmi.toStringAsFixed(1),
                  unit: _getBMICategory(bmi)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showEditBodyComp(context, ref, weight, height),
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text('Edit Measurements'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  void _showEditBodyComp(
      BuildContext context, WidgetRef ref, double weight, double height) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditBodyCompSheet(
        initialWeight: weight,
        initialHeight: height,
        onSave: (w, h) {
          ref
              .read(healthIntegrationProvider.notifier)
              .updateManualBodyComp(w, h);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _CompStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  const _CompStat(
      {required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                color: context.fgSub,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: context.fg, fontSize: 20, fontWeight: FontWeight.w900)),
        Text(unit, style: TextStyle(color: context.fgSub, fontSize: 11)),
      ],
    );
  }
}

class _VitalsGrid extends StatelessWidget {
  final HealthDataPayload payload;
  const _VitalsGrid({required this.payload});

  @override
  Widget build(BuildContext context) {
    double steps = 0;
    double calories = 0;
    double heartRate = 0;
    double restingHeartRate = 0;
    double hrv = 0;
    double weight = 0;

    for (var m in payload.metrics) {
      final type = m.type.toUpperCase();
      if (type.contains('STEPS')) {
        steps += m.value;
      }
      if (type.contains('ENERGY') || type.contains('CALORIES')) {
        calories += m.value;
      }
      if (type.contains('HEART_RATE') &&
          !type.contains('RESTING') &&
          !type.contains('VARIABILITY')) {
        heartRate = m.value;
      }
      if (type.contains('RESTING_HEART_RATE')) {
        restingHeartRate = m.value;
      }
      if (type.contains('VARIABILITY') || type.contains('HRV')) {
        hrv = m.value;
      }
      if (type.contains('WEIGHT')) {
        weight = m.value;
      }
    }

    final sleepMins =
        payload.sleep.fold(0, (sum, s) => sum + s.durationMinutes);
    final metrics = <_VitalData>[
      _VitalData(
        'Sleep',
        sleepMins > 0 ? '${sleepMins ~/ 60}h ${sleepMins % 60}m' : '--',
        '',
        Icons.nights_stay_rounded,
        Colors.indigo,
      ),
      _VitalData(
        'Steps',
        steps > 0 ? '${steps.toInt()}' : '--',
        'steps',
        Icons.directions_walk_rounded,
        Colors.teal,
      ),
      _VitalData(
        'Heart Rate',
        heartRate > 0 ? '${heartRate.toInt()}' : '--',
        'bpm',
        Icons.favorite_rounded,
        Colors.redAccent,
      ),
      _VitalData(
        'Resting HR',
        restingHeartRate > 0 ? '${restingHeartRate.toInt()}' : '--',
        'bpm',
        Icons.monitor_heart_rounded,
        Colors.pinkAccent,
      ),
      _VitalData(
        'HRV',
        hrv > 0 ? hrv.toStringAsFixed(hrv >= 10 ? 0 : 1) : '--',
        'ms',
        Icons.show_chart_rounded,
        Colors.deepPurpleAccent,
      ),
      _VitalData(
        'Calories',
        calories > 0 ? '${calories.toInt()}' : '--',
        'kcal',
        Icons.local_fire_department_rounded,
        Colors.orange,
      ),
      _VitalData(
        'Weight',
        weight > 0 ? weight.toStringAsFixed(1) : '--',
        'kg',
        Icons.monitor_weight_rounded,
        Colors.blue,
      ),
      _VitalData(
        'Workouts',
        payload.workouts.isNotEmpty ? '${payload.workouts.length}' : '--',
        'today',
        Icons.fitness_center_rounded,
        Colors.green,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final data = metrics[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(data.icon, color: data.color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.label,
                      style: TextStyle(
                          color: context.fgSub,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(data.value,
                      style: TextStyle(
                          color: context.fg,
                          fontSize: 22,
                          fontWeight: FontWeight.w900)),
                  if (data.unit.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(data.unit,
                        style: TextStyle(color: context.fgSub, fontSize: 11)),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                data.value == '--' ? 'No data yet' : 'Today',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VitalData {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  _VitalData(this.label, this.value, this.unit, this.icon, this.color);
}

class _EditBodyCompSheet extends StatefulWidget {
  final double initialWeight;
  final double initialHeight;
  final Function(double, double) onSave;

  const _EditBodyCompSheet(
      {required this.initialWeight,
      required this.initialHeight,
      required this.onSave});

  @override
  State<_EditBodyCompSheet> createState() => _EditBodyCompSheetState();
}

class _EditBodyCompSheetState extends State<_EditBodyCompSheet> {
  late double _weight;
  late double _height;

  @override
  void initState() {
    super.initState();
    _weight = widget.initialWeight;
    _height = widget.initialHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Update Body Stats',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          _MeasurementSlider(
            label: 'Weight',
            value: _weight,
            min: 40,
            max: 150,
            unit: 'kg',
            onChanged: (v) => setState(() => _weight = v),
          ),
          const SizedBox(height: 24),
          _MeasurementSlider(
            label: 'Height',
            value: _height,
            min: 120,
            max: 220,
            unit: 'cm',
            onChanged: (v) => setState(() => _height = v),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onSave(_weight, _height),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Save Stats',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasurementSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;

  const _MeasurementSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${value.toStringAsFixed(1)} $unit',
                style: TextStyle(
                    color: context.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: context.accent,
          inactiveColor: context.stroke,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
