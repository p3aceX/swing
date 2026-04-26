import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SwingCamera {
  static const MethodChannel _channel = MethodChannel('com.dhandha.swing/camera');
  static const EventChannel _eventChannel = EventChannel('com.dhandha.swing/camera/events');

  StreamSubscription? _eventSubscription;
  final VoidCallback onInitialized;
  final Function(String) onError;
  final VoidCallback onConnectionSuccess;
  final VoidCallback onConnectionDisconnect;
  final Function(String) onConnectionFailed;

  SwingCamera({
    required this.onInitialized,
    required this.onError,
    required this.onConnectionSuccess,
    required this.onConnectionDisconnect,
    required this.onConnectionFailed,
  });

  Future<void> initialize({
    required int width,
    required int height,
    required int fps,
    required int bitrate,
    required bool isVertical,
  }) async {
    try {
      final dynamic result = await _channel.invokeMethod('initialize', {
        'width': width,
        'height': height,
        'fps': fps,
        'bitrate': bitrate,
        'isVertical': isVertical,
      });

      _eventSubscription = _eventChannel.receiveBroadcastStream().listen((event) {
        final Map<String, dynamic> eventMap = Map<String, dynamic>.from(event);
        final String type = eventMap['type'];

        switch (type) {
          case 'connected':
            onConnectionSuccess();
            break;
          case 'disconnected':
            onConnectionDisconnect();
            break;
          case 'connectionFailed':
            onConnectionFailed(eventMap['message'] ?? 'Connection failed');
            break;
          case 'error':
            onError(eventMap['message'] ?? 'Unknown error');
            break;
        }
      });

      onInitialized();
    } catch (e) {
      onError('Failed to initialize camera: $e');
    }
  }

  Future<void> startPreview() async {
    await _channel.invokeMethod('startPreview');
  }

  Future<void> stopPreview() async {
    await _channel.invokeMethod('stopPreview');
  }

  Future<void> startStreaming(String url) async {
    await _channel.invokeMethod('startStreaming', {'url': url});
  }

  Future<void> stopStreaming() async {
    await _channel.invokeMethod('stopStreaming');
  }

  Future<void> pauseStream() async {
    await _channel.invokeMethod('pauseStream');
  }

  Future<void> resumeStream() async {
    await _channel.invokeMethod('resumeStream');
  }

  Future<void> setZoomRatio(double ratio) async {
    await _channel.invokeMethod('setZoomRatio', {'ratio': ratio});
  }

  Future<void> setOrientation(bool isVertical) async {
    await _channel.invokeMethod('setOrientation', {'isVertical': isVertical});
  }

  Future<void> switchCamera() async {
    await _channel.invokeMethod('switchCamera');
  }

  Future<void> setMuted(bool isMuted) async {
    await _channel.invokeMethod('setMuted', {'isMuted': isMuted});
  }

  Future<void> setBatteryShield(bool enabled) async {
    await _channel.invokeMethod('setBatteryShield', {'enabled': enabled});
  }

  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    await _channel.invokeMethod('dispose');
  }
}
