import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/home_models.dart';

class HomeData {
  final List<FollowedMatch> followedMatches;
  final MarketingBanner? banner;
  final List<DailyPerformance> dailyPerformances;
  final List<CricketNews> news;
  final List<LiveMatchPreview> liveMatches;
  final bool isLoading;
  final String? error;

  const HomeData({
    this.followedMatches = const [],
    this.banner,
    this.dailyPerformances = const [],
    this.news = const [],
    this.liveMatches = const [],
    this.isLoading = false,
    this.error,
  });

  HomeData copyWith({
    List<FollowedMatch>? followedMatches,
    MarketingBanner? banner,
    List<DailyPerformance>? dailyPerformances,
    List<CricketNews>? news,
    List<LiveMatchPreview>? liveMatches,
    bool? isLoading,
    String? error,
  }) {
    return HomeData(
      followedMatches: followedMatches ?? this.followedMatches,
      banner: banner ?? this.banner,
      dailyPerformances: dailyPerformances ?? this.dailyPerformances,
      news: news ?? this.news,
      liveMatches: liveMatches ?? this.liveMatches,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HomeController extends StateNotifier<HomeData> {
  HomeController() : super(const HomeData(isLoading: true)) {
    _init();
  }

  void _init() {
    // Mock Data for "For You" and "Live"
    state = const HomeData(
      isLoading: false,
      banner: MarketingBanner(
        id: 'b1',
        title: 'Join the Summer Cup 2026',
        ctaLabel: 'Register Now',
        bgColor: Color(0xFF1A3A2A),
      ),
      followedMatches: [
        FollowedMatch(
          id: 'fm1',
          playerName: 'Rohit Sharma',
          matchTitle: 'Mumbai vs Delhi',
          status: 'Live',
          score: '42*(28)',
        ),
        FollowedMatch(
          id: 'fm2',
          playerName: 'Virat Kohli',
          matchTitle: 'RCB vs KKR',
          status: 'Upcoming',
        ),
      ],
      dailyPerformances: [
        DailyPerformance(
          id: 'dp1',
          userName: 'You',
          userAvatarUrl: 'https://i.pravatar.cc/150?u=you',
          statLine: '54(32) & 1/12',
          ipEarned: 240,
          matchName: 'Friendly vs Titans',
        ),
        DailyPerformance(
          id: 'dp2',
          userName: 'Arjun K.',
          userAvatarUrl: 'https://i.pravatar.cc/150?u=arjun',
          statLine: '3/18 (4.0)',
          ipEarned: 180,
          matchName: 'Academy Finals',
        ),
      ],
      news: [
        CricketNews(
          id: 'n1',
          title:
              'New training facility opened in North Mumbai with 10 turf wickets.',
          source: 'Swing News',
          timeAgo: '2h ago',
        ),
        CricketNews(
          id: 'n2',
          title: 'Upcoming inter-academy tournament starts this Saturday.',
          source: 'Local Cricket',
          timeAgo: '5h ago',
        ),
      ],
      liveMatches: [
        LiveMatchPreview(
          id: 'lm1',
          teamA: 'Warriors',
          teamB: 'Titans',
          score: '142/4 (16.2) • 120/8 (20.0)',
          status: '2nd Innings',
          league: 'Mumbai Premier League',
        ),
        LiveMatchPreview(
          id: 'lm2',
          teamA: 'Eagles',
          teamB: 'Hawks',
          score: 'Yet to start',
          status: 'Toss delayed',
          league: 'Corporate Cup',
        ),
      ],
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    _init();
  }
}

final homeControllerProvider =
    StateNotifierProvider.autoDispose<HomeController, HomeData>((ref) {
  return HomeController();
});
