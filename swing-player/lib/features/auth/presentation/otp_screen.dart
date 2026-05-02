import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/auth_controller.dart';

const _kNavy  = Color(0xFF071B3D);
const _kBlue  = Color(0xFF0057C8);
const _kIvory = Color(0xFFF4F2EB);

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
    ref.listen<AuthState>(authControllerProvider, (_, next) {
      if (next.isAuthenticated) context.go('/home');
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage!.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          backgroundColor: context.danger,
        ));
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final h = MediaQuery.of(context).size.height;

    final defaultPin = PinTheme(
      width: 52,
      height: 60,
      textStyle: const TextStyle(
        color: _kNavy,
        fontSize: 24,
        fontWeight: FontWeight.w900,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(10),
      ),
    );

    final focusedPin = defaultPin.copyDecorationWith(
      color: _kBlue.withValues(alpha: 0.1),
    );

    final submittedPin = defaultPin.copyDecorationWith(
      color: const Color(0xFF72C86A).withValues(alpha: 0.12),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Brand header ───────────────────────────────────────────────
          Container(
            width: double.infinity,
            height: h * 0.42,
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo/logo-light.png',
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SWING',
                    style: TextStyle(
                      color: _kNavy,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'YOUR CRICKET IDENTITY',
                    style: TextStyle(
                      color: _kNavy.withValues(alpha: 0.35),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  const Text(
                    'VERIFY YOUR\nNUMBER',
                    style: TextStyle(
                      color: _kNavy,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: _kNavy.withValues(alpha: 0.45),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        const TextSpan(text: 'Code sent to '),
                        TextSpan(
                          text: widget.phoneNumber,
                          style: const TextStyle(
                            color: _kBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── OTP pin boxes ────────────────────────────────────────
                  Center(
                    child: Pinput(
                      controller: _otpController,
                      length: 6,
                      defaultPinTheme: defaultPin,
                      focusedPinTheme: focusedPin,
                      submittedPinTheme: submittedPin,
                      separatorBuilder: (_) => const SizedBox(width: 8),
                      onCompleted: (_) => ref
                          .read(authControllerProvider.notifier)
                          .verifyOtp(_otpController.text.trim()),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Resend row ───────────────────────────────────────────
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "DIDN'T RECEIVE IT?",
                          style: TextStyle(
                            color: _kNavy.withValues(alpha: 0.4),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: _secondsLeft == 0
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
                                ? 'RESEND CODE'
                                : 'RESEND IN ${_secondsLeft}S',
                            style: TextStyle(
                              color:
                                  _secondsLeft == 0 ? _kBlue : _kNavy.withValues(alpha: 0.3),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── CTA button ───────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => ref
                              .read(authControllerProvider.notifier)
                              .verifyOtp(_otpController.text.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kBlue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _kBlue.withValues(alpha: 0.3),
                        disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'VERIFY IDENTITY',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.shield_rounded, size: 18),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Back link ────────────────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text(
                        '← Change number',
                        style: TextStyle(
                          color: _kNavy.withValues(alpha: 0.45),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
