import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contracts/host_path_config.dart';
import '../../../providers/host_dio_provider.dart';
import '../domain/match_models.dart';

class HostMatchDetailRepository {
  HostMatchDetailRepository(this._dio, this._paths);

  final Dio _dio;
  final HostPathConfig _paths;

  Future<MatchCenter> loadMatchCenter(String matchId) async {
    final scorecardResponse = await _dio.get(_paths.matchScorecard(matchId));
    final scorecardRoot = _unwrapMap(scorecardResponse.data);

    Map<String, dynamic> matchRoot = const <String, dynamic>{};
    Map<String, dynamic> playersRoot = const <String, dynamic>{};
    Map<String, dynamic> previewRoot = const <String, dynamic>{};
    Map<String, dynamic> overlayRoot = const <String, dynamic>{};
    var overlayLoaded = false;

    Future<Map<String, dynamic>> safeGet(String path) async {
      try {
        final res = await _dio.get(path);
        return _unwrapMap(res.data);
      } catch (_) {
        return const <String, dynamic>{};
      }
    }

    await Future.wait([
      safeGet(_paths.match(matchId)).then((v) => matchRoot = v),
      safeGet(_paths.matchPlayers(matchId)).then((v) => playersRoot = v),
      safeGet(_paths.matchPreview(matchId)).then((v) => previewRoot = v),
      safeGet(_paths.matchOverlay(matchId)).then((v) {
        overlayRoot = v;
        overlayLoaded = v.isNotEmpty;
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

  /// Lightweight fetch — only match + players + scorecard (no preview/overlay).
  /// Used to refresh just the score display without reloading the full page.
  Future<MatchLiveScore> loadLiveScore(String matchId) async {
    Map<String, dynamic> matchRoot = {};
    Map<String, dynamic> playersRoot = {};

    final scorecardRes = await _dio.get(_paths.matchScorecard(matchId));
    final scorecardRoot = _unwrapMap(scorecardRes.data);

    await Future.wait([
      _dio.get(_paths.match(matchId)).then((r) => matchRoot = _unwrapMap(r.data)),
      _dio
          .get(_paths.matchPlayers(matchId))
          .then((r) => playersRoot = _unwrapMap(r.data))
          .catchError((_) {}),
    ]);

    final matchContainer =
        _map(matchRoot['match']).isNotEmpty ? _map(matchRoot['match']) : matchRoot;
    final merged = <String, dynamic>{}
      ..addAll(matchContainer)
      ..addAll(scorecardRoot);

    final teamAName = _entityName(merged['teamA']) ??
        _entityName(merged['team1']) ??
        _str(merged['teamAName']);
    final teamBName = _entityName(merged['teamB']) ??
        _entityName(merged['team2']) ??
        _str(merged['teamBName']);
    final innings =
        _parseInnings(merged, teamAName: teamAName, teamBName: teamBName);

    return MatchLiveScore(
      teamAScore: _resolveTeamScore(
          side: 'A', teamName: teamAName, root: merged, innings: innings),
      teamBScore: _resolveTeamScore(
          side: 'B', teamName: teamBName, root: merged, innings: innings),
      liveState: _buildLiveState(
        matchRoot: matchContainer,
        playersRoot: playersRoot,
        scorecardRoot: scorecardRoot,
      ),
      innings: innings,
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
          final response = await _dio.get<ResponseBody>(
            _paths.matchOverlayStream(matchId),
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
          if (body == null) throw StateError('Live stream unavailable');

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
            if (line.startsWith(':')) continue;
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
          if (!controller.isClosed) controller.addError(error, stackTrace);
        } catch (error, stackTrace) {
          if (!controller.isClosed) controller.addError(error, stackTrace);
        }
        if (closed) break;
        await Future<void>.delayed(const Duration(seconds: 1));
      }
      if (!controller.isClosed) await controller.close();
    }

    controller.onListen = () { unawaited(pump()); };
    controller.onCancel = () {
      closed = true;
      cancelToken?.cancel('stream closed');
    };
    return controller.stream;
  }

  Future<List<MatchCommentaryEntry>> loadCommentary(
    String matchId, {
    int? inningsNum,
    int limit = 500,
    int offset = 0,
  }) async {
    final params = <String, dynamic>{'limit': limit, 'offset': offset};
    if (inningsNum != null) params['innings'] = inningsNum;
    final response = await _dio.get(
      _paths.matchCommentary(matchId),
      queryParameters: params,
    );
    final root = _unwrapMap(response.data);
    return _list(root['commentary'])
        .whereType<Map<String, dynamic>>()
        .map((c) => MatchCommentaryEntry(
              inningsNumber: _intOrNull(c['inningsNumber']) ?? 1,
              over: _str(c['over']),
              overNumber: _intOrNull(c['overNumber']) ?? 0,
              ballNumber: _intOrNull(c['ballNumber']) ?? 0,
              batter: _str(c['batter']),
              bowler: _str(c['bowler']),
              outcome: _str(c['outcome']),
              runs: _intOrNull(c['runs']) ?? 0,
              isWicket: c['isWicket'] == true,
              text: _str(c['text']),
              dismissalType: _orNull(_str(c['dismissalType'])),
              dismissedPlayer: _orNull(_str(c['dismissedPlayer'])),
              fielder: _orNull(_str(c['fielder'])),
              scoreAfterBall: _orNull(_str(c['scoreAfterBall'])),
              teamName: _orNull(_str(c['teamName'])),
              tags: _list(c['tags']).whereType<String>().toList(),
            ))
        .toList();
  }

  Future<MatchAnalysis> loadMatchAnalysis(String matchId) async {
    final response = await _dio.get(_paths.matchAnalysis(matchId));
    final root = _unwrapMap(response.data);
    final innings = _list(root['innings'])
        .whereType<Map<String, dynamic>>()
        .map((inn) => MatchAnalysisInnings(
              inningsNumber: _intOrNull(inn['inningsNumber']) ?? 1,
              battingTeam: _str(inn['battingTeam']),
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
                        over: _str(w['over']),
                        runs: _intOrNull(w['runs']) ?? 0,
                        isWicket: w['isWicket'] == true,
                        batter: _str(w['batter']),
                        zone: _canonicalWagonZone(_orNull(_str(w['zone'] ?? ''))),
                      ))
                  .toList(),
            ))
        .toList();
    return MatchAnalysis(matchId: matchId, innings: innings);
  }

  Future<List<PlayerMatch>> fetchMyMatches() async {
    try {
      final response = await _dio.get(_paths.myMatches);
      final items = _unwrapStatRows(response.data);
      final now = DateTime.now();
      final result = <PlayerMatch>[];
      for (final item in items) {
        if (item is! Map<String, dynamic>) continue;
        final raw = Map<String, dynamic>.from(item);
        // Stat rows from /player/matches have nested `match` with flat team name fields.
        // Hoist teamA/teamB objects so _mapMatch resolves names correctly.
        final matchObj = raw['match'];
        if (matchObj is Map) {
          final m = Map<String, dynamic>.from(matchObj);
          if (_str(m['teamAName']).isNotEmpty && m['teamA'] == null) {
            m['teamA'] = {'name': m['teamAName']};
          }
          if (_str(m['teamBName']).isNotEmpty && m['teamB'] == null) {
            m['teamB'] = {'name': m['teamBName']};
          }
          if (_str(m['venueName']).isNotEmpty && m['venue'] == null) {
            m['venue'] = {'name': m['venueName']};
          }
          if (_str(m['format']).isNotEmpty && m['formatLabel'] == null) {
            m['formatLabel'] = m['format'];
          }
          raw['match'] = m;
        }
        final pm = _mapMatch(raw, now);
        if (pm.id.isNotEmpty) result.add(pm);
      }
      final seen = <String>{};
      final deduped = result.where((m) => seen.add(m.id)).toList();
      final enriched = await Future.wait(deduped.map(_enrichWithPreview));
      return enriched;
    } catch (e) {
      debugPrint('[MyMatches] failed: $e');
      return [];
    }
  }

  Future<PlayerMatch> _enrichWithPreview(PlayerMatch match) async {
    try {
      final res = await _dio.get(_paths.matchPreview(match.id));
      final raw = _unwrapPreview(res.data);
      if (raw.isEmpty) return match;

      final tossText = _orNull(_str(raw['tossText']));

      final inningsList = _list(raw['innings'])
          .whereType<Map<String, dynamic>>()
          .toList();
      String? scoreSummary;
      if (inningsList.isNotEmpty) {
        final parts = inningsList.map((inn) {
          final team = _str(inn['teamName']);
          final runs = inn['runs']?.toString() ?? '0';
          final wkts = inn['wickets']?.toString() ?? '0';
          final overs = _str(inn['overs']);
          return '$team  $runs/$wkts${overs.isNotEmpty ? ' ($overs)' : ''}';
        }).toList();
        scoreSummary = parts.join('\n');
      }

      final winner = _orNull(_str(raw['winner']));
      final margin = _orNull(_str(raw['winMargin']));
      MatchResult? result;
      if (match.lifecycle == MatchLifecycle.past) {
        if (winner == null) {
          result = MatchResult.unknown;
        } else {
          final w = winner.trim().toLowerCase();
          final p = match.playerTeamName.trim().toLowerCase();
          result = w == p ? MatchResult.win : MatchResult.loss;
        }
      }

      if (winner != null && match.lifecycle == MatchLifecycle.past) {
        final resultLine =
            margin != null ? '$winner won by $margin' : '$winner won';
        scoreSummary = scoreSummary != null
            ? '$scoreSummary\n$resultLine'
            : resultLine;
      }

      return match.copyWith(
        scoreSummary: scoreSummary,
        tossWinner: tossText,
        tossDecision: null,
        result: result,
      );
    } catch (_) {
      return match;
    }
  }

  Map<String, dynamic> _unwrapPreview(dynamic data) {
    if (data is Map<String, dynamic>) {
      final d = data['data'];
      if (d is Map<String, dynamic>) return d;
      final m = data['match'];
      if (m is Map<String, dynamic>) return m;
      return data;
    }
    return {};
  }

  // Unwraps { success, data: { data: [...statRows], meta } } → the inner list.
  List<dynamic> _unwrapStatRows(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final outer = data['data'];
      if (outer is List) return outer;
      if (outer is Map) {
        final inner = outer['data'];
        if (inner is List) return inner;
        for (final key in const ['matches', 'items', 'results', 'rows']) {
          final list = outer[key];
          if (list is List) return list;
        }
      }
      for (final key in const ['matches', 'items', 'results', 'rows']) {
        final list = data[key];
        if (list is List) return list;
      }
    }
    return const [];
  }

  Future<List<PlayerMatch>> loadTeamMatches(String teamId) async {
    try {
      final response = await _dio.get(
        _paths.teamMatches(teamId),
        queryParameters: {'limit': 50},
      );
      final items = _unwrapList(response.data);
      final now = DateTime.now();
      final result = <PlayerMatch>[];
      for (final item in items) {
        if (item is! Map<String, dynamic>) continue;
        final raw = Map<String, dynamic>.from(item);
        _normalizeTeamMatchShape(raw);
        final m = _mapMatch(raw, now);
        if (m.id.isNotEmpty || m.title != 'Match') result.add(m);
      }
      return result;
    } catch (e) {
      debugPrint('[TeamMatches] failed: $e');
      return [];
    }
  }

  void _normalizeTeamMatchShape(Map<String, dynamic> raw) {
    if (_str(raw['status']).isEmpty) {
      final hasWinner = _str(raw['winnerId']).isNotEmpty;
      final hasCompletedAt = _str(raw['completedAt']).isNotEmpty;
      if (hasWinner || hasCompletedAt) raw['status'] = 'COMPLETED';
    }
    if (_str(raw['scheduledAt']).isEmpty && _str(raw['completedAt']).isNotEmpty) {
      raw['scheduledAt'] = raw['completedAt'];
    }
    if (_str(raw['teamAName']).isNotEmpty && raw['teamA'] == null) {
      raw['teamA'] = {'name': raw['teamAName']};
    }
    if (_str(raw['teamBName']).isNotEmpty && raw['teamB'] == null) {
      raw['teamB'] = {'name': raw['teamBName']};
    }
    if (_str(raw['teamSide']).isNotEmpty && raw['team'] == null) {
      raw['team'] = raw['teamSide'];
    }
    final winnerId = _str(raw['winnerId']);
    if (winnerId.isNotEmpty &&
        winnerId != 'A' && winnerId != 'B' &&
        winnerId != 'DRAW' && winnerId != 'TIE') {
      final teamAName = _str(raw['teamAName']);
      final teamBName = _str(raw['teamBName']);
      if (teamAName.isNotEmpty && winnerId.toLowerCase() == teamAName.toLowerCase()) {
        raw['winnerId'] = 'A';
      } else if (teamBName.isNotEmpty && winnerId.toLowerCase() == teamBName.toLowerCase()) {
        raw['winnerId'] = 'B';
      }
    }
    if (_str(raw['venueName']).isNotEmpty && raw['venue'] == null) {
      raw['venue'] = {'name': raw['venueName']};
    }
    if (_str(raw['format']).isNotEmpty && raw['formatLabel'] == null) {
      raw['formatLabel'] = raw['format'];
    }
  }

  // ── Mapping ────────────────────────────────────────────────────────────────

  PlayerMatch _mapMatch(Map<String, dynamic> raw, DateTime now) {
    final stat = raw;
    final match = _map(raw['match']).isNotEmpty ? _map(raw['match']) : raw;
    final tournament = _map(match['tournament']);
    final arena = _map(match['arena']);
    final venue = _map(match['venue']);
    final teamA = _entityName(match['teamA']) ??
        _entityName(match['team1']) ??
        _str(match['teamAName']);
    final teamB = _entityName(match['teamB']) ??
        _entityName(match['team2']) ??
        _str(match['teamBName']);
    final teams =
        _list(match['teams']).whereType<Map<String, dynamic>>().toList();

    final firstTeam = teamA.isNotEmpty
        ? teamA
        : (teams.isNotEmpty ? _str(teams.first['name']) : '');
    final secondTeam = teamB.isNotEmpty
        ? teamB
        : (teams.length > 1 ? _str(teams[1]['name']) : '');
    final playerSide = _str(stat['team']).toUpperCase();
    final playerTeamSignal = _normalizeLabel(_firstNonEmpty([
      _entityName(stat['team']) ?? '',
      _str(stat['teamName']),
      _entityName(stat['playerTeam']) ?? '',
      _str(stat['playerTeamName']),
    ]));
    final hasPlayerStatSignal = [
      stat['runs'], stat['balls'], stat['wickets'],
      stat['catches'], stat['overs'], stat['performanceScore'], stat['impactPoints'],
    ].any((v) => v != null);
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
      _str(tournament['name']),
      _str(match['tournamentName']),
    ]);
    final competitionLabel = _firstNonEmpty([
      tournamentLabel,
      _str(match['competitionName']),
      _str(match['seriesName']),
    ]);
    final title = _buildTitle(
      primary: _firstNonEmpty([
        _str(match['title']), _str(match['name']), _str(match['matchTitle']),
      ]),
      firstTeam: firstTeam,
      secondTeam: secondTeam,
      competitionLabel: competitionLabel,
    );
    final scheduledAt = _parseScheduledAt(match);
    final sectionType = _deriveSectionType(match, tournamentLabel);
    final lifecycle = _deriveLifecycle(raw: match, scheduledAt: scheduledAt, now: now);
    final result = _deriveResult(
      stat: stat, match: match,
      playerTeamName: playerTeamName, opponentTeamName: opponentTeamName,
    );
    final statusLabel = _deriveStatusLabel(match, lifecycle);
    final venueLabel = _firstNonEmpty([
      _str(venue['name']), _str(arena['name']),
      _str(match['venueName']), _str(match['location']),
    ]).isEmpty ? null : _firstNonEmpty([
      _str(venue['name']), _str(arena['name']),
      _str(match['venueName']), _str(match['location']),
    ]);
    final rawFormat = _firstNonEmpty([
      _str(match['format']), _str(match['matchFormat']), _str(match['gameFormat']),
    ]);
    return PlayerMatch(
      id: _firstNonEmpty([
        _str(match['id']), _str(match['_id']),
        _str(stat['matchId']), _str(stat['id']),
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
      venueLabel: venueLabel,
      formatLabel: rawFormat.isEmpty
          ? null
          : _displayFormatLabel(rawFormat,
              customOvers: _resolveCustomOvers(match, const {})),
      playerRuns: _intOrNull(stat['runs']),
      playerBalls: _intOrNull(stat['balls']),
      playerWickets: _intOrNull(stat['wickets']),
      playerCatches: _intOrNull(stat['catches']),
      canScore: _hasScoringPermissionFlag(stat) || _hasScoringPermissionFlag(match),
      scoringOwnerIds: scoringOwnerIds.toList(growable: false),
      involvesPlayerTeam: involvesPlayerTeam,
      ballType: _orNull(_firstNonEmpty([_str(match['ballType']), _str(match['ball_type'])])),
      scoreSummary: _buildMatchCardSummary(stat, match, playerTeamName, opponentTeamName),
      tossWinner: _buildTossSummary(match, firstTeam, secondTeam),
      tossDecision: null,
      playerTeamLogoUrl: switch (playerSide) {
        'A' => _orNull(_str(match['teamALogoUrl'])),
        'B' => _orNull(_str(match['teamBLogoUrl'])),
        _ => _orNull(_str(match['teamALogoUrl'])),
      },
      opponentTeamLogoUrl: switch (playerSide) {
        'A' => _orNull(_str(match['teamBLogoUrl'])),
        'B' => _orNull(_str(match['teamALogoUrl'])),
        _ => _orNull(_str(match['teamBLogoUrl'])),
      },
      playerTeamShortName: switch (playerSide) {
        'A' => _orNull(_str(match['teamAShortName'])),
        'B' => _orNull(_str(match['teamBShortName'])),
        _ => _orNull(_str(match['teamAShortName'])),
      },
      opponentTeamShortName: switch (playerSide) {
        'A' => _orNull(_str(match['teamBShortName'])),
        'B' => _orNull(_str(match['teamAShortName'])),
        _ => _orNull(_str(match['teamBShortName'])),
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
        _str(merged['teamAName']);
    final teamBName = _entityName(merged['teamB']) ??
        _entityName(merged['team2']) ??
        _str(merged['teamBName']);
    final tournamentLabel = _firstNonEmpty([
      _str(tournament['name']),
      _str(merged['tournamentName']),
    ]);
    final lifecycle = _deriveLifecycle(
      raw: merged,
      scheduledAt: _parseScheduledAt(merged),
      now: now,
    );
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
    final innings = _parseInnings(merged, teamAName: teamAName, teamBName: teamBName);
    final teamAScore = _resolveTeamScore(side: 'A', teamName: teamAName, root: merged, innings: innings);
    final teamBScore = _resolveTeamScore(side: 'B', teamName: teamBName, root: merged, innings: innings);
    final venueLabel = _firstNonEmpty([
      _str(venue['name']), _str(arena['name']),
      _str(merged['venueName']), _str(merged['location']),
    ]).isEmpty ? null : _firstNonEmpty([
      _str(venue['name']), _str(arena['name']),
      _str(merged['venueName']), _str(merged['location']),
    ]);
    final rawFormat = _firstNonEmpty([
      _str(merged['format']), _str(merged['matchFormat']), _str(merged['gameFormat']),
    ]);

    return MatchCenter(
      id: _firstNonEmpty([_str(merged['id']), _str(merged['_id']), requestedId]),
      title: _buildTitle(
        primary: _firstNonEmpty([_str(merged['title']), _str(merged['name']), _str(merged['matchTitle'])]),
        firstTeam: teamAName,
        secondTeam: teamBName,
        competitionLabel: tournamentLabel,
      ),
      sectionType: _deriveSectionType(merged, tournamentLabel),
      lifecycle: lifecycle,
      statusLabel: _deriveStatusLabel(merged, lifecycle),
      teamAName: teamAName.isEmpty ? 'Team A' : teamAName,
      teamBName: teamBName.isEmpty ? 'Team B' : teamBName,
      teamALogoUrl: _orNull(_firstNonEmpty([
        _str(_map(previewRoot['teamA'])['logoUrl']),
        _str(_map(scorecardRoot['teamA'])['logoUrl']),
        _str(_map(playersRoot['teamA'])['logoUrl']),
      ])),
      teamBLogoUrl: _orNull(_firstNonEmpty([
        _str(_map(previewRoot['teamB'])['logoUrl']),
        _str(_map(scorecardRoot['teamB'])['logoUrl']),
        _str(_map(playersRoot['teamB'])['logoUrl']),
      ])),
      teamAShortName: _orNull(_firstNonEmpty([
        _str(_map(previewRoot['teamA'])['shortName']),
        _str(_map(scorecardRoot['teamA'])['shortName']),
        _str(_map(playersRoot['teamA'])['shortName']),
      ])),
      teamBShortName: _orNull(_firstNonEmpty([
        _str(_map(previewRoot['teamB'])['shortName']),
        _str(_map(scorecardRoot['teamB'])['shortName']),
        _str(_map(playersRoot['teamB'])['shortName']),
      ])),
      teamAScore: teamAScore,
      teamBScore: teamBScore,
      scheduledAt: _parseScheduledAt(merged),
      competitionLabel: tournamentLabel.isEmpty ? null : tournamentLabel,
      venueLabel: venueLabel,
      formatLabel: rawFormat.isEmpty
          ? null
          : _displayFormatLabel(rawFormat, customOvers: _resolveCustomOvers(merged, previewRoot)),
      matchType: _firstNonEmpty([_str(merged['matchType']), _str(merged['type'])]).isEmpty
          ? null
          : _displayLabel(_firstNonEmpty([_str(merged['matchType']), _str(merged['type'])])),
      resultSummary: _buildResultSummary(merged, teamAName, teamBName),
      winnerTeamName: _resolveWinnerTeamName(merged, teamAName, teamBName),
      winMargin: _orNull(_str(merged['winMargin'])),
      overlayLoaded: overlayLoaded,
      youtubeUrl: _orNull(_firstNonEmpty([
        _str(overlayRoot['youtubeUrl']),
        _str(overlayRoot['youtube_url']),
        _str(overlayRoot['streamUrl']),
        _str(overlayRoot['liveStreamUrl']),
        _str(previewRoot['youtubeUrl']),
        _str(previewRoot['youtube_url']),
      ])),
      tossSummary: _orNull(_str(previewRoot['tossText'])) ??
          _buildTossSummary(merged, teamAName, teamBName),
      currentRunRate: liveState?.currentRunRate ??
          _rateLabel(merged, const ['currentRunRate', 'currentRR', 'runRate', 'crr']),
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

  // ── Derive helpers ─────────────────────────────────────────────────────────

  String _buildTitle({
    required String primary,
    required String firstTeam,
    required String secondTeam,
    required String competitionLabel,
  }) {
    if (primary.isNotEmpty) return primary;
    if (firstTeam.isNotEmpty && secondTeam.isNotEmpty) return '$firstTeam vs $secondTeam';
    if (competitionLabel.isNotEmpty) return competitionLabel;
    if (firstTeam.isNotEmpty) return firstTeam;
    return 'Match';
  }

  MatchSectionType _deriveSectionType(Map<String, dynamic> raw, String tournamentLabel) {
    final rawType = _firstNonEmpty([
      _str(raw['type']), _str(raw['matchType']), _str(raw['category']),
    ]).toLowerCase();
    final hasTournament = rawType.contains('tournament') ||
        rawType.contains('league') ||
        (raw['tournamentId'] != null && _str(raw['tournamentId']).isNotEmpty) ||
        _map(raw['tournament']).isNotEmpty ||
        tournamentLabel.isNotEmpty;
    return hasTournament ? MatchSectionType.tournament : MatchSectionType.individual;
  }

  MatchLifecycle _deriveLifecycle({
    required Map<String, dynamic> raw,
    required DateTime? scheduledAt,
    required DateTime now,
  }) {
    final rawStatus = _firstNonEmpty([
      _str(raw['status']), _str(raw['matchStatus']), _str(raw['state']), _str(raw['liveStatus']),
    ]);
    final normalized = rawStatus.toLowerCase();
    final exact = rawStatus.toUpperCase();

    if (const {'SCHEDULED', 'TOSS_DONE', 'TOSS_DELAYED', 'TOSS_PENDING', 'NOT_STARTED', 'YET_TO_START'}.contains(exact)) {
      return MatchLifecycle.upcoming;
    }
    if (const {'IN_PROGRESS', 'LIVE', 'ONGOING', 'STARTED'}.contains(exact)) {
      return MatchLifecycle.live;
    }
    if (const {'COMPLETED', 'ABANDONED', 'CANCELLED', 'CANCELED', 'RESULT', 'FINISHED'}.contains(exact)) {
      return MatchLifecycle.past;
    }
    if (_containsAny(normalized, const ['toss', 'scheduled', 'yet_to_start', 'not_started', 'delayed', 'pending', 'upcoming'])) {
      return MatchLifecycle.upcoming;
    }
    if (_containsAny(normalized, const ['live', 'ongoing', 'in_progress', 'started', 'innings'])) {
      return MatchLifecycle.live;
    }
    if (_containsAny(normalized, const ['complete', 'finished', 'cancelled', 'canceled', 'abandoned', 'result'])) {
      return MatchLifecycle.past;
    }
    if (scheduledAt != null) {
      return scheduledAt.isBefore(now) ? MatchLifecycle.past : MatchLifecycle.upcoming;
    }
    return MatchLifecycle.upcoming;
  }

  String _deriveStatusLabel(Map<String, dynamic> raw, MatchLifecycle lifecycle) {
    final rawStatus = _firstNonEmpty([
      _str(raw['status']), _str(raw['matchStatus']), _str(raw['state']), _str(raw['liveStatus']),
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
    final winnerId = _str(match['winnerId']).toUpperCase();
    final playerSide = _str(stat['team']).toUpperCase();
    if (winnerId == 'DRAW' || winnerId == 'TIE' || winnerId == 'ABANDONED') return MatchResult.draw;
    if (playerSide != 'A' && playerSide != 'B') return MatchResult.unknown;
    if (winnerId == 'A' || winnerId == 'B') {
      return winnerId == playerSide ? MatchResult.win : MatchResult.loss;
    }
    final normalizedWinner = _normalizeLabel(_str(match['winnerId']));
    if (normalizedWinner.isNotEmpty) {
      if (normalizedWinner == _normalizeLabel(playerTeamName)) return MatchResult.win;
      if (normalizedWinner == _normalizeLabel(opponentTeamName)) return MatchResult.loss;
    }
    final summary = _normalizeLabel(_firstNonEmpty([
      _str(match['resultSummary']), _str(match['scoreSummary']),
    ]));
    if (summary.contains('draw') || summary.contains('tie')) return MatchResult.draw;
    return MatchResult.unknown;
  }

  DateTime? _parseScheduledAt(Map<String, dynamic> raw) {
    for (final v in [
      raw['scheduledAt'], raw['startsAt'], raw['startTime'],
      raw['matchDateTime'], raw['dateTime'], raw['date'], raw['matchDate'],
    ]) {
      final parsed = _parseDateTimeValue(v);
      if (parsed != null) return parsed.toLocal();
    }
    final date = _str(raw['matchDate']).isEmpty ? _str(raw['date']) : _str(raw['matchDate']);
    final time = _str(raw['matchTime']).isEmpty ? _str(raw['time']) : _str(raw['matchTime']);
    if (date.isNotEmpty && time.isNotEmpty) {
      return DateTime.tryParse('${date}T$time')?.toLocal();
    }
    return null;
  }

  DateTime? _parseDateTimeValue(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      final trimmed = value.trim();
      final direct = DateTime.tryParse(trimmed);
      if (direct != null) return direct;
      final asInt = int.tryParse(trimmed);
      if (asInt != null) return DateTime.fromMillisecondsSinceEpoch(asInt < 1000000000000 ? asInt * 1000 : asInt);
      return null;
    }
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value < 1000000000000 ? value * 1000 : value);
    if (value is num) {
      final millis = value.toInt();
      return DateTime.fromMillisecondsSinceEpoch(millis < 1000000000000 ? millis * 1000 : millis);
    }
    return null;
  }

  // ── Innings / scoring ──────────────────────────────────────────────────────

  List<MatchInnings> _parseInnings(
    Map<String, dynamic> root, {
    String teamAName = '',
    String teamBName = '',
  }) {
    return _list(root['innings'])
        .whereType<Map<String, dynamic>>()
        .toList()
        .asMap()
        .entries
        .map((e) => _mapInnings(e.value, e.key, teamAName: teamAName, teamBName: teamBName))
        .toList();
  }

  MatchInnings _mapInnings(Map<String, dynamic> raw, int index, {String teamAName = '', String teamBName = ''}) {
    final battingTeamSide = _str(raw['battingTeam']).toUpperCase();
    final isSuperOver = raw['isSuperOver'] == true;
    final isCompleted = raw['isCompleted'] == true;

    final String teamName;
    if (battingTeamSide == 'A' && teamAName.isNotEmpty) {
      teamName = teamAName;
    } else if (battingTeamSide == 'B' && teamBName.isNotEmpty) {
      teamName = teamBName;
    } else {
      teamName = _firstNonEmpty([
        _entityName(raw['battingTeam']) ?? '',
        _entityName(raw['team']) ?? '',
        _str(raw['teamName']),
        _str(raw['name']),
        'Innings ${index + 1}',
      ]);
    }

    const ordinals = ['1st', '2nd', '3rd', '4th'];
    final ordinal = index < ordinals.length ? ordinals[index] : '${index + 1}th';
    final title = isSuperOver ? '$teamName (Super Over)' : '$teamName $ordinal Innings';

    final totalRuns = _intOrNull(raw['totalRuns']);
    final totalWickets = _intOrNull(raw['totalWickets']);
    final totalOvers = raw['totalOvers'];
    String score;
    if (totalRuns != null) {
      final wicketsLabel = totalWickets != null ? '/$totalWickets' : '';
      final oversLabel = totalOvers is num
          ? ' (${totalOvers.toStringAsFixed(1)} ov)'
          : (totalOvers is String && totalOvers.isNotEmpty) ? ' ($totalOvers ov)' : '';
      score = '$totalRuns$wicketsLabel$oversLabel';
    } else {
      score = _firstNonEmpty([_str(raw['score']), _scoreFromMap(raw)]);
      if (score.isEmpty) score = 'Yet to bat';
    }

    final battingRaw = _firstList(raw, const ['batting', 'battingScorecard', 'batters', 'batsmen']);
    final bowlingRaw = _firstList(raw, const ['bowling', 'bowlingScorecard', 'bowlers']);

    return MatchInnings(
      title: title,
      score: score,
      battingTeamName: teamName,
      extras: _intOrNull(raw['extras']) ?? 0,
      isCompleted: isCompleted,
      isSuperOver: isSuperOver,
      batting: battingRaw.whereType<Map<String, dynamic>>().map(_mapBatsmanRow).toList(),
      bowling: bowlingRaw.whereType<Map<String, dynamic>>().map(_mapBowlerRow).toList(),
      fallOfWickets: _list(raw['fallOfWickets'])
          .whereType<Map<String, dynamic>>()
          .map((f) => FallOfWicket(
                wicket: _intOrNull(f['wicket']) ?? 0,
                score: _str(f['score']),
                player: _str(f['player']),
                over: _str(f['over']),
              ))
          .toList(),
      partnerships: _list(raw['partnerships'])
          .whereType<Map<String, dynamic>>()
          .map((p) => MatchPartnership(
                batter1: _str(p['batter1']),
                batter2: _str(p['batter2']),
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
      playerRaw is Map<String, dynamic> ? _str(playerRaw['name']) : '',
      _str(raw['name']),
      _str(raw['playerName']),
      _str(raw['batterName']),
      _str(_map(raw['player'])['name']),
      _str(_map(_map(raw['player'])['user'])['name']),
    ]);
    final sr = raw['strikeRate'];
    final srLabel = sr is num ? sr.toStringAsFixed(1) : (sr is String && sr.isNotEmpty ? sr : '-');
    final dismissalType = _str(raw['dismissalType']);
    return MatchBatsmanRow(
      playerId: _orNull(_firstNonEmpty([_str(raw['playerId']), _str(_map(raw['player'])['id'])])),
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
      _str(raw['name']), _str(raw['playerName']), _str(raw['bowlerName']),
    ]);
    final eco = raw['economy'];
    final ecoLabel = eco is num ? eco.toStringAsFixed(2) : (eco is String && eco.isNotEmpty ? eco : '-');
    final oversRaw = raw['overs'] ?? raw['oversBowled'];
    final overs = oversRaw is num
        ? oversRaw.toStringAsFixed(1)
        : (_str(oversRaw as Object? ?? '').isNotEmpty ? _str(oversRaw) : '0.0');
    return MatchBowlerRow(
      playerId: _orNull(_firstNonEmpty([_str(raw['playerId']), _str(_map(raw['player'])['id'])])),
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
        totalImpactPoints: _intOrNull(breakdown['totalImpactPoints']) ?? (_intOrNull(item['impactPoints']) ?? 0),
        playingPoints: _intOrNull(breakdown['playingPoints']) ?? 0,
        battingPoints: _intOrNull(breakdown['battingPoints']) ?? 0,
        bowlingPoints: _intOrNull(breakdown['bowlingPoints']) ?? 0,
        fieldingPoints: _intOrNull(breakdown['fieldingPoints']) ?? 0,
        winBonusPoints: _intOrNull(breakdown['winBonusPoints']) ?? 0,
        mvpBonusPoints: _intOrNull(breakdown['mvpBonusPoints']) ?? 0,
        battingDetails: MatchImpactBattingDetails(
          runsPoints: _intOrNull(batting['runsPoints']) ?? 0,
          boundaryBonusPoints: _intOrNull(batting['boundaryBonusPoints']) ?? 0,
          strikeRateBonusPoints: _intOrNull(batting['strikeRateBonusPoints']) ?? 0,
          contributionBonusPoints: _intOrNull(batting['contributionBonusPoints']) ?? 0,
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
              playerId: _str(item['playerId']),
              playerName: _str(item['playerName'], fb: 'Player'),
              teamName: _str(item['teamName']),
              impactPoints: _intOrNull(item['impactPoints']) ?? 0,
              performanceScore: (item['performanceScore'] as num?)?.toDouble() ?? 0.0,
              isMvp: item['isMvp'] == true,
              summary: _str(item['summary'], fb: 'Impact sample building'),
              breakdown: parseBreakdown(item),
            ))
        .toList();

    final mvpRaw = _map(raw['mvp']);
    final mvp = mvpRaw.isEmpty
        ? null
        : MatchCompetitiveEntry(
            playerId: _str(mvpRaw['playerId']),
            playerName: _str(mvpRaw['playerName'], fb: 'Player'),
            teamName: _str(mvpRaw['teamName']),
            impactPoints: _intOrNull(mvpRaw['impactPoints']) ?? 0,
            performanceScore: (mvpRaw['performanceScore'] as num?)?.toDouble() ?? 0.0,
            isMvp: mvpRaw['isMvp'] == true,
            summary: _str(mvpRaw['summary'], fb: 'Impact sample building'),
            breakdown: parseBreakdown(mvpRaw),
          );

    final infoRaw = _map(raw['info']);
    return MatchCompetitiveSummary(
      source: _str(raw['source'], fb: 'UNAVAILABLE'),
      isOfficial: raw['isOfficial'] == true,
      isProvisional: raw['isProvisional'] == true,
      mvp: mvp,
      leaderboard: leaderboard,
      info: MatchImpactInfo(
        title: _str(infoRaw['title'], fb: 'How Impact Points Work'),
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
    final pTeamA = _map(playersRoot['teamA']);
    final pTeamB = _map(playersRoot['teamB']);
    if (pTeamA.isNotEmpty || pTeamB.isNotEmpty) {
      final squads = <MatchSquad>[];
      if (pTeamA.isNotEmpty) {
        squads.add(_buildSquadFromPlayersEndpoint(
          teamName: _str(pTeamA['name']).isEmpty ? teamAName : _str(pTeamA['name']),
          captainId: _str(pTeamA['captainId']),
          viceCaptainId: _str(pTeamA['viceCaptainId']),
          wicketKeeperId: _str(pTeamA['wicketKeeperId']),
          players: _list(pTeamA['players']),
        ));
      }
      if (pTeamB.isNotEmpty) {
        squads.add(_buildSquadFromPlayersEndpoint(
          teamName: _str(pTeamB['name']).isEmpty ? teamBName : _str(pTeamB['name']),
          captainId: _str(pTeamB['captainId']),
          viceCaptainId: _str(pTeamB['viceCaptainId']),
          wicketKeeperId: _str(pTeamB['wicketKeeperId']),
          players: _list(pTeamB['players']),
        ));
      }
      if (squads.any((s) => s.players.isNotEmpty)) return squads;
    }

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
    ].where((s) => s.players.isNotEmpty).toList();

    if (squads.isNotEmpty) return squads;

    return _list(root['teams'])
        .whereType<Map<String, dynamic>>()
        .map((team) => _buildSquad(teamName: _entityName(team) ?? 'Squad', source: team, fallback: const []))
        .where((s) => s.players.isNotEmpty)
        .toList();
  }

  MatchSquad _buildSquadFromPlayersEndpoint({
    required String teamName,
    required String captainId,
    required String viceCaptainId,
    required String wicketKeeperId,
    required List<dynamic> players,
  }) {
    final parsed = players.whereType<Map<String, dynamic>>().map((p) {
      final profileId = _str(p['profileId']);
      final userId = _str(p['userId']);
      bool matches(String id) => id.isNotEmpty && (profileId == id || userId == id);
      final isCaptain = matches(captainId);
      final isViceCaptain = matches(viceCaptainId);
      final isWicketKeeper = matches(wicketKeeperId);
      final name = _firstNonEmpty([_str(p['name']), _str(_map(p['user'])['name'])]);
      if (name.isEmpty) return null;
      return MatchSquadPlayer(
        name: name,
        isCaptain: isCaptain,
        isViceCaptain: isViceCaptain,
        isWicketKeeper: isWicketKeeper,
        avatarUrl: _str(p['avatarUrl']).isEmpty ? _str(_map(p['user'])['avatarUrl']) : _str(p['avatarUrl']),
        roleLabel: _orNull([
          if (isCaptain) 'Captain',
          if (isViceCaptain) 'Vice Captain',
          if (isWicketKeeper) 'Wicket Keeper',
        ].join(', ')),
      );
    }).whereType<MatchSquadPlayer>().toList();
    return MatchSquad(teamName: teamName, players: parsed);
  }

  MatchSquad _buildSquad({
    required String teamName,
    required Map<String, dynamic> source,
    required List<dynamic> fallback,
  }) {
    final players = _firstList(source, const ['playingXI', 'playing11', 'lineup', 'players', 'squad']);
    final resolved = players.isNotEmpty ? players : fallback;
    return MatchSquad(
      teamName: teamName,
      players: resolved.map(_mapSquadPlayer).whereType<MatchSquadPlayer>().toList(),
    );
  }

  MatchSquadPlayer? _mapSquadPlayer(dynamic raw) {
    if (raw is String && raw.trim().isNotEmpty) return MatchSquadPlayer(name: raw.trim());
    if (raw is! Map<String, dynamic>) return null;
    final user = _map(raw['user']);
    final name = _firstNonEmpty([_str(raw['name']), _str(raw['playerName']), _str(user['name'])]);
    if (name.isEmpty) return null;
    final isCaptain = raw['isCaptain'] == true || _str(raw['role']).toLowerCase() == 'captain';
    final isWK = raw['isWicketKeeper'] == true || _str(raw['role']).toLowerCase().contains('wicket');
    final isVC = raw['isViceCaptain'] == true || _str(raw['role']).toLowerCase().contains('vice');
    final roles = <String>[if (isCaptain) 'C', if (isVC) 'VC', if (isWK) 'WK'];
    return MatchSquadPlayer(
      name: name,
      isCaptain: isCaptain,
      isWicketKeeper: isWK,
      roleLabel: roles.isEmpty ? null : roles.join(' · '),
      avatarUrl: _str(user['avatarUrl']).isEmpty ? null : user['avatarUrl'] as String?,
    );
  }

  // ── Live state ─────────────────────────────────────────────────────────────

  MatchLiveState? _buildLiveState({
    required Map<String, dynamic> matchRoot,
    required Map<String, dynamic> playersRoot,
    required Map<String, dynamic> scorecardRoot,
  }) {
    final inningsList = _list(matchRoot['innings']).whereType<Map<String, dynamic>>().toList();
    if (inningsList.isEmpty) return null;

    final currentInnings = inningsList.firstWhere(
      (i) => i['isCompleted'] != true && i['isSuperOver'] != true,
      orElse: () => const <String, dynamic>{},
    );
    if (currentInnings.isEmpty) return null;

    final currentStrikerId = _str(currentInnings['currentStrikerId']);
    final currentNonStrikerId = _str(currentInnings['currentNonStrikerId']);
    final currentBowlerId = _str(currentInnings['currentBowlerId']);

    final nameById = <String, String>{};
    for (final teamKey in ['teamA', 'teamB']) {
      for (final p in _list(_map(playersRoot[teamKey])['players']).whereType<Map<String, dynamic>>()) {
        final name = _str(p['name']);
        if (name.isEmpty) continue;
        final pid = _str(p['profileId']);
        final uid = _str(p['userId']);
        if (pid.isNotEmpty) nameById[pid] = name;
        if (uid.isNotEmpty) nameById[uid] = name;
      }
    }

    final scInningsList = _list(scorecardRoot['innings']).whereType<Map<String, dynamic>>().toList();
    final activeScInnings = scInningsList.firstWhere(
      (i) => i['isCompleted'] != true && i['isSuperOver'] != true,
      orElse: () => scInningsList.isNotEmpty ? scInningsList.last : const <String, dynamic>{},
    );

    final nameToBat = <String, Map<String, dynamic>>{};
    final nameToBowl = <String, Map<String, dynamic>>{};
    if (activeScInnings.isNotEmpty) {
      for (final row in _list(activeScInnings['batting']).whereType<Map<String, dynamic>>()) {
        final n = _str(row['player'] is String ? row['player'] : _map(row['player'])['name']);
        if (n.isNotEmpty) nameToBat[n] = row;
      }
      for (final row in _list(activeScInnings['bowling']).whereType<Map<String, dynamic>>()) {
        final n = _str(row['player'] is String ? row['player'] : _map(row['player'])['name']);
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
      return LiveBatter(name: name, runs: runs, balls: balls, fours: fours, sixes: sixes, strikeRate: sr, isStriker: isStriker);
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
      return LiveBowler(name: name, overs: overs, runs: runs, wickets: wickets, economy: economy);
    }

    final totalOversRaw = currentInnings['totalOvers'];
    final totalOversNum = totalOversRaw is num ? totalOversRaw.toDouble() : 0.0;
    final currentOverNum = totalOversNum.floor();
    final ballsInCurrentOver = ((totalOversNum - currentOverNum) * 10).round();
    final ballEvents = _list(currentInnings['ballEvents']).whereType<Map<String, dynamic>>().toList();

    var currentOverBalls = ballEvents
        .where((b) => (_intOrNull(b['overNumber']) ?? -1) == currentOverNum)
        .map(_ballDisplay)
        .toList();
    if (currentOverBalls.isEmpty && currentOverNum > 0 && ballsInCurrentOver == 0) {
      currentOverBalls = ballEvents
          .where((b) => (_intOrNull(b['overNumber']) ?? -1) == currentOverNum - 1)
          .map(_ballDisplay)
          .toList();
    }

    final totalRuns = _intOrNull(currentInnings['totalRuns']) ?? 0;
    final crr = totalOversNum > 0 ? totalRuns / totalOversNum : null;
    final crrLabel = crr?.toStringAsFixed(2);
    final inningsNumber = _intOrNull(currentInnings['inningsNumber']) ?? 1;
    final formatOvers = _formatOvers(_str(matchRoot['format']).toUpperCase());
    int? target, toWin, ballsRemaining;
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
          rrrLabel = (toWin * 6 / ballsRemaining).toStringAsFixed(2);
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
    return switch (_str(ball['outcome']).toUpperCase()) {
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

  // ── Summary helpers ────────────────────────────────────────────────────────

  String? _buildMatchCardSummary(
    Map<String, dynamic> stat,
    Map<String, dynamic> match,
    String playerTeamName,
    String opponentTeamName,
  ) {
    final explicit = _firstNonEmpty([_str(match['scoreSummary']), _str(match['resultSummary'])]);
    if (explicit.isNotEmpty) return explicit;
    final winnerId = _str(match['winnerId']).toUpperCase();
    if (winnerId.isEmpty) return null;
    if (winnerId == 'DRAW') return 'Match drawn';
    if (winnerId == 'TIE') return 'Match tied';
    if (winnerId == 'ABANDONED') return 'Match abandoned';
    if (winnerId == 'A' || winnerId == 'B') {
      final playerSide = _str(stat['team']).toUpperCase();
      final winnerName = winnerId == 'A'
          ? (playerSide == 'B' ? opponentTeamName : playerTeamName)
          : (playerSide == 'A' ? opponentTeamName : playerTeamName);
      final margin = _str(match['winMargin']);
      final suffix = margin.isNotEmpty ? ' by $margin' : '';
      return '${winnerName.isEmpty ? 'Team' : winnerName} won$suffix';
    }
    // UUID or named winner
    final resolvedWinner = _resolveWinnerTeamName(match, playerTeamName, opponentTeamName);
    if (resolvedWinner != null) {
      final margin = _str(match['winMargin']);
      final suffix = margin.isNotEmpty ? ' by $margin' : '';
      return '$resolvedWinner won$suffix';
    }
    return null;
  }

  String? _buildResultSummary(Map<String, dynamic> raw, String teamAName, String teamBName) {
    final explicit = _firstNonEmpty([_str(raw['resultSummary']), _str(raw['summary'])]);
    if (explicit.isNotEmpty) return explicit;
    final winnerId = _str(raw['winnerId']).toUpperCase();
    if (winnerId.isEmpty) return null;
    if (winnerId == 'DRAW') return 'Match ended in a draw';
    if (winnerId == 'TIE') return 'Match tied';
    if (winnerId == 'ABANDONED') return 'Match abandoned';
    final winnerName = winnerId == 'A' ? teamAName : (winnerId == 'B' ? teamBName : '');
    if (winnerName.isEmpty) return null;
    final margin = _str(raw['winMargin']);
    return margin.isNotEmpty ? '$winnerName won by $margin' : '$winnerName won';
  }

  String? _resolveWinnerTeamName(Map<String, dynamic> raw, String teamAName, String teamBName) {
    final winnerId = _str(raw['winnerId']).toUpperCase();
    if (winnerId == 'A' && teamAName.isNotEmpty) return teamAName;
    if (winnerId == 'B' && teamBName.isNotEmpty) return teamBName;
    final namedWinner = _str(raw['winnerName']);
    if (namedWinner.isNotEmpty) return namedWinner;
    final rawWinner = _str(raw['winnerId']);
    if (rawWinner.isNotEmpty && !{'DRAW', 'TIE', 'ABANDONED', 'A', 'B'}.contains(rawWinner.toUpperCase())) {
      return rawWinner;
    }
    return null;
  }

  String? _buildTossSummary(Map<String, dynamic> raw, String teamAName, String teamBName) {
    final explicit = _firstNonEmpty([_str(raw['tossSummary']), _str(raw['tossResult']), _str(raw['toss'])]);
    if (explicit.isNotEmpty) return explicit;
    final tossWonBy = _str(raw['tossWonBy']).toUpperCase();
    final tossDecision = _str(raw['tossDecision']).toUpperCase();
    if (tossWonBy.isEmpty || tossDecision.isEmpty) return null;
    final tossTeam = tossWonBy == 'A' ? teamAName : (tossWonBy == 'B' ? teamBName : '');
    if (tossTeam.isEmpty) return null;
    final decision = tossDecision == 'BAT' ? 'elected to bat' : 'elected to bowl';
    return '$tossTeam won the toss and $decision';
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
    final direct = _firstNonEmpty([_str(root['team${side}Score']), _scoreFromMap(sideMap)]);
    if (direct.isNotEmpty) return direct;
    if (teamName.isNotEmpty) {
      final matching = innings.where(
        (inning) => _normalizeLabel(inning.title).contains(_normalizeLabel(teamName)),
      );
      if (matching.isNotEmpty) return matching.map((inning) => inning.score).join(' & ');
    }
    return '';
  }

  String _scoreFromMap(Map<String, dynamic> raw) {
    final score = _str(raw['score']);
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

  // ── Wagon wheel ────────────────────────────────────────────────────────────

  static const _canonicalWagonZones = <String>{
    'straight', 'third_man', 'point', 'cover', 'long_off',
    'long_on', 'mid_wicket', 'square_leg', 'fine_leg',
  };
  static const _wagonZoneAliases = <String, String>{
    'third-man': 'third_man', 'third man': 'third_man', '3rd man': 'third_man',
    'slip': 'third_man', 'gully': 'third_man',
    'backward-point': 'point', 'backward point': 'point', 'deep-point': 'point', 'deep point': 'point',
    'extra-cover': 'cover', 'extra cover': 'cover', 'deep-cover': 'cover', 'deep cover': 'cover',
    'deep-extra-cover': 'cover', 'deep extra cover': 'cover',
    'mid-off': 'long_off', 'mid off': 'long_off', 'long-off': 'long_off', 'long off': 'long_off',
    'straight': 'straight', 'straight-drive': 'straight', 'straight drive': 'straight',
    'mid-on': 'long_on', 'mid on': 'long_on', 'long-on': 'long_on', 'long on': 'long_on',
    'deep-mid-wicket': 'mid_wicket', 'deep mid wicket': 'mid_wicket', 'mid-wicket': 'mid_wicket', 'mid wicket': 'mid_wicket',
    'square-leg': 'square_leg', 'square leg': 'square_leg', 'deep-square-leg': 'square_leg', 'deep square leg': 'square_leg',
    'fine-leg': 'fine_leg', 'fine leg': 'fine_leg', 'deep-fine-leg': 'fine_leg', 'deep fine leg': 'fine_leg',
  };

  String? _canonicalWagonZone(String? rawZone) {
    if (rawZone == null) return null;
    var normalized = rawZone.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    if (normalized.endsWith('-in')) normalized = normalized.substring(0, normalized.length - 3);
    if (normalized.endsWith('_in')) normalized = normalized.substring(0, normalized.length - 3);
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_|_$'), '');
    if (normalized.isEmpty) return null;
    if (_canonicalWagonZones.contains(normalized)) return normalized;
    final hyphen = normalized.replaceAll('_', '-');
    final spaced = normalized.replaceAll('_', ' ');
    return _wagonZoneAliases[normalized] ?? _wagonZoneAliases[hyphen] ?? _wagonZoneAliases[spaced];
  }

  // ── Generic helpers ────────────────────────────────────────────────────────

  Map<String, dynamic> _unwrapMap(dynamic data) {
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

  List<dynamic> _unwrapList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final inner = data['data'];
      if (inner is List) return inner;
      for (final key in const ['matches', 'items', 'results', 'rows']) {
        final nested = data[key];
        if (nested is List) return nested;
      }
    }
    return const [];
  }

  Map<String, dynamic> _map(dynamic v) => v is Map<String, dynamic> ? v : <String, dynamic>{};
  List<dynamic> _list(dynamic v) => v is List ? v : const [];

  String? _entityName(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value is Map<String, dynamic>) {
      final label = _firstNonEmpty([
        _str(value['name']), _str(value['teamName']), _str(value['shortName']),
      ]);
      return label.isEmpty ? null : label;
    }
    return null;
  }

  String _str(dynamic v, {String fb = ''}) {
    final s = v?.toString().trim() ?? '';
    return s.isEmpty ? fb : s;
  }
  String? _orNull(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
  String _firstNonEmpty(List<String> values) {
    for (final v in values) { if (v.trim().isNotEmpty) return v.trim(); }
    return '';
  }
  int? _intOrNull(dynamic v) => (v as num?)?.toInt();
  bool _truthy(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) { final n = v.trim().toLowerCase(); return n == 'true' || n == '1' || n == 'yes' || n == 'y'; }
    return false;
  }
  bool _containsAny(String v, List<String> patterns) => patterns.any(v.contains);
  String _normalizeLabel(String v) => v.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
  String _displayLabel(String raw) => raw.replaceAll('-', '_').split('_').where((p) => p.isNotEmpty).map((p) => '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}').join(' ');
  String _displayFormatLabel(String raw, {int? customOvers}) {
    return switch (raw.toUpperCase()) {
      'T10' => 'T10',
      'T20' => 'T20',
      'ONE_DAY' => 'ODI',
      'TWO_INNINGS' => 'Test Match',
      'CUSTOM' => customOvers != null && customOvers > 0 ? 'Custom · $customOvers Overs' : 'Custom',
      _ => _displayLabel(raw),
    };
  }
  int? _resolveCustomOvers(Map<String, dynamic> primary, Map<String, dynamic> secondary) {
    for (final k in const ['customOvers', 'maxOvers', 'oversPerInnings', 'noOfOvers', 'numberOfOvers', 'matchOvers']) {
      final v = primary[k] ?? secondary[k];
      if (v is num && v > 0) return v.toInt();
    }
    return null;
  }
  String? _rateLabel(Map<String, dynamic> raw, List<String> keys) {
    for (final key in keys) {
      final v = raw[key];
      if (v is num) return v.toStringAsFixed(1);
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }
  bool _hasScoringPermissionFlag(Map<String, dynamic> source) =>
      _truthy(source['canScore']) || _truthy(source['isHost']) ||
      _truthy(source['isScorer']) || _truthy(source['isOwner']) || _truthy(source['isManager']);

  List<String> _collectScoringOwnerIds(Map<String, dynamic> source) {
    final ids = <String>{};
    void add(dynamic v) {
      final s = '$v'.trim();
      if (s.isNotEmpty && s != 'null') ids.add(s);
    }
    for (final k in const [
      'scorerId', 'scorerProfileId', 'scorerPlayerId', 'hostId', 'hostProfileId', 'hostPlayerId',
      'ownerId', 'ownerProfileId', 'ownerPlayerId', 'managerId', 'managerProfileId',
      'organizerId', 'organizerProfileId', 'createdBy', 'createdById', 'createdByProfileId',
      'createdByPlayerId', 'userId', 'playerId', 'profileId',
    ]) { add(source[k]); }
    for (final nested in [
      _map(source['scorer']), _map(source['host']), _map(source['owner']),
      _map(source['manager']), _map(source['createdByUser']), _map(source['createdBy']), _map(source['organizer']),
    ]) {
      add(nested['id']); add(nested['_id']); add(nested['profileId']);
      add(nested['playerId']); add(nested['playerProfileId']); add(nested['userId']);
    }
    return ids.toList(growable: false);
  }

  List<dynamic> _firstList(Map<String, dynamic> raw, List<String> keys) {
    for (final key in keys) {
      final v = raw[key];
      if (v is List && v.isNotEmpty) return v;
    }
    return const [];
  }

  Map<String, dynamic> _firstNonEmptyMap(Map<String, dynamic> raw, List<String> keys) {
    for (final key in keys) {
      final v = _map(raw[key]);
      if (v.isNotEmpty) return v;
    }
    return const <String, dynamic>{};
  }
}

final hostMatchDetailRepositoryProvider = Provider<HostMatchDetailRepository>(
  (ref) => HostMatchDetailRepository(
    ref.watch(hostDioProvider),
    ref.watch(hostPathConfigProvider),
  ),
);
