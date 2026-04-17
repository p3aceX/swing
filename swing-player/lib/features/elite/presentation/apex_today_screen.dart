import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/controller/profile_controller.dart';
import '../controller/elite_controller.dart';
import '../domain/elite_models.dart';

/// Formats a date as YYYY-MM-DD for the API.
String _dateKey(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

class ApexTodayScreen extends ConsumerStatefulWidget {
  const ApexTodayScreen({super.key});

  @override
  ConsumerState<ApexTodayScreen> createState() => _ApexTodayScreenState();
}

class _ApexTodayScreenState extends ConsumerState<ApexTodayScreen> {
  final _today = DateTime.now();
  late final String _dateStr;

  @override
  void initState() {
    super.initState();
    _dateStr = _dateKey(_today);
  }

  @override
  Widget build(BuildContext context) {
    final playerName =
        ref.watch(profileControllerProvider).data?.identity.fullName ?? '';
    final dayAsync = ref.watch(dayLogProvider(_dateStr));

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.fg),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Today',
          style: TextStyle(
            color: context.fg,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: dayAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: context.accent, strokeWidth: 2),
        ),
        error: (e, _) => _ErrorBody(
          onRetry: () => ref.invalidate(dayLogProvider(_dateStr)),
        ),
        data: (dayLog) {
          if (dayLog.isLocked) {
            return _LockedView(dayLog: dayLog);
          }
          if (dayLog.hasPlan) {
            return _ExecuteView(
              dayLog: dayLog,
              dateStr: _dateStr,
              onSubmitted: (updated) {
                ref.invalidate(dayLogProvider(_dateStr));
              },
            );
          }
          return _PlanView(
            dayLog: dayLog,
            dateStr: _dateStr,
            playerName: playerName,
            onPlanSaved: () => ref.invalidate(dayLogProvider(_dateStr)),
          );
        },
      ),
    );
  }
}

// ── Plan Mode ────────────────────────────────────────────────────────────────

class _PlanView extends ConsumerStatefulWidget {
  final DayLog dayLog;
  final String dateStr;
  final String playerName;
  final VoidCallback onPlanSaved;

  const _PlanView({
    required this.dayLog,
    required this.dateStr,
    required this.playerName,
    required this.onPlanSaved,
  });

  @override
  ConsumerState<_PlanView> createState() => _PlanViewState();
}

class _PlanViewState extends ConsumerState<_PlanView> {
  late int _nets;
  late int _drills;
  late int _gym;
  late int _recovery;
  late double _sleep;
  final _oneThing = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final d = widget.dayLog;
    _nets = d.targetNetsMinutes;
    _drills = d.targetDrillsMinutes;
    _gym = d.targetGymMinutes;
    _recovery = d.targetRecoveryMinutes;
    _sleep = d.targetSleepHours;
    _oneThing.text = d.oneThingToday ?? '';
  }

  @override
  void dispose() {
    _oneThing.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _canConfirm => _oneThing.text.trim().isNotEmpty;

  Future<void> _confirmPlan() async {
    _focusNode.unfocus();
    if (!_canConfirm) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
            '"One thing to focus on" is required before confirming your plan'),
        backgroundColor: context.warn,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final plan = DayPlanUpdate(
      oneThingToday: _oneThing.text.trim(),
      targetNetsMinutes: _nets,
      targetDrillsMinutes: _drills,
      targetGymMinutes: _gym,
      targetRecoveryMinutes: _recovery,
      targetSleepHours: _sleep,
    );

    final updated = await ref
        .read(dayPlanControllerProvider.notifier)
        .updatePlan(widget.dateStr, plan);

    if (!mounted) return;
    if (updated != null) {
      widget.onPlanSaved();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Failed to save plan — please try again'),
        backgroundColor: context.danger,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(dayPlanControllerProvider).isLoading;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _GreetingHeader(playerName: widget.playerName),
              const SizedBox(height: 20),
              _SectionHeader(
                  title: 'Set Your Plan',
                  subtitle: "Targets are pre-filled from your routine. Adjust as needed."),
              const SizedBox(height: 14),
              _PlanSlider(
                label: 'Nets',
                icon: Icons.sports_cricket_rounded,
                value: _nets.toDouble(),
                max: 120,
                unit: 'min',
                onChanged: (v) => setState(() => _nets = v.round()),
              ),
              _PlanSlider(
                label: 'Drills',
                icon: Icons.repeat_rounded,
                value: _drills.toDouble(),
                max: 60,
                unit: 'min',
                onChanged: (v) => setState(() => _drills = v.round()),
              ),
              _PlanSlider(
                label: 'Gym',
                icon: Icons.fitness_center_rounded,
                value: _gym.toDouble(),
                max: 90,
                unit: 'min',
                onChanged: (v) => setState(() => _gym = v.round()),
              ),
              _PlanSlider(
                label: 'Recovery',
                icon: Icons.self_improvement_rounded,
                value: _recovery.toDouble(),
                max: 60,
                unit: 'min',
                onChanged: (v) => setState(() => _recovery = v.round()),
              ),
              _PlanSlider(
                label: 'Sleep target',
                icon: Icons.bedtime_rounded,
                value: _sleep,
                min: 5,
                max: 10,
                unit: 'hrs',
                onChanged: (v) =>
                    setState(() => _sleep = (v * 2).round() / 2),
              ),
              const SizedBox(height: 20),
              _OneThing(
                  controller: _oneThing,
                  focusNode: _focusNode,
                  onChanged: (_) => setState(() {})),
            ],
          ),
        ),
        _ConfirmBar(
          label: 'Confirm My Plan',
          onTap: isSaving ? null : _confirmPlan,
          isLoading: isSaving,
        ),
      ],
    );
  }
}

// ── Execute Mode ─────────────────────────────────────────────────────────────

class _ExecuteView extends ConsumerStatefulWidget {
  final DayLog dayLog;
  final String dateStr;
  final ValueChanged<DayLog> onSubmitted;

  const _ExecuteView({
    required this.dayLog,
    required this.dateStr,
    required this.onSubmitted,
  });

  @override
  ConsumerState<_ExecuteView> createState() => _ExecuteViewState();
}

class _ExecuteViewState extends ConsumerState<_ExecuteView> {
  late int _nets;
  late int _drills;
  late int _gym;
  late int _recovery;
  late double _sleep;
  final _wellController = TextEditingController();
  final _badlyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default actuals to the planned targets
    _nets = widget.dayLog.actualNetsMinutes ?? widget.dayLog.targetNetsMinutes;
    _drills =
        widget.dayLog.actualDrillsMinutes ?? widget.dayLog.targetDrillsMinutes;
    _gym = widget.dayLog.actualGymMinutes ?? widget.dayLog.targetGymMinutes;
    _recovery = widget.dayLog.actualRecoveryMinutes ??
        widget.dayLog.targetRecoveryMinutes;
    _sleep =
        widget.dayLog.actualSleepHours ?? widget.dayLog.targetSleepHours;
  }

  @override
  void dispose() {
    _wellController.dispose();
    _badlyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final submission = ExecutionSubmission(
      actualNetsMinutes: _nets,
      actualDrillsMinutes: _drills,
      actualGymMinutes: _gym,
      actualRecoveryMinutes: _recovery,
      actualSleepHours: _sleep,
      whatDidWell: _wellController.text.trim().isEmpty
          ? null
          : _wellController.text.trim(),
      whatDidBadly: _badlyController.text.trim().isEmpty
          ? null
          : _badlyController.text.trim(),
    );

    final result = await ref
        .read(executionControllerProvider.notifier)
        .submit(widget.dateStr, submission);

    if (!mounted) return;
    if (result != null) {
      widget.onSubmitted(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Submission failed — please try again'),
        backgroundColor: context.danger,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dayLog;
    final isSubmitting = ref.watch(executionControllerProvider).isLoading;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (d.oneThingToday != null) ...[
                _FocusBadge(text: d.oneThingToday!),
                const SizedBox(height: 16),
              ],
              _SectionHeader(
                  title: 'Log Execution',
                  subtitle: 'How did you actually do today?'),
              const SizedBox(height: 14),
              _PlanVsActualSlider(
                label: 'Nets',
                icon: Icons.sports_cricket_rounded,
                planned: d.targetNetsMinutes,
                value: _nets.toDouble(),
                max: 150,
                unit: 'min',
                onChanged: (v) => setState(() => _nets = v.round()),
              ),
              _PlanVsActualSlider(
                label: 'Drills',
                icon: Icons.repeat_rounded,
                planned: d.targetDrillsMinutes,
                value: _drills.toDouble(),
                max: 90,
                unit: 'min',
                onChanged: (v) => setState(() => _drills = v.round()),
              ),
              _PlanVsActualSlider(
                label: 'Gym',
                icon: Icons.fitness_center_rounded,
                planned: d.targetGymMinutes,
                value: _gym.toDouble(),
                max: 120,
                unit: 'min',
                onChanged: (v) => setState(() => _gym = v.round()),
              ),
              _PlanVsActualSlider(
                label: 'Recovery',
                icon: Icons.self_improvement_rounded,
                planned: d.targetRecoveryMinutes,
                value: _recovery.toDouble(),
                max: 90,
                unit: 'min',
                onChanged: (v) => setState(() => _recovery = v.round()),
              ),
              _PlanVsActualSlider(
                label: 'Sleep',
                icon: Icons.bedtime_rounded,
                planned: d.targetSleepHours.round(),
                value: _sleep,
                min: 3,
                max: 12,
                unit: 'hrs',
                onChanged: (v) =>
                    setState(() => _sleep = (v * 2).round() / 2),
              ),
              const SizedBox(height: 20),
              _ReflectionField(
                label: 'What went well?',
                controller: _wellController,
                hint: 'One thing that clicked today…',
              ),
              const SizedBox(height: 12),
              _ReflectionField(
                label: 'What could be better?',
                controller: _badlyController,
                hint: 'One thing to improve tomorrow…',
              ),
            ],
          ),
        ),
        _ConfirmBar(
          label: 'Submit Day',
          onTap: isSubmitting ? null : _submit,
          isLoading: isSubmitting,
          color: context.success,
        ),
      ],
    );
  }
}

// ── Locked / Results View ─────────────────────────────────────────────────────

class _LockedView extends StatelessWidget {
  final DayLog dayLog;

  const _LockedView({required this.dayLog});

  Color _scoreColor(BuildContext context, double score) {
    if (score >= 75) return context.accent;
    if (score >= 40) return context.warn;
    return context.danger;
  }

  String _scoreLabel(double score) {
    if (score >= 75) return 'Apex';
    if (score >= 40) return 'On Track';
    return 'Below Target';
  }

  @override
  Widget build(BuildContext context) {
    final score = dayLog.executionScore ?? 0;
    final color = _scoreColor(context, score);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // EE% Hero
        Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
              color: color.withOpacity(0.08),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${score.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  'EE%',
                  style: TextStyle(color: color.withOpacity(0.7), fontSize: 13),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _scoreLabel(score),
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (dayLog.oneThingToday != null) ...[
          _FocusBadge(text: dayLog.oneThingToday!),
          const SizedBox(height: 16),
        ],
        Text(
          'Plan vs Actual',
          style: TextStyle(
              color: context.fg, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _CompareRow(
          label: 'Nets',
          icon: Icons.sports_cricket_rounded,
          planned: dayLog.targetNetsMinutes,
          actual: dayLog.actualNetsMinutes,
          unit: 'min',
        ),
        _CompareRow(
          label: 'Drills',
          icon: Icons.repeat_rounded,
          planned: dayLog.targetDrillsMinutes,
          actual: dayLog.actualDrillsMinutes,
          unit: 'min',
        ),
        _CompareRow(
          label: 'Gym',
          icon: Icons.fitness_center_rounded,
          planned: dayLog.targetGymMinutes,
          actual: dayLog.actualGymMinutes,
          unit: 'min',
        ),
        _CompareRow(
          label: 'Recovery',
          icon: Icons.self_improvement_rounded,
          planned: dayLog.targetRecoveryMinutes,
          actual: dayLog.actualRecoveryMinutes,
          unit: 'min',
        ),
        _CompareRow(
          label: 'Sleep',
          icon: Icons.bedtime_rounded,
          planned: dayLog.targetSleepHours.round(),
          actual: dayLog.actualSleepHours?.round(),
          unit: 'hrs',
        ),
      ],
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final int planned;
  final int? actual;
  final String unit;

  const _CompareRow({
    required this.label,
    required this.icon,
    required this.planned,
    required this.actual,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    if (planned == 0 && (actual == null || actual == 0)) {
      return const SizedBox.shrink();
    }
    final hit = actual != null && actual! >= planned;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.fgSub),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(color: context.fg, fontSize: 14)),
          ),
          Text(
            '$planned$unit',
            style: TextStyle(color: context.fgSub, fontSize: 13),
          ),
          const SizedBox(width: 6),
          Icon(Icons.arrow_forward_rounded, size: 14, color: context.fgSub),
          const SizedBox(width: 6),
          Text(
            actual != null ? '$actual$unit' : '—',
            style: TextStyle(
              color: hit ? context.accent : context.warn,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            hit ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 14,
            color: hit ? context.accent : context.fgSub,
          ),
        ],
      ),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  final String playerName;
  const _GreetingHeader({required this.playerName});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_greeting${playerName.isNotEmpty ? ', ${playerName.split(' ').first}' : ''}',
          style: TextStyle(
            color: context.fg,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'What does today look like?',
          style: TextStyle(color: context.fgSub, fontSize: 14),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                color: context.fg,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: TextStyle(color: context.fgSub, fontSize: 13)),
      ],
    );
  }
}

class _FocusBadge extends StatelessWidget {
  final String text;
  const _FocusBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.accentBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.accent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.center_focus_strong_rounded,
              size: 16, color: context.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'One thing today',
                  style: TextStyle(
                      color: context.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: TextStyle(
                      color: context.fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OneThing extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OneThing({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.center_focus_strong_rounded,
                size: 15, color: context.accent),
            const SizedBox(width: 6),
            Text(
              'One thing I\'ll focus on today',
              style: TextStyle(
                  color: context.fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            Text('*',
                style: TextStyle(color: context.danger, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          style: TextStyle(color: context.fg, fontSize: 14),
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'e.g. Work on late swing bowling…',
            hintStyle: TextStyle(color: context.fgSub, fontSize: 14),
            filled: true,
            fillColor: context.cardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.stroke),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.stroke),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.accent),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _PlanSlider extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;

  const _PlanSlider({
    required this.label,
    required this.icon,
    required this.value,
    this.min = 0,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isOff = value <= min && unit == 'min';
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.fgSub),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Text(label,
                style: TextStyle(color: context.fgSub, fontSize: 13)),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: context.accent,
                inactiveTrackColor: context.stroke,
                thumbColor: context.accent,
                overlayColor: context.accent.withOpacity(0.15),
                trackHeight: 2,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: ((max - min) / (unit == 'min' ? 5 : 0.5)).round(),
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              isOff
                  ? 'Off'
                  : '${value % 1 == 0 ? value.toInt() : value}$unit',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isOff ? context.fgSub : context.fg,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanVsActualSlider extends StatelessWidget {
  final String label;
  final IconData icon;
  final int planned;
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;

  const _PlanVsActualSlider({
    required this.label,
    required this.icon,
    required this.planned,
    required this.value,
    this.min = 0,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final actual = value;
    final isAhead = planned > 0 && actual >= planned;
    final accentColor = isAhead ? context.accent : context.warn;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: context.fgSub),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(color: context.fg, fontSize: 14)),
              const Spacer(),
              Text(
                'Plan: ${planned == 0 ? 'None' : '$planned$unit'}',
                style: TextStyle(color: context.fgSub, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 24),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: accentColor,
                    inactiveTrackColor: context.stroke,
                    thumbColor: accentColor,
                    overlayColor: accentColor.withOpacity(0.15),
                    trackHeight: 2,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: actual.clamp(min, max),
                    min: min,
                    max: max,
                    divisions:
                        ((max - min) / (unit == 'min' ? 5 : 0.5)).round(),
                    onChanged: onChanged,
                  ),
                ),
              ),
              SizedBox(
                width: 52,
                child: Text(
                  '${actual % 1 == 0 ? actual.toInt() : actual}$unit',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReflectionField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  const _ReflectionField({
    required this.label,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: context.fg,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: TextStyle(color: context.fg, fontSize: 14),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.fgSub, fontSize: 14),
            filled: true,
            fillColor: context.cardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.stroke),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.stroke),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.accent),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _ConfirmBar extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color? color;

  const _ConfirmBar({
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? context.accent;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: Colors.white,
              disabledBackgroundColor: bg.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(label,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorBody({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 40, color: context.fgSub),
          const SizedBox(height: 12),
          Text(
            'Could not load today\'s plan',
            style: TextStyle(color: context.fgSub, fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child:
                Text('Retry', style: TextStyle(color: context.accent)),
          ),
        ],
      ),
    );
  }
}
