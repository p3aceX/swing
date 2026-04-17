import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/auth_controller.dart';
import 'auth_scaffold.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    if (authState.status != AuthStatus.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go(authState.isAuthenticated ? '/home' : '/login');
      });
    }

    return AuthScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _controller,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: context.accentBg,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: context.accent.withValues(alpha: 0.28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.accent.withValues(alpha: 0.10),
                      blurRadius: 28,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.sports_cricket,
                  size: 48,
                  color: context.accent,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'SWING',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 40,
                    letterSpacing: -1.3,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Identity-first cricket for serious players.',
              style: TextStyle(color: context.fgSub),
            ),
          ],
        ),
      ),
    );
  }
}
