import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/auth_controller.dart';
import 'auth_scaffold.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  Timer? _timer;
  int _secondsLeft = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.go('/home');
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    final authState = ref.watch(authControllerProvider);
    final pinTheme = PinTheme(
      width: 52,
      height: 62,
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.stroke),
      ),
      textStyle: TextStyle(
        color: context.fg,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    );

    return AuthScaffold(
      bottom: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: authState.status == AuthStatus.loading
              ? null
              : () => ref.read(authControllerProvider.notifier).verifyOtp(
                    _otpController.text.trim(),
                  ),
          child: Text(
            authState.status == AuthStatus.loading
                ? 'Verifying...'
                : 'Verify & Continue',
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back'),
                ),
                const SizedBox(height: 20),
                Text(
                  'Verify your number',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter the 6-digit code sent to ${widget.phoneNumber}.',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                Pinput(
                  controller: _otpController,
                  length: 6,
                  defaultPinTheme: pinTheme,
                  focusedPinTheme: pinTheme.copyDecorationWith(
                    border: Border.all(color: context.accent, width: 1.5),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      'Didn’t receive it?',
                      style: TextStyle(color: context.fgSub),
                    ),
                    TextButton(
                      onPressed: _secondsLeft == 0
                          ? () async {
                              await ref
                                  .read(authControllerProvider.notifier)
                                  .sendOtp(
                                    widget.phoneNumber,
                                    registrationName: ref
                                        .read(authControllerProvider)
                                        .registrationName,
                                  );
                              if (mounted &&
                                  ref
                                          .read(authControllerProvider)
                                          .errorMessage ==
                                      null) {
                                _startTimer();
                              }
                            }
                          : null,
                      child: Text(
                        _secondsLeft == 0
                            ? 'Resend OTP'
                            : 'Resend in ${_secondsLeft}s',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
