import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/studio/p2p_studio_manager.dart';
import '../../providers/streaming_provider.dart';
import '../../framework/swing_camera_preview.dart';

class MultiViewStudioPage extends StatefulWidget {
  const MultiViewStudioPage({super.key});

  @override
  State<MultiViewStudioPage> createState() => _MultiViewStudioPageState();
}

class _MultiViewStudioPageState extends State<MultiViewStudioPage> {
  String? _activeNodeId = "LOCAL"; // Default to local camera

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StreamingProvider>().startHardware();
    });
  }

  @override
  Widget build(BuildContext context) {
    final studio = context.watch<P2PStudioManager>();
    final streaming = context.watch<StreamingProvider>();
    final remoteRenderers = studio.remoteRenderers;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Column(
          children: [
            Text(studio.isStudio ? "MASTER CONTROL CENTER" : "PRO MIXER", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
            if (studio.dashboardUrl != null)
              Text("REMOTE DASHBOARD: ${studio.dashboardUrl}", style: const TextStyle(fontSize: 9, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.emergency_recording, color: Colors.red), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. PROGRAM VIEW
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent, width: 3),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.redAccent.withAlpha(30), blurRadius: 20)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_activeNodeId == "LOCAL")
                        Consumer<StreamingProvider>(
                          builder: (context, p, _) {
                            if (p.controller == null) return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                            return SwingCameraPreview();
                          },
                        )
                      else if (_activeNodeId != null && remoteRenderers.containsKey(_activeNodeId))
                        RTCVideoView(remoteRenderers[_activeNodeId]!, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
                      else
                        _buildNoSignalView(),
                      
                      _buildOverlayTag("ON AIR", Colors.red),
                    ],
                  ),
                ),
              ),
            ),

            // 2. MULTI-VIEW GRID (Preview all cameras)
            Expanded(
              flex: 2,
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 16/9,
                ),
                itemCount: remoteRenderers.length + 1, // +1 for Local Camera
                itemBuilder: (context, index) {
                  // Local camera is always first
                  if (index == 0) {
                    return _buildPreviewCard("LOCAL", null, isLocal: true);
                  }

                  final nodeId = remoteRenderers.keys.elementAt(index - 1);
                  final renderer = remoteRenderers[nodeId]!;
                  return _buildPreviewCard(nodeId, renderer);
                },
              ),
            ),

            // 3. STUDIO CONTROLS
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[900],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(Icons.grid_view, "Layout"),
                  _buildActionButton(Icons.layers, "Overlays"),
                  _buildActionButton(Icons.settings, "Audio"),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => streaming.start(),
                    icon: const Icon(Icons.radio_button_checked),
                    label: const Text("GO LIVE"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(String id, RTCVideoRenderer? renderer, {bool isLocal = false}) {
    final bool isActive = _activeNodeId == id || (isLocal && _activeNodeId == "LOCAL");
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeNodeId = isLocal ? "LOCAL" : id;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: isActive ? Colors.greenAccent : Colors.white10, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withAlpha(5),
          boxShadow: isActive ? [BoxShadow(color: Colors.greenAccent.withAlpha(20), blurRadius: 10)] : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (renderer != null)
                RTCVideoView(renderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
              else if (isLocal)
                Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isActive ? Icons.videocam : Icons.videocam_off, color: isActive ? Colors.greenAccent : Colors.white24, size: 24),
                        const SizedBox(height: 4),
                        const Text("LOCAL", style: TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              else
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              
              if (isActive)
                _buildOverlayTag("LIVE", Colors.greenAccent.withAlpha(200)),
              
              Positioned(
                bottom: 6,
                left: 6,
                child: Text(
                  isLocal ? "HUB CAMERA" : "CAM \${id.substring(0, 4)}",
                  style: const TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoSignalView() {
    return Container(
      color: const Color(0xFF111111),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sensors_off, color: Colors.white10, size: 48),
            const SizedBox(height: 16),
            Text("NO SIGNAL", style: TextStyle(color: Colors.white.withAlpha(20), fontWeight: FontWeight.w900, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayTag(String label, Color color) {
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 8)),
      ],
    );
  }
}
