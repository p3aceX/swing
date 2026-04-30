import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/api/providers.dart';
import 'core/notifications/onesignal_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OneSignalService.instance.initialize();
  runApp(
    ProviderScope(
      overrides: [hostDioOverride],
      child: const SwingBizApp(),
    ),
  );
}
