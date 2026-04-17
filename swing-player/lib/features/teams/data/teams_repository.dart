import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/auth/token_storage.dart';
import '../domain/team_models.dart';

class TeamsRepository {
  final _client = ApiClient.instance.dio;

  Future<({List<PlayerTeam> mySquads, List<PlayerTeam> playingFor})>
      loadTeamsByOwnership() async {
    // Resolve both profile and user identity so we can split created squads
    // from teams the player is only part of.
    final profileResponse = await _client.get(ApiEndpoints.playerProfile);
    final profile = _unwrapMap(profileResponse.data);
    final myProfileId = _string(profile['id']);
    final storedUserId = await TokenStorage.getUserId();
    final myUserId = storedUserId != null && storedUserId.trim().isNotEmpty
        ? storedUserId.trim()
        : _string(_map(profile['user'])['id']);

    // Fetch all teams that include this player via the player-scoped endpoint.
    final teamsResponse = await _client.get(ApiEndpoints.myTeams);
    final payload = _unwrapMap(teamsResponse.data);
    final rawTeams =
        _list(payload['teams']).whereType<Map<String, dynamic>>().toList();

    final teams = rawTeams
        .map((raw) =>
            _mapTeam(raw, myProfileId: myProfileId, myUserId: myUserId))
        .toList();

    return (
      mySquads: teams.where((t) => t.isOwner).toList(),
      playingFor: teams.where((t) => !t.isOwner).toList(),
    );
  }

  Future<List<TeamPlayerSearchResult>> searchPlayers(String query) async {
    final response = await _client.get(
      ApiEndpoints.playerSearch,
      queryParameters: {'q': query, 'limit': 20},
    );
    final payload = _unwrapMap(response.data);
    return _list(payload['data'])
        .whereType<Map<String, dynamic>>()
        .map(
          (raw) => TeamPlayerSearchResult(
            userId: _string(raw['userId']),
            name: _string(raw['name'], fallback: 'Player'),
            phone: _string(raw['phone']).isEmpty ? null : _string(raw['phone']),
            avatarUrl: _string(raw['avatarUrl']).isEmpty
                ? null
                : _string(raw['avatarUrl']),
            playerRole: _string(raw['playerRole']).isEmpty
                ? null
                : _string(raw['playerRole']).replaceAll('_', ' '),
            playerLevel: _string(raw['playerLevel']).isEmpty
                ? null
                : _string(raw['playerLevel']).replaceAll('_', ' '),
            swingIndex: _numOrNull(raw['swingIndex']),
          ),
        )
        .where((player) => player.userId.isNotEmpty)
        .toList();
  }

  Future<void> addPlayerToTeam({
    required String teamId,
    required String playerIdOrUserId,
  }) async {
    await _client.post(
      ApiEndpoints.teamMembers(teamId),
      data: {'playerId': playerIdOrUserId},
    );
  }

  Future<void> joinTeam(String teamId) async {
    await _client.post(ApiEndpoints.teamJoin(teamId));
  }

  Future<void> followTeam(String teamId) async {
    await _client.post(ApiEndpoints.teamFollow(teamId));
  }

  Future<void> quickAddPlayer({
    required String teamId,
    required String name,
    required String phone,
  }) async {
    await _client.post(
      ApiEndpoints.playerTeamQuickAdd(teamId),
      data: {'name': name.trim(), 'phone': phone.trim()},
    );
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
    debugPrint('[UpdateTeam] → PATCH /teams/$teamId payload=$payload');
    try {
      final res = await _client.patch(ApiEndpoints.teamById(teamId), data: payload);
      debugPrint('[UpdateTeam] ← ${res.statusCode} body=${res.data}');
    } catch (e) {
      debugPrint('[UpdateTeam] ERROR: $e');
      rethrow;
    }
  }

  Future<void> removePlayerFromTeam({
    required String teamId,
    required String profileId,
  }) async {
    debugPrint('[RemovePlayer] → DELETE /teams/$teamId/members/$profileId');
    try {
      await _client.delete(ApiEndpoints.teamMember(teamId, profileId));
      debugPrint('[RemovePlayer] ← success');
    } catch (e) {
      debugPrint('[RemovePlayer] ERROR: $e');
      rethrow;
    }
  }

  Future<void> deleteTeam(String teamId) async {
    debugPrint('[DeleteTeam] → DELETE /teams/$teamId');
    try {
      final res = await _client.delete(ApiEndpoints.teamById(teamId));
      debugPrint('[DeleteTeam] ← ${res.statusCode} body=${res.data}');
    } catch (e) {
      debugPrint('[DeleteTeam] ERROR: $e');
      rethrow;
    }
  }

  PlayerTeam _mapTeam(
    Map<String, dynamic> raw, {
    required String myProfileId,
    required String myUserId,
  }) {
    final roleAssignments = _map(raw['roleAssignments']);
    final captainId = _string(_map(roleAssignments['captain'])['id']);
    final viceCaptainId = _string(_map(roleAssignments['viceCaptain'])['id']);
    final wicketKeeperId = _string(_map(roleAssignments['wicketKeeper'])['id']);
    final players =
        _list(raw['players']).whereType<Map<String, dynamic>>().toList();

    final members = players.map((player) {
      final profileId = _string(player['id']);
      final roles = <String>[
        if (profileId == captainId) 'Captain',
        if (profileId == viceCaptainId) 'Vice Captain',
        if (profileId == wicketKeeperId) 'Wicketkeeper',
      ];

      final user = _map(player['user']);
      return TeamMember(
        profileId: profileId,
        userId: _string(user['id']),
        name: _string(user['name'], fallback: 'Player'),
        avatarUrl: _string(user['avatarUrl']).isEmpty
            ? null
            : _string(user['avatarUrl']),
        battingStyle: _displayBattingStyle(_string(player['battingStyle'])),
        bowlingStyle: _displayBowlingStyle(_string(player['bowlingStyle'])),
        swingIndex: _numOrNull(player['swingIndex']),
        totalXp: _intOrNull(player['totalXp']),
        swingRank: _string(player['swingRank']).isEmpty
            ? null
            : _string(player['swingRank']),
        totalRuns: _intOrNull(player['totalRuns']),
        totalWickets: _intOrNull(player['totalWickets']),
        matchesPlayed: _intOrNull(player['matchesPlayed']),
        matchesWon: _intOrNull(player['matchesWon']),
        roles: roles,
      );
    }).toList()
      ..sort((a, b) {
        final roleOrder = _roleRank(a.roles) - _roleRank(b.roles);
        if (roleOrder != 0) return roleOrder;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    final createdByUserId = _string(raw['createdByUserId']);
    final isOwner = createdByUserId.isNotEmpty && createdByUserId == myUserId;

    return PlayerTeam(
      id: _string(raw['id']).isNotEmpty
          ? _string(raw['id'])
          : _string(raw['_id']).isNotEmpty
              ? _string(raw['_id'])
              : _string(raw['teamId']),
      name: _string(raw['name'], fallback: 'Team'),
      shortName:
          _string(raw['shortName']).isEmpty ? null : _string(raw['shortName']),
      logoUrl: _string(raw['logoUrl']).isEmpty ? null : _string(raw['logoUrl']),
      city: _string(raw['city']).isEmpty ? null : _string(raw['city']),
      teamType: _displayTeamType(_string(raw['teamType'])),
      members: members,
      isOwner: isOwner,
    );
  }

  int _roleRank(List<String> roles) {
    if (roles.contains('Captain')) return 0;
    if (roles.contains('Vice Captain')) return 1;
    if (roles.contains('Wicketkeeper')) return 2;
    return 3;
  }

  Map<String, dynamic> _unwrapMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is Map<String, dynamic>) return inner;
      return data;
    }
    return <String, dynamic>{};
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

  double? _numOrNull(dynamic value) {
    return (value as num?)?.toDouble();
  }

  int? _intOrNull(dynamic value) {
    return (value as num?)?.toInt();
  }

  String? _displayBattingStyle(String raw) {
    if (raw.isEmpty) return null;
    return switch (raw) {
      'LEFT_HAND' => 'Left-hand',
      'RIGHT_HAND' => 'Right-hand',
      _ => raw.replaceAll('_', ' '),
    };
  }

  String? _displayBowlingStyle(String raw) {
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

  String? _displayTeamType(String raw) {
    if (raw.isEmpty) return null;
    return raw
        .split('_')
        .map((part) => '${part[0]}${part.substring(1).toLowerCase()}')
        .join(' ');
  }
}
