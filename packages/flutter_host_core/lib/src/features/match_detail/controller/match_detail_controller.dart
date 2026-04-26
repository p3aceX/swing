import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/match_detail_repository.dart';
import '../domain/match_models.dart';

class MatchDetailState {
  const MatchDetailState({
    this.isLoading = false,
    this.matchCenter,
    this.commentary = const [],
    this.analysis,
    this.error,
  });

  final bool isLoading;
  final MatchCenter? matchCenter;
  final List<MatchCommentaryEntry> commentary;
  final MatchAnalysis? analysis;
  final String? error;

  bool get hasData => matchCenter != null;

  MatchDetailState copyWith({
    bool? isLoading,
    MatchCenter? matchCenter,
    List<MatchCommentaryEntry>? commentary,
    MatchAnalysis? analysis,
    String? error,
    bool clearError = false,
  }) {
    return MatchDetailState(
      isLoading: isLoading ?? this.isLoading,
      matchCenter: matchCenter ?? this.matchCenter,
      commentary: commentary ?? this.commentary,
      analysis: analysis ?? this.analysis,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MatchDetailController extends StateNotifier<MatchDetailState> {
  MatchDetailController(this._repo, this._matchId)
      : super(const MatchDetailState(isLoading: true));

  final HostMatchDetailRepository _repo;
  final String _matchId;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final center = await _repo.loadMatchCenter(_matchId);
      if (!mounted) return;
      state = MatchDetailState(isLoading: false, matchCenter: center);
    } catch (e) {
      if (!mounted) return;
      state = MatchDetailState(isLoading: false, error: _messageFor(e));
    }
  }

  Future<void> refresh() => load();

  Future<void> loadCommentary({int? inningsNum}) async {
    try {
      final entries = await _repo.loadCommentary(_matchId, inningsNum: inningsNum);
      if (!mounted) return;
      state = state.copyWith(commentary: entries);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: _messageFor(e));
    }
  }

  Future<void> loadAnalysis() async {
    try {
      final analysis = await _repo.loadMatchAnalysis(_matchId);
      if (!mounted) return;
      state = state.copyWith(analysis: analysis);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: _messageFor(e));
    }
  }

  Stream<String> watchLiveOverlay() => _repo.watchLiveOverlay(_matchId);

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
      return e.message ?? 'Could not load match.';
    }
    return e.toString();
  }
}

final matchDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<MatchDetailController, MatchDetailState, String>(
  (ref, matchId) {
    final ctrl = MatchDetailController(ref.watch(hostMatchDetailRepositoryProvider), matchId);
    ctrl.load();
    return ctrl;
  },
);

/// Lightweight live-score provider. Only the score widget watches this, so
/// SSE-driven invalidations don't rebuild the full match detail page.
final matchLiveScoreProvider =
    FutureProvider.autoDispose.family<MatchLiveScore, String>(
  (ref, matchId) async {
    return ref.watch(hostMatchDetailRepositoryProvider).loadLiveScore(matchId);
  },
);

final matchCommentaryProvider = FutureProvider.autoDispose.family<List<MatchCommentaryEntry>, ({String matchId, int? inningsNum})>(
  (ref, args) async {
    final repo = ref.watch(hostMatchDetailRepositoryProvider);
    return repo.loadCommentary(args.matchId, inningsNum: args.inningsNum);
  },
);

final matchAnalysisProvider = FutureProvider.autoDispose.family<MatchAnalysis, String>(
  (ref, matchId) async {
    final repo = ref.watch(hostMatchDetailRepositoryProvider);
    return repo.loadMatchAnalysis(matchId);
  },
);
