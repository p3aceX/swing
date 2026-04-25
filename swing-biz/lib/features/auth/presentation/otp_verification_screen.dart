import 'dart:async';

import 'package:flutter/material.dart';
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
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Number')),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF0F8F6), Colors.white],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFD8E3E0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x140F172A),
                        blurRadius: 28,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: auth.step == AuthStep.name
                      ? _nameFallback(auth, ctl)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7F6F2),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.shield_outlined,
                                color: Color(0xFF0F766E),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Enter verification code',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'We sent a 6-digit code to $maskedPhone',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF5B6B79),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Code expires in ${_timeLabel(_secondsLeft)}',
                              style: const TextStyle(
                                color: Color(0xFF0F766E),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Pinput(
                              length: 6,
                              controller: _otpCtrl,
                              autofocus: true,
                              onCompleted: ctl.verifyOtp,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
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
                                  : const Text('Verify'),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: _resendWait > 0 || auth.loading
                                  ? null
                                  : () async {
                                      await ctl.sendOtp(auth.phone);
                                      _startTimer();
                                    },
                              child: Text(
                                _resendWait > 0
                                    ? 'Resend OTP in ${_resendWait}s'
                                    : 'Resend OTP',
                              ),
                            ),
                            TextButton(
                              onPressed: auth.loading
                                  ? null
                                  : () {
                                      ctl.resetToPhone();
                                      context.go(AppRoutes.login);
                                    },
                              child: const Text('Change Phone Number'),
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

  Widget _nameFallback(AuthFlowState auth, AuthController ctl) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F6F2),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.edit_outlined,
            color: Color(0xFF0F766E),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Complete your account',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We still need your full name before creating your business account.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF5B6B79),
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
        ElevatedButton(
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
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return phone;
    final tail = digits.substring(digits.length - 4);
    return '+91 ${digits.substring(0, 2)}****$tail';
  }

  String _timeLabel(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }
}
