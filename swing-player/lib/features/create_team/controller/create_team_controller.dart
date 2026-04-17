import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/storage/supabase_storage_service.dart';
import '../data/create_team_repository.dart';

class CreateTeamState {
  const CreateTeamState({
    this.isSubmitting = false,
    this.createdTeamId,
    this.error,
  });

  final bool isSubmitting;
  final String? createdTeamId;
  final String? error;

  CreateTeamState copyWith({
    bool? isSubmitting,
    String? createdTeamId,
    String? error,
  }) =>
      CreateTeamState(
        isSubmitting: isSubmitting ?? this.isSubmitting,
        createdTeamId: createdTeamId ?? this.createdTeamId,
        error: error,
      );
}

class CreateTeamController extends StateNotifier<CreateTeamState> {
  CreateTeamController(this._repository, this._storage)
      : super(const CreateTeamState());

  final CreateTeamRepository _repository;
  final SupabaseStorageService _storage;

  Future<bool> createTeam({
    required String name,
    String? shortName,
    XFile? logoFile,
    String? city,
    required String teamType,
    required bool iAmCaptain,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final logoUrl =
          logoFile == null ? null : await _storage.uploadTeamLogo(logoFile);
      final id = await _repository.createTeam(
        name: name,
        shortName: shortName,
        logoUrl: logoUrl,
        city: city,
        teamType: teamType,
        iAmCaptain: iAmCaptain,
      );
      state = state.copyWith(isSubmitting: false, createdTeamId: id);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: _messageFor(e));
      return false;
    }
  }

  void clearError() => state = state.copyWith(error: null);

  String _messageFor(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final nested = data['error'];
        if (nested is Map<String, dynamic> && nested['message'] is String) {
          return nested['message'] as String;
        }
        if (data['message'] is String) return data['message'] as String;
      }
    }
    return e.toString();
  }
}

final createTeamControllerProvider =
    StateNotifierProvider.autoDispose<CreateTeamController, CreateTeamState>(
  (ref) => CreateTeamController(
    CreateTeamRepository(),
    SupabaseStorageService(),
  ),
);
