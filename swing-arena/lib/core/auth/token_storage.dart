import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _accessKey = 'biz_access_token';
  static const _refreshKey = 'biz_refresh_token';
  static const _activeProfileKey = 'biz_active_profile';
  static const _biometricEnabledKey = 'biz_biometric_enabled';
  static const _biometricPhoneKey = 'biz_biometric_phone';

  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshKey, value: refreshToken);
    }
  }

  static Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  static Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  static Future<void> saveActiveProfile(String? value) async {
    if (value == null) {
      await _storage.delete(key: _activeProfileKey);
    } else {
      await _storage.write(key: _activeProfileKey, value: value);
    }
  }

  static Future<String?> getActiveProfile() =>
      _storage.read(key: _activeProfileKey);

  static Future<void> setBiometricEnabled(bool enabled, {String? phone}) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
    if (phone != null) {
      await _storage.write(key: _biometricPhoneKey, value: phone);
    } else if (!enabled) {
      await _storage.delete(key: _biometricPhoneKey);
    }
  }

  static Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _biometricEnabledKey);
    return val == 'true';
  }

  static Future<String?> getBiometricPhone() =>
      _storage.read(key: _biometricPhoneKey);

  static Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    // Note: We might want to keep the refresh token if biometrics are enabled,
    // but typically a logout should clear everything. 
    // If the user wants "not to ask OTP next time", we might need to keep it.
    final bioEnabled = await isBiometricEnabled();
    if (!bioEnabled) {
      await _storage.delete(key: _refreshKey);
    }
    await _storage.delete(key: _activeProfileKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
