import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'allowed_users.dart';

const _kTokenKey = 'auth.token';
const _kEmailKey = 'auth.email';

final sharedPreferencesProvider = Provider<SharedPreferences>((_) {
  throw UnimplementedError('SharedPreferences must be overridden at startup.');
});

class AuthStorage {
  AuthStorage(this._prefs);

  final SharedPreferences _prefs;

  RestoredSession? restore() {
    final token = _prefs.getString(_kTokenKey);
    final email = _prefs.getString(_kEmailKey);
    if (token == null || token.isEmpty || email == null || email.isEmpty) {
      return null;
    }

    final normalized = email.trim().toLowerCase();
    AllowedUser? user;
    for (final candidate in kAllowedUsers) {
      if (candidate.email == normalized) {
        user = candidate;
        break;
      }
    }
    if (user == null) {
      clear();
      return null;
    }

    return RestoredSession(user: user, token: token);
  }

  Future<void> save({
    required AllowedUser user,
    required String token,
  }) async {
    await _prefs.setString(_kTokenKey, token);
    await _prefs.setString(_kEmailKey, user.email);
  }

  Future<void> clear() async {
    await _prefs.remove(_kTokenKey);
    await _prefs.remove(_kEmailKey);
  }
}

class RestoredSession {
  const RestoredSession({
    required this.user,
    required this.token,
  });

  final AllowedUser user;
  final String token;
}

final authStorageProvider = Provider<AuthStorage>((ref) {
  return AuthStorage(ref.watch(sharedPreferencesProvider));
});
