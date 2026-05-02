import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/auth_controller.dart';

const _kNavy  = Color(0xFF071B3D);
const _kBlue  = Color(0xFF0057C8);
const _kIvory = Color(0xFFF4F2EB);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _focusNode = FocusNode();
  bool _focused = false;

  String get _phoneDigits =>
      _phoneController.text.replaceAll(RegExp(r'\D'), '');

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (_, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage!.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          backgroundColor: context.danger,
        ));
      }
    });

    final authState   = ref.watch(authControllerProvider);
    final hasValidPhone = _phoneDigits.length == 10;
    final isLoading   = authState.status == AuthStatus.loading;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
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
                    'LOGIN',
                    style: TextStyle(
                      color: _kNavy,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Phone input ──────────────────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _focused ? _kBlue : _kNavy.withValues(alpha: 0.18),
                        width: _focused ? 2 : 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '+91',
                          style: TextStyle(
                            color: _kBlue,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 22,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          color: _kNavy.withValues(alpha: 0.15),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            focusNode: _focusNode,
                            onChanged: (_) => setState(() {}),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            cursorColor: _kBlue,
                            style: const TextStyle(
                              color: _kNavy,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3.0,
                            ),
                            decoration: const InputDecoration(
                              hintText: '00000 00000',
                              hintStyle: TextStyle(
                                color: Color(0x33071B3D),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                                fontSize: 17,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              filled: false,
                              isCollapsed: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        if (hasValidPhone)
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF72C86A), size: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── CTA button ───────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: isLoading || !hasValidPhone ? null : _handleContinue,
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
                                  'CONTINUE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Center(
                    child: Text(
                      'By continuing you agree to our Terms & Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _kNavy.withValues(alpha: 0.35),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleContinue() async {
    final digits = _phoneDigits;
    if (digits.length != 10) return;

    final phone  = '+91$digits';
    debugPrint('[Login] checkPhone → $phone');
    final exists = await ref.read(authControllerProvider.notifier).checkPhone(phone);
    if (!mounted) return;

    final authState       = ref.read(authControllerProvider);
    debugPrint('[Login] exists=$exists error=${authState.errorMessage}');
    if (authState.errorMessage != null) return;
    final normalizedPhone = authState.pendingPhoneNumber ?? phone;

    if (exists) {
      debugPrint('[Login] sendOtp → $normalizedPhone');
      await ref.read(authControllerProvider.notifier).sendOtp(normalizedPhone);
      if (!mounted) return;
      final errAfter = ref.read(authControllerProvider).errorMessage;
      debugPrint('[Login] sendOtp done, error=$errAfter');
      if (errAfter == null) {
        debugPrint('[Login] navigating to /otp');
        context.go('/otp?phone=${Uri.encodeComponent(normalizedPhone)}');
      }
      return;
    }

    debugPrint('[Login] user not found → /register');
    context.go('/register?phone=${Uri.encodeComponent(normalizedPhone)}');
  }
}
