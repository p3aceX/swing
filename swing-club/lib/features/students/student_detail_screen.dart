import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/widgets.dart';
import '../fees/record_payment_sheet.dart';
import 'student_provider.dart';

class StudentDetailScreen extends ConsumerStatefulWidget {
  final String enrollmentId;
  const StudentDetailScreen({super.key, required this.enrollmentId});

  @override
  ConsumerState<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends ConsumerState<StudentDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 5, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _recordPayment() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => RecordPaymentSheet(prefillEnrollmentId: widget.enrollmentId),
      ).then((_) => ref.invalidate(studentDetailProvider(widget.enrollmentId)));

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = Theme.of(context).scaffoldBackgroundColor;

    final state = ref.watch(studentDetailProvider(widget.enrollmentId));

    final name = state.maybeWhen(
      data: (e) {
        final p = (e['playerProfile'] ?? e['user']) as Map<String, dynamic>? ?? {};
        return (p['name'] ?? p['username']) as String? ?? 'Student';
      },
      orElse: () => 'Student',
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: cs.onSurface,
          titleSpacing: 0,
          title: Text(name,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
                letterSpacing: -0.3,
              )),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(49),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                  controller: _tabs,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: const [
                    Tab(text: 'Profile'),
                    Tab(text: 'Cricket'),
                    Tab(text: 'Enrollment'),
                    Tab(text: 'Fees'),
                    Tab(text: 'More'),
                  ],
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: cs.onSurface.withValues(alpha: 0.08),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: null,
          onPressed: _recordPayment,
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          icon: const Icon(Icons.payment_rounded),
          label: const Text('Record Payment',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        body: state.when(
          loading: loadingBody,
          error: (e, _) => errorBody(
              e, () => ref.invalidate(studentDetailProvider(widget.enrollmentId))),
          data: (enrollment) => TabBarView(
            controller: _tabs,
            children: [
              _ProfileTab(enrollment: enrollment),
              _CricketTab(enrollment: enrollment),
              _EnrollmentTab(enrollment: enrollment),
              _FeesTab(enrollment: enrollment),
              _MoreTab(enrollment: enrollment),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

String _fmt(String s) => s
    .split(RegExp(r'[_\s]'))
    .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
    .join(' ');

class _Section extends StatelessWidget {
  final String label;
  final List<_InfoRow> rows;
  const _Section({required this.label, required this.rows});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
          child: Text(label.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurface.withValues(alpha: 0.4),
                letterSpacing: 0.8,
              )),
        ),
        ...List.generate(rows.length, (i) => Column(children: [
          rows[i],
          if (i < rows.length - 1)
            Divider(
              height: 1,
              thickness: 0.5,
              indent: 20,
              color: cs.onSurface.withValues(alpha: 0.07),
            ),
        ])),
        Divider(height: 1, thickness: 0.5,
            color: cs.onSurface.withValues(alpha: 0.07)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? child;

  const _InfoRow(this.label, {this.value, this.child})
      : assert(value != null || child != null);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: Row(children: [
        SizedBox(
          width: 112,
          child: Text(label,
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.45),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              )),
        ),
        Expanded(
          child: value != null
              ? Text(value!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ))
              : child!,
        ),
      ]),
    );
  }
}

// ── Tab: Profile ───────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  final Map<String, dynamic> enrollment;
  const _ProfileTab({required this.enrollment});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final p  = (enrollment['playerProfile'] ?? enrollment['user'])
            as Map<String, dynamic>? ?? {};

    final name   = (p['name']  ?? p['username']) as String? ?? '—';
    final phone  = p['phone']  as String? ?? '';
    final gender = p['gender'] as String? ?? '';
    final dob    = (p['dateOfBirth'] as String? ?? '').split('T').first;
    final city   = p['city']   as String? ?? '';
    final stateV = p['state']  as String? ?? '';
    final blood  = enrollment['bloodGroup'] as String? ?? '';
    final color  = _nameColor(name);

    final rows = <_InfoRow>[
      if (phone.isNotEmpty)
        _InfoRow('Phone', child: Row(children: [
          Text(phone,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                  color: cs.onSurface)),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => launchUrl(Uri.parse('tel:$phone'),
                mode: LaunchMode.externalApplication),
            child: Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                border: Border.all(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.3), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.call_rounded, size: 15,
                  color: Color(0xFF16A34A)),
            ),
          ),
        ])),
      if (gender.isNotEmpty) _InfoRow('Gender',     value: _fmt(gender)),
      if (dob.isNotEmpty)    _InfoRow('DOB',         value: dob),
      if (city.isNotEmpty || stateV.isNotEmpty)
        _InfoRow('Location', value: [city, stateV].where((s) => s.isNotEmpty).join(', ')),
      if (blood.isNotEmpty)  _InfoRow('Blood Group', value: blood),
    ];

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        const SizedBox(height: 28),
        Center(
          child: Column(children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 28),
              ),
            ),
            const SizedBox(height: 12),
            Text(name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                    color: cs.onSurface, letterSpacing: -0.3)),
            const SizedBox(height: 20),
          ]),
        ),
        if (rows.isNotEmpty) _Section(label: 'Personal', rows: rows),
      ],
    );
  }
}

// ── Tab: Cricket ──────────────────────────────────────────────────────────────

class _CricketTab extends StatelessWidget {
  final Map<String, dynamic> enrollment;
  const _CricketTab({required this.enrollment});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final p  = (enrollment['playerProfile'] ?? enrollment['user'])
            as Map<String, dynamic>? ?? {};

    final role    = p['playerRole']   as String? ?? '';
    final batting = p['battingStyle'] as String? ?? '';
    final bowling = p['bowlingStyle'] as String? ?? '';
    final level   = p['level']        as String? ?? '';
    final jersey  = p['jerseyNumber'] as dynamic;
    final goals   = p['goals']        as String? ?? '';

    final hasData = role.isNotEmpty || batting.isNotEmpty ||
        bowling.isNotEmpty || level.isNotEmpty || jersey != null;

    if (!hasData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.sports_cricket_rounded,
                size: 48, color: cs.onSurface.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text('Cricket profile not updated',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: cs.onSurface.withValues(alpha: 0.4))),
            const SizedBox(height: 8),
            Text('Ask the player to download the Swing – Player App to update their profile.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.5,
                    color: cs.onSurface.withValues(alpha: 0.35))),
          ]),
        ),
      );
    }

    final cricketRows = <_InfoRow>[
      if (role.isNotEmpty)    _InfoRow('Role',    value: _fmt(role)),
      if (batting.isNotEmpty) _InfoRow('Batting', value: _fmt(batting)),
      if (bowling.isNotEmpty) _InfoRow('Bowling', value: _fmt(bowling)),
      if (level.isNotEmpty)   _InfoRow('Level',   value: _fmt(level)),
      if (jersey != null)     _InfoRow('Jersey',  value: '#$jersey'),
    ];

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        _Section(label: 'Cricket Profile', rows: cricketRows),
        if (goals.isNotEmpty)
          _Section(label: 'Goals', rows: [_InfoRow('', value: goals)]),
      ],
    );
  }
}

// ── Tab: Enrollment ────────────────────────────────────────────────────────────

class _EnrollmentTab extends StatelessWidget {
  final Map<String, dynamic> enrollment;
  const _EnrollmentTab({required this.enrollment});

  @override
  Widget build(BuildContext context) {
    final batch      = enrollment['batch'] as Map<String, dynamic>? ?? {};
    final regNo      = enrollment['registrationNo']   as String? ?? '';
    final status     = enrollment['enrollmentStatus'] as String? ?? '';
    final isTrial    = enrollment['isTrial'] == true;
    final trialEnds  = (enrollment['trialEndsAt'] as String? ?? '').split('T').first;
    final enrolledAt = (enrollment['enrolledAt']  as String? ?? '').split('T').first;

    final rows = <_InfoRow>[
      if (regNo.isNotEmpty) _InfoRow('Reg. No.',    value: regNo),
      _InfoRow('Status', child: statusBadge(status)),
      if (batch['name'] != null) _InfoRow('Batch',  value: batch['name'] as String),
      _InfoRow('Type', value: isTrial ? 'Trial' : 'Full Member'),
      if (isTrial && trialEnds.isNotEmpty) _InfoRow('Trial Ends', value: trialEnds),
      if (enrolledAt.isNotEmpty) _InfoRow('Enrolled On', value: enrolledAt),
    ];

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [_Section(label: 'Enrollment', rows: rows)],
    );
  }
}

// ── Tab: Fees ──────────────────────────────────────────────────────────────────

class _FeesTab extends StatelessWidget {
  final Map<String, dynamic> enrollment;
  const _FeesTab({required this.enrollment});

  @override
  Widget build(BuildContext context) {
    final cs        = Theme.of(context).colorScheme;
    final feeStatus = enrollment['feeStatus']    as String? ?? '';
    final freq      = enrollment['feeFrequency'] as String? ?? '';

    final rows = <_InfoRow>[
      _InfoRow('Status',    child: statusBadge(feeStatus)),
      _InfoRow('Amount',    value: rupeesFromPaise(enrollment['feeAmountPaise'])),
      if (freq.isNotEmpty) _InfoRow('Frequency', value: _fmt(freq)),
    ];

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        _Section(label: 'Fee Details', rows: rows),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Text('Tap "Record Payment" below to log a payment for this student.',
              style: TextStyle(fontSize: 13,
                  color: cs.onSurface.withValues(alpha: 0.4), height: 1.5)),
        ),
      ],
    );
  }
}

// ── Tab: More ──────────────────────────────────────────────────────────────────

class _MoreTab extends ConsumerWidget {
  final Map<String, dynamic> enrollment;
  const _MoreTab({required this.enrollment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs             = Theme.of(context).colorScheme;
    final parentName     = enrollment['parentName']    as String? ?? '';
    final parentPhone    = enrollment['parentPhone']   as String? ?? '';
    final parentRelation = enrollment['parentRelation'] as String? ?? '';
    final aadhaar        = enrollment['aadhaarNumber'] as String? ?? '';
    final emergName      = enrollment['emergencyContactName']  as String? ?? '';
    final emergPhone     = enrollment['emergencyContactPhone'] as String? ?? '';
    final enrollmentId   = enrollment['id'] as String? ?? '';

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        if (parentName.isNotEmpty || parentPhone.isNotEmpty)
          _Section(label: 'Parent / Guardian', rows: [
            if (parentRelation.isNotEmpty) _InfoRow('Relation', value: parentRelation),
            if (parentName.isNotEmpty)     _InfoRow('Name',     value: parentName),
            if (parentPhone.isNotEmpty)
              _InfoRow('Phone', child: _PhoneRow(parentPhone, cs)),
          ]),

        if (aadhaar.isNotEmpty)
          _Section(label: 'Identity', rows: [_InfoRow('Aadhaar', value: aadhaar)]),

        if (emergName.isNotEmpty || emergPhone.isNotEmpty)
          _Section(label: 'Emergency Contact', rows: [
            if (emergName.isNotEmpty)  _InfoRow('Name',  value: emergName),
            if (emergPhone.isNotEmpty) _InfoRow('Phone', child: _PhoneRow(emergPhone, cs)),
          ]),

        if (enrollmentId.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            child: Text('ACTIONS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: cs.onSurface.withValues(alpha: 0.4), letterSpacing: 0.8)),
          ),
          _ActionTile(
            icon: Icons.pause_circle_outline,
            label: 'Mark as Inactive',
            onTap: () => _updateStatus(context, ref, enrollmentId, 'INACTIVE'),
          ),
          Divider(height: 1, thickness: 0.5,
              indent: 20, color: cs.onSurface.withValues(alpha: 0.07)),
          _ActionTile(
            icon: Icons.pause_outlined,
            label: 'Mark as Paused',
            onTap: () => _updateStatus(context, ref, enrollmentId, 'PAUSED'),
          ),
          Divider(height: 1, thickness: 0.5,
              color: cs.onSurface.withValues(alpha: 0.07)),
          _ActionTile(
            icon: Icons.person_off_rounded,
            label: 'Remove Student',
            color: const Color(0xFFDC2626),
            onTap: () => _confirmRemove(context, ref, enrollmentId),
          ),
          Divider(height: 1, thickness: 0.5,
              color: cs.onSurface.withValues(alpha: 0.07)),
        ],
      ],
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref,
      String enrollmentId, String status) async {
    try {
      await ref.read(studentsProvider.notifier)
          .updateEnrollment(enrollmentId, {'enrollmentStatus': status});
      if (context.mounted) {
        ref.invalidate(studentDetailProvider(enrollmentId));
        Navigator.pop(context);
      }
    } catch (_) {
      if (context.mounted) showSnack(context, 'Failed to update status');
    }
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref,
      String enrollmentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Student',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
            'This will remove the student from the academy. '
            'Their data will be retained but they will be marked inactive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626)),
            child: const Text('Remove', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _updateStatus(context, ref, enrollmentId, 'INACTIVE');
    }
  }
}

class _PhoneRow extends StatelessWidget {
  final String phone;
  final ColorScheme cs;
  const _PhoneRow(this.phone, this.cs);

  @override
  Widget build(BuildContext context) => Row(children: [
        Text(phone,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: cs.onSurface)),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => launchUrl(Uri.parse('tel:$phone'),
              mode: LaunchMode.externalApplication),
          child: Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              border: Border.all(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.3), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.call_rounded, size: 15, color: Color(0xFF16A34A)),
          ),
        ),
      ]);
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _ActionTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = color ?? cs.onSurface;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(icon, color: color ?? cs.onSurface.withValues(alpha: 0.45), size: 20),
      title: Text(label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: fg)),
      onTap: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}

// ── Helper ────────────────────────────────────────────────────────────────────

Color _nameColor(String name) {
  const colors = [
    Color(0xFF2563EB), Color(0xFF7C3AED), Color(0xFF059669),
    Color(0xFFEA580C), Color(0xFF0891B2), Color(0xFFDC2626),
  ];
  return colors[name.codeUnits.fold(0, (a, b) => a + b) % colors.length];
}
