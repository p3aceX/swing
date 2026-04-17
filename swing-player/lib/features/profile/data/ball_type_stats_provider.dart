import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import 'profile_payload_models.dart';

// ─── Ball Type ────────────────────────────────────────────────────────────────

enum BallType { leather, tennis }

extension BallTypeExtension on BallType {
  String get apiValue => this == BallType.leather ? 'LEATHER' : 'TENNIS';
  String get label => this == BallType.leather ? 'Leather' : 'Tennis';
}

// ─── State ────────────────────────────────────────────────────────────────────

class BallTypeStatsState {
  const BallTypeStatsState({
    this.profile,
    this.ballType = BallType.leather,
    this.isLoading = false,
    this.error,
  });

  final EliteProfilePayload? profile;
  final BallType ballType;
  final bool isLoading;
  final String? error;

  bool get hasData => profile != null;

  BallTypeStatsState copyWith({
    EliteProfilePayload? profile,
    BallType? ballType,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return BallTypeStatsState(
      profile: profile ?? this.profile,
      ballType: ballType ?? this.ballType,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  // ── Match ─────────────────────────────────────────────────────────────────

  int get totalMatches => profile?.stats.matches.total ?? 0;
  int get wins => profile?.stats.matches.wins ?? 0;
  int get losses => profile?.stats.matches.losses ?? 0;
  double get winPct => profile?.stats.matches.winPct ?? 0.0;

  // ── Batting ───────────────────────────────────────────────────────────────

  int get totalRuns => profile?.stats.batting.totalRuns ?? 0;
  int get totalBallsFaced => profile?.stats.batting.totalBallsFaced ?? 0;
  int get highestScore => profile?.stats.batting.highestScore ?? 0;
  double get battingAverage => profile?.stats.batting.average ?? 0.0;
  double get strikeRate => profile?.stats.batting.strikeRate ?? 0.0;
  int get fours => profile?.stats.batting.fours ?? 0;
  int get sixes => profile?.stats.batting.sixes ?? 0;
  int get fifties => profile?.stats.batting.fifties ?? 0;
  int get hundreds => profile?.stats.batting.hundreds ?? 0;

  // ── Bowling ───────────────────────────────────────────────────────────────

  int get totalWickets => profile?.stats.bowling.totalWickets ?? 0;
  int get totalBallsBowled => profile?.stats.bowling.totalBallsBowled ?? 0;
  String get bestBowling {
    final v = (profile?.stats.bowling.bestBowling ?? '-').trim();
    return v.isEmpty || v == '-' ? '--' : v;
  }

  double get bowlingAverage => profile?.stats.bowling.average ?? 0.0;
  double get economy => profile?.stats.bowling.economy ?? 0.0;
  double get bowlingStrikeRate => profile?.stats.bowling.strikeRate ?? 0.0;
  int get fiveWicketHauls => profile?.stats.bowling.fiveWicketHauls ?? 0;
  int get maidens => profile?.stats.bowling.maidens ?? 0;
  int get dotBalls => profile?.stats.bowling.dotBalls ?? 0;

  // ── Fielding ──────────────────────────────────────────────────────────────

  int get catches => profile?.stats.fielding.catches ?? 0;
  int get stumpings => profile?.stats.fielding.stumpings ?? 0;
  int get runOuts => profile?.stats.fielding.runOuts ?? 0;
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final ballTypeStatsProvider = StateNotifierProvider.autoDispose
    .family<BallTypeStatsNotifier, BallTypeStatsState, String>(
  (ref, profileId) => BallTypeStatsNotifier(
    ApiClient.instance.dio,
    profileId: profileId,
  ),
);

// ─── Notifier ─────────────────────────────────────────────────────────────────

class BallTypeStatsNotifier extends StateNotifier<BallTypeStatsState> {
  BallTypeStatsNotifier(this._dio, {required this.profileId})
      : super(const BallTypeStatsState()) {
    load(BallType.leather);
  }

  final Dio _dio;
  final String profileId;

  Future<void> load(BallType ballType) async {
    state = state.copyWith(ballType: ballType, isLoading: true, clearError: true);
    try {
      final response = await _dio.get(
        ApiEndpoints.elitePlayerProfile(profileId),
        queryParameters: {'ballType': ballType.apiValue},
      );
      final body = response.data;
      // Unwrap { "data": {...} } envelope — same as profile_repository._unwrapMap
      final topLevel = body is Map<String, dynamic> ? body : <String, dynamic>{};
      final data = topLevel['data'] is Map<String, dynamic>
          ? topLevel['data'] as Map<String, dynamic>
          : topLevel;
      final profile = EliteProfilePayload.fromJson(data);
      state = state.copyWith(profile: profile, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.statusCode == 404
            ? 'Stats not available.'
            : 'Could not load stats.',
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Could not load stats.');
    }
  }
}
