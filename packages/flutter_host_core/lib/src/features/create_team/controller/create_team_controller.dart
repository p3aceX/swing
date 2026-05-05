import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/create_team_repository.dart';

class HostCreateTeamState {
  const HostCreateTeamState({
    this.isSubmitting = false,
    this.createdTeamId,
    this.error,
  });

  final bool isSubmitting;
  final String? createdTeamId;
  final String? error;

  HostCreateTeamState copyWith({
    bool? isSubmitting,
    String? createdTeamId,
    String? error,
    bool clearError = false,
  }) =>
      HostCreateTeamState(
        isSubmitting: isSubmitting ?? this.isSubmitting,
        createdTeamId: createdTeamId ?? this.createdTeamId,
        error: clearError ? null : (error ?? this.error),
      );
}

class HostCreateTeamController extends StateNotifier<HostCreateTeamState> {
  HostCreateTeamController(this._repository)
      : super(const HostCreateTeamState());

  final HostCreateTeamRepository _repository;

  Future<String?> createTeam({
    required String name,
    String? shortName,
    String? logoUrl,
    String? city,
    required String teamType,
    required bool iAmCaptain,
    String? academyId,
    String? coachId,
    String? arenaId,
    String? motto,
    String? homeGroundName,
    int? foundedYear,
    String? ageGroup,
    String? format,
    String? skillLevel,
    bool isPublic = true,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final id = await _repository.createTeam(
        name: name,
        shortName: shortName,
        logoUrl: logoUrl,
        city: city,
        teamType: teamType,
        iAmCaptain: iAmCaptain,
        academyId: academyId,
        coachId: coachId,
        arenaId: arenaId,
        motto: motto,
        homeGroundName: homeGroundName,
        foundedYear: foundedYear,
        ageGroup: ageGroup,
        format: format,
        skillLevel: skillLevel,
        isPublic: isPublic,
      );
      state = state.copyWith(
        isSubmitting: false,
        createdTeamId: id,
        clearError: true,
      );
      return id;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        error: _messageFor(error),
      );
      return null;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);

  String _messageFor(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final nested = data['error'];
        if (nested is Map<String, dynamic> && nested['message'] is String) {
          return nested['message'] as String;
        }
        if (data['message'] is String) return data['message'] as String;
      }
    }
    return error.toString();
  }
}

final hostCreateTeamControllerProvider = StateNotifierProvider.autoDispose<
    HostCreateTeamController, HostCreateTeamState>(
  (ref) =>
      HostCreateTeamController(ref.watch(hostCreateTeamRepositoryProvider)),
);
