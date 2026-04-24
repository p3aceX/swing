import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/router/app_router.dart';
import '../data/academy_dashboard_data.dart';
import '../widgets/dashboard_widgets.dart';

AppBar ownerAppBar(BuildContext context, String title) {
  return AppBar(
    leading: IconButton(
      onPressed: () {
        if (Navigator.of(context).canPop()) {
          context.pop();
          return;
        }
        debugPrint('Owner back fallback for $title');
        context.go(AppRoutes.dashboard);
      },
      icon: const Icon(Icons.arrow_back_rounded),
    ),
    title: Text(title),
  );
}

void ownerPush(BuildContext context, String route) {
  try {
    context.push(route);
  } catch (error, stackTrace) {
    debugPrint('Owner navigation failed for $route: $error');
    debugPrintStack(stackTrace: stackTrace);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open this screen right now')),
    );
  }
}

void ownerGo(BuildContext context, String route) {
  try {
    context.go(route);
  } catch (error, stackTrace) {
    debugPrint('Owner navigation failed for $route: $error');
    debugPrintStack(stackTrace: stackTrace);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open this screen right now')),
    );
  }
}

Future<File> _writeOwnerFile(
  String fileName,
  String content,
) async {
  final file = File('${Directory.systemTemp.path}\\$fileName');
  await file.writeAsString(content);
  return file;
}

Future<void> _showGeneratedFile(
  BuildContext context,
  String label,
  File file,
) async {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$label saved to ${file.path}')),
  );
}

Future<void> _generatePdfDocument(
  BuildContext context, {
  required String title,
  required List<String> lines,
  bool printAfterCreate = false,
}) async {
  final document = pw.Document();
  document.addPage(
    pw.Page(
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 20)),
          pw.SizedBox(height: 12),
          ...lines.map((line) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Text(line),
              )),
        ],
      ),
    ),
  );
  final bytes = await document.save();
  final file = await File(
    '${Directory.systemTemp.path}\\${title.toLowerCase().replaceAll(' ', '_')}.pdf',
  ).writeAsBytes(bytes, flush: true);
  if (printAfterCreate) {
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }
  if (!context.mounted) return;
  await _showGeneratedFile(context, '$title PDF', file);
}

Future<void> _generateCsvFile(
  BuildContext context, {
  required String fileName,
  required String content,
}) async {
  final file = await _writeOwnerFile(fileName, content);
  if (!context.mounted) return;
  await _showGeneratedFile(context, 'Excel-ready CSV', file);
}

Future<void> _openWhatsAppShare(
  BuildContext context, {
  required String message,
}) async {
  final uri = Uri.parse(
    'https://wa.me/?text=${Uri.encodeComponent(message)}',
  );
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open WhatsApp')),
    );
  }
}

class AcademyOverviewScreen extends StatelessWidget {
  const AcademyOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academy Overview')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _OverviewCard('Academy', 'Swing Academy, Mumbai'),
          _OverviewCard('Current Plan', 'Professional'),
          _OverviewCard('Players', '48 active players'),
          _OverviewCard('Coaches', '5 coaches'),
        ],
      ),
    );
  }
}

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  int _visibleCount = 2;

  @override
  Widget build(BuildContext context) {
    final visible = academyStudents.take(_visibleCount).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Players'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.createStudent),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Player'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: () => ownerPush(context, AppRoutes.students),
                child: const Text('View Students'),
              ),
              FilledButton.tonal(
                onPressed: () => ownerPush(context, AppRoutes.createStudent),
                child: const Text('Add Students'),
              ),
              FilledButton.tonal(
                onPressed: () => ownerPush(context, AppRoutes.studentSchedule),
                child: const Text('Edit Schedule'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('48 Players',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          RoundedPanel(
            child: Column(
              children: const [
                SimpleFormField(label: 'Search by name, mobile, ID'),
                _InlineDropdown(label: 'Batch', value: 'All Batches'),
                _InlineDropdown(label: 'Status', value: 'Active'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...visible.map(
            (student) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Dismissible(
                key: ValueKey(student.id),
                background: _swipeAction(
                  Colors.orange,
                  Alignment.centerLeft,
                  Icons.edit_rounded,
                  'Edit',
                ),
                secondaryBackground: _swipeAction(
                  Colors.red,
                  Alignment.centerRight,
                  Icons.delete_rounded,
                  'Delete',
                ),
                child: RoundedPanel(
                  onTap: () =>
                      context.push('${AppRoutes.students}/${student.id}'),
                  child: Row(
                    children: [
                      CircleAvatar(child: Text(student.photoTag)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                )),
                            const SizedBox(height: 4),
                            Text('${student.age} yrs • ${student.batch}'),
                            Text(
                              'Fees: ${feeStatusLabel(student.status)}',
                              style: TextStyle(
                                color: feeStatusColor(student.status),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(
                        label: student.balance <= 0 ? 'Active' : 'Active',
                        color: const Color(0xFF16A34A),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_visibleCount < academyStudents.length)
            OutlinedButton(
              onPressed: () => setState(() => _visibleCount += 10),
              child: const Text('Load More'),
            ),
        ],
      ),
    );
  }

  Widget _swipeAction(
    Color color,
    Alignment alignment,
    IconData icon,
    String label,
  ) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
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
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Player Profile'),
          actions: [
            IconButton(
              onPressed: () =>
                  context.push('${AppRoutes.editStudent}/$studentId'),
              icon: const Icon(Icons.edit_rounded),
            ),
            IconButton(
              onPressed: () =>
                  context.push('${AppRoutes.deleteStudent}/$studentId'),
              icon: const Icon(Icons.delete_rounded),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Attendance'),
              Tab(text: 'Fees'),
              Tab(text: 'Performance'),
              Tab(text: 'Documents'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: RoundedPanel(
                child: Row(
                  children: [
                    CircleAvatar(radius: 30, child: Text(student.photoTag)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900)),
                          Text('${student.age} • ${student.joinDate}'),
                        ],
                      ),
                    ),
                    StatusBadge(
                      label: 'Active',
                      color: const Color(0xFF16A34A),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _tabList([
                    _keyValueCard('Phone', student.phone),
                    _keyValueCard('Email', student.email),
                    _keyValueCard('Gender', student.gender),
                    _keyValueCard('Blood Type', student.bloodType),
                    _keyValueCard('Parent', student.guardianName),
                    _keyValueCard('Parent Phone', student.guardianPhone),
                    _keyValueCard('Batch', student.batch),
                    _keyValueCard('Coach', student.coachName),
                    _actionButtons([
                      _ActionConfig(
                        'Send Fee Reminder',
                        () => ownerPush(context, AppRoutes.feeReminderForm),
                      ),
                      _ActionConfig('Mark Attendance', () {}),
                      _ActionConfig(
                        'Add Document',
                        () => ownerPush(context, AppRoutes.documentAdd),
                      ),
                    ]),
                  ]),
                  _tabList([
                    _chartCard('Attendance Percentage',
                        '${student.attendancePercent}%'),
                    _chartCard('Batch A1', '15 / 20 sessions (75%)'),
                    _chartCard('Batch B2', '10 / 12 sessions (83%)'),
                    _downloadButton('Download Report'),
                  ]),
                  _tabList([
                    _keyValueCard('Monthly Fee', money(student.fee)),
                    _keyValueCard('Total Paid', money(student.totalPaid)),
                    _keyValueCard('Balance Due', money(student.balance)),
                    ...student.feeHistory.map(
                      (entry) => _historyTile(
                        '${entry.date} • ${entry.batch}',
                        '${money(entry.amount)} • ${feeStatusLabel(entry.status)}',
                      ),
                    ),
                    _actionButtons([
                      _ActionConfig(
                        'Send Invoice',
                        () =>
                            context.push('${AppRoutes.feeInvoice}/$studentId'),
                      ),
                      _ActionConfig(
                        'Record Payment',
                        () => context.push(
                          '${AppRoutes.feeRecordPayment}/$studentId',
                        ),
                      ),
                      _ActionConfig(
                        'Payment Status',
                        () => context.push(
                          '${AppRoutes.feePaymentStatus}/$studentId',
                        ),
                      ),
                      _ActionConfig(
                        'Payment History',
                        () => context.push(
                          '${AppRoutes.feePaymentHistory}/$studentId',
                        ),
                      ),
                    ]),
                  ]),
                  _tabList([
                    _keyValueCard('Skill Level', student.skillLevel),
                    _historyTile('Coach Comments', student.performanceNotes),
                    _historyTile('Improvement Areas', 'Needs better footwork'),
                  ]),
                  _tabList([
                    ...student.documents
                        .map((doc) => _historyTile(doc, 'Download • Delete')),
                    _downloadButton('Upload Document'),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabList(List<Widget> children) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: children
            .map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: child,
                ))
            .toList(),
      );

  Widget _keyValueCard(String label, String value) => RoundedPanel(
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      );

  Widget _chartCard(String title, String subtitle) => RoundedPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Container(height: 48, color: const Color(0xFFE2E8F0)),
            const SizedBox(height: 8),
            Text(subtitle),
          ],
        ),
      );

  Widget _historyTile(
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) =>
      RoundedPanel(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(subtitle),
          ],
        ),
      );

  Widget _actionButtons(List<_ActionConfig> actions) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: actions
            .map((action) => FilledButton.tonal(
                  onPressed: action.onPressed,
                  child: Text(action.label),
                ))
            .toList(),
      );

  Widget _downloadButton(
    String label, {
    VoidCallback? onPressed,
  }) =>
      ElevatedButton(onPressed: onPressed ?? () {}, child: Text(label));
}

class CreateStudentScreen extends StatelessWidget {
  const CreateStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Player')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              children: [
                const SectionTitle(title: 'Personal Information'),
                const SimpleFormField(label: 'Full name*'),
                const SimpleFormField(label: 'DOB*'),
                const SimpleFormField(
                    label: 'Phone number*', keyboardType: TextInputType.phone),
                const SimpleFormField(
                    label: 'Email', keyboardType: TextInputType.emailAddress),
                const _InlineDropdown(label: 'Gender*', value: 'Male'),
                const SimpleFormField(label: 'Blood type'),
                const SectionTitle(title: 'Parent / Guardian'),
                const SimpleFormField(label: 'Parent name*'),
                const _InlineDropdown(label: 'Relationship*', value: 'Father'),
                const SimpleFormField(
                    label: 'Parent phone*', keyboardType: TextInputType.phone),
                const SimpleFormField(
                    label: 'Parent email',
                    keyboardType: TextInputType.emailAddress),
                const SimpleFormField(label: 'Parent address'),
                const SectionTitle(title: 'Batch Assignment'),
                const _InlineDropdown(
                    label: 'Select batch*', value: 'Cricket Beginner A1'),
                const SimpleFormField(label: 'Join date*'),
                const Text(
                  'Select which batch this player will join',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                const SectionTitle(title: 'Emergency Contact'),
                const SimpleFormField(label: 'Contact name'),
                const SimpleFormField(label: 'Relationship'),
                const SimpleFormField(
                    label: 'Phone number', keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            context.push('${AppRoutes.students}/st-1'),
                        child: const Text('Save'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.go(AppRoutes.createStudent),
                        child: const Text('Save & Add Another'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
              ],
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
      appBar: AppBar(
        title: const Text('Coaches'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.createCoachProfile),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Coach'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('5 Coaches',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          const RoundedPanel(
            child: Column(
              children: [
                SimpleFormField(label: 'Search by name, specialization'),
                _InlineDropdown(label: 'Specialization', value: 'Cricket'),
                _InlineDropdown(label: 'Status', value: 'Active'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...academyCoaches.map(
            (coach) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RoundedPanel(
                onTap: () => context.push('${AppRoutes.coaches}/${coach.id}'),
                child: Row(
                  children: [
                    CircleAvatar(child: Text(coach.photoTag)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(coach.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(coach.specializations.join(', ')),
                          Text(
                            'Batches: ${coach.assignedBatches.length} • Salary ${money(coach.salary)}',
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text('⭐ ${coach.rating}'),
                        StatusBadge(
                          label: coach.salaryHistory.first.contains('Pending')
                              ? 'Pending'
                              : 'Paid',
                          color: coach.salaryHistory.first.contains('Pending')
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF16A34A),
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

class CoachProfileScreen extends StatelessWidget {
  const CoachProfileScreen({super.key, required this.coachId});

  final String coachId;

  @override
  Widget build(BuildContext context) {
    final coach = academyCoaches.firstWhere(
      (item) => item.id == coachId,
      orElse: () => academyCoaches.first,
    );
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Coach Profile'),
          actions: [
            IconButton(
              onPressed: () => context.push('${AppRoutes.editCoach}/$coachId'),
              icon: const Icon(Icons.edit_rounded),
            ),
            IconButton(
              onPressed: () =>
                  context.push('${AppRoutes.deleteCoach}/$coachId'),
              icon: const Icon(Icons.delete_rounded),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Batches'),
              Tab(text: 'Salary'),
              Tab(text: 'Attendance'),
              Tab(text: 'Performance'),
              Tab(text: 'Documents'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: RoundedPanel(
                child: Row(
                  children: [
                    CircleAvatar(radius: 30, child: Text(coach.photoTag)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(coach.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900)),
                          Text(coach.specializations.join(', ')),
                        ],
                      ),
                    ),
                    Text('⭐ ${coach.rating}'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _simpleList([
                    _kv('Experience', '${coach.experienceYears} years'),
                    _kv('Bank Info', coach.bankInfo),
                    _kv('Assignments', coach.assignedBatches.join(', ')),
                    _buttonWrap([
                      _ActionConfig(
                        'View Batches',
                        () =>
                            context.push('${AppRoutes.coachBatches}/$coachId'),
                      ),
                      _ActionConfig(
                        'View Salary',
                        () => context.push('${AppRoutes.payroll}/$coachId'),
                      ),
                      _ActionConfig(
                        'Send Message',
                        () =>
                            context.push('${AppRoutes.coachMessage}/$coachId'),
                      ),
                    ]),
                  ]),
                  _simpleList([
                    ...coach.assignedBatches.map(
                      (b) => _historyCard(b, '12 players • Active'),
                    ),
                    _kv('Total students', '28'),
                  ]),
                  _simpleList([
                    _kv('Base Salary', 'Rs 20,000'),
                    _kv('Incentives', 'Rs 5,000'),
                    _kv('Deductions', 'Rs 1,000'),
                    _kv('Net Salary', money(coach.salary)),
                    ...coach.salaryHistory.map(
                        (h) => _historyCard(h, 'View Slip • Record Payment')),
                    _buttonWrap([
                      _ActionConfig(
                        'Salary Details',
                        () => context.push('${AppRoutes.payroll}/$coachId'),
                      ),
                      _ActionConfig(
                        'Send Salary Slip',
                        () => context.push(
                          '${AppRoutes.payrollSendSlip}/$coachId',
                        ),
                      ),
                    ]),
                  ]),
                  _simpleList([
                    _historyCard('Sessions Conducted', '42 / 45 (93%)'),
                    _historyCard(
                        'Monthly Chart', 'Attendance trend placeholder'),
                  ]),
                  _simpleList([
                    _historyCard(
                        'Owner Notes', 'Strong discipline and planning'),
                    _historyCard('Student Feedback', 'Average rating 4.5 / 5'),
                  ]),
                  _simpleList(coach.documents
                      .map((doc) => _historyCard(doc, 'Download • Delete'))
                      .toList()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _simpleList(List<Widget> children) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: children
            .map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: child,
                ))
            .toList(),
      );

  Widget _kv(String label, String value) => RoundedPanel(
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      );

  Widget _historyCard(String title, String subtitle) => RoundedPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(subtitle),
          ],
        ),
      );

  Widget _buttonWrap(List<_ActionConfig> labels) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: labels
            .map((label) => FilledButton.tonal(
                  onPressed: label.onPressed,
                  child: Text(label.label),
                ))
            .toList(),
      );
}

class CreateCoachProfileScreen extends StatelessWidget {
  const CreateCoachProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Coach')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              children: [
                const SectionTitle(title: 'Personal Information'),
                const SimpleFormField(label: 'Full name*'),
                const SimpleFormField(label: 'DOB*'),
                const SimpleFormField(
                    label: 'Phone*', keyboardType: TextInputType.phone),
                const SimpleFormField(
                    label: 'Email', keyboardType: TextInputType.emailAddress),
                const SectionTitle(title: 'Professional Information'),
                const SimpleFormField(label: 'Sports specialization(s)*'),
                const SimpleFormField(
                    label: 'Years of experience*',
                    keyboardType: TextInputType.number),
                const SimpleFormField(label: 'Certifications'),
                const SimpleFormField(label: 'Bio'),
                const SectionTitle(title: 'Bank Information'),
                const SimpleFormField(label: 'Account holder name*'),
                const SimpleFormField(label: 'Bank name*'),
                const SimpleFormField(
                    label: 'Account number*',
                    keyboardType: TextInputType.number),
                const SimpleFormField(label: 'IFSC code*'),
                const SectionTitle(title: 'Salary Details'),
                const SimpleFormField(
                    label: 'Base monthly salary*',
                    keyboardType: TextInputType.number),
                const SimpleFormField(label: 'Incentive type'),
                const SimpleFormField(
                    label: 'Incentive amount',
                    keyboardType: TextInputType.number),
                const SimpleFormField(
                    label: 'Deductions', keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            context.push('${AppRoutes.coaches}/co-1'),
                        child: const Text('Save'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batches & Schedule'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.createBatch),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Create Batch'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('6 Batches',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          const RoundedPanel(
            child: Column(
              children: [
                _InlineDropdown(label: 'Sport', value: 'Cricket'),
                _InlineDropdown(label: 'Coach', value: 'Rohan Mehta'),
                _InlineDropdown(label: 'Status', value: 'Active'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...academyBatches.map(
            (batch) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RoundedPanel(
                onTap: () => context.push('${AppRoutes.batches}/${batch.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(batch.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800)),
                        ),
                        StatusBadge(
                          label: statusLabel(batch.status),
                          color: const Color(0xFF16A34A),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('${batch.sport} • ${batch.level}'),
                    Text(batch.coachName),
                    Text('${batch.schedule} • ${batch.time}'),
                    Text(
                        'Players count: ${batch.studentIds.length} / ${batch.capacity}'),
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
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Batch Details'),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.edit_rounded)),
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.archive_rounded)),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Students'),
              Tab(text: 'Schedule'),
              Tab(text: 'Attendance'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: RoundedPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(batch.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text('${batch.sport} • ${batch.coachName}'),
                    Text('${batch.schedule} • ${batch.time}'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _batchList([
                    _batchCard('Capacity',
                        '${batch.capacity} total, ${students.length} enrolled'),
                    _batchCard('Fee Structure', money(batch.fee)),
                    _batchCard('Created Date', batch.createdDate),
                    _buttonWrap(
                      context,
                      ['View Students', 'Add Student', 'Edit Schedule'],
                    ),
                  ]),
                  _batchList([
                    ...students.map(
                      (student) => _batchCard(
                        student.name,
                        '${student.joinDate} • View Profile • Remove from Batch',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => context.push(AppRoutes.createStudent),
                      child: const Text('Add Student'),
                    ),
                  ]),
                  _batchList([
                    _batchCard('Monday', batch.time),
                    _batchCard('Wednesday', batch.time),
                    _batchCard('Friday', batch.time),
                    ElevatedButton(
                      onPressed: () =>
                          ownerPush(context, AppRoutes.studentSchedule),
                      child: const Text('Edit Schedule'),
                    ),
                  ]),
                  _batchList([
                    _batchCard('Monthly attendance chart',
                        'Graph placeholder for attendance'),
                    ...students.map((s) =>
                        _batchCard(s.name, '${s.attendancePercent}% attended')),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _batchList(List<Widget> children) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: children
            .map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: child,
                ))
            .toList(),
      );

  Widget _batchCard(String title, String subtitle) => RoundedPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(subtitle),
          ],
        ),
      );

  Widget _buttonWrap(BuildContext context, List<String> labels) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: labels
            .map(
              (label) => FilledButton.tonal(
                onPressed: () {
                  switch (label) {
                    case 'View Students':
                      ownerPush(context, AppRoutes.students);
                      return;
                    case 'Add Student':
                      ownerPush(context, AppRoutes.createStudent);
                      return;
                    case 'Edit Schedule':
                      ownerPush(context, AppRoutes.studentSchedule);
                      return;
                    default:
                      debugPrint('Unhandled batch action: $label');
                      return;
                  }
                },
                child: Text(label),
              ),
            )
            .toList(),
      );
}

class CreateBatchScreen extends StatelessWidget {
  const CreateBatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Batch')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              children: [
                const SectionTitle(title: 'Batch Information'),
                const SimpleFormField(label: 'Batch name*'),
                const _InlineDropdown(label: 'Sport type*', value: 'Cricket'),
                const _InlineDropdown(label: 'Batch level', value: 'Beginner'),
                const SectionTitle(title: 'Coach Assignment'),
                const _InlineDropdown(
                    label: 'Assign coach*', value: 'Rohan Mehta'),
                const SectionTitle(title: 'Schedule'),
                const SimpleFormField(label: 'Days of week*'),
                const SimpleFormField(label: 'Start time*'),
                const SimpleFormField(label: 'End time*'),
                const SimpleFormField(label: 'Start date*'),
                const SimpleFormField(label: 'End date'),
                const SectionTitle(title: 'Capacity & Fees'),
                const SimpleFormField(
                    label: 'Max capacity*', keyboardType: TextInputType.number),
                const SimpleFormField(
                    label: 'Fee amount*', keyboardType: TextInputType.number),
                const SimpleFormField(
                    label: 'Discount %', keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Create Batch'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeeManagementScreen extends StatelessWidget {
  const FeeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fee Management'),
          actions: [
            TextButton.icon(
              onPressed: () => _recordPayment(context),
              icon: const Icon(Icons.payments_rounded, size: 18),
              label: const Text('Collect Now'),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Fee Plans'),
              Tab(text: 'Student Payments'),
              Tab(text: 'Payment History'),
              Tab(text: 'Reminders'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Expanded(child: _MetricMini('Rs 1.45L', 'Revenue')),
                  SizedBox(width: 8),
                  Expanded(child: _MetricMini('Rs 32.5k', 'Pending')),
                  SizedBox(width: 8),
                  Expanded(child: _MetricMini('Rs 15k', 'Overdue')),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...academyFeePlans.map(
                        (plan) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: RoundedPanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(plan.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(height: 6),
                                Text(
                                    '${plan.sport} • ${plan.duration} • ${money(plan.amount)}'),
                                Text(
                                    'Discount ${plan.discountPercent}% • Students ${plan.studentsCount}'),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    TextButton(
                                        onPressed: () =>
                                            context.push(AppRoutes.feePlan),
                                        child: const Text('Edit')),
                                    TextButton(
                                        onPressed: () => ownerPush(context,
                                            '${AppRoutes.feePlanDetails}/${Uri.encodeComponent(plan.name)}'),
                                        child: const Text('View Details')),
                                    TextButton(
                                        onPressed: () => ownerPush(context,
                                            '${AppRoutes.feePlanDelete}/${Uri.encodeComponent(plan.name)}'),
                                        child: const Text('Delete')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => context.push(AppRoutes.feePlan),
                        child: const Text('Create New Plan'),
                      ),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const RoundedPanel(
                        child: Column(
                          children: [
                            _InlineDropdown(label: 'Status', value: 'All'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...academyStudents.map(
                        (student) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: RoundedPanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(student.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text(
                                    '${student.batch} • ${money(student.fee)}'),
                                Text(
                                    'Paid ${money(student.totalPaid)} • Balance ${money(student.balance)}'),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    OutlinedButton(
                                        onPressed: () => context.push(
                                            '${AppRoutes.feeInvoice}/${student.id}'),
                                        child: const Text('View Invoice')),
                                    OutlinedButton(
                                        onPressed: () => context
                                            .push(AppRoutes.feeReminderForm),
                                        child: const Text('Send Reminder')),
                                    FilledButton.tonal(
                                        onPressed: () => context.push(
                                            '${AppRoutes.feeRecordPayment}/${student.id}'),
                                        child: const Text('Record Payment')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const RoundedPanel(
                        child: Column(
                          children: [
                            SimpleFormField(label: 'Date range'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...academyStudents
                          .expand((student) => student.feeHistory)
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: RoundedPanel(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                          '${entry.date} • ${entry.batch}'),
                                    ),
                                    Text(money(entry.amount)),
                                    const SizedBox(width: 12),
                                    TextButton(
                                        onPressed: () => context.push(
                                            '${AppRoutes.feeReceipt}/${academyStudents.first.id}'),
                                        child: const Text('Receipt')),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const RoundedPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pending fees due 15th of month',
                                style: TextStyle(fontWeight: FontWeight.w800)),
                            SizedBox(height: 6),
                            Text('Active'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton(
                              onPressed: () =>
                                  ownerPush(context, AppRoutes.feeReminderForm),
                              child: const Text('Edit')),
                          OutlinedButton(
                              onPressed: () =>
                                  ownerPush(context, AppRoutes.feeReminderList),
                              child: const Text('Disable')),
                          ElevatedButton(
                              onPressed: () =>
                                  ownerPush(context, AppRoutes.feeReminderForm),
                              child: const Text('Create New Reminder')),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _recordPayment(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Record Payment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              const SimpleFormField(
                  label: 'Student name*', initialValue: 'Arjun Patel'),
              const SimpleFormField(
                  label: 'Batch / Plan*', initialValue: 'Cricket Monthly'),
              const SimpleFormField(
                  label: 'Amount paid*',
                  initialValue: '2000',
                  keyboardType: TextInputType.number),
              const _InlineDropdown(label: 'Payment method*', value: 'UPI'),
              const SimpleFormField(
                  label: 'Payment date*', initialValue: '23 Apr 2026'),
              const SimpleFormField(label: 'Transaction ID'),
              const SimpleFormField(label: 'Notes'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Payment of Rs 2,000 recorded')),
                        );
                      },
                      child: const Text('Record Payment'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeePlanScreen extends StatelessWidget {
  const FeePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fee Plan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              children: [
                const SectionTitle(title: 'Plan Information'),
                const SimpleFormField(label: 'Plan name*'),
                const _InlineDropdown(
                    label: 'Applicable sport*', value: 'Cricket'),
                const _InlineDropdown(label: 'Duration*', value: '1 month'),
                const SectionTitle(title: 'Pricing'),
                const SimpleFormField(
                    label: 'Base fee*', keyboardType: TextInputType.number),
                const SimpleFormField(
                    label: 'Discount percentage',
                    keyboardType: TextInputType.number),
                const SimpleFormField(
                    label: 'Tax percentage',
                    keyboardType: TextInputType.number),
                const RoundedPanel(
                  child: Row(
                    children: [
                      Expanded(child: Text('Final fee')),
                      Text('Rs 5,000',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const SectionTitle(title: 'Plan Details'),
                const SimpleFormField(label: 'Description'),
                const SimpleFormField(label: 'Valid from - to'),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Save Plan'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeeInvoiceScreen extends StatelessWidget {
  const FeeInvoiceScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    final student = academyStudents.firstWhere(
      (item) => item.id == studentId,
      orElse: () => academyStudents.first,
    );
    return Scaffold(
      appBar: ownerAppBar(context, 'Invoice & Receipt'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Swing Academy',
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 8),
                const Text('Invoice ID: INV-2026-001'),
                const Text('Date issued: 23 Apr 2026'),
                const SizedBox(height: 14),
                Text('Bill To: ${student.name}'),
                Text('Parent: ${student.guardianName}'),
                const Divider(),
                Text('${student.batch} • ${money(student.fee)}'),
                Text('Discount: Rs 0'),
                Text('Tax: Rs 0'),
                Text(
                  'Total Due / Paid: ${money(student.fee)}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Text(
                  student.balance <= 0
                      ? 'Paid in full'
                      : 'Partial payment – Balance due: ${money(student.balance)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                  onPressed: () => _generatePdfDocument(
                        context,
                        title: 'Invoice ${student.name}',
                        lines: [
                          'Student: ${student.name}',
                          'Batch: ${student.batch}',
                          'Amount: ${money(student.fee)}',
                        ],
                      ),
                  child: const Text('Download PDF')),
              OutlinedButton(
                  onPressed: () => _generatePdfDocument(
                        context,
                        title: 'Invoice ${student.name}',
                        lines: [
                          'Student: ${student.name}',
                          'Batch: ${student.batch}',
                          'Amount: ${money(student.fee)}',
                        ],
                        printAfterCreate: true,
                      ),
                  child: const Text('Print')),
              OutlinedButton(
                  onPressed: () => _openWhatsAppShare(
                        context,
                        message:
                            'Invoice for ${student.name}: ${money(student.fee)} due for ${student.batch}.',
                      ),
                  child: const Text('Share via WhatsApp')),
              OutlinedButton(
                onPressed: () =>
                    ownerPush(context, '${AppRoutes.feeReceipt}/$studentId'),
                child: const Text('Receipt'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Salary Management'),
          actions: [
            TextButton.icon(
              onPressed: () => _markSalaryPaid(context),
              icon: const Icon(Icons.payments_rounded, size: 18),
              label: const Text('Pay Now'),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Salary Breakdown'),
              Tab(text: 'Payment History'),
              Tab(text: 'Incentives'),
              Tab(text: 'Reports'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Expanded(child: _MetricMini('Rs 1.2L', 'Total')),
                  SizedBox(width: 8),
                  Expanded(child: _MetricMini('Rs 80k', 'Paid')),
                  SizedBox(width: 8),
                  Expanded(child: _MetricMini('Rs 40k', 'Pending')),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: academyCoaches
                        .map(
                          (coach) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: RoundedPanel(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(coach.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800)),
                                      ),
                                      StatusBadge(
                                        label: coach.salaryHistory.first
                                                .contains('Pending')
                                            ? 'Pending'
                                            : 'Paid',
                                        color: coach.salaryHistory.first
                                                .contains('Pending')
                                            ? const Color(0xFFF59E0B)
                                            : const Color(0xFF16A34A),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text('Base salary ${money(coach.salary)}'),
                                  Text(
                                      'Incentives Rs 5,000 • Deductions Rs 1,000'),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      OutlinedButton(
                                          onPressed: () => context.push(
                                              '${AppRoutes.payroll}/${coach.id}'),
                                          child: const Text('View Details')),
                                      OutlinedButton(
                                          onPressed: () =>
                                              _markSalaryPaid(context),
                                          child: const Text('Mark Paid')),
                                      OutlinedButton(
                                          onPressed: () => context.push(
                                              '${AppRoutes.payrollSendSlip}/${coach.id}'),
                                          child: const Text('Send Slip')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: academyCoaches
                        .expand((coach) => coach.salaryHistory
                            .map((h) => _historyTile('${coach.name} • $h')))
                        .toList(),
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      RoundedPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rs 500 per session conducted',
                                style: TextStyle(fontWeight: FontWeight.w800)),
                            SizedBox(height: 4),
                            Text('Manage incentive rules'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: () =>
                                context.push(AppRoutes.payrollIncentives),
                            child: const Text('View Incentives'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                context.push(AppRoutes.payrollAddIncentive),
                            child: const Text('Add Incentive'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      RoundedPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Monthly salary expense trend',
                                style: TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 12),
                            Container(
                                height: 120, color: const Color(0xFFE2E8F0)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                                onPressed: () =>
                                    context.push(AppRoutes.payrollReport),
                                child: const Text('Download Payroll Report')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _markSalaryPaid(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Mark Salary Paid',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              const SimpleFormField(
                  label: 'Coach name*', initialValue: 'Rohan Mehta'),
              const SimpleFormField(label: 'Month*', initialValue: 'Apr 2026'),
              const SimpleFormField(
                  label: 'Amount paid*',
                  initialValue: '23500',
                  keyboardType: TextInputType.number),
              const _InlineDropdown(
                  label: 'Payment method*', value: 'Bank Transfer'),
              const SimpleFormField(
                  label: 'Payment date*', initialValue: '23 Apr 2026'),
              const SimpleFormField(label: 'Transaction ID'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Salary payment recorded')),
                        );
                      },
                      child: const Text('Mark as Paid'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CoachSalaryDetailsScreen extends StatelessWidget {
  const CoachSalaryDetailsScreen({super.key, required this.coachId});

  final String coachId;

  @override
  Widget build(BuildContext context) {
    final coach = academyCoaches.firstWhere(
      (item) => item.id == coachId,
      orElse: () => academyCoaches.first,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Coach Salary Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Row(
              children: [
                CircleAvatar(child: Text(coach.photoTag)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(coach.name,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
                const StatusBadge(label: 'Pending', color: Color(0xFFF59E0B)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...[
            ('Base monthly salary', 'Rs 20,000'),
            ('Sessions conducted', 'Rs 4,500'),
            ('Performance bonus', 'Rs 1,000'),
            ('Advance given', 'Rs -1,000'),
            ('Absent days', 'Rs -1,000'),
            ('Net salary', 'Rs 23,500'),
          ].map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RoundedPanel(
                  child: Row(
                    children: [
                      Expanded(child: Text(row.$1)),
                      Text(row.$2,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              )),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                  onPressed: () =>
                      context.push('${AppRoutes.payrollSendSlip}/$coachId'),
                  child: const Text('Mark as Paid')),
              OutlinedButton(
                  onPressed: () =>
                      context.push('${AppRoutes.payrollSendSlip}/$coachId'),
                  child: const Text('Download Slip')),
              OutlinedButton(
                  onPressed: () =>
                      context.push('${AppRoutes.payrollSendSlip}/$coachId'),
                  child: const Text('Send Slip')),
            ],
          ),
        ],
      ),
    );
  }
}

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventory'),
          actions: [
            TextButton.icon(
              onPressed: () => context.push(AppRoutes.inventoryItem),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Item'),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Stock Items'),
              Tab(text: 'Issued Items'),
              Tab(text: 'Damage / Loss'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const RoundedPanel(
                  child: Column(
                    children: [
                      SimpleFormField(label: 'Search by item name'),
                      _InlineDropdown(
                          label: 'Category', value: 'Sports Equipment'),
                      _InlineDropdown(label: 'Status', value: 'In Stock'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ...inventoryItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RoundedPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(
                              '${item.category} • ${item.quantity} ${item.unit} • ${money(item.value)}'),
                          Text(item.status),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              OutlinedButton(
                                  onPressed: () => ownerPush(
                                      context, AppRoutes.inventoryItem),
                                  child: const Text('Edit')),
                              OutlinedButton(
                                  onPressed: () => ownerPush(
                                      context, AppRoutes.inventoryBilling),
                                  child: const Text('Billing Create')),
                              OutlinedButton(
                                  onPressed: () => ownerPush(
                                      context, AppRoutes.inventoryIssue),
                                  child: const Text('Issue Item')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const RoundedPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cricket Balls • Batch A1',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      SizedBox(height: 4),
                      Text('Issued to Coach Rohan • Return 25 Apr 2026'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      ownerPush(context, AppRoutes.inventoryIssueHistory),
                  child: const Text('View Issue History'),
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                RoundedPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Batting Gloves',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      SizedBox(height: 4),
                      Text('Damaged on 10 Apr 2026 • Replacement Rs 2,400'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryItemScreen extends StatelessWidget {
  const InventoryItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ownerAppBar(context, 'Add / Edit Inventory Item'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              children: [
                const SectionTitle(title: 'Item Information'),
                const SimpleFormField(label: 'Item name*'),
                const _InlineDropdown(
                    label: 'Category*', value: 'Sports Equipment'),
                const SimpleFormField(label: 'Description'),
                const SectionTitle(title: 'Stock Details'),
                const SimpleFormField(
                    label: 'Quantity*', keyboardType: TextInputType.number),
                const _InlineDropdown(label: 'Unit*', value: 'each'),
                const SimpleFormField(
                    label: 'Unit cost*', keyboardType: TextInputType.number),
                const SimpleFormField(
                    label: 'Total value', initialValue: 'Rs 0'),
                const SectionTitle(title: 'Tracking'),
                const SimpleFormField(label: 'Serial / Batch number'),
                const SimpleFormField(label: 'Purchase date'),
                const SimpleFormField(label: 'Warranty expiry'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            ownerGo(context, AppRoutes.inventoryBilling),
                        child: const Text('Save'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ownerAppBar(context, 'Reports'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const RoundedPanel(
            child: Column(
              children: [
                SimpleFormField(label: 'From - To'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
              onPressed: () => ownerPush(
                  context, '${AppRoutes.reports}/${reportTypes.first.id}'),
              child: const Text('Generate Report')),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reportTypes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.08,
            ),
            itemBuilder: (context, index) {
              final report = reportTypes[index];
              return RoundedPanel(
                onTap: () => context.push('${AppRoutes.reports}/${report.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SoftIcon(icon: report.icon, color: const Color(0xFF6366F1)),
                    const Spacer(),
                    Text(report.title,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(report.description,
                        style: const TextStyle(color: Color(0xFF64748B))),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                  onPressed: () => _generatePdfDocument(
                        context,
                        title: 'Academy Report',
                        lines: reportTypes
                            .map((item) => '${item.title}: ${item.description}')
                            .toList(),
                      ),
                  child: const Text('Download as PDF')),
              OutlinedButton(
                  onPressed: () => _generateCsvFile(
                        context,
                        fileName: 'academy_report.csv',
                        content:
                            'Report,Description\n${reportTypes.map((item) => '${item.title},${item.description}').join('\n')}',
                      ),
                  child: const Text('Download as Excel')),
              OutlinedButton(
                  onPressed: () => _generatePdfDocument(
                        context,
                        title: 'Academy Report',
                        lines: reportTypes
                            .map((item) => '${item.title}: ${item.description}')
                            .toList(),
                        printAfterCreate: true,
                      ),
                  child: const Text('Print')),
            ],
          ),
        ],
      ),
    );
  }
}

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key, required this.reportId});

  final String reportId;

  @override
  Widget build(BuildContext context) {
    final report = reportTypes.firstWhere(
      (item) => item.id == reportId,
      orElse: () => reportTypes.first,
    );
    return Scaffold(
      appBar: ownerAppBar(context, report.title),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text('Date range: Jan 1 – Mar 31, 2024'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton(
                        onPressed: () {}, child: const Text('Edit Filter')),
                    OutlinedButton(
                        onPressed: () => _generatePdfDocument(
                              context,
                              title: report.title,
                              lines: [
                                'Date range: Jan 1 - Mar 31, 2024',
                                'Total revenue: Rs 4.35L',
                                'Average monthly: Rs 1.45L',
                              ],
                            ),
                        child: const Text('Export')),
                    OutlinedButton(
                        onPressed: () => _generatePdfDocument(
                              context,
                              title: report.title,
                              lines: [
                                'Date range: Jan 1 - Mar 31, 2024',
                                'Total revenue: Rs 4.35L',
                                'Average monthly: Rs 1.45L',
                              ],
                              printAfterCreate: true,
                            ),
                        child: const Text('Print')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(child: _MetricMini('Rs 4.35L', 'Total')),
              SizedBox(width: 8),
              Expanded(child: _MetricMini('Rs 1.45L', 'Average')),
              SizedBox(width: 8),
              Expanded(child: _MetricMini('+12%', 'Growth')),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            'Revenue trend',
            'Revenue by batch',
            'Revenue source',
          ].map(
            (title) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RoundedPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    Container(height: 140, color: const Color(0xFFE2E8F0)),
                  ],
                ),
              ),
            ),
          ),
          const RoundedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Month, Revenue, % Change, Notes',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 8),
                Text('Jan • Rs 1.2L • +5% • Strong enrollment'),
                Text('Feb • Rs 1.45L • +9% • Higher collections'),
                Text('Mar • Rs 1.7L • +12% • Batch expansion'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DevelopmentSettingsScreen extends StatelessWidget {
  const DevelopmentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academy Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ExpansionSection(
            title: 'Account Information',
            children: [
              SimpleFormField(
                  label: 'Academy name', initialValue: 'Swing Academy'),
              SimpleFormField(label: 'Address', initialValue: 'Mumbai'),
              SimpleFormField(label: 'Phone'),
              SimpleFormField(label: 'Email'),
            ],
          ),
          _ExpansionSection(
            title: 'Subscription Plan',
            children: [
              _StaticText('Current plan: Professional'),
              _StaticText('Up to 50 players'),
              _StaticText('Up to 10 coaches'),
              _StaticText('Salary management'),
            ],
          ),
          _ExpansionSection(
            title: 'Payment Methods',
            children: [
              _StaticText('Bank account: XXXXXXXX8901'),
              _StaticText('UPI ID: swing@upi'),
            ],
          ),
          _ExpansionSection(
            title: 'User Access Control',
            children: [
              _StaticText('Admin (current user)'),
              _StaticText('Co-owner'),
            ],
          ),
          _ExpansionSection(
            title: 'Notifications',
            children: [
              _StaticText('Email notifications enabled'),
              _StaticText('SMS notifications enabled'),
              _StaticText('Push notifications enabled'),
            ],
          ),
          _ExpansionSection(
            title: 'Data & Privacy',
            children: [
              _StaticText('Download My Data'),
              _StaticText('Delete Account'),
            ],
          ),
          _ExpansionSection(
            title: 'Help & Support',
            children: [
              _StaticText('View Help Center'),
              _StaticText('Contact Support'),
              _StaticText('Report Bug'),
            ],
          ),
        ],
      ),
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
          const _PlanCard(
            title: 'Free',
            price: 'Rs 0',
            color: Color(0xFF64748B),
            features: ['50 players', '5 coaches', 'Basic billing'],
          ),
          const SizedBox(height: 12),
          const _PlanCard(
            title: 'Professional',
            price: 'Rs 4,999 / month',
            color: Color(0xFFF59E0B),
            features: [
              'Salary management',
              'Reports',
              'Inventory',
              'Advanced analytics',
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Upgrade Plan'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          RoundedPanel(
            child: Column(
              children: [
                _InlineDropdown(label: 'Audience', value: 'All students'),
                SimpleFormField(label: 'Batch'),
                SimpleFormField(label: 'Message'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AcademyProfileScreen extends StatelessWidget {
  const AcademyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AcademyOverviewScreen();
  }
}

class EditStudentScreen extends StatelessWidget {
  const EditStudentScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    final student = academyStudents.firstWhere(
      (item) => item.id == studentId,
      orElse: () => academyStudents.first,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Player')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              children: [
                SimpleFormField(label: 'Name', initialValue: student.name),
                SimpleFormField(label: 'Age', initialValue: '${student.age}'),
                SimpleFormField(label: 'Sport', initialValue: 'Cricket'),
                SimpleFormField(label: 'Batch', initialValue: student.batch),
                SimpleFormField(label: 'Fees', initialValue: '${student.fee}'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      context.go('${AppRoutes.students}/$studentId'),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DeleteStudentConfirmationScreen extends StatelessWidget {
  const DeleteStudentConfirmationScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    final student = academyStudents.firstWhere(
      (item) => item.id == studentId,
      orElse: () => academyStudents.first,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Delete Player')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: RoundedPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Delete ${student.name}?',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                const Text('This action cannot be undone.'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.go(AppRoutes.students),
                        child: const Text('Delete'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditCoachProfileScreen extends StatelessWidget {
  const EditCoachProfileScreen({super.key, required this.coachId});

  final String coachId;

  @override
  Widget build(BuildContext context) {
    final coach = academyCoaches.firstWhere(
      (item) => item.id == coachId,
      orElse: () => academyCoaches.first,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Coach')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              children: [
                SimpleFormField(label: 'Name', initialValue: coach.name),
                SimpleFormField(label: 'Role', initialValue: coach.role),
                SimpleFormField(
                  label: 'Salary',
                  initialValue: '${coach.salary}',
                  keyboardType: TextInputType.number,
                ),
                SimpleFormField(
                  label: 'Batches',
                  initialValue: coach.assignedBatches.join(', '),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.go('${AppRoutes.coaches}/$coachId'),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DeleteCoachConfirmationScreen extends StatelessWidget {
  const DeleteCoachConfirmationScreen({super.key, required this.coachId});

  final String coachId;

  @override
  Widget build(BuildContext context) {
    final coach = academyCoaches.firstWhere(
      (item) => item.id == coachId,
      orElse: () => academyCoaches.first,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Delete Coach')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: RoundedPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Delete ${coach.name}?',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.go(AppRoutes.coaches),
                        child: const Text('Delete'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CoachAssignedBatchesScreen extends StatelessWidget {
  const CoachAssignedBatchesScreen({super.key, required this.coachId});

  final String coachId;

  @override
  Widget build(BuildContext context) {
    final coach = academyCoaches.firstWhere(
      (item) => item.id == coachId,
      orElse: () => academyCoaches.first,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Assigned Batches')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: coach.assignedBatches
            .map((batch) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: RoundedPanel(
                    child: Text(batch),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class CoachMessageScreen extends StatelessWidget {
  const CoachMessageScreen({super.key, required this.coachId});

  final String coachId;

  @override
  Widget build(BuildContext context) {
    final coach = academyCoaches.firstWhere(
      (item) => item.id == coachId,
      orElse: () => academyCoaches.first,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Send Message')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              children: [
                SimpleFormField(label: 'To', initialValue: coach.name),
                const SimpleFormField(label: 'Message'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Send Message'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecordPaymentScreen extends StatelessWidget {
  const RecordPaymentScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    final student = academyStudents.firstWhere(
      (item) => item.id == studentId,
      orElse: () => academyStudents.first,
    );
    return Scaffold(
      appBar: ownerAppBar(context, 'Record Payment'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              children: [
                SimpleFormField(label: 'Student', initialValue: student.name),
                SimpleFormField(label: 'Batch', initialValue: student.batch),
                SimpleFormField(
                  label: 'Amount paid',
                  initialValue: '${student.fee}',
                  keyboardType: TextInputType.number,
                ),
                const _InlineDropdown(label: 'Payment method', value: 'UPI'),
                const SimpleFormField(
                    label: 'Payment date', initialValue: '24 Apr 2026'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.go(
                    '${AppRoutes.feePaymentStatus}/$studentId',
                  ),
                  child: const Text('Record Payment'),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => ownerPush(
                          context, '${AppRoutes.feeInvoice}/$studentId'),
                      child: const Text('View Invoice'),
                    ),
                    OutlinedButton(
                      onPressed: () => ownerPush(
                          context, '${AppRoutes.feeReceipt}/$studentId'),
                      child: const Text('Receipt'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentStatusScreen extends StatelessWidget {
  const PaymentStatusScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    final student = academyStudents.firstWhere(
      (item) => item.id == studentId,
      orElse: () => academyStudents.first,
    );
    return Scaffold(
      appBar: ownerAppBar(context, 'Payment Status'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('Current status: ${feeStatusLabel(student.status)}'),
                Text('Paid: ${money(student.totalPaid)}'),
                Text('Balance: ${money(student.balance)}'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => ownerPush(
                          context, '${AppRoutes.feeInvoice}/$studentId'),
                      child: const Text('View Invoice'),
                    ),
                    OutlinedButton(
                      onPressed: () => ownerPush(
                          context, '${AppRoutes.feeReceipt}/$studentId'),
                      child: const Text('Receipt'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StudentPaymentHistoryScreen extends StatelessWidget {
  const StudentPaymentHistoryScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    final student = academyStudents.firstWhere(
      (item) => item.id == studentId,
      orElse: () => academyStudents.first,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: student.feeHistory
            .map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: RoundedPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.date,
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                        Text('${entry.batch} • ${money(entry.amount)}'),
                        Text(feeStatusLabel(entry.status)),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return FeeInvoiceScreen(studentId: studentId);
  }
}

class ReminderManagementScreen extends StatelessWidget {
  const ReminderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ownerAppBar(context, 'Reminders Management'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const RoundedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pending fees due 15th of month',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text('Active'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => context.push(AppRoutes.feeReminderForm),
                child: const Text('Edit Reminder'),
              ),
              OutlinedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reminder disabled')),
                ),
                child: const Text('Disable Reminder'),
              ),
              ElevatedButton(
                onPressed: () => context.push(AppRoutes.feeReminderForm),
                child: const Text('Add Reminder'),
              ),
              ElevatedButton(
                onPressed: () =>
                    ownerPush(context, AppRoutes.feeReminderHistory),
                child: const Text('Reminder History'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReminderFormScreen extends StatelessWidget {
  const ReminderFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ownerAppBar(context, 'Add Reminder'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              children: [
                const SimpleFormField(
                    label: 'Select students',
                    initialValue: 'Arjun Patel, Siya Shah'),
                const SimpleFormField(
                    label: 'Schedule', initialValue: '15th of month'),
                const SimpleFormField(
                    label: 'Message',
                    initialValue: 'Fee payment reminder for current month'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ownerGo(context, AppRoutes.feeReminderList),
                  child: const Text('Save Reminder'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReminderHistoryScreen extends StatelessWidget {
  const ReminderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ownerAppBar(context, 'Reminder History'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          RoundedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('15 Apr 2026',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Sent to 5 students for Cricket Monthly'),
              ],
            ),
          ),
          SizedBox(height: 10),
          RoundedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('01 Apr 2026',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Sent to 8 students for Cricket Quarterly'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ownerAppBar(context, 'Documents'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => ownerPush(context, AppRoutes.documentAdd),
                child: const Text('Add Document'),
              ),
              OutlinedButton(
                onPressed: () => ownerPush(context, AppRoutes.documentView),
                child: const Text('View Documents'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...academyStudents.first.documents.map(
            (document) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RoundedPanel(
                onTap: () => ownerPush(context, AppRoutes.documentView),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(document,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Text('Tap to view or delete'),
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

class AddDocumentScreen extends StatelessWidget {
  const AddDocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ownerAppBar(context, 'Add Document'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              children: [
                const SimpleFormField(label: 'Document name'),
                const _InlineDropdown(
                    label: 'Category', value: 'Admission Form'),
                const SimpleFormField(label: 'Notes'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ownerGo(context, AppRoutes.documentView),
                  child: const Text('Save Document'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ViewDocumentsScreen extends StatelessWidget {
  const ViewDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ownerAppBar(context, 'View Documents'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: academyStudents.first.documents
            .map(
              (document) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RoundedPanel(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(document,
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                      TextButton(
                        onPressed: () => ownerPush(
                          context,
                          '${AppRoutes.documentDelete}/${Uri.encodeComponent(document)}',
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class DeleteDocumentScreen extends StatelessWidget {
  const DeleteDocumentScreen({super.key, required this.documentName});

  final String documentName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ownerAppBar(context, 'Delete Document'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: RoundedPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Delete $documentName?',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            ownerGo(context, AppRoutes.documentView),
                        child: const Text('Delete'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StudentScheduleScreen extends StatelessWidget {
  const StudentScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ownerAppBar(context, 'Student Schedule'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: academyBatches
            .map(
              (batch) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RoundedPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(batch.name,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('${batch.schedule} • ${batch.time}'),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class FeePlanDetailsScreen extends StatelessWidget {
  const FeePlanDetailsScreen({super.key, required this.planName});

  final String planName;

  @override
  Widget build(BuildContext context) {
    final plan = academyFeePlans.firstWhere(
      (item) => item.name == planName,
      orElse: () => academyFeePlans.first,
    );
    return Scaffold(
      appBar: ownerAppBar(context, 'Fee Plan Details'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.name,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Sport: ${plan.sport}'),
                Text('Duration: ${plan.duration}'),
                Text('Amount: ${money(plan.amount)}'),
                Text('Discount: ${plan.discountPercent}%'),
                Text('Students enrolled: ${plan.studentsCount}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeePlanDeleteScreen extends StatelessWidget {
  const FeePlanDeleteScreen({super.key, required this.planName});

  final String planName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ownerAppBar(context, 'Delete Fee Plan'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: RoundedPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Delete $planName?',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => ownerGo(context, AppRoutes.fees),
                        child: const Text('Delete'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SendSalarySlipScreen extends StatelessWidget {
  const SendSalarySlipScreen({super.key, required this.coachId});

  final String coachId;

  @override
  Widget build(BuildContext context) {
    final coach = academyCoaches.firstWhere(
      (item) => item.id == coachId,
      orElse: () => academyCoaches.first,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Send Salary Slip')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              children: [
                SimpleFormField(label: 'Coach', initialValue: coach.name),
                const SimpleFormField(label: 'Month', initialValue: 'Apr 2026'),
                const SimpleFormField(
                    label: 'Delivery', initialValue: 'Email / WhatsApp'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Send Slip'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IncentivesScreen extends StatelessWidget {
  const IncentivesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incentives'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.payrollAddIncentive),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Incentive'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          RoundedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rohan Mehta • Rs 1,500',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Session performance incentive'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddIncentiveScreen extends StatelessWidget {
  const AddIncentiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Incentive')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              children: [
                const _InlineDropdown(label: 'Coach', value: 'Rohan Mehta'),
                const SimpleFormField(
                  label: 'Incentive amount',
                  keyboardType: TextInputType.number,
                ),
                const SimpleFormField(label: 'Reason'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.payrollIncentives),
                  child: const Text('Save Incentive'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PayrollReportScreen extends StatelessWidget {
  const PayrollReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payroll Report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          RoundedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly Payroll Summary',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 8),
                Text('Total salary expense: Rs 1,20,000'),
                Text('Pending payouts: Rs 40,000'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InventoryBillingScreen extends StatelessWidget {
  const InventoryBillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ownerAppBar(context, 'Inventory Billing'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              children: [
                const SimpleFormField(
                    label: 'Item', initialValue: 'Cricket Ball'),
                const SimpleFormField(label: 'Quantity', initialValue: '12'),
                const SimpleFormField(
                  label: 'Bill amount',
                  initialValue: '3600',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ownerGo(context, AppRoutes.inventoryIssue),
                  child: const Text('Continue to Issue Items'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IssueInventoryItemScreen extends StatelessWidget {
  const IssueInventoryItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ownerAppBar(context, 'Issue Item'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              children: [
                const _InlineDropdown(label: 'Item', value: 'Cricket Balls'),
                const SimpleFormField(
                    label: 'Assign to coach/player',
                    initialValue: 'Rohan Mehta'),
                const SimpleFormField(
                  label: 'Quantity',
                  initialValue: '10',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.inventoryIssueHistory),
                  child: const Text('Save Issue'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IssuedItemsHistoryScreen extends StatelessWidget {
  const IssuedItemsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ownerAppBar(context, 'Issued Items History'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          RoundedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cricket Balls • Coach Rohan',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Issued on 24 Apr 2026 • Return due 25 Apr 2026'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OwnerSearchScreen extends StatelessWidget {
  const OwnerSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SimpleFormField(
              label: 'Search for players, coaches, batches...'),
          const SizedBox(height: 12),
          const SectionTitle(title: 'Players'),
          RoundedPanel(
            onTap: () => context.push('${AppRoutes.students}/st-1'),
            child: const Text('Arjun Patel • Cricket Beginner A1'),
          ),
          const SizedBox(height: 10),
          const SectionTitle(title: 'Coaches'),
          RoundedPanel(
            onTap: () => context.push('${AppRoutes.coaches}/co-1'),
            child: const Text('Rohan Mehta • Cricket Coach'),
          ),
        ],
      ),
    );
  }
}

class OwnerNotificationsScreen extends StatelessWidget {
  const OwnerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      'Payment received from Arjun Patel',
      'Reminder sent to 5 students',
      'Salary slip pending for coach payout',
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: RoundedPanel(
            onTap: () =>
                context.push('${AppRoutes.ownerNotificationDetail}/$index'),
            child: Text(items[index]),
          ),
        ),
      ),
    );
  }
}

class OwnerNotificationDetailScreen extends StatelessWidget {
  const OwnerNotificationDetailScreen(
      {super.key, required this.notificationIndex});

  final int notificationIndex;

  @override
  Widget build(BuildContext context) {
    final details = [
      'Rs 2,000 has been paid for the March batch fee.',
      'Fee reminder was sent to 5 players with pending dues.',
      'April salary slip is ready to be sent to the assigned coach.',
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RoundedPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(details[notificationIndex],
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Take Action'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OwnerLogoutConfirmationScreen extends ConsumerWidget {
  const OwnerLogoutConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logout')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: RoundedPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Are you sure you want to logout?',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await ref
                              .read(sessionControllerProvider.notifier)
                              .signOut();
                          if (context.mounted) context.go(AppRoutes.welcome);
                        },
                        child: const Text('Logout'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionConfig {
  const _ActionConfig(this.label, this.onPressed);

  final String label;
  final VoidCallback onPressed;
}

class _ExpansionSection extends StatelessWidget {
  const _ExpansionSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: children,
      ),
    );
  }
}

class _StaticText extends StatelessWidget {
  const _StaticText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(alignment: Alignment.centerLeft, child: Text(text)),
    );
  }
}

class _MetricMini extends StatelessWidget {
  const _MetricMini(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return RoundedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}

class _InlineDropdown extends StatelessWidget {
  const _InlineDropdown({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RoundedPanel(
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
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
                child: Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900)),
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

Widget _historyTile(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RoundedPanel(child: Text(text)),
    );
