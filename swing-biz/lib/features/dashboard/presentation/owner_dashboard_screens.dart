import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../data/academy_dashboard_data.dart';
import '../widgets/dashboard_widgets.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: academyStudents.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final student = academyStudents[index];
          final color = feeStatusColor(student.status);
          return RoundedPanel(
            onTap: () => context.push('${AppRoutes.students}/${student.id}'),
            child: Row(
              children: [
                StatusBadge(
                  label: feeStatusLabel(student.status),
                  color: color,
                  icon: feeStatusIcon(student.status),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${student.batch}  |  ${money(student.fee)}',
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    final student = academyStudents.firstWhere(
      (item) => item.id == studentId,
      orElse: () => academyStudents.first,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Student Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Row(
              children: [
                SoftIcon(
                  icon: Icons.person_rounded,
                  color: feeStatusColor(student.status),
                  size: 52,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text('${student.age} years  |  ${student.phone}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SectionTitle(title: 'Fee'),
          RoundedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _KeyValueRow('Batch', student.batch),
                _KeyValueRow('Monthly fee', money(student.fee)),
                _KeyValueRow('Discount', money(student.discount)),
                const SizedBox(height: 8),
                StatusBadge(
                  label: feeStatusLabel(student.status),
                  color: feeStatusColor(student.status),
                  icon: feeStatusIcon(student.status),
                ),
              ],
            ),
          ),
          const SectionTitle(title: 'Due History'),
          ...student.dueHistory.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RoundedPanel(
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded, color: Color(0xFF64748B)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BatchesScreen extends StatelessWidget {
  const BatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final active = academyBatches
        .where((batch) => batch.status == EntityStatus.active)
        .length;
    return Scaffold(
      appBar: AppBar(title: const Text('Batches')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Row(
              children: [
                const SoftIcon(
                    icon: Icons.calendar_month_rounded,
                    color: Color(0xFF34D399)),
                const SizedBox(width: 12),
                Text(
                  '$active running batches',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          ),
          const SectionTitle(title: 'All Batches'),
          ...academyBatches.map(
            (batch) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RoundedPanel(
                onTap: () => context.push('${AppRoutes.batches}/${batch.id}'),
                child: Row(
                  children: [
                    SoftIcon(
                      icon: Icons.groups_2_rounded,
                      color: batch.status == EntityStatus.active
                          ? const Color(0xFF34D399)
                          : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(batch.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 3),
                          Text('${batch.time}  |  ${batch.coachName}'),
                        ],
                      ),
                    ),
                    StatusBadge(
                      label: statusLabel(batch.status),
                      color: batch.status == EntityStatus.active
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BatchDetailsScreen extends StatelessWidget {
  const BatchDetailsScreen({super.key, required this.batchId});

  final String batchId;

  @override
  Widget build(BuildContext context) {
    final batch = academyBatches.firstWhere(
      (item) => item.id == batchId,
      orElse: () => academyBatches.first,
    );
    final students = academyStudents
        .where((student) => batch.studentIds.contains(student.id))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Batch Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batch.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 14),
                _KeyValueRow('Time', batch.time),
                _KeyValueRow('Coach', batch.coachName),
                _KeyValueRow('Fee', money(batch.fee)),
                _KeyValueRow(
                    'Capacity', '${students.length}/${batch.capacity}'),
              ],
            ),
          ),
          const SectionTitle(title: 'Students'),
          ...students.map(
            (student) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RoundedPanel(
                onTap: () =>
                    context.push('${AppRoutes.students}/${student.id}'),
                child: Row(
                  children: [
                    Expanded(child: Text(student.name)),
                    StatusBadge(
                      label: feeStatusLabel(student.status),
                      color: feeStatusColor(student.status),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CoachesScreen extends StatelessWidget {
  const CoachesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coaches')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: academyCoaches.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final coach = academyCoaches[index];
          return RoundedPanel(
            onTap: () => context.push('${AppRoutes.coaches}/${coach.id}'),
            child: Row(
              children: [
                const SoftIcon(
                    icon: Icons.sports_rounded, color: Color(0xFFF59E0B)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(coach.name,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text('${coach.role}  |  ${money(coach.salary)}'),
                    ],
                  ),
                ),
                StatusBadge(
                  label: statusLabel(coach.status),
                  color: coach.status == EntityStatus.active
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF64748B),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CoachProfileScreen extends StatelessWidget {
  const CoachProfileScreen({super.key, required this.coachId});

  final String coachId;

  @override
  Widget build(BuildContext context) {
    final coach = academyCoaches.firstWhere(
      (item) => item.id == coachId,
      orElse: () => academyCoaches.first,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Coach Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coach.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 12),
                _KeyValueRow('Role', coach.role),
                _KeyValueRow('Salary', money(coach.salary)),
                StatusBadge(
                  label: statusLabel(coach.status),
                  color: coach.status == EntityStatus.active
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF64748B),
                ),
              ],
            ),
          ),
          const SectionTitle(title: 'Assigned Batches'),
          ...coach.assignedBatches
              .map((batch) => _SimpleTile(Icons.groups_rounded, batch)),
          const SectionTitle(title: 'Salary History'),
          ...coach.salaryHistory
              .map((entry) => _SimpleTile(Icons.payments_rounded, entry)),
        ],
      ),
    );
  }
}

class FeeManagementScreen extends StatelessWidget {
  const FeeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fees')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle(title: 'Student Fees'),
          ...academyStudents.map(
            (student) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RoundedPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            student.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        StatusBadge(
                          label: feeStatusLabel(student.status),
                          color: feeStatusColor(student.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _KeyValueRow('Current fee', money(student.fee)),
                    _KeyValueRow('Discount', money(student.discount)),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.remove_rounded),
                            label: const Text('Decrease'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Increase'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: () {},
                            child: const Text('Mark Paid'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: () {},
                            child: const Text('Unpaid'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreateStudentScreen extends StatelessWidget {
  const CreateStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FormScaffold(
      title: 'Add Student',
      submitLabel: 'Create Profile',
      children: [
        SimpleFormField(label: 'Name'),
        SimpleFormField(label: 'Age', keyboardType: TextInputType.number),
        SimpleFormField(label: 'Phone', keyboardType: TextInputType.phone),
        SimpleFormField(label: 'Batch'),
        SimpleFormField(label: 'Fee', keyboardType: TextInputType.number),
        _ChoiceRow(title: 'Registration', options: ['Trial', 'Paid']),
      ],
    );
  }
}

class CreateBatchScreen extends StatelessWidget {
  const CreateBatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FormScaffold(
      title: 'New Batch',
      submitLabel: 'Create Batch',
      children: [
        SimpleFormField(label: 'Batch Name'),
        SimpleFormField(label: 'Timing'),
        SimpleFormField(label: 'Coach assignment'),
        SimpleFormField(label: 'Fee', keyboardType: TextInputType.number),
        SimpleFormField(label: 'Capacity', keyboardType: TextInputType.number),
      ],
    );
  }
}

class PlanUpgradeScreen extends StatelessWidget {
  const PlanUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade Plan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Free vs Pro',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 14),
          const _PlanCard(
            title: 'Free',
            price: 'Rs 0',
            color: Color(0xFF64748B),
            features: ['50 students', 'Basic batches', 'Manual fee tracking'],
          ),
          const SizedBox(height: 12),
          const _PlanCard(
            title: 'Pro',
            price: 'Rs 999/mo',
            color: Color(0xFFF59E0B),
            features: [
              'Unlimited students',
              'Payroll history',
              'Announcements',
              'Inventory tracking',
            ],
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.star_rounded),
            label: const Text('Upgrade to Pro'),
          ),
        ],
      ),
    );
  }
}

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FormScaffold(
      title: 'Announcements',
      submitLabel: 'Send Announcement',
      children: [
        _ChoiceRow(
            title: 'Send to', options: ['All students', 'Specific batch']),
        SimpleFormField(label: 'Batch'),
        SimpleFormField(label: 'Message'),
      ],
    );
  }
}

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _UtilityScreen(
      title: 'Inventory',
      icon: Icons.inventory_2_rounded,
      items: [
        'Cricket balls: 64 available',
        'Batting gloves: 18 available',
        'Cones: 40 available'
      ],
      action: 'Add Item',
    );
  }
}

class AcademyProfileScreen extends StatelessWidget {
  const AcademyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FormScaffold(
      title: 'Academy Profile',
      submitLabel: 'Save Details',
      children: [
        SimpleFormField(label: 'Academy name', initialValue: 'Swing Academy'),
        SimpleFormField(label: 'City', initialValue: 'Mumbai'),
        SimpleFormField(label: 'State', initialValue: 'Maharashtra'),
        SimpleFormField(
            label: 'Contact phone', keyboardType: TextInputType.phone),
      ],
    );
  }
}

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _UtilityScreen(
      title: 'Payroll',
      icon: Icons.account_balance_rounded,
      items: academyCoaches
          .map((coach) => '${coach.name}: ${money(coach.salary)}')
          .toList(),
      action: 'Pay Salary',
    );
  }
}

class DevelopmentSettingsScreen extends StatelessWidget {
  const DevelopmentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _UtilityScreen(
      title: 'Settings',
      icon: Icons.settings_rounded,
      items: ['Feature toggles', 'Support and help', 'Notification settings'],
      action: 'Open Support',
    );
  }
}

class _FormScaffold extends StatelessWidget {
  const _FormScaffold({
    required this.title,
    required this.submitLabel,
    required this.children,
  });

  final String title;
  final String submitLabel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              children: [
                ...children,
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () {},
                  child: Text(submitLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({required this.title, required this.options});

  final String title;
  final List<String> options;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: options
                .map(
                  (option) => ChoiceChip(
                    selected: option == options.first,
                    label: Text(option),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _UtilityScreen extends StatelessWidget {
  const _UtilityScreen({
    required this.title,
    required this.icon,
    required this.items,
    required this.action,
  });

  final String title;
  final IconData icon;
  final List<String> items;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Row(
              children: [
                SoftIcon(icon: icon, color: const Color(0xFF6366F1)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SectionTitle(title: 'Overview'),
          ...items.map((item) => _SimpleTile(icon, item)),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: () {}, child: Text(action)),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.features,
    required this.color,
  });

  final String title;
  final String price;
  final List<String> features;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RoundedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SoftIcon(icon: Icons.star_rounded, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              Text(price, style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 18, color: color),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleTile extends StatelessWidget {
  const _SimpleTile(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RoundedPanel(
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF64748B)),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
