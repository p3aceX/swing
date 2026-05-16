import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/academy_detail_repository.dart';
import '../domain/academy_detail_models.dart';

final _repo = AcademyDetailRepository();

final academyDetailProvider = FutureProvider<AcademyDetailData>((ref) async {
  final results = await Future.wait([
    _repo.getMySchedule(),
    _repo.getMyAnnouncements(),
    _repo.getDrillAssignments(),
    _repo.getReportCards(),
  ]);
  return AcademyDetailData(
    schedule: results[0] as MyScheduleData,
    announcements: results[1] as List<AcademyAnnouncement>,
    drillAssignments: results[2] as List<DrillAssignmentItem>,
    reportCards: results[3] as List<ReportCardItem>,
  );
});

final academyDetailRepositoryProvider = Provider<AcademyDetailRepository>((_) => _repo);
