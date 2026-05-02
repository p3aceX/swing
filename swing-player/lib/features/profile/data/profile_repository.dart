import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../elite/domain/swing_index_summary.dart';
import '../../matches/data/matches_repository.dart';
import '../../matches/domain/match_models.dart';
import 'profile_payload_models.dart';
import 'profile_api_transformers.dart';
import '../domain/profile_field_mappings.dart';
import '../domain/profile_models.dart';
import '../../../core/api/base_repository.dart';

class CitySuggestion {
  const CitySuggestion({
    required this.city,
    required this.state,
  });

  final String city;
  final String state;

  String get label => '$city, $state';
}

class ProfileRepository extends BaseRepository {
  ProfileRepository([Dio? dio]) : _client = dio ?? ApiClient.instance.dio;

  final Dio _client;
  final _matchesRepository = MatchesRepository();

  Stream<PlayerProfilePageData> loadProfilePageStream({String? profileId}) async* {
    yield await loadProfilePage(profileId: profileId);
  }

  Future<PlayerProfilePageData> loadProfilePage({String? profileId}) async {
    final isOwnProfile = profileId == null;

    try {
      final bootstrapResponse = await _safeGet(
        isOwnProfile
            ? ApiEndpoints.playerProfile
            : ApiEndpoints.publicPlayerProfile(profileId),
      );
      final bootstrapFullResponse = await _safeGet(
        isOwnProfile
            ? ApiEndpoints.playerProfileFull
            : ApiEndpoints.publicPlayerProfileFull(profileId),
      );
      final bootstrapBaseProfile = _unwrapMap(bootstrapResponse);
      final bootstrapFullProfile = _unwrapMap(bootstrapFullResponse);
      final bootstrapProfile = <String, dynamic>{
        ...bootstrapBaseProfile,
        ...bootstrapFullProfile,
      };
      final bootstrapBaseIdentity = _map(bootstrapBaseProfile['identity']);
      final bootstrapFullIdentity = _map(bootstrapFullProfile['identity']);
      final bootstrapIdentity = bootstrapBaseIdentity.isNotEmpty ||
              bootstrapFullIdentity.isNotEmpty
          ? <String, dynamic>{
              ...bootstrapBaseIdentity,
              ...bootstrapFullIdentity,
            }
          : bootstrapProfile;
      final bootstrapSocial = _map(bootstrapProfile['social']);

      var idToFetch = _string(profileId);
      if (idToFetch.isEmpty) {
        idToFetch = _string(bootstrapIdentity['id']);
      }
      if (idToFetch.isEmpty) {
        throw StateError('Could not resolve player profile id.');
      }

      final results = await Future.wait<dynamic>([
        _client.get(ApiEndpoints.elitePlayerProfile(idToFetch)), // [0]
        _safeGet(ApiEndpoints.playerEnrollments), // [1]
        _safeGet(ApiEndpoints.payments, queryParameters: {'limit': 50}), // [2]
        _safeGet(ApiEndpoints.playerFeedback,
            queryParameters: {'limit': 3}), // [3]
        _safeGet(ApiEndpoints.playerLiveSession), // [4]
        _safeLoadRecentMatches(), // [5]
      ]);

      final eliteRaw = _unwrapMap(results[0]);
      final elite = EliteProfilePayload.fromJson(eliteRaw);
      final enrollments = _unwrapListResponse(results[1]);
      final payments = _unwrapPayments(results[2]);
      final feedback = _unwrapMap(results[3]);
      final liveSession = _unwrapMap(results[4]);
      final recentMatches = results[5] is List<PlayerMatch>
          ? results[5] as List<PlayerMatch>
          : const <PlayerMatch>[];

      final statsRaw = _map(eliteRaw['stats']);
      final battingRaw = _map(statsRaw['batting']);
      final bowlingRaw = _map(statsRaw['bowling']);
      final bowlingSummaryRaw = _map(bowlingRaw['summary']).isNotEmpty
          ? _map(bowlingRaw['summary'])
          : bowlingRaw;
      final fieldingRaw = _map(statsRaw['fielding']);

      String pickString(List<dynamic> values, {String fallback = '-'}) {
        for (final value in values) {
          final candidate = _string(value, fallback: '').trim();
          if (candidate.isNotEmpty && candidate != '-') return candidate;
        }
        return fallback;
      }

      final eliteIdentityRaw = _map(eliteRaw['identity']);
      final mergedIdentity = <String, dynamic>{
        ...bootstrapIdentity,
        ...eliteIdentityRaw,
      };
      final normalizedIdentity =
          ProfileIdentityResponseTransformer.normalize(mergedIdentity);

      var fansCount = elite.identity.fans > 0
          ? elite.identity.fans
          : _int(_firstNonNull([
              mergedIdentity['fans'],
              mergedIdentity['followersCount'],
              mergedIdentity['followers'],
              bootstrapSocial['followersCount'],
              bootstrapSocial['fans'],
              bootstrapSocial['followers'],
            ]));
      var followingCount = elite.identity.following > 0
          ? elite.identity.following
          : _int(_firstNonNull([
              mergedIdentity['following'],
              mergedIdentity['followingCount'],
              bootstrapSocial['followingCount'],
              bootstrapSocial['following'],
            ]));

      if (idToFetch.isNotEmpty && (fansCount == 0 || followingCount == 0)) {
        final resolved = await _resolveFollowCounts(idToFetch);
        if (fansCount == 0) fansCount = resolved.followers;
        if (followingCount == 0) followingCount = resolved.following;
      }

      final resolvedName = pickString([
        eliteIdentityRaw['name'],
        eliteIdentityRaw['fullName'],
        bootstrapIdentity['fullName'],
        bootstrapIdentity['name'],
      ]);
      final resolvedRole = pickString([
        normalizedIdentity['playerRole'],
        eliteIdentityRaw['playerRole'],
        bootstrapIdentity['playerRole'],
      ], fallback: '');
      final resolvedBattingStyle = pickString([
        normalizedIdentity['battingStyle'],
        eliteIdentityRaw['battingStyle'],
        bootstrapIdentity['battingStyle'],
      ], fallback: '');
      final resolvedBowlingStyle = pickString([
        normalizedIdentity['bowlingStyle'],
        eliteIdentityRaw['bowlingStyle'],
        bootstrapIdentity['bowlingStyle'],
      ], fallback: '');
      final resolvedLevel = pickString([
        normalizedIdentity['level'],
        eliteIdentityRaw['level'],
        bootstrapIdentity['level'],
      ], fallback: '');
      final resolvedCity = pickString([
        eliteIdentityRaw['city'],
        bootstrapIdentity['city'],
      ]);
      final resolvedState = pickString([
        eliteIdentityRaw['state'],
        bootstrapIdentity['state'],
      ]);
      final resolvedBio = pickString([
        eliteIdentityRaw['bio'],
        bootstrapIdentity['bio'],
      ]);
      final resolvedGoal = pickString(
        [eliteIdentityRaw['goal'], eliteIdentityRaw['goals']],
        fallback: '-',
      );
      final resolvedAvatarUrl = _httpUrl(_firstNonNull([
        eliteIdentityRaw['avatarUrl'],
        bootstrapIdentity['avatarUrl'],
      ]));
      final resolvedCoverUrl = _string(_firstNonNull([
        eliteIdentityRaw['coverUrl'],
        bootstrapIdentity['coverUrl'],
      ])).ifEmptyToNull();
      final displayRole =
          ProfileFieldMappings.displayLabel(ProfileFieldKey.role, resolvedRole);
      final displayBattingStyle = ProfileFieldMappings.displayLabel(
        ProfileFieldKey.battingStyle,
        resolvedBattingStyle,
      );
      final displayBowlingStyle = ProfileFieldMappings.displayLabel(
        ProfileFieldKey.bowlingStyle,
        resolvedBowlingStyle,
      );
      final displayLevel =
          ProfileFieldMappings.displayLabel(ProfileFieldKey.level, resolvedLevel);
      final dateOfBirth = pickString(
        [elite.identity.dateOfBirth, mergedIdentity['dateOfBirth']],
        fallback: '',
      );

      final ranking = elite.ranking;
      final rankingLabel = ranking.label.trim().isNotEmpty
          ? ranking.label
          : '${ranking.rank} ${ranking.division}'.trim();
      final rankingRaw = <String, dynamic>{
        'progress': ranking.progress,
        'impactPoints': ranking.impactPoints,
      };

      final skillMatrix = PlayerSkillMatrix(
        batting: elite.skillMatrix.batting,
        bowling: elite.skillMatrix.bowling,
        fielding: elite.skillMatrix.fielding,
        fitness: elite.skillMatrix.fitness,
        clutch: elite.skillMatrix.clutch,
        consistency: elite.skillMatrix.consistency,
        captaincy: elite.skillMatrix.captaincy,
      );

      final matches = elite.stats.matches;
      final batting = elite.stats.batting;
      final bowling = elite.stats.bowling;
      final fielding = elite.stats.fielding;

      final fullStats = FullCricketStats(
        ranking: RankingStats(
          lifetimeIp: ranking.impactPoints,
          rankProgressPoints: ranking.progress,
          rankName: rankingLabel,
          matchesPlayed: matches.total,
          matchesWon: matches.wins,
          winRate: matches.winPct,
          winStreak: 0,
        ),
        batting: BattingStats(
          runs: batting.totalRuns,
          ballsFaced: batting.totalBallsFaced,
          average: batting.average,
          strikeRate: batting.strikeRate,
          highestScore: batting.highestScore,
          thirties: batting.thirties,
          fifties: batting.fifties,
          hundreds: batting.hundreds,
          fours: batting.fours,
          sixes: batting.sixes,
          ducks: batting.ducks,
        ),
        bowling: BowlingStats(
          wickets: bowling.totalWickets,
          oversBowled: bowling.totalBallsBowled / 6,
          average: bowling.average,
          economy: bowling.economy,
          strikeRate: bowling.strikeRate,
          bestBowling: bowling.bestBowling,
          threeWicketHauls: bowling.threeWicketHauls,
          fiveWicketHauls: bowling.fiveWicketHauls,
        ),
        fielding: FieldingStats(
          catches: fielding.catches,
          stumpings: fielding.stumpings,
          runOuts: fielding.runOuts,
        ),
        swingIndex: SwingIndexBreakdown(
          overall: ranking.swingIndex.round(),
          batting: skillMatrix.batting.round(),
          bowling: skillMatrix.bowling.round(),
          fielding: skillMatrix.fielding.round(),
          fitness: skillMatrix.fitness.round(),
          clutch: skillMatrix.clutch.round(),
          consistency: skillMatrix.consistency.round(),
          captaincy: skillMatrix.captaincy,
        ),
      );

      final metricValues = _buildMetricValues(
        statsRaw: statsRaw,
        battingRaw: battingRaw,
        bowlingRaw: bowlingRaw,
        bowlingSummary: bowlingSummaryRaw,
        fieldingRaw: fieldingRaw,
        rankingRaw: rankingRaw,
      );

      final performance = PerformanceSnapshot(
        battingImpact: skillMatrix.batting.round(),
        bowlingImpact: skillMatrix.bowling.round(),
        fieldingImpact: skillMatrix.fielding.round(),
        fitness: skillMatrix.fitness.round(),
        clutch: skillMatrix.clutch.round(),
        consistency: skillMatrix.consistency.round(),
        captaincy: skillMatrix.captaincy,
        recentForm: elite.wellness.recoveryScore.round(),
        summary: 'Maintaining a stable profile across all formats.',
      );

      final rankProgress = PlayerRankProgress(
        rank: ranking.rank,
        division: ranking.division.toString(),
        label: rankingLabel,
        impactPoints: ranking.impactPoints,
        seasonPoints: ranking.impactPoints,
        mvpCount: 0,
        progress: ranking.progress / 100,
        pointsToNextRank: math.max(0, 100 - ranking.progress),
        nextRankLabel: 'Next Rank',
        momentumLabel: ranking.progress >= 70 ? 'Rising' : 'Stable',
      );

      final swingSeed = idToFetch.length >= 4 ? idToFetch.substring(0, 4) : idToFetch;
      final swingId = _string(mergedIdentity['swingId'])
          .ifEmpty(swingSeed.isEmpty ? 'SW-0000' : 'SW-${swingSeed.toUpperCase()}');

      final identity = PlayerIdentity(
        id: idToFetch,
        fullName: resolvedName,
        swingId: swingId,
        followersCount: fansCount,
        followingCount: followingCount,
        primaryRole: displayRole,
        battingStyle: displayBattingStyle,
        bowlingStyle: displayBowlingStyle,
        archetype: _deriveArchetype(
          displayRole,
          displayBattingStyle,
          displayBowlingStyle,
        ),
        competitiveTier: rankingLabel,
        level: displayLevel,
        pulseStatus: _derivePulseStatus(
          overallScore: ranking.swingIndex.round(),
          recentForm: elite.wellness.recoveryScore.round(),
        ),
        city: resolvedCity,
        state: resolvedState,
        goal: resolvedGoal,
        bio: resolvedBio,
        avatarUrl: resolvedAvatarUrl,
        coverUrl: resolvedCoverUrl,
      );

      final recentPerformances = _buildRecentPerformances(recentMatches);
      final skillAxes = _buildSkillAxes(
        skillMatrix: skillMatrix,
        performance: performance,
        trend: const <String, dynamic>{},
      );
      final swingIndexSummary = _buildSwingIndexSummaryFromRanking(
        swingIndex: ranking.swingIndex,
        skillMatrix: skillMatrix,
      );

      final academy = _buildAcademy(
        enrollments: enrollments,
        payments: payments,
        liveSession: liveSession,
        feedback: feedback,
        reportCards: <String, dynamic>{},
        card: <String, dynamic>{},
      );

      final unified = UnifiedProfileData(
        identity: ProfileIdentity(
          id: idToFetch,
          name: resolvedName,
          avatarUrl: resolvedAvatarUrl,
          bio: resolvedBio,
          city: resolvedCity,
          state: resolvedState,
          playerRole: displayRole,
          battingStyle: displayBattingStyle,
          bowlingStyle: displayBowlingStyle,
          level: displayLevel,
          fans: fansCount,
          following: followingCount,
        ),
        ranking: ProfileRanking(
          rank: ranking.rank,
          label: rankingLabel,
          division: ranking.division,
          impactPoints: ranking.impactPoints,
          swingIndex: ranking.swingIndex,
          progress: ranking.progress,
        ),
        stats: ProfileStats(
          batting: fullStats.batting,
          bowling: fullStats.bowling,
          fielding: fullStats.fielding,
        ),
        precision: BattingPrecision(
          powerplaySR: elite.precision.powerplaySR,
          middleOversSR: elite.precision.middleOversSR,
          deathOversSR: elite.precision.deathOversSR,
          paceSR: elite.precision.paceSR,
          spinSR: elite.precision.spinSR,
        ),
        badges: elite.badges
            .map(
              (badge) => ProfileBadge(
                id: badge.id,
                name: badge.name,
                description: badge.description,
                category: badge.category,
                isUnlocked: badge.isUnlocked,
                iconUrl: _httpUrl(badge.iconUrl),
                xpReward: badge.xpReward,
                isRare: badge.isRare,
                awardedAt: badge.awardedAt,
              ),
            )
            .toList(growable: false),
        wellness: WellnessData(
          recoveryScore: elite.wellness.recoveryScore,
          oversBowledPastMonth: elite.wellness.oversBowledPastMonth,
          trainingHoursWeekly: elite.wellness.trainingHoursWeekly,
          fatigueLevel: elite.wellness.fatigueLevel,
        ),
        teams: elite.teams
            .map(
              (team) => ProfileTeam(
                id: team.id,
                name: team.name,
                powerScore: team.powerScore,
              ),
            )
            .toList(growable: false),
      );

      final editableProfile = _buildEditableProfile(<String, dynamic>{
        ...normalizedIdentity,
        'dateOfBirth': dateOfBirth,
        'city': resolvedCity,
        'state': resolvedState,
        'playerRole': ProfileFieldMappings.normalizeApiValue(
              ProfileFieldKey.role,
              resolvedRole,
            ) ??
            resolvedRole,
        'battingStyle': ProfileFieldMappings.normalizeApiValue(
              ProfileFieldKey.battingStyle,
              resolvedBattingStyle,
            ) ??
            resolvedBattingStyle,
        'bowlingStyle': ProfileFieldMappings.normalizeApiValue(
              ProfileFieldKey.bowlingStyle,
              resolvedBowlingStyle,
            ) ??
            resolvedBowlingStyle,
        'level': ProfileFieldMappings.normalizeApiValue(
              ProfileFieldKey.level,
              resolvedLevel,
            ) ??
            resolvedLevel,
        'bio': resolvedBio,
      });

      final viewerContextNode = _map(bootstrapSocial['viewerContext']);

      return PlayerProfilePageData(
        identity: identity,
        heroStats: _buildHeroStatsFromStats(fullStats),
        performance: performance,
        fullStats: fullStats,
        metricValues: metricValues,
        rankProgress: rankProgress,
        seasonProgress: _buildSeasonProgress(rankProgress.seasonPoints),
        skillMatrix: skillMatrix,
        skillAxes: skillAxes,
        insights: _buildInsights(
          identity: identity,
          fullStats: fullStats,
          performance: performance,
          skillAxes: skillAxes,
        ),
        trophies: _buildTrophies(
          identity: identity,
          fullStats: fullStats,
          rankProgress: rankProgress,
          recentPerformances: recentPerformances,
        ),
        recentPerformances: recentPerformances,
        academy: academy,
        account: _buildAccountActions(isOwnProfile, academy.isLinked),
        editableProfile: editableProfile,
        isProfileComplete: _isProfileComplete(<String, dynamic>{
          ...mergedIdentity,
          'dateOfBirth': dateOfBirth,
          'city': resolvedCity,
          'playerRole': resolvedRole,
        }),
        unified: unified,
        showcase: const [],
        notificationSummary: isOwnProfile
            ? const ProfileNotificationSummary(
                unreadNotificationCount: 0,
                unreadConversationCount: 0,
                unreadMessageCount: 0,
              )
            : null,
        swingIndexSummary: swingIndexSummary,
        viewerContext: PlayerViewerContext(
          isSelf: _bool(viewerContextNode['isSelf'], fallback: isOwnProfile),
          following:
              _bool(viewerContextNode['following']) || elite.isFollowing,
          directConversationId:
              _string(viewerContextNode['directConversationId'])
                      .ifEmptyToNull() ??
                  elite.directConversationId,
        ),
      );
    } catch (e, stack) {
      final is401 = e is DioException && e.response?.statusCode == 401;
      if (kDebugMode && !is401) {
        debugPrint('ProfileRepo: Global Error: $e');
        debugPrint(stack.toString());
      }
      rethrow;
    }
  }

  List<ProfileKeyStat> _buildHeroStatsFromStats(FullCricketStats stats) {
    return [
      ProfileKeyStat(
          label: 'Matches', value: stats.ranking.matchesPlayed.toString()),
      ProfileKeyStat(
          label: 'Avg', value: _formatDecimal(stats.batting.average)),
      ProfileKeyStat(
          label: 'SR', value: _formatDecimal(stats.batting.strikeRate)),
      ProfileKeyStat(label: 'Wkts', value: stats.bowling.wickets.toString()),
      ProfileKeyStat(
          label: 'Econ', value: _formatDecimal(stats.bowling.economy)),
    ];
  }

  Map<String, Object?> _buildMetricValues({
    required Map<String, dynamic> statsRaw,
    required Map<String, dynamic> battingRaw,
    required Map<String, dynamic> bowlingRaw,
    required Map<String, dynamic> bowlingSummary,
    required Map<String, dynamic> fieldingRaw,
    required Map<String, dynamic> rankingRaw,
  }) {
    final index = <String, Object?>{};

    void collect(dynamic node) {
      if (node is Map<String, dynamic>) {
        node.forEach((key, value) {
          if (value is Map<String, dynamic> || value is List) {
            collect(value);
          } else {
            index.putIfAbsent(key, () => value);
          }
        });
      } else if (node is List) {
        for (final item in node) {
          collect(item);
        }
      }
    }

    collect(statsRaw);
    collect(battingRaw);
    collect(bowlingRaw);
    collect(fieldingRaw);

    Object? pick(String key, [List<String> aliases = const []]) {
      if (index.containsKey(key)) return index[key];
      for (final alias in aliases) {
        if (index.containsKey(alias)) return index[alias];
      }
      return null;
    }

    String? bestBowlingFigure;
    final bestWickets = pick('bestBowlingWickets');
    final bestRuns = pick('bestBowlingRuns');
    if (bestWickets != null && bestRuns != null) {
      bestBowlingFigure = '${_int(bestWickets)}/${_int(bestRuns)}';
    } else {
      final existing = pick('bestBowlingFigure', ['bestBowling']);
      bestBowlingFigure = existing == null ? null : '$existing';
    }

    final matchesPlayed = _int(pick('matchesPlayed', [
      'totalMatches',
      'total',
    ]));
    final matchesWon = _int(pick('matchesWon', [
      'wins',
    ]));
    final matchesLost = _int(pick('losses', [
      'matchesLost',
    ]));
    final winPctRaw = pick('winPct');
    final computedWinPct = matchesPlayed == 0
        ? 0.0
        : (matchesWon / math.max(1, matchesPlayed)) * 100;
    final winPct = winPctRaw == null
        ? computedWinPct
        : (winPctRaw is num
            ? winPctRaw.toDouble()
            : double.tryParse('$winPctRaw') ?? computedWinPct);

    return {
      'battingInnings': pick('battingInnings', ['innings', 'totalInnings']),
      'notOuts': pick('notOuts'),
      'totalRuns': pick('totalRuns', ['runs']),
      'totalBallsFaced': pick('totalBallsFaced', ['totalBalls', 'ballsFaced']),
      'totalFours': pick('totalFours', ['fours']),
      'totalSixes': pick('totalSixes', ['sixes']),
      'totalBoundaries': pick('totalBoundaries'),
      'boundaryRuns': pick('boundaryRuns'),
      'highestScore': pick('highestScore'),
      'battingDismissals': pick('battingDismissals', ['dismissals']),
      'battingAverage': pick('battingAverage', ['average']),
      'strikeRate': pick('strikeRate'),
      'runsPerInnings': pick('runsPerInnings'),
      'ballsPerDismissal': pick('ballsPerDismissal'),
      'boundaryPerBall': pick('boundaryPerBall'),
      'ballsPerBoundary': pick('ballsPerBoundary'),
      'boundaryRunPct': pick('boundaryRunPct'),
      'dotBallPctBat': pick('dotBallPctBat'),
      'singlesPctBat': pick('singlesPctBat'),
      'scoringShotPct': pick('scoringShotPct'),
      'thirties': pick('thirties'),
      'forties': pick('forties'),
      'fifties': pick('fifties'),
      'hundreds': pick('hundreds'),
      'ducks': pick('ducks'),
      'fiftyPlusInningsPct': pick('fiftyPlusInningsPct'),
      'hundredConversionFromFiftyPct': pick('hundredConversionFromFiftyPct'),
      'thirtyToFiftyConversionPct': pick('thirtyToFiftyConversionPct'),
      'fiftyToHundredConversionPct': pick('fiftyToHundredConversionPct'),
      'maxBoundariesInInnings': pick('maxBoundariesInInnings'),
      'powerplayRuns': pick('powerplayRuns'),
      'powerplayBalls': pick('powerplayBalls'),
      'powerplaySR': pick('powerplaySR'),
      'middleRuns': pick('middleRuns'),
      'middleBalls': pick('middleBalls'),
      'middleSR': pick('middleSR'),
      'deathRuns': pick('deathRuns'),
      'deathBalls': pick('deathBalls'),
      'deathSR': pick('deathSR'),
      'deathBoundaryPerBall': pick('deathBoundaryPerBall'),
      'vsPaceRuns': pick('vsPaceRuns'),
      'vsPaceBalls': pick('vsPaceBalls'),
      'vsPaceSR': pick('vsPaceSR', ['paceSR']),
      'vsSpinRuns': pick('vsSpinRuns'),
      'vsSpinBalls': pick('vsSpinBalls'),
      'vsSpinSR': pick('vsSpinSR', ['spinSR']),
      'vsLeftArmPaceSR': pick('vsLeftArmPaceSR'),
      'vsRightArmPaceSR': pick('vsRightArmPaceSR'),
      'vsOffSpinSR': pick('vsOffSpinSR'),
      'vsLegSpinSR': pick('vsLegSpinSR'),
      'bowlingInnings': pick('bowlingInnings'),
      'totalBallsBowled':
          pick('totalBallsBowled', ['ballsBowled', 'totalBalls']),
      'totalOvers': pick('totalOvers', ['oversBowled']),
      'totalWickets': pick('totalWickets', ['wickets']),
      'totalRunsConceded': pick('totalRunsConceded'),
      'maidens': pick('maidens'),
      'dotBallsBowled': pick('dotBallsBowled'),
      'wides': pick('wides'),
      'noBalls': pick('noBalls'),
      'legalDeliveriesPct': pick('legalDeliveriesPct'),
      'bowlingAverage': pick('bowlingAverage', ['average']),
      'economyRate': pick('economyRate', ['economy']),
      'bowlingStrikeRate': pick('bowlingStrikeRate', ['strikeRate']),
      'wicketsPerMatch': pick('wicketsPerMatch'),
      'wicketsPerInnings': pick('wicketsPerInnings'),
      'dotBallPctBowl': pick('dotBallPctBowl'),
      'boundariesConceded': pick('boundariesConceded'),
      'boundaryConcededPct': pick('boundaryConcededPct'),
      'ballsPerBoundaryConceded': pick('ballsPerBoundaryConceded'),
      'controlBallPct': pick('controlBallPct'),
      'bestBowlingWickets': pick('bestBowlingWickets'),
      'bestBowlingRuns': pick('bestBowlingRuns'),
      'bestBowlingFigure': bestBowlingFigure,
      'threeWicketHauls': pick('threeWicketHauls', ['threeWHauls', '3wHauls']),
      'fourWicketHauls': pick('fourWicketHauls', ['fourWHauls', '4wHauls']),
      'fiveWicketHauls': pick('fiveWicketHauls', ['fiveWHauls', '5wHauls']),
      'wicketsBowled': pick('wicketsBowled'),
      'wicketsLBW': pick('wicketsLBW'),
      'wicketsCaught': pick('wicketsCaught'),
      'otherWickets': pick('otherWickets'),
      'ppBallsBowled': pick('ppBallsBowled'),
      'ppRunsConceded': pick('ppRunsConceded'),
      'ppEconomy': pick('ppEconomy'),
      'middleBallsBowled': pick('middleBallsBowled'),
      'middleRunsConceded': pick('middleRunsConceded'),
      'middleEconomy': pick('middleEconomy'),
      'deathBallsBowled': pick('deathBallsBowled'),
      'deathRunsConceded': pick('deathRunsConceded'),
      'deathEconomy': pick('deathEconomy'),
      'deathWickets': pick('deathWickets'),
      'catches': pick('catches'),
      'runOutDirect': pick('runOutDirect'),
      'runOutAssist': pick('runOutAssist'),
      'stumpings': pick('stumpings'),
      'totalDismissalInvolvements': pick('totalDismissalInvolvements'),
      'catchesPerMatch': pick('catchesPerMatch'),
      'runOutInvolvementPerMatch': pick('runOutInvolvementPerMatch'),
      'stumpingsPerKeepingInnings': pick('stumpingsPerKeepingInnings'),
      'missedChances': pick('missedChances'),
      'dismissalInvolvementPerMatch': pick('dismissalInvolvementPerMatch'),
      'matchesPlayed': matchesPlayed,
      'matchesWon': matchesWon,
      'matchesLost': matchesLost,
      'winPct': winPct,
      'chaseMatches': pick('chaseMatches'),
      'chaseWins': pick('chaseWins'),
      'defendMatches': pick('defendMatches'),
      'defendWins': pick('defendWins'),
      'knockoutMatches': pick('knockoutMatches'),
      'knockoutImpactAvg': pick('knockoutImpactAvg'),
      'mvpCount': pick('mvpCount'),
      'last5Runs': pick('last5Runs'),
      'last5Wickets': pick('last5Wickets'),
      'last5BatAvg': pick('last5BatAvg'),
      'last5BatSR': pick('last5BatSR'),
      'last5Economy': pick('last5Economy'),
      'last10Runs': pick('last10Runs'),
      'last10Wickets': pick('last10Wickets'),
      'runsStdDev': pick('runsStdDev'),
      'wicketsStdDev': pick('wicketsStdDev'),
      'consistencyIndex': pick('consistencyIndex'),
      'rankProgressPoints': rankingRaw['progress'],
      'lifetimeImpactPoints': rankingRaw['impactPoints'],
    };
  }

  Future<bool> followPlayer(String profileId) async {
    await _client.post(ApiEndpoints.playerFollow(profileId));
    return true;
  }

  Future<bool> unfollowPlayer(String profileId) async {
    await _client.delete(ApiEndpoints.playerFollow(profileId));
    return false;
  }

  Future<void> updateProfile(PlayerProfileUpdateRequest request) async {
    final payload = ProfileUpdatePayloadTransformer.toApi(request);
    try {
      await _client.put(ApiEndpoints.playerProfile, data: payload);
      return;
    } on DioException catch (error) {
      _debugDioException('updateProfile', error, payload: payload);
      final level = payload['level'];
      if ((error.response?.statusCode == 400 ||
              error.response?.statusCode == 422) &&
          level is String) {
        final legacyLevel = ProfileFieldMappings.legacyLevelFallback(level);
        if (legacyLevel != null && legacyLevel != level) {
          final fallbackPayload = <String, dynamic>{
            ...payload,
            'level': legacyLevel,
          };
          try {
            await _client.put(ApiEndpoints.playerProfile, data: fallbackPayload);
            return;
          } on DioException catch (fallbackError) {
            _debugDioException(
              'updateProfile(legacy-level-fallback)',
              fallbackError,
              payload: fallbackPayload,
            );
            rethrow;
          }
        }
      }
      rethrow;
    }
  }

  Future<String> updateAvatar(String avatarUrl) async {
    try {
      final response = await _client.put(
        ApiEndpoints.playerProfileAvatar,
        data: {
          'avatarUrl': avatarUrl.trim(),
          'avatar_url': avatarUrl.trim(),
        },
      );
      final payload = _unwrapMap(response);
      final data = _map(payload['data']);
      final resolved = _httpUrl(data['avatarUrl']) ?? avatarUrl.trim();
      return resolved;
    } on DioException catch (error) {
      throw DioException(
        requestOptions: error.requestOptions,
        response: error.response,
        error: 'Avatar upload failed: ${error.message}',
        stackTrace: error.stackTrace,
        type: error.type,
      );
    }
  }

  Future<String> startDirectConversation(String profileId) async {
    final response = await _client.post(
      '/v1/chat/direct',
      data: {'targetProfileId': profileId},
    );
    final data = _unwrapMap(response);
    return _string(data['id']);
  }

  Future<List<CitySuggestion>> searchCities(String query,
      {int limit = 10}) async {
    final response = await _client.get(
      ApiEndpoints.publicCities,
      queryParameters: {'q': query, 'limit': limit},
    );
    final payload = _map(response.data);
    final data = _map(payload['data']);
    final items = _list(data['items'].isEmpty ? payload['items'] : data['items']);
    return items
        .map((m) => CitySuggestion(
              city: _string(m['city']),
              state: _string(m['state']),
            ))
        .toList();
  }

  List<AccountAction> _buildAccountActions(
      bool isOwnProfile, bool academyLinked) {
    if (!isOwnProfile) return const [];
    return [
      const AccountAction(
        id: 'subscription',
        label: 'Subscription',
        subtitle: 'Manage membership and premium access',
      ),
      const AccountAction(
        id: 'support',
        label: 'Help & Support',
        subtitle: 'Contact support and resolve account issues',
      ),
      const AccountAction(
        id: 'logout',
        label: 'Logout',
        subtitle: 'Sign out from this device',
      ),
    ];
  }

  String _deriveArchetype(
      String role, String battingStyle, String bowlingStyle) {
    if (role == 'All Rounder') return 'Two-phase competitor';
    if (role == 'Bowler' && bowlingStyle.toLowerCase().contains('spin')) {
      return 'Pressure builder';
    }
    if (role == 'Bowler') return 'Rhythm enforcer';
    if (role.contains('Wicket Keeper')) return 'Game reader';
    if (battingStyle == 'Left Hand') return 'Angle disruptor';
    return 'Front-foot shotmaker';
  }

  String _derivePulseStatus(
      {required int overallScore, required int recentForm}) {
    if (overallScore >= 75 && recentForm >= 72) return 'Locked In';
    if (overallScore >= 60) return 'Rising';
    if (recentForm < 40) return 'Rebuilding';
    return 'Finding Form';
  }

  // ... rest of private helpers (mapping, parsing, etc.)
  Future<dynamic> _safeGet(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _client.get(path, queryParameters: queryParameters);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) rethrow;
      if (kDebugMode) debugPrint('[Profile] _safeGet failed $path → $e');
      return null;
    }
  }

  Map<String, dynamic> _unwrapMap(dynamic response) {
    if (response == null) return <String, dynamic>{};
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      return inner is Map<String, dynamic> ? inner : data;
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _unwrapListResponse(dynamic response) {
    if (response == null) return const [];
    final data = response.data;
    // Direct array response
    if (data is List) return data.whereType<Map<String, dynamic>>().toList();
    if (data is Map<String, dynamic>) {
      // { data: [...] } or { badges: [...] } or { items: [...] }
      for (final key in ['data', 'badges', 'items']) {
        final inner = data[key];
        if (inner is List) {
          return inner.whereType<Map<String, dynamic>>().toList();
        }
      }
    }
    return const [];
  }

  List<Map<String, dynamic>> _unwrapPayments(dynamic response) {
    if (response == null) return const [];
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is Map<String, dynamic>) {
        final payments = inner['payments'];
        if (payments is List) {
          return payments.whereType<Map<String, dynamic>>().toList();
        }
      }
    }
    return const [];
  }

  Map<String, dynamic> _map(dynamic value) =>
      value is Map<String, dynamic> ? value : <String, dynamic>{};
  List<dynamic> _list(dynamic value) => value is List ? value : const [];
  String _string(dynamic value, {String fallback = ''}) =>
      (value is String && value.trim().isNotEmpty) ? value.trim() : fallback;
  bool _bool(dynamic value, {bool fallback = false}) =>
      value is bool ? value : fallback;
  dynamic _firstNonNull(List<dynamic> values) {
    for (final value in values) {
      if (value != null) return value;
    }
    return null;
  }

  int _int(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
    }
    return 0;
  }

  int? _intOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  Future<({int followers, int following})> _resolveFollowCounts(
      String profileId) async {
    int followers = 0;
    int following = 0;

    try {
      final res = await _client.get(
        ApiEndpoints.playerFollowers,
        queryParameters: {'playerId': profileId},
      );
      followers = _extractFollowCount(res.data, mode: 'followers');
    } catch (_) {}

    try {
      final res = await _client.get(
        ApiEndpoints.playerFollowing,
        queryParameters: {'playerId': profileId},
      );
      following = _extractFollowCount(res.data, mode: 'following');
    } catch (_) {}

    return (followers: followers, following: following);
  }

  int _extractFollowCount(dynamic body, {required String mode}) {
    if (body is List) return body.length;
    if (body is! Map<String, dynamic>) return 0;

    int extractNumericCount(Map<String, dynamic> map) {
      final keys = mode == 'followers'
          ? ['followersCount', 'followers', 'count', 'total', 'totalCount']
          : ['followingCount', 'following', 'count', 'total', 'totalCount'];

      for (final key in keys) {
        final value = map[key];
        if (value is num || value is String) {
          return _int(value);
        }
      }

      final meta = _map(map['meta']);
      if (meta.isNotEmpty) {
        for (final key in ['count', 'total', 'totalCount']) {
          final value = meta[key];
          if (value is num || value is String) return _int(value);
        }
      }

      final pagination = _map(map['pagination']);
      if (pagination.isNotEmpty) {
        for (final key in ['total', 'count', 'totalCount']) {
          final value = pagination[key];
          if (value is num || value is String) return _int(value);
        }
      }

      return -1;
    }

    int extractListCount(Map<String, dynamic> map) {
      final dataNode = map['data'];
      if (dataNode is List) return dataNode.length;
      if (dataNode is Map<String, dynamic>) {
        final inner = dataNode['data'] ??
            dataNode[mode] ??
            dataNode['players'] ??
            dataNode['items'] ??
            dataNode['results'];
        if (inner is List) return inner.length;
      }
      final rootList =
          map[mode] ?? map['players'] ?? map['items'] ?? map['results'];
      if (rootList is List) return rootList.length;
      return 0;
    }

    final explicit = extractNumericCount(body);
    final fromList = extractListCount(body);
    if (explicit < 0) return fromList;
    return explicit > fromList ? explicit : fromList;
  }

  void _debugDioException(
    String operation,
    DioException error, {
    Map<String, dynamic>? payload,
  }) {
    if (!kDebugMode) return;
    final status = error.response?.statusCode;
    final path = error.requestOptions.path;
    final method = error.requestOptions.method;
    final message = error.message ?? 'Unknown DioException';
    final responseBody = error.response?.data;
    debugPrint(
      '[Profile][$operation] DioException $method $path '
      'status=$status message=$message',
    );
    if (payload != null) {
      debugPrint('[Profile][$operation] payload=$payload');
    }
    debugPrint('[Profile][$operation] response=$responseBody');
  }

  String? _dateOnlyString(dynamic value) {
    final raw = _string(value);
    if (raw.isEmpty) return null;
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;
    return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
  }

  String _formatDecimal(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);

  AcademySummary _buildAcademy({
    required List<Map<String, dynamic>> enrollments,
    required List<Map<String, dynamic>> payments,
    required Map<String, dynamic> card,
    required Map<String, dynamic> feedback,
    required Map<String, dynamic> reportCards,
    required Map<String, dynamic> liveSession,
  }) {
    final enrollment =
        enrollments.isNotEmpty ? enrollments.first : <String, dynamic>{};
    final enrollmentAcademy = _map(enrollment['academy']);
    final enrollmentId = _string(enrollment['enrollmentId'],
        fallback: _string(enrollment['id']));
    final linked = _string(enrollmentAcademy['name']).isNotEmpty;

    return AcademySummary(
      isLinked: linked,
      enrollmentId: enrollmentId.isEmpty ? null : enrollmentId,
      academyName: linked ? _string(enrollmentAcademy['name']) : null,
      academyCity: _string(enrollmentAcademy['city']).ifEmptyToNull(),
      coachName: null,
      batchName: null,
      batchSchedule: null,
      feeAmountPaise: 0,
      feePaidPaise: 0,
      feeDuePaise: 0,
      feeFrequency: null,
      feeStatus: null,
      transactions: const [],
      nextSessionLabel: null,
      latestReportSummary: null,
      joinCtaLabel: linked ? 'Academy linked' : 'Join Academy',
    );
  }

  PlayerProfileUpdateRequest _buildEditableProfile(
      Map<String, dynamic> profile) {
    final rawDays = _list(profile['availableDays']);
    final rawTimes = _list(profile['preferredTimes']);
    final radius = _int(profile['locationRadius']);
    return PlayerProfileUpdateRequest(
      name: _string(profile['fullName']).ifEmptyToNull() ??
          _string(profile['name']).ifEmptyToNull(),
      username: _string(profile['username']).ifEmptyToNull(),
      dateOfBirth: _dateOnlyString(profile['dateOfBirth']),
      gender: _string(profile['gender']).ifEmptyToNull(),
      city: _string(profile['city']),
      state: _string(profile['state']),
      jerseyNumber: _intOrNull(profile['jerseyNumber']) ??
          _intOrNull(profile['jerseyNo']),
      playerRole: ProfileFieldMappings.normalizeApiValue(
            ProfileFieldKey.role,
            _string(profile['playerRole']),
          ) ??
          _string(profile['playerRole']).ifEmptyToNull(),
      battingStyle: ProfileFieldMappings.normalizeApiValue(
            ProfileFieldKey.battingStyle,
            _string(profile['battingStyle']),
          ) ??
          _string(profile['battingStyle']).ifEmptyToNull(),
      bowlingStyle: ProfileFieldMappings.normalizeApiValue(
            ProfileFieldKey.bowlingStyle,
            _string(profile['bowlingStyle']),
          ) ??
          _string(profile['bowlingStyle']).ifEmptyToNull(),
      level: ProfileFieldMappings.normalizeApiValue(
            ProfileFieldKey.level,
            _string(profile['level']),
          ) ??
          _string(profile['level']).ifEmptyToNull(),
      goals: _string(profile['goals']),
      bio: _string(profile['bio']),
      isPublic: _bool(profile['isPublic'], fallback: true),
      availableDays:
          rawDays.map((e) => e.toString()).toList(growable: false),
      preferredTimes:
          rawTimes.map((e) => e.toString()).toList(growable: false),
      locationRadius: radius > 0 ? radius : 10,
      showStats: _bool(profile['showStats'], fallback: true),
      showLocation: _bool(profile['showLocation'], fallback: false),
      scoutingOptIn: _bool(profile['scoutingOptIn'], fallback: false),
    );
  }

  bool _isProfileComplete(Map<String, dynamic> profile) =>
      _string(profile['dateOfBirth']).isNotEmpty &&
      _string(profile['city']).isNotEmpty &&
      _string(profile['playerRole']).isNotEmpty;

  Future<List<PlayerMatch>> _safeLoadRecentMatches() async {
    try {
      return await _matchesRepository.loadMyMatches();
    } catch (_) {
      return const <PlayerMatch>[];
    }
  }

  List<PlayerRecentPerformance> _buildRecentPerformances(
          List<PlayerMatch> matches) =>
      []; // Simplified for now

  List<PlayerSkillAxis> _buildSkillAxes(
      {required PlayerSkillMatrix skillMatrix,
      required PerformanceSnapshot performance,
      required Map<String, dynamic> trend}) {
    return [
      PlayerSkillAxis(
        key: 'batting',
        label: 'Batting',
        value: skillMatrix.batting,
      ),
      PlayerSkillAxis(
        key: 'bowling',
        label: 'Bowling',
        value: skillMatrix.bowling,
      ),
      PlayerSkillAxis(
        key: 'fielding',
        label: 'Fielding',
        value: skillMatrix.fielding,
      ),
      PlayerSkillAxis(
        key: 'fitness',
        label: 'Fitness',
        value: skillMatrix.fitness,
      ),
      PlayerSkillAxis(
        key: 'clutch',
        label: 'Clutch',
        value: skillMatrix.clutch,
      ),
      PlayerSkillAxis(
        key: 'consistency',
        label: 'Consistency',
        value: skillMatrix.consistency,
      ),
      PlayerSkillAxis(
        key: 'captaincy',
        label: 'Captaincy',
        value: skillMatrix.captaincy,
        isLocked: skillMatrix.captaincy == null,
        lockedText:
            skillMatrix.captaincy == null ? 'No captain data yet' : null,
      ),
    ];
  }

  SwingIndexSummary _buildSwingIndexSummaryFromRanking({
    required double swingIndex,
    required PlayerSkillMatrix skillMatrix,
  }) {
    final axes = <String, double>{
      SwingIndexAxisKeys.reliabilityAxis: skillMatrix.consistency,
      SwingIndexAxisKeys.powerAxis: skillMatrix.batting,
      SwingIndexAxisKeys.bowlingAxis: skillMatrix.bowling,
      SwingIndexAxisKeys.fieldingAxis: skillMatrix.fielding,
      SwingIndexAxisKeys.impactAxis: skillMatrix.clutch,
    };
    final ordered = axes.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));

    final strengths = ordered
        .take(2)
        .map((entry) => SwingIndexInsight(key: entry.key, score: entry.value))
        .toList(growable: false);
    final weakestAreas = ordered
        .reversed
        .take(2)
        .map((entry) => SwingIndexInsight(key: entry.key, score: entry.value))
        .toList(growable: false);

    return SwingIndexSummary(
      swingIndexScore: swingIndex.clamp(0, 100).toDouble(),
      axes: axes,
      strengths: strengths,
      weakestAreas: weakestAreas,
    );
  }

  PlayerProfileInsights _buildInsights(
      {required PlayerIdentity identity,
      required FullCricketStats fullStats,
      required PerformanceSnapshot performance,
      required List<PlayerSkillAxis> skillAxes}) {
    return const PlayerProfileInsights(
        strengths: [], workOns: [], summary: 'Profile analysis active.');
  }

  List<PlayerTrophy> _buildTrophies(
          {required PlayerIdentity identity,
          required FullCricketStats fullStats,
          required PlayerRankProgress rankProgress,
          required List<PlayerRecentPerformance> recentPerformances}) =>
      [];

  SeasonProgress _buildSeasonProgress(int seasonPoints) => SeasonProgress(
      title: 'Season',
      summary: '',
      currentPoints: seasonPoints,
      progress: 0.5,
      nextRewardLabel: '',
      nextMilestonePoints: 1000,
      milestones: []);

  /// Returns the URL only if it's a real http/https URL — filters out data: URIs
  /// that the backend generates as SVG placeholders.
  String? _httpUrl(dynamic value) {
    final s = _string(value);
    if (s.isEmpty) return null;
    if (s.startsWith('http://') || s.startsWith('https://')) return s;
    return null;
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
  String? ifEmptyToNull() => trim().isEmpty ? null : this;
}
