import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/my_teams_repository.dart';
import '../domain/my_teams_models.dart';

class HostMyTeamsState {
  const HostMyTeamsState({
    this.isLoading = false,
    this.error,
    this.data,
  });

  final bool isLoading;
  final String? error;
  final HostMyTeams? data;

  HostMyTeamsState copyWith({
    bool? isLoading,
    String? error,
    HostMyTeams? data,
    bool clearError = false,
  }) {
    return HostMyTeamsState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      data: data ?? this.data,
    );
  }
}

class HostMyTeamsController extends StateNotifier<HostMyTeamsState> {
  HostMyTeamsController(this._repo) : super(const HostMyTeamsState());

  final HostMyTeamsRepository _repo;

  Future<void> load({String? currentUserId}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final teams = await _repo.load(currentUserId: currentUserId);
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        data: teams,
        clearError: true,
      );
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }
}

/// Kept alive for the lifetime of the [ProviderScope] — the host CreateMatch
/// screen `watch`es this so the picker sheet doesn't see a disposed notifier.
final hostMyTeamsControllerProvider =
    StateNotifierProvider<HostMyTeamsController, HostMyTeamsState>(
  (ref) => HostMyTeamsController(ref.watch(hostMyTeamsRepositoryProvider)),
);
