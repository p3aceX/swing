import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_host_core/flutter_host_core.dart';

import '../auth/token_storage.dart';

class ApiClient {
  ApiClient._() {
    final baseUrl = _resolveBaseUrl();
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    if (kDebugMode) {
      debugPrint('[biz API] baseUrl=$baseUrl');
    }
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
          if (error.response?.statusCode != 401 ||
              error.requestOptions.path == HostContracts.bizLogin ||
              error.requestOptions.path == HostContracts.authRefresh) {
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
  static const String _canonicalBaseUrl =
      'https://swing-backend-1007730655118.asia-south1.run.app';

  late final Dio _dio;
  final List<Completer<String?>> _refreshWaiters = [];
  bool _refreshing = false;

  final _sessionExpiredController = StreamController<void>.broadcast();
  Stream<void> get sessionExpired => _sessionExpiredController.stream;

  Dio get dio => _dio;

  String _resolveBaseUrl() {
    return _canonicalBaseUrl;
  }

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
        HostContracts.authRefresh,
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

      for (final w in _refreshWaiters) {
        w.complete(accessToken);
      }
      _refreshWaiters.clear();
      return accessToken;
    } catch (e) {
      for (final w in _refreshWaiters) {
        w.completeError(e);
      }
      _refreshWaiters.clear();
      rethrow;
    } finally {
      _refreshing = false;
    }
  }

}
