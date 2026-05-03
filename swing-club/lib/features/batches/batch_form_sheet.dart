import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../shared/widgets.dart';
import 'batch_provider.dart';

class BatchFormSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existing;

  const BatchFormSheet({super.key, this.existing});

  @override
  ConsumerState<BatchFormSheet> createState() => _BatchFormSheetState();
}

class _BatchFormSheetState extends ConsumerState<BatchFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _maxCtrl;
  late String _sport;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?['name'] as String?);
    _ageCtrl = TextEditingController(text: widget.existing?['ageGroup'] as String?);
    _descCtrl = TextEditingController(text: widget.existing?['description'] as String?);
    _maxCtrl = TextEditingController(
        text: (widget.existing?['maxStudents'] ?? 20).toString());
    _sport = (widget.existing?['sport'] as String?) ?? kSports.first;
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
      'sport': _sport,
      'maxStudents': int.tryParse(_maxCtrl.text) ?? 20,
      'description': _descCtrl.text.trim(),
    };
    try {
      if (widget.existing != null) {
        await ref.read(batchesProvider.notifier).updateBatch(widget.existing!['id'] as String, payload);
      } else {
        await ref.read(batchesProvider.notifier).create(payload);
      }
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
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    widget.existing == null ? 'New Batch' : 'Edit Batch',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Batch Name *'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageCtrl,
                decoration: const InputDecoration(labelText: 'Age Group (e.g. U-14, Open)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _sport,
                decoration: const InputDecoration(labelText: 'Sport'),
                items: kSports
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _sport = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _maxCtrl,
                decoration: const InputDecoration(labelText: 'Max Students'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(widget.existing == null ? 'Create Batch' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
