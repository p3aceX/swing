import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/biometric_service.dart';
import '../../../core/auth/token_storage.dart';
import '../../../core/api/api_client.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/router/app_router.dart';

class BiometricScreen extends ConsumerStatefulWidget {
  const BiometricScreen({super.key});

  @override
  ConsumerState<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends ConsumerState<BiometricScreen> {
  bool _loading = false;
  String? _error;
  String? _phone;

  @override
  void initState() {
    super.initState();
    _loadPhone();
    // Auto-trigger on open
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _loadPhone() async {
    final p = await TokenStorage.getBiometricPhone();
    await BiometricService.instance.isAvailable();
    if (mounted) {
      setState(() {
        _phone = p;
      });
    }
  }

  Future<void> _authenticate() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final passed = await BiometricService.instance.authenticate();
      if (!passed) {
        if (mounted) {
          setState(() {
            _loading = false;
            _error = 'Verification failed. Try again.';
          });
        }
        return;
      }
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '[${e.code}] ${e.message}';
        });
      }
      return;
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Error: $e';
        });
      }
      return;
    }

    // Biometric passed — verify token is still valid
    try {
      final refreshToken = await TokenStorage.getRefreshToken();

      if (refreshToken == null) {
        _fallbackToOtp();
        return;
      }

      await ApiClient.instance.refreshSessionToken();
      await ApiClient.instance.dio.get('/biz/me');

      // Unlock the session — router will redirect to dashboard automatically
      if (mounted) {
        await ref.read(sessionControllerProvider.notifier).unlockSession();
      }
    } catch (_) {
      _fallbackToOtp();
    }
  }

  Future<void> _fallbackToOtp() async {
    await ref.read(sessionControllerProvider.notifier).signOut();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final text = scheme.onSurface;
    final textSub = scheme.onSurface.withValues(alpha: 0.6);
    final accent = scheme.primary;
    final accentDim = scheme.primary.withValues(alpha: 0.12);
    final border = scheme.outline;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 3),
                // Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration:
                          const BoxDecoration(color: Colors.transparent),
                      padding: const EdgeInsets.all(2),
                      child: Image.asset('assets/logo/logo.png',
                          fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      'Swing.',
                      style: TextStyle(
                        fontFamily: 'SwingLogoFont',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: text,
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 2),
                // Biometric icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: accentDim,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: accent.withValues(alpha: 0.1), width: 1),
                  ),
                  child: _loading
                      ? Padding(
                          padding: const EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: accent,
                          ),
                        )
                      : Icon(Icons.fingerprint_rounded,
                          color: accent, size: 52),
                ),
                const SizedBox(height: 32),
                Text(
                  'Welcome back',
                  style: TextStyle(
                    color: text,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _phone != null
                      ? 'Verify identity for $_phone'
                      : 'Verify your identity to continue',
                  style: TextStyle(
                      color: textSub,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    _error!,
                    style: TextStyle(
                        color: scheme.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ],
                const Spacer(flex: 2),
                // Retry button
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _authenticate,
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      disabledBackgroundColor: border,
                      foregroundColor: scheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: const Text('Use Biometric'),
                  ),
                ),
                const SizedBox(height: 16),
                // Use OTP instead
                GestureDetector(
                  onTap: _fallbackToOtp,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Use phone number instead',
                      style: TextStyle(
                        color: textSub,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: border,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
