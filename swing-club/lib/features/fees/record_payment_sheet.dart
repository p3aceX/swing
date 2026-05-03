import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../shared/widgets.dart';
import '../students/student_provider.dart';
import 'fee_provider.dart';

class RecordPaymentSheet extends ConsumerStatefulWidget {
  final String? prefillEnrollmentId;

  const RecordPaymentSheet({super.key, this.prefillEnrollmentId});

  @override
  ConsumerState<RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends ConsumerState<RecordPaymentSheet> {
  String? _enrollmentId;
  final _amountCtrl = TextEditingController();
  String _mode = kPaymentModes.first;
  final _notesCtrl = TextEditingController();
  DateTime _paidAt = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _enrollmentId = widget.prefillEnrollmentId;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _record() async {
    if (_enrollmentId == null) {
      showSnack(context, 'Select a student');
      return;
    }
    if (_amountCtrl.text.isEmpty) {
      showSnack(context, 'Enter an amount');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(paymentsProvider.notifier).recordPayment({
        'enrollmentId': _enrollmentId,
        'amountPaise': (double.tryParse(_amountCtrl.text) ?? 0) * 100,
        'paymentMode': _mode,
        if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text.trim(),
        'paidAt': _paidAt.toIso8601String(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showSnack(context, 'Failed to record payment');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentsState = ref.watch(studentsProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Record Payment',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.prefillEnrollmentId == null)
              studentsState.when(
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Failed to load students'),
                data: (students) => DropdownButtonFormField<String>(
                  value: _enrollmentId,
                  decoration: const InputDecoration(labelText: 'Student *'),
                  items: students.map((s) {
                    final user = s['user'] as Map<String, dynamic>? ?? {};
                    return DropdownMenuItem(
                      value: s['id'] as String,
                      child: Text(user['name'] as String? ?? '—'),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _enrollmentId = v),
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (₹) *', prefixText: '₹ '),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _mode,
              decoration: const InputDecoration(labelText: 'Payment Mode'),
              items: kPaymentModes
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => _mode = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Payment Date'),
              subtitle: Text(
                  '${_paidAt.day}/${_paidAt.month}/${_paidAt.year}'),
              trailing: const Icon(Icons.calendar_today_outlined, size: 18),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _paidAt,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _paidAt = d);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _record,
              child: _isLoading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Record Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
