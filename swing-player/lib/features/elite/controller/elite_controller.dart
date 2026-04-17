import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/storage/goal_storage.dart';
import '../../profile/controller/profile_controller.dart';
import '../data/elite_repository.dart';
import '../domain/elite_models.dart';

final eliteRepositoryProvider = Provider<EliteRepository>(
  (ref) => EliteRepository(ApiClient.instance.dio),
);

/// In-memory goal cache — survives tab switches within a session.
/// NOT autoDispose.
final goalCacheProvider = StateProvider<ApexGoal?>((ref) => null);

/// Reads goal from local secure storage — survives app restarts.
/// NOT autoDispose so it's only read once per session.
final goalPersistedProvider = FutureProvider<ApexGoal?>((ref) async {
  return GoalStorage.load();
});

/// True if the user has submitted a journal today (persisted to disk).
/// NOT autoDispose — set once per session.
final journaledTodayProvider = StateProvider<bool>((ref) => false);

/// True if today's journal was marked as a cheat day.
/// NOT autoDispose — set once per session.
final cheatDayTodayProvider = StateProvider<bool>((ref) => false);

/// Initialises [journaledTodayProvider] from disk on first load.
final journalTodayInitProvider = FutureProvider<void>((ref) async {
  final journaledToday = await GoalStorage.journaledToday();
  if (journaledToday) {
    ref.read(journaledTodayProvider.notifier).state = true;
  }
  final cheatDayToday = await GoalStorage.cheatDayToday();
  ref.read(cheatDayTodayProvider.notifier).state = cheatDayToday;
});

final eliteProfileProvider =
    FutureProvider.autoDispose<EliteProfile>((ref) async {
  final profileState = ref.watch(profileControllerProvider);

  if (profileState.isLoading || profileState.data == null) {
    // Return a future that stays loading until the profile is ready
    return Completer<EliteProfile>().future;
  }

  final playerId = profileState.data!.identity.id;
  return ref.read(eliteRepositoryProvider).fetchProfile(playerId);
});

final apexStateProvider = FutureProvider.autoDispose<ApexState>((ref) async {
  final profileState = ref.watch(profileControllerProvider);
  if (profileState.isLoading || profileState.data == null) {
    return Completer<ApexState>().future;
  }
  final playerId = profileState.data!.identity.id;
  return ref.read(eliteRepositoryProvider).fetchApexState(playerId);
});

class ElitePerformanceLogController extends StateNotifier<AsyncValue<void>> {
  final EliteRepository _repository;
  final String? _playerId;

  ElitePerformanceLogController(this._repository, this._playerId)
      : super(const AsyncValue.data(null));

  Future<void> submit(ElitePerformanceLog log) async {
    final playerId = _playerId;
    if (playerId == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _repository.submitPerformanceLog(playerId, log));
  }
}

final elitePerformanceLogControllerProvider = StateNotifierProvider.autoDispose<
    ElitePerformanceLogController, AsyncValue<void>>((ref) {
  final profileState = ref.watch(profileControllerProvider);
  final playerId = profileState.data?.identity.id;
  return ElitePerformanceLogController(
      ref.watch(eliteRepositoryProvider), playerId);
});

class ApexGoalController extends StateNotifier<AsyncValue<void>> {
  final EliteRepository _repository;
  final String? _playerId;

  ApexGoalController(this._repository, this._playerId)
      : super(const AsyncValue.data(null));

  Future<bool> save(ApexGoal goal) async {
    final playerId = _playerId;
    if (playerId == null) return false;
    state = const AsyncValue.loading();
    try {
      await _repository.saveApexGoal(playerId, goal);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final apexGoalControllerProvider =
    StateNotifierProvider<ApexGoalController, AsyncValue<void>>(
        (ref) {
  final profileState = ref.watch(profileControllerProvider);
  final playerId = profileState.data?.identity.id;
  return ApexGoalController(ref.watch(eliteRepositoryProvider), playerId);
});

// ── My Plan ──────────────────────────────────────────────────────────────────

final myPlanProvider = FutureProvider.autoDispose<MyPlan?>((ref) async {
  return ref.read(eliteRepositoryProvider).fetchMyPlan();
});

class MyPlanSaveController extends StateNotifier<AsyncValue<void>> {
  final EliteRepository _repository;

  MyPlanSaveController(this._repository) : super(const AsyncValue.data(null));

  Future<bool> save(MyPlan plan) async {
    state = const AsyncValue.loading();
    try {
      await _repository.saveMyPlan(plan);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      debugPrint('[MyPlanSaveController] Save failed: $e');
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final myPlanSaveControllerProvider =
    StateNotifierProvider.autoDispose<MyPlanSaveController, AsyncValue<void>>(
        (ref) => MyPlanSaveController(ref.watch(eliteRepositoryProvider)));

final weeklyPlanProvider = FutureProvider.autoDispose<WeeklyPlan?>((ref) async {
  return ref.read(eliteRepositoryProvider).getMyPlan();
});

class WeeklyPlanSaveController extends StateNotifier<AsyncValue<void>> {
  final EliteRepository _repository;

  WeeklyPlanSaveController(this._repository)
      : super(const AsyncValue.data(null));

  Future<bool> create(WeeklyPlan plan) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createMyPlan(plan);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      debugPrint('[WeeklyPlanSaveController] Create failed: $e');
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> update(WeeklyPlan plan) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateMyPlan(plan);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      debugPrint('[WeeklyPlanSaveController] Update failed: $e');
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> delete() async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteMyPlan();
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      debugPrint('[WeeklyPlanSaveController] Delete failed: $e');
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final weeklyPlanSaveControllerProvider =
    StateNotifierProvider<WeeklyPlanSaveController, AsyncValue<void>>(
  (ref) => WeeklyPlanSaveController(ref.watch(eliteRepositoryProvider)),
);

// ── Activity Journal Controller ──────────────────────────────────────────────

class ActivityJournalController extends StateNotifier<AsyncValue<void>> {
  final EliteRepository _repository;
  final String? _playerId;

  ActivityJournalController(this._repository, this._playerId)
      : super(const AsyncValue.data(null));

  Future<bool> submit(ActivityJournalEntry entry) async {
    final playerId = _playerId;
    if (playerId == null || !mounted) return false;
    state = const AsyncValue.loading();
    try {
      await _repository.submitActivityJournal(playerId, entry);
      if (!mounted) return false;
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      if (!mounted) return false;
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final activityJournalControllerProvider =
    StateNotifierProvider<ActivityJournalController, AsyncValue<void>>((ref) {
  final profileState = ref.watch(profileControllerProvider);
  final playerId = profileState.data?.identity.id;
  return ActivityJournalController(
      ref.watch(eliteRepositoryProvider), playerId);
});

// ── Plan → Execution Providers ───────────────────────────────────────────────

final dayLogProvider =
    FutureProvider.autoDispose.family<DayLog, String>((ref, date) async {
  return ref.read(eliteRepositoryProvider).fetchDayLog(date);
});

final apexDayLogProvider =
    FutureProvider.autoDispose.family<ApexDayLog, String>((ref, date) async {
  return ref.read(eliteRepositoryProvider).getDayLog(date);
});

final executionStreakProvider =
    FutureProvider.autoDispose<List<ExecutionStreakEntry>>((ref) async {
  return ref.read(eliteRepositoryProvider).fetchExecutionStreak();
});

final journalConsistencyProvider = FutureProvider.autoDispose
    .family<JournalConsistency, int>((ref, days) async {
  final profileState = ref.watch(profileControllerProvider);
  if (profileState.isLoading || profileState.data == null) {
    return Completer<JournalConsistency>().future;
  }
  final playerId = profileState.data!.identity.id;
  return ref
      .read(eliteRepositoryProvider)
      .fetchJournalStreak(playerId, days: days <= 0 ? 30 : days);
});

// ── Day Plan Controller ──────────────────────────────────────────────────────

class DayPlanController extends StateNotifier<AsyncValue<DayLog?>> {
  final EliteRepository _repository;

  DayPlanController(this._repository) : super(const AsyncValue.data(null));

  Future<DayLog?> updatePlan(String date, DayPlanUpdate plan) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateDayPlan(date, plan);
      final updated = await _repository.fetchDayLog(date);
      state = AsyncValue.data(updated);
      return updated;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final dayPlanControllerProvider =
    StateNotifierProvider.autoDispose<DayPlanController, AsyncValue<DayLog?>>(
        (ref) {
  return DayPlanController(ref.watch(eliteRepositoryProvider));
});

class ApexDayPlanController extends StateNotifier<AsyncValue<ApexDayLog?>> {
  final EliteRepository _repository;

  ApexDayPlanController(this._repository) : super(const AsyncValue.data(null));

  Future<ApexDayLog?> update(String date, ApexDayPlanPatch patch) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repository.updateApexDayPlan(date, patch);
      state = AsyncValue.data(updated);
      return updated;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final apexDayPlanControllerProvider = StateNotifierProvider.autoDispose<
    ApexDayPlanController, AsyncValue<ApexDayLog?>>((ref) {
  return ApexDayPlanController(ref.watch(eliteRepositoryProvider));
});

// ── Execution Submit Controller ──────────────────────────────────────────────

class ExecutionController extends StateNotifier<AsyncValue<DayLog?>> {
  final EliteRepository _repository;

  ExecutionController(this._repository) : super(const AsyncValue.data(null));

  Future<DayLog?> submit(String date, ExecutionSubmission submission) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.submitExecution(date, submission);
      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final executionControllerProvider =
    StateNotifierProvider.autoDispose<ExecutionController, AsyncValue<DayLog?>>(
        (ref) {
  return ExecutionController(ref.watch(eliteRepositoryProvider));
});

class ApexDayExecutionController
    extends StateNotifier<AsyncValue<ApexDayLog?>> {
  final EliteRepository _repository;

  ApexDayExecutionController(this._repository)
      : super(const AsyncValue.data(null));

  Future<ApexDayLog?> submit(
      String date, ApexDayExecutionSubmit submission) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.submitDayExecution(date, submission);
      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final apexDayExecutionControllerProvider = StateNotifierProvider.autoDispose<
    ApexDayExecutionController, AsyncValue<ApexDayLog?>>((ref) {
  return ApexDayExecutionController(ref.watch(eliteRepositoryProvider));
});

// ── Weekly Template Controller ───────────────────────────────────────────────

class WeeklyTemplateController extends StateNotifier<AsyncValue<void>> {
  final EliteRepository _repository;

  WeeklyTemplateController(this._repository)
      : super(const AsyncValue.data(null));

  Future<bool> save(WeeklyPlanTemplate template) async {
    state = const AsyncValue.loading();
    try {
      await _repository.saveWeeklyTemplate(template);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final weeklyTemplateControllerProvider = StateNotifierProvider.autoDispose<
    WeeklyTemplateController, AsyncValue<void>>((ref) {
  return WeeklyTemplateController(ref.watch(eliteRepositoryProvider));
});
