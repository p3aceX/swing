import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'streaming/stream_controller.dart';
import 'ui/live_page.dart';
import 'ui/login_page.dart';

/// Global route observer so widgets that own scarce resources (e.g. the
/// camera in PreStreamPreview) can release them the moment they're hidden
/// by a pushed route, and re-acquire when revealed again.
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // LANDSCAPE-ONLY app. Cricket is shot in landscape; trying to support
  // portrait kept introducing race conditions where Pedro's encoder read
  // Display.getRotation() before SystemChrome had actually applied the
  // user's choice. Locking app-wide at boot means the rotation is settled
  // before any UI even renders.
  SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const SwingLiveApp());
}

class SwingLiveApp extends StatelessWidget {
  const SwingLiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StreamController()..init(),
      child: MaterialApp(
        title: 'Swing Live',
        debugShowCheckedModeBanner: false,
        navigatorObservers: [appRouteObserver],
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
        ),
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final phase = context.watch<StreamController>().phase;
    if (phase == StreamPhase.signedOut) return const LoginPage();
    return const LivePage();
  }
}
