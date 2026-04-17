import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/presentation/widgets/profile_section_card.dart';
import '../controller/elite_controller.dart';
import '../domain/elite_models.dart';

String _apiDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

class ApexExecuteTab extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const ApexExecuteTab({super.key, this.initialDate});

  @override
  ConsumerState<ApexExecuteTab> createState() => _ApexExecuteTabState();
}

class _ApexExecuteTabState extends ConsumerState<ApexExecuteTab> {
  late final DateTime _selectedDate;
  late final String _dateKey;

  final _oneThingCtrl = TextEditingController();
  final _wellCtrl = TextEditingController();
  final _badlyCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  int _nets = 0;
  int _drills = 0;
  int _fitness = 0;
  int _recovery = 0;
  double _sleep = 0;
  double _hydration = 0;
  String _seedHash = '';

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _dateKey = _apiDate(_selectedDate);
  }

  @override
  void dispose() {
    _oneThingCtrl.dispose();
    _wellCtrl.dispose();
    _badlyCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(apexDayLogProvider(_dateKey));
  }

  void _seedFromLog(ApexDayLog log) {
    final hash = [
      log.id,
      log.date,
      log.weekday,
      '${log.isLocked}',
      '${log.executionScore ?? -1}',
      log.oneThingToday ?? '',
      log.execution.actualNetsMinutes,
      log.execution.actualDrillsMinutes,
      log.execution.actualFitnessMinutes,
      log.execution.actualRecoveryMinutes,
      '${log.execution.actualSleepHours ?? -1}',
      '${log.execution.actualHydrationLiters ?? -1}',
      log.execution.whatDidWell ?? '',
      log.execution.whatDidBadly ?? '',
      log.execution.note ?? '',
    ].join('|');

    if (_seedHash == hash) return;
    _seedHash = hash;

    _oneThingCtrl.text = (log.oneThingToday ?? '').trim();
    _wellCtrl.text = (log.execution.whatDidWell ?? '').trim();
    _badlyCtrl.text = (log.execution.whatDidBadly ?? '').trim();
    _noteCtrl.text = (log.execution.note ?? '').trim();

    _nets = log.execution.actualNetsMinutes > 0
        ? log.execution.actualNetsMinutes
        : log.plan.netsMinutes;
    _drills = log.execution.actualDrillsMinutes > 0
        ? log.execution.actualDrillsMinutes
        : log.plan.drillsMinutes;
    _fitness = log.execution.actualFitnessMinutes > 0
        ? log.execution.actualFitnessMinutes
        : log.plan.fitnessMinutes;
    _recovery = log.execution.actualRecoveryMinutes > 0
        ? log.execution.actualRecoveryMinutes
        : log.plan.recoveryMinutes;
    _sleep = log.execution.actualSleepHours ?? log.plan.sleepTargetHours;
    _hydration =
        log.execution.actualHydrationLiters ?? log.plan.hydrationTargetLiters;
  }

  Future<void> _saveOneThing(ApexDayLog log) async {
    if (log.isLocked) return;
    final updated =
        await ref.read(apexDayPlanControllerProvider.notifier).update(
              _dateKey,
              ApexDayPlanPatch(oneThingToday: _oneThingCtrl.text.trim()),
            );
    if (!mounted) return;
    if (updated != null) {
      ref.invalidate(apexDayLogProvider(_dateKey));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Focus saved'),
          backgroundColor: context.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final error = _extractError(ref.read(apexDayPlanControllerProvider));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: context.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _submit(ApexDayLog log) async {
    if (log.isLocked) return;
    final payload = ApexDayExecutionSubmit(
      actualNetsMinutes: _nets,
      actualDrillsMinutes: _drills,
      actualFitnessMinutes: _fitness,
      actualRecoveryMinutes: _recovery,
      actualSleepHours: _sleep,
      actualHydrationLiters: _hydration,
      whatDidWell: _trimOrNull(_wellCtrl.text),
      whatDidBadly: _trimOrNull(_badlyCtrl.text),
      note: _trimOrNull(_noteCtrl.text),
    );

    final updated = await ref
        .read(apexDayExecutionControllerProvider.notifier)
        .submit(_dateKey, payload);

    if (!mounted) return;
    if (updated != null) {
      ref.read(journaledTodayProvider.notifier).state = true;
      ref.invalidate(apexDayLogProvider(_dateKey));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Execution submitted'),
          backgroundColor: context.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final error = _extractError(ref.read(apexDayExecutionControllerProvider));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: context.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayAsync = ref.watch(apexDayLogProvider(_dateKey));
    final isSavingFocus = ref.watch(apexDayPlanControllerProvider).isLoading;
    final isSubmitting =
        ref.watch(apexDayExecutionControllerProvider).isLoading;

    return dayAsync.when(
      loading: () => const _ExecuteLoadingState(),
      error: (error, _) => _ExecuteErrorState(
        message: '$error',
        onRetry: () => ref.invalidate(apexDayLogProvider(_dateKey)),
      ),
      data: (log) {
        _seedFromLog(log);
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
            children: [
              _ExecuteHeader(date: _selectedDate, weekday: log.weekday),
              const SizedBox(height: 14),
              _TodayPlanBlock(plan: log.plan),
              const SizedBox(height: 14),
              _OneThingBlock(
                controller: _oneThingCtrl,
                locked: log.isLocked,
                isSaving: isSavingFocus,
                onSave: () => _saveOneThing(log),
              ),
              const SizedBox(height: 14),
              _ExecutionBlock(
                locked: log.isLocked,
                plan: log.plan,
                nets: _nets,
                drills: _drills,
                fitness: _fitness,
                recovery: _recovery,
                sleep: _sleep,
                hydration: _hydration,
                onNetsChanged: (v) => setState(() => _nets = v),
                onDrillsChanged: (v) => setState(() => _drills = v),
                onFitnessChanged: (v) => setState(() => _fitness = v),
                onRecoveryChanged: (v) => setState(() => _recovery = v),
                onSleepChanged: (v) => setState(() => _sleep = v),
                onHydrationChanged: (v) => setState(() => _hydration = v),
              ),
              const SizedBox(height: 14),
              _ReflectionBlock(
                locked: log.isLocked,
                whatDidWell: _wellCtrl,
                whatDidBadly: _badlyCtrl,
                note: _noteCtrl,
              ),
              const SizedBox(height: 14),
              _PlanVsExecutionBlock(score: log.executionScore),
              const SizedBox(height: 14),
              _SubmitBlock(
                locked: log.isLocked,
                isSubmitting: isSubmitting,
                onSubmit: () => _submit(log),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExecuteHeader extends StatelessWidget {
  final DateTime date;
  final String weekday;

  const _ExecuteHeader({
    required this.date,
    required this.weekday,
  });

  @override
  Widget build(BuildContext context) {
    final day = weekday.trim().isNotEmpty ? weekday.trim() : _weekdayCode(date);
    return ProfileSectionCard(
      title: 'Execute',
      subtitle: 'Daily journal for planned work.',
      trailing: Text(
        day,
        style: TextStyle(
          color: context.accent,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      child: Text(
        _humanDate(date),
        style: TextStyle(
          color: context.fg,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _TodayPlanBlock extends StatelessWidget {
  final ApexDayPlan plan;

  const _TodayPlanBlock({required this.plan});

  @override
  Widget build(BuildContext context) {
    final plannedActivityItems = <_PlanListItem>[
      if (plan.netsMinutes > 0)
        _PlanListItem(
          icon: Icons.sports_cricket_rounded,
          label: 'Nets',
          valueText: '${plan.netsMinutes}m',
        ),
      if (plan.drillsMinutes > 0)
        _PlanListItem(
          icon: Icons.adjust_rounded,
          label: 'Skill Work',
          valueText: '${plan.drillsMinutes}m',
        ),
      if (plan.fitnessMinutes > 0)
        _PlanListItem(
          icon: Icons.fitness_center_rounded,
          label: 'Conditioning',
          valueText: '${plan.fitnessMinutes}m',
        ),
      if (plan.recoveryMinutes > 0)
        _PlanListItem(
          icon: Icons.favorite_rounded,
          label: 'Recovery',
          valueText: '${plan.recoveryMinutes}m',
        ),
    ];
    final hasWellnessTargets =
        plan.sleepTargetHours > 0 || plan.hydrationTargetLiters > 0;

    return ProfileSectionCard(
      title: "Today's Plan",
      subtitle: 'Plan inherited from your weekly structure.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plannedActivityItems.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'No workload planned today.',
                style: TextStyle(color: context.fgSub, fontSize: 12.5),
              ),
            ),
          for (final item in plannedActivityItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PlanListRow(item: item),
            ),
          if (hasWellnessTargets) ...[
            if (plannedActivityItems.isNotEmpty) const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (plan.sleepTargetHours > 0)
                  _MinimalChip(
                    icon: Icons.bedtime_rounded,
                    label: 'Sleep ${_fmt(plan.sleepTargetHours)}h',
                  ),
                if (plan.hydrationTargetLiters > 0)
                  _MinimalChip(
                    icon: Icons.water_drop_rounded,
                    label: 'Hydration ${_fmt(plan.hydrationTargetLiters)}L',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _OneThingBlock extends StatelessWidget {
  final TextEditingController controller;
  final bool locked;
  final bool isSaving;
  final VoidCallback onSave;

  const _OneThingBlock({
    required this.controller,
    required this.locked,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'One Thing Today',
      subtitle: 'Your single daily focus.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!locked)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Set one clear focus before final submit.',
                style: TextStyle(color: context.fgSub, fontSize: 12),
              ),
            ),
          TextField(
            controller: controller,
            enabled: !locked,
            maxLines: 2,
            style: TextStyle(color: context.fg, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Set your focus for today',
              hintStyle: TextStyle(color: context.fgSub),
              filled: true,
              fillColor: context.panel,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.stroke),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.accent),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.stroke),
              ),
            ),
          ),
          if (!locked) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: isSaving ? null : onSave,
                icon: isSaving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded, size: 16),
                label: const Text('Save Focus'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExecutionBlock extends StatelessWidget {
  final bool locked;
  final ApexDayPlan plan;
  final int nets;
  final int drills;
  final int fitness;
  final int recovery;
  final double sleep;
  final double hydration;
  final ValueChanged<int> onNetsChanged;
  final ValueChanged<int> onDrillsChanged;
  final ValueChanged<int> onFitnessChanged;
  final ValueChanged<int> onRecoveryChanged;
  final ValueChanged<double> onSleepChanged;
  final ValueChanged<double> onHydrationChanged;

  const _ExecutionBlock({
    required this.locked,
    required this.plan,
    required this.nets,
    required this.drills,
    required this.fitness,
    required this.recovery,
    required this.sleep,
    required this.hydration,
    required this.onNetsChanged,
    required this.onDrillsChanged,
    required this.onFitnessChanged,
    required this.onRecoveryChanged,
    required this.onSleepChanged,
    required this.onHydrationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controls = <Widget>[
      if (plan.netsMinutes > 0)
        _JournalExecutionSliderRow(
          icon: Icons.sports_cricket_rounded,
          label: 'Nets',
          targetText: 'Plan ${plan.netsMinutes}m',
          valueText: '${nets}m',
          value: nets.toDouble(),
          min: 0,
          max: _maxForMinutes(plan.netsMinutes),
          divisions: (_maxForMinutes(plan.netsMinutes) / 5).round(),
          progress: _progress(nets.toDouble(), plan.netsMinutes.toDouble()),
          locked: locked,
          onChanged: (v) => onNetsChanged(v.round()),
        ),
      if (plan.drillsMinutes > 0)
        _JournalExecutionSliderRow(
          icon: Icons.adjust_rounded,
          label: 'Skill Work',
          targetText: 'Plan ${plan.drillsMinutes}m',
          valueText: '${drills}m',
          value: drills.toDouble(),
          min: 0,
          max: _maxForMinutes(plan.drillsMinutes),
          divisions: (_maxForMinutes(plan.drillsMinutes) / 5).round(),
          progress: _progress(drills.toDouble(), plan.drillsMinutes.toDouble()),
          locked: locked,
          onChanged: (v) => onDrillsChanged(v.round()),
        ),
      if (plan.fitnessMinutes > 0)
        _JournalExecutionSliderRow(
          icon: Icons.fitness_center_rounded,
          label: 'Conditioning',
          targetText: 'Plan ${plan.fitnessMinutes}m',
          valueText: '${fitness}m',
          value: fitness.toDouble(),
          min: 0,
          max: _maxForMinutes(plan.fitnessMinutes),
          divisions: (_maxForMinutes(plan.fitnessMinutes) / 5).round(),
          progress:
              _progress(fitness.toDouble(), plan.fitnessMinutes.toDouble()),
          locked: locked,
          onChanged: (v) => onFitnessChanged(v.round()),
        ),
      if (plan.recoveryMinutes > 0)
        _JournalExecutionSliderRow(
          icon: Icons.favorite_rounded,
          label: 'Recovery',
          targetText: 'Plan ${plan.recoveryMinutes}m',
          valueText: '${recovery}m',
          value: recovery.toDouble(),
          min: 0,
          max: _maxForMinutes(plan.recoveryMinutes),
          divisions: (_maxForMinutes(plan.recoveryMinutes) / 5).round(),
          progress:
              _progress(recovery.toDouble(), plan.recoveryMinutes.toDouble()),
          locked: locked,
          onChanged: (v) => onRecoveryChanged(v.round()),
        ),
      if (plan.sleepTargetHours > 0)
        _JournalExecutionSliderRow(
          icon: Icons.bedtime_rounded,
          label: 'Sleep',
          targetText: 'Plan ${_fmt(plan.sleepTargetHours)}h',
          valueText: '${_fmt(sleep)}h',
          value: sleep,
          min: 0,
          max: _maxForHours(plan.sleepTargetHours),
          divisions: (_maxForHours(plan.sleepTargetHours) * 2).round(),
          progress: _progress(sleep, plan.sleepTargetHours),
          locked: locked,
          onChanged: (v) => onSleepChanged((v * 2).roundToDouble() / 2),
        ),
      if (plan.hydrationTargetLiters > 0)
        _JournalExecutionSliderRow(
          icon: Icons.water_drop_rounded,
          label: 'Hydration',
          targetText: 'Plan ${_fmt(plan.hydrationTargetLiters)}L',
          valueText: '${_fmt(hydration)}L',
          value: hydration,
          min: 0,
          max: _maxForHydration(plan.hydrationTargetLiters),
          divisions: (_maxForHydration(plan.hydrationTargetLiters) * 2).round(),
          progress: _progress(hydration, plan.hydrationTargetLiters),
          locked: locked,
          onChanged: (v) => onHydrationChanged((v * 2).roundToDouble() / 2),
        ),
    ];

    return ProfileSectionCard(
      title: 'Execution',
      subtitle: 'Log only the activities planned for today.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: controls.isEmpty
            ? [
                Text(
                  'No planned activity targets for today. You can still add reflection and submit.',
                  style: TextStyle(color: context.fgSub, fontSize: 12.5),
                ),
              ]
            : controls
                .map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: w,
                  ),
                )
                .toList(growable: false),
      ),
    );
  }
}

class _ReflectionBlock extends StatelessWidget {
  final bool locked;
  final TextEditingController whatDidWell;
  final TextEditingController whatDidBadly;
  final TextEditingController note;

  const _ReflectionBlock({
    required this.locked,
    required this.whatDidWell,
    required this.whatDidBadly,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Reflection',
      subtitle: 'Daily review before lock.',
      child: Column(
        children: [
          _ReflectionField(
            label: 'What went well?',
            controller: whatDidWell,
            locked: locked,
          ),
          const SizedBox(height: 10),
          _ReflectionField(
            label: 'What went badly?',
            controller: whatDidBadly,
            locked: locked,
          ),
          const SizedBox(height: 10),
          _ReflectionField(
            label: 'Note (optional)',
            controller: note,
            locked: locked,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

class _PlanVsExecutionBlock extends StatelessWidget {
  final double? score;

  const _PlanVsExecutionBlock({required this.score});

  @override
  Widget build(BuildContext context) {
    final pct = score?.clamp(0, 100).round();
    return ProfileSectionCard(
      title: 'Plan vs Execution',
      subtitle: 'Daily completion score.',
      child: pct == null
          ? Row(
              children: [
                Icon(Icons.hourglass_empty_rounded,
                    color: context.fgSub, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Pending submission',
                  style: TextStyle(color: context.fgSub, fontSize: 13),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$pct%',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _scoreColor(context, pct).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: _scoreColor(context, pct)
                              .withValues(alpha: 0.32)),
                    ),
                    child: Text(
                      _scoreLabel(pct),
                      style: TextStyle(
                        color: _scoreColor(context, pct),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SubmitBlock extends StatelessWidget {
  final bool locked;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _SubmitBlock({
    required this.locked,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    if (locked) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.stroke),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_rounded, color: context.accent, size: 18),
            const SizedBox(width: 8),
            Text(
              'Day locked. Entries are read-only.',
              style: TextStyle(
                color: context.fg,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: context.accent.withValues(alpha: 0.45),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Submit Final Execution',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
      ),
    );
  }
}

class _JournalExecutionSliderRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String targetText;
  final String valueText;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final double? progress;
  final bool locked;
  final ValueChanged<double> onChanged;

  const _JournalExecutionSliderRow({
    required this.icon,
    required this.label,
    required this.targetText,
    required this.valueText,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.progress,
    required this.locked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: context.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: context.accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      targetText,
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: context.stroke),
                ),
                child: Text(
                  valueText,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: context.accent,
              inactiveTrackColor: context.stroke.withValues(alpha: 0.5),
              thumbColor: context.accent,
              overlayColor: context.accent.withValues(alpha: 0.18),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions <= 0 ? null : divisions,
              onChanged: locked ? null : onChanged,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 2),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 4,
                value: progress,
                backgroundColor: context.stroke.withValues(alpha: 0.45),
                valueColor: AlwaysStoppedAnimation<Color>(
                    context.accent.withValues(alpha: 0.95)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanListItem {
  final IconData icon;
  final String label;
  final String valueText;

  const _PlanListItem({
    required this.icon,
    required this.label,
    required this.valueText,
  });
}

class _PlanListRow extends StatelessWidget {
  final _PlanListItem item;

  const _PlanListRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          Icon(item.icon, color: context.fgSub, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.label,
              style: TextStyle(
                color: context.fg,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            item.valueText,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MinimalChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MinimalChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: context.fgSub, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 11.8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool locked;
  final int maxLines;

  const _ReflectionField({
    required this.label,
    required this.controller,
    required this.locked,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: !locked,
      maxLines: maxLines,
      style: TextStyle(color: context.fg, fontSize: 13.5),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: context.fgSub, fontSize: 12),
        filled: true,
        fillColor: context.panel,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.accent),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.stroke),
        ),
      ),
    );
  }
}

class _ExecuteLoadingState extends StatelessWidget {
  const _ExecuteLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: List.generate(
        6,
        (_) => Container(
          height: 110,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.stroke),
          ),
        ),
      ),
    );
  }
}

class _ExecuteErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ExecuteErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: [
        ProfileSectionCard(
          title: 'Execute Unavailable',
          subtitle: 'Could not load today\'s day-log right now.',
          trailing: Icon(Icons.error_outline_rounded, color: context.warn),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(color: context.fgSub, fontSize: 12),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () =>
                        DefaultTabController.of(context).animateTo(1),
                    child: const Text('Open Plan Tab'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String? _trimOrNull(String value) {
  final t = value.trim();
  return t.isEmpty ? null : t;
}

String _extractError(AsyncValue state) {
  final err = state.asError?.error;
  if (err is DioException) {
    final body = err.response?.data;
    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      final errorNode = map['error'];
      if (errorNode is Map) {
        final message = '${errorNode['message'] ?? ''}'.trim();
        if (message.isNotEmpty) return message;
      }
      final message = '${map['message'] ?? ''}'.trim();
      if (message.isNotEmpty) return message;
    }
    final status = err.response?.statusCode;
    if (status != null) {
      return 'Request failed (HTTP $status).';
    }
  }
  return 'Something went wrong. Please try again.';
}

String _humanDate(DateTime dt) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final day = days[(dt.weekday - 1).clamp(0, 6)];
  final month = months[(dt.month - 1).clamp(0, 11)];
  return '$day, ${dt.day} $month ${dt.year}';
}

String _weekdayCode(DateTime dt) {
  const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  return days[(dt.weekday - 1).clamp(0, 6)];
}

Color _scoreColor(BuildContext context, int score) {
  if (score <= 39) return context.danger;
  if (score <= 74) return context.warn;
  return context.success;
}

String _scoreLabel(int score) {
  if (score <= 39) return 'Off Track';
  if (score <= 74) return 'In Progress';
  return 'Locked In';
}

double? _progress(double actual, double planned) {
  if (planned <= 0) return null;
  return (actual / planned).clamp(0.0, 1.0);
}

String _fmt(double value) {
  if (value % 1 == 0) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}

double _maxForMinutes(int planned) {
  final doubled = planned * 2;
  if (doubled < 120) return 120;
  if (doubled > 600) return 600;
  return doubled.toDouble();
}

double _maxForHours(double planned) {
  final doubled = planned * 2;
  if (doubled < 8) return 8;
  if (doubled > 16) return 16;
  return doubled;
}

double _maxForHydration(double planned) {
  final doubled = planned * 2;
  if (doubled < 4) return 4;
  if (doubled > 20) return 20;
  return doubled;
}
