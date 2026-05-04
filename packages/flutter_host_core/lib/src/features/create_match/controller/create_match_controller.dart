import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/create_match_repository.dart';

class HostCreateMatchState {
  const HostCreateMatchState({
    this.isSubmitting = false,
    this.error,
    this.createdMatchId,
  });

  final bool isSubmitting;
  final String? error;
  final String? createdMatchId;

  HostCreateMatchState copyWith({
    bool? isSubmitting,
    String? error,
    String? createdMatchId,
    bool clearError = false,
  }) {
    return HostCreateMatchState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      createdMatchId: createdMatchId ?? this.createdMatchId,
    );
  }
}

class HostCreateMatchController extends StateNotifier<HostCreateMatchState> {
  HostCreateMatchController(this._repository)
      : super(const HostCreateMatchState());

  final HostCreateMatchRepository _repository;

  Future<String?> createMatch({
    required String teamAName,
    required String teamBName,
    required String venueName,
    required String venueCity,
    required DateTime scheduledAt,
    required String format,
    required String matchType,
    String? teamAId,
    String? teamBId,
    int? customOvers,
    bool hasImpactPlayer = false,
    String? ballType,
    String? facilityId,
    String? tournamentId,
    List<String>? teamAPlayerIds,
    List<String>? teamBPlayerIds,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final matchId = await _repository.createMatch(
        teamAName: teamAName,
        teamBName: teamBName,
        teamAId: teamAId,
        teamBId: teamBId,
        venueName: venueName,
        venueCity: venueCity,
        scheduledAt: scheduledAt,
        format: format,
        matchType: matchType,
        customOvers: customOvers,
        hasImpactPlayer: hasImpactPlayer,
        ballType: ballType,
        facilityId: facilityId,
        tournamentId: tournamentId,
        teamAPlayerIds: teamAPlayerIds,
        teamBPlayerIds: teamBPlayerIds,
      );
      state = state.copyWith(
        isSubmitting: false,
        createdMatchId: matchId,
        clearError: true,
      );
      return matchId;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        error: error.toString(),
      );
      return null;
    }
  }
}

final hostCreateMatchControllerProvider = StateNotifierProvider.autoDispose<
    HostCreateMatchController, HostCreateMatchState>(
  (ref) => HostCreateMatchController(ref.watch(hostCreateMatchRepositoryProvider)),
);
