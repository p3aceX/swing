import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    this.teamALogoUrl,
    this.teamBLogoUrl,
    this.teamACity,
    this.teamBCity,
    this.format,
    this.matchType,
    this.category,
    this.ageGroup,
    this.ballType,
    this.venueId,
    this.venueName,
    this.venueCity,
    this.scheduledAt,
    this.customOvers,
    this.hasImpactPlayer,
  });

  final String id;
  final String teamAId;
  final String teamBId;
  final String teamAName;
  final String teamBName;
  final String? teamALogoUrl;
  final String? teamBLogoUrl;
  final String? teamACity;
  final String? teamBCity;
  final String? format;
  final String? matchType;
  final String? category;
  final String? ageGroup;
  final String? ballType;
  final String? venueId;
  final String? venueName;
  final String? venueCity;
  final DateTime? scheduledAt;
  final int? customOvers;
  final bool? hasImpactPlayer;
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

    String? pickNested(String nested, String key) {
      final obj = data[nested];
      if (obj is Map) {
        final v = '${obj[key] ?? ''}'.trim();
        if (v.isNotEmpty) return v;
      }
      return null;
    }

    DateTime? parseDate(Object? raw) {
      if (raw == null) return null;
      try {
        return DateTime.parse('$raw').toLocal();
      } catch (_) {
        return null;
      }
    }

    String? trimToNull(Object? v) {
      final s = '${v ?? ''}'.trim();
      return s.isEmpty ? null : s;
    }

    final venue = data['venue'];
    final venueObj = venue is Map ? Map<String, dynamic>.from(venue) : null;

    return HostMatchSummary(
      id: '${data['id'] ?? matchId}',
      teamAId: pickId('teamAId', 'teamA'),
      teamBId: pickId('teamBId', 'teamB'),
      teamAName: pickName('teamAName', 'teamA', 'Team A'),
      teamBName: pickName('teamBName', 'teamB', 'Team B'),
      teamALogoUrl: pickNested('teamA', 'logoUrl'),
      teamBLogoUrl: pickNested('teamB', 'logoUrl'),
      teamACity: pickNested('teamA', 'city'),
      teamBCity: pickNested('teamB', 'city'),
      format: trimToNull(data['format']),
      matchType: trimToNull(data['matchType']),
      category: trimToNull(data['category']),
      ageGroup: trimToNull(data['ageGroup']),
      ballType: trimToNull(data['ballType']),
      venueId: trimToNull(data['facilityId'] ?? venueObj?['id']),
      venueName: trimToNull(data['venueName'] ?? venueObj?['name']),
      venueCity: trimToNull(data['venueCity'] ?? venueObj?['city']),
      scheduledAt: parseDate(data['scheduledAt']),
      customOvers: (data['customOvers'] as num?)?.toInt(),
      hasImpactPlayer: data['hasImpactPlayer'] == true,
    );
  }

  Future<String> createMatch({
    required String teamAName,
    required String teamBName,
    required String venueName,
    required String venueCity,
    required DateTime scheduledAt,
    required String format,
    required String category,
    required String ageGroup,
    String? matchType,
    String? teamAId,
    String? teamBId,
    int? customOvers,
    bool hasImpactPlayer = false,
    String? ballType,
    String? facilityId,
    String? tournamentId,
    List<String>? teamAPlayerIds,
    List<String>? teamBPlayerIds,
  }) async {
    final body = <String, dynamic>{
      'teamAName': teamAName.trim(),
      'teamBName': teamBName.trim(),
      if ((teamAId ?? '').isNotEmpty) 'teamAId': teamAId,
      if ((teamBId ?? '').isNotEmpty) 'teamBId': teamBId,
      if (venueName.trim().isNotEmpty) 'venueName': venueName.trim(),
      if (venueCity.trim().isNotEmpty) 'venueCity': venueCity.trim(),
      'scheduledAt': scheduledAt.toUtc().toIso8601String(),
      'format': format,
      'category': category,
      'ageGroup': ageGroup,
      if ((matchType ?? '').isNotEmpty) 'matchType': matchType,
      'hasImpactPlayer': hasImpactPlayer,
      if (format == 'CUSTOM' && customOvers != null) 'customOvers': customOvers,
      if ((ballType ?? '').isNotEmpty) 'ballType': ballType,
      if ((facilityId ?? '').isNotEmpty) 'facilityId': facilityId,
      if ((tournamentId ?? '').isNotEmpty) 'tournamentId': tournamentId,
      'teamAPlayerIds': teamAPlayerIds ?? const <String>[],
      'teamBPlayerIds': teamBPlayerIds ?? const <String>[],
    };
    debugPrint('[CreateMatch] → POST ${_paths.createMatch} body=$body');
    try {
      final response = await _dio.post(_paths.createMatch, data: body);
      debugPrint('[CreateMatch] ← ${response.statusCode} body=${response.data}');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final payload = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        final id = '${payload['id'] ?? ''}'.trim();
        if (id.isNotEmpty) return id;
      }
      throw StateError('Match created but no match id was returned.');
    } on DioException catch (e) {
      debugPrint(
        '[CreateMatch] FAIL status=${e.response?.statusCode} '
        'type=${e.type.name} msg=${e.message}',
      );
      debugPrint('[CreateMatch] error body: ${e.response?.data}');
      rethrow;
    }
  }

  /// Bulk-edit pre-match settings on an existing match (PATCH /matches/:id).
  /// Only sends the fields the caller passes — preserves toss / scoring /
  /// playing-11 state on the existing row.
  Future<void> updateMatchSettings(
    String matchId, {
    String? format,
    String? ballType,
    String? category,
    String? ageGroup,
    String? venueName,
    String? venueCity,
    String? facilityId,
    DateTime? scheduledAt,
    int? customOvers,
    bool? hasImpactPlayer,
    String? teamAName,
    String? teamBName,
  }) async {
    final body = <String, dynamic>{
      if (format != null) 'format': format,
      if (ballType != null) 'ballType': ballType,
      if (category != null) 'category': category,
      if (ageGroup != null) 'ageGroup': ageGroup,
      if ((venueName ?? '').isNotEmpty) 'venueName': venueName,
      if ((venueCity ?? '').isNotEmpty) 'venueCity': venueCity,
      if ((facilityId ?? '').isNotEmpty) 'facilityId': facilityId,
      if (scheduledAt != null)
        'scheduledAt': scheduledAt.toUtc().toIso8601String(),
      if (customOvers != null) 'customOvers': customOvers,
      if (hasImpactPlayer != null) 'hasImpactPlayer': hasImpactPlayer,
      if ((teamAName ?? '').isNotEmpty) 'teamAName': teamAName,
      if ((teamBName ?? '').isNotEmpty) 'teamBName': teamBName,
    };
    debugPrint('[EditMatch] → PATCH ${_paths.match(matchId)} body=$body');
    try {
      final response =
          await _dio.patch(_paths.match(matchId), data: body);
      debugPrint(
          '[EditMatch] ← ${response.statusCode} body=${response.data}');
    } on DioException catch (e) {
      debugPrint(
          '[EditMatch] FAIL status=${e.response?.statusCode} body=${e.response?.data}');
      rethrow;
    }
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
    this.namedImpactSubs = const [],
  });

  final List<String> playerIds;
  final String? captainId;
  final String? viceCaptainId;
  final String? wicketKeeperId;
  final String? impactPlayerId;
  /// Pre-declared Impact Player substitutes (max 4). Only the players in
  /// this list are eligible for the in-match Impact Player swap. May be
  /// empty when the rule is off or hosts skip the declaration.
  final List<String> namedImpactSubs;

  Map<String, dynamic> toJson() => {
        'playerIds': playerIds,
        if (captainId != null) 'captainId': captainId,
        if (viceCaptainId != null) 'viceCaptainId': viceCaptainId,
        if (wicketKeeperId != null) 'wicketKeeperId': wicketKeeperId,
        if (impactPlayerId != null) 'impactPlayerId': impactPlayerId,
        if (namedImpactSubs.isNotEmpty) 'namedImpactSubs': namedImpactSubs,
      };
}

final hostCreateMatchRepositoryProvider = Provider<HostCreateMatchRepository>(
  (ref) => HostCreateMatchRepository(
    ref.watch(hostDioProvider),
    ref.watch(hostPathConfigProvider),
  ),
);
