import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import 'allowed_users.dart';
import 'auth_storage.dart';

class AuthState {
  const AuthState({this.user, this.liveApi = false});

  final AllowedUser? user;
  final bool liveApi;

  bool get isLoggedIn => user != null;
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final restored = ref.read(authStorageProvider).restore();
    if (restored == null) return const AuthState();

    ref.read(apiClientProvider).setToken(restored.token);
    return AuthState(user: restored.user, liveApi: true);
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    final match = kAllowedUsers.where((u) => u.email == normalized).toList();
    if (match.isEmpty) return 'This email is not authorised for SwingAdmin.';
    if (password != kSharedPassword) return 'Incorrect password.';

    final api = ref.read(apiClientProvider);
    String? token;
    try {
      final data = await api.post('/admin/auth/login', {
        'email': normalized,
        'password': password,
      });
      if (data is Map) {
        token = data['accessToken']?.toString() ??
            data['token']?.toString() ??
            (data['tokens'] is Map
                ? (data['tokens'] as Map)['accessToken']?.toString()
                : null);
      }
    } on ApiException catch (e) {
      return 'Admin sign-in failed: ${e.message}';
    } catch (e) {
      return 'Network error — ${e.toString()}';
    }

    if (token == null || token.isEmpty) {
      return 'Admin sign-in did not return an access token.';
    }

    api.setToken(token);
    await ref.read(authStorageProvider).save(
          user: match.first,
          token: token,
        );
    state = AuthState(user: match.first, liveApi: true);
    return null;
  }

  Future<void> logout() async {
    ref.read(apiClientProvider).setToken(null);
    await ref.read(authStorageProvider).clear();
    state = const AuthState();
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
