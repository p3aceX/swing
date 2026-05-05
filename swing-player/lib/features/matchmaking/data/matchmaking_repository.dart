import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/matchmaking_models.dart';

// ignore: avoid_print
void _mmLog(String msg) => debugPrint('[MM:repo] $msg');

class MatchmakingRepository {
  MatchmakingRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<List<MmGround>> searchGrounds({
    String? query,
    required String date,
    required String format,
    String? teamId,
    int? overs,
  }) async {
    final resp = await _dio.get(
      ApiEndpoints.matchmakingGrounds,
      queryParameters: {
        'date': date,
        'format': format,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (teamId != null && teamId.isNotEmpty) 'teamId': teamId,
        if (overs != null) 'overs': overs,
      },
    );
    final data = _unwrap(resp.data);
    final rawList = (data['grounds'] as List?) ?? [];
    final raw = rawList
        .whereType<Map<String, dynamic>>()
        .map(MmGround.fromJson)
        .toList();

    // Group by arena id — backend sends one entry per unit,
    // we collapse them into one card per arena, merging slots.
    final Map<String, MmGround> byArena = {};
    for (final unit in raw) {
      if (!byArena.containsKey(unit.id)) {
        byArena[unit.id] = unit;
      } else {
        final existing = byArena[unit.id]!;
        // Merge slots; skip duplicates (same time already seen from another unit)
        final existingTimes = existing.slots.map((s) => s.time).toSet();
        final merged = [
          ...existing.slots,
          ...unit.slots.where((s) => !existingTimes.contains(s.time)),
        ]..sort((a, b) => a.time.compareTo(b.time));
        byArena[unit.id] = MmGround(
          id: existing.id,
          name: existing.name,
          area: existing.area,
          photoUrl: existing.photoUrl,
          slots: merged,
        );
      }
    }
    return byArena.values.toList();
  }

  Future<MmCreateLobbyResult> joinLobby(String lobbyId, String teamId) async {
    final resp = await _dio.post(
      '${ApiEndpoints.matchmakingLobby(lobbyId)}/join',
      data: {'teamId': teamId},
    );
    return MmCreateLobbyResult.fromJson(_unwrap(resp.data));
  }

  Future<({String orderId, String key, int amountPaise, String currency})>
      createMatchPaymentOrder(String matchId) async {
    final resp = await _dio.post(
      '/payments/orders',
      data: {'entityType': 'MATCHMAKING_MATCH', 'entityId': matchId},
    );
    final data = _unwrap(resp.data);
    final order = data['razorpayOrder'] as Map<String, dynamic>? ?? {};
    return (
      orderId: order['id'] as String? ?? '',
      key: order['key'] as String? ?? '',
      amountPaise: (order['amount'] as num?)?.toInt() ?? 0,
      currency: (order['currency'] as String?) ?? 'INR',
    );
  }

  Future<void> verifyMatchPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    await _dio.post('/payments/verify', data: {
      'razorpayPaymentId': razorpayPaymentId,
      'razorpayOrderId': razorpayOrderId,
      'razorpaySignature': razorpaySignature,
    });
  }

  Future<MmCreateLobbyResult> createLobby({
    required String teamId,
    required String format,
    required String date,
    required List<({String groundId, String slotTime})> picks,
    String? ballType,
  }) async {
    final resp = await _dio.post(
      ApiEndpoints.matchmakingLobbies,
      data: {
        'teamId': teamId,
        'format': format,
        if (ballType != null) 'ballType': ballType,
        'date': date,
        'picks': picks
            .map((p) => {'groundId': p.groundId, 'slotTime': p.slotTime})
            .toList(),
      },
    );
    return MmCreateLobbyResult.fromJson(_unwrap(resp.data));
  }

  Future<MmLobbyStatus?> getActiveLobby() async {
    _mmLog('getActiveLobby → GET ${ApiEndpoints.matchmakingActiveLobby}');
    final resp = await _dio.get(ApiEndpoints.matchmakingActiveLobby);
    final data = _unwrap(resp.data);
    if (data.isEmpty || data['lobbyId'] == null) {
      _mmLog('getActiveLobby → no active lobby');
      return null;
    }
    _mmLog('getActiveLobby → lobbyId=${data['lobbyId']} status=${data['status']}');
    return MmLobbyStatus.fromJson(data);
  }

  Future<MmLobbyStatus> getLobbyStatus(String lobbyId) async {
    final resp = await _dio.get(ApiEndpoints.matchmakingLobby(lobbyId));
    return MmLobbyStatus.fromJson(_unwrap(resp.data));
  }

  Future<List<MmOpenLobby>> listOpenLobbies({
    String? date,
    String? format,
  }) async {
    _mmLog('listOpenLobbies → date=$date format=$format');
    try {
      final resp = await _dio.get(
        ApiEndpoints.matchmakingLobbies,
        queryParameters: {
          if (date != null) 'date': date,
          if (format != null && format.isNotEmpty) 'format': format,
        },
      );
      _mmLog('listOpenLobbies → HTTP ${resp.statusCode}');
      final data = _unwrap(resp.data);
      final rawList = (data['lobbies'] as List?) ?? [];
      _mmLog('listOpenLobbies → raw count=${rawList.length} keys=${data.keys.toList()}');
      final result = rawList
          .whereType<Map<String, dynamic>>()
          .map(MmOpenLobby.fromJson)
          .toList();
      _mmLog('listOpenLobbies → parsed count=${result.length}');
      return result;
    } catch (e, st) {
      _mmLog('listOpenLobbies ERROR: $e\n$st');
      rethrow;
    }
  }

  Future<({String status, String? bookingId})> confirmMatch(
      String matchId, String lobbyId) async {
    final resp = await _dio.post(
      ApiEndpoints.matchmakingMatchConfirm(matchId),
      data: {'lobbyId': lobbyId},
    );
    final data = _unwrap(resp.data);
    return (
      status: data['status'] as String,
      bookingId: data['bookingId'] as String?,
    );
  }

  Future<void> declineMatch(String matchId, String lobbyId) async {
    await _dio.post(
      ApiEndpoints.matchmakingMatchDecline(matchId),
      data: {'lobbyId': lobbyId},
    );
  }

  Future<void> leaveLobby(String lobbyId) async {
    await _dio.delete(ApiEndpoints.matchmakingLobby(lobbyId));
  }

  Map<String, dynamic> _unwrap(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final inner = responseData['data'];
      if (inner is Map<String, dynamic>) return inner;
      return responseData;
    }
    return {};
  }
}
