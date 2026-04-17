import '../../elite/domain/swing_index_summary.dart';

class PlayerProfilePageData {
  const PlayerProfilePageData({
    required this.identity,
    required this.heroStats,
    required this.performance,
    required this.fullStats,
    required this.metricValues,
    required this.rankProgress,
    required this.seasonProgress,
    required this.skillMatrix,
    required this.skillAxes,
    required this.insights,
    required this.trophies,
    required this.recentPerformances,
    required this.academy,
    required this.account,
    required this.editableProfile,
    required this.isProfileComplete,
    required this.unified,
    required this.showcase,
    this.notificationSummary,
    this.swingIndexSummary,
    this.viewerContext,
  });

  final PlayerIdentity identity;
  final List<ProfileKeyStat> heroStats;
  final PerformanceSnapshot performance;
  final FullCricketStats fullStats;
  final Map<String, Object?> metricValues;
  final PlayerRankProgress rankProgress;
  final SeasonProgress seasonProgress;
  final PlayerSkillMatrix skillMatrix;
  final List<PlayerSkillAxis> skillAxes;
  final PlayerProfileInsights insights;
  final List<PlayerTrophy> trophies;
  final List<PlayerRecentPerformance> recentPerformances;
  final AcademySummary academy;
  final List<AccountAction> account;
  final PlayerProfileUpdateRequest editableProfile;
  final bool isProfileComplete;
  final UnifiedProfileData unified;
  final List<ProfileShowcaseItem> showcase;
  final ProfileNotificationSummary? notificationSummary;
  final SwingIndexSummary? swingIndexSummary;
  final PlayerViewerContext? viewerContext;

  PlayerProfilePageData copyWith({
    PlayerIdentity? identity,
    PlayerProfileUpdateRequest? editableProfile,
    bool? isProfileComplete,
    UnifiedProfileData? unified,
    List<ProfileShowcaseItem>? showcase,
    ProfileNotificationSummary? notificationSummary,
    SwingIndexSummary? swingIndexSummary,
    PlayerViewerContext? viewerContext,
  }) {
    return PlayerProfilePageData(
      identity: identity ?? this.identity,
      heroStats: heroStats,
      performance: performance,
      fullStats: fullStats,
      metricValues: metricValues,
      rankProgress: rankProgress,
      seasonProgress: seasonProgress,
      skillMatrix: skillMatrix,
      skillAxes: skillAxes,
      insights: insights,
      trophies: trophies,
      recentPerformances: recentPerformances,
      academy: academy,
      account: account,
      editableProfile: editableProfile ?? this.editableProfile,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      unified: unified ?? this.unified,
      showcase: showcase ?? this.showcase,
      notificationSummary: notificationSummary ?? this.notificationSummary,
      swingIndexSummary: swingIndexSummary ?? this.swingIndexSummary,
      viewerContext: viewerContext ?? this.viewerContext,
    );
  }
}

class UnifiedProfileData {
  const UnifiedProfileData({
    required this.identity,
    required this.ranking,
    required this.stats,
    required this.precision,
    required this.badges,
    required this.wellness,
    required this.teams,
  });

  final ProfileIdentity identity;
  final ProfileRanking ranking;
  final ProfileStats stats;
  final BattingPrecision precision;
  final List<ProfileBadge> badges;
  final WellnessData wellness;
  final List<ProfileTeam> teams;
}

class ProfileIdentity {
  const ProfileIdentity({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.bio,
    required this.city,
    required this.state,
    required this.playerRole,
    required this.battingStyle,
    required this.bowlingStyle,
    required this.level,
    required this.fans,
    required this.following,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final String bio;
  final String city;
  final String state;
  final String playerRole;
  final String battingStyle;
  final String bowlingStyle;
  final String level;
  final int fans;
  final int following;
}

class ProfileRanking {
  const ProfileRanking({
    required this.rank,
    required this.label,
    required this.division,
    required this.impactPoints,
    required this.swingIndex,
    required this.progress,
  });

  final String rank;
  final String label;
  final int division;
  final int impactPoints;
  final double swingIndex;
  final int progress;
}

class ProfileStats {
  const ProfileStats({
    required this.batting,
    required this.bowling,
    required this.fielding,
  });

  final BattingStats batting;
  final BowlingStats bowling;
  final FieldingStats fielding;
}

class ProfileBadge {
  const ProfileBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.isUnlocked,
    this.iconUrl,
    required this.xpReward,
    this.isRare = false,
    this.awardedAt,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final bool isUnlocked;
  final String? iconUrl;
  final int xpReward;
  final bool? isRare;
  final String? awardedAt;
}

class ProfileTeam {
  const ProfileTeam({
    required this.id,
    required this.name,
    required this.powerScore,
  });

  final String id;
  final String name;
  final double powerScore;
}

class EliteAnalytics {
  const EliteAnalytics({
    required this.precision,
    required this.milestones,
    required this.wellness,
    required this.benchmarks,
  });

  final BattingPrecision precision;
  final AdvancedMilestones milestones;
  final WellnessData wellness;
  final BenchmarkingData benchmarks;
}

class BattingPrecision {
  const BattingPrecision({
    required this.powerplaySR,
    required this.middleOversSR,
    required this.deathOversSR,
    required this.paceSR,
    required this.spinSR,
  });

  final double powerplaySR;
  final double middleOversSR;
  final double deathOversSR;
  final double paceSR;
  final double spinSR;
}

class AdvancedMilestones {
  const AdvancedMilestones({
    required this.thirties,
    required this.fifties,
    required this.hundreds,
    required this.ducks,
    required this.threeWicketHauls,
    required this.fiveWicketHauls,
  });

  final int thirties;
  final int fifties;
  final int hundreds;
  final int ducks;
  final int threeWicketHauls;
  final int fiveWicketHauls;
}

class WellnessData {
  const WellnessData({
    required this.recoveryScore,
    required this.oversBowledPastMonth,
    required this.trainingHoursWeekly,
    required this.fatigueLevel,
  });

  final double recoveryScore;
  final double oversBowledPastMonth;
  final double trainingHoursWeekly;
  final int fatigueLevel;
}

class BenchmarkingData {
  const BenchmarkingData({
    required this.cityAverageSR,
    required this.percentile,
    required this.label,
  });

  final double cityAverageSR;
  final int percentile;
  final String label;
}

class PlayerViewerContext {
  const PlayerViewerContext({
    required this.isSelf,
    required this.following,
    this.directConversationId,
  });

  final bool isSelf;
  final bool following;
  final String? directConversationId;

  PlayerViewerContext copyWith({
    bool? isSelf,
    bool? following,
    String? directConversationId,
  }) {
    return PlayerViewerContext(
      isSelf: isSelf ?? this.isSelf,
      following: following ?? this.following,
      directConversationId: directConversationId ?? this.directConversationId,
    );
  }
}

class PlayerIdentity {
  const PlayerIdentity({
    required this.id,
    required this.fullName,
    required this.swingId,
    required this.followersCount,
    required this.followingCount,
    required this.primaryRole,
    required this.battingStyle,
    required this.bowlingStyle,
    required this.archetype,
    required this.competitiveTier,
    required this.level,
    required this.pulseStatus,
    required this.city,
    required this.state,
    required this.goal,
    required this.bio,
    this.avatarUrl,
    this.coverUrl,
  });

  final String id;
  final String fullName;
  final String swingId;
  final int followersCount;
  final int followingCount;
  final String primaryRole;
  final String battingStyle;
  final String bowlingStyle;
  final String archetype;
  final String competitiveTier;
  final String level;
  final String pulseStatus;
  final String city;
  final String state;
  final String goal;
  final String bio;
  final String? avatarUrl;
  final String? coverUrl;

  PlayerIdentity copyWith({
    String? avatarUrl,
    String? coverUrl,
  }) {
    return PlayerIdentity(
      id: id,
      fullName: fullName,
      swingId: swingId,
      followersCount: followersCount,
      followingCount: followingCount,
      primaryRole: primaryRole,
      battingStyle: battingStyle,
      bowlingStyle: bowlingStyle,
      archetype: archetype,
      competitiveTier: competitiveTier,
      level: level,
      pulseStatus: pulseStatus,
      city: city,
      state: state,
      goal: goal,
      bio: bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }
}

class ProfileKeyStat {
  const ProfileKeyStat({
    required this.label,
    required this.value,
    this.caption,
  });

  final String label;
  final String value;
  final String? caption;
}

class PerformanceSnapshot {
  const PerformanceSnapshot({
    required this.battingImpact,
    required this.bowlingImpact,
    required this.fieldingImpact,
    required this.fitness,
    required this.clutch,
    required this.consistency,
    this.captaincy,
    required this.recentForm,
    required this.summary,
  });

  final int battingImpact;
  final int bowlingImpact;
  final int fieldingImpact;
  final int fitness;
  final int clutch;
  final int consistency;
  final double? captaincy;
  final int recentForm;
  final String summary;
}

class FullCricketStats {
  const FullCricketStats({
    required this.ranking,
    required this.batting,
    required this.bowling,
    required this.fielding,
    required this.swingIndex,
  });

  final RankingStats ranking;
  final BattingStats batting;
  final BowlingStats bowling;
  final FieldingStats fielding;
  final SwingIndexBreakdown swingIndex;
}

class RankingStats {
  const RankingStats({
    required this.lifetimeIp,
    required this.rankProgressPoints,
    required this.rankName,
    required this.matchesPlayed,
    required this.matchesWon,
    required this.winRate,
    required this.winStreak,
  });

  final int lifetimeIp;
  final int rankProgressPoints;
  final String rankName;
  final int matchesPlayed;
  final int matchesWon;
  final double winRate;
  final int winStreak;
}

class BattingStats {
  const BattingStats({
    required this.runs,
    required this.ballsFaced,
    required this.average,
    required this.strikeRate,
    required this.highestScore,
    required this.thirties,
    required this.fifties,
    required this.hundreds,
    required this.fours,
    required this.sixes,
    required this.ducks,
  });

  final int runs;
  final int ballsFaced;
  final double average;
  final double strikeRate;
  final int highestScore;
  final int thirties;
  final int fifties;
  final int hundreds;
  final int fours;
  final int sixes;
  final int ducks;
}

class BowlingStats {
  const BowlingStats({
    required this.wickets,
    required this.oversBowled,
    required this.average,
    required this.economy,
    required this.strikeRate,
    required this.bestBowling,
    required this.threeWicketHauls,
    required this.fiveWicketHauls,
  });

  final int wickets;
  final double oversBowled;
  final double average;
  final double economy;
  final double strikeRate;
  final String bestBowling;
  final int threeWicketHauls;
  final int fiveWicketHauls;
}

class FieldingStats {
  const FieldingStats({
    required this.catches,
    required this.stumpings,
    required this.runOuts,
  });

  final int catches;
  final int stumpings;
  final int runOuts;
}

class SwingIndexBreakdown {
  const SwingIndexBreakdown({
    required this.overall,
    required this.batting,
    required this.bowling,
    required this.fielding,
    required this.fitness,
    required this.clutch,
    required this.consistency,
    this.captaincy,
  });

  final int overall;
  final int batting;
  final int bowling;
  final int fielding;
  final int fitness;
  final int clutch;
  final int consistency;
  final double? captaincy;
}

class PlayerSkillMatrix {
  const PlayerSkillMatrix({
    required this.batting,
    required this.bowling,
    required this.fielding,
    required this.fitness,
    required this.clutch,
    required this.consistency,
    this.captaincy,
  });

  final double batting;
  final double bowling;
  final double fielding;
  final double fitness;
  final double clutch;
  final double consistency;
  final double? captaincy;
}

class AcademySummary {
  const AcademySummary({
    required this.isLinked,
    required this.enrollmentId,
    required this.academyName,
    required this.academyCity,
    required this.coachName,
    required this.batchName,
    required this.batchSchedule,
    required this.feeAmountPaise,
    required this.feePaidPaise,
    required this.feeDuePaise,
    required this.feeFrequency,
    required this.feeStatus,
    required this.transactions,
    required this.nextSessionLabel,
    required this.latestReportSummary,
    required this.joinCtaLabel,
  });

  final bool isLinked;
  final String? enrollmentId;
  final String? academyName;
  final String? academyCity;
  final String? coachName;
  final String? batchName;
  final String? batchSchedule;
  final int feeAmountPaise;
  final int feePaidPaise;
  final int feeDuePaise;
  final String? feeFrequency;
  final String? feeStatus;
  final List<FeeTransactionSummary> transactions;
  final String? nextSessionLabel;
  final String? latestReportSummary;
  final String joinCtaLabel;
}

class FeeTransactionSummary {
  const FeeTransactionSummary({
    required this.id,
    required this.amountPaise,
    required this.status,
    required this.mode,
    required this.createdAt,
  });

  final String id;
  final int amountPaise;
  final String status;
  final String? mode;
  final DateTime? createdAt;
}

class PlayerRankProgress {
  const PlayerRankProgress({
    required this.rank,
    required this.division,
    required this.label,
    required this.impactPoints,
    required this.seasonPoints,
    required this.mvpCount,
    required this.progress,
    required this.pointsToNextRank,
    required this.nextRankLabel,
    required this.momentumLabel,
    this.hasPremiumPass = false,
  });

  final String rank;
  final String? division;
  final String label;
  final int impactPoints;
  final int seasonPoints;
  final int mvpCount;
  final double progress;
  final int pointsToNextRank;
  final String nextRankLabel;
  final String momentumLabel;
  final bool hasPremiumPass;
}

class SeasonProgress {
  const SeasonProgress({
    required this.title,
    required this.summary,
    required this.currentPoints,
    required this.progress,
    required this.nextRewardLabel,
    required this.nextMilestonePoints,
    required this.milestones,
  });

  final String title;
  final String summary;
  final int currentPoints;
  final double progress;
  final String nextRewardLabel;
  final int nextMilestonePoints;
  final List<SeasonMilestone> milestones;
}

class SeasonMilestone {
  const SeasonMilestone({
    required this.label,
    required this.requiredPoints,
    required this.isUnlocked,
    required this.isCurrent,
  });

  final String label;
  final int requiredPoints;
  final bool isUnlocked;
  final bool isCurrent;
}

class PlayerSkillAxis {
  const PlayerSkillAxis({
    required this.key,
    required this.label,
    required this.value,
    this.isLocked = false,
    this.lockedText,
    this.delta,
  });

  final String key;
  final String label;
  final double? value;
  final bool isLocked;
  final String? lockedText;
  final int? delta;
}

class PlayerProfileInsights {
  const PlayerProfileInsights({
    required this.strengths,
    required this.workOns,
    required this.summary,
  });

  final List<PlayerFocusItem> strengths;
  final List<PlayerFocusItem> workOns;
  final String summary;
}

class PlayerFocusItem {
  const PlayerFocusItem({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;
}

enum TrophyTone {
  steel,
  emerald,
  gold,
}

class PlayerTrophy {
  const PlayerTrophy({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.tone,
  });

  final String id;
  final String title;
  final String subtitle;
  final String iconKey;
  final TrophyTone tone;
}

class PlayerRecentPerformance {
  const PlayerRecentPerformance({
    required this.id,
    required this.opponent,
    required this.impactPoints,
    required this.outcomeLabel,
    required this.summary,
    required this.deltas,
    this.mvpWon = false,
  });

  final String id;
  final String opponent;
  final int impactPoints;
  final String outcomeLabel;
  final String summary;
  final List<PlayerPerformanceDelta> deltas;
  final bool mvpWon;
}

class PlayerPerformanceDelta {
  const PlayerPerformanceDelta({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;
}

class AccountAction {
  const AccountAction({
    required this.id,
    required this.label,
    required this.subtitle,
  });

  final String id;
  final String label;
  final String subtitle;
}

class PlayerProfileUpdateRequest {
  const PlayerProfileUpdateRequest({
    this.name,
    this.username,
    this.dateOfBirth,
    this.gender,
    this.city,
    this.state,
    this.avatarUrl,
    this.coverUrl,
    this.jerseyNumber,
    this.includeJerseyNumber = false,
    this.playerRole,
    this.battingStyle,
    this.bowlingStyle,
    this.level,
    this.goals,
    this.bio,
    this.availableDays,
    this.preferredTimes,
    this.locationRadius,
    this.isPublic,
    this.showStats,
    this.showLocation,
    this.scoutingOptIn,
  });

  final String? name;
  final String? username;
  final String? dateOfBirth;
  final String? gender;
  final String? city;
  final String? state;
  final String? avatarUrl;
  final String? coverUrl;
  final int? jerseyNumber;
  final bool includeJerseyNumber;
  final String? playerRole;
  final String? battingStyle;
  final String? bowlingStyle;
  final String? level;
  final String? goals;
  final String? bio;
  final List<String>? availableDays;
  final List<String>? preferredTimes;
  final int? locationRadius;
  final bool? isPublic;
  final bool? showStats;
  final bool? showLocation;
  final bool? scoutingOptIn;

  PlayerProfileUpdateRequest copyWith({
    String? name,
    String? username,
    String? dateOfBirth,
    String? gender,
    String? city,
    String? state,
    String? avatarUrl,
    String? coverUrl,
    int? jerseyNumber,
    bool? includeJerseyNumber,
    String? playerRole,
    String? battingStyle,
    String? bowlingStyle,
    String? level,
    String? goals,
    String? bio,
    List<String>? availableDays,
    List<String>? preferredTimes,
    int? locationRadius,
    bool? isPublic,
    bool? showStats,
    bool? showLocation,
    bool? scoutingOptIn,
  }) {
    return PlayerProfileUpdateRequest(
      name: name ?? this.name,
      username: username ?? this.username,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      city: city ?? this.city,
      state: state ?? this.state,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      includeJerseyNumber: includeJerseyNumber ?? this.includeJerseyNumber,
      playerRole: playerRole ?? this.playerRole,
      battingStyle: battingStyle ?? this.battingStyle,
      bowlingStyle: bowlingStyle ?? this.bowlingStyle,
      level: level ?? this.level,
      goals: goals ?? this.goals,
      bio: bio ?? this.bio,
      availableDays: availableDays ?? this.availableDays,
      preferredTimes: preferredTimes ?? this.preferredTimes,
      locationRadius: locationRadius ?? this.locationRadius,
      isPublic: isPublic ?? this.isPublic,
      showStats: showStats ?? this.showStats,
      showLocation: showLocation ?? this.showLocation,
      scoutingOptIn: scoutingOptIn ?? this.scoutingOptIn,
    );
  }

  Map<String, dynamic> toJson() {
    final trimmedAvatarUrl = avatarUrl?.trim();
    final trimmedCoverUrl = coverUrl?.trim();

    return {
      if (name != null) 'name': name!.trim(),
      if (username != null) 'username': username!.trim(),
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (city != null) 'city': city!.trim(),
      if (state != null) 'state': state!.trim(),
      if (trimmedAvatarUrl != null) 'avatarUrl': trimmedAvatarUrl,
      if (trimmedAvatarUrl != null) 'avatar_url': trimmedAvatarUrl,
      if (trimmedCoverUrl != null) 'coverUrl': trimmedCoverUrl,
      if (trimmedCoverUrl != null) 'cover_url': trimmedCoverUrl,
      if (includeJerseyNumber) 'jerseyNumber': jerseyNumber,
      if (includeJerseyNumber) 'jerseyNo': jerseyNumber,
      if (playerRole != null) 'playerRole': playerRole,
      if (battingStyle != null) 'battingStyle': battingStyle,
      if (bowlingStyle != null) 'bowlingStyle': bowlingStyle,
      if (level != null) 'level': level,
      if (goals != null) 'goals': goals!.trim(),
      if (bio != null) 'bio': bio!.trim(),
      if (availableDays != null) 'availableDays': availableDays,
      if (preferredTimes != null) 'preferredTimes': preferredTimes,
      if (locationRadius != null) 'locationRadius': locationRadius,
      if (isPublic != null) 'isPublic': isPublic,
      if (showStats != null) 'showStats': showStats,
      if (showLocation != null) 'showLocation': showLocation,
      if (scoutingOptIn != null) 'scoutingOptIn': scoutingOptIn,
    };
  }
}

class ProfileShowcaseItem {
  const ProfileShowcaseItem({
    required this.url,
    this.thumbnailUrl,
    this.isPinned = false,
    this.title,
    required this.type,
    this.caption,
  });

  final String url;
  final String? thumbnailUrl;
  final bool isPinned;
  final String? title;
  final String type;
  final String? caption;
}

class ProfileNotificationSummary {
  const ProfileNotificationSummary({
    required this.unreadNotificationCount,
    required this.unreadConversationCount,
    required this.unreadMessageCount,
  });

  final int unreadNotificationCount;
  final int unreadConversationCount;
  final int unreadMessageCount;
}

