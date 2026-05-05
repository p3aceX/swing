import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../shared/widgets.dart';
import '../batches/batch_provider.dart';
import 'fee_provider.dart';

class FeeStructureSheet extends ConsumerStatefulWidget {
  const FeeStructureSheet({super.key});

  @override
  ConsumerState<FeeStructureSheet> createState() => _FeeStructureSheetState();
}

class _FeeStructureSheetState extends ConsumerState<FeeStructureSheet> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _frequency = kFeeFrequencies.first;
  String? _batchId;
  final _dueDayCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _dueDayCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty || _amountCtrl.text.isEmpty) {
      showSnack(context, 'Name and amount are required');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(feeStructuresProvider.notifier).create({
        'name': _nameCtrl.text.trim(),
        'amountPaise': (double.tryParse(_amountCtrl.text) ?? 0) * 100,
        'frequency': _frequency,
        if (_batchId != null) 'batchId': _batchId,
        if (_dueDayCtrl.text.isNotEmpty) 'dueDayOfMonth': int.tryParse(_dueDayCtrl.text),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showSnack(context, 'Failed to create fee structure');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final batchesState = ref.watch(batchesProvider);

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
                const Text('Create Fee Structure',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Structure Name *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (₹) *', prefixText: '₹ '),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _frequency,
              decoration: const InputDecoration(labelText: 'Frequency'),
              items: kFeeFrequencies
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (v) => setState(() => _frequency = v!),
            ),
            const SizedBox(height: 12),
            batchesState.maybeWhen(
              data: (batches) => DropdownButtonFormField<String?>(
                initialValue: _batchId,
                decoration: const InputDecoration(labelText: 'Batch (optional)'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All students')),
                  ...batches.map((b) => DropdownMenuItem(
                      value: b['id'] as String, child: Text(b['name'] as String? ?? ''))),
                ],
                onChanged: (v) => setState(() => _batchId = v),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dueDayCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Due Day of Month (1–28, optional)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: const Text('Create Structure'),
            ),
          ],
        ),
      ),
    );
  }
}
