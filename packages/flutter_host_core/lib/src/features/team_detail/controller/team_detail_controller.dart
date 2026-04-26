import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/team_detail_repository.dart';
import '../domain/team_models.dart';
import '../../match_detail/domain/match_models.dart';

class TeamDetailState {
  const TeamDetailState({
    this.isLoading = false,
    this.team,
    this.analytics,
    this.matches = const [],
    this.isFollowing = false,
    this.followLoading = false,
    this.error,
  });

  final bool isLoading;
  final PlayerTeam? team;
  final TeamAnalytics? analytics;
  final List<PlayerMatch> matches;
  final bool isFollowing;
  final bool followLoading;
  final String? error;

  bool get hasData => team != null;

  TeamDetailState copyWith({
    bool? isLoading,
    PlayerTeam? team,
    TeamAnalytics? analytics,
    List<PlayerMatch>? matches,
    bool? isFollowing,
    bool? followLoading,
    String? error,
    bool clearError = false,
  }) {
    return TeamDetailState(
      isLoading: isLoading ?? this.isLoading,
      team: team ?? this.team,
      analytics: analytics ?? this.analytics,
      matches: matches ?? this.matches,
      isFollowing: isFollowing ?? this.isFollowing,
      followLoading: followLoading ?? this.followLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TeamDetailController extends StateNotifier<TeamDetailState> {
  TeamDetailController(this._repo, this._teamId, {String? currentUserId})
      : _currentUserId = currentUserId,
        super(const TeamDetailState(isLoading: true));

  final HostTeamDetailRepository _repo;
  final String _teamId;
  final String? _currentUserId;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _repo.loadTeam(_teamId, currentUserId: _currentUserId),
        _repo.loadTeamAnalytics(_teamId),
        _repo.loadTeamMatches(_teamId),
        _repo.getFollowStatus(_teamId),
      ]);
      state = TeamDetailState(
        isLoading: false,
        team: results[0] as PlayerTeam,
        analytics: results[1] as TeamAnalytics?,
        matches: results[2] as List<PlayerMatch>,
        isFollowing: results[3] as bool,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _messageFor(e));
    }
  }

  Future<void> refresh() => load();

  Future<bool> toggleFollow() async {
    final wasFollowing = state.isFollowing;
    state = state.copyWith(followLoading: true);
    try {
      if (wasFollowing) {
        await _repo.unfollowTeam(_teamId);
      } else {
        await _repo.followTeam(_teamId);
      }
      state = state.copyWith(isFollowing: !wasFollowing, followLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(followLoading: false, error: _messageFor(e));
      return false;
    }
  }

  Future<bool> addPlayer(String profileId) async {
    try {
      await _repo.addPlayer(teamId: _teamId, profileId: profileId);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(error: _messageFor(e));
      return false;
    }
  }

  Future<bool> quickAddPlayer({required String name, required String phone}) async {
    try {
      await _repo.quickAddPlayer(teamId: _teamId, name: name, phone: phone);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(error: _messageFor(e));
      return false;
    }
  }

  Future<bool> removePlayer(String profileId) async {
    try {
      await _repo.removePlayer(teamId: _teamId, profileId: profileId);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(error: _messageFor(e));
      return false;
    }
  }

  Future<bool> updateTeam({
    String? name,
    String? shortName,
    String? city,
    String? teamType,
    String? logoUrl,
  }) async {
    try {
      await _repo.updateTeam(
        teamId: _teamId,
        name: name,
        shortName: shortName,
        city: city,
        teamType: teamType,
        logoUrl: logoUrl,
      );
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(error: _messageFor(e));
      return false;
    }
  }

  Future<bool> deleteTeam() async {
    try {
      await _repo.deleteTeam(_teamId);
      return true;
    } catch (e) {
      state = state.copyWith(error: _messageFor(e));
      return false;
    }
  }

  Future<bool> joinTeam() async {
    try {
      await _repo.joinTeam(_teamId);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(error: _messageFor(e));
      return false;
    }
  }

  Future<List<TeamPlayerSearchResult>> searchPlayers(String query) async {
    if (query.trim().length < 2) return const [];
    try {
      return await _repo.searchPlayers(query.trim());
    } catch (_) {
      return const [];
    }
  }

  String _messageFor(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final nested = data['error'];
        if (nested is Map<String, dynamic> && nested['message'] is String) {
          return (nested['message'] as String).trim();
        }
        final msg = data['message'];
        if (msg is String && msg.trim().isNotEmpty) return msg.trim();
      }
      return e.message ?? 'Could not load team.';
    }
    if (e is Exception) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      return msg.isNotEmpty ? msg : 'Something went wrong';
    }
    return e.toString();
  }
}

final teamDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<TeamDetailController, TeamDetailState, ({String teamId, String? currentUserId})>(
  (ref, args) {
    final ctrl = TeamDetailController(
      ref.watch(hostTeamDetailRepositoryProvider),
      args.teamId,
      currentUserId: args.currentUserId,
    );
    ctrl.load();
    return ctrl;
  },
);
