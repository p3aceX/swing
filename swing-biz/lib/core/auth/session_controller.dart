import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'token_storage.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class SessionState {
  const SessionState({
    this.status = AuthStatus.unknown,
    this.activeProfile,
  });

  final AuthStatus status;
  final BizProfileType? activeProfile;

  SessionState copyWith({
    AuthStatus? status,
    BizProfileType? activeProfile,
    bool clearActiveProfile = false,
  }) =>
      SessionState(
        status: status ?? this.status,
        activeProfile:
            clearActiveProfile ? null : (activeProfile ?? this.activeProfile),
      );
}

class SessionController extends StateNotifier<SessionState> {
  SessionController() : super(const SessionState()) {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final token = await TokenStorage.getAccessToken();
    final profileRaw = await TokenStorage.getActiveProfile();
    final profile =
        profileRaw == null ? null : bizProfileTypeFromString(profileRaw);
    state = SessionState(
      status:
          token == null ? AuthStatus.unauthenticated : AuthStatus.authenticated,
      activeProfile: profile,
    );
  }

  Future<void> signIn({
    required String accessToken,
    required String refreshToken,
  }) async {
    await TokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await TokenStorage.saveActiveProfile(null);
    state = state.copyWith(
      status: AuthStatus.authenticated,
      clearActiveProfile: true,
    );
  }

  Future<void> setActiveProfile(BizProfileType? profile) async {
    await TokenStorage.saveActiveProfile(_nameOf(profile));
    state = state.copyWith(
        activeProfile: profile, clearActiveProfile: profile == null);
  }

  Future<void> signOut() async {
    await TokenStorage.clear();
    state = const SessionState(status: AuthStatus.unauthenticated);
  }

  String? _nameOf(BizProfileType? p) {
    if (p == null) return null;
    switch (p) {
      case BizProfileType.academy:
        return 'ACADEMY';
      case BizProfileType.coach:
        return 'COACH';
      case BizProfileType.arena:
        return 'ARENA';
      case BizProfileType.arenaManager:
        return 'ARENA_MANAGER';
      case BizProfileType.store:
        return 'STORE';
    }
  }
}

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>(
  (ref) => SessionController(),
);
