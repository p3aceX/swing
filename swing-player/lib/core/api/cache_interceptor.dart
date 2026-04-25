import 'package:dio/dio.dart';
import 'cache_manager.dart';

class CacheInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method.toUpperCase() == 'GET' &&
        options.extra['refresh'] != true) {
      final cacheKey = _generateCacheKey(options);
      final cachedData = CacheManager.get(cacheKey);

      if (cachedData != null) {
        // If we have cached data, we can resolve immediately.
        // Note: For a "cache-then-network" strategy at the Interceptor level,
        // we'd need more complex logic. For now, we'll let the Repository 
        // handle the stream-based dual emission, but this provides a 
        // safety net for other GET requests.
        if (options.extra['cacheOnly'] == true) {
           return handler.resolve(
            Response(
              requestOptions: options,
              data: cachedData,
              statusCode: 200,
              statusMessage: 'OK (from cache)',
            ),
          );
        }
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    if (response.requestOptions.method.toUpperCase() == 'GET' &&
        response.statusCode == 200 &&
        (data is Map || data is List)) {
      final cacheKey = _generateCacheKey(response.requestOptions);
      CacheManager.set(cacheKey, data, ttl: const Duration(hours: 24));
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.method.toUpperCase() == 'GET') {
      final cacheKey = _generateCacheKey(err.requestOptions);
      final cachedData = CacheManager.get(cacheKey);

      if (cachedData != null) {
        // If there's an error but we have cached data, return it
        return handler.resolve(
          Response(
            requestOptions: err.requestOptions,
            data: cachedData,
            statusCode: 200,
            statusMessage: 'OK (from cache)',
          ),
        );
      }
    }
    handler.next(err);
  }

  String _generateCacheKey(RequestOptions options) {
    return '${options.method}:${options.uri.toString()}';
  }
}
