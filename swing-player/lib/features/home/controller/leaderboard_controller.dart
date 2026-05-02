import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/leaderboard_repository.dart';
import '../domain/leaderboard_models.dart';

final leaderboardRepositoryProvider =
    Provider<LeaderboardRepository>((ref) => LeaderboardRepository());

/// Global leaderboard – paginated, auto-dispose
final leaderboardProvider =
    StreamProvider.autoDispose<LeaderboardData>((ref) {
  return ref.watch(leaderboardRepositoryProvider).loadLeaderboardStream();
});

/// Recommendations – small list from recent match teammates/opponents
final recommendationsProvider =
    StreamProvider.autoDispose<List<LeaderboardEntry>>((ref) {
  return ref.watch(leaderboardRepositoryProvider).loadRecommendationsStream();
});
