import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thermal/thermal.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:speed_test_dart/speed_test_dart.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import '../services/rtmp_service.dart';
import '../services/youtube_service.dart';
import '../models/streaming_quality.dart';
import '../framework/swing_camera.dart';
import '../overlays/api/overlay_api_client.dart';
import '../overlays/models/overlay_models.dart';
import '../overlays/packs/overlay_pack.dart';

class StreamingProvider extends ChangeNotifier with WidgetsBindingObserver {
  final RTMPService _rtmpService = RTMPService();
  final YouTubeService _youtubeService = YouTubeService();
  final OverlayApiClient _overlayApi = OverlayApiClient();
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
  bool _isManualMode = true;
  bool _hardwareStarted = false;
  bool _isPaused = false;
  bool _isResuming = false;
  bool _isCameraReady = false;
  String? _activeBroadcastId;
  
  String _rtmpUrl = "";
  String _streamKey = "";
  String _socialAccountName = "";
  String _errorMessage = "";
  StreamingQuality _quality = StreamingQuality.auto;
  ThermalStatus _thermalStatus = ThermalStatus.none;

  // Overlay feed state — populated by validateAndConnectMatch()
  String? _liveCode;
  String? _savedPin;
  OverlayBootstrap? _bootstrap;
  OverlayTick? _tick;
  StreamSubscription<OverlayTick>? _tickSub;
  final StreamController<OverlayEffect> _effectsCtrl =
      StreamController<OverlayEffect>.broadcast();

  double _networkStrength = 1.0;
  int _currentBitrate = 0;
  double _cpuTemp = 0.0;
  bool _isAutoThrottling = false;
  int _reconnectCount = 0;
  static const int maxReconnects = 5;

  double _deviceRotation = 0; // 0, pi/2, etc
  bool _isLandscape = false;

  DateTime? _streamStartTime;
  Duration _streamDuration = Duration.zero;
  double _totalDataSentMB = 0.0;
  Timer? _statsTimer;
  Timer? _smartMonitorTimer;

  // Getters
  bool get isStreaming => _isStreaming;
  bool get isPaused => _isPaused;
  bool get isResuming => _isResuming;
  bool get isCameraReady => _isCameraReady;
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
  double get networkStrength => _networkStrength;
  int get currentBitrate => _currentBitrate;
  bool get isAutoThrottling => _isAutoThrottling;
  double get deviceRotation => _deviceRotation;
  bool get isLandscape => _isLandscape;
  SwingCamera? get controller => _rtmpService.controller;
  String get rtmpUrl => _rtmpUrl;
  String get streamKey => _streamKey;

  // Overlay feed getters — consumed by overlay packs.
  OverlayBootstrap? get bootstrap => _bootstrap;
  OverlayTick? get tick => _tick;
  Stream<OverlayEffect> get overlayEffects => _effectsCtrl.stream;
  String? get liveCode => _liveCode;
  String? get savedPin => _savedPin;
  bool get hasMatchConnected => _bootstrap != null;

  // Overlay orientation override — null means follow device.
  bool? _overlayLandscapeOverride;
  bool? get overlayLandscapeOverride => _overlayLandscapeOverride;

  /// Effective orientation the overlay should render in.
  /// Honors the manual override when set; otherwise tracks device orientation.
  bool get overlayIsLandscape =>
      _overlayLandscapeOverride ?? _isLandscape;

  /// Cycles AUTO → PORTRAIT → LANDSCAPE → AUTO.
  void cycleOverlayOrientation() {
    if (_overlayLandscapeOverride == null) {
      _overlayLandscapeOverride = false; // forced portrait
    } else if (_overlayLandscapeOverride == false) {
      _overlayLandscapeOverride = true; // forced landscape
    } else {
      _overlayLandscapeOverride = null; // back to auto
    }
    notifyListeners();
  }

  // Methods
  void _startSmartMonitor() {
    _smartMonitorTimer?.cancel();
    _smartMonitorTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!_isStreaming) return;
      if (_networkStrength < 0.5 && !_isAutoThrottling) {
        _isAutoThrottling = true;
        await _rtmpService.applyQuality(StreamingQuality.standard720p30, _isVertical);
        notifyListeners();
      } else if (_networkStrength > 0.8 && _isAutoThrottling) {
        _isAutoThrottling = false;
        await _applyConfig();
        notifyListeners();
      }
      if (_thermalStatus == ThermalStatus.severe || _thermalStatus == ThermalStatus.critical) {
         if (!_isEcoMode) setEcoMode(true);
      }
    });
  }

  void _stopSmartMonitor() {
    _smartMonitorTimer?.cancel();
  }

  /// Validate the match credentials, fetch the bootstrap, and start the SSE
  /// tick stream. Call this from SetupPage when the user submits the
  /// liveCode + PIN. Returns null on success, or an error message string.
  Future<String?> validateAndConnectMatch({
    required String liveCode,
    required String pin,
  }) async {
    debugPrint(
        '[OverlayDebug] validateAndConnectMatch start  liveCode="$liveCode" pinLen=${pin.length}');
    try {
      await disconnectMatch();
      final v = await _overlayApi.validateMatch(liveCode: liveCode, pin: pin);
      _liveCode = liveCode;
      _savedPin = pin;
      _saveConfig();

      debugPrint(
          '[OverlayDebug] fetching bootstrap for matchDbId=${v.matchDbId}');
      _bootstrap = await _overlayApi.fetchBootstrap(
        matchId: v.matchDbId,
        overlayToken: v.overlayToken,
      );

      debugPrint('[OverlayDebug] subscribing to tick stream');
      _tickSub = _overlayApi
          .tickStream(matchId: v.matchDbId, overlayToken: v.overlayToken)
          .listen(_onTick);

      debugPrint('[OverlayDebug] validateAndConnectMatch ok ✓');
      notifyListeners();
      return null;
    } on OverlayApiException catch (e) {
      debugPrint(
          '[OverlayDebug] validateAndConnectMatch FAILED: ${e.code} (HTTP ${e.statusCode}): ${e.message}');
      return '${e.code}: ${e.message}';
    } catch (e, st) {
      debugPrint(
          '[OverlayDebug] validateAndConnectMatch unexpected error: $e\n$st');
      return 'Could not connect: $e';
    }
  }

  Future<void> disconnectMatch() async {
    await _tickSub?.cancel();
    _tickSub = null;
    _bootstrap = null;
    _tick = null;
    _liveCode = null;
    notifyListeners();
  }

  void _onTick(OverlayTick t) {
    final prev = _tick;
    _tick = t;
    _detectEffects(prev, t);
    notifyListeners();
  }

  // Compare consecutive ticks to fire one-shot animated effects.
  // Mirrors lib/overlays/overlay_view.dart:_detectEffects so behavior is
  // identical whether the orchestration lives here or in OverlayView.
  void _detectEffects(OverlayTick? prev, OverlayTick now) {
    final newest = now.lastBalls.isNotEmpty ? now.lastBalls.last : null;
    final prevNewest =
        prev?.lastBalls.isNotEmpty == true ? prev!.lastBalls.last : null;
    if (newest == null) return;
    if (prevNewest != null && prevNewest.id == newest.id) return;

    if (newest.isWicket) {
      final prevStrikerRuns =
          prev?.current?.striker?.playerId == newest.batterId
              ? prev?.current?.striker?.runs
              : prev?.current?.nonStriker?.playerId == newest.batterId
                  ? prev?.current?.nonStriker?.runs
                  : null;
      final isDuck = (prevStrikerRuns == 0) && newest.runs == 0;
      final fx = isDuck ? OverlayEffect.duck : OverlayEffect.wicket;
      debugPrint(
          '[OverlayDebug] effect=$fx · ball over=${newest.overNumber}.${newest.ballNumber} runs=${newest.runs} dismissal=${newest.dismissalType}');
      _effectsCtrl.add(fx);
      return;
    }
    if (newest.runs == 6) {
      debugPrint(
          '[OverlayDebug] effect=six · ball over=${newest.overNumber}.${newest.ballNumber}');
      _effectsCtrl.add(OverlayEffect.six);
    } else if (newest.runs == 4) {
      debugPrint(
          '[OverlayDebug] effect=four · ball over=${newest.overNumber}.${newest.ballNumber}');
      _effectsCtrl.add(OverlayEffect.four);
    }
  }

  Future<void> estimateBandwidth() async {
    _networkStrength = 0.5;
    notifyListeners();
    try {
      final socket = await Socket.connect('8.8.8.8', 53, timeout: const Duration(seconds: 2));
      await socket.close();
      _networkStrength = 0.9;
      if (_quality == StreamingQuality.auto) _quality = StreamingQuality.ultra1080p60;
    } catch (e) {
      _networkStrength = 0.4;
      if (_quality == StreamingQuality.auto) _quality = StreamingQuality.high1080p30;
    }
    notifyListeners();
  }

  Future<void> initProvider() async {
    WidgetsBinding.instance.addObserver(this);
    await _loadSavedConfig();
    _thermal.onThermalStatusChanged.listen(_handleThermalChange);
    _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
    _rtmpService.onEvent.listen(_handleConnectionEvent);
    
    // Professional Orientation Engine — uses accelerometer (useSensor: true)
    // because Flutter is locked to portraitUp, so the OS-orientation source
    // would never emit landscape events.
    NativeDeviceOrientationCommunicator()
        .onOrientationChanged(useSensor: true)
        .listen((event) {
      debugPrint('[OverlayDebug] orientation event: $event');
      bool isNowLandscape = false;
      double rotation = 0;

      switch (event) {
        case NativeDeviceOrientation.landscapeLeft:
          isNowLandscape = true;
          rotation = -3.14159 / 2; // -90 deg
          break;
        case NativeDeviceOrientation.landscapeRight:
          isNowLandscape = true;
          rotation = 3.14159 / 2; // 90 deg
          break;
        case NativeDeviceOrientation.portraitDown:
          rotation = 3.14159; // 180 deg
          break;
        default:
          rotation = 0;
          break;
      }

      if (_deviceRotation != rotation || _isLandscape != isNowLandscape) {
        _deviceRotation = rotation;
        _isLandscape = isNowLandscape;
        _isVertical = !isNowLandscape;
        debugPrint(
            '[OverlayDebug] rotation updated → isLandscape=$isNowLandscape  rotation=${rotation.toStringAsFixed(2)} rad');
        // Sync native encoder without restarting preview
        _rtmpService.setOrientation(_isVertical);
        notifyListeners();
      }
    });
    
    // Try to resume an active YouTube broadcast on every app start. The old
    // gate required `_rtmpUrl.isNotEmpty`, but `_checkActiveBroadcast` is
    // exactly what populates `_rtmpUrl` — so it could never run.
    if (_socialAccountName.isNotEmpty) {
      _youtubeService.signInSilently().then((account) {
        if (account != null) _checkActiveBroadcast();
      });
      estimateBandwidth();
    }
  }

  Future<void> _checkActiveBroadcast() async {
    final credentials = await _youtubeService.getLiveStreamCredentials();
    if (credentials != null) {
      _rtmpUrl = credentials['url']!;
      _streamKey = credentials['key']!;
      _activeBroadcastId = _youtubeService.currentBroadcastId;
      _isResuming = true;
      notifyListeners();
    }
  }

  Future<void> startHardware() async {
    if (_hardwareStarted) return;
    _hardwareStarted = true;
    _isCameraReady = false;
    await _rtmpService.init(_quality, _isVertical, () {
      _isCameraReady = true;
      notifyListeners();
    }, () {
      _isStreaming = true;
      _startStreamingSession();
      notifyListeners();
    }, (error) {
      _errorMessage = error;
      _isStreaming = false;
      _stopStreamingSession();
      notifyListeners();
    });
  }

  /// Re-arms the camera preview surface after the activity returns from
  /// background. PreflightPage calls this on AppLifecycleState.resumed.
  Future<void> ensurePreviewAlive() async {
    if (!_hardwareStarted) {
      await startHardware();
      return;
    }
    await _rtmpService.restartPreview();
  }

  Future<void> start() async {
    _errorMessage = "";
    if (_rtmpUrl.isEmpty || _streamKey.isEmpty) {
      debugPrint("[STREAM_DEBUG] start() - No credentials, attempting to fetch...");
      await _checkActiveBroadcast();
    }
    
    if (_rtmpUrl.isEmpty || _streamKey.isEmpty) {
      _errorMessage = _socialAccountName.isEmpty
          ? 'No streaming destination — connect YouTube first.'
          : 'No active broadcast found. Create one in YouTube Studio, then retry.';
      notifyListeners();
      return;
    }
    HapticFeedback.heavyImpact();
    try {
      await _rtmpService.startStreaming(_rtmpUrl, _streamKey);
      _startSmartMonitor();
    } catch (e) {
      _errorMessage = 'Start failed: $e';
      notifyListeners();
      debugPrint("Start error: $e");
    }
  }

  Future<void> stop() async {
    HapticFeedback.heavyImpact();
    _isPaused = false;
    _stopStreamingSession();
    _stopSmartMonitor();
    await _rtmpService.stopStreaming();
    _isStreaming = false;
    _isBatterySaverActive = false;
    notifyListeners();
  }

  Future<void> pause() async {
    if (!_isStreaming) return;
    await _rtmpService.stopStreaming(); // Pedro handles "pause" by stopping the stream
    _isPaused = true;
    _isStreaming = false;
    _stopSmartMonitor();
    notifyListeners();
  }

  Future<void> resume() async {
    if (!_isPaused) return;
    await start();
    _isPaused = false;
    notifyListeners();
  }

  void _handleConnectionEvent(Map<String, dynamic> event) {
    final type = event['type'] as String;
    switch (type) {
      case 'connected':
        _isStreaming = true;
        _isResuming = false;
        _reconnectCount = 0;
        break;
      case 'disconnected':
        _isStreaming = false;
        // Don't auto-reconnect on deliberate disconnect
        break;
      case 'connectionFailed':
        _isStreaming = false;
        if (_reconnectCount < maxReconnects) {
          _reconnectCount++;
          debugPrint("[STREAM_DEBUG] Reconnect attempt $_reconnectCount/$maxReconnects...");
          Future.delayed(const Duration(seconds: 3), () => start());
        }
        break;
    }
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

  // Other control methods
  Future<void> setZoom(double ratio) async => await _rtmpService.setZoomRatio(ratio);
  Future<void> setMuted(bool value) async {
    _isMuted = value;
    await _rtmpService.setMuted(_isMuted);
    notifyListeners();
  }
  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    await _rtmpService.setMuted(_isMuted);
    notifyListeners();
  }
  Future<void> toggleCamera() async {
    await _rtmpService.switchCamera();
    _isFrontCamera = !_isFrontCamera;
    notifyListeners();
  }
  void setOrientation(bool isVertical) {
    _isVertical = isVertical;
    if (_isStreaming || controller != null) _applyConfig();
    notifyListeners();
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
  Future<void> _applyConfig() async {
    final activeQuality = _isThrottled || _isEcoMode ? StreamingQuality.standard720p30 : _quality;
    await _rtmpService.applyQuality(activeQuality, _isVertical);
  }

  // Account methods
  Future<void> connectYouTube() async {
    _isConnectingSocial = true;
    notifyListeners();
    try {
      final account = await _youtubeService.signIn();
      if (account != null) {
        _socialAccountName = account.displayName ?? account.email;
        _isManualMode = false;
        estimateBandwidth();
        if (_rtmpUrl.isEmpty || _streamKey.isEmpty) {
          final credentials = await _youtubeService.getLiveStreamCredentials();
          if (credentials != null) {
            _rtmpUrl = credentials['url']!;
            _streamKey = credentials['key']!;
          }
        }
        await _saveConfig();
      }
    } finally {
      _isConnectingSocial = false;
      notifyListeners();
    }
  }
  Future<void> refreshYouTubeStream() async {
    _isConnectingSocial = true;
    notifyListeners();
    final credentials = await _youtubeService.getLiveStreamCredentials();
    if (credentials != null) {
      _rtmpUrl = credentials['url']!;
      _streamKey = credentials['key']!;
      await _saveConfig();
    }
    _isConnectingSocial = false;
    notifyListeners();
  }
  Future<void> disconnectYouTube() async {
    await _youtubeService.signOut();
    _socialAccountName = "";
    _isManualMode = true;
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
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none) && _isStreaming) stop();
    notifyListeners();
  }

  Future<void> _loadSavedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    _rtmpUrl = prefs.getString('rtmp_url') ?? "";
    _streamKey = prefs.getString('stream_key') ?? "";
    _socialAccountName = prefs.getString('social_account_name') ?? "";
    _liveCode = prefs.getString('saved_live_code');
    _savedPin = prefs.getString('saved_pin');
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
    if (_liveCode != null) await prefs.setString('saved_live_code', _liveCode!);
    if (_savedPin != null) await prefs.setString('saved_pin', _savedPin!);
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
    _tickSub?.cancel();
    _effectsCtrl.close();
    fullShutdown();
    super.dispose();
  }
}
