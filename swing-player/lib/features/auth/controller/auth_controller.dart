import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/token_storage.dart';
import '../../../core/notifications/fcm_service.dart';
import '../data/auth_repository.dart';
import '../../profile/controller/profile_controller.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider), ref);
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository, this._ref) : super(const AuthState.loading()) {
    _initialize();
    _sessionExpiredSub = ApiClient.instance.sessionExpired.listen((_) {
      _onSessionExpired();
    });
  }

  final AuthRepository _repository;
  final Ref _ref;
  final _streamController = StreamController<AuthState>.broadcast();
  late final StreamSubscription<void> _sessionExpiredSub;
  String? _verificationId;
  PhoneAuthCredential? _instantVerificationCredential;

  @override
  Stream<AuthState> get stream => _streamController.stream;

  Future<void> _initialize() async {
    try {
      final accessToken = await TokenStorage.getAccessToken();
      final cachedProfileComplete = await TokenStorage.getProfileComplete();
      final cachedUserRank = await TokenStorage.getUserRank();

      var isProfileComplete = cachedProfileComplete ?? false;
      var userRank = cachedUserRank;
      if (accessToken != null &&
          accessToken.isNotEmpty &&
          cachedProfileComplete == null) {
        try {
          isProfileComplete = await _repository.fetchProfileComplete();
          await TokenStorage.saveProfileComplete(isProfileComplete);
        } catch (_) {
          isProfileComplete = false;
        }
      }
      if (accessToken != null && accessToken.isNotEmpty) {
        try {
          userRank = await _repository.fetchUserRank();
          if (userRank != null && userRank.isNotEmpty) {
            await TokenStorage.saveUserRank(userRank);
          }
        } catch (_) {
          userRank = cachedUserRank;
        }
      }

      state = AuthState(
        status: AuthStatus.idle,
        isAuthenticated: accessToken != null && accessToken.isNotEmpty,
        isProfileComplete: isProfileComplete,
        userRank: userRank,
      );
    } catch (_) {
      state = const AuthState(status: AuthStatus.idle);
    }
    _streamController.add(state);
  }

  Future<bool> checkPhone(String phoneNumber) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      pendingPhoneNumber: phoneNumber,
      registrationName: null,
    );
    _streamController.add(state);

    try {
      final result = await _repository.checkPhone(phoneNumber);
      state = state.copyWith(
        status: AuthStatus.idle,
        pendingPhoneNumber: result.normalizedPhone,
      );
      _streamController.add(state);
      return result.exists;
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _messageFor(error),
      );
      _streamController.add(state);
      return false;
    }
  }

  Future<void> sendOtp(String phoneNumber, {String? registrationName}) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      pendingPhoneNumber: phoneNumber,
      registrationName: registrationName,
    );
    _streamController.add(state);

    _verificationId = null;
    _instantVerificationCredential = null;

    final completer = Completer<void>();

    try {
      if (Firebase.apps.isEmpty) {
        throw UnsupportedError(
          'Phone login is not configured for this build yet.',
        );
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async {
          _instantVerificationCredential = credential;
          state = state.copyWith(
            status: AuthStatus.idle,
            pendingPhoneNumber: phoneNumber,
            registrationName: registrationName,
          );
          _streamController.add(state);
          if (!completer.isCompleted) completer.complete();
        },
        verificationFailed: (error) {
          final message = error.message ?? 'Phone verification failed.';
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: message,
          );
          _streamController.add(state);
          if (!completer.isCompleted) {
            completer.completeError(Exception(message));
          }
        },
        codeSent: (verificationId, _) {
          _verificationId = verificationId;
          state = state.copyWith(
            status: AuthStatus.idle,
            pendingPhoneNumber: phoneNumber,
            registrationName: registrationName,
          );
          _streamController.add(state);
          if (!completer.isCompleted) completer.complete();
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );

      await completer.future;
    } catch (error) {
      if (state.status == AuthStatus.error && state.errorMessage != null) {
        return;
      }

      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _messageFor(error),
      );
      _streamController.add(state);
    }
  }

  Future<void> verifyOtp(String code) async {
    if (_verificationId == null && _instantVerificationCredential == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'No OTP request is active. Start again.',
      );
      _streamController.add(state);
      return;
    }

    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    _streamController.add(state);

    try {
      final credential = _instantVerificationCredential ??
          PhoneAuthProvider.credential(
            verificationId: _verificationId!,
            smsCode: code,
          );
      await _signInWithCredential(
        credential,
        registrationName: state.registrationName,
      );
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _messageFor(error),
      );
      _streamController.add(state);
    }
  }

  Future<void> _signInWithCredential(
    PhoneAuthCredential credential, {
    String? registrationName,
  }) async {
    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final idToken = await userCredential.user?.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Could not get Firebase login token.');
    }

    final result = await _repository.loginWithFirebase(
      idToken: idToken,
      name: registrationName,
    );

    state = state.copyWith(
      status: AuthStatus.idle,
      isAuthenticated: true,
      isProfileComplete: result.isProfileComplete,
      userRank: result.userRank,
      pendingPhoneNumber: null,
      registrationName: null,
      errorMessage: null,
    );
    _verificationId = null;
    _instantVerificationCredential = null;
    // Reload profile with the new user's token
    _ref.invalidate(profileControllerProvider);
    _streamController.add(state);
    // Register FCM token for push notifications
    FcmService.instance.registerToken();
  }

  Future<void> signOut() async {
    await FcmService.instance.removeToken();
    await FirebaseAuth.instance.signOut();
    await TokenStorage.clear();
    // Invalidate cached profile so the next login loads fresh data
    _ref.invalidate(profileControllerProvider);
    state = const AuthState(status: AuthStatus.idle);
    _streamController.add(state);
  }

  /// Called when ApiClient detects a 401 that could not be refreshed.
  /// Clears Firebase session and marks the user as unauthenticated so the
  /// router redirects to the login screen.
  void _onSessionExpired() {
    if (!state.isAuthenticated) return; // already logged out
    if (kDebugMode) debugPrint('[Auth] Session expired — redirecting to login');
    FirebaseAuth.instance.signOut().ignore();
    _ref.invalidate(profileControllerProvider);
    state = const AuthState(status: AuthStatus.idle, isAuthenticated: false);
    _streamController.add(state);
  }

  String _messageFor(Object error) {
    if (error is FirebaseAuthException) {
      return error.message ?? 'Phone verification failed.';
    }
    if (error is UnsupportedError) {
      return error.message ?? 'Phone login is not available on this build.';
    }
    if (error is DioException) {
      if (kDebugMode) {
        debugPrint(
          'Auth Dio error: status=${error.response?.statusCode} data=${error.response?.data}',
        );
      }
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        if (data['message'] is String) {
          return data['message'] as String;
        }
        final nested = data['error'];
        if (nested is Map<String, dynamic> && nested['message'] is String) {
          return nested['message'] as String;
        }
      }
    }
    final text = error.toString();
    if (text.startsWith('Exception: ')) {
      return text.replaceFirst('Exception: ', '');
    }
    return 'Something went wrong. Try again.';
  }

  @override
  void dispose() {
    _sessionExpiredSub.cancel();
    _streamController.close();
    super.dispose();
  }
}

enum AuthStatus { loading, idle, error }

class AuthState {
  static const _unset = Object();

  const AuthState({
    required this.status,
    this.isAuthenticated = false,
    this.isProfileComplete = false,
    this.userRank,
    this.pendingPhoneNumber,
    this.registrationName,
    this.errorMessage,
  });

  const AuthState.loading() : this(status: AuthStatus.loading);

  final AuthStatus status;
  final bool isAuthenticated;
  final bool isProfileComplete;
  final String? userRank;
  final String? pendingPhoneNumber;
  final String? registrationName;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    bool? isAuthenticated,
    bool? isProfileComplete,
    Object? userRank = _unset,
    Object? pendingPhoneNumber = _unset,
    Object? registrationName = _unset,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      userRank:
          identical(userRank, _unset) ? this.userRank : userRank as String?,
      pendingPhoneNumber: identical(pendingPhoneNumber, _unset)
          ? this.pendingPhoneNumber
          : pendingPhoneNumber as String?,
      registrationName: identical(registrationName, _unset)
          ? this.registrationName
          : registrationName as String?,
      errorMessage: errorMessage,
    );
  }
}
