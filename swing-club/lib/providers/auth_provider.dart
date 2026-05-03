import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/secure_storage.dart';

// ── BusinessStatus model ────────────────────────────────────────────────────
class BusinessStatus {
  final bool hasBusinessAccount;
  final String? businessAccountId;
  final List<String> availableProfiles;
  final String? academyId;

  const BusinessStatus({
    this.hasBusinessAccount = false,
    this.businessAccountId,
    this.availableProfiles = const [],
    this.academyId,
  });

  bool get hasAcademy => availableProfiles.contains('ACADEMY');

  factory BusinessStatus.fromMap(Map<String, dynamic> m) => BusinessStatus(
        hasBusinessAccount: m['hasBusinessAccount'] as bool? ?? false,
        businessAccountId: m['businessAccountId'] as String?,
        availableProfiles: (m['availableProfiles'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        academyId: m['academyId'] as String?,
      );
}

// ── AuthState ───────────────────────────────────────────────────────────────
class AuthState {
  final String? accessToken;
  final String? refreshToken;
  final bool isAuthenticated;
  final String? userId;
  final BusinessStatus? businessStatus;

  const AuthState({
    this.accessToken,
    this.refreshToken,
    this.isAuthenticated = false,
    this.userId,
    this.businessStatus,
  });

  AuthState copyWith({
    String? accessToken,
    String? refreshToken,
    bool? isAuthenticated,
    String? userId,
    BusinessStatus? businessStatus,
  }) =>
      AuthState(
        accessToken:    accessToken    ?? this.accessToken,
        refreshToken:   refreshToken   ?? this.refreshToken,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        userId:         userId         ?? this.userId,
        businessStatus: businessStatus ?? this.businessStatus,
      );
}

// ── AuthNotifier ─────────────────────────────────────────────────────────────
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    final storage = ref.read(secureStorageProvider);
    final access  = storage.cachedAccessToken;
    final refresh = storage.cachedRefreshToken;
    if (access != null && refresh != null) {
      return AuthState(accessToken: access, refreshToken: refresh, isAuthenticated: true);
    }
    return const AuthState();
  }

  Future<void> login({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required BusinessStatus businessStatus,
  }) async {
    final storage = ref.read(secureStorageProvider);
    await storage.saveTokens(access: accessToken, refresh: refreshToken);
    await storage.saveUserId(userId);
    if (businessStatus.academyId != null) {
      await storage.saveAcademyId(businessStatus.academyId!);
    }
    state = AuthState(
      accessToken:     accessToken,
      refreshToken:    refreshToken,
      isAuthenticated: true,
      userId:          userId,
      businessStatus:  businessStatus,
    );
  }

  void updateTokens(String accessToken, String refreshToken) {
    ref.read(secureStorageProvider).saveTokens(access: accessToken, refresh: refreshToken);
    state = state.copyWith(accessToken: accessToken, refreshToken: refreshToken);
  }

  void setBusinessStatus(BusinessStatus status) {
    state = state.copyWith(businessStatus: status);
  }

  Future<void> logout() async {
    await ref.read(secureStorageProvider).clear();
    state = const AuthState();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────
final secureStorageProvider = Provider<SecureStorage>((_) => throw UnimplementedError());
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
