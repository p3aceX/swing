import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../contracts/host_path_config.dart';
import '../providers/host_dio_provider.dart';

class HostPlayerRepository {
  HostPlayerRepository(this._dio, this._paths);

  final Dio _dio;
  final HostPathConfig _paths;

  Future<List<Map<String, dynamic>>> searchPlayers(String query) async {
    final response = await _dio.get(
      _paths.playerSearch,
      queryParameters: {
        'q': query.trim(),
        'limit': 20,
      },
    );
    final data = response.data;
    final payload = data is Map<String, dynamic>
        ? (data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data)
        : <String, dynamic>{};
    final rows =
        payload['data'] ?? payload['players'] ?? payload['results'] ?? const [];
    if (rows is! List) return const [];
    return rows
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }
}

final hostPlayerRepositoryProvider = Provider<HostPlayerRepository>(
  (ref) => HostPlayerRepository(
    ref.watch(hostDioProvider),
    ref.watch(hostPathConfigProvider),
  ),
);
