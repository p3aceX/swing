import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted YouTube broadcast credentials. Created once per match,
/// reused across app restarts/crashes until expired or explicitly ended.
class StreamSession {
  final String broadcastId;
  final String streamId;
  final String rtmpUrl;
  final String streamKey;
  final DateTime createdAt;
  final bool wasStreaming;
  // Captured at goLive() time — Pedro's encoder dimensions are locked once
  // streaming begins, so we persist the chosen orientation for both
  // resume() and crash recovery.
  final bool isVertical;

  StreamSession({
    required this.broadcastId,
    required this.streamId,
    required this.rtmpUrl,
    required this.streamKey,
    required this.createdAt,
    required this.wasStreaming,
    required this.isVertical,
  });

  StreamSession copyWith({bool? wasStreaming, bool? isVertical}) =>
      StreamSession(
        broadcastId: broadcastId,
        streamId: streamId,
        rtmpUrl: rtmpUrl,
        streamKey: streamKey,
        createdAt: createdAt,
        wasStreaming: wasStreaming ?? this.wasStreaming,
        isVertical: isVertical ?? this.isVertical,
      );

  // A broadcast that's already gone live has a hard 12h cap on YouTube; an
  // upcoming broadcast also gets stale within a day. 11h keeps us safely
  // within both windows.
  bool get isFresh =>
      DateTime.now().difference(createdAt) < const Duration(hours: 11);

  Map<String, dynamic> _toJson() => {
        'broadcastId': broadcastId,
        'streamId': streamId,
        'rtmpUrl': rtmpUrl,
        'streamKey': streamKey,
        'createdAt': createdAt.toIso8601String(),
        'wasStreaming': wasStreaming,
        'isVertical': isVertical,
      };

  static StreamSession _fromJson(Map<String, dynamic> j) => StreamSession(
        broadcastId: j['broadcastId'] as String,
        streamId: j['streamId'] as String,
        rtmpUrl: j['rtmpUrl'] as String,
        streamKey: j['streamKey'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        wasStreaming: j['wasStreaming'] as bool? ?? false,
        isVertical: j['isVertical'] as bool? ?? true,
      );

  static const _prefsKey = 'stream_session_v1';

  static Future<StreamSession?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return null;
    try {
      return _fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await prefs.remove(_prefsKey);
      return null;
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_toJson()));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
