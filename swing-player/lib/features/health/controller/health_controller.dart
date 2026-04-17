import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/health_repository.dart';
import '../domain/health_models.dart';

final healthRepositoryProvider = Provider((ref) => HealthRepository());

final healthDashboardProvider =
    StateNotifierProvider<HealthDashboardNotifier, AsyncValue<HealthDashboard>>((ref) {
  return HealthDashboardNotifier(ref.watch(healthRepositoryProvider));
});

class HealthDashboardNotifier extends StateNotifier<AsyncValue<HealthDashboard>> {
  HealthDashboardNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final HealthRepository _repository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getDashboard());
  }

  Future<void> submitWellness(WellnessCheckIn checkIn) async {
    await _repository.submitWellness(checkIn);
    await load();
  }

  Future<void> submitWorkload(WorkloadEvent event) async {
    await _repository.submitWorkload(event);
    await load();
  }
}
