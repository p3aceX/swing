import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../auth/token_storage.dart';
import 'api_endpoints.dart';
import 'cache_interceptor.dart';

class ApiClient {
  ApiClient._() {
    final baseUrl = _resolveBaseUrl();
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(CacheInterceptor());
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Retry on 429 (too many requests) or 503 with exponential backoff
          final status = error.response?.statusCode;
          if (status == 429 || status == 503) {
            final retryCount =
                (error.requestOptions.extra['_retryCount'] as int?) ?? 0;
            if (retryCount < 3) {
              final delay = Duration(milliseconds: 500 * (1 << retryCount));
              await Future.delayed(delay);
              final opts = error.requestOptions;
              opts.extra['_retryCount'] = retryCount + 1;
              try {
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(e is DioException ? e : error);
              }
            }
          }

          if (error.response?.statusCode != 401 ||
              error.requestOptions.path == ApiEndpoints.login) {
            return handler.next(error);
          }

          try {
            final newToken = await _refreshAccessToken();
            if (newToken == null) {
              await _expireSession();
              return handler.next(error);
            }

            final request = error.requestOptions;
            request.headers['Authorization'] = 'Bearer $newToken';
            final response = await _dio.fetch(request);
            return handler.resolve(response);
          } catch (_) {
            await _expireSession();
            return handler.next(error);
          }
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._();
  static const String canonicalBaseUrl =
      'https://swing-backend-1007730655118.asia-south1.run.app';
  static const Set<String> _deprecatedHosts = {
    'https://swing-backend-nbid5gga4q-de.a.run.app',
    'https://swing-backend-nbid5gga4q-el.a.run.app',
  };

  late final Dio _dio;
  final List<Completer<String?>> _refreshWaiters = [];
  bool _refreshing = false;

  /// Emits when the session is forcibly cleared because a mid-session token
  /// refresh failed. AuthController subscribes to this and redirects to login.
  final _sessionExpiredController = StreamController<void>.broadcast();
  Stream<void> get sessionExpired => _sessionExpiredController.stream;

  Dio get dio => _dio;

  static String normalizeBaseUrl(String? rawUrl) {
    final trimmed = rawUrl?.trim() ?? '';
    if (trimmed.isEmpty) {
      return canonicalBaseUrl;
    }
    if (_deprecatedHosts.contains(trimmed)) {
      return canonicalBaseUrl;
    }
    return trimmed;
  }

  String _resolveBaseUrl() {
    final envUrl = normalizeBaseUrl(dotenv.env['API_BASE_URL']);
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    if (kIsWeb) return 'http://localhost:3000';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3000';
      default:
        return 'http://localhost:3000';
    }
  }

  /// Clears stored tokens and signals all listeners that the session expired.
  Future<void> _expireSession() async {
    await TokenStorage.clear();
    _sessionExpiredController.add(null);
  }

  Future<String?> _refreshAccessToken() async {
    if (_refreshing) {
      final waiter = Completer<String?>();
      _refreshWaiters.add(waiter);
      return waiter.future;
    }

    _refreshing = true;
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) return null;

      final response = await Dio(BaseOptions(baseUrl: _resolveBaseUrl())).post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final payload = response.data as Map<String, dynamic>;
      final data = (payload['data'] ?? payload) as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String?;
      final nextRefreshToken = data['refreshToken'] as String?;

      if (accessToken == null) return null;
      await TokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: nextRefreshToken ?? refreshToken,
      );

      for (final waiter in _refreshWaiters) {
        waiter.complete(accessToken);
      }
      _refreshWaiters.clear();
      return accessToken;
    } catch (error) {
      for (final waiter in _refreshWaiters) {
        waiter.completeError(error);
      }
      _refreshWaiters.clear();
      rethrow;
    } finally {
      _refreshing = false;
    }
  }
}
