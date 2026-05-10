import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/streaming_provider.dart';
import 'core/studio/p2p_studio_manager.dart';
import 'ui/pages/splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const SwingLiveApp());
}

class SwingLiveApp extends StatelessWidget {
  const SwingLiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StreamingProvider()),
        ChangeNotifierProvider(create: (_) => P2PStudioManager()),
      ],
      child: MaterialApp(
        title: 'Swing Live Studio',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.red,
          scaffoldBackgroundColor: Colors.black,
          cardColor: const Color(0xFF121212),
          appBarTheme: const AppBarTheme(backgroundColor: Colors.black, elevation: 0),
          fontFamily: 'Inter',
        ),
        home: const SplashPage(),
      ),
    );
  }
}
