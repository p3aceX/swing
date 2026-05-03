import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../shared/widgets.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _dio = Dio();
  bool _isLoading = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final raw   = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    final phone = raw.length == 10 ? '+91$raw' : '+$raw';
    if (raw.length < 10) {
      showSnack(context, 'Enter a valid 10-digit phone number');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await _dio.post(
        '$kBackendBaseUrl/auth/check-phone',
        data: {'phone': phone},
      );
      if (!mounted) return;

      if (res.data['success'] == true) {
        final data            = res.data['data'] as Map<String, dynamic>;
        final exists          = data['exists'] as bool? ?? false;
        final normalizedPhone = data['normalizedPhone'] as String? ?? phone;

        if (exists) {
          // Existing user → go straight to OTP
          final sessionId = await _sendOtp(normalizedPhone);
          if (sessionId != null && mounted) {
            context.push('/otp', extra: {
              'phone':      normalizedPhone,
              'sessionId':  sessionId,
              'isNewUser':  false,
            });
          }
        } else {
          // New user → collect name first
          context.push('/name', extra: {'phone': normalizedPhone});
        }
      }
    } on DioException catch (e) {
      if (mounted) showSnack(context, e.response?.data?['message'] ?? 'Connection error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _sendOtp(String phone) async {
    final rawPhone = phone.replaceAll('+91', '');
    try {
      final res = await _dio.get(
        'https://2factor.in/API/V1/$kTwoFactorKey/SMS/$rawPhone/AUTOGEN',
      );
      if (res.data['Status'] == 'Success') return res.data['Details'] as String;
    } catch (_) {}
    if (mounted) showSnack(context, 'Failed to send OTP. Please try again.');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EB),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Image.asset('asset/logodark.png', height: 56),
                const Spacer(flex: 1),
                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF071B3D),
                    letterSpacing: -1.5,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your mobile number to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),
                // Phone field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0DED6)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        decoration: const BoxDecoration(
                          border: Border(right: BorderSide(color: Color(0xFFE0DED6))),
                        ),
                        child: const Text(
                          '+91',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF071B3D),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          maxLength: 10,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF071B3D),
                            letterSpacing: 1,
                          ),
                          decoration: const InputDecoration(
                            hintText: '9876543210',
                            border: InputBorder.none,
                            filled: false,
                            counterText: '',
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onSubmitted: (_) => _handleContinue(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF071B3D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                          ),
                  ),
                ),
                const Spacer(flex: 2),
                const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Center(
                    child: Text(
                      'By continuing, you agree to our Terms & Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
