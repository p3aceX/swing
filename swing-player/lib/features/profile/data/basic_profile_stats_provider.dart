import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

enum BallType { leather, tennis }

extension BallTypeX on BallType {
  String get apiValue => this == BallType.tennis ? 'TENNIS' : 'LEATHER';
  String get label => this == BallType.tennis ? 'Tennis' : 'Leather';
}

class BasicProfileStatsRequest {
  const BasicProfileStatsRequest({
    required this.profileId,
    required this.ballType,
  });

  final String? profileId;
  final BallType ballType;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is BasicProfileStatsRequest &&
            other.profileId == profileId &&
            other.ballType == ballType);
  }

  @override
  int get hashCode => Object.hash(profileId, ballType);
}

final basicProfileStatsProvider =
    StateNotifierProvider.autoDispose.family<BasicProfileStatsNotifier,
        BasicProfileStatsState, BasicProfileStatsRequest>(
  (ref, request) => BasicProfileStatsNotifier(ApiClient.instance.dio, request),
);

class BasicProfileStatsState {
  const BasicProfileStatsState({
    this.stats,
    this.isLoading = false,
    this.error,
  });

  final BasicProfileStats? stats;
  final bool isLoading;
  final String? error;

  BasicProfileStatsState copyWith({
    BasicProfileStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return BasicProfileStatsState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BasicProfileStatsNotifier extends StateNotifier<BasicProfileStatsState> {
  BasicProfileStatsNotifier(this._dio, this.request)
      : super(const BasicProfileStatsState()) {
    load();
  }

  final Dio _dio;
  final BasicProfileStatsRequest request;

  Future<void> load({bool force = false}) async {
    if (state.isLoading && !force) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(
        request.profileId == null
            ? ApiEndpoints.playerProfile
            : ApiEndpoints.publicPlayerProfile(request.profileId!),
        queryParameters: {'ballType': request.ballType.apiValue},
      );
      final payload = _unwrapPayload(response);
      final stats = BasicProfileStats.fromJson(payload);
      state = state.copyWith(stats: stats, isLoading: false, error: null);
    } on DioException catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load stats.',
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load stats.',
      );
    }
  }

  Future<void> refresh() => load(force: true);
}

class BasicProfileStats {
  const BasicProfileStats({
    required this.matches,
    required this.batting,
    required this.bowling,
    required this.fielding,
  });

  final MatchSummary matches;
  final BattingSummary batting;
  final BowlingSummary bowling;
  final FieldingSummary fielding;

  factory BasicProfileStats.fromJson(Map<String, dynamic> json) {
    final stats = _map(json['stats']);
    final battingNode = _map(stats['batting']);
    final bowlingNode = _map(stats['bowling']);
    return BasicProfileStats(
      matches: MatchSummary.fromJson(_map(stats['matches'])),
      batting: BattingSummary.fromJson(_map(battingNode['summary'])
          .isNotEmpty
          ? _map(battingNode['summary'])
          : battingNode),
      bowling: BowlingSummary.fromJson(_map(bowlingNode['summary'])
          .isNotEmpty
          ? _map(bowlingNode['summary'])
          : bowlingNode),
      fielding: FieldingSummary.fromJson(_map(stats['fielding'])),
    );
  }
}

class MatchSummary {
  const MatchSummary({
    required this.total,
    required this.wins,
    required this.winPct,
  });

  final int total;
  final int wins;
  final double winPct;

  factory MatchSummary.fromJson(Map<String, dynamic> json) {
    return MatchSummary(
      total: _toInt(json['total']),
      wins: _toInt(json['wins']),
      winPct: _toDouble(json['winPct']),
    );
  }
}

class BattingSummary {
  const BattingSummary({
    required this.totalRuns,
    required this.totalBallsFaced,
    required this.average,
    required this.strikeRate,
    required this.highestScore,
    required this.fours,
    required this.fifties,
    required this.hundreds,
    required this.sixes,
  });

  final int totalRuns;
  final int totalBallsFaced;
  final double average;
  final double strikeRate;
  final int highestScore;
  final int fours;
  final int fifties;
  final int hundreds;
  final int sixes;

  factory BattingSummary.fromJson(Map<String, dynamic> json) {
    return BattingSummary(
      totalRuns: _toInt(json['totalRuns']),
      totalBallsFaced: _toInt(json['totalBallsFaced']),
      average: _toDouble(json['average']),
      strikeRate: _toDouble(json['strikeRate']),
      highestScore: _toInt(json['highestScore']),
      fours: _toInt(json['fours']),
      fifties: _toInt(json['fifties']),
      hundreds: _toInt(json['hundreds']),
      sixes: _toInt(json['sixes']),
    );
  }
}

class BowlingSummary {
  const BowlingSummary({
    required this.totalWickets,
    required this.totalBallsBowled,
    required this.bestBowling,
    required this.average,
    required this.economy,
    required this.strikeRate,
    required this.fiveWicketHauls,
    required this.maidens,
    required this.dotBalls,
  });

  final int totalWickets;
  final int totalBallsBowled;
  final String bestBowling;
  final double average;
  final double economy;
  final double strikeRate;
  final int fiveWicketHauls;
  final int maidens;
  final int dotBalls;

  factory BowlingSummary.fromJson(Map<String, dynamic> json) {
    return BowlingSummary(
      totalWickets: _toInt(json['totalWickets']),
      totalBallsBowled: _toInt(json['totalBallsBowled']),
      bestBowling: _string(json['bestBowling'], fallback: '--'),
      average: _toDouble(json['average']),
      economy: _toDouble(json['economy']),
      strikeRate: _toDouble(json['strikeRate']),
      fiveWicketHauls: _toInt(json['fiveWicketHauls']),
      maidens: _toInt(json['maidens']),
      dotBalls: _toInt(json['dotBalls']),
    );
  }
}

class FieldingSummary {
  const FieldingSummary({
    required this.catches,
    required this.stumpings,
    required this.runOuts,
  });

  final int catches;
  final int stumpings;
  final int runOuts;

  factory FieldingSummary.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return const FieldingSummary(catches: 0, stumpings: 0, runOuts: 0);
    }
    return FieldingSummary(
      catches: _toInt(json['catches']),
      stumpings: _toInt(json['stumpings']),
      runOuts: _toInt(json['runOuts']),
    );
  }
}

Map<String, dynamic> _unwrapPayload(dynamic response) {
  if (response == null) return <String, dynamic>{};
  final data = response.data;
  if (data is Map<String, dynamic>) {
    final inner = data['data'];
    return inner is Map<String, dynamic> ? inner : data;
  }
  return <String, dynamic>{};
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : <String, dynamic>{};

int _toInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
  }
  return 0;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

String _string(dynamic value, {String fallback = ''}) {
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return fallback;
}
