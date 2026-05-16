import 'dart:async';
import 'package:flutter/services.dart';

/// Thin bridge to the Android MainActivity MethodChannel. Only exposes the
/// subset of methods MainActivity.kt actually implements — anything else
/// would return notImplemented at runtime.
class SwingCamera {
  static const MethodChannel _channel =
      MethodChannel('com.dhandha.swing/camera');
  static const EventChannel _eventChannel =
      EventChannel('com.dhandha.swing/camera/events');

  StreamSubscription? _eventSub;
  final _eventCtrl = StreamController<CameraEvent>.broadcast();

  Stream<CameraEvent> get events => _eventCtrl.stream;

  int? _instanceId;

  Future<void> initialize({
    required int width,
    required int height,
    required int fps,
    required int bitrate,
    required bool isVertical,
  }) async {
    // CRITICAL: subscribe to the event channel BEFORE invokeMethod fires.
    // Platform-channel messages are FIFO, so the native side processes our
    // `listen` registration before the `initialize` handler — meaning any
    // `previewReady` (or other) event emitted from inside `initialize` will
    // have a registered eventSink to send to.
    _eventSub ??= _eventChannel.receiveBroadcastStream().listen((raw) {
      final m = Map<String, dynamic>.from(raw as Map);
      _eventCtrl.add(CameraEvent.fromMap(m));
    });
    final res = await _channel.invokeMethod('initialize', {
      'width': width,
      'height': height,
      'fps': fps,
      'bitrate': bitrate,
      'isVertical': isVertical,
    });
    if (res is Map) {
      _instanceId = res['instanceId'] as int?;
    }
  }

  Future<void> startPreview() => _channel.invokeMethod('startPreview');

  Future<bool> isPreviewReady() async {
    final v = await _channel.invokeMethod<bool>('isPreviewReady');
    return v ?? false;
  }

  Future<void> startStreaming(String url) =>
      _channel.invokeMethod('startStreaming', {'url': url});

  Future<void> stopStreaming() => _channel.invokeMethod('stopStreaming');

  Future<void> switchCamera() => _channel.invokeMethod('switchCamera');

  Future<void> setBitrate(int bitrate) =>
      _channel.invokeMethod('setBitrate', {'bitrate': bitrate});

  /// Toggle audio on the encoder. When muted, Pedro's `disableAudio` stops
  /// pushing audio frames to RTMP — the YouTube stream goes silent until
  /// `setMuted(false)` re-enables it. Video keeps flowing either way.
  Future<void> setMuted(bool muted) =>
      _channel.invokeMethod('setMuted', {'isMuted': muted});

  /// Hard-resets Pedro's native RtmpCamera2 instance. The next platform-
  /// view mount will create a fresh one — required for pause/resume to
  /// behave like cold-start (which is the only path that works reliably).
  Future<void> resetCamera() => _channel.invokeMethod('resetCamera');

  /// Ship a PNG-encoded overlay snapshot to native. Pedro composites it
  /// on every encoded frame so YouTube viewers see the scorebar / event
  /// flashes. Pass `null` to remove the overlay filter.
  Future<void> setOverlayBitmap(Uint8List? bytes) =>
      _channel.invokeMethod('setOverlayBitmap', {'bytes': bytes});

  Future<void> dispose() async {
    await _eventSub?.cancel();
    _eventSub = null;
    await _eventCtrl.close();
    await _channel.invokeMethod('dispose', {'instanceId': _instanceId});
  }
}

class CameraEvent {
  final String type;
  final String? message;
  final int? bitrate;
  final int? fps;

  CameraEvent({required this.type, this.message, this.bitrate, this.fps});

  factory CameraEvent.fromMap(Map<String, dynamic> m) => CameraEvent(
        type: m['type'] as String,
        message: m['message'] as String?,
        bitrate: (m['bitrate'] as num?)?.toInt(),
        fps: (m['fps'] as num?)?.toInt(),
      );
}
