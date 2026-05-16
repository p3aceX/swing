import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/academy_detail_models.dart';

class AcademyDetailRepository {
  final _client = ApiClient.instance.dio;

  Future<MyScheduleData> getMySchedule() async {
    final res = await _client.get(ApiEndpoints.playerMySchedule);
    final data = (res.data['data'] as Map<String, dynamic>);
    return MyScheduleData.fromJson(data);
  }

  Future<List<AcademyAnnouncement>> getMyAnnouncements() async {
    final res = await _client.get(ApiEndpoints.playerMyAnnouncements);
    final data = res.data['data'] as Map<String, dynamic>;
    return (data['announcements'] as List<dynamic>)
        .map((e) => AcademyAnnouncement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<DrillAssignmentItem>> getDrillAssignments() async {
    final res = await _client.get(ApiEndpoints.playerDrillAssignments);
    final raw = res.data['data'];
    final list = raw is List ? raw : (raw as Map<String, dynamic>)['assignments'] as List<dynamic>? ?? [];
    return list.map((e) => DrillAssignmentItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ReportCardItem>> getReportCards() async {
    final res = await _client.get(ApiEndpoints.playerReportCards);
    final data = res.data['data'] as Map<String, dynamic>;
    return (data['reportCards'] as List<dynamic>)
        .map((e) => ReportCardItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> logDrillProgress(String assignmentId, int quantity) async {
    await _client.post(ApiEndpoints.drillLog(assignmentId), data: {'quantityDone': quantity});
  }
}
