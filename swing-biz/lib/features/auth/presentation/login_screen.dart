import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';

import '../controller/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final ctl = ref.read(authControllerProvider.notifier);

    ref.listen(authControllerProvider, (prev, next) {
      if (next.error != null && prev?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
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
                    'Swing Biz',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your academy, coaching or arena business.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 32),
                  if (auth.step == AuthStep.phone) _phoneForm(auth, ctl),
                  if (auth.step == AuthStep.otp) _otpForm(auth, ctl),
                  if (auth.step == AuthStep.name) _nameForm(auth, ctl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _phoneForm(AuthFlowState state, AuthController ctl) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Phone number',
              hintText: '+91 98765 43210',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: state.loading ? null : () => ctl.sendOtp(_phoneCtrl.text),
            child: state.loading
                ? const SizedBox(
                    height: 22, width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Send OTP'),
          ),
        ],
      );

  Widget _otpForm(AuthFlowState state, AuthController ctl) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter the 6-digit code sent to ${state.phone}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Pinput(
            length: 6,
            controller: _otpCtrl,
            autofocus: true,
            onCompleted: ctl.verifyOtp,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed:
                state.loading ? null : () => ctl.verifyOtp(_otpCtrl.text),
            child: state.loading
                ? const SizedBox(
                    height: 22, width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Verify'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: state.loading ? null : ctl.resetToPhone,
            child: const Text('Use a different number'),
          ),
        ],
      );

  Widget _nameForm(AuthFlowState state, AuthController ctl) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "First time here — let's create your business account.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Your full name'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                state.loading ? null : () => ctl.submitName(_nameCtrl.text),
            child: state.loading
                ? const SizedBox(
                    height: 22, width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Continue'),
          ),
        ],
      );
}
