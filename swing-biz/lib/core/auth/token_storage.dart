import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _accessKey = 'biz_access_token';
  static const _refreshKey = 'biz_refresh_token';
  static const _activeProfileKey = 'biz_active_profile';

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

  static Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _activeProfileKey);
  }
}
