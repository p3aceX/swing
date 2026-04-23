import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/me_providers.dart';
import '../../../core/router/app_router.dart';

class BusinessDetailsScreen extends ConsumerStatefulWidget {
  const BusinessDetailsScreen({super.key});

  @override
  ConsumerState<BusinessDetailsScreen> createState() =>
      _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends ConsumerState<BusinessDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessName = TextEditingController();
  final _contactName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _address = TextEditingController();
  final _pincode = TextEditingController();
  final _gst = TextEditingController();
  final _pan = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _businessName,
      _contactName,
      _phone,
      _email,
      _city,
      _state,
      _address,
      _pincode,
      _gst,
      _pan,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(hostBizRepositoryProvider);
      await repo.upsertBusinessDetails(BusinessDetailsInput(
        businessName: _businessName.text.trim(),
        contactName: _contactName.text.trim().isEmpty ? null : _contactName.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        city: _city.text.trim().isEmpty ? null : _city.text.trim(),
        state: _state.text.trim().isEmpty ? null : _state.text.trim(),
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        pincode: _pincode.text.trim().isEmpty ? null : _pincode.text.trim(),
        gstNumber: _gst.text.trim().isEmpty ? null : _gst.text.trim(),
        panNumber: _pan.text.trim().isEmpty ? null : _pan.text.trim(),
      ));
      ref.invalidate(meProvider);
      if (!mounted) return;
      context.go(AppRoutes.chooseProfile);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business details')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Tell us about your business. You can refine this later.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              _field(_businessName, 'Business name *', required: true),
              _field(_contactName, 'Contact person'),
              _field(_phone, 'Contact phone', keyboard: TextInputType.phone),
              _field(_email, 'Email', keyboard: TextInputType.emailAddress),
              _field(_city, 'City'),
              _field(_state, 'State'),
              _field(_address, 'Address'),
              _field(_pincode, 'Pincode'),
              _field(_gst, 'GST number'),
              _field(_pan, 'PAN number'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 22, width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save and continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType? keyboard,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboard,
          decoration: InputDecoration(labelText: label),
          validator: required
              ? (v) => (v == null || v.trim().length < 2)
                  ? 'This field is required'
                  : null
              : null,
        ),
      );
}
