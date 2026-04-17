import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/matches_repository.dart';
import '../domain/match_models.dart';

final matchesRepositoryProvider =
    Provider<MatchesRepository>((ref) => MatchesRepository());

class MatchesState {
  const MatchesState({
    this.isLoading = false,
    this.matches = const [],
    this.error,
  });

  final bool isLoading;
  final List<PlayerMatch> matches;
  final String? error;

  MatchesState copyWith({
    bool? isLoading,
    List<PlayerMatch>? matches,
    String? error,
  }) {
    return MatchesState(
      isLoading: isLoading ?? this.isLoading,
      matches: matches ?? this.matches,
      error: error,
    );
  }
}

class MatchesController extends StateNotifier<MatchesState> {
  MatchesController(this._repository)
      : super(const MatchesState(isLoading: true)) {
    load();
  }

  final MatchesRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: state.matches.isEmpty, error: null);
    try {
      await for (final matches in _repository.loadMyMatchesStream()) {
        state = MatchesState(isLoading: false, matches: matches);
      }
    } catch (error) {
      state = MatchesState(
        isLoading: false,
        matches: state.matches,
        error: _messageFor(error),
      );
    }
  }

  Future<void> refresh() => load();

  String _messageFor(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
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
      if (status != null) return 'Server error $status. Check your connection.';
      // Connection errors — most likely wrong base URL or no internet
      final type = error.type.name;
      return 'Network error ($type). Check API_BASE_URL in .env';
    }
    return error.toString();
  }
}

final matchesControllerProvider =
    StateNotifierProvider.autoDispose<MatchesController, MatchesState>((ref) {
  return MatchesController(ref.watch(matchesRepositoryProvider));
});

final matchCenterProvider = FutureProvider.autoDispose
    .family<MatchCenter, String>((ref, matchId) async {
  return ref.watch(matchesRepositoryProvider).loadMatchCenter(matchId);
});

final matchCommentaryProvider = FutureProvider.autoDispose
    .family<List<MatchCommentaryEntry>, String>((ref, matchId) async {
  return ref.watch(matchesRepositoryProvider).loadCommentary(matchId);
});

final matchAnalysisProvider = FutureProvider.autoDispose
    .family<MatchAnalysis, String>((ref, matchId) async {
  return ref.watch(matchesRepositoryProvider).loadMatchAnalysis(matchId);
});
