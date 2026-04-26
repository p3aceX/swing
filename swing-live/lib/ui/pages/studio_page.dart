import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../providers/streaming_provider.dart';
import '../../framework/swing_camera_preview.dart';

class StudioPage extends StatefulWidget {
  const StudioPage({super.key});

  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> {
  final ValueNotifier<double> _zoomLevel = ValueNotifier<double>(1.0);
  bool _isUIVisible = true;
  bool _showStats = false;
  Timer? _sleepTimer;
  bool? _lastIsLandscape;
  int _buildCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initStudio();
      _resetSleepTimer();
    });
  }

  @override
  void dispose() {
    debugPrint('[STUDIO_DEBUG] StudioPage DISPOSED\n${StackTrace.current}');
    _zoomLevel.dispose();
    _sleepTimer?.cancel();
    super.dispose();
  }

  void _resetSleepTimer() {
    _sleepTimer?.cancel();
    final provider = context.read<StreamingProvider>();

    if (provider.isBatterySaverActive) {
      provider.toggleBatterySaver();
    }

    _sleepTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && !provider.isBatterySaverActive) {
        provider.toggleBatterySaver();
      }
    });
  }

  Future<void> _initStudio() async {
    debugPrint("[UI_DEBUG] StudioPage: Initializing hardware...");
    await context.read<StreamingProvider>().startHardware();
  }

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    debugPrint('[STUDIO_DEBUG] StudioPage build #$_buildCount');
    final provider = context.watch<StreamingProvider>();

    // Use MediaQuery instead of NativeDeviceOrientationReader — NDOP uses an
    // internal LayoutBuilder that deactivates its entire subtree on window-insets
    // changes triggered by AndroidView virtual display creation, which was the
    // root cause of SwingCameraPreview being repeatedly torn down and remounted.
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (_lastIsLandscape != isLandscape) {
      _lastIsLandscape = isLandscape;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<StreamingProvider>().setOrientation(!isLandscape);
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          _resetSleepTimer();
          if (!_isUIVisible) {
            setState(() => _isUIVisible = true);
          }
        },
        onPanUpdate: (_) => _resetSleepTimer(),
        child: Stack(
          children: [
            // 1. FULLSCREEN PREVIEW
            // Consumer.child keeps SwingCameraPreview stable across provider
            // rebuilds. Camera preview is now a sibling of all overlay widgets
            // rather than a descendant, so nothing above it can tear it down.
            Positioned.fill(
              child: Consumer<StreamingProvider>(
                builder: (context, p, cameraPreview) {
                  debugPrint('[CONSUMER_DEBUG] Consumer rebuilt: controller=${p.controller != null}, error="${p.errorMessage}", cameraPreview_identity=${cameraPreview.hashCode}');
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      cameraPreview!,
                      if (p.errorMessage.isNotEmpty)
                        _buildErrorView(p)
                      else if (p.controller == null)
                        const Center(
                            child: CircularProgressIndicator(
                                color: Colors.redAccent)),
                    ],
                  );
                },
                child: const SwingCameraPreview(),
              ),
            ),

            // 2. BATTERY SAVER OVERLAY
            if (provider.isBatterySaverActive)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withAlpha(250),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.nights_stay,
                            color: Colors.white10, size: 80),
                        const SizedBox(height: 20),
                        const Text("IDLE PROTECTION",
                            style: TextStyle(
                                color: Colors.white12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2)),
                        const SizedBox(height: 8),
                        const Text("Tap to wake screen",
                            style:
                                TextStyle(color: Colors.white10, fontSize: 10)),
                      ],
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 2000.ms),
                  ),
                ),
              ),

            // 3. INTERACTIVE OVERLAYS
            if (_isUIVisible && !provider.isBatterySaverActive)
              RepaintBoundary(
                child: SafeArea(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 10,
                        left: 15,
                        right: 15,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new,
                                  color: Colors.white, size: 24),
                              onPressed: () async {
                                final nav = Navigator.of(context);
                                HapticFeedback.lightImpact();
                                await context
                                    .read<StreamingProvider>()
                                    .fullShutdown();
                                nav.pop();
                              },
                            ),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _showStats = !_showStats),
                              child: const _StatusBadge()
                                  .animate()
                                  .fadeIn()
                                  .scale(),
                            ),
                            IconButton(
                              icon: Icon(
                                  _showStats
                                      ? Icons.analytics
                                      : Icons.analytics_outlined,
                                  color: Colors.white,
                                  size: 24),
                              onPressed: () =>
                                  setState(() => _showStats = !_showStats),
                            ),
                          ],
                        ),
                      ),

                      if (_showStats)
                        Positioned(
                          top: 70,
                          left: 15,
                          right: 15,
                          child: _buildStatsDashboard()
                              .animate()
                              .fadeIn()
                              .slideY(begin: -0.1),
                        ),

                      Positioned(
                        right: 10,
                        top: 150,
                        bottom: 150,
                        child: _buildZoomSlider()
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideX(begin: 0.5),
                      ),

                      Positioned(
                        left: 15,
                        bottom: isLandscape ? 20 : 120,
                        child: _buildSideControls(provider)
                            .animate()
                            .fadeIn(delay: 300.ms)
                            .slideX(begin: -0.5),
                      ),

                      Positioned(
                        bottom: 30,
                        left: 0,
                        right: 0,
                        child: _buildMainActionButton(provider),
                      ),
                    ],
                  ),
                ),
              ),

            if (!_isUIVisible && !provider.isBatterySaverActive)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: const Center(
                  child: Text(
                    "TAP TO REVEAL CONTROLS",
                    style: TextStyle(
                        color: Colors.white12,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1),
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 1000.ms),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(StreamingProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              provider.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: provider.startHardware,
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.white10),
            child:
                const Text("RETRY", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDashboard() {
    final provider = context.watch<StreamingProvider>();
    final duration = provider.streamDuration;
    final timeStr =
        "${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(180),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("DURATION", timeStr, Icons.timer),
              _buildStatItem(
                  "DATA SENT",
                  "${provider.totalDataSentMB.toStringAsFixed(1)} MB",
                  Icons.cloud_upload),
              _buildStatItem(
                  "BITRATE",
                  provider.isStreaming
                      ? "${(provider.quality.bitrate / 1000000).toStringAsFixed(1)} Mbps"
                      : "0 Mbps",
                  Icons.speed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.redAccent, size: 16),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14)),
        Text(label,
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 8,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildZoomSlider() {
    return Container(
      width: 44,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(100),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: RotatedBox(
        quarterTurns: 3,
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 5),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: Colors.redAccent,
            inactiveTrackColor: Colors.white12,
            thumbColor: Colors.white,
          ),
          child: ValueListenableBuilder<double>(
            valueListenable: _zoomLevel,
            builder: (context, zoom, _) {
              return Slider(
                value: zoom,
                min: 1.0,
                max: 4.0,
                onChanged: (v) {
                  _resetSleepTimer();
                  if ((v - zoom).abs() > 0.02) {
                    _zoomLevel.value = v;
                    context.read<StreamingProvider>().setZoom(v);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSideControls(StreamingProvider provider) {
    return Column(
      children: [
        _CircleButton(
          icon: provider.isMuted ? Icons.mic_off : Icons.mic,
          color: provider.isMuted
              ? Colors.red.withAlpha(200)
              : Colors.black45,
          onPressed: () {
            _resetSleepTimer();
            provider.toggleMute();
          },
        ),
        const SizedBox(height: 15),
        _CircleButton(
          icon: Icons.flip_camera_ios,
          color: Colors.black45,
          onPressed: () {
            _resetSleepTimer();
            provider.toggleCamera();
          },
        ),
      ],
    );
  }

  Widget _buildMainActionButton(StreamingProvider provider) {
    if (!provider.isStreaming) {
      return Center(
        child: GestureDetector(
          onTap: () {
            _resetSleepTimer();
            provider.start();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [BoxShadow(color: Colors.redAccent.withAlpha(80), blurRadius: 20, spreadRadius: 2)],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text("START BROADCAST", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5);
    }

    // Live controls: pause/resume + stop
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pause / Resume
          GestureDetector(
            onTap: () {
              _resetSleepTimer();
              if (provider.isPaused) {
                provider.resumeStream();
              } else {
                provider.pauseStream();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: provider.isPaused ? Colors.orangeAccent.withAlpha(220) : Colors.white12,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: provider.isPaused ? Colors.orangeAccent : Colors.white24, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(provider.isPaused ? Icons.play_arrow : Icons.pause, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    provider.isPaused ? "RESUME" : "PAUSE",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Stop (long-press required to avoid accidental stops)
          GestureDetector(
            onLongPress: () {
              _resetSleepTimer();
              provider.stop();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(180),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [BoxShadow(color: Colors.red.withAlpha(60), blurRadius: 12, spreadRadius: 1)],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stop, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text("STOP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                ],
              ),
            ),
          ),
        ],
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StreamingProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
            color: provider.isStreaming ? Colors.red : Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: provider.isStreaming ? Colors.red : Colors.greenAccent,
              shape: BoxShape.circle,
            ),
          )
              .animate(
                  onPlay: (c) =>
                      provider.isStreaming ? c.repeat() : c.stop())
              .scale(
                  duration: 800.ms,
                  begin: const Offset(1, 1),
                  end: const Offset(1.3, 1.3))
              .then()
              .scale(
                  duration: 800.ms,
                  begin: const Offset(1.3, 1.3),
                  end: const Offset(1, 1)),
          const SizedBox(width: 12),
          Text(
            provider.isStreaming ? "LIVE" : "READY",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _CircleButton(
      {required this.icon, required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white10),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
