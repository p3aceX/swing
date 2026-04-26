import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/streaming_provider.dart';
import 'ui/pages/setup_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SwingLiveApp());
}

class SwingLiveApp extends StatelessWidget {
  const SwingLiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StreamingProvider()),
      ],
      child: MaterialApp(
        title: 'Swing Live Studio',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.red,
          scaffoldBackgroundColor: Colors.black,
          fontFamily: 'Inter', // Modern clean font look
        ),
        home: const SetupPage(),
      ),
    );
  }
}
