import 'package:flutter/material.dart';

class FollowedMatch {
  final String id;
  final String playerName;
  final String? playerAvatarUrl;
  final String matchTitle;
  final String status;
  final String? score;

  const FollowedMatch({
    required this.id,
    required this.playerName,
    this.playerAvatarUrl,
    required this.matchTitle,
    required this.status,
    this.score,
  });
}

class MarketingBanner {
  final String id;
  final String title;
  final String? imageUrl;
  final String? ctaLabel;
  final Color? bgColor;

  const MarketingBanner({
    required this.id,
    required this.title,
    this.imageUrl,
    this.ctaLabel,
    this.bgColor,
  });
}

class DailyPerformance {
  final String id;
  final String userName;
  final String userAvatarUrl;
  final String statLine; // e.g. "42(28) & 2/15"
  final int ipEarned;
  final String matchName;

  const DailyPerformance({
    required this.id,
    required this.userName,
    required this.userAvatarUrl,
    required this.statLine,
    required this.ipEarned,
    required this.matchName,
  });
}

class CricketNews {
  final String id;
  final String title;
  final String source;
  final String timeAgo;
  final String? imageUrl;

  const CricketNews({
    required this.id,
    required this.title,
    required this.source,
    required this.timeAgo,
    this.imageUrl,
  });
}

// Keep existing for Live tab and shared usage
class LiveMatchPreview {
  final String id;
  final String teamA;
  final String teamB;
  final String? teamALogo;
  final String? teamBLogo;
  final String score;
  final String status;
  final String league;

  const LiveMatchPreview({
    required this.id,
    required this.teamA,
    required this.teamB,
    this.teamALogo,
    this.teamBLogo,
    required this.score,
    required this.status,
    required this.league,
  });
}
