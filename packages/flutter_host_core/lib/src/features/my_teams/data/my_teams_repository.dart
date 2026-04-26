import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contracts/host_path_config.dart';
import '../../../providers/host_dio_provider.dart';
import '../domain/my_teams_models.dart';

/// Loads the current user's teams from `_paths.myTeams` and splits them into
/// "owned by me" vs "I'm a member of" buckets.
///
/// Ownership is decided by comparing each team's `createdByUserId` against the
/// `currentUserId` the host app passes in. Hosts that don't track that (e.g.
/// admin panels with super-user access) can pass `null` and treat everything
/// as `playingFor`.
class HostMyTeamsRepository {
  HostMyTeamsRepository(this._dio, this._paths);

  final Dio _dio;
  final HostPathConfig _paths;

  Future<HostMyTeams> load({String? currentUserId}) async {
    final response = await _dio.get(_paths.myTeams);
    final data = response.data;

    // Normalise: extract the teams array from whatever shape the API returns.
    List<Map<String, dynamic>> list;
    if (data is List) {
      list = data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      final root = _asMap(data);
      final payload = root['data'] is Map
          ? Map<String, dynamic>.from(root['data'] as Map)
          : root;
      final rawTeams = payload['teams'] ?? payload['items'] ?? payload['data'] ?? const [];
      list = (rawTeams is List)
          ? rawTeams.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
          : const <Map<String, dynamic>>[];
    }

    final owner = (currentUserId ?? '').trim();
    final teams = list.map((raw) => _toTeam(raw, owner)).toList();

    return HostMyTeams(
      mySquads: teams.where((t) => t.isOwner).toList(),
      playingFor: teams.where((t) => !t.isOwner).toList(),
    );
  }

  HostMyTeam _toTeam(Map<String, dynamic> raw, String currentUserId) {
    final players = (raw['players'] is List ? raw['players'] as List : const [])
        .whereType<Map>()
        .toList();
    final directCount = (raw['playerCount'] as num?)?.toInt();
    final createdBy = _str(raw['createdByUserId']);
    final id = _firstNonEmpty([
      _str(raw['id']),
      _str(raw['_id']),
      _str(raw['teamId']),
    ]);
    return HostMyTeam(
      id: id,
      name: _str(raw['name']).isEmpty ? 'Team' : _str(raw['name']),
      shortName: _orNull(_str(raw['shortName'])),
      city: _orNull(_str(raw['city'])),
      logoUrl: _orNull(_str(raw['logoUrl'])),
      teamType: _orNull(_str(raw['teamType'])),
      playerCount: players.isNotEmpty ? players.length : (directCount ?? 0),
      isOwner: createdBy.isNotEmpty &&
          currentUserId.isNotEmpty &&
          createdBy == currentUserId,
    );
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  String _str(Object? value) => '${value ?? ''}'.trim();

  String? _orNull(String value) => value.isEmpty ? null : value;

  String _firstNonEmpty(List<String> values) {
    for (final v in values) {
      if (v.isNotEmpty) return v;
    }
    return '';
  }
}

final hostMyTeamsRepositoryProvider = Provider<HostMyTeamsRepository>(
  (ref) => HostMyTeamsRepository(
    ref.watch(hostDioProvider),
    ref.watch(hostPathConfigProvider),
  ),
);
