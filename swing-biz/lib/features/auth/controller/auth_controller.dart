import 'package:firebase_auth/firebase_auth.dart';
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
  });

  final AuthStep step;
  final String phone;
  final bool loading;
  final String? error;
  final String? firebaseIdToken;

  AuthFlowState copyWith({
    AuthStep? step,
    String? phone,
    bool? loading,
    String? error,
    bool clearError = false,
    String? firebaseIdToken,
  }) =>
      AuthFlowState(
        step: step ?? this.step,
        phone: phone ?? this.phone,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
        firebaseIdToken: firebaseIdToken ?? this.firebaseIdToken,
      );
}

class AuthController extends StateNotifier<AuthFlowState> {
  AuthController(this._ref) : super(const AuthFlowState());

  final Ref _ref;
  String? _verificationId;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<void> sendOtp(String rawPhone) async {
    final phone = _normalize(rawPhone);
    if (!RegExp(r'^\+\d{10,15}$').hasMatch(phone)) {
      state = state.copyWith(error: 'Enter a valid phone number');
      return;
    }
    state = state.copyWith(loading: true, phone: phone, clearError: true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (e) {
          state = state.copyWith(loading: false, error: e.message ?? 'Verification failed');
        },
        codeSent: (verificationId, _) {
          _verificationId = verificationId;
          state = state.copyWith(step: AuthStep.otp, loading: false);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> verifyOtp(String code) async {
    if (_verificationId == null) {
      state = state.copyWith(error: 'Session expired — request OTP again');
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(loading: false, error: e.message ?? 'Invalid OTP');
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    final userCred = await _auth.signInWithCredential(credential);
    final idToken = await userCred.user!.getIdToken();
    if (idToken == null) {
      state = state.copyWith(loading: false, error: 'Could not retrieve token');
      return;
    }
    state = state.copyWith(firebaseIdToken: idToken);
    await _exchangeWithBackend(idToken: idToken);
  }

  Future<void> submitName(String name) async {
    final token = state.firebaseIdToken;
    if (token == null) {
      state = state.copyWith(error: 'Session expired — restart login', step: AuthStep.phone);
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    await _exchangeWithBackend(idToken: token, name: name);
  }

  Future<void> _exchangeWithBackend({required String idToken, String? name}) async {
    try {
      final repo = _ref.read(hostBizRepositoryProvider);
      final result = await repo.bizLogin(idToken: idToken, name: name);
      await _ref.read(sessionControllerProvider.notifier).signIn(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
          );
      state = state.copyWith(loading: false, clearError: true);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('NAME_REQUIRED')) {
        state = state.copyWith(step: AuthStep.name, loading: false, clearError: true);
        return;
      }
      state = state.copyWith(loading: false, error: _humanize(msg));
    }
  }

  void resetToPhone() {
    state = const AuthFlowState();
    _verificationId = null;
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
    StateNotifierProvider.autoDispose<AuthController, AuthFlowState>(
  (ref) => AuthController(ref),
);
