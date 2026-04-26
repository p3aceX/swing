import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contracts/host_path_config.dart';
import '../../../providers/host_dio_provider.dart';
import '../domain/team_models.dart';
import '../../match_detail/domain/match_models.dart';

class HostTeamDetailRepository {
  HostTeamDetailRepository(this._dio, this._paths);

  final Dio _dio;
  final HostPathConfig _paths;

  Future<PlayerTeam> loadTeam(String teamId, {String? currentUserId}) async {
    final response = await _dio.get(_paths.teamPublic(teamId));
    final root = _unwrapMap(response.data);
    return _mapTeam(root, currentUserId: currentUserId ?? '');
  }

  Future<TeamAnalytics?> loadTeamAnalytics(String teamId) async {
    try {
      final response = await _dio.get(_paths.teamAnalytics(teamId));
      final root = _unwrapMap(response.data);
      return TeamAnalytics.fromJson(root);
    } catch (e) {
      debugPrint('[TeamAnalytics] failed: $e');
      return null;
    }
  }

  Future<List<PlayerMatch>> loadTeamMatches(String teamId) async {
    try {
      final response = await _dio.get(
        _paths.teamMatches(teamId),
        queryParameters: {'limit': 50},
      );
      final items = _unwrapList(response.data);
      final now = DateTime.now();
      final matches = items
          .whereType<Map<String, dynamic>>()
          .map((raw) => _mapMatch(raw, now))
          .where((m) => m.id.isNotEmpty)
          .toList();

      // Enrich with preview data (score + toss) in parallel.
      final enriched = await Future.wait(
        matches.map((m) => _enrichWithPreview(m)),
      );
      return enriched;
    } catch (e) {
      debugPrint('[TeamMatches] failed: $e');
      return [];
    }
  }

  Future<PlayerMatch> _enrichWithPreview(PlayerMatch match) async {
    try {
      final res = await _dio.get(_paths.matchPreview(match.id));
      final raw = _unwrapPreview(res.data);
      if (raw.isEmpty) return match;

      // Toss: preview returns a ready-made string.
      final tossText = _orNull(_str(raw['tossText']));

      // Score: build from innings array.
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

      // Result: derive from winner field (team name string from preview).
      // The list endpoint's `won` field is unreliable — use preview's `winner`.
      final winner = _orNull(_str(raw['winner']));
      final margin = _orNull(_str(raw['winMargin']));
      MatchResult? result;
      if (match.lifecycle == MatchLifecycle.past) {
        if (winner == null) {
          result = MatchResult.unknown;
        } else {
          // Normalize both for comparison (strip extra spaces, lowercase).
          final w = winner.trim().toLowerCase();
          final p = match.playerTeamName.trim().toLowerCase();
          result = w == p ? MatchResult.win : MatchResult.loss;
        }
      }

      // Result line appended after score.
      if (winner != null && match.lifecycle == MatchLifecycle.past) {
        final resultLine = margin != null
            ? '$winner won by $margin'
            : '$winner won';
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
    } catch (e) {
      debugPrint('[Preview] ${match.id} FAILED: $e');
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

  Future<void> updateTeam({
    required String teamId,
    String? name,
    String? shortName,
    String? city,
    String? teamType,
    String? logoUrl,
  }) async {
    final payload = {
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      if (shortName != null) 'shortName': shortName.trim(),
      if (city != null) 'city': city.trim(),
      if (teamType != null) 'teamType': teamType,
      if (logoUrl != null && logoUrl.isNotEmpty) 'logoUrl': logoUrl,
    };
    await _dio.patch(_paths.teamUpdate(teamId), data: payload);
  }

  Future<void> addPlayer({
    required String teamId,
    required String profileId,
  }) async {
    final res = await _dio.post(
      _paths.teamQuickAdd(teamId),
      data: {'profileId': profileId},
    );
    final body = _unwrapMap(res.data);
    if (body['alreadyInTeam'] == true) {
      throw Exception('Player is already in this team');
    }
  }

  Future<void> quickAddPlayer({
    required String teamId,
    required String name,
    required String phone,
  }) async {
    final res = await _dio.post(
      _paths.teamQuickAdd(teamId),
      data: {'name': name.trim(), 'phone': phone.trim()},
    );
    final body = _unwrapMap(res.data);
    if (body['alreadyInTeam'] == true) {
      throw Exception('Player is already in this team');
    }
  }

  Future<void> removePlayer({
    required String teamId,
    required String profileId,
  }) async {
    await _dio.delete(_paths.teamMember(teamId, profileId));
  }

  Future<void> deleteTeam(String teamId) async {
    await _dio.delete(_paths.teamDelete(teamId));
  }

  Future<void> joinTeam(String teamId) async {
    await _dio.post(_paths.teamJoin(teamId));
  }

  Future<bool> getFollowStatus(String teamId) async {
    try {
      final res = await _dio.get(_paths.teamFollowStatus(teamId));
      final data = _unwrapMap(res.data);
      return data['isFollowing'] == true || data['following'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> followTeam(String teamId) async {
    await _dio.post(_paths.teamFollow(teamId));
  }

  Future<void> unfollowTeam(String teamId) async {
    await _dio.delete(_paths.teamFollow(teamId));
  }

  Future<List<TeamPlayerSearchResult>> searchPlayers(String query) async {
    final response = await _dio.get(
      _paths.playerSearch,
      queryParameters: {'q': query, 'limit': 20, 'type': 'players'},
    );
    final payload = _unwrapMap(response.data);
    // Response: { players: [...], teams: [...], ... }
    return _list(payload['players'])
        .whereType<Map<String, dynamic>>()
        .map((raw) => TeamPlayerSearchResult(
              userId: _str(raw['userId']),
              profileId: _str(raw['profileId']),
              name: _str(raw['name'], fb: 'Player'),
              phone: _orNull(_str(raw['phone'])),
              avatarUrl: _orNull(_str(raw['avatarUrl'])),
              playerRole: _orNull(_str(raw['playerRole'])
                  .replaceAll('_', ' ')),
              playerLevel: _orNull(_str(raw['playerLevel'])
                  .replaceAll('_', ' ')),
              swingIndex: (raw['swingIndex'] as num?)?.toDouble(),
            ))
        .where((p) => p.profileId.isNotEmpty)
        .toList();
  }

  // ── Mapping helpers ─────────────────────────────────────────────────────

  PlayerTeam _mapTeam(Map<String, dynamic> raw, {required String currentUserId}) {
    // The public endpoint returns members with boolean role flags.
    // Fallback to the older players/squad keys for forward-compat.
    final playersNode = raw['members'] ?? raw['players'] ?? raw['squad'];
    final players = _list(playersNode)
        .whereType<Map<String, dynamic>>()
        .toList();

    final members = players.map((player) {
      // Public endpoint uses 'profileId'; older shapes may use 'id'.
      final profileId = _str(player['profileId']).isNotEmpty
          ? _str(player['profileId'])
          : _str(player['id']);

      // Boolean flags from public endpoint.
      final isCaptain = player['isCaptain'] == true;
      final isViceCaptain = player['isViceCaptain'] == true;
      final isWicketKeeper = player['isWicketKeeper'] == true;

      // Fallback: derive roles from roleAssignments if boolean flags absent.
      List<String> roles;
      if (isCaptain || isViceCaptain || isWicketKeeper) {
        roles = <String>[
          if (isCaptain) 'Captain',
          if (isViceCaptain) 'Vice Captain',
          if (isWicketKeeper) 'Wicketkeeper',
        ];
      } else {
        final ra = _map(raw['roleAssignments']);
        final captainId = _str(_map(ra['captain'])['id']);
        final vcId = _str(_map(ra['viceCaptain'])['id']);
        final wkId = _str(_map(ra['wicketKeeper'])['id']);
        roles = <String>[
          if (profileId == captainId && captainId.isNotEmpty) 'Captain',
          if (profileId == vcId && vcId.isNotEmpty) 'Vice Captain',
          if (profileId == wkId && wkId.isNotEmpty) 'Wicketkeeper',
        ];
      }

      // Name/avatar: direct fields in public endpoint; nested in user for older shapes.
      final user = _map(player['user']);
      final name = _str(player['name']).isNotEmpty
          ? _str(player['name'])
          : _str(user['name'], fb: 'Player');
      final avatarUrl = _orNull(_str(player['avatarUrl']).isNotEmpty
          ? _str(player['avatarUrl'])
          : _str(user['avatarUrl']));

      return TeamMember(
        profileId: profileId,
        userId: _str(user['id']).isNotEmpty ? _str(user['id']) : _str(player['userId']),
        name: name,
        avatarUrl: avatarUrl,
        battingStyle: _displayBatting(_str(player['battingStyle'])),
        bowlingStyle: _displayBowling(_str(player['bowlingStyle'])),
        swingIndex: (player['swingIndex'] as num?)?.toDouble(),
        totalXp: (player['totalXp'] as num?)?.toInt(),
        swingRank: _orNull(_str(player['swingRank'])),
        totalRuns: (player['totalRuns'] as num?)?.toInt(),
        totalWickets: (player['totalWickets'] as num?)?.toInt(),
        matchesPlayed: (player['matchesPlayed'] as num?)?.toInt(),
        matchesWon: (player['matchesWon'] as num?)?.toInt(),
        roles: roles,
      );
    }).toList()
      ..sort((a, b) {
        final r = _roleRank(a.roles) - _roleRank(b.roles);
        return r != 0 ? r : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    // Backend now returns isOwner directly (team.createdByUserId === user.userId).
    final isOwner = raw['isOwner'] == true;

    return PlayerTeam(
      id: _firstNonEmpty([_str(raw['id']), _str(raw['_id']), _str(raw['teamId'])]),
      name: _str(raw['name'], fb: 'Team'),
      shortName: _orNull(_str(raw['shortName'])),
      logoUrl: _orNull(_str(raw['logoUrl'])),
      city: _orNull(_str(raw['city'])),
      teamType: _displayTeamType(_str(raw['teamType'])),
      members: members,
      isOwner: isOwner,
    );
  }

  PlayerMatch _mapMatch(Map<String, dynamic> raw, DateTime now) {
    final status = _str(raw['status']).toUpperCase();
    final lifecycle = switch (status) {
      'LIVE' || 'IN_PROGRESS' || 'TOSS_DONE' => MatchLifecycle.live,
      'COMPLETED' || 'CANCELLED' => MatchLifecycle.past,
      _ => MatchLifecycle.upcoming,
    };

    // Flat fields from /teams/:id/matches endpoint.
    final teamAName = _firstNonEmpty([
      _entityName(raw['teamA']) ?? '',
      _str(raw['teamAName']),
    ]);
    final teamBName = _firstNonEmpty([
      _entityName(raw['teamB']) ?? '',
      _str(raw['teamBName']),
    ]);

    // teamSide tells us which team (A or B) is the current player's team.
    final teamSide = _str(raw['teamSide']).toUpperCase();
    final playerTeamName = teamSide == 'B' ? teamBName : teamAName;
    final opponentTeamName = teamSide == 'B' ? teamAName : teamBName;

    // Result is determined after preview enrichment using the winner team name.
    const result = MatchResult.unknown;

    final venueRaw = _firstNonEmpty([
      _str(raw['venueName']),
      raw['venue'] is Map ? _str((raw['venue'] as Map)['name']) : '',
      raw['arena'] is Map ? _str((raw['arena'] as Map)['name']) : '',
      _str(raw['location']),
    ]);

    final formatRaw = _firstNonEmpty([
      _str(raw['format']),
      _str(raw['matchFormat']),
      _str(raw['gameFormat']),
    ]);

    final competitionRaw = _firstNonEmpty([
      _str(raw['tournamentName']),
      _str(raw['competitionName']),
      _str(raw['seriesName']),
    ]);

    final tossWonBy = _str(raw['tossWonBy']);
    final tossDecision = _str(raw['tossDecision']);

    // Score is not available from the team matches endpoint.
    final scoreA = _str(raw['scoreA']);
    final scoreB = _str(raw['scoreB']);
    String? scoreSummary = _str(raw['scoreSummary']).isEmpty
        ? null
        : _str(raw['scoreSummary']);
    if (scoreSummary == null && (scoreA.isNotEmpty || scoreB.isNotEmpty)) {
      final parts = <String>[];
      if (playerTeamName.isNotEmpty && scoreA.isNotEmpty) {
        parts.add('$playerTeamName  $scoreA');
      } else if (scoreA.isNotEmpty) {
        parts.add(scoreA);
      }
      if (opponentTeamName.isNotEmpty && scoreB.isNotEmpty) {
        parts.add('$opponentTeamName  $scoreB');
      } else if (scoreB.isNotEmpty) {
        parts.add(scoreB);
      }
      if (parts.isNotEmpty) scoreSummary = parts.join('\n');
    }

    return PlayerMatch(
      id: _firstNonEmpty([_str(raw['id']), _str(raw['_id'])]),
      title: teamAName.isNotEmpty && teamBName.isNotEmpty
          ? '$teamAName vs $teamBName'
          : 'Match',
      sectionType: MatchSectionType.individual,
      lifecycle: lifecycle,
      result: result,
      statusLabel: status.isEmpty ? 'UPCOMING' : status,
      playerTeamName: playerTeamName,
      opponentTeamName: opponentTeamName,
      scheduledAt: _parseDate(raw['scheduledAt'] ?? raw['createdAt']),
      venueLabel: venueRaw.isEmpty ? null : venueRaw,
      formatLabel: formatRaw.isEmpty ? null : _displayFormat(formatRaw),
      competitionLabel: competitionRaw.isEmpty ? null : competitionRaw,
      scoreSummary: scoreSummary,
      ballType: _str(raw['ballType']).isEmpty ? null : _str(raw['ballType']),
      tossWinner: tossWonBy.isEmpty ? null : tossWonBy,
      tossDecision: tossDecision.isEmpty ? null : tossDecision,
    );
  }

  String? _entityName(dynamic v) {
    if (v is Map) {
      final m = Map<String, dynamic>.from(v);
      final n = _str(m['name']);
      return n.isEmpty ? null : n;
    }
    return null;
  }

  int _roleRank(List<String> roles) {
    if (roles.contains('Captain')) return 0;
    if (roles.contains('Vice Captain')) return 1;
    if (roles.contains('Wicketkeeper')) return 2;
    return 3;
  }

  Map<String, dynamic> _unwrapMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      final d = data['data'];
      if (d is Map<String, dynamic>) return d;
      final t = data['team'];
      if (t is Map<String, dynamic>) return t;
      return data;
    }
    return {};
  }

  List<dynamic> _unwrapList(dynamic data) {
    if (data is Map) {
      final inner = data['data'];
      if (inner is List) return inner;
      // Nested envelope: { data: { matches: [...], total, page } }
      if (inner is Map) {
        final nested = inner['matches'] ?? inner['items'] ?? inner['data'];
        if (nested is List) return nested;
      }
      final items = data['matches'] ?? data['items'];
      if (items is List) return items;
    }
    if (data is List) return data;
    return [];
  }

  Map<String, dynamic> _map(dynamic v) =>
      v is Map<String, dynamic> ? v : {};

  List<dynamic> _list(dynamic v) => v is List ? v : [];

  String _str(dynamic v, {String fb = ''}) {
    final s = v?.toString().trim() ?? '';
    return s.isEmpty ? fb : s;
  }

  String? _orNull(String v) => v.isEmpty ? null : v;

  String _firstNonEmpty(List<String> values) {
    for (final v in values) {
      if (v.isNotEmpty) return v;
    }
    return '';
  }

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }

  String? _displayBatting(String raw) {
    if (raw.isEmpty) return null;
    return switch (raw) {
      'LEFT_HAND' => 'Left-hand',
      'RIGHT_HAND' => 'Right-hand',
      _ => raw.replaceAll('_', ' '),
    };
  }

  String? _displayBowling(String raw) {
    if (raw.isEmpty) return null;
    return switch (raw) {
      'LEFT_ARM_FAST' => 'Left-arm pace',
      'LEFT_ARM_MEDIUM' => 'Left-arm seam',
      'LEFT_ARM_ORTHODOX' => 'Left-arm spin',
      'LEFT_ARM_CHINAMAN' => 'Chinaman',
      'RIGHT_ARM_FAST' => 'Right-arm pace',
      'RIGHT_ARM_MEDIUM' => 'Right-arm seam',
      'RIGHT_ARM_OFFBREAK' => 'Off spin',
      'RIGHT_ARM_LEGBREAK' => 'Leg spin',
      'NOT_A_BOWLER' => 'Not a bowler',
      _ => raw.replaceAll('_', ' '),
    };
  }

  String _displayFormat(String raw) {
    return switch (raw.toUpperCase()) {
      'T10' => 'T10',
      'T20' => 'T20',
      'ONE_DAY' => 'ODI',
      'TWO_INNINGS' => 'Test',
      'CUSTOM' => 'Custom',
      _ => raw.replaceAll('_', ' '),
    };
  }

  String? _displayTeamType(String raw) {
    if (raw.isEmpty) return null;
    return raw
        .split('_')
        .map((p) => '${p[0]}${p.substring(1).toLowerCase()}')
        .join(' ');
  }
}

final hostTeamDetailRepositoryProvider = Provider<HostTeamDetailRepository>(
  (ref) => HostTeamDetailRepository(
    ref.watch(hostDioProvider),
    ref.watch(hostPathConfigProvider),
  ),
);
