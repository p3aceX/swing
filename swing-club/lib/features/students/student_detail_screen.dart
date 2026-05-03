import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets.dart';
import '../fees/record_payment_sheet.dart';
import 'student_provider.dart';

class StudentDetailScreen extends ConsumerWidget {
  final String enrollmentId;

  const StudentDetailScreen({super.key, required this.enrollmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studentDetailProvider(enrollmentId));

    return Scaffold(
      appBar: AppBar(
        title: state.maybeWhen(
          data: (e) {
            final user = e['user'] as Map<String, dynamic>? ?? {};
            return Text(user['name'] as String? ?? 'Student');
          },
          orElse: () => const Text('Student'),
        ),
      ),
      body: state.when(
        loading: loadingBody,
        error: (e, _) =>
            errorBody(e, () => ref.invalidate(studentDetailProvider(enrollmentId))),
        data: (enrollment) => _StudentBody(enrollment: enrollment, enrollmentId: enrollmentId),
      ),
    );
  }
}

class _StudentBody extends ConsumerStatefulWidget {
  final Map<String, dynamic> enrollment;
  final String enrollmentId;

  const _StudentBody({required this.enrollment, required this.enrollmentId});

  @override
  ConsumerState<_StudentBody> createState() => _StudentBodyState();
}

class _StudentBodyState extends ConsumerState<_StudentBody> {
  @override
  Widget build(BuildContext context) {
    final e = widget.enrollment;
    final user = e['user'] as Map<String, dynamic>? ?? {};
    final batch = e['batch'] as Map<String, dynamic>? ?? {};

    return ListView(
      children: [
        _Section(
          title: 'Profile',
          children: [
            _InfoRow('Name', user['name'] as String? ?? '—'),
            _InfoRow('Phone', user['phone'] as String? ?? '—'),
            _InfoRow('Batch', batch['name'] as String? ?? '—'),
            _InfoRow('Status', e['enrollmentStatus'] as String? ?? '—'),
            if (e['isTrial'] == true) _InfoRow('Trial', 'Yes'),
            if (e['bloodGroup'] != null) _InfoRow('Blood Group', e['bloodGroup'] as String),
            if (e['dateOfBirth'] != null) _InfoRow('DOB', e['dateOfBirth'] as String),
            if (e['city'] != null) _InfoRow('City', e['city'] as String),
            if (e['emergencyContactName'] != null)
              _InfoRow('Emergency', '${e['emergencyContactName']} · ${e['emergencyContactPhone'] ?? ''}'),
          ],
        ),
        const Divider(height: 1),
        _Section(
          title: 'Fee Status',
          trailing: statusBadge(e['feeStatus'] as String? ?? 'PENDING'),
          children: [
            _InfoRow('Amount', rupeesFromPaise(e['feeAmountPaise'])),
            _InfoRow('Frequency', e['feeFrequency'] as String? ?? '—'),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                    builder: (_) => RecordPaymentSheet(prefillEnrollmentId: widget.enrollmentId),
                  ),
                  child: const Text('Record Payment'),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        _Section(
          title: 'Actions',
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mark as Inactive'),
              leading: const Icon(Icons.pause_circle_outline, color: Colors.grey),
              onTap: () => _updateStatus('INACTIVE'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mark as Paused'),
              leading: const Icon(Icons.pause_outlined, color: Colors.grey),
              onTap: () => _updateStatus('PAUSED'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _updateStatus(String status) async {
    try {
      await ref.read(studentsProvider.notifier).updateEnrollment(
        widget.enrollmentId,
        {'enrollmentStatus': status},
      );
      if (mounted) {
        ref.invalidate(studentDetailProvider(widget.enrollmentId));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) showSnack(context, 'Failed to update status');
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final List<Widget> children;

  const _Section({required this.title, this.trailing, required this.children});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 13, color: Colors.grey,
                        fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: children),
          ),
        ],
      );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ),
            Expanded(
              child: Text(value, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
      );
}
