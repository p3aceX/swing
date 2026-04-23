import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/me_providers.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/router/app_router.dart';

class CreateArenaScreen extends ConsumerStatefulWidget {
  const CreateArenaScreen({super.key});

  @override
  ConsumerState<CreateArenaScreen> createState() => _CreateArenaScreenState();
}

class _CreateArenaScreenState extends ConsumerState<CreateArenaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();
  final _phone = TextEditingController();
  bool _parking = false;
  bool _lights = false;
  bool _washrooms = false;
  bool _canteen = false;
  bool _cctv = false;
  bool _saving = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(hostBizRepositoryProvider);
      await repo.createArena(ArenaProfileInput(
        name: _name.text.trim(),
        address: _address.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        pincode: _pincode.text.trim(),
        description:
            _description.text.trim().isEmpty ? null : _description.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        hasParking: _parking,
        hasLights: _lights,
        hasWashrooms: _washrooms,
        hasCanteen: _canteen,
        hasCCTV: _cctv,
      ));
      await ref
          .read(sessionControllerProvider.notifier)
          .setActiveProfile(BizProfileType.arena);
      ref.invalidate(meProvider);
      if (!mounted) return;
      context.go(AppRoutes.dashboard);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create arena: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create arena')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _field(_name, 'Arena name *', required: true),
            _field(_description, 'Description'),
            _field(_address, 'Address *', required: true),
            _field(_city, 'City *', required: true),
            _field(_state, 'State *', required: true),
            _field(_pincode, 'Pincode *', required: true, minLen: 4),
            _field(_phone, 'Phone', keyboard: TextInputType.phone),
            const SizedBox(height: 8),
            _check('Parking', _parking, (v) => setState(() => _parking = v)),
            _check('Lights', _lights, (v) => setState(() => _lights = v)),
            _check('Washrooms', _washrooms, (v) => setState(() => _washrooms = v)),
            _check('Canteen', _canteen, (v) => setState(() => _canteen = v)),
            _check('CCTV', _cctv, (v) => setState(() => _cctv = v)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 22, width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create arena'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _check(String label, bool v, ValueChanged<bool> onChanged) =>
      CheckboxListTile(
        value: v,
        onChanged: (x) => onChanged(x ?? false),
        title: Text(label),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      );

  Widget _field(TextEditingController c, String label,
          {bool required = false, int minLen = 2, TextInputType? keyboard}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          keyboardType: keyboard,
          decoration: InputDecoration(labelText: label),
          validator: required
              ? (v) =>
                  (v == null || v.trim().length < minLen) ? 'Required' : null
              : null,
        ),
      );

  @override
  void dispose() {
    for (final c in [
      _name, _description, _address, _city, _state, _pincode, _phone,
    ]) {
      c.dispose();
    }
    super.dispose();
  }
}
