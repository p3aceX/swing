import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _profileCompleteKey = 'profile_complete';
  static const _userRankKey = 'user_rank';

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

  static Future<void> saveUserId(String userId) =>
      _storage.write(key: _userIdKey, value: userId);

  static Future<String?> getUserId() => _storage.read(key: _userIdKey);

  static Future<void> saveUserRank(String rank) =>
      _storage.write(key: _userRankKey, value: rank);

  static Future<String?> getUserRank() => _storage.read(key: _userRankKey);

  static Future<void> saveProfileComplete(bool value) => _storage.write(
        key: _profileCompleteKey,
        value: value ? 'true' : 'false',
      );

  static Future<bool?> getProfileComplete() async {
    final value = await _storage.read(key: _profileCompleteKey);
    if (value == null) return null;
    return value == 'true';
  }

  static Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _profileCompleteKey);
    await _storage.delete(key: _userRankKey);
  }
}
