import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../match_detail/data/match_detail_repository.dart';
import '../../match_detail/domain/match_models.dart';
import '../data/play_tab_repository.dart';
import '../domain/play_tab_models.dart';

// ─── Matches ──────────────────────────────────────────────────────────────────

class PlayMatchesState {
  const PlayMatchesState({
    this.isLoading = false,
    this.matches = const [],
    this.error,
  });

  final bool isLoading;
  final List<PlayerMatch> matches;
  final String? error;

  PlayMatchesState copyWith({
    bool? isLoading,
    List<PlayerMatch>? matches,
    String? error,
    bool clearError = false,
  }) =>
      PlayMatchesState(
        isLoading: isLoading ?? this.isLoading,
        matches: matches ?? this.matches,
        error: clearError ? null : (error ?? this.error),
      );
}

class PlayMatchesController extends StateNotifier<PlayMatchesState> {
  PlayMatchesController(this._repo)
      : super(const PlayMatchesState(isLoading: true)) {
    load();
  }

  final HostMatchDetailRepository _repo;

  Future<void> load() async {
    state = state.copyWith(
      isLoading: state.matches.isEmpty,
      clearError: true,
    );
    try {
      final matches = await _repo.fetchMyMatches();
      if (!mounted) return;
      state = PlayMatchesState(isLoading: false, matches: matches);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() => load();
}

final playMatchesControllerProvider = StateNotifierProvider.autoDispose<
    PlayMatchesController, PlayMatchesState>(
  (ref) => PlayMatchesController(ref.watch(hostMatchDetailRepositoryProvider)),
);

// ─── Tournaments ──────────────────────────────────────────────────────────────

class PlayTournamentsState {
  const PlayTournamentsState({
    this.isLoading = false,
    this.myTournaments = const [],
    this.publicTournaments = const [],
    this.error,
    this.exploreQuery = '',
    this.exploreFormat = '',
  });

  final bool isLoading;
  final List<PlayTournament> myTournaments;
  final List<PlayTournament> publicTournaments;
  final String? error;
  final String exploreQuery;
  final String exploreFormat;

  PlayTournamentsState copyWith({
    bool? isLoading,
    List<PlayTournament>? myTournaments,
    List<PlayTournament>? publicTournaments,
    String? error,
    String? exploreQuery,
    String? exploreFormat,
    bool clearError = false,
  }) =>
      PlayTournamentsState(
        isLoading: isLoading ?? this.isLoading,
        myTournaments: myTournaments ?? this.myTournaments,
        publicTournaments: publicTournaments ?? this.publicTournaments,
        error: clearError ? null : (error ?? this.error),
        exploreQuery: exploreQuery ?? this.exploreQuery,
        exploreFormat: exploreFormat ?? this.exploreFormat,
      );

  List<PlayTournament> get participated =>
      myTournaments.where((t) => t.isParticipating && !t.isHost).toList();
  List<PlayTournament> get hosted =>
      myTournaments.where((t) => t.isHost).toList();
}

class PlayTournamentsController extends StateNotifier<PlayTournamentsState> {
  PlayTournamentsController(this._repo)
      : super(const PlayTournamentsState(isLoading: true)) {
    load();
  }

  final PlayTabRepository _repo;

  Future<void> load() async {
    state = state.copyWith(
      isLoading: state.myTournaments.isEmpty,
      clearError: true,
    );
    try {
      final mine = await _repo.fetchMyTournaments();
      if (!mounted) return;
      state = state.copyWith(isLoading: false, myTournaments: mine);
      _refreshExplore();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => load();

  Future<void> _refreshExplore() async {
    try {
      final pub = await _repo.fetchPublicTournaments(
        query: state.exploreQuery.isEmpty ? null : state.exploreQuery,
        format: state.exploreFormat.isEmpty ? null : state.exploreFormat,
      );
      if (!mounted) return;
      state = state.copyWith(publicTournaments: pub);
    } catch (_) {}
  }

  void setExploreQuery(String q) {
    state = state.copyWith(exploreQuery: q);
    _refreshExplore();
  }

  void setExploreFormat(String f) {
    state = state.copyWith(exploreFormat: f);
    _refreshExplore();
  }
}

final playTournamentsControllerProvider = StateNotifierProvider.autoDispose<
    PlayTournamentsController, PlayTournamentsState>(
  (ref) =>
      PlayTournamentsController(ref.watch(playTabRepositoryProvider)),
);
