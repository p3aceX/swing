import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/youtube_auth.dart';
import 'broadcast_repository.dart';
import 'rtmp_engine.dart';
import 'stream_session.dart';
import 'thermal_monitor.dart';

enum StreamPhase {
  /// First run, no Google account bound, no cached creds.
  signedOut,

  /// Signed in but hardware/preview not yet started.
  signedIn,

  /// Hardware ready, no broadcast yet OR cached broadcast ready to use.
  ready,

  /// User tapped GO LIVE — creating broadcast and/or connecting RTMP.
  connecting,

  /// RTMP is connected, broadcast is live on YouTube.
  live,

  /// User paused. RTMP stopped, broadcast still alive on YouTube
  /// (enableAutoStop=false). Can resume to keep the same broadcast.
  paused,

  /// Permission denial, hardware fault, or YouTube API failure. Holds
  /// `errorMessage` for the UI. Recoverable via retry.
  error,
}

/// Single source of truth. Owns auth, engine, and the persisted session.
/// The UI watches `phase` + `errorMessage` and reacts.
class StreamController extends ChangeNotifier with WidgetsBindingObserver {
  final _auth = YouTubeAuth();
  final _repo = BroadcastRepository();
  final _engine = RtmpEngine();
  final _thermal = ThermalMonitor();

  StreamSession? _session;
  StreamPhase _phase = StreamPhase.signedOut;
  String? _errorMessage;
  String? _connectionStatus; // shown to user during CONNECTING phase
  List<StreamSession> _availableSessions = [];
  bool _isLoadingSessions = false;

  DateTime? _liveStartedAt;
  Duration _liveDuration = Duration.zero;
  Timer? _tickTimer;

  // Public getters
  StreamPhase get phase => _phase;
  String? get errorMessage => _errorMessage;
  String? get connectionStatus => _connectionStatus;
  String? get accountEmail => _auth.account?.email;
  String? get accountPhoto => _auth.account?.photoUrl;
  RtmpEngine get engine => _engine;
  ThermalLevel get thermalLevel => _thermal.level;
  Duration get liveDuration => _liveDuration;
  int get liveBitrate => _engine.liveBitrate;
  int get liveFps => _engine.liveFps;
  List<StreamSession> get availableSessions => _availableSessions;
  bool get isLoadingSessions => _isLoadingSessions;

  // Quality preset. Always starts at 1080p60 (the cap). System adapts
  // DOWN automatically on broken-pipe / network failure — the user
  // doesn't have to guess what their bandwidth can sustain. Persisted
  // across launches (manual overrides stick).
  static const _prefsQuality = 'live_stream_quality';

  ConnectivityResult _net = ConnectivityResult.none;
  StreamSubscription<List<ConnectivityResult>>? _netSub;

  ConnectivityResult get network => _net;
  StreamQuality get quality => _engine.quality;

  // Reconnect counter — when a mid-stream RTMP socket dies we drop one
  // preset notch and retry. Reset on a successful live transition.
  int _reconnectAttempt = 0;
  static const _maxReconnectAttempts = 4;

  // Set when we auto-pause because the app went to background; flipped
  // back off when we auto-resume on foreground. Lets us distinguish
  // "user paused" from "OS paused us" so we only auto-resume the latter.
  bool _pausedByLifecycle = false;

  Future<void> setQuality(StreamQuality q) async {
    if (_phase == StreamPhase.live ||
        _phase == StreamPhase.connecting) {
      return; // ignore mid-stream changes
    }
    _engine.setQuality(q);
    final p = await SharedPreferences.getInstance();
    await p.setString(_prefsQuality, q.name);
    notifyListeners();
  }

  void _watchConnectivity() async {
    final c = Connectivity();
    final initial = await c.checkConnectivity();
    _net = _bestOf(initial);
    notifyListeners();
    _netSub = c.onConnectivityChanged.listen((list) {
      _net = _bestOf(list);
      notifyListeners();
    });
  }

  static ConnectivityResult _bestOf(List<ConnectivityResult> r) {
    if (r.contains(ConnectivityResult.ethernet)) return ConnectivityResult.ethernet;
    if (r.contains(ConnectivityResult.wifi))     return ConnectivityResult.wifi;
    if (r.contains(ConnectivityResult.mobile))   return ConnectivityResult.mobile;
    return r.isEmpty ? ConnectivityResult.none : r.first;
  }

  StreamController() {
    _engine.addListener(_onEngineChange);
    _thermal.addListener(_onThermalChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  ThermalLevel _lastHandledThermal = ThermalLevel.none;

  void _onThermalChanged() {
    final lvl = _thermal.level;
    notifyListeners();
    
    if (lvl.index < ThermalLevel.moderate.index) {
      if (lvl.index <= ThermalLevel.light.index) {
        _lastHandledThermal = lvl;
      }
      return;
    }
    if (lvl.index <= _lastHandledThermal.index) return;
    _lastHandledThermal = lvl;

    if (_phase == StreamPhase.live) {
      final newQ = _engine.quality.oneStepDown;
      if (newQ != _engine.quality) {
        _engine.applyQualityHotSwap(newQ);
        debugPrint('[StreamController] Thermally throttled to ${newQ.label}');
      }
    }
  }

  /// App lifecycle bridge. When Android destroys our OpenGL surface
  /// (minimize / app switcher / lock screen), Pedro's encoder dies a
  /// second or two later with a generic error — and Dart never finds
  /// out cleanly. We pre-empt that: stop the RTMP socket ourselves on
  /// background so the YouTube broadcast stays in a clean "paused"
  /// state, then auto-restart it the moment the app is foregrounded
  /// again and the preview surface is back.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        if (_phase == StreamPhase.live ||
            _phase == StreamPhase.connecting) {
          debugPrint('[CTRL] lifecycle=$state → auto-pause');
          _pausedByLifecycle = true;
          unawaited(_engine.stopStreaming());
          _setPhase(StreamPhase.paused);
          _stopTicker();
        }
        break;
      case AppLifecycleState.resumed:
        // We intentionally DO NOT auto-resume. Coming back from
        // background after a quick app switch or phone call has too
        // many ways to fail silently — the OpenGL surface needs to be
        // re-created, the camera may have been revoked, Pedro's encoder
        // may be in an inconsistent state. Auto-restarting the stream
        // in that window leaves the user staring at a black camera
        // preview with the broadcast running on a dead source.
        //
        // Instead we surface the paused state with `_pausedByLifecycle`
        // and let the user tap RESUME when they're actually ready —
        // gives Pedro time to recover and gives the user visible
        // control over a live broadcast.
        if (_pausedByLifecycle && _phase == StreamPhase.paused) {
          debugPrint('[CTRL] lifecycle=resumed → awaiting manual resume');
          notifyListeners(); // UI re-renders to show the RESUME affordance
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // No action — inactive can fire spuriously (incoming call banner);
        // detached only fires on full process death.
        break;
    }
  }

  /// Whether the stream is paused due to the app being backgrounded
  /// (vs. an explicit user pause). UI uses this to surface the manual
  /// RESUME affordance more prominently — it's the user's signal that
  /// the broadcast is paused but recoverable.
  bool get isPausedByLifecycle =>
      _pausedByLifecycle && _phase == StreamPhase.paused;

  Future<void> init() async {
    // Load the cached session (if any) so a subsequent goLive() reuses the
    // same YouTube broadcast instead of creating a new one. We *do not*
    // push RTMP automatically here — the user always taps GO LIVE. This is
    // deliberate: two simultaneous RTMP connections to the same stream key
    // (one from auto-resume + one from a manual tap) cause YouTube to drop
    // both with a "Broken pipe" error.
    _session = await StreamSession.load();
    await _loadQualityPref();
    _watchConnectivity();
    final ok = await _auth.signInSilently();
    _setPhase(ok ? StreamPhase.signedIn : StreamPhase.signedOut);
    if (ok) {
      // Background fetch of existing streams so the UI can show Resume buttons
      unawaited(fetchAvailableSessions());
    }
  }

  Future<void> _loadQualityPref() async {
    final p = await SharedPreferences.getInstance();
    final saved = p.getString(_prefsQuality);
    if (saved == null) return; // keep the engine default (1080p60)
    final match = StreamQuality.values.where((q) => q.name == saved);
    if (match.isNotEmpty) _engine.setQuality(match.first);
  }

  Future<void> signIn() async {
    _errorMessage = null;
    final ok = await _auth.signInInteractive();
    if (!ok) {
      _errorMessage = 'Google sign-in failed or cancelled.';
      _setPhase(StreamPhase.signedOut);
      return;
    }
    _setPhase(StreamPhase.signedIn);
    await fetchAvailableSessions();
  }

  Future<void> signOut() async {
    await _engine.stopStreaming();
    await _auth.signOut();
    await StreamSession.clear();
    _session = null;
    _liveStartedAt = null;
    _liveDuration = Duration.zero;
    _setPhase(StreamPhase.signedOut);
  }

  /// User tapped the GO LIVE button. Caller passes the *current* device
  /// orientation (read from MediaQuery at tap time) — the stream is locked
  /// to that orientation until END.
  Future<void> goLive({required bool isVertical}) async {
    _errorMessage = null;
    if (!_auth.isSignedIn) {
      _errorMessage = 'Sign in with Google first.';
      _setPhase(StreamPhase.signedOut);
      return;
    }

    // Decide reuse vs create-fresh BEFORE flipping phase so the UI sees
    // the right status the first frame it renders CONNECTING.
    if (_session != null && _session!.isFresh) {
      _connectionStatus = 'Existing stream found — resuming';
    } else {
      _connectionStatus = 'Looking for existing stream…';
    }
    _setPhase(StreamPhase.connecting);

    // Give the UI one frame + a beat to unmount the camera-plugin preview
    // (which owns the camera until now). Without this, Pedro's Camera2
    // acquire races against the camera plugin's release and fails.
    await Future.delayed(const Duration(milliseconds: 400));
    await _ensureHardware(isVertical);
    if (_engine.phase == RtmpPhase.failed) {
      _errorMessage = _engine.lastError;
      _setPhase(StreamPhase.error);
      return;
    }

    if (_session == null || !_session!.isFresh) {
      try {
        // findOrCreate: scan YouTube for an existing usable broadcast first,
        // only mint a new one if none exist. Keeps quota low and prevents
        // duplicate broadcasts when the local cache is gone (uninstall,
        // wipe, multi-device, etc).
        final result =
            await _repo.findOrCreate(_auth.api!, isVertical: isVertical);
        _session = result.session;
        _connectionStatus = result.reused
            ? 'Existing stream found — resuming'
            : 'New broadcast created';
        notifyListeners();
      } catch (e) {
        _errorMessage = 'Could not create YouTube broadcast: $e';
        _setPhase(StreamPhase.error);
        return;
      }
    }

    // Mark wasStreaming BEFORE pushing RTMP so a crash mid-handshake still
    // triggers crash recovery on next launch.
    _session = _session!.copyWith(wasStreaming: true, isVertical: isVertical);
    await _session!.save();

    await _engine.startStreaming(_session!.rtmpUrl, _session!.streamKey);
  }

  Future<void> fetchAvailableSessions() async {
    if (!_auth.isSignedIn || _auth.api == null) return;
    _isLoadingSessions = true;
    notifyListeners();
    try {
      _availableSessions = await _repo.listActiveBroadcasts(
        _auth.api!,
        isVertical: true, // dummy default, will be set on resume
      );
    } catch (e) {
      debugPrint('[CTRL] fetchAvailableSessions failed: $e');
    } finally {
      _isLoadingSessions = false;
      notifyListeners();
    }
  }

  /// Resume an existing YouTube broadcast fetched from the API.
  /// We pre-load the session then delegate entirely to [goLive] so that the
  /// camera handoff delay, hardware init, and engine phase transitions are
  /// handled identically to a normal go-live — avoids camera-binding bugs.
  Future<void> resumeExistingSession(StreamSession session,
      {required bool isVertical}) async {
    // Pre-load the session. goLive() checks `_session.isFresh` and will skip
    // the findOrCreate API call because this session is already set.
    // Stamp createdAt=now so isFresh is always true regardless of when the
    // broadcast was originally scheduled.
    _session = StreamSession(
      broadcastId: session.broadcastId,
      streamId: session.streamId,
      rtmpUrl: session.rtmpUrl,
      streamKey: session.streamKey,
      createdAt: DateTime.now(),
      wasStreaming: session.wasStreaming,
      isVertical: isVertical,
    );
    await _session!.save();
    _connectionStatus = 'Resuming existing stream…';
    // Delegate to goLive — it handles everything else.
    await goLive(isVertical: isVertical);
  }

  /// User tapped PAUSE. Stops RTMP but keeps the broadcast alive on YouTube
  /// (enableAutoStop=false). Resume reconnects to the same key.
  Future<void> pause() async {
    // Clear the lifecycle flag so a *manual* pause is treated as the
    // user's intent — we won't auto-resume just because they tabbed away
    // afterwards.
    _pausedByLifecycle = false;
    await _engine.stopStreaming();
    _setPhase(StreamPhase.paused);
    _stopTicker();
  }

  Future<void> resume({bool skipRelease = false}) async {
    if (_session == null) {
      _errorMessage = 'No active session to resume.';
      _setPhase(StreamPhase.error);
      return;
    }
    // Take the EXACT same code path as a cold-start "Resume Existing
    // Stream" — the user confirmed that works reliably. Difference vs
    // pause/resume previously: that path goes through goLive() which
    // forces a fresh _engine.initialize(), giving Pedro a clean
    // encoder state for the next startStream. Without the reset,
    // Pedro's encoder/camera binding gets stuck and the YouTube feed
    // shows black even though preview shows pixels.
    _reconnectAttempt = 0;
    _errorMessage = null;
    _pausedByLifecycle = false;

    // releaseCamera flips engine.phase → idle so _ensureHardware
    // inside goLive() will actually run initialize (it short-circuits
    // when phase is already ready/connecting/live, which is the case
    // after a pause).
    if (!skipRelease) {
      await _engine.releaseCamera();
    }

    // goLive() handles connecting status, 400ms platform-view settle
    // delay, hardware init, and startStreaming — the same lifecycle
    // as a fresh broadcast. The cached _session means it won't try to
    // mint a new YouTube broadcast.
    await goLive(isVertical: _session!.isVertical);
  }

  /// User tapped END STREAM. Stops RTMP, transitions broadcast to complete,
  /// clears local cache. Releases the camera so the pre-stream preview can
  /// reacquire it. Next goLive() creates a fresh broadcast.
  Future<void> endStream() async {
    await _engine.stopStreaming();
    _stopTicker();
    _liveDuration = Duration.zero;
    _liveStartedAt = null;
    final s = _session;
    _session = null;
    if (s != null && _auth.api != null) {
      try {
        await _repo.end(_auth.api!, s.broadcastId);
      } catch (_) {}
    }
    await StreamSession.clear();
    await _engine.releaseCamera();
    _setPhase(_auth.isSignedIn ? StreamPhase.signedIn : StreamPhase.signedOut);
  }

  Future<void> switchCamera() => _engine.switchCamera();

  bool get isMuted => _engine.isMuted;
  Future<void> toggleMute() async {
    await _engine.setMuted(!_engine.isMuted);
    notifyListeners();
  }

  Future<void> _ensureHardware(bool isVertical) async {
    if (_engine.phase == RtmpPhase.ready ||
        _engine.phase == RtmpPhase.connecting ||
        _engine.phase == RtmpPhase.live) {
      return;
    }
    await _engine.initialize(isVertical: isVertical);
  }

  void _onEngineChange() {
    // Engine drives phase transitions for connection lifecycle. Other
    // transitions (signedOut/signedIn/paused) come from explicit user calls.
    switch (_engine.phase) {
      case RtmpPhase.live:
        _liveStartedAt ??= DateTime.now();
        _connectionStatus = null; // clear once we're actually live
        _reconnectAttempt = 0;    // healthy — reset the backoff counter
        _startTicker();
        _setPhase(StreamPhase.live);
        break;
      case RtmpPhase.failed:
        _errorMessage = _engine.lastError;
        _stopTicker();
        // RTMP died mid-stream (broken pipe is the common one — network
        // can't sustain the current bitrate). Try to reconnect at a
        // lower quality before giving up on the broadcast.
        if (_phase == StreamPhase.live ||
            _phase == StreamPhase.connecting) {
          unawaited(_attemptReconnect());
        } else {
          _setPhase(StreamPhase.error);
        }
        break;
      case RtmpPhase.ready:
      case RtmpPhase.connecting:
      case RtmpPhase.initializing:
      case RtmpPhase.idle:
        // Pass through — controller already in the right phase.
        notifyListeners();
        break;
    }
  }

  /// Adaptive reconnect on mid-stream RTMP failure (broken pipe / network
  /// blip). Drops one quality notch and re-opens the RTMP socket. The
  /// YouTube broadcast itself stays alive (enableAutoStop=false) — we're
  /// only re-establishing the publisher side.
  ///
  /// Up to [_maxReconnectAttempts] tries; after that we give up and end
  /// the broadcast properly so a fresh GO LIVE mints a new one.
  Future<void> _attemptReconnect() async {
    if (_session == null) {
      _setPhase(StreamPhase.error);
      return;
    }
    _reconnectAttempt++;
    if (_reconnectAttempt > _maxReconnectAttempts) {
      _reconnectAttempt = 0;
      _dropSessionAfterFailure();
      return;
    }

    // Step quality down each attempt; on attempt 1 we keep current quality
    // (maybe it was a transient blip), from attempt 2 we drop.
    final oldQ = _engine.quality;
    final newQ =
        _reconnectAttempt >= 2 ? oldQ.oneStepDown : oldQ;
    if (newQ != oldQ) {
      await _engine.applyQualityHotSwap(newQ);
    }

    _connectionStatus =
        'Reconnecting (try $_reconnectAttempt) at ${newQ.label}…';
    _setPhase(StreamPhase.connecting);
    notifyListeners();

    // Backoff so we don't slam YouTube with rapid reconnects.
    await Future.delayed(Duration(seconds: 1 + _reconnectAttempt));

    if (_session == null) return; // user ended in the meantime
    await _engine.startStreaming(_session!.rtmpUrl, _session!.streamKey);
  }

  /// Final-give-up handler when reconnect attempts are exhausted. Ends the
  /// broadcast on YouTube so a fresh GO LIVE mints a new one.
  void _dropSessionAfterFailure() {
    final s = _session;
    _session = null;
    _availableSessions = []; // Clear so stale session is removed from resume list
    _setPhase(StreamPhase.error);
    () async {
      await StreamSession.clear();
      await _engine.releaseCamera();
      if (s != null && _auth.api != null) {
        try {
          await _repo.end(_auth.api!, s.broadcastId);
        } catch (_) {}
      }
    }();
  }

  void _startTicker() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_liveStartedAt == null) return;
      _liveDuration = DateTime.now().difference(_liveStartedAt!);
      notifyListeners();
    });
  }

  void _stopTicker() {
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  void _setPhase(StreamPhase p) {
    _phase = p;
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _netSub?.cancel();
    _engine.removeListener(_onEngineChange);
    _thermal.removeListener(_onThermalChanged);
    _tickTimer?.cancel();
    _engine.dispose();
    _thermal.dispose();
    super.dispose();
  }
}
