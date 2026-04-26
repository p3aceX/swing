import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contracts/host_path_config.dart';
import '../../../providers/host_dio_provider.dart';

class HostCreateTeamRepository {
  const HostCreateTeamRepository(this._dio, this._paths);

  final Dio _dio;
  final HostPathConfig _paths;

  Future<String> createTeam({
    required String name,
    String? shortName,
    String? logoUrl,
    String? city,
    required String teamType,
    required bool iAmCaptain,
  }) async {
    final response = await _dio.post(
      _paths.myTeams,
      data: {
        'name': name.trim(),
        if ((shortName ?? '').trim().isNotEmpty) 'shortName': shortName!.trim(),
        if ((logoUrl ?? '').trim().isNotEmpty) 'logoUrl': logoUrl!.trim(),
        if ((city ?? '').trim().isNotEmpty) 'city': city!.trim(),
        'teamType': teamType,
        'iAmCaptain': iAmCaptain,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is Map<String, dynamic>) {
        return '${inner['id'] ?? ''}';
      }
      return '${data['id'] ?? ''}';
    }
    return '';
  }
}

final hostCreateTeamRepositoryProvider = Provider<HostCreateTeamRepository>(
  (ref) => HostCreateTeamRepository(
    ref.watch(hostDioProvider),
    ref.watch(hostPathConfigProvider),
  ),
);
