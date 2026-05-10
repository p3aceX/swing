// Mock OverlayBootstrap + OverlayTick for the preview page.
// Lets the design be reviewed without a live match.

import '../models/overlay_models.dart';

OverlayBootstrap mockBootstrap() => OverlayBootstrap(
      match: MatchInfo(
        id: 'mock-match-1',
        type: 'LEAGUE',
        format: 'T20',
        status: 'INNINGS_2',
        scheduledAt: DateTime.now(),
        startedAt: DateTime.now().subtract(const Duration(minutes: 78)),
        venue: 'Eden Gardens',
      ),
      tournament: TournamentInfo(
        id: 't1',
        name: 'Swing Premier League',
        logoUrl: null,
        format: 'T20',
      ),
      toss: TossState(
        done: true,
        wonBy: 'A',
        decision: 'BAT',
        doneAt: DateTime.now().subtract(const Duration(minutes: 90)),
      ),
      teamA: TeamInfo(
        id: 'team-a',
        name: 'Swing Strikers',
        shortName: 'SWS',
        logoUrl: null,
        city: 'Mumbai',
        homeGround: 'Wankhede',
        powerScore: 1840,
        credibilityScore: 95,
        captainId: 'p1',
        viceCaptainId: 'p2',
        wicketKeeperId: 'p3',
        playingXi: _mockXi('A', startId: 1),
      ),
      teamB: TeamInfo(
        id: 'team-b',
        name: 'AKCT Titans',
        shortName: 'AKT',
        logoUrl: null,
        city: 'Bengaluru',
        homeGround: 'Chinnaswamy',
        powerScore: 1790,
        credibilityScore: 92,
        captainId: 'p12',
        viceCaptainId: 'p13',
        wicketKeeperId: 'p14',
        playingXi: _mockXi('B', startId: 12),
      ),
      generatedAt: DateTime.now(),
    );

List<PlayerInfo> _mockXi(String side, {required int startId}) {
  final names = side == 'A'
      ? const [
          'Rohit Sharma',
          'Shubman Gill',
          'Virat Kohli',
          'Suryakumar Yadav',
          'Hardik Pandya',
          'Rishabh Pant',
          'Ravindra Jadeja',
          'Mohammed Shami',
          'Jasprit Bumrah',
          'Kuldeep Yadav',
          'Mohammed Siraj',
        ]
      : const [
          'Babar Azam',
          'Mohammad Rizwan',
          'Fakhar Zaman',
          'Iftikhar Ahmed',
          'Shadab Khan',
          'Imad Wasim',
          'Mohammad Nawaz',
          'Shaheen Afridi',
          'Naseem Shah',
          'Haris Rauf',
          'Mohammad Wasim',
        ];
  final ranks = const [
    'LEGEND',
    'ELITE',
    'PRO',
    'PRO',
    'CHALLENGER',
    'CHALLENGER',
    'CONTENDER',
    'CONTENDER',
    'ROOKIE',
    'ROOKIE',
    'ROOKIE',
  ];
  return List.generate(11, (i) {
    final id = 'p${startId + i}';
    return PlayerInfo(
      id: id,
      teamSide: side,
      name: names[i],
      username: names[i].toLowerCase().replaceAll(' ', ''),
      photoUrl: null,
      jerseyNumber: 7 + i,
      role: i < 5
          ? 'BATSMAN'
          : i < 7
              ? 'ALL_ROUNDER'
              : 'BOWLER',
      battingStyle: i.isEven ? 'RIGHT_HAND' : 'LEFT_HAND',
      bowlingStyle: i < 7 ? 'NOT_A_BOWLER' : 'RIGHT_ARM_FAST',
      isCaptain: i == 0,
      isViceCaptain: i == 1,
      isWicketKeeper: i == 2,
      career: PlayerCareer(
        matchesPlayed: 120 + i * 5,
        matchesWon: 70 + i * 2,
        runs: 3500 - i * 220,
        ballsFaced: 2800 - i * 180,
        highestScore: 152 - i * 6,
        fifties: 28 - i,
        hundreds: 6 - (i ~/ 4),
        fours: 320 - i * 15,
        sixes: 110 - i * 6,
        battingAverage: (45.5 - i * 1.5).clamp(10, 60),
        strikeRate: (138 - i * 2.5).clamp(80, 180),
        wickets: i < 7 ? 5 : 80 + (i - 7) * 12,
        oversBowled: i < 7 ? 8.0 : 240.0 + (i - 7) * 30,
        bestBowling: i < 7 ? null : '5/24',
        fiveWicketHauls: i < 7 ? 0 : 2,
        bowlingAverage: i < 7 ? 0 : 22.5 + i,
        economyRate: i < 7 ? 0 : 7.2 + i * 0.1,
        bowlingStrikeRate: i < 7 ? 0 : 18.5,
      ),
      swing: SwingScores(
        index: 80 - i * 3.5,
        batting: i < 7 ? 85 - i * 4 : 30,
        bowling: i < 7 ? 30 : 80 - (i - 7) * 5,
        fielding: 70 - i * 2,
        fitness: 75,
        gameIntelligence: 70 - i,
        coachability: 80,
      ),
      rank: CompetitiveRank(
        key: ranks[i],
        division: (i % 3) + 1,
        lifetimeImpactPoints: 12000 - i * 600,
        rankProgressPoints: 2400 - i * 150,
        winStreak: 4 - (i % 4),
        mvpCount: 8 - i,
        hasPremiumPass: i < 3,
      ),
    );
  });
}

OverlayTick mockTick({
  int runs = 142,
  int wickets = 4,
  num overs = 16.3,
  int? lastBallRuns,
  bool lastBallWicket = false,
}) {
  final inningsA = InningsSummary(
    inningsNumber: 1,
    battingTeam: 'A',
    runs: 178,
    wickets: 6,
    overs: 20.0,
    isCompleted: true,
    isDeclared: false,
  );
  final inningsB = InningsSummary(
    inningsNumber: 2,
    battingTeam: 'B',
    runs: runs,
    wickets: wickets,
    overs: overs,
    isCompleted: false,
    isDeclared: false,
  );
  return OverlayTick(
    matchId: 'mock-match-1',
    status: 'INNINGS_2',
    toss: TossState(done: true, wonBy: 'A', decision: 'BAT'),
    inningsSummary: [inningsA, inningsB],
    current: CurrentInnings(
      inningsNumber: 2,
      battingTeam: 'B',
      runs: runs,
      wickets: wickets,
      overs: overs,
      extras: 6,
      striker: BatterState(
        playerId: 'p12',
        runs: 64,
        balls: 41,
        fours: 7,
        sixes: 2,
        strikeRate: 156.0,
        isOut: false,
      ),
      nonStriker: BatterState(
        playerId: 'p13',
        runs: 28,
        balls: 22,
        fours: 3,
        sixes: 0,
        strikeRate: 127.2,
        isOut: false,
      ),
      bowler: BowlerState(
        playerId: 'p9',
        oversBowled: 3.3,
        wickets: 2,
        runsConceded: 24,
        economy: 6.85,
        wides: 1,
        noBalls: 0,
      ),
    ),
    chase: ChaseState(target: 179, runsNeeded: 179 - runs),
    result: null,
    lastBalls: _mockLastBalls(
      lastBallRuns: lastBallRuns,
      lastBallWicket: lastBallWicket,
    ),
    serverAt: DateTime.now(),
  );
}

List<BallEvent> _mockLastBalls({int? lastBallRuns, bool lastBallWicket = false}) {
  final base = [
    _ball('b1', 16, 1, runs: 1),
    _ball('b2', 16, 2, runs: 0),
    _ball('b3', 16, 3, runs: 4),
    _ball('b4', 16, 4, runs: 0),
    _ball('b5', 16, 5, runs: 6),
  ];
  base.add(
    _ball(
      'b6',
      16,
      6,
      runs: lastBallRuns ?? 1,
      isWicket: lastBallWicket,
    ),
  );
  return base;
}

BallEvent _ball(String id, int over, int ball,
        {int runs = 0, bool isWicket = false}) =>
    BallEvent(
      id: id,
      overNumber: over,
      ballNumber: ball,
      batterId: 'p12',
      bowlerId: 'p9',
      outcome: isWicket ? 'WICKET' : 'NORMAL',
      runs: runs,
      extras: 0,
      totalRuns: runs,
      isWicket: isWicket,
      dismissalType: isWicket ? 'BOWLED' : null,
      dismissedPlayerId: isWicket ? 'p12' : null,
      scoredAt: DateTime.now(),
    );
