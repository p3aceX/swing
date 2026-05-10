// End-to-end smoke-test for the matchmaking discover flow.
//
// Logs in with a Firebase test phone number (configured in Firebase Console
// with a fixed OTP), exchanges the resulting idToken for a backend access
// token via /auth/login, then exercises the matchmaking endpoints.
//
// Run:
//   dart run scripts/test_matchmaking.dart
//
// Optional env overrides:
//   PHONE=+917977690545
//   OTP=123456
//   BASE_URL=https://...               backend (defaults to canonical prod)
//   DATE=YYYY-MM-DD                    discover date (defaults to today)
//   FORMAT=T20|ODI|ANY                 default T20
//   WINDOWS=MORNING,EVENING            default MORNING
//
// No UI, no curl, no SQL — pure Dart hitting the same REST API the app uses.

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

const _backendCanonical = 'https://swing-backend-nbid5gga4q-el.a.run.app';
// Android Firebase API key from lib/firebase_options.dart.
const _firebaseApiKey = 'AIzaSyA_YhSxMbQvZhRgQmssZNvuAbNr3iOE56Y';
const _firebaseHost = 'https://identitytoolkit.googleapis.com';

Future<void> main(List<String> args) async {
  final phone = Platform.environment['PHONE'] ?? '+917977690545';
  final otp = Platform.environment['OTP'] ?? '123456';
  final baseUrl = Platform.environment['BASE_URL'] ?? _backendCanonical;
  final today =
      DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
  final date = Platform.environment['DATE'] ?? today;
  final format = Platform.environment['FORMAT'] ?? 'T20';
  final windowsRanked =
      (Platform.environment['WINDOWS'] ?? 'MORNING').split(',');

  stdout.writeln('▶ phone=$phone  otp=***  baseUrl=$baseUrl');
  stdout.writeln('▶ date=$date  format=$format  windowsRanked=$windowsRanked');
  stdout.writeln('');

  // ── 1. Firebase: sendVerificationCode (test phones bypass real reCAPTCHA) ──
  stdout.writeln('━━ 1. Firebase sendVerificationCode ━━');
  final fbDio = Dio(BaseOptions(
    baseUrl: _firebaseHost,
    headers: {'Content-Type': 'application/json'},
    validateStatus: (_) => true,
  ));
  final sendResp = await fbDio.post(
    '/v1/accounts:sendVerificationCode',
    queryParameters: {'key': _firebaseApiKey},
    data: {'phoneNumber': phone},
  );
  stdout.writeln('  status: ${sendResp.statusCode}');
  if (sendResp.statusCode != 200) {
    stdout.writeln('  body: ${_pretty(sendResp.data)}');
    stdout.writeln('');
    stdout.writeln(
        '✘ sendVerificationCode failed. If the error mentions reCAPTCHA, '
        'this phone is not configured as a Firebase test phone — add it in '
        'Firebase Console → Authentication → Sign-in method → Phone → '
        '"Phone numbers for testing".');
    exit(1);
  }
  final sessionInfo = (sendResp.data as Map?)?['sessionInfo'] as String?;
  if (sessionInfo == null) {
    stdout.writeln('  body: ${_pretty(sendResp.data)}');
    stdout.writeln('✘ Missing sessionInfo in response.');
    exit(1);
  }
  stdout.writeln('  sessionInfo: ${sessionInfo.substring(0, 16)}…');
  stdout.writeln('');

  // ── 2. Firebase: signInWithPhoneNumber → idToken ─────────────────────────
  stdout.writeln('━━ 2. Firebase signInWithPhoneNumber ━━');
  final signInResp = await fbDio.post(
    '/v1/accounts:signInWithPhoneNumber',
    queryParameters: {'key': _firebaseApiKey},
    data: {'sessionInfo': sessionInfo, 'code': otp},
  );
  stdout.writeln('  status: ${signInResp.statusCode}');
  if (signInResp.statusCode != 200) {
    stdout.writeln('  body: ${_pretty(signInResp.data)}');
    stdout.writeln('✘ Firebase OTP verify failed.');
    exit(1);
  }
  final idToken = (signInResp.data as Map?)?['idToken'] as String?;
  if (idToken == null) {
    stdout.writeln('  body: ${_pretty(signInResp.data)}');
    stdout.writeln('✘ No idToken returned.');
    exit(1);
  }
  stdout.writeln('  idToken: ${idToken.substring(0, 32)}…');
  stdout.writeln('');

  // ── 3. Backend: /auth/login → accessToken ────────────────────────────────
  stdout.writeln('━━ 3. POST $baseUrl/auth/login ━━');
  final apiDio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    validateStatus: (_) => true,
  ));
  final loginResp = await apiDio.post(
    '/auth/login',
    data: {'idToken': idToken, 'initialRole': 'PLAYER'},
  );
  stdout.writeln('  status: ${loginResp.statusCode}');
  if (loginResp.statusCode != 200) {
    stdout.writeln('  body: ${_pretty(loginResp.data)}');
    stdout.writeln('✘ Backend login failed.');
    exit(1);
  }
  final loginData = _unwrap(loginResp.data);
  final accessToken = loginData['accessToken'] as String?;
  final user = (loginData['user'] ?? <String, dynamic>{}) as Map<String, dynamic>;
  if (accessToken == null) {
    stdout.writeln('  body: ${_pretty(loginResp.data)}');
    stdout.writeln('✘ No accessToken returned.');
    exit(1);
  }
  stdout.writeln('  user.id: ${user['id']}  name: ${user['name']}');
  stdout.writeln('  accessToken: ${accessToken.substring(0, 32)}…');
  stdout.writeln('');

  apiDio.options.headers['Authorization'] = 'Bearer $accessToken';

  // ── 4. Active lobbies + teams ────────────────────────────────────────────
  stdout.writeln('━━ 4. GET /matchmaking/lobbies/active-all ━━');
  final activeResp = await apiDio.get('/matchmaking/lobbies/active-all');
  stdout.writeln('  status: ${activeResp.statusCode}');
  if (activeResp.statusCode != 200) {
    stdout.writeln('  body: ${_pretty(activeResp.data)}');
    exit(1);
  }
  final unwrapped = _unwrap(activeResp.data);
  final teams = (unwrapped['teams'] as List? ?? const [])
      .whereType<Map<String, dynamic>>()
      .toList();
  final lobbies = (unwrapped['lobbies'] as List? ?? const [])
      .whereType<Map<String, dynamic>>()
      .toList();
  final allLobbies = (unwrapped['allLobbies'] as List? ?? const [])
      .whereType<Map<String, dynamic>>()
      .toList();
  stdout.writeln('  teams: ${teams.length}');
  for (final t in teams) {
    stdout.writeln(
        '    · ${t['id']}  "${t['name']}"  matches=${t['matchesPlayed']}');
  }
  stdout.writeln('  active lobbies (one-per-team): ${lobbies.length}');
  for (final l in lobbies) {
    stdout.writeln('    · ${l['lobbyId']}  team=${l['teamId']}'
        '  date=${l['date']}  fmt=${l['format']}'
        '  status=${l['status']}  windowsRanked=${l['windowsRanked']}'
        '  windowsMatched=${l['windowsMatched']}');
  }
  stdout.writeln('  all active lobbies (multi-date): ${allLobbies.length}');
  stdout.writeln('');

  if (teams.isEmpty) {
    stdout.writeln('⚠ No teams — discover cannot run. (Test user has no teams.)');
    return;
  }

  // ── 5. Discover for each team ────────────────────────────────────────────
  for (final t in teams) {
    final teamId = t['id'] as String;
    final teamName = t['name'] ?? '?';
    stdout.writeln('━━ 5. POST /matchmaking/discover  team="$teamName" ($teamId) ━━');
    final body = {
      'teamId': teamId,
      'filters': {
        'date': date,
        'format': format,
        'windowsRanked': windowsRanked,
        'groundsRanked': const <String>[],
      },
    };
    stdout.writeln('  → request: ${_pretty(body)}');
    final r = await apiDio.post('/matchmaking/discover', data: body);
    stdout.writeln('  status: ${r.statusCode}');
    if (r.statusCode != 200) {
      stdout.writeln('  body: ${_pretty(r.data)}');
      stdout.writeln('  ↳ surface code: ${_extractErrCode(r.data)}');
      stdout.writeln('');
      continue;
    }
    final disc = _unwrap(r.data);
    final yourLobbyId = disc['yourLobbyId'];
    final primary = (disc['primary'] as List? ?? const []);
    final alternatives = (disc['alternatives'] as List? ?? const []);
    stdout.writeln('  yourLobbyId: $yourLobbyId');
    stdout.writeln('  primary candidates: ${primary.length}');
    stdout.writeln('  alternatives: ${alternatives.length}');
    if (disc['alternativeReason'] != null) {
      stdout.writeln('  alternativeReason: ${disc['alternativeReason']}');
    }
    if (primary.isEmpty && alternatives.isEmpty) {
      stdout.writeln(
          '  ⚠ No matches for these filters — try DATE=YYYY-MM-DD or '
          'WINDOWS=AFTERNOON.');
    } else if (primary.isNotEmpty) {
      final first = primary.first as Map<String, dynamic>;
      final lobby = first['lobby'] as Map<String, dynamic>?;
      stdout.writeln('  ↳ top match: lobby=${lobby?['lobbyId']}'
          '  team=${lobby?['teamName']}'
          '  start=${lobby?['startTime']}');
    }
    stdout.writeln('');
  }

  stdout.writeln('━━ done ━━');
}

Map<String, dynamic> _unwrap(dynamic data) {
  if (data is Map<String, dynamic>) {
    final d = data['data'];
    if (d is Map<String, dynamic>) return d;
    return data;
  }
  return <String, dynamic>{};
}

String _pretty(dynamic data) {
  try {
    return const JsonEncoder.withIndent('  ').convert(data);
  } catch (_) {
    return data.toString();
  }
}

String _extractErrCode(dynamic body) {
  if (body is Map && body['error'] is Map) {
    final err = body['error'] as Map;
    return '${err['code']}: ${err['message']}';
  }
  return '(no structured error)';
}
