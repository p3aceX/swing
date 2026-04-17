class TeamMember {
  const TeamMember({
    required this.profileId,
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.battingStyle,
    this.bowlingStyle,
    this.swingIndex,
    this.totalXp,
    this.swingRank,
    this.totalRuns,
    this.totalWickets,
    this.matchesPlayed,
    this.matchesWon,
    this.roles = const [],
  });

  final String profileId;
  final String userId;
  final String name;
  final String? avatarUrl;
  final String? battingStyle;
  final String? bowlingStyle;
  final double? swingIndex;
  final int? totalXp;
  final String? swingRank;
  final int? totalRuns;
  final int? totalWickets;
  final int? matchesPlayed;
  final int? matchesWon;
  final List<String> roles;

  String? get rankLabel {
    final raw = swingRank;
    if (raw == null || raw.trim().isEmpty) return null;
    return raw
        .split('_')
        .map((part) => '${part[0]}${part.substring(1).toLowerCase()}')
        .join(' ');
  }
}

class PlayerTeam {
  const PlayerTeam({
    required this.id,
    required this.name,
    this.shortName,
    this.logoUrl,
    this.city,
    this.teamType,
    this.members = const [],
    this.isOwner = false,
  });

  final String id;
  final String name;
  final String? shortName;
  final String? logoUrl;
  final String? city;
  final String? teamType;
  final List<TeamMember> members;

  /// True when the current player created this team.
  final bool isOwner;

  int get totalXp =>
      members.fold<int>(0, (sum, member) => sum + (member.totalXp ?? 0));

  double? get averageSwingIndex {
    final values =
        members.map((member) => member.swingIndex).whereType<double>().toList();
    if (values.isEmpty) return null;
    final total = values.fold<double>(0, (sum, value) => sum + value);
    return total / values.length;
  }

  String get rankLabel {
    final xp = totalXp;
    final raw = switch (xp) {
      >= 20000 => 'LEGEND',
      >= 10000 => 'NATIONAL',
      >= 5000 => 'STATE',
      >= 2500 => 'DISTRICT',
      >= 1000 => 'CLUB_RANK',
      _ => 'GULLY',
    };
    return raw
        .split('_')
        .map((part) => '${part[0]}${part.substring(1).toLowerCase()}')
        .join(' ');
  }

  List<TeamMember> get membersByXp {
    final copy = [...members];
    copy.sort((a, b) {
      final xpOrder = (b.totalXp ?? 0).compareTo(a.totalXp ?? 0);
      if (xpOrder != 0) return xpOrder;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return copy;
  }

  List<TeamMember> get membersBySwing {
    final copy = [...members];
    copy.sort((a, b) {
      final swingOrder = (b.swingIndex ?? -1).compareTo(a.swingIndex ?? -1);
      if (swingOrder != 0) return swingOrder;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return copy;
  }

  List<TeamMember> get membersByRuns {
    final copy = [...members];
    copy.sort((a, b) {
      final runOrder = (b.totalRuns ?? 0).compareTo(a.totalRuns ?? 0);
      if (runOrder != 0) return runOrder;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return copy;
  }

  List<TeamMember> get membersByWickets {
    final copy = [...members];
    copy.sort((a, b) {
      final wicketOrder = (b.totalWickets ?? 0).compareTo(a.totalWickets ?? 0);
      if (wicketOrder != 0) return wicketOrder;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return copy;
  }
}

class TeamPlayerSearchResult {
  const TeamPlayerSearchResult({
    required this.userId,
    required this.name,
    this.phone,
    this.avatarUrl,
    this.playerRole,
    this.playerLevel,
    this.swingIndex,
  });

  final String userId;
  final String name;
  final String? phone;
  final String? avatarUrl;
  final String? playerRole;
  final String? playerLevel;
  final double? swingIndex;
}

// ── Analytics Models ─────────────────────────────────────────────────────────

/// Safely reads a numeric value that may be a plain number OR a map like
/// `{current: 66, max: 100}`.
double _parseScore(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is Map) {
    final inner = value['current'] ?? value['score'] ?? value['value'];
    if (inner is num) return inner.toDouble();
  }
  return 0.0;
}

class TeamAnalytics {
  const TeamAnalytics({
    required this.summary,
    required this.batting,
    required this.bowling,
    required this.topBatsmen,
    required this.topBowlers,
    required this.strategy,
    required this.venues,
    required this.powerScore,
    this.nrr = 0.0,
  });

  final TeamSummary summary;
  final TeamBattingStats batting;
  final TeamBowlingStats bowling;
  final List<TopStatPlayer> topBatsmen;
  final List<TopStatPlayer> topBowlers;
  final TeamMatchStrategy strategy;
  final List<VenuePerformance> venues;
  final double powerScore;
  final double nrr;

  factory TeamAnalytics.fromJson(Map<String, dynamic> json) {
    final performers = json['topPerformers'] as Map<String, dynamic>? ?? {};
    return TeamAnalytics(
      summary: TeamSummary.fromJson(json['summary'] ?? {}),
      // Backend key is 'batting' not 'battingAnalytics'
      batting: TeamBattingStats.fromJson(
          json['batting'] ?? json['battingAnalytics'] ?? {}),
      bowling: TeamBowlingStats.fromJson(
          json['bowling'] ?? json['bowlingAnalytics'] ?? {}),
      // Backend key is 'batsmen' / 'bowlers' not 'topBatsmen' / 'topBowlers'
      topBatsmen: ((performers['batsmen'] ?? performers['topBatsmen']) as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => TopStatPlayer.fromJson(e, true))
              .toList() ??
          <TopStatPlayer>[],
      topBowlers: ((performers['bowlers'] ?? performers['topBowlers']) as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => TopStatPlayer.fromJson(e, false))
              .toList() ??
          <TopStatPlayer>[],
      strategy: TeamMatchStrategy.fromJson(json['matchContext'] ?? {}),
      venues: ((json['matchContext']?['venuePerformance'] ??
                  json['venuePerformance']) as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => VenuePerformance.fromJson(e))
              .toList() ??
          [],
      powerScore: _parseScore(json['powerScore']),
      nrr: _parseScore(json['nrr']),
    );
  }
}

class TeamSummary {
  const TeamSummary({
    required this.matchesPlayed,
    required this.totalWins,
    required this.totalLosses,
    required this.totalTies,
    required this.winRate,
    required this.winStreak,
    required this.recentForm,
  });

  final int matchesPlayed;
  final int totalWins;
  final int totalLosses;
  final int totalTies;
  final double winRate;
  final int winStreak;
  final List<String> recentForm;

  factory TeamSummary.fromJson(Map<String, dynamic> json) {
    final rawWinRate = (json['winRate'] as num?)?.toDouble() ?? 0.0;
    // API returns 0–100 already (e.g. 100 means 100%). Normalise to 0–1 for
    // consistent internal representation so callers can multiply by 100 if
    // they need a display percentage.
    final winRate = rawWinRate > 1 ? rawWinRate / 100 : rawWinRate;
    return TeamSummary(
      matchesPlayed: (json['matchesPlayed'] as num?)?.toInt() ?? 0,
      totalWins: (json['totalWins'] as num?)?.toInt() ?? 0,
      totalLosses: (json['totalLosses'] as num?)?.toInt() ?? 0,
      totalTies: (json['totalTies'] as num?)?.toInt() ?? 0,
      winRate: winRate,
      winStreak: (json['winStreak'] as num?)?.toInt() ?? 0,
      recentForm: (json['recentForm'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class TeamBattingStats {
  const TeamBattingStats({
    required this.averageScore,
    required this.highestScore,
    required this.lowestScore,
    required this.totalRuns,
    required this.totalFours,
    required this.totalSixes,
    required this.teamBattingAverage,
    required this.dotBallPercentage,
    required this.scoringRate,
  });

  final double averageScore;
  final int highestScore;
  final int lowestScore;
  final int totalRuns;
  final int totalFours;
  final int totalSixes;
  final double teamBattingAverage;
  final double dotBallPercentage;
  final double scoringRate;

  factory TeamBattingStats.fromJson(Map<String, dynamic> json) {
    return TeamBattingStats(
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      highestScore: (json['highestScore'] as num?)?.toInt() ?? 0,
      lowestScore: (json['lowestScore'] as num?)?.toInt() ?? 0,
      totalRuns: (json['totalRuns'] as num?)?.toInt() ?? 0,
      totalFours: (json['totalFours'] as num?)?.toInt() ?? 0,
      totalSixes: (json['totalSixes'] as num?)?.toInt() ?? 0,
      teamBattingAverage: (json['teamBattingAverage'] as num?)?.toDouble() ?? 0.0,
      dotBallPercentage: (json['dotBallPercentage'] as num?)?.toDouble() ?? 0.0,
      scoringRate: (json['scoringRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TeamBowlingStats {
  const TeamBowlingStats({
    required this.averageEconomy,
    required this.totalWickets,
    required this.averageWicketsPerMatch,
    required this.bowlingAverage,
    this.bestBowling,
    required this.dotBallPercentage,
    required this.extrasConcededAverage,
  });

  final double averageEconomy;
  final int totalWickets;
  final double averageWicketsPerMatch;
  final double bowlingAverage;
  final String? bestBowling;
  final double dotBallPercentage;
  final double extrasConcededAverage;

  factory TeamBowlingStats.fromJson(Map<String, dynamic> json) {
    // bestBowling may be a String ("3/11") or an object {wickets, runs, playerName}
    String? bestBowling;
    final bb = json['bestBowling'];
    if (bb is String && bb.isNotEmpty) {
      bestBowling = bb;
    } else if (bb is Map<String, dynamic>) {
      final w = bb['wickets'];
      final r = bb['runs'];
      final name = bb['playerName'];
      if (w != null && r != null) {
        bestBowling = '$w/$r${name != null ? " ($name)" : ""}';
      }
    }
    return TeamBowlingStats(
      averageEconomy: (json['averageEconomy'] as num?)?.toDouble() ?? 0.0,
      totalWickets: (json['totalWickets'] as num?)?.toInt() ?? 0,
      averageWicketsPerMatch:
          (json['averageWicketsPerMatch'] as num?)?.toDouble() ?? 0.0,
      bowlingAverage: (json['bowlingAverage'] as num?)?.toDouble() ?? 0.0,
      bestBowling: bestBowling,
      dotBallPercentage: (json['dotBallPercentage'] as num?)?.toDouble() ?? 0.0,
      extrasConcededAverage:
          (json['extrasConcededAverage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TopStatPlayer {
  const TopStatPlayer({
    required this.profileId,
    required this.name,
    this.avatarUrl,
    required this.value,
    required this.secondary,
    required this.label,
  });

  final String profileId;
  final String name;
  final String? avatarUrl;
  final String value;
  final String secondary;
  final String label;

  factory TopStatPlayer.fromJson(Map<String, dynamic> json, bool isBatting) {
    // Batting: keys are 'runs', 'average', 'strikeRate'
    // Bowling: keys are 'wickets', 'economy', 'average'
    String fmtNum(dynamic v, {int dp = 1}) {
      final n = (v as num?)?.toDouble();
      if (n == null) return '–';
      return n == n.truncateToDouble() ? n.toInt().toString() : n.toStringAsFixed(dp);
    }

    return TopStatPlayer(
      profileId: (json['playerId'] ?? json['profileId'] ?? '').toString(),
      name: (json['name'] ?? 'Player').toString(),
      avatarUrl: json['avatarUrl'] as String?,
      value: isBatting
          ? (json['runs'] ?? json['totalRuns'] ?? 0).toString()
          : (json['wickets'] ?? json['totalWickets'] ?? 0).toString(),
      secondary: isBatting
          ? 'SR ${fmtNum(json['strikeRate'])}  Avg ${fmtNum(json['average'])}'
          : 'Econ ${fmtNum(json['economy'])}  Avg ${fmtNum(json['average'])}',
      label: isBatting ? 'Runs' : 'Wkts',
    );
  }
}

class TeamMatchStrategy {
  const TeamMatchStrategy({
    required this.tossWinMatchWinRate,
    required this.tossLossMatchWinRate,
    required this.battingFirstWinRate,
    required this.chasingWinRate,
  });

  final double tossWinMatchWinRate;
  final double tossLossMatchWinRate;
  final double battingFirstWinRate;
  final double chasingWinRate;

  factory TeamMatchStrategy.fromJson(Map<String, dynamic> json) {
    final toss = json['tossImpact'] as Map<String, dynamic>? ?? {};
    double pct(dynamic v) {
      final n = (v as num?)?.toDouble() ?? 0.0;
      return n > 1 ? n / 100 : n;
    }
    return TeamMatchStrategy(
      tossWinMatchWinRate: pct(
        toss['winRateWhenWonToss'] ??   // actual key from backend
        toss['winRateTossWon'] ??
        toss['tossWonWinRate'] ??
        json['tossWinMatchWinRate'],
      ),
      tossLossMatchWinRate: pct(
        toss['winRateWhenLostToss'] ??  // actual key from backend
        toss['winRateTossLost'] ??
        toss['tossLostWinRate'] ??
        json['tossLossMatchWinRate'],
      ),
      battingFirstWinRate: pct(json['battingFirstWinRate'] ?? json['batFirstWinRate']),
      chasingWinRate: pct(json['chasingWinRate'] ?? json['chaseWinRate']),
    );
  }
}

class VenuePerformance {
  const VenuePerformance({
    required this.venueName,
    required this.matches,
    required this.winRate,
  });

  final String venueName;
  final int matches;
  final double winRate;

  factory VenuePerformance.fromJson(Map<String, dynamic> json) {
    final rawWinRate = (json['winRate'] as num?)?.toDouble() ?? 0.0;
    return VenuePerformance(
      venueName: (json['venueName'] ?? json['venue'] ?? 'Other').toString(),
      matches: (json['matches'] as num?)?.toInt() ?? 0,
      winRate: rawWinRate > 1 ? rawWinRate / 100 : rawWinRate,
    );
  }
}
