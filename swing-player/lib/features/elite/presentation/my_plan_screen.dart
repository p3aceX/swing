import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/elite_controller.dart';
import '../domain/elite_models.dart';

const _activityIcons = {
  ActivityCategory.nets: Icons.sports_cricket_rounded,
  ActivityCategory.skillWork: Icons.adjust_rounded,
  ActivityCategory.conditioning: Icons.directions_run_rounded,
  ActivityCategory.gym: Icons.fitness_center_rounded,
  ActivityCategory.match: Icons.emoji_events_rounded,
  ActivityCategory.recovery: Icons.favorite_rounded,
};

const _weekDays = [
  (1, 'Mon'),
  (2, 'Tue'),
  (3, 'Wed'),
  (4, 'Thu'),
  (5, 'Fri'),
  (6, 'Sat'),
  (7, 'Sun'),
];

const _planDayPrefsKey = 'elite_my_plan_selected_days_v1';

class MyPlanScreen extends ConsumerStatefulWidget {
  const MyPlanScreen({super.key});

  @override
  ConsumerState<MyPlanScreen> createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends ConsumerState<MyPlanScreen> {
  late MyPlan _plan;
  final _nameCtrl = TextEditingController();
  final Map<ActivityCategory, Set<int>> _selectedDays = {};
  bool _isBootstrapping = true;
  String? _bootstrapError;

  @override
  void initState() {
    super.initState();
    _plan = MyPlan.empty();
    _nameCtrl.text = _plan.name;
    _bootstrap();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    if (mounted) {
      setState(() {
        _isBootstrapping = true;
        _bootstrapError = null;
      });
    }
    try {
      final existing = await ref.read(myPlanProvider.future);
      final storedDays = await _loadStoredDays();
      final basePlan = existing ?? MyPlan.empty();
      final selected = <ActivityCategory, Set<int>>{};
      for (final activity in basePlan.activities) {
        final fromPrefs = storedDays[activity.category];
        final fromPlan = activity.days.where((d) => d >= 1 && d <= 7).toSet();
        selected[activity.category] =
            (fromPrefs != null && fromPrefs.isNotEmpty)
                ? fromPrefs
                : (fromPlan.isNotEmpty
                    ? fromPlan
                    : _defaultDaysForCount(activity.timesPerWeek));
      }
      final syncedPlan = _syncPlanWithDays(basePlan, selected);
      if (!mounted) return;
      setState(() {
        _plan = syncedPlan;
        _nameCtrl.text = syncedPlan.name;
        _selectedDays
          ..clear()
          ..addAll(selected);
        _isBootstrapping = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _plan = MyPlan.empty();
        _nameCtrl.text = _plan.name;
        _selectedDays.clear();
        _isBootstrapping = false;
        _bootstrapError =
            'Could not load existing plan. You can still create one.';
      });
    }
  }

  Future<Map<ActivityCategory, Set<int>>> _loadStoredDays() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_planDayPrefsKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      final out = <ActivityCategory, Set<int>>{};
      for (final entry in decoded.entries) {
        final category = _categoryFromApiType('${entry.key}');
        if (category == null || entry.value is! List) continue;
        final days = (entry.value as List)
            .map((e) => int.tryParse('$e') ?? -1)
            .where((d) => d >= 1 && d <= 7)
            .toSet();
        if (days.isNotEmpty) out[category] = days;
      }
      return out;
    } catch (_) {
      return {};
    }
  }

  Future<void> _persistStoredDays() async {
    final prefs = await SharedPreferences.getInstance();
    final activeCats = _plan.activities.map((a) => a.category).toSet();
    final payload = <String, List<int>>{};
    for (final entry in _selectedDays.entries) {
      if (!activeCats.contains(entry.key) || entry.value.isEmpty) continue;
      final sorted = entry.value.toList()..sort();
      payload[entry.key.apiType] = sorted;
    }
    await prefs.setString(_planDayPrefsKey, jsonEncode(payload));
  }

  ActivityCategory? _categoryFromApiType(String apiType) {
    for (final c in ActivityCategory.values) {
      if (c.apiType == apiType) return c;
    }
    return null;
  }

  Set<int> _defaultDaysForCount(int count) {
    final safe = count < 1 ? 1 : (count > 7 ? 7 : count);
    switch (safe) {
      case 1:
        return {3};
      case 2:
        return {2, 5};
      case 3:
        return {1, 3, 5};
      case 4:
        return {1, 2, 4, 6};
      case 5:
        return {1, 2, 3, 5, 6};
      case 6:
        return {1, 2, 3, 4, 5, 6};
      case 7:
        return {1, 2, 3, 4, 5, 6, 7};
      default:
        return {3};
    }
  }

  MyPlan _syncPlanWithDays(
    MyPlan base,
    Map<ActivityCategory, Set<int>> selected,
  ) {
    return base.copyWith(
      activities: base.activities.map((a) {
        final days = selected[a.category];
        final effectiveDays = (days != null && days.isNotEmpty)
            ? days
            : (a.days.isNotEmpty
                ? a.days.where((d) => d >= 1 && d <= 7).toSet()
                : _defaultDaysForCount(a.timesPerWeek));
        final count = effectiveDays.length;
        final safeCount = count < 1 ? 1 : (count > 7 ? 7 : count);
        final sortedDays = effectiveDays.toList()..sort();
        return a.copyWith(timesPerWeek: safeCount, days: sortedDays);
      }).toList(),
    );
  }

  PlannedActivity? _activityFor(ActivityCategory cat) {
    try {
      return _plan.activities.firstWhere((a) => a.category == cat);
    } catch (_) {
      return null;
    }
  }

  void _toggleActivity(ActivityCategory cat) {
    setState(() {
      final existing = _activityFor(cat);
      if (existing != null) {
        _selectedDays.remove(cat);
        _plan = _plan.copyWith(
          activities: _plan.activities.where((a) => a.category != cat).toList(),
        );
      } else {
        final defaults = _defaultDaysForCount(3);
        _selectedDays[cat] = defaults;
        _plan = _plan.copyWith(
          activities: [
            ..._plan.activities,
            PlannedActivity(
              category: cat,
              timesPerWeek: defaults.length,
              days: (defaults.toList()..sort()),
            ),
          ],
        );
      }
    });
  }

  void _toggleActivityDay(ActivityCategory cat, int day) {
    if (_activityFor(cat) == null) return;
    setState(() {
      final current = Set<int>.from(_selectedDays[cat] ?? {3});
      if (current.contains(day)) {
        if (current.length == 1) return;
        current.remove(day);
      } else {
        if (current.length >= 7) return;
        current.add(day);
      }
      _selectedDays[cat] = current;
      _plan = _plan.copyWith(
        activities: _plan.activities.map((a) {
          final sortedDays = current.toList()..sort();
          return a.category == cat
              ? a.copyWith(timesPerWeek: current.length, days: sortedDays)
              : a;
        }).toList(),
      );
    });
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim().isEmpty
        ? 'My Training Plan'
        : _nameCtrl.text.trim();
    final updated =
        _syncPlanWithDays(_plan.copyWith(name: name), _selectedDays);
    final ok =
        await ref.read(myPlanSaveControllerProvider.notifier).save(updated);
    if (!mounted) return;
    if (ok) {
      _plan = updated;
      try {
        await _persistStoredDays();
      } catch (e) {
        debugPrint('[MyPlan] Failed to persist day selections: $e');
      }
      ref.invalidate(myPlanProvider);
      ref.invalidate(eliteProfileProvider);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Plan saved'),
        backgroundColor: context.accent,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.of(context).pop(true);
    } else {
      final saveState = ref.read(myPlanSaveControllerProvider);
      final message = _extractSaveErrorMessage(saveState);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: context.danger,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  String _extractSaveErrorMessage(AsyncValue<void> saveState) {
    final err = saveState.asError?.error;
    if (err == null) return 'Failed to save - try again';
    if (err is DioException) {
      final status = err.response?.statusCode;
      final body = err.response?.data;
      if (status == 401) return 'Session expired. Please login again.';
      if (status == 404) return 'Player profile not found on server.';
      if (status == 422 || status == 400) {
        return 'Plan format rejected by server (${status ?? ''}).';
      }
      final fromBody = body is Map
          ? (body['error'] ?? body['message'] ?? body['code'])?.toString()
          : null;
      if (fromBody != null && fromBody.trim().isNotEmpty) return fromBody;
      if (status != null) return 'Server error ($status) while saving plan.';
    }
    return 'Failed to save - try again';
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(myPlanSaveControllerProvider).isLoading;

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
          'My Plan',
          style: TextStyle(
            color: context.fg,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isBootstrapping
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: context.accent,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      if (_bootstrapError != null) ...[
                        _InlineMessage(
                          text: _bootstrapError!,
                          onRetry: _bootstrap,
                        ),
                        const SizedBox(height: 16),
                      ],
                      _SectionLabel('Plan name'),
                      const SizedBox(height: 8),
                      _NameField(controller: _nameCtrl),
                      const SizedBox(height: 24),
                      _SectionLabel('What will you commit to?'),
                      const SizedBox(height: 4),
                      Text(
                        'Select activities, then choose exact weekdays for each one.',
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...ActivityCategory.values.map((cat) {
                        final planned = _activityFor(cat);
                        final isOn = planned != null;
                        return _ActivityRow(
                          icon: _activityIcons[cat]!,
                          label: cat.label,
                          subtitle: cat.subtitle,
                          isOn: isOn,
                          selectedDays: _selectedDays[cat] ??
                              _defaultDaysForCount(planned?.timesPerWeek ?? 3),
                          onToggle: () => _toggleActivity(cat),
                          onToggleDay: (day) => _toggleActivityDay(cat, day),
                        );
                      }),
                      const SizedBox(height: 24),
                      _SectionLabel('Daily targets'),
                      const SizedBox(height: 4),
                      Text(
                        'These are your baseline goals - recorded every time you journal.',
                        style: TextStyle(color: context.fgSub, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      _VitalTarget(
                        icon: Icons.bedtime_rounded,
                        label: 'Sleep target',
                        value: _plan.sleepTargetHours,
                        min: 5,
                        max: 10,
                        unit: 'hrs',
                        onChanged: (v) => setState(
                          () => _plan = _plan.copyWith(
                            sleepTargetHours: (v * 2).round() / 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _VitalTarget(
                        icon: Icons.water_drop_rounded,
                        label: 'Hydration target',
                        value: _plan.hydrationTargetLiters,
                        min: 1,
                        max: 6,
                        unit: 'L',
                        onChanged: (v) => setState(
                          () => _plan = _plan.copyWith(
                            hydrationTargetLiters: (v * 2).round() / 2,
                          ),
                        ),
                      ),
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

class _InlineMessage extends StatelessWidget {
  final String text;
  final VoidCallback onRetry;
  const _InlineMessage({required this.text, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: context.fgSub, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: context.fgSub, fontSize: 12.5),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
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
        hintText: 'e.g. Pre-Season Block',
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

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isOn;
  final Set<int> selectedDays;
  final VoidCallback onToggle;
  final ValueChanged<int> onToggleDay;

  const _ActivityRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isOn,
    required this.selectedDays,
    required this.onToggle,
    required this.onToggleDay,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isOn ? context.accentBg : context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isOn ? context.accent : context.stroke),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isOn ? context.accent : context.fgSub,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: isOn ? context.accent : context.fg,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(color: context.fgSub, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: isOn,
                    onChanged: (_) => onToggle(),
                    activeColor: context.accent,
                  ),
                ],
              ),
            ),
          ),
          if (isOn) ...[
            Divider(height: 1, color: context.accent.withValues(alpha: 0.2)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Which days this week?',
                        style: TextStyle(color: context.fgSub, fontSize: 13),
                      ),
                      const Spacer(),
                      Text(
                        '${selectedDays.length}x',
                        style: TextStyle(
                          color: context.fg,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _weekDays.map((day) {
                      final isSelected = selectedDays.contains(day.$1);
                      return _DayChip(
                        label: day.$2,
                        selected: isSelected,
                        onTap: () => onToggleDay(day.$1),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? context.accent : context.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? context.accent : context.stroke,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : context.fgSub,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _VitalTarget extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;

  const _VitalTarget({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.fgSub),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: context.fgSub, fontSize: 13),
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: context.accent,
              inactiveTrackColor: context.stroke,
              thumbColor: context.accent,
              overlayColor: context.accent.withValues(alpha: 0.15),
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: SizedBox(
              width: 120,
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: ((max - min) / 0.5).round(),
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              '${value % 1 == 0 ? value.toInt() : value}$unit',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: context.fg,
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
              disabledBackgroundColor: context.accent.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save Plan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ),
    );
  }
}
