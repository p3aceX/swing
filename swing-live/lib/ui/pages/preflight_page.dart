import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/streaming_provider.dart';
import '../../framework/pedro_stream_view.dart';
import '../../overlays/packs/basic/basic_pack.dart';
import 'studio_page.dart';

class PreflightPage extends StatefulWidget {
  const PreflightPage({super.key});

  @override
  State<PreflightPage> createState() => _PreflightPageState();
}

class _PreflightPageState extends State<PreflightPage>
    with WidgetsBindingObserver {
  final ValueNotifier<double> _zoomLevel = ValueNotifier<double>(1.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start Pedro now (preview only, no streaming yet) so preflight and
    // studio show the exact same pipeline. Pedro stays alive across the
    // navigation to StudioPage — `startHardware()` is idempotent.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<StreamingProvider>().startHardware();
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the app comes back from background, Pedro's GL surface is dead.
    // Re-bootstrap so the preview returns instead of leaving a transparent
    // PlatformView hole that lets the Setup page show through.
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<StreamingProvider>().ensurePreviewAlive();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Restore system bars when leaving the preflight page.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _zoomLevel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StreamingProvider>();
    final bool isLandscape = provider.isLandscape;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Material(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 0. SOLID BLACK BASE
            const Positioned.fill(child: ColoredBox(color: Colors.black)),

            // 1. STABLE CAMERA PREVIEW
            AnimatedCrossFade(
              firstChild: SizedBox.expand(
                child: ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.redAccent, strokeWidth: 2),
                        const SizedBox(height: 16),
                        Text("INITIALIZING CAMERA...", 
                          style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ],
                    ),
                  ),
                ),
              ),
              secondChild: const SizedBox.expand(child: PedroStreamView()),
              crossFadeState: provider.isCameraReady ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: 600.ms,
            ),

            // 2. CONTROLS LAYER
            SafeArea(
              child: _buildPositionedControls(context, provider, isLandscape),
            ),

            // 3. BROADCAST OVERLAY
            if (provider.bootstrap != null)
              _buildPositionedOverlay(context, provider),
          ],
        ),
      ),
    );
  }

  /// Same pattern as _buildPositionedOverlay: in portrait, fill the
  /// Flutter window; in landscape, position a 914×411 canvas with
  /// negative `left` so it overflows past the portrait window, then
  /// counter-rotate to fit.
  Widget _buildPositionedControls(
      BuildContext context, StreamingProvider provider, bool isLandscape) {
    final hasOverlay = provider.bootstrap != null;
    final controls = Stack(
      fit: StackFit.expand,
      children: [
        // TOP HUD
        Positioned(
          top: 40,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBackBtn(),
              _buildSystemHUD(provider),
              _buildNetworkPill(provider),
            ],
          ),
        ),

        // SIDE TOOLS — in landscape, split: controls (flip/mic/mode) on
        // left, zoom slider on right. In portrait, unified on the right.
        if (isLandscape) ...[
          Positioned(
            left: 20,
            top: 100,
            bottom: 100,
            child: _buildControlsConsole(provider),
          ),
          Positioned(
            right: 20,
            top: 100,
            bottom: 100,
            child: _buildZoomConsole(provider),
          ),
        ] else
          Positioned(
            right: 20,
            top: 100,
            bottom: 100,
            child: _buildSideConsole(provider, isLandscape),
          ),

        // ACTION BUTTON — sits above the overlay strip. Portrait strip
        // is ~120px tall (header + teams + batters + bowler), landscape
        // strip is ~76px. Plus safe-area bottom (~30px).
        Positioned(
          bottom: hasOverlay ? (isLandscape ? 130 : 200) : 60,
          left: isLandscape ? 140 : 60,
          right: isLandscape ? 140 : 60,
          child: _buildProductionBtn(context, provider),
        ),
      ],
    );

    if (!isLandscape) {
      return Positioned.fill(child: controls);
    }

    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    return Positioned(
      left: (w - h) / 2,
      top: (h - w) / 2,
      width: h,
      height: w,
      child: Transform.rotate(
        angle: -provider.deviceRotation,
        alignment: Alignment.center,
        child: controls,
      ),
    );
  }

  Widget _buildSideConsole(StreamingProvider provider, bool isLandscape) {
    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: [
          _toolBtn(Icons.flip_camera_ios, () => provider.toggleCamera()),
          const SizedBox(height: 8),
          _toolBtn(provider.isMuted ? Icons.mic_off : Icons.mic, () => provider.toggleMute()),
          const SizedBox(height: 8),
          _orientationBtn(provider),
          const Spacer(),
          const Icon(Icons.zoom_in, color: Colors.white24, size: 12),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(trackHeight: 2, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8)),
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

  Widget _buildControlsConsole(StreamingProvider provider) {
    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(25)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _toolBtn(Icons.flip_camera_ios, () => provider.toggleCamera()),
          const SizedBox(height: 12),
          _toolBtn(provider.isMuted ? Icons.mic_off : Icons.mic, () => provider.toggleMute()),
          const SizedBox(height: 12),
          _orientationBtn(provider),
        ],
      ),
    );
  }

  Widget _buildZoomConsole(StreamingProvider provider) {
    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: [
          const Icon(Icons.zoom_in, color: Colors.white24, size: 12),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(trackHeight: 2, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8)),
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
          const Icon(Icons.zoom_out, color: Colors.white24, size: 12),
        ],
      ),
    );
  }

  /// Picks the right pack and gives it the right canvas for the device's
  /// orientation, then counter-rotates so the strip lands at the user's
  /// bottom edge. Portrait pack uses Flutter's natural portrait canvas;
  /// landscape pack gets a 914×411 canvas (positioned with negative
  /// left so it extends past Flutter's portrait window — Stack allows
  /// Positioned children to overflow).
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
    // Landscape pack canvas: width = Flutter height, height = Flutter
    // width. Position it centered in the Flutter window — its natural
    // bounds extend past the window horizontally, but rotating it
    // ±90° brings the visible content back inside.
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

  Widget _toolBtn(IconData icon, VoidCallback onTap) {
    return IconButton(icon: Icon(icon, color: Colors.white, size: 20), onPressed: onTap);
  }

  /// Cycles overlay orientation: AUTO (follow device) →
  /// PORTRAIT (forced) → LANDSCAPE (forced) → AUTO.
  Widget _orientationBtn(StreamingProvider provider) {
    final override = provider.overlayLandscapeOverride;
    final IconData icon;
    final Color color;
    final String badge;
    if (override == null) {
      icon = Icons.screen_rotation;
      color = Colors.white60;
      badge = 'AUTO';
    } else if (override == false) {
      icon = Icons.stay_current_portrait;
      color = Colors.orangeAccent;
      badge = 'P';
    } else {
      icon = Icons.stay_current_landscape;
      color = Colors.orangeAccent;
      badge = 'L';
    }
    return Tooltip(
      message: 'Overlay orientation · ${override == null ? 'auto' : override ? 'landscape' : 'portrait'}',
      child: InkWell(
        onTap: provider.cycleOverlayOrientation,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              Positioned(
                bottom: 2,
                child: Text(
                  badge,
                  style: TextStyle(
                      color: color,
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductionBtn(BuildContext context, StreamingProvider provider) {
    // Red→deeper-red gradient body with a gold border + gold text.
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StudioPage()),
      ),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: provider.isResuming
                ? const [Color(0xFFD32F2F), Color(0xFF7F0000)]
                : const [Color(0xFFE53935), Color(0xFF8B0000)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFFFC107), // gold
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFC107).withAlpha(60),
              blurRadius: 10,
              spreadRadius: 0.3,
            ),
            BoxShadow(
              color: Colors.red.withAlpha(60),
              blurRadius: 16,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          provider.isResuming ? 'RESUME LIVE' : 'START LIVE',
          style: const TextStyle(
            color: Color(0xFFFFD54F), // gold text
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.6,
          ),
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2000.ms);
  }

  Widget _buildSystemHUD(StreamingProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("PRE-FLIGHT", style: TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold)),
          Text(provider.isResuming ? "RE-SYNC" : "READY", 
              style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildNetworkPill(StreamingProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
      child: Text("${(provider.networkStrength * 15).toStringAsFixed(1)} Mbps", 
          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildBackBtn() {
    return IconButton(icon: const Icon(Icons.close, color: Colors.white38), onPressed: () => Navigator.pop(context));
  }
}
