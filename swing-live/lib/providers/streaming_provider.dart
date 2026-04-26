import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thermal/thermal.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../services/rtmp_service.dart';
import '../services/youtube_service.dart';
import '../models/streaming_quality.dart';
import '../framework/swing_camera.dart';

class StreamingProvider extends ChangeNotifier with WidgetsBindingObserver {
  final RTMPService _rtmpService = RTMPService();
  final YouTubeService _youtubeService = YouTubeService();
  final Thermal _thermal = Thermal();
  final Connectivity _connectivity = Connectivity();

  bool _isStreaming = false;
  bool _isFrontCamera = true;
  bool _isEcoMode = false;
  bool _isThrottled = false;
  bool _isVertical = true;
  bool _isMuted = false;
  bool _isBatterySaverActive = false;
  bool _isConnectingSocial = false;
  bool _isManualMode = true; // Default to manual for immediate usability
  bool _hardwareStarted = false;
  bool _isPaused = false;
  
  String _rtmpUrl = "";
  String _streamKey = "";
  String _socialAccountName = "";
  String _errorMessage = "";
  StreamingQuality _quality = StreamingQuality.high1080p30;
  ThermalStatus _thermalStatus = ThermalStatus.none;

  // Stats
  DateTime? _streamStartTime;
  Duration _streamDuration = Duration.zero;
  double _totalDataSentMB = 0.0;
  Timer? _statsTimer;

  bool get isStreaming => _isStreaming;
  bool get isPaused => _isPaused;
  bool get isFrontCamera => _isFrontCamera;
  bool get isEcoMode => _isEcoMode;
  bool get isThrottled => _isThrottled;
  bool get isVertical => _isVertical;
  bool get isMuted => _isMuted;
  bool get isBatterySaverActive => _isBatterySaverActive;
  bool get isConnectingSocial => _isConnectingSocial;
  bool get isManualMode => _isManualMode;
  StreamingQuality get quality => _quality;
  ThermalStatus get thermalStatus => _thermalStatus;
  Duration get streamDuration => _streamDuration;
  double get totalDataSentMB => _totalDataSentMB;
  String get socialAccountName => _socialAccountName;
  String get errorMessage => _errorMessage;
  SwingCamera? get controller => _rtmpService.controller;

  Future<void> initProvider() async {
    WidgetsBinding.instance.addObserver(this);
    await _loadSavedConfig();
    _thermal.onThermalStatusChanged.listen(_handleThermalChange);
    _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
    _errorMessage = "";
    notifyListeners();

    // If YouTube was connected in a previous session and credentials are cached,
    // restore the API client silently — no OAuth dialog, no API calls.
    if (_socialAccountName.isNotEmpty && _rtmpUrl.isNotEmpty) {
      _youtubeService.signInSilently();
    }
  }

  void setManualMode(bool manual) {
    _isManualMode = manual;
    _saveConfig();
    notifyListeners();
  }

  void setOrientation(bool isVertical) {
    if (_isVertical != isVertical) {
      debugPrint("[PROVIDER_DEBUG] Orientation changed: ${isVertical ? 'Vertical' : 'Horizontal'}");
      _isVertical = isVertical;
      if (_isStreaming || controller != null) {
        _applyConfig();
      }
      notifyListeners();
    }
  }

  Future<void> startHardware() async {
    if (_hardwareStarted) return;
    _hardwareStarted = true;
    debugPrint("[PROVIDER_DEBUG] startHardware() called");
    _errorMessage = "";
    notifyListeners();

    await _rtmpService.init(
      _quality,
      _isVertical,
      () {
        debugPrint("[PROVIDER_DEBUG] onControllerCreated triggered");
        notifyListeners();
      },
      () {
        debugPrint("[PROVIDER_DEBUG] Connection SUCCESS callback");
        _isStreaming = true;
        _startStreamingSession();
        notifyListeners();
      },
      (error) {
        debugPrint("[PROVIDER_DEBUG] ERROR callback: $error");
        _errorMessage = error;
        _isStreaming = false;
        _stopStreamingSession();
        notifyListeners();
      },
    );
  }

  Future<void> connectYouTube() async {
    _isConnectingSocial = true;
    notifyListeners();
    try {
      final account = await _youtubeService.signIn();
      if (account != null) {
        _socialAccountName = account.displayName ?? account.email;
        _isManualMode = false;

        // Only fetch credentials when we don't already have a cached stream.
        // The RTMP URL and stream key for a liveStream are permanent — reusing
        // them avoids 3–4 API calls on every connect and protects quota.
        if (_rtmpUrl.isEmpty || _streamKey.isEmpty) {
          final credentials = await _youtubeService.getLiveStreamCredentials();
          if (credentials != null) {
            _rtmpUrl = credentials['url']!;
            _streamKey = credentials['key']!;
          }
        }
        await _saveConfig();
      }
    } catch (e) {
      debugPrint("YouTube Sign-In failed: $e");
    } finally {
      _isConnectingSocial = false;
      notifyListeners();
    }
  }

  // Force-fetches a new broadcast and stream — use when the previous broadcast
  // has ended or the user explicitly wants a fresh stream.
  Future<void> refreshYouTubeStream() async {
    _isConnectingSocial = true;
    notifyListeners();
    try {
      final credentials = await _youtubeService.getLiveStreamCredentials();
      if (credentials != null) {
        _rtmpUrl = credentials['url']!;
        _streamKey = credentials['key']!;
        await _saveConfig();
      }
    } catch (e) {
      debugPrint("YouTube stream refresh failed: $e");
    } finally {
      _isConnectingSocial = false;
      notifyListeners();
    }
  }

  Future<void> disconnectYouTube() async {
    await _youtubeService.signOut();
    _socialAccountName = "";
    _isManualMode = true;
    notifyListeners();
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none) && _isStreaming) {
      stop();
    }
  }

  Future<void> toggleCamera() async {
    HapticFeedback.lightImpact();
    await _rtmpService.switchCamera();
    _isFrontCamera = !_isFrontCamera;
    notifyListeners();
  }

  Future<void> setZoom(double ratio) async {
    await _rtmpService.setZoomRatio(ratio);
  }

  Future<void> toggleMute() async {
    HapticFeedback.selectionClick();
    _isMuted = !_isMuted;
    await _rtmpService.setMuted(_isMuted);
    notifyListeners();
  }

  Future<void> toggleBatterySaver() async {
    _isBatterySaverActive = !_isBatterySaverActive;
    await _rtmpService.setBatteryShield(_isBatterySaverActive);
    notifyListeners();
  }

  void _handleThermalChange(ThermalStatus status) {
    _thermalStatus = status;
    bool shouldThrottle = (status == ThermalStatus.severe || status == ThermalStatus.critical);
    if (shouldThrottle != _isThrottled) {
      _isThrottled = shouldThrottle;
      _applyConfig();
    }
    notifyListeners();
  }

  Future<void> _applyConfig() async {
    final activeQuality = _isThrottled || _isEcoMode ? StreamingQuality.standard720p30 : _quality;
    await _rtmpService.applyQuality(activeQuality, _isVertical);
  }

  Future<void> setEcoMode(bool value) async {
    _isEcoMode = value;
    await _applyConfig();
    notifyListeners();
  }

  Future<void> setQuality(StreamingQuality quality) async {
    _quality = quality;
    await _applyConfig();
    _saveConfig();
    notifyListeners();
  }

  void setConfig(String url, String key) {
    _rtmpUrl = url;
    _streamKey = key;
    _saveConfig();
  }

  String get rtmpUrl => _rtmpUrl;
  String get streamKey => _streamKey;

  Future<void> start() async {
    debugPrint("[PROVIDER_DEBUG] start() requested with URL: $_rtmpUrl");
    if (_rtmpUrl.isEmpty || _streamKey.isEmpty) {
      debugPrint("[PROVIDER_DEBUG] start() aborted: URL or Key is empty");
      return;
    }
    HapticFeedback.heavyImpact();
    try {
      await _rtmpService.startStreaming(_rtmpUrl, _streamKey);
    } catch (e) {
      debugPrint("[PROVIDER_DEBUG] start() THREW: $e");
    }
  }

  Future<void> pauseStream() async {
    if (!_isStreaming || _isPaused) return;
    HapticFeedback.mediumImpact();
    _isPaused = true;
    await _rtmpService.pauseStream();
    notifyListeners();
  }

  Future<void> resumeStream() async {
    if (!_isStreaming || !_isPaused) return;
    HapticFeedback.mediumImpact();
    _isPaused = false;
    await _rtmpService.resumeStream();
    notifyListeners();
  }

  Future<void> stop() async {
    HapticFeedback.heavyImpact();
    _isPaused = false;
    _stopStreamingSession();
    await _rtmpService.stopStreaming();
    _isStreaming = false;
    _isBatterySaverActive = false;
    notifyListeners();
  }

  void _startStreamingSession() {
    _streamStartTime = DateTime.now();
    _statsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isStreaming && _streamStartTime != null) {
        _streamDuration = DateTime.now().difference(_streamStartTime!);
        final currentBitrate = _isThrottled || _isEcoMode ? 2500000 : _quality.bitrate;
        _totalDataSentMB += (currentBitrate / 8) / (1024 * 1024);
        notifyListeners();
      }
    });
  }

  void _stopStreamingSession() {
    _statsTimer?.cancel();
  }

  Future<void> _loadSavedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    _rtmpUrl = prefs.getString('rtmp_url') ?? "";
    _streamKey = prefs.getString('stream_key') ?? "";
    _socialAccountName = prefs.getString('social_account_name') ?? "";
    // Restore mode: if YouTube was connected, default back to YouTube mode
    _isManualMode = prefs.getBool('is_manual_mode') ?? _socialAccountName.isEmpty;
    final qIndex = prefs.getInt('quality_index');
    if (qIndex != null && qIndex < StreamingQuality.values.length) {
      _quality = StreamingQuality.values[qIndex];
    }
    notifyListeners();
  }

  Future<void> _saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rtmp_url', _rtmpUrl);
    await prefs.setString('stream_key', _streamKey);
    await prefs.setString('social_account_name', _socialAccountName);
    await prefs.setBool('is_manual_mode', _isManualMode);
    await prefs.setInt('quality_index', StreamingQuality.values.indexOf(_quality));
  }

  Future<void> fullShutdown() async {
    _hardwareStarted = false;
    _stopStreamingSession();
    await _rtmpService.dispose();
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    fullShutdown();
    super.dispose();
  }
}
