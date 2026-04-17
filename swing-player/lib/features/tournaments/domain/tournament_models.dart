import 'dart:convert';

import 'package:intl/intl.dart';

// ── List card model ───────────────────────────────────────────────────────────

class PlayerTournament {
  const PlayerTournament({
    required this.id,
    required this.name,
    required this.status,
    required this.format,
    required this.tournamentFormat,
    required this.startDate,
    required this.teamCount,
    required this.maxTeams,
    required this.isHost,
    required this.isParticipating,
    this.slug,
    this.city,
    this.venueName,
    this.logoUrl,
    this.entryFee,
    this.endDate,
    this.ballType,
    this.earlyBirdDeadline,
    this.earlyBirdFee,
  });

  final String id;
  final String name;
  final String status;
  final String format;
  final String tournamentFormat;
  final DateTime startDate;
  final DateTime? endDate;
  final int teamCount;
  final int maxTeams;
  final bool isHost;
  final bool isParticipating;
  final String? slug;
  final String? city;
  final String? venueName;
  final String? logoUrl;
  final int? entryFee;
  final String? ballType;
  final DateTime? earlyBirdDeadline;
  final int? earlyBirdFee;

  /// Returns the effective entry fee accounting for early bird pricing.
  int? get effectiveEntryFee {
    if (earlyBirdFee != null &&
        earlyBirdDeadline != null &&
        DateTime.now().isBefore(earlyBirdDeadline!)) {
      return earlyBirdFee;
    }
    return entryFee;
  }

  bool get isEarlyBirdActive =>
      earlyBirdFee != null &&
      earlyBirdDeadline != null &&
      DateTime.now().isBefore(earlyBirdDeadline!);

  PlayerTournament copyWith({
    bool? isHost,
    bool? isParticipating,
  }) {
    return PlayerTournament(
      id: id,
      name: name,
      status: status,
      format: format,
      tournamentFormat: tournamentFormat,
      startDate: startDate,
      teamCount: teamCount,
      maxTeams: maxTeams,
      isHost: isHost ?? this.isHost,
      isParticipating: isParticipating ?? this.isParticipating,
      slug: slug,
      city: city,
      venueName: venueName,
      logoUrl: logoUrl,
      entryFee: entryFee,
      endDate: endDate,
      ballType: ballType,
      earlyBirdDeadline: earlyBirdDeadline,
      earlyBirdFee: earlyBirdFee,
    );
  }

  factory PlayerTournament.fromJson(
    Map<String, dynamic> j, {
    Set<String> myTeamIds = const {},
    Set<String> myTeamNames = const {},
    bool forceHosted = false,
    bool forceParticipating = false,
  }) {
    final count = j['_count'];
    final teamCount = count is Map
        ? (count['teams'] as int? ?? 0)
        : (j['teamCount'] as int? ?? 0);
    final isHost = forceHosted || j['isHost'] == true;
    final explicitParticipating = forceParticipating ||
        j['isParticipating'] == true ||
        j['isParticipant'] == true ||
        j['isPlaying'] == true ||
        j['isRegistered'] == true ||
        j['joined'] == true ||
        j['isJoined'] == true;
    final hasMyTeam = _hasMyTeam(
      j,
      myTeamIds: myTeamIds,
      myTeamNames: myTeamNames,
    );

    return PlayerTournament(
      id: '${j['id'] ?? j['_id'] ?? j['tournamentId'] ?? ''}',
      name: '${j['name'] ?? 'Tournament'}',
      status: '${j['status'] ?? 'UPCOMING'}',
      format: '${j['format'] ?? 'T20'}',
      tournamentFormat: '${j['tournamentFormat'] ?? 'LEAGUE'}',
      startDate: DateTime.tryParse('${j['startDate'] ?? ''}') ?? DateTime.now(),
      endDate:
          j['endDate'] != null ? DateTime.tryParse('${j['endDate']}') : null,
      teamCount: teamCount,
      maxTeams: (j['maxTeams'] as int?) ?? 8,
      isHost: isHost,
      isParticipating:
          explicitParticipating || hasMyTeam || (forceParticipating && !isHost),
      slug: j['slug'] as String?,
      city: j['city'] as String?,
      venueName: j['venueName'] as String?,
      logoUrl: j['logoUrl'] as String?,
      entryFee: j['entryFee'] as int?,
      ballType: j['ballType'] as String? ?? 'LEATHER',
      earlyBirdDeadline: j['earlyBirdDeadline'] != null
          ? DateTime.tryParse('${j['earlyBirdDeadline']}')
          : null,
      earlyBirdFee: j['earlyBirdFee'] as int?,
    );
  }

  static bool _hasMyTeam(
    Map<String, dynamic> raw, {
    required Set<String> myTeamIds,
    required Set<String> myTeamNames,
  }) {
    if (myTeamIds.isEmpty && myTeamNames.isEmpty) return false;

    // Object / array candidates that contain full or partial team data.
    final candidates = <dynamic>[
      raw['teams'],
      raw['participantTeams'],
      raw['participatingTeams'],
      raw['registeredTeams'],
      raw['joinedTeams'],
      raw['entries'],
      raw['registrations'],
      raw['participants'],
      raw['myTeams'],
      raw['team'],
      raw['myTeam'],
    ];

    for (final candidate in candidates) {
      final matched = _matchesCandidateTeam(
        candidate,
        myTeamIds: myTeamIds,
        myTeamNames: myTeamNames,
      );
      if (matched) return true;
    }

    // Some APIs return flat arrays of team IDs for efficiency.
    final flatIdArrays = <dynamic>[
      raw['teamIds'],
      raw['participantTeamIds'],
      raw['registeredTeamIds'],
    ];
    for (final arr in flatIdArrays) {
      if (arr is List) {
        for (final id in arr) {
          if (myTeamIds.contains(_normalize('$id'))) return true;
        }
      }
    }

    return false;
  }

  static bool _matchesCandidateTeam(
    dynamic candidate, {
    required Set<String> myTeamIds,
    required Set<String> myTeamNames,
  }) {
    if (candidate is List) {
      for (final item in candidate) {
        if (_matchesCandidateTeam(
          item,
          myTeamIds: myTeamIds,
          myTeamNames: myTeamNames,
        )) {
          return true;
        }
      }
      return false;
    }

    if (candidate is Map) {
      final map = candidate.cast<dynamic, dynamic>();
      if (map['isMine'] == true ||
          map['isMyTeam'] == true ||
          map['isParticipant'] == true ||
          map['isPlaying'] == true) {
        return true;
      }

      final ids = <String>{
        _normalize('${map['id'] ?? ''}'),
        _normalize('${map['teamId'] ?? ''}'),
        _normalize('${map['team_id'] ?? ''}'),
      }..remove('');

      if (ids.any(myTeamIds.contains)) return true;

      final nestedTeam = map['team'];
      if (nestedTeam is Map &&
          _matchesCandidateTeam(
            nestedTeam,
            myTeamIds: myTeamIds,
            myTeamNames: myTeamNames,
          )) {
        return true;
      }

      final names = <String>{
        _normalize('${map['name'] ?? ''}'),
        _normalize('${map['teamName'] ?? ''}'),
        _normalize('${map['team_name'] ?? ''}'),
        _normalize('${map['shortName'] ?? ''}'),
      }..remove('');

      if (names.any(myTeamNames.contains)) return true;
    }

    return false;
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}

// ── Full detail model ─────────────────────────────────────────────────────────

class TournamentDetail {
  const TournamentDetail({
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
  final List<TournamentGroup> groups;
  final List<TournamentStanding> standings;
  final List<TournamentHighlight> highlights;

  bool get isEarlyBirdActive =>
      earlyBirdFee != null &&
      earlyBirdDeadline != null &&
      DateTime.now().isBefore(earlyBirdDeadline!);

  int? get effectiveEntryFee {
    if (isEarlyBirdActive) return earlyBirdFee;
    return entryFee;
  }

  /// Organiser display name: custom → academy → createdBy → Swing Official
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

  factory TournamentDetail.fromJson(Map<String, dynamic> j) {
    final List teamsJson = j['teams'] is List ? j['teams'] as List : [];
    final List groupsJson = j['groups'] is List ? j['groups'] as List : [];
    final List standingsJson =
        j['standings'] is List ? j['standings'] as List : [];

    // highlights may arrive as a parsed List or a raw JSON string
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

    return TournamentDetail(
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
          .map(TournamentGroup.fromJson)
          .toList(),
      standings: standingsJson
          .whereType<Map<String, dynamic>>()
          .map(TournamentStanding.fromJson)
          .toList(),
      highlights: highlightsJson
          .whereType<Map<String, dynamic>>()
          .map(TournamentHighlight.fromJson)
          .toList(),
    );
  }
}

// ── Highlight / video ─────────────────────────────────────────────────────────

class TournamentHighlight {
  const TournamentHighlight({required this.title, required this.youtubeUrl});

  final String title;
  final String youtubeUrl;

  String? get videoId {
    final uri = Uri.tryParse(youtubeUrl);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.firstOrNull;
    }
    return uri.queryParameters['v'];
  }

  String? get thumbnailUrl {
    final id = videoId;
    return id != null ? 'https://img.youtube.com/vi/$id/hqdefault.jpg' : null;
  }

  factory TournamentHighlight.fromJson(Map<String, dynamic> j) =>
      TournamentHighlight(
        title: '${j['title'] ?? j['name'] ?? 'Highlight'}',
        youtubeUrl: '${j['youtubeUrl'] ?? j['url'] ?? ''}',
      );
}

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

class TournamentGroup {
  const TournamentGroup(
      {required this.id, required this.name, required this.teams});
  final String id;
  final String name;
  final List<TournamentTeamEntry> teams;

  factory TournamentGroup.fromJson(Map<String, dynamic> j) {
    final List teamsJson = j['teams'] is List ? j['teams'] as List : [];
    return TournamentGroup(
      id: '${j['id'] ?? ''}',
      name: '${j['name'] ?? 'Group'}',
      teams: teamsJson
          .whereType<Map<String, dynamic>>()
          .map(TournamentTeamEntry.fromJson)
          .toList(),
    );
  }
}

class TournamentStanding {
  const TournamentStanding({
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

  factory TournamentStanding.fromJson(Map<String, dynamic> j) =>
      TournamentStanding(
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

// ── Tournament Matches ────────────────────────────────────────────────────────

class TournamentMatch {
  const TournamentMatch({
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
  });
  final String id;
  final String teamAName;
  final String teamBName;
  final String status;
  final List<TournamentMatchInnings> innings;
  final DateTime? scheduledAt;
  final int? round;
  final String? groupName;
  final String? result;
  final String? format;

  factory TournamentMatch.fromJson(Map<String, dynamic> j) {
    final List inningsJson = j['innings'] is List ? j['innings'] as List : [];
    return TournamentMatch(
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
      round: _toInt(j['round']),
      groupName: j['groupName'] != null ? '${j['groupName']}' : null,
      result: j['result'] != null ? '${j['result']}' : null,
      format: j['format'] != null ? '${j['format']}' : null,
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

// ── Leaderboard models ────────────────────────────────────────────────────────

class TournamentLeaderboard {
  const TournamentLeaderboard({
    required this.topBatsmen,
    required this.topBowlers,
    required this.topFielders,
    required this.tournamentTotals,
    this.playerOfTournament,
  });

  final List<LeaderboardPlayer> topBatsmen;
  final List<LeaderboardPlayer> topBowlers;
  final List<LeaderboardPlayer> topFielders;
  final TournamentTotals tournamentTotals;
  final LeaderboardPlayer? playerOfTournament;

  factory TournamentLeaderboard.fromJson(Map<String, dynamic> j) {
    List<LeaderboardPlayer> parseList(dynamic raw) => raw is List
        ? raw
            .whereType<Map<String, dynamic>>()
            .map(LeaderboardPlayer.fromJson)
            .toList()
        : [];
    return TournamentLeaderboard(
      topBatsmen: parseList(j['topBatsmen']),
      topBowlers: parseList(j['topBowlers']),
      topFielders: parseList(j['topFielders']),
      playerOfTournament: j['playerOfTournament'] != null
          ? LeaderboardPlayer.fromJson(
              j['playerOfTournament'] as Map<String, dynamic>)
          : null,
      tournamentTotals: j['tournamentTotals'] != null
          ? TournamentTotals.fromJson(
              j['tournamentTotals'] as Map<String, dynamic>)
          : const TournamentTotals(),
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

class LeaderboardPlayer {
  const LeaderboardPlayer({
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

  factory LeaderboardPlayer.fromJson(Map<String, dynamic> j) =>
      LeaderboardPlayer(
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

class TournamentTotals {
  const TournamentTotals({
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

  factory TournamentTotals.fromJson(Map<String, dynamic> j) => TournamentTotals(
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

String formatOvers(double overs) {
  final full = overs.floor();
  final balls = ((overs - full) * 10).round();
  if (balls == 0) return '$full';
  return '$full.$balls';
}
