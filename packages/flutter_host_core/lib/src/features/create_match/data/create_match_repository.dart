import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/host_dio_provider.dart';

class HostCreateMatchRepository {
  const HostCreateMatchRepository(this._dio);

  final Dio _dio;

  Future<String> createMatch({
    required String teamAName,
    required String teamBName,
    required String venueName,
    required String venueCity,
    required DateTime scheduledAt,
    required String format,
    required String matchType,
    int? customOvers,
    bool hasImpactPlayer = false,
  }) async {
    final response = await _dio.post(
      '/matches',
      data: {
        'teamAName': teamAName.trim(),
        'teamBName': teamBName.trim(),
        'venueName': venueName.trim(),
        'venueCity': venueCity.trim(),
        'scheduledAt': scheduledAt.toUtc().toIso8601String(),
        'format': format,
        'matchType': matchType,
        'hasImpactPlayer': hasImpactPlayer,
        if (format == 'CUSTOM' && customOvers != null) 'customOvers': customOvers,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final payload = data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;
      final id = '${payload['id'] ?? ''}'.trim();
      if (id.isNotEmpty) return id;
    }
    throw StateError('Match created but no match id was returned.');
  }
}

final hostCreateMatchRepositoryProvider = Provider<HostCreateMatchRepository>(
  (ref) => HostCreateMatchRepository(ref.watch(hostDioProvider)),
);
