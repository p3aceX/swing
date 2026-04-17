import 'package:dio/dio.dart';
import 'cache_manager.dart';

abstract class BaseRepository {
  String generateCacheKey(String path, {Map<String, dynamic>? queryParameters}) {
    final queryStr = queryParameters?.entries.map((e) => '${e.key}=${e.value}').join('&') ?? '';
    return 'GET:$path?$queryStr';
  }

  /// Returns cached data if available, otherwise null.
  dynamic getCached(String key) => CacheManager.get(key);

  /// Saves data to cache.
  Future<void> saveToCache(String key, dynamic data, {Duration? ttl}) =>
      CacheManager.set(key, data, ttl: ttl);
}
