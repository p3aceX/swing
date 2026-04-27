import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../domain/booking_models.dart';

final playerBookingRepositoryProvider =
    Provider<PlayerBookingRepository>((ref) {
  return PlayerBookingRepository();
});

class PlayerBookingRepository {
  PlayerBookingRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<Map<String, dynamic>> holdSlot({
    required String arenaUnitId,
    required String bookingDate,
    required String startTime,
    required String endTime,
  }) async {
    final response = await _dio.post(
      '/bookings/hold',
      data: {
        'arenaUnitId': arenaUnitId,
        'bookingDate': bookingDate,
        'startTime': startTime,
        'endTime': endTime,
      },
    );
    return _unwrapMap(response.data);
  }

  Future<PlayerBooking> createBooking({
    required String arenaUnitId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    required int totalPricePaise,
    String? notes,
  }) async {
    final response = await _dio.post(
      '/bookings',
      data: {
        'arenaUnitId': arenaUnitId,
        'bookingDate': bookingDate,
        'startTime': startTime,
        'endTime': endTime,
        'totalPricePaise': totalPricePaise,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
    return PlayerBooking.fromJson(_unwrapMap(response.data));
  }

  Future<BookingPaymentOrder> createPaymentOrder(String bookingId) async {
    final response = await _dio.post('/bookings/$bookingId/payment-order');
    return BookingPaymentOrder.fromJson(_unwrapMap(response.data));
  }

  Future<PlayerBooking> verifyPayment({
    required String bookingId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    final response = await _dio.post(
      '/bookings/verify-payment',
      data: {
        'bookingId': bookingId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpayOrderId': razorpayOrderId,
        'razorpaySignature': razorpaySignature,
      },
    );
    return PlayerBooking.fromJson(_unwrapMap(response.data));
  }

  Future<List<PlayerBooking>> fetchMyBookings({String? status}) async {
    final response = await _dio.get(
      '/bookings/me',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    return _unwrapList(response.data).map(PlayerBooking.fromJson).toList();
  }

  Future<PlayerBooking> fetchBookingDetail(String bookingId) async {
    final response = await _dio.get('/bookings/$bookingId');
    return PlayerBooking.fromJson(_unwrapMap(response.data));
  }

  Future<PlayerBooking> cancelBooking(String bookingId,
      {String? reason}) async {
    final response = await _dio.post(
      '/bookings/$bookingId/cancel',
      data: {
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    return PlayerBooking.fromJson(_unwrapMap(response.data));
  }

  String messageFor(Object error, {String fallback = 'Something went wrong.'}) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final message = data['message'] ?? data['error'];
        if (message != null && '$message'.trim().isNotEmpty) {
          return '$message'.trim();
        }
      }
      if (error.message != null && error.message!.trim().isNotEmpty) {
        return error.message!.trim();
      }
    }
    return fallback;
  }
}

Map<String, dynamic> _unwrapMap(dynamic body) {
  final root =
      body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};
  final data = root['data'];
  if (data is Map) {
    final nested = data['booking'] ?? data['reservation'] ?? data;
    return Map<String, dynamic>.from(nested as Map);
  }
  final booking = root['booking'] ?? root['reservation'];
  if (booking is Map) return Map<String, dynamic>.from(booking);
  return root;
}

List<Map<String, dynamic>> _unwrapList(dynamic body) {
  final root = body is Map ? body : <String, dynamic>{};
  final raw = root['data'] ?? root['bookings'] ?? root['items'] ?? body;
  if (raw is Map) {
    final nested = raw['bookings'] ?? raw['items'] ?? raw['data'];
    if (nested is List) {
      return nested.whereType<Map>().map(Map<String, dynamic>.from).toList();
    }
  }
  if (raw is List) {
    return raw.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }
  return const [];
}
