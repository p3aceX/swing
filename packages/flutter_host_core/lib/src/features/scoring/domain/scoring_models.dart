class ScoringMatch {
  const ScoringMatch({
    this.id = '',
    this.status = '',
    this.teamAName = 'Team A',
    this.teamBName = 'Team B',
    this.format = 'T20',
    this.innings = const [],
    this.customOvers,
    this.tossWonBy,
    this.tossDecision,
    this.winnerId,
    this.winMargin,
    this.matchType,
    this.hasImpactPlayer = false,
    this.teamAPlayerIds = const [],
    this.teamBPlayerIds = const [],
    this.scorerId,
    this.venueName,
    this.venueCity,
    this.scheduledAt,
  });

  final String id;
  final String status;
  final String teamAName;
  final String teamBName;
  final String format;
  final List<ScoringInnings> innings;
  final int? customOvers;
  final String? tossWonBy;
  final String? tossDecision;
  final String? winnerId;
  final String? winMargin;
  final String? matchType;
  final bool hasImpactPlayer;
  final List<String> teamAPlayerIds;
  final List<String> teamBPlayerIds;
  final String? scorerId;
  final String? venueName;
  final String? venueCity;
  final DateTime? scheduledAt;

  factory ScoringMatch.fromJson(Map<String, dynamic> json) {
    final payload = _unwrapMap(json);
    final rawInnings = (_list(payload['innings'])
          ..sort((a, b) => _asInt(_map(a)['inningsNumber']).compareTo(_asInt(_map(b)['inningsNumber']))))
        .whereType<Map>()
        .map((entry) => ScoringInnings.fromJson(Map<String, dynamic>.from(entry)))
        .toList();

    DateTime? parsedAt;
    final rawAt = payload['scheduledAt'];
    if (rawAt != null) {
      try { parsedAt = DateTime.parse('$rawAt').toLocal(); } catch (_) {}
    }

    return ScoringMatch(
      id: _asString(payload['id']),
      status: _asString(payload['status']),
      teamAName: _asString(payload['teamAName'], fallback: 'Team A'),
      teamBName: _asString(payload['teamBName'], fallback: 'Team B'),
      format: _asString(payload['format'], fallback: 'T20'),
      innings: rawInnings,
      customOvers: payload['customOvers'] is num ? (payload['customOvers'] as num).toInt() : null,
      tossWonBy: _nullableString(payload['tossWonBy']),
      tossDecision: _nullableString(payload['tossDecision']),
      winnerId: _nullableString(payload['winnerId']),
      winMargin: _nullableString(payload['winMargin']),
      matchType: _nullableString(payload['matchType']),
      hasImpactPlayer: payload['hasImpactPlayer'] == true,
      teamAPlayerIds: _list(payload['teamAPlayerIds']).map((e) => '$e').where((e) => e.isNotEmpty).toList(),
      teamBPlayerIds: _list(payload['teamBPlayerIds']).map((e) => '$e').where((e) => e.isNotEmpty).toList(),
      scorerId: _nullableString(payload['scorerId']),
      venueName: _nullableString(payload['venueName']),
      venueCity: _nullableString(payload['venueCity']),
      scheduledAt: parsedAt,
    );
  }

  ScoringInnings? get activeInnings {
    for (final innings in this.innings) {
      if (!innings.isCompleted) return innings;
    }
    return this.innings.isNotEmpty ? this.innings.last : null;
  }

  bool get isComplete {
    return status == 'COMPLETED' ||
        status == 'ABANDONED' ||
        status == 'CANCELLED' ||
        winnerId != null;
  }

  bool get isMultiInnings => format == 'TEST' || format == 'TWO_INNINGS';

  int get maxOvers {
    if (customOvers != null && customOvers! > 0) return customOvers!;
    switch (format) {
      case 'T10':
        return 10;
      case 'ONE_DAY':
        return 50;
      case 'BOX_CRICKET':
        return 6;
      case 'TEST':
      case 'TWO_INNINGS':
        return 90;
      default:
        return 20;
    }
  }

  ScoringInnings? get completedFirstInnings {
    for (final innings in this.innings) {
      if (innings.inningsNumber == 1 && innings.isCompleted) return innings;
    }
    return null;
  }

  String teamName(String side) => side == 'A' ? teamAName : teamBName;

  String? get battingTeam => activeInnings?.battingTeam;

  String? get bowlingTeam {
    final side = battingTeam;
    if (side == null || side.isEmpty) return null;
    return side == 'A' ? 'B' : 'A';
  }
}

class ScoringInnings {
  const ScoringInnings({
    this.id = '',
    this.inningsNumber = 1,
    this.battingTeam = 'A',
    this.currentStrikerId,
    this.currentNonStrikerId,
    this.currentBowlerId,
    this.overNumber = 0,
    this.ballInOver = 0,
    this.legalCount = 0,
    this.totalRuns = 0,
    this.totalWickets = 0,
    this.isCompleted = false,
    this.isFreeHit = false,
    this.balls = const [],
  });

  final String id;
  final int inningsNumber;
  final String battingTeam;
  final String? currentStrikerId;
  final String? currentNonStrikerId;
  final String? currentBowlerId;
  final int overNumber;
  final int ballInOver;
  final int legalCount;
  final int totalRuns;
  final int totalWickets;
  final bool isCompleted;
  final bool isFreeHit;
  final List<ScoringBall> balls;

  factory ScoringInnings.fromJson(Map<String, dynamic> json) {
    final payload = _unwrapMap(json);
    final rawBalls = _list(payload['ballEvents'] ?? payload['balls']);

    // Server sends totalOvers in cricket notation "completedOvers.ballsInOver"
    // e.g. "1.3" = 1 completed over, 3 balls into the next.
    // Fall back to explicit fields if the server ever adds them.
    int derivedOverNumber = _asInt(payload['overNumber']);
    int derivedBallInOver = _asInt(payload['ballInOver']);
    int derivedLegalCount = _asInt(payload['legalCount']);
    if (derivedOverNumber == 0 && derivedBallInOver == 0 && derivedLegalCount == 0) {
      final rawTotalOvers = payload['totalOvers'];
      if (rawTotalOvers != null) {
        if (rawTotalOvers is int) {
          // Integer = exactly N completed overs, 0 balls in new over
          // e.g. 1 → overNumber=1, ballInOver=0
          derivedOverNumber = rawTotalOvers;
          derivedBallInOver = 0;
        } else if (rawTotalOvers is double) {
          // Double = completed.balls cricket notation
          // e.g. 0.5 → overNumber=0, ballInOver=5
          derivedOverNumber = rawTotalOvers.floor();
          derivedBallInOver = ((rawTotalOvers - rawTotalOvers.floor()) * 10).round();
        } else {
          // String fallback: split on '.'
          final s = '$rawTotalOvers';
          final dotIdx = s.indexOf('.');
          if (dotIdx >= 0) {
            derivedOverNumber = int.tryParse(s.substring(0, dotIdx)) ?? 0;
            derivedBallInOver = int.tryParse(s.substring(dotIdx + 1)) ?? 0;
          } else {
            derivedOverNumber = int.tryParse(s) ?? 0;
            derivedBallInOver = 0;
          }
        }
        derivedLegalCount = derivedOverNumber * 6 + derivedBallInOver;
      }
    }

    return ScoringInnings(
      id: _asString(payload['id']),
      inningsNumber: _asInt(payload['inningsNumber'], fallback: 1),
      battingTeam: _asString(payload['battingTeam'], fallback: 'A'),
      currentStrikerId: _nullableString(payload['currentStrikerId']),
      currentNonStrikerId: _nullableString(payload['currentNonStrikerId']),
      currentBowlerId: _nullableString(payload['currentBowlerId']),
      overNumber: derivedOverNumber,
      ballInOver: derivedBallInOver,
      legalCount: derivedLegalCount,
      totalRuns: _asInt(payload['totalRuns']),
      totalWickets: _asInt(payload['totalWickets']),
      isCompleted: payload['isCompleted'] == true,
      isFreeHit: payload['isFreeHit'] == true,
      balls: rawBalls
          .whereType<Map>()
          .map((e) => ScoringBall.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  String get scoreDisplay => '$totalRuns/$totalWickets';
}

class ScoringBall {
  const ScoringBall({
    this.id = '',
    this.batterId,
    this.bowlerId,
    this.outcome = 'DOT',
    this.runs = 0,
    this.extras = 0,
    this.isWicket = false,
    this.isOverthrow = false,
    this.overthrowRuns = 0,
    this.dismissalType,
    this.dismissedPlayerId,
    this.nonBatterId,
  });

  final String id;
  final String? batterId;
  final String? bowlerId;
  final String outcome;
  final int runs;
  final int extras;
  final bool isWicket;
  final bool isOverthrow;
  final int overthrowRuns;
  final String? dismissalType;
  final String? dismissedPlayerId;
  final String? nonBatterId;

  factory ScoringBall.fromJson(Map<String, dynamic> json) {
    final payload = _unwrapMap(json);
    return ScoringBall(
      id: _asString(payload['id']),
      batterId: _nullableString(payload['batterId']),
      bowlerId: _nullableString(payload['bowlerId']),
      outcome: _asString(payload['outcome'], fallback: 'DOT'),
      runs: _asInt(payload['runs']),
      extras: _asInt(payload['extras']),
      isWicket: payload['isWicket'] == true,
      isOverthrow: payload['isOverthrow'] == true,
      overthrowRuns: _asInt(payload['overthrowRuns']),
      dismissalType: _nullableString(payload['dismissalType']),
      dismissedPlayerId: _nullableString(payload['dismissedPlayerId']),
      nonBatterId: _nullableString(payload['nonBatterId']),
    );
  }
}

class ScoringMatchPlayer {
  const ScoringMatchPlayer({
    required this.profileId,
    required this.name,
    this.userId,
    this.avatarUrl,
    this.phone,
  });

  final String profileId;
  final String name;
  final String? userId;
  final String? avatarUrl;
  final String? phone;

  factory ScoringMatchPlayer.fromJson(Map<String, dynamic> json) {
    final user = _map(json['user']);
    return ScoringMatchPlayer(
      profileId: _asString(
        json['profileId'],
        fallback: _asString(json['id']),
      ),
      name: _asString(
        json['name'],
        fallback: _asString(user['name'], fallback: 'Player'),
      ),
      userId: _nullableString(json['userId']) ?? _nullableString(user['id']),
      avatarUrl: _nullableString(json['avatarUrl']) ?? _nullableString(user['avatarUrl']),
      phone: _nullableString(json['phone']) ?? _nullableString(user['phone']),
    );
  }

  bool matchesId(String raw) => raw.isNotEmpty && (profileId == raw || userId == raw);
}

class ScoringPlayersData {
  const ScoringPlayersData({
    this.teamA = const [],
    this.teamB = const [],
    this.teamACaptainId,
    this.teamBCaptainId,
    this.teamAViceCaptainId,
    this.teamBViceCaptainId,
    this.teamAWicketKeeperId,
    this.teamBWicketKeeperId,
  });

  final List<ScoringMatchPlayer> teamA;
  final List<ScoringMatchPlayer> teamB;
  final String? teamACaptainId;
  final String? teamBCaptainId;
  final String? teamAViceCaptainId;
  final String? teamBViceCaptainId;
  final String? teamAWicketKeeperId;
  final String? teamBWicketKeeperId;

  List<ScoringMatchPlayer> get players => [...teamA, ...teamB];

  factory ScoringPlayersData.fromJson(Map<String, dynamic> json) {
    final payload = _unwrapMap(json);
    final teamAMap = _map(payload['teamA']);
    final teamBMap = _map(payload['teamB']);
    List<ScoringMatchPlayer> parsePlayers(dynamic rows) {
      return _list(rows)
          .whereType<Map>()
          .map((e) => ScoringMatchPlayer.fromJson(Map<String, dynamic>.from(e)))
          .where((player) => player.profileId.isNotEmpty)
          .toList();
    }

    return ScoringPlayersData(
      teamA: parsePlayers(teamAMap['players']),
      teamB: parsePlayers(teamBMap['players']),
      teamACaptainId: _nullableString(teamAMap['captainId']),
      teamBCaptainId: _nullableString(teamBMap['captainId']),
      teamAViceCaptainId: _nullableString(teamAMap['viceCaptainId']),
      teamBViceCaptainId: _nullableString(teamBMap['viceCaptainId']),
      teamAWicketKeeperId: _nullableString(teamAMap['wicketKeeperId']),
      teamBWicketKeeperId: _nullableString(teamBMap['wicketKeeperId']),
    );
  }

  String normalizeId(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return '';
    for (final player in players) {
      if (player.profileId == value || player.userId == value) {
        return player.profileId;
      }
    }
    return value;
  }

  ScoringMatchPlayer? findById(String id) {
    final target = normalizeId(id);
    for (final player in players) {
      if (player.profileId == target || player.userId == id) return player;
    }
    return null;
  }

  List<ScoringMatchPlayer> forSide(String side) => side == 'A' ? teamA : teamB;
}

Map<String, dynamic> _unwrapMap(Map<String, dynamic> value) {
  final inner = value['data'];
  if (inner is Map<String, dynamic>) return inner;
  if (inner is Map) return Map<String, dynamic>.from(inner);
  return value;
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<dynamic> _list(dynamic value) => value is List ? value : const [];

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = '$value'.trim();
  return text.isEmpty ? fallback : text;
}

String? _nullableString(dynamic value) {
  final text = _asString(value);
  return text.isEmpty ? null : text;
}

int _asInt(dynamic value, {int fallback = 0}) => (value as num?)?.toInt() ?? fallback;
