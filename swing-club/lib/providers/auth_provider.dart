import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/token_storage.dart';

class AuthState {
  final String? accessToken;
  final String? refreshToken;
  final bool isAuthenticated;

  const AuthState({
    this.accessToken,
    this.refreshToken,
    this.isAuthenticated = false,
  });

  AuthState copyWith({String? accessToken, String? refreshToken, bool? isAuthenticated}) =>
      AuthState(
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      );
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    final storage = ref.read(tokenStorageProvider);
    final access = storage.accessToken;
    final refresh = storage.refreshToken;
    if (access != null && refresh != null) {
      return AuthState(accessToken: access, refreshToken: refresh, isAuthenticated: true);
    }
    return const AuthState();
  }

  Future<void> login(String accessToken, String refreshToken) async {
    await ref.read(tokenStorageProvider).saveTokens(access: accessToken, refresh: refreshToken);
    state = AuthState(
      accessToken: accessToken,
      refreshToken: refreshToken,
      isAuthenticated: true,
    );
  }

  void updateTokens(String accessToken, String refreshToken) {
    state = state.copyWith(accessToken: accessToken, refreshToken: refreshToken);
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clear();
    state = const AuthState();
  }
}

final tokenStorageProvider = Provider<TokenStorage>((_) => throw UnimplementedError());
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
