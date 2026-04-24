import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/router/app_router.dart';
import '../data/coach_dashboard_data.dart';

const _coachBg = Color(0xFF121212);
const _coachCard = Color(0xFF1E1E1E);
const _coachBorder = Color(0xFF2A2A2A);
const _coachRed = Color(0xFF8B0000);
const _coachSoftRed = Color(0xFFE57F7F);
const _coachText = Color(0xFFFFFFFF);
const _coachMuted = Color(0xFFBDBDBD);

class CoachHomeScreen extends ConsumerWidget {
  const CoachHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaySessions = coachSessions.take(3).toList();
    return Scaffold(
      backgroundColor: _coachBg,
      appBar: AppBar(
        backgroundColor: _coachBg,
        foregroundColor: _coachText,
        title: const Text('Academy Manager - Coach'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.sharedSearch),
            icon: const Icon(Icons.search_rounded),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () => context.push(AppRoutes.sharedNotifications),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: _coachRed,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '2',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: _coachRed,
              child: Text('RM', style: TextStyle(color: Colors.white)),
            ),
            onSelected: (value) {
              if (value == 'profile') {
                context.push(AppRoutes.sharedProfileMenu);
              } else if (value == 'settings') {
                context.push(AppRoutes.coachSettings);
              } else if (value == 'help') {
                context.push(AppRoutes.sharedProfileMenu);
              } else if (value == 'logout') {
                context.push(AppRoutes.sharedLogoutConfirm);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'profile', child: Text('Account')),
              PopupMenuItem(value: 'settings', child: Text('Settings')),
              PopupMenuItem(value: 'help', child: Text('Help Center')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _WelcomeBanner(),
          const SizedBox(height: 14),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _SectionTitle("Today's Sessions"),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.coachSchedule),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...todaySessions.map(
                  (session) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SessionOverviewTile(session: session),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: _buttonStyle(),
                    onPressed: () => context.push(
                      '${AppRoutes.coachSessions}/${todaySessions.first.id}',
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start Session'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(
                child: _MetricCard(
                  label: 'Sessions This Month',
                  value: '42 / 45 (93%)',
                  icon: Icons.timeline_rounded,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'Avg Attendance',
                  value: '87%',
                  icon: Icons.fact_check_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _MetricCard(
            label: 'Monthly Earnings',
            value: 'Rs 25,000 (pending)',
            icon: Icons.payments_rounded,
          ),
          const SizedBox(height: 18),
          const _SectionTitle('Quick Access'),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: coachQuickModules.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final module = coachQuickModules[index];
              return _Panel(
                onTap: () => context.push(module.route),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SoftCircleIcon(module.icon),
                    const SizedBox(height: 10),
                    Text(
                      module.label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _coachText,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          const _SectionTitle('Recent Activity'),
          const SizedBox(height: 10),
          ...coachActivities.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _Panel(
                child: Row(
                  children: [
                    const _SoftCircleIcon(Icons.history_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: _coachText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _CoachBottomNav(index: 0),
    );
  }
}

class CoachProfilePlanScreen extends StatelessWidget {
  const CoachProfilePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CoachShell(
      title: 'Coach Profile',
      bottomIndex: 5,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Panel(
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 34,
                      backgroundColor: _coachRed,
                      child: Text(
                        'RM',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coachName,
                            style: TextStyle(
                              color: _coachText,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Cricket, Fitness',
                            style: TextStyle(color: _coachMuted),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Rating 4.5 / 5',
                            style: TextStyle(color: _coachSoftRed),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => context.push(AppRoutes.coachProfileEdit),
                      child: const Text('Edit Profile'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const _InfoRow('Full name', coachName),
                const _InfoRow('DOB', '14 Jun 1991'),
                const _InfoRow('Phone', '+91 98765 43210'),
                const _InfoRow('Email', 'rohan@swingacademy.in'),
                const _InfoRow('Academy', coachAcademy),
                const _InfoRow('Years of experience', '8 years'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Assigned Batches'),
                const SizedBox(height: 12),
                ...coachAssignedBatches.map(
                  (batch) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child:
                        Text(batch, style: const TextStyle(color: _coachMuted)),
                  ),
                ),
                const SizedBox(height: 10),
                const _InfoRow('Total students coached', '28'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Availability'),
                const SizedBox(height: 12),
                const _InfoRow('Work days', 'Mon-Sat'),
                const _InfoRow('Hours', '5:00 PM - 9:00 PM'),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    style: _buttonStyle(),
                    onPressed: () => context.push(AppRoutes.coachProfileEdit),
                    child: const Text('Edit Availability'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CoachEditProfileScreen extends StatelessWidget {
  const CoachEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CoachShell(
      title: 'Edit Coach Profile',
      bottomIndex: 5,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Personal Information'),
                const SizedBox(height: 12),
                const _Field(label: 'Full name', initialValue: coachName),
                const _Field(label: 'DOB', initialValue: '14 Jun 1991'),
                const _Field(label: 'Phone', initialValue: '+91 98765 43210'),
                const _Field(
                  label: 'Email',
                  initialValue: 'rohan@swingacademy.in',
                ),
                const _DropdownField(label: 'Gender', value: 'Male'),
                const SizedBox(height: 16),
                const _SectionTitle('Professional Information'),
                const SizedBox(height: 12),
                const _DropdownField(
                  label: 'Sports specialization',
                  value: 'Cricket, Fitness',
                ),
                const _Field(label: 'Years of experience', initialValue: '8'),
                const _Field(
                  label: 'Certifications',
                  initialValue: 'NIS Level 1, Strength Coach Level 1',
                ),
                const _Field(
                  label: 'Bio',
                  initialValue:
                      'Focus on structured player development and game intelligence.',
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                const _SectionTitle('Availability'),
                const SizedBox(height: 12),
                const _DropdownField(label: 'Work days', value: 'Mon-Sat'),
                const _Field(
                    label: 'Available hours',
                    initialValue: '5:00 PM - 9:00 PM'),
                const _Field(label: 'Days off', initialValue: 'Sunday morning'),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: _buttonStyle(),
                        onPressed: () => context.pop(),
                        child: const Text('Save Changes'),
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

class CoachTodaySessionsScreen extends StatelessWidget {
  const CoachTodaySessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CoachShell(
      title: "Today's Sessions",
      bottomIndex: 1,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Panel(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '23 Apr 2026',
                        style: TextStyle(
                          color: _coachText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('3 sessions today',
                          style: TextStyle(color: _coachMuted)),
                    ],
                  ),
                ),
                _SoftCircleIcon(Icons.schedule_rounded),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...coachSessions.take(3).map(
                (session) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CoachSessionCard(session: session),
                ),
              ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: _buttonStyle(),
            onPressed: () => context.push(AppRoutes.coachSchedule),
            child: const Text('View Full Schedule'),
          ),
        ],
      ),
    );
  }
}

class CoachScheduleScreen extends StatelessWidget {
  const CoachScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: _CoachShell(
        title: 'My Sessions',
        bottomIndex: 1,
        appBarBottom: const TabBar(
          tabs: [
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
            Tab(text: 'List'),
          ],
        ),
        child: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _Panel(
                  child: Text(
                    'Mon-Sun Weekly Calendar\n6:00 AM - 9:00 PM',
                    style: TextStyle(
                        color: _coachText, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 12),
                ...coachSessions.map(
                  (session) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _Panel(
                      onTap: () => context.push(
                        '${AppRoutes.coachSessions}/${session.id}',
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${session.batchName} - ${session.dateLabel}',
                            style: const TextStyle(
                              color: _coachText,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${session.timeRange} - ${session.studentCount} students',
                            style: const TextStyle(color: _coachMuted),
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
              children: const [
                _Panel(
                  child: Text(
                    'Monthly calendar view with session markers for assigned batches.',
                    style: TextStyle(color: _coachMuted),
                  ),
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: coachSessions
                  .map(
                    (session) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SessionOverviewTile(session: session),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class CoachSessionDetailsScreen extends StatefulWidget {
  const CoachSessionDetailsScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  State<CoachSessionDetailsScreen> createState() =>
      _CoachSessionDetailsScreenState();
}

class _CoachSessionDetailsScreenState extends State<CoachSessionDetailsScreen> {
  bool _started = false;
  bool _ended = false;
  final Map<String, AttendanceMark> _attendance = {};
  final TextEditingController _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = coachSessions.firstWhere(
      (item) => item.id == widget.sessionId,
      orElse: () => coachSessions.first,
    );
    final attendanceEnabled = _started && !_ended;

    return Scaffold(
      backgroundColor: _coachBg,
      appBar: AppBar(
        backgroundColor: _coachBg,
        foregroundColor: _coachText,
        title: const Text('Session Detail'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
        children: [
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.batchName,
                  style: const TextStyle(
                    color: _coachText,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${session.dateLabel} - ${session.timeRange}',
                  style: const TextStyle(color: _coachMuted),
                ),
                const SizedBox(height: 8),
                Text(
                  _ended
                      ? 'Session completed'
                      : _started
                          ? 'Happening now'
                          : 'Upcoming in 15 min',
                  style: const TextStyle(color: _coachSoftRed),
                ),
                if (_started && !_ended) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Time remaining: 01:02:00',
                    style: TextStyle(color: _coachMuted),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton(
                      style: _buttonStyle(),
                      onPressed: _started || _ended
                          ? null
                          : () => setState(() => _started = true),
                      child: const Text('Start Session'),
                    ),
                    OutlinedButton(
                      onPressed: !_started || _ended
                          ? null
                          : () {
                              setState(() => _ended = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Attendance marked for ${session.batchName} (${session.studentCount} students)',
                                  ),
                                ),
                              );
                              context.pop();
                            },
                      child: const Text('End Session'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Session Information'),
                const SizedBox(height: 12),
                _InfoRow('Sport', session.sport),
                _InfoRow('Location', session.location),
                _InfoRow(
                  'Students',
                  '${session.studentCount} / ${session.capacity}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _SectionTitle('Attendance'),
          const SizedBox(height: 10),
          ...session.students.map(
            (student) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: _coachRed,
                          child: Icon(Icons.person_rounded,
                              color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            student,
                            style: const TextStyle(
                              color: _coachText,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: AttendanceMark.values.map((mark) {
                        return ChoiceChip(
                          label: Text(_attendanceLabel(mark)),
                          selected: _attendance[student] == mark,
                          onSelected: attendanceEnabled
                              ? (_) =>
                                  setState(() => _attendance[student] = mark)
                              : null,
                          selectedColor: _coachRed,
                          backgroundColor: _coachBg,
                          labelStyle: TextStyle(
                            color: _attendance[student] == mark
                                ? Colors.white
                                : _coachMuted,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      enabled: attendanceEnabled,
                      style: const TextStyle(color: _coachText),
                      decoration: _inputDecoration('Notes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Session Notes'),
                const SizedBox(height: 12),
                TextField(
                  controller: _notes,
                  enabled: !_ended,
                  maxLines: 4,
                  maxLength: 500,
                  style: const TextStyle(color: _coachText),
                  decoration: _inputDecoration(
                    'Good energy today, focus on ball control',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: _coachBg,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: _buttonStyle(),
                onPressed: attendanceEnabled
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Attendance marked for ${session.batchName} (${session.studentCount} students)',
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text('Save Attendance'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: !_started || _ended
                    ? null
                    : () {
                        setState(() => _ended = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Session ended')),
                        );
                        context.pop();
                      },
                child: const Text('End Session'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CoachStudentsScreen extends StatelessWidget {
  const CoachStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CoachShell(
      title: 'My Students',
      bottomIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '28 Students',
                  style: TextStyle(
                    color: _coachText,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 12),
                _Field(label: 'Search by name'),
                _DropdownField(label: 'Batch', value: 'All batches'),
                _DropdownField(label: 'Status', value: 'Active'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...coachStudents.map(
            (student) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _Panel(
                onTap: () => context.push(
                  '${AppRoutes.coachStudents}/${student.id}',
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: _coachRed,
                      child: Icon(Icons.person_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: const TextStyle(
                              color: _coachText,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(student.batch,
                              style: const TextStyle(color: _coachMuted)),
                          Text(
                            'Attendance ${student.attendancePercent}% (${student.attendedSessions}/${student.totalSessions})',
                            style: const TextStyle(color: _coachMuted),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${student.performanceRating}',
                          style: const TextStyle(
                            color: _coachSoftRed,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'Rating',
                          style: TextStyle(color: _coachMuted, fontSize: 12),
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

class CoachStudentDetailScreen extends StatelessWidget {
  const CoachStudentDetailScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    final student = coachStudents.firstWhere(
      (item) => item.id == studentId,
      orElse: () => coachStudents.first,
    );
    return DefaultTabController(
      length: 4,
      child: _CoachShell(
        title: 'Student Detail',
        bottomIndex: 2,
        appBarBottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Attendance'),
            Tab(text: 'Performance Notes'),
            Tab(text: 'Injury / Health'),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _Panel(
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: _coachRed,
                      child: Icon(Icons.person_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: const TextStyle(
                              color: _coachText,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${student.age} yrs - ${student.batch}',
                            style: const TextStyle(color: _coachMuted),
                          ),
                          Text(
                            'Overall rating ${student.performanceRating}/10',
                            style: const TextStyle(color: _coachSoftRed),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _Panel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle('Overview'),
                            const SizedBox(height: 12),
                            _InfoRow('Phone', student.phone),
                            _InfoRow('Parent', student.parentName),
                            _InfoRow('Join date', student.joinDate),
                            _InfoRow('Status', student.status),
                            const SizedBox(height: 12),
                            const _SectionTitle('Skill Areas'),
                            const SizedBox(height: 8),
                            ...student.skills.map(
                              (skill) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        skill.label,
                                        style:
                                            const TextStyle(color: _coachMuted),
                                      ),
                                    ),
                                    Text(
                                      '${skill.rating}/5',
                                      style: const TextStyle(
                                        color: _coachText,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ElevatedButton(
                                  style: _buttonStyle(),
                                  onPressed: () => _showPerformanceNoteDialog(
                                    context,
                                    student.name,
                                  ),
                                  child: const Text('Add Performance Note'),
                                ),
                                OutlinedButton(
                                  onPressed: () => _showHealthIssueDialog(
                                    context,
                                    student.name,
                                  ),
                                  child: const Text('Record Injury'),
                                ),
                                OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('Send Message to Parent'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _Panel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attendance ${student.attendancePercent}%',
                              style: const TextStyle(
                                color: _coachText,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Last ${student.attendanceHistory.length} sessions',
                              style: const TextStyle(color: _coachMuted),
                            ),
                            const SizedBox(height: 12),
                            ...student.attendanceHistory.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${entry.date} - ${entry.batch}',
                                        style:
                                            const TextStyle(color: _coachText),
                                      ),
                                    ),
                                    Text(
                                      entry.status,
                                      style:
                                          const TextStyle(color: _coachMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          style: _buttonStyle(),
                          onPressed: () =>
                              _showPerformanceNoteDialog(context, student.name),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add Note'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...student.performanceNotes.map(
                        (note) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _Panel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note.date,
                                  style: const TextStyle(color: _coachMuted),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  note.note,
                                  style: const TextStyle(color: _coachText),
                                ),
                                if (note.rating != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Rating ${note.rating}/10',
                                    style:
                                        const TextStyle(color: _coachSoftRed),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (student.performanceNotes.isEmpty)
                        const _Panel(
                          child: Text(
                            'No notes yet',
                            style: TextStyle(color: _coachMuted),
                          ),
                        ),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          style: _buttonStyle(),
                          onPressed: () =>
                              _showHealthIssueDialog(context, student.name),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Log Issue'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...student.healthNotes.map(
                        (note) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _Panel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(note.date,
                                    style: const TextStyle(color: _coachMuted)),
                                const SizedBox(height: 8),
                                Text(
                                  note.description,
                                  style: const TextStyle(color: _coachText),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${note.severity} - ${note.status}',
                                  style: const TextStyle(color: _coachSoftRed),
                                ),
                                Text(
                                  note.followUpRequired
                                      ? 'Follow-up required'
                                      : 'No follow-up required',
                                  style: const TextStyle(color: _coachMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (student.healthNotes.isEmpty)
                        const _Panel(
                          child: Text(
                            'No health incidents logged',
                            style: TextStyle(color: _coachMuted),
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
}

class CoachAttendanceScreen extends StatelessWidget {
  const CoachAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: _CoachShell(
        title: 'Attendance',
        bottomIndex: 3,
        appBarBottom: const TabBar(
          tabs: [
            Tab(text: 'By Student'),
            Tab(text: 'By Session'),
          ],
        ),
        child: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle('Attendance Summary'),
                      SizedBox(height: 12),
                      _InfoRow('Overall attendance', '87%'),
                      _InfoRow('Sessions conducted', '42'),
                      _InfoRow('Student-sessions', '504'),
                      _InfoRow('Absences', '65'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ...coachStudents.map(
                  (student) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _Panel(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.name,
                                  style: const TextStyle(
                                    color: _coachText,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(student.batch,
                                    style: const TextStyle(color: _coachMuted)),
                              ],
                            ),
                          ),
                          Text(
                            '${student.attendancePercent}%',
                            style: const TextStyle(
                              color: _coachSoftRed,
                              fontWeight: FontWeight.w900,
                            ),
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
                ...coachSessions.map(
                  (session) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _Panel(
                      onTap: () => context.push(
                        '${AppRoutes.coachSessions}/${session.id}',
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.batchName,
                                  style: const TextStyle(
                                    color: _coachText,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${session.dateLabel} - ${session.timeRange}',
                                  style: const TextStyle(color: _coachMuted),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${session.studentCount}/${session.capacity}',
                            style: const TextStyle(color: _coachSoftRed),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: _buttonStyle(),
                  onPressed: () {},
                  child: const Text('Download Report (PDF/Excel)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CoachTrainingPlansScreen extends StatelessWidget {
  const CoachTrainingPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CoachShell(
      title: 'Training Plans',
      bottomIndex: 4,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '5 Plans',
                  style: TextStyle(
                    color: _coachText,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              ElevatedButton.icon(
                style: _buttonStyle(),
                onPressed: () => context.push(AppRoutes.coachTrainingForm),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Training Plan'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _Panel(
            child: Column(
              children: [
                _DropdownField(label: 'Batch', value: 'All batches'),
                _DropdownField(label: 'Status', value: 'Active'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...coachTrainingPlans.map(
            (plan) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _Panel(
                onTap: () =>
                    context.push('${AppRoutes.coachTraining}/${plan.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plan.name,
                            style: const TextStyle(
                              color: _coachText,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        _StatusChip(plan.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(plan.sport,
                        style: const TextStyle(color: _coachMuted)),
                    Text(
                      plan.targetBatches.join(', '),
                      style: const TextStyle(color: _coachMuted),
                    ),
                    Text(
                      plan.duration,
                      style: const TextStyle(color: _coachMuted),
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

class CoachTrainingPlanDetailScreen extends StatelessWidget {
  const CoachTrainingPlanDetailScreen({super.key, required this.planId});

  final String planId;

  @override
  Widget build(BuildContext context) {
    final plan = coachTrainingPlans.firstWhere(
      (item) => item.id == planId,
      orElse: () => coachTrainingPlans.first,
    );
    return _CoachShell(
      title: 'Training Plan Detail',
      bottomIndex: 4,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.name,
                        style: const TextStyle(
                          color: _coachText,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _StatusChip(plan.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(plan.sport, style: const TextStyle(color: _coachMuted)),
                Text(
                  plan.targetBatches.join(', '),
                  style: const TextStyle(color: _coachMuted),
                ),
                Text(
                  '${plan.startDate} - ${plan.endDate}',
                  style: const TextStyle(color: _coachMuted),
                ),
                const SizedBox(height: 12),
                Text(plan.objective, style: const TextStyle(color: _coachText)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      style: _buttonStyle(),
                      onPressed: () =>
                          context.push(AppRoutes.coachTrainingForm),
                      child: const Text('Edit Plan'),
                    ),
                    OutlinedButton(
                        onPressed: () {}, child: const Text('Duplicate')),
                    OutlinedButton(
                        onPressed: () {}, child: const Text('Archive')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...plan.weeks.map(
            (week) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                backgroundColor: _coachCard,
                collapsedBackgroundColor: _coachCard,
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: _coachBorder),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: _coachBorder),
                ),
                title: Text(
                  week.title,
                  style: const TextStyle(
                      color: _coachText, fontWeight: FontWeight.w800),
                ),
                children: week.sessions
                    .map(
                      (session) => ListTile(
                        title: Text(
                          session.name,
                          style: const TextStyle(color: _coachText),
                        ),
                        subtitle: Text(
                          '${session.durationMinutes} min - ${session.drills.join(', ')}',
                          style: const TextStyle(color: _coachMuted),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Assigned Students'),
                const SizedBox(height: 12),
                ...coachStudents.take(4).map(
                      (student) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(student.name,
                            style: const TextStyle(color: _coachMuted)),
                      ),
                    ),
                const SizedBox(height: 12),
                const _SectionTitle('Drills Used'),
                const SizedBox(height: 10),
                ...plan.drillsUsed.map(
                  (drill) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child:
                        Text(drill, style: const TextStyle(color: _coachMuted)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CoachTrainingPlanFormScreen extends StatelessWidget {
  const CoachTrainingPlanFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CoachShell(
      title: 'Create Training Plan',
      bottomIndex: 4,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Plan Information'),
                const SizedBox(height: 12),
                const _Field(label: 'Plan name*'),
                const _DropdownField(label: 'Sport type*', value: 'Cricket'),
                const _Field(label: 'Objective*', maxLines: 4),
                const SizedBox(height: 16),
                const _SectionTitle('Target Batches'),
                const SizedBox(height: 12),
                const _DropdownField(
                    label: 'Batches*', value: 'Batch A1, Batch B2'),
                const SizedBox(height: 16),
                const _SectionTitle('Duration'),
                const SizedBox(height: 12),
                const _Field(label: 'Start date*', initialValue: '01 Apr 2026'),
                const _Field(label: 'End date*', initialValue: '27 May 2026'),
                const _Field(label: 'Frequency', initialValue: '2'),
                const SizedBox(height: 16),
                const _SectionTitle('Plan Structure'),
                const SizedBox(height: 12),
                const _Field(label: 'Week 1 title', initialValue: 'Foundation'),
                const _Field(
                    label: 'Session name', initialValue: 'Basic Footwork'),
                const _Field(label: 'Duration (minutes)', initialValue: '45'),
                const _DropdownField(
                  label: 'Drills',
                  value: 'Ball Control Drill, Passing Accuracy Drill',
                ),
                const _Field(label: 'Coach notes', maxLines: 3),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: _buttonStyle(),
                        onPressed: () => context.pop(),
                        child: const Text('Save Plan'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Save as Draft'),
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

class CoachEarningsScreen extends StatelessWidget {
  const CoachEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CoachShell(
      title: 'Earnings',
      bottomIndex: 5,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DropdownField(label: 'Month / Year', value: 'Apr 2026'),
                SizedBox(height: 12),
                _InfoRow('Base salary', 'Rs 20,000'),
                _InfoRow('Sessions conducted', 'Rs 5,000'),
                _InfoRow('Performance bonus', 'Rs 1,000'),
                _InfoRow('Deductions', 'Rs -1,000'),
                Divider(color: _coachBorder),
                _InfoRow('Net earning', 'Rs 25,000'),
                _InfoRow('Status', 'Pending'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle('Payment Status'),
                SizedBox(height: 12),
                Text(
                  'Payment expected by 30 Apr 2026',
                  style: TextStyle(color: _coachMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('History'),
                const SizedBox(height: 12),
                ...coachEarningHistory.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.month,
                            style: const TextStyle(color: _coachText),
                          ),
                        ),
                        Text(
                          coachMoney(entry.amount),
                          style: const TextStyle(color: _coachMuted),
                        ),
                        const SizedBox(width: 12),
                        _StatusChip(entry.status),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      style: _buttonStyle(),
                      onPressed: () {},
                      child: const Text('Download Current Slip'),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Download All Slips'),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Request Early Payment'),
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

class CoachSettingsScreen extends ConsumerWidget {
  const CoachSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _CoachShell(
      title: 'Coach Settings',
      bottomIndex: 5,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle('Account Information'),
                SizedBox(height: 12),
                _InfoRow('Name', coachName),
                _InfoRow('DOB', '14 Jun 1991'),
                _InfoRow('Phone', '+91 98765 43210'),
                _InfoRow('Email', 'rohan@swingacademy.in'),
                _InfoRow('Specialization', 'Cricket, Fitness'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle('Availability'),
                SizedBox(height: 12),
                _InfoRow('Work days', 'Mon-Sat'),
                _InfoRow('Hours', '5:00 PM - 9:00 PM'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle('Bank Details'),
                SizedBox(height: 12),
                _InfoRow('Account', 'XXXXXX8901'),
                _InfoRow('Bank', 'HDFC Bank'),
                _InfoRow('IFSC', 'HDFC0001234'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle('Subscription Plan'),
                SizedBox(height: 12),
                _InfoRow('Current plan', coachPlan),
                Text(
                  'Session reminders, earnings view, student updates',
                  style: TextStyle(color: _coachMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle('Notifications'),
                SizedBox(height: 12),
                Text('Session reminders', style: TextStyle(color: _coachText)),
                SizedBox(height: 8),
                Text('Payment notifications',
                    style: TextStyle(color: _coachText)),
                SizedBox(height: 8),
                Text('Student updates', style: TextStyle(color: _coachText)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle('App Preferences'),
                SizedBox(height: 12),
                _InfoRow('Language', 'English'),
                _InfoRow('Theme', 'Dark'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Help & Support'),
                const SizedBox(height: 12),
                const Text('View Help Center',
                    style: TextStyle(color: _coachText)),
                const SizedBox(height: 8),
                const Text('Contact Support',
                    style: TextStyle(color: _coachText)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: _buttonStyle(),
                    onPressed: () async =>
                        ref.read(sessionControllerProvider.notifier).signOut(),
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachShell extends StatelessWidget {
  const _CoachShell({
    required this.title,
    required this.child,
    required this.bottomIndex,
    this.appBarBottom,
  });

  final String title;
  final Widget child;
  final int bottomIndex;
  final PreferredSizeWidget? appBarBottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _coachBg,
      appBar: AppBar(
        backgroundColor: _coachBg,
        foregroundColor: _coachText,
        title: Text(title),
        bottom: appBarBottom,
      ),
      body: child,
      bottomNavigationBar: _CoachBottomNav(index: bottomIndex),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        children: [
          const _SoftCircleIcon(Icons.sports_rounded, size: 52),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Welcome back, Rohan',
                  style: TextStyle(
                    color: _coachText,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '23 Apr 2026 - 6:30 PM',
                  style: TextStyle(color: _coachMuted),
                ),
                SizedBox(height: 6),
                Text(
                  '3 sessions today',
                  style: TextStyle(color: _coachSoftRed),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionOverviewTile extends StatelessWidget {
  const _SessionOverviewTile({required this.session});

  final CoachDashboardSession session;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      onTap: () => context.push('${AppRoutes.coachSessions}/${session.id}'),
      child: Row(
        children: [
          _SoftCircleIcon(session.icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.batchName,
                  style: const TextStyle(
                    color: _coachText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.startLabel} - ${session.endLabel} - ${session.studentCount} students',
                  style: const TextStyle(color: _coachMuted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: _coachMuted),
        ],
      ),
    );
  }
}

class _CoachSessionCard extends StatelessWidget {
  const _CoachSessionCard({required this.session});

  final CoachDashboardSession session;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${session.batchName} - ${session.sport}',
                  style: const TextStyle(
                    color: _coachText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _StatusChip(coachSessionStateLabel(session.state)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${session.timeRange} - ${session.location}',
            style: const TextStyle(color: _coachMuted),
          ),
          const SizedBox(height: 4),
          Text(
            'Students enrolled: ${session.studentCount} / ${session.capacity}',
            style: const TextStyle(color: _coachMuted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (session.state == CoachSessionState.upcoming)
                ElevatedButton(
                  style: _buttonStyle(),
                  onPressed: () =>
                      context.push('${AppRoutes.coachSessions}/${session.id}'),
                  child: const Text('Start Session'),
                ),
              if (session.state == CoachSessionState.live) ...[
                ElevatedButton(
                  style: _buttonStyle(),
                  onPressed: () =>
                      context.push('${AppRoutes.coachSessions}/${session.id}'),
                  child: const Text('View Attendance'),
                ),
                OutlinedButton(
                    onPressed: () {}, child: const Text('End Session')),
              ],
              if (session.state == CoachSessionState.completed) ...[
                OutlinedButton(
                  onPressed: () =>
                      context.push('${AppRoutes.coachSessions}/${session.id}'),
                  child: const Text('View Report'),
                ),
                OutlinedButton(
                    onPressed: () {}, child: const Text('Edit Report')),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CoachBottomNav extends StatelessWidget {
  const _CoachBottomNav({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavTarget('Home', Icons.home_rounded, AppRoutes.coachHome),
      _NavTarget('Sessions', Icons.event_rounded, AppRoutes.coachSessions),
      _NavTarget('Students', Icons.groups_rounded, AppRoutes.coachStudents),
      _NavTarget(
          'Attendance', Icons.fact_check_rounded, AppRoutes.coachAttendance),
      _NavTarget(
          'Training', Icons.fitness_center_rounded, AppRoutes.coachTraining),
      _NavTarget('Earnings', Icons.payments_rounded, AppRoutes.coachEarnings),
      _NavTarget('Settings', Icons.settings_rounded, AppRoutes.coachSettings),
    ];
    return NavigationBar(
      backgroundColor: _coachCard,
      indicatorColor: _coachRed.withValues(alpha: .25),
      selectedIndex: index,
      destinations: items
          .map(
            (item) => NavigationDestination(
              icon: Icon(item.icon, color: _coachMuted),
              selectedIcon: Icon(item.icon, color: Colors.white),
              label: item.label,
            ),
          )
          .toList(),
      onDestinationSelected: (selected) => context.go(items[selected].route),
    );
  }
}

class _NavTarget {
  const _NavTarget(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SoftCircleIcon(icon),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: _coachText,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: _coachMuted)),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _coachCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _coachBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return container;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: container,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: _coachText,
        fontWeight: FontWeight.w900,
        fontSize: 16,
      ),
    );
  }
}

class _SoftCircleIcon extends StatelessWidget {
  const _SoftCircleIcon(this.icon, {this.size = 42});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _coachRed.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: _coachSoftRed, size: size * .5),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: _coachMuted)),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style:
                const TextStyle(color: _coachText, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final lower = label.toLowerCase();
    final color = lower.contains('active') ||
            lower.contains('paid') ||
            lower.contains('now')
        ? const Color(0xFF1DB954)
        : lower.contains('draft') || lower.contains('pending')
            ? _coachSoftRed
            : _coachMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    this.initialValue,
    this.maxLines = 1,
  });

  final String label;
  final String? initialValue;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initialValue,
        maxLines: maxLines,
        style: const TextStyle(color: _coachText),
        decoration: _inputDecoration(label),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InputDecorator(
        decoration: _inputDecoration(label),
        child: Row(
          children: [
            Expanded(
              child: Text(value, style: const TextStyle(color: _coachText)),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: _coachMuted),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: _coachMuted),
    filled: true,
    fillColor: _coachBg,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _coachBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _coachSoftRed),
    ),
  );
}

ButtonStyle _buttonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: _coachRed,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}

String _attendanceLabel(AttendanceMark mark) {
  return switch (mark) {
    AttendanceMark.present => 'Present',
    AttendanceMark.absent => 'Absent',
    AttendanceMark.late => 'Late',
  };
}

Future<void> _showPerformanceNoteDialog(
    BuildContext context, String studentName) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: _coachCard,
      title: const Text('Add Performance Note',
          style: TextStyle(color: _coachText)),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Field(label: 'Student', initialValue: studentName),
              const _Field(label: 'Date', initialValue: '23 Apr 2026'),
              const _DropdownField(label: 'Technical skills', value: '4 / 5'),
              const _DropdownField(label: 'Physical fitness', value: '3 / 5'),
              const _DropdownField(label: 'Tactical awareness', value: '4 / 5'),
              const _DropdownField(label: 'Teamwork', value: '5 / 5'),
              const _Field(
                label: 'Coach notes',
                maxLines: 4,
                initialValue:
                    'Excellent improvement in accuracy. Needs to work on stamina.',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: _buttonStyle(),
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Note added for $studentName')),
            );
          },
          child: const Text('Save Note'),
        ),
      ],
    ),
  );
}

Future<void> _showHealthIssueDialog(BuildContext context, String studentName) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: _coachCard,
      title: const Text('Log Injury / Health Issue',
          style: TextStyle(color: _coachText)),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Field(label: 'Student', initialValue: studentName),
              const _Field(
                  label: 'Date of incident', initialValue: '23 Apr 2026'),
              const _DropdownField(label: 'Type', value: 'Injury'),
              const _Field(label: 'Description', maxLines: 3),
              const _DropdownField(label: 'Severity', value: 'Minor'),
              const _Field(label: 'Affected area', initialValue: 'Right ankle'),
              const _DropdownField(
                label: 'Requires medical attention?',
                value: 'No',
              ),
              const _DropdownField(label: 'Status', value: 'Ongoing'),
              const _Field(label: 'Follow-up date'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: _buttonStyle(),
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Health issue logged for $studentName')),
            );
          },
          child: const Text('Log Issue'),
        ),
      ],
    ),
  );
}
