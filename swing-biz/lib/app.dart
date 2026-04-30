import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/session_controller.dart';
import 'core/auth/token_storage.dart';
import 'core/notifications/onesignal_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class SwingBizApp extends ConsumerStatefulWidget {
  const SwingBizApp({super.key});

  @override
  ConsumerState<SwingBizApp> createState() => _SwingBizAppState();
}

class _SwingBizAppState extends ConsumerState<SwingBizApp>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      ref.read(sessionControllerProvider.notifier).lockSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    // Hand the router to OneSignal so tap-to-open works
    OneSignalService.instance.router = router;
    return MaterialApp.router(
      title: 'Swing Biz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
