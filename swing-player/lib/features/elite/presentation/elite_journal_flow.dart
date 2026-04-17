import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/storage/goal_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/elite_controller.dart';
import '../domain/elite_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Drill / recovery content libraries
// ─────────────────────────────────────────────────────────────────────────────

const _battingDrills = [
  'Cover Drive',
  'Straight Drive',
  'Pull Shot',
  'Hook Shot',
  'Sweep Shot',
  'Reverse Sweep',
  'Late Cut',
  'Flick Shot',
  'Yorker Defence',
  'Leave Outside Off',
];
const _bowlingDrills = [
  'Outswing',
  'Inswing',
  'Leg Cutter',
  'Off Cutter',
  'Yorker',
  'Bouncer',
  'Off Spin',
  'Leg Spin',
  'Googly',
  'Flipper',
];
const _fieldingDrills = [
  'Ground Fielding',
  'Catching',
  'Slip Catching',
  'Throw-down',
  'Boundary Fielding',
];
const _recoveryOptions = [
  'Ice Bath',
  'Physio',
  'Foam Roll',
  'Stretching',
  'Yoga',
  'Rest',
];

const _activityIcons = {
  ActivityCategory.nets: Icons.sports_cricket_rounded,
  ActivityCategory.skillWork: Icons.adjust_rounded,
  ActivityCategory.conditioning: Icons.directions_run_rounded,
  ActivityCategory.gym: Icons.fitness_center_rounded,
  ActivityCategory.match: Icons.emoji_events_rounded,
  ActivityCategory.recovery: Icons.favorite_rounded,
};

// ─────────────────────────────────────────────────────────────────────────────
// Per-activity mutable form state
// ─────────────────────────────────────────────────────────────────────────────

class _ActivityFormState {
  // Nets
  List<String> netsDrills = [];
  final netsClicked = TextEditingController();
  final netsNeedsWork = TextEditingController();
  double netsRating = 7;

  // Skill Work
  final skillDrill = TextEditingController();
  double skillQuality = 7;
  final skillObs = TextEditingController();

  // Conditioning
  ConditioningType condType = ConditioningType.running;
  RunType runType = RunType.easy;
  final condObs = TextEditingController();

  // Gym
  GymFocus gymFocus = GymFocus.strength;
  double gymEnergy = 7;
  final gymNote = TextEditingController();

  // Match
  String matchRole = 'Batsman';
  final matchWell = TextEditingController();
  final matchFix = TextEditingController();
  double matchRating = 7;

  // Recovery
  List<String> recoveryTypes = [];
  BodyState bodyState = BodyState.okay;
  final recoveryNote = TextEditingController();

  void dispose() {
    netsClicked.dispose();
    netsNeedsWork.dispose();
    skillDrill.dispose();
    skillObs.dispose();
    condObs.dispose();
    gymNote.dispose();
    matchWell.dispose();
    matchFix.dispose();
    recoveryNote.dispose();
  }

  ActivityJournalEntry toEntry(
      ActivityCategory cat, DailyVitals vitals, String takeaway) {
    return ActivityJournalEntry(
      date: DateTime.now(),
      activity: cat,
      vitals: vitals,
      takeaway: takeaway,
      netsDetail: cat == ActivityCategory.nets
          ? NetsJournalDetail(
              drills: List.from(netsDrills),
              whatClicked: netsClicked.text.trim(),
              whatNeedsWork: netsNeedsWork.text.trim(),
              rating: netsRating.round(),
            )
          : null,
      skillWorkDetail: cat == ActivityCategory.skillWork
          ? SkillWorkJournalDetail(
              drillName: skillDrill.text.trim(),
              quality: skillQuality.round(),
              observation: skillObs.text.trim(),
            )
          : null,
      conditioningDetail: cat == ActivityCategory.conditioning
          ? ConditioningJournalDetail(
              type: condType,
              runType: condType == ConditioningType.running ? runType : null,
              observation: condObs.text.trim(),
            )
          : null,
      gymDetail: cat == ActivityCategory.gym
          ? GymJournalDetail(
              focus: gymFocus,
              energyLevel: gymEnergy.round(),
              note: gymNote.text.trim(),
            )
          : null,
      matchDetail: cat == ActivityCategory.match
          ? MatchJournalDetail(
              role: matchRole,
              executedWell: matchWell.text.trim(),
              toFix: matchFix.text.trim(),
              rating: matchRating.round(),
            )
          : null,
      recoveryDetail: cat == ActivityCategory.recovery
          ? RecoveryJournalDetail(
              types: List.from(recoveryTypes),
              bodyState: bodyState,
              note: recoveryNote.text.trim(),
            )
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Journal Flow Widget
// ─────────────────────────────────────────────────────────────────────────────

class EliteJournalFlow extends ConsumerStatefulWidget {
  const EliteJournalFlow({super.key});

  @override
  ConsumerState<EliteJournalFlow> createState() => _EliteJournalFlowState();
}

class _EliteJournalFlowState extends ConsumerState<EliteJournalFlow> {
  static const _planDayPrefsKey = 'elite_my_plan_selected_days_v1';

  // Phase 1 — activity selection
  final List<ActivityCategory> _selected = [];
  List<ActivityCategory> _plannedToday = [];
  bool _loadingPlannedToday = true;
  bool _isCheatDay = false;
  bool _selectionConfirmed = false;

  // Phase 2 — per-activity form states (created after confirmation)
  final Map<ActivityCategory, _ActivityFormState> _formStates = {};

  // Phase 3 — vitals (shared)
  double _sleepHours = 7.5;
  double _hydration = 3.0;

  // Phase 4 — reflection (shared)
  final _takeawayCtrl = TextEditingController();

  // PageView for phase 2+
  late PageController _pageCtrl;
  int _page = 0; // index within the confirmed-activity pages

  @override
  void initState() {
    super.initState();
    _bootstrapTodaySelection();
  }

  @override
  void dispose() {
    _takeawayCtrl.dispose();
    for (final s in _formStates.values) {
      s.dispose();
    }
    super.dispose();
  }

  Future<void> _bootstrapTodaySelection() async {
    final plannedToday = await _resolvePlannedActivitiesForToday();
    if (!mounted) return;
    setState(() {
      _plannedToday = plannedToday;
      _selected
        ..clear()
        ..addAll(plannedToday);
      _loadingPlannedToday = false;
    });
  }

  Future<List<ActivityCategory>> _resolvePlannedActivitiesForToday() async {
    try {
      final plan = await ref.read(myPlanProvider.future);
      if (plan == null || plan.activities.isEmpty) return const [];
      final storedDays = await _loadStoredDays();
      final today = DateTime.now().weekday; // Mon=1 ... Sun=7
      final out = <ActivityCategory>[];

      for (final activity in plan.activities) {
        final selectedDays = storedDays[activity.category];
        final days = (selectedDays != null && selectedDays.isNotEmpty)
            ? selectedDays
            : _defaultDaysForCount(activity.timesPerWeek);
        if (days.contains(today)) out.add(activity.category);
      }

      return out;
    } catch (_) {
      return const [];
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

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'Today';
    }
  }

  void _toggleActivity(ActivityCategory cat) {
    setState(() {
      if (_isCheatDay) _isCheatDay = false;
      if (_selected.contains(cat)) {
        _selected.remove(cat);
      } else {
        _selected.add(cat);
      }
    });
  }

  void _toggleCheatDay(bool enabled) {
    setState(() {
      _isCheatDay = enabled;
      if (enabled) {
        _selected.clear();
      } else {
        _selected
          ..clear()
          ..addAll(_plannedToday);
      }
    });
  }

  void _confirmSelection() {
    if (_selected.isEmpty && !_isCheatDay) return;
    // Build form states for each selected activity
    for (final cat in _selected) {
      _formStates.putIfAbsent(cat, () => _ActivityFormState());
    }
    _pageCtrl = PageController();
    setState(() {
      _selectionConfirmed = true;
      _page = 0;
    });
  }

  // Total pages = _selected.length (detail) + 1 (vitals) + 1 (reflect)
  int get _totalPages => _selected.length + 2;
  bool get _isVitalsPage => _page == _selected.length;
  bool get _isReflectPage => _page == _selected.length + 1;

  void _next() {
    if (_page < _totalPages - 1) {
      setState(() => _page++);
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _submit() async {
    final vitals = DailyVitals(
      sleepHours: _sleepHours,
      hydrationLiters: _hydration,
    );
    final takeaway = _takeawayCtrl.text.trim();

    // Submit one journal entry per selected activity
    final controller = ref.read(activityJournalControllerProvider.notifier);
    bool allOk = true;

    if (_isCheatDay) {
      final entry = ActivityJournalEntry(
        date: DateTime.now(),
        activity: ActivityCategory.recovery,
        vitals: vitals,
        takeaway: takeaway,
        isCheatDay: true,
        recoveryDetail: const RecoveryJournalDetail(
          types: ['Rest'],
          bodyState: BodyState.okay,
          note: 'Cheat day — no training logged.',
        ),
      );
      allOk = await controller.submit(entry);
    } else {
      for (final cat in _selected) {
        final state = _formStates[cat]!;
        final entry = state.toEntry(cat, vitals, takeaway);
        final ok = await controller.submit(entry);
        if (!ok) {
          allOk = false;
          break;
        }
      }
    }

    if (!mounted) return;
    if (allOk) {
      await GoalStorage.saveJournalDate();
      await GoalStorage.saveCheatDayStatus(isCheatDay: _isCheatDay);
      if (!mounted) return;
      ref.read(journaledTodayProvider.notifier).state = true;
      ref.read(cheatDayTodayProvider.notifier).state = _isCheatDay;
      ref.invalidate(eliteProfileProvider);
      ref.invalidate(executionStreakProvider);
      ref.invalidate(journalConsistencyProvider(30));
      Navigator.of(context).pop();
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
    if (!_selectionConfirmed) {
      if (_loadingPlannedToday) {
        return Scaffold(
          backgroundColor: context.bg,
          appBar: AppBar(
            backgroundColor: context.bg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close, color: context.fg),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      return _ActivitySelectionScreen(
        selected: _selected,
        plannedToday: _plannedToday,
        weekdayLabel: _weekdayLabel(DateTime.now().weekday),
        isCheatDay: _isCheatDay,
        onCheatDayChanged: _toggleCheatDay,
        onToggle: _toggleActivity,
        onConfirm:
            (_selected.isNotEmpty || _isCheatDay) ? _confirmSelection : null,
      );
    }

    final isSubmitting = ref.watch(activityJournalControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: context.fg),
          onPressed: () {
            if (_page > 0) {
              setState(() => _page--);
              _pageCtrl.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut);
            } else {
              setState(() => _selectionConfirmed = false);
            }
          },
        ),
        title: _PageTitle(
          page: _page,
          activities: _selected,
          isVitals: _isVitalsPage,
          isReflect: _isReflectPage,
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _ProgressBar(current: _page, total: _totalPages),
        ),
      ),
      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // One detail page per activity
          ...List.generate(_selected.length, (i) {
            final cat = _selected[i];
            final formState = _formStates[cat]!;
            return _DetailPage(
              key: ValueKey(cat),
              category: cat,
              formState: formState,
              onChanged: () => setState(() {}),
              onNext: _next,
            );
          }),
          // Vitals
          _VitalsPage(
            sleepHours: _sleepHours,
            hydration: _hydration,
            onSleep: (v) => setState(() => _sleepHours = v),
            onHydration: (v) => setState(() => _hydration = v),
            onNext: _next,
          ),
          // Reflect
          _ReflectPage(
            takeaway: _takeawayCtrl,
            isSubmitting: isSubmitting,
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Activity Selection Screen (Phase 1)
// ─────────────────────────────────────────────────────────────────────────────

class _ActivitySelectionScreen extends StatefulWidget {
  final List<ActivityCategory> selected;
  final List<ActivityCategory> plannedToday;
  final String weekdayLabel;
  final bool isCheatDay;
  final ValueChanged<bool> onCheatDayChanged;
  final ValueChanged<ActivityCategory> onToggle;
  final VoidCallback? onConfirm;

  const _ActivitySelectionScreen({
    required this.selected,
    required this.plannedToday,
    required this.weekdayLabel,
    required this.isCheatDay,
    required this.onCheatDayChanged,
    required this.onToggle,
    required this.onConfirm,
  });

  @override
  State<_ActivitySelectionScreen> createState() =>
      _ActivitySelectionScreenState();
}

class _ActivitySelectionScreenState extends State<_ActivitySelectionScreen> {
  bool _showAdditionalActivities = false;

  @override
  Widget build(BuildContext context) {
    final planned = widget.plannedToday;
    final hasPlanned = planned.isNotEmpty;
    final additional =
        ActivityCategory.values.where((cat) => !planned.contains(cat)).toList();

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.fg),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('What did you do today?',
            style: TextStyle(
                color: context.fg, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: [
                Text(
                  'Hey, it\'s ${widget.weekdayLabel}.',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hasPlanned
                      ? 'Planned for ${widget.weekdayLabel} is pre-selected below. If plans changed, remove or add activities before continuing.'
                      : 'No activities were planned for ${widget.weekdayLabel}. Add what you actually did today.',
                  style: TextStyle(
                      color: context.fgSub, fontSize: 14, height: 1.5),
                ),
                if (!widget.isCheatDay && hasPlanned) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: planned.map((cat) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.accentBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: context.accent.withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_activityIcons[cat],
                                size: 12, color: context.accent),
                            const SizedBox(width: 5),
                            Text(
                              cat.label,
                              style: TextStyle(
                                color: context.accent,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => widget.onCheatDayChanged(!widget.isCheatDay),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                          widget.isCheatDay ? context.accentBg : context.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            widget.isCheatDay ? context.accent : context.stroke,
                        width: widget.isCheatDay ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.free_breakfast_rounded,
                          color: widget.isCheatDay
                              ? context.accent
                              : context.fgSub,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cheat Day (No Activity)',
                                style: TextStyle(
                                  color: widget.isCheatDay
                                      ? context.accent
                                      : context.fg,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'No training today. We\'ll only log vitals + reflection.',
                                style: TextStyle(
                                    color: context.fgSub, fontSize: 11.5),
                              ),
                            ],
                          ),
                        ),
                        if (widget.isCheatDay)
                          Icon(Icons.check_circle_rounded,
                              color: context.accent, size: 18),
                      ],
                    ),
                  ),
                ),
                if (widget.isCheatDay) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Cheat day selected. If plans changed and you trained, turn this off and choose activities below.',
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                if (!widget.isCheatDay && hasPlanned) ...[
                  Text(
                    'Planned today',
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: planned.map((cat) {
                      final isOn = widget.selected.contains(cat);
                      return _ActivityCard(
                        icon: _activityIcons[cat]!,
                        label: cat.label,
                        subtitle: cat.subtitle,
                        isSelected: isOn,
                        onTap: () => widget.onToggle(cat),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => setState(() =>
                        _showAdditionalActivities = !_showAdditionalActivities),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.stroke),
                      foregroundColor: context.fg,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 14,
                      ),
                    ),
                    icon: Icon(
                      _showAdditionalActivities
                          ? Icons.expand_less_rounded
                          : Icons.add_rounded,
                      size: 18,
                    ),
                    label: Text(
                      _showAdditionalActivities
                          ? 'Hide other activities'
                          : 'Add another activity',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (_showAdditionalActivities) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Other activities',
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: additional.map((cat) {
                        final isOn = widget.selected.contains(cat);
                        return _ActivityCard(
                          icon: _activityIcons[cat]!,
                          label: cat.label,
                          subtitle: cat.subtitle,
                          isSelected: isOn,
                          onTap: () => widget.onToggle(cat),
                        );
                      }).toList(),
                    ),
                  ],
                ] else if (!widget.isCheatDay) ...[
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: ActivityCategory.values.map((cat) {
                      final isOn = widget.selected.contains(cat);
                      return _ActivityCard(
                        icon: _activityIcons[cat]!,
                        label: cat.label,
                        subtitle: cat.subtitle,
                        isSelected: isOn,
                        onTap: () => widget.onToggle(cat),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: widget.onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: context.stroke,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    (!widget.isCheatDay && widget.selected.isEmpty)
                        ? 'Select at least one activity'
                        : widget.isCheatDay
                            ? 'Continue — Cheat day'
                            : 'Continue — ${widget.selected.length} ${widget.selected.length == 1 ? 'activity' : 'activities'}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? context.accentBg : context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? context.accent : context.stroke,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    size: 20,
                    color: isSelected ? context.accent : context.fgSub),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check_circle_rounded,
                      size: 16, color: context.accent),
              ],
            ),
            const Spacer(),
            Text(label,
                style: TextStyle(
                  color: isSelected ? context.accent : context.fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(color: context.fgSub, fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page Title & Progress
// ─────────────────────────────────────────────────────────────────────────────

class _PageTitle extends StatelessWidget {
  final int page;
  final List<ActivityCategory> activities;
  final bool isVitals;
  final bool isReflect;

  const _PageTitle({
    required this.page,
    required this.activities,
    required this.isVitals,
    required this.isReflect,
  });

  @override
  Widget build(BuildContext context) {
    if (isVitals) {
      return Text('Quick check-in',
          style: TextStyle(
              color: context.fg, fontSize: 16, fontWeight: FontWeight.w600));
    }
    if (isReflect) {
      return Text('Wrap-up',
          style: TextStyle(
              color: context.fg, fontSize: 16, fontWeight: FontWeight.w600));
    }
    final cat = activities[page];
    final suffix =
        activities.length > 1 ? ' (${page + 1}/${activities.length})' : '';
    return Text(
      '${cat.label}$suffix',
      style: TextStyle(
          color: context.fg, fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
          total,
          (i) => Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 3,
                  color: i <= current ? context.accent : context.stroke,
                ),
              )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail Page (one per activity)
// ─────────────────────────────────────────────────────────────────────────────

class _DetailPage extends StatelessWidget {
  final ActivityCategory category;
  final _ActivityFormState formState;
  final VoidCallback onChanged;
  final VoidCallback onNext;

  const _DetailPage({
    super.key,
    required this.category,
    required this.formState,
    required this.onChanged,
    required this.onNext,
  });

  String _intro(ActivityCategory cat) {
    return switch (cat) {
      ActivityCategory.nets => 'Nice. Let\'s quickly log your nets session.',
      ActivityCategory.skillWork =>
        'Great, let\'s capture the skill work details.',
      ActivityCategory.conditioning =>
        'Awesome, let\'s log your conditioning session.',
      ActivityCategory.gym => 'Solid. Let\'s record your gym work.',
      ActivityCategory.match => 'Big one. Let\'s log your match notes.',
      ActivityCategory.recovery => 'Recovery matters. Let\'s note it properly.',
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget form;
    switch (category) {
      case ActivityCategory.nets:
        form = _NetsForm(s: formState, onChanged: onChanged);
      case ActivityCategory.skillWork:
        form = _SkillWorkForm(s: formState, onChanged: onChanged);
      case ActivityCategory.conditioning:
        form = _ConditioningForm(s: formState, onChanged: onChanged);
      case ActivityCategory.gym:
        form = _GymForm(s: formState, onChanged: onChanged);
      case ActivityCategory.match:
        form = _MatchForm(s: formState, onChanged: onChanged);
      case ActivityCategory.recovery:
        form = _RecoveryForm(s: formState, onChanged: onChanged);
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _intro(category),
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                form,
              ],
            ),
          ),
        ),
        _NextBar(label: 'Continue', onTap: onNext),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Activity-specific forms
// ─────────────────────────────────────────────────────────────────────────────

class _NetsForm extends StatelessWidget {
  final _ActivityFormState s;
  final VoidCallback onChanged;
  const _NetsForm({required this.s, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _FormLabel('What did you work on?'),
      const SizedBox(height: 8),
      _GroupLabel('Batting'),
      const SizedBox(height: 6),
      _DrillCloud(
          all: _battingDrills,
          selected: s.netsDrills,
          onToggle: (d) {
            s.netsDrills.contains(d)
                ? s.netsDrills.remove(d)
                : s.netsDrills.add(d);
            onChanged();
          }),
      const SizedBox(height: 12),
      _GroupLabel('Bowling'),
      const SizedBox(height: 6),
      _DrillCloud(
          all: _bowlingDrills,
          selected: s.netsDrills,
          onToggle: (d) {
            s.netsDrills.contains(d)
                ? s.netsDrills.remove(d)
                : s.netsDrills.add(d);
            onChanged();
          }),
      const SizedBox(height: 12),
      _GroupLabel('Fielding'),
      const SizedBox(height: 6),
      _DrillCloud(
          all: _fieldingDrills,
          selected: s.netsDrills,
          onToggle: (d) {
            s.netsDrills.contains(d)
                ? s.netsDrills.remove(d)
                : s.netsDrills.add(d);
            onChanged();
          }),
      const SizedBox(height: 20),
      _FormLabel('What clicked today?'),
      const SizedBox(height: 8),
      _JTextField(
          ctrl: s.netsClicked,
          hint: 'Something that felt connected…',
          lines: 2),
      const SizedBox(height: 16),
      _FormLabel('What still needs work?'),
      const SizedBox(height: 8),
      _JTextField(
          ctrl: s.netsNeedsWork, hint: 'Focus for next session…', lines: 2),
      const SizedBox(height: 20),
      _FormLabel('Session rating'),
      const SizedBox(height: 8),
      _RatingSlider(
          value: s.netsRating,
          onChanged: (v) {
            s.netsRating = v;
            onChanged();
          }),
    ]);
  }
}

class _SkillWorkForm extends StatelessWidget {
  final _ActivityFormState s;
  final VoidCallback onChanged;
  const _SkillWorkForm({required this.s, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _FormLabel('Which drill did you focus on?'),
      const SizedBox(height: 8),
      _JTextField(ctrl: s.skillDrill, hint: 'e.g. Cover drive, off spin…'),
      const SizedBox(height: 20),
      _FormLabel('Execution quality'),
      const SizedBox(height: 8),
      _RatingSlider(
          value: s.skillQuality,
          onChanged: (v) {
            s.skillQuality = v;
            onChanged();
          }),
      const SizedBox(height: 20),
      _FormLabel('Key observation'),
      const SizedBox(height: 8),
      _JTextField(
          ctrl: s.skillObs,
          hint: 'One thing you noticed about your technique…',
          lines: 3),
    ]);
  }
}

class _ConditioningForm extends StatelessWidget {
  final _ActivityFormState s;
  final VoidCallback onChanged;
  const _ConditioningForm({required this.s, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _FormLabel('What type?'),
      const SizedBox(height: 12),
      _Segmented<ConditioningType>(
        options: ConditioningType.values,
        selected: s.condType,
        label: (t) => t.label,
        onSelect: (t) {
          s.condType = t;
          onChanged();
        },
      ),
      if (s.condType == ConditioningType.running) ...[
        const SizedBox(height: 20),
        _FormLabel('What kind of run?'),
        const SizedBox(height: 12),
        _Segmented<RunType>(
          options: RunType.values,
          selected: s.runType,
          label: (t) => t.label,
          onSelect: (t) {
            s.runType = t;
            onChanged();
          },
        ),
      ],
      const SizedBox(height: 20),
      _FormLabel('One observation'),
      const SizedBox(height: 8),
      _JTextField(
        ctrl: s.condObs,
        hint: s.condType == ConditioningType.running
            ? 'Body feel, pace, breathing…'
            : 'How clear the mind felt…',
        lines: 3,
      ),
    ]);
  }
}

class _GymForm extends StatelessWidget {
  final _ActivityFormState s;
  final VoidCallback onChanged;
  const _GymForm({required this.s, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _FormLabel('Focus today'),
      const SizedBox(height: 12),
      _OptionChips<GymFocus>(
        options: GymFocus.values,
        selected: s.gymFocus,
        label: (f) => f.label,
        onSelect: (f) {
          s.gymFocus = f;
          onChanged();
        },
      ),
      const SizedBox(height: 20),
      _FormLabel('Energy level'),
      const SizedBox(height: 8),
      _RatingSlider(
        value: s.gymEnergy,
        onChanged: (v) {
          s.gymEnergy = v;
          onChanged();
        },
        lowLabel: 'Drained',
        highLabel: 'Fired up',
      ),
      const SizedBox(height: 20),
      _FormLabel('Anything to note? (optional)'),
      const SizedBox(height: 8),
      _JTextField(
          ctrl: s.gymNote,
          hint: 'A PB, something that felt off, injury concern…',
          lines: 2),
    ]);
  }
}

class _MatchForm extends StatelessWidget {
  final _ActivityFormState s;
  final VoidCallback onChanged;
  const _MatchForm({required this.s, required this.onChanged});

  static const _roles = [
    'Batsman',
    'Bowler',
    'All-rounder',
    'Wicket-keeper',
    'Fielder'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _FormLabel('Your role today'),
      const SizedBox(height: 12),
      _OptionChips<String>(
        options: _roles,
        selected: s.matchRole,
        label: (r) => r,
        onSelect: (r) {
          s.matchRole = r;
          onChanged();
        },
      ),
      const SizedBox(height: 20),
      _FormLabel('One thing you executed well'),
      const SizedBox(height: 8),
      _JTextField(
          ctrl: s.matchWell,
          hint: 'What actually worked under pressure…',
          lines: 2),
      const SizedBox(height: 16),
      _FormLabel('One thing to fix next time'),
      const SizedBox(height: 8),
      _JTextField(
          ctrl: s.matchFix, hint: 'What would you do differently…', lines: 2),
      const SizedBox(height: 20),
      _FormLabel('Self-rating'),
      const SizedBox(height: 8),
      _RatingSlider(
          value: s.matchRating,
          onChanged: (v) {
            s.matchRating = v;
            onChanged();
          }),
    ]);
  }
}

class _RecoveryForm extends StatelessWidget {
  final _ActivityFormState s;
  final VoidCallback onChanged;
  const _RecoveryForm({required this.s, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _FormLabel('What did you do?'),
      const SizedBox(height: 8),
      _DrillCloud(
        all: _recoveryOptions,
        selected: s.recoveryTypes,
        onToggle: (t) {
          s.recoveryTypes.contains(t)
              ? s.recoveryTypes.remove(t)
              : s.recoveryTypes.add(t);
          onChanged();
        },
      ),
      const SizedBox(height: 20),
      _FormLabel('How does the body feel?'),
      const SizedBox(height: 12),
      _Segmented<BodyState>(
        options: BodyState.values,
        selected: s.bodyState,
        label: (b) => b.label,
        onSelect: (b) {
          s.bodyState = b;
          onChanged();
        },
      ),
      const SizedBox(height: 20),
      _FormLabel('Notes (optional)'),
      const SizedBox(height: 8),
      _JTextField(
          ctrl: s.recoveryNote,
          hint: 'Physio feedback, area of concern, plan for tomorrow…',
          lines: 3),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vitals Page
// ─────────────────────────────────────────────────────────────────────────────

class _VitalsPage extends StatelessWidget {
  final double sleepHours;
  final double hydration;
  final ValueChanged<double> onSleep;
  final ValueChanged<double> onHydration;
  final VoidCallback onNext;

  const _VitalsPage({
    required this.sleepHours,
    required this.hydration,
    required this.onSleep,
    required this.onHydration,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            children: [
              Text(
                'Before we wrap up, quick body check.',
                style:
                    TextStyle(color: context.fgSub, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              _VitalCard(
                icon: Icons.bedtime_rounded,
                label: 'Sleep last night',
                child: _VitalSlider(
                  value: sleepHours,
                  displayText:
                      '${sleepHours % 1 == 0 ? sleepHours.toInt() : sleepHours}h',
                  badge: sleepHours >= 7.5
                      ? 'Good'
                      : sleepHours >= 6
                          ? 'Short'
                          : 'Low',
                  badgeColor: sleepHours >= 7.5
                      ? context.accent
                      : sleepHours >= 6
                          ? context.warn
                          : context.danger,
                  min: 3,
                  max: 12,
                  divisions: 18,
                  minLabel: '3h',
                  maxLabel: '12h',
                  onChanged: (v) => onSleep((v * 2).round() / 2),
                ),
              ),
              const SizedBox(height: 16),
              _VitalCard(
                icon: Icons.water_drop_rounded,
                label: 'Hydration today',
                child: _VitalSlider(
                  value: hydration,
                  displayText:
                      '${hydration % 1 == 0 ? hydration.toInt() : hydration}L',
                  badge: hydration >= 3
                      ? 'Well hydrated'
                      : hydration >= 2
                          ? 'Okay'
                          : 'Low',
                  badgeColor: hydration >= 3
                      ? context.accent
                      : hydration >= 2
                          ? context.warn
                          : context.danger,
                  min: 0,
                  max: 6,
                  divisions: 12,
                  minLabel: '0L',
                  maxLabel: '6L',
                  onChanged: (v) => onHydration((v * 2).round() / 2),
                ),
              ),
            ],
          ),
        ),
        _NextBar(label: 'Continue', onTap: onNext),
      ],
    );
  }
}

class _VitalCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;
  const _VitalCard(
      {required this.icon, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.stroke),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: context.fgSub),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: context.fgSub,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }
}

class _VitalSlider extends StatelessWidget {
  final double value;
  final String displayText;
  final String badge;
  final Color badgeColor;
  final double min;
  final double max;
  final int divisions;
  final String minLabel;
  final String maxLabel;
  final ValueChanged<double> onChanged;

  const _VitalSlider({
    required this.value,
    required this.displayText,
    required this.badge,
    required this.badgeColor,
    required this.min,
    required this.max,
    required this.divisions,
    required this.minLabel,
    required this.maxLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Text(displayText,
            style: TextStyle(
                color: badgeColor,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1)),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6)),
          child: Text(badge,
              style: TextStyle(
                  color: badgeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
      const SizedBox(height: 4),
      _ThemedSlider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(minLabel, style: TextStyle(color: context.fgSub, fontSize: 11)),
        Text(maxLabel, style: TextStyle(color: context.fgSub, fontSize: 11)),
      ]),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reflect Page
// ─────────────────────────────────────────────────────────────────────────────

class _ReflectPage extends StatelessWidget {
  final TextEditingController takeaway;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _ReflectPage({
    required this.takeaway,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Nice work. What are you taking from today?',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A technique cue, a mindset shift, or just what the body told you.',
                style:
                    TextStyle(color: context.fgSub, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TextField(
                  controller: takeaway,
                  style:
                      TextStyle(color: context.fg, fontSize: 15, height: 1.6),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Write freely…',
                    hintStyle: TextStyle(color: context.fgSub),
                    filled: true,
                    fillColor: context.cardBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.stroke),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.stroke),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.accent),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ),
            ]),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      context.accent.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Done — log it',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared UI components
// ─────────────────────────────────────────────────────────────────────────────

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          color: context.fg, fontSize: 15, fontWeight: FontWeight.w600));
}

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: TextStyle(
          color: context.fgSub,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8));
}

class _DrillCloud extends StatelessWidget {
  final List<String> all;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  const _DrillCloud(
      {required this.all, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: all.map((d) {
        final on = selected.contains(d);
        return GestureDetector(
          onTap: () => onToggle(d),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: on ? context.accentBg : context.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: on ? context.accent : context.stroke),
            ),
            child: Text(d,
                style: TextStyle(
                  color: on ? context.accent : context.fgSub,
                  fontSize: 12,
                  fontWeight: on ? FontWeight.w600 : FontWeight.w400,
                )),
          ),
        );
      }).toList(),
    );
  }
}

class _JTextField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final int lines;
  const _JTextField({required this.ctrl, required this.hint, this.lines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: context.fg, fontSize: 14),
      maxLines: lines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.fgSub, fontSize: 14),
        filled: true,
        fillColor: context.cardBg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: context.stroke)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: context.stroke)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: context.accent)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _RatingSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String lowLabel;
  final String highLabel;
  const _RatingSlider(
      {required this.value,
      required this.onChanged,
      this.lowLabel = 'Poor',
      this.highLabel = 'Excellent'});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('${value.round()}',
            style: TextStyle(
                color: context.accent,
                fontSize: 28,
                fontWeight: FontWeight.w800)),
        Text(' / 10', style: TextStyle(color: context.fgSub, fontSize: 14)),
      ]),
      _ThemedSlider(
          value: value, min: 1, max: 10, divisions: 9, onChanged: onChanged),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(lowLabel, style: TextStyle(color: context.fgSub, fontSize: 11)),
        Text(highLabel, style: TextStyle(color: context.fgSub, fontSize: 11)),
      ]),
    ]);
  }
}

class _ThemedSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  const _ThemedSlider(
      {required this.value,
      required this.min,
      required this.max,
      required this.divisions,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: context.accent,
        inactiveTrackColor: context.stroke,
        thumbColor: context.accent,
        overlayColor: context.accent.withValues(alpha: 0.15),
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
      ),
      child: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged),
    );
  }
}

class _Segmented<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelect;
  const _Segmented(
      {required this.options,
      required this.selected,
      required this.label,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((o) {
        final on = o == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(o),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: o == options.last ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: on ? context.accentBg : context.cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: on ? context.accent : context.stroke),
              ),
              child: Text(label(o),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: on ? context.accent : context.fgSub,
                      fontSize: 13,
                      fontWeight: on ? FontWeight.w700 : FontWeight.w400)),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _OptionChips<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelect;
  const _OptionChips(
      {required this.options,
      required this.selected,
      required this.label,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final on = o == selected;
        return GestureDetector(
          onTap: () => onSelect(o),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: on ? context.accentBg : context.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: on ? context.accent : context.stroke),
            ),
            child: Text(label(o),
                style: TextStyle(
                    color: on ? context.accent : context.fgSub,
                    fontSize: 13,
                    fontWeight: on ? FontWeight.w700 : FontWeight.w400)),
          ),
        );
      }).toList(),
    );
  }
}

class _NextBar extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NextBar({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(label,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}
