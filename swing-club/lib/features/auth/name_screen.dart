import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../shared/widgets.dart';

class NameScreen extends ConsumerStatefulWidget {
  final String phone;
  const NameScreen({super.key, required this.phone});

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  final _nameController = TextEditingController();
  final _dio = Dio();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final name = _nameController.text.trim();
    if (name.length < 2) {
      showSnack(context, 'Please enter your full name');
      return;
    }
    setState(() => _isLoading = true);

    try {
      final rawPhone  = widget.phone.replaceAll('+91', '');
      final sessionId = await _sendOtp(rawPhone);
      if (!mounted) return;

      if (sessionId != null) {
        context.push('/otp', extra: {
          'phone':     widget.phone,
          'sessionId': sessionId,
          'isNewUser': true,
          'name':      name,
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _sendOtp(String rawPhone) async {
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
            const SizedBox(height: 16),
            const Text(
              "What's your\nname?",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Color(0xFF071B3D),
                letterSpacing: -1.5,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'This will appear on your academy profile',
              style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 48),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0DED6)),
              ),
              child: TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF071B3D),
                ),
                decoration: const InputDecoration(
                  hintText: 'Full name',
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
                onSubmitted: (_) => _handleSendOtp(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSendOtp,
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
                        'Send OTP',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
