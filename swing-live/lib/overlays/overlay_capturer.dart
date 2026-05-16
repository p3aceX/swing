import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Snapshots the Premium-A overlay's [RepaintBoundary] subtree at a fixed
/// cadence, encodes it as PNG, and ships the bytes to Android's
/// MainActivity. Native composites the bitmap on top of every encoded
/// camera frame via Pedro's `ImageObjectFilterRender`, which is how the
/// overlay actually shows up on YouTube viewers' screens (instead of just
/// in the local Flutter widget tree).
///
/// Thermal note: this is a hot path. Phones throttle hard during long
/// matches. We keep the snapshot rate low (default 3fps — cricket score
/// state doesn't change faster than that anyway) and capture only the
/// boundary identified by [captureKey], not the whole tree.
class OverlayCapturer {
  OverlayCapturer._();
  static final OverlayCapturer instance = OverlayCapturer._();

  /// Attach this to the [RepaintBoundary] wrapping the overlay subtree.
  final GlobalKey captureKey = GlobalKey();

  static const MethodChannel _channel =
      MethodChannel('com.dhandha.swing/camera');

  Timer? _timer;
  bool _busy = false;
  bool _running = false;
  bool _loggedFirstSnap = false;
  int _lastSum = -1;

  /// Begin periodic capture. Idempotent — safe to call from a phase
  /// listener that fires repeatedly.
  void start({Duration interval = const Duration(seconds: 1)}) {
    if (_running) return;
    _running = true;
    debugPrint('[overlay-capturer] start (every ${interval.inMilliseconds}ms)');
    _timer = Timer.periodic(interval, (_) => _snap());
    // First frame immediately so the overlay appears the moment the
    // YouTube viewer's player connects, not 333ms later.
    Future.microtask(_snap);
  }

  Future<void> stop() async {
    _running = false;
    _loggedFirstSnap = false;
    _timer?.cancel();
    _timer = null;
    try {
      await _channel.invokeMethod('setOverlayBitmap', {'bytes': null});
    } catch (_) {
      // Channel may not be wired (older native build) — silently drop.
    }
  }

  Future<void> _snap() async {
    if (_busy || !_running) return;
    _busy = true;
    try {
      final ro = captureKey.currentContext?.findRenderObject();
      if (ro is! RenderRepaintBoundary) return;
      if (ro.debugNeedsPaint) {
        // Boundary hasn't painted yet — skip this tick, try again next.
        return;
      }
      final size = ro.size;
      if (size.isEmpty) return;

      // Lower target resolution for thermal management (720 instead of 1080)
      final pixelRatio = (720.0 / size.height).clamp(1.0, 3.0);
      final image = await ro.toImage(pixelRatio: pixelRatio);
      // Use raw RGBA to avoid expensive PNG encoding
      final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final width = image.width;
      final height = image.height;
      image.dispose();
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      
      // "Next Level" Speed: XOR sparse hashing to skip redundant updates
      int sum = 0;
      for (int i = 0; i < bytes.length; i += 128) {
        sum ^= bytes[i]; 
      }
      if (_lastSum == sum) return; 
      _lastSum = sum;

      await _channel.invokeMethod('setOverlayBitmap', {
        'bytes': bytes,
        'width': width,
        'height': height,
      });
      // First-snap heartbeat so it's obvious in logs whether the channel
      // is reachable at all. Subsequent ticks stay quiet.
      if (!_loggedFirstSnap) {
        _loggedFirstSnap = true;
        debugPrint(
            '[overlay-capturer] first snap ok (${bytes.length} bytes, ${width}x${height})');
      }
    } catch (e) {
      debugPrint('[overlay-capturer] snap failed: $e');
    } finally {
      _busy = false;
    }
  }
}
