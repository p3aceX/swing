import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

/// On-screen camera preview for preflight and pre-stream UI.
///
/// Uses the official `camera` plugin (CameraX/AVFoundation under the hood) for a
/// simple full-screen preview. Pedro's pipeline only takes ownership of the camera
/// once the user starts streaming — by then this widget is disposed and pedro
/// initialises against a free camera.
class SwingCameraPreview extends StatefulWidget {
  final bool isVertical;
  final bool useFrontCamera;
  final double zoom;

  const SwingCameraPreview({
    super.key,
    this.isVertical = true,
    this.useFrontCamera = false,
    this.zoom = 1.0,
  });

  @override
  State<SwingCameraPreview> createState() => _SwingCameraPreviewState();
}

class _SwingCameraPreviewState extends State<SwingCameraPreview> {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void didUpdateWidget(covariant SwingCameraPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.useFrontCamera != widget.useFrontCamera) {
      _switchLens();
    } else if (oldWidget.zoom != widget.zoom) {
      _applyZoom(widget.zoom);
    }
  }

  Future<void> _bootstrap() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;
    await _bindController(widget.useFrontCamera);
  }

  Future<void> _switchLens() async {
    final old = _controller;
    _controller = null;
    if (mounted) setState(() {});
    await old?.dispose();
    await _bindController(widget.useFrontCamera);
  }

  Future<void> _bindController(bool front) async {
    if (_cameras.isEmpty) return;
    final desired = front ? CameraLensDirection.front : CameraLensDirection.back;
    final cam = _cameras.firstWhere(
      (c) => c.lensDirection == desired,
      orElse: () => _cameras.first,
    );
    final controller = CameraController(
      cam,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await controller.initialize();
    if (!mounted) {
      await controller.dispose();
      return;
    }
    if (widget.zoom != 1.0) {
      try {
        await controller.setZoomLevel(widget.zoom);
      } catch (_) {}
    }
    setState(() => _controller = controller);
  }

  Future<void> _applyZoom(double z) async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    try {
      final min = await c.getMinZoomLevel();
      final max = await c.getMaxZoomLevel();
      await c.setZoomLevel(z.clamp(min, max));
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return const ColoredBox(color: Colors.black);
    }
    // CameraPreview reports the sensor-natural size; on a portrait phone with
    // a landscape sensor, the preview's intrinsic aspect is landscape. Wrap in
    // FittedBox(cover) so it fills the screen with a slight crop instead of
    // letterboxing, matching the expected "full-screen camera" feel.
    final size = c.value.previewSize ?? const Size(1080, 1920);
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.height,
          height: size.width,
          child: CameraPreview(c),
        ),
      ),
    );
  }
}
