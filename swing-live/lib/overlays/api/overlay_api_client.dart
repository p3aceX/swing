import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/overlay_models.dart';

class OverlayApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;
  OverlayApiException(this.code, this.message, {this.statusCode});
  @override
  String toString() => 'OverlayApiException($code, $statusCode): $message';
}

class OverlayValidateResult {
  final String matchDbId; // canonical match.id (NOT the liveCode)
  final String overlayToken;
  final Map<String, dynamic> rawMatch;
  OverlayValidateResult({
    required this.matchDbId,
    required this.overlayToken,
    required this.rawMatch,
  });
}

class OverlayApiClient {
  OverlayApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? 'https://swing-backend-nbid5gga4q-el.a.run.app';

  final String baseUrl;

  // POST /live/validate-match
  Future<OverlayValidateResult> validateMatch({
    required String liveCode,
    required String pin,
  }) async {
    final url = '$baseUrl/live/validate-match';
    debugPrint('[OverlayDebug] POST $url  body={matchId:"$liveCode", pin:"${'*' * pin.length}"}');
    final stopwatch = Stopwatch()..start();
    final res = await http.post(
      Uri.parse(url),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'matchId': liveCode, 'pin': pin}),
    );
    debugPrint(
        '[OverlayDebug] validate ← ${res.statusCode} in ${stopwatch.elapsedMilliseconds}ms · ${res.body.length}b');
    debugPrint('[OverlayDebug] validate body: ${_truncate(res.body, 600)}');

    final body = _decode(res);
    if (res.statusCode != 200 || body['success'] != true) {
      final err = (body['error'] as Map?) ?? {};
      throw OverlayApiException(
        (err['code'] as String?) ?? 'VALIDATE_FAILED',
        (err['message'] as String?) ?? 'Validation failed',
        statusCode: res.statusCode,
      );
    }
    final data = body['data'] as Map<String, dynamic>;
    final match = data['match'] as Map<String, dynamic>;
    final token = data['overlayToken'] as String?;
    if (token == null) {
      debugPrint(
          '[OverlayDebug] validate succeeded but data.overlayToken missing! data keys: ${data.keys.toList()}');
      throw OverlayApiException(
          'NO_TOKEN', 'Backend did not return overlayToken');
    }
    debugPrint(
        '[OverlayDebug] validate ok: matchId=${match['id']} title="${match['title']}" tokenLen=${token.length}');
    return OverlayValidateResult(
      matchDbId: match['id'] as String,
      overlayToken: token,
      rawMatch: match,
    );
  }

  // GET /live/matches/:id/bootstrap
  Future<OverlayBootstrap> fetchBootstrap({
    required String matchId,
    required String overlayToken,
  }) async {
    final url = '$baseUrl/live/matches/$matchId/bootstrap';
    debugPrint('[OverlayDebug] GET $url');
    final stopwatch = Stopwatch()..start();
    final res = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $overlayToken'},
    );
    debugPrint(
        '[OverlayDebug] bootstrap ← ${res.statusCode} in ${stopwatch.elapsedMilliseconds}ms · ${res.body.length}b');
    if (res.statusCode != 200) {
      debugPrint(
          '[OverlayDebug] bootstrap ERROR body: ${_truncate(res.body, 800)}');
    }

    final body = _decode(res);
    if (res.statusCode != 200 || body['success'] != true) {
      final err = (body['error'] as Map?) ?? {};
      throw OverlayApiException(
        (err['code'] as String?) ?? 'BOOTSTRAP_FAILED',
        (err['message'] as String?) ?? 'Bootstrap failed',
        statusCode: res.statusCode,
      );
    }
    final boot = OverlayBootstrap.fromJson(body['data'] as Map<String, dynamic>);
    debugPrint(
        '[OverlayDebug] bootstrap ok: ${boot.teamA.shortName ?? boot.teamA.name} (${boot.teamA.playingXi.length}xi) vs ${boot.teamB.shortName ?? boot.teamB.name} (${boot.teamB.playingXi.length}xi) · status=${boot.match.status} · toss.done=${boot.toss.done}');
    return boot;
  }

  static String _truncate(String s, int n) =>
      s.length <= n ? s : '${s.substring(0, n)}…(+${s.length - n})';

  // GET /live/matches/:id/tick   (SSE stream)
  // Auto-reconnects with exponential backoff (max 10s).
  Stream<OverlayTick> tickStream({
    required String matchId,
    required String overlayToken,
  }) {
    final controller = StreamController<OverlayTick>(sync: false);
    var closed = false;
    var backoffMs = 500;
    http.Client? client;
    StreamSubscription<String>? sub;

    // Forward declarations so `connect` can reference `scheduleReconnect`
    // and vice versa.
    late final Future<void> Function() connect;
    late final void Function() scheduleReconnect;

    scheduleReconnect = () {
      sub?.cancel();
      sub = null;
      client?.close();
      client = null;
      if (closed) return;
      final delay = Duration(milliseconds: backoffMs);
      debugPrint('[OverlayDebug] SSE will reconnect in ${backoffMs}ms');
      backoffMs = (backoffMs * 2).clamp(500, 10000);
      Future.delayed(delay, connect);
    };

    var tickCount = 0;
    connect = () async {
      if (closed) return;
      client = http.Client();
      try {
        final url = '$baseUrl/live/matches/$matchId/tick?token=…';
        debugPrint('[OverlayDebug] SSE GET $url');
        final req = http.Request(
          'GET',
          Uri.parse('$baseUrl/live/matches/$matchId/tick?token=$overlayToken'),
        );
        req.headers['Accept'] = 'text/event-stream';
        req.headers['Cache-Control'] = 'no-cache';

        final response = await client!.send(req);
        debugPrint('[OverlayDebug] SSE ← ${response.statusCode}');
        if (response.statusCode != 200) {
          throw OverlayApiException(
            'TICK_HTTP_${response.statusCode}',
            'Tick stream rejected',
            statusCode: response.statusCode,
          );
        }
        backoffMs = 500; // reset on successful connect

        final lines =
            response.stream.transform(utf8.decoder).transform(const LineSplitter());

        String? eventName;
        final dataBuffer = StringBuffer();

        sub = lines.listen((line) {
          if (line.isEmpty) {
            // dispatch event
            if (dataBuffer.isNotEmpty) {
              final data = dataBuffer.toString();
              if ((eventName ?? 'tick') == 'tick') {
                try {
                  final json = jsonDecode(data) as Map<String, dynamic>;
                  final t = OverlayTick.fromJson(json);
                  tickCount++;
                  // Log every 10th tick + the first to avoid log spam.
                  if (tickCount == 1 || tickCount % 10 == 0) {
                    final c = t.current;
                    debugPrint(
                        '[OverlayDebug] tick #$tickCount status=${t.status} score=${c?.runs}/${c?.wickets} (${c?.overs.toStringAsFixed(1)}) lastBalls=${t.lastBalls.length}');
                  }
                  controller.add(t);
                } catch (e) {
                  debugPrint(
                      '[OverlayDebug] tick parse error: $e · raw=${_truncate(data, 200)}');
                }
              }
            }
            eventName = null;
            dataBuffer.clear();
            return;
          }
          if (line.startsWith(':')) return; // SSE comment
          if (line.startsWith('event:')) {
            eventName = line.substring(6).trim();
          } else if (line.startsWith('data:')) {
            if (dataBuffer.isNotEmpty) dataBuffer.write('\n');
            dataBuffer.write(line.substring(5).trimLeft());
          }
        }, onError: (e) {
          debugPrint('[OverlayDebug] SSE stream error: $e — reconnecting');
          scheduleReconnect();
        }, onDone: () {
          debugPrint(
              '[OverlayDebug] SSE stream done (received $tickCount ticks) — reconnecting');
          if (!closed) scheduleReconnect();
        });
      } catch (e) {
        debugPrint('[OverlayDebug] SSE connect error: $e');
        scheduleReconnect();
      }
    };

    controller.onListen = connect;
    controller.onCancel = () async {
      closed = true;
      await sub?.cancel();
      client?.close();
    };
    return controller.stream;
  }

  Map<String, dynamic> _decode(http.Response res) {
    try {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw OverlayApiException(
        'BAD_JSON',
        'Could not decode response: ${res.body}',
        statusCode: res.statusCode,
      );
    }
  }
}
