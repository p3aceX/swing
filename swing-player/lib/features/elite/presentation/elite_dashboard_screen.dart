import "package:cached_network_image/cached_network_image.dart";
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/storage/goal_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/controller/profile_controller.dart';
import '../../profile/data/profile_payload_models.dart';
import '../../profile/data/stats_extended_provider.dart';
import '../../profile/domain/profile_models.dart';
import '../../profile/domain/rank_visual_theme.dart';
import '../../profile/presentation/edit_profile_screen.dart';
import '../../profile/presentation/widgets/profile_section_card.dart';
import '../controller/elite_controller.dart';
import '../domain/elite_models.dart';
import '../domain/swing_index_summary.dart';
import 'apex_day_journal_modal.dart';
import 'execution_heatmap_widget.dart';
import 'identity_goal_page.dart';
import 'my_plan_screen.dart';
import 'widgets/swing_index_radar_card.dart';

class EliteDashboardScreen extends ConsumerWidget {
  const EliteDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialise journaledToday from disk (no-op if already done).
    ref.watch(journalTodayInitProvider);

    final cachedGoal = ref.watch(goalCacheProvider);
    final persistedGoal = ref.watch(goalPersistedProvider).asData?.value;
    final profileAsync = ref.watch(eliteProfileProvider);
    final profileData = profileAsync.asData?.value;
    final profileState = ref.watch(profileControllerProvider);
    final networkGoal = profileData?.goal;
    final networkGoalValid =
        networkGoal != null && networkGoal.targetRole.isNotEmpty;

    final effectiveGoal =
        cachedGoal ?? persistedGoal ?? (networkGoalValid ? networkGoal : null);

    // Sync: backfill cache + disk when network has goal and we don't yet.
    ref.listen<AsyncValue<EliteProfile>>(eliteProfileProvider, (_, next) {
      final g = next.asData?.value.goal;
      if (g != null && g.targetRole.isNotEmpty) {
        if (ref.read(goalCacheProvider) == null) {
          ref.read(goalCacheProvider.notifier).state = g;
        }
        if (persistedGoal == null) GoalStorage.save(g);
      }
    });

    void refreshPath() {
      ref.invalidate(profileControllerProvider);
      ref.invalidate(eliteProfileProvider);
      ref.invalidate(weeklyPlanProvider);
      ref.invalidate(journalConsistencyProvider(30));
    }

    Future<void> openEditProfile(PlayerProfilePageData data) async {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => EditProfileScreen(data: data)),
      );
      refreshPath();
    }

    return _ApexTabsShell(
      profileState: profileState,
      goal: effectiveGoal,
      goalLoading: profileAsync.isLoading && persistedGoal == null,
      goalError: profileAsync.hasError && effectiveGoal == null
          ? profileAsync.error.toString()
          : null,
      onRetry: refreshPath,
      onOpenEditProfile: openEditProfile,
      onOpenGoalFlow: () => _openSetup(context),
    );
  }

  void _openSetup(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const IdentityAndGoalDefinitionPage(),
    ));
  }
}

String _eliteDateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
const String _planDayPrefsKey = 'elite_my_plan_selected_days_v1';

Future<Map<ActivityCategory, Set<int>>> _loadStoredPlanDays() async {
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

Future<List<String>> _plannedActivityTypesForToday(WidgetRef ref) async {
  try {
    final plan = await ref.read(myPlanProvider.future);
    if (plan == null || plan.activities.isEmpty) return const [];
    final storedDays = await _loadStoredPlanDays();
    final today = DateTime.now().weekday;
    final out = <String>{};
    for (final activity in plan.activities) {
      final fromPrefs = storedDays[activity.category];
      final fromPlan = activity.days.where((d) => d >= 1 && d <= 7).toSet();
      final days = (fromPrefs != null && fromPrefs.isNotEmpty)
          ? fromPrefs
          : (fromPlan.isNotEmpty
              ? fromPlan
              : _defaultDaysForCount(activity.timesPerWeek));
      if (days.contains(today)) out.add(activity.category.apiType);
    }
    return out.toList(growable: false);
  } catch (_) {
    return const [];
  }
}

Future<void> openApexJournalModal(BuildContext context, WidgetRef ref) async {
  final todayKey = _eliteDateKey(DateTime.now());
  final profileState = ref.read(profileControllerProvider);
  final playerName = profileState.data?.identity.fullName ?? 'Player';

  ApexDayLog log;
  final plannedActivityTypes = await _plannedActivityTypesForToday(ref);
  try {
    final fromCache = ref.read(apexDayLogProvider(todayKey)).asData?.value;
    log = fromCache ?? await ref.read(apexDayLogProvider(todayKey).future);
  } catch (e) {
    if (!context.mounted) return;
    ref.invalidate(apexDayLogProvider(todayKey));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not open journal: $e'),
        backgroundColor: context.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.96,
      child: ApexDayJournalModal(
        dayLog: log,
        playerName: playerName,
        plannedActivityTypes: plannedActivityTypes,
        onSubmitted: () {
          ref.invalidate(apexDayLogProvider(todayKey));
          ref.invalidate(journalConsistencyProvider(30));
          ref.invalidate(executionStreakProvider);
          ref.invalidate(eliteProfileProvider);
        },
      ),
    ),
  );

  ref.invalidate(apexDayLogProvider(todayKey));
  ref.invalidate(journalConsistencyProvider(30));
  ref.invalidate(executionStreakProvider);
}

class _ApexTabsShell extends ConsumerWidget {
  final ProfileState profileState;
  final ApexGoal? goal;
  final bool goalLoading;
  final String? goalError;
  final VoidCallback onRetry;
  final Future<void> Function(PlayerProfilePageData data) onOpenEditProfile;
  final VoidCallback onOpenGoalFlow;

  const _ApexTabsShell({
    required this.profileState,
    required this.goal,
    required this.goalLoading,
    required this.goalError,
    required this.onRetry,
    required this.onOpenEditProfile,
    required this.onOpenGoalFlow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fridayHighlightColor =
        resolveRankVisualTheme(profileState.data?.unified.ranking.rank).primary;
    final currentPlayerId = profileState.data?.identity.id;

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          // ── AIM / PREPARE / EVALUATE / XCELERATE sub-tab strip ──────────
          Container(
            decoration: BoxDecoration(
              color: context.bg,
              border: Border(
                bottom: BorderSide(
                  color: context.stroke.withValues(alpha: 0.7),
                  width: 0.5,
                ),
              ),
            ),
            child: TabBar(
              isScrollable: true,
              dividerColor: Colors.transparent,
              dividerHeight: 0,
              labelColor: context.fg,
              unselectedLabelColor: context.fgSub,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              labelPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: context.accent,
              indicatorWeight: 2,
              tabs: const [
                Tab(text: 'Aim'),
                Tab(text: 'Prepare'),
                Tab(text: 'Evaluate'),
                Tab(text: 'Xcelerate'),
              ],
            ),
          ),
          // ── Tab content ─────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              children: [
                _PathTab(
                  profileState: profileState,
                  goal: goal,
                  goalLoading: goalLoading,
                  goalError: goalError,
                  onRetry: onRetry,
                  onOpenEditProfile: onOpenEditProfile,
                  onOpenGoalFlow: onOpenGoalFlow,
                ),
                _PlanTab(fridayHighlightColor: fridayHighlightColor),
                const _PerformanceTab(),
                const _ImproveTab(),
              ],
            ),
          ),
        ],
      ),
    );

  }
}

class _PathTab extends StatelessWidget {
  final ProfileState profileState;
  final ApexGoal? goal;
  final bool goalLoading;
  final String? goalError;
  final VoidCallback onRetry;
  final Future<void> Function(PlayerProfilePageData data) onOpenEditProfile;
  final VoidCallback onOpenGoalFlow;

  const _PathTab({
    required this.profileState,
    required this.goal,
    required this.goalLoading,
    required this.goalError,
    required this.onRetry,
    required this.onOpenEditProfile,
    required this.onOpenGoalFlow,
  });

  @override
  Widget build(BuildContext context) {
    if (profileState.isLoading && profileState.data == null) {
      return const _PathLoadingState();
    }

    if (profileState.error != null && profileState.data == null) {
      return _PathErrorState(message: profileState.error!, onRetry: onRetry);
    }

    final data = profileState.data;
    if (data == null) {
      return _PathErrorState(
        message: 'Could not load profile right now.',
        onRetry: onRetry,
      );
    }

    final completeness =
        _ApexProfileCompleteness.fromIdentity(data.unified.identity);
    if (!completeness.isComplete) {
      return _PathProfileIncompleteState(
        missingFields: completeness.missingFields,
        onCompleteProfile: () => onOpenEditProfile(data),
        onRetry: onRetry,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WhoIAmCard(
            profile: data,
            onEditProfile: () => onOpenEditProfile(data),
          ),
          const SizedBox(height: 14),
          _PathSwingIndexCard(
            swingIndex: data.unified.ranking.swingIndex,
            skillMatrix: data.skillMatrix,
          ),
          const SizedBox(height: 14),
          _PathGoalCard(
            goal: goal,
            playerName: data.identity.fullName,
            isLoading: goalLoading,
            error: goalError,
            onSetGoal: onOpenGoalFlow,
            onEditGoal: onOpenGoalFlow,
            onRetry: onRetry,
          ),
        ],
      ),
    );
  }
}

class _PlanTab extends ConsumerWidget {
  static const int _journalWindowDays = 30;

  const _PlanTab({required this.fridayHighlightColor});

  final Color fridayHighlightColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayKey = _eliteDateKey(DateTime.now());
    final todayLogAsync = ref.watch(apexDayLogProvider(todayKey));
    final profileData = ref.watch(profileControllerProvider).data;
    final playerId = profileData?.identity.id;
    final swingIndex = profileData?.unified.ranking.swingIndex ?? 0.0;

    Future<void> openPlanEditor() async {
      await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(builder: (_) => const MyPlanScreen()),
      );
      if (!context.mounted) return;
      ref.invalidate(myPlanProvider);
      ref.invalidate(eliteProfileProvider);
      ref.invalidate(weeklyPlanProvider);
    }

    Future<void> openJournalModal() async {
      await openApexJournalModal(context, ref);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(profileControllerProvider);
        ref.invalidate(myPlanProvider);
        ref.invalidate(eliteProfileProvider);
        ref.invalidate(weeklyPlanProvider);
        ref.invalidate(apexDayLogProvider(todayKey));
        ref.invalidate(journalConsistencyProvider(_journalWindowDays));
        if (playerId != null && playerId.trim().isNotEmpty) {
          ref.invalidate(statsExtendedProvider(playerId.trim()));
        }
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 132),
        children: [
          _PlanSwingIndexCard(swingIndex: swingIndex),
          const SizedBox(height: 14),
          const _SectionLabel('Weekly Plan'),
          const SizedBox(height: 10),
          _MyPlanBlock(
            onCreatePlan: openPlanEditor,
            onEditPlan: openPlanEditor,
            fridayHighlightColor: fridayHighlightColor,
          ),
          const SizedBox(height: 14),
          const _PreparePlanExecutionMonthCard(
            windowDays: _journalWindowDays,
          ),
        ],
      ),
    );

  }
}

// _TodayJournalButton removed as it is now in the ApexHealthShell header


class _PreparePlanExecutionMonthCard extends ConsumerWidget {
  final int windowDays;

  const _PreparePlanExecutionMonthCard({
    required this.windowDays,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consistencyAsync = ref.watch(journalConsistencyProvider(windowDays));
    final weeklyPlanAsync = ref.watch(weeklyPlanProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: consistencyAsync.when(
        loading: () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan vs Execution',
              style: TextStyle(
                color: context.fg,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 10),
            const SizedBox(
              height: 120,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ],
        ),
        error: (error, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan vs Execution',
              style: TextStyle(
                color: context.fg,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),
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
        data: (consistency) {
          final model = _PrepareMonthExecutionModel.fromJournalDays(
            consistency.days,
            weeklyPlan: weeklyPlanAsync.asData?.value,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Plan vs Execution',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh streak',
                    visualDensity: VisualDensity.compact,
                    onPressed: () =>
                        ref.invalidate(journalConsistencyProvider(windowDays)),
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: context.fgSub,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _PrepareMonthAverageBox(model: model),
              const SizedBox(height: 10),
              _PrepareMonthGitHubHeatmap(model: model),
            ],
          );
        },
      ),
    );
  }
}

class _PrepareMonthExecutionModel {
  final DateTime monthStart;
  final DateTime monthEnd;
  final List<_PrepareMonthPoint> points;
  final double averagePct;
  final int scoredDays;
  final int totalDays;

  const _PrepareMonthExecutionModel({
    required this.monthStart,
    required this.monthEnd,
    required this.points,
    required this.averagePct,
    required this.scoredDays,
    required this.totalDays,
  });

  factory _PrepareMonthExecutionModel.fromJournalDays(
    List<JournalDay> days, {
    WeeklyPlan? weeklyPlan,
  }) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    final today = DateTime(now.year, now.month, now.day);

    final byDate = <String, JournalDay>{};
    for (final day in days) {
      final d = DateTime(day.date.year, day.date.month, day.date.day);
      if (d.year == now.year && d.month == now.month) {
        byDate[_prepareMonthDateKey(d)] = day;
      }
    }

    final points = <_PrepareMonthPoint>[];
    var total = 0.0;
    var scored = 0;

    for (var i = 0; i < monthEnd.day; i++) {
      final date = monthStart.add(Duration(days: i));
      if (date.isAfter(today)) {
        points.add(_PrepareMonthPoint(date: date, score: null));
        continue;
      }
      final score = _scoreForDay(
        byDate[_prepareMonthDateKey(date)],
        plannedFallbackFromWeekday:
            _plannedActivitiesFromWeeklyTemplate(weeklyPlan, date),
      );
      if (score != null) {
        total += score;
        scored += 1;
      }
      points.add(_PrepareMonthPoint(date: date, score: score));
    }

    return _PrepareMonthExecutionModel(
      monthStart: monthStart,
      monthEnd: monthEnd,
      points: points,
      averagePct: scored == 0 ? 0 : total / scored,
      scoredDays: scored,
      totalDays: monthEnd.day,
    );
  }

  static int _plannedActivitiesFromWeeklyTemplate(
    WeeklyPlan? weeklyPlan,
    DateTime date,
  ) {
    final plan = weeklyPlan;
    if (plan == null || plan.days.isEmpty) return 0;
    const weekdayKeys = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final weekday = weekdayKeys[(date.weekday - 1).clamp(0, 6)];
    WeeklyPlanDay? row;
    for (final d in plan.days) {
      if (d.weekday == weekday) {
        row = d;
        break;
      }
    }
    if (row == null) return 0;
    return [
      row.netsMinutes,
      row.drillsMinutes,
      row.fitnessMinutes,
      row.recoveryMinutes,
    ].where((v) => v > 0).length;
  }

  static double? _scoreForDay(
    JournalDay? day, {
    int plannedFallbackFromWeekday = 0,
  }) {
    if (day == null) return null;

    var plannedActivities = day.plannedActivityCount;
    if (plannedActivities <= 0) plannedActivities = day.plannedTargets;
    if (plannedActivities <= 0) plannedActivities = plannedFallbackFromWeekday;
    if (plannedActivities <= 0 && day.plannedMinutes > 0) plannedActivities = 1;
    if (plannedActivities <= 0 && day.isPlannedDay) plannedActivities = 1;
    if (plannedActivities <= 0) return null;

    var journaledActivities = day.actualActivityCount;
    if (journaledActivities <= 0) journaledActivities = day.actualTargets;
    if (journaledActivities <= 0 && day.actualMinutes > 0) {
      journaledActivities = 1;
    }
    if (journaledActivities <= 0 && day.isExecutedDay) journaledActivities = 1;

    return ((journaledActivities / plannedActivities).clamp(0.0, 1.0)) * 100.0;
  }
}

class _PrepareMonthPoint {
  final DateTime date;
  final double? score;

  const _PrepareMonthPoint({
    required this.date,
    required this.score,
  });
}

class _PrepareMonthAverageBox extends StatelessWidget {
  final _PrepareMonthExecutionModel model;

  const _PrepareMonthAverageBox({
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        '${_prepareMonthShort(model.monthStart.month)} ${model.monthStart.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: context.panel,
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
                  '$title Avg',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
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

class _PrepareMonthGitHubHeatmap extends StatelessWidget {
  final _PrepareMonthExecutionModel model;

  const _PrepareMonthGitHubHeatmap({
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final byDate = <String, _PrepareMonthPoint>{
      for (final p in model.points) _prepareMonthDateKey(p.date): p,
    };

    final gridStart =
        model.monthStart.subtract(Duration(days: model.monthStart.weekday - 1));
    final gridEnd =
        model.monthEnd.add(Duration(days: 7 - model.monthEnd.weekday));
    final totalCells = gridEnd.difference(gridStart).inDays + 1;
    final weeks = (totalCells / 7).ceil();
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    DateTime dayAt(int week, int dow) =>
        gridStart.add(Duration(days: week * 7 + dow));

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 3.0;
        final usableWidth = constraints.maxWidth - (7 - 1) * gap;
        final cellSize = usableWidth > 0 ? usableWidth / 7 : 14.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ...List.generate(7, (dow) {
                  return Padding(
                    padding: EdgeInsets.only(right: dow == 6 ? 0 : gap),
                    child: SizedBox(
                      width: cellSize,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          dayLabels[dow],
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 4),
            ...List.generate(weeks, (week) {
              return Padding(
                padding: EdgeInsets.only(bottom: week == weeks - 1 ? 0 : gap),
                child: Row(
                  children: [
                    ...List.generate(7, (dow) {
                      final date = dayAt(week, dow);
                      final inMonth = !date.isBefore(model.monthStart) &&
                          !date.isAfter(model.monthEnd);
                      final score = byDate[_prepareMonthDateKey(date)]?.score;

                      return Padding(
                        padding: EdgeInsets.only(right: dow == 6 ? 0 : gap),
                        child: Tooltip(
                          message: inMonth
                              ? '${date.day}/${date.month} • ${score == null ? 'No plan' : '${score.round()}%'}'
                              : '',
                          child: Container(
                            width: cellSize,
                            height: cellSize,
                            decoration: BoxDecoration(
                              color: _heatColor(
                                context,
                                inMonth: inMonth,
                                score: score,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: context.stroke.withValues(alpha: 0.45),
                                width: 0.6,
                              ),
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
                _legendDot(context, context.danger),
                _legendDot(context, const Color(0xFF8BD7A2)),
                _legendDot(context, const Color(0xFF4CAE6E)),
                _legendDot(context, const Color(0xFF1C6B3E)),
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

  Widget _legendDot(BuildContext context, Color color) {
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

String _prepareMonthShort(int month) {
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

String _prepareMonthDateKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class _ScoredDay {
  final DateTime date;
  final double score;

  const _ScoredDay({
    required this.date,
    required this.score,
  });
}

List<_ScoredDay> _windowScoresFromJournalDays(
  List<JournalDay> source, {
  int days = 30,
}) {
  final byDate = <String, double>{};
  for (final day in source) {
    final d = _dayOnlyLocal(day.date);
    byDate[_keyLocalDate(d)] = day.executionScore.clamp(0.0, 100.0);
  }
  final today = _dayOnlyLocal(DateTime.now());
  final start = today.subtract(Duration(days: days - 1));
  return List.generate(days, (i) {
    final d = start.add(Duration(days: i));
    return _ScoredDay(
      date: d,
      score: byDate[_keyLocalDate(d)] ?? 0,
    );
  });
}

int _bestStreak(List<_ScoredDay> days) {
  var run = 0;
  var best = 0;
  for (final day in days) {
    if (day.score > 0) {
      run += 1;
      if (run > best) best = run;
    } else {
      run = 0;
    }
  }
  return best;
}

int _currentStreak(List<_ScoredDay> days) {
  var run = 0;
  for (var i = days.length - 1; i >= 0; i--) {
    if (days[i].score > 0) {
      run += 1;
    } else {
      break;
    }
  }
  return run;
}

double _avgScore(List<_ScoredDay> days) {
  if (days.isEmpty) return 0;
  var total = 0.0;
  for (final day in days) {
    total += day.score;
  }
  return total / days.length;
}

Color _scoreToHeatColor(BuildContext context, double score) {
  if (score <= 0) return context.danger;
  if (score <= 39) return const Color(0xFF8BD7A2);
  if (score <= 74) return const Color(0xFF4CAE6E);
  return const Color(0xFF1C6B3E);
}

// ignore: unused_element
class _GitHubStreakSection extends ConsumerWidget {
  static const int _windowDays = 30;

  const _GitHubStreakSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consistencyAsync = ref.watch(journalConsistencyProvider(_windowDays));

    return consistencyAsync.when(
      loading: () => _SimpleLoadingCard(
        title: 'Plan vs Execution Streak',
        height: 190,
      ),
      error: (error, _) => _SimpleErrorCard(
        title: 'Plan vs Execution Streak',
        message: error.toString(),
        onRetry: () => ref.invalidate(journalConsistencyProvider(_windowDays)),
      ),
      data: (consistency) {
        final points = _windowScoresFromJournalDays(
          consistency.days,
          days: _windowDays,
        );
        final average = consistency.summary.planVsExecutionPct > 0
            ? consistency.summary.planVsExecutionPct
            : _avgScore(points);
        final current = consistency.summary.currentStreak > 0
            ? consistency.summary.currentStreak
            : _currentStreak(points);
        final best = _bestStreak(points);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Plan vs Execution',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh streak',
                    visualDensity: VisualDensity.compact,
                    onPressed: () =>
                        ref.invalidate(journalConsistencyProvider(_windowDays)),
                    icon: Icon(Icons.refresh_rounded,
                        color: context.fgSub, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _StreakStatPill(
                      label: 'Average',
                      value: '${average.round()}%',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StreakStatPill(
                      label: 'Current',
                      value: '${current}d',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StreakStatPill(
                      label: 'Best',
                      value: '${best}d',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _MiniGitHubHeatmap(points: points),
            ],
          ),
        );
      },
    );
  }
}

class _StreakStatPill extends StatelessWidget {
  final String label;
  final String value;

  const _StreakStatPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: context.fg,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniGitHubHeatmap extends StatelessWidget {
  final List<_ScoredDay> points;

  const _MiniGitHubHeatmap({required this.points});

  @override
  Widget build(BuildContext context) {
    final byDate = <String, double>{
      for (final p in points) _keyLocalDate(p.date): p.score,
    };

    final start = points.first.date;
    final end = points.last.date;
    final gridStart = start.subtract(Duration(days: start.weekday - 1));
    final gridEnd = end.add(Duration(days: 7 - end.weekday));
    final total = gridEnd.difference(gridStart).inDays + 1;
    final weeks = (total / 7).ceil();
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    DateTime dayAt(int week, int dow) =>
        gridStart.add(Duration(days: week * 7 + dow));

    return LayoutBuilder(
      builder: (context, constraints) {
        const labelWidth = 24.0;
        const gap = 3.0;
        final usableWidth =
            constraints.maxWidth - labelWidth - (weeks - 1) * gap;
        final cellSize = usableWidth / weeks;

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
                        labels[dow][0],
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ...List.generate(weeks, (week) {
                      final date = dayAt(week, dow);
                      final inWindow =
                          !date.isBefore(start) && !date.isAfter(end);
                      final score = byDate[_keyLocalDate(date)];
                      final color = !inWindow
                          ? context.stroke.withValues(alpha: 0.12)
                          : _scoreToHeatColor(context, score ?? 0);

                      return Padding(
                        padding:
                            EdgeInsets.only(right: week == weeks - 1 ? 0 : gap),
                        child: Tooltip(
                          message: inWindow
                              ? '${date.day}/${date.month} • ${(score ?? 0).round()}%'
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
                Text('Less',
                    style: TextStyle(fontSize: 9.5, color: context.fgSub)),
                const SizedBox(width: 4),
                _heatLegendDot(context, context.danger),
                _heatLegendDot(context, const Color(0xFF8BD7A2)),
                _heatLegendDot(context, const Color(0xFF4CAE6E)),
                _heatLegendDot(context, const Color(0xFF1C6B3E)),
                const SizedBox(width: 4),
                Text('More',
                    style: TextStyle(fontSize: 9.5, color: context.fgSub)),
              ],
            ),
          ],
        );
      },
    );
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

// ignore: unused_element
class _PlanExecutionTrendSection extends ConsumerWidget {
  static const int _windowDays = 30;

  const _PlanExecutionTrendSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consistencyAsync = ref.watch(journalConsistencyProvider(_windowDays));

    return consistencyAsync.when(
      loading: () => _SimpleLoadingCard(
        title: 'Plan vs Execution Trend',
        height: 170,
      ),
      error: (error, _) => _SimpleErrorCard(
        title: 'Plan vs Execution Trend',
        message: error.toString(),
        onRetry: () => ref.invalidate(journalConsistencyProvider(_windowDays)),
      ),
      data: (consistency) {
        final points = _windowScoresFromJournalDays(
          consistency.days,
          days: _windowDays,
        );
        final average = consistency.summary.planVsExecutionPct > 0
            ? consistency.summary.planVsExecutionPct
            : _avgScore(points);

        final spots = <FlSpot>[
          for (var i = 0; i < points.length; i++)
            FlSpot(i.toDouble(), points[i].score)
        ];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Plan vs Execution Trend',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  Text(
                    'Avg ${average.round()}%',
                    style: TextStyle(
                      color: context.accent,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 132,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (points.length - 1).toDouble(),
                    minY: 0,
                    maxY: 100,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 25,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: context.stroke.withValues(alpha: 0.25),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: context.stroke.withValues(alpha: 0.5),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: 25,
                          getTitlesWidget: (value, meta) => Text(
                            '${value.toInt()}',
                            style: TextStyle(
                              color: context.fgSub,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 20,
                          interval: 7,
                          getTitlesWidget: (value, meta) {
                            final i = value.round();
                            if (i < 0 || i >= points.length) {
                              return const SizedBox.shrink();
                            }
                            final d = points[i].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${d.day}/${d.month}',
                                style: TextStyle(
                                  color: context.fgSub,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: context.accent,
                        barWidth: 2.4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: context.accent.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ignore: unused_element
class _QuickReviewStrip extends ConsumerWidget {
  static const int _windowDays = 30;

  const _QuickReviewStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consistencyAsync = ref.watch(journalConsistencyProvider(_windowDays));

    return consistencyAsync.when(
      loading: () => _SimpleLoadingCard(
        title: 'Quick Review',
        height: 120,
      ),
      error: (error, _) => _SimpleErrorCard(
        title: 'Quick Review',
        message: error.toString(),
        onRetry: () => ref.invalidate(journalConsistencyProvider(_windowDays)),
      ),
      data: (consistency) {
        final adherenceRows = consistency.weekly.adherence.entries.toList();
        adherenceRows.sort(
          (a, b) => b.value.completionPct.compareTo(a.value.completionPct),
        );
        final mostDone = adherenceRows.isEmpty
            ? null
            : adherenceRows.firstWhere(
                (row) => row.value.planned > 0 || row.value.actual > 0,
                orElse: () => adherenceRows.first,
              );

        final skippedRows = adherenceRows
            .where((row) => row.value.planned > 0)
            .toList(growable: false)
          ..sort(
            (a, b) => a.value.completionPct.compareTo(b.value.completionPct),
          );
        final mostSkipped = skippedRows.isEmpty ? null : skippedRows.first;

        final reviewItems = [
          (
            'Most Done Activity',
            mostDone == null
                ? 'Not enough data'
                : '${_activityLabel(mostDone.key)} (${mostDone.value.completionPct.round()}%)'
          ),
          (
            'Most Skipped Activity',
            mostSkipped == null
                ? 'Not enough data'
                : '${_activityLabel(mostSkipped.key)} (${mostSkipped.value.completionPct.round()}%)'
          ),
          ('Meal Skipped', 'Waiting for summary endpoint'),
          ('Worst Hydration Days', 'Waiting for summary endpoint'),
          ('Less Sleep Days', 'Waiting for summary endpoint'),
        ];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Review',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 740 ? 3 : 2;
                  const gap = 8.0;
                  final itemWidth =
                      (constraints.maxWidth - gap * (columns - 1)) / columns;

                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: reviewItems.map((item) {
                      return SizedBox(
                        width: itemWidth,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: context.panel,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: context.stroke),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.$1,
                                style: TextStyle(
                                  color: context.fgSub,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.25,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.$2,
                                style: TextStyle(
                                  color: context.fg,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(growable: false),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _activityLabel(String raw) {
    final cleaned = raw.replaceAll('_', ' ').toLowerCase().trim();
    return cleaned
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => '${e[0].toUpperCase()}${e.substring(1)}')
        .join(' ');
  }
}

// ignore: unused_element
class _DailyReflectionClosureCard extends StatelessWidget {
  final AsyncValue<ApexDayLog> dayLogAsync;
  final VoidCallback onOpenJournal;

  const _DailyReflectionClosureCard({
    required this.dayLogAsync,
    required this.onOpenJournal,
  });

  @override
  Widget build(BuildContext context) {
    return dayLogAsync.when(
      loading: () => _SimpleLoadingCard(
        title: 'Daily Reflection',
        height: 122,
      ),
      error: (error, _) => _SimpleErrorCard(
        title: 'Daily Reflection',
        message: error.toString(),
        onRetry: onOpenJournal,
      ),
      data: (log) {
        if (!log.isLocked) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.stroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Reflection',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Today is not locked yet. Submit your journal to generate final reflection.',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onOpenJournal,
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Open Journal'),
                ),
              ],
            ),
          );
        }

        final execution = log.execution;
        final score = log.executionScore;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Reflection',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              _ReflectionLine(
                label: 'One Thing Today',
                value: (log.oneThingToday ?? '').trim(),
              ),
              _ReflectionLine(
                label: 'What I did well',
                value: (execution.whatDidWell ?? '').trim(),
              ),
              _ReflectionLine(
                label: 'What I missed',
                value: (execution.whatDidBadly ?? '').trim(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    score == null ? '—' : '${score.round()}%',
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Final Plan vs Execution',
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReflectionLine extends StatelessWidget {
  final String label;
  final String value;

  const _ReflectionLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final text = value.isEmpty ? 'Not provided' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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
            text,
            style: TextStyle(
              color: context.fg,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _MonthlySummaryCard extends ConsumerWidget {
  static const int _unlockDays = 30;
  static const bool _summaryEndpointAvailable = false;

  const _MonthlySummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consistencyAsync = ref.watch(journalConsistencyProvider(30));

    return consistencyAsync.when(
      loading: () => _SimpleLoadingCard(
        title: 'Monthly Summary',
        height: 120,
      ),
      error: (error, _) => _SimpleErrorCard(
        title: 'Monthly Summary',
        message: error.toString(),
        onRetry: () => ref.invalidate(journalConsistencyProvider(30)),
      ),
      data: (consistency) {
        final activeDays = consistency.summary.activeDaysInWindow;
        final progress = (activeDays / _unlockDays).clamp(0.0, 1.0);
        final remaining = (_unlockDays - activeDays).clamp(0, _unlockDays);
        final unlocked = _summaryEndpointAvailable && activeDays >= _unlockDays;

        if (!unlocked) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.stroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Monthly Summary',
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    Icon(Icons.lock_outline_rounded,
                        color: context.fgSub, size: 16),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Complete 30 days of journaling to unlock your monthly summary.',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: context.stroke.withValues(alpha: 0.35),
                    valueColor: AlwaysStoppedAnimation<Color>(context.accent),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$activeDays/$_unlockDays days complete • $remaining days left',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        // TODO(summary-api): replace this fallback when range-summary endpoint is available.
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.stroke),
          ),
          child: Text(
            'Monthly summary is ready.',
            style: TextStyle(color: context.fg),
          ),
        );
      },
    );
  }
}

class _SimpleLoadingCard extends StatelessWidget {
  final String title;
  final double height;

  const _SimpleLoadingCard({
    required this.title,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.fg,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: height,
            decoration: BoxDecoration(
              color: context.stroke.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleErrorCard extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const _SimpleErrorCard({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.fg,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: TextStyle(color: context.fgSub, fontSize: 11.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

DateTime _dayOnlyLocal(DateTime date) =>
    DateTime(date.year, date.month, date.day);

String _keyLocalDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

enum _EvaluateStatsFilter {
  all,
  batting,
  bowling,
  fielding,
  captaincy,
}

extension _EvaluateStatsFilterX on _EvaluateStatsFilter {
  String get label {
    switch (this) {
      case _EvaluateStatsFilter.all:
        return 'All';
      case _EvaluateStatsFilter.batting:
        return 'Batting';
      case _EvaluateStatsFilter.bowling:
        return 'Bowling';
      case _EvaluateStatsFilter.fielding:
        return 'Fielding';
      case _EvaluateStatsFilter.captaincy:
        return 'Captaincy';
    }
  }

  EliteMetricCategory? get category {
    switch (this) {
      case _EvaluateStatsFilter.all:
        return null;
      case _EvaluateStatsFilter.batting:
        return EliteMetricCategory.batting;
      case _EvaluateStatsFilter.bowling:
        return EliteMetricCategory.bowling;
      case _EvaluateStatsFilter.fielding:
        return EliteMetricCategory.fielding;
      case _EvaluateStatsFilter.captaincy:
        return EliteMetricCategory.captaincy;
    }
  }
}

class _PerformanceTab extends ConsumerStatefulWidget {
  const _PerformanceTab();

  @override
  ConsumerState<_PerformanceTab> createState() => _PerformanceTabState();
}

class _PerformanceTabState extends ConsumerState<_PerformanceTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  _EvaluateStatsFilter _selectedFilter = _EvaluateStatsFilter.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshAll({required String playerId}) async {
    final futures = <Future<void>>[
      ref.read(profileControllerProvider.notifier).refresh(),
    ];
    if (playerId.trim().isNotEmpty) {
      futures.add(
        ref.read(statsExtendedProvider(playerId.trim()).notifier).refresh(),
      );
    }
    await Future.wait(futures);
  }

  List<EliteExtendedMetricItem> _filteredMetrics(StatsExtendedState state) {
    final category = _selectedFilter.category;
    if (category == null) return state.metricItems;
    return state.metricItems
        .where((metric) => metric.category == category)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final profileData = profileState.data;
    final playerId = profileData?.identity.id.trim() ?? '';
    final swingIndex = profileData?.unified.ranking.swingIndex ?? 0.0;
    final hasPlayerId = playerId.isNotEmpty;
    final statsState = hasPlayerId
        ? ref.watch(statsExtendedProvider(playerId))
        : const StatsExtendedState();

    if (hasPlayerId && !statsState.hasLoaded && !statsState.isLoading) {
      Future.microtask(
        () => ref.read(statsExtendedProvider(playerId).notifier).load(),
      );
    }

    final filteredMetrics = _filteredMetrics(statsState);
    final retryStats = hasPlayerId
        ? () => ref.read(statsExtendedProvider(playerId).notifier).refresh()
        : null;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          child: _PlanSwingIndexCard(swingIndex: swingIndex),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.stroke),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: context.panel,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: context.fg,
              unselectedLabelColor: context.fgSub,
              labelStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Stats'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _EvaluateOverviewPane(
                state: statsState,
                onRefresh: () => _refreshAll(playerId: playerId),
              ),
              _EvaluateStatsPane(
                state: statsState,
                filteredMetrics: filteredMetrics,
                selectedFilter: _selectedFilter,
                onRefresh: () => _refreshAll(playerId: playerId),
                onRetry: retryStats,
                onFilterChanged: (filter) {
                  if (_selectedFilter == filter) return;
                  setState(() => _selectedFilter = filter);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EvaluateOverviewPane extends StatelessWidget {
  const _EvaluateOverviewPane({
    required this.state,
    required this.onRefresh,
  });

  final StatsExtendedState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final battingCount = state.metricItems
        .where((metric) => metric.category == EliteMetricCategory.batting)
        .length;
    final bowlingCount = state.metricItems
        .where((metric) => metric.category == EliteMetricCategory.bowling)
        .length;
    final fieldingCount = state.metricItems
        .where((metric) => metric.category == EliteMetricCategory.fielding)
        .length;
    final captaincyCount = state.metricItems
        .where((metric) => metric.category == EliteMetricCategory.captaincy)
        .length;
    final evidenceCount =
        state.metricItems.where((metric) => metric.hasEvidence).length;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
        children: [
          if (state.isLoading && !state.hasLoaded)
            const _SimpleLoadingCard(title: 'Evaluate Overview', height: 96)
          else if (state.isLocked)
            _EvaluateInfoCard(
              title: 'Premium Locked',
              message: state.lockMessage?.trim().isNotEmpty == true
                  ? state.lockMessage!.trim()
                  : 'Unlock the APEX Pack to view detailed evaluation stats.',
              icon: Icons.lock_outline_rounded,
              iconColor: context.warn,
            )
          else if (state.error != null && state.metricItems.isEmpty)
            _SimpleErrorCard(
              title: 'Evaluate Overview',
              message: state.error!,
              onRetry: () => onRefresh(),
            )
          else if (state.metricItems.isEmpty)
            _EvaluateInfoCard(
              title: 'Evaluate Overview',
              message: 'No metrics available yet.',
              icon: Icons.bar_chart_rounded,
              iconColor: context.fgSub,
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.stroke),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Metrics Coverage',
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _EvaluateSummaryChip(
                        label: 'Total',
                        value: '${state.metricItems.length}',
                      ),
                      _EvaluateSummaryChip(
                        label: 'Evidence',
                        value: '$evidenceCount',
                      ),
                      _EvaluateSummaryChip(
                        label: 'Batting',
                        value: '$battingCount',
                      ),
                      _EvaluateSummaryChip(
                        label: 'Bowling',
                        value: '$bowlingCount',
                      ),
                      _EvaluateSummaryChip(
                        label: 'Fielding',
                        value: '$fieldingCount',
                      ),
                      _EvaluateSummaryChip(
                        label: 'Captaincy',
                        value: state.captaincyApplicable
                            ? '$captaincyCount'
                            : 'Not applicable',
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EvaluateStatsPane extends StatelessWidget {
  const _EvaluateStatsPane({
    required this.state,
    required this.filteredMetrics,
    required this.selectedFilter,
    required this.onRefresh,
    required this.onRetry,
    required this.onFilterChanged,
  });

  final StatsExtendedState state;
  final List<EliteExtendedMetricItem> filteredMetrics;
  final _EvaluateStatsFilter selectedFilter;
  final Future<void> Function() onRefresh;
  final VoidCallback? onRetry;
  final ValueChanged<_EvaluateStatsFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final captaincyNotApplicable =
        selectedFilter == _EvaluateStatsFilter.captaincy &&
            !state.captaincyApplicable;
    final showStateOnly = (state.isLoading && !state.hasLoaded) ||
        state.isLocked ||
        (state.error != null && state.metricItems.isEmpty) ||
        captaincyNotApplicable ||
        filteredMetrics.isEmpty;
    final rowCount = showStateOnly ? 2 : 2 + filteredMetrics.length;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
        itemCount: rowCount,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _EvaluateStatsFilterChips(
                selected: selectedFilter,
                onChanged: onFilterChanged,
              ),
            );
          }

          if (index == 1) {
            if (state.isLoading && !state.hasLoaded) {
              return const _SimpleLoadingCard(
                  title: 'Premium Metrics', height: 96);
            }
            if (state.isLocked) {
              return _EvaluateInfoCard(
                title: 'Premium Metrics',
                message: state.lockMessage?.trim().isNotEmpty == true
                    ? state.lockMessage!.trim()
                    : 'Unlock the APEX Pack to view detailed metrics.',
                icon: Icons.lock_outline_rounded,
                iconColor: context.warn,
              );
            }
            if (state.error != null && state.metricItems.isEmpty) {
              return _SimpleErrorCard(
                title: 'Premium Metrics',
                message: state.error!,
                onRetry: onRetry ?? () => onRefresh(),
              );
            }
            if (captaincyNotApplicable) {
              return _EvaluateInfoCard(
                title: 'Captaincy',
                message: 'Not applicable',
                icon: Icons.info_outline_rounded,
                iconColor: context.fgSub,
              );
            }
            if (filteredMetrics.isEmpty) {
              return _EvaluateInfoCard(
                title: 'Premium Metrics',
                message: 'No metrics available for this category yet.',
                icon: Icons.bar_chart_rounded,
                iconColor: context.fgSub,
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _EvaluateListHeader(
                count: filteredMetrics.length,
                isRefreshing: state.isLoading,
              ),
            );
          }

          final metric = filteredMetrics[index - 2];
          return _EvaluateMetricRow(metric: metric);
        },
      ),
    );
  }
}

class _EvaluateStatsFilterChips extends StatelessWidget {
  const _EvaluateStatsFilterChips({
    required this.selected,
    required this.onChanged,
  });

  final _EvaluateStatsFilter selected;
  final ValueChanged<_EvaluateStatsFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _EvaluateStatsFilter.values
          .map(
            (filter) => ChoiceChip(
              selected: selected == filter,
              label: Text(filter.label),
              onSelected: (_) => onChanged(filter),
              labelStyle: TextStyle(
                color: selected == filter ? Colors.white : context.fgSub,
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
              ),
              backgroundColor: context.cardBg,
              selectedColor: context.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: context.stroke),
              ),
              visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _EvaluateListHeader extends StatelessWidget {
  const _EvaluateListHeader({
    required this.count,
    required this.isRefreshing,
  });

  final int count;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          Text(
            '$count metrics',
            style: TextStyle(
              color: context.fg,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (isRefreshing) ...[
            const SizedBox(width: 10),
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.accent,
              ),
            ),
          ],
          const Spacer(),
          Text(
            'Pull to refresh',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EvaluateMetricRow extends StatelessWidget {
  const _EvaluateMetricRow({required this.metric});

  final EliteExtendedMetricItem metric;

  @override
  Widget build(BuildContext context) {
    final value = metric.hasEvidence
        ? metric.value
        : metric.category == EliteMetricCategory.captaincy
            ? 'Not applicable'
            : 'N/A';
    final evidenceBadgeLabel = metric.hasEvidence
        ? 'Evidence'
        : metric.category == EliteMetricCategory.captaincy
            ? 'Not applicable'
            : 'No evidence';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.label,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _EvaluateMetricBadge(
                      label: evidenceBadgeLabel,
                      color:
                          metric.hasEvidence ? context.success : context.warn,
                    ),
                    if (metric.isPremium)
                      _EvaluateMetricBadge(
                        label: 'APEX',
                        color: context.accent,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: metric.hasEvidence ? context.fg : context.fgSub,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              if (metric.unit.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  metric.unit,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _EvaluateMetricBadge extends StatelessWidget {
  const _EvaluateMetricBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EvaluateInfoCard extends StatelessWidget {
  const _EvaluateInfoCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
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

class _EvaluateSummaryChip extends StatelessWidget {
  const _EvaluateSummaryChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.stroke.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
    );
  }
}

class _ImproveTab extends StatelessWidget {
  const _ImproveTab();

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

class _ApexProfileCompleteness {
  final bool isComplete;
  final List<String> missingFields;

  const _ApexProfileCompleteness({
    required this.isComplete,
    required this.missingFields,
  });

  factory _ApexProfileCompleteness.fromIdentity(ProfileIdentity identity) {
    final checks = <String, String?>{
      'Name': identity.name,
      'Avatar': identity.avatarUrl,
      'City': identity.city,
      'Player Role': identity.playerRole,
      'Batting Style': identity.battingStyle,
      'Bowling Style': identity.bowlingStyle,
      'Level': identity.level,
    };

    final missing = checks.entries
        .where((entry) => !_hasValue(entry.value))
        .map((entry) => entry.key)
        .toList(growable: false);

    return _ApexProfileCompleteness(
      isComplete: missing.isEmpty,
      missingFields: missing,
    );
  }

  static bool _hasValue(String? value) {
    if (value == null) return false;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    final normalized = trimmed.toLowerCase();
    return normalized != 'null' && normalized != '-';
  }
}

class _PathLoadingState extends StatelessWidget {
  const _PathLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: [
        ...List.generate(
          4,
          (_) => Container(
            height: 126,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.stroke),
            ),
          ),
        ),
      ],
    );
  }
}

class _PathErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PathErrorState({
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
          title: 'Path Unavailable',
          subtitle: 'Could not load your profile context for Apex right now.',
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

class _PathProfileIncompleteState extends StatelessWidget {
  final List<String> missingFields;
  final VoidCallback onCompleteProfile;
  final VoidCallback onRetry;

  const _PathProfileIncompleteState({
    required this.missingFields,
    required this.onCompleteProfile,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: [
        ProfileSectionCard(
          title: 'Complete Profile',
          subtitle:
              'Apex Path unlocks after your core player profile is updated.',
          trailing: Icon(Icons.verified_user_outlined, color: context.accent),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Missing fields: ${missingFields.join(', ')}',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: missingFields
                    .map(
                      (item) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.panel,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: context.stroke),
                        ),
                        child: Text(
                          item,
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onCompleteProfile,
                      child: const Text('Complete Profile'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: onRetry,
                    child: const Text('Refresh'),
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

class _WhoIAmCard extends StatelessWidget {
  final PlayerProfilePageData profile;
  final VoidCallback onEditProfile;

  const _WhoIAmCard({
    required this.profile,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final identity = profile.identity;
    final unified = profile.unified.identity;
    final city = unified.city.trim().isNotEmpty ? unified.city : identity.city;
    final avatarUrl = (unified.avatarUrl ?? identity.avatarUrl)?.trim();
    final displayName = identity.fullName.trim().isNotEmpty
        ? identity.fullName.trim()
        : unified.name.trim();
    final details = <String>[
      _display(identity.primaryRole),
      _display(identity.battingStyle),
      _display(identity.bowlingStyle),
      _display(identity.level),
    ].where((item) => item != '-').map(_formatDetail).toList(growable: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: context.panel,
                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? CachedNetworkImageProvider(avatarUrl)
                    : null,
                child: (avatarUrl == null || avatarUrl.isEmpty)
                    ? Text(
                        _initial(identity.fullName),
                        style: TextStyle(
                          color: context.fg,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName.isNotEmpty ? displayName : '-',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (city.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 13, color: context.fgSub),
                          const SizedBox(width: 4),
                          Text(
                            city,
                            style: TextStyle(
                              color: context.fgSub,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.check_circle_rounded,
                color: context.success,
                size: 18,
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Edit Profile',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                style: IconButton.styleFrom(
                  backgroundColor: context.panel,
                  side: BorderSide(color: context.stroke),
                ),
                onPressed: onEditProfile,
                icon: Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: context.fgSub,
                ),
              ),
            ],
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              details.join(' • '),
              style: TextStyle(
                color: context.fgSub,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _display(String value) => value.trim().isEmpty ? '-' : value.trim();

  String _formatDetail(String value) {
    return value
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .split(' ')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _initial(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }
}

class _PathSwingIndexCard extends StatelessWidget {
  final double swingIndex;
  final PlayerSkillMatrix skillMatrix;

  const _PathSwingIndexCard({
    required this.swingIndex,
    required this.skillMatrix,
  });

  @override
  Widget build(BuildContext context) {
    final summary = SwingIndexSummary(
      swingIndexScore: swingIndex.clamp(0, 100).toDouble(),
      axes: <String, double>{
        SwingIndexAxisKeys.reliabilityAxis: skillMatrix.consistency,
        SwingIndexAxisKeys.powerAxis: skillMatrix.batting,
        SwingIndexAxisKeys.bowlingAxis: skillMatrix.bowling,
        SwingIndexAxisKeys.fieldingAxis: skillMatrix.fielding,
        SwingIndexAxisKeys.impactAxis: skillMatrix.clutch,
      },
    );

    return SwingIndexRadarCard(
      summary: summary,
      scoreLabel: 'APEX SCORE',
      subtitle: 'Updated from latest performance',
      showInsights: false,
    );
  }
}

class _PathGoalCard extends StatelessWidget {
  final ApexGoal? goal;
  final String playerName;
  final bool isLoading;
  final String? error;
  final VoidCallback onSetGoal;
  final VoidCallback onEditGoal;
  final VoidCallback onRetry;

  const _PathGoalCard({
    required this.goal,
    required this.playerName,
    required this.isLoading,
    required this.error,
    required this.onSetGoal,
    required this.onEditGoal,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (goal != null) {
      return _GoalCard(
        goal: goal!,
        playerName: playerName,
        onEdit: onEditGoal,
      );
    }

    return ProfileSectionCard(
      title: 'Goal',
      subtitle: 'Who you want to become.',
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading && goal == null) {
      return const SizedBox(
        height: 72,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null && goal == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Could not load goal right now.',
            style: TextStyle(
              color: context.fg,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error!,
            style: TextStyle(color: context.fgSub, fontSize: 11.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
          ),
        ],
      );
    }

    if (goal == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You have not set your Apex goal yet.',
            style: TextStyle(color: context.fgSub, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onSetGoal,
            child: const Text('Set Goal'),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

// ── No Goal Screen ────────────────────────────────────────────────────────────

// ignore: unused_element
class _NoGoalScreen extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSetup;
  const _NoGoalScreen({required this.isLoading, required this.onSetup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Apex',
                  style: TextStyle(
                      color: context.fg,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Text(
                'Get 1% better every day.',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: context.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.track_changes_rounded,
                      color: context.accent, size: 26),
                ),
                const SizedBox(height: 20),
                Text('Define your path',
                    style: TextStyle(
                        color: context.fg,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3)),
                const SizedBox(height: 8),
                Text(
                  'Set your target role, level, and commitment.\nElite athletes know exactly where they\'re going.',
                  style: TextStyle(
                      color: context.fgSub,
                      fontSize: 14,
                      height: 1.55,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Set up my goal',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                ),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Goal Dashboard ────────────────────────────────────────────────────────────

// ignore: unused_element
class _GoalDashboard extends ConsumerWidget {
  final ApexGoal goal;
  final String playerName;
  final bool journaledToday;
  final double disciplineScore;
  final Map<String, Map<String, int>> planAdherence;
  final VoidCallback onEdit;
  final VoidCallback onJournal;
  final VoidCallback onToday;
  final VoidCallback onWeeklyPlan;

  const _GoalDashboard({
    required this.goal,
    required this.playerName,
    required this.journaledToday,
    required this.disciplineScore,
    required this.planAdherence,
    required this.onEdit,
    required this.onJournal,
    required this.onToday,
    required this.onWeeklyPlan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onJournal,
        backgroundColor: context.accent,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(Icons.edit_note_rounded, size: 20),
        label: Text(
          journaledToday ? 'Log Again' : 'Log Today',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(eliteProfileProvider);
          ref.invalidate(executionStreakProvider);
          ref.invalidate(journalConsistencyProvider(30));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: context.bg,
              elevation: 0,
              titleSpacing: 24,
              toolbarHeight: 70,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Apex',
                      style: TextStyle(
                          color: context.fg,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 2),
                  Text(
                    'Get 1% better every day.',
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Goal Card ──────────────────────────────────────────
                    _GoalCard(
                        goal: goal, playerName: playerName, onEdit: onEdit),

                    const SizedBox(height: 20),

                    // ── My Plan ────────────────────────────────────────────
                    const _SectionLabel('My Plan'),
                    const SizedBox(height: 10),
                    _MyPlanBlock(
                      onCreatePlan: onWeeklyPlan,
                      onEditPlan: onWeeklyPlan,
                      fridayHighlightColor: context.accent,
                    ),

                    const SizedBox(height: 28),
                    Divider(color: context.stroke, height: 1),
                    const SizedBox(height: 20),

                    // ── Discipline | Streak tabs ───────────────────────────
                    _StatsTabs(
                      score: disciplineScore,
                      adherence: planAdherence,
                    ),

                    const SizedBox(height: 28),
                    Divider(color: context.stroke, height: 1),
                    const SizedBox(height: 20),

                    // ── Execution History ──────────────────────────────────
                    const _SectionLabel('Execution history'),
                    const SizedBox(height: 12),
                    const ExecutionHeatmapWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bold Goal Card ────────────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  final ApexGoal goal;
  final String playerName;
  final VoidCallback onEdit;

  const _GoalCard(
      {required this.goal, required this.playerName, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final commitment = goal.commitmentStatement.isNotEmpty
        ? goal.commitmentStatement
        : '${goal.targetLevel} ${goal.targetRole} in ${goal.timeline}';
    final displayName =
        playerName.trim().isNotEmpty ? playerName.trim() : 'Champion';

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF050505),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.campaign_rounded,
                  color: Colors.white.withValues(alpha: 0.62),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Hey $displayName, don't forget your goal.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withValues(alpha: 0.35), size: 12),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '"$commitment"',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                height: 1.4,
                letterSpacing: -0.15,
              ),
            ),
            const SizedBox(height: 20),
            // Pill row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (goal.targetRole.isNotEmpty)
                  _DarkPill(label: goal.targetRole.replaceAll('_', ' ')),
                if (goal.targetFormat.isNotEmpty)
                  _DarkPill(label: goal.targetFormat),
                if (goal.targetLevel.isNotEmpty)
                  _DarkPill(label: goal.targetLevel),
                if (goal.timeline.isNotEmpty) _DarkPill(label: goal.timeline),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GoalDetailSheet(goal: goal, onEdit: onEdit),
    );
  }
}

class _DarkPill extends StatelessWidget {
  final String label;
  const _DarkPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.92),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ── Goal Detail Bottom Sheet ──────────────────────────────────────────────────

class _GoalDetailSheet extends StatelessWidget {
  final ApexGoal goal;
  final VoidCallback onEdit;

  const _GoalDetailSheet({required this.goal, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: context.bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.stroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Goal Detail',
                            style: TextStyle(
                                color: context.fg,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3)),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onEdit();
                          },
                          child: Text('Edit',
                              style: TextStyle(
                                  color: context.accent,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Stat grid
                    _SheetStatRow(
                        label: 'Role',
                        value: goal.targetRole.replaceAll('_', ' ')),
                    _SheetDivider(),
                    _SheetStatRow(label: 'Format', value: goal.targetFormat),
                    _SheetDivider(),
                    _SheetStatRow(label: 'Level', value: goal.targetLevel),
                    _SheetDivider(),
                    _SheetStatRow(label: 'Timeline', value: goal.timeline),

                    if (goal.focusAreas.isNotEmpty) ...[
                      _SheetDivider(),
                      const SizedBox(height: 4),
                      Text('Focus areas',
                          style: TextStyle(
                              color: context.fgSub,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: goal.focusAreas
                            .map((f) => _SheetChip(label: f))
                            .toList(),
                      ),
                    ],

                    if (goal.styleIdentity.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text('Style identity',
                          style: TextStyle(
                              color: context.fgSub,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4)),
                      const SizedBox(height: 8),
                      Text(
                        goal.styleIdentity,
                        style: TextStyle(
                            color: context.fg,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.5),
                      ),
                    ],

                    if (goal.commitmentStatement.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text('Commitment',
                          style: TextStyle(
                              color: context.fgSub,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4)),
                      const SizedBox(height: 8),
                      Text(
                        '"${goal.commitmentStatement}"',
                        style: TextStyle(
                            color: context.fg,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SheetStatRow extends StatelessWidget {
  final String label;
  final String value;
  const _SheetStatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: context.fgSub,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          Text(value,
              style: TextStyle(
                  color: context.fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _SheetDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Divider(color: context.stroke, height: 1);
}

class _SheetChip extends StatelessWidget {
  final String label;
  const _SheetChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.stroke),
      ),
      child: Text(label,
          style: TextStyle(
              color: context.fg, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: TextStyle(
          color: context.fgSub,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      );
}

class _PlanSwingIndexCard extends StatelessWidget {
  const _PlanSwingIndexCard({required this.swingIndex});

  final double swingIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          Icon(Icons.speed_rounded, color: context.accent, size: 18),
          const SizedBox(width: 8),
          Text(
            'Swing Index',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Tooltip(
            message: 'SWI is backend-calculated and confidence-adjusted.',
            child: Icon(
              Icons.info_outline_rounded,
              size: 15,
              color: context.fgSub,
            ),
          ),
          const Spacer(),
          Text(
            swingIndex.toStringAsFixed(1),
            style: TextStyle(
              color: context.fg,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── My Plan Block ─────────────────────────────────────────────────────────────

class _MyPlanBlock extends ConsumerWidget {
  final VoidCallback onCreatePlan;
  final VoidCallback onEditPlan;
  final Color fridayHighlightColor;

  const _MyPlanBlock({
    required this.onCreatePlan,
    required this.onEditPlan,
    required this.fridayHighlightColor,
  });

  static const _icons = {
    ActivityCategory.nets: Icons.sports_cricket_rounded,
    ActivityCategory.skillWork: Icons.adjust_rounded,
    ActivityCategory.conditioning: Icons.directions_run_rounded,
    ActivityCategory.gym: Icons.fitness_center_rounded,
    ActivityCategory.match: Icons.emoji_events_rounded,
    ActivityCategory.recovery: Icons.favorite_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(myPlanProvider);

    return planAsync.when(
      loading: () => _PlanSkeleton(),
      error: (e, _) => _PlanError(
        onRetry: () => ref.invalidate(myPlanProvider),
        detail: e.toString(),
      ),
      data: (plan) {
        if (plan == null || plan.activities.isEmpty) {
          return _PlanEmpty(onTap: onCreatePlan);
        }
        return _PlanSummary(
          plan: plan,
          icons: _icons,
          onEdit: onEditPlan,
          fridayHighlightColor: fridayHighlightColor,
        );
      },
    );
  }
}

class _PlanEmpty extends StatelessWidget {
  final VoidCallback onTap;
  const _PlanEmpty({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.stroke),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.add_rounded, color: context.accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create your training plan',
                      style: TextStyle(
                          color: context.fg,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('Set which activities you commit to each week',
                      style: TextStyle(color: context.fgSub, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.fgSub, size: 20),
          ],
        ),
      ),
    );
  }
}

class _PlanSummary extends StatefulWidget {
  final MyPlan plan;
  final Map<ActivityCategory, IconData> icons;
  final VoidCallback onEdit;
  final Color fridayHighlightColor;

  const _PlanSummary({
    required this.plan,
    required this.icons,
    required this.onEdit,
    required this.fridayHighlightColor,
  });

  @override
  State<_PlanSummary> createState() => _PlanSummaryState();
}

class _PlanSummaryState extends State<_PlanSummary> {
  static const _planDayPrefsKey = 'elite_my_plan_selected_days_v1';
  static const _weekDayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  Map<ActivityCategory, Set<int>> _storedDays = const {};

  @override
  void initState() {
    super.initState();
    _loadStoredDays();
  }

  @override
  void didUpdateWidget(covariant _PlanSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadStoredDays();
  }

  Future<void> _loadStoredDays() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_planDayPrefsKey);
    if (raw == null || raw.isEmpty) {
      if (!mounted) return;
      setState(() => _storedDays = const {});
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
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

      if (!mounted) return;
      setState(() => _storedDays = out);
    } catch (_) {
      // Keep fallback behavior based on timesPerWeek.
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

  Set<int> _daysFor(PlannedActivity activity) {
    final fromPlan = activity.days.where((d) => d >= 1 && d <= 7).toSet();
    if (fromPlan.isNotEmpty) return fromPlan;
    final fromPrefs = _storedDays[activity.category];
    if (fromPrefs != null && fromPrefs.isNotEmpty) return fromPrefs;
    return _defaultDaysForCount(activity.timesPerWeek);
  }

  BorderRadius _segmentRadius({
    required bool active,
    required bool prevActive,
    required bool nextActive,
  }) {
    if (!active) return BorderRadius.circular(4);
    return BorderRadius.horizontal(
      left: Radius.circular(prevActive ? 2 : 7),
      right: Radius.circular(nextActive ? 2 : 7),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayWeekday = DateTime.now().weekday;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(widget.plan.name,
                  style: TextStyle(
                      color: context.fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton(
                onPressed: widget.onEdit,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  minimumSize: const Size(0, 28),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Edit',
                  style: TextStyle(
                    color: context.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 108),
              Expanded(
                child: Row(
                  children: _weekDayLabels
                      .asMap()
                      .entries
                      .map((entry) => Expanded(
                            child: Center(
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  color: (entry.key + 1) == DateTime.friday
                                      ? widget.fridayHighlightColor
                                      : ((entry.key + 1) == todayWeekday
                                          ? context.accent
                                          : context.fgSub),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...widget.plan.activities.map((activity) {
            final days = _daysFor(activity);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 108,
                    child: Row(
                      children: [
                        Icon(
                          widget.icons[activity.category],
                          size: 13,
                          color: context.accent,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            activity.category.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.fg,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: List.generate(7, (i) {
                        final day = i + 1;
                        final active = days.contains(day);
                        final isFriday = day == DateTime.friday;
                        final prevActive = i > 0 && days.contains(day - 1);
                        final nextActive = i < 6 && days.contains(day + 1);
                        return Expanded(
                          child: Container(
                            height: 18,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: active
                                  ? (isFriday
                                      ? widget.fridayHighlightColor
                                          .withValues(alpha: 0.9)
                                      : context.accent.withValues(alpha: 0.88))
                                  : context.stroke.withValues(alpha: 0.15),
                              border: Border.all(
                                color: active
                                    ? (isFriday
                                        ? widget.fridayHighlightColor
                                            .withValues(alpha: 0.98)
                                        : context.accent
                                            .withValues(alpha: 0.98))
                                    : context.stroke.withValues(alpha: 0.35),
                              ),
                              borderRadius: _segmentRadius(
                                active: active,
                                prevActive: prevActive,
                                nextActive: nextActive,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.bedtime_rounded, size: 12, color: context.fgSub),
              const SizedBox(width: 4),
              Text('${widget.plan.sleepTargetHours}h sleep',
                  style: TextStyle(color: context.fgSub, fontSize: 11)),
              const SizedBox(width: 12),
              Icon(Icons.water_drop_rounded, size: 12, color: context.fgSub),
              const SizedBox(width: 4),
              Text('${widget.plan.hydrationTargetLiters}L hydration',
                  style: TextStyle(color: context.fgSub, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanError extends StatelessWidget {
  final VoidCallback onRetry;
  final String detail;
  const _PlanError({required this.onRetry, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Could not load My Plan',
            style: TextStyle(
              color: context.fg,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: TextStyle(color: context.fgSub, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              minimumSize: const Size(0, 28),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Retry',
              style: TextStyle(
                color: context.accent,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
    );
  }
}

// ── Stats Tabs (Discipline | Streak) ─────────────────────────────────────────

class _StatsTabs extends StatefulWidget {
  final double score;
  final Map<String, Map<String, int>> adherence;

  const _StatsTabs({
    required this.score,
    required this.adherence,
  });

  @override
  State<_StatsTabs> createState() => _StatsTabsState();
}

class _StatsTabsState extends State<_StatsTabs> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab bar
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.stroke),
          ),
          child: Row(
            children: [
              _TabChip(
                label: 'Discipline',
                active: _tab == 0,
                onTap: () => setState(() => _tab = 0),
              ),
              _TabChip(
                label: 'Streak',
                active: _tab == 1,
                onTap: () => setState(() => _tab = 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _tab == 0
              ? _DisciplineScoreWidget(
                  key: const ValueKey('disc'),
                  score: widget.score,
                  adherence: widget.adherence,
                )
              : const _StreakSection(key: ValueKey('streak')),
        ),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: active ? context.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : context.fgSub,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Discipline Score Widget ───────────────────────────────────────────────────

class _DisciplineScoreWidget extends ConsumerWidget {
  final double score;
  final Map<String, Map<String, int>> adherence;

  const _DisciplineScoreWidget({
    super.key,
    required this.score,
    required this.adherence,
  });

  Color _gaugeColor(double value) {
    if (value >= 75) return const Color(0xFF3FA66A); // neon green
    if (value >= 40) return const Color(0xFFF5A623); // amber
    return const Color(0xFFE53935); // red
  }

  String _label(double value) {
    if (value >= 75) return 'Apex Elite';
    if (value >= 40) return 'Performing';
    return 'Inconsistent';
  }

  double _executionAverage(List<ExecutionStreakEntry> entries) {
    if (entries.isEmpty) return 0;

    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final byDate = {
      for (final e in entries)
        DateTime(e.date.year, e.date.month, e.date.day): e.score
    };
    final earliest =
        entries.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b);
    var cursor = DateTime(earliest.year, earliest.month, earliest.day);
    double total = 0;
    int count = 0;
    while (!cursor.isAfter(todayNorm)) {
      total += byDate[cursor] ?? 0.0;
      count++;
      cursor = cursor.add(const Duration(days: 1));
    }
    return count == 0 ? 0 : total / count;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final executionAsync = ref.watch(executionStreakProvider);
    final executionAvg = executionAsync.asData == null
        ? null
        : _executionAverage(executionAsync.asData!.value);
    final effectiveScore = executionAvg ?? score;

    final color = _gaugeColor(effectiveScore);
    final hasAdherence = adherence.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DISCIPLINE SCORE',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Plan vs Execution: ${effectiveScore.round()}%',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular gauge
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: _GaugePainter(
                    progress: (effectiveScore / 100).clamp(0.0, 1.0),
                    color: color,
                    trackColor: context.stroke.withValues(alpha: 0.35),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${effectiveScore.round()}%',
                          style: TextStyle(
                            color: color,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          _label(effectiveScore),
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Breakdown
              Expanded(
                child: hasAdherence
                    ? _BreakdownGrid(adherence: adherence)
                    : _EmptyBreakdown(score: effectiveScore),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  const _GaugePainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 9.0;
    const startAngle = -2.356194; // -135°
    const fullSweep = 4.712389; // 270°

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // Track
    canvas.drawArc(
      rect,
      startAngle,
      fullSweep,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    if (progress <= 0) return;

    // Progress arc
    canvas.drawArc(
      rect,
      startAngle,
      fullSweep * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.progress != progress || old.color != color;
}

class _BreakdownGrid extends StatelessWidget {
  final Map<String, Map<String, int>> adherence;

  const _BreakdownGrid({required this.adherence});

  static const _activityLabels = {
    'NETS': 'Nets',
    'SKILL_WORK': 'Skill Work',
    'CONDITIONING': 'Conditioning',
    'GYM': 'Gym',
    'MATCH': 'Match',
    'RECOVERY': 'Recovery',
  };

  @override
  Widget build(BuildContext context) {
    final entries = adherence.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries.map((e) {
        final label = _activityLabels[e.key] ?? e.key;
        final actual = e.value['actual'] ?? 0;
        final planned = e.value['planned'] ?? 0;
        final ratio = planned > 0 ? actual / planned : 0.0;
        final barColor = ratio >= 0.75
            ? const Color(0xFF3FA66A)
            : ratio >= 0.4
                ? const Color(0xFFF5A623)
                : const Color(0xFFE53935);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$actual / $planned',
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: ratio.clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: context.stroke.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _EmptyBreakdown extends StatelessWidget {
  final double score;
  const _EmptyBreakdown({required this.score});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Plan vs Execution is ${score.round()}%.\nLog daily to unlock activity-wise breakdown.',
      style: TextStyle(
        color: context.fgSub,
        fontSize: 12,
        height: 1.5,
      ),
    );
  }
}

// ── Streak Section ────────────────────────────────────────────────────────────

class _StreakSection extends ConsumerWidget {
  static const int _windowDays = 30;

  const _StreakSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consistencyAsync = ref.watch(journalConsistencyProvider(_windowDays));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Journal Consistency',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: () =>
                  ref.invalidate(journalConsistencyProvider(_windowDays)),
              icon: Icon(Icons.refresh_rounded, color: context.fgSub, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 8),
        consistencyAsync.when(
          loading: () => _loadingState(context),
          error: (error, _) => _errorState(
            context,
            message: error.toString(),
            onRetry: () =>
                ref.invalidate(journalConsistencyProvider(_windowDays)),
          ),
          data: (consistency) {
            final sortedDays = [...consistency.days]
              ..sort((a, b) => a.date.compareTo(b.date));

            if (sortedDays.isEmpty) {
              return _emptyState(
                context,
                onRetry: () =>
                    ref.invalidate(journalConsistencyProvider(_windowDays)),
              );
            }

            final summary = consistency.summary;
            final plannedDays = summary.plannedDays;
            final executedDays = summary.executedDays;
            final double planVsExecutionPct = summary.planVsExecutionPct > 0
                ? summary.planVsExecutionPct
                : (plannedDays > 0
                    ? (executedDays / plannedDays) * 100.0
                    : 0.0);

            final adherenceRows = consistency.weekly.adherence.entries.toList()
              ..sort((a, b) =>
                  a.value.completionPct.compareTo(b.value.completionPct));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _metricCards(
                  context,
                  currentStreak: summary.currentStreak,
                  activeDays: summary.activeDaysInWindow,
                  plannedDays: plannedDays,
                  executedDays: executedDays,
                  planVsExecutionPct: planVsExecutionPct,
                  weeklyDiscipline: consistency.weekly.disciplineScore,
                ),
                const SizedBox(height: 14),
                _calendarBlock(context, sortedDays),
                const SizedBox(height: 14),
                _dailyPlanVsExecutionBlock(context, sortedDays),
                const SizedBox(height: 14),
                _weeklyAdherenceBlock(context, adherenceRows),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _metricCards(
    BuildContext context, {
    required int currentStreak,
    required int activeDays,
    required int plannedDays,
    required int executedDays,
    required double planVsExecutionPct,
    required double weeklyDiscipline,
  }) {
    final items = [
      ('Current Streak', '${currentStreak}d', 'Live run'),
      ('Active Days (30d)', '$activeDays/$_windowDays', 'Logged days'),
      (
        'Plan vs Execution',
        '${planVsExecutionPct.round()}%',
        plannedDays > 0 ? '$executedDays/$plannedDays days' : 'No planned days'
      ),
      ('Weekly Discipline', '${weeklyDiscipline.round()}%', 'This week'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        const gap = 8.0;
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items.map((item) {
            return SizedBox(
              width: cardWidth,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.stroke),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$1,
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.$2,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.$3,
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _calendarBlock(BuildContext context, List<JournalDay> days) {
    final byKey = <String, JournalDay>{
      for (final d in days) _dateKey(_dayOnly(d.date)): d,
    };

    final rangeStart = _dayOnly(days.first.date);
    final rangeEnd = _dayOnly(days.last.date);
    final today = _dayOnly(
        DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30)));

    final gridStart =
        rangeStart.subtract(Duration(days: rangeStart.weekday - 1));
    final gridEnd = rangeEnd.add(Duration(days: 7 - rangeEnd.weekday));
    final totalCells = gridEnd.difference(gridStart).inDays + 1;
    final weekRows = (totalCells / 7).ceil();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '30-Day Calendar',
            style: TextStyle(
              color: context.fg,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 2.5;
              final cellW = (constraints.maxWidth - (7 - 1) * gap) / 7;
              const cellH = 16.0;
              const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

              DateTime dayAt(int row, int col) =>
                  gridStart.add(Duration(days: row * 7 + col));

              Widget dayCell(DateTime date) {
                final d = _dayOnly(date);
                final inRange = !d.isBefore(rangeStart) && !d.isAfter(rangeEnd);
                final day = byKey[_dateKey(d)];

                if (!inRange) {
                  return SizedBox(
                    width: cellW,
                    height: cellH,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.stroke.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }

                final color = _dayColor(
                  context,
                  day: day,
                  date: d,
                  today: today,
                );

                final hasWorkload = day?.hasWorkload == true;
                final hasWellness = day?.hasWellness == true;
                final badgeText = hasWorkload && hasWellness
                    ? 'B'
                    : hasWorkload
                        ? 'W'
                        : hasWellness
                            ? 'H'
                            : '';

                final tooltip = day == null
                    ? '${_displayDate(d)}\nNo journal data'
                    : '${_displayDate(d)}\n'
                        'Streak: ${day.streakCount}\n'
                        'Planned: ${day.plannedTargets} targets • ${day.plannedMinutes}m\n'
                        'Actual: ${day.actualTargets} targets • ${day.actualMinutes}m\n'
                        'Execution: ${day.executionScore.round()}%\n'
                        '${day.isLocked ? 'Locked' : 'Unlocked'}';

                return Tooltip(
                  message: tooltip,
                  child: SizedBox(
                    width: cellW,
                    height: cellH,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                              border: d == today
                                  ? Border.all(color: context.accent, width: 1)
                                  : null,
                            ),
                            child: Text(
                              '${d.day}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        if (badgeText.isNotEmpty)
                          Positioned(
                            right: 1,
                            top: 1,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                badgeText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 6,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(7, (col) {
                      return Padding(
                        padding: EdgeInsets.only(right: col == 6 ? 0 : gap),
                        child: SizedBox(
                          width: cellW,
                          child: Text(
                            labels[col],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.fgSub,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  ...List.generate(weekRows, (row) {
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: row == weekRows - 1 ? 0 : gap),
                      child: Row(
                        children: List.generate(7, (col) {
                          final day = dayAt(row, col);
                          return Padding(
                            padding: EdgeInsets.only(right: col == 6 ? 0 : gap),
                            child: dayCell(day),
                          );
                        }),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less', style: TextStyle(fontSize: 9, color: context.fgSub)),
              const SizedBox(width: 4),
              _dot(context, context.danger),
              _dot(context, const Color(0xFF8BD7A2)),
              _dot(context, const Color(0xFF4CAE6E)),
              _dot(context, const Color(0xFF1C6B3E)),
              const SizedBox(width: 4),
              Text('More', style: TextStyle(fontSize: 9, color: context.fgSub)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dailyPlanVsExecutionBlock(
      BuildContext context, List<JournalDay> days) {
    final desc = [...days]..sort((a, b) => b.date.compareTo(a.date));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plan vs Execution by Day',
            style: TextStyle(
              color: context.fg,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
          ...desc.map((day) {
            final miss = day.isPlannedDay && !day.isExecutedDay;
            final planned = day.plannedMinutes;
            final actual = day.actualMinutes;
            final progress = planned > 0
                ? (actual / planned).clamp(0.0, 1.0)
                : (day.isExecutedDay ? 1.0 : 0.0);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: miss
                    ? context.danger.withValues(alpha: 0.1)
                    : context.bg.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: miss
                      ? context.danger.withValues(alpha: 0.4)
                      : context.stroke.withValues(alpha: 0.7),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _displayDate(day.date),
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (miss)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.danger.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Miss',
                            style: TextStyle(
                              color: context.danger,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Planned ${planned}m • Actual ${actual}m',
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: context.stroke.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        miss
                            ? context.danger
                            : _greenByScore(_dayAdherenceScore(day)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _weeklyAdherenceBlock(
    BuildContext context,
    List<MapEntry<String, JournalAdherence>> rows,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Adherence by Activity',
            style: TextStyle(
              color: context.fg,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          if (rows.isEmpty)
            Text(
              'No weekly adherence data available yet.',
              style: TextStyle(color: context.fgSub, fontSize: 12),
            )
          else ...[
            Row(
              children: [
                _tableCell(context, 'Activity', flex: 4, isHeader: true),
                _tableCell(context, 'Planned',
                    flex: 2, isHeader: true, alignEnd: true),
                _tableCell(context, 'Actual',
                    flex: 2, isHeader: true, alignEnd: true),
                _tableCell(context, 'Completion',
                    flex: 3, isHeader: true, alignEnd: true),
              ],
            ),
            const SizedBox(height: 6),
            ...rows.map((entry) {
              final adherence = entry.value;
              final completion = adherence.completionPct;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    _tableCell(context, _activityLabel(entry.key), flex: 4),
                    _tableCell(context, '${adherence.planned}',
                        flex: 2, alignEnd: true),
                    _tableCell(context, '${adherence.actual}',
                        flex: 2, alignEnd: true),
                    _tableCell(context, '${completion.round()}%',
                        flex: 3,
                        alignEnd: true,
                        color: completion >= 75
                            ? context.success
                            : completion >= 40
                                ? context.warn
                                : context.danger),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _loadingState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(
              2,
              (_) => Expanded(
                child: Container(
                  height: 54,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: context.stroke.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 96,
            decoration: BoxDecoration(
              color: context.stroke.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, {required VoidCallback onRetry}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No journal data for the last 30 days.',
            style: TextStyle(
                color: context.fg, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Start logging daily to unlock consistency analytics.',
            style: TextStyle(color: context.fgSub, fontSize: 12),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _errorState(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Could not load journal consistency',
            style: TextStyle(
                color: context.fg, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: TextStyle(color: context.fgSub, fontSize: 11),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _tableCell(
    BuildContext context,
    String text, {
    required int flex,
    bool isHeader = false,
    bool alignEnd = false,
    Color? color,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: alignEnd ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          color: color ?? (isHeader ? context.fgSub : context.fg),
          fontSize: isHeader ? 10 : 11.5,
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
    );
  }

  DateTime _dayOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  Color _dayColor(
    BuildContext context, {
    required JournalDay? day,
    required DateTime date,
    required DateTime today,
  }) {
    if (day == null) {
      return date.isAfter(today)
          ? context.stroke.withValues(alpha: 0.2)
          : context.danger.withValues(alpha: 0.75);
    }

    // Future days and locked days are neutral, everything else is judged.
    if (date.isAfter(today) || day.isLocked) {
      return context.stroke.withValues(alpha: 0.35);
    }

    final hasExecution = day.isExecutedDay ||
        day.executionScore > 0 ||
        day.actualMinutes > 0 ||
        day.actualTargets > 0;
    final isLogged = day.isActive || hasExecution;

    if (isLogged) {
      return _greenByScore(_dayAdherenceScore(day));
    }

    // No-performance day should be visibly red.
    return context.danger;
  }

  Color _greenByScore(double score) {
    final t = (score.clamp(0.0, 100.0)) / 100.0;
    return Color.lerp(const Color(0xFF8BD7A2), const Color(0xFF1C6B3E), t) ??
        const Color(0xFF3FA66A);
  }

  double _dayAdherenceScore(JournalDay day) {
    if (day.executionScore > 0) {
      return day.executionScore.clamp(0.0, 100.0);
    }

    final plannedUnits = day.plannedMinutes > 0
        ? day.plannedMinutes.toDouble()
        : day.plannedTargets.toDouble();
    final actualUnits = day.actualMinutes > 0
        ? day.actualMinutes.toDouble()
        : day.actualTargets.toDouble();

    if (plannedUnits > 0) {
      return ((actualUnits / plannedUnits).clamp(0.0, 1.0)) * 100.0;
    }

    final hasExecution =
        day.isExecutedDay || day.actualMinutes > 0 || day.actualTargets > 0;
    return hasExecution ? 100.0 : 0.0;
  }

  String _activityLabel(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[_-]+'), ' ').trim().toLowerCase();
    if (cleaned.isEmpty) return raw;
    return cleaned
        .split(RegExp(r'\s+'))
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String _displayDate(DateTime date) =>
      '${date.day} ${_monthShort(date.month)} ${date.year}';

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

  Widget _dot(BuildContext context, Color color) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
