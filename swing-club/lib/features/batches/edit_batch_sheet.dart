import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets.dart';
import 'batch_provider.dart';

class EditBatchSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> existing;

  const EditBatchSheet({super.key, required this.existing});

  @override
  ConsumerState<EditBatchSheet> createState() => _EditBatchSheetState();
}

class _EditBatchSheetState extends ConsumerState<EditBatchSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _maxCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing['name'] as String?);
    _ageCtrl = TextEditingController(text: widget.existing['ageGroup'] as String?);
    _descCtrl = TextEditingController(text: widget.existing['description'] as String?);
    _maxCtrl = TextEditingController(
        text: (widget.existing['maxStudents'] ?? 20).toString());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _descCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final payload = {
      'name': _nameCtrl.text.trim(),
      'ageGroup': _ageCtrl.text.trim(),
      'sport': 'CRICKET',
      'maxStudents': int.tryParse(_maxCtrl.text) ?? 20,
      'description': _descCtrl.text.trim(),
    };
    try {
      await ref.read(batchesProvider.notifier).updateBatch(widget.existing['id'] as String, payload);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showSnack(context, 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Batch Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Batch Name *'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageCtrl,
                decoration: const InputDecoration(labelText: 'Age Group'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: 'CRICKET',
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Sport'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maxCtrl,
                decoration: const InputDecoration(labelText: 'Max Students'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
