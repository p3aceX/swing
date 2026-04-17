import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../shared/apex_theme.dart';
import '../../../elite/controller/elite_controller.dart';
import '../../../elite/domain/elite_models.dart';
import '../../../health/controller/diet_controller.dart';
import '../../../health/controller/fitness_controller.dart';
import '../../../health/data/diet_repository.dart';
import '../../../health/domain/diet_models.dart';
import '../../../health/domain/fitness_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  JournalFlow — launcher sheet
//
//  Shows three independent log options. Each opens its own focused sheet.
//  Training log reads today's plan — only planned activities shown.
// ─────────────────────────────────────────────────────────────────────────────

class JournalFlow extends ConsumerWidget {
  const JournalFlow({super.key});

  static const _kWeekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(weeklyPlanProvider);
    final today = _kWeekdays[DateTime.now().weekday - 1];
    final todayPlan = planAsync.asData?.value?.days
        .cast<WeeklyPlanDay?>()
        .firstWhere((d) => d?.weekday == today, orElse: () => null);

    return Container(
      decoration: const BoxDecoration(
        color: ApexColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 32, height: 3,
                  decoration: BoxDecoration(
                    color: ApexColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Text(
                DateFormat('EEEE, d MMM').format(DateTime.now()).toUpperCase(),
                style: ApexTextStyles.labelCaps,
              ),
              const SizedBox(height: 4),
              const Text(
                'What do you want to log?',
                style: TextStyle(
                  color: ApexColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),

              // Training card
              _LaunchCard(
                icon: Icons.sports_cricket_rounded,
                title: 'Training',
                subtitle: _buildTrainSubtitle(todayPlan, today),
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => TrainingLogSheet(todayPlan: todayPlan),
                  ).then((_) {
                    if (context.mounted) Navigator.of(context).pop();
                  });
                },
              ),
              const SizedBox(height: 10),

              // Exercises card
              _LaunchCard(
                icon: Icons.fitness_center_rounded,
                title: 'Exercises',
                subtitle: 'Search & log gym or conditioning exercises',
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const ExerciseLogSheet(),
                  ).then((_) {
                    if (context.mounted) Navigator.of(context).pop();
                  });
                },
              ),
              const SizedBox(height: 10),

              // Meal card
              _LaunchCard(
                icon: Icons.restaurant_rounded,
                title: 'Meal',
                subtitle: 'Log what you ate — search from food library',
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const MealLogSheet(),
                  ).then((_) {
                    if (context.mounted) Navigator.of(context).pop();
                  });
                },
              ),
              const SizedBox(height: 10),

              // Body card
              _LaunchCard(
                icon: Icons.monitor_weight_rounded,
                title: 'Body',
                subtitle: 'Log weight, sleep, and energy level',
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const BodyLogSheet(),
                  ).then((_) {
                    if (context.mounted) Navigator.of(context).pop();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildTrainSubtitle(WeeklyPlanDay? plan, String today) {
    if (plan == null) return 'Log today\'s training session';
    final activities = <String>[];
    if (plan.hasNets || plan.netsMinutes > 0) activities.add('Nets');
    if (plan.hasGym || (plan.fitnessMinutes > 0 && !plan.hasConditioning)) activities.add('Gym');
    if (plan.hasConditioning) activities.add('Conditioning');
    if (plan.hasSkillWork || plan.drillsMinutes > 0) activities.add('Drills');
    if (plan.hasMatch) activities.add('Match');
    if (plan.hasRecovery || plan.recoveryMinutes > 0) activities.add('Recovery');
    if (activities.isEmpty) return 'Rest day planned — log anyway?';
    return 'Planned: ${activities.join(', ')}';
  }
}

class _LaunchCard extends StatelessWidget {
  const _LaunchCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: ApexColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ApexColors.border, width: 0.5),
        ),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: ApexColors.surfaceHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ApexColors.border, width: 0.5),
            ),
            child: Icon(icon, size: 18, color: ApexColors.textPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: ApexColors.textPrimary,
                        fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: ApexColors.textMuted, fontSize: 12,
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 12, color: ApexColors.textDim),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Training Log Sheet
// ─────────────────────────────────────────────────────────────────────────────

class TrainingLogSheet extends ConsumerStatefulWidget {
  const TrainingLogSheet({super.key, required this.todayPlan});
  final WeeklyPlanDay? todayPlan;

  @override
  ConsumerState<TrainingLogSheet> createState() => _TrainingLogSheetState();
}

class _TrainingLogSheetState extends ConsumerState<TrainingLogSheet> {
  late final List<_ActivityEntry> _activities;
  bool _saving = false;

  static const _allActivities = [
    ('NETS',         'Nets',         Icons.sports_cricket_rounded),
    ('GYM',          'Gym',          Icons.fitness_center_rounded),
    ('CONDITIONING', 'Conditioning', Icons.bolt_rounded),
    ('DRILLS',       'Skill Drills', Icons.track_changes_rounded),
    ('MATCH',        'Match',        Icons.emoji_events_rounded),
    ('RECOVERY',     'Recovery',     Icons.favorite_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _activities = _buildActivities(widget.todayPlan);
  }

  List<_ActivityEntry> _buildActivities(WeeklyPlanDay? plan) {
    if (plan == null) return [];
    final list = <_ActivityEntry>[];
    for (final a in _allActivities) {
      final key = a.$1;
      final planned = _isPlanned(plan, key);
      if (planned) {
        list.add(_ActivityEntry(
          key: key,
          label: a.$2,
          icon: a.$3,
          checked: true,
          minutes: _plannedMinutes(plan, key),
          fromPlan: true,
        ));
      }
    }
    return list;
  }

  bool _isPlanned(WeeklyPlanDay plan, String key) {
    switch (key) {
      case 'NETS': return plan.hasNets || plan.netsMinutes > 0;
      case 'GYM': return plan.hasGym || (plan.fitnessMinutes > 0 && !plan.hasConditioning);
      case 'CONDITIONING': return plan.hasConditioning;
      case 'DRILLS': return plan.hasSkillWork || plan.drillsMinutes > 0;
      case 'MATCH': return plan.hasMatch;
      case 'RECOVERY': return plan.hasRecovery || plan.recoveryMinutes > 0;
    }
    return false;
  }

  int _plannedMinutes(WeeklyPlanDay plan, String key) {
    switch (key) {
      case 'NETS': return plan.netsMinutes > 0 ? plan.netsMinutes : 60;
      case 'GYM': case 'CONDITIONING': return plan.fitnessMinutes > 0 ? plan.fitnessMinutes : 60;
      case 'DRILLS': return plan.drillsMinutes > 0 ? plan.drillsMinutes : 45;
      case 'RECOVERY': return plan.recoveryMinutes > 0 ? plan.recoveryMinutes : 30;
    }
    return 60;
  }

  void _addUnplanned(String key) {
    if (_activities.any((a) => a.key == key)) return;
    final def = _allActivities.firstWhere((a) => a.$1 == key);
    setState(() => _activities.add(_ActivityEntry(
      key: key, label: def.$2, icon: def.$3,
      checked: true, minutes: 60, fromPlan: false,
    )));
  }

  Future<void> _submit() async {
    final checked = _activities.where((a) => a.checked).toList();
    if (checked.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _saving = true);
    for (final act in checked) {
      final ctrl = ref.read(activityJournalControllerProvider.notifier);
      final entry = ActivityJournalEntry(
        date: DateTime.now(),
        activity: _mapKey(act.key),
        vitals: const DailyVitals(sleepHours: 0, hydrationLiters: 0),
        takeaway: 'Logged via APEX plan.',
        netsDetail: act.key == 'NETS'
            ? NetsJournalDetail(drills: const [], whatClicked: '', whatNeedsWork: '', rating: act.intensity)
            : null,
        gymDetail: act.key == 'GYM'
            ? GymJournalDetail(focus: GymFocus.mixed, energyLevel: act.intensity, note: '')
            : null,
      );
      await ctrl.submit(entry);
    }

    // If gym/conditioning — also submit exercises if any added
    final fitState = ref.read(fitnessLogControllerProvider);
    if (fitState.session.exercises.isNotEmpty) {
      await ref.read(fitnessLogControllerProvider.notifier).submit();
    }

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(_snackBar('Training logged.'));
  }

  ActivityCategory _mapKey(String k) => switch (k) {
    'NETS' => ActivityCategory.nets,
    'GYM' => ActivityCategory.gym,
    'CONDITIONING' => ActivityCategory.conditioning,
    'DRILLS' => ActivityCategory.skillWork,
    'MATCH' => ActivityCategory.match,
    _ => ActivityCategory.recovery,
  };

  @override
  Widget build(BuildContext context) {
    final unplannedKeys = _allActivities
        .where((a) => !_activities.any((e) => e.key == a.$1))
        .toList();
    final isRestDay = widget.todayPlan != null && _activities.isEmpty;

    return _LogSheet(
      title: 'Training Log',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan context badge
          _ContextBadge(
            text: widget.todayPlan == null
                ? 'No plan — log freely'
                : isRestDay
                    ? 'Rest day planned'
                    : 'From your weekly plan',
          ),
          const SizedBox(height: 16),

          if (_activities.isEmpty && !isRestDay)
            const _EmptyHint(message: 'No activities planned — add below'),

          ..._activities.map((act) => _ActivityRow(
            activity: act,
            onToggle: () => setState(() => act.checked = !act.checked),
            onMinutesChanged: (v) => setState(() => act.minutes = v),
            onIntensityChanged: (v) => setState(() => act.intensity = v),
          )),

          // Add unplanned / cheat day
          if (unplannedKeys.isNotEmpty) ...[
            const SizedBox(height: 12),
            _AddActivityPicker(
              label: isRestDay || _activities.isEmpty
                  ? 'Add activity'
                  : 'Add different activity',
              options: unplannedKeys,
              onSelected: _addUnplanned,
            ),
          ],
        ],
      ),
      saving: _saving,
      onSubmit: _submit,
      submitLabel: 'Save Training',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Exercise Log Sheet
// ─────────────────────────────────────────────────────────────────────────────

class ExerciseLogSheet extends ConsumerStatefulWidget {
  const ExerciseLogSheet({super.key});

  @override
  ConsumerState<ExerciseLogSheet> createState() => _ExerciseLogSheetState();
}

class _ExerciseLogSheetState extends ConsumerState<ExerciseLogSheet> {
  String _query = '';
  bool _saving = false;

  Future<void> _submit() async {
    final fitState = ref.read(fitnessLogControllerProvider);
    if (fitState.session.exercises.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _saving = true);
    final ok = await ref.read(fitnessLogControllerProvider.notifier).submit();
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      _snackBar(ok ? 'Exercises logged.' : 'Failed to save — try again.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fitState = ref.watch(fitnessLogControllerProvider);
    final searchAsync = ref.watch(fitnessSearchProvider);

    return _LogSheet(
      title: 'Exercise Log',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Added exercises
          if (fitState.session.exercises.isNotEmpty) ...[
            const _SubSectionLabel(label: 'LOGGED EXERCISES'),
            const SizedBox(height: 10),
            ...fitState.session.exercises.map((ex) => _ExerciseChip(
              exercise: ex.exercise,
              sets: ex.sets,
              reps: ex.reps,
              onRemove: () => ref
                  .read(fitnessLogControllerProvider.notifier)
                  .removeExercise(ex.exercise.id),
            )),
            const SizedBox(height: 20),
          ],

          const _SubSectionLabel(label: 'SEARCH EXERCISES'),
          const SizedBox(height: 10),
          _SearchField(
            hint: 'e.g. squat, push-up, sprint...',
            query: _query,
            onChanged: (q) => setState(() => _query = q),
          ),
          const SizedBox(height: 8),

          if (_query.length >= 2)
            searchAsync.when(
              loading: () => const _SearchLoading(),
              error: (_, __) => const SizedBox.shrink(),
              data: (items) => items.isEmpty
                  ? const _EmptyHint(message: 'No exercises found')
                  : Column(
                      children: items.take(10).map((ex) => _ExerciseResult(
                        exercise: ex,
                        isAdded: fitState.session.exercises
                            .any((e) => e.exercise.id == ex.id),
                        onAdd: () {
                          HapticFeedback.selectionClick();
                          ref
                              .read(fitnessLogControllerProvider.notifier)
                              .addExercise(ex);
                        },
                      )).toList(),
                    ),
            )
          else
            const _SearchHint(message: 'Type to search exercise library'),
        ],
      ),
      saving: _saving,
      onSubmit: _submit,
      submitLabel: 'Save Exercises',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Meal Log Sheet
// ─────────────────────────────────────────────────────────────────────────────

class MealLogSheet extends ConsumerStatefulWidget {
  const MealLogSheet({super.key});

  @override
  ConsumerState<MealLogSheet> createState() => _MealLogSheetState();
}

class _MealLogSheetState extends ConsumerState<MealLogSheet> {
  MealType _mealType = MealType.lunch;
  final List<DietLogEntry> _items = [];
  int _waterMl = 0;
  String _query = '';
  bool _saving = false;

  Future<void> _submit() async {
    if (_items.isEmpty && _waterMl == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _saving = true);
    try {
      final notifier = ref.read(dietLogProvider.notifier);
      notifier.reset();
      notifier.setMealType(_mealType);
      for (final e in _items) {
        notifier.addItem(e.item);
      }
      notifier.setWater(_waterMl);
      await notifier.submit(DietRepository());
    } catch (_) {}
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(_snackBar('Meal logged.'));
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(nutritionSearchProvider(_query));
    final totalCals = _items.fold<double>(0, (s, e) => s + e.item.calories * e.servings);

    return _LogSheet(
      title: 'Meal Log',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal type
          const _SubSectionLabel(label: 'MEAL TYPE'),
          const SizedBox(height: 10),
          _MealTypePicker(
            selected: _mealType,
            onChanged: (t) => setState(() => _mealType = t),
          ),
          const SizedBox(height: 20),

          // Logged items
          if (_items.isNotEmpty) ...[
            Row(children: [
              const _SubSectionLabel(label: 'ADDED ITEMS'),
              const Spacer(),
              Text('${totalCals.round()} kcal',
                  style: const TextStyle(
                      color: ApexColors.textMuted, fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 8),
            ..._items.map((e) => _FoodChip(
              entry: e,
              onRemove: () => setState(
                  () => _items.removeWhere((i) => i.item.id == e.item.id)),
            )),
            const SizedBox(height: 16),
          ],

          // Search
          const _SubSectionLabel(label: 'SEARCH FOOD'),
          const SizedBox(height: 10),
          _SearchField(
            hint: 'e.g. rice, chicken, banana...',
            query: _query,
            onChanged: (q) => setState(() => _query = q),
          ),
          const SizedBox(height: 8),

          if (_query.length >= 2)
            searchAsync.when(
              loading: () => const _SearchLoading(),
              error: (_, __) => const SizedBox.shrink(),
              data: (items) => items.isEmpty
                  ? const _EmptyHint(message: 'No results')
                  : Column(
                      children: items.take(8).map((item) => _FoodResult(
                        item: item,
                        isAdded: _items.any((e) => e.item.id == item.id),
                        onAdd: () => setState(() {
                          final idx = _items.indexWhere((e) => e.item.id == item.id);
                          if (idx >= 0) {
                            _items[idx] = DietLogEntry(
                                item: _items[idx].item,
                                servings: _items[idx].servings + 1);
                          } else {
                            _items.add(DietLogEntry(item: item, servings: 1));
                          }
                        }),
                      )).toList(),
                    ),
            )
          else
            const _SearchHint(message: 'Type 2+ characters to search'),

          const SizedBox(height: 24),

          // Water
          const _SubSectionLabel(label: 'WATER'),
          const SizedBox(height: 10),
          _WaterPicker(
            waterMl: _waterMl,
            onChanged: (ml) => setState(() => _waterMl = ml),
          ),
        ],
      ),
      saving: _saving,
      onSubmit: _submit,
      submitLabel: 'Save Meal',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Body Log Sheet
// ─────────────────────────────────────────────────────────────────────────────

class BodyLogSheet extends ConsumerStatefulWidget {
  const BodyLogSheet({super.key});

  @override
  ConsumerState<BodyLogSheet> createState() => _BodyLogSheetState();
}

class _BodyLogSheetState extends ConsumerState<BodyLogSheet> {
  double _weightKg = 0;
  double _sleepHours = 7;
  int _energyLevel = 7;
  bool _saving = false;

  Future<void> _submit() async {
    setState(() => _saving = true);
    // Log as journal vitals entry
    final ctrl = ref.read(activityJournalControllerProvider.notifier);
    await ctrl.submit(ActivityJournalEntry(
      date: DateTime.now(),
      activity: ActivityCategory.recovery,
      vitals: DailyVitals(
        sleepHours: _sleepHours,
        hydrationLiters: 0,
      ),
      takeaway: _weightKg > 0
          ? 'Body check-in: ${_weightKg.toStringAsFixed(1)}kg, sleep ${_sleepHours.toStringAsFixed(1)}h, energy $_energyLevel/10.'
          : 'Body check-in via APEX.',
    ));
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(_snackBar('Body check-in saved.'));
  }

  @override
  Widget build(BuildContext context) {
    return _LogSheet(
      title: 'Body Check-in',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SubSectionLabel(label: 'BODY WEIGHT'),
          const SizedBox(height: 10),
          _WeightInput(
            weightKg: _weightKg,
            onChanged: (v) => setState(() => _weightKg = v),
          ),
          const SizedBox(height: 24),

          _SliderField(
            label: 'SLEEP',
            value: _sleepHours,
            min: 3, max: 12, divisions: 18,
            display: '${_sleepHours.toStringAsFixed(1)} hrs',
            onChanged: (v) => setState(() => _sleepHours = v),
          ),
          const SizedBox(height: 20),

          _SliderField(
            label: 'ENERGY',
            value: _energyLevel.toDouble(),
            min: 1, max: 10, divisions: 9,
            display: '$_energyLevel / 10',
            onChanged: (v) => setState(() => _energyLevel = v.round()),
          ),
        ],
      ),
      saving: _saving,
      onSubmit: _submit,
      submitLabel: 'Save Check-in',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared shell — _LogSheet wraps every log screen with header + submit
// ─────────────────────────────────────────────────────────────────────────────

class _LogSheet extends StatelessWidget {
  const _LogSheet({
    required this.title,
    required this.child,
    required this.saving,
    required this.onSubmit,
    required this.submitLabel,
  });

  final String title;
  final Widget child;
  final bool saving;
  final VoidCallback onSubmit;
  final String submitLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: ApexColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 32, height: 3,
              decoration: BoxDecoration(
                color: ApexColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close_rounded,
                    color: ApexColors.textMuted, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: const TextStyle(
                      color: ApexColors.textPrimary, fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(
                DateFormat('EEE, d MMM').format(DateTime.now()),
                style: const TextStyle(
                    color: ApexColors.textDim, fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ]),
          ),
          const SizedBox(height: 4),
          Container(height: 0.5, color: ApexColors.border),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: child,
            ),
          ),

          // Submit
          Container(height: 0.5, color: ApexColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: GestureDetector(
              onTap: saving ? null : () {
                HapticFeedback.mediumImpact();
                onSubmit();
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: saving
                      ? ApexColors.surfaceHigh
                      : ApexColors.accentAim,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: saving
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(submitLabel,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14,
                              fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Activity entry model
// ─────────────────────────────────────────────────────────────────────────────

class _ActivityEntry {
  _ActivityEntry({
    required this.key,
    required this.label,
    required this.icon,
    required this.checked,
    required this.minutes,
    required this.fromPlan,
    this.intensity = 7,
  });

  final String key;
  final String label;
  final IconData icon;
  bool checked;
  int minutes;
  int intensity;
  final bool fromPlan;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Training — activity row
// ─────────────────────────────────────────────────────────────────────────────

class _ActivityRow extends StatefulWidget {
  const _ActivityRow({
    required this.activity,
    required this.onToggle,
    required this.onMinutesChanged,
    required this.onIntensityChanged,
  });

  final _ActivityEntry activity;
  final VoidCallback onToggle;
  final ValueChanged<int> onMinutesChanged;
  final ValueChanged<int> onIntensityChanged;

  @override
  State<_ActivityRow> createState() => _ActivityRowState();
}

class _ActivityRowState extends State<_ActivityRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final act = widget.activity;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: act.checked ? ApexColors.surfaceHigh : ApexColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: act.checked ? ApexColors.borderMid : ApexColors.border,
          width: act.checked ? 1 : 0.5,
        ),
      ),
      child: Column(
        children: [
          // Main row
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(children: [
                GestureDetector(
                  onTap: widget.onToggle,
                  child: Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: act.checked
                          ? ApexColors.textPrimary.withValues(alpha: 0.9)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: act.checked
                            ? ApexColors.textPrimary
                            : ApexColors.border,
                      ),
                    ),
                    child: act.checked
                        ? const Icon(Icons.check_rounded,
                            size: 14, color: ApexColors.background)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(act.icon, size: 15, color: ApexColors.textPrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(act.label,
                            style: TextStyle(
                                color: act.checked
                                    ? ApexColors.textPrimary
                                    : ApexColors.textMuted,
                                fontSize: 13, fontWeight: FontWeight.w700)),
                        if (act.fromPlan) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: ApexColors.border,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text('PLAN',
                                style: TextStyle(
                                    color: ApexColors.textDim,
                                    fontSize: 8, fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5)),
                          ),
                        ],
                      ]),
                      Text('${act.minutes} min · intensity ${act.intensity}/10',
                          style: const TextStyle(
                              color: ApexColors.textDim, fontSize: 10)),
                    ],
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 16, color: ApexColors.textDim,
                ),
              ]),
            ),
          ),

          // Expanded — edit minutes + intensity
          if (_expanded && act.checked)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  Container(height: 0.5, color: ApexColors.border),
                  const SizedBox(height: 12),
                  _SliderField(
                    label: 'DURATION',
                    value: act.minutes.toDouble(),
                    min: 15, max: 180, divisions: 33,
                    display: '${act.minutes} min',
                    onChanged: (v) => widget.onMinutesChanged(v.round()),
                  ),
                  const SizedBox(height: 12),
                  _SliderField(
                    label: 'INTENSITY',
                    value: act.intensity.toDouble(),
                    min: 1, max: 10, divisions: 9,
                    display: '${act.intensity} / 10',
                    onChanged: (v) => widget.onIntensityChanged(v.round()),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Add unplanned activity picker
// ─────────────────────────────────────────────────────────────────────────────

class _AddActivityPicker extends StatefulWidget {
  const _AddActivityPicker({
    required this.label,
    required this.options,
    required this.onSelected,
  });
  final String label;
  final List<(String, String, IconData)> options;
  final ValueChanged<String> onSelected;

  @override
  State<_AddActivityPicker> createState() => _AddActivityPickerState();
}

class _AddActivityPickerState extends State<_AddActivityPicker> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: Row(children: [
            const Icon(Icons.add_rounded, size: 14, color: ApexColors.textMuted),
            const SizedBox(width: 6),
            Text(widget.label,
                style: const TextStyle(
                    color: ApexColors.textMuted, fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
        if (_open) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.options.map((opt) => GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onSelected(opt.$1);
                setState(() => _open = false);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: ApexColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ApexColors.border, width: 0.5),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(opt.$3, size: 13, color: ApexColors.textMuted),
                  const SizedBox(width: 6),
                  Text(opt.$2,
                      style: const TextStyle(
                          color: ApexColors.textMuted, fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared form widgets — all monochrome
// ─────────────────────────────────────────────────────────────────────────────

class _SubSectionLabel extends StatelessWidget {
  const _SubSectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: ApexTextStyles.labelCaps.copyWith(fontSize: 9));
  }
}

class _ContextBadge extends StatelessWidget {
  const _ContextBadge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ApexColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ApexColors.border, width: 0.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.calendar_today_rounded, size: 11, color: ApexColors.textDim),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(
                color: ApexColors.textDim, fontSize: 11,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(message,
          style: const TextStyle(
              color: ApexColors.textDim, fontSize: 12,
              fontStyle: FontStyle.italic)),
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(message,
          style: const TextStyle(
              color: ApexColors.textDim, fontSize: 12,
              fontStyle: FontStyle.italic)),
    );
  }
}

class _SearchLoading extends StatelessWidget {
  const _SearchLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 18, height: 18,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: ApexColors.textMuted),
        ),
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.hint,
    required this.query,
    required this.onChanged,
  });
  final String hint;
  final String query;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.query);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ApexColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ApexColors.border, width: 0.5),
      ),
      child: TextField(
        controller: _ctrl,
        style: const TextStyle(
            color: ApexColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: ApexColors.textDim, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded,
              color: ApexColors.textDim, size: 17),
          suffixIcon: _ctrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: ApexColors.textDim, size: 15),
                  onPressed: () {
                    _ctrl.clear();
                    widget.onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}

// Exercise search result
class _ExerciseResult extends StatelessWidget {
  const _ExerciseResult({
    required this.exercise,
    required this.isAdded,
    required this.onAdd,
  });
  final FitnessExercise exercise;
  final bool isAdded;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ApexColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ApexColors.border, width: 0.5),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(exercise.name,
                style: const TextStyle(
                    color: ApexColors.textPrimary,
                    fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(
              [
                exercise.category,
                if (exercise.defaultSets != null)
                  '${exercise.defaultSets}×${exercise.defaultReps ?? '?'}',
              ].join(' · '),
              style: const TextStyle(color: ApexColors.textDim, fontSize: 10),
            ),
          ]),
        ),
        GestureDetector(
          onTap: isAdded ? null : () {
            HapticFeedback.selectionClick();
            onAdd();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: ApexColors.surfaceHigh,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: ApexColors.border, width: 0.5),
            ),
            child: Text(isAdded ? 'Added' : '+ Add',
                style: TextStyle(
                    color: isAdded ? ApexColors.textDim : ApexColors.textPrimary,
                    fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}

// Exercise chip (added)
class _ExerciseChip extends StatelessWidget {
  const _ExerciseChip({
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.onRemove,
  });
  final FitnessExercise exercise;
  final int sets;
  final int reps;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ApexColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ApexColors.borderMid, width: 0.5),
      ),
      child: Row(children: [
        const Icon(Icons.check_rounded, size: 13, color: ApexColors.textPrimary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(exercise.name,
                style: const TextStyle(
                    color: ApexColors.textPrimary,
                    fontSize: 12, fontWeight: FontWeight.w700)),
            Text('$sets × $reps',
                style: const TextStyle(
                    color: ApexColors.textDim, fontSize: 10)),
          ]),
        ),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(Icons.close_rounded,
              size: 15, color: ApexColors.textDim),
        ),
      ]),
    );
  }
}

// Food search result
class _FoodResult extends StatelessWidget {
  const _FoodResult({
    required this.item,
    required this.isAdded,
    required this.onAdd,
  });
  final NutritionItem item;
  final bool isAdded;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ApexColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ApexColors.border, width: 0.5),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name,
                style: const TextStyle(
                    color: ApexColors.textPrimary,
                    fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(
              '${item.calories.round()} kcal · P ${item.proteinG.round()}g · C ${item.carbsG.round()}g · F ${item.fatG.round()}g',
              style: const TextStyle(color: ApexColors.textDim, fontSize: 10),
            ),
          ]),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: isAdded ? null : () {
            HapticFeedback.selectionClick();
            onAdd();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: ApexColors.surfaceHigh,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: ApexColors.border, width: 0.5),
            ),
            child: Text(isAdded ? 'Added' : '+ Add',
                style: TextStyle(
                    color: isAdded ? ApexColors.textDim : ApexColors.textPrimary,
                    fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}

// Food chip (added)
class _FoodChip extends StatelessWidget {
  const _FoodChip({required this.entry, required this.onRemove});
  final DietLogEntry entry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ApexColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ApexColors.borderMid, width: 0.5),
      ),
      child: Row(children: [
        const Icon(Icons.check_rounded, size: 13, color: ApexColors.textPrimary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(entry.item.name,
                style: const TextStyle(
                    color: ApexColors.textPrimary,
                    fontSize: 12, fontWeight: FontWeight.w700)),
            Text(
              '${entry.servings.toStringAsFixed(1)} serving · ${(entry.item.calories * entry.servings).round()} kcal',
              style: const TextStyle(color: ApexColors.textDim, fontSize: 10),
            ),
          ]),
        ),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(Icons.close_rounded,
              size: 15, color: ApexColors.textDim),
        ),
      ]),
    );
  }
}

// Meal type picker
class _MealTypePicker extends StatelessWidget {
  const _MealTypePicker({required this.selected, required this.onChanged});
  final MealType selected;
  final ValueChanged<MealType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: MealType.values.map((t) {
        final isSelected = t == selected;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(t);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? ApexColors.surfaceHigh : ApexColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? ApexColors.borderMid : ApexColors.border,
                width: isSelected ? 1 : 0.5,
              ),
            ),
            child: Text(t.label,
                style: TextStyle(
                    color: isSelected
                        ? ApexColors.textPrimary
                        : ApexColors.textMuted,
                    fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        );
      }).toList(),
    );
  }
}

// Water picker
class _WaterPicker extends StatelessWidget {
  const _WaterPicker({required this.waterMl, required this.onChanged});
  final int waterMl;
  final ValueChanged<int> onChanged;

  static const _options = [0, 250, 500, 750, 1000, 1500, 2000, 2500, 3000];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: _options.map((ml) {
        final isSelected = ml == waterMl;
        final label = ml == 0 ? 'None' : ml >= 1000 ? '${ml ~/ 1000}L' : '${ml}ml';
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(ml);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? ApexColors.surfaceHigh : ApexColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? ApexColors.borderMid : ApexColors.border,
                width: isSelected ? 1 : 0.5,
              ),
            ),
            child: Text(label,
                style: TextStyle(
                    color: isSelected
                        ? ApexColors.textPrimary
                        : ApexColors.textMuted,
                    fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        );
      }).toList(),
    );
  }
}

// Slider field
class _SliderField extends StatelessWidget {
  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: ApexTextStyles.labelCaps.copyWith(fontSize: 9)),
        const Spacer(),
        Text(display,
            style: const TextStyle(
                color: ApexColors.textPrimary, fontSize: 12,
                fontWeight: FontWeight.w800)),
      ]),
      SliderTheme(
        data: const SliderThemeData(
          trackHeight: 2,
          thumbColor: ApexColors.textPrimary,
          activeTrackColor: ApexColors.textPrimary,
          inactiveTrackColor: ApexColors.border,
          overlayColor: Colors.transparent,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
        ),
        child: Slider(
          value: value.clamp(min, max),
          min: min, max: max, divisions: divisions,
          onChanged: onChanged,
        ),
      ),
    ]);
  }
}

// Weight input
class _WeightInput extends StatefulWidget {
  const _WeightInput({required this.weightKg, required this.onChanged});
  final double weightKg;
  final ValueChanged<double> onChanged;

  @override
  State<_WeightInput> createState() => _WeightInputState();
}

class _WeightInputState extends State<_WeightInput> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.weightKg > 0 ? widget.weightKg.toStringAsFixed(1) : '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ApexColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ApexColors.border, width: 0.5),
      ),
      child: Row(children: [
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: _ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
                color: ApexColors.textPrimary, fontSize: 28,
                fontWeight: FontWeight.w800),
            decoration: const InputDecoration(
              hintText: '—',
              hintStyle: TextStyle(
                  color: ApexColors.textDim, fontSize: 28,
                  fontWeight: FontWeight.w300),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
            onChanged: (v) {
              final parsed = double.tryParse(v);
              if (parsed != null) widget.onChanged(parsed);
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: ApexColors.surfaceHigh,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: ApexColors.border, width: 0.5),
          ),
          child: const Text('KG',
              style: TextStyle(
                  color: ApexColors.textMuted, fontSize: 12,
                  fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Helpers
// ─────────────────────────────────────────────────────────────────────────────

SnackBar _snackBar(String message) => SnackBar(
      backgroundColor: ApexColors.surfaceHigh,
      content: Text(message,
          style: const TextStyle(
              color: ApexColors.textPrimary, fontWeight: FontWeight.w600)),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
