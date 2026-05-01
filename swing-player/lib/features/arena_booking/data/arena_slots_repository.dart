import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      '/arenas/$arenaId/slots',
      queryParameters: {
        'date': DateFormat('yyyy-MM-dd').format(date),
        'durationMins': durationMins.toString(),
      },
    );
    debugPrint('[API /slots raw]\n${const JsonEncoder.withIndent('  ').convert(resp.data)}');
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

  String messageFor(Object error,
      {String fallback = 'Could not complete request.'}) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final message = data['message'] ?? data['error'];
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
