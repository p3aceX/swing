import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_controller.dart';

enum AuthStep { phone, otp, name }

class AuthFlowState {
  const AuthFlowState({
    this.step = AuthStep.phone,
    this.phone = '',
    this.loading = false,
    this.error,
    this.firebaseIdToken,
    this.pendingName,
    this.verificationId,
  });

  final AuthStep step;
  final String phone;
  final bool loading;
  final String? error;
  final String? firebaseIdToken;
  final String? pendingName;
  final String? verificationId;

  AuthFlowState copyWith({
    AuthStep? step,
    String? phone,
    bool? loading,
    String? error,
    bool clearError = false,
    String? firebaseIdToken,
    String? pendingName,
    bool clearPendingName = false,
    String? verificationId,
    bool clearVerificationId = false,
  }) =>
      AuthFlowState(
        step: step ?? this.step,
        phone: phone ?? this.phone,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
        firebaseIdToken: firebaseIdToken ?? this.firebaseIdToken,
        pendingName: clearPendingName ? null : (pendingName ?? this.pendingName),
        verificationId:
            clearVerificationId ? null : (verificationId ?? this.verificationId),
      );
}

class AuthController extends StateNotifier<AuthFlowState> {
  AuthController(this._ref) : super(const AuthFlowState());

  final Ref _ref;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<void> sendOtp(String rawPhone) async {
    final phone = _normalize(rawPhone);
    debugPrint('[biz auth] sendOtp start phone=$phone');
    if (!RegExp(r'^\+\d{10,15}$').hasMatch(phone)) {
      debugPrint('[biz auth] sendOtp invalid phone');
      state = state.copyWith(error: 'Enter a valid phone number');
      return;
    }
    state = state.copyWith(loading: true, phone: phone, clearError: true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async {
          debugPrint('[biz auth] verificationCompleted auto');
          await _signInWithCredential(credential);
        },
        verificationFailed: (e) {
          debugPrint('[biz auth] verificationFailed code=${e.code} message=${e.message}');
          state = state.copyWith(
              loading: false, error: e.message ?? 'Verification failed');
        },
        codeSent: (verificationId, _) {
          debugPrint('[biz auth] codeSent verificationId=${verificationId.isNotEmpty}');
          state = state.copyWith(
            step: AuthStep.otp,
            loading: false,
            verificationId: verificationId,
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {
          debugPrint('[biz auth] codeAutoRetrievalTimeout');
          state = state.copyWith(verificationId: verificationId);
        },
      );
    } catch (e) {
      debugPrint('[biz auth] sendOtp exception=$e');
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<PhoneCheckResult> checkPhone(String rawPhone) async {
    final phone = _normalize(rawPhone);
    debugPrint('[biz auth] checkPhone phone=$phone');
    state = state.copyWith(loading: true, clearError: true);
    try {
      final repo = _ref.read(hostBizRepositoryProvider);
      final result = await repo.checkPhone(phone);
      debugPrint('[biz auth] checkPhone result exists=${result.exists} normalized=${result.normalizedPhone}');
      state = state.copyWith(loading: false, phone: result.normalizedPhone);
      return result;
    } catch (e) {
      debugPrint('[biz auth] checkPhone exception=$e');
      state = state.copyWith(loading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> verifyOtp(String code) async {
    final verificationId = state.verificationId;
    debugPrint('[biz auth] verifyOtp codeLength=${code.length} hasVerificationId=${verificationId != null} hasFirebaseUser=${_auth.currentUser != null}');
    if (verificationId == null) {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        debugPrint('[biz auth] verifyOtp falling back to currentUser token');
        final idToken = await currentUser.getIdToken();
        if (idToken != null) {
          state = state.copyWith(
            firebaseIdToken: idToken,
            loading: true,
            clearError: true,
          );
          await _exchangeWithBackend(idToken: idToken, name: state.pendingName);
          return;
        }
      }
      debugPrint('[biz auth] verifyOtp session expired');
      state = state.copyWith(error: 'Session expired — request OTP again');
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );
      debugPrint('[biz auth] verifyOtp credential created');
      await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint('[biz auth] verifyOtp firebaseException code=${e.code} message=${e.message}');
      state = state.copyWith(loading: false, error: e.message ?? 'Invalid OTP');
    } catch (e) {
      debugPrint('[biz auth] verifyOtp exception=$e');
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    debugPrint('[biz auth] signInWithCredential start');
    final userCred = await _auth.signInWithCredential(credential);
    final idToken = await userCred.user!.getIdToken();
    debugPrint('[biz auth] signInWithCredential done user=${userCred.user?.uid} tokenPresent=${idToken != null}');
    if (idToken == null) {
      state = state.copyWith(loading: false, error: 'Could not retrieve token');
      return;
    }
    state = state.copyWith(firebaseIdToken: idToken);
    await _exchangeWithBackend(idToken: idToken, name: state.pendingName);
  }

  Future<void> submitName(String name) async {
    final trimmed = name.trim();
    final token = state.firebaseIdToken;
    if (token == null) {
      state = state.copyWith(
          error: 'Session expired — restart login', step: AuthStep.phone);
      return;
    }
    if (trimmed.length < 2) {
      state = state.copyWith(error: 'Enter your full name');
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    await _exchangeWithBackend(idToken: token, name: trimmed);
  }

  void setPendingName(String? name) {
    final trimmed = name?.trim();
    state = state.copyWith(
      pendingName: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
    );
  }

  Future<void> _exchangeWithBackend(
      {required String idToken, String? name}) async {
    try {
      debugPrint('[biz auth] exchangeWithBackend start namePresent=${name != null && name.trim().isNotEmpty} step=${state.step.name}');
      final repo = _ref.read(hostBizRepositoryProvider);
      final result = await repo.bizLogin(idToken: idToken, name: name);
      debugPrint('[biz auth] exchangeWithBackend success isNewUser=${result.isNewUser} profiles=${result.businessStatus.availableProfiles.map((e) => e.name).join(",")} hasBusinessAccount=${result.businessStatus.hasBusinessAccount}');
      await _ref.read(sessionControllerProvider.notifier).signIn(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
          );
      debugPrint('[biz auth] session signIn completed');
      state = state.copyWith(
        loading: false,
        clearError: true,
        clearPendingName: true,
        clearVerificationId: true,
      );
    } catch (e) {
      final msg = e.toString();
      debugPrint('[biz auth] exchangeWithBackend exception=$msg');
      if (msg.contains('NAME_REQUIRED')) {
        state = state.copyWith(
            step: AuthStep.name, loading: false, clearError: true);
        return;
      }
      state = state.copyWith(loading: false, error: _humanize(msg));
    }
  }

  void resetToPhone() {
    state = const AuthFlowState();
  }

  String _normalize(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.startsWith('+')) return digits;
    if (digits.length == 10) return '+91$digits';
    return digits;
  }

  String _humanize(String raw) {
    if (raw.contains('NAME_REQUIRED')) return 'Name required';
    if (raw.contains('ACCOUNT_BANNED')) return 'Account banned';
    if (raw.contains('ACCOUNT_BLOCKED')) return 'Account blocked';
    return 'Login failed — please try again';
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthFlowState>(
  (ref) => AuthController(ref),
);
