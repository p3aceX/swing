import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifications/onesignal_service.dart';
import 'token_storage.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class SessionState {
  const SessionState({
    this.status = AuthStatus.unknown,
    this.activeProfile,
    this.isLocked = false,
  });

  final AuthStatus status;
  final BizProfileType? activeProfile;
  final bool isLocked;

  SessionState copyWith({
    AuthStatus? status,
    BizProfileType? activeProfile,
    bool? isLocked,
    bool clearActiveProfile = false,
  }) =>
      SessionState(
        status: status ?? this.status,
        activeProfile:
            clearActiveProfile ? null : (activeProfile ?? this.activeProfile),
        isLocked: isLocked ?? this.isLocked,
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
    final bioEnabled = await TokenStorage.isBiometricEnabled();
    
    debugPrint(
        '[biz session] bootstrap token=${token != null} profileRaw=$profileRaw bioEnabled=$bioEnabled');
    state = SessionState(
      status:
          token == null ? AuthStatus.unauthenticated : AuthStatus.authenticated,
      activeProfile: profile,
      isLocked: token != null && bioEnabled,
    );
  }

  Future<void> signIn({
    required String accessToken,
    required String refreshToken,
  }) async {
    debugPrint(
        '[biz session] signIn start access=${accessToken.isNotEmpty} refresh=${refreshToken.isNotEmpty}');
    await TokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await OneSignalService.instance.identifyFromStoredToken();
    await TokenStorage.saveActiveProfile(null);
    state = state.copyWith(
      status: AuthStatus.authenticated,
      clearActiveProfile: true,
      isLocked: false,
    );
    debugPrint('[biz session] signIn state authenticated');
  }

  Future<void> setActiveProfile(BizProfileType? profile) async {
    debugPrint('[biz session] setActiveProfile profile=${profile?.name}');
    await TokenStorage.saveActiveProfile(_nameOf(profile));
    state = state.copyWith(
        activeProfile: profile, clearActiveProfile: profile == null);
  }

  Future<void> signOut() async {
    debugPrint('[biz session] signOut');
    await OneSignalService.instance.logout();
    await TokenStorage.clear();
    state = const SessionState(status: AuthStatus.unauthenticated, isLocked: false);
  }

  void lockSession() {
    if (state.status == AuthStatus.authenticated) {
      debugPrint('[biz session] lockSession');
      state = state.copyWith(isLocked: true);
    }
  }

  Future<void> unlockSession() async {
    debugPrint('[biz session] unlockSession');
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      state = state.copyWith(isLocked: false, status: AuthStatus.authenticated);
    } else {
      await _bootstrap();
    }
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
