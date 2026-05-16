import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../main.dart' show appRouteObserver;

/// Stock-quality preview using the official camera plugin. Owns the camera
/// only while mounted AND visible — unmounting OR being covered by a
/// pushed route releases it. This lets the next consumer (Pedro for RTMP,
/// flutter_webrtc for Studio Mode) acquire the camera cleanly.
class PreStreamPreview extends StatefulWidget {
  const PreStreamPreview({super.key});

  @override
  State<PreStreamPreview> createState() => _PreStreamPreviewState();
}

class _PreStreamPreviewState extends State<PreStreamPreview>
    with WidgetsBindingObserver, RouteAware {
  CameraController? _controller;
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bind();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) appRouteObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      c.dispose();
      _controller = null;
      if (mounted) setState(() {});
    } else if (state == AppLifecycleState.resumed) {
      _bind();
    }
  }

  // RouteAware: another route was pushed on top of us. Release the camera
  // so the new screen (Studio Mode) can acquire it. Re-bind when it pops.
  @override
  void didPushNext() {
    _controller?.dispose();
    _controller = null;
    if (mounted) setState(() {});
  }

  @override
  void didPopNext() {
    _bind();
  }

  Future<void> _bind() async {
    setState(() => _initializing = true);
    final cams = await availableCameras();
    if (cams.isEmpty) {
      if (mounted) setState(() => _initializing = false);
      return;
    }
    final back = cams.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cams.first,
    );
    final c = CameraController(
      back,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    try {
      await c.initialize();
    } catch (_) {
      if (mounted) setState(() => _initializing = false);
      return;
    }
    if (!mounted) {
      await c.dispose();
      return;
    }
    setState(() {
      _controller = c;
      _initializing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: _initializing
            ? const SizedBox(
                width: 24,
                height: 24,
                child:
                    CircularProgressIndicator(strokeWidth: 2, color: Colors.white24),
              )
            : null,
      );
    }
    return Center(
      child: CameraPreview(c),
    );
  }
}
