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

  factory ScoringMatch.fromJson(Map<String, dynamic> json) {
    final payload = _unwrapMap(json);
    final rawInnings = (_list(payload['innings'])
          ..sort((a, b) => _asInt(_map(a)['inningsNumber']).compareTo(_asInt(_map(b)['inningsNumber']))))
        .whereType<Map>()
        .map((entry) => ScoringInnings.fromJson(Map<String, dynamic>.from(entry)))
        .toList();

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
    final rawBalls = _list(payload['ballEvents'].isNotEmpty ? payload['ballEvents'] : payload['balls']);
    return ScoringInnings(
      id: _asString(payload['id']),
      inningsNumber: _asInt(payload['inningsNumber'], fallback: 1),
      battingTeam: _asString(payload['battingTeam'], fallback: 'A'),
      currentStrikerId: _nullableString(payload['currentStrikerId']),
      currentNonStrikerId: _nullableString(payload['currentNonStrikerId']),
      currentBowlerId: _nullableString(payload['currentBowlerId']),
      overNumber: _asInt(payload['overNumber']),
      ballInOver: _asInt(payload['ballInOver']),
      legalCount: _asInt(payload['legalCount']),
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
    this.dismissalType,
  });

  final String id;
  final String? batterId;
  final String? bowlerId;
  final String outcome;
  final int runs;
  final int extras;
  final bool isWicket;
  final String? dismissalType;

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
      dismissalType: _nullableString(payload['dismissalType']),
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
