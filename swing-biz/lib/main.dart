import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/api/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env is optional — fall back to canonical backend URL.
  }
  await Firebase.initializeApp();

  runApp(
    ProviderScope(
      overrides: [hostDioOverride],
      child: const SwingBizApp(),
    ),
  );
}
