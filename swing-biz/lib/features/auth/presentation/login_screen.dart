import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final ctl = ref.read(authControllerProvider.notifier);
    final normalized = _digitsOnly(_phoneCtrl.text);
    final isValid = normalized.length == 10;

    ref.listen(authControllerProvider, (prev, next) {
      if (next.error != null && prev?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
      if (next.step == AuthStep.otp && prev?.step != AuthStep.otp) {
        context.go(AppRoutes.otp);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Enter Your Mobile Number')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'We\'ll send a 6-digit code to verify your number',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      SizedBox(
                        width: 96,
                        child: DropdownButtonFormField<String>(
                          initialValue: '+91',
                          decoration: const InputDecoration(labelText: 'Code'),
                          items: const [
                            DropdownMenuItem(value: '+91', child: Text('+91')),
                            DropdownMenuItem(value: '+1', child: Text('+1')),
                          ],
                          onChanged: (_) {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'Mobile number',
                            hintText: '9876543210',
                            errorText: _phoneCtrl.text.isEmpty || isValid
                                ? null
                                : 'Enter a valid 10-digit number',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    normalized.isEmpty ? '' : _formattedNumber(normalized),
                    style: const TextStyle(color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: !isValid || auth.loading
                        ? null
                        : () => ctl.sendOtp('+91$normalized'),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _digitsOnly(String raw) => raw.replaceAll(RegExp(r'\D'), '');

  String _formattedNumber(String digits) {
    final safe = digits.padRight(10).substring(0, 10).trimRight();
    if (safe.length <= 5) return safe;
    return '${safe.substring(0, 5)} ${safe.substring(5)}';
  }
}
