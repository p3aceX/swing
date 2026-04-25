import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_host_core/flutter_host_core.dart'
    show HostPathConfig, hostDioProvider, hostPathConfigProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/api/api_client.dart';
import 'core/bootstrap/app_bootstrap.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Local development can run without an env file.
  }

  await AppBootstrap.initialize();

  final firebaseAvailable = await _initializeFirebase();

  if (firebaseAvailable && kDebugMode) {
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        hostDioProvider.overrideWithValue(ApiClient.instance.dio),
        hostPathConfigProvider.overrideWithValue(HostPathConfig.player()),
      ],
      child: const SwingPlayerApp(),
    ),
  );
}

Future<bool> _initializeFirebase() async {
  if (Firebase.apps.isNotEmpty) {
    return true;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return true;
  } on UnsupportedError {
    return false;
  }
}
