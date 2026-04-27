import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TwoFactorService {
  TwoFactorService._();
  static final TwoFactorService instance = TwoFactorService._();

  // TODO: Replace with your actual API key from 2Factor.in
  static const String _apiKey = 'c03bfecb-f75f-11f0-a6b2-0200cd936042';
  static const String _baseUrl = 'https://2factor.in/API/V1/$_apiKey/SMS';

  final _dio = Dio();

  /// Sends an OTP to the given phone number.
  /// Returns the Session ID if successful.
  Future<String?> sendOtp(String phoneNumber) async {
    debugPrint('2Factor: Requesting OTP for $phoneNumber...');
    try {
      final url = '$_baseUrl/$phoneNumber/AUTOGEN2';
      debugPrint('2Factor: URL: $url');
      final response = await _dio.get(url);
      
      debugPrint('2Factor: Response: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['Status'] == 'Success') {
          final sessionId = data['Details'] as String;
          debugPrint('2Factor: OTP Sent successfully. SessionId: $sessionId');
          return sessionId;
        }
      }
      return null;
    } catch (e) {
      debugPrint('2Factor: Send Exception: $e');
      return null;
    }
  }

  Future<bool> verifyOtp({
    required String sessionId,
    required String otpInput,
  }) async {
    debugPrint('2Factor: Verifying OTP $otpInput for Session $sessionId...');
    try {
      final url = '$_baseUrl/VERIFY/$sessionId/$otpInput';
      debugPrint('2Factor: URL: $url');
      final response = await _dio.get(url);
      
      debugPrint('2Factor: Response: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final success = data['Status'] == 'Success' && data['Details'] == 'OTP Matched';
        debugPrint('2Factor: Verification result: $success');
        return success;
      }
      return false;
    } catch (e) {
      debugPrint('2Factor: Verify Exception: $e');
      return false;
    }
  }
}
