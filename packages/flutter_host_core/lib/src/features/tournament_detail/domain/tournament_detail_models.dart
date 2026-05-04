import 'dart:convert';

import 'package:intl/intl.dart';

// ── Full detail model ─────────────────────────────────────────────────────────

class TournamentDetailModel {
  const TournamentDetailModel({
    required this.id,
    required this.name,
    required this.status,
    required this.format,
    required this.tournamentFormat,
    required this.startDate,
    required this.maxTeams,
    required this.ballType,
    required this.teams,
    required this.groups,
    required this.standings,
    this.slug,
    this.endDate,
    this.city,
    this.venueName,
    this.logoUrl,
    this.coverUrl,
    this.description,
    this.rules,
    this.entryFee,
    this.earlyBirdDeadline,
    this.earlyBirdFee,
    this.organiserName,
    this.organiserPhone,
    this.prizePool,
    this.isVerified = false,
    this.academyName,
    this.createdByName,
    this.highlights = const [],
  });

  final String id;
  final String name;
  final String status;
  final String format;
  final String tournamentFormat;
  final DateTime startDate;
  final DateTime? endDate;
  final int maxTeams;
  final String ballType;
  final String? slug;
  final String? city;
  final String? venueName;
  final String? logoUrl;
  final String? coverUrl;
  final String? description;
  final String? rules;
  final int? entryFee;
  final DateTime? earlyBirdDeadline;
  final int? earlyBirdFee;
  final String? organiserName;
  final String? organiserPhone;
  final String? prizePool;
  final bool isVerified;
  final String? academyName;
  final String? createdByName;
  final List<TournamentTeamEntry> teams;
  final List<TournamentGroupModel> groups;
  final List<TournamentStandingModel> standings;
  final List<TournamentHighlightModel> highlights;

  bool get isEarlyBirdActive =>
      earlyBirdFee != null &&
      earlyBirdDeadline != null &&
      DateTime.now().isBefore(earlyBirdDeadline!);

  int? get effectiveEntryFee {
    if (isEarlyBirdActive) return earlyBirdFee;
    return entryFee;
  }

  String get resolvedOrganiserName => organiserName?.isNotEmpty == true
      ? organiserName!
      : academyName?.isNotEmpty == true
          ? academyName!
          : createdByName?.isNotEmpty == true
              ? createdByName!
              : 'Swing Official';

  bool get isSwingOfficial =>
      organiserName == null && academyName == null && createdByName == null;

  int get confirmedTeamCount => teams.where((t) => t.isConfirmed).length;

  factory TournamentDetailModel.fromJson(Map<String, dynamic> j) {
    final List teamsJson = j['teams'] is List ? j['teams'] as List : [];
    final List groupsJson = j['groups'] is List ? j['groups'] as List : [];
    final List standingsJson =
        j['standings'] is List ? j['standings'] as List : [];

    List highlightsJson = [];
    final rawHighlights = j['highlights'];
    if (rawHighlights is List) {
      highlightsJson = rawHighlights;
    } else if (rawHighlights is String && rawHighlights.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawHighlights);
        if (decoded is List) highlightsJson = decoded;
      } catch (_) {}
    }

    return TournamentDetailModel(
      id: '${j['id'] ?? j['_id'] ?? j['tournamentId'] ?? ''}',
      name: '${j['name'] ?? 'Tournament'}',
      status: '${j['status'] ?? 'UPCOMING'}',
      format: '${j['format'] ?? 'T20'}',
      tournamentFormat: '${j['tournamentFormat'] ?? 'LEAGUE'}',
      startDate: DateTime.tryParse('${j['startDate'] ?? ''}') ?? DateTime.now(),
      endDate:
          j['endDate'] != null ? DateTime.tryParse('${j['endDate']}') : null,
      maxTeams: (j['maxTeams'] as int?) ?? 8,
      ballType: '${j['ballType'] ?? 'LEATHER'}',
      slug: j['slug'] as String?,
      city: j['city'] as String?,
      venueName: j['venueName'] as String?,
      logoUrl: j['logoUrl'] as String?,
      coverUrl: j['coverUrl'] as String?,
      description: j['description'] as String?,
      rules: j['rules'] as String?,
      entryFee: j['entryFee'] as int?,
      earlyBirdDeadline: j['earlyBirdDeadline'] != null
          ? DateTime.tryParse('${j['earlyBirdDeadline']}')
          : null,
      earlyBirdFee: j['earlyBirdFee'] as int?,
      organiserName: j['organiserName'] as String?,
      organiserPhone: j['organiserPhone'] as String?,
      prizePool: j['prizePool'] as String?,
      isVerified: j['isVerified'] == true,
      academyName: (j['academy'] as Map?)?['name'] as String?,
      createdByName: (j['createdBy'] as Map?)?['name'] as String?,
      teams: teamsJson
          .whereType<Map<String, dynamic>>()
          .map(TournamentTeamEntry.fromJson)
          .toList(),
      groups: groupsJson
          .whereType<Map<String, dynamic>>()
          .map(TournamentGroupModel.fromJson)
          .toList(),
      standings: standingsJson
          .whereType<Map<String, dynamic>>()
          .map(TournamentStandingModel.fromJson)
          .toList(),
      highlights: highlightsJson
          .whereType<Map<String, dynamic>>()
          .map(TournamentHighlightModel.fromJson)
          .toList(),
    );
  }
}

// ── Highlight ─────────────────────────────────────────────────────────────────

class TournamentHighlightModel {
  const TournamentHighlightModel({required this.title, required this.youtubeUrl});

  final String title;
  final String youtubeUrl;

  String? get videoId {
    final uri = Uri.tryParse(youtubeUrl);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) return uri.pathSegments.firstOrNull;
    return uri.queryParameters['v'];
  }

  String? get thumbnailUrl {
    final id = videoId;
    return id != null ? 'https://img.youtube.com/vi/$id/hqdefault.jpg' : null;
  }

  factory TournamentHighlightModel.fromJson(Map<String, dynamic> j) =>
      TournamentHighlightModel(
        title: '${j['title'] ?? j['name'] ?? 'Highlight'}',
        youtubeUrl: '${j['youtubeUrl'] ?? j['url'] ?? ''}',
      );
}

// ── Team entry ────────────────────────────────────────────────────────────────

class TournamentTeamEntry {
  const TournamentTeamEntry({
    required this.id,
    required this.teamName,
    required this.isConfirmed,
    this.teamId,
    this.teamLogoUrl,
    this.teamShortName,
    this.groupId,
  });
  final String id;
  final String? teamId;
  final String teamName;
  final bool isConfirmed;
  final String? teamLogoUrl;
  final String? teamShortName;
  final String? groupId;

  factory TournamentTeamEntry.fromJson(Map<String, dynamic> j) {
    final team = j['team'] as Map?;
    return TournamentTeamEntry(
      id: '${j['id'] ?? ''}',
      teamId: (team?['id'] ?? j['teamId']) as String?,
      teamName: '${j['teamName'] ?? team?['name'] ?? ''}',
      isConfirmed: j['isConfirmed'] == true,
      teamLogoUrl: team?['logoUrl'] as String?,
      teamShortName: team?['shortName'] as String?,
      groupId: j['groupId'] as String?,
    );
  }
}

// ── Group ─────────────────────────────────────────────────────────────────────

class TournamentGroupModel {
  const TournamentGroupModel(
      {required this.id, required this.name, required this.teams});
  final String id;
  final String name;
  final List<TournamentTeamEntry> teams;

  factory TournamentGroupModel.fromJson(Map<String, dynamic> j) {
    final List teamsJson = j['teams'] is List ? j['teams'] as List : [];
    return TournamentGroupModel(
      id: '${j['id'] ?? ''}',
      name: '${j['name'] ?? 'Group'}',
      teams: teamsJson
          .whereType<Map<String, dynamic>>()
          .map(TournamentTeamEntry.fromJson)
          .toList(),
    );
  }
}

// ── Standing ──────────────────────────────────────────────────────────────────

class TournamentStandingModel {
  const TournamentStandingModel({
    required this.id,
    required this.teamName,
    required this.played,
    required this.won,
    required this.lost,
    required this.tied,
    required this.noResult,
    required this.points,
    required this.netRunRate,
    this.groupId,
    this.groupName,
    this.position,
  });
  final String id;
  final String teamName;
  final int played;
  final int won;
  final int lost;
  final int tied;
  final int noResult;
  final int points;
  final double netRunRate;
  final String? groupId;
  final String? groupName;
  final int? position;

  factory TournamentStandingModel.fromJson(Map<String, dynamic> j) =>
      TournamentStandingModel(
        id: '${j['id'] ?? ''}',
        teamName: '${j['teamName'] ?? ''}',
        played: (j['played'] as int?) ?? 0,
        won: (j['won'] as int?) ?? 0,
        lost: (j['lost'] as int?) ?? 0,
        tied: (j['tied'] as int?) ?? 0,
        noResult: (j['noResult'] as int?) ?? 0,
        points: (j['points'] as int?) ?? 0,
        netRunRate: (j['netRunRate'] as num?)?.toDouble() ?? 0.0,
        groupId: j['groupId'] as String?,
        groupName: j['groupName'] as String?,
        position: j['position'] as int?,
      );
}

// ── Match ─────────────────────────────────────────────────────────────────────

class TournamentMatchModel {
  const TournamentMatchModel({
    required this.id,
    required this.teamAName,
    required this.teamBName,
    required this.status,
    required this.innings,
    this.scheduledAt,
    this.round,
    this.groupName,
    this.result,
    this.format,
    this.winner,
  });
  final String id;
  final String teamAName;
  final String teamBName;
  final String status;
  final List<TournamentMatchInnings> innings;
  final DateTime? scheduledAt;
  final String? round;
  final String? groupName;
  final String? result;
  final String? format;
  final String? winner;

  factory TournamentMatchModel.fromJson(Map<String, dynamic> j) {
    final List inningsJson = j['innings'] is List ? j['innings'] as List : [];
    return TournamentMatchModel(
      id: '${j['id'] ?? ''}',
      teamAName: '${j['teamAName'] ?? ''}',
      teamBName: '${j['teamBName'] ?? ''}',
      status: '${j['status'] ?? 'UPCOMING'}',
      innings: inningsJson
          .whereType<Map<String, dynamic>>()
          .map(TournamentMatchInnings.fromJson)
          .toList(),
      scheduledAt: j['scheduledAt'] != null
          ? DateTime.tryParse('${j['scheduledAt']}')
          : null,
      round: j['round'] != null ? '${j['round']}' : null,
      groupName: j['groupName'] != null ? '${j['groupName']}' : null,
      result: j['result'] != null ? '${j['result']}' : null,
      format: j['format'] != null ? '${j['format']}' : null,
      winner: j['winnerId'] != null ? '${j['winnerId']}' : null,
    );
  }
}

class TournamentMatchInnings {
  const TournamentMatchInnings({
    required this.inningsNumber,
    required this.battingTeam,
    required this.totalRuns,
    required this.totalWickets,
    required this.totalOvers,
    required this.isCompleted,
  });
  final int inningsNumber;
  final String battingTeam;
  final int totalRuns;
  final int totalWickets;
  final double totalOvers;
  final bool isCompleted;

  factory TournamentMatchInnings.fromJson(Map<String, dynamic> j) =>
      TournamentMatchInnings(
        inningsNumber: _toInt(j['inningsNumber']) ?? 1,
        battingTeam: '${j['battingTeam'] ?? ''}',
        totalRuns: _toInt(j['totalRuns']) ?? 0,
        totalWickets: _toInt(j['totalWickets']) ?? 0,
        totalOvers: (j['totalOvers'] as num?)?.toDouble() ??
            double.tryParse('${j['totalOvers'] ?? ''}') ??
            0.0,
        isCompleted: j['isCompleted'] == true,
      );
}

// ── Leaderboard ───────────────────────────────────────────────────────────────

class TournamentLeaderboardModel {
  const TournamentLeaderboardModel({
    required this.topBatsmen,
    required this.topBowlers,
    required this.topFielders,
    required this.tournamentTotals,
    this.playerOfTournament,
  });

  final List<LeaderboardPlayerModel> topBatsmen;
  final List<LeaderboardPlayerModel> topBowlers;
  final List<LeaderboardPlayerModel> topFielders;
  final TournamentTotalsModel tournamentTotals;
  final LeaderboardPlayerModel? playerOfTournament;

  factory TournamentLeaderboardModel.fromJson(Map<String, dynamic> j) {
    List<LeaderboardPlayerModel> parseList(dynamic raw) => raw is List
        ? raw
            .whereType<Map<String, dynamic>>()
            .map(LeaderboardPlayerModel.fromJson)
            .toList()
        : [];
    return TournamentLeaderboardModel(
      topBatsmen: parseList(j['topBatsmen']),
      topBowlers: parseList(j['topBowlers']),
      topFielders: parseList(j['topFielders']),
      playerOfTournament: j['playerOfTournament'] != null
          ? LeaderboardPlayerModel.fromJson(
              j['playerOfTournament'] as Map<String, dynamic>)
          : null,
      tournamentTotals: j['tournamentTotals'] != null
          ? TournamentTotalsModel.fromJson(
              j['tournamentTotals'] as Map<String, dynamic>)
          : const TournamentTotalsModel(),
    );
  }
}

class LeaderboardPlayerInfo {
  const LeaderboardPlayerInfo({
    required this.id,
    required this.name,
    required this.rankKey,
    required this.rankDivision,
    required this.lifetimeIp,
    this.avatarUrl,
    this.username,
  });
  final String id;
  final String name;
  final String rankKey;
  final int rankDivision;
  final int lifetimeIp;
  final String? avatarUrl;
  final String? username;

  factory LeaderboardPlayerInfo.fromJson(Map<String, dynamic> j) =>
      LeaderboardPlayerInfo(
        id: '${j['id'] ?? ''}',
        name: '${j['name'] ?? 'Unknown'}',
        rankKey: '${j['rankKey'] ?? 'ROOKIE'}',
        rankDivision: (j['rankDivision'] as int?) ?? 3,
        lifetimeIp: (j['lifetimeIp'] as int?) ?? 0,
        avatarUrl: j['avatarUrl'] as String?,
        username: j['username'] as String?,
      );
}

class LeaderboardPlayerModel {
  const LeaderboardPlayerModel({
    required this.player,
    required this.totalIp,
    required this.runs,
    required this.balls,
    required this.fours,
    required this.sixes,
    required this.strikeRate,
    required this.highestScore,
    required this.innings,
    required this.wickets,
    required this.oversBowled,
    required this.runsConceded,
    required this.economy,
    required this.catches,
    required this.stumpings,
    required this.runOuts,
    required this.totalDismissals,
    this.reason,
  });

  final LeaderboardPlayerInfo player;
  final int totalIp;
  final int runs;
  final int balls;
  final int fours;
  final int sixes;
  final double strikeRate;
  final int highestScore;
  final int innings;
  final int wickets;
  final double oversBowled;
  final int runsConceded;
  final double economy;
  final int catches;
  final int stumpings;
  final int runOuts;
  final int totalDismissals;
  final String? reason;

  factory LeaderboardPlayerModel.fromJson(Map<String, dynamic> j) =>
      LeaderboardPlayerModel(
        player: LeaderboardPlayerInfo.fromJson(
            (j['player'] as Map<String, dynamic>?) ?? {}),
        totalIp: (j['totalIp'] as int?) ?? 0,
        runs: (j['runs'] as int?) ?? 0,
        balls: (j['balls'] as int?) ?? 0,
        fours: (j['fours'] as int?) ?? 0,
        sixes: (j['sixes'] as int?) ?? 0,
        strikeRate: (j['strikeRate'] as num?)?.toDouble() ?? 0.0,
        highestScore: (j['highestScore'] as int?) ?? 0,
        innings: (j['innings'] as int?) ?? 0,
        wickets: (j['wickets'] as int?) ?? 0,
        oversBowled: (j['oversBowled'] as num?)?.toDouble() ?? 0.0,
        runsConceded: (j['runsConceded'] as int?) ?? 0,
        economy: (j['economy'] as num?)?.toDouble() ?? 0.0,
        catches: (j['catches'] as int?) ?? 0,
        stumpings: (j['stumpings'] as int?) ?? 0,
        runOuts: (j['runOuts'] as int?) ?? 0,
        totalDismissals: (j['totalDismissals'] as int?) ?? 0,
        reason: j['reason'] as String?,
      );
}

class TournamentTotalsModel {
  const TournamentTotalsModel({
    this.totalRuns = 0,
    this.totalFours = 0,
    this.totalSixes = 0,
    this.totalWickets = 0,
    this.matchesPlayed = 0,
    this.totalIpAwarded = 0,
  });
  final int totalRuns;
  final int totalFours;
  final int totalSixes;
  final int totalWickets;
  final int matchesPlayed;
  final int totalIpAwarded;

  factory TournamentTotalsModel.fromJson(Map<String, dynamic> j) =>
      TournamentTotalsModel(
        totalRuns: (j['totalRuns'] as int?) ?? 0,
        totalFours: (j['totalFours'] as int?) ?? 0,
        totalSixes: (j['totalSixes'] as int?) ?? 0,
        totalWickets: (j['totalWickets'] as int?) ?? 0,
        matchesPlayed: (j['matchesPlayed'] as int?) ?? 0,
        totalIpAwarded: (j['totalIpAwarded'] as int?) ?? 0,
      );
}

// ── Utilities ─────────────────────────────────────────────────────────────────

String formatTournamentDate(DateTime date) =>
    DateFormat('d MMM yyyy').format(date);

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse('$v');
}

String formatMatchOvers(double overs) {
  final full = overs.floor();
  final balls = ((overs - full) * 10).round();
  if (balls == 0) return '$full';
  return '$full.$balls';
}
