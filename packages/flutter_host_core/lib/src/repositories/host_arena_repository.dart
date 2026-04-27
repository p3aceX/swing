import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

  Future<ArenaUnitOption> createArenaUnit(
    String arenaId,
    Map<String, dynamic> input,
  ) async {
    final response = await _dio.post(
      _paths.arenaUnits(arenaId),
      data: input,
    );
    final data = _extractMap(response.data);
    final payload = data['data'] ?? data;
    return ArenaUnitOption.fromJson(Map<String, dynamic>.from(payload as Map));
  }

  Future<ArenaUnitOption> updateArenaUnit(
    String unitId,
    Map<String, dynamic> input,
  ) async {
    final response = await _dio.patch(
      _paths.arenaUnit(unitId),
      data: input,
    );
    final data = _extractMap(response.data);
    final payload = data['data'] ?? data;
    return ArenaUnitOption.fromJson(Map<String, dynamic>.from(payload as Map));
  }

  Future<void> deleteArenaUnit(String unitId) async {
    await _dio.delete(_paths.arenaUnit(unitId));
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

  Future<PlayerSlotsData> fetchPlayerSlots({
    required String arenaId,
    required DateTime date,
    required int durationMins,
  }) async {
    final response = await _dio.get(
      _paths.arenaSlots(arenaId),
      queryParameters: {
        'date': date.toIso8601String().split('T').first,
        'durationMins': durationMins,
      },
    );
    final root = _extractMap(response.data);
    final payload = (root['data'] ?? root) as Map?;
    return PlayerSlotsData.fromJson(
      payload != null ? Map<String, dynamic>.from(payload) : <String, dynamic>{},
    );
  }

  Future<List<ArenaAddon>> fetchArenaAddons(String arenaId) async {
    final response = await _dio.get(_paths.arenaAddons(arenaId));
    final list = _extractList(response.data, ['data', 'addons']);
    return list.map(ArenaAddon.fromJson).toList();
  }

  Future<ArenaAddon> createArenaAddon(
    String arenaId,
    Map<String, dynamic> input,
  ) async {
    final response = await _dio.post(
      _paths.arenaAddons(arenaId),
      data: input,
    );
    final data = _extractMap(response.data);
    final payload = data['data'] ?? data;
    return ArenaAddon.fromJson(Map<String, dynamic>.from(payload as Map));
  }

  Future<ArenaAddon> updateArenaAddon(
    String addonId,
    Map<String, dynamic> input,
  ) async {
    final response = await _dio.patch(
      _paths.arenaAddon(addonId),
      data: input,
    );
    final data = _extractMap(response.data);
    final payload = data['data'] ?? data;
    return ArenaAddon.fromJson(Map<String, dynamic>.from(payload as Map));
  }

  Future<void> deleteArenaAddon(String addonId) async {
    await _dio.delete(_paths.arenaAddon(addonId));
  }

  Future<List<ArenaTimeBlock>> listUnitTimeBlocks(
    String arenaId, {
    required String unitId,
  }) async {
    final response = await _dio.get(
      _paths.arenaBlocks(arenaId),
      queryParameters: {'unitId': unitId},
    );
    final data = _extractMap(response.data);
    final list = ((data['data'] ?? const []) as List)
        .whereType<Map>()
        .map((e) => ArenaTimeBlock.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return list;
  }

  Future<ArenaTimeBlock> createTimeBlock(
    String arenaId,
    Map<String, dynamic> input,
  ) async {
    final response = await _dio.post(
      _paths.arenaBlocks(arenaId),
      data: input,
    );
    final data = _extractMap(response.data);
    final payload = data['data'] ?? data;
    return ArenaTimeBlock.fromJson(Map<String, dynamic>.from(payload as Map));
  }

  Future<void> deleteTimeBlock(String blockId) async {
    await _dio.delete(_paths.arenaBlock(blockId));
  }

  Future<List<ArenaReservation>> listArenaBookings(
    String arenaId, {
    String? date,
    String? unitId,
  }) async {
    final response = await _dio.get(
      _paths.arenaReservations(arenaId),
      queryParameters: {
        if (date != null) 'date': date,
      },
    );
    final data = _extractMap(response.data);
    final list = ((data['data'] ?? const []) as List)
        .whereType<Map>()
        .map((e) => ArenaReservation.fromJson(Map<String, dynamic>.from(e)))
        .where((r) => unitId == null || r.unitId == unitId)
        .toList();
    return list;
  }

  // Returns { "YYYY-MM-DD": { count, revenuePaise } }
  Future<Map<String, ArenaDaySummary>> fetchMonthSummary(
    String arenaId,
    String month, // "YYYY-MM"
  ) async {
    final response = await _dio.get(
      _paths.arenaBookingSummary(arenaId),
      queryParameters: {'month': month},
    );
    final data = _extractMap(response.data);
    final payload = (data['data'] ?? data) as Map?;
    final result = <String, ArenaDaySummary>{};
    payload?.forEach((key, value) {
      if (value is Map) {
        result['$key'] = ArenaDaySummary(
          count: (value['count'] as num?)?.toInt() ?? 0,
          revenuePaise: (value['revenuePaise'] as num?)?.toInt() ?? 0,
        );
      }
    });
    return result;
  }

  Future<ArenaReservation> createManualBooking(
    String arenaId, {
    required String unitId,
    required String date,
    required String startTime,
    required String endTime,
    required String guestName,
    required String guestPhone,
    required String paymentMode,
    required int amountPaise,
    int advancePaise = 0,
    String? notes,
  }) async {
    final response = await _dio.post(
      _paths.arenaManualBooking(arenaId),
      data: {
        'unitId': unitId,
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'guestName': guestName,
        'guestPhone': guestPhone,
        'paymentMode': paymentMode,
        'amountPaise': amountPaise,
        'advancePaise': advancePaise,
        if (notes != null) 'notes': notes,
      },
    );
    final data = _extractMap(response.data);
    final payload = data['data'] ?? data;
    return ArenaReservation.fromJson(Map<String, dynamic>.from(payload as Map));
  }

  Future<ArenaReservation> markBookingPaid(
    String bookingId, {
    required String paymentMode,
    int? amountPaise,
    String? reference,
  }) async {
    final response = await _dio.post(
      _paths.bookingMarkPaid(bookingId),
      data: {
        'paymentMode': paymentMode,
        if (amountPaise != null) 'amountPaise': amountPaise,
        if (reference != null) 'reference': reference,
      },
    );
    final data = _extractMap(response.data);
    final payload = data['data'] ?? data;
    return ArenaReservation.fromJson(Map<String, dynamic>.from(payload as Map));
  }

  Future<ArenaReservation> cancelBookingByOwner(
    String bookingId, {
    String? reason,
  }) async {
    final response = await _dio.post(
      _paths.bookingCancelByOwner(bookingId),
      data: {if (reason != null) 'reason': reason},
    );
    final data = _extractMap(response.data);
    final payload = data['data'] ?? data;
    return ArenaReservation.fromJson(Map<String, dynamic>.from(payload as Map));
  }

  Future<ArenaPaymentsData> fetchArenaPayments(
    String arenaId, {
    String? month,
    String? mode,
  }) async {
    debugPrint('[payments] fetchArenaPayments arena=$arenaId month=$month mode=$mode');
    try {
      final response = await _dio.get(
        _paths.arenaPayments(arenaId),
        queryParameters: {
          if (month != null) 'month': month,
          if (mode != null) 'mode': mode,
        },
      );
      debugPrint('[payments] status=${response.statusCode} type=${response.data.runtimeType}');
      debugPrint('[payments] raw: ${response.data}');
      final data = _extractMap(response.data);
      debugPrint('[payments] top-level keys: ${data.keys.toList()}');
      final payload = _extractMap(data['data'] ?? data);
      debugPrint('[payments] payload keys: ${payload.keys.toList()}');
      final rawCheckedIn = payload['checkedInBookings'];
      final rawPending = payload['pendingBookings'];
      debugPrint('[payments] checkedInBookings type=${rawCheckedIn.runtimeType} value=$rawCheckedIn');
      debugPrint('[payments] pendingBookings type=${rawPending.runtimeType} value=$rawPending');
      final checkedIn = ((rawCheckedIn ?? const []) as List)
          .whereType<Map>()
          .map((e) => ArenaReservation.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      final pending = ((rawPending ?? const []) as List)
          .whereType<Map>()
          .map((e) => ArenaReservation.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      debugPrint('[payments] parsed: ${checkedIn.length} checked-in, ${pending.length} pending');
      if (checkedIn.isNotEmpty) {
        final b = checkedIn.first;
        debugPrint('[payments] first checked-in: id=${b.id} status=${b.status} checkedInAt=${b.checkedInAt} total=${b.totalAmountPaise}');
      }
      if (pending.isNotEmpty) {
        final b = pending.first;
        debugPrint('[payments] first pending: id=${b.id} status=${b.status} checkedInAt=${b.checkedInAt} total=${b.totalAmountPaise}');
      }
      return ArenaPaymentsData(checkedInBookings: checkedIn, pendingBookings: pending);
    } catch (e, st) {
      debugPrint('[payments] fetchArenaPayments ERROR: $e\n$st');
      rethrow;
    }
  }

  Future<List<ArenaGuest>> fetchArenaGuests(
    String arenaId, {
    String? search,
  }) async {
    debugPrint('[customers] fetchArenaGuests arena=$arenaId search=$search');
    try {
      final response = await _dio.get(
        _paths.arenaGuests(arenaId),
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      debugPrint('[customers] raw response: ${response.data}');
      final data = _extractMap(response.data);
      final list = ((data['data'] ?? const []) as List)
          .whereType<Map>()
          .map((e) => ArenaGuest.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      debugPrint('[customers] parsed: ${list.length} guests');
      return list;
    } catch (e, st) {
      debugPrint('[customers] fetchArenaGuests ERROR: $e\n$st');
      rethrow;
    }
  }

  Future<ArenaReservation> checkinByOwner(String bookingId) async {
    final response = await _dio.post(_paths.bookingCheckinByOwner(bookingId));
    final data = _extractMap(response.data);
    final payload = data['data'] ?? data;
    return ArenaReservation.fromJson(Map<String, dynamic>.from(payload as Map));
  }
}

class ArenaDaySummary {
  const ArenaDaySummary({required this.count, required this.revenuePaise});
  final int count;
  final int revenuePaise;
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
