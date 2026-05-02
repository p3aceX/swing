import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/auth_controller.dart';
import 'auth_scaffold.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();

  bool get _hasValidName => _nameController.text.trim().length >= 2;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!.toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 12)),
            backgroundColor: context.danger,
          ),
        );
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // HERO LOGO
              Center(
                child: Image.asset(
                  isDark ? 'assets/logo/logo-dark.png' : 'assets/logo/logo-light.png',
                  height: 64,
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(),
              // HEADLINE
              Text(
                'CREATE YOUR\nPLAYER IDENTITY',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'ADD YOUR NAME TO CONTINUE',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 40),
              // TECHNICAL INPUT
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                  color: context.panel,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _hasValidName 
                        ? context.accent.withValues(alpha: 0.5) 
                        : context.stroke.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _nameController,
                  onChanged: (_) => setState(() {}),
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(40),
                  ],
                  cursorColor: context.accent,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                  decoration: InputDecoration(
                    hintText: 'FULL NAME',
                    hintStyle: TextStyle(
                      color: context.fgSub.withValues(alpha: 0.2),
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // PHONE READONLY HUD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: context.panel.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.stroke.withValues(alpha: 0.05)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.phone_android_rounded, color: context.fgSub, size: 16),
                    const SizedBox(width: 12),
                    Text(
                      widget.phoneNumber,
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // ACTION BUTTON
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: authState.status == AuthStatus.loading || !_hasValidName
                      ? null
                      : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.ctaBg,
                    foregroundColor: context.ctaFg,
                    disabledBackgroundColor: context.panel,
                    disabledForegroundColor: context.fgSub.withValues(alpha: 0.3),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: authState.status == AuthStatus.loading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: context.ctaFg))
                      : const Text(
                          'CONTINUE TO OTP',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: 1.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'GO BACK',
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendOtp() async {
    final name = _nameController.text.trim();
    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your full name to continue.')),
      );
      return;
    }

    await ref.read(authControllerProvider.notifier).sendOtp(
          widget.phoneNumber,
          registrationName: name,
        );
    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    if (authState.errorMessage == null) {
      context.go('/otp?phone=${Uri.encodeComponent(widget.phoneNumber)}');
    }
  }
}
