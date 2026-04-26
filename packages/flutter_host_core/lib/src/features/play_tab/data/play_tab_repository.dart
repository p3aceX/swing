import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contracts/host_path_config.dart';
import '../../../providers/host_dio_provider.dart';
import '../domain/play_tab_models.dart';

class PlayTabRepository {
  PlayTabRepository(this._dio, this._paths);

  final Dio _dio;
  final HostPathConfig _paths;

  Future<List<PlayTournament>> fetchMyTournaments() async {
    final tRoot = await _safeGet(_paths.myTournaments);

    final dataField = tRoot['data'];
    final inner = dataField is Map
        ? Map<String, dynamic>.from(dataField)
        : <String, dynamic>{};

    final merged = <String, PlayTournament>{};

    void addAll(dynamic rows, {bool forceHost = false, bool forceParticipating = false}) {
      final list = _list(rows);
      for (final e in list) {
        if (e is! Map) continue;
        final raw = Map<String, dynamic>.from(e);
        final t = PlayTournament.fromJson(raw,
            forceHost: forceHost, forceParticipating: forceParticipating);
        if (t.id.isEmpty) continue;
        final existing = merged[t.id];
        merged[t.id] = existing == null
            ? t
            : existing.copyWith(
                isHost: existing.isHost || t.isHost,
                isParticipating: existing.isParticipating || t.isParticipating,
              );
      }
    }

    if (dataField is List) {
      addAll(dataField);
    } else {
      addAll(inner['hostedTournaments'], forceHost: true);
      addAll(inner['participatedTournaments'], forceParticipating: true);
      addAll(inner['joinedTournaments'], forceParticipating: true);
      addAll(inner['teamTournaments'], forceParticipating: true);
      addAll(inner['myTournaments'], forceParticipating: true);
      addAll(inner['registeredTournaments'], forceParticipating: true);
      addAll(inner['tournaments'], forceParticipating: true);
      addAll(tRoot['tournaments'], forceParticipating: true);
    }

    // Every tournament returned by /player/tournaments is player-associated.
    // If the API didn't explicitly set isParticipating and the user isn't the
    // host, they must be a participant — mark them as such.
    // Never force isHost; only the API's own flag should set that.
    for (final key in merged.keys.toList()) {
      final t = merged[key]!;
      if (!t.isHost && !t.isParticipating) {
        merged[key] = t.copyWith(isParticipating: true);
      }
    }

    if (kDebugMode) {
      debugPrint('[Tournaments] total=${merged.length}'
          ' participated=${merged.values.where((t) => t.isParticipating && !t.isHost).length}'
          ' hosted=${merged.values.where((t) => t.isHost).length}');
    }

    return merged.values.toList();
  }

  Future<List<PlayTournament>> fetchPublicTournaments({
    String? query,
    String? city,
    String? format,
  }) async {
    final response = await _dio.get(
      '/public/tournaments',
      queryParameters: {
        if ((query ?? '').isNotEmpty) 'q': query,
        if ((city ?? '').isNotEmpty) 'city': city,
        if ((format ?? '').isNotEmpty) 'format': format,
      },
    );
    final root = _root(response.data);
    final items = _list(root['data'] ?? root['tournaments'] ?? root);
    return items
        .whereType<Map>()
        .map((e) => PlayTournament.fromJson(Map<String, dynamic>.from(e)))
        .where((t) => t.id.isNotEmpty)
        .toList();
  }

  Future<Map<String, dynamic>> _safeGet(String path) async {
    try {
      final res = await _dio.get(path);
      return _root(res.data);
    } catch (_) {
      return const {};
    }
  }

  static Map<String, dynamic> _root(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }

  static List<dynamic> _list(dynamic v) => v is List ? v : const [];
}

final playTabRepositoryProvider = Provider<PlayTabRepository>(
  (ref) => PlayTabRepository(
    ref.watch(hostDioProvider),
    ref.watch(hostPathConfigProvider),
  ),
);
