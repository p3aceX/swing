import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../shared/widgets.dart';
import '../batches/batch_provider.dart';
import 'fee_provider.dart';

class RecordPaymentSheet extends ConsumerStatefulWidget {
  final String? prefillEnrollmentId;
  const RecordPaymentSheet({super.key, this.prefillEnrollmentId});

  @override
  ConsumerState<RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends ConsumerState<RecordPaymentSheet> {
  Map<String, dynamic>? _batch;
  Map<String, dynamic>? _enrollment;

  final _amountCtrl = TextEditingController();
  final _notesCtrl  = TextEditingController();
  String   _mode   = kPaymentModes.first;
  DateTime _paidAt = DateTime.now();
  String   _search = '';
  bool     _isLoading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.prefillEnrollmentId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final payments = ref.read(paymentsProvider).valueOrNull ?? [];
        final match = payments.where((e) => e['id'] == widget.prefillEnrollmentId).firstOrNull;
        if (match != null && mounted) _pickEnrollment(match);
      });
    }
  }

  void _pickBatch(Map<String, dynamic> batch) =>
      setState(() { _batch = batch; _enrollment = null; _search = ''; });

  void _pickEnrollment(Map<String, dynamic> e) {
    final paise = e['amount'] as int? ?? 0;
    _amountCtrl.text = (paise / 100).toStringAsFixed(0);
    setState(() => _enrollment = e);
  }

  Future<void> _record() async {
    if (_enrollment == null || _amountCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(paymentsProvider.notifier).recordPayment({
        'enrollmentId': _enrollment!['id'],
        'amountPaise': ((double.tryParse(_amountCtrl.text) ?? 0) * 100).round(),
        'paymentMode': _mode,
        if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text.trim(),
        'paidAt': _paidAt.toIso8601String(),
      });
      if (mounted) {
        ref.invalidate(financeSummaryProvider);
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) showSnack(context, 'Failed to record payment');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 12, 10),
            child: Row(
              children: [
                if (_batch != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                    onPressed: () => setState(() {
                      if (_enrollment != null) {
                        _enrollment = null;
                      } else {
                        _batch = null;
                      }
                    }),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _enrollment != null
                        ? 'Payment Details'
                        : _batch != null
                            ? _batch!['name'] as String? ?? 'Select Student'
                            : 'Select Batch',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _enrollment != null
                ? _PaymentForm(
                    enrollment: _enrollment!,
                    amountCtrl: _amountCtrl,
                    notesCtrl: _notesCtrl,
                    mode: _mode,
                    paidAt: _paidAt,
                    isLoading: _isLoading,
                    onModeChanged: (v) => setState(() => _mode = v),
                    onDateChanged: (d) => setState(() => _paidAt = d),
                    onRecord: _record,
                  )
                : _batch != null
                    ? _StudentPicker(
                        batch: _batch!,
                        search: _search,
                        onSearchChanged: (v) => setState(() => _search = v),
                        onPick: _pickEnrollment,
                        scrollCtrl: scrollCtrl,
                      )
                    : _BatchPicker(
                        onPick: _pickBatch,
                        scrollCtrl: scrollCtrl,
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Step 1 — Batch picker ──────────────────────────────────────────────────────

class _BatchPicker extends ConsumerWidget {
  final ValueChanged<Map<String, dynamic>> onPick;
  final ScrollController scrollCtrl;
  const _BatchPicker({required this.onPick, required this.scrollCtrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(batchesProvider);
    return state.when(
      loading: loadingBody,
      error: (e, _) => errorBody(e, () => ref.invalidate(batchesProvider)),
      data: (batches) {
        if (batches.isEmpty) return emptyBody('No batches found');
        return ListView.separated(
          controller: scrollCtrl,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: batches.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final b = batches[i];
            final count = ((b['_count'] as Map?)?['enrollments'] as num?)?.toInt() ?? 0;
            final fees  = (b['feeStructures'] as List? ?? []).cast<Map>();
            final fee   = fees.isNotEmpty ? (fees.first['amountPaise'] as num? ?? 0).toInt() : 0;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF2E63D9).withValues(alpha: 0.1),
                child: const Icon(Icons.groups_rounded, color: Color(0xFF2E63D9), size: 20),
              ),
              title: Text(b['name'] as String? ?? '—',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                '$count student${count != 1 ? 's' : ''}'
                '${fee > 0 ? '  ·  ${rupeesFromPaise(fee)}/mo' : ''}',
              ),
              trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
              onTap: () => onPick(b),
            );
          },
        );
      },
    );
  }
}

// ── Step 2 — Student picker ────────────────────────────────────────────────────

class _StudentPicker extends ConsumerWidget {
  final Map<String, dynamic> batch;
  final String search;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Map<String, dynamic>> onPick;
  final ScrollController scrollCtrl;

  const _StudentPicker({
    required this.batch,
    required this.search,
    required this.onSearchChanged,
    required this.onPick,
    required this.scrollCtrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentsProvider);
    final batchName = batch['name'] as String? ?? '';

    return state.when(
      loading: loadingBody,
      error: (e, _) => errorBody(e, () => ref.invalidate(paymentsProvider)),
      data: (all) {
        final students = all
            .where((e) => e['batchName'] == batchName)
            .where((e) => search.isEmpty ||
                (e['studentName'] as String? ?? '').toLowerCase().contains(search.toLowerCase()))
            .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search student…',
                  prefixIcon: Icon(Icons.search, size: 20),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: onSearchChanged,
              ),
            ),
            Expanded(
              child: students.isEmpty
                  ? emptyBody('No students found')
                  : ListView.separated(
                      controller: scrollCtrl,
                      itemCount: students.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final e = students[i];
                        final name   = e['studentName'] as String? ?? '—';
                        final status = e['status'] as String? ?? '';
                        final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF2E63D9).withValues(alpha: 0.1),
                            child: Text(initial,
                                style: const TextStyle(
                                    color: Color(0xFF2E63D9), fontWeight: FontWeight.w800,
                                    fontSize: 15)),
                          ),
                          title: Text(name,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(rupeesFromPaise(e['amount'])),
                          trailing: statusBadge(status),
                          onTap: () => onPick(e),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ── Step 3 — Payment form ──────────────────────────────────────────────────────

class _PaymentForm extends StatelessWidget {
  final Map<String, dynamic> enrollment;
  final TextEditingController amountCtrl;
  final TextEditingController notesCtrl;
  final String mode;
  final DateTime paidAt;
  final bool isLoading;
  final ValueChanged<String> onModeChanged;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onRecord;

  const _PaymentForm({
    required this.enrollment,
    required this.amountCtrl,
    required this.notesCtrl,
    required this.mode,
    required this.paidAt,
    required this.isLoading,
    required this.onModeChanged,
    required this.onDateChanged,
    required this.onRecord,
  });

  @override
  Widget build(BuildContext context) {
    final name      = enrollment['studentName'] as String? ?? '—';
    final batchName = enrollment['batchName']   as String? ?? '';

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF2E63D9).withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_rounded, size: 18, color: Color(0xFF2E63D9)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(
                          fontWeight: FontWeight.w800, color: Color(0xFF2E63D9))),
                      if (batchName.isNotEmpty)
                        Text(batchName, style: const TextStyle(
                            fontSize: 12, color: Color(0xFF2E63D9))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: amountCtrl,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount (₹) *', prefixText: '₹ '),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: mode,
            decoration: const InputDecoration(labelText: 'Payment Mode'),
            items: kPaymentModes
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (v) => onModeChanged(v!),
          ),
          const SizedBox(height: 4),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Payment Date'),
            subtitle: Text(DateFormat('d MMM yyyy').format(paidAt)),
            trailing: const Icon(Icons.calendar_today_outlined, size: 18),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: paidAt,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (d != null) onDateChanged(d);
            },
          ),
          const SizedBox(height: 4),
          TextField(
            controller: notesCtrl,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isLoading ? null : onRecord,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            child: isLoading
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Record Payment',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
