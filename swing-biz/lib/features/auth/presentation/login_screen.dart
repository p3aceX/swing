import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../controller/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reset auth state when entering login screen to clear any stale step/error
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      ref.read(authControllerProvider.notifier).resetToPhone();
    });
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final auth = ref.read(authControllerProvider);
    if (auth.loading) return;

    final normalized = _digitsOnly(_phoneCtrl.text);
    final phone = '+91$normalized';

    try {
      final result =
          await ref.read(authControllerProvider.notifier).checkPhone(phone);
      if (!mounted) return;

      if (result.exists) {
        await ref
            .read(authControllerProvider.notifier)
            .sendOtp(result.normalizedPhone);
        if (!mounted) return;
        final updated = ref.read(authControllerProvider);
        if (updated.step == AuthStep.otp || updated.step == AuthStep.name) {
          context.go(AppRoutes.otp);
        }
      } else {
        context.go(
            '${AppRoutes.register}?phone=${Uri.encodeComponent(result.normalizedPhone)}');
      }
    } catch (_) {
      // Error handled by AuthController listener.
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final normalized = _digitsOnly(_phoneCtrl.text);
    final isValid = normalized.length == 10;

    ref.listen(authControllerProvider, (prev, next) {
      if (next.error != null && prev?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _AuthLogoMark(size: 156),
                    const SizedBox(height: 20),
                    Text(
                      'Login',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF101828),
                        height: 1,
                        letterSpacing: -0.8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 28),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x12000000),
                            blurRadius: 28,
                            offset: Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Mobile number',
                              style: TextStyle(
                                color: Color(0xFF101828),
                                fontSize: 18,
                                height: 1.2,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              autofocus: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Mobile number',
                                hintText: '98765 43210',
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(left: 16, right: 10),
                                  child: Center(
                                    widthFactor: 1,
                                    child: Text(
                                      '+91',
                                      style: TextStyle(
                                        color: Color(0xFF101828),
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 0,
                                  minHeight: 0,
                                ),
                                errorText: _phoneCtrl.text.isEmpty || isValid
                                    ? null
                                    : 'Enter a valid 10-digit number',
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 18),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF101828),
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              onPressed:
                                  !isValid || auth.loading ? null : _onContinue,
                              child: auth.loading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                  )
                                  : const Text('Send OTP'),
                            ),
                            const SizedBox(height: 14),
                            const _TermsNotice(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _digitsOnly(String raw) => raw.characters
      .where((c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57)
      .join();
}

class _AuthLogoMark extends StatelessWidget {
  const _AuthLogoMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset('assets/logo/logo.png', fit: BoxFit.contain),
      ),
    );
  }
}

class _TermsNotice extends StatelessWidget {
  const _TermsNotice();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'By continuing, you accept the Terms & Conditions.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF667085),
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
