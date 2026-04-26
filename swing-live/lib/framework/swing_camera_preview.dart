import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class SwingCameraPreview extends StatefulWidget {
  final bool isVertical;

  const SwingCameraPreview({super.key, this.isVertical = true});

  @override
  State<SwingCameraPreview> createState() => _SwingCameraPreviewState();
}

class _SwingCameraPreviewState extends State<SwingCameraPreview> {
  static int _instanceCount = 0;
  late final int _id;

  @override
  void initState() {
    super.initState();
    _id = ++_instanceCount;
    debugPrint('[PREVIEW_DEBUG] SwingCameraPreview #$_id initState\n${StackTrace.current}');
  }

  @override
  void dispose() {
    debugPrint('[PREVIEW_DEBUG] SwingCameraPreview #$_id dispose\n${StackTrace.current}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String viewType = 'com.dhandha.swing/camera_view';

    if (defaultTargetPlatform == TargetPlatform.android) {
      return const AndroidView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: <String, dynamic>{},
        creationParamsCodec: StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: <String, dynamic>{},
        creationParamsCodec: StandardMessageCodec(),
      );
    }

    return const Center(child: Text('Platform not supported'));
  }
}
