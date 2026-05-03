import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _academyIdKey = 'academy_id';

  final SharedPreferences _prefs;
  const TokenStorage(this._prefs);

  String? get accessToken => _prefs.getString(_accessKey);
  String? get refreshToken => _prefs.getString(_refreshKey);
  String? get academyId => _prefs.getString(_academyIdKey);

  Future<void> saveTokens({required String access, required String refresh}) async {
    await _prefs.setString(_accessKey, access);
    await _prefs.setString(_refreshKey, refresh);
  }

  Future<void> saveAcademyId(String id) => _prefs.setString(_academyIdKey, id);

  Future<void> clear() async {
    await _prefs.remove(_accessKey);
    await _prefs.remove(_refreshKey);
    await _prefs.remove(_academyIdKey);
  }
}
