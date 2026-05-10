// Typed models for the swing-backend overlay feed.
//
// Two endpoints feed these:
//   GET /live/matches/:id/bootstrap  → OverlayBootstrap (one-time, on overlay load)
//   GET /live/matches/:id/tick (SSE) → OverlayTick (live updates ~1Hz)
//
// JSON shapes mirror swing-backend/apps/api/src/modules/live/overlay-feed.routes.ts.

class OverlayBootstrap {
  final MatchInfo match;
  final TournamentInfo? tournament;
  final TossState toss;
  final TeamInfo teamA;
  final TeamInfo teamB;
  final DateTime generatedAt;

  OverlayBootstrap({
    required this.match,
    required this.tournament,
    required this.toss,
    required this.teamA,
    required this.teamB,
    required this.generatedAt,
  });

  factory OverlayBootstrap.fromJson(Map<String, dynamic> j) => OverlayBootstrap(
        match: MatchInfo.fromJson(j['match'] as Map<String, dynamic>),
        tournament: j['tournament'] == null
            ? null
            : TournamentInfo.fromJson(j['tournament'] as Map<String, dynamic>),
        toss: TossState.fromJson(j['toss'] as Map<String, dynamic>),
        teamA: TeamInfo.fromJson(j['teamA'] as Map<String, dynamic>),
        teamB: TeamInfo.fromJson(j['teamB'] as Map<String, dynamic>),
        generatedAt: DateTime.tryParse(j['generatedAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class MatchInfo {
  final String id;
  final String? type;
  final String? format;
  final String? status;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? venue;
  final String? ballType;
  final int? customOvers;
  final String? winnerId;
  final String? winMargin;

  MatchInfo({
    required this.id,
    this.type,
    this.format,
    this.status,
    this.scheduledAt,
    this.startedAt,
    this.completedAt,
    this.venue,
    this.ballType,
    this.customOvers,
    this.winnerId,
    this.winMargin,
  });

  factory MatchInfo.fromJson(Map<String, dynamic> j) => MatchInfo(
        id: j['id'] as String,
        type: j['type'] as String?,
        format: j['format'] as String?,
        status: j['status'] as String?,
        scheduledAt: _date(j['scheduledAt']),
        startedAt: _date(j['startedAt']),
        completedAt: _date(j['completedAt']),
        venue: j['venue'] as String?,
        ballType: j['ballType'] as String?,
        customOvers: (j['customOvers'] as num?)?.toInt(),
        winnerId: j['winnerId'] as String?,
        winMargin: j['winMargin'] as String?,
      );
}

class TournamentInfo {
  final String id;
  final String name;
  final String? logoUrl;
  final String? format;

  TournamentInfo({required this.id, required this.name, this.logoUrl, this.format});

  factory TournamentInfo.fromJson(Map<String, dynamic> j) => TournamentInfo(
        id: j['id'] as String,
        name: j['name'] as String,
        logoUrl: j['logoUrl'] as String?,
        format: j['format'] as String?,
      );
}

class TossState {
  final bool done;
  final String? wonBy; // 'A' | 'B'
  final String? decision; // 'BAT' | 'BOWL'
  final DateTime? doneAt;

  TossState({required this.done, this.wonBy, this.decision, this.doneAt});

  factory TossState.fromJson(Map<String, dynamic> j) => TossState(
        done: j['done'] as bool? ?? false,
        wonBy: j['wonBy'] as String?,
        decision: j['decision'] as String?,
        doneAt: _date(j['doneAt']),
      );
}

class TeamInfo {
  final String? id;
  final String name;
  final String? shortName;
  final String? logoUrl;
  final String? city;
  final String? motto;
  final String? homeGround;
  final int? foundedYear;
  final num? powerScore;
  final num? credibilityScore;
  final String? captainId;
  final String? viceCaptainId;
  final String? wicketKeeperId;
  final List<PlayerInfo> playingXi;

  TeamInfo({
    this.id,
    required this.name,
    this.shortName,
    this.logoUrl,
    this.city,
    this.motto,
    this.homeGround,
    this.foundedYear,
    this.powerScore,
    this.credibilityScore,
    this.captainId,
    this.viceCaptainId,
    this.wicketKeeperId,
    required this.playingXi,
  });

  factory TeamInfo.fromJson(Map<String, dynamic> j) => TeamInfo(
        id: j['id'] as String?,
        name: j['name'] as String,
        shortName: j['shortName'] as String?,
        logoUrl: j['logoUrl'] as String?,
        city: j['city'] as String?,
        motto: j['motto'] as String?,
        homeGround: j['homeGround'] as String?,
        foundedYear: (j['foundedYear'] as num?)?.toInt(),
        powerScore: j['powerScore'] as num?,
        credibilityScore: j['credibilityScore'] as num?,
        captainId: j['captainId'] as String?,
        viceCaptainId: j['viceCaptainId'] as String?,
        wicketKeeperId: j['wicketKeeperId'] as String?,
        playingXi: ((j['playingXi'] as List?) ?? const [])
            .map((p) => PlayerInfo.fromJson(p as Map<String, dynamic>))
            .toList(),
      );
}

class PlayerInfo {
  final String id;
  final String teamSide; // 'A' | 'B'
  final String name;
  final String? username;
  final String? photoUrl;
  final int? jerseyNumber;
  final String? role;
  final String? battingStyle;
  final String? bowlingStyle;
  final bool isCaptain;
  final bool isViceCaptain;
  final bool isWicketKeeper;
  final PlayerCareer? career;
  final SwingScores? swing;
  final CompetitiveRank? rank;

  PlayerInfo({
    required this.id,
    required this.teamSide,
    required this.name,
    this.username,
    this.photoUrl,
    this.jerseyNumber,
    this.role,
    this.battingStyle,
    this.bowlingStyle,
    required this.isCaptain,
    required this.isViceCaptain,
    required this.isWicketKeeper,
    this.career,
    this.swing,
    this.rank,
  });

  factory PlayerInfo.fromJson(Map<String, dynamic> j) => PlayerInfo(
        id: j['id'] as String,
        teamSide: j['teamSide'] as String? ?? 'A',
        name: j['name'] as String? ?? '',
        username: j['username'] as String?,
        photoUrl: j['photoUrl'] as String?,
        jerseyNumber: (j['jerseyNumber'] as num?)?.toInt(),
        role: j['role'] as String?,
        battingStyle: j['battingStyle'] as String?,
        bowlingStyle: j['bowlingStyle'] as String?,
        isCaptain: j['isCaptain'] as bool? ?? false,
        isViceCaptain: j['isViceCaptain'] as bool? ?? false,
        isWicketKeeper: j['isWicketKeeper'] as bool? ?? false,
        career: j['career'] == null
            ? null
            : PlayerCareer.fromJson(j['career'] as Map<String, dynamic>),
        swing: j['swing'] == null
            ? null
            : SwingScores.fromJson(j['swing'] as Map<String, dynamic>),
        rank: j['rank'] == null
            ? null
            : CompetitiveRank.fromJson(j['rank'] as Map<String, dynamic>),
      );
}

class PlayerCareer {
  final int matchesPlayed;
  final int matchesWon;
  final int runs;
  final int ballsFaced;
  final int highestScore;
  final int fifties;
  final int hundreds;
  final int fours;
  final int sixes;
  final num battingAverage;
  final num strikeRate;
  final int wickets;
  final num oversBowled;
  final String? bestBowling;
  final int fiveWicketHauls;
  final num bowlingAverage;
  final num economyRate;
  final num bowlingStrikeRate;

  PlayerCareer({
    required this.matchesPlayed,
    required this.matchesWon,
    required this.runs,
    required this.ballsFaced,
    required this.highestScore,
    required this.fifties,
    required this.hundreds,
    required this.fours,
    required this.sixes,
    required this.battingAverage,
    required this.strikeRate,
    required this.wickets,
    required this.oversBowled,
    required this.bestBowling,
    required this.fiveWicketHauls,
    required this.bowlingAverage,
    required this.economyRate,
    required this.bowlingStrikeRate,
  });

  factory PlayerCareer.fromJson(Map<String, dynamic> j) => PlayerCareer(
        matchesPlayed: _int(j['matchesPlayed']),
        matchesWon: _int(j['matchesWon']),
        runs: _int(j['runs']),
        ballsFaced: _int(j['ballsFaced']),
        highestScore: _int(j['highestScore']),
        fifties: _int(j['fifties']),
        hundreds: _int(j['hundreds']),
        fours: _int(j['fours']),
        sixes: _int(j['sixes']),
        battingAverage: (j['battingAverage'] as num?) ?? 0,
        strikeRate: (j['strikeRate'] as num?) ?? 0,
        wickets: _int(j['wickets']),
        oversBowled: (j['oversBowled'] as num?) ?? 0,
        bestBowling: j['bestBowling'] as String?,
        fiveWicketHauls: _int(j['fiveWicketHauls']),
        bowlingAverage: (j['bowlingAverage'] as num?) ?? 0,
        economyRate: (j['economyRate'] as num?) ?? 0,
        bowlingStrikeRate: (j['bowlingStrikeRate'] as num?) ?? 0,
      );
}

class SwingScores {
  final num index;
  final num batting;
  final num bowling;
  final num fielding;
  final num fitness;
  final num gameIntelligence;
  final num coachability;

  SwingScores({
    required this.index,
    required this.batting,
    required this.bowling,
    required this.fielding,
    required this.fitness,
    required this.gameIntelligence,
    required this.coachability,
  });

  factory SwingScores.fromJson(Map<String, dynamic> j) => SwingScores(
        index: (j['index'] as num?) ?? 0,
        batting: (j['batting'] as num?) ?? 0,
        bowling: (j['bowling'] as num?) ?? 0,
        fielding: (j['fielding'] as num?) ?? 0,
        fitness: (j['fitness'] as num?) ?? 0,
        gameIntelligence: (j['gameIntelligence'] as num?) ?? 0,
        coachability: (j['coachability'] as num?) ?? 0,
      );
}

class CompetitiveRank {
  final String key; // ROOKIE | … | LEGEND
  final int division;
  final int lifetimeImpactPoints;
  final int rankProgressPoints;
  final int winStreak;
  final int mvpCount;
  final bool hasPremiumPass;

  CompetitiveRank({
    required this.key,
    required this.division,
    required this.lifetimeImpactPoints,
    required this.rankProgressPoints,
    required this.winStreak,
    required this.mvpCount,
    required this.hasPremiumPass,
  });

  factory CompetitiveRank.fromJson(Map<String, dynamic> j) => CompetitiveRank(
        key: j['key'] as String? ?? 'ROOKIE',
        division: _int(j['division']),
        lifetimeImpactPoints: _int(j['lifetimeImpactPoints']),
        rankProgressPoints: _int(j['rankProgressPoints']),
        winStreak: _int(j['winStreak']),
        mvpCount: _int(j['mvpCount']),
        hasPremiumPass: j['hasPremiumPass'] as bool? ?? false,
      );
}

// ─── Tick (live) ──────────────────────────────────────────────────────────────

class OverlayTick {
  final String matchId;
  final String? status;
  final TossState toss;
  final List<InningsSummary> inningsSummary;
  final CurrentInnings? current;
  final ChaseState? chase;
  final ResultState? result;
  final List<BallEvent> lastBalls;
  final DateTime serverAt;

  OverlayTick({
    required this.matchId,
    required this.status,
    required this.toss,
    required this.inningsSummary,
    required this.current,
    required this.chase,
    required this.result,
    required this.lastBalls,
    required this.serverAt,
  });

  factory OverlayTick.fromJson(Map<String, dynamic> j) => OverlayTick(
        matchId: j['matchId'] as String,
        status: j['status'] as String?,
        toss: TossState.fromJson((j['toss'] as Map<String, dynamic>?) ?? const {}),
        inningsSummary: ((j['inningsSummary'] as List?) ?? const [])
            .map((e) => InningsSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
        current: j['current'] == null
            ? null
            : CurrentInnings.fromJson(j['current'] as Map<String, dynamic>),
        chase: j['chase'] == null
            ? null
            : ChaseState.fromJson(j['chase'] as Map<String, dynamic>),
        result: j['result'] == null
            ? null
            : ResultState.fromJson(j['result'] as Map<String, dynamic>),
        lastBalls: ((j['lastBalls'] as List?) ?? const [])
            .map((e) => BallEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
        serverAt: DateTime.tryParse(j['serverAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class InningsSummary {
  final int inningsNumber;
  final String battingTeam; // 'A' | 'B'
  final int runs;
  final int wickets;
  final num overs;
  final bool isCompleted;
  final bool isDeclared;

  InningsSummary({
    required this.inningsNumber,
    required this.battingTeam,
    required this.runs,
    required this.wickets,
    required this.overs,
    required this.isCompleted,
    required this.isDeclared,
  });

  factory InningsSummary.fromJson(Map<String, dynamic> j) => InningsSummary(
        inningsNumber: _int(j['inningsNumber']),
        battingTeam: j['battingTeam'] as String? ?? 'A',
        runs: _int(j['runs']),
        wickets: _int(j['wickets']),
        overs: (j['overs'] as num?) ?? 0,
        isCompleted: j['isCompleted'] as bool? ?? false,
        isDeclared: j['isDeclared'] as bool? ?? false,
      );
}

class CurrentInnings {
  final int inningsNumber;
  final String battingTeam;
  final int runs;
  final int wickets;
  final num overs;
  final int extras;
  final BatterState? striker;
  final BatterState? nonStriker;
  final BowlerState? bowler;

  CurrentInnings({
    required this.inningsNumber,
    required this.battingTeam,
    required this.runs,
    required this.wickets,
    required this.overs,
    required this.extras,
    this.striker,
    this.nonStriker,
    this.bowler,
  });

  factory CurrentInnings.fromJson(Map<String, dynamic> j) => CurrentInnings(
        inningsNumber: _int(j['inningsNumber']),
        battingTeam: j['battingTeam'] as String? ?? 'A',
        runs: _int(j['runs']),
        wickets: _int(j['wickets']),
        overs: (j['overs'] as num?) ?? 0,
        extras: _int(j['extras']),
        striker: j['striker'] == null
            ? null
            : BatterState.fromJson(j['striker'] as Map<String, dynamic>),
        nonStriker: j['nonStriker'] == null
            ? null
            : BatterState.fromJson(j['nonStriker'] as Map<String, dynamic>),
        bowler: j['bowler'] == null
            ? null
            : BowlerState.fromJson(j['bowler'] as Map<String, dynamic>),
      );
}

class BatterState {
  final String playerId;
  final int runs;
  final int balls;
  final int fours;
  final int sixes;
  final num strikeRate;
  final bool isOut;

  BatterState({
    required this.playerId,
    required this.runs,
    required this.balls,
    required this.fours,
    required this.sixes,
    required this.strikeRate,
    required this.isOut,
  });

  factory BatterState.fromJson(Map<String, dynamic> j) => BatterState(
        playerId: j['playerId'] as String,
        runs: _int(j['runs']),
        balls: _int(j['balls']),
        fours: _int(j['fours']),
        sixes: _int(j['sixes']),
        strikeRate: (j['strikeRate'] as num?) ?? 0,
        isOut: j['isOut'] as bool? ?? false,
      );
}

class BowlerState {
  final String playerId;
  final num oversBowled;
  final int wickets;
  final int runsConceded;
  final num economy;
  final int wides;
  final int noBalls;

  BowlerState({
    required this.playerId,
    required this.oversBowled,
    required this.wickets,
    required this.runsConceded,
    required this.economy,
    required this.wides,
    required this.noBalls,
  });

  factory BowlerState.fromJson(Map<String, dynamic> j) => BowlerState(
        playerId: j['playerId'] as String,
        oversBowled: (j['oversBowled'] as num?) ?? 0,
        wickets: _int(j['wickets']),
        runsConceded: _int(j['runsConceded']),
        economy: (j['economy'] as num?) ?? 0,
        wides: _int(j['wides']),
        noBalls: _int(j['noBalls']),
      );
}

class ChaseState {
  final int target;
  final int runsNeeded;
  final int? ballsRemaining;
  final num? requiredRunRate;

  ChaseState({
    required this.target,
    required this.runsNeeded,
    this.ballsRemaining,
    this.requiredRunRate,
  });

  factory ChaseState.fromJson(Map<String, dynamic> j) => ChaseState(
        target: _int(j['target']),
        runsNeeded: _int(j['runsNeeded']),
        ballsRemaining: (j['ballsRemaining'] as num?)?.toInt(),
        requiredRunRate: j['requiredRunRate'] as num?,
      );
}

class ResultState {
  final String? winnerId;
  final String? margin;
  ResultState({this.winnerId, this.margin});
  factory ResultState.fromJson(Map<String, dynamic> j) =>
      ResultState(winnerId: j['winnerId'] as String?, margin: j['margin'] as String?);
}

class BallEvent {
  final String id;
  final int overNumber;
  final int ballNumber;
  final String batterId;
  final String? nonBatterId;
  final String bowlerId;
  final String? fielderId;
  final String outcome;
  final int runs;
  final int extras;
  final int totalRuns;
  final bool isWicket;
  final String? dismissalType;
  final String? dismissedPlayerId;
  final String? wagonZone;
  final String? shotType;
  final String? ballLine;
  final String? ballLength;
  final String? scoreAfterBall;
  final DateTime? scoredAt;

  BallEvent({
    required this.id,
    required this.overNumber,
    required this.ballNumber,
    required this.batterId,
    this.nonBatterId,
    required this.bowlerId,
    this.fielderId,
    required this.outcome,
    required this.runs,
    required this.extras,
    required this.totalRuns,
    required this.isWicket,
    this.dismissalType,
    this.dismissedPlayerId,
    this.wagonZone,
    this.shotType,
    this.ballLine,
    this.ballLength,
    this.scoreAfterBall,
    this.scoredAt,
  });

  factory BallEvent.fromJson(Map<String, dynamic> j) => BallEvent(
        id: j['id'] as String,
        overNumber: _int(j['overNumber']),
        ballNumber: _int(j['ballNumber']),
        batterId: j['batterId'] as String,
        nonBatterId: j['nonBatterId'] as String?,
        bowlerId: j['bowlerId'] as String,
        fielderId: j['fielderId'] as String?,
        outcome: j['outcome'] as String? ?? '',
        runs: _int(j['runs']),
        extras: _int(j['extras']),
        totalRuns: _int(j['totalRuns']),
        isWicket: j['isWicket'] as bool? ?? false,
        dismissalType: j['dismissalType'] as String?,
        dismissedPlayerId: j['dismissedPlayerId'] as String?,
        wagonZone: j['wagonZone'] as String?,
        shotType: j['shotType'] as String?,
        ballLine: j['ballLine'] as String?,
        ballLength: j['ballLength'] as String?,
        scoreAfterBall: j['scoreAfterBall'] as String?,
        scoredAt: _date(j['scoredAt']),
      );
}

int _int(dynamic v) => v is num ? v.toInt() : 0;
DateTime? _date(dynamic v) =>
    v is String ? DateTime.tryParse(v) : (v is DateTime ? v : null);
