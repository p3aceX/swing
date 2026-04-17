import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/teams_repository.dart';
import '../domain/team_models.dart';

final teamsRepositoryProvider =
    Provider<TeamsRepository>((ref) => TeamsRepository());

class TeamsState {
  const TeamsState({
    this.isLoading = false,
    this.mySquads = const [],
    this.playingFor = const [],
    this.error,
  });

  final bool isLoading;

  /// Teams created by the current player.
  final List<PlayerTeam> mySquads;

  /// Teams where the current player is only a member.
  final List<PlayerTeam> playingFor;

  final String? error;

  /// All teams combined.
  List<PlayerTeam> get teams => [...mySquads, ...playingFor];

  TeamsState copyWith({
    bool? isLoading,
    List<PlayerTeam>? mySquads,
    List<PlayerTeam>? playingFor,
    String? error,
  }) {
    return TeamsState(
      isLoading: isLoading ?? this.isLoading,
      mySquads: mySquads ?? this.mySquads,
      playingFor: playingFor ?? this.playingFor,
      error: error,
    );
  }
}

class TeamsController extends StateNotifier<TeamsState> {
  TeamsController(this._repository) : super(const TeamsState(isLoading: true)) {
    load();
  }

  final TeamsRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.loadTeamsByOwnership();
      state = TeamsState(
        isLoading: false,
        mySquads: result.mySquads,
        playingFor: result.playingFor,
      );
    } catch (error) {
      state = TeamsState(
        isLoading: false,
        mySquads: state.mySquads,
        playingFor: state.playingFor,
        error: _messageFor(error),
      );
    }
  }

  Future<void> refresh() => load();

  Future<List<TeamPlayerSearchResult>> searchPlayers(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];
    try {
      return await _repository.searchPlayers(trimmed);
    } catch (_) {
      return const [];
    }
  }

  Future<bool> addPlayerToTeam({
    required String teamId,
    required String playerIdOrUserId,
  }) async {
    try {
      await _repository.addPlayerToTeam(
        teamId: teamId,
        playerIdOrUserId: playerIdOrUserId,
      );
      await load();
      return true;
    } catch (error) {
      state = state.copyWith(error: _messageFor(error));
      return false;
    }
  }

  Future<bool> joinTeam(String teamId) async {
    try {
      await _repository.joinTeam(teamId);
      await load();
      return true;
    } catch (error) {
      state = state.copyWith(error: _messageFor(error));
      return false;
    }
  }

  Future<bool> followTeam(String teamId) async {
    try {
      await _repository.followTeam(teamId);
      return true;
    } catch (error) {
      state = state.copyWith(error: _messageFor(error));
      return false;
    }
  }

  Future<bool> quickAddPlayer({
    required String teamId,
    required String name,
    required String phone,
  }) async {
    try {
      await _repository.quickAddPlayer(teamId: teamId, name: name, phone: phone);
      await load();
      return true;
    } catch (error) {
      state = state.copyWith(error: _messageFor(error));
      return false;
    }
  }

  Future<bool> updateTeam({
    required String teamId,
    String? name,
    String? shortName,
    String? city,
    String? teamType,
    String? logoUrl,
  }) async {
    try {
      await _repository.updateTeam(
        teamId: teamId,
        name: name,
        shortName: shortName,
        city: city,
        teamType: teamType,
        logoUrl: logoUrl,
      );
      await load();
      return true;
    } catch (error) {
      state = state.copyWith(error: _messageFor(error));
      return false;
    }
  }

  Future<bool> removePlayerFromTeam({
    required String teamId,
    required String profileId,
  }) async {
    try {
      await _repository.removePlayerFromTeam(
          teamId: teamId, profileId: profileId);
      await load();
      return true;
    } catch (error) {
      state = state.copyWith(error: _messageFor(error));
      return false;
    }
  }

  Future<bool> deleteTeam(String teamId) async {
    try {
      await _repository.deleteTeam(teamId);
      await load();
      return true;
    } catch (error) {
      state = state.copyWith(error: _messageFor(error));
      return false;
    }
  }

  String _messageFor(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final nested = data['error'];
        if (nested is Map<String, dynamic> &&
            nested['message'] is String &&
            (nested['message'] as String).trim().isNotEmpty) {
          return (nested['message'] as String).trim();
        }
        final message = data['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
      return error.message ?? 'Could not load teams.';
    }
    return error.toString();
  }
}

final teamsControllerProvider =
    StateNotifierProvider.autoDispose<TeamsController, TeamsState>((ref) {
  return TeamsController(ref.watch(teamsRepositoryProvider));
});
