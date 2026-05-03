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
  final String? address;
  final String? city;
  final String? state;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.sessionId,
    required this.isNewUser,
    this.name,
    this.address,
    this.city,
    this.state,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _dio = Dio();
  bool _isVerifying = false;

  Future<void> _handleVerify(String otp) async {
    setState(() => _isVerifying = true);
    try {
      final res = await _dio.post('$kBackendBaseUrl/auth/biz/phone-login', data: {
        'phone': widget.phone,
        'sessionId': widget.sessionId,
        'otp': otp,
        'name': widget.name ?? 'Academy Owner',
      });

      if (res.data['success'] == true) {
        final data = res.data['data'] as Map<String, dynamic>;
        final accessToken = data['accessToken'] as String;
        final refreshToken = data['refreshToken'] as String;

        if (widget.isNewUser && widget.name != null && widget.address != null) {
          await _setupAcademy(accessToken);
        }

        if (!mounted) return;
        await ref.read(authProvider.notifier).login(accessToken, refreshToken);
        if (!mounted) return;
        context.go('/home');
      } else {
        if (mounted) showSnack(context, 'Invalid OTP. Please try again.');
      }
    } on DioException catch (e) {
      if (mounted) showSnack(context, e.response?.data?['message'] ?? 'Invalid OTP');
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _setupAcademy(String token) async {
    try {
      final authedDio = Dio(BaseOptions(headers: {'Authorization': 'Bearer $token'}));
      await authedDio.put('$kBackendBaseUrl/biz/business-details', data: {
        'businessName': '${widget.name} Academy',
        'city': widget.city,
        'state': widget.state,
        'address': widget.address,
      });
      await authedDio.post('$kBackendBaseUrl/biz/academy', data: {
        'name': '${widget.name} Academy',
        'city': widget.city,
        'state': widget.state,
        'address': widget.address,
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Text(
              'Code sent to +91 ${widget.phone}',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text('Enter the 6-digit code below',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 48),
            Pinput(
              length: 6,
              onCompleted: _handleVerify,
              defaultPinTheme: PinTheme(
                width: 52,
                height: 56,
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 40),
            if (_isVerifying) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
