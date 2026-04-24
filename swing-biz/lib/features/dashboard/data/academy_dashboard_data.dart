import 'package:flutter/material.dart';

enum FeeStatus { paid, partial, pending, overdue, prepaid, trial }

enum EntityStatus { active, inactive, leftAcademy, completed, archived }

class AcademyStudent {
  const AcademyStudent({
    required this.id,
    required this.name,
    required this.age,
    required this.photoTag,
    required this.phone,
    required this.email,
    required this.gender,
    required this.bloodType,
    required this.batch,
    required this.coachName,
    required this.joinDate,
    required this.guardianName,
    required this.guardianPhone,
    required this.guardianEmail,
    required this.guardianRelation,
    required this.fee,
    required this.totalPaid,
    required this.balance,
    required this.status,
    required this.skillLevel,
    required this.attendancePercent,
    required this.performanceNotes,
    required this.documents,
    required this.feeHistory,
  });

  final String id;
  final String name;
  final int age;
  final String photoTag;
  final String phone;
  final String email;
  final String gender;
  final String bloodType;
  final String batch;
  final String coachName;
  final String joinDate;
  final String guardianName;
  final String guardianPhone;
  final String guardianEmail;
  final String guardianRelation;
  final int fee;
  final int totalPaid;
  final int balance;
  final FeeStatus status;
  final String skillLevel;
  final int attendancePercent;
  final String performanceNotes;
  final List<String> documents;
  final List<FeeHistoryEntry> feeHistory;
}

class FeeHistoryEntry {
  const FeeHistoryEntry({
    required this.date,
    required this.batch,
    required this.amount,
    required this.status,
  });

  final String date;
  final String batch;
  final int amount;
  final FeeStatus status;
}

class AcademyBatch {
  const AcademyBatch({
    required this.id,
    required this.name,
    required this.sport,
    required this.level,
    required this.time,
    required this.schedule,
    required this.coachName,
    required this.status,
    required this.studentIds,
    required this.fee,
    required this.capacity,
    required this.createdDate,
  });

  final String id;
  final String name;
  final String sport;
  final String level;
  final String time;
  final String schedule;
  final String coachName;
  final EntityStatus status;
  final List<String> studentIds;
  final int fee;
  final int capacity;
  final String createdDate;
}

class AcademyCoach {
  const AcademyCoach({
    required this.id,
    required this.name,
    required this.photoTag,
    required this.role,
    required this.specializations,
    required this.salary,
    required this.status,
    required this.salaryHistory,
    required this.assignedBatches,
    required this.rating,
    required this.experienceYears,
    required this.bankInfo,
    required this.documents,
  });

  final String id;
  final String name;
  final String photoTag;
  final String role;
  final List<String> specializations;
  final int salary;
  final EntityStatus status;
  final List<String> salaryHistory;
  final List<String> assignedBatches;
  final double rating;
  final int experienceYears;
  final String bankInfo;
  final List<String> documents;
}

class DashboardMetric {
  const DashboardMetric({
    required this.label,
    required this.amount,
    required this.icon,
  });

  final String label;
  final String amount;
  final IconData icon;
}

class QuickAction {
  const QuickAction({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

class ActivityItem {
  const ActivityItem(this.text, this.time);

  final String text;
  final String time;
}

class FeePlan {
  const FeePlan({
    required this.name,
    required this.sport,
    required this.duration,
    required this.amount,
    required this.discountPercent,
    required this.taxPercent,
    required this.studentsCount,
  });

  final String name;
  final String sport;
  final String duration;
  final int amount;
  final int discountPercent;
  final int taxPercent;
  final int studentsCount;
}

class InventoryItem {
  const InventoryItem({
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.value,
    required this.status,
  });

  final String name;
  final String category;
  final int quantity;
  final String unit;
  final int value;
  final String status;
}

class ReportTypeItem {
  const ReportTypeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
}

const academyStudents = [
  AcademyStudent(
    id: 'st-1',
    name: 'Arjun Patel',
    age: 13,
    photoTag: 'AP',
    phone: '+91 98765 43210',
    email: 'arjun@example.com',
    gender: 'Male',
    bloodType: 'B+',
    batch: 'Cricket Beginner A1',
    coachName: 'Rohan Mehta',
    joinDate: '12 Jan 2026',
    guardianName: 'Nilesh Patel',
    guardianPhone: '+91 99887 77665',
    guardianEmail: 'nilesh@example.com',
    guardianRelation: 'Father',
    fee: 5000,
    totalPaid: 10000,
    balance: 0,
    status: FeeStatus.paid,
    skillLevel: '7/10',
    attendancePercent: 75,
    performanceNotes: 'Needs better footwork. Excellent progress last month.',
    documents: ['ID Proof', 'Admission Form', 'Medical Certificate'],
    feeHistory: [
      FeeHistoryEntry(
        date: '01 Apr 2026',
        batch: 'A1',
        amount: 5000,
        status: FeeStatus.paid,
      ),
      FeeHistoryEntry(
        date: '01 Mar 2026',
        batch: 'A1',
        amount: 5000,
        status: FeeStatus.paid,
      ),
    ],
  ),
  AcademyStudent(
    id: 'st-2',
    name: 'Meera Iyer',
    age: 11,
    photoTag: 'MI',
    phone: '+91 90000 11223',
    email: 'meera@example.com',
    gender: 'Female',
    bloodType: 'O+',
    batch: 'Junior Skills B2',
    coachName: 'Priya Nair',
    joinDate: '22 Feb 2026',
    guardianName: 'Lakshmi Iyer',
    guardianPhone: '+91 90000 44556',
    guardianEmail: 'lakshmi@example.com',
    guardianRelation: 'Mother',
    fee: 4200,
    totalPaid: 2000,
    balance: 2200,
    status: FeeStatus.partial,
    skillLevel: '6/10',
    attendancePercent: 83,
    performanceNotes: 'Strong focus during drill work.',
    documents: ['ID Proof', 'Medical Certificate'],
    feeHistory: [
      FeeHistoryEntry(
        date: '01 Apr 2026',
        batch: 'B2',
        amount: 2000,
        status: FeeStatus.partial,
      ),
    ],
  ),
  AcademyStudent(
    id: 'st-3',
    name: 'Kabir Khan',
    age: 15,
    photoTag: 'KK',
    phone: '+91 91111 22233',
    email: 'kabir@example.com',
    gender: 'Male',
    bloodType: 'A+',
    batch: 'Evening Elite C1',
    coachName: 'Rohan Mehta',
    joinDate: '07 Mar 2026',
    guardianName: 'Farah Khan',
    guardianPhone: '+91 91111 44455',
    guardianEmail: 'farah@example.com',
    guardianRelation: 'Guardian',
    fee: 6500,
    totalPaid: 0,
    balance: 6500,
    status: FeeStatus.overdue,
    skillLevel: '8/10',
    attendancePercent: 68,
    performanceNotes: 'Explosive batting, needs consistency in fielding.',
    documents: ['Admission Form'],
    feeHistory: [
      FeeHistoryEntry(
        date: '01 Apr 2026',
        batch: 'C1',
        amount: 6500,
        status: FeeStatus.overdue,
      ),
    ],
  ),
];

const academyBatches = [
  AcademyBatch(
    id: 'bt-1',
    name: 'Cricket Beginner A1',
    sport: 'Cricket',
    level: 'Beginner',
    time: '6:00 PM - 7:30 PM',
    schedule: 'Mon, Wed, Fri',
    coachName: 'Rohan Mehta',
    status: EntityStatus.active,
    studentIds: ['st-1'],
    fee: 5000,
    capacity: 15,
    createdDate: '12 Jan 2026',
  ),
  AcademyBatch(
    id: 'bt-2',
    name: 'Junior Skills B2',
    sport: 'Cricket',
    level: 'Intermediate',
    time: '5:00 PM - 6:00 PM',
    schedule: 'Tue, Thu, Sat',
    coachName: 'Priya Nair',
    status: EntityStatus.active,
    studentIds: ['st-2'],
    fee: 4200,
    capacity: 15,
    createdDate: '22 Feb 2026',
  ),
  AcademyBatch(
    id: 'bt-3',
    name: 'Evening Elite C1',
    sport: 'Cricket',
    level: 'Advanced',
    time: '7:30 PM - 9:00 PM',
    schedule: 'Mon, Tue, Thu',
    coachName: 'Rohan Mehta',
    status: EntityStatus.active,
    studentIds: ['st-3'],
    fee: 6500,
    capacity: 15,
    createdDate: '07 Mar 2026',
  ),
];

const academyCoaches = [
  AcademyCoach(
    id: 'co-1',
    name: 'Rohan Mehta',
    photoTag: 'RM',
    role: 'Head Coach',
    specializations: ['Cricket'],
    salary: 24000,
    status: EntityStatus.active,
    salaryHistory: ['Mar 2026 - Paid', 'Feb 2026 - Paid', 'Jan 2026 - Paid'],
    assignedBatches: ['Cricket Beginner A1', 'Evening Elite C1'],
    rating: 4.5,
    experienceYears: 8,
    bankInfo: 'HDFC •••• 4567',
    documents: ['NIS Certificate', 'Level 2 Coaching Cert'],
  ),
  AcademyCoach(
    id: 'co-2',
    name: 'Priya Nair',
    photoTag: 'PN',
    role: 'Assistant Coach',
    specializations: ['Cricket', 'Fitness'],
    salary: 20000,
    status: EntityStatus.active,
    salaryHistory: ['Mar 2026 - Pending', 'Feb 2026 - Paid'],
    assignedBatches: ['Junior Skills B2'],
    rating: 4.2,
    experienceYears: 5,
    bankInfo: 'ICICI •••• 9988',
    documents: ['Strength & Conditioning Cert'],
  ),
];

const academyActivities = [
  ActivityItem("Player 'Arjun' added to Batch A1", '10m ago'),
  ActivityItem('Fee reminder sent to 5 students', '1h ago'),
  ActivityItem('Salary payment of Rs 25K marked as paid', '3h ago'),
];

const academyFeePlans = [
  FeePlan(
    name: 'Cricket Monthly',
    sport: 'Cricket',
    duration: '1 month',
    amount: 5000,
    discountPercent: 5,
    taxPercent: 0,
    studentsCount: 18,
  ),
  FeePlan(
    name: 'Cricket Quarterly',
    sport: 'Cricket',
    duration: '3 months',
    amount: 13500,
    discountPercent: 10,
    taxPercent: 0,
    studentsCount: 8,
  ),
];

const inventoryItems = [
  InventoryItem(
    name: 'Cricket Balls',
    category: 'Sports Equipment',
    quantity: 64,
    unit: 'each',
    value: 12800,
    status: 'In Stock',
  ),
  InventoryItem(
    name: 'Batting Gloves',
    category: 'Safety Gear',
    quantity: 18,
    unit: 'pair',
    value: 14400,
    status: 'Low Stock',
  ),
];

const reportTypes = [
  ReportTypeItem(
    id: 'revenue',
    title: 'Revenue Report',
    description: 'Income from fees and payments',
    icon: Icons.currency_rupee_rounded,
  ),
  ReportTypeItem(
    id: 'attendance',
    title: 'Attendance Report',
    description: 'Student and coach attendance',
    icon: Icons.fact_check_rounded,
  ),
  ReportTypeItem(
    id: 'payroll',
    title: 'Payroll Report',
    description: 'Salary and compensation summary',
    icon: Icons.payments_rounded,
  ),
  ReportTypeItem(
    id: 'players',
    title: 'Player Growth Report',
    description: 'New enrollments and churn',
    icon: Icons.trending_up_rounded,
  ),
  ReportTypeItem(
    id: 'batches',
    title: 'Batch Performance Report',
    description: 'Batch-wise metrics',
    icon: Icons.bar_chart_rounded,
  ),
  ReportTypeItem(
    id: 'inventory',
    title: 'Inventory Report',
    description: 'Stock levels and usage',
    icon: Icons.inventory_2_rounded,
  ),
];

String feeStatusLabel(FeeStatus status) {
  return switch (status) {
    FeeStatus.paid => 'Paid',
    FeeStatus.partial => 'Partial',
    FeeStatus.pending => 'Pending',
    FeeStatus.overdue => 'Overdue',
    FeeStatus.prepaid => 'Prepaid',
    FeeStatus.trial => 'Trial',
  };
}

String statusLabel(EntityStatus status) {
  return switch (status) {
    EntityStatus.active => 'Active',
    EntityStatus.inactive => 'Inactive',
    EntityStatus.leftAcademy => 'Left Academy',
    EntityStatus.completed => 'Completed',
    EntityStatus.archived => 'Archived',
  };
}

Color feeStatusColor(FeeStatus status) {
  return switch (status) {
    FeeStatus.paid => const Color(0xFF16A34A),
    FeeStatus.partial => const Color(0xFFF59E0B),
    FeeStatus.pending => const Color(0xFFF97316),
    FeeStatus.overdue => const Color(0xFFDC2626),
    FeeStatus.prepaid => const Color(0xFF0EA5E9),
    FeeStatus.trial => const Color(0xFF7C3AED),
  };
}

IconData feeStatusIcon(FeeStatus status) {
  return switch (status) {
    FeeStatus.paid => Icons.check_circle_outline,
    FeeStatus.partial => Icons.timelapse_rounded,
    FeeStatus.pending => Icons.pending_actions_rounded,
    FeeStatus.overdue => Icons.warning_amber_rounded,
    FeeStatus.prepaid => Icons.verified_rounded,
    FeeStatus.trial => Icons.hourglass_empty_outlined,
  };
}

String money(int amount) {
  if (amount >= 100000) return 'Rs ${(amount / 100000).toStringAsFixed(2)}L';
  if (amount >= 1000) return 'Rs ${(amount / 1000).toStringAsFixed(1)}k';
  return 'Rs $amount';
}
