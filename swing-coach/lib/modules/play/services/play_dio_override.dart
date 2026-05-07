import 'package:dio/dio.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _baseUrl = 'https://swing-backend-1007730655118.asia-south1.run.app';

List<Override> hostPlayOverridesForCoachToken(String accessToken) {
  return [
    hostDioOverrideForCoachToken(accessToken),
    hostPathConfigProvider.overrideWithValue(HostPathConfig.club()),
  ];
}

Override hostDioOverrideForCoachToken(String accessToken) {
  return hostDioProvider.overrideWith((ref) {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 45),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    if (accessToken.trim().isNotEmpty) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers['Authorization'] = 'Bearer $accessToken';
            handler.next(options);
          },
        ),
      );
    }
    return dio;
  });
}
