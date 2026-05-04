import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  final String sessionId;
  final bool isNewUser;
  final String? name;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.sessionId,
    required this.isNewUser,
    this.name,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _dio        = Dio();
  bool _isVerifying = false;
  bool _canResend   = false;
  int  _countdown   = 30;
  Timer? _timer;
  late String _sessionId;

  @override
  void initState() {
    super.initState();
    _sessionId = widget.sessionId;
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 30;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  Future<void> _handleResend() async {
    if (!_canResend) return;
    setState(() => _canResend = false);
    try {
      final res = await _dio.post(
        '$kBackendBaseUrl/auth/biz/send-otp',
        data: {'phone': widget.phone},
      );
      if (res.data['success'] == true) {
        setState(() => _sessionId = res.data['data']['sessionId'] as String);
        _startCountdown();
        if (mounted) showSnack(context, 'OTP resent successfully');
      } else {
        final msg = res.data['message'] as String? ?? 'Failed to resend OTP';
        if (mounted) showSnack(context, msg);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final raw    = e.response?.data;
      final body   = raw is Map ? raw : null;
      final errObj = body?['error'];
      final errMap = errObj is Map ? errObj : null;
      final msg    = (body?['message'] ?? errMap?['message']
                      ?? 'Failed to resend OTP (${e.response?.statusCode})').toString();
      showSnack(context, msg);
    } catch (e) {
      if (mounted) showSnack(context, 'Network error: $e');
    }
  }

  Future<void> _handleVerify(String otp) async {
    setState(() => _isVerifying = true);
    try {
      final body = <String, dynamic>{
        'phone':     widget.phone,
        'sessionId': _sessionId,
        'otp':       otp,
      };
      if (widget.isNewUser && widget.name != null) {
        body['name'] = widget.name;
      }

      final res = await _dio.post('$kBackendBaseUrl/auth/biz/phone-login', data: body);

      if (!mounted) return;

      if (res.data['success'] == true) {
        final data           = res.data['data'] as Map<String, dynamic>;
        final accessToken    = data['accessToken'] as String;
        final refreshToken   = data['refreshToken'] as String;
        final user           = data['user'] as Map<String, dynamic>? ?? {};
        final userId         = user['id'] as String? ?? '';
        final bsMap          = data['businessStatus'] as Map<String, dynamic>? ?? {};
        final businessStatus = BusinessStatus.fromMap(bsMap);

        await ref.read(authProvider.notifier).login(
          accessToken:    accessToken,
          refreshToken:   refreshToken,
          userId:         userId,
          businessStatus: businessStatus,
        );

        if (!mounted) return;

        // Navigate based on businessStatus
        if (!businessStatus.hasBusinessAccount) {
          context.go('/business-details');
        } else if (!businessStatus.hasAcademy) {
          context.go('/academy-setup');
        } else {
          context.go('/home');
        }
      } else {
        showSnack(context, 'Invalid OTP. Please try again.');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final code = e.response?.data?['code'] as String?;
      if (code == 'ACCOUNT_BANNED') {
        _showBlockedDialog('Account Banned', 'Your account has been banned. Contact support.');
      } else if (code == 'ACCOUNT_BLOCKED') {
        _showBlockedDialog('Account Blocked', 'Your account is blocked. Contact support.');
      } else {
        showSnack(context, e.response?.data?['message'] ?? 'Invalid OTP. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  void _showBlockedDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPin = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: Color(0xFF071B3D),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0DED6), width: 1.5),
      ),
    );

    final focusedPin = defaultPin.copyWith(
      decoration: defaultPin.decoration!.copyWith(
        border: Border.all(color: const Color(0xFF071B3D), width: 2),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F2EB),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Center(child: Image.asset('asset/logolight.png', height: 76)),
            const SizedBox(height: 24),
            const Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Color(0xFF071B3D),
                letterSpacing: -1.5,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500),
                children: [
                  const TextSpan(text: 'Sent to '),
                  TextSpan(
                    text: widget.phone,
                    style: const TextStyle(color: Color(0xFF071B3D), fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 56),
            Center(
              child: Pinput(
                length: 6,
                autofocus: true,
                defaultPinTheme: defaultPin,
                focusedPinTheme: focusedPin,
                onCompleted: _handleVerify,
              ),
            ),
            const SizedBox(height: 40),
            if (_isVerifying)
              const Center(child: CircularProgressIndicator(color: Color(0xFF071B3D)))
            else
              Center(
                child: _canResend
                    ? GestureDetector(
                        onTap: _handleResend,
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: Color(0xFF0057C8),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    : Text(
                        'Resend in ${_countdown}s',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
