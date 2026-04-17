import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/fitness_repository.dart';
import '../domain/fitness_models.dart';

final fitnessRepositoryProvider = Provider((ref) => FitnessRepository());

// ── Exercise Library Search ──────────────────────────────────────────────────

final fitnessSearchQueryProvider = StateProvider<String>((ref) => '');

final fitnessSearchProvider =
    FutureProvider<List<FitnessExercise>>((ref) async {
  final query = ref.watch(fitnessSearchQueryProvider);
  if (query.length < 2) return [];

  final repo = ref.watch(fitnessRepositoryProvider);
  return repo.searchExercises(query);
});

// ── Fitness Summary / Dashboard ──────────────────────────────────────────────

final fitnessSummaryProvider =
    StateNotifierProvider<FitnessSummaryNotifier, AsyncValue<FitnessSummary>>(
        (ref) {
  return FitnessSummaryNotifier(ref.watch(fitnessRepositoryProvider));
});

class FitnessSummaryNotifier extends StateNotifier<AsyncValue<FitnessSummary>> {
  FitnessSummaryNotifier(this._repository) : super(const AsyncValue.loading()) {
    refresh();
  }

  final FitnessRepository _repository;

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getFitnessSummary());
  }
}

// ── Session Logger State ─────────────────────────────────────────────────────

class FitnessLogState {
  const FitnessLogState({
    required this.session,
    this.isSubmitting = false,
  });

  final WorkoutSession session;
  final bool isSubmitting;

  FitnessLogState copyWith({
    WorkoutSession? session,
    bool? isSubmitting,
  }) {
    return FitnessLogState(
      session: session ?? this.session,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final fitnessLogControllerProvider =
    StateNotifierProvider.autoDispose<FitnessLogController, FitnessLogState>(
        (ref) {
  return FitnessLogController(ref.watch(fitnessRepositoryProvider), ref);
});

class FitnessLogController extends StateNotifier<FitnessLogState> {
  FitnessLogController(this._repository, this._ref)
      : super(FitnessLogState(
          session: WorkoutSession(
            id: '',
            loggedAt: DateTime.now(),
            exercises: [],
          ),
        ));

  final FitnessRepository _repository;
  final Ref _ref;

  void addExercise(FitnessExercise exercise) {
    if (state.session.exercises.any((e) => e.exercise.id == exercise.id)) {
      return;
    }

    final updatedExercises = [
      ...state.session.exercises,
      WorkoutExercise(
        exercise: exercise,
        sets: exercise.defaultSets ?? 3,
        reps: exercise.defaultReps ?? 10,
        durationMinutes: exercise.durationMins,
      ),
    ];
    state = state.copyWith(
      session: WorkoutSession(
        id: state.session.id,
        loggedAt: state.session.loggedAt,
        exercises: updatedExercises,
        intensity: state.session.intensity,
        notes: state.session.notes,
      ),
    );
  }

  void removeExercise(String id) {
    final updatedExercises =
        state.session.exercises.where((e) => e.exercise.id != id).toList();
    state = state.copyWith(
      session: WorkoutSession(
        id: state.session.id,
        loggedAt: state.session.loggedAt,
        exercises: updatedExercises,
        intensity: state.session.intensity,
        notes: state.session.notes,
      ),
    );
  }

  void updateExercise(int index,
      {int? sets, int? reps, double? weight, int? duration, int? intensity}) {
    final exercises = [...state.session.exercises];
    final e = exercises[index];

    if (sets != null) e.sets = sets;
    if (reps != null) e.reps = reps;
    if (weight != null) e.weightKg = weight;
    if (duration != null) e.durationMinutes = duration;
    if (intensity != null) e.intensity = intensity;

    state = state.copyWith(
      session: WorkoutSession(
        id: state.session.id,
        loggedAt: state.session.loggedAt,
        exercises: exercises,
        intensity: state.session.intensity,
        notes: state.session.notes,
      ),
    );
  }

  void setIntensity(SessionIntensity intensity) {
    state = state.copyWith(
      session: WorkoutSession(
        id: state.session.id,
        loggedAt: state.session.loggedAt,
        exercises: state.session.exercises,
        intensity: intensity,
        notes: state.session.notes,
      ),
    );
  }

  Future<bool> submit() async {
    if (state.session.exercises.isEmpty) return false;

    state = state.copyWith(isSubmitting: true);
    try {
      await _repository.logSession(state.session);
      _ref.read(fitnessSummaryProvider.notifier).refresh();
      return true;
    } catch (e) {
      return false;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}
