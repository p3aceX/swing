import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:screen_brightness/screen_brightness.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../framework/pedro_stream_view.dart';
import '../overlays/native_overlay_bridge.dart';
import '../overlays/premium_a/premium_a_overlay.dart';
import '../overlays/premium_a/state/live_match_feed.dart';
import '../overlays/premium_a/state/match_credentials.dart';
import '../streaming/bandwidth_tester.dart';
import '../streaming/rtmp_engine.dart';
import '../streaming/stream_controller.dart';
import '../streaming/stream_session.dart';
import 'widgets/pre_stream_preview.dart';

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  /// Hides all swing-live chrome (top bar + center action button) so the
  /// producer can review the active overlay against the raw camera. Tap
  /// anywhere on the screen to exit. Persists only within the session.
  bool _overlayPreview = false;

  /// Lets the settings sheet ask the overlay to re-init its feed (e.g.
  /// after connecting / disconnecting a match).
  final GlobalKey<PremiumAOverlayState> _overlayKey =
      GlobalKey<PremiumAOverlayState>();

  Timer? _dimTimer;
  bool _isDimmed = false;

  /// Bumped on every resume to force PedroStreamView to remount,
  /// triggering a fresh RtmpCamera2 creation natively. Without this
  /// the same Pedro instance survives pause/resume and ends up
  /// pushing black frames.
  int _streamViewGen = 0;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _resetDimTimer();
  }

  void _resetDimTimer() {
    _dimTimer?.cancel();
    if (_isDimmed) {
      _isDimmed = false;
      ScreenBrightness().resetScreenBrightness();
    }
    _dimTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() => _isDimmed = true);
        ScreenBrightness().setScreenBrightness(0.1);
      }
    });
  }

  @override
  void dispose() {
    _dimTimer?.cancel();
    ScreenBrightness().resetScreenBrightness();
    WakelockPlus.disable();
    super.dispose();
  }

  /// Full hard-reset resume: nuke Pedro's RtmpCamera2, remount the
  /// platform view so a fresh one is built, then resume. This mirrors
  /// the cold-start lifecycle exactly — the only path that reliably
  /// avoids the black-screen-on-resume bug.
  Future<void> _hardResumeStream(StreamController ctrl) async {
    // 1. Nuke native state via OLD bridge while we still have it.
    // Native: stopStream, stopPreview, rtmpCamera = null.
    await ctrl.engine.camera?.resetCamera();
    
    // 2. Release the OLD bridge in Dart and flip engine phase to idle.
    // This calls native dispose() which is now a safe no-op because
    // rtmpCamera was just nulled.
    await ctrl.engine.releaseCamera();

    if (!mounted) return;

    // 3. Bump the key — Flutter disposes the old PedroStreamView and
    // creates a new one. CameraPlatformView.init runs and instantiates
    // a fresh Pedro instance since the companion was just nulled.
    setState(() => _streamViewGen++);

    // 4. Let the new platform view's GL surface settle. We wait a bit
    // longer here to ensure the native surfaceCreated -> startPreview
    // flow has finished before we try to start the encoder.
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    // 5. Full resume — skip the redundant releaseCamera() call inside
    // ctrl.resume since we already did it in step 2. goLive() will 
    // now correctly initialize because phase is already idle.
    await ctrl.resume(skipRelease: true);
  }

  /// Pre-stream phases use the stock camera plugin for a sharp preview;
  /// streaming phases hand the camera to Pedro and show its OpenGlView.
  bool _isPreStream(StreamPhase p) =>
      p == StreamPhase.signedIn ||
      p == StreamPhase.ready ||
      p == StreamPhase.error;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<StreamController>();
    final isLive = ctrl.phase == StreamPhase.live;
    final preStream = _isPreStream(ctrl.phase);

    return Listener(
      onPointerDown: (_) => _resetDimTimer(),
      onPointerMove: (_) => _resetDimTimer(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: preStream
                    ? const PreStreamPreview()
                    : PedroStreamView(
                        key: ValueKey('pedro-$_streamViewGen'),
                      ),
              ),
              // We keep PremiumAOverlay in the tree at all times so the
              // NativeOverlayBridge stays connected to the match feed.
              // It handles its own internal rendering bypass when live.
              Positioned.fill(
                child: PremiumAOverlay(
                  key: _overlayKey,
                  previewMode: _overlayPreview,
                ),
              ),
              
              // Either the regular chrome OR a single-tap exit hint when
              // the user is reviewing the overlay in preview mode.
              if (_overlayPreview)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _overlayPreview = false),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 8, left: 0, right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              color: Colors.black54,
                              child: const Text(
                                'OVERLAY PREVIEW · TAP TO EXIT',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                Positioned(
                  left: 16,
                  right: 16,
                  top: 8,
                  child: _TopBar(
                    ctrl: ctrl,
                    onPreviewOverlay: () =>
                        setState(() => _overlayPreview = true),
                    onResume: () => _hardResumeStream(ctrl),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: _CenterAction(
                      ctrl: ctrl,
                      onMatchPaired: () => _overlayKey.currentState?.reload(),
                      onResume: _hardResumeStream,
                    ),
                  ),
                ),
              ],

              if (_isDimmed)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: Text(
                          'DIMMED TO SAVE POWER\nTAP TO WAKE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white24,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.ctrl,
    required this.onPreviewOverlay,
    required this.onResume,
  });
  final StreamController ctrl;
  final VoidCallback onPreviewOverlay;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final isLive = ctrl.phase == StreamPhase.live;
    final isPaused = ctrl.phase == StreamPhase.paused;
    final isConnecting = ctrl.phase == StreamPhase.connecting;
    final preStream =
        !isLive && !isPaused && !isConnecting;
    return Row(
      children: [
        // LEFT cluster.
        if (isLive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.red,
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
          )
        else if (isPaused)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.white24,
            child: const Text(
              'PAUSED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
          ),
        if (isLive || isPaused) const SizedBox(width: 10),
        if (isLive || isPaused)
          Text(
            _fmt(ctrl.liveDuration),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        // Pre-stream: show the profile chip on the left so the user knows
        // which account they're about to broadcast under.
        if (preStream) _ProfileChip(ctrl: ctrl),

        const Spacer(),

        // RIGHT cluster.
        if (preStream) ...[
          _SettingsChip(ctrl: ctrl, onTap: () => _showSettings(context)),
          const SizedBox(width: 6),
          _iconBtn(Icons.tune, () => _showSettings(context)),
          _iconBtn(Icons.visibility_outlined, onPreviewOverlay),
        ],
        // While live or paused, still allow overlay preview — the user
        // might want to verify the overlay against the actual broadcast.
        if (isLive || isPaused)
          _iconBtn(Icons.visibility_outlined, onPreviewOverlay),
        // Stats — resolution · fps · bitrate · network — shown when active.
        if (isLive || isPaused) ...[
          _LiveStats(ctrl: ctrl),
          const SizedBox(width: 8),
        ],
        // TEST FLASH icon — opens a popup with FOUR/SIX/OUT/DUCK
        // triggers so the producer can verify the broadcast overlay
        // animations are rendering without waiting for a real boundary.
        if (isLive || isPaused) _FlashTestButton(),
        // MUTE / UNMUTE icon — live or paused (so producer can pre-mute
        // before going live too).
        if (isLive || isPaused)
          _iconBtn(
            ctrl.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            () => ctrl.toggleMute(),
            color: ctrl.isMuted ? Colors.redAccent : null,
          ),
        // PAUSE / RESUME icon — live ↔ paused.
        if (isLive)
          _iconBtn(Icons.pause_rounded, () => ctrl.pause()),
        if (isPaused)
          _iconBtn(Icons.play_arrow_rounded, onResume),
        // END button — live or paused.
        if (isLive || isPaused)
          _iconBtn(
            Icons.stop_rounded,
            () => _confirmEnd(context),
            color: Colors.redAccent,
          ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {Color? color}) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: color ?? Colors.white, size: 22),
      ),
    );
  }

  Future<void> _showSettings(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16, 14, 16,
            16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: Text(
                  'STREAM SETTINGS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.4,
                  ),
                ),
              ),
              _SpeedTest(ctrl: ctrl),
              const SizedBox(height: 12),
              const Text(
                'QUALITY',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 6),
              _QualityPicker(ctrl: ctrl),
              const SizedBox(height: 18),
              // Test flashes — manually fire each event animation so we
              // can verify the native renderer works independently of
              // whether the backend is emitting boundary/wicket events.
              const Text(
                'TEST FLASH (DEBUG)',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 6),
              const _TestFlashRow(),
              const SizedBox(height: 18),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: const Text(
                    'DONE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmEnd(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('End stream?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Broadcast will be archived to your YouTube channel.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('End',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (ok == true) await ctrl.endStream();
  }

  static String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

/// The single centered action. Pre-stream: GO LIVE / RESUME button.
/// Connecting: progress + status text. Live / paused: nothing — the
/// bottom of the screen is left clear for the future overlay layer
/// (scoreboard, sponsor strip, lower-thirds).
class _CenterAction extends StatelessWidget {
  const _CenterAction({
    required this.ctrl,
    required this.onMatchPaired,
    required this.onResume,
  });
  final StreamController ctrl;
  final VoidCallback onMatchPaired;
  final Future<void> Function(StreamController) onResume;

  @override
  Widget build(BuildContext context) {
    switch (ctrl.phase) {
      case StreamPhase.signedIn:
      case StreamPhase.ready:
      case StreamPhase.error:
        final sessions = ctrl.availableSessions;
        final hasResume = sessions.isNotEmpty;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ctrl.errorMessage != null &&
                ctrl.phase == StreamPhase.error) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.black54,
                child: Text(
                  ctrl.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            _bigCircleButton(
              label: hasResume ? 'RESUME' : 'GO LIVE',
              onTap: () => _onGoLiveTapped(context, hasResume, sessions),
            ),
            if (hasResume) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => _onGoLiveTapped(context, false, sessions),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white60,
                ),
                child: const Text(
                  'START NEW STREAM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
            ],
          ],
        );

      case StreamPhase.connecting:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 36, height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 2.4, color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              (ctrl.connectionStatus ?? 'CONNECTING…').toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.6,
              ),
            ),
          ],
        );

      case StreamPhase.paused:
        // Paused — explicit user pause OR auto-paused because the app
        // was backgrounded. Either way, show a big RESUME button so
        // the producer doesn't have to hunt for the small play icon
        // in the top bar. The button does a full hard reset: nukes
        // Pedro's RtmpCamera2 natively + remounts the platform view
        // to force a fresh GL surface + re-runs goLive (same path as
        // cold-start resume which is the one that actually works).
        return _ResumeButton(
          ctrl: ctrl,
          onResume: onResume,
        );

      case StreamPhase.live:
      case StreamPhase.signedOut:
        return const SizedBox.shrink();
    }
  }

  /// GO LIVE tap handler. If no match credentials are saved yet, opens
  /// the pair sheet first — validates, saves, reloads the overlay, and
  /// stays on the preview screen so the user can verify the overlay is
  /// showing real match data BEFORE the next tap actually broadcasts.
  /// If creds are already saved, broadcasts immediately.
  Future<void> _onGoLiveTapped(
    BuildContext context,
    bool hasResume,
    List<StreamSession> sessions,
  ) async {
    final saved = await MatchCredentials.load();
    if (!context.mounted) return;
    if (saved == null) {
      // First-time: pair the match. User stays on preview after.
      final ok = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: Colors.black,
        isScrollControlled: true,
        builder: (ctx) => const _PairSheet(),
      );
      if (ok == true) onMatchPaired();
      return;
    }
    // Creds present — actually broadcast.
    if (hasResume) {
      await ctrl.resumeExistingSession(sessions.first, isVertical: false);
    } else {
      await ctrl.goLive(isVertical: false);
    }
  }

  /// Big round-edge tappable button. 64px tall, ~72% of the screen wide.
  Widget _bigCircleButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 240,
      height: 64,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF2D2D),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.4,
          ),
        ),
      ),
    );
  }
}


/// Simple quality picker — 4 presets max, capped at 1080p60. Default is
/// 1080p60 (the cap); the controller adaptively degrades on broken-pipe.
/// Hidden while connecting/live/paused.
class _QualityPicker extends StatelessWidget {
  const _QualityPicker({required this.ctrl});
  final StreamController ctrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          for (final q in StreamQuality.values) ...[
            Expanded(
              child: InkWell(
                onTap: () => ctrl.setQuality(q),
                child: Container(
                  height: 32,
                  alignment: Alignment.center,
                  color: ctrl.quality == q ? Colors.white : Colors.white10,
                  child: Text(
                    q.label,
                    style: TextStyle(
                      color: ctrl.quality == q ? Colors.black : Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            if (q != StreamQuality.values.last) const SizedBox(width: 1),
          ],
        ],
      ),
    );
  }
}

/// Top-bar stat strip shown while live. Resolution · FPS · bitrate · net.
class _LiveStats extends StatelessWidget {
  const _LiveStats({required this.ctrl});
  final StreamController ctrl;

  @override
  Widget build(BuildContext context) {
    final q = ctrl.quality;
    final kbps = ctrl.liveBitrate ~/ 1000;
    final actualFps = ctrl.liveFps;
    final fps = actualFps > 0 ? actualFps : q.fps;
    
    // Check if currently throttling
    final isThrottling = ctrl.thermalLevel.index >= 3; // ThermalLevel.moderate and above

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isThrottling) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            color: Colors.orange,
            child: const Text(
              'HOT',
              style: TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        _stat('${q.height}p'),
        _dot(),
        _stat('${fps}fps'),
        _dot(),
        _stat(kbps > 0 ? '$kbps kbps' : '— kbps'),
        _dot(),
        _stat(_netLabel(ctrl.network)),
      ],
    );
  }

  Widget _stat(String t) => Text(
        t,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      );

  Widget _dot() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6),
        child: Text('·',
            style: TextStyle(color: Colors.white24, fontSize: 12)),
      );

  static String _netLabel(ConnectivityResult r) {
    switch (r) {
      case ConnectivityResult.ethernet: return 'WIRED';
      case ConnectivityResult.wifi:     return 'WIFI';
      case ConnectivityResult.mobile:   return '5G/4G';
      case ConnectivityResult.none:     return 'OFFLINE';
      default: return '—';
    }
  }
}


/// Upload speed test. Tap the "TEST SPEED" pill → POSTs 2MB to Cloudflare,
/// times it, shows result Mbps + a recommended preset. Tapping the
/// recommendation chip applies that preset to the controller.
class _SpeedTest extends StatefulWidget {
  const _SpeedTest({required this.ctrl});
  final StreamController ctrl;
  @override
  State<_SpeedTest> createState() => _SpeedTestState();
}

class _SpeedTestState extends State<_SpeedTest> {
  bool _running = false;
  double? _mbps;
  StreamQuality? _reco;
  String? _error;

  Future<void> _run() async {
    setState(() {
      _running = true;
      _error = null;
    });
    try {
      final m = await BandwidthTester.testUploadMbps();
      if (!mounted) return;
      setState(() {
        _mbps = m;
        _reco = BandwidthTester.recommendFor(m);
        _running = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Test failed';
        _running = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Test button (or RETEST label).
        InkWell(
          onTap: _running ? null : _run,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: _running ? Colors.white12 : Colors.white24,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_running)
                  const SizedBox(
                    width: 12, height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.6, color: Colors.white70,
                    ),
                  )
                else
                  const Icon(Icons.speed, size: 14, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  _running
                      ? 'TESTING…'
                      : (_mbps != null ? 'RETEST SPEED' : 'TEST SPEED'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Result / recommendation.
        Expanded(
          child: _running
              ? const SizedBox.shrink()
              : (_error != null
                  ? Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    )
                  : (_mbps != null && _reco != null
                      ? _result(_mbps!, _reco!)
                      : const Text(
                          'measure upload before going live',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                          ),
                        ))),
        ),
      ],
    );
  }

  Widget _result(double mbps, StreamQuality reco) {
    final mbpsTxt = mbps >= 10
        ? '${mbps.toStringAsFixed(0)} Mbps'
        : '${mbps.toStringAsFixed(1)} Mbps';
    final canHandleCurrent = widget.ctrl.quality.bitrate * 1.3 <=
        mbps * 1_000_000;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          mbpsTxt,
          style: TextStyle(
            color: mbps >= 5 ? const Color(0xFF19C37D) : Colors.orangeAccent,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: 8),
        if (canHandleCurrent)
          const Text(
            '· good for current',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 10,
              letterSpacing: 1.0,
            ),
          )
        else
          InkWell(
            onTap: () => widget.ctrl.setQuality(reco),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              color: const Color(0xFF19C37D),
              child: Text(
                'TAP → ${reco.label}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Avatar + email chip. Tap → popup with the bound Google account email
/// and a Sign out action. We only render this in pre-stream phases —
/// switching accounts mid-broadcast doesn't make sense.
class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.ctrl});
  final StreamController ctrl;

  @override
  Widget build(BuildContext context) {
    final photo = ctrl.accountPhoto;
    final email = ctrl.accountEmail ?? '—';
    return InkWell(
      onTap: () => _showAccountSheet(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: CircleAvatar(
          radius: 14,
          backgroundColor: Colors.white12,
          backgroundImage:
              photo != null && photo.isNotEmpty ? NetworkImage(photo) : null,
          child: photo == null || photo.isEmpty
              ? Text(
                  email.isNotEmpty ? email[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Future<void> _showAccountSheet(BuildContext context) async {
    final photo = ctrl.accountPhoto;
    final email = ctrl.accountEmail ?? '—';
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white12,
                    backgroundImage: photo != null && photo.isNotEmpty
                        ? NetworkImage(photo)
                        : null,
                    child: photo == null || photo.isEmpty
                        ? const Icon(Icons.person,
                            color: Colors.white70, size: 22)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SIGNED IN TO YOUTUBE',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await ctrl.endStream();
                    await ctrl.signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white12,
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: const Text(
                    'SIGN OUT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Current-settings chip (pre-stream only). Shows the active quality
/// preset plus its bitrate target — so the user always knows what they're
/// about to broadcast. Tap → opens the same settings sheet as the tune
/// icon, so it doubles as an entry point.
class _SettingsChip extends StatelessWidget {
  const _SettingsChip({required this.ctrl, required this.onTap});
  final StreamController ctrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final q = ctrl.quality;
    final mbps = (q.bitrate / 1_000_000).toStringAsFixed(
      q.bitrate >= 10_000_000 ? 0 : 1,
    );
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        color: Colors.white12,
        child: Text(
          '${q.label} · $mbps Mbps',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }
}

/// Match-pairing section in the settings sheet. Enter Swing ID + Swing
/// Pass from the host app; on Connect we POST validate-match, persist
/// the credentials, and tell the overlay to re-init its feed.

/// Pair-match modal — appears when the user taps GO LIVE without a saved
/// match. Two inputs (Swing ID, Swing Pass), validates against the
/// backend (POST /live/validate-match), saves credentials on success,
/// closes returning true. On cancel returns false.
class _PairSheet extends StatefulWidget {
  const _PairSheet();
  @override
  State<_PairSheet> createState() => _PairSheetState();
}

class _PairSheetState extends State<_PairSheet> {
  // Swing IDs are issued as `swing#NNNN` (4-digit suffix). We render the
  // `swing#` part as a non-editable prefix decoration so the controller
  // only ever holds the suffix — no double-prefix bugs.
  static const _swingPrefix = 'swing#';
  final _codeCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  bool _busy = false;
  String? _error;
  String? _matchTitle;

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  Future<void> _hydrate() async {
    final saved = await MatchCredentials.load();
    if (!mounted || saved == null) return;
    setState(() {
      // Strip the prefix when populating — the field renders just the suffix.
      final code = saved.liveCode;
      _codeCtrl.text =
          code.toLowerCase().startsWith(_swingPrefix)
              ? code.substring(_swingPrefix.length)
              : code;
      _pinCtrl.text = saved.livePin;
    });
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _validate() async {
    // The input field shows the `swing#` prefix as a non-editable
    // decoration; the controller only carries the suffix. Defensive
    // strip in case someone pasted the full ID.
    var suffix = _codeCtrl.text.trim();
    if (suffix.toLowerCase().startsWith(_swingPrefix)) {
      suffix = suffix.substring(_swingPrefix.length);
    }
    final code = '$_swingPrefix$suffix';
    final pin = _pinCtrl.text.trim();
    if (suffix.isEmpty || pin.isEmpty) {
      setState(() => _error = 'Enter both Swing ID and Swing Pass.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _matchTitle = null;
    });
    final creds = MatchCredentials(
      host: MatchCredentials.defaultHost,
      liveCode: code,
      livePin: pin,
    );
    try {
      final data = await LiveMatchFeed.validateCredentials(creds);
      await creds.save();
      if (!mounted) return;
      final match = data['match'] as Map<String, dynamic>?;
      final title = match?['title'] as String?;
      setState(() {
        _busy = false;
        _matchTitle = title ?? 'MATCH PAIRED';
      });
      // Brief moment to show the success state, then close.
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    // Scroll-safe so the layout never overflows when the keyboard pushes
    // the sheet upward (the entire form can be slightly taller than the
    // remaining viewport at small heights / landscape).
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'PAIR MATCH',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.4,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter the Swing ID and Swing Pass from the host app to bind '
              'this stream to the live match overlay.',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _field(
                    label: 'SWING ID',
                    controller: _codeCtrl,
                    prefixText: _swingPrefix,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _field(label: 'SWING PASS', controller: _pinCtrl)),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(
                  color: Colors.orangeAccent, fontSize: 11,
                ),
              ),
            ],
            if (_matchTitle != null) ...[
              const SizedBox(height: 10),
              Text(
                '✓ ${_matchTitle!}',
                style: const TextStyle(
                  color: Color(0xFF19C37D),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.6,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _busy ? null : _validate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF19C37D),
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.white12,
                  disabledForegroundColor: Colors.white54,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.6, color: Colors.black,
                        ),
                      )
                    : const Text(
                        'VALIDATE & PAIR',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style:
                  TextButton.styleFrom(foregroundColor: Colors.white54),
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            prefixText: prefixText,
            prefixStyle: prefixText == null
                ? null
                : const TextStyle(
                    color: Color(0xFFE6B544),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
            isDense: true,
            filled: true,
            fillColor: Colors.white10,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        ),
      ],
    );
  }
}

/// Lightning-bolt button shown in the top bar while live/paused. Tap →
/// popup of FOUR / SIX / OUT / DUCK to fire the corresponding flash
/// animation immediately, bypassing the SSE feed. Lets the producer
/// confirm the broadcast overlay is rendering without waiting for a
/// real boundary or wicket.
class _FlashTestButton extends StatelessWidget {
  const _FlashTestButton();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.flash_on_rounded,
        color: Colors.white,
        size: 22,
      ),
      tooltip: 'Test flash',
      color: Colors.black,
      onSelected: (kind) =>
          NativeOverlayBridge.instance.debugFireFlash(kind),
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'FOUR',
          child: Text(
            'FOUR',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
        ),
        PopupMenuItem(
          value: 'SIX',
          child: Text(
            'SIX',
            style: TextStyle(
              color: Color(0xFFE6B544),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
        ),
        PopupMenuItem(
          value: 'OUT',
          child: Text(
            'OUT',
            style: TextStyle(
              color: Color(0xFFC42531),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
        ),
        PopupMenuItem(
          value: 'DUCK',
          child: Text(
            'DUCK',
            style: TextStyle(
              color: Color(0xFFE6B544),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

/// Row of test buttons that fire the four event flashes (FOUR / SIX /
/// OUT / DUCK) directly via NativeOverlayBridge.debugFireFlash. Used
/// from the settings sheet to verify the native renderer is alive
/// without depending on the backend emitting real ball events.
class _TestFlashRow extends StatelessWidget {
  const _TestFlashRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        _TestFlashChip(kind: 'FOUR'),
        _TestFlashChip(kind: 'SIX'),
        _TestFlashChip(kind: 'OUT'),
        _TestFlashChip(kind: 'DUCK'),
      ],
    );
  }
}

class _TestFlashChip extends StatelessWidget {
  const _TestFlashChip({required this.kind});
  final String kind;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          onPressed: () =>
              NativeOverlayBridge.instance.debugFireFlash(kind),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white24, width: 1),
            shape: const RoundedRectangleBorder(),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text(
            kind,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}

/// Big visible RESUME button shown over the camera preview while the
/// broadcast is paused — either because the user tapped pause OR
/// because the app was backgrounded (phone call, app switch, screen
/// off). Avoids the "is the stream actually running?" ambiguity that
/// comes from relying on the small icon in the top bar.
class _ResumeButton extends StatelessWidget {
  const _ResumeButton({required this.ctrl, required this.onResume});
  final StreamController ctrl;
  final Future<void> Function(StreamController) onResume;

  @override
  Widget build(BuildContext context) {
    final isLifecycle = ctrl.isPausedByLifecycle;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isLifecycle ? 'STREAM PAUSED' : 'PAUSED',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.0,
          ),
        ),
        const SizedBox(height: 6),
        if (isLifecycle)
          const Text(
            'App was minimised — broadcast held safely',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        const SizedBox(height: 18),
        Material(
          color: Colors.white,
          shape: const StadiumBorder(),
          child: InkWell(
            onTap: () => onResume(ctrl),
            customBorder: const StadiumBorder(),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.black, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'RESUME',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
