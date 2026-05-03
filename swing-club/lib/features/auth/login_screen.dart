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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(Icons.sports_cricket_rounded, size: 72, color: Color(0xFF0057C8)),
                const SizedBox(height: 20),
                Text(
                  'Swing Club',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Academy Management Suite',
                    style: TextStyle(color: Colors.grey, fontSize: 15)),
                const SizedBox(height: 56),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    hintText: '9958955622',
                    prefixIcon: Icon(Icons.phone_iphone_outlined),
                  ),
                  onSubmitted: (_) => _handleContinue(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleContinue,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Get Started',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
