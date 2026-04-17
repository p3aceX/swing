import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/auth_controller.dart';
import 'auth_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();

  String get _phoneDigits =>
      _phoneController.text.replaceAll(RegExp(r'\D'), '');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    final authState = ref.watch(authControllerProvider);
    final hasValidPhone = _phoneDigits.length == 10;

    return AuthScaffold(
      bottom: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: authState.status == AuthStatus.loading || !hasValidPhone
              ? null
              : _handleContinue,
          child: Text(
            authState.status == AuthStatus.loading ? 'Checking...' : 'Continue',
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
                Text(
                  'Enter Swing',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'Use your mobile number to continue.',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _phoneController,
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: TextStyle(
                    color: context.fg,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Phone number',
                    hintText: '9876543210',
                    prefixIcon: const Icon(Icons.phone_android),
                    prefixText: '+91  ',
                    helperText: hasValidPhone ? null : 'Enter 10 digits',
                    counterText: '${_phoneDigits.length}/10',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    final digits = _phoneDigits;
    if (digits.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit mobile number.')),
      );
      return;
    }

    final phone = '+91$digits';
    final exists =
        await ref.read(authControllerProvider.notifier).checkPhone(phone);
    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    if (authState.errorMessage != null) return;
    final normalizedPhone = authState.pendingPhoneNumber ?? phone;

    if (exists) {
      await ref.read(authControllerProvider.notifier).sendOtp(normalizedPhone);
      if (!mounted) return;
      final nextState = ref.read(authControllerProvider);
      if (nextState.errorMessage == null) {
        context.go('/otp?phone=${Uri.encodeComponent(normalizedPhone)}');
      }
      return;
    }

    context.go('/register?phone=${Uri.encodeComponent(normalizedPhone)}');
  }
}
