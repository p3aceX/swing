import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../shared/widgets.dart';
import 'fee_provider.dart';

class AddExpenseSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existing;

  const AddExpenseSheet({super.key, this.existing});

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _payeeCtrl = TextEditingController();
  String _category = kExpenseCategories.first;
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _category = e['category'] as String? ?? kExpenseCategories.first;
      _descCtrl.text = e['description'] as String? ?? '';
      final paise = e['amountPaise'];
      if (paise != null) {
        _amountCtrl.text = (paise / 100).toStringAsFixed(0);
      }
      _payeeCtrl.text = e['payee'] as String? ?? '';
      final dateStr = e['date'] as String?;
      if (dateStr != null) {
        try {
          _date = DateTime.parse(dateStr).toLocal();
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _payeeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_descCtrl.text.isEmpty) {
      showSnack(context, 'Description is required');
      return;
    }
    if (_amountCtrl.text.isEmpty) {
      showSnack(context, 'Amount is required');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final payload = {
        'category': _category,
        'description': _descCtrl.text.trim(),
        'amountPaise': ((double.tryParse(_amountCtrl.text) ?? 0) * 100).round(),
        'date': _date.toIso8601String(),
        if (_payeeCtrl.text.isNotEmpty) 'payee': _payeeCtrl.text.trim(),
      };
      final e = widget.existing;
      if (e != null) {
        await ref.read(expensesProvider.notifier).edit(e['id'] as String, payload);
      } else {
        await ref.read(expensesProvider.notifier).create(payload);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) showSnack(context, 'Failed to save expense');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
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
                Text(isEdit ? 'Edit Expense' : 'Add Expense',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: kExpenseCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (₹) *', prefixText: '₹ '),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(DateFormat('d MMM yyyy').format(_date)),
              trailing: const Icon(Icons.calendar_today_outlined, size: 18),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                );
                if (d != null) setState(() => _date = d);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _payeeCtrl,
              decoration: const InputDecoration(labelText: 'Payee (optional)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isEdit ? 'Update Expense' : 'Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
