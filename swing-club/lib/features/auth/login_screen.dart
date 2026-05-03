import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../shared/widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _dio = Dio();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (phone.length < 10) {
      showSnack(context, 'Enter a valid 10-digit phone number');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await _dio.post('$kBackendBaseUrl/auth/check-phone', data: {'phone': phone});
      if (!mounted) return;

      if (res.data['success'] == true) {
        final exists = res.data['data']['exists'] == true;
        if (exists) {
          final sessionId = await _sendOtp(phone);
          if (sessionId != null && mounted) {
            context.push('/otp', extra: {
              'phone': phone,
              'sessionId': sessionId,
              'isNewUser': false,
            });
          }
        } else {
          context.push('/register', extra: phone);
        }
      }
    } on DioException catch (e) {
      if (mounted) showSnack(context, e.response?.data?['message'] ?? 'Connection error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _sendOtp(String phone) async {
    try {
      final res = await _dio.get(
        'https://2factor.in/API/V1/$kTwoFactorKey/SMS/$phone/AUTOGEN',
      );
      if (res.data['Status'] == 'Success') return res.data['Details'] as String;
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          // Background accent
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'asset/logolight.png',
                      height: 120,
                    ),
                    const SizedBox(height: 48),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Welcome to\nSwing Academy',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Premium Academy Management',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 64),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        hintText: '9958955622',
                        prefixIcon: const Icon(Icons.phone_iphone_rounded),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                        ),
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (_) => _handleContinue(),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'By continuing, you agree to our Terms and Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
