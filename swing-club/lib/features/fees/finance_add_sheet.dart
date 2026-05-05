import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../shared/widgets.dart';
import '../batches/batch_provider.dart';
import 'fee_provider.dart';

enum _Mode { payment, expense }

class FinanceAddSheet extends ConsumerStatefulWidget {
  const FinanceAddSheet({super.key});

  @override
  ConsumerState<FinanceAddSheet> createState() => _FinanceAddSheetState();
}

class _FinanceAddSheetState extends ConsumerState<FinanceAddSheet> {
  _Mode? _mode;

  // — Payment state ————————————————————————————————————————
  Map<String, dynamic>? _batch;
  Map<String, dynamic>? _enrollment;
  final _payAmountCtrl = TextEditingController();
  final _payNotesCtrl  = TextEditingController();
  String   _payMode    = kPaymentModes.first;
  DateTime _paidAt     = DateTime.now();
  String   _paySearch  = '';

  // — Expense state ————————————————————————————————————————
  final _descCtrl    = TextEditingController();
  final _expAmtCtrl  = TextEditingController();
  final _payeeCtrl   = TextEditingController();
  String   _category = kExpenseCategories.first;
  DateTime _expDate  = DateTime.now();

  bool _isLoading = false;

  @override
  void dispose() {
    _payAmountCtrl.dispose();
    _payNotesCtrl.dispose();
    _descCtrl.dispose();
    _expAmtCtrl.dispose();
    _payeeCtrl.dispose();
    super.dispose();
  }

  void _back() {
    setState(() {
      if (_mode == _Mode.payment) {
        if (_enrollment != null) {
          _enrollment = null;
        } else if (_batch != null) {
          _batch = null;
          _paySearch = '';
        } else {
          _mode = null;
        }
      } else {
        _mode = null;
      }
    });
  }

  void _pickBatch(Map<String, dynamic> batch) =>
      setState(() { _batch = batch; _enrollment = null; _paySearch = ''; });

  void _pickEnrollment(Map<String, dynamic> e) {
    final paise = e['amount'] as int? ?? 0;
    _payAmountCtrl.text = (paise / 100).toStringAsFixed(0);
    setState(() => _enrollment = e);
  }

  Future<void> _recordPayment() async {
    if (_enrollment == null || _payAmountCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(paymentsProvider.notifier).recordPayment({
        'enrollmentId': _enrollment!['id'],
        'amountPaise': ((double.tryParse(_payAmountCtrl.text) ?? 0) * 100).round(),
        'paymentMode': _payMode,
        if (_payNotesCtrl.text.isNotEmpty) 'notes': _payNotesCtrl.text.trim(),
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

  Future<void> _saveExpense() async {
    if (_descCtrl.text.isEmpty) { showSnack(context, 'Description is required'); return; }
    if (_expAmtCtrl.text.isEmpty) { showSnack(context, 'Amount is required'); return; }
    setState(() => _isLoading = true);
    try {
      await ref.read(expensesProvider.notifier).create({
        'category': _category,
        'description': _descCtrl.text.trim(),
        'amountPaise': ((double.tryParse(_expAmtCtrl.text) ?? 0) * 100).round(),
        'date': _expDate.toIso8601String(),
        if (_payeeCtrl.text.isNotEmpty) 'payee': _payeeCtrl.text.trim(),
      });
      if (mounted) {
        ref.invalidate(financeSummaryProvider);
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) showSnack(context, 'Failed to save expense');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _headerTitle {
    if (_mode == null) return 'Add Finance';
    if (_mode == _Mode.expense) return 'Add Expense';
    if (_enrollment != null) return 'Payment Details';
    if (_batch != null) return _batch!['name'] as String? ?? 'Select Student';
    return 'Select Batch';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _mode == null ? 0.45 : 0.72,
      minChildSize: 0.35,
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
                if (_mode != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                    onPressed: _back,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _headerTitle,
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
            child: switch (_mode) {
              null        => _ChoiceScreen(onPick: (m) => setState(() => _mode = m), scrollCtrl: scrollCtrl),
              _Mode.payment => _paymentContent(scrollCtrl),
              _Mode.expense => _ExpenseForm(
                  descCtrl: _descCtrl,
                  amountCtrl: _expAmtCtrl,
                  payeeCtrl: _payeeCtrl,
                  category: _category,
                  date: _expDate,
                  isLoading: _isLoading,
                  onCategoryChanged: (v) => setState(() => _category = v),
                  onDateChanged: (d) => setState(() => _expDate = d),
                  onSave: _saveExpense,
                ),
            },
          ),
        ],
      ),
    );
  }

  Widget _paymentContent(ScrollController scrollCtrl) {
    if (_enrollment != null) {
      return _PaymentForm(
        enrollment: _enrollment!,
        amountCtrl: _payAmountCtrl,
        notesCtrl: _payNotesCtrl,
        mode: _payMode,
        paidAt: _paidAt,
        isLoading: _isLoading,
        onModeChanged: (v) => setState(() => _payMode = v),
        onDateChanged: (d) => setState(() => _paidAt = d),
        onRecord: _recordPayment,
      );
    }
    if (_batch != null) {
      return _StudentPicker(
        batch: _batch!,
        search: _paySearch,
        onSearchChanged: (v) => setState(() => _paySearch = v),
        onPick: _pickEnrollment,
        scrollCtrl: scrollCtrl,
      );
    }
    return _BatchPicker(onPick: _pickBatch, scrollCtrl: scrollCtrl);
  }
}

// ── Choice screen ──────────────────────────────────────────────────────────────

class _ChoiceScreen extends StatelessWidget {
  final ValueChanged<_Mode> onPick;
  final ScrollController scrollCtrl;
  const _ChoiceScreen({required this.onPick, required this.scrollCtrl});

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        _ChoiceTile(
          icon: Icons.payments_rounded,
          color: const Color(0xFF2E63D9),
          title: 'Record Payment',
          subtitle: 'Add a fee payment from a student',
          onTap: () => onPick(_Mode.payment),
        ),
        const SizedBox(height: 14),
        _ChoiceTile(
          icon: Icons.receipt_long_rounded,
          color: const Color(0xFFC62828),
          title: 'Add Expense',
          subtitle: 'Log a club or academy expense',
          onTap: () => onPick(_Mode.expense),
        ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ChoiceTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: color)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: TextStyle(
                      fontSize: 12,
                      color: color.withValues(alpha: 0.7))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}

// ── Batch picker ───────────────────────────────────────────────────────────────

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

// ── Student picker ─────────────────────────────────────────────────────────────

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
    final state     = ref.watch(paymentsProvider);
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
                        final e       = students[i];
                        final name    = e['studentName'] as String? ?? '—';
                        final status  = e['status'] as String? ?? '';
                        final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF2E63D9).withValues(alpha: 0.1),
                            child: Text(initial, style: const TextStyle(
                                color: Color(0xFF2E63D9), fontWeight: FontWeight.w800,
                                fontSize: 15)),
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
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

// ── Payment form ───────────────────────────────────────────────────────────────

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

// ── Expense form ───────────────────────────────────────────────────────────────

class _ExpenseForm extends StatelessWidget {
  final TextEditingController descCtrl;
  final TextEditingController amountCtrl;
  final TextEditingController payeeCtrl;
  final String category;
  final DateTime date;
  final bool isLoading;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onSave;

  const _ExpenseForm({
    required this.descCtrl,
    required this.amountCtrl,
    required this.payeeCtrl,
    required this.category,
    required this.date,
    required this.isLoading,
    required this.onCategoryChanged,
    required this.onDateChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: kExpenseCategories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => onCategoryChanged(v!),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: descCtrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Description *'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount (₹) *', prefixText: '₹ '),
          ),
          const SizedBox(height: 4),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            subtitle: Text(DateFormat('d MMM yyyy').format(date)),
            trailing: const Icon(Icons.calendar_today_outlined, size: 18),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 1)),
              );
              if (d != null) onDateChanged(d);
            },
          ),
          const SizedBox(height: 4),
          TextField(
            controller: payeeCtrl,
            decoration: const InputDecoration(labelText: 'Payee (optional)'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isLoading ? null : onSave,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            child: isLoading
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Add Expense',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
