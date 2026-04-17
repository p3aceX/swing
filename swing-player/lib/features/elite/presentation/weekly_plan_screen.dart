import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/elite_controller.dart';
import '../domain/elite_models.dart';

class WeeklyPlanScreen extends ConsumerStatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  ConsumerState<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends ConsumerState<WeeklyPlanScreen> {
  late WeeklyPlanTemplate _template;
  final _nameController = TextEditingController();
  int _expandedDay = DateTime.now().weekday - 1; // 0=Monday

  @override
  void initState() {
    super.initState();
    _template = WeeklyPlanTemplate.empty();
    _nameController.text = _template.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _updateDay(int index, WeeklyTemplateDay day) {
    setState(() {
      final days = List<WeeklyTemplateDay>.from(_template.days);
      days[index] = day;
      _template = _template.copyWith(days: days);
    });
  }

  Future<void> _save() async {
    final updated = _template.copyWith(name: _nameController.text.trim());
    final ok =
        await ref.read(weeklyTemplateControllerProvider.notifier).save(updated);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Routine saved'),
        backgroundColor: context.accent,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Failed to save — please try again'),
        backgroundColor: context.danger,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(weeklyTemplateControllerProvider).isLoading;

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
          'Weekly Routine',
          style: TextStyle(
              color: context.fg, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _SectionLabel('Routine name'),
                const SizedBox(height: 6),
                _NameField(controller: _nameController),
                const SizedBox(height: 20),
                _SectionLabel('Daily targets'),
                const SizedBox(height: 4),
                Text(
                  'Set baseline durations for each activity. The plan will auto-fill these every day.',
                  style: TextStyle(color: context.fgSub, fontSize: 13),
                ),
                const SizedBox(height: 14),
                ...List.generate(7, (i) {
                  return _DayCard(
                    dayLabel: kDayLabels[i],
                    day: _template.days[i],
                    isExpanded: _expandedDay == i,
                    onTap: () => setState(
                        () => _expandedDay = _expandedDay == i ? -1 : i),
                    onChanged: (d) => _updateDay(i, d),
                  );
                }),
              ],
            ),
          ),
          _SaveBar(onSave: _save, isSaving: isSaving),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: context.fgSub,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  const _NameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(color: context.fg, fontSize: 15),
      decoration: InputDecoration(
        hintText: 'e.g. Normal Training Week',
        hintStyle: TextStyle(color: context.fgSub),
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
    );
  }
}

class _DayCard extends StatelessWidget {
  final String dayLabel;
  final WeeklyTemplateDay day;
  final bool isExpanded;
  final VoidCallback onTap;
  final ValueChanged<WeeklyTemplateDay> onChanged;

  const _DayCard({
    required this.dayLabel,
    required this.day,
    required this.isExpanded,
    required this.onTap,
    required this.onChanged,
  });

  int get _totalMinutes =>
      day.netsMinutes +
      day.drillsMinutes +
      day.gymMinutes +
      day.recoveryMinutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? context.accent : context.stroke,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(
                    dayLabel,
                    style: TextStyle(
                        color: context.fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (_totalMinutes > 0)
                    Text(
                      '${_totalMinutes}min',
                      style: TextStyle(color: context.accent, fontSize: 13),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: context.fgSub,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Divider(color: context.stroke, height: 1),
                  const SizedBox(height: 12),
                  _ActivitySlider(
                    label: 'Nets',
                    icon: Icons.sports_cricket_rounded,
                    value: day.netsMinutes.toDouble(),
                    min: 0,
                    max: 120,
                    unit: 'min',
                    onChanged: (v) =>
                        onChanged(day.copyWith(netsMinutes: v.round())),
                  ),
                  _ActivitySlider(
                    label: 'Drills',
                    icon: Icons.repeat_rounded,
                    value: day.drillsMinutes.toDouble(),
                    min: 0,
                    max: 60,
                    unit: 'min',
                    onChanged: (v) =>
                        onChanged(day.copyWith(drillsMinutes: v.round())),
                  ),
                  _ActivitySlider(
                    label: 'Gym',
                    icon: Icons.fitness_center_rounded,
                    value: day.gymMinutes.toDouble(),
                    min: 0,
                    max: 90,
                    unit: 'min',
                    onChanged: (v) =>
                        onChanged(day.copyWith(gymMinutes: v.round())),
                  ),
                  _ActivitySlider(
                    label: 'Recovery',
                    icon: Icons.self_improvement_rounded,
                    value: day.recoveryMinutes.toDouble(),
                    min: 0,
                    max: 60,
                    unit: 'min',
                    onChanged: (v) =>
                        onChanged(day.copyWith(recoveryMinutes: v.round())),
                  ),
                  _ActivitySlider(
                    label: 'Sleep',
                    icon: Icons.bedtime_rounded,
                    value: day.sleepHours,
                    min: 5,
                    max: 10,
                    divisions: 10,
                    unit: 'hrs',
                    onChanged: (v) => onChanged(
                        day.copyWith(sleepHours: (v * 2).round() / 2)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActivitySlider extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String unit;
  final ValueChanged<double> onChanged;

  const _ActivitySlider({
    required this.label,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isZero = value <= min && unit == 'min';
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.fgSub),
          const SizedBox(width: 8),
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: TextStyle(color: context.fgSub, fontSize: 13),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: context.accent,
                inactiveTrackColor: context.stroke,
                thumbColor: context.accent,
                overlayColor: context.accent.withOpacity(0.15),
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions:
                    divisions ?? ((max - min) ~/ (unit == 'min' ? 5 : 1)),
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              isZero ? 'Off' : '${value % 1 == 0 ? value.toInt() : value}$unit',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isZero ? context.fgSub : context.fg,
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

class _SaveBar extends StatelessWidget {
  final VoidCallback onSave;
  final bool isSaving;

  const _SaveBar({required this.onSave, required this.isSaving});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isSaving ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.accent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: context.accent.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text(
                    'Save Routine',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ),
    );
  }
}
