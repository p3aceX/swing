import 'package:flutter/material.dart';

enum CoachSessionState { upcoming, live, completed }

enum AttendanceMark { present, absent, late }

class CoachDashboardSession {
  const CoachDashboardSession({
    required this.id,
    required this.batchName,
    required this.sport,
    required this.startLabel,
    required this.endLabel,
    required this.dateLabel,
    required this.location,
    required this.studentCount,
    required this.capacity,
    required this.icon,
    required this.state,
    required this.notes,
    required this.students,
  });

  final String id;
  final String batchName;
  final String sport;
  final String startLabel;
  final String endLabel;
  final String dateLabel;
  final String location;
  final int studentCount;
  final int capacity;
  final IconData icon;
  final CoachSessionState state;
  final String notes;
  final List<String> students;

  String get timeRange => '$startLabel - $endLabel';
}

class CoachStudentNote {
  const CoachStudentNote({
    required this.date,
    required this.note,
    this.rating,
  });

  final String date;
  final String note;
  final int? rating;
}

class CoachHealthNote {
  const CoachHealthNote({
    required this.date,
    required this.description,
    required this.severity,
    required this.status,
    required this.followUpRequired,
  });

  final String date;
  final String description;
  final String severity;
  final String status;
  final bool followUpRequired;
}

class CoachAttendanceEntry {
  const CoachAttendanceEntry({
    required this.date,
    required this.batch,
    required this.status,
  });

  final String date;
  final String batch;
  final String status;
}

class CoachStudentSkill {
  const CoachStudentSkill({
    required this.label,
    required this.rating,
  });

  final String label;
  final int rating;
}

class CoachStudent {
  const CoachStudent({
    required this.id,
    required this.name,
    required this.age,
    required this.ageGroup,
    required this.batch,
    required this.joinDate,
    required this.status,
    required this.attendancePercent,
    required this.attendedSessions,
    required this.totalSessions,
    required this.performanceRating,
    required this.parentName,
    required this.phone,
    required this.skills,
    required this.performanceNotes,
    required this.healthNotes,
    required this.attendanceHistory,
  });

  final String id;
  final String name;
  final int age;
  final String ageGroup;
  final String batch;
  final String joinDate;
  final String status;
  final int attendancePercent;
  final int attendedSessions;
  final int totalSessions;
  final double performanceRating;
  final String parentName;
  final String phone;
  final List<CoachStudentSkill> skills;
  final List<CoachStudentNote> performanceNotes;
  final List<CoachHealthNote> healthNotes;
  final List<CoachAttendanceEntry> attendanceHistory;
}

class CoachTrainingSessionTemplate {
  const CoachTrainingSessionTemplate({
    required this.name,
    required this.durationMinutes,
    required this.drills,
    required this.notes,
  });

  final String name;
  final int durationMinutes;
  final List<String> drills;
  final String notes;
}

class CoachTrainingWeek {
  const CoachTrainingWeek({
    required this.title,
    required this.sessions,
  });

  final String title;
  final List<CoachTrainingSessionTemplate> sessions;
}

class CoachTrainingPlan {
  const CoachTrainingPlan({
    required this.id,
    required this.name,
    required this.sport,
    required this.targetBatches,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.objective,
    required this.drillsUsed,
    required this.weeks,
  });

  final String id;
  final String name;
  final String sport;
  final List<String> targetBatches;
  final String duration;
  final String startDate;
  final String endDate;
  final String status;
  final String objective;
  final List<String> drillsUsed;
  final List<CoachTrainingWeek> weeks;
}

class CoachEarningsHistory {
  const CoachEarningsHistory({
    required this.month,
    required this.amount,
    required this.status,
  });

  final String month;
  final int amount;
  final String status;
}

class CoachQuickModule {
  const CoachQuickModule({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

const coachName = 'Rohan Mehta';
const coachAcademy = 'Swing Academy';
const coachPlan = 'FREE';
const coachRole = 'Head Coach';
const coachRating = 4.5;

const coachAssignedBatches = [
  'Batch A1 - Mon, Wed, Fri - 6:00 PM',
  'Batch B2 - Tue, Thu, Sat - 7:45 PM',
  'Fielding Pro - Sun - 8:00 AM',
];

const coachActivities = [
  'You conducted 3 sessions this week',
  'Earnings updated: +Rs 1,500',
  'Attendance saved for Batch A1',
];

const coachQuickStats = {
  'sessions': '42 / 45 (93%)',
  'attendance': '87%',
  'earnings': 'Rs 25,000',
};

const coachSessions = [
  CoachDashboardSession(
    id: 'a1',
    batchName: 'Batch A1',
    sport: 'Cricket',
    startLabel: '6:00 PM',
    endLabel: '7:30 PM',
    dateLabel: 'Today',
    location: 'Main Nets',
    studentCount: 12,
    capacity: 15,
    icon: Icons.sports_cricket_rounded,
    state: CoachSessionState.upcoming,
    notes: 'Focus on front-foot defense and controlled drives.',
    students: [
      'Aarav Sharma',
      'Kabir Khan',
      'Vivaan Gupta',
      'Advik Joshi',
    ],
  ),
  CoachDashboardSession(
    id: 'b2',
    batchName: 'Batch B2',
    sport: 'Cricket',
    startLabel: '7:45 PM',
    endLabel: '8:45 PM',
    dateLabel: 'Today',
    location: 'Indoor Practice Bay',
    studentCount: 10,
    capacity: 12,
    icon: Icons.sports_baseball_rounded,
    state: CoachSessionState.live,
    notes: 'Fielding reactions and catching under lights.',
    students: [
      'Meera Iyer',
      'Anaya Patel',
      'Ishaan Rao',
      'Diya Nair',
    ],
  ),
  CoachDashboardSession(
    id: 'c3',
    batchName: 'Fitness Elite',
    sport: 'Conditioning',
    startLabel: '5:30 AM',
    endLabel: '6:15 AM',
    dateLabel: 'Today',
    location: 'Track',
    studentCount: 8,
    capacity: 10,
    icon: Icons.fitness_center_rounded,
    state: CoachSessionState.completed,
    notes: 'Sprint patterns, mobility, and ladder coordination.',
    students: [
      'Aarav Sharma',
      'Anaya Patel',
      'Kabir Khan',
      'Ishaan Rao',
    ],
  ),
  CoachDashboardSession(
    id: 'd4',
    batchName: 'Weekend Skills',
    sport: 'Cricket',
    startLabel: '8:00 AM',
    endLabel: '9:30 AM',
    dateLabel: 'Saturday',
    location: 'Turf 2',
    studentCount: 14,
    capacity: 16,
    icon: Icons.track_changes_rounded,
    state: CoachSessionState.upcoming,
    notes: 'Rotation strike play and pressure drills.',
    students: [
      'Kabir Khan',
      'Vivaan Gupta',
      'Meera Iyer',
      'Diya Nair',
    ],
  ),
];

const coachStudents = [
  CoachStudent(
    id: 'stu-1',
    name: 'Aarav Sharma',
    age: 13,
    ageGroup: 'U-14',
    batch: 'Batch A1',
    joinDate: '12 Jan 2026',
    status: 'Active',
    attendancePercent: 95,
    attendedSessions: 19,
    totalSessions: 20,
    performanceRating: 8.6,
    parentName: 'Ritesh Sharma',
    phone: '+91 98765 11111',
    skills: [
      CoachStudentSkill(label: 'Ball Control', rating: 4),
      CoachStudentSkill(label: 'Shot Selection', rating: 4),
      CoachStudentSkill(label: 'Fitness', rating: 3),
      CoachStudentSkill(label: 'Teamwork', rating: 5),
    ],
    performanceNotes: [
      CoachStudentNote(
        date: '20 Apr 2026',
        note: 'Excellent timing through covers. Needs stronger calling.',
        rating: 8,
      ),
      CoachStudentNote(
        date: '12 Apr 2026',
        note: 'Improved movement against short ball.',
      ),
    ],
    healthNotes: [
      CoachHealthNote(
        date: '02 Apr 2026',
        description: 'Minor ankle strain during sprint work.',
        severity: 'Minor',
        status: 'Resolved',
        followUpRequired: false,
      ),
    ],
    attendanceHistory: [
      CoachAttendanceEntry(
          date: '20 Apr', batch: 'Batch A1', status: 'Present'),
      CoachAttendanceEntry(
          date: '18 Apr', batch: 'Batch A1', status: 'Present'),
      CoachAttendanceEntry(date: '16 Apr', batch: 'Batch A1', status: 'Late'),
    ],
  ),
  CoachStudent(
    id: 'stu-2',
    name: 'Meera Iyer',
    age: 11,
    ageGroup: 'U-12',
    batch: 'Batch B2',
    joinDate: '03 Feb 2026',
    status: 'Active',
    attendancePercent: 91,
    attendedSessions: 20,
    totalSessions: 22,
    performanceRating: 8.1,
    parentName: 'Lakshmi Iyer',
    phone: '+91 98765 22222',
    skills: [
      CoachStudentSkill(label: 'Footwork', rating: 4),
      CoachStudentSkill(label: 'Reaction Time', rating: 4),
      CoachStudentSkill(label: 'Throwing', rating: 3),
      CoachStudentSkill(label: 'Confidence', rating: 4),
    ],
    performanceNotes: [
      CoachStudentNote(
        date: '18 Apr 2026',
        note: 'Good reaction speed in catching drills.',
        rating: 8,
      ),
    ],
    healthNotes: [],
    attendanceHistory: [
      CoachAttendanceEntry(
          date: '19 Apr', batch: 'Batch B2', status: 'Present'),
      CoachAttendanceEntry(date: '17 Apr', batch: 'Batch B2', status: 'Absent'),
      CoachAttendanceEntry(
          date: '15 Apr', batch: 'Batch B2', status: 'Present'),
    ],
  ),
  CoachStudent(
    id: 'stu-3',
    name: 'Kabir Khan',
    age: 15,
    ageGroup: 'U-16',
    batch: 'Batch A1',
    joinDate: '24 Dec 2025',
    status: 'Active',
    attendancePercent: 88,
    attendedSessions: 22,
    totalSessions: 25,
    performanceRating: 8.9,
    parentName: 'Faizan Khan',
    phone: '+91 98765 33333',
    skills: [
      CoachStudentSkill(label: 'Power Hitting', rating: 5),
      CoachStudentSkill(label: 'Fielding', rating: 4),
      CoachStudentSkill(label: 'Fitness', rating: 4),
      CoachStudentSkill(label: 'Tactical Awareness', rating: 4),
    ],
    performanceNotes: [
      CoachStudentNote(
        date: '21 Apr 2026',
        note: 'Excellent finishing power. Work on recovery runs.',
        rating: 9,
      ),
    ],
    healthNotes: [
      CoachHealthNote(
        date: '10 Apr 2026',
        description: 'Hamstring tightness after conditioning.',
        severity: 'Moderate',
        status: 'Ongoing',
        followUpRequired: true,
      ),
    ],
    attendanceHistory: [
      CoachAttendanceEntry(date: '20 Apr', batch: 'Batch A1', status: 'Late'),
      CoachAttendanceEntry(
          date: '18 Apr', batch: 'Batch A1', status: 'Present'),
      CoachAttendanceEntry(
          date: '16 Apr', batch: 'Batch A1', status: 'Present'),
    ],
  ),
  CoachStudent(
    id: 'stu-4',
    name: 'Anaya Patel',
    age: 10,
    ageGroup: 'U-10',
    batch: 'Batch B2',
    joinDate: '15 Mar 2026',
    status: 'Active',
    attendancePercent: 93,
    attendedSessions: 14,
    totalSessions: 15,
    performanceRating: 7.8,
    parentName: 'Nilesh Patel',
    phone: '+91 98765 44444',
    skills: [
      CoachStudentSkill(label: 'Balance', rating: 4),
      CoachStudentSkill(label: 'Basics', rating: 3),
      CoachStudentSkill(label: 'Energy', rating: 5),
      CoachStudentSkill(label: 'Listening', rating: 4),
    ],
    performanceNotes: [],
    healthNotes: [],
    attendanceHistory: [
      CoachAttendanceEntry(
          date: '19 Apr', batch: 'Batch B2', status: 'Present'),
      CoachAttendanceEntry(
          date: '17 Apr', batch: 'Batch B2', status: 'Present'),
      CoachAttendanceEntry(
          date: '15 Apr', batch: 'Batch B2', status: 'Present'),
    ],
  ),
];

const coachTrainingPlans = [
  CoachTrainingPlan(
    id: 'plan-1',
    name: 'Cricket Foundation Build',
    sport: 'Cricket',
    targetBatches: ['Batch A1', 'Batch B2'],
    duration: '8 weeks',
    startDate: '01 Apr 2026',
    endDate: '27 May 2026',
    status: 'Active',
    objective: 'Improve movement, shot stability, and match awareness.',
    drillsUsed: [
      'Ball Control Drill',
      'Passing Accuracy Drill',
      'Field Positioning Drill',
    ],
    weeks: [
      CoachTrainingWeek(
        title: 'Week 1 - Foundation Building',
        sessions: [
          CoachTrainingSessionTemplate(
            name: 'Basic Footwork',
            durationMinutes: 45,
            drills: ['Ball Control Drill', 'Ladder Steps'],
            notes: 'Prioritize balance and forward transfer.',
          ),
          CoachTrainingSessionTemplate(
            name: 'Throwdown Accuracy',
            durationMinutes: 40,
            drills: ['Passing Accuracy Drill'],
            notes: 'Control alignment through contact.',
          ),
        ],
      ),
      CoachTrainingWeek(
        title: 'Week 2 - Skill Development',
        sessions: [
          CoachTrainingSessionTemplate(
            name: 'Field Position Awareness',
            durationMinutes: 35,
            drills: ['Field Positioning Drill'],
            notes: 'Build anticipation in ring positions.',
          ),
        ],
      ),
    ],
  ),
  CoachTrainingPlan(
    id: 'plan-2',
    name: 'Fielding Sharpness Cycle',
    sport: 'Cricket',
    targetBatches: ['Fielding Pro'],
    duration: '4 weeks',
    startDate: '15 Apr 2026',
    endDate: '13 May 2026',
    status: 'Draft',
    objective: 'Raise catch completion and relay speed under pressure.',
    drillsUsed: ['Reaction Catch Drill', 'Relay Throw Circuit'],
    weeks: [
      CoachTrainingWeek(
        title: 'Week 1 - Reaction Work',
        sessions: [
          CoachTrainingSessionTemplate(
            name: 'Reaction Catching',
            durationMinutes: 30,
            drills: ['Reaction Catch Drill'],
            notes: 'Keep feet active before release.',
          ),
        ],
      ),
    ],
  ),
];

const coachEarningHistory = [
  CoachEarningsHistory(month: 'Apr 2026', amount: 25000, status: 'Pending'),
  CoachEarningsHistory(month: 'Mar 2026', amount: 24200, status: 'Paid'),
  CoachEarningsHistory(month: 'Feb 2026', amount: 23800, status: 'Paid'),
  CoachEarningsHistory(month: 'Jan 2026', amount: 22900, status: 'Paid'),
];

const coachQuickModules = [
  CoachQuickModule(
    label: 'Profile',
    icon: Icons.person_rounded,
    route: '/coach-home/profile',
  ),
  CoachQuickModule(
    label: "Today's Sessions",
    icon: Icons.event_available_rounded,
    route: '/coach-home/sessions',
  ),
  CoachQuickModule(
    label: 'My Students',
    icon: Icons.groups_rounded,
    route: '/coach-home/students',
  ),
  CoachQuickModule(
    label: 'Attendance',
    icon: Icons.fact_check_rounded,
    route: '/coach-home/attendance',
  ),
  CoachQuickModule(
    label: 'Training Plans',
    icon: Icons.fitness_center_rounded,
    route: '/coach-home/training',
  ),
  CoachQuickModule(
    label: 'Earnings',
    icon: Icons.payments_rounded,
    route: '/coach-home/earnings',
  ),
  CoachQuickModule(
    label: 'Settings',
    icon: Icons.settings_rounded,
    route: '/coach-home/settings',
  ),
];

String coachMoney(int amount) => 'Rs ${amount.toString()}';

String coachSessionStateLabel(CoachSessionState state) {
  return switch (state) {
    CoachSessionState.upcoming => 'Upcoming',
    CoachSessionState.live => 'Now',
    CoachSessionState.completed => 'Completed',
  };
}

Color coachSessionStateColor(CoachSessionState state) {
  return switch (state) {
    CoachSessionState.upcoming => const Color(0xFF757575),
    CoachSessionState.live => const Color(0xFF1DB954),
    CoachSessionState.completed => const Color(0xFF3B82F6),
  };
}
