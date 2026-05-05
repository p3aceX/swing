import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../shared/widgets.dart';
import 'inventory_provider.dart';

class AddInventorySheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existing;

  const AddInventorySheet({super.key, this.existing});

  @override
  ConsumerState<AddInventorySheet> createState() => _AddInventorySheetState();
}

class _AddInventorySheetState extends ConsumerState<AddInventorySheet> {
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  String _condition = kConditions.first;
  DateTime? _purchasedAt;
  final _costCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _nameCtrl.text = e['name'] as String? ?? '';
      _categoryCtrl.text = e['category'] as String? ?? '';
      _qtyCtrl.text = (e['quantity'] as int? ?? 1).toString();
      final cond = e['condition'] as String?;
      if (cond != null && kConditions.contains(cond)) _condition = cond;
      final dateStr = e['purchasedAt'] as String?;
      if (dateStr != null) {
        try {
          _purchasedAt = DateTime.parse(dateStr).toLocal();
        } catch (_) {}
      }
      final cost = e['costPaise'];
      if (cost != null) {
        _costCtrl.text = (cost / 100).toStringAsFixed(0);
      }
      _notesCtrl.text = e['notes'] as String? ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _qtyCtrl.dispose();
    _costCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty) {
      showSnack(context, 'Name is required');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final payload = {
        'name': _nameCtrl.text.trim(),
        if (_categoryCtrl.text.isNotEmpty) 'category': _categoryCtrl.text.trim(),
        'quantity': int.tryParse(_qtyCtrl.text) ?? 1,
        'condition': _condition,
        if (_purchasedAt != null) 'purchasedAt': _purchasedAt!.toIso8601String(),
        if (_costCtrl.text.isNotEmpty)
          'costPaise': ((double.tryParse(_costCtrl.text) ?? 0) * 100).round(),
        if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text.trim(),
      };
      final e = widget.existing;
      if (e != null) {
        await ref.read(inventoryProvider.notifier).edit(e['id'] as String, payload);
      } else {
        await ref.read(inventoryProvider.notifier).add(payload);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) showSnack(context, 'Failed to save item');
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
                Text(isEdit ? 'Edit Item' : 'Add Item',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Item Name *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(labelText: 'Category (optional)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _condition,
              decoration: const InputDecoration(labelText: 'Condition'),
              items: kConditions
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _condition = v!),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Purchased At'),
              subtitle: Text(_purchasedAt == null
                  ? 'Optional'
                  : '${_purchasedAt!.day}/${_purchasedAt!.month}/${_purchasedAt!.year}'),
              trailing: const Icon(Icons.calendar_today_outlined, size: 18),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _purchasedAt ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _purchasedAt = d);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _costCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cost (₹, optional)', prefixText: '₹ '),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isEdit ? 'Update Item' : 'Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}
