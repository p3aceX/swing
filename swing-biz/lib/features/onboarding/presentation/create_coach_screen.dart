import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/me_providers.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/router/app_router.dart';

class CreateCoachScreen extends ConsumerStatefulWidget {
  const CreateCoachScreen({super.key});

  @override
  ConsumerState<CreateCoachScreen> createState() => _CreateCoachScreenState();
}

class _CreateCoachScreenState extends ConsumerState<CreateCoachScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bio = TextEditingController();
  final _specs = TextEditingController();
  final _certs = TextEditingController();
  final _experience = TextEditingController(text: '0');
  final _rate = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  bool _gig = false;
  bool _oneOnOne = false;
  bool _saving = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(hostBizRepositoryProvider);
      await repo.createOrUpdateCoach(CoachProfileInput(
        bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
        specializations: _splitCsv(_specs.text),
        certifications: _splitCsv(_certs.text),
        experienceYears: int.tryParse(_experience.text.trim()) ?? 0,
        hourlyRate: int.tryParse(_rate.text.trim()),
        city: _city.text.trim().isEmpty ? null : _city.text.trim(),
        state: _state.text.trim().isEmpty ? null : _state.text.trim(),
        gigEnabled: _gig,
        oneOnOneEnabled: _oneOnOne,
      ));
      await ref
          .read(sessionControllerProvider.notifier)
          .setActiveProfile(BizProfileType.coach);
      ref.invalidate(meProvider);
      if (!mounted) return;
      context.go(AppRoutes.dashboard);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<String> _splitCsv(String raw) => raw
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create coach profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _field(_bio, 'Bio'),
            _field(_specs, 'Specializations (comma separated)'),
            _field(_certs, 'Certifications (comma separated)'),
            Row(
              children: [
                Expanded(
                  child: _field(_experience, 'Experience (years)',
                      keyboard: TextInputType.number),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _field(_rate, 'Hourly rate (₹)',
                      keyboard: TextInputType.number),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: _field(_city, 'City')),
                const SizedBox(width: 8),
                Expanded(child: _field(_state, 'State')),
              ],
            ),
            SwitchListTile(
              value: _gig,
              onChanged: (v) => setState(() => _gig = v),
              title: const Text('Accept gigs'),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              value: _oneOnOne,
              onChanged: (v) => setState(() => _oneOnOne = v),
              title: const Text('Accept 1-on-1 lessons'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 22, width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create coach profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
          {TextInputType? keyboard}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          keyboardType: keyboard,
          decoration: InputDecoration(labelText: label),
        ),
      );

  @override
  void dispose() {
    for (final c in [_bio, _specs, _certs, _experience, _rate, _city, _state]) {
      c.dispose();
    }
    super.dispose();
  }
}
