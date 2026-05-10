import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/streaming_provider.dart';
import '../../framework/pedro_stream_view.dart';
import '../../overlays/packs/basic/basic_pack.dart';

class StudioPage extends StatefulWidget {
  const StudioPage({super.key});

  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> {
  final ValueNotifier<double> _zoomLevel = ValueNotifier<double>(1.0);
  bool _isUIVisible = true;
  bool _isGraphicsVisible = true;
  Timer? _uiTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StreamingProvider>().startHardware();
      _startUITimer();
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _startUITimer() {
    _uiTimer?.cancel();
    _uiTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _isUIVisible = false);
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    _zoomLevel.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StreamingProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Material(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 0. SOLID BLACK BASE
            const Positioned.fill(child: ColoredBox(color: Colors.black)),

            // 1. RAW CAMERA FEED
            AnimatedCrossFade(
              firstChild: const SizedBox.expand(child: ColoredBox(color: Colors.black)),
              secondChild: const SizedBox.expand(child: PedroStreamView()),
              crossFadeState: provider.isCameraReady ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: 800.ms,
            ),

            // 2. PRISM-STYLE ROTATING INTERACTIVE LAYER
          SafeArea(
            child: AnimatedRotation(
              turns: provider.deviceRotation / (2 * 3.14159),
              duration: 400.ms,
              curve: Curves.easeInOutBack,
              child: GestureDetector(
                onTap: _isUIVisible 
                  ? null // Let children handle taps when visible
                  : () => setState(() => _isUIVisible = true),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // BACKGROUND HIT TARGET (only when UI is visible)
                    if (_isUIVisible)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () => setState(() => _isUIVisible = false),
                          child: const ColoredBox(color: Colors.transparent),
                        ),
                      ),

                    // HUD (TOP)
                    AnimatedPositioned(
                      duration: 300.ms,
                      top: _isUIVisible ? (provider.isLandscape ? 20 : 40) : -100,
                      left: 20,
                      right: 20,
                      child: _buildTopTelemetry(provider),
                    ),

                    // CONTROLS (BOTTOM)
                    AnimatedPositioned(
                      duration: 300.ms,
                      bottom: _isUIVisible ? (provider.isLandscape ? 30 : 60) : -120,
                      left: provider.isLandscape ? 80 : 40,
                      right: provider.isLandscape ? 80 : 40,
                      child: _buildBottomControls(provider),
                    ),

                    // SIDE CONSOLE
                    if (_isUIVisible)
                      Positioned(
                        right: 15,
                        top: 150,
                        bottom: 150,
                        child: _buildSideConsole(provider),
                      ).animate().fadeIn(),
                  ],
                ),
              ),
            ),
          ),

          // 3. BROADCAST OVERLAY
          if (_isGraphicsVisible && provider.bootstrap != null)
            _buildPositionedOverlay(context, provider),
        ],
      ),
    ),
    );
  }

  /// See preflight_page.dart for the full rationale. Portrait pack
  /// uses Flutter's natural canvas; landscape pack gets a 914×411
  /// canvas centered (with negative `left`) before being rotated.
  Widget _buildPositionedOverlay(
      BuildContext context, StreamingProvider provider) {
    final isVisualLandscape = provider.deviceRotation.abs() > math.pi / 4;

    if (!isVisualLandscape) {
      return Positioned.fill(
        child: IgnorePointer(
          child: basicOverlayPack.portraitBuilder(
            bootstrap: provider.bootstrap!,
            tick: provider.tick,
            effects: provider.overlayEffects,
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    return Positioned(
      left: (w - h) / 2,
      top: (h - w) / 2,
      width: h,
      height: w,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: -provider.deviceRotation,
          alignment: Alignment.center,
          child: basicOverlayPack.landscapeBuilder(
            bootstrap: provider.bootstrap!,
            tick: provider.tick,
            effects: provider.overlayEffects,
          ),
        ),
      ),
    );
  }

  Widget _buildSideConsole(StreamingProvider provider) {
    return Container(
      width: 46,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(23)),
      child: Column(
        children: [
          _miniTool(Icons.flip_camera_ios, () => provider.toggleCamera()),
          const Spacer(),
          const Icon(Icons.zoom_in, color: Colors.white24, size: 10),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(trackHeight: 2, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6)),
                child: Slider(
                  value: _zoomLevel.value,
                  min: 1.0,
                  max: 4.0,
                  onChanged: (v) {
                    setState(() => _zoomLevel.value = v);
                    provider.setZoom(v);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniTool(IconData icon, VoidCallback onTap) {
    return IconButton(icon: Icon(icon, color: Colors.white70, size: 18), onPressed: onTap);
  }

  Widget _buildTopTelemetry(StreamingProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        Row(
          children: [
            _buildTelemetryItem("NET", "${(provider.networkStrength * 100).toInt()}%", Icons.speed),
            const SizedBox(width: 20),
            _buildLiveIndicator(provider),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomControls(StreamingProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildControlPill(
          icon: _isGraphicsVisible ? Icons.layers : Icons.layers_clear,
          onTap: () => setState(() => _isGraphicsVisible = !_isGraphicsVisible),
          isActive: _isGraphicsVisible,
        ),
        _buildMainActionButton(provider),
        _buildControlPill(
          icon: provider.isMuted ? Icons.mic_off : Icons.mic,
          onTap: () => provider.toggleMute(),
          isActive: !provider.isMuted,
        ),
      ],
    );
  }

  Widget _buildMainActionButton(StreamingProvider provider) {
    final bool isLive = provider.isStreaming;
    final bool isLandscape = provider.isLandscape;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        debugPrint('[STREAM_DEBUG] GO LIVE tap received  isLive=$isLive  '
            'rtmpUrlLen=${provider.rtmpUrl.length}  keyLen=${provider.streamKey.length}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tap received — starting…'),
            duration: Duration(seconds: 1),
          ),
        );
        if (isLive) {
          await provider.stop();
          return;
        }
        await provider.start();
        if (!mounted) return;
        final err = provider.errorMessage;
        debugPrint('[STREAM_DEBUG] after start()  isStreaming=${provider.isStreaming}  err="$err"');
        if (err.isNotEmpty && !provider.isStreaming) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err), backgroundColor: Colors.red.shade900),
          );
        } else if (!provider.isStreaming) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connecting…'), duration: Duration(seconds: 2)),
          );
        }
      },
      child: Container(
        height: isLandscape ? 48 : 64,
        padding: EdgeInsets.symmetric(horizontal: isLandscape ? 16 : 24),
        decoration: BoxDecoration(
          color: isLive ? Colors.transparent : Colors.redAccent,
          borderRadius: BorderRadius.circular(isLandscape ? 24 : 32),
          border: Border.all(color: isLive ? Colors.redAccent : Colors.white, width: 2),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isLive ? Icons.stop : Icons.radio_button_checked, color: Colors.white, size: isLandscape ? 22 : 28),
              SizedBox(width: isLandscape ? 8 : 12),
              Text(
                isLive 
                    ? "END LIVE" 
                    : (provider.isResuming ? "RESUME LIVE ▸" : "GO LIVE ▸"), 
                style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 1,
                  fontSize: isLandscape ? 12 : 14,
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlPill({required IconData icon, required VoidCallback onTap, bool isActive = true}) {
    final bool isLandscape = context.read<StreamingProvider>().isLandscape;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isLandscape ? 40 : 50,
        height: isLandscape ? 40 : 50,
        decoration: BoxDecoration(color: isActive ? Colors.white10 : Colors.redAccent.withAlpha(40), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white70, size: isLandscape ? 18 : 22),
      ),
    );
  }

  Widget _buildTelemetryItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 10, color: Colors.white24),
        const SizedBox(width: 6),
        Text(value, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildLiveIndicator(StreamingProvider provider) {
    String text = "OFFLINE";
    Color color = Colors.white10;
    if (provider.isStreaming) {
      text = "● LIVE";
      color = Colors.red;
    } else if (provider.isPaused) {
      text = "PAUSED";
      color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildMiniStatus(StreamingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
      child: const Text("LIVE", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
