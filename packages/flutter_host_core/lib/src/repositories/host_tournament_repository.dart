import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../contracts/host_path_config.dart';
import '../providers/host_dio_provider.dart';

class SharedTournamentRepository {
  SharedTournamentRepository(this._dio, this._paths);

  final Dio _dio;
  final HostPathConfig _paths;

  Future<List<Map<String, dynamic>>> listMine() async {
    final response = await _dio.get(_paths.myTournaments);
    final root = _asMap(response.data);
    final rows =
        (root['tournaments'] ?? root['data'] ?? const []) as List? ?? const [];
    return rows
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>> getTournament(String id) async {
    final response = await _dio.get(_paths.tournament(id));
    final root = _asMap(response.data);
    final data = root['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return root;
  }

  Future<Map<String, dynamic>> createTournament({
    required String name,
    required String format,
    required String tournamentFormat,
    required DateTime startDate,
    DateTime? endDate,
    String? city,
    String? venueName,
    int? maxTeams,
    int? entryFee,
    String? prizePool,
    String? description,
    bool isPublic = true,
    int? seriesMatchCount,
    String ballType = 'LEATHER',
    DateTime? earlyBirdDeadline,
    int? earlyBirdFee,
    String? organiserName,
    String? organiserPhone,
  }) async {
    final response = await _dio.post(
      _paths.myTournaments,
      data: {
        'name': name.trim(),
        'format': format,
        'tournamentFormat': tournamentFormat,
        'startDate': startDate.toUtc().toIso8601String(),
        if (endDate != null) 'endDate': endDate.toUtc().toIso8601String(),
        if ((city ?? '').trim().isNotEmpty) 'city': city!.trim(),
        if ((venueName ?? '').trim().isNotEmpty) 'venueName': venueName!.trim(),
        if (maxTeams != null) 'maxTeams': maxTeams,
        if (entryFee != null) 'entryFee': entryFee,
        if ((prizePool ?? '').trim().isNotEmpty) 'prizePool': prizePool!.trim(),
        if ((description ?? '').trim().isNotEmpty)
          'description': description!.trim(),
        'isPublic': isPublic,
        if (tournamentFormat == 'SERIES' && seriesMatchCount != null)
          'seriesMatchCount': seriesMatchCount,
        'ballType': ballType,
        if (earlyBirdDeadline != null)
          'earlyBirdDeadline': earlyBirdDeadline.toUtc().toIso8601String(),
        if (earlyBirdFee != null) 'earlyBirdFee': earlyBirdFee,
        if ((organiserName ?? '').trim().isNotEmpty)
          'organiserName': organiserName!.trim(),
        if ((organiserPhone ?? '').trim().isNotEmpty)
          'organiserPhone': organiserPhone!.trim(),
      },
    );
    return _extractDataMap(response.data);
  }

  Future<void> deleteTournament(String tournamentId) async {
    await _dio.delete(_paths.tournament(tournamentId));
  }

  Future<List<Map<String, dynamic>>> listTeams(String tournamentId) async {
    final response =
        await _dio.get('${_paths.tournament(tournamentId)}/teams');
    return _asList(response.data);
  }

  Future<List<Map<String, dynamic>>> listGroups(String tournamentId) async {
    final response =
        await _dio.get('${_paths.tournament(tournamentId)}/groups');
    return _asList(response.data);
  }

  Future<Map<String, List<Map<String, dynamic>>>> getStandings(
      String tournamentId) async {
    final response =
        await _dio.get('${_paths.tournament(tournamentId)}/standings');
    final root = _asMap(response.data);
    final data = root['data'];
    if (data is! Map) return const {};
    final result = <String, List<Map<String, dynamic>>>{};
    for (final entry in data.entries) {
      final rows = entry.value is List ? entry.value as List : const [];
      result[entry.key] = rows
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> getSchedule(String tournamentId) async {
    final response = await _dio.get(
      '${_paths.tournament(tournamentId)}/schedule',
      options: Options(extra: {'refresh': true}),
    );
    return _asList(response.data);
  }

  Future<Map<String, dynamic>> addTeam(
    String tournamentId, {
    String? teamId,
    String? teamName,
    String? captainId,
    List<String> playerIds = const [],
  }) async {
    final response = await _dio.post(
      '${_paths.tournament(tournamentId)}/teams',
      data: {
        if ((teamId ?? '').trim().isNotEmpty) 'teamId': teamId!.trim(),
        if ((teamName ?? '').trim().isNotEmpty) 'teamName': teamName!.trim(),
        if ((captainId ?? '').trim().isNotEmpty) 'captainId': captainId!.trim(),
        if (playerIds.isNotEmpty) 'playerIds': playerIds,
      },
    );
    return _extractDataMap(response.data);
  }

  Future<void> removeTeam(String tournamentId, String tournamentTeamId) async {
    await _dio.delete(
        '${_paths.tournament(tournamentId)}/teams/$tournamentTeamId');
  }

  Future<Map<String, dynamic>> confirmTeam(
    String tournamentId,
    String tournamentTeamId,
    bool isConfirmed,
  ) async {
    final response = await _dio.patch(
      '${_paths.tournament(tournamentId)}/teams/$tournamentTeamId/confirm',
      data: {'isConfirmed': isConfirmed},
    );
    return _extractDataMap(response.data);
  }

  Future<List<Map<String, dynamic>>> createGroups(
    String tournamentId, {
    required List<String> groupNames,
    bool autoAssign = false,
  }) async {
    final response = await _dio.post(
      '${_paths.tournament(tournamentId)}/groups',
      data: {
        'groupNames': groupNames,
        'autoAssign': autoAssign,
      },
    );
    return _asList(response.data);
  }

  Future<void> discardGroups(String tournamentId) async {
    await _dio.delete('${_paths.tournament(tournamentId)}/groups');
  }

  Future<Map<String, dynamic>> assignTeamToGroup(
    String tournamentId,
    String tournamentTeamId,
    String? groupId,
  ) async {
    final response = await _dio.patch(
      '${_paths.tournament(tournamentId)}/teams/$tournamentTeamId/assign-group',
      data: {'groupId': groupId},
    );
    return _extractDataMap(response.data);
  }

  Future<void> recalculateStandings(String tournamentId) async {
    await _dio.post(
        '${_paths.tournament(tournamentId)}/recalculate-standings');
  }

  Future<void> autoGenerateSchedule(
    String tournamentId, {
    int matchesPerDay = 1,
  }) async {
    await _dio.post(
      '${_paths.tournament(tournamentId)}/auto-generate',
      data: {'matchesPerDay': matchesPerDay},
    );
  }

  Future<Map<String, dynamic>> generateSmartSchedule(
    String tournamentId, {
    required String startDate,
    required String matchStartTime,
    required int matchesPerDay,
    required double gapBetweenMatchesHours,
    required List<int> validWeekdays,
    List<String> excludeDates = const [],
  }) async {
    final response = await _dio.post(
      '${_paths.tournament(tournamentId)}/smart-schedule',
      data: {
        'startDate': startDate,
        'matchStartTime': matchStartTime,
        'matchesPerDay': matchesPerDay,
        'gapBetweenMatchesHours': gapBetweenMatchesHours,
        'validWeekdays': validWeekdays,
        if (excludeDates.isNotEmpty) 'excludeDates': excludeDates,
      },
    );
    return _extractDataMap(response.data);
  }

  Future<void> updateMatch(
    String matchId, {
    DateTime? scheduledAt,
    bool swapTeams = false,
  }) async {
    await _dio.patch(
      _paths.match(matchId),
      data: {
        if (scheduledAt != null)
          'scheduledAt': scheduledAt.toUtc().toIso8601String(),
        if (swapTeams) 'swapTeams': true,
      },
    );
  }

  Future<void> deleteSchedule(String tournamentId) async {
    await _dio.delete('${_paths.tournament(tournamentId)}/schedule');
  }

  Future<void> advanceRound(String tournamentId) async {
    await _dio.post('${_paths.tournament(tournamentId)}/advance-round');
  }

  Map<String, dynamic> _extractDataMap(Object? data) {
    final root = _asMap(data);
    final inner = root['data'];
    if (inner is Map) return Map<String, dynamic>.from(inner);
    return root;
  }

  List<Map<String, dynamic>> _asList(Object? data) {
    final root = _asMap(data);
    final inner = root['data'];
    final rows = inner is List ? inner : (data is List ? data : const []);
    return rows
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }
}

class HostTournamentRepository extends SharedTournamentRepository {
  HostTournamentRepository(super.dio, super.paths);
}

final hostTournamentRepositoryProvider = Provider<HostTournamentRepository>(
  (ref) => HostTournamentRepository(
    ref.watch(hostDioProvider),
    ref.watch(hostPathConfigProvider),
  ),
);

class TournamentPermissions {
  const TournamentPermissions({
    this.canManage = false,
    this.canEdit = false,
  });

  final bool canManage;
  final bool canEdit;

  const TournamentPermissions.host()
      : canManage = true,
        canEdit = true;
}
