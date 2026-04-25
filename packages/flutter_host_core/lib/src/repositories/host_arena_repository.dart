import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../contracts/host_path_config.dart';
import '../features/arena_booking/domain/arena_booking_models.dart';
import '../providers/host_dio_provider.dart';

class HostArenaBookingRepository {
  HostArenaBookingRepository(this._dio, this._paths);

  final Dio _dio;
  final HostPathConfig _paths;

  Future<List<ArenaListing>> fetchArenas({
    String? city,
    String? search,
    String? sport,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    final response = await _dio.get(
      _paths.arenas,
      queryParameters: {
        if (city != null && city.isNotEmpty) 'city': city,
        if (search != null && search.isNotEmpty) 'search': search,
        if (sport != null && sport.isNotEmpty) 'sport': sport,
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lng': longitude,
        if (radiusKm != null) 'radiusKm': radiusKm,
      },
    );
    final list = _extractList(response.data, ['data', 'arenas']);
    return list.map(ArenaListing.fromJson).toList();
  }

  Future<List<ArenaListing>> fetchOwnedArenas() async {
    final response = await _dio.get(_paths.ownedArenas);
    final data = _extractMap(response.data);
    final payload = data['data'] ?? data['arenas'] ?? data;
    if (payload is List) {
      return payload
          .whereType<Map>()
          .map((e) => ArenaListing.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    final list = _extractList(response.data, ['data', 'arenas']);
    return list.map(ArenaListing.fromJson).toList();
  }

  Future<ArenaListing> fetchArenaDetail(String arenaId) async {
    final response = await _dio.get(_paths.arena(arenaId));
    final data = _extractMap(response.data);
    final payload = data['data'] ?? data;
    return ArenaListing.fromJson(Map<String, dynamic>.from(payload as Map));
  }

  Future<ArenaListing> updateArena(
    String arenaId,
    Map<String, dynamic> input,
  ) async {
    final response = await _dio.put(
      _paths.arena(arenaId),
      data: input,
    );
    final data = _extractMap(response.data);
    final payload = data['data'] ?? data;
    return ArenaListing.fromJson(Map<String, dynamic>.from(payload as Map));
  }

  Future<Map<String, List<AvailabilitySlot>>> fetchAvailability({
    required String arenaId,
    required DateTime date,
  }) async {
    final response = await _dio.get(
      _paths.arenaAvailability(arenaId),
      queryParameters: {'date': date.toIso8601String().split('T').first},
    );
    final root = _extractMap(response.data);
    final rows = (root['availability'] ?? root['data'] ?? const {}) as Object?;
    final result = <String, List<AvailabilitySlot>>{};
    if (rows is Map) {
      rows.forEach((key, value) {
        final slots = (value as List? ?? const [])
            .whereType<Map>()
            .map((e) => AvailabilitySlot.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        result['$key'] = slots;
      });
    }
    return result;
  }

  Future<List<ArenaAddon>> fetchArenaAddons(String arenaId) async {
    final response = await _dio.get(_paths.arenaAddons(arenaId));
    final list = _extractList(response.data, ['data', 'addons']);
    return list.map(ArenaAddon.fromJson).toList();
  }
}

final hostArenaBookingRepositoryProvider = Provider<HostArenaBookingRepository>(
  (ref) => HostArenaBookingRepository(
    ref.watch(hostDioProvider),
    ref.watch(hostPathConfigProvider),
  ),
);

Map<String, dynamic> _extractMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _extractList(Object? data, List<String> path) {
  Object? current = data;
  for (final key in path) {
    final map = _extractMap(current);
    current = map[key];
  }
  if (current is List) {
    return current
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  if (path.length == 2) {
    final root = _extractMap(data);
    final nested = root[path[0]];
    if (nested is List) {
      return nested
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }
  return const [];
}
