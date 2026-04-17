import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/controller/auth_controller.dart';
import 'features/profile/controller/profile_controller.dart';
import 'features/profile/domain/rank_visual_theme.dart';

final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.dark);

class SwingPlayerApp extends ConsumerStatefulWidget {
  const SwingPlayerApp({super.key});

  @override
  ConsumerState<SwingPlayerApp> createState() => _SwingPlayerAppState();
}

class _SwingPlayerAppState extends ConsumerState<SwingPlayerApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: _onResume,
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _onResume() {
    // App came to foreground — silently re-fetch profile so rank / data
    // is always current without showing any loading indicator.
    ref.read(profileControllerProvider.notifier).silentRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authControllerProvider);

    // Attempt to use live profile rank for the best theme experience
    final profileState = ref.watch(profileControllerProvider);
    final currentRank = profileState.data?.rankProgress.rank ?? authState.userRank;

    final rankTheme = resolveRankVisualTheme(currentRank);

    return MaterialApp.router(
      title: 'Swing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(rankTheme),
      darkTheme: AppTheme.darkTheme(rankTheme),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
