import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../models/streaming_quality.dart';
import '../framework/swing_camera.dart';

class RTMPService {
  SwingCamera? _controller;
  
  SwingCamera? get controller => _controller;

  Future<void> init(
    StreamingQuality quality,
    bool isVertical,
    Function() onControllerCreated,
    Function() onConnectionSuccess,
    Function(String) onConnectionFailed,
  ) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      onConnectionFailed("Video streaming is only supported on Android and iOS devices.");
      return;
    }

    final camStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    debugPrint("[CAMERA_DEBUG] Camera Permission: ${camStatus.name}");
    debugPrint("[CAMERA_DEBUG] Mic Permission: ${micStatus.name}");

    if (!camStatus.isGranted || !micStatus.isGranted) {
      onConnectionFailed("Permissions denied. Please allow camera and mic access in settings.");
      return;
    }

    try {
      if (_controller != null) {
        await dispose();
      }

      _controller = SwingCamera(
        onInitialized: () {
          debugPrint("[CAMERA_DEBUG] Controller initialized, UI notified");
          onControllerCreated();
        },
        onError: (error) {
          debugPrint("[CAMERA_DEBUG] FATAL ERROR: $error");
          onConnectionFailed("Hardware error: $error");
        },
        onConnectionSuccess: () {
          debugPrint("[STREAM_DEBUG] Connection SUCCESS callback triggered");
          onConnectionSuccess();
        },
        onConnectionFailed: (error) {
          debugPrint("[STREAM_DEBUG] Connection FAILED callback: $error");
          onConnectionFailed(error);
        },
        onConnectionDisconnect: () {
          debugPrint("[STREAM_DEBUG] Connection DISCONNECTED callback");
        },
      );

      await _controller!.initialize(
        width: quality.width,
        height: quality.height,
        fps: quality.fps,
        bitrate: quality.bitrate,
        isVertical: isVertical,
      );

      debugPrint("[CAMERA_DEBUG] Controller initialized. Starting preview...");
      await _controller!.startPreview();
      debugPrint("[CAMERA_DEBUG] startPreview() called successfully");
    } catch (e, stack) {
      debugPrint("[CAMERA_DEBUG] FATAL ERROR during init: $e");
      debugPrint("[CAMERA_DEBUG] Stacktrace: $stack");
      onConnectionFailed("Hardware error: $e");
    }
  }

  Future<void> applyQuality(StreamingQuality quality, bool isVertical) async {
    if (_controller == null) return;
    // For now, SwingCamera handles orientation switching internally if needed.
    // To support dynamic quality changes during preview, we'd add an updateConfig method.
  }

  Future<void> startStreaming(String url, String streamKey) async {
    if (_controller == null) {
      debugPrint("[STREAM_DEBUG] Cannot start: Controller is NULL");
      return;
    }
    
    final cleanUrl = url.trim();
    final cleanKey = streamKey.trim();

    if (cleanUrl.isEmpty || cleanKey.isEmpty) {
      debugPrint("[STREAM_DEBUG] ERROR: URL or Key is empty. URL: '$cleanUrl', Key length: ${cleanKey.length}");
      return;
    }

    if (!cleanUrl.startsWith("rtmp://") && !cleanUrl.startsWith("rtmps://")) {
      debugPrint("[STREAM_DEBUG] ERROR: Invalid RTMP URL protocol. Must start with rtmp:// or rtmps://");
      return;
    }

    debugPrint("[STREAM_DEBUG] Attempting to start stream...");
    final fullUrl = cleanUrl.endsWith('/') ? '$cleanUrl$cleanKey' : '$cleanUrl/$cleanKey';
    debugPrint("[STREAM_DEBUG] Final URL generated");

    try {
      await _controller!.startStreaming(fullUrl);
      debugPrint("[STREAM_DEBUG] startStreaming() method call finished without throwing");
    } catch (e, stack) {
      debugPrint("[STREAM_DEBUG] startStreaming() THREW ERROR: $e");
      debugPrint("[STREAM_DEBUG] Stack: $stack");
    }
  }

  Future<void> stopStreaming() async {
    if (_controller != null) {
      await _controller!.stopStreaming();
    }
  }

  Future<void> pauseStream() async {
    if (_controller != null) {
      await _controller!.pauseStream();
    }
  }

  Future<void> resumeStream() async {
    if (_controller != null) {
      await _controller!.resumeStream();
    }
  }

  Future<void> setMuted(bool muted) async {
    if (_controller != null) {
      await _controller!.setMuted(muted);
    }
  }

  Future<void> switchCamera() async {
    if (_controller != null) {
      await _controller!.switchCamera();
    }
  }

  Future<void> setZoomRatio(double ratio) async {
    if (_controller != null) {
      await _controller!.setZoomRatio(ratio);
    }
  }

  Future<void> setOrientation(bool isVertical) async {
    if (_controller != null) {
      await _controller!.setOrientation(isVertical);
    }
  }

  Future<void> setBatteryShield(bool enabled) async {
    if (_controller != null) {
      await _controller!.setBatteryShield(enabled);
    }
  }

  Future<void> stopPreview() async {
    if (_controller != null) {
      try {
        await _controller!.stopPreview();
      } catch (e) {
        // Suppress
      }
    }
  }

  Future<void> dispose() async {
    if (_controller != null) {
      try {
        await _controller!.stopStreaming();
        await _controller!.stopPreview();
        await _controller!.dispose();
      } catch (e) {
        // Suppress
      }
      _controller = null;
    }
  }
}
