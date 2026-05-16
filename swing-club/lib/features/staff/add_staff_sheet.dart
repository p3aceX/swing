import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets.dart';
import 'staff_provider.dart';

const _kPaymentModes = ['CASH', 'UPI', 'BANK_TRANSFER'];

class AddStaffSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existing;
  const AddStaffSheet({super.key, this.existing});

  @override
  ConsumerState<AddStaffSheet> createState() => _AddStaffSheetState();
}

class _AddStaffSheetState extends ConsumerState<AddStaffSheet> {
  final _nameCtrl   = TextEditingController();
  final _roleCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _salaryCtrl = TextEditingController();
  String _paymentMode = 'CASH';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _nameCtrl.text   = e['name']  as String? ?? '';
      _roleCtrl.text   = e['role']  as String? ?? '';
      _phoneCtrl.text  = e['phone'] as String? ?? '';
      final paise = e['salaryPaise'];
      if (paise != null) _salaryCtrl.text = (paise / 100).toStringAsFixed(0);
      _paymentMode = e['paymentMode'] as String? ?? 'CASH';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _phoneCtrl.dispose();
    _salaryCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) { showSnack(context, 'Name is required'); return; }
    if (_roleCtrl.text.trim().isEmpty) { showSnack(context, 'Role is required'); return; }
    if (_salaryCtrl.text.isEmpty)      { showSnack(context, 'Salary is required'); return; }

    setState(() => _isLoading = true);
    try {
      final payload = {
        'name':        _nameCtrl.text.trim(),
        'role':        _roleCtrl.text.trim(),
        'salaryPaise': ((double.tryParse(_salaryCtrl.text) ?? 0) * 100).round(),
        'paymentMode': _paymentMode,
        if (_phoneCtrl.text.trim().isNotEmpty) 'phone': _phoneCtrl.text.trim(),
      };
      final e = widget.existing;
      if (e != null) {
        await ref.read(staffProvider.notifier).edit(e['id'] as String, payload);
      } else {
        await ref.read(staffProvider.notifier).create(payload);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) showSnack(context, 'Failed to save');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(isEdit ? 'Edit Staff' : 'Add Staff Member',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Full Name *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _roleCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Role *',
                hintText: 'e.g. Groundsman, Water Boy, Security',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 10,
              decoration: const InputDecoration(labelText: 'Phone (optional)', counterText: ''),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _salaryCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Monthly Salary (₹) *', prefixText: '₹ '),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _paymentMode,
              decoration: const InputDecoration(labelText: 'Payment Mode'),
              items: _kPaymentModes.map((m) => DropdownMenuItem(
                value: m,
                child: Text(m.replaceAll('_', ' ')),
              )).toList(),
              onChanged: (v) => setState(() => _paymentMode = v!),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: cs.primary),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(isEdit ? 'Update' : 'Add Staff Member',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
