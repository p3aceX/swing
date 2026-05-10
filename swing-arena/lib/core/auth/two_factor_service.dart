import 'package:dio/dio.dart';

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
    try {
      final url = '$_baseUrl/$phoneNumber/AUTOGEN2';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['Status'] == 'Success') {
          return data['Details'] as String;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> verifyOtp({
    required String sessionId,
    required String otpInput,
  }) async {
    try {
      final url = '$_baseUrl/VERIFY/$sessionId/$otpInput';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['Status'] == 'Success' && data['Details'] == 'OTP Matched';
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
