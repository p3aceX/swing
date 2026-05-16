import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../streaming/thermal_monitor.dart';
import '../streaming/whip_publisher.dart';
import 'qr_scan_page.dart';

/// Publish the phone camera to the self-hosted Swing Studio via WHIP
/// (WebRTC). Two-step UX: SETUP (server/key/orientation/resolution/fps)
/// → PRE-LIVE (preview + GO LIVE). Settings reachable any time via the
/// gear icon.
class StudioPage extends StatefulWidget {
  const StudioPage({super.key});

  @override
  State<StudioPage> createState() => _StudioPageState();
}

enum StudioOrientation { landscape, portrait }
enum StudioView { setup, preLive }

/// Capture resolution presets. Width/height are landscape-orientation;
/// the OS rotates per the current orientation lock.
enum StudioResolution {
  p480(854, 480, '480p'),
  p720(1280, 720, '720p'),
  p1080(1920, 1080, '1080p'),
  p1440(2560, 1440, '1440p'),
  p2160(3840, 2160, '4K');

  const StudioResolution(this.width, this.height, this.label);
  final int width;
  final int height;
  final String label;
}

class _StudioPageState extends State<StudioPage> {
  static const _prefsServer = 'studio_server';
  static const _prefsKey = 'studio_key';
  static const _prefsOrientation = 'studio_orientation';
  static const _prefsResolution = 'studio_resolution';
  static const _prefsFps = 'studio_fps';

  final _serverCtrl = TextEditingController();
  final _keyCtrl = TextEditingController(text: 'cam1');
  final _renderer = RTCVideoRenderer();
  final _publisher = WhipPublisher();
  bool _frontCamera = false;
  bool _loaded = false;
  StudioView _view = StudioView.setup;
  StudioOrientation _orientation = StudioOrientation.landscape;
  StudioResolution _resolution = StudioResolution.p1080;
  int _fps = 30;
  DateTime? _liveStartedAt;

  // Connection-aware quality hints.
  ConnectivityResult _net = ConnectivityResult.none;
  StreamSubscription<List<ConnectivityResult>>? _netSub;

  // Thermal throttling. Only drop a notch when we cross UP into a hotter
  // level we haven't handled yet; recovery is manual (user can bump
  // resolution/fps back up via settings).
  final ThermalMonitor _thermal = ThermalMonitor();
  ThermalLevel _lastHandledThermal = ThermalLevel.none;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _renderer.initialize();
    _publisher.addListener(_onPubChanged);
    _thermal.addListener(_onThermalChanged);
    _loadPrefs();
    _watchConnectivity();
  }

  Future<void> _watchConnectivity() async {
    final c = Connectivity();
    final initial = await c.checkConnectivity();
    if (mounted) {
      setState(() => _net = _bestOf(initial));
    }
    _netSub = c.onConnectivityChanged.listen((list) {
      if (!mounted) return;
      setState(() => _net = _bestOf(list));
    });
  }

  /// Pick the best transport when multiple are simultaneously active
  /// (ethernet > wifi > mobile > rest).
  static ConnectivityResult _bestOf(List<ConnectivityResult> r) {
    if (r.contains(ConnectivityResult.ethernet)) return ConnectivityResult.ethernet;
    if (r.contains(ConnectivityResult.wifi))     return ConnectivityResult.wifi;
    if (r.contains(ConnectivityResult.mobile))   return ConnectivityResult.mobile;
    return r.isEmpty ? ConnectivityResult.none : r.first;
  }

  StudioResolution get _recommendedResolution {
    switch (_net) {
      case ConnectivityResult.ethernet:
        return StudioResolution.p1080;
      case ConnectivityResult.wifi:
        return StudioResolution.p1080;
      case ConnectivityResult.mobile:
        return StudioResolution.p720;
      default:
        return StudioResolution.p480;
    }
  }

  int get _recommendedFps {
    switch (_net) {
      case ConnectivityResult.ethernet:
        return 60;
      case ConnectivityResult.wifi:
        return 30;
      case ConnectivityResult.mobile:
        return 30;
      default:
        return 24;
    }
  }

  String get _networkLabel {
    switch (_net) {
      case ConnectivityResult.ethernet: return 'WIRED';
      case ConnectivityResult.wifi:     return 'WIFI';
      case ConnectivityResult.mobile:   return 'CELLULAR';
      case ConnectivityResult.none:     return 'OFFLINE';
      default: return 'UNKNOWN';
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _netSub?.cancel();
    _thermal.removeListener(_onThermalChanged);
    _thermal.dispose();
    _publisher.removeListener(_onPubChanged);
    _publisher.dispose();
    _renderer.dispose();
    _serverCtrl.dispose();
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    _serverCtrl.text = p.getString(_prefsServer) ?? '';
    _keyCtrl.text = p.getString(_prefsKey) ?? 'cam1';
    final o = p.getString(_prefsOrientation);
    if (o == 'portrait') _orientation = StudioOrientation.portrait;
    final r = p.getString(_prefsResolution);
    final byName = {
      for (final v in StudioResolution.values) v.name: v,
    };
    _resolution = byName[r] ?? _recommendedResolution;
    _fps = p.getInt(_prefsFps) ?? _recommendedFps;

    if (!mounted) return;
    // Skip setup if already configured.
    setState(() {
      _loaded = true;
      if (_serverCtrl.text.isNotEmpty && _keyCtrl.text.isNotEmpty) {
        _view = StudioView.preLive;
      }
    });
    _applyOrientation();
    if (_view == StudioView.preLive) _kickPreview();
  }

  Future<void> _savePrefs() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_prefsServer, _serverCtrl.text.trim());
    await p.setString(_prefsKey, _keyCtrl.text.trim());
    await p.setString(
      _prefsOrientation,
      _orientation == StudioOrientation.portrait ? 'portrait' : 'landscape',
    );
    await p.setString(_prefsResolution, _resolution.name);
    await p.setInt(_prefsFps, _fps);
  }

  void _applyOrientation() {
    // The orientation lock is only meaningful in PRE-LIVE — that's where the
    // camera capturer reads device orientation. The SETUP form is much more
    // comfortable in portrait (or whatever the user is naturally holding),
    // so we leave it unlocked there. Locking setup to landscape gave us a
    // <130px-tall body and a RenderFlex overflow.
    if (_view != StudioView.preLive) {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      return;
    }
    if (_orientation == StudioOrientation.portrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void _kickPreview() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _publisher.prepareCamera(
        frontCamera: _frontCamera,
        width: _resolution.width,
        height: _resolution.height,
        fps: _fps,
      );
    });
  }

  bool get _isLive => _publisher.phase == WhipPhase.live;
  bool get _isConnecting =>
      _publisher.phase == WhipPhase.connecting ||
      _publisher.phase == WhipPhase.acquiring;
  bool get _settingsValid =>
      _serverCtrl.text.trim().isNotEmpty && _keyCtrl.text.trim().isNotEmpty;

  void _onPubChanged() {
    if (!mounted) return;
    if (_publisher.phase == WhipPhase.live && _liveStartedAt == null) {
      _liveStartedAt = DateTime.now();
    } else if (_publisher.phase != WhipPhase.live) {
      _liveStartedAt = null;
    }
    setState(() {});
    final s = _publisher.localStream;
    if (s != null && _renderer.srcObject != s) {
      _renderer.srcObject = s;
    } else if (s == null && _renderer.srcObject != null) {
      _renderer.srcObject = null;
    }
  }

  // ── Thermal throttling ──────────────────────────────────────────────
  void _onThermalChanged() {
    if (!mounted) return;
    final lvl = _thermal.level;
    // Rebuild so the THROTTLING chip can appear/disappear.
    setState(() {});

    // Only act on transitions that cross UP into moderate-or-worse and
    // are strictly hotter than what we already responded to.
    if (lvl.index < ThermalLevel.moderate.index) {
      // Cooling down to light/none — let the user manually push quality
      // back up, but reset our "handled" floor so a future re-heat will
      // throttle again.
      if (lvl.index <= ThermalLevel.light.index) {
        _lastHandledThermal = lvl;
      }
      return;
    }
    if (lvl.index <= _lastHandledThermal.index) return;
    _lastHandledThermal = lvl;

    // Don't reconfigure while we're mid-handshake or already live —
    // _setResolution/_setFps would no-op anyway, and bouncing the
    // encoder under load makes things worse.
    if (_isLive || _isConnecting) return;

    _applyThermalDrop();
  }

  Future<void> _applyThermalDrop() async {
    // Resolution: drop ONE notch toward 480p.
    final nextRes = switch (_resolution) {
      StudioResolution.p2160 => StudioResolution.p1440,
      StudioResolution.p1440 => StudioResolution.p1080,
      StudioResolution.p1080 => StudioResolution.p720,
      StudioResolution.p720  => StudioResolution.p480,
      StudioResolution.p480  => StudioResolution.p480,
    };
    // FPS: 120 → 60, 60 → 30, else hold.
    final nextFps = _fps >= 120 ? 60 : (_fps >= 60 ? 30 : _fps);

    // When stepping 1080+ down to 720, also clip 120fps to 60 so we
    // don't sit at 720p120.
    if (nextRes != _resolution) await _setResolution(nextRes);
    if (nextFps != _fps) await _setFps(nextFps);
  }

  bool get _isThrottling =>
      _thermal.level.index >= ThermalLevel.moderate.index;

  // ── Setup → pre-live ────────────────────────────────────────────────
  Future<void> _continueFromSetup() async {
    if (_serverCtrl.text.trim().isEmpty || _keyCtrl.text.trim().isEmpty) return;
    await _savePrefs();
    if (!mounted) return;
    setState(() => _view = StudioView.preLive);
    _applyOrientation();
    _kickPreview();
  }

  void _openSettings() {
    setState(() => _view = StudioView.setup);
    // Unlock orientation so the setup form has room to breathe.
    _applyOrientation();
  }

  // ── Stream control ──────────────────────────────────────────────────
  Future<void> _publish() async {
    final server = _serverCtrl.text.trim();
    final key = _keyCtrl.text.trim();
    if (server.isEmpty || key.isEmpty) {
      setState(() => _view = StudioView.setup);
      return;
    }
    await _savePrefs();
    await _publisher.start(
      server: server,
      key: key,
      frontCamera: _frontCamera,
    );
  }

  Future<void> _stop() => _publisher.stop();

  Future<void> _flip() async {
    setState(() => _frontCamera = !_frontCamera);
    final wasLive = _isLive || _isConnecting;
    await _publisher.releaseCamera();
    await _publisher.prepareCamera(
      frontCamera: _frontCamera,
      width: _resolution.width,
      height: _resolution.height,
      fps: _fps,
    );
    if (wasLive) await _publish();
  }

  Future<void> _setOrientation(StudioOrientation v) async {
    if (_orientation == v) return;
    if (_isLive || _isConnecting) return;
    setState(() => _orientation = v);
    _applyOrientation();
    await _savePrefs();
  }

  Future<void> _setResolution(StudioResolution v) async {
    if (_resolution == v) return;
    if (_isLive || _isConnecting) return;
    setState(() => _resolution = v);
    await _savePrefs();
  }

  Future<void> _setFps(int v) async {
    if (_fps == v) return;
    if (_isLive || _isConnecting) return;
    setState(() => _fps = v);
    await _savePrefs();
  }

  // ── QR pairing ──────────────────────────────────────────────────────
  Future<void> _scanQr() async {
    final result = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (result == null || !mounted) return;
    final server = result['server']?.trim();
    final key = result['key']?.trim();
    if (server != null && server.isNotEmpty) _serverCtrl.text = server;
    if (key != null && key.isNotEmpty) _keyCtrl.text = key;
    setState(() {});
    await _savePrefs();
  }

  // ── Build ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_view == StudioView.setup) return _buildSetup();
    return _buildPreLive();
  }

  Widget _buildSetup() {
    final canContinue = _loaded && _settingsValid;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: back + title + tiny network indicator.
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      // If config is valid AND we already have a preview
                      // running, go back to pre-live instead of exiting.
                      if (_settingsValid &&
                          _publisher.localStream != null) {
                        setState(() => _view = StudioView.preLive);
                        _applyOrientation();
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
                    child: const SizedBox(
                      width: 56, height: 56,
                      child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                  ),
                  const Text(
                    'STUDIO SETUP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.4,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.white10,
                    child: Text(
                      _networkLabel,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Form.
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _scanQr,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text(
                          'SCAN STUDIO QR',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.4,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF19C37D),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _field(
                      label: 'STUDIO SERVER',
                      hint: '192.168.1.3',
                      controller: _serverCtrl,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 18),
                    _field(
                      label: 'STREAM KEY',
                      hint: 'cam1',
                      controller: _keyCtrl,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 22),
                    _sectionLabel('ORIENTATION'),
                    const SizedBox(height: 6),
                    _pillRow([
                      _Pill(
                        label: 'LANDSCAPE',
                        selected: _orientation == StudioOrientation.landscape,
                        onTap: () => _setOrientation(StudioOrientation.landscape),
                      ),
                      _Pill(
                        label: 'PORTRAIT',
                        selected: _orientation == StudioOrientation.portrait,
                        onTap: () => _setOrientation(StudioOrientation.portrait),
                      ),
                    ]),
                    const SizedBox(height: 22),
                    _sectionLabel('RESOLUTION'),
                    const SizedBox(height: 6),
                    _pillRow([
                      for (final r in StudioResolution.values)
                        _Pill(
                          label: r.label,
                          selected: _resolution == r,
                          recommended: r == _recommendedResolution,
                          onTap: () => _setResolution(r),
                        ),
                    ]),
                    const SizedBox(height: 6),
                    _recoLine(
                      'Recommended for $_networkLabel: '
                      '${_recommendedResolution.label}',
                    ),
                    const SizedBox(height: 22),
                    _sectionLabel('FRAME RATE'),
                    const SizedBox(height: 6),
                    _pillRow([
                      for (final f in const [24, 30, 60, 120])
                        _Pill(
                          label: '${f}fps',
                          selected: _fps == f,
                          recommended: f == _recommendedFps,
                          onTap: () => _setFps(f),
                        ),
                    ]),
                    const SizedBox(height: 6),
                    _recoLine('Recommended: ${_recommendedFps}fps'),
                  ],
                ),
              ),
            ),
            // Continue button.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: canContinue ? _continueFromSetup : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.white12,
                    disabledForegroundColor: Colors.white38,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: const Text(
                    'CONTINUE',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.6,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreLive() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _renderer.srcObject == null
              ? _Empty(phase: _publisher.phase)
              : RTCVideoView(
                  _renderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  mirror: _frontCamera,
                ),
          // Back (top-left, big hit area).
          Positioned(
            top: 0, left: 0,
            child: SafeArea(
              bottom: false, right: false,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final nav = Navigator.of(context);
                    if (_isLive || _isConnecting) await _publisher.stop();
                    if (mounted) nav.maybePop();
                  },
                  child: const SizedBox(
                    width: 56, height: 56,
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 26),
                  ),
                ),
              ),
            ),
          ),
          // Top-right: live badge + flip + settings.
          Positioned(
            top: 0, right: 0,
            child: SafeArea(
              bottom: false, left: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isThrottling) ...[
                      const _ThrottleBadge(),
                      const SizedBox(width: 8),
                    ],
                    if (_isLive)
                      _LiveBadge(startedAt: _liveStartedAt)
                    else if (_isConnecting)
                      const _PhaseLabel('CONNECTING…'),
                    if (_isLive || _isConnecting) const SizedBox(width: 8),
                    _IconBtn(icon: Icons.cameraswitch, onTap: _flip),
                    const SizedBox(width: 4),
                    _IconBtn(
                      icon: Icons.settings,
                      onTap: (_isLive || _isConnecting) ? null : _openSettings,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom: GO LIVE / END.
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: _GoButton(
                  isLive: _isLive,
                  isConnecting: _isConnecting,
                  loaded: _loaded,
                  canPublish: _settingsValid,
                  error: _publisher.error,
                  onPublish: _publish,
                  onEnd: _stop,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Setup form helpers ──────────────────────────────────────────────
  Widget _sectionLabel(String t) => Text(
        t,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      );

  Widget _recoLine(String t) => Text(
        t,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      );

  Widget _pillRow(List<Widget> pills) {
    final children = <Widget>[];
    for (var i = 0; i < pills.length; i++) {
      if (i > 0) children.add(const SizedBox(width: 1));
      children.add(Expanded(child: pills[i]));
    }
    return Row(children: children);
  }

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(label),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
            filled: true,
            fillColor: Colors.white10,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Small widgets

class _Empty extends StatelessWidget {
  const _Empty({required this.phase});
  final WhipPhase phase;

  @override
  Widget build(BuildContext context) {
    final msg = phase == WhipPhase.acquiring
        ? 'OPENING CAMERA…'
        : phase == WhipPhase.failed
            ? 'CAMERA UNAVAILABLE'
            : 'STUDIO';
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Text(
          msg,
          style: const TextStyle(
            color: Colors.white24,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.4,
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        color: Colors.black54,
        child: Icon(
          icon,
          color: onTap == null ? Colors.white30 : Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.recommended = false,
  });
  final String label;
  final bool selected;
  final bool recommended;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        color: selected ? Colors.white : Colors.white10,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: onTap == null
                    ? Colors.white24
                    : (selected ? Colors.black : Colors.white70),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
              ),
            ),
            if (recommended && !selected)
              Positioned(
                top: 3, right: 4,
                child: Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF19C37D),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.startedAt});
  final DateTime? startedAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: const Color(0xFFFF2D2D),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(width: 10),
          StreamBuilder<int>(
            stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
            builder: (ctx, snap) => Text(
              _fmt(startedAt == null
                  ? Duration.zero
                  : DateTime.now().difference(startedAt!)),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _PhaseLabel extends StatelessWidget {
  const _PhaseLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: Colors.black54,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}

class _ThrottleBadge extends StatelessWidget {
  const _ThrottleBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: const Color(0xFFFFB020),
      child: const Text(
        'THROTTLING',
        style: TextStyle(
          color: Colors.black,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}

class _GoButton extends StatelessWidget {
  const _GoButton({
    required this.isLive,
    required this.isConnecting,
    required this.loaded,
    required this.canPublish,
    required this.error,
    required this.onPublish,
    required this.onEnd,
  });

  final bool isLive;
  final bool isConnecting;
  final bool loaded;
  final bool canPublish;
  final String? error;
  final VoidCallback onPublish;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (error != null && !isConnecting) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.black54,
            child: Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 11),
            ),
          ),
          const SizedBox(height: 6),
        ],
        if (!isLive && !isConnecting && !canPublish) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.black54,
            child: const Text(
              'TAP ⚙ TO SET STUDIO SERVER AND STREAM KEY',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
        SizedBox(
          height: 58,
          child: ElevatedButton(
            onPressed: isConnecting
                ? null
                : (isLive
                    ? onEnd
                    : ((loaded && canPublish) ? onPublish : null)),
            style: ElevatedButton.styleFrom(
              backgroundColor: isLive ? Colors.white : const Color(0xFFFF2D2D),
              foregroundColor: isLive ? Colors.black : Colors.white,
              disabledBackgroundColor: Colors.white12,
              disabledForegroundColor: Colors.white54,
              elevation: 0,
              shape: const RoundedRectangleBorder(),
            ),
            child: Text(
              isLive ? 'END' : (isConnecting ? 'CONNECTING…' : 'GO LIVE'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
