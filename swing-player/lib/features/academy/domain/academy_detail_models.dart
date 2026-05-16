class BatchScheduleItem {
  const BatchScheduleItem({
    required this.id,
    required this.day,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.groundNote,
  });

  final String id;
  final String day;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String? groundNote;

  factory BatchScheduleItem.fromJson(Map<String, dynamic> j) => BatchScheduleItem(
        id: j['id'] as String,
        day: j['day'] as String,
        dayOfWeek: (j['dayOfWeek'] as num).toInt(),
        startTime: j['startTime'] as String,
        endTime: j['endTime'] as String,
        groundNote: j['groundNote'] as String?,
      );
}

class UpcomingSession {
  const UpcomingSession({
    required this.id,
    required this.scheduledAt,
    required this.durationMins,
    required this.isCancelled,
    required this.sessionType,
    this.cancelReason,
    this.locationName,
  });

  final String id;
  final DateTime scheduledAt;
  final int durationMins;
  final bool isCancelled;
  final String sessionType;
  final String? cancelReason;
  final String? locationName;

  factory UpcomingSession.fromJson(Map<String, dynamic> j) => UpcomingSession(
        id: j['id'] as String,
        scheduledAt: DateTime.parse(j['scheduledAt'] as String),
        durationMins: (j['durationMins'] as num).toInt(),
        isCancelled: j['isCancelled'] as bool? ?? false,
        sessionType: j['sessionType'] as String? ?? 'PRACTICE',
        cancelReason: j['cancelReason'] as String?,
        locationName: j['locationName'] as String?,
      );
}

class MyScheduleData {
  const MyScheduleData({
    required this.batchName,
    required this.schedules,
    required this.upcomingSessions,
  });

  final String? batchName;
  final List<BatchScheduleItem> schedules;
  final List<UpcomingSession> upcomingSessions;

  factory MyScheduleData.fromJson(Map<String, dynamic> j) => MyScheduleData(
        batchName: j['batchName'] as String?,
        schedules: (j['schedules'] as List<dynamic>)
            .map((e) => BatchScheduleItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        upcomingSessions: (j['upcomingSessions'] as List<dynamic>)
            .map((e) => UpcomingSession.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class AcademyAnnouncement {
  const AcademyAnnouncement({
    required this.id,
    required this.title,
    required this.body,
    required this.isPinned,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final bool isPinned;
  final DateTime createdAt;

  factory AcademyAnnouncement.fromJson(Map<String, dynamic> j) => AcademyAnnouncement(
        id: j['id'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        isPinned: j['isPinned'] as bool? ?? false,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

class DrillAssignmentItem {
  const DrillAssignmentItem({
    required this.id,
    required this.drillName,
    required this.targetQuantity,
    required this.targetUnit,
    required this.status,
    required this.assignedAt,
    this.dueDate,
    this.description,
    this.skillArea,
    this.difficulty,
    this.videoUrl,
  });

  final String id;
  final String drillName;
  final int targetQuantity;
  final String targetUnit;
  final String status;
  final DateTime assignedAt;
  final DateTime? dueDate;
  final String? description;
  final String? skillArea;
  final String? difficulty;
  final String? videoUrl;

  bool get isCompleted => status.toUpperCase() == 'COMPLETED';

  factory DrillAssignmentItem.fromJson(Map<String, dynamic> j) {
    final drill = j['drill'] as Map<String, dynamic>? ?? {};
    return DrillAssignmentItem(
      id: j['id'] as String,
      drillName: drill['name'] as String? ?? j['drillName'] as String? ?? 'Drill',
      targetQuantity: (j['targetQuantity'] as num?)?.toInt() ?? 0,
      targetUnit: j['targetUnit'] as String? ?? 'REPS',
      status: j['status'] as String? ?? 'ACTIVE',
      assignedAt: DateTime.parse(j['assignedAt'] as String? ?? j['createdAt'] as String),
      dueDate: j['dueDate'] != null ? DateTime.parse(j['dueDate'] as String) : null,
      description: drill['description'] as String?,
      skillArea: drill['skillArea'] as String?,
      difficulty: drill['difficulty'] as String?,
      videoUrl: drill['videoUrl'] as String?,
    );
  }
}

class ReportCardItem {
  const ReportCardItem({
    required this.id,
    required this.month,
    required this.summary,
    required this.highlights,
    required this.improvements,
    this.attendanceRate,
    this.drillCompletion,
    this.overallScore,
  });

  final String id;
  final String month;
  final String summary;
  final List<String> highlights;
  final List<String> improvements;
  final double? attendanceRate;
  final double? drillCompletion;
  final double? overallScore;

  factory ReportCardItem.fromJson(Map<String, dynamic> j) => ReportCardItem(
        id: j['id'] as String,
        month: j['month'] as String,
        summary: j['summary'] as String? ?? '',
        highlights: (j['highlights'] as List<dynamic>?)?.cast<String>() ?? [],
        improvements: (j['improvements'] as List<dynamic>?)?.cast<String>() ?? [],
        attendanceRate: (j['categoryScores']?['attendance'] as num?)?.toDouble(),
        drillCompletion: (j['categoryScores']?['drillCompletion'] as num?)?.toDouble(),
        overallScore: (j['overallScore'] as num?)?.toDouble(),
      );
}

class AcademyDetailData {
  const AcademyDetailData({
    required this.schedule,
    required this.announcements,
    required this.drillAssignments,
    required this.reportCards,
  });

  final MyScheduleData schedule;
  final List<AcademyAnnouncement> announcements;
  final List<DrillAssignmentItem> drillAssignments;
  final List<ReportCardItem> reportCards;
}
