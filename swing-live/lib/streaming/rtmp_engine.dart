import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../framework/swing_camera.dart';

/// Time we'll wait for the native side to confirm the OpenGL surface is
/// bound. If we exceed this the user is on a phone/state where the surface
/// will never arrive — surface a clear error instead of hanging forever.
const _previewReadyTimeout = Duration(seconds: 6);

enum RtmpPhase { idle, initializing, ready, connecting, live, failed }

/// Quality presets aligned with YouTube Live's recommended bitrates for
/// landscape capture. Width/height are landscape — orientation is locked
/// app-wide at boot. Capped at 1080p60: phone HW encoders can't reliably
/// sustain >1080p over a long match without thermal throttling, dropped
/// frames, or the SoC giving up entirely.
enum StreamQuality {
  p720_30(1280, 720, 30, 3_000_000, '720p30'),
  p720_60(1280, 720, 60, 4_500_000, '720p60'),
  p1080_30(1920, 1080, 30, 6_000_000, '1080p30'),
  p1080_60(1920, 1080, 60, 9_000_000, '1080p60');

  const StreamQuality(
    this.width,
    this.height,
    this.fps,
    this.bitrate,
    this.label,
  );
  final int width;
  final int height;
  final int fps;
  final int bitrate;
  final String label;

  /// One step down the ladder. Used by the broken-pipe / reconnect logic
  /// to back off when the network can't keep up with the current preset.
  StreamQuality get oneStepDown {
    switch (this) {
      case StreamQuality.p1080_60: return StreamQuality.p1080_30;
      case StreamQuality.p1080_30: return StreamQuality.p720_60;
      case StreamQuality.p720_60:  return StreamQuality.p720_30;
      case StreamQuality.p720_30:  return StreamQuality.p720_30;
    }
  }
}

/// Owns the native camera + RTMP encoder. The phase reflects pedro's state.
/// Crash recovery: the engine itself is recreated on every app launch, but
/// it can be told to reconnect immediately with a cached URL+key.
class RtmpEngine extends ChangeNotifier {
  SwingCamera? _camera;
  StreamSubscription<CameraEvent>? _eventSub;

  RtmpPhase _phase = RtmpPhase.idle;
  String? _lastError;
  int _liveBitrate = 0;
  int _liveFps = 0;
  Timer? _connectTimer;

  // Surface-ready handshake. Reset on each initialize() so we wait for the
  // next native previewReady event before pushing RTMP.
  bool _previewReady = false;
  Completer<void>? _previewReadyCompleter;

  RtmpPhase get phase => _phase;
  String? get lastError => _lastError;
  int get liveBitrate => _liveBitrate;
  int get liveFps => _liveFps;
  SwingCamera? get camera => _camera;

  /// Acquire camera + mic perms and prepare the encoder. Hardcoded 1080p30 at
  /// 4.5 Mbps — fine for cricket, fits most uplinks.
  Future<bool> initialize({required bool isVertical}) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      _fail('Streaming only supported on Android/iOS.');
      return false;
    }
    _setPhase(RtmpPhase.initializing);

    final cam = await Permission.camera.request();
    final mic = await Permission.microphone.request();
    if (!cam.isGranted || !mic.isGranted) {
      _fail('Camera and microphone permissions are required.');
      return false;
    }

    // Drop any previous instance.
    await _disposeCameraOnly();

    // Reset the surface handshake — we'll wait for the next previewReady
    // event from native before allowing startStreaming through.
    _previewReady = false;
    _previewReadyCompleter = null;

    final c = SwingCamera();
    _camera = c;
    _eventSub = c.events.listen(_onEvent);

    try {
      await c.initialize(
        width: quality.width,
        height: quality.height,
        fps: quality.fps,
        bitrate: quality.bitrate,
        isVertical: isVertical,
      );
      await c.startPreview();
      _setPhase(RtmpPhase.ready);
      return true;
    } catch (e) {
      _fail('Hardware init failed: $e');
      return false;
    }
  }

  /// Currently-selected quality preset. Set via [setQuality] before
  /// [initialize] / [startStreaming]. Defaults to 1080p30 — phones
  /// overheat (and thermally throttle the encoder) on 1080p60 over a
  /// multi-hour match. 60fps preset is available in settings for short
  /// clips, but isn't the default any more.
  StreamQuality quality = StreamQuality.p1080_30;

  void setQuality(StreamQuality q) {
    quality = q;
    notifyListeners();
  }

  /// Push the quality parameters to native WITHOUT tearing down the camera.
  /// Used by adaptive degradation on reconnect: native MainActivity's
  /// `initialize` handler just stores the params; the next call to
  /// `startStreaming` re-runs `prepareVideo` with them.
  Future<void> applyQualityHotSwap(StreamQuality q) async {
    quality = q;
    final c = _camera;
    if (c == null) {
      notifyListeners();
      return;
    }
    await c.initialize(
      width: q.width,
      height: q.height,
      fps: q.fps,
      bitrate: q.bitrate,
      isVertical: false, // app is locked to landscape at boot
    );
    notifyListeners();
  }

  /// Block until the native OpenGl surface is bound (or timeout). Calling
  /// startStream before this fires causes pedro to throw "get surface".
  ///
  /// Belt-and-braces: we listen for the `previewReady` event (fast path) AND
  /// poll `isPreviewReady` via MethodChannel (race-proof fallback) — the
  /// event channel and method channel aren't FIFO with each other, so a
  /// pure-event approach can lose the first emit.
  Future<void> _awaitPreviewReady() async {
    final c = _camera;
    if (c == null) throw 'Camera not initialized';
    // Always verify with native at least once — the cached `_previewReady`
    // flag is set on the previewReady event, but on a background→foreground
    // cycle the OpenGL surface is destroyed and the flag goes stale. If we
    // trust the flag blindly we skip the wait and pedro then throws
    // "get surface" because the actual native surface isn't back yet.
    final deadline = DateTime.now().add(_previewReadyTimeout);
    while (DateTime.now().isBefore(deadline)) {
      try {
        if (await c.isPreviewReady()) {
          _previewReady = true;
          return;
        } else {
          // Native says no — clear the stale flag so subsequent calls
          // don't short-circuit either.
          _previewReady = false;
        }
      } catch (_) {
        // Method may not be implemented on older builds — fall back to
        // the cached event-driven flag.
        if (_previewReady) return;
      }
      await Future.delayed(const Duration(milliseconds: 150));
    }
    throw 'Preview surface never became ready — '
        'is the camera view visible on screen?';
  }

  Future<void> startStreaming(String rtmpUrl, String streamKey) async {
    final c = _camera;
    if (c == null) {
      _fail('Camera not initialized.');
      return;
    }
    var url = rtmpUrl.trim();
    final key = streamKey.trim();
    if (url.isEmpty || key.isEmpty) {
      _fail('Empty RTMP URL or stream key.');
      return;
    }
    if (url.startsWith('rtmps://')) {
      url = url.replaceFirst('rtmps://', 'rtmp://');
    }
    final fullUrl = url.endsWith('/') ? '$url$key' : '$url/$key';

    _setPhase(RtmpPhase.connecting);
    _lastError = null;
    try {
      await _awaitPreviewReady();
      await c.startStreaming(fullUrl);
      // Start a 30-second watchdog. If we don't go live within this window,
      // the RTMP handshake is stalled (YouTube refused, NAT timeout, etc.).
      _connectTimer?.cancel();
      _connectTimer = Timer(const Duration(seconds: 30), () {
        if (_phase == RtmpPhase.connecting) {
          _fail('Connection timed out. YouTube did not respond within 30s. '
              'Try ending the old stream and going live fresh.');
        }
      });
    } catch (e) {
      _fail('Start failed: $e');
    }
  }

  Future<void> stopStreaming() async {
    _connectTimer?.cancel();
    await _camera?.stopStreaming();
    _setPhase(RtmpPhase.ready);
  }

  Future<void> switchCamera() async => _camera?.switchCamera();

  bool _muted = false;
  bool get isMuted => _muted;

  Future<void> setMuted(bool muted) async {
    _muted = muted;
    await _camera?.setMuted(muted);
    notifyListeners();
  }

  /// Hand the camera back so another consumer (e.g. the camera plugin) can
  /// acquire it. The engine is left re-usable — call [initialize] again
  /// when streaming is needed.
  Future<void> releaseCamera() async {
    await _disposeCameraOnly();
    _setPhase(RtmpPhase.idle);
  }

  @override
  void dispose() {
    _disposeCameraOnly();
    super.dispose();
  }

  Future<void> _disposeCameraOnly() async {
    _connectTimer?.cancel();
    await _eventSub?.cancel();
    _eventSub = null;
    try {
      await _camera?.dispose();
    } catch (_) {}
    _camera = null;
  }

  void _onEvent(CameraEvent e) {
    switch (e.type) {
      case 'previewReady':
        _previewReady = true;
        if (_previewReadyCompleter != null &&
            !_previewReadyCompleter!.isCompleted) {
          _previewReadyCompleter!.complete();
        }
        break;
      case 'connected':
        _connectTimer?.cancel(); // RTMP handshake succeeded — disarm watchdog
        _lastError = null;
        _setPhase(RtmpPhase.live);
        // Overlay rendering is owned by NativeOverlayBridge (attached
        // from PremiumAOverlay). Pedro's filter is attached lazily on
        // first state push, so no explicit start hook needed here.
        break;
      case 'disconnected':
        if (_phase == RtmpPhase.live || _phase == RtmpPhase.connecting) {
          _setPhase(RtmpPhase.ready);
        }
        break;
      case 'connectionFailed':
        _fail(e.message ?? 'Connection failed');
        break;
      case 'error':
        _fail(e.message ?? 'Hardware error');
        break;
      case 'stats':
        _liveBitrate = e.bitrate ?? 0;
        _liveFps = e.fps ?? 0;
        notifyListeners();
        break;
    }
  }

  void _setPhase(RtmpPhase p) {
    _phase = p;
    notifyListeners();
  }

  void _fail(String reason) {
    debugPrint('[RTMP] $reason');
    _lastError = reason;
    _setPhase(RtmpPhase.failed);
  }
}
