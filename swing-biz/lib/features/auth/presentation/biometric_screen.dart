import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/biometric_service.dart';
import '../../../core/auth/token_storage.dart';
import '../../../core/api/api_client.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/router/app_router.dart';

const _bg = Color(0xFFFFFFFF);
const _border = Color(0xFFE2E8F0);
const _accent = Color(0xFF059669);
const _accentDim = Color(0xFFD1FAE5);
const _text = Color(0xFF0F172A);
const _textSub = Color(0xFF64748B);

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
    final available = await BiometricService.instance.isAvailable();
    debugPrint('Biometrics: isAvailable=$available phone=$p');
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
      debugPrint('Biometrics: PlatformException ${e.code} - ${e.message}');
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
    debugPrint('Biometrics: Auth successful, verifying tokens...');
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      debugPrint('Biometrics: Refresh token found: ${refreshToken != null}');

      if (refreshToken == null) {
        debugPrint('Biometrics: No refresh token, falling back to OTP');
        _fallbackToOtp();
        return;
      }

      debugPrint('Biometrics: Refreshing session token...');
      await ApiClient.instance.refreshSessionToken();
      debugPrint('Biometrics: Calling /biz/me to verify session...');
      await ApiClient.instance.dio.get('/biz/me');
      debugPrint('Biometrics: Session verified. Unlocking...');

      // Unlock the session — router will redirect to dashboard automatically
      if (mounted) {
        await ref.read(sessionControllerProvider.notifier).unlockSession();
        debugPrint('Biometrics: Session unlocked.');
      }
    } catch (e) {
      debugPrint('Biometrics: Token verification failed: $e');
      _fallbackToOtp();
    }
  }

  Future<void> _fallbackToOtp() async {
    await ref.read(sessionControllerProvider.notifier).signOut();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bg,
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
                        color: _text,
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
                    color: _accentDim,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _accent.withValues(alpha: 0.1), width: 1),
                  ),
                  child: _loading
                      ? const Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: _accent,
                          ),
                        )
                      : const Icon(Icons.fingerprint_rounded,
                          color: _accent, size: 52),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    color: _text,
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
                  style: const TextStyle(
                      color: _textSub,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    _error!,
                    style: const TextStyle(
                        color: Color(0xFFDC2626),
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
                      backgroundColor: _accent,
                      disabledBackgroundColor: _border,
                      foregroundColor: Colors.white,
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
                        color: _textSub,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: _border,
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
