import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../contracts/host_contracts.dart';
import '../features/arena_booking/domain/arena_booking_models.dart';
import '../providers/host_dio_provider.dart';

class HostArenaBookingRepository {
  HostArenaBookingRepository(this._dio);

  final Dio _dio;

  Future<List<ArenaListing>> fetchArenas({
    String? city,
    String? sport,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    final response = await _dio.get(
      HostContracts.arenas,
      queryParameters: {
        if (city != null && city.isNotEmpty) 'city': city,
        if (sport != null && sport.isNotEmpty) 'sport': sport,
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lng': longitude,
        if (radiusKm != null) 'radiusKm': radiusKm,
      },
    );
    final list = _extractList(response.data, ['data', 'arenas']);
    return list.map(ArenaListing.fromJson).toList();
  }

  Future<Map<String, List<AvailabilitySlot>>> fetchAvailability({
    required String arenaId,
    required DateTime date,
  }) async {
    final response = await _dio.get(
      HostContracts.arenaAvailability(arenaId),
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
    final response = await _dio.get(HostContracts.arenaAddons(arenaId));
    final list = _extractList(response.data, ['data', 'addons']);
    return list.map(ArenaAddon.fromJson).toList();
  }
}

final hostArenaBookingRepositoryProvider =
    Provider<HostArenaBookingRepository>(
  (ref) => HostArenaBookingRepository(ref.watch(hostDioProvider)),
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
