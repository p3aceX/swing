import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/base_repository.dart';
import '../domain/match_models.dart';

class MatchesRepository extends BaseRepository {
  final _client = ApiClient.instance.dio;

  Stream<List<PlayerMatch>> loadMyMatchesStream() async* {
    const path = ApiEndpoints.playerMatches;
    final cacheKey = generateCacheKey(path);

    final cached = getCached(cacheKey);
    if (cached != null) {
      final items = _unwrapListResponse(cached);
      final now = DateTime.now();
      yield items
          .map((item) => _mapMatch(item, now))
          .where((match) => match.id.isNotEmpty || match.title != 'Match')
          .toList();
    }

    try {
      final response = await _client.get(path);
      final items = _unwrapListResponse(response.data);
      final now = DateTime.now();
      yield items
          .map((item) => _mapMatch(item, now))
          .where((match) => match.id.isNotEmpty || match.title != 'Match')
          .toList();
    } catch (e) {
      if (cached == null) rethrow;
    }
  }

  Future<List<PlayerMatch>> loadMyMatches() async {
    final response = await _client.get(ApiEndpoints.playerMatches);
    final items = _unwrapListResponse(response.data);
    final now = DateTime.now();

    return items
        .map((item) => _mapMatch(item, now))
        .where((match) => match.id.isNotEmpty || match.title != 'Match')
        .toList();
  }

  Future<List<PlayerMatch>> loadPublicPlayerMatches(
    String playerId, {
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      debugPrint('[PublicMatches] → GET /player/profile/$playerId/matches'
          '?limit=$limit&offset=$offset');
      final response = await _client.get(
        ApiEndpoints.publicPlayerMatches(playerId),
        queryParameters: {'limit': limit, 'offset': offset},
      );
      debugPrint('[PublicMatches] ← status ${response.statusCode}');
      debugPrint('[PublicMatches] raw body: ${response.data}');

      final items = _unwrapListResponse(response.data);
      debugPrint('[PublicMatches] unwrapped ${items.length} items');

      final now = DateTime.now();
      final mapped = <PlayerMatch>[];
      for (var i = 0; i < items.length; i++) {
        final raw = items[i];
        debugPrint('[PublicMatches] item[$i] keys: ${raw.keys.toList()}');
        debugPrint('[PublicMatches] item[$i] match keys: '
            '${_map(raw["match"]).keys.toList()}');
        final m = _mapMatch(raw, now);
        debugPrint('[PublicMatches] item[$i] → id="${m.id}" '
            'title="${m.title}" lifecycle=${m.lifecycle}');
        // Keep all items; a missing id is a backend data issue, not a signal to drop
        if (m.id.isNotEmpty) mapped.add(m);
      }
      debugPrint('[PublicMatches] returning ${mapped.length} matches');
      return mapped;
    } on DioException catch (e) {
      debugPrint('[PublicMatches] DioException: '
          'status=${e.response?.statusCode} msg=${e.message}');
      debugPrint('[PublicMatches] body: ${e.response?.data}');
      if (e.response?.statusCode == 404) throw const PlayerNotFoundException();
      rethrow;
    } catch (e, st) {
      debugPrint('[PublicMatches] unexpected error: $e\n$st');
      rethrow;
    }
  }

  Future<List<PlayerMatch>> loadTeamMatches(String teamId) async {
    debugPrint('[TeamMatches] → GET /player/teams/$teamId/matches');
    final response = await _client.get(
      ApiEndpoints.playerTeamMatches(teamId),
      queryParameters: {'limit': 50},
    );
    debugPrint('[TeamMatches] ← ${response.statusCode}');
    final items = _unwrapListResponse(response.data);
    debugPrint('[TeamMatches] ${items.length} items');
    final now = DateTime.now();
    final result = <PlayerMatch>[];
    for (var i = 0; i < items.length; i++) {
      final raw = Map<String, dynamic>.from(items[i]);

      // ── Normalise flat team-matches shape to what _mapMatch expects ──────
      // Status
      if (_string(raw['status']).isEmpty) {
        final hasWinner = _string(raw['winnerId']).isNotEmpty;
        final hasCompletedAt = _string(raw['completedAt']).isNotEmpty;
        if (hasWinner || hasCompletedAt) raw['status'] = 'COMPLETED';
      }
      // Date: expose completedAt as scheduledAt for sorting
      if (_string(raw['scheduledAt']).isEmpty &&
          _string(raw['completedAt']).isNotEmpty) {
        raw['scheduledAt'] = raw['completedAt'];
      }
      // Team names → objects so _entityName resolves them
      if (_string(raw['teamAName']).isNotEmpty && raw['teamA'] == null) {
        raw['teamA'] = {'name': raw['teamAName']};
      }
      if (_string(raw['teamBName']).isNotEmpty && raw['teamB'] == null) {
        raw['teamB'] = {'name': raw['teamBName']};
      }
      // Which side is the current player's team?
      if (_string(raw['teamSide']).isNotEmpty && raw['team'] == null) {
        raw['team'] = raw['teamSide']; // 'A' or 'B'
      }
      // winnerId may be a full team name instead of "A"/"B".
      // Resolve it to the side letter so _deriveResult works correctly.
      final winnerId = _string(raw['winnerId']);
      if (winnerId.isNotEmpty &&
          winnerId != 'A' &&
          winnerId != 'B' &&
          winnerId != 'DRAW' &&
          winnerId != 'TIE') {
        final teamAName = _string(raw['teamAName']);
        final teamBName = _string(raw['teamBName']);
        if (teamAName.isNotEmpty &&
            winnerId.toLowerCase() == teamAName.toLowerCase()) {
          raw['winnerId'] = 'A';
        } else if (teamBName.isNotEmpty &&
            winnerId.toLowerCase() == teamBName.toLowerCase()) {
          raw['winnerId'] = 'B';
        }
      }
      // Venue
      if (_string(raw['venueName']).isNotEmpty && raw['venue'] == null) {
        raw['venue'] = {'name': raw['venueName']};
      }
      // Format
      if (_string(raw['format']).isNotEmpty && raw['formatLabel'] == null) {
        raw['formatLabel'] = raw['format'];
      }

      final m = _mapMatch(raw, now);
      debugPrint(
        '[TeamMatches] [$i] id=${m.id} '
        'winnerId="${_string(raw["winnerId"])}" '
        'completedAt="${_string(raw["completedAt"])}" '
        '→ lifecycle=${m.lifecycle.name}',
      );
      if (m.id.isNotEmpty || m.title != 'Match') result.add(m);
    }
    return result;
  }

  Future<MatchCenter> loadMatchCenter(String matchId) async {
    final scorecardResponse = await _client.get(
      ApiEndpoints.matchScorecard(matchId),
    );
    final scorecardRoot = _unwrapMapResponse(scorecardResponse.data);

    Map<String, dynamic> matchRoot = const <String, dynamic>{};
    Map<String, dynamic> playersRoot = const <String, dynamic>{};
    Map<String, dynamic> previewRoot = const <String, dynamic>{};
    Map<String, dynamic> overlayRoot = const <String, dynamic>{};
    var overlayLoaded = false;

    Future<Map<String, dynamic>> safeMapRequest(String path) async {
      try {
        final response = await _client.get(path);
        return _unwrapMapResponse(response.data);
      } catch (_) {
        return const <String, dynamic>{};
      }
    }

    await Future.wait([
      safeMapRequest(ApiEndpoints.matchById(matchId))
          .then((value) => matchRoot = value),
      safeMapRequest(ApiEndpoints.matchPlayers(matchId))
          .then((value) => playersRoot = value),
      safeMapRequest(ApiEndpoints.matchPreview(matchId))
          .then((value) => previewRoot = value),
      safeMapRequest(ApiEndpoints.publicOverlay(matchId)).then((value) {
        overlayRoot = value;
        overlayLoaded = value.isNotEmpty;
      }),
    ]);

    return _mapMatchCenter(
      scorecardRoot: scorecardRoot,
      matchRoot: matchRoot,
      playersRoot: playersRoot,
      previewRoot: previewRoot,
      overlayRoot: overlayRoot,
      overlayLoaded: overlayLoaded,
      requestedId: matchId,
      now: DateTime.now(),
    );
  }

  Stream<String> watchLiveOverlay(String matchId) {
    final controller = StreamController<String>();
    CancelToken? cancelToken;
    var closed = false;

    Future<void> pump() async {
      while (!closed) {
        cancelToken = CancelToken();
        try {
          final response = await _client.get<ResponseBody>(
            ApiEndpoints.publicOverlayStream(matchId),
            cancelToken: cancelToken,
            options: Options(
              responseType: ResponseType.stream,
              receiveTimeout: Duration.zero,
              headers: const {
                'Accept': 'text/event-stream',
                'Cache-Control': 'no-cache',
              },
            ),
          );

          final body = response.data;
          if (body == null) {
            throw StateError('Live stream unavailable');
          }

          var eventName = 'message';
          final dataLines = <String>[];

          await for (final line in body.stream
              .map((chunk) => chunk.toList(growable: false))
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
            if (closed) break;

            if (line.isEmpty) {
              if (eventName == 'overlay' && dataLines.isNotEmpty) {
                controller.add(dataLines.join('\n'));
              }
              eventName = 'message';
              dataLines.clear();
              continue;
            }

            if (line.startsWith(':')) {
              continue;
            }
            if (line.startsWith('event:')) {
              eventName = line.substring(6).trim();
              continue;
            }
            if (line.startsWith('data:')) {
              dataLines.add(line.substring(5).trimLeft());
            }
          }
        } on DioException catch (error, stackTrace) {
          if (CancelToken.isCancel(error) || closed) break;
          if (!controller.isClosed) {
            controller.addError(error, stackTrace);
          }
        } catch (error, stackTrace) {
          if (!controller.isClosed) {
            controller.addError(error, stackTrace);
          }
        }

        if (closed) break;
        await Future<void>.delayed(const Duration(seconds: 1));
      }

      if (!controller.isClosed) {
        await controller.close();
      }
    }

    controller.onListen = () {
      unawaited(pump());
    };
    controller.onCancel = () {
      closed = true;
      cancelToken?.cancel('stream closed');
    };

    return controller.stream;
  }

  Future<List<MatchCommentaryEntry>> loadCommentary(
    String matchId, {
    int? inningsNum,
    int limit = 50,
    int offset = 0,
  }) async {
    final params = <String, dynamic>{'limit': limit, 'offset': offset};
    if (inningsNum != null) params['innings'] = inningsNum;
    final response = await _client.get(
      ApiEndpoints.matchCommentary(matchId),
      queryParameters: params,
    );
    final root = _unwrapMapResponse(response.data);
    return _list(root['commentary'])
        .whereType<Map<String, dynamic>>()
        .map((c) => MatchCommentaryEntry(
              inningsNumber: _intOrNull(c['inningsNumber']) ?? 1,
              over: _string(c['over']),
              overNumber: _intOrNull(c['overNumber']) ?? 0,
              ballNumber: _intOrNull(c['ballNumber']) ?? 0,
              batter: _string(c['batter']),
              bowler: _string(c['bowler']),
              outcome: _string(c['outcome']),
              runs: _intOrNull(c['runs']) ?? 0,
              isWicket: c['isWicket'] == true,
              text: _string(c['text']),
              dismissalType: _nullIfEmpty(_string(c['dismissalType'])),
              dismissedPlayer: _nullIfEmpty(_string(c['dismissedPlayer'])),
              fielder: _nullIfEmpty(_string(c['fielder'])),
              scoreAfterBall: _nullIfEmpty(_string(c['scoreAfterBall'])),
              teamName: _nullIfEmpty(_string(c['teamName'])),
              tags: _list(c['tags']).whereType<String>().toList(),
            ))
        .toList();
  }

  Future<MatchAnalysis> loadMatchAnalysis(String matchId) async {
    final response = await _client.get(ApiEndpoints.matchAnalysis(matchId));
    final root = _unwrapMapResponse(response.data);
    final innings = _list(root['innings'])
        .whereType<Map<String, dynamic>>()
        .map((inn) => MatchAnalysisInnings(
              inningsNumber: _intOrNull(inn['inningsNumber']) ?? 1,
              battingTeam: _string(inn['battingTeam']),
              overStats: _list(inn['overStats'])
                  .whereType<Map<String, dynamic>>()
                  .map((o) => MatchOverStat(
                        over: _intOrNull(o['over']) ?? 0,
                        runs: _intOrNull(o['runs']) ?? 0,
                        wickets: _intOrNull(o['wickets']) ?? 0,
                        runRate: (o['runRate'] as num?)?.toDouble() ?? 0.0,
                        cumulativeRuns: _intOrNull(o['cumulativeRuns']) ?? 0,
                      ))
                  .toList(),
              wagonWheel: _list(inn['wagonWheel'])
                  .whereType<Map<String, dynamic>>()
                  .map((w) => WagonWheelBall(
                        over: _string(w['over']),
                        runs: _intOrNull(w['runs']) ?? 0,
                        isWicket: w['isWicket'] == true,
                        batter: _string(w['batter']),
                        zone: _canonicalWagonZone(
                          _nullIfEmpty(_string(w['zone'] ?? '')),
                        ),
                      ))
                  .toList(),
            ))
        .toList();
    return MatchAnalysis(matchId: matchId, innings: innings);
  }

  PlayerMatch _mapMatch(Map<String, dynamic> raw, DateTime now) {
    final stat = raw;
    final match = _map(raw['match']).isNotEmpty ? _map(raw['match']) : raw;
    final tournament = _map(match['tournament']);
    final arena = _map(match['arena']);
    final venue = _map(match['venue']);
    final teamA = _entityName(match['teamA']) ??
        _entityName(match['team1']) ??
        _string(match['teamAName']);
    final teamB = _entityName(match['teamB']) ??
        _entityName(match['team2']) ??
        _string(match['teamBName']);
    final teams =
        _list(match['teams']).whereType<Map<String, dynamic>>().toList();

    final firstTeam = teamA.isNotEmpty
        ? teamA
        : (teams.isNotEmpty ? _string(teams.first['name']) : '');
    final secondTeam = teamB.isNotEmpty
        ? teamB
        : (teams.length > 1 ? _string(teams[1]['name']) : '');
    final playerSide = _string(stat['team']).toUpperCase();
    final playerTeamSignal = _normalizeLabel(_firstNonEmpty([
      _entityName(stat['team']) ?? '',
      _string(stat['teamName']),
      _entityName(stat['playerTeam']) ?? '',
      _string(stat['playerTeamName']),
      _entityName(match['playerTeam']) ?? '',
      _string(match['playerTeamName']),
    ]));
    final hasPlayerStatSignal = [
      stat['runs'],
      stat['balls'],
      stat['wickets'],
      stat['catches'],
      stat['overs'],
      stat['performanceScore'],
      stat['impactPoints'],
    ].any((value) => value != null);
    final scoringOwnerIds = <String>{}
      ..addAll(_collectScoringOwnerIds(raw))
      ..addAll(_collectScoringOwnerIds(stat))
      ..addAll(_collectScoringOwnerIds(match));
    final involvesPlayerTeam = playerSide == 'A' ||
        playerSide == 'B' ||
        _truthy(stat['isParticipant']) ||
        _truthy(stat['isPlaying']) ||
        _truthy(stat['isSelected']) ||
        _truthy(match['isParticipant']) ||
        (playerTeamSignal.isNotEmpty &&
            (playerTeamSignal == _normalizeLabel(firstTeam) ||
                playerTeamSignal == _normalizeLabel(secondTeam))) ||
        hasPlayerStatSignal;
    final playerTeamName = switch (playerSide) {
      'A' => firstTeam,
      'B' => secondTeam,
      _ => firstTeam,
    };
    final opponentTeamName = switch (playerSide) {
      'A' => secondTeam,
      'B' => firstTeam,
      _ => secondTeam,
    };

    final tournamentLabel = _firstNonEmpty([
      _string(tournament['name']),
      _string(match['tournamentName']),
    ]);
    final competitionLabel = _firstNonEmpty([
      tournamentLabel,
      _string(match['competitionName']),
      _string(match['seriesName']),
    ]);

    final title = _buildTitle(
      primary: _firstNonEmpty([
        _string(match['title']),
        _string(match['name']),
        _string(match['matchTitle']),
      ]),
      firstTeam: firstTeam,
      secondTeam: secondTeam,
      competitionLabel: competitionLabel,
    );

    final scheduledAt = _parseScheduledAt(match);
    final sectionType = _deriveSectionType(match, tournamentLabel);
    final lifecycle = _deriveLifecycle(
      raw: match,
      scheduledAt: scheduledAt,
      now: now,
    );
    final result = _deriveResult(
      stat: stat,
      match: match,
      playerTeamName: playerTeamName,
      opponentTeamName: opponentTeamName,
    );
    final statusLabel = _deriveStatusLabel(match, lifecycle);

    return PlayerMatch(
      id: _firstNonEmpty([
        _string(match['id']),
        _string(match['_id']),
        _string(stat['matchId']),
        _string(stat['id']),
      ]),
      title: title,
      sectionType: sectionType,
      lifecycle: lifecycle,
      result: result,
      statusLabel: statusLabel,
      playerTeamName: playerTeamName,
      opponentTeamName: opponentTeamName,
      scheduledAt: scheduledAt,
      competitionLabel: competitionLabel.isEmpty ? null : competitionLabel,
      venueLabel: _firstNonEmpty([
        _string(venue['name']),
        _string(arena['name']),
        _string(match['venueName']),
        _string(match['location']),
      ]).isEmpty
          ? null
          : _firstNonEmpty([
              _string(venue['name']),
              _string(arena['name']),
              _string(match['venueName']),
              _string(match['location']),
            ]),
      formatLabel: _firstNonEmpty([
        _string(match['format']),
        _string(match['matchFormat']),
        _string(match['gameFormat']),
      ]).isEmpty
          ? null
          : _displayFormatLabel(
              _firstNonEmpty([
                _string(match['format']),
                _string(match['matchFormat']),
                _string(match['gameFormat']),
              ]),
              customOvers: _resolveCustomOvers(match, const {}),
            ),
      playerRuns: _intOrNull(stat['runs']),
      playerBalls: _intOrNull(stat['balls']),
      playerWickets: _intOrNull(stat['wickets']),
      playerCatches: _intOrNull(stat['catches']),
      canScore: _truthy(stat['isHost']) ||
          _truthy(stat['canScore']) ||
          _truthy(stat['isScorer']) ||
          _truthy(stat['isOwner']) ||
          _truthy(stat['isManager']) ||
          _truthy(match['isHost']) ||
          _truthy(match['canScore']) ||
          _truthy(match['isScorer']) ||
          _truthy(match['isOwner']) ||
          _truthy(match['isManager']),
      scoringOwnerIds: scoringOwnerIds.toList(growable: false),
      involvesPlayerTeam: involvesPlayerTeam,
      ballType: _nullIfEmpty(_firstNonEmpty([
        _string(match['ballType']),
        _string(match['ball_type']),
      ])),
      scoreSummary:
          _buildMatchCardSummary(stat, match, playerTeamName, opponentTeamName),
      playerTeamLogoUrl: switch (playerSide) {
        'A' => _nullIfEmpty(_string(match['teamALogoUrl'])),
        'B' => _nullIfEmpty(_string(match['teamBLogoUrl'])),
        _ => _nullIfEmpty(_string(match['teamALogoUrl'])),
      },
      opponentTeamLogoUrl: switch (playerSide) {
        'A' => _nullIfEmpty(_string(match['teamBLogoUrl'])),
        'B' => _nullIfEmpty(_string(match['teamALogoUrl'])),
        _ => _nullIfEmpty(_string(match['teamBLogoUrl'])),
      },
      playerTeamShortName: switch (playerSide) {
        'A' => _nullIfEmpty(_string(match['teamAShortName'])),
        'B' => _nullIfEmpty(_string(match['teamBShortName'])),
        _ => _nullIfEmpty(_string(match['teamAShortName'])),
      },
      opponentTeamShortName: switch (playerSide) {
        'A' => _nullIfEmpty(_string(match['teamBShortName'])),
        'B' => _nullIfEmpty(_string(match['teamAShortName'])),
        _ => _nullIfEmpty(_string(match['teamBShortName'])),
      },
    );
  }

  MatchCenter _mapMatchCenter({
    required Map<String, dynamic> scorecardRoot,
    required Map<String, dynamic> matchRoot,
    required Map<String, dynamic> playersRoot,
    required Map<String, dynamic> previewRoot,
    required Map<String, dynamic> overlayRoot,
    required bool overlayLoaded,
    required String requestedId,
    required DateTime now,
  }) {
    final scorecard = _map(scorecardRoot['scorecard']).isNotEmpty
        ? _map(scorecardRoot['scorecard'])
        : scorecardRoot;
    final matchContainer = _map(matchRoot['match']).isNotEmpty
        ? _map(matchRoot['match'])
        : matchRoot;
    final merged = <String, dynamic>{}
      ..addAll(matchContainer)
      ..addAll(scorecard);

    final tournament = _map(merged['tournament']);
    final venue = _map(merged['venue']);
    final arena = _map(merged['arena']);

    final teamAName = _entityName(merged['teamA']) ??
        _entityName(merged['team1']) ??
        _string(merged['teamAName']);
    final teamBName = _entityName(merged['teamB']) ??
        _entityName(merged['team2']) ??
        _string(merged['teamBName']);
    final tournamentLabel = _firstNonEmpty([
      _string(tournament['name']),
      _string(merged['tournamentName']),
    ]);

    final lifecycle = _deriveLifecycle(
      raw: merged,
      scheduledAt: _parseScheduledAt(merged),
      now: now,
    );

    // Build live state — use unwrapped scorecard for live-computed stats
    final liveState = lifecycle == MatchLifecycle.live
        ? _buildLiveState(
            matchRoot: matchContainer,
            playersRoot: playersRoot,
            scorecardRoot: scorecard,
          )
        : null;

    final scoringOwnerIds = <String>{}
      ..addAll(_collectScoringOwnerIds(merged))
      ..addAll(_collectScoringOwnerIds(matchContainer))
      ..addAll(_collectScoringOwnerIds(matchRoot))
      ..addAll(_collectScoringOwnerIds(scorecard))
      ..addAll(_collectScoringOwnerIds(previewRoot))
      ..addAll(_collectScoringOwnerIds(playersRoot));

    final innings = _parseInnings(
      merged,
      teamAName: teamAName,
      teamBName: teamBName,
    );
    final teamAScore = _resolveTeamScore(
      side: 'A',
      teamName: teamAName,
      root: merged,
      innings: innings,
    );
    final teamBScore = _resolveTeamScore(
      side: 'B',
      teamName: teamBName,
      root: merged,
      innings: innings,
    );

    return MatchCenter(
      id: _firstNonEmpty([
        _string(merged['id']),
        _string(merged['_id']),
        requestedId,
      ]),
      title: _buildTitle(
        primary: _firstNonEmpty([
          _string(merged['title']),
          _string(merged['name']),
          _string(merged['matchTitle']),
        ]),
        firstTeam: teamAName,
        secondTeam: teamBName,
        competitionLabel: tournamentLabel,
      ),
      sectionType: _deriveSectionType(merged, tournamentLabel),
      lifecycle: lifecycle,
      statusLabel: _deriveStatusLabel(merged, lifecycle),
      teamAName: teamAName.isEmpty ? 'Team A' : teamAName,
      teamBName: teamBName.isEmpty ? 'Team B' : teamBName,
      teamALogoUrl: _nullIfEmpty(_firstNonEmpty([
        _string(_map(previewRoot['teamA'])['logoUrl']),
        _string(_map(scorecardRoot['teamA'])['logoUrl']),
        _string(_map(playersRoot['teamA'])['logoUrl']),
      ])),
      teamBLogoUrl: _nullIfEmpty(_firstNonEmpty([
        _string(_map(previewRoot['teamB'])['logoUrl']),
        _string(_map(scorecardRoot['teamB'])['logoUrl']),
        _string(_map(playersRoot['teamB'])['logoUrl']),
      ])),
      teamAShortName: _nullIfEmpty(_firstNonEmpty([
        _string(_map(previewRoot['teamA'])['shortName']),
        _string(_map(scorecardRoot['teamA'])['shortName']),
        _string(_map(playersRoot['teamA'])['shortName']),
      ])),
      teamBShortName: _nullIfEmpty(_firstNonEmpty([
        _string(_map(previewRoot['teamB'])['shortName']),
        _string(_map(scorecardRoot['teamB'])['shortName']),
        _string(_map(playersRoot['teamB'])['shortName']),
      ])),
      teamAScore: teamAScore,
      teamBScore: teamBScore,
      scheduledAt: _parseScheduledAt(merged),
      competitionLabel: tournamentLabel.isEmpty ? null : tournamentLabel,
      venueLabel: _firstNonEmpty([
        _string(venue['name']),
        _string(arena['name']),
        _string(merged['venueName']),
        _string(merged['location']),
      ]).isEmpty
          ? null
          : _firstNonEmpty([
              _string(venue['name']),
              _string(arena['name']),
              _string(merged['venueName']),
              _string(merged['location']),
            ]),
      formatLabel: _firstNonEmpty([
        _string(merged['format']),
        _string(merged['matchFormat']),
        _string(merged['gameFormat']),
      ]).isEmpty
          ? null
          : _displayFormatLabel(
              _firstNonEmpty([
                _string(merged['format']),
                _string(merged['matchFormat']),
                _string(merged['gameFormat']),
              ]),
              customOvers: _resolveCustomOvers(merged, previewRoot),
            ),
      matchType: _firstNonEmpty([
        _string(merged['matchType']),
        _string(merged['type']),
      ]).isEmpty
          ? null
          : _displayLabel(_firstNonEmpty([
              _string(merged['matchType']),
              _string(merged['type']),
            ])),
      resultSummary: _buildResultSummary(merged, teamAName, teamBName),
      winnerTeamName: _resolveWinnerTeamName(merged, teamAName, teamBName),
      winMargin: _nullIfEmpty(_string(merged['winMargin'])),
      overlayLoaded: overlayLoaded,
      youtubeUrl: _nullIfEmpty(_firstNonEmpty([
        _string(overlayRoot['youtubeUrl']),
        _string(overlayRoot['youtube_url']),
        _string(overlayRoot['streamUrl']),
        _string(overlayRoot['liveStreamUrl']),
        _string(previewRoot['youtubeUrl']),
        _string(previewRoot['youtube_url']),
      ])),
      tossSummary: _nullIfEmpty(_string(previewRoot['tossText'])) ??
          _buildTossSummary(merged, teamAName, teamBName),
      currentRunRate: liveState?.currentRunRate ??
          _rateLabel(
              merged, const ['currentRunRate', 'currentRR', 'runRate', 'crr']),
      requiredRunRate: liveState?.requiredRunRate ??
          _rateLabel(merged, const ['requiredRunRate', 'requiredRR', 'rrr']),
      liveState: liveState,
      competitive: _parseCompetitive(merged),
      innings: innings,
      squads: _parseSquads(
        root: merged,
        playersRoot: playersRoot,
        teamAName: teamAName.isEmpty ? 'Team A' : teamAName,
        teamBName: teamBName.isEmpty ? 'Team B' : teamBName,
      ),
      canScore: _hasScoringPermissionFlag(merged) ||
          _hasScoringPermissionFlag(matchContainer) ||
          _hasScoringPermissionFlag(matchRoot) ||
          _hasScoringPermissionFlag(previewRoot) ||
          _hasScoringPermissionFlag(playersRoot) ||
          _hasScoringPermissionFlag(scorecard),
      scoringOwnerIds: scoringOwnerIds.toList(growable: false),
    );
  }

  String _buildTitle({
    required String primary,
    required String firstTeam,
    required String secondTeam,
    required String competitionLabel,
  }) {
    if (primary.isNotEmpty) return primary;
    if (firstTeam.isNotEmpty && secondTeam.isNotEmpty) {
      return '$firstTeam vs $secondTeam';
    }
    if (competitionLabel.isNotEmpty) return competitionLabel;
    if (firstTeam.isNotEmpty) return firstTeam;
    return 'Match';
  }

  MatchSectionType _deriveSectionType(
    Map<String, dynamic> raw,
    String tournamentLabel,
  ) {
    final rawType = _firstNonEmpty([
      _string(raw['type']),
      _string(raw['matchType']),
      _string(raw['matchType']),
      _string(raw['category']),
    ]).toLowerCase();

    final hasTournamentSignal = rawType.contains('tournament') ||
        rawType.contains('league') ||
        rawType == 'tournament' ||
        (raw['tournamentId'] != null &&
            _string(raw['tournamentId']).isNotEmpty) ||
        _map(raw['tournament']).isNotEmpty ||
        tournamentLabel.isNotEmpty;

    return hasTournamentSignal
        ? MatchSectionType.tournament
        : MatchSectionType.individual;
  }

  MatchLifecycle _deriveLifecycle({
    required Map<String, dynamic> raw,
    required DateTime? scheduledAt,
    required DateTime now,
  }) {
    final rawStatus = _firstNonEmpty([
      _string(raw['status']),
      _string(raw['matchStatus']),
      _string(raw['state']),
      _string(raw['liveStatus']),
    ]);
    final normalized = rawStatus.toLowerCase();

    final exactStatus = rawStatus.toUpperCase();

    if (const {
      'SCHEDULED',
      'TOSS_DONE',
      'TOSS_DELAYED',
      'TOSS_PENDING',
      'NOT_STARTED',
      'YET_TO_START',
    }.contains(exactStatus)) {
      return MatchLifecycle.upcoming;
    }

    if (const {
      'IN_PROGRESS',
      'LIVE',
      'ONGOING',
      'STARTED',
    }.contains(exactStatus)) {
      return MatchLifecycle.live;
    }

    if (const {
      'COMPLETED',
      'ABANDONED',
      'CANCELLED',
      'CANCELED',
      'RESULT',
      'FINISHED',
    }.contains(exactStatus)) {
      return MatchLifecycle.past;
    }

    if (_containsAny(normalized, const [
      'toss',
      'scheduled',
      'yet_to_start',
      'yet to start',
      'not_started',
      'not started',
      'delayed',
      'pending',
      'upcoming',
    ])) {
      return MatchLifecycle.upcoming;
    }

    if (_containsAny(normalized, const [
      'live',
      'ongoing',
      'in_progress',
      'in progress',
      'started',
      'innings',
    ])) {
      return MatchLifecycle.live;
    }

    if (_containsAny(normalized, const [
      'complete',
      'completed',
      'finished',
      'cancelled',
      'canceled',
      'abandoned',
      'result',
    ])) {
      return MatchLifecycle.past;
    }

    if (scheduledAt != null) {
      return scheduledAt.isBefore(now)
          ? MatchLifecycle.past
          : MatchLifecycle.upcoming;
    }

    return MatchLifecycle.upcoming;
  }

  String _deriveStatusLabel(
      Map<String, dynamic> raw, MatchLifecycle lifecycle) {
    // Map backend status enums to clean display labels
    final rawStatus = _firstNonEmpty([
      _string(raw['status']),
      _string(raw['matchStatus']),
      _string(raw['state']),
      _string(raw['liveStatus']),
    ]).toUpperCase();

    return switch (rawStatus) {
      'SCHEDULED' => 'Scheduled',
      'TOSS_DONE' => 'Toss Done',
      'IN_PROGRESS' => 'Live',
      'COMPLETED' => 'Completed',
      'ABANDONED' => 'Abandoned',
      'CANCELLED' => 'Cancelled',
      _ => switch (lifecycle) {
          MatchLifecycle.live => 'Live',
          MatchLifecycle.upcoming => 'Upcoming',
          MatchLifecycle.past => 'Completed',
        },
    };
  }

  MatchResult _deriveResult({
    required Map<String, dynamic> stat,
    required Map<String, dynamic> match,
    required String playerTeamName,
    required String opponentTeamName,
  }) {
    final winnerId = _string(match['winnerId']).toUpperCase();
    final playerSide = _string(stat['team']).toUpperCase();

    if (winnerId == 'DRAW' || winnerId == 'TIE' || winnerId == 'ABANDONED') {
      return MatchResult.draw;
    }

    if (playerSide != 'A' && playerSide != 'B') {
      return MatchResult.unknown;
    }

    if (winnerId == 'A' || winnerId == 'B') {
      return winnerId == playerSide ? MatchResult.win : MatchResult.loss;
    }

    final normalizedWinner = _normalizeLabel(_string(match['winnerId']));
    if (normalizedWinner.isNotEmpty) {
      final normalizedPlayerTeam = _normalizeLabel(playerTeamName);
      final normalizedOpponent = _normalizeLabel(opponentTeamName);
      if (normalizedWinner == normalizedPlayerTeam) return MatchResult.win;
      if (normalizedWinner == normalizedOpponent) return MatchResult.loss;
    }

    final summary = _normalizeLabel(
      _firstNonEmpty([
        _string(match['resultSummary']),
        _string(match['scoreSummary']),
      ]),
    );
    if (summary.contains('draw') || summary.contains('tie')) {
      return MatchResult.draw;
    }

    return MatchResult.unknown;
  }

  DateTime? _parseScheduledAt(Map<String, dynamic> raw) {
    final candidates = [
      raw['scheduledAt'],
      raw['startsAt'],
      raw['startTime'],
      raw['matchDateTime'],
      raw['dateTime'],
      raw['date'],
      raw['matchDate'],
    ];

    for (final candidate in candidates) {
      final parsed = _parseDateTimeValue(candidate);
      if (parsed != null) return parsed.toLocal();
    }

    final date = _string(raw['matchDate'], fallback: _string(raw['date']));
    final time = _string(raw['matchTime'], fallback: _string(raw['time']));
    if (date.isNotEmpty && time.isNotEmpty) {
      final parsed = DateTime.tryParse('${date}T$time');
      if (parsed != null) return parsed.toLocal();
    }

    return null;
  }

  DateTime? _parseDateTimeValue(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      final trimmed = value.trim();
      final direct = DateTime.tryParse(trimmed);
      if (direct != null) return direct;
      final asInt = int.tryParse(trimmed);
      if (asInt != null) {
        return DateTime.fromMillisecondsSinceEpoch(
          asInt < 1000000000000 ? asInt * 1000 : asInt,
        );
      }
      return null;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        value < 1000000000000 ? value * 1000 : value,
      );
    }
    if (value is num) {
      final millis = value.toInt();
      return DateTime.fromMillisecondsSinceEpoch(
        millis < 1000000000000 ? millis * 1000 : millis,
      );
    }
    return null;
  }

  List<Map<String, dynamic>> _unwrapListResponse(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }

    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is List) {
        return inner.whereType<Map<String, dynamic>>().toList();
      }
      if (inner is Map<String, dynamic>) {
        final nestedData = inner['data'];
        if (nestedData is List) {
          return nestedData.whereType<Map<String, dynamic>>().toList();
        }
        for (final key in const ['matches', 'items', 'results', 'rows']) {
          final nested = inner[key];
          if (nested is List) {
            return nested.whereType<Map<String, dynamic>>().toList();
          }
        }
      }

      for (final key in const ['matches', 'items', 'results', 'rows']) {
        final nested = data[key];
        if (nested is List) {
          return nested.whereType<Map<String, dynamic>>().toList();
        }
      }
    }

    return const [];
  }

  Map<String, dynamic> _unwrapMapResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is Map<String, dynamic>) {
        final nested = inner['data'];
        if (nested is Map<String, dynamic>) return nested;
        return inner;
      }
      return data;
    }
    return const <String, dynamic>{};
  }

  Map<String, dynamic> _map(dynamic value) {
    return value is Map<String, dynamic> ? value : <String, dynamic>{};
  }

  List<dynamic> _list(dynamic value) {
    return value is List ? value : const [];
  }

  String _string(dynamic value, {String fallback = ''}) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  String? _nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

  String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      if (value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  String? _entityName(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value is Map<String, dynamic>) {
      final label = _firstNonEmpty([
        _string(value['name']),
        _string(value['teamName']),
        _string(value['shortName']),
      ]);
      return label.isEmpty ? null : label;
    }
    return null;
  }

  bool _containsAny(String value, List<String> patterns) {
    return patterns.any(value.contains);
  }

  bool _hasScoringPermissionFlag(Map<String, dynamic> source) {
    return _truthy(source['canScore']) ||
        _truthy(source['isHost']) ||
        _truthy(source['isScorer']) ||
        _truthy(source['isOwner']) ||
        _truthy(source['isManager']);
  }

  List<String> _collectScoringOwnerIds(Map<String, dynamic> source) {
    final ids = <String>{};
    void add(dynamic value) {
      final normalized = '$value'.trim();
      if (normalized.isEmpty || normalized == 'null') return;
      ids.add(normalized);
    }

    for (final key in const [
      'scorerId',
      'scorerProfileId',
      'scorerPlayerId',
      'hostId',
      'hostProfileId',
      'hostPlayerId',
      'ownerId',
      'ownerProfileId',
      'ownerPlayerId',
      'managerId',
      'managerProfileId',
      'organizerId',
      'organizerProfileId',
      'createdBy',
      'createdById',
      'createdByProfileId',
      'createdByPlayerId',
      'userId',
      'playerId',
      'profileId',
    ]) {
      add(source[key]);
    }

    final scorer = _map(source['scorer']);
    final host = _map(source['host']);
    final owner = _map(source['owner']);
    final manager = _map(source['manager']);
    final creator = _map(source['createdByUser']);
    final creatorAlt = _map(source['createdBy']);
    final organizer = _map(source['organizer']);
    for (final nested in [
      scorer,
      host,
      owner,
      manager,
      creator,
      creatorAlt,
      organizer
    ]) {
      add(nested['id']);
      add(nested['_id']);
      add(nested['profileId']);
      add(nested['playerId']);
      add(nested['playerProfileId']);
      add(nested['userId']);
    }

    return ids.toList(growable: false);
  }

  bool _truthy(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' ||
          normalized == '1' ||
          normalized == 'yes' ||
          normalized == 'y';
    }
    return false;
  }

  String _displayLabel(String raw) {
    return raw
        .replaceAll('-', '_')
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  /// Tries multiple possible field names / sources for the custom overs count.
  int? _resolveCustomOvers(
      Map<String, dynamic> primary, Map<String, dynamic> secondary) {
    const keys = [
      'customOvers',
      'maxOvers',
      'oversPerInnings',
      'noOfOvers',
      'numberOfOvers',
      'matchOvers',
    ];
    for (final k in keys) {
      final v = primary[k] ?? secondary[k];
      if (v is num && v > 0) return v.toInt();
    }
    return null;
  }

  String _displayFormatLabel(String raw, {int? customOvers}) {
    switch (raw.toUpperCase()) {
      case 'T10':
        return 'T10';
      case 'T20':
        return 'T20';
      case 'ONE_DAY':
        return 'ODI';
      case 'TWO_INNINGS':
        return 'Test Match';
      case 'CUSTOM':
        return customOvers != null && customOvers > 0
            ? 'Custom · $customOvers Overs'
            : 'Custom';
      default:
        return _displayLabel(raw);
    }
  }

  int? _intOrNull(dynamic value) => (value as num?)?.toInt();

  String? _rateLabel(Map<String, dynamic> raw, List<String> keys) {
    for (final key in keys) {
      final value = raw[key];
      if (value is num) return value.toStringAsFixed(1);
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  List<MatchInnings> _parseInnings(
    Map<String, dynamic> root, {
    String teamAName = '',
    String teamBName = '',
  }) {
    final rawList = _list(root['innings']);
    return rawList
        .whereType<Map<String, dynamic>>()
        .toList()
        .asMap()
        .entries
        .map((e) => _mapInnings(
              e.value,
              e.key,
              teamAName: teamAName,
              teamBName: teamBName,
            ))
        .toList();
  }

  MatchInnings _mapInnings(
    Map<String, dynamic> raw,
    int index, {
    String teamAName = '',
    String teamBName = '',
  }) {
    final battingTeamSide = _string(raw['battingTeam']).toUpperCase();
    final isSuperOver = raw['isSuperOver'] == true;
    final isCompleted = raw['isCompleted'] == true;

    // Resolve team name from side code ("A" / "B") or fallback fields
    final String teamName;
    if (battingTeamSide == 'A' && teamAName.isNotEmpty) {
      teamName = teamAName;
    } else if (battingTeamSide == 'B' && teamBName.isNotEmpty) {
      teamName = teamBName;
    } else {
      teamName = _firstNonEmpty([
        _entityName(raw['battingTeam']) ?? '',
        _entityName(raw['team']) ?? '',
        _string(raw['teamName']),
        _string(raw['name']),
        'Innings ${index + 1}',
      ]);
    }

    // Build innings title
    const ordinals = ['1st', '2nd', '3rd', '4th'];
    final ordinal =
        index < ordinals.length ? ordinals[index] : '${index + 1}th';
    final title =
        isSuperOver ? '$teamName (Super Over)' : '$teamName $ordinal Innings';

    // Build score string from structured fields or fall back to raw
    final totalRuns = _intOrNull(raw['totalRuns']);
    final totalWickets = _intOrNull(raw['totalWickets']);
    final totalOvers = raw['totalOvers'];
    String score;
    if (totalRuns != null) {
      final wicketsLabel = totalWickets != null ? '/$totalWickets' : '';
      final oversLabel = totalOvers is num
          ? ' (${totalOvers.toStringAsFixed(1)} ov)'
          : (totalOvers is String && totalOvers.isNotEmpty)
              ? ' ($totalOvers ov)'
              : '';
      score = '$totalRuns$wicketsLabel$oversLabel';
    } else {
      score = _firstNonEmpty([
        _string(raw['score']),
        _scoreFromMap(raw),
      ]);
      if (score.isEmpty) score = 'Yet to bat';
    }

    final battingRaw = _firstList(raw, const [
      'batting',
      'battingScorecard',
      'batters',
      'batsmen',
    ]);
    final bowlingRaw = _firstList(raw, const [
      'bowling',
      'bowlingScorecard',
      'bowlers',
    ]);

    return MatchInnings(
      title: title,
      score: score,
      battingTeamName: teamName,
      extras: _intOrNull(raw['extras']) ?? 0,
      isCompleted: isCompleted,
      isSuperOver: isSuperOver,
      batting: battingRaw
          .whereType<Map<String, dynamic>>()
          .map(_mapBatsmanRow)
          .toList(),
      bowling: bowlingRaw
          .whereType<Map<String, dynamic>>()
          .map(_mapBowlerRow)
          .toList(),
      fallOfWickets: _list(raw['fallOfWickets'])
          .whereType<Map<String, dynamic>>()
          .map((f) => FallOfWicket(
                wicket: _intOrNull(f['wicket']) ?? 0,
                score: _string(f['score']),
                player: _string(f['player']),
                over: _string(f['over']),
              ))
          .toList(),
      partnerships: _list(raw['partnerships'])
          .whereType<Map<String, dynamic>>()
          .map((p) => MatchPartnership(
                batter1: _string(p['batter1']),
                batter2: _string(p['batter2']),
                runs: _intOrNull(p['runs']) ?? 0,
                balls: _intOrNull(p['balls']) ?? 0,
              ))
          .toList(),
    );
  }

  MatchBatsmanRow _mapBatsmanRow(Map<String, dynamic> raw) {
    final playerRaw = raw['player'];
    final name = _firstNonEmpty([
      playerRaw is String ? playerRaw : '',
      playerRaw is Map<String, dynamic> ? _string(playerRaw['name']) : '',
      _string(raw['name']),
      _string(raw['playerName']),
      _string(raw['batterName']),
      _string(_map(raw['player'])['name']),
      _string(_map(_map(raw['player'])['user'])['name']),
    ]);

    final sr = raw['strikeRate'];
    final srLabel = sr is num
        ? sr.toStringAsFixed(1)
        : (sr is String && sr.isNotEmpty ? sr : '-');

    final dismissalType = _string(raw['dismissalType']);

    return MatchBatsmanRow(
      playerId: _nullIfEmpty(_firstNonEmpty([
        _string(raw['playerId']),
        _string(_map(raw['player'])['id']),
      ])),
      name: name.isEmpty ? 'Player' : name,
      runs: _intOrNull(raw['runs']) ?? 0,
      balls: _intOrNull(raw['balls']) ?? 0,
      fours: _intOrNull(raw['fours']) ?? 0,
      sixes: _intOrNull(raw['sixes']) ?? 0,
      strikeRate: srLabel,
      isOut: raw['isOut'] == true,
      dismissal: dismissalType.isEmpty ? null : _displayLabel(dismissalType),
    );
  }

  MatchBowlerRow _mapBowlerRow(Map<String, dynamic> raw) {
    final playerRaw = raw['player'];
    final name = _firstNonEmpty([
      playerRaw is String ? playerRaw : '',
      _string(raw['name']),
      _string(raw['playerName']),
      _string(raw['bowlerName']),
    ]);

    final eco = raw['economy'];
    final ecoLabel = eco is num
        ? eco.toStringAsFixed(2)
        : (eco is String && eco.isNotEmpty ? eco : '-');

    final oversRaw = raw['overs'] ?? raw['oversBowled'];
    final overs = oversRaw is num
        ? oversRaw.toStringAsFixed(1)
        : (_string(oversRaw as Object? ?? '').isNotEmpty
            ? _string(oversRaw)
            : '0.0');

    return MatchBowlerRow(
      playerId: _nullIfEmpty(_firstNonEmpty([
        _string(raw['playerId']),
        _string(_map(raw['player'])['id']),
      ])),
      name: name.isEmpty ? 'Bowler' : name,
      overs: overs,
      runs: _intOrNull(raw['runs'] ?? raw['runsConceded']) ?? 0,
      wickets: _intOrNull(raw['wickets']) ?? 0,
      economy: ecoLabel,
    );
  }

  MatchCompetitiveSummary? _parseCompetitive(Map<String, dynamic> root) {
    final raw = _map(root['competitive']);
    if (raw.isEmpty) return null;

    MatchImpactBreakdown parseBreakdown(Map<String, dynamic> item) {
      final breakdown = _map(item['breakdown']);
      final batting = _map(breakdown['battingDetails']);
      final bowling = _map(breakdown['bowlingDetails']);
      final fielding = _map(breakdown['fieldingDetails']);

      return MatchImpactBreakdown(
        baseImpactPoints: _intOrNull(breakdown['baseImpactPoints']) ?? 0,
        totalImpactPoints: _intOrNull(breakdown['totalImpactPoints']) ??
            (_intOrNull(item['impactPoints']) ?? 0),
        playingPoints: _intOrNull(breakdown['playingPoints']) ?? 0,
        battingPoints: _intOrNull(breakdown['battingPoints']) ?? 0,
        bowlingPoints: _intOrNull(breakdown['bowlingPoints']) ?? 0,
        fieldingPoints: _intOrNull(breakdown['fieldingPoints']) ?? 0,
        winBonusPoints: _intOrNull(breakdown['winBonusPoints']) ?? 0,
        mvpBonusPoints: _intOrNull(breakdown['mvpBonusPoints']) ?? 0,
        battingDetails: MatchImpactBattingDetails(
          runsPoints: _intOrNull(batting['runsPoints']) ?? 0,
          boundaryBonusPoints: _intOrNull(batting['boundaryBonusPoints']) ?? 0,
          strikeRateBonusPoints:
              _intOrNull(batting['strikeRateBonusPoints']) ?? 0,
          contributionBonusPoints:
              _intOrNull(batting['contributionBonusPoints']) ?? 0,
        ),
        bowlingDetails: MatchImpactBowlingDetails(
          wicketPoints: _intOrNull(bowling['wicketPoints']) ?? 0,
          dotBallPoints: _intOrNull(bowling['dotBallPoints']) ?? 0,
          maidenPoints: _intOrNull(bowling['maidenPoints']) ?? 0,
          economyBonusPoints: _intOrNull(bowling['economyBonusPoints']) ?? 0,
        ),
        fieldingDetails: MatchImpactFieldingDetails(
          catchPoints: _intOrNull(fielding['catchPoints']) ?? 0,
          runOutPoints: _intOrNull(fielding['runOutPoints']) ?? 0,
          stumpingPoints: _intOrNull(fielding['stumpingPoints']) ?? 0,
        ),
      );
    }

    final leaderboard = _list(raw['leaderboard'])
        .whereType<Map<String, dynamic>>()
        .map((item) => MatchCompetitiveEntry(
              playerId: _string(item['playerId']),
              playerName: _string(item['playerName'], fallback: 'Player'),
              teamName: _string(item['teamName']),
              impactPoints: _intOrNull(item['impactPoints']) ?? 0,
              performanceScore:
                  (item['performanceScore'] as num?)?.toDouble() ?? 0.0,
              isMvp: item['isMvp'] == true,
              summary:
                  _string(item['summary'], fallback: 'Impact sample building'),
              breakdown: parseBreakdown(item),
            ))
        .toList();

    final mvpRaw = _map(raw['mvp']);
    final mvp = mvpRaw.isEmpty
        ? null
        : MatchCompetitiveEntry(
            playerId: _string(mvpRaw['playerId']),
            playerName: _string(mvpRaw['playerName'], fallback: 'Player'),
            teamName: _string(mvpRaw['teamName']),
            impactPoints: _intOrNull(mvpRaw['impactPoints']) ?? 0,
            performanceScore:
                (mvpRaw['performanceScore'] as num?)?.toDouble() ?? 0.0,
            isMvp: mvpRaw['isMvp'] == true,
            summary:
                _string(mvpRaw['summary'], fallback: 'Impact sample building'),
            breakdown: parseBreakdown(mvpRaw),
          );

    final infoRaw = _map(raw['info']);

    return MatchCompetitiveSummary(
      source: _string(raw['source'], fallback: 'UNAVAILABLE'),
      isOfficial: raw['isOfficial'] == true,
      isProvisional: raw['isProvisional'] == true,
      mvp: mvp,
      leaderboard: leaderboard,
      info: MatchImpactInfo(
        title: _string(infoRaw['title'], fallback: 'How Impact Points Work'),
        items: _list(infoRaw['items']).map((item) => '$item').toList(),
      ),
    );
  }

  List<MatchSquad> _parseSquads({
    required Map<String, dynamic> root,
    required Map<String, dynamic> playersRoot,
    required String teamAName,
    required String teamBName,
  }) {
    // Priority 1: use the dedicated /players endpoint response
    // It returns { teamA: { name, captainId, players: [...] }, teamB: { ... } }
    final pTeamA = _map(playersRoot['teamA']);
    final pTeamB = _map(playersRoot['teamB']);
    if (pTeamA.isNotEmpty || pTeamB.isNotEmpty) {
      final squads = <MatchSquad>[];
      if (pTeamA.isNotEmpty) {
        squads.add(_buildSquadFromPlayersEndpoint(
          teamName: _string(pTeamA['name']).isEmpty
              ? teamAName
              : _string(pTeamA['name']),
          captainId: _string(pTeamA['captainId']),
          viceCaptainId: _string(pTeamA['viceCaptainId']),
          wicketKeeperId: _string(pTeamA['wicketKeeperId']),
          players: _list(pTeamA['players']),
        ));
      }
      if (pTeamB.isNotEmpty) {
        squads.add(_buildSquadFromPlayersEndpoint(
          teamName: _string(pTeamB['name']).isEmpty
              ? teamBName
              : _string(pTeamB['name']),
          captainId: _string(pTeamB['captainId']),
          viceCaptainId: _string(pTeamB['viceCaptainId']),
          wicketKeeperId: _string(pTeamB['wicketKeeperId']),
          players: _list(pTeamB['players']),
        ));
      }
      if (squads.any((s) => s.players.isNotEmpty)) return squads;
    }

    // Priority 2: fall back to scorecard/match root (e.g., nested squad fields)
    final squads = <MatchSquad>[
      _buildSquad(
        teamName: teamAName,
        source: _firstNonEmptyMap(root, const ['teamA', 'team1']),
        fallback: _firstList(root, const ['teamAPlayers', 'team1Players']),
      ),
      _buildSquad(
        teamName: teamBName,
        source: _firstNonEmptyMap(root, const ['teamB', 'team2']),
        fallback: _firstList(root, const ['teamBPlayers', 'team2Players']),
      ),
    ].where((squad) => squad.players.isNotEmpty).toList();

    if (squads.isNotEmpty) return squads;

    final teams = _list(root['teams']).whereType<Map<String, dynamic>>();
    return teams
        .map(
          (team) => _buildSquad(
            teamName: _entityName(team) ?? 'Squad',
            source: team,
            fallback: const [],
          ),
        )
        .where((squad) => squad.players.isNotEmpty)
        .toList();
  }

  MatchSquad _buildSquadFromPlayersEndpoint({
    required String teamName,
    required String captainId,
    required String viceCaptainId,
    required String wicketKeeperId,
    required List<dynamic> players,
  }) {
    final parsed = players
        .whereType<Map<String, dynamic>>()
        .map((p) {
          final profileId = _string(p['profileId']);
          final userId = _string(p['userId']);
          bool matches(String id) =>
              id.isNotEmpty && (profileId == id || userId == id);
          final isCaptain = matches(captainId);
          final isViceCaptain = matches(viceCaptainId);
          final isWicketKeeper = matches(wicketKeeperId);
          final name = _firstNonEmpty([
            _string(p['name']),
            _string(_map(p['user'])['name']),
          ]);
          if (name.isEmpty) return null;
          return MatchSquadPlayer(
            name: name,
            isCaptain: isCaptain,
            isViceCaptain: isViceCaptain,
            isWicketKeeper: isWicketKeeper,
            avatarUrl: _string(p['avatarUrl']).isEmpty
                ? _string(_map(p['user'])['avatarUrl'])
                : _string(p['avatarUrl']),
            roleLabel: _nullIfEmpty([
              if (isCaptain) 'Captain',
              if (isViceCaptain) 'Vice Captain',
              if (isWicketKeeper) 'Wicket Keeper',
            ].join(', ')),
          );
        })
        .whereType<MatchSquadPlayer>()
        .toList();

    return MatchSquad(teamName: teamName, players: parsed);
  }

  MatchSquad _buildSquad({
    required String teamName,
    required Map<String, dynamic> source,
    required List<dynamic> fallback,
  }) {
    final players = _firstList(source, const [
      'playingXI',
      'playing11',
      'lineup',
      'players',
      'squad',
    ]);
    final resolved = players.isNotEmpty ? players : fallback;

    return MatchSquad(
      teamName: teamName,
      players:
          resolved.map(_mapSquadPlayer).whereType<MatchSquadPlayer>().toList(),
    );
  }

  MatchSquadPlayer? _mapSquadPlayer(dynamic raw) {
    if (raw is String && raw.trim().isNotEmpty) {
      return MatchSquadPlayer(name: raw.trim());
    }
    if (raw is! Map<String, dynamic>) return null;
    final user = _map(raw['user']);
    final name = _firstNonEmpty([
      _string(raw['name']),
      _string(raw['playerName']),
      _string(user['name']),
    ]);
    if (name.isEmpty) return null;

    final isCaptain = raw['isCaptain'] == true ||
        _string(raw['role']).toLowerCase() == 'captain';
    final isWK = raw['isWicketKeeper'] == true ||
        _string(raw['role']).toLowerCase().contains('wicket');
    final isVC = raw['isViceCaptain'] == true ||
        _string(raw['role']).toLowerCase().contains('vice');

    final roles = <String>[
      if (isCaptain) 'C',
      if (isVC) 'VC',
      if (isWK) 'WK',
    ];

    return MatchSquadPlayer(
      name: name,
      isCaptain: isCaptain,
      isWicketKeeper: isWK,
      roleLabel: roles.isEmpty ? null : roles.join(' · '),
      avatarUrl: _string(user['avatarUrl']).isEmpty
          ? null
          : user['avatarUrl'] as String?,
    );
  }

  List<dynamic> _firstList(Map<String, dynamic> raw, List<String> keys) {
    for (final key in keys) {
      final value = raw[key];
      if (value is List && value.isNotEmpty) return value;
    }
    return const [];
  }

  Map<String, dynamic> _firstNonEmptyMap(
    Map<String, dynamic> raw,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = _map(raw[key]);
      if (value.isNotEmpty) return value;
    }
    return const <String, dynamic>{};
  }

  String _resolveTeamScore({
    required String side,
    required String teamName,
    required Map<String, dynamic> root,
    required List<MatchInnings> innings,
  }) {
    final sideMap = side == 'A'
        ? _firstNonEmptyMap(root, const ['teamA', 'team1'])
        : _firstNonEmptyMap(root, const ['teamB', 'team2']);
    final direct = _firstNonEmpty([
      _string(root['team${side}Score']),
      _scoreFromMap(sideMap),
    ]);
    if (direct.isNotEmpty) return direct;

    if (teamName.isNotEmpty) {
      final matching = innings.where(
        (inning) =>
            _normalizeLabel(inning.title).contains(_normalizeLabel(teamName)),
      );
      if (matching.isNotEmpty) {
        return matching.map((inning) => inning.score).join(' & ');
      }
    }

    return '';
  }

  String _scoreFromMap(Map<String, dynamic> raw) {
    final score = _string(raw['score']);
    if (score.isNotEmpty) return score;
    final runs = raw['runs'];
    final wickets = raw['wickets'];
    final overs = raw['overs'];
    if (runs is num) {
      final wicketsLabel = wickets is num ? '/${wickets.toInt()}' : '';
      final oversLabel = overs != null ? ' (${overs.toString()} ov)' : '';
      return '${runs.toInt()}$wicketsLabel$oversLabel';
    }
    return '';
  }

  String _normalizeLabel(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
  }

  static const _canonicalWagonZones = <String>{
    'straight',
    'third_man',
    'point',
    'cover',
    'long_off',
    'long_on',
    'mid_wicket',
    'square_leg',
    'fine_leg',
  };

  static const _wagonZoneAliases = <String, String>{
    'third-man': 'third_man',
    'third man': 'third_man',
    '3rd man': 'third_man',
    'slip': 'third_man',
    'gully': 'third_man',
    'backward-point': 'point',
    'backward point': 'point',
    'deep-point': 'point',
    'deep point': 'point',
    'extra-cover': 'cover',
    'extra cover': 'cover',
    'deep-cover': 'cover',
    'deep cover': 'cover',
    'deep-extra-cover': 'cover',
    'deep extra cover': 'cover',
    'mid-off': 'long_off',
    'mid off': 'long_off',
    'long-off': 'long_off',
    'long off': 'long_off',
    'straight': 'straight',
    'straight-drive': 'straight',
    'straight drive': 'straight',
    'mid-on': 'long_on',
    'mid on': 'long_on',
    'long-on': 'long_on',
    'long on': 'long_on',
    'deep-mid-wicket': 'mid_wicket',
    'deep mid wicket': 'mid_wicket',
    'mid-wicket': 'mid_wicket',
    'mid wicket': 'mid_wicket',
    'square-leg': 'square_leg',
    'square leg': 'square_leg',
    'deep-square-leg': 'square_leg',
    'deep square leg': 'square_leg',
    'fine-leg': 'fine_leg',
    'fine leg': 'fine_leg',
    'deep-fine-leg': 'fine_leg',
    'deep fine leg': 'fine_leg',
  };

  String? _canonicalWagonZone(String? rawZone) {
    if (rawZone == null) return null;
    var normalized = rawZone.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    if (normalized.endsWith('-in')) {
      normalized = normalized.substring(0, normalized.length - 3);
    }
    if (normalized.endsWith('_in')) {
      normalized = normalized.substring(0, normalized.length - 3);
    }
    normalized = normalized
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    if (normalized.isEmpty) return null;
    if (_canonicalWagonZones.contains(normalized)) return normalized;
    final hyphen = normalized.replaceAll('_', '-');
    final spaced = normalized.replaceAll('_', ' ');
    return _wagonZoneAliases[normalized] ??
        _wagonZoneAliases[hyphen] ??
        _wagonZoneAliases[spaced];
  }

  // ── Derived summary helpers ────────────────────────────────────────────────

  String? _buildMatchCardSummary(
    Map<String, dynamic> stat,
    Map<String, dynamic> match,
    String playerTeamName,
    String opponentTeamName,
  ) {
    // Try explicit summary fields first
    final explicit = _firstNonEmpty([
      _string(match['scoreSummary']),
      _string(match['resultSummary']),
    ]);
    if (explicit.isNotEmpty) return explicit;

    // Build from winnerId + winMargin
    final winnerId = _string(match['winnerId']).toUpperCase();
    if (winnerId.isEmpty) return null;

    if (winnerId == 'DRAW') return 'Match drawn';
    if (winnerId == 'TIE') return 'Match tied';
    if (winnerId == 'ABANDONED') return 'Match abandoned';

    if (winnerId == 'A' || winnerId == 'B') {
      final playerSide = _string(stat['team']).toUpperCase();
      final winnerName = winnerId == 'A'
          ? (playerSide == 'B' ? opponentTeamName : playerTeamName)
          : (playerSide == 'A' ? opponentTeamName : playerTeamName);
      final margin = _string(match['winMargin']);
      final suffix = margin.isNotEmpty ? ' by $margin' : '';
      return '${winnerName.isEmpty ? 'Team' : winnerName} won$suffix';
    }

    return null;
  }

  String? _buildResultSummary(
    Map<String, dynamic> raw,
    String teamAName,
    String teamBName,
  ) {
    // Try explicit summary fields first
    final explicit = _firstNonEmpty([
      _string(raw['resultSummary']),
      _string(raw['summary']),
    ]);
    if (explicit.isNotEmpty) return explicit;

    final winnerId = _string(raw['winnerId']).toUpperCase();
    if (winnerId.isEmpty) return null;

    if (winnerId == 'DRAW') return 'Match ended in a draw';
    if (winnerId == 'TIE') return 'Match tied';
    if (winnerId == 'ABANDONED') return 'Match abandoned';

    final winnerName =
        winnerId == 'A' ? teamAName : (winnerId == 'B' ? teamBName : '');
    if (winnerName.isEmpty) return null;

    final margin = _string(raw['winMargin']);
    return margin.isNotEmpty ? '$winnerName won by $margin' : '$winnerName won';
  }

  String? _resolveWinnerTeamName(
    Map<String, dynamic> raw,
    String teamAName,
    String teamBName,
  ) {
    final winnerId = _string(raw['winnerId']).toUpperCase();
    if (winnerId == 'A' && teamAName.isNotEmpty) return teamAName;
    if (winnerId == 'B' && teamBName.isNotEmpty) return teamBName;

    final namedWinner = _string(raw['winnerName']);
    if (namedWinner.isNotEmpty) return namedWinner;

    final rawWinner = _string(raw['winnerId']);
    if (rawWinner.isNotEmpty &&
        !{'DRAW', 'TIE', 'ABANDONED', 'A', 'B'}
            .contains(rawWinner.toUpperCase())) {
      return rawWinner;
    }

    return null;
  }

  String? _buildTossSummary(
    Map<String, dynamic> raw,
    String teamAName,
    String teamBName,
  ) {
    final explicit = _firstNonEmpty([
      _string(raw['tossSummary']),
      _string(raw['tossResult']),
      _string(raw['toss']),
    ]);
    if (explicit.isNotEmpty) return explicit;

    final tossWonBy = _string(raw['tossWonBy']).toUpperCase();
    final tossDecision = _string(raw['tossDecision']).toUpperCase();
    if (tossWonBy.isEmpty || tossDecision.isEmpty) return null;

    final tossTeam =
        tossWonBy == 'A' ? teamAName : (tossWonBy == 'B' ? teamBName : '');
    if (tossTeam.isEmpty) return null;

    final decision =
        tossDecision == 'BAT' ? 'elected to bat' : 'elected to bowl';
    return '$tossTeam won the toss and $decision';
  }

  // ── Live match state ────────────────────────────────────────────────────────

  MatchLiveState? _buildLiveState({
    required Map<String, dynamic> matchRoot,
    required Map<String, dynamic> playersRoot,
    required Map<String, dynamic> scorecardRoot,
  }) {
    final inningsList =
        _list(matchRoot['innings']).whereType<Map<String, dynamic>>().toList();
    if (inningsList.isEmpty) return null;

    // Find the active (non-completed, non-super-over) innings
    final currentInnings = inningsList.firstWhere(
      (i) => i['isCompleted'] != true && i['isSuperOver'] != true,
      orElse: () => const <String, dynamic>{},
    );
    if (currentInnings.isEmpty) return null;

    final currentStrikerId = _string(currentInnings['currentStrikerId']);
    final currentNonStrikerId = _string(currentInnings['currentNonStrikerId']);
    final currentBowlerId = _string(currentInnings['currentBowlerId']);

    // Build id→name lookup from players endpoint
    final nameById = <String, String>{};
    for (final teamKey in ['teamA', 'teamB']) {
      for (final p in _list(_map(playersRoot[teamKey])['players'])
          .whereType<Map<String, dynamic>>()) {
        final name = _string(p['name']);
        if (name.isEmpty) continue;
        final pid = _string(p['profileId']);
        final uid = _string(p['userId']);
        if (pid.isNotEmpty) nameById[pid] = name;
        if (uid.isNotEmpty) nameById[uid] = name;
      }
    }

    // Build name→stats from live-computed scorecard (active innings only)
    // The scorecard endpoint computes stats directly from BallEvents, so it's
    // always accurate for live matches unlike playerMatchStats.
    final scInningsList = _list(scorecardRoot['innings'])
        .whereType<Map<String, dynamic>>()
        .toList();
    final activeScInnings = scInningsList.firstWhere(
      (i) => i['isCompleted'] != true && i['isSuperOver'] != true,
      orElse: () => scInningsList.isNotEmpty
          ? scInningsList.last
          : const <String, dynamic>{},
    );

    final nameToBat = <String, Map<String, dynamic>>{};
    final nameToBowl = <String, Map<String, dynamic>>{};
    if (activeScInnings.isNotEmpty) {
      for (final row in _list(activeScInnings['batting'])
          .whereType<Map<String, dynamic>>()) {
        final n = _string(row['player'] is String
            ? row['player']
            : _map(row['player'])['name']);
        if (n.isNotEmpty) nameToBat[n] = row;
      }
      for (final row in _list(activeScInnings['bowling'])
          .whereType<Map<String, dynamic>>()) {
        final n = _string(row['player'] is String
            ? row['player']
            : _map(row['player'])['name']);
        if (n.isNotEmpty) nameToBowl[n] = row;
      }
    }

    LiveBatter? makeBatter(String id, bool isStriker) {
      if (id.isEmpty) return null;
      final name = nameById[id];
      if (name == null || name.isEmpty) return null;
      final s = nameToBat[name] ?? const <String, dynamic>{};
      final runs = _intOrNull(s['runs']) ?? 0;
      final balls = _intOrNull(s['balls']) ?? 0;
      final fours = _intOrNull(s['fours']) ?? 0;
      final sixes = _intOrNull(s['sixes']) ?? 0;
      final srRaw = s['strikeRate'];
      final sr = srRaw is num
          ? srRaw.toStringAsFixed(1)
          : (srRaw is String && srRaw.isNotEmpty)
              ? srRaw
              : (balls > 0 ? (runs * 100 / balls).toStringAsFixed(1) : '-');
      return LiveBatter(
        name: name,
        runs: runs,
        balls: balls,
        fours: fours,
        sixes: sixes,
        strikeRate: sr,
        isStriker: isStriker,
      );
    }

    LiveBowler? makeBowler(String id) {
      if (id.isEmpty) return null;
      final name = nameById[id];
      if (name == null || name.isEmpty) return null;
      final s = nameToBowl[name] ?? const <String, dynamic>{};
      final oversRaw = s['overs'] ?? s['oversBowled'];
      final overs = oversRaw is num
          ? oversRaw.toStringAsFixed(1)
          : (oversRaw is String && oversRaw.isNotEmpty ? oversRaw : '0.0');
      final runs = _intOrNull(s['runs'] ?? s['runsConceded']) ?? 0;
      final wickets = _intOrNull(s['wickets']) ?? 0;
      final ecoRaw = s['economy'];
      final economy = ecoRaw is num
          ? ecoRaw.toStringAsFixed(2)
          : (ecoRaw is String && ecoRaw.isNotEmpty ? ecoRaw : '-');
      return LiveBowler(
        name: name,
        overs: overs,
        runs: runs,
        wickets: wickets,
        economy: economy,
      );
    }

    // Current over progress
    final totalOversRaw = currentInnings['totalOvers'];
    final totalOversNum = totalOversRaw is num ? totalOversRaw.toDouble() : 0.0;
    var currentOverNum = totalOversNum.floor();
    final ballsInCurrentOver = ((totalOversNum - currentOverNum) * 10).round();

    final ballEvents = _list(currentInnings['ballEvents'])
        .whereType<Map<String, dynamic>>()
        .toList();

    var currentOverBalls = ballEvents
        .where((b) => (_intOrNull(b['overNumber']) ?? -1) == currentOverNum)
        .map(_ballDisplay)
        .toList();

    // Fallback: if no balls in current over but we just finished an over,
    // show the last over's balls instead of an empty list.
    if (currentOverBalls.isEmpty &&
        currentOverNum > 0 &&
        ballsInCurrentOver == 0) {
      currentOverBalls = ballEvents
          .where(
              (b) => (_intOrNull(b['overNumber']) ?? -1) == currentOverNum - 1)
          .map(_ballDisplay)
          .toList();
    }

    // CRR
    final totalRuns = _intOrNull(currentInnings['totalRuns']) ?? 0;
    final crr = totalOversNum > 0 ? totalRuns / totalOversNum : null;
    final crrLabel = crr?.toStringAsFixed(2);

    // Target / RRR (innings 2 of limited-overs only)
    final inningsNumber = _intOrNull(currentInnings['inningsNumber']) ?? 1;
    final formatOvers =
        _formatOvers(_string(matchRoot['format']).toUpperCase());
    int? target;
    int? toWin;
    int? ballsRemaining;
    String? rrrLabel;

    if (inningsNumber == 2 && formatOvers != null) {
      final inn1 = inningsList.firstWhere(
        (i) => (_intOrNull(i['inningsNumber']) ?? 0) == 1,
        orElse: () => const <String, dynamic>{},
      );
      final inn1Total = _intOrNull(inn1['totalRuns']);
      if (inn1Total != null) {
        target = inn1Total + 1;
        toWin = target - totalRuns;
        final totalBalls = formatOvers * 6;
        final ballsBowled = currentOverNum * 6 + ballsInCurrentOver;
        ballsRemaining = totalBalls - ballsBowled;
        if (ballsRemaining > 0 && toWin > 0) {
          final rrr = toWin * 6 / ballsRemaining;
          rrrLabel = rrr.toStringAsFixed(2);
        }
      }
    }

    return MatchLiveState(
      striker: makeBatter(currentStrikerId, true),
      nonStriker: makeBatter(currentNonStrikerId, false),
      currentBowler: makeBowler(currentBowlerId),
      currentOverBalls: currentOverBalls,
      currentOverNumber: currentOverNum,
      target: target,
      toWin: toWin,
      ballsRemaining: ballsRemaining,
      currentRunRate: crrLabel,
      requiredRunRate: rrrLabel,
    );
  }

  String _ballDisplay(Map<String, dynamic> ball) {
    if (ball['isWicket'] == true) return 'W';
    return switch (_string(ball['outcome']).toUpperCase()) {
      'DOT' => '.',
      'SINGLE' => '1',
      'DOUBLE' => '2',
      'TRIPLE' => '3',
      'FOUR' => '4',
      'SIX' => '6',
      'WIDE' => 'WD',
      'NO_BALL' => 'NB',
      'BYE' => 'B',
      'LEG_BYE' => 'LB',
      _ => '.',
    };
  }

  int? _formatOvers(String format) => switch (format) {
        'T10' => 10,
        'T20' => 20,
        'ONE_DAY' => 50,
        'BOX_CRICKET' => 6,
        _ => null,
      };
}
