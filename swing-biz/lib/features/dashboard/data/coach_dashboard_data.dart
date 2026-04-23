import 'package:flutter/material.dart';

class CoachSession {
  const CoachSession({
    required this.id,
    required this.name,
    required this.type,
    required this.time,
    required this.dateTime,
    required this.location,
    required this.format,
    required this.students,
    required this.notes,
    required this.icon,
  });

  final String id;
  final String name;
  final String type;
  final String time;
  final String dateTime;
  final String location;
  final String format;
  final List<String> students;
  final String notes;
  final IconData icon;
}

class CoachStudent {
  const CoachStudent({
    required this.name,
    required this.ageGroup,
    required this.skillLevel,
    required this.assignedSession,
  });

  final String name;
  final String ageGroup;
  final String skillLevel;
  final String assignedSession;
}

class CoachEarnings {
  const CoachEarnings({
    required this.salary,
    required this.gigs,
    required this.oneOnOne,
    required this.bonus,
    required this.payoutStatus,
  });

  final int salary;
  final int gigs;
  final int oneOnOne;
  final int bonus;
  final String payoutStatus;

  int get total => salary + gigs + oneOnOne + bonus;
}

const coachName = 'Rohan Mehta';
const coachAcademy = 'Swing Academy';
const coachPlan = 'FREE';
const coachEarnings = CoachEarnings(
  salary: 48000,
  gigs: 8500,
  oneOnOne: 12000,
  bonus: 4000,
  payoutStatus: 'Processing for Apr 2026',
);

const coachStudents = [
  CoachStudent(
    name: 'Aarav Sharma',
    ageGroup: 'U-14',
    skillLevel: 'Intermediate',
    assignedSession: 'Morning Nets',
  ),
  CoachStudent(
    name: 'Meera Iyer',
    ageGroup: 'U-12',
    skillLevel: 'Beginner',
    assignedSession: 'Junior Drill',
  ),
  CoachStudent(
    name: 'Kabir Khan',
    ageGroup: 'U-16',
    skillLevel: 'Advanced',
    assignedSession: 'Fielding Pro',
  ),
  CoachStudent(
    name: 'Anaya Patel',
    ageGroup: 'U-10',
    skillLevel: 'Beginner',
    assignedSession: 'Fitness Basics',
  ),
];

const coachSessions = [
  CoachSession(
    id: 'cs-1',
    name: 'Morning Nets',
    type: 'Nets',
    time: '6:00 AM',
    dateTime: 'Today, 6:00 AM',
    location: 'Swing Academy Turf 1',
    format: 'Group',
    students: ['Aarav Sharma', 'Kabir Khan'],
    notes: 'Powerplay batting, straight drive control, 12-ball rotations.',
    icon: Icons.sports_cricket_rounded,
  ),
  CoachSession(
    id: 'cs-2',
    name: 'Junior Drill',
    type: 'Drill',
    time: '4:30 PM',
    dateTime: 'Today, 4:30 PM',
    location: 'Swing Academy Nets',
    format: 'Group',
    students: ['Meera Iyer', 'Anaya Patel'],
    notes: 'Footwork ladder, stance correction, underarm throwdowns.',
    icon: Icons.track_changes_rounded,
  ),
  CoachSession(
    id: 'cs-3',
    name: 'Fitness Basics',
    type: 'Fitness',
    time: '7:00 AM',
    dateTime: 'Tomorrow, 7:00 AM',
    location: 'City Sports Ground',
    format: '1-on-1',
    students: ['Anaya Patel'],
    notes: 'Mobility, sprint starts, core stability.',
    icon: Icons.fitness_center_rounded,
  ),
  CoachSession(
    id: 'cs-4',
    name: 'Fielding Pro',
    type: 'Fielding',
    time: '6:30 PM',
    dateTime: 'Fri, 6:30 PM',
    location: 'Swing Academy Turf 2',
    format: 'Group',
    students: ['Kabir Khan', 'Aarav Sharma'],
    notes: 'High catches, relay throws, ring field reactions.',
    icon: Icons.sports_baseball_rounded,
  ),
];

String coachMoney(int amount) {
  if (amount >= 1000) return 'Rs ${(amount / 1000).toStringAsFixed(1)}k';
  return 'Rs $amount';
}
