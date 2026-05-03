import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_client.dart';
import '../../booking/domain/booking_models.dart';
import '../domain/arena_slots_models.dart';

final arenaSlotsRepositoryProvider = Provider<ArenaSlotsRepository>((ref) {
  return ArenaSlotsRepository();
});

class ArenaSlotsRepository {
  ArenaSlotsRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<ArenaSlots> getArenaSlots(
    String arenaId,
    DateTime date,
    int durationMins,
  ) async {
    final resp = await _dio.get(
      '/arenas/$arenaId/booking-context',
      queryParameters: {
        'date': DateFormat('yyyy-MM-dd').format(date),
        'durationMins': durationMins.toString(),
      },
    );
    return ArenaSlots.fromJson(_unwrapMap(resp.data));
  }

  Future<SlotHold> holdSlot({
    required String arenaId,
    required String unitId,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) async {
    final resp = await _dio.post(
      '/bookings/hold',
      data: {
        'arenaId': arenaId,
        'unitId': unitId,
        'arenaUnitId': unitId,
        'bookingDate': DateFormat('yyyy-MM-dd').format(date),
        'date': DateFormat('yyyy-MM-dd').format(date),
        'startTime': startTime,
        'endTime': endTime,
      },
    );
    return SlotHold.fromJson(_unwrapMap(resp.data));
  }

  Future<ArenaPaymentOrder> createPaymentOrder(int amountPaise) async {
    final resp = await _dio.post(
      '/payments/orders',
      data: {
        'amountPaise': amountPaise,
        'currency': 'INR',
        'entityType': 'ARENA_BOOKING',
      },
    );
    return ArenaPaymentOrder.fromJson(_unwrapMap(resp.data));
  }

  Future<PlayerBooking> createBooking({
    required String holdId,
    required String unitId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String phonePeOrderId,
    required int advancePaise,
    required int totalAmountPaise,
  }) async {
    final resp = await _dio.post(
      '/bookings',
      data: {
        'holdId': holdId,
        'arenaUnitId': unitId,
        'unitId': unitId,
        'bookingDate': DateFormat('yyyy-MM-dd').format(date),
        'date': DateFormat('yyyy-MM-dd').format(date),
        'startTime': startTime,
        'endTime': endTime,
        'phonePeOrderId': phonePeOrderId,
        'merchantOrderId': phonePeOrderId,
        'paymentGateway': 'PHONEPE',
        'advancePaise': advancePaise,
        'totalAmountPaise': totalAmountPaise,
        'totalPricePaise': totalAmountPaise,
      },
    );
    return PlayerBooking.fromJson(_unwrapMap(resp.data));
  }

  /// Player-accessible: returns busy slots for an arena on a date.
  /// Uses /busy endpoint which requires no arena ownership.
  Future<List<ArenaReservation>> listArenaBusySlots(
    String arenaId, {
    required String date,
  }) async {
    final resp = await _dio.get(
      '/bookings/arena/$arenaId/busy',
      queryParameters: {'date': date},
    );
    final root = resp.data is Map
        ? Map<String, dynamic>.from(resp.data as Map)
        : <String, dynamic>{};
    final list = (root['data'] ?? const []) as List;
    return list
        .whereType<Map>()
        .map((e) => ArenaReservation.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Map<String, dynamic>> createMonthlyPass({
    required String arenaUnitId,
    required String startTime,
    required String endTime,
    required String startDate,
    String? variantType,
    int months = 1,
    String? phonePeOrderId,
  }) async {
    final resp = await _dio.post(
      '/public/monthly-passes',
      data: {
        'arenaUnitId': arenaUnitId,
        'startTime': startTime,
        'endTime': endTime,
        'daysOfWeek': [1, 2, 3, 4, 5, 6, 7],
        'startDate': startDate,
        'months': months,
        if (variantType != null) 'variantType': variantType,
        if (phonePeOrderId != null) 'phonePeOrderId': phonePeOrderId,
        if (phonePeOrderId != null) 'paymentGateway': 'PHONEPE',
      },
    );
    return _unwrapMap(resp.data);
  }

  Future<Map<String, dynamic>> createBulkBooking({
    required String arenaUnitId,
    required String startTime,
    required String endTime,
    required List<String> dates,
    String? phonePeOrderId,
  }) async {
    final resp = await _dio.post(
      '/public/bulk-bookings',
      data: {
        'arenaUnitId': arenaUnitId,
        'startTime': startTime,
        'endTime': endTime,
        'dates': dates,
        if (phonePeOrderId != null) 'phonePeOrderId': phonePeOrderId,
        if (phonePeOrderId != null) 'paymentGateway': 'PHONEPE',
      },
    );
    return _unwrapMap(resp.data);
  }

  String messageFor(Object error,
      {String fallback = 'Could not complete request.'}) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final nestedError = data['error'];
        final message = data['message'] ??
            (nestedError is Map ? nestedError['message'] : null) ??
            nestedError;
        if (message != null && '$message'.trim().isNotEmpty) {
          return '$message'.trim();
        }
      }
      final message = error.message;
      if (message != null && message.trim().isNotEmpty) return message.trim();
    }
    return fallback;
  }
}

Map<String, dynamic> _unwrapMap(dynamic body) {
  final root =
      body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};
  final data = root['data'];
  if (data is Map) return Map<String, dynamic>.from(data);
  return root;
}
