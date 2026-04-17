import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/auth/token_storage.dart';

class AuthRepository {
  final _client = ApiClient.instance.dio;

  Future<PhoneCheckResult> checkPhone(String phoneNumber) async {
    final response = await _client.post(
      ApiEndpoints.checkPhone,
      data: {'phone': phoneNumber},
    );

    final payload = response.data as Map<String, dynamic>;
    final data = (payload['data'] ?? payload) as Map<String, dynamic>;

    return PhoneCheckResult(
      exists: data['exists'] as bool? ?? false,
      normalizedPhone: data['normalizedPhone'] as String? ?? phoneNumber,
    );
  }

  Future<LoginResult> loginWithFirebase({
    required String idToken,
    String? name,
  }) async {
    final response = await _client.post(
      ApiEndpoints.login,
      data: {
        'idToken': idToken,
        if (name != null && name.isNotEmpty) 'name': name,
        'initialRole': 'PLAYER',
      },
    );

    final payload = response.data as Map<String, dynamic>;
    final data = (payload['data'] ?? payload) as Map<String, dynamic>;
    final user = (data['user'] ?? <String, dynamic>{}) as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Login succeeded but no access token was returned.');
    }

    await TokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    if (user['id'] is String) {
      await TokenStorage.saveUserId(user['id'] as String);
    }

    var profileComplete = false;
    String? userRank;
    try {
      profileComplete = await fetchProfileComplete(
        accessToken: accessToken,
      );
    } catch (_) {
      profileComplete = false;
    }
    try {
      userRank = await fetchUserRank(
        accessToken: accessToken,
      );
    } catch (_) {
      userRank = null;
    }

    await TokenStorage.saveProfileComplete(profileComplete);
    if (userRank != null && userRank.isNotEmpty) {
      await TokenStorage.saveUserRank(userRank);
    }

    return LoginResult(
      accessToken: accessToken,
      refreshToken: refreshToken,
      isNewUser: data['isNewUser'] as bool? ?? false,
      isProfileComplete: profileComplete,
      userRank: userRank,
    );
  }

  Future<bool> fetchProfileComplete({String? accessToken}) async {
    final token = accessToken ?? await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) return false;

    final response = await _client.get(
      ApiEndpoints.playerProfile,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    final payload = response.data as Map<String, dynamic>;
    final data = (payload['data'] ?? payload) as Map<String, dynamic>;

    return data['dateOfBirth'] != null &&
        (data['city'] as String?)?.isNotEmpty == true;
  }

  Future<String?> fetchUserRank({String? accessToken}) async {
    final token = accessToken ?? await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) return null;

    final options = Options(
      headers: {'Authorization': 'Bearer $token'},
    );

    try {
      final response = await _client.get(
        ApiEndpoints.playerCompetitive,
        options: options,
      );
      final payload = response.data as Map<String, dynamic>;
      final data = (payload['data'] ?? payload) as Map<String, dynamic>;
      final rank = _normalizeRank(
        data['currentRankKey'] as String? ?? data['rankKey'] as String?,
      );
      if (rank != null) return rank;
    } catch (_) {
      // Fall through to profile endpoint.
    }

    final response = await _client.get(
      ApiEndpoints.playerProfile,
      options: options,
    );
    final payload = response.data as Map<String, dynamic>;
    final data = (payload['data'] ?? payload) as Map<String, dynamic>;

    return _normalizeRank(
      data['currentRankKey'] as String? ??
          data['swingRank'] as String? ??
          data['rank'] as String?,
    );
  }

  String? _normalizeRank(String? rawRank) {
    final value = (rawRank ?? '').trim();
    if (value.isEmpty) return null;

    final normalized = value
        .toLowerCase()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .first;

    return normalized.isEmpty ? null : normalized;
  }
}

class PhoneCheckResult {
  const PhoneCheckResult({
    required this.exists,
    required this.normalizedPhone,
  });

  final bool exists;
  final String normalizedPhone;
}

class LoginResult {
  const LoginResult({
    required this.accessToken,
    required this.refreshToken,
    required this.isNewUser,
    required this.isProfileComplete,
    this.userRank,
  });

  final String accessToken;
  final String? refreshToken;
  final bool isNewUser;
  final bool isProfileComplete;
  final String? userRank;
}
