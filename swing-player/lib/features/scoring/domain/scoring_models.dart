// Models for ball-by-ball cricket scoring

String _string(dynamic value) {
  if (value == null) return '';
  if (value is String) return value.trim();
  return '$value';
}

String? _stringOrNull(dynamic value) {
  final normalized = _string(value);
  return normalized.isEmpty ? null : normalized;
}

List<dynamic> _list(dynamic value) => value is List ? value : const [];

class ScoringMatchPlayer {
  const ScoringMatchPlayer({
    required this.profileId,
    required this.userId,
    required this.name,
    this.avatarUrl,
  });

  final String profileId;
  final String userId;
  final String name;
  final String? avatarUrl;

  bool matchesId(String id) =>
      id.isNotEmpty && (profileId == id || userId == id);

  factory ScoringMatchPlayer.fromJson(Map<String, dynamic> j) =>
      ScoringMatchPlayer(
        profileId: _string(j['profileId'] ?? j['id']),
        userId: _string(j['userId']),
        name: _string(j['name']),
        avatarUrl: _stringOrNull(j['avatarUrl']),
      );
}

class ScoringBall {
  const ScoringBall({
    required this.id,
    required this.batterId,
    this.nonBatterId,
    required this.bowlerId,
    required this.outcome,
    required this.runs,
    required this.extras,
    required this.isWicket,
    required this.overNumber,
    required this.ballNumber,
    this.dismissalType,
    this.dismissedPlayerId,
    this.fielderId,
    this.wagonZone,
    this.tags = const [],
  });

  final String id;
  final String batterId;
  final String? nonBatterId;
  final String bowlerId;
  final String outcome;
  final int runs;
  final int extras;
  final bool isWicket;
  final int overNumber;
  final int ballNumber;
  final String? dismissalType;
  final String? dismissedPlayerId;
  final String? fielderId;
  final String? wagonZone;
  final List<String> tags;

  bool get isLegal => outcome != 'WIDE' && outcome != 'NO_BALL';

  factory ScoringBall.fromJson(Map<String, dynamic> j) => ScoringBall(
        id: _string(j['id']),
        batterId: _string(j['batterId']),
        nonBatterId: _stringOrNull(j['nonBatterId']),
        bowlerId: _string(j['bowlerId']),
        outcome: _stringOrNull(j['outcome']) ?? 'DOT',
        runs: (j['runs'] as num?)?.toInt() ?? 0,
        extras: (j['extras'] as num?)?.toInt() ?? 0,
        isWicket: j['isWicket'] == true,
        overNumber: (j['overNumber'] as num?)?.toInt() ?? 0,
        ballNumber: (j['ballNumber'] as num?)?.toInt() ?? 0,
        dismissalType: _stringOrNull(j['dismissalType']),
        dismissedPlayerId: _stringOrNull(j['dismissedPlayerId']),
        fielderId: _stringOrNull(j['fielderId']),
        wagonZone: _stringOrNull(j['wagonZone']),
        tags: _list(j['tags']).map((e) => '$e').toList(),
      );
}

class ScoringInnings {
  const ScoringInnings({
    required this.id,
    required this.inningsNumber,
    required this.battingTeam,
    required this.totalRuns,
    required this.totalWickets,
    required this.totalOvers,
    required this.extras,
    required this.isCompleted,
    required this.balls,
    this.currentStrikerId,
    this.currentNonStrikerId,
    this.currentBowlerId,
    this.isFreeHit = false,
  });

  final String id;
  final int inningsNumber;
  final String battingTeam; // "A" or "B"
  final int totalRuns;
  final int totalWickets;
  final double totalOvers;
  final int extras;
  final bool isCompleted;
  final List<ScoringBall> balls;
  final String? currentStrikerId;
  final String? currentNonStrikerId;
  final String? currentBowlerId;
  final bool isFreeHit;

  String get scoreDisplay =>
      '$totalRuns/$totalWickets (${_fmtOvers(totalOvers)} ov)';

  /// Float-safe formatter: avoids (o - floor) * 10 precision issues.
  static String _fmtOvers(double o) {
    final tenths = (o * 10).round();
    final full = tenths ~/ 10;
    final part = tenths % 10;
    return part == 0 ? '$full' : '$full.$part';
  }

  /// Current over index (0-based), derived from backend's authoritative totalOvers.
  int get overNumber => (totalOvers * 10).round() ~/ 10;

  /// Balls already bowled in the current over (0-5), from totalOvers.
  int get ballInOver => (totalOvers * 10).round() % 10;

  /// All deliveries (incl. wides/no-balls) in the current over.
  List<ScoringBall> get thisOverBalls =>
      balls.where((b) => b.overNumber == overNumber).toList();

  /// Count of legal deliveries — used for bowler stats & innings-over check.
  int get legalCount => balls.where((b) => b.isLegal).length;

  factory ScoringInnings.fromJson(Map<String, dynamic> j) => ScoringInnings(
        id: _string(j['id']),
        inningsNumber: (j['inningsNumber'] as num?)?.toInt() ?? 1,
        battingTeam: _stringOrNull(j['battingTeam']) ?? 'A',
        totalRuns: (j['totalRuns'] as num?)?.toInt() ?? 0,
        totalWickets: (j['totalWickets'] as num?)?.toInt() ?? 0,
        totalOvers: (j['totalOvers'] as num?)?.toDouble() ?? 0.0,
        extras: (j['extras'] as num?)?.toInt() ?? 0,
        isCompleted: j['isCompleted'] == true,
        balls: _list(j['ballEvents'] ?? j['balls'])
            .whereType<Map>()
            .map((e) => ScoringBall.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        currentStrikerId:
            _stringOrNull(j['currentStrikerId'] ?? j['strikerId']),
        currentNonStrikerId:
            _stringOrNull(j['currentNonStrikerId'] ?? j['nonStrikerId']),
        currentBowlerId: _stringOrNull(j['currentBowlerId'] ?? j['bowlerId']),
        isFreeHit: j['isFreeHit'] == true,
      );
}

class ScoringMatch {
  const ScoringMatch({
    required this.id,
    required this.status,
    required this.teamAName,
    required this.teamBName,
    required this.format,
    required this.innings,
    this.customOvers,
    this.tossWonBy,
    this.tossDecision,
    this.winnerId,
    this.winMargin,
    this.matchType,
    this.hasImpactPlayer = false,
    this.teamAPlayerIds = const [],
    this.teamBPlayerIds = const [],
  });

  final String id;
  final String status;
  final String teamAName;
  final String teamBName;
  final String format;
  final List<ScoringInnings> innings;
  final int? customOvers;
  final String? tossWonBy; // "A" | "B"
  final String? tossDecision; // "BAT" | "BOWL"
  final String? winnerId;
  final String? winMargin;
  final String? matchType;
  final bool hasImpactPlayer;
  final List<String> teamAPlayerIds; // playing 11 profile IDs
  final List<String> teamBPlayerIds;

  int get maxOvers {
    if (customOvers != null && customOvers! > 0) return customOvers!;
    switch (format) {
      case 'T10':
        return 10;
      case 'T20':
        return 20;
      case 'ONE_DAY':
        return 50;
      case 'TWO_INNINGS':
        return 90;
      default:
        return 20;
    }
  }

  String teamName(String side) => side == 'A' ? teamAName : teamBName;

  String _otherSide(String side) => side == 'A' ? 'B' : 'A';

  ScoringInnings? get activeInnings =>
      innings.where((i) => !i.isCompleted).firstOrNull;

  ScoringInnings? get completedFirstInnings =>
      innings.where((i) => i.isCompleted && i.inningsNumber == 1).firstOrNull;

  bool get hasToss => tossWonBy != null;
  bool get isComplete => status == 'COMPLETED';
  bool get isLive => status == 'IN_PROGRESS';

  /// Batting team for the active innings ("A" | "B")
  String? get battingTeam {
    final active = activeInnings;
    if (active != null) return active.battingTeam;

    final firstInnings = completedFirstInnings;
    if (firstInnings != null && !isComplete) {
      return _otherSide(firstInnings.battingTeam);
    }

    if (tossWonBy != null && tossDecision != null) {
      final decision = tossDecision!.toUpperCase();
      if (decision == 'BAT') return tossWonBy;
      if (decision == 'BOWL') return _otherSide(tossWonBy!);
    }

    return null;
  }

  /// Bowling team for the active innings
  String? get bowlingTeam =>
      battingTeam == null ? null : _otherSide(battingTeam!);

  factory ScoringMatch.fromJson(Map<String, dynamic> j) {
    final data = j['data'] as Map<String, dynamic>? ?? j;
    return ScoringMatch(
      id: '${data['id'] ?? ''}',
      status: '${data['status'] ?? 'SCHEDULED'}',
      teamAName: '${data['teamAName'] ?? 'Team A'}',
      teamBName: '${data['teamBName'] ?? 'Team B'}',
      format: '${data['format'] ?? 'T20'}',
      customOvers: (data['customOvers'] as num?)?.toInt(),
      tossWonBy: data['tossWonBy'] as String?,
      tossDecision: data['tossDecision'] as String?,
      winnerId: data['winnerId'] as String?,
      winMargin: data['winMargin'] as String?,
      matchType: data['matchType'] as String?,
      hasImpactPlayer: data['hasImpactPlayer'] == true,
      teamAPlayerIds:
          (data['teamAPlayerIds'] as List?)?.map((e) => '$e').toList() ?? [],
      teamBPlayerIds:
          (data['teamBPlayerIds'] as List?)?.map((e) => '$e').toList() ?? [],
      innings: (data['innings'] as List?)
              ?.map((e) =>
                  ScoringInnings.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }
}

class ScoringPlayersData {
  const ScoringPlayersData({
    required this.teamA,
    required this.teamB,
    this.teamACaptainId,
    this.teamAViceCaptainId,
    this.teamAWicketKeeperId,
    this.teamBCaptainId,
    this.teamBViceCaptainId,
    this.teamBWicketKeeperId,
  });

  final List<ScoringMatchPlayer> teamA;
  final List<ScoringMatchPlayer> teamB;
  final String? teamACaptainId;
  final String? teamAViceCaptainId;
  final String? teamAWicketKeeperId;
  final String? teamBCaptainId;
  final String? teamBViceCaptainId;
  final String? teamBWicketKeeperId;

  List<ScoringMatchPlayer> forSide(String side) => side == 'A' ? teamA : teamB;

  /// Players NOT in the playing 11 (bench) for impact player substitution
  List<ScoringMatchPlayer> benchForSide(String side, List<String> playingIds) {
    final all = forSide(side);
    return all.where((p) => !playingIds.contains(p.profileId)).toList();
  }

  ScoringMatchPlayer? findById(String profileId) {
    for (final p in [...teamA, ...teamB]) {
      if (p.matchesId(profileId)) return p;
    }
    return null;
  }

  String? normalizeId(String? id) {
    final raw = _stringOrNull(id);
    if (raw == null) return null;
    return findById(raw)?.profileId ?? raw;
  }

  factory ScoringPlayersData.fromJson(Map<String, dynamic> j) {
    final data = j['data'] as Map<String, dynamic>? ?? j;

    // Backend returns {teamA: {name, players: [...]}, teamB: {name, players: [...]}}
    // Handle both flat list (old) and nested object (current) formats
    List<ScoringMatchPlayer> parseSide(dynamic raw) {
      List? list;
      if (raw is List) {
        list = raw;
      } else if (raw is Map) {
        list = raw['players'] as List?;
      }
      return list
              ?.map((e) => ScoringMatchPlayer.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [];
    }

    String? strOrNull(dynamic v) => v is String ? v : null;

    final a = data['teamA'];
    final b = data['teamB'];

    return ScoringPlayersData(
      teamA: parseSide(a),
      teamB: parseSide(b),
      teamACaptainId: a is Map ? strOrNull(a['captainId']) : null,
      teamAViceCaptainId: a is Map ? strOrNull(a['viceCaptainId']) : null,
      teamAWicketKeeperId: a is Map ? strOrNull(a['wicketKeeperId']) : null,
      teamBCaptainId: b is Map ? strOrNull(b['captainId']) : null,
      teamBViceCaptainId: b is Map ? strOrNull(b['viceCaptainId']) : null,
      teamBWicketKeeperId: b is Map ? strOrNull(b['wicketKeeperId']) : null,
    );
  }
}
