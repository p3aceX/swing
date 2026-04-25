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
      final result = await ref.read(authControllerProvider.notifier).checkPhone(phone);
      if (!mounted) return;

      if (result.exists) {
        await ref
            .read(authControllerProvider.notifier)
            .sendOtp(result.normalizedPhone);
      } else {
        context.go('${AppRoutes.register}?phone=${Uri.encodeComponent(result.normalizedPhone)}');
      }
    } catch (e) {
      // Error handled by AuthController listener
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
      final movedToAuthStep = prev?.step != next.step &&
          (next.step == AuthStep.otp || next.step == AuthStep.name);
      if (movedToAuthStep) {
        context.go(AppRoutes.otp);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF7FBFA), Color(0xFFFFFFFF)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xFFDBE5E2)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x140F172A),
                        blurRadius: 32,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Swing',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.4,
                          color: const Color(0xFF0F766E),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        'Enter your mobile number',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We will send you an OTP to continue.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF5B6B79),
                        ),
                      ),
                      const SizedBox(height: 26),
                      TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        autofocus: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Mobile number',
                          hintText: '9876543210',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 16, right: 10),
                            child: Center(
                              widthFactor: 1,
                              child: Text(
                                '+91',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w700,
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
                      const SizedBox(height: 22),
                      ElevatedButton(
                        onPressed: !isValid || auth.loading ? null : _onContinue,
                        child: auth.loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Continue'),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '10 digits only',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF8A9A97),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _digitsOnly(String raw) => raw.replaceAll(RegExp(r'\D'), '');
}
