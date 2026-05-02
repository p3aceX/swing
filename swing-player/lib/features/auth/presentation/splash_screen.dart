import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controller/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    if (authState.status != AuthStatus.loading) {
      // Delay navigation to let animation play
      Future.delayed(const Duration(milliseconds: 2400), () {
        if (!mounted) return;
        context.go(authState.isAuthenticated ? '/home' : '/login');
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Image.asset(
          'assets/logo/splash.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
