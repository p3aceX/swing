import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/controller/profile_controller.dart';
import '../../profile/presentation/widgets/profile_section_card.dart';
import '../controller/elite_controller.dart';
import '../domain/elite_models.dart';

class ApexPlanTab extends ConsumerStatefulWidget {
  final ProfileState profileState;
  final VoidCallback onRetry;

  const ApexPlanTab({
    super.key,
    required this.profileState,
    required this.onRetry,
  });

  @override
  ConsumerState<ApexPlanTab> createState() => _ApexPlanTabState();
}

class _ApexPlanTabState extends ConsumerState<ApexPlanTab> {
  static const int _journalWindowDays = 30;
  final TextEditingController _nameController = TextEditingController();
  bool _isEditing = false;
  bool _isCreating = false;
  WeeklyPlan? _draftPlan;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(weeklyPlanProvider);
    ref.invalidate(journalConsistencyProvider(_journalWindowDays));
    ref.invalidate(profileControllerProvider);
    ref.invalidate(eliteProfileProvider);
  }

  void _startCreate() {
    final draft = WeeklyPlan.empty();
    setState(() {
      _isEditing = true;
      _isCreating = true;
      _draftPlan = _clonePlan(draft);
      _nameController.text = draft.name;
    });
  }

  void _startEdit(WeeklyPlan plan) {
    final draft = _clonePlan(plan);
    setState(() {
      _isEditing = true;
      _isCreating = false;
      _draftPlan = draft;
      _nameController.text = draft.name;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _isCreating = false;
      _draftPlan = null;
      _nameController.clear();
    });
  }

  WeeklyPlan _clonePlan(WeeklyPlan plan) {
    return plan.copyWith(
      days: plan.days.map((d) => d.copyWith()).toList(growable: false),
    );
  }

  void _updateName(String value) {
    final draft = _draftPlan;
    if (draft == null) return;
    setState(() {
      _draftPlan = draft.copyWith(name: value);
    });
  }

  void _updateDay(int index, WeeklyPlanDay updated) {
    final draft = _draftPlan;
    if (draft == null || index < 0 || index >= draft.days.length) return;
    final days = List<WeeklyPlanDay>.from(draft.days);
    days[index] = updated;
    setState(() {
      _draftPlan = draft.copyWith(days: days);
    });
  }

  Future<void> _save() async {
    final currentDraft = _draftPlan;
    if (currentDraft == null) return;
    final normalizedName = currentDraft.name.trim().isEmpty
        ? 'My Weekly Plan'
        : currentDraft.name.trim();
    final payload = currentDraft.copyWith(name: normalizedName);
    final creating = _isCreating;

    final notifier = ref.read(weeklyPlanSaveControllerProvider.notifier);
    final ok = creating
        ? await notifier.create(payload)
        : await notifier.update(payload);

    if (!mounted) return;
    if (ok) {
      _cancelEdit();
      ref.invalidate(weeklyPlanProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(creating ? 'Weekly plan created' : 'Weekly plan updated'),
          backgroundColor: context.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final error =
        _extractSaveErrorMessage(ref.read(weeklyPlanSaveControllerProvider));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: context.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.profileState.isLoading && widget.profileState.data == null) {
      return const _PlanTabLoadingState();
    }

    if (widget.profileState.error != null && widget.profileState.data == null) {
      return _PlanTabErrorState(
        message: widget.profileState.error!,
        onRetry: widget.onRetry,
      );
    }

    if (widget.profileState.data == null) {
      return _PlanTabErrorState(
        message: 'Could not load profile right now.',
        onRetry: widget.onRetry,
      );
    }

    final weeklyPlanAsync = ref.watch(weeklyPlanProvider);
    final isSaving = ref.watch(weeklyPlanSaveControllerProvider).isLoading;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        children: [
          _buildWeeklyPlanBlock(
            context,
            weeklyPlanAsync: weeklyPlanAsync,
            isSaving: isSaving,
          ),
          const SizedBox(height: 14),
          const _PreparePlanExecutionStreakCard(windowDays: _journalWindowDays),
        ],
      ),
    );
  }

  Widget _buildWeeklyPlanBlock(
    BuildContext context, {
    required AsyncValue<WeeklyPlan?> weeklyPlanAsync,
    required bool isSaving,
  }) {
    if (_isEditing) {
      final draft = _draftPlan ??
          (weeklyPlanAsync.asData?.value != null
              ? _clonePlan(weeklyPlanAsync.asData!.value!)
              : WeeklyPlan.empty());
      return ProfileSectionCard(
        title: _isCreating ? 'Create Weekly Plan' : 'Edit Weekly Plan',
        subtitle: 'Set your weekly training structure.',
        trailing: TextButton(
          onPressed: isSaving ? null : _cancelEdit,
          child: const Text('Cancel'),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              onChanged: _updateName,
              style: TextStyle(
                color: context.fg,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: 'Plan Name',
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
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(draft.days.length, (index) {
              final day = draft.days[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PlanDayEditorCard(
                  day: day,
                  fallbackWeekday: index < kWeeklyPlanWeekdays.length
                      ? kWeeklyPlanWeekdays[index]
                      : '',
                  onChanged: (updated) => _updateDay(index, updated),
                ),
              );
            }),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      context.accent.withValues(alpha: 0.45),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isCreating ? 'Create Weekly Plan' : 'Save Changes',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    }

    return weeklyPlanAsync.when(
      loading: () => const ProfileSectionCard(
        title: 'Weekly Plan',
        subtitle: 'Loading your current weekly structure.',
        child: _WeeklyPlanLoadingBody(),
      ),
      error: (error, _) => ProfileSectionCard(
        title: 'Weekly Plan',
        subtitle: 'Could not load your weekly plan.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$error',
              style: TextStyle(color: context.fgSub, fontSize: 12),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(weeklyPlanProvider),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (plan) {
        if (plan == null) {
          return ProfileSectionCard(
            title: 'Weekly Plan',
            subtitle: 'What your week looks like.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No weekly plan yet. Create your first training structure.',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _startCreate,
                  child: const Text('Create Weekly Plan'),
                ),
              ],
            ),
          );
        }

        // Determine today's weekday abbreviation (MON, TUE, …)
        final todayAbbr = const [
          'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'
        ][DateTime.now().weekday - 1];

        return ProfileSectionCard(
          title: plan.name.trim().isNotEmpty ? plan.name.trim() : 'Weekly Plan',
          subtitle: 'Tap a day to see training details.',
          trailing: TextButton(
            onPressed: () => _startEdit(plan),
            child: const Text('Edit'),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...List.generate(plan.days.length, (index) {
                final day = plan.days[index];
                final dayAbbr = day.weekday.trim().isNotEmpty
                    ? day.weekday.trim().toUpperCase()
                    : (index < kWeeklyPlanWeekdays.length
                        ? kWeeklyPlanWeekdays[index]
                        : '');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _PlanDayReadCard(
                    day: day,
                    fallbackWeekday: index < kWeeklyPlanWeekdays.length
                        ? kWeeklyPlanWeekdays[index]
                        : '',
                    isToday: dayAbbr == todayAbbr,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _extractSaveErrorMessage(AsyncValue<void> state) {
    final error = state.asError?.error;
    if (error is DioException) {
      final body = error.response?.data;
      if (body is Map) {
        final map = Map<String, dynamic>.from(body);
        final errorNode = map['error'];
        if (errorNode is Map) {
          final msg = '${errorNode['message'] ?? ''}'.trim();
          if (msg.isNotEmpty) return msg;
        }
        final message = '${map['message'] ?? ''}'.trim();
        if (message.isNotEmpty) return message;
      }
      final status = error.response?.statusCode;
      if (status != null) {
        return 'Could not save weekly plan (HTTP $status).';
      }
    }
    return 'Could not save weekly plan right now.';
  }
}

class _PlanTabLoadingState extends StatelessWidget {
  const _PlanTabLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: [
        Container(
          height: 110,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.stroke),
          ),
        ),
        Container(
          height: 380,
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.stroke),
          ),
        ),
      ],
    );
  }
}

class _PlanTabErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PlanTabErrorState({
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
          title: 'Plan Unavailable',
          subtitle: 'Could not load your Apex plan context right now.',
          trailing: Icon(Icons.error_outline_rounded, color: context.warn),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(color: context.fgSub, fontSize: 12),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyPlanLoadingBody extends StatelessWidget {
  const _WeeklyPlanLoadingBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        7,
        (_) => Container(
          height: 52,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: context.panel,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.stroke),
          ),
        ),
      ),
    );
  }
}

// ── Rich read-only day card ────────────────────────────────────────────────────

class _PlanDayReadCard extends StatefulWidget {
  final WeeklyPlanDay day;
  final String fallbackWeekday;
  final bool isToday;

  const _PlanDayReadCard({
    required this.day,
    required this.fallbackWeekday,
    this.isToday = false,
  });

  @override
  State<_PlanDayReadCard> createState() => _PlanDayReadCardState();
}

class _PlanDayReadCardState extends State<_PlanDayReadCard> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _expanded = widget.isToday;
  }

  @override
  Widget build(BuildContext context) {
    final day = widget.day;
    final label = _weekdayLabel(day.weekday, widget.fallbackWeekday);
    final isToday = widget.isToday;
    final hasTraining = day.hasAnyTraining;
    final totalMin = day.totalTrainingMinutes;

    final accentColor = isToday ? context.accent : null;
    final borderColor = isToday
        ? context.accent.withValues(alpha: 0.4)
        : context.stroke.withValues(alpha: 0.95);
    final bgColor = isToday
        ? context.accent.withValues(alpha: 0.06)
        : context.panel;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            // ── Header row ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Row(
                children: [
                  // Day pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isToday
                          ? context.accent
                          : context.cardBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isToday ? Colors.white : context.fg,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: context.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'TODAY',
                        style: TextStyle(
                          color: context.accent,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Activity icons strip
                  _ActivityIconsStrip(day: day),
                  const SizedBox(width: 10),
                  // Total load
                  if (totalMin > 0)
                    Text(
                      '${totalMin}m',
                      style: TextStyle(
                        color: accentColor ?? context.fgSub,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else if (!hasTraining)
                    Text(
                      'Rest',
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(width: 6),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: context.fgSub,
                  ),
                ],
              ),
            ),

            // ── Expanded detail ─────────────────────────────────────────────
            if (_expanded) ...[
              Divider(
                  height: 1,
                  thickness: 1,
                  color: context.stroke.withValues(alpha: 0.5)),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Training activities
                    if (hasTraining) ...[
                      _SectionLabel('Training'),
                      const SizedBox(height: 8),
                      _ActivityRow(
                        icon: Icons.sports_cricket_rounded,
                        label: 'Nets',
                        minutes: day.netsMinutes,
                        active: day.hasNets || day.netsMinutes > 0,
                      ),
                      _ActivityRow(
                        icon: Icons.adjust_rounded,
                        label: 'Skill Work',
                        minutes: day.drillsMinutes,
                        active: day.hasSkillWork || day.drillsMinutes > 0,
                      ),
                      _ActivityRow(
                        icon: Icons.fitness_center_rounded,
                        label: 'Gym',
                        minutes: day.fitnessMinutes,
                        active: day.hasGym,
                      ),
                      _ActivityRow(
                        icon: Icons.directions_run_rounded,
                        label: 'Conditioning',
                        minutes: 0,
                        active: day.hasConditioning,
                        note: day.fitnessMinutes > 0
                            ? 'See fitness above'
                            : null,
                      ),
                      _ActivityRow(
                        icon: Icons.emoji_events_rounded,
                        label: 'Match',
                        minutes: 0,
                        active: day.hasMatch,
                      ),
                      if (day.hasRecovery || day.recoveryMinutes > 0)
                        _ActivityRow(
                          icon: Icons.favorite_rounded,
                          label: 'Recovery',
                          minutes: day.recoveryMinutes,
                          active: day.hasRecovery || day.recoveryMinutes > 0,
                        ),
                      const SizedBox(height: 12),
                    ],
                    // Wellness targets
                    _SectionLabel('Daily Targets'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _WellnessTarget(
                            icon: Icons.bedtime_rounded,
                            label: 'Sleep',
                            value: '${_fmt(day.sleepTargetHours)}h',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _WellnessTarget(
                            icon: Icons.water_drop_rounded,
                            label: 'Hydration',
                            value: '${_fmt(day.hydrationTargetLiters)}L',
                          ),
                        ),
                        if (day.hasProperDiet) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: _WellnessTarget(
                              icon: Icons.restaurant_rounded,
                              label: 'Proper Diet',
                              value: '✓',
                              active: true,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActivityIconsStrip extends StatelessWidget {
  final WeeklyPlanDay day;
  const _ActivityIconsStrip({required this.day});

  @override
  Widget build(BuildContext context) {
    final activities = <(IconData, bool)>[
      (Icons.sports_cricket_rounded, day.hasNets || day.netsMinutes > 0),
      (Icons.adjust_rounded, day.hasSkillWork || day.drillsMinutes > 0),
      (Icons.fitness_center_rounded, day.hasGym || day.fitnessMinutes > 0),
      (Icons.directions_run_rounded, day.hasConditioning),
      (Icons.emoji_events_rounded, day.hasMatch),
    ];
    final active = activities.where((a) => a.$2).toList();
    if (active.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: active
          .take(4)
          .map((a) => Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(a.$1, size: 14, color: context.accent),
              ))
          .toList(),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: TextStyle(
          color: context.fgSub,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      );
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int minutes;
  final bool active;
  final String? note;

  const _ActivityRow({
    required this.icon,
    required this.label,
    required this.minutes,
    required this.active,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: active
                  ? context.accent.withValues(alpha: 0.12)
                  : context.cardBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 14,
              color: active ? context.accent : context.fgSub,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: active ? context.fg : context.fgSub,
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          if (minutes > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: context.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${minutes}m',
                style: TextStyle(
                  color: context.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else if (note != null)
            Text(
              note!,
              style: TextStyle(color: context.fgSub, fontSize: 11),
            )
          else if (!active)
            Text(
              'Off',
              style: TextStyle(color: context.fgSub, fontSize: 11),
            ),
        ],
      ),
    );
  }
}

class _WellnessTarget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool active;

  const _WellnessTarget({
    required this.icon,
    required this.label,
    required this.value,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14,
              color: active ? context.accent : context.fgSub),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanDayEditorCard extends StatelessWidget {
  final WeeklyPlanDay day;
  final String fallbackWeekday;
  final ValueChanged<WeeklyPlanDay> onChanged;

  const _PlanDayEditorCard({
    required this.day,
    required this.fallbackWeekday,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final weekday = _weekdayLabel(day.weekday, fallbackWeekday);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.stroke.withValues(alpha: 0.95)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            weekday,
            style: TextStyle(
              color: context.fg,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PlanStepper(
                label: 'Nets',
                value: '${day.netsMinutes}m',
                onMinus: () => onChanged(
                  day.copyWith(
                      netsMinutes: _stepInt(day.netsMinutes, -15, 0, 300)),
                ),
                onPlus: () => onChanged(
                  day.copyWith(
                      netsMinutes: _stepInt(day.netsMinutes, 15, 0, 300)),
                ),
              ),
              _PlanStepper(
                label: 'Drills',
                value: '${day.drillsMinutes}m',
                onMinus: () => onChanged(
                  day.copyWith(
                      drillsMinutes: _stepInt(day.drillsMinutes, -15, 0, 180)),
                ),
                onPlus: () => onChanged(
                  day.copyWith(
                      drillsMinutes: _stepInt(day.drillsMinutes, 15, 0, 180)),
                ),
              ),
              _PlanStepper(
                label: 'Fitness',
                value: '${day.fitnessMinutes}m',
                onMinus: () => onChanged(
                  day.copyWith(
                      fitnessMinutes:
                          _stepInt(day.fitnessMinutes, -15, 0, 240)),
                ),
                onPlus: () => onChanged(
                  day.copyWith(
                      fitnessMinutes: _stepInt(day.fitnessMinutes, 15, 0, 240)),
                ),
              ),
              _PlanStepper(
                label: 'Recovery',
                value: '${day.recoveryMinutes}m',
                onMinus: () => onChanged(
                  day.copyWith(
                      recoveryMinutes:
                          _stepInt(day.recoveryMinutes, -15, 0, 180)),
                ),
                onPlus: () => onChanged(
                  day.copyWith(
                      recoveryMinutes:
                          _stepInt(day.recoveryMinutes, 15, 0, 180)),
                ),
              ),
              _PlanStepper(
                label: 'Sleep',
                value: '${_fmt(day.sleepTargetHours)}h',
                onMinus: () => onChanged(
                  day.copyWith(
                      sleepTargetHours:
                          _stepDouble(day.sleepTargetHours, -0.5, 4, 14)),
                ),
                onPlus: () => onChanged(
                  day.copyWith(
                      sleepTargetHours:
                          _stepDouble(day.sleepTargetHours, 0.5, 4, 14)),
                ),
              ),
              _PlanStepper(
                label: 'Hydration',
                value: '${_fmt(day.hydrationTargetLiters)}L',
                onMinus: () => onChanged(
                  day.copyWith(
                      hydrationTargetLiters:
                          _stepDouble(day.hydrationTargetLiters, -0.5, 0, 12)),
                ),
                onPlus: () => onChanged(
                  day.copyWith(
                      hydrationTargetLiters:
                          _stepDouble(day.hydrationTargetLiters, 0.5, 0, 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static int _stepInt(int current, int delta, int min, int max) {
    final next = current + delta;
    return next.clamp(min, max);
  }

  static double _stepDouble(
      double current, double delta, double min, double max) {
    final next = current + delta;
    final clamped = next.clamp(min, max).toDouble();
    return (clamped * 10).roundToDouble() / 10;
  }
}

class _PlanStepper extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _PlanStepper({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onMinus,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.panel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.stroke),
              ),
              child: Icon(Icons.remove, size: 14, color: context.fgSub),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onPlus,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.panel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.stroke),
              ),
              child: Icon(Icons.add, size: 14, color: context.fgSub),
            ),
          ),
        ],
      ),
    );
  }
}

String _weekdayLabel(String raw, String fallback) {
  final key = raw.trim().isNotEmpty ? raw.trim().toUpperCase() : fallback;
  return switch (key) {
    'MON' => 'Monday',
    'TUE' => 'Tuesday',
    'WED' => 'Wednesday',
    'THU' => 'Thursday',
    'FRI' => 'Friday',
    'SAT' => 'Saturday',
    'SUN' => 'Sunday',
    _ => key.isEmpty ? 'Day' : key,
  };
}

String _fmt(double value) {
  if (value % 1 == 0) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}

class _PreparePlanExecutionStreakCard extends ConsumerWidget {
  final int windowDays;

  const _PreparePlanExecutionStreakCard({
    required this.windowDays,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consistencyAsync = ref.watch(journalConsistencyProvider(windowDays));

    return consistencyAsync.when(
      loading: () => const ProfileSectionCard(
        title: 'Plan vs Execution',
        subtitle: 'Preparing monthly streak.',
        child: SizedBox(
          height: 150,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      error: (error, _) => ProfileSectionCard(
        title: 'Plan vs Execution',
        subtitle: 'Could not load your monthly streak.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$error',
              style: TextStyle(color: context.fgSub, fontSize: 12),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.invalidate(journalConsistencyProvider(windowDays)),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (consistency) {
        final monthModel =
            _PrepareMonthStreakModel.fromConsistency(consistency.days);

        return ProfileSectionCard(
          title: 'Plan vs Execution',
          subtitle:
              'GitHub-style streak by planned activities vs journal completion.',
          trailing: IconButton(
            tooltip: 'Refresh streak',
            visualDensity: VisualDensity.compact,
            onPressed: () => ref.invalidate(journalConsistencyProvider(
              windowDays,
            )),
            icon: Icon(Icons.refresh_rounded, color: context.fgSub, size: 18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MonthlyAverageBox(model: monthModel),
              const SizedBox(height: 10),
              _MonthGitHubHeatmap(model: monthModel),
            ],
          ),
        );
      },
    );
  }
}

class _PrepareMonthStreakModel {
  final DateTime monthStart;
  final DateTime monthEnd;
  final List<_PrepareDayPoint> points;
  final double averagePct;
  final int scoredDays;
  final int totalDays;

  const _PrepareMonthStreakModel({
    required this.monthStart,
    required this.monthEnd,
    required this.points,
    required this.averagePct,
    required this.scoredDays,
    required this.totalDays,
  });

  factory _PrepareMonthStreakModel.fromConsistency(List<JournalDay> days) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    final byDate = <String, JournalDay>{};
    for (final day in days) {
      final date = _dayOnly(day.date);
      if (date.year == now.year && date.month == now.month) {
        byDate[_dateKey(date)] = day;
      }
    }

    final points = <_PrepareDayPoint>[];
    var sum = 0.0;
    var scoredDays = 0;
    final totalDays = monthEnd.day;

    for (var d = 1; d <= totalDays; d++) {
      final date = DateTime(now.year, now.month, d);
      final score = _scoreForDay(byDate[_dateKey(date)]);
      if (score != null) {
        sum += score;
        scoredDays += 1;
      }
      points.add(_PrepareDayPoint(date: date, score: score));
    }

    final averagePct = scoredDays == 0 ? 0.0 : sum / scoredDays;

    return _PrepareMonthStreakModel(
      monthStart: monthStart,
      monthEnd: monthEnd,
      points: points,
      averagePct: averagePct,
      scoredDays: scoredDays,
      totalDays: totalDays,
    );
  }

  static double? _scoreForDay(JournalDay? day) {
    if (day == null) return null;

    var plannedActivities = day.plannedActivityCount;
    if (plannedActivities <= 0) plannedActivities = day.plannedTargets;
    if (plannedActivities <= 0 && day.plannedMinutes > 0) {
      plannedActivities = 1;
    }
    if (plannedActivities <= 0 && day.isPlannedDay) {
      plannedActivities = 1;
    }
    if (plannedActivities <= 0) return null;

    var journaledActivities = day.actualActivityCount;
    if (journaledActivities <= 0) journaledActivities = day.actualTargets;
    if (journaledActivities <= 0 && day.actualMinutes > 0) {
      journaledActivities = 1;
    }
    if (journaledActivities <= 0 && day.isExecutedDay) {
      journaledActivities = 1;
    }

    return ((journaledActivities / plannedActivities).clamp(0.0, 1.0)) * 100.0;
  }

  static DateTime _dayOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class _PrepareDayPoint {
  final DateTime date;
  final double? score;

  const _PrepareDayPoint({
    required this.date,
    required this.score,
  });
}

class _MonthlyAverageBox extends StatelessWidget {
  final _PrepareMonthStreakModel model;

  const _MonthlyAverageBox({
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        '${_monthShort(model.monthStart.month)} ${model.monthStart.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title Avg',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${model.averagePct.round()}%',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${model.scoredDays}/${model.totalDays} days scored',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthGitHubHeatmap extends StatelessWidget {
  final _PrepareMonthStreakModel model;

  const _MonthGitHubHeatmap({
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final byDate = <String, _PrepareDayPoint>{
      for (final point in model.points) _dateKey(point.date): point,
    };

    final gridStart = model.monthStart.subtract(
      Duration(days: model.monthStart.weekday - 1),
    );
    final gridEnd =
        model.monthEnd.add(Duration(days: 7 - model.monthEnd.weekday));
    final total = gridEnd.difference(gridStart).inDays + 1;
    final weeks = (total / 7).ceil();
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    DateTime dayAt(int week, int dow) =>
        gridStart.add(Duration(days: week * 7 + dow));

    return LayoutBuilder(
      builder: (context, constraints) {
        const labelWidth = 16.0;
        const gap = 3.0;
        final usableWidth =
            constraints.maxWidth - labelWidth - (weeks - 1) * gap;
        final cellSize = usableWidth > 0 ? usableWidth / weeks : 9.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(7, (dow) {
              return Padding(
                padding: EdgeInsets.only(bottom: dow == 6 ? 0 : gap),
                child: Row(
                  children: [
                    SizedBox(
                      width: labelWidth,
                      child: Text(
                        labels[dow],
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ...List.generate(weeks, (week) {
                      final date = dayAt(week, dow);
                      final inMonth = !date.isBefore(model.monthStart) &&
                          !date.isAfter(model.monthEnd);
                      final point = byDate[_dateKey(date)];
                      final score = point?.score;
                      final color = _heatColor(
                        context,
                        inMonth: inMonth,
                        score: score,
                      );

                      return Padding(
                        padding:
                            EdgeInsets.only(right: week == weeks - 1 ? 0 : gap),
                        child: Tooltip(
                          message: inMonth
                              ? '${date.day}/${date.month} • ${score == null ? 'No plan' : '${score.round()}%'}'
                              : '',
                          child: Container(
                            width: cellSize,
                            height: cellSize,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Less',
                  style: TextStyle(fontSize: 9.5, color: context.fgSub),
                ),
                const SizedBox(width: 4),
                _heatLegendDot(context, context.danger),
                _heatLegendDot(context, const Color(0xFF8BD7A2)),
                _heatLegendDot(context, const Color(0xFF4CAE6E)),
                _heatLegendDot(context, const Color(0xFF1C6B3E)),
                const SizedBox(width: 4),
                Text(
                  'More',
                  style: TextStyle(fontSize: 9.5, color: context.fgSub),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Color _heatColor(
    BuildContext context, {
    required bool inMonth,
    required double? score,
  }) {
    if (!inMonth) return context.stroke.withValues(alpha: 0.1);
    if (score == null) return context.stroke.withValues(alpha: 0.35);
    if (score <= 0) return context.danger;
    if (score <= 39) return const Color(0xFF8BD7A2);
    if (score <= 74) return const Color(0xFF4CAE6E);
    return const Color(0xFF1C6B3E);
  }

  Widget _heatLegendDot(BuildContext context, Color color) {
    return Container(
      width: 9,
      height: 9,
      margin: const EdgeInsets.symmetric(horizontal: 1.2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

String _monthShort(int month) {
  const names = [
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
    'Dec',
  ];
  return names[(month - 1).clamp(0, 11)];
}

String _dateKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
