import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted match-pairing credentials. The user gets a Swing ID
/// (= match.liveCode) and a Swing Pass (= match.livePin) from the host
/// app, types them in here, and the overlay switches from demo to real
/// data.
@immutable
class MatchCredentials {
  static const _kHost = 'overlay_backend_host';
  static const _kCode = 'overlay_live_code';
  static const _kPin  = 'overlay_live_pin';

  /// Production swing-backend on Google Cloud Run. Override via the
  /// settings sheet if running against a local stack.
  static const defaultHost =
      'https://swing-backend-1007730655118.asia-south1.run.app';

  final String host;     // backend base, no trailing slash
  final String liveCode; // Swing ID (match.liveCode)
  final String livePin;  // Swing Pass (match.livePin)

  const MatchCredentials({
    required this.host,
    required this.liveCode,
    required this.livePin,
  });

  bool get isComplete => liveCode.isNotEmpty && livePin.isNotEmpty;

  static Future<MatchCredentials?> load() async {
    final p = await SharedPreferences.getInstance();
    final code = p.getString(_kCode) ?? '';
    final pin = p.getString(_kPin) ?? '';
    if (code.isEmpty || pin.isEmpty) return null;
    final host = p.getString(_kHost) ?? defaultHost;
    return MatchCredentials(host: host, liveCode: code, livePin: pin);
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kHost, host);
    await p.setString(_kCode, liveCode);
    await p.setString(_kPin, livePin);
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kHost);
    await p.remove(_kCode);
    await p.remove(_kPin);
  }
}
