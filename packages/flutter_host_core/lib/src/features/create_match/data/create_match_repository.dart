import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contracts/host_path_config.dart';
import '../../../providers/host_dio_provider.dart';

class HostMatchSummary {
  const HostMatchSummary({
    required this.id,
    required this.teamAId,
    required this.teamBId,
    required this.teamAName,
    required this.teamBName,
  });

  final String id;
  final String teamAId;
  final String teamBId;
  final String teamAName;
  final String teamBName;
}

class HostCreateMatchRepository {
  const HostCreateMatchRepository(this._dio, this._paths);

  final Dio _dio;
  final HostPathConfig _paths;

  Future<HostMatchSummary> getMatch(String matchId) async {
    final response = await _dio.get(_paths.match(matchId));
    final body = response.data;
    final root = body is Map<String, dynamic>
        ? body
        : (body is Map ? Map<String, dynamic>.from(body) : const {});
    final raw = root['data'] is Map ? root['data'] as Map : root;
    final data = Map<String, dynamic>.from(raw);

    String pickId(String key, String nested) {
      final direct = '${data[key] ?? ''}'.trim();
      if (direct.isNotEmpty) return direct;
      final obj = data[nested];
      if (obj is Map) {
        return '${obj['id'] ?? ''}'.trim();
      }
      return '';
    }

    String pickName(String directKey, String nested, String fallback) {
      final direct = '${data[directKey] ?? ''}'.trim();
      if (direct.isNotEmpty) return direct;
      final obj = data[nested];
      if (obj is Map) {
        final n = '${obj['name'] ?? obj['teamName'] ?? ''}'.trim();
        if (n.isNotEmpty) return n;
      }
      return fallback;
    }

    return HostMatchSummary(
      id: '${data['id'] ?? matchId}',
      teamAId: pickId('teamAId', 'teamA'),
      teamBId: pickId('teamBId', 'teamB'),
      teamAName: pickName('teamAName', 'teamA', 'Team A'),
      teamBName: pickName('teamBName', 'teamB', 'Team B'),
    );
  }

  Future<String> createMatch({
    required String teamAName,
    required String teamBName,
    required String venueName,
    required String venueCity,
    required DateTime scheduledAt,
    required String format,
    required String matchType,
    int? customOvers,
    bool hasImpactPlayer = false,
    String? ballType,
    String? facilityId,
    String? tournamentId,
    List<String>? teamAPlayerIds,
    List<String>? teamBPlayerIds,
  }) async {
    final response = await _dio.post(
      _paths.createMatch,
      data: {
        'teamAName': teamAName.trim(),
        'teamBName': teamBName.trim(),
        if (venueName.trim().isNotEmpty) 'venueName': venueName.trim(),
        if (venueCity.trim().isNotEmpty) 'venueCity': venueCity.trim(),
        'scheduledAt': scheduledAt.toUtc().toIso8601String(),
        'format': format,
        'matchType': matchType,
        'hasImpactPlayer': hasImpactPlayer,
        if (format == 'CUSTOM' && customOvers != null)
          'customOvers': customOvers,
        if ((ballType ?? '').isNotEmpty) 'ballType': ballType,
        if ((facilityId ?? '').isNotEmpty) 'facilityId': facilityId,
        if ((tournamentId ?? '').isNotEmpty) 'tournamentId': tournamentId,
        'teamAPlayerIds': teamAPlayerIds ?? const <String>[],
        'teamBPlayerIds': teamBPlayerIds ?? const <String>[],
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final payload = data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;
      final id = '${payload['id'] ?? ''}'.trim();
      if (id.isNotEmpty) return id;
    }
    throw StateError('Match created but no match id was returned.');
  }

  /// Replaces the Playing 11 rosters + role assignments for both sides of a
  /// match. Maps to `PUT /matches/:id/players`.
  Future<void> setPlayingEleven(
    String matchId, {
    required HostTeamEleven teamA,
    required HostTeamEleven teamB,
  }) async {
    await _dio.put(
      _paths.matchPlayers(matchId),
      data: {
        'teamA': teamA.toJson(),
        'teamB': teamB.toJson(),
      },
    );
  }
}

/// Per-team payload for [HostCreateMatchRepository.setPlayingEleven].
class HostTeamEleven {
  const HostTeamEleven({
    required this.playerIds,
    this.captainId,
    this.viceCaptainId,
    this.wicketKeeperId,
    this.impactPlayerId,
  });

  final List<String> playerIds;
  final String? captainId;
  final String? viceCaptainId;
  final String? wicketKeeperId;
  final String? impactPlayerId;

  Map<String, dynamic> toJson() => {
        'playerIds': playerIds,
        if (captainId != null) 'captainId': captainId,
        if (viceCaptainId != null) 'viceCaptainId': viceCaptainId,
        if (wicketKeeperId != null) 'wicketKeeperId': wicketKeeperId,
        if (impactPlayerId != null) 'impactPlayerId': impactPlayerId,
      };
}

final hostCreateMatchRepositoryProvider = Provider<HostCreateMatchRepository>(
  (ref) => HostCreateMatchRepository(
    ref.watch(hostDioProvider),
    ref.watch(hostPathConfigProvider),
  ),
);
