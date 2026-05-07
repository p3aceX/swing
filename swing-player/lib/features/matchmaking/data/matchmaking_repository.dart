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
    _mmLog(
        'searchGrounds → date=$date format=$format teamId=${teamId ?? 'null'} overs=${overs ?? 'null'} q=${query ?? 'null'}');
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
    _mmLog('searchGrounds → raw grounds=${raw.length}');
    for (final g in raw.take(10)) {
      _mmLog(
          '  rawGround: id=${g.id} name=${g.name} area=${g.area} slots=${g.slots.length} photo=${g.photoUrl != null && g.photoUrl!.isNotEmpty}');
    }

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
    _mmLog('searchGrounds → grouped arenas=${byArena.length}');
    for (final g in byArena.values.take(10)) {
      _mmLog(
          '  groupedArena: id=${g.id} name=${g.name} area=${g.area} slots=${g.slots.length}');
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

  // ── Plan B / V2 — first-to-pay flow ─────────────────────────────────────

  /// B1 — express interest on a lobby. Idempotent per (lobbyId, teamId).
  Future<MmInterest> expressInterest(String lobbyId, String teamId) async {
    _mmLog('expressInterest → lobbyId=$lobbyId teamId=$teamId');
    final resp = await _dio.post(
      ApiEndpoints.matchmakingExpressInterest(lobbyId),
      data: {'teamId': teamId},
    );
    return MmInterest.fromJson(_unwrap(resp.data));
  }

  /// B2 — acquire 120s lock + create Razorpay order. Throws "LOCK_TAKEN" if
  /// another team is currently paying.
  Future<MmInterestLock> lockAndPay(String interestId) async {
    _mmLog('lockAndPay → interestId=$interestId');
    final resp = await _dio.post(
      ApiEndpoints.matchmakingInterestLockAndPay(interestId),
    );
    return MmInterestLock.fromJson(_unwrap(resp.data));
  }

  /// B3 — verify Razorpay payment and create the match.
  Future<MmInterestVerifyResult> verifyInterestPayment({
    required String interestId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    _mmLog('verifyInterestPayment → interestId=$interestId');
    final resp = await _dio.post(
      ApiEndpoints.matchmakingInterestVerifyPayment(interestId),
      data: {
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      },
    );
    return MmInterestVerifyResult.fromJson(_unwrap(resp.data));
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
    List<({String groundId, String slotTime})> picks = const [],
    String? ballType,
    // Discover-flow preference fields. When `timeWindow` is set and `picks` is
    // empty, the backend records this as a preference-lobby that matches via
    // window overlap rather than exact slot.
    String? timeWindow,
    String? preferredArenaId,
  }) async {
    final resp = await _dio.post(
      ApiEndpoints.matchmakingLobbies,
      data: {
        'teamId': teamId,
        'format': format,
        if (ballType != null) 'ballType': ballType,
        'date': date,
        if (picks.isNotEmpty)
          'picks': picks
              .map((p) => {'groundId': p.groundId, 'slotTime': p.slotTime})
              .toList(),
        if (timeWindow != null) 'timeWindow': timeWindow,
        if (preferredArenaId != null) 'preferredArenaId': preferredArenaId,
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

  // ── Discover-flow ──────────────────────────────────────────────────────────

  /// Lists the user's teams and one active lobby per team. Drives the
  /// team-switcher chip on the Discover tab.
  Future<MmActiveLobbiesResponse> getActiveLobbiesAll() async {
    _mmLog('getActiveLobbiesAll → GET ${ApiEndpoints.matchmakingActiveLobbiesAll}');
    final resp = await _dio.get(ApiEndpoints.matchmakingActiveLobbiesAll);
    return MmActiveLobbiesResponse.fromJson(_unwrap(resp.data));
  }

  /// Single-shot discovery: ensures the team's active lobby (find/update/create)
  /// and returns ranked closest matches + alternatives in one round trip.
  Future<MmDiscoverResponse> discoverLobbies({
    required String teamId,
    required String date,
    required String format,
    String? ballType,
    List<String> timeWindows = const [], // 5-bucket enum strings
    String? preferredArenaId, // legacy single-ground (deprecated)
    List<String> preferredArenaIds = const [], // up to 3 grounds
    double? lat,
    double? lng,
  }) async {
    _mmLog(
        'discoverLobbies → teamId=$teamId date=$date format=$format windows=$timeWindows arenas=$preferredArenaIds');
    final body = <String, dynamic>{
      'teamId': teamId,
      'filters': {
        'date': date,
        'format': format,
        if (ballType != null) 'ballType': ballType,
        'timeWindows': timeWindows,
        if (preferredArenaId != null) 'preferredArenaId': preferredArenaId,
        if (preferredArenaIds.isNotEmpty) 'preferredArenaIds': preferredArenaIds,
      },
      if (lat != null && lng != null) 'context': {'lat': lat, 'lng': lng},
    };
    final resp = await _dio.post(ApiEndpoints.matchmakingDiscover, data: body);
    return MmDiscoverResponse.fromJson(_unwrap(resp.data));
  }

  Future<MmLobbyStatus> getLobbyStatus(String lobbyId) async {
    final resp = await _dio.get(ApiEndpoints.matchmakingLobby(lobbyId));
    return MmLobbyStatus.fromJson(_unwrap(resp.data));
  }

  Future<List<MmOpenLobby>> listOpenLobbies({
    String? date,
    String? format,
    String? timeWindow,
    String? preferredArenaId,
  }) async {
    _mmLog(
        'listOpenLobbies → date=$date format=$format timeWindow=$timeWindow preferredArenaId=$preferredArenaId');
    try {
      final resp = await _dio.get(
        ApiEndpoints.matchmakingLobbies,
        queryParameters: {
          if (date != null) 'date': date,
          if (format != null && format.isNotEmpty) 'format': format,
          if (timeWindow != null) 'timeWindow': timeWindow,
          if (preferredArenaId != null) 'preferredArenaId': preferredArenaId,
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
