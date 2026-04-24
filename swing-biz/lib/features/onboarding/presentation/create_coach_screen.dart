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
  final _page = PageController();
  final _personalKey = GlobalKey<FormState>();
  final _proKey = GlobalKey<FormState>();

  final _fullName = TextEditingController();
  final _dob = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _expertise = TextEditingController(text: 'Cricket');
  final _experience = TextEditingController(text: '0');
  final _certifications = TextEditingController();
  int _step = 0;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _fullName,
      _dob,
      _phone,
      _email,
      _expertise,
      _experience,
      _certifications,
    ]) {
      c.dispose();
    }
    _page.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final form = _step == 0 ? _personalKey : _proKey;
    if (!form.currentState!.validate()) return;
    if (_step == 1) return _submit();
    setState(() => _step = 1);
    await _page.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(hostBizRepositoryProvider);
      await repo.createOrUpdateCoach(
        CoachProfileInput(
          bio: _fullName.text.trim(),
          specializations: _csv(_expertise.text),
          certifications: _csv(_certifications.text),
          experienceYears: int.tryParse(_experience.text.trim()) ?? 0,
          city: null,
          state: null,
          gigEnabled: true,
          oneOnOneEnabled: true,
        ),
      );
      await ref
          .read(sessionControllerProvider.notifier)
          .setActiveProfile(BizProfileType.coach);
      ref.invalidate(meProvider);
      if (mounted) context.go(AppRoutes.coachHome);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save coach profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<String> _csv(String raw) =>
      raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coach Setup')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: List.generate(
                2,
                (index) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index == 1 ? 0 : 8),
                    height: 6,
                    decoration: BoxDecoration(
                      color: index <= _step
                          ? Theme.of(context).colorScheme.primary
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _page,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _CoachStep(
                  title: 'Personal Info',
                  child: Form(
                    key: _personalKey,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _field(_fullName, 'Full name *', required: true),
                        _field(_dob, 'DOB *', required: true),
                        _field(_phone, 'Phone *',
                            required: true, keyboard: TextInputType.phone),
                        _field(_email, 'Email',
                            keyboard: TextInputType.emailAddress),
                      ],
                    ),
                  ),
                ),
                _CoachStep(
                  title: 'Professional Info',
                  child: Form(
                    key: _proKey,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _field(_expertise, 'Sports expertise *',
                            required: true),
                        _field(_experience, 'Years of experience *',
                            required: true, keyboard: TextInputType.number),
                        _field(_certifications, 'Certifications'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () async {
                              setState(() => _step = 0);
                              await _page.previousPage(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOut,
                              );
                            },
                      child: const Text('Back'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _next,
                    child: _saving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_step == 1 ? 'Submit' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    bool required = false,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (v) => (v == null || v.trim().length < 2) ? 'Required' : null
            : null,
      ),
    );
  }
}

class _CoachStep extends StatelessWidget {
  const _CoachStep({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
