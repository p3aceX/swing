import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/academy_provider.dart';
import '../../shared/widgets.dart';
import 'settings_provider.dart';

class AcademyProfileScreen extends ConsumerStatefulWidget {
  const AcademyProfileScreen({super.key});

  @override
  ConsumerState<AcademyProfileScreen> createState() => _AcademyProfileScreenState();
}

class _AcademyProfileScreenState extends ConsumerState<AcademyProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  bool _isLoading = false;
  bool _populated = false;

  @override
  void dispose() {
    for (final c in [_nameCtrl, _descCtrl, _taglineCtrl, _phoneCtrl, _emailCtrl,
        _websiteCtrl, _addressCtrl, _cityCtrl, _stateCtrl, _pincodeCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _populate(Map<String, dynamic> academy) {
    if (_populated) return;
    _populated = true;
    _nameCtrl.text = academy['name'] as String? ?? '';
    _descCtrl.text = academy['description'] as String? ?? '';
    _taglineCtrl.text = academy['tagline'] as String? ?? '';
    _phoneCtrl.text = academy['phone'] as String? ?? '';
    _emailCtrl.text = academy['email'] as String? ?? '';
    _websiteCtrl.text = academy['websiteUrl'] as String? ?? '';
    _addressCtrl.text = academy['address'] as String? ?? '';
    _cityCtrl.text = academy['city'] as String? ?? '';
    _stateCtrl.text = academy['state'] as String? ?? '';
    _pincodeCtrl.text = academy['pincode'] as String? ?? '';
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final academyState = await ref.read(academyProvider.future);
      await ref.read(settingsProvider.notifier).updateAcademy(
        academyState.academyId,
        {
          'name': _nameCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'tagline': _taglineCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'websiteUrl': _websiteCtrl.text.trim(),
          'address': _addressCtrl.text.trim(),
          'city': _cityCtrl.text.trim(),
          'state': _stateCtrl.text.trim(),
          'pincode': _pincodeCtrl.text.trim(),
        },
      );
      if (mounted) showSnack(context, 'Academy profile updated');
    } catch (e) {
      if (mounted) showSnack(context, 'Failed to update profile');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(academyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academy Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
      body: state.when(
        loading: loadingBody,
        error: (e, _) => errorBody(e, () => ref.invalidate(academyProvider)),
        data: (academyState) {
          _populate(academyState.data);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _field(_nameCtrl, 'Academy Name *'),
              const SizedBox(height: 12),
              _field(_taglineCtrl, 'Tagline'),
              const SizedBox(height: 12),
              _field(_descCtrl, 'Description', maxLines: 3),
              const SizedBox(height: 12),
              _field(_phoneCtrl, 'Phone', type: TextInputType.phone),
              const SizedBox(height: 12),
              _field(_emailCtrl, 'Email', type: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _field(_websiteCtrl, 'Website URL', type: TextInputType.url),
              const Divider(height: 32),
              const Text('Address', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _field(_addressCtrl, 'Street Address'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _field(_cityCtrl, 'City')),
                const SizedBox(width: 12),
                Expanded(child: _field(_stateCtrl, 'State')),
              ]),
              const SizedBox(height: 12),
              _field(_pincodeCtrl, 'Pincode', type: TextInputType.number),
            ],
          );
        },
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
    TextInputType type = TextInputType.text,
  }) =>
      TextField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label),
        maxLines: maxLines,
        keyboardType: type,
      );
}
