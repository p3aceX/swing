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
  final _page = PageController();
  final _basicKey = GlobalKey<FormState>();
  final _contactKey = GlobalKey<FormState>();
  final _bankKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _country = TextEditingController(text: 'India');
  final _sport = TextEditingController(text: 'Cricket');
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _bankHolder = TextEditingController();
  final _bankName = TextEditingController();
  final _accountNumber = TextEditingController();
  final _ifsc = TextEditingController();
  int _step = 0;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _city,
      _state,
      _country,
      _sport,
      _phone,
      _email,
      _address,
      _bankHolder,
      _bankName,
      _accountNumber,
      _ifsc,
    ]) {
      c.dispose();
    }
    _page.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final form = switch (_step) {
      0 => _basicKey,
      1 => _contactKey,
      _ => _bankKey,
    };
    if (!form.currentState!.validate()) return;
    if (_step == 2) return _submit();
    setState(() => _step++);
    await _page.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(hostBizRepositoryProvider);
      await repo.createAcademy(
        AcademyProfileInput(
          name: _name.text.trim(),
          city: _city.text.trim(),
          state: _state.text.trim(),
          phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          address: _address.text.trim().isEmpty ? null : _address.text.trim(),
          tagline: _sport.text.trim(),
        ),
      );
      await ref
          .read(sessionControllerProvider.notifier)
          .setActiveProfile(BizProfileType.academy);
      ref.invalidate(meProvider);
      if (mounted) context.go(AppRoutes.dashboard);
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
      appBar: AppBar(title: const Text('Academy Setup')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: List.generate(
                3,
                (index) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
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
                _StepShell(
                  title: 'Academy Basic Info',
                  child: Form(
                    key: _basicKey,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _field(_name, 'Academy name *', required: true),
                        _field(_city, 'City *', required: true),
                        _field(_state, 'State *', required: true),
                        _field(_country, 'Country *', required: true),
                        _field(_sport, 'Sport type *', required: true),
                      ],
                    ),
                  ),
                ),
                _StepShell(
                  title: 'Contact & Address',
                  child: Form(
                    key: _contactKey,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _field(_phone, 'Phone', keyboard: TextInputType.phone),
                        _field(_email, 'Email',
                            keyboard: TextInputType.emailAddress),
                        _field(_address, 'Office address', required: true),
                      ],
                    ),
                  ),
                ),
                _StepShell(
                  title: 'Bank Details',
                  child: Form(
                    key: _bankKey,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _field(_bankHolder, 'Account holder name *',
                            required: true),
                        _field(_bankName, 'Bank name *', required: true),
                        _field(_accountNumber, 'Account number *',
                            required: true, keyboard: TextInputType.number),
                        _field(_ifsc, 'IFSC *', required: true),
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
                              setState(() => _step--);
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
                        : Text(_step == 2 ? 'Submit' : 'Next'),
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

class _StepShell extends StatelessWidget {
  const _StepShell({required this.title, required this.child});

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
