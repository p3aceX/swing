class PlayerNotFoundException implements Exception {
  const PlayerNotFoundException([this.message = 'Player not found']);
  final String message;
  @override
  String toString() => message;
}

enum MatchSectionType {
  individual,
  tournament,
}

enum MatchTimelineFilter {
  all,
  live,
  upcoming,
  past,
  hosting,
}

enum MatchLifecycle {
  live,
  upcoming,
  past,
}

enum MatchResult {
  win,
  loss,
  draw,
  unknown,
}

class PlayerMatch {
  const PlayerMatch({
    required this.id,
    required this.title,
    required this.sectionType,
    required this.lifecycle,
    required this.result,
    required this.statusLabel,
    required this.playerTeamName,
    required this.opponentTeamName,
    this.playerTeamLogoUrl,
    this.opponentTeamLogoUrl,
    this.playerTeamShortName,
    this.opponentTeamShortName,
    this.scheduledAt,
    this.competitionLabel,
    this.venueLabel,
    this.formatLabel,
    this.scoreSummary,
    this.playerRuns,
    this.playerBalls,
    this.playerWickets,
    this.playerCatches,
    this.canScore = false,
    this.scoringOwnerIds = const [],
    this.involvesPlayerTeam = false,
    this.isMatchmaking = false,
    this.ballType,
    this.tossWinner,
    this.tossDecision,
  });

  final String id;
  final String title;
  final MatchSectionType sectionType;
  final MatchLifecycle lifecycle;
  final MatchResult result;
  final String statusLabel;
  final String playerTeamName;
  final String opponentTeamName;
  final String? playerTeamLogoUrl;
  final String? opponentTeamLogoUrl;
  final String? playerTeamShortName;
  final String? opponentTeamShortName;
  final DateTime? scheduledAt;
  final String? competitionLabel;
  final String? venueLabel;
  final String? formatLabel;
  final String? scoreSummary;
  final int? playerRuns;
  final int? playerBalls;
  final int? playerWickets;
  final int? playerCatches;

  /// True when the current player has scoring rights for this match
  /// (i.e. they created it or are a member of a participating team).
  final bool canScore;
  final List<String> scoringOwnerIds;

  /// True when the backend payload indicates this match involves the
  /// current player's team, not just the surrounding tournament schedule.
  final bool involvesPlayerTeam;

  /// True when this match was created via the matchmaking flow.
  /// Delete is controlled by the arena owner, not the player.
  final bool isMatchmaking;

  /// e.g. 'LEATHER' or 'TENNIS'
  final String? ballType;

  /// Team that won the toss, e.g. 'Mumbai Tigers'
  final String? tossWinner;

  /// What the toss winner chose, e.g. 'BAT' or 'BOWL'
  final String? tossDecision;

  PlayerMatch copyWith({
    String? scoreSummary,
    String? tossWinner,
    String? tossDecision,
    MatchResult? result,
    String? statusLabel,
  }) {
    return PlayerMatch(
      id: id,
      title: title,
      sectionType: sectionType,
      lifecycle: lifecycle,
      result: result ?? this.result,
      statusLabel: statusLabel ?? this.statusLabel,
      playerTeamName: playerTeamName,
      opponentTeamName: opponentTeamName,
      playerTeamLogoUrl: playerTeamLogoUrl,
      opponentTeamLogoUrl: opponentTeamLogoUrl,
      playerTeamShortName: playerTeamShortName,
      opponentTeamShortName: opponentTeamShortName,
      scheduledAt: scheduledAt,
      competitionLabel: competitionLabel,
      venueLabel: venueLabel,
      formatLabel: formatLabel,
      scoreSummary: scoreSummary ?? this.scoreSummary,
      playerRuns: playerRuns,
      playerBalls: playerBalls,
      playerWickets: playerWickets,
      playerCatches: playerCatches,
      canScore: canScore,
      scoringOwnerIds: scoringOwnerIds,
      involvesPlayerTeam: involvesPlayerTeam,
      ballType: ballType,
      tossWinner: tossWinner ?? this.tossWinner,
      tossDecision: tossDecision ?? this.tossDecision,
    );
  }
}

// ── Structured scorecard row types ────────────────────────────────────────────

class MatchBatsmanRow {
  const MatchBatsmanRow({
    required this.name,
    required this.runs,
    required this.balls,
    required this.fours,
    required this.sixes,
    required this.strikeRate,
    required this.isOut,
    this.playerId,
    this.dismissal,
  });

  final String? playerId;
  final String name;
  final int runs;
  final int balls;
  final int fours;
  final int sixes;
  final String strikeRate; // "150.0" or "-"
  final bool isOut;
  final String? dismissal; // "Caught", "Bowled", …
}

class MatchBowlerRow {
  const MatchBowlerRow({
    required this.name,
    required this.overs,
    required this.runs,
    required this.wickets,
    required this.economy,
    this.playerId,
  });

  final String? playerId;
  final String name;
  final String overs; // "4.0"
  final int runs;
  final int wickets;
  final String economy; // "6.25" or "-"
}

// ── Match center models ────────────────────────────────────────────────────────

class MatchCenter {
  const MatchCenter({
    required this.id,
    required this.title,
    required this.sectionType,
    required this.lifecycle,
    required this.statusLabel,
    required this.teamAName,
    required this.teamBName,
    required this.teamAScore,
    required this.teamBScore,
    required this.innings,
    required this.squads,
    this.scheduledAt,
    this.competitionLabel,
    this.venueLabel,
    this.formatLabel,
    this.matchType,
    this.resultSummary,
    this.winnerTeamName,
    this.winMargin,
    this.overlayLoaded = false,
    this.youtubeUrl,
    this.tossSummary,
    this.currentRunRate,
    this.requiredRunRate,
    this.liveState,
    this.competitive,
    this.teamALogoUrl,
    this.teamBLogoUrl,
    this.teamAShortName,
    this.teamBShortName,
    this.canScore = false,
    this.scoringOwnerIds = const [],
  });

  final String id;
  final String title;
  final MatchSectionType sectionType;
  final MatchLifecycle lifecycle;
  final String statusLabel;
  final String teamAName;
  final String teamBName;
  final String? teamALogoUrl;
  final String? teamBLogoUrl;
  final String? teamAShortName;
  final String? teamBShortName;
  final String teamAScore;
  final String teamBScore;
  final DateTime? scheduledAt;
  final String? competitionLabel;
  final String? venueLabel;
  final String? formatLabel;
  final String? matchType;
  final String? resultSummary;
  final String? winnerTeamName;
  final String? winMargin;
  final bool overlayLoaded;
  final String? youtubeUrl;
  final String? tossSummary;
  final String? currentRunRate;
  final String? requiredRunRate;
  final MatchLiveState? liveState;
  final MatchCompetitiveSummary? competitive;
  final List<MatchInnings> innings;
  final List<MatchSquad> squads;
  final bool canScore;
  final List<String> scoringOwnerIds;
}

class MatchCompetitiveSummary {
  const MatchCompetitiveSummary({
    required this.source,
    required this.isOfficial,
    required this.isProvisional,
    required this.leaderboard,
    required this.info,
    this.mvp,
  });

  final String source;
  final bool isOfficial;
  final bool isProvisional;
  final MatchCompetitiveEntry? mvp;
  final List<MatchCompetitiveEntry> leaderboard;
  final MatchImpactInfo info;
}

class MatchCompetitiveEntry {
  const MatchCompetitiveEntry({
    required this.playerId,
    required this.playerName,
    required this.teamName,
    required this.impactPoints,
    required this.performanceScore,
    required this.isMvp,
    required this.summary,
    required this.breakdown,
  });

  final String playerId;
  final String playerName;
  final String teamName;
  final int impactPoints;
  final double performanceScore;
  final bool isMvp;
  final String summary;
  final MatchImpactBreakdown breakdown;
}

class MatchImpactInfo {
  const MatchImpactInfo({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;
}

class MatchImpactBreakdown {
  const MatchImpactBreakdown({
    required this.baseImpactPoints,
    required this.totalImpactPoints,
    required this.playingPoints,
    required this.battingPoints,
    required this.bowlingPoints,
    required this.fieldingPoints,
    required this.winBonusPoints,
    required this.mvpBonusPoints,
    required this.battingDetails,
    required this.bowlingDetails,
    required this.fieldingDetails,
  });

  final int baseImpactPoints;
  final int totalImpactPoints;
  final int playingPoints;
  final int battingPoints;
  final int bowlingPoints;
  final int fieldingPoints;
  final int winBonusPoints;
  final int mvpBonusPoints;
  final MatchImpactBattingDetails battingDetails;
  final MatchImpactBowlingDetails bowlingDetails;
  final MatchImpactFieldingDetails fieldingDetails;
}

class MatchImpactBattingDetails {
  const MatchImpactBattingDetails({
    required this.runsPoints,
    required this.boundaryBonusPoints,
    required this.strikeRateBonusPoints,
    required this.contributionBonusPoints,
  });

  final int runsPoints;
  final int boundaryBonusPoints;
  final int strikeRateBonusPoints;
  final int contributionBonusPoints;
}

class MatchImpactBowlingDetails {
  const MatchImpactBowlingDetails({
    required this.wicketPoints,
    required this.dotBallPoints,
    required this.maidenPoints,
    required this.economyBonusPoints,
  });

  final int wicketPoints;
  final int dotBallPoints;
  final int maidenPoints;
  final int economyBonusPoints;
}

class MatchImpactFieldingDetails {
  const MatchImpactFieldingDetails({
    required this.catchPoints,
    required this.runOutPoints,
    required this.stumpingPoints,
  });

  final int catchPoints;
  final int runOutPoints;
  final int stumpingPoints;
}

// ── Live match state ───────────────────────────────────────────────────────────

class MatchLiveState {
  const MatchLiveState({
    this.striker,
    this.nonStriker,
    this.currentBowler,
    this.currentOverBalls = const [],
    this.currentOverNumber = 0,
    this.target,
    this.toWin,
    this.ballsRemaining,
    this.currentRunRate,
    this.requiredRunRate,
  });

  final LiveBatter? striker;
  final LiveBatter? nonStriker;
  final LiveBowler? currentBowler;
  final List<String> currentOverBalls;
  final int currentOverNumber;
  final int? target;
  final int? toWin;
  final int? ballsRemaining;
  final String? currentRunRate;
  final String? requiredRunRate;
}

class LiveBatter {
  const LiveBatter({
    required this.name,
    required this.runs,
    required this.balls,
    required this.fours,
    required this.sixes,
    required this.strikeRate,
    required this.isStriker,
  });

  final String name;
  final int runs, balls, fours, sixes;
  final String strikeRate;
  final bool isStriker;
}

class LiveBowler {
  const LiveBowler({
    required this.name,
    required this.overs,
    required this.runs,
    required this.wickets,
    required this.economy,
  });

  final String name;
  final String overs, economy;
  final int runs, wickets;
}

class FallOfWicket {
  const FallOfWicket({
    required this.wicket,
    required this.score,
    required this.player,
    required this.over,
  });

  final int wicket;
  final String score; // "45/1"
  final String player;
  final String over; // "8.3"
}

class MatchPartnership {
  const MatchPartnership({
    required this.batter1,
    required this.batter2,
    required this.runs,
    required this.balls,
  });

  final String batter1;
  final String batter2;
  final int runs;
  final int balls;
}

class MatchInnings {
  const MatchInnings({
    required this.title,
    required this.score,
    required this.battingTeamName,
    required this.batting,
    required this.bowling,
    this.extras = 0,
    this.isCompleted = false,
    this.isSuperOver = false,
    this.fallOfWickets = const [],
    this.partnerships = const [],
  });

  final String title;
  final String score; // "124/6 (20.0 ov)"
  final String battingTeamName;
  final int extras;
  final bool isCompleted;
  final bool isSuperOver;
  final List<MatchBatsmanRow> batting;
  final List<MatchBowlerRow> bowling;
  final List<FallOfWicket> fallOfWickets;
  final List<MatchPartnership> partnerships;
}

class MatchSquad {
  const MatchSquad({
    required this.teamName,
    required this.players,
  });

  final String teamName;
  final List<MatchSquadPlayer> players;
}

// ── Commentary ────────────────────────────────────────────────────────────────

class MatchCommentaryEntry {
  const MatchCommentaryEntry({
    required this.inningsNumber,
    required this.over,
    required this.overNumber,
    required this.ballNumber,
    required this.batter,
    required this.bowler,
    required this.outcome,
    required this.runs,
    required this.isWicket,
    required this.text,
    this.dismissalType,
    this.dismissedPlayer,
    this.fielder,
    this.scoreAfterBall,
    this.teamName,
    this.tags = const [],
  });

  final int inningsNumber;
  final String over;
  final int overNumber;
  final int ballNumber;
  final String batter;
  final String bowler;
  final String outcome;
  final int runs;
  final bool isWicket;
  final String text;
  final String? dismissalType;
  final String? dismissedPlayer;
  final String? fielder;
  final String? scoreAfterBall;
  final String? teamName;
  final List<String> tags;
}

// ── Analysis models ───────────────────────────────────────────────────────────

class MatchOverStat {
  const MatchOverStat({
    required this.over,
    required this.runs,
    required this.wickets,
    required this.runRate,
    required this.cumulativeRuns,
  });

  final int over;
  final int runs;
  final int wickets;
  final double runRate;
  final int cumulativeRuns;
}

class WagonWheelBall {
  const WagonWheelBall({
    required this.over,
    required this.runs,
    required this.isWicket,
    required this.batter,
    this.zone,
  });

  final String over;
  final int runs;
  final bool isWicket;
  final String batter;
  final String? zone; // e.g. "mid-wicket-in", "cover-out"
}

class MatchAnalysisInnings {
  const MatchAnalysisInnings({
    required this.inningsNumber,
    required this.battingTeam,
    required this.overStats,
    required this.wagonWheel,
  });

  final int inningsNumber;
  final String battingTeam;
  final List<MatchOverStat> overStats;
  final List<WagonWheelBall> wagonWheel;
}

class MatchAnalysis {
  const MatchAnalysis({
    required this.matchId,
    required this.innings,
  });

  final String matchId;
  final List<MatchAnalysisInnings> innings;
}

class MatchSquadPlayer {
  const MatchSquadPlayer({
    required this.name,
    this.playerId,
    this.roleLabel,
    this.isCaptain = false,
    this.isViceCaptain = false,
    this.isWicketKeeper = false,
    this.avatarUrl,
  });

  final String name;
  final String? playerId;
  final String? roleLabel;
  final bool isCaptain;
  final bool isViceCaptain;
  final bool isWicketKeeper;
  final String? avatarUrl;
}

/// Lightweight snapshot of live-changing score data. Fetched independently
/// from the full MatchCenter so only the score widget rebuilds per ball.
class MatchLiveScore {
  const MatchLiveScore({
    this.teamAScore = '',
    this.teamBScore = '',
    this.liveState,
    this.innings = const [],
  });

  final String teamAScore;
  final String teamBScore;
  final MatchLiveState? liveState;
  final List<MatchInnings> innings;
}

