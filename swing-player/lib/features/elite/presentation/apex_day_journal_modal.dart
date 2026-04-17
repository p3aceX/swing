import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/goal_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/elite_controller.dart';
import '../domain/elite_models.dart';

enum _JournalActivity {
  nets,
  skillWork,
  conditioning,
  gym,
  match,
  recovery,
}

extension _JournalActivityX on _JournalActivity {
  String get label => switch (this) {
        _JournalActivity.nets => 'Nets',
        _JournalActivity.skillWork => 'Skill Work',
        _JournalActivity.conditioning => 'Conditioning',
        _JournalActivity.gym => 'Gym',
        _JournalActivity.match => 'Match',
        _JournalActivity.recovery => 'Recovery',
      };

  IconData get icon => switch (this) {
        _JournalActivity.nets => Icons.sports_cricket_rounded,
        _JournalActivity.skillWork => Icons.adjust_rounded,
        _JournalActivity.conditioning => Icons.directions_run_rounded,
        _JournalActivity.gym => Icons.fitness_center_rounded,
        _JournalActivity.match => Icons.emoji_events_rounded,
        _JournalActivity.recovery => Icons.favorite_rounded,
      };
}

class ApexDayJournalModal extends ConsumerStatefulWidget {
  final ApexDayLog dayLog;
  final String playerName;
  final List<String> plannedActivityTypes;
  final VoidCallback onSubmitted;

  const ApexDayJournalModal({
    super.key,
    required this.dayLog,
    required this.playerName,
    this.plannedActivityTypes = const [],
    required this.onSubmitted,
  });

  @override
  ConsumerState<ApexDayJournalModal> createState() =>
      _ApexDayJournalModalState();
}

class _ApexDayJournalModalState extends ConsumerState<ApexDayJournalModal> {
  int _step = 0;
  bool _cheatDay = false;
  bool _showAlternativeActivities = false;
  bool _isSubmitting = false;
  _JournalActivity? _editingActivity;

  final _plannedToday = <_JournalActivity>{};
  final _selected = <_JournalActivity>{};
  final _completedActivities = <_JournalActivity>{};

  final _skillFocusCtrl = TextEditingController();
  final _netsLearnCtrl = TextEditingController();
  final _netsMissCtrl = TextEditingController();
  final _skillLearnCtrl = TextEditingController();
  final _skillMissCtrl = TextEditingController();
  final _matchBattingNumberCtrl = TextEditingController();
  final _matchRunsCtrl = TextEditingController();
  final _matchBallsCtrl = TextEditingController();
  final _matchOversCtrl = TextEditingController();
  final _matchRunsGivenCtrl = TextEditingController();
  final _matchWicketsCtrl = TextEditingController();
  final _matchCatchesCtrl = TextEditingController();
  final _matchRunOutsCtrl = TextEditingController();

  final _selectedTags = <_JournalActivity, Set<String>>{};
  final _activityRatings = <_JournalActivity, int>{};
  String? _netsSessionType;
  String? _skillWorkType;
  bool _matchDidBowl = false;

  static const List<String> _skillWorkTypes = [
    'Batting',
    'Bowling',
    'Fielding',
    'Catching',
    'WK',
  ];

  static const Map<_JournalActivity, List<String>> _focusTags = {
    _JournalActivity.gym: [
      'Upper body',
      'Legs',
      'Core',
      'Mobility',
      'Strength',
      'Power',
    ],
    _JournalActivity.conditioning: [
      'Stamina',
      'Speed',
      'Agility',
      'Endurance',
      'Sprint work',
    ],
    _JournalActivity.recovery: [
      'Stretch',
      'Mobility',
      'Rest',
      'Foam roll',
    ],
  };

  static const List<String> _netsBattingFocusTags = [
    'Technique',
    'Shot Selection',
    'Match Simulation',
    'Bio Mechanics',
  ];

  static const List<String> _netsBowlingFocusTags = [
    'Speed and Consistency',
    'Variation',
    'Control',
  ];

  @override
  void initState() {
    super.initState();
    final log = widget.dayLog;

    _netsLearnCtrl.text = (log.execution.whatDidWell ?? '').trim();
    _netsMissCtrl.text = (log.execution.whatDidBadly ?? '').trim();
    _skillLearnCtrl.text = (log.execution.whatDidWell ?? '').trim();
    _skillMissCtrl.text = (log.execution.whatDidBadly ?? '').trim();

    final plannedByType = _activitiesFromPlanTypes(widget.plannedActivityTypes);
    final plannedFallback = _plannedActivities(log.plan).toSet();
    final plannedOrdered = _JournalActivity.values
        .where((activity) => plannedByType.isNotEmpty
            ? plannedByType.contains(activity)
            : plannedFallback.contains(activity))
        .toList(growable: false);
    _plannedToday
      ..clear()
      ..addAll(plannedOrdered);

    _selected
      ..clear()
      ..addAll(_plannedToday);

    for (final activity in _JournalActivity.values) {
      _selectedTags[activity] = <String>{};
      _activityRatings[activity] = 0;
    }
  }

  @override
  void dispose() {
    _skillFocusCtrl.dispose();
    _netsLearnCtrl.dispose();
    _netsMissCtrl.dispose();
    _skillLearnCtrl.dispose();
    _skillMissCtrl.dispose();
    _matchBattingNumberCtrl.dispose();
    _matchRunsCtrl.dispose();
    _matchBallsCtrl.dispose();
    _matchOversCtrl.dispose();
    _matchRunsGivenCtrl.dispose();
    _matchWicketsCtrl.dispose();
    _matchCatchesCtrl.dispose();
    _matchRunOutsCtrl.dispose();
    super.dispose();
  }

  List<_JournalActivity> _plannedActivities(ApexDayPlan plan) {
    final out = <_JournalActivity>[];
    if (plan.netsMinutes > 0) out.add(_JournalActivity.nets);
    if (plan.drillsMinutes > 0) out.add(_JournalActivity.skillWork);
    if (plan.fitnessMinutes > 0) out.add(_JournalActivity.gym);
    if (plan.recoveryMinutes > 0) out.add(_JournalActivity.recovery);
    return out.toSet().toList(growable: false);
  }

  Set<_JournalActivity> _activitiesFromPlanTypes(List<String> types) {
    final out = <_JournalActivity>{};
    for (final raw in types) {
      final parsed = _activityFromPlanType(raw);
      if (parsed != null) out.add(parsed);
    }
    return out;
  }

  _JournalActivity? _activityFromPlanType(String raw) {
    final value = raw.trim().toUpperCase();
    switch (value) {
      case 'NETS':
        return _JournalActivity.nets;
      case 'SKILL_WORK':
        return _JournalActivity.skillWork;
      case 'CONDITIONING':
        return _JournalActivity.conditioning;
      case 'GYM':
        return _JournalActivity.gym;
      case 'MATCH':
        return _JournalActivity.match;
      case 'RECOVERY':
        return _JournalActivity.recovery;
      default:
        return null;
    }
  }

  bool _isActivityReadyToSave(_JournalActivity activity) {
    if (!_isActivityDetailsValid(activity)) return false;
    if (activity == _JournalActivity.nets) {
      if (_netsLearnCtrl.text.trim().isEmpty ||
          _netsMissCtrl.text.trim().isEmpty) {
        return false;
      }
    }
    if (activity == _JournalActivity.skillWork) {
      if (_skillLearnCtrl.text.trim().isEmpty ||
          _skillMissCtrl.text.trim().isEmpty) {
        return false;
      }
    }
    return (_activityRatings[activity] ?? 0) > 0;
  }

  bool _isActivityComplete(_JournalActivity activity) {
    return _selected.contains(activity) &&
        _completedActivities.contains(activity);
  }

  void _openActivityEditor(_JournalActivity activity) {
    setState(() {
      _selected.add(activity);
      _completedActivities.remove(activity);
      _cheatDay = false;
      _editingActivity = activity;
      _step = 1;
    });
  }

  void _removeActivity(_JournalActivity activity) {
    setState(() {
      _selected.remove(activity);
      if (_editingActivity == activity) {
        _editingActivity = null;
        _step = 0;
      }
      _completedActivities.remove(activity);
      _activityRatings[activity] = 0;
    });
  }

  void _saveCurrentActivity() {
    final activity = _editingActivity;
    if (activity == null) return;
    if (!_isActivityReadyToSave(activity)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Fill all required fields for this activity.'),
          backgroundColor: context.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() {
      _completedActivities.add(activity);
      _editingActivity = null;
      _step = 0;
    });
  }

  DateTime _journalDate() {
    final raw = widget.dayLog.date.trim();
    if (raw.isEmpty) return DateTime.now();
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return DateTime.now();
    }
  }

  GymFocus _gymFocusFromTags(Set<String> tags) {
    if (tags.contains('Mobility')) return GymFocus.mobility;
    if (tags.contains('Cardio')) return GymFocus.cardio;
    if (tags.contains('Strength')) return GymFocus.strength;
    return GymFocus.mixed;
  }

  ActivityJournalEntry _entryForActivity(_JournalActivity activity) {
    final date = _journalDate();
    final tags = _selectedTags[activity] ?? <String>{};
    final rating = (_activityRatings[activity] ?? 7).clamp(1, 10);
    final vitals = DailyVitals(
      sleepHours: widget.dayLog.plan.sleepTargetHours,
      hydrationLiters: widget.dayLog.plan.hydrationTargetLiters,
    );

    switch (activity) {
      case _JournalActivity.nets:
        return ActivityJournalEntry(
          date: date,
          activity: ActivityCategory.nets,
          vitals: vitals,
          takeaway: _netsLearnCtrl.text.trim(),
          netsDetail: NetsJournalDetail(
            drills: tags.toList(growable: false),
            whatClicked: _netsLearnCtrl.text.trim(),
            whatNeedsWork: _netsMissCtrl.text.trim(),
            rating: rating,
          ),
        );
      case _JournalActivity.skillWork:
        return ActivityJournalEntry(
          date: date,
          activity: ActivityCategory.skillWork,
          vitals: vitals,
          takeaway: _skillLearnCtrl.text.trim(),
          skillWorkDetail: SkillWorkJournalDetail(
            drillName: _skillWorkType ?? 'Skill Work',
            quality: rating,
            observation: _skillFocusCtrl.text.trim(),
          ),
        );
      case _JournalActivity.conditioning:
        return ActivityJournalEntry(
          date: date,
          activity: ActivityCategory.conditioning,
          vitals: vitals,
          takeaway: tags.join(', '),
          conditioningDetail: ConditioningJournalDetail(
            type: ConditioningType.running,
            runType: RunType.easy,
            observation: tags.join(', '),
          ),
        );
      case _JournalActivity.gym:
        return ActivityJournalEntry(
          date: date,
          activity: ActivityCategory.gym,
          vitals: vitals,
          takeaway: tags.join(', '),
          gymDetail: GymJournalDetail(
            focus: _gymFocusFromTags(tags),
            energyLevel: rating,
            note: tags.join(', '),
          ),
        );
      case _JournalActivity.match:
        final batting = 'Bat #${_matchBattingNumberCtrl.text.trim()} '
            '(${_matchRunsCtrl.text.trim()} off ${_matchBallsCtrl.text.trim()})';
        final bowling = _matchDidBowl
            ? 'Bowling: ${_matchOversCtrl.text.trim()} ov, '
                '${_matchRunsGivenCtrl.text.trim()} runs, '
                '${_matchWicketsCtrl.text.trim()} wkts.'
            : 'No bowling.';
        final fielding = 'Fielding: ${_matchCatchesCtrl.text.trim()} catches, '
            '${_matchRunOutsCtrl.text.trim()} run outs.';
        return ActivityJournalEntry(
          date: date,
          activity: ActivityCategory.match,
          vitals: vitals,
          takeaway: batting,
          matchDetail: MatchJournalDetail(
            role: batting,
            executedWell: bowling,
            toFix: fielding,
            rating: rating,
          ),
        );
      case _JournalActivity.recovery:
        return ActivityJournalEntry(
          date: date,
          activity: ActivityCategory.recovery,
          vitals: vitals,
          takeaway: tags.join(', '),
          recoveryDetail: RecoveryJournalDetail(
            types: tags.toList(growable: false),
            bodyState: BodyState.okay,
            note: tags.join(', '),
          ),
        );
    }
  }

  Future<bool> _submitCheatDayToDb() async {
    final entry = ActivityJournalEntry(
      date: _journalDate(),
      activity: ActivityCategory.recovery,
      vitals: const DailyVitals(sleepHours: 0, hydrationLiters: 0),
      takeaway: 'Cheat day',
      isCheatDay: true,
      recoveryDetail: const RecoveryJournalDetail(
        types: ['Rest'],
        bodyState: BodyState.okay,
        note: 'Cheat day — no activity day.',
      ),
    );
    return ref.read(activityJournalControllerProvider.notifier).submit(entry);
  }

  Future<void> _submitJournal() async {
    if (widget.dayLog.isLocked) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    if (_isSubmitting) return;
    if (!_cheatDay) {
      if (_selected.isEmpty || _selected.any((a) => !_isActivityComplete(a))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Complete all selected activities first.'),
            backgroundColor: context.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);
    bool allOk = true;

    if (_cheatDay) {
      allOk = await _submitCheatDayToDb();
    } else {
      final selectedActivities = _JournalActivity.values
          .where((activity) => _selected.contains(activity))
          .toList(growable: false);
      for (final activity in selectedActivities) {
        final entry = _entryForActivity(activity);
        final ok = await ref
            .read(activityJournalControllerProvider.notifier)
            .submit(entry);
        if (!ok) {
          allOk = false;
          break;
        }
      }
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!allOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not submit journal. Please try again.'),
          backgroundColor: context.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await GoalStorage.saveJournalDate();
    await GoalStorage.saveCheatDayStatus(isCheatDay: _cheatDay);
    if (!mounted) return;
    ref.read(journaledTodayProvider.notifier).state = true;
    ref.read(cheatDayTodayProvider.notifier).state = _cheatDay;
    widget.onSubmitted();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.dayLog.isLocked;
    final canPrimaryAction = _canAdvanceFromCurrentStep();
    final isEditing = _step == 1 && _editingActivity != null;

    return SafeArea(
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.bg,
          elevation: 0,
          titleSpacing: 16,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: context.fg),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            isLocked ? 'Today Reflection' : 'Add Journal',
            style: TextStyle(
              color: context.fg,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ),
        body: isLocked
            ? _lockedBody(context)
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: _stepperHeader(context),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: _stepBody(context),
                    ),
                  ),
                  SafeArea(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                      decoration: BoxDecoration(
                        color: context.bg,
                        border: Border(
                          top: BorderSide(
                              color: context.stroke.withValues(alpha: 0.8)),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (isEditing)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () => setState(() {
                                          _editingActivity = null;
                                          _step = 0;
                                        }),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Back',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          if (isEditing) const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSubmitting || !canPrimaryAction
                                  ? null
                                  : isEditing
                                      ? _saveCurrentActivity
                                      : _submitJournal,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                isEditing
                                    ? 'Save Activity'
                                    : (_cheatDay
                                        ? 'Submit Cheat Day'
                                        : 'Submit Journal'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _stepperHeader(BuildContext context) {
    final stepCount = _cheatDay ? 1 : 2;
    final safeStep = _step.clamp(0, stepCount - 1);
    final currentStep = _cheatDay ? 1 : (safeStep + 1);
    final title = _cheatDay
        ? 'Cheat Day'
        : (safeStep == 0
            ? 'Add Activities'
            : '${_editingActivity?.label ?? 'Activity'} Journal');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.fg,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: currentStep / stepCount,
              minHeight: 6,
              backgroundColor: context.stroke.withValues(alpha: 0.45),
              valueColor: AlwaysStoppedAnimation<Color>(context.accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBody(BuildContext context) {
    if (_cheatDay) return _cheatDayStep(context);
    if (_step == 1 && _editingActivity != null) return _detailsStep(context);
    return _selectionStep(context);
  }

  bool _canAdvanceFromCurrentStep() {
    if (_step == 1) {
      final activity = _editingActivity;
      return activity != null && _isActivityReadyToSave(activity);
    }
    if (_cheatDay) return true;
    if (_selected.isEmpty) return false;
    return _selected.every(_isActivityComplete);
  }

  bool _isActivityDetailsValid(_JournalActivity activity) {
    switch (activity) {
      case _JournalActivity.nets:
        final selected = _selectedTags[activity] ?? const <String>{};
        return _netsSessionType != null && selected.isNotEmpty;
      case _JournalActivity.skillWork:
        return _skillWorkType != null && _skillFocusCtrl.text.trim().isNotEmpty;
      case _JournalActivity.gym:
      case _JournalActivity.conditioning:
      case _JournalActivity.recovery:
        final selected = _selectedTags[activity] ?? const <String>{};
        return selected.isNotEmpty;
      case _JournalActivity.match:
        final battingNo = _matchBattingNumberCtrl.text.trim();
        final runs = _matchRunsCtrl.text.trim();
        final balls = _matchBallsCtrl.text.trim();
        final overs = _matchOversCtrl.text.trim();
        final runsGiven = _matchRunsGivenCtrl.text.trim();
        final wickets = _matchWicketsCtrl.text.trim();
        if (battingNo.isEmpty || runs.isEmpty || balls.isEmpty) return false;
        if (_matchDidBowl &&
            (overs.isEmpty || runsGiven.isEmpty || wickets.isEmpty)) {
          return false;
        }
        return true;
    }
  }

  Widget _selectionStep(BuildContext context) {
    final planned = _plannedToday.toList(growable: false);
    final hasPlanned = planned.isNotEmpty;
    final alternatives = _JournalActivity.values
        .where((activity) => !_plannedToday.contains(activity))
        .toList(growable: false);

    Widget activityCard(_JournalActivity activity) {
      final selected = _selected.contains(activity);
      final filled = selected && _isActivityComplete(activity);
      return SizedBox(
        width: (MediaQuery.of(context).size.width - 42) / 2,
        child: GestureDetector(
          onTap: _cheatDay ? null : () => _openActivityEditor(activity),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? context.accentBg : context.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? context.accent : context.stroke,
                width: selected ? 1.6 : 1.1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(activity.icon,
                        size: 20,
                        color: selected ? context.accent : context.fgSub),
                    const Spacer(),
                    if (filled)
                      Icon(Icons.check_circle_rounded,
                          size: 18, color: context.accent),
                    if (selected && !filled)
                      Icon(Icons.radio_button_checked_rounded,
                          size: 18,
                          color: context.accent.withValues(alpha: .7)),
                    if (_plannedToday.contains(activity))
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: context.panel,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'PLANNED',
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  activity.label,
                  style: TextStyle(
                    color: selected ? context.accent : context.fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.1,
                  ),
                ),
                if (selected) ...[
                  const SizedBox(height: 4),
                  Text(
                    filled ? 'Filled' : 'Added',
                    style: TextStyle(
                      color: context.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Journal',
          style: TextStyle(
            color: context.fg,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap an activity to open its journal form.',
          style: TextStyle(
            color: context.fgSub,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (_selected.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Today\'s Journal',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          ..._JournalActivity.values.where(_selected.contains).map((activity) {
            final completed = _isActivityComplete(activity);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.stroke, width: 1.1),
              ),
              child: Row(
                children: [
                  Icon(activity.icon, size: 17, color: context.fgSub),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      activity.label,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (completed)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.check_circle_rounded,
                          size: 18, color: context.accent),
                    ),
                  TextButton(
                    onPressed: () => _openActivityEditor(activity),
                    child: const Text('Edit'),
                  ),
                  IconButton(
                    onPressed: () => _removeActivity(activity),
                    icon: Icon(Icons.close_rounded,
                        size: 18, color: context.fgSub),
                  ),
                ],
              ),
            );
          }),
        ],
        if (hasPlanned) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.stroke),
            ),
            child: Text(
              planned.map((e) => e.label).join(', '),
              style: TextStyle(
                color: context.fg,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () => setState(() {
            _cheatDay = !_cheatDay;
            if (_cheatDay) {
              _step = 0;
              _selected.clear();
              _completedActivities.clear();
              _editingActivity = null;
              _showAlternativeActivities = false;
            } else if (_selected.isEmpty) {
              _selected.addAll(planned);
            }
          }),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _cheatDay ? context.accentBg : context.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _cheatDay ? context.accent : context.stroke,
                width: _cheatDay ? 1.6 : 1.1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.free_breakfast_rounded,
                    size: 20,
                    color: _cheatDay ? context.accent : context.fgSub),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cheat Day / Off Plan',
                    style: TextStyle(
                      color: _cheatDay ? context.accent : context.fg,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (_cheatDay)
                  Icon(Icons.check_circle_rounded, color: context.accent),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (!_cheatDay && hasPlanned) ...[
          Text(
            'Planned',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: planned.map(activityCard).toList(growable: false),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => setState(
              () => _showAlternativeActivities = !_showAlternativeActivities,
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              _showAlternativeActivities
                  ? Icons.expand_less_rounded
                  : Icons.add_rounded,
              size: 18,
            ),
            label: Text(
              _showAlternativeActivities
                  ? 'Hide Alternative Activity'
                  : 'Add Alternative Activity',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
          if (_showAlternativeActivities) ...[
            const SizedBox(height: 10),
            Text(
              'Alternative Activity',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: alternatives.map(activityCard).toList(growable: false),
            ),
          ],
        ] else if (!_cheatDay) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.stroke, width: 1.1),
            ),
            child: Text(
              'No activity planned today.',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => setState(
              () => _showAlternativeActivities = !_showAlternativeActivities,
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              _showAlternativeActivities
                  ? Icons.expand_less_rounded
                  : Icons.add_rounded,
              size: 18,
            ),
            label: Text(
              _showAlternativeActivities ? 'Hide Activity' : 'Add Activity',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
          if (_showAlternativeActivities) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _JournalActivity.values
                  .map(activityCard)
                  .toList(growable: false),
            ),
          ],
        ],
      ],
    );
  }

  Widget _cheatDayStep(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.stroke, width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.free_breakfast_rounded,
                  color: context.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'Cheat Day Selected',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailsStep(BuildContext context) {
    if (_cheatDay) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.stroke, width: 1.1),
        ),
        child: Text(
          'Cheat day selected.',
          style: TextStyle(
            color: context.fg,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    final activity = _editingActivity;
    if (activity == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.stroke, width: 1.1),
        ),
        child: Text(
          'Select an activity to start journaling.',
          style: TextStyle(
            color: context.fg,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _activityDetailCard(context, activity),
        if (activity == _JournalActivity.nets) ...[
          const SizedBox(height: 10),
          _reflectionCard(
            context,
            title: 'Nets Reflection',
            workedCtrl: _netsLearnCtrl,
            missedCtrl: _netsMissCtrl,
          ),
        ],
        if (activity == _JournalActivity.skillWork) ...[
          const SizedBox(height: 10),
          _reflectionCard(
            context,
            title: 'Skill Work Reflection',
            workedCtrl: _skillLearnCtrl,
            missedCtrl: _skillMissCtrl,
          ),
        ],
        const SizedBox(height: 10),
        _reviewRatingCard(context, activity),
      ],
    );
  }

  Widget _activityDetailCard(BuildContext context, _JournalActivity activity) {
    final filled = _isActivityComplete(activity);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.stroke, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.accentBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(activity.icon, size: 20, color: context.accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.label,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              if (filled)
                Icon(Icons.check_circle_rounded,
                    size: 20, color: context.accent),
            ],
          ),
          const SizedBox(height: 14),
          _activitySpecificDetails(context, activity),
        ],
      ),
    );
  }

  Widget _activitySpecificDetails(
    BuildContext context,
    _JournalActivity activity,
  ) {
    final selected = _selectedTags[activity] ?? <String>{};
    final tags = _focusTagsFor(activity);

    switch (activity) {
      case _JournalActivity.nets:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _activityFieldLabel(context, 'NETS Type'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _netsTypeBox(context, 'Batting', Icons.sports_cricket_rounded),
                _netsTypeBox(context, 'Bowling', Icons.track_changes_rounded),
                _netsTypeBox(context, 'Both', Icons.all_inclusive_rounded),
              ],
            ),
            const SizedBox(height: 14),
            _focusTagSection(
              context,
              activity: activity,
              selected: selected,
              tags: tags,
              title: 'Focus today',
            ),
          ],
        );
      case _JournalActivity.skillWork:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _activityFieldLabel(context, 'Skill Type'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _skillWorkTypes.map((option) {
                return _selectionChip(
                  context,
                  label: option,
                  selected: _skillWorkType == option,
                  onTap: () => setState(
                    () => _skillWorkType =
                        _skillWorkType == option ? null : option,
                  ),
                );
              }).toList(growable: false),
            ),
            const SizedBox(height: 14),
            _activityFieldLabel(context, 'Focus today'),
            const SizedBox(height: 8),
            _detailInputField(
              context,
              controller: _skillFocusCtrl,
              hint: 'What was your focus?',
              onChanged: (_) => setState(() {}),
            ),
          ],
        );
      case _JournalActivity.gym:
        return _focusTagSection(
          context,
          activity: activity,
          selected: selected,
          tags: tags,
          title: 'Gym focus',
        );
      case _JournalActivity.conditioning:
        return _focusTagSection(
          context,
          activity: activity,
          selected: selected,
          tags: tags,
          title: 'Conditioning focus',
        );
      case _JournalActivity.match:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _activityFieldLabel(context, 'Batting'),
            const SizedBox(height: 8),
            _detailInputField(
              context,
              controller: _matchBattingNumberCtrl,
              hint: 'Batted at number',
              keyboardType: TextInputType.number,
              maxLines: 1,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _detailInputField(
                    context,
                    controller: _matchRunsCtrl,
                    hint: 'Runs',
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _detailInputField(
                    context,
                    controller: _matchBallsCtrl,
                    hint: 'Balls',
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _activityFieldLabel(context, 'Bowling'),
            const SizedBox(height: 8),
            Row(
              children: [
                _selectionChip(
                  context,
                  label: 'Yes',
                  selected: _matchDidBowl,
                  onTap: () => setState(() => _matchDidBowl = true),
                ),
                const SizedBox(width: 10),
                _selectionChip(
                  context,
                  label: 'No',
                  selected: !_matchDidBowl,
                  onTap: () => setState(() {
                    _matchDidBowl = false;
                    _matchOversCtrl.clear();
                    _matchRunsGivenCtrl.clear();
                    _matchWicketsCtrl.clear();
                  }),
                ),
              ],
            ),
            if (_matchDidBowl) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _detailInputField(
                      context,
                      controller: _matchOversCtrl,
                      hint: 'Overs',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      maxLines: 1,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _detailInputField(
                      context,
                      controller: _matchRunsGivenCtrl,
                      hint: 'Runs given',
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _detailInputField(
                      context,
                      controller: _matchWicketsCtrl,
                      hint: 'Wickets',
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            _activityFieldLabel(context, 'Fielding'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _detailInputField(
                    context,
                    controller: _matchCatchesCtrl,
                    hint: 'Catches',
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _detailInputField(
                    context,
                    controller: _matchRunOutsCtrl,
                    hint: 'Run outs',
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ],
        );
      case _JournalActivity.recovery:
        return _focusTagSection(
          context,
          activity: activity,
          selected: selected,
          tags: tags,
          title: 'Recovery focus',
        );
    }
  }

  Widget _netsTypeBox(
    BuildContext context,
    String option,
    IconData icon,
  ) {
    final isOn = _netsSessionType == option;
    return GestureDetector(
      onTap: () => setState(() {
        _netsSessionType = isOn ? null : option;
        final allowed = _focusTagsFor(_JournalActivity.nets).toSet();
        _selectedTags[_JournalActivity.nets] =
            (_selectedTags[_JournalActivity.nets] ?? <String>{})
                .where(allowed.contains)
                .toSet();
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 106,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isOn ? context.accentBg : context.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOn ? context.accent : context.stroke,
            width: isOn ? 1.4 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: isOn ? context.accent : context.fgSub),
            const SizedBox(height: 6),
            Text(
              option,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isOn ? context.accent : context.fg,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _focusTagSection(
    BuildContext context, {
    required _JournalActivity activity,
    required Set<String> selected,
    required List<String> tags,
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _activityFieldLabel(context, title),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tags.map((tag) {
            final isOn = selected.contains(tag);
            return _selectionChip(
              context,
              label: tag,
              selected: isOn,
              onTap: () => setState(() {
                if (isOn) {
                  selected.remove(tag);
                } else {
                  selected.add(tag);
                }
                _selectedTags[activity] = selected;
              }),
            );
          }).toList(growable: false),
        ),
      ],
    );
  }

  Widget _lockedBody(BuildContext context) {
    final e = widget.dayLog.execution;
    final score = widget.dayLog.executionScore;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.stroke, width: 1.1),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_rounded, color: context.accent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Today is already locked. Reflection is read-only.',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _lockedField(context, 'One Thing Today', widget.dayLog.oneThingToday),
        const SizedBox(height: 10),
        _lockedField(context, 'What I did well', e.whatDidWell),
        const SizedBox(height: 10),
        _lockedField(context, 'What I missed', e.whatDidBadly),
        const SizedBox(height: 10),
        _lockedField(context, 'Note', e.note),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.stroke, width: 1.1),
          ),
          child: Row(
            children: [
              Text(
                score == null ? '—' : '${score.round()}%',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Final Plan vs Execution',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _lockedField(BuildContext context, String label, String? value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke, width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            (value ?? '').trim().isEmpty ? 'Not provided' : value!.trim(),
            style: TextStyle(
              color: context.fg,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _focusTagsFor(_JournalActivity activity) {
    if (activity != _JournalActivity.nets) {
      return _focusTags[activity] ?? const <String>[];
    }
    switch (_netsSessionType) {
      case 'Batting':
        return _netsBattingFocusTags;
      case 'Bowling':
        return _netsBowlingFocusTags;
      default:
        return [..._netsBattingFocusTags, ..._netsBowlingFocusTags];
    }
  }

  Widget _selectionChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? context.accentBg : context.panel,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: selected ? context.accent : context.stroke,
            width: selected ? 1.4 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? context.accent : context.fgSub,
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _activityFieldLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        color: context.fg,
        fontSize: 15,
        fontWeight: FontWeight.w900,
        height: 1.15,
      ),
    );
  }

  Widget _detailInputField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 2,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(
        color: context.fg,
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: context.fgSub,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: context.panel,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.stroke, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.accent, width: 1.3),
        ),
      ),
    );
  }

  Widget _reviewRatingCard(BuildContext context, _JournalActivity activity) {
    final rating = _activityRatings[activity] ?? 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rating > 0 ? context.accent : context.stroke,
          width: rating > 0 ? 1.4 : 1.1,
        ),
      ),
      child: Row(
        children: [
          Icon(activity.icon, size: 18, color: context.fgSub),
          const SizedBox(width: 8),
          SizedBox(
            width: 92,
            child: Text(
              activity.label,
              style: TextStyle(
                color: context.fg,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(5, (index) {
                final value = index + 1;
                final active = value <= rating;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _activityRatings[activity] = value),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Icon(
                      active ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 25,
                      color: active ? context.accent : context.fgSub,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reflectionCard(
    BuildContext context, {
    required String title,
    required TextEditingController workedCtrl,
    required TextEditingController missedCtrl,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke, width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.fg,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          _textField(
            context,
            controller: workedCtrl,
            hint: 'What worked?',
            maxLines: 3,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          _textField(
            context,
            controller: missedCtrl,
            hint: 'What didn\'t work?',
            maxLines: 3,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _textField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    int maxLines = 2,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(
        color: context.fg,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: context.fgSub,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: context.cardBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.stroke, width: 1.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.accent, width: 1.4),
        ),
      ),
    );
  }
}
