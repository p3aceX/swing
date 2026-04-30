import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../core/router/app_router.dart';
import '../controller/auth_controller.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  Timer? _timer;
  int _secondsLeft = 600;
  int _resendWait = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = 600;
    _resendWait = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) _secondsLeft--;
        if (_resendWait > 0) _resendWait--;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final ctl = ref.read(authControllerProvider.notifier);
    final maskedPhone = _maskPhone(auth.phone);
    final theme = Theme.of(context);

    ref.listen(authControllerProvider, (prev, next) {
      if (next.error != null && prev?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
      if (prev?.phone != next.phone && next.step == AuthStep.otp) {
        _startTimer();
      }
      if (next.step == AuthStep.phone) context.go(AppRoutes.login);

      if (next.needsBiometricEnrollment &&
          !next.loading &&
          (prev == null || !prev.needsBiometricEnrollment || prev.loading)) {
        _showBiometricDialog(context, ref);
      }
    });

    final pinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: Color(0xFF101828),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8E2D8)),
      ),
    );

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
                    const _AuthLogoMark(size: 144),
                    const SizedBox(height: 18),
                    Text(
                      auth.step == AuthStep.name
                          ? 'Complete account'
                          : 'Verify your number',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF101828),
                        height: 1,
                        letterSpacing: -0.8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      auth.step == AuthStep.name
                          ? 'Add the owner name used by your arena team.'
                          : 'Enter the 6-digit OTP sent to $maskedPhone.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
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
                        padding: const EdgeInsets.all(22),
                        child: auth.step == AuthStep.name
                            ? _nameFallback(auth, ctl)
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.timer_outlined,
                                          color: Color(0xFF067647), size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Code expires in ${_timeLabel(_secondsLeft)}',
                                        style: const TextStyle(
                                          color: Color(0xFF067647),
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Pinput(
                                    length: 6,
                                    controller: _otpCtrl,
                                    autofocus: true,
                                    defaultPinTheme: pinTheme,
                                    focusedPinTheme: pinTheme.copyWith(
                                      decoration: pinTheme.decoration?.copyWith(
                                        border: Border.all(
                                          color: const Color(0xFF101828),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    submittedPinTheme: pinTheme.copyWith(
                                      decoration: pinTheme.decoration?.copyWith(
                                        color: const Color(0xFFEAF8EE),
                                        border: Border.all(
                                            color: const Color(0xFF12B76A)),
                                      ),
                                    ),
                                    onCompleted: ctl.verifyOtp,
                                  ),
                                  const SizedBox(height: 22),
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
                                    onPressed: auth.loading
                                        ? null
                                        : () => ctl.verifyOtp(_otpCtrl.text),
                                    child: auth.loading
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Verify OTP'),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: _resendWait > 0 ||
                                                  auth.loading
                                              ? null
                                              : () async {
                                                  await ctl.sendOtp(auth.phone);
                                                  _startTimer();
                                                },
                                          child: Text(_resendWait > 0
                                              ? 'Resend in ${_resendWait}s'
                                              : 'Resend OTP'),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: auth.loading
                                              ? null
                                              : () {
                                                  ctl.resetToPhone();
                                                  context.go(AppRoutes.login);
                                                },
                                          child: const Text('Change number'),
                                        ),
                                      ),
                                    ],
                                  ),
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

  Widget _nameFallback(AuthFlowState auth, AuthController ctl) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Owner name',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'We still need your full name before creating your business account.',
          style: TextStyle(
            color: Color(0xFF667085),
            fontSize: 13,
            height: 1.45,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Full name',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF101828),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(54),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: auth.loading ? null : () => ctl.submitName(_nameCtrl.text),
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
      ],
    );
  }

  String _maskPhone(String phone) {
    final digits = phone.characters
        .where((c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57)
        .join();
    if (digits.length < 10) return phone;
    final tail = digits.substring(digits.length - 4);
    return '+91 ${digits.substring(0, 2)}****$tail';
  }

  String _timeLabel(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  void _showBiometricDialog(BuildContext screenContext, WidgetRef ref) {
    showDialog(
      context: screenContext,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Enable Biometric?',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text(
            'Use your fingerprint or face to login faster next time without waiting for OTP.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // skipBiometrics sets needsBiometricEnrollment=false →
              // RouterRefreshStream fires → router redirects to dashboard.
              ref.read(authControllerProvider.notifier).skipBiometrics();
            },
            child: const Text('Maybe later',
                style: TextStyle(color: Color(0xFF667085))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final enabled = await ref
                  .read(authControllerProvider.notifier)
                  .enableBiometrics();
              // enableBiometrics sets needsBiometricEnrollment=false on success →
              // RouterRefreshStream fires → router redirects to dashboard.
              if (!enabled && screenContext.mounted) {
                ScaffoldMessenger.of(screenContext).showSnackBar(
                  const SnackBar(
                      content: Text('Biometric setup failed. Try again.')),
                );
                _showBiometricDialog(screenContext, ref);
              }
            },
            child: const Text('Enable',
                style: TextStyle(
                    color: Color(0xFF101828), fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _AuthLogoMark extends StatelessWidget {
  const _AuthLogoMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF0F2F5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Image.asset('assets/logo/logo.png', fit: BoxFit.contain),
      ),
    );
  }
}
