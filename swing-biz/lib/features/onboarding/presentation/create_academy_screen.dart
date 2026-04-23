import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/me_providers.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/router/app_router.dart';

class CreateAcademyScreen extends ConsumerStatefulWidget {
  const CreateAcademyScreen({super.key});

  @override
  ConsumerState<CreateAcademyScreen> createState() =>
      _CreateAcademyScreenState();
}

class _CreateAcademyScreenState extends ConsumerState<CreateAcademyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _tagline = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _address = TextEditingController();
  final _pincode = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  bool _saving = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(hostBizRepositoryProvider);
      await repo.createAcademy(AcademyProfileInput(
        name: _name.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        tagline: _tagline.text.trim().isEmpty ? null : _tagline.text.trim(),
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        pincode: _pincode.text.trim().isEmpty ? null : _pincode.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      ));
      await ref
          .read(sessionControllerProvider.notifier)
          .setActiveProfile(BizProfileType.academy);
      ref.invalidate(meProvider);
      if (!mounted) return;
      context.go(AppRoutes.dashboard);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create academy: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create academy')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _field(_name, 'Academy name *', required: true),
            _field(_tagline, 'Tagline'),
            _field(_city, 'City *', required: true),
            _field(_state, 'State *', required: true),
            _field(_address, 'Address'),
            _field(_pincode, 'Pincode'),
            _field(_phone, 'Phone', keyboard: TextInputType.phone),
            _field(_email, 'Email', keyboard: TextInputType.emailAddress),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 22, width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create academy'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
          {bool required = false, TextInputType? keyboard}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          keyboardType: keyboard,
          decoration: InputDecoration(labelText: label),
          validator: required
              ? (v) => (v == null || v.trim().length < 2)
                  ? 'Required'
                  : null
              : null,
        ),
      );

  @override
  void dispose() {
    for (final c in [_name, _tagline, _city, _state, _address, _pincode, _phone, _email]) {
      c.dispose();
    }
    super.dispose();
  }
}
