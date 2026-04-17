import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../controller/health_controller.dart';
import '../controller/health_integration_controller.dart';
import '../domain/health_integration_models.dart';
import '../domain/health_models.dart';
import 'widgets/metric_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  VITALS Screen — Health Intelligence Dashboard
// ─────────────────────────────────────────────────────────────────────────────

class VitalsScreen extends ConsumerWidget {
  const VitalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(healthIntegrationProvider);
    final healthState = ref.watch(healthDashboardProvider);
    final healthData = ref.watch(recentHealthDataProvider);
    final manualBodyComp = ref.watch(manualBodyCompProvider);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 48,
        titleSpacing: 16,
        title: Text(
          'Health · recovery · body composition',
          style: TextStyle(
            color: context.fgSub,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          _SyncBtn(state: syncState, ref: ref),
          const SizedBox(width: 12),
        ],
      ),
      body: healthState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monitor_heart_outlined,
                  size: 48, color: context.fgSub),
              const SizedBox(height: 16),
              Text('Could not load vitals',
                  style: TextStyle(color: context.fgSub)),
              TextButton(
                onPressed: () => ref.invalidate(healthDashboardProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (_) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            // Body composition card
            const SectionHeader(title: 'Body Composition'),
            const SizedBox(height: 10),
            _BodyCompCard(manualBodyComp: manualBodyComp, ref: ref),
            const SizedBox(height: 24),
            // Synced vitals grid
            const SectionHeader(title: 'Synced Vitals'),
            const SizedBox(height: 10),
            healthData.when(
              data: (payload) => _VitalsGrid(payload: payload),
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Center(
                child: Text('Error loading vitals data',
                    style: TextStyle(color: context.fgSub)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Sync button ───────────────────────────────────────────────────────────────

class _SyncBtn extends StatelessWidget {
  const _SyncBtn({required this.state, required this.ref});
  final HealthSyncState state;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        backgroundColor: tint.withValues(alpha: 0.08),
      ),
      icon: isSyncing
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: tint),
            )
          : Icon(icon, color: tint, size: 18),
      label: Text(label,
          style:
              const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}

// ── Body composition card ─────────────────────────────────────────────────────

class _BodyCompCard extends StatelessWidget {
  const _BodyCompCard({required this.manualBodyComp, required this.ref});
  final BodyComposition? manualBodyComp;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final weight = manualBodyComp?.weight ?? 75.0;
    final height = manualBodyComp?.height ?? 175.0;
    final bmi = weight / ((height / 100) * (height / 100));
    final bodyFat = manualBodyComp?.bodyFatPercent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        children: [
          // ── Primary 3-stat row ─────────────────────────────────────────
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
                  unit: _bmiCategory(bmi)),
            ],
          ),
          // ── Body fat row (conditional) ─────────────────────────────────
          if (bodyFat != null) ...[
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: context.accent.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: context.accent.withValues(alpha: 0.18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.monitor_weight_outlined,
                          color: context.accent, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Body Fat',
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${bodyFat.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  _editSheet(context, ref, weight, height, bodyFat),
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

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  void _editSheet(BuildContext context, WidgetRef ref, double weight,
      double height, double? bodyFat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditBodyCompSheet(
        initialWeight: weight,
        initialHeight: height,
        initialBodyFat: bodyFat,
        onSave: (w, h, bf) {
          ref
              .read(healthIntegrationProvider.notifier)
              .updateManualBodyComp(w, h, bodyFatPercent: bf);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _CompStat extends StatelessWidget {
  const _CompStat(
      {required this.label, required this.value, required this.unit});
  final String label;
  final String value;
  final String unit;

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
                color: context.fg,
                fontSize: 20,
                fontWeight: FontWeight.w900)),
        Text(unit, style: TextStyle(color: context.fgSub, fontSize: 11)),
      ],
    );
  }
}

// ── Vitals grid ───────────────────────────────────────────────────────────────

class _VitalsGrid extends StatelessWidget {
  const _VitalsGrid({required this.payload});
  final HealthDataPayload payload;

  @override
  Widget build(BuildContext context) {
    double steps = 0,
        calories = 0,
        heartRate = 0,
        restingHR = 0,
        hrv = 0,
        weight = 0;

    for (var m in payload.metrics) {
      final type = m.type.toUpperCase();
      if (type.contains('STEPS')) steps += m.value;
      if (type.contains('ENERGY') || type.contains('CALORIES')) {
        calories += m.value;
      }
      if (type.contains('HEART_RATE') &&
          !type.contains('RESTING') &&
          !type.contains('VARIABILITY')) {
        heartRate = m.value;
      }
      if (type.contains('RESTING_HEART_RATE')) restingHR = m.value;
      if (type.contains('VARIABILITY') || type.contains('HRV')) hrv = m.value;
      if (type.contains('WEIGHT')) weight = m.value;
    }

    final sleepMins =
        payload.sleep.fold(0, (sum, s) => sum + s.durationMinutes);

    final metrics = <_VD>[
      _VD('Sleep',
          sleepMins > 0 ? '${sleepMins ~/ 60}h ${sleepMins % 60}m' : '--', '',
          Icons.nights_stay_rounded, Colors.indigo),
      _VD('Steps', steps > 0 ? '${steps.toInt()}' : '--', 'steps',
          Icons.directions_walk_rounded, Colors.teal),
      _VD('Heart Rate', heartRate > 0 ? '${heartRate.toInt()}' : '--', 'bpm',
          Icons.favorite_rounded, Colors.redAccent),
      _VD('Resting HR', restingHR > 0 ? '${restingHR.toInt()}' : '--', 'bpm',
          Icons.monitor_heart_rounded, Colors.pinkAccent),
      _VD('HRV',
          hrv > 0 ? hrv.toStringAsFixed(hrv >= 10 ? 0 : 1) : '--', 'ms',
          Icons.show_chart_rounded, Colors.deepPurpleAccent),
      _VD('Calories', calories > 0 ? '${calories.toInt()}' : '--', 'kcal',
          Icons.local_fire_department_rounded, Colors.orange),
      _VD('Weight', weight > 0 ? weight.toStringAsFixed(1) : '--', 'kg',
          Icons.monitor_weight_rounded, Colors.blue),
      _VD('Workouts',
          payload.workouts.isNotEmpty ? '${payload.workouts.length}' : '--',
          'today', Icons.fitness_center_rounded, Colors.green),
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
      itemBuilder: (context, i) {
        final d = metrics[i];
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
              Row(children: [
                Icon(d.icon, color: d.color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(d.label,
                      style: TextStyle(
                          color: context.fgSub,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(d.value,
                      style: TextStyle(
                          color: context.fg,
                          fontSize: 22,
                          fontWeight: FontWeight.w900)),
                  if (d.unit.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(d.unit,
                        style:
                            TextStyle(color: context.fgSub, fontSize: 11)),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                d.value == '--' ? 'No data yet' : 'Today',
                style: TextStyle(
                    color: context.fgSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VD {
  const _VD(this.label, this.value, this.unit, this.icon, this.color);
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
}

// ── Edit body comp sheet ──────────────────────────────────────────────────────

class _EditBodyCompSheet extends StatefulWidget {
  const _EditBodyCompSheet({
    required this.initialWeight,
    required this.initialHeight,
    this.initialBodyFat,
    required this.onSave,
  });
  final double initialWeight;
  final double initialHeight;
  final double? initialBodyFat;
  // weight, height, optional body fat %
  final void Function(double, double, double?) onSave;

  @override
  State<_EditBodyCompSheet> createState() => _EditBodyCompSheetState();
}

class _EditBodyCompSheetState extends State<_EditBodyCompSheet> {
  late double _weight;
  late double _height;
  bool _bodyFatEnabled = false;
  late double _bodyFat;

  @override
  void initState() {
    super.initState();
    _weight = widget.initialWeight;
    _height = widget.initialHeight;
    _bodyFatEnabled = widget.initialBodyFat != null;
    _bodyFat = widget.initialBodyFat ?? 18.0;
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
          Text(
            'Update Body Stats',
            style: TextStyle(
                color: context.fg, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          _Slider(
            label: 'Weight',
            value: _weight,
            min: 40,
            max: 150,
            unit: 'kg',
            onChanged: (v) => setState(() => _weight = v),
          ),
          const SizedBox(height: 24),
          _Slider(
            label: 'Height',
            value: _height,
            min: 120,
            max: 220,
            unit: 'cm',
            onChanged: (v) => setState(() => _height = v),
          ),
          const SizedBox(height: 24),
          // ── Optional body fat toggle ─────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _bodyFatEnabled = !_bodyFatEnabled),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _bodyFatEnabled
                    ? context.accent.withValues(alpha: 0.08)
                    : context.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _bodyFatEnabled
                      ? context.accent.withValues(alpha: 0.3)
                      : context.stroke,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.monitor_weight_outlined,
                    color: _bodyFatEnabled ? context.accent : context.fgSub,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Body Fat %',
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Optional — more precise than BMI for athletes',
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _bodyFatEnabled,
                    onChanged: (v) => setState(() => _bodyFatEnabled = v),
                    activeColor: context.accent,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
          ),
          // Body fat slider (visible when enabled)
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: _bodyFatEnabled
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: _Slider(
                      label: 'Body Fat',
                      value: _bodyFat,
                      min: 4,
                      max: 45,
                      unit: '%',
                      onChanged: (v) => setState(() => _bodyFat = v),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onSave(
                _weight,
                _height,
                _bodyFatEnabled ? _bodyFat : null,
              ),
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

class _Slider extends StatelessWidget {
  const _Slider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    TextStyle(color: context.fg, fontWeight: FontWeight.bold)),
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
