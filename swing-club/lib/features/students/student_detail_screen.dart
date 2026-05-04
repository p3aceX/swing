import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/widgets.dart';
import '../fees/record_payment_sheet.dart';
import 'student_provider.dart';

const _kNavy   = Color(0xFF071B3D);
const _kBorder = Color(0xFFE0DED6);

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
    final state = ref.watch(studentDetailProvider(widget.enrollmentId));

    final name = state.maybeWhen(
      data: (e) {
        final p = (e['playerProfile'] ?? e['user']) as Map<String, dynamic>? ?? {};
        return (p['name'] ?? p['username']) as String? ?? 'Student';
      },
      orElse: () => 'Student',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        bottom: TabBar(
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: _recordPayment,
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
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

String _fmt(String s) => s
    .split(RegExp(r'[_\s]'))
    .map((w) => w.isEmpty
        ? ''
        : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
    .join(' ');

Widget _infoCard(List<Widget> rows) => Container(
  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: _kBorder),
  ),
  child: Column(
    children: List.generate(rows.length, (i) => Column(children: [
      rows[i],
      if (i < rows.length - 1) const Divider(height: 1, indent: 16),
    ])),
  ),
);

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(children: [
      SizedBox(
        width: 110,
        child: Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ),
      Expanded(
        child: Text(value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: _kNavy)),
      ),
    ]),
  );
}

class _InfoRowWidget extends StatelessWidget {
  final String label;
  final Widget child;

  const _InfoRowWidget(this.label, this.child);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(children: [
      SizedBox(
        width: 110,
        child: Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ),
      child,
    ]),
  );
}

Widget _sectionLabel(String text) => Padding(
  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
  child: Text(text.toUpperCase(),
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey,
          letterSpacing: 0.8)),
);

// ── Tab: Profile ───────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  final Map<String, dynamic> enrollment;

  const _ProfileTab({required this.enrollment});

  @override
  Widget build(BuildContext context) {
    final p = (enrollment['playerProfile'] ?? enrollment['user'])
            as Map<String, dynamic>? ?? {};

    final name    = (p['name']  ?? p['username']) as String? ?? '—';
    final phone   = p['phone']  as String? ?? '';
    final gender  = p['gender'] as String? ?? '';
    final dob     = (p['dateOfBirth'] as String? ?? '').split('T').first;
    final city    = p['city']   as String? ?? '';
    final stateV  = p['state']  as String? ?? '';
    final blood   = enrollment['bloodGroup'] as String? ?? '';

    final personalRows = <Widget>[
      if (phone.isNotEmpty)
        _InfoRowWidget('Phone', Row(children: [
          Text(phone, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _kNavy)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => launchUrl(Uri.parse('tel:$phone'),
                mode: LaunchMode.externalApplication),
            child: const Icon(Icons.call_rounded, size: 18, color: Color(0xFF2E7D32)),
          ),
        ])),
      if (gender.isNotEmpty) _InfoRow('Gender',  _fmt(gender)),
      if (dob.isNotEmpty)    _InfoRow('DOB',     dob),
      if (city.isNotEmpty || stateV.isNotEmpty)
        _InfoRow('Location', [city, stateV].where((s) => s.isNotEmpty).join(', ')),
      if (blood.isNotEmpty)  _InfoRow('Blood Group', blood),
    ];

    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 120),
      children: [
        Center(
          child: Column(children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: _kNavy.withOpacity(0.1),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: _kNavy, fontWeight: FontWeight.w800, fontSize: 26),
              ),
            ),
            const SizedBox(height: 10),
            Text(name,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: _kNavy)),
            const SizedBox(height: 16),
          ]),
        ),
        if (personalRows.isNotEmpty) ...[
          _sectionLabel('Personal'),
          _infoCard(personalRows),
        ],
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
    final p = (enrollment['playerProfile'] ?? enrollment['user'])
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sports_cricket_rounded,
                  size: 56, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text(
                'Cricket profile not updated',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ask the player to download the\nSwing – Player App to update their profile.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF071B3D).withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'swing-player-app',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF071B3D),
                      letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 120),
      children: [
        _sectionLabel('Cricket Profile'),
        _infoCard([
          if (role.isNotEmpty)    _InfoRow('Role',    _fmt(role)),
          if (batting.isNotEmpty) _InfoRow('Batting', _fmt(batting)),
          if (bowling.isNotEmpty) _InfoRow('Bowling', _fmt(bowling)),
          if (level.isNotEmpty)   _InfoRow('Level',   _fmt(level)),
          if (jersey != null)     _InfoRow('Jersey',  '#$jersey'),
        ]),
        if (goals.isNotEmpty) ...[
          _sectionLabel('Goals'),
          _infoCard([_InfoRow('', goals)]),
        ],
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
    final batch   = enrollment['batch'] as Map<String, dynamic>? ?? {};
    final regNo   = enrollment['registrationNo']   as String? ?? '';
    final status  = enrollment['enrollmentStatus'] as String? ?? '';
    final isTrial = enrollment['isTrial'] == true;
    final trialEnds = (enrollment['trialEndsAt'] as String? ?? '').split('T').first;
    final enrolledAt = (enrollment['enrolledAt'] as String? ?? '').split('T').first;

    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 120),
      children: [
        _sectionLabel('Enrollment'),
        _infoCard([
          if (regNo.isNotEmpty)         _InfoRow('Reg. No.',   regNo),
          _InfoRowWidget('Status', statusBadge(status)),
          if (batch['name'] != null)    _InfoRow('Batch',      batch['name'] as String),
          _InfoRow('Type', isTrial ? 'Trial' : 'Full Member'),
          if (isTrial && trialEnds.isNotEmpty)
            _InfoRow('Trial Ends', trialEnds),
          if (enrolledAt.isNotEmpty)    _InfoRow('Enrolled On', enrolledAt),
        ]),
      ],
    );
  }
}

// ── Tab: Fees ──────────────────────────────────────────────────────────────────

class _FeesTab extends StatelessWidget {
  final Map<String, dynamic> enrollment;

  const _FeesTab({required this.enrollment});

  @override
  Widget build(BuildContext context) {
    final feeStatus = enrollment['feeStatus']     as String? ?? '';
    final freq      = enrollment['feeFrequency']  as String? ?? '';

    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 120),
      children: [
        _sectionLabel('Fee Details'),
        _infoCard([
          _InfoRowWidget('Status',    statusBadge(feeStatus)),
          _InfoRow('Amount',    rupeesFromPaise(enrollment['feeAmountPaise'])),
          if (freq.isNotEmpty) _InfoRow('Frequency', _fmt(freq)),
        ]),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            'Tap "Record Payment" below to log a payment for this student.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
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
    final parentName    = enrollment['parentName']    as String? ?? '';
    final parentPhone   = enrollment['parentPhone']   as String? ?? '';
    final parentRelation = enrollment['parentRelation'] as String? ?? '';
    final aadhaar       = enrollment['aadhaarNumber'] as String? ?? '';
    final emergName     = enrollment['emergencyContactName']  as String? ?? '';
    final emergPhone    = enrollment['emergencyContactPhone'] as String? ?? '';
    final enrollmentId  = enrollment['id'] as String? ?? '';

    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 120),
      children: [
        if (parentName.isNotEmpty || parentPhone.isNotEmpty) ...[
          _sectionLabel('Parent / Guardian'),
          _infoCard([
            if (parentRelation.isNotEmpty) _InfoRow('Relation', parentRelation),
            if (parentName.isNotEmpty)     _InfoRow('Name',     parentName),
            if (parentPhone.isNotEmpty)
              _InfoRowWidget('Phone', Row(children: [
                Text(parentPhone,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: _kNavy)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse('tel:$parentPhone'),
                      mode: LaunchMode.externalApplication),
                  child: const Icon(Icons.call_rounded,
                      size: 18, color: Color(0xFF2E7D32)),
                ),
              ])),
          ]),
        ],

        if (aadhaar.isNotEmpty) ...[
          _sectionLabel('Identity'),
          _infoCard([_InfoRow('Aadhaar', aadhaar)]),
        ],

        if (emergName.isNotEmpty || emergPhone.isNotEmpty) ...[
          _sectionLabel('Emergency Contact'),
          _infoCard([
            if (emergName.isNotEmpty)  _InfoRow('Name',  emergName),
            if (emergPhone.isNotEmpty)
              _InfoRowWidget('Phone', Row(children: [
                Text(emergPhone,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: _kNavy)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse('tel:$emergPhone'),
                      mode: LaunchMode.externalApplication),
                  child: const Icon(Icons.call_rounded,
                      size: 18, color: Color(0xFF2E7D32)),
                ),
              ])),
          ]),
        ],

        if (enrollmentId.isNotEmpty) ...[
          _sectionLabel('Actions'),
          _infoCard([
            _ActionTile(
              icon: Icons.pause_circle_outline,
              label: 'Mark as Inactive',
              onTap: () => _updateStatus(context, ref, enrollmentId, 'INACTIVE'),
            ),
            _ActionTile(
              icon: Icons.pause_outlined,
              label: 'Mark as Paused',
              onTap: () => _updateStatus(context, ref, enrollmentId, 'PAUSED'),
            ),
          ]),
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
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    leading: Icon(icon, color: Colors.grey, size: 20),
    title: Text(label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    onTap: onTap,
    visualDensity: VisualDensity.compact,
  );
}
