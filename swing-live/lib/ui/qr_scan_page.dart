import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen QR scanner for pairing with the Swing Studio desktop UI.
///
/// The studio web page renders a QR encoding
/// `swinglive://studio?server=<ip>&key=<streamkey>`. On a successful
/// scan we pop with a `Map<String, String>` of `{server, key}`. Back
/// button pops with `null`.
class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  /// Guard against the multi-detection avalanche while the QR is on
  /// screen — we only want to pop once.
  bool _scanned = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    for (final code in capture.barcodes) {
      final raw = code.rawValue;
      if (raw == null || raw.isEmpty) continue;
      final uri = Uri.tryParse(raw);
      if (uri == null) continue;
      if (uri.scheme != 'swinglive') continue;
      // Accept either swinglive://studio?... or swinglive:studio?...
      final isStudio = uri.host == 'studio' ||
          uri.path == 'studio' ||
          uri.path == '/studio';
      if (!isStudio) continue;
      final server = uri.queryParameters['server'];
      if (server == null || server.isEmpty) continue;
      final key = uri.queryParameters['key'] ?? '';
      _scanned = true;
      final nav = Navigator.of(context);
      // Stop the camera before popping to be sure no more detection
      // callbacks queue up after we've decided to leave.
      _controller.stop();
      // Capture `nav` synchronously so the post-pop microtask can't
      // race against widget unmount. One-shot — never reset `_scanned`
      // (a stray second pop would drop the user past StudioPage to home).
      Future.microtask(() {
        if (mounted) {
          nav.pop(<String, String>{'server': server, 'key': key});
        }
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, _) {
              final msg = _friendlyError(error);
              return _ErrorState(message: msg);
            },
          ),
          // Soft cutout / scan-area hint.
          IgnorePointer(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.72,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white70, width: 2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Hint label below the cutout.
          const Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: 32),
                child: Text(
                  'POINT AT STUDIO QR',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.4,
                  ),
                ),
              ),
            ),
          ),
          // Back button.
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              bottom: false,
              right: false,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 26),
                  ),
                ),
              ),
            ),
          ),
          if (_error != null)
            Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 64, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    color: Colors.black54,
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _friendlyError(MobileScannerException error) {
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return 'CAMERA PERMISSION DENIED.\nENABLE IT IN SETTINGS TO SCAN.';
      case MobileScannerErrorCode.unsupported:
        return 'SCANNING IS NOT SUPPORTED ON THIS DEVICE.';
      default:
        return 'CAMERA UNAVAILABLE.';
    }
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.8,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}
