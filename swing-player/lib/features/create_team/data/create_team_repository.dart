import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class CreateTeamRepository {
  final _client = ApiClient.instance.dio;

  Future<String> createTeam({
    required String name,
    String? shortName,
    String? logoUrl,
    String? city,
    required String teamType,
    required bool iAmCaptain,
  }) async {
    final response = await _client.post(
      ApiEndpoints.myTeams,
      data: {
        'name': name,
        if (shortName != null && shortName.isNotEmpty) 'shortName': shortName,
        if (logoUrl != null && logoUrl.isNotEmpty) 'logoUrl': logoUrl,
        if (city != null && city.isNotEmpty) 'city': city,
        'teamType': teamType,
        'iAmCaptain': iAmCaptain,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is Map<String, dynamic>) return (inner['id'] as String?) ?? '';
    }
    return '';
  }
}
