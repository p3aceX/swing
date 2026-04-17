import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/diet_repository.dart';
import '../domain/diet_models.dart';

// ── Repository provider ───────────────────────────────────────────────────────

final _dietRepoProvider = Provider<DietRepository>((_) => DietRepository());

// ── Daily summary provider ───────────────────────────────────────────────────

final dietSummaryProvider =
    FutureProvider.autoDispose.family<DietDailySummary, DateTime?>(
  (ref, date) async {
    final repo = ref.read(_dietRepoProvider);
    return repo.getDailySummary(date: date);
  },
);

// ── Nutrition search provider ─────────────────────────────────────────────────

final nutritionSearchProvider =
    FutureProvider.autoDispose.family<List<NutritionItem>, String>(
  (ref, query) async {
    if (query.trim().isEmpty) return [];
    final repo = ref.read(_dietRepoProvider);
    return repo.searchNutritionLibrary(query);
  },
);

// ── Meal log state (modal state management) ───────────────────────────────────

class DietLogState {
  const DietLogState({
    this.selectedMealType = MealType.breakfast,
    this.loggedItems = const [],
    this.waterMl = 0,
    this.isSubmitting = false,
    this.error,
  });

  final MealType selectedMealType;
  final List<DietLogEntry> loggedItems;
  final int waterMl;
  final bool isSubmitting;
  final String? error;

  double get totalCalories =>
      loggedItems.fold(0, (s, e) => s + e.item.calories * e.servings);
  double get totalProtein =>
      loggedItems.fold(0, (s, e) => s + e.item.proteinG * e.servings);
  double get totalCarbs =>
      loggedItems.fold(0, (s, e) => s + e.item.carbsG * e.servings);
  double get totalFat =>
      loggedItems.fold(0, (s, e) => s + e.item.fatG * e.servings);

  DietLogState copyWith({
    MealType? selectedMealType,
    List<DietLogEntry>? loggedItems,
    int? waterMl,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) =>
      DietLogState(
        selectedMealType: selectedMealType ?? this.selectedMealType,
        loggedItems: loggedItems ?? this.loggedItems,
        waterMl: waterMl ?? this.waterMl,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: clearError ? null : error ?? this.error,
      );
}

class DietLogEntry {
  const DietLogEntry({required this.item, required this.servings});
  final NutritionItem item;
  final double servings;
}

class DietLogNotifier extends Notifier<DietLogState> {
  @override
  DietLogState build() => const DietLogState();

  void setMealType(MealType type) =>
      state = state.copyWith(selectedMealType: type, clearError: true);

  void addItem(NutritionItem item) {
    final existing = state.loggedItems
        .indexWhere((e) => e.item.id == item.id);
    if (existing >= 0) {
      // Already present — bump servings
      final updated = List<DietLogEntry>.from(state.loggedItems);
      final current = updated[existing];
      updated[existing] = DietLogEntry(
          item: current.item, servings: current.servings + 1);
      state = state.copyWith(loggedItems: updated);
    } else {
      state = state.copyWith(
          loggedItems: [...state.loggedItems, DietLogEntry(item: item, servings: 1)]);
    }
  }

  void updateServings(String itemId, double servings) {
    if (servings <= 0) {
      removeItem(itemId);
      return;
    }
    final updated = state.loggedItems.map((e) {
      if (e.item.id == itemId) return DietLogEntry(item: e.item, servings: servings);
      return e;
    }).toList();
    state = state.copyWith(loggedItems: updated);
  }

  void removeItem(String itemId) {
    state = state.copyWith(
        loggedItems: state.loggedItems.where((e) => e.item.id != itemId).toList());
  }

  void setWater(int ml) => state = state.copyWith(waterMl: ml);

  Future<void> submit(DietRepository repo) async {
    if (state.loggedItems.isEmpty && state.waterMl == 0) return;
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final log = MealLog(
        id: '',
        mealType: state.selectedMealType,
        loggedAt: DateTime.now(),
        items: state.loggedItems
            .map((e) => MealLogItem(item: e.item, servings: e.servings))
            .toList(),
        waterMl: state.waterMl,
      );
      await repo.logMeal(log);
      state = const DietLogState();
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: 'Failed to log meal');
    }
  }

  void reset() => state = const DietLogState();
}

final dietLogProvider =
    NotifierProvider<DietLogNotifier, DietLogState>(DietLogNotifier.new);
