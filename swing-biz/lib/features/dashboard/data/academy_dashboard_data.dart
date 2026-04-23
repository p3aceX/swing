import 'package:flutter/material.dart';

enum FeeStatus { paid, unpaid, due, trial }

enum EntityStatus { active, inactive }

class AcademyStudent {
  const AcademyStudent({
    required this.id,
    required this.name,
    required this.age,
    required this.phone,
    required this.batch,
    required this.fee,
    required this.status,
    required this.dueHistory,
    required this.discount,
  });

  final String id;
  final String name;
  final int age;
  final String phone;
  final String batch;
  final int fee;
  final FeeStatus status;
  final List<String> dueHistory;
  final int discount;
}

class AcademyBatch {
  const AcademyBatch({
    required this.id,
    required this.name,
    required this.time,
    required this.coachName,
    required this.status,
    required this.studentIds,
    required this.fee,
    required this.capacity,
  });

  final String id;
  final String name;
  final String time;
  final String coachName;
  final EntityStatus status;
  final List<String> studentIds;
  final int fee;
  final int capacity;
}

class AcademyCoach {
  const AcademyCoach({
    required this.id,
    required this.name,
    required this.role,
    required this.salary,
    required this.status,
    required this.salaryHistory,
    required this.assignedBatches,
  });

  final String id;
  final String name;
  final String role;
  final int salary;
  final EntityStatus status;
  final List<String> salaryHistory;
  final List<String> assignedBatches;
}

class DashboardMetric {
  const DashboardMetric({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String label;
  final String amount;
  final IconData icon;
  final Color color;
}

class QuickAction {
  const QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String route;
}

const academyStudents = [
  AcademyStudent(
    id: 'st-1',
    name: 'Aarav Sharma',
    age: 13,
    phone: '+91 98765 43210',
    batch: 'Morning Elite',
    fee: 4500,
    status: FeeStatus.paid,
    discount: 0,
    dueHistory: ['Mar 2026 paid on time', 'Apr 2026 paid on time'],
  ),
  AcademyStudent(
    id: 'st-2',
    name: 'Meera Iyer',
    age: 11,
    phone: '+91 99887 77665',
    batch: 'Junior Basics',
    fee: 3200,
    status: FeeStatus.due,
    discount: 300,
    dueHistory: ['Apr 2026 due in 4 days'],
  ),
  AcademyStudent(
    id: 'st-3',
    name: 'Kabir Khan',
    age: 15,
    phone: '+91 90909 12345',
    batch: 'Evening Pro',
    fee: 5200,
    status: FeeStatus.unpaid,
    discount: 0,
    dueHistory: ['Mar 2026 pending', 'Apr 2026 pending'],
  ),
  AcademyStudent(
    id: 'st-4',
    name: 'Anaya Patel',
    age: 10,
    phone: '+91 91234 56780',
    batch: 'Trial Group',
    fee: 0,
    status: FeeStatus.trial,
    discount: 0,
    dueHistory: ['Trial ends 30 Apr 2026'],
  ),
];

const academyBatches = [
  AcademyBatch(
    id: 'bt-1',
    name: 'Morning Elite',
    time: '6:00 AM - 7:30 AM',
    coachName: 'Rohan Mehta',
    status: EntityStatus.active,
    studentIds: ['st-1'],
    fee: 4500,
    capacity: 18,
  ),
  AcademyBatch(
    id: 'bt-2',
    name: 'Junior Basics',
    time: '4:30 PM - 5:30 PM',
    coachName: 'Priya Nair',
    status: EntityStatus.active,
    studentIds: ['st-2'],
    fee: 3200,
    capacity: 24,
  ),
  AcademyBatch(
    id: 'bt-3',
    name: 'Evening Pro',
    time: '6:00 PM - 8:00 PM',
    coachName: 'Rohan Mehta',
    status: EntityStatus.active,
    studentIds: ['st-3'],
    fee: 5200,
    capacity: 16,
  ),
  AcademyBatch(
    id: 'bt-4',
    name: 'Trial Group',
    time: 'Sunday 9:00 AM',
    coachName: 'Nisha Rao',
    status: EntityStatus.inactive,
    studentIds: ['st-4'],
    fee: 0,
    capacity: 12,
  ),
];

const academyCoaches = [
  AcademyCoach(
    id: 'co-1',
    name: 'Rohan Mehta',
    role: 'Head Coach',
    salary: 48000,
    status: EntityStatus.active,
    salaryHistory: ['Feb 2026: Rs 48,000', 'Mar 2026: Rs 48,000'],
    assignedBatches: ['Morning Elite', 'Evening Pro'],
  ),
  AcademyCoach(
    id: 'co-2',
    name: 'Priya Nair',
    role: 'Junior Coach',
    salary: 32000,
    status: EntityStatus.active,
    salaryHistory: ['Feb 2026: Rs 32,000', 'Mar 2026: Rs 32,000'],
    assignedBatches: ['Junior Basics'],
  ),
  AcademyCoach(
    id: 'co-3',
    name: 'Nisha Rao',
    role: 'Trial Coach',
    salary: 18000,
    status: EntityStatus.inactive,
    salaryHistory: ['Jan 2026: Rs 18,000'],
    assignedBatches: ['Trial Group'],
  ),
];

String feeStatusLabel(FeeStatus status) {
  return switch (status) {
    FeeStatus.paid => 'Paid',
    FeeStatus.unpaid => 'Unpaid',
    FeeStatus.due => 'Due',
    FeeStatus.trial => 'Trial',
  };
}

String statusLabel(EntityStatus status) {
  return switch (status) {
    EntityStatus.active => 'Active',
    EntityStatus.inactive => 'Inactive',
  };
}

Color feeStatusColor(FeeStatus status) {
  return switch (status) {
    FeeStatus.paid => const Color(0xFF16A34A),
    FeeStatus.unpaid => const Color(0xFFDC2626),
    FeeStatus.due => const Color(0xFFD97706),
    FeeStatus.trial => const Color(0xFF7C3AED),
  };
}

IconData feeStatusIcon(FeeStatus status) {
  return switch (status) {
    FeeStatus.paid => Icons.check_circle_outline,
    FeeStatus.unpaid => Icons.cancel_outlined,
    FeeStatus.due => Icons.schedule_outlined,
    FeeStatus.trial => Icons.hourglass_empty_outlined,
  };
}

String money(int amount) {
  if (amount >= 100000) return 'Rs ${(amount / 100000).toStringAsFixed(1)}L';
  if (amount >= 1000) return 'Rs ${(amount / 1000).toStringAsFixed(1)}k';
  return 'Rs $amount';
}
