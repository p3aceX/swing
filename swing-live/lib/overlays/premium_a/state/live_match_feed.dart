import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'ball_event.dart';
import 'match_credentials.dart';
import 'match_feed.dart';
import 'match_state.dart';

/// Backend feed for the Premium-A overlay.
///
/// Flow:
///   1. `POST /live/validate-match` — checks the Swing ID + Pass.
///   2. `GET  /public/overlay/<matchId>/stream` — public SSE stream of
///      pre-resolved overlay state (no auth). Frames look like:
///        event: overlay
///        data: { batting: {...}, striker: {...}, bowler: {...}, ... }
///
/// We use the PUBLIC endpoint instead of `/live/matches/<id>/tick` because
/// the deployed backend's validate-match doesn't currently emit an
/// `overlayToken` in its response — the public stream side-steps the
/// auth entirely and serves the same data with names already resolved.
class LiveMatchFeed implements MatchFeed {
  LiveMatchFeed(this.credentials);

  final MatchCredentials credentials;

  @override
  final ValueNotifier<MatchState> state =
      ValueNotifier<MatchState>(_seed());

  @override
  final ValueNotifier<MatchFeedStatus> status =
      ValueNotifier<MatchFeedStatus>(MatchFeedStatus.connecting);

  final _eventsCtrl = StreamController<OverlayEvent>.broadcast();
  @override
  Stream<OverlayEvent> get events => _eventsCtrl.stream;

  http.Client? _client;
  StreamSubscription<List<int>>? _sseSub;
  Timer? _reconnectTimer;
  String? _matchId;
  String? _matchTitle;
  final Set<String> _seenBallIds = {};

  bool _disposed = false;

  // 500ms coalescing window so a burst of SSE frames (e.g. score
  // correction, then ball confirmation) doesn't redraw the overlay
  // multiple times in the same animation frame. Latest payload wins.
  Timer? _throttleTimer;
  Map<String, dynamic>? _pendingPayload;

  // ── Lifecycle ────────────────────────────────────────────────────────
  @override
  void start() {
    if (_disposed) return;
    _connect();
  }

  @override
  void stop() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _sseSub?.cancel();
    _sseSub = null;
    _client?.close();
    _client = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _throttleTimer?.cancel();
    stop();
    _eventsCtrl.close();
    state.dispose();
    status.dispose();
  }

  // ── Connection flow ──────────────────────────────────────────────────
  Future<void> _connect() async {
    if (_disposed) return;
    status.value = MatchFeedStatus.connecting;
    try {
      final v = await validateCredentials(credentials);
      _matchId = v['matchId'] as String;
      final match = v['match'] as Map<String, dynamic>?;
      _matchTitle = match?['title'] as String?;
      _openOverlayStream();
    } catch (e) {
      status.value = MatchFeedStatus.failed(e.toString());
      _scheduleReconnect();
    }
  }

  /// Public helper — also used by the pair sheet to verify creds before
  /// the user goes live. Throws a human-readable string on failure.
  static Future<Map<String, dynamic>> validateCredentials(
      MatchCredentials creds) async {
    final url = '${creds.host}/live/validate-match';
    final reqBody = jsonEncode({
      'matchId': creds.liveCode,
      'pin': creds.livePin,
    });
    debugPrint('[validate-match] POST $url');
    debugPrint('[validate-match] body: $reqBody');
    final res = await http
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: reqBody,
        )
        .timeout(const Duration(seconds: 10));
    debugPrint('[validate-match] status: ${res.statusCode}');
    debugPrint('[validate-match] response: ${res.body}');

    if (res.statusCode != 200) {
      final code = _extractCode(res.body);
      final msg = _extractError(res.body);
      if (code == 'MATCH_NOT_FOUND') {
        throw 'Match not found. Open the host app → tap "Take Match Live" '
            'on this match first to generate the Swing ID.';
      }
      if (code == 'INVALID_PIN') {
        throw 'Swing Pass is wrong. Check the 4-digit pass from the host app.';
      }
      throw 'HTTP ${res.statusCode}: $msg';
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw _extractError(res.body);
    }
    final data = body['data'] as Map<String, dynamic>?;
    final match = data?['match'] as Map<String, dynamic>?;
    final matchId = match?['id'] as String?;
    if (matchId == null) {
      throw 'Server returned no match id.';
    }
    return {
      'matchId': matchId,
      'match': match,
      // overlayToken is optional in deployed builds — we don't need it for
      // the public overlay stream we consume.
      'overlayToken': data?['overlayToken'] as String?,
    };
  }

  void _openOverlayStream() {
    _sseSub?.cancel();
    _client = http.Client();
    final url = '${credentials.host}/public/overlay/$_matchId/stream';
    debugPrint('[overlay-stream] connecting: $url');
    final req = http.Request('GET', Uri.parse(url));
    req.headers['Accept'] = 'text/event-stream';
    req.headers['Cache-Control'] = 'no-cache';
    _client!.send(req).then((res) {
      if (res.statusCode != 200) {
        debugPrint('[overlay-stream] status ${res.statusCode}');
        status.value = MatchFeedStatus.failed('stream HTTP ${res.statusCode}');
        _scheduleReconnect();
        return;
      }
      status.value = MatchFeedStatus.live;
      debugPrint('[overlay-stream] CONNECTED status=200');
      // SSE parser. Frame = lines terminated by \n\n. Each line in the
      // frame is either `event: <type>` or `data: <json>`.
      final buf = StringBuffer();
      String? eventType;
      _sseSub = res.stream.listen(
        (chunk) {
          buf.write(utf8.decode(chunk, allowMalformed: true));
          final raw = buf.toString();
          final blocks = raw.split('\n\n');
          for (var i = 0; i < blocks.length - 1; i++) {
            final block = blocks[i];
            eventType = null;
            final dataLines = <String>[];
            for (final line in block.split('\n')) {
              if (line.startsWith('event:')) {
                eventType = line.substring(6).trim();
              } else if (line.startsWith('data:')) {
                dataLines.add(line.substring(5).trim());
              }
            }
            if (dataLines.isEmpty) continue;
            if (eventType == 'error') {
              debugPrint('[overlay-stream] error event: ${dataLines.join()}');
              continue;
            }
            try {
              final payload = jsonDecode(dataLines.join('\n'))
                  as Map<String, dynamic>;
              _applyOverlay(payload);
            } catch (e) {
              debugPrint('[overlay-stream] parse failed: $e');
            }
          }
          buf
            ..clear()
            ..write(blocks.last);
        },
        onError: (e) {
          debugPrint('[overlay-stream] error: $e');
          status.value = MatchFeedStatus.disconnected;
          _scheduleReconnect();
        },
        onDone: () {
          if (_disposed) return;
          status.value = MatchFeedStatus.disconnected;
          _scheduleReconnect();
        },
        cancelOnError: true,
      );
    }).catchError((e) {
      debugPrint('[overlay-stream] connect failed: $e');
      status.value = MatchFeedStatus.failed(e.toString());
      _scheduleReconnect();
    });
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 4), _connect);
  }

  // ── Public payload → MatchState ───────────────────────────────────────
  void _applyOverlay(Map<String, dynamic> p) {
    if (_throttleTimer != null) {
      _pendingPayload = p;
      return;
    }

    _doApply(p);

    _throttleTimer = Timer(const Duration(milliseconds: 500), () {
      _throttleTimer = null;
      if (_pendingPayload != null) {
        final p2 = _pendingPayload!;
        _pendingPayload = null;
        _doApply(p2);
      }
    });
  }

  void _doApply(Map<String, dynamic> p) {
    final prev = state.value;

    final teamAName = (p['teamAName'] as String?) ?? 'TEAM A';
    final teamBName = (p['teamBName'] as String?) ?? 'TEAM B';
    final teamAShort = (p['teamAShortName'] as String?) ?? _short3(teamAName);
    final teamBShort = (p['teamBShortName'] as String?) ?? _short3(teamBName);

    final teamA = TeamMeta(
      shortCode: teamAShort.toUpperCase(),
      fullName: teamAName.toUpperCase(),
      accentColor: 0xFF0B6FF0,
    );
    final teamB = TeamMeta(
      shortCode: teamBShort.toUpperCase(),
      fullName: teamBName.toUpperCase(),
      accentColor: 0xFFFFD60A,
    );

    final venue = ((p['venueName'] as String?) ?? '').toUpperCase();

    final batting = p['batting'] as Map<String, dynamic>?;
    final teamKey = batting?['teamKey'] as String?;
    final battingSide =
        teamKey == 'B' ? InningsSide.teamB : InningsSide.teamA;

    final runs = (batting?['runs'] as num?)?.toInt() ?? 0;
    final wickets = (batting?['wickets'] as num?)?.toInt() ?? 0;
    final oversNum = (batting?['overs'] as num?)?.toDouble() ?? 0.0;
    final balls = _oversToBalls(oversNum);
    final target = (batting?['target'] as num?)?.toInt();

    final striker = _batter(p['striker']);
    final nonStriker = _batter(p['nonStriker']);
    final bowler = _bowler(p['bowler']);

    final thisOver = (p['thisOver'] as List<dynamic>?) ?? const [];
    final currentOver = thisOver
        .whereType<Map<String, dynamic>>()
        .map(_outcomeFromBallEvent)
        .toList();

    final isPowerplay = p['isPowerplay'] == true;

    state.value = MatchState(
      teamA: teamA,
      teamB: teamB,
      groundName: venue,
      matchLabel: (_matchTitle ?? 'LIVE MATCH').toUpperCase(),
      battingSide: battingSide,
      score: runs,
      wickets: wickets,
      balls: balls,
      target: target,
      striker: striker ?? prev.striker,
      nonStriker: nonStriker ?? prev.nonStriker,
      bowler: bowler ?? prev.bowler,
      currentOver: currentOver,
      phase: isPowerplay
          ? MatchPhase.powerplay
          : balls >= 96
              ? MatchPhase.death
              : MatchPhase.middle,
      winner: null,
    );

    // Diff thisOver vs seen → fire flash events.
    debugPrint(
        '[overlay-stream] _doApply: thisOver.length=${thisOver.length}, seen=${_seenBallIds.length}');
    if (thisOver.isNotEmpty && _seenBallIds.isEmpty) {
      debugPrint('[overlay-stream] first ball raw: ${thisOver.first}');
      debugPrint(
          '[overlay-stream] first ball runtimeType: ${thisOver.first.runtimeType}');
    }
    for (final raw in thisOver) {
      // Accept any Map (the strict `Map<String, dynamic>` cast was
      // failing because jsonDecode of nested arrays sometimes hands us
      // a `Map<dynamic, dynamic>` — that strict check was silently
      // skipping every ball).
      if (raw is! Map) continue;
      // Backend may not include `id` for individual balls in `thisOver`.
      // Fall back to a synthetic id derived from over+ball position so
      // we still de-dupe properly.
      final id = (raw['id'] as String?) ??
          (raw['ballId'] as String?) ??
          '${raw['over'] ?? ''}.${raw['ballInOver'] ?? thisOver.indexOf(raw)}';
      if (_seenBallIds.contains(id)) continue;
      _seenBallIds.add(id);
      final outcome = _outcomeFromBallEvent(Map<String, dynamic>.from(raw));
      debugPrint(
          '[overlay-stream] NEW BALL id=$id outcome=${raw['outcome']} '
          'isWicket=${outcome.isWicket} isFour=${outcome.isBoundary} '
          'isSix=${outcome.isSix}');
      _eventsCtrl.add(BallLanded(outcome));
      if (outcome.isWicket) {
        final dismissedId = raw['dismissedPlayerId'] as String? ??
            raw['batterId'] as String?;
        final dismissedName =
            (raw['dismissedName'] as String?) ?? striker?.name ?? '—';
        final batterSnap = BatterSnapshot(
          name: _shortenName(dismissedName),
          runs: prev.striker.runs,
          ballsFaced: prev.striker.ballsFaced,
          fours: prev.striker.fours,
          sixes: prev.striker.sixes,
        );
        final dismissalType =
            (raw['dismissalType'] as String?)?.toUpperCase().replaceAll(
                  '_',
                  ' ',
                ) ??
                'OUT';
        _eventsCtrl.add(WicketTaken(
          dismissed: batterSnap,
          dismissalMethod: dismissalType,
          bowlerName: bowler?.name ?? '',
        ));
        if (dismissedId == null) {} // suppress unused-warning fence
      }
    }
    if (_seenBallIds.length > 200) {
      final tooMany = _seenBallIds.length - 100;
      final keep = _seenBallIds.skip(tooMany).toSet();
      _seenBallIds
        ..clear()
        ..addAll(keep);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────
  int _oversToBalls(double overs) {
    final whole = overs.floor();
    final frac = ((overs - whole) * 10).round();
    return whole * 6 + frac;
  }

  static String _short3(String full) {
    final parts = full.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final s = parts[0][0] + parts[1][0] + (parts.length >= 3 ? parts[2][0] : '');
      return s.toUpperCase().substring(0, s.length.clamp(2, 3));
    }
    return full
        .substring(0, full.length.clamp(2, 3))
        .toUpperCase();
  }

  static String _shortenName(String full) {
    final parts = full.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.toUpperCase();
    return '${parts.first[0].toUpperCase()}. ${parts.last.toUpperCase()}';
  }

  BatterSnapshot? _batter(dynamic raw) {
    if (raw is! Map) return null;
    final name = raw['name'] as String?;
    return BatterSnapshot(
      name: name != null ? _shortenName(name) : '—',
      runs: (raw['runs'] as num?)?.toInt() ?? 0,
      ballsFaced: (raw['balls'] as num?)?.toInt() ?? 0,
      fours: (raw['fours'] as num?)?.toInt() ?? 0,
      sixes: (raw['sixes'] as num?)?.toInt() ?? 0,
    );
  }

  BowlerSnapshot? _bowler(dynamic raw) {
    if (raw is! Map) return null;
    final name = raw['name'] as String?;
    // Backend payload (public.routes.ts) ships `{ id, overs, runs,
    // wickets, economy, name }`. We previously read `oversBowled` /
    // `runsConceded`, which never existed on this endpoint — every
    // bowler ended up at 0.0-0-0-0 in the scorebar regardless of how
    // much they'd actually bowled.
    final overs = (raw['overs'] as num?)?.toDouble() ??
        (raw['oversBowled'] as num?)?.toDouble() ??
        0;
    final runs = (raw['runs'] as num?)?.toInt() ??
        (raw['runsConceded'] as num?)?.toInt() ??
        0;
    return BowlerSnapshot(
      name: name != null ? _shortenName(name) : '—',
      legalBallsBowled: _oversToBalls(overs),
      maidens: 0,
      runsConceded: runs,
      wickets: (raw['wickets'] as num?)?.toInt() ?? 0,
    );
  }

  BallOutcome _outcomeFromBallEvent(Map<String, dynamic> b) {
    final outcome = b['outcome'] as String?;
    final isWide = outcome == 'WIDE';
    final isNoBall = outcome == 'NO_BALL';
    final isSix = outcome == 'SIX';
    final isFour = outcome == 'FOUR';
    final runs = (b['runs'] as num?)?.toInt() ?? 0;
    final extras = (b['extras'] as num?)?.toInt() ?? 0;
    final isWicket = b['isWicket'] == true;
    return BallOutcome(
      runsFromBat: runs,
      extras: extras,
      extraKind: isWide
          ? ExtraKind.wide
          : isNoBall
              ? ExtraKind.noBall
              : outcome == 'BYE'
                  ? ExtraKind.bye
                  : outcome == 'LEG_BYE'
                      ? ExtraKind.legBye
                      : null,
      isWicket: isWicket,
      isBoundary: isFour,
      isSix: isSix,
      wasLegal: !isWide && !isNoBall,
    );
  }

  static String _extractError(String body) {
    try {
      final j = jsonDecode(body) as Map<String, dynamic>;
      final err = j['error'];
      if (err is Map) return err['message']?.toString() ?? body;
      if (err is String) return err;
      return body;
    } catch (_) {
      return body;
    }
  }

  static String? _extractCode(String body) {
    try {
      final j = jsonDecode(body) as Map<String, dynamic>;
      final err = j['error'];
      if (err is Map) return err['code']?.toString();
    } catch (_) {}
    return null;
  }

  static MatchState _seed() {
    return const MatchState(
      teamA: TeamMeta(shortCode: '—', fullName: '—', accentColor: 0xFF0B6FF0),
      teamB: TeamMeta(shortCode: '—', fullName: '—', accentColor: 0xFFFFD60A),
      groundName: 'CONNECTING…',
      matchLabel: 'LIVE MATCH',
      battingSide: InningsSide.teamA,
      score: 0,
      wickets: 0,
      balls: 0,
      target: null,
      striker: BatterSnapshot(
          name: '—', runs: 0, ballsFaced: 0, fours: 0, sixes: 0),
      nonStriker: BatterSnapshot(
          name: '—', runs: 0, ballsFaced: 0, fours: 0, sixes: 0),
      bowler: BowlerSnapshot(
          name: '—',
          legalBallsBowled: 0,
          maidens: 0,
          runsConceded: 0,
          wickets: 0),
      currentOver: [],
      phase: MatchPhase.middle,
      winner: null,
    );
  }
}
