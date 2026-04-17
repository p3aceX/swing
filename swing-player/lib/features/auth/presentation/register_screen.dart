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
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    final authState = ref.watch(authControllerProvider);
    return AuthScaffold(
      bottom: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: authState.status == AuthStatus.loading || !_hasValidName
              ? null
              : _sendOtp,
          child: Text(
            authState.status == AuthStatus.loading
                ? 'Sending OTP...'
                : 'Continue to OTP',
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
                  'Create your player identity',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'No account found for ${widget.phoneNumber}. Add your name to continue.',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _nameController,
                  onChanged: (_) => setState(() {}),
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(40),
                  ],
                  style: TextStyle(
                    color: context.fg,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: context.panel,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.stroke),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.phone_android_rounded, color: context.fgSub),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.phoneNumber,
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
