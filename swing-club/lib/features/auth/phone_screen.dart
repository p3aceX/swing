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
  final _dio             = Dio();
  bool _isLoading        = false;
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
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
          final sessionId = await _sendOtp(normalizedPhone);
          if (sessionId != null && mounted) {
            // ignore: use_build_context_synchronously
            context.push('/otp', extra: {
              'phone':     normalizedPhone,
              'sessionId': sessionId,
              'isNewUser': false,
            });
          }
        } else {
          // ignore: use_build_context_synchronously
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
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 72),

                // ── Logo ──────────────────────────────────────────────────────
                Center(child: Image.asset('asset/logolight.png', height: 120)),

                const Spacer(),

                // ── Headline ──────────────────────────────────────────────────
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    letterSpacing: -0.3,
                  ),
                ),
                const Text(
                  'Swing Academy',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF071B3D),
                    letterSpacing: -1.5,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Enter your mobile number to get started',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 36),

                // ── Phone field ───────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0DED6)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        decoration: const BoxDecoration(
                          border: Border(right: BorderSide(color: Color(0xFFE0DED6))),
                        ),
                        child: const Text(
                          '+91',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
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
                          autofocus: false,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF071B3D),
                            letterSpacing: 1.5,
                          ),
                          decoration: const InputDecoration(
                            hintText: '98765 43210',
                            hintStyle: TextStyle(
                              color: Color(0xFFBBBBBB),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
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

                const SizedBox(height: 16),

                // ── Continue button ───────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleContinue,
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

                const SizedBox(height: 20),

                // ── Terms ─────────────────────────────────────────────────────
                Center(
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                      children: [
                        const TextSpan(text: 'By continuing, you accept our '),
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: TextStyle(
                            color: const Color(0xFF071B3D),
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFF071B3D).withValues(alpha: 0.4),
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: const Color(0xFF071B3D),
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFF071B3D).withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
