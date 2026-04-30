import 'package:flutter/foundation.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/auth/two_factor_service.dart';
import '../../../core/auth/biometric_service.dart';
import '../../../core/auth/token_storage.dart';

enum AuthStep { phone, otp, name }

class AuthFlowState {
  const AuthFlowState({
    this.step = AuthStep.phone,
    this.phone = '',
    this.loading = false,
    this.error,
    this.idToken, // Used to store temporary credentials or backend tokens
    this.pendingName,
    this.verificationId, // Stores the 2Factor Session ID
    this.needsBiometricEnrollment = false,
  });

  final AuthStep step;
  final String phone;
  final bool loading;
  final String? error;
  final String? idToken;
  final String? pendingName;
  final String? verificationId;
  final bool needsBiometricEnrollment;

  AuthFlowState copyWith({
    AuthStep? step,
    String? phone,
    bool? loading,
    String? error,
    bool clearError = false,
    String? idToken,
    String? pendingName,
    bool clearPendingName = false,
    String? verificationId,
    bool clearVerificationId = false,
    bool? needsBiometricEnrollment,
  }) =>
      AuthFlowState(
        step: step ?? this.step,
        phone: phone ?? this.phone,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
        idToken: idToken ?? this.idToken,
        pendingName: clearPendingName ? null : (pendingName ?? this.pendingName),
        verificationId:
            clearVerificationId ? null : (verificationId ?? this.verificationId),
        needsBiometricEnrollment:
            needsBiometricEnrollment ?? this.needsBiometricEnrollment,
      );
}

class AuthController extends StateNotifier<AuthFlowState> {
  AuthController(this._ref) : super(const AuthFlowState());

  final Ref _ref;

  Future<void> sendOtp(String rawPhone) async {
    final phone = _normalize(rawPhone);
    if (!RegExp(r'^\+\d{10,15}$').hasMatch(phone)) {
      state = state.copyWith(error: 'Enter a valid phone number');
      return;
    }
    state = state.copyWith(
      step: AuthStep.phone,
      loading: true,
      phone: phone,
      clearError: true,
    );

    try {
      // Use 2Factor instead of Firebase
      final sessionId = await TwoFactorService.instance.sendOtp(phone);
      
      if (sessionId != null) {
        state = state.copyWith(
          step: AuthStep.otp,
          loading: false,
          verificationId: sessionId,
        );
      } else {
        state = state.copyWith(
          loading: false,
          error: 'Failed to send OTP. Please try again.',
        );
      }
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<PhoneCheckResult> checkPhone(String rawPhone) async {
    final phone = _normalize(rawPhone);
    state = state.copyWith(
      step: AuthStep.phone,
      loading: true,
      clearError: true,
    );
    try {
      final repo = _ref.read(hostBizRepositoryProvider);
      final result = await repo.checkPhone(phone);
      state = state.copyWith(loading: false, phone: result.normalizedPhone);
      return result;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> verifyOtp(String code) async {
    final sessionId = state.verificationId;
    if (sessionId == null) {
      state = state.copyWith(error: 'Session expired — request OTP again');
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _exchangeWithBackend(
        phone: state.phone,
        sessionId: sessionId,
        otp: code,
        name: state.pendingName,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> submitName(String name) async {
    final trimmed = name.trim();
    if (trimmed.length < 2) {
      state = state.copyWith(error: 'Enter your full name');
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    await _exchangeWithBackend(
      phone: state.phone,
      sessionId: state.verificationId ?? '',
      otp: state.idToken ?? '',
      name: trimmed,
    );
  }

  void setPendingName(String? name) {
    final trimmed = name?.trim();
    state = state.copyWith(
      pendingName: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
    );
  }

  Future<void> _exchangeWithBackend({
    required String phone,
    required String sessionId,
    required String otp,
    String? name,
  }) async {
    debugPrint('Auth: Exchanging with backend. Phone: $phone, Name: $name');
    try {
      final repo = _ref.read(hostBizRepositoryProvider);
      final result = await repo.bizPhoneLogin(
        phone: phone,
        sessionId: sessionId,
        otp: otp,
        name: name,
      );
      
      await _ref.read(sessionControllerProvider.notifier).signIn(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
          );

      bool needsBio = false;
      try {
        final bioAvailable = await BiometricService.instance.isAvailable();
        final bioEnabled = await TokenStorage.isBiometricEnabled();
        if (bioAvailable && !bioEnabled) {
          needsBio = true;
        }
      } catch (_) {}

      state = state.copyWith(
        loading: false,
        clearError: true,
        clearPendingName: true,
        clearVerificationId: true,
        needsBiometricEnrollment: needsBio,
      );
    } catch (e) {
      debugPrint('Auth: Exchange Error: $e');
      final msg = e.toString();
      if (msg.contains('NAME_REQUIRED')) {
        // Cache otp in idToken field so submitName can re-use it
        state = state.copyWith(
          step: AuthStep.name,
          loading: false,
          clearError: true,
          idToken: otp,
        );
        return;
      }
      state = state.copyWith(loading: false, error: _humanize(msg));
    }
  }

  Future<void> enableBiometrics() async {
    try {
      final passed = await BiometricService.instance.authenticate();
      if (passed) {
        await TokenStorage.setBiometricEnabled(true, phone: state.phone);
        state = state.copyWith(needsBiometricEnrollment: false);
        debugPrint('Auth: Biometrics manually enabled for ${state.phone}');
      }
    } catch (e) {
      debugPrint('Auth: Failed to enable biometrics: $e');
    }
  }

  void skipBiometrics() {
    state = state.copyWith(needsBiometricEnrollment: false);
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
