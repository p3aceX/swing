import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'constants.dart';
import 'token_storage.dart';
import '../providers/auth_provider.dart';

class ApiClient {
  late final Dio _dio;
  final TokenStorage _storage;
  final Ref _ref;
  bool _isRefreshing = false;

  ApiClient(this._storage, this._ref) {
    _dio = Dio(BaseOptions(
      baseUrl: kBackendBaseUrl,
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _storage.accessToken;
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (err, handler) async {
        if (err.response?.statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;
          try {
            final refresh = _storage.refreshToken;
            if (refresh != null) {
              final res = await Dio().post(
                '$kBackendBaseUrl/auth/refresh',
                data: {'refreshToken': refresh},
              );
              if (res.data['success'] == true) {
                final newAccess = res.data['data']['accessToken'] as String;
                final newRefresh = (res.data['data']['refreshToken'] as String?) ?? refresh;
                await _storage.saveTokens(access: newAccess, refresh: newRefresh);
                _ref.read(authProvider.notifier).updateTokens(newAccess, newRefresh);
                final opts = err.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newAccess';
                final response = await _dio.fetch(opts);
                _isRefreshing = false;
                handler.resolve(response);
                return;
              }
            }
          } catch (_) {}
          _isRefreshing = false;
          await _storage.clear();
          _ref.read(authProvider.notifier).logout();
        }
        handler.next(err);
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) =>
      _dio.get(path, queryParameters: params);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> patch(String path, {dynamic data}) =>
      _dio.patch(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(tokenStorageProvider);
  return ApiClient(storage, ref);
});
