import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _accessKey  = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _academyKey = 'academy_id';
  static const _userIdKey  = 'user_id';

  final FlutterSecureStorage _storage;

  SecureStorage(this._storage);

  // ── Reads (async) ──────────────────────────────────────────────────────────
  Future<String?> get accessToken  => _storage.read(key: _accessKey);
  Future<String?> get refreshToken => _storage.read(key: _refreshKey);
  Future<String?> get academyId    => _storage.read(key: _academyKey);
  Future<String?> get userId       => _storage.read(key: _userIdKey);

  // Sync cache — populated once on app start so ApiClient can read synchronously
  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  String? _cachedUserId;
  String? get cachedAccessToken  => _cachedAccessToken;
  String? get cachedRefreshToken => _cachedRefreshToken;
  String? get cachedUserId       => _cachedUserId;

  Future<void> load() async {
    _cachedAccessToken  = await accessToken;
    _cachedRefreshToken = await refreshToken;
    _cachedUserId       = await userId;
  }

  // ── Writes ─────────────────────────────────────────────────────────────────
  Future<void> saveTokens({required String access, required String refresh}) async {
    _cachedAccessToken  = access;
    _cachedRefreshToken = refresh;
    await Future.wait([
      _storage.write(key: _accessKey,  value: access),
      _storage.write(key: _refreshKey, value: refresh),
    ]);
  }


  Future<void> saveAcademyId(String id) => _storage.write(key: _academyKey, value: id);
  Future<void> saveUserId(String id) async {
    _cachedUserId = id;
    await _storage.write(key: _userIdKey, value: id);
  }

  // ── Clear ──────────────────────────────────────────────────────────────────
  Future<void> clear() async {
    _cachedAccessToken  = null;
    _cachedRefreshToken = null;
    _cachedUserId       = null;
    await _storage.deleteAll();
  }
}
