import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../../core/router/app_router.dart';
import '../controller/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, required this.phone});

  final String phone;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _pageController = PageController();
  final _ownerFormKey = GlobalKey<FormState>();
  final _businessFormKey = GlobalKey<FormState>();
  final _locationFormKey = GlobalKey<FormState>();
  final _optionalFormKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _businessNameCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();
  final _panCtrl = TextEditingController();

  Timer? _pincodeDebounce;
  bool _fetchingLocation = false;
  int _step = 0;
  static const int _stepCount = 4;

  @override
  void dispose() {
    _pageController.dispose();
    _pincodeDebounce?.cancel();
    _nameCtrl.dispose();
    _businessNameCtrl.dispose();
    _pincodeCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _gstCtrl.dispose();
    _panCtrl.dispose();
    super.dispose();
  }

  void _onPincodeChanged(String value) {
    _pincodeDebounce?.cancel();
    final pincode = value.trim();
    if (pincode.length != 6) {
      setState(() => _fetchingLocation = false);
      return;
    }
    setState(() => _fetchingLocation = true);
    _pincodeDebounce = Timer(const Duration(milliseconds: 350), () {
      _lookupPincode(pincode);
    });
  }

  Future<void> _lookupPincode(String pincode) async {
    try {
      final res = await http
          .get(Uri.parse('https://api.postalpincode.in/pincode/$pincode'))
          .timeout(const Duration(seconds: 6));
      if (!mounted) return;
      final data = jsonDecode(res.body) as List;
      if (data.isNotEmpty && data[0]['Status'] == 'Success') {
        final offices = data[0]['PostOffice'] as List;
        if (offices.isNotEmpty) {
          final office = offices[0] as Map<String, dynamic>;
          setState(() {
            _cityCtrl.text = office['District'] as String? ?? _cityCtrl.text;
            _stateCtrl.text = office['State'] as String? ?? _stateCtrl.text;
          });
        }
      }
    } catch (_) {
      // Manual entry still works if the lookup fails.
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  Future<void> _goNext() async {
    final isValid = switch (_step) {
      0 => _ownerFormKey.currentState?.validate() ?? false,
      1 => _businessFormKey.currentState?.validate() ?? false,
      2 => _locationFormKey.currentState?.validate() ?? false,
      3 => _optionalFormKey.currentState?.validate() ?? false,
      _ => false,
    };
    if (!isValid) return;

    if (_step == _stepCount - 1) {
      await _submit();
      return;
    }

    setState(() => _step++);
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _goBack() async {
    if (_step == 0) {
      context.go(AppRoutes.login);
      return;
    }
    setState(() => _step--);
    await _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _submit() async {
    final controller = ref.read(authControllerProvider.notifier);
    controller.setPendingName(_nameCtrl.text);
    controller.setPendingBusinessDetails(
      BusinessDetailsInput(
        businessName: _businessNameCtrl.text.trim(),
        contactName: _nameCtrl.text.trim(),
        phone: widget.phone,
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        pincode: _pincodeCtrl.text.trim(),
        gstNumber: _gstCtrl.text.trim().isEmpty ? null : _gstCtrl.text.trim(),
        panNumber: _panCtrl.text.trim().isEmpty ? null : _panCtrl.text.trim(),
      ),
    );

    await controller.sendOtp(widget.phone);
    if (!mounted) return;
    final updated = ref.read(authControllerProvider);
    if (updated.step == AuthStep.otp || updated.step == AuthStep.name) {
      context.go(AppRoutes.otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    ref.listen(authControllerProvider, (prev, next) {
      if (next.error != null && prev?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Business registration'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _ProgressHeader(
              step: _step,
              total: _stepCount,
              title: _stepTitle(_step),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildOwnerStep(context),
                  _buildBusinessStep(context),
                  _buildLocationStep(context),
                  _buildOptionalStep(context),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border(
                    top: BorderSide(color: scheme.outline),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: auth.loading ? null : _goBack,
                        child: Text(_step == 0 ? 'Cancel' : 'Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: auth.loading ? null : _goNext,
                        child: auth.loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_step == _stepCount - 1
                                ? 'Send OTP'
                                : 'Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stepTitle(int step) {
    switch (step) {
      case 0:
        return 'Owner details';
      case 1:
        return 'Business name';
      case 2:
        return 'Location';
      case 3:
        return 'Optional details';
      default:
        return 'Business registration';
    }
  }

  Widget _buildOwnerStep(BuildContext context) {
    return _StepCard(
      title: 'Who manages this account?',
      subtitle: 'Start with the person who owns or manages the business.',
      child: Form(
        key: _ownerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              validator: (v) => (v == null || v.trim().length < 2)
                  ? 'Enter the contact person name'
                  : null,
              decoration: const InputDecoration(
                labelText: 'Contact person name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: widget.phone,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessStep(BuildContext context) {
    return _StepCard(
      title: 'What is the business name?',
      subtitle: 'This is the name your arena will use across the app.',
      child: Form(
        key: _businessFormKey,
        child: TextFormField(
          controller: _businessNameCtrl,
          validator: (v) =>
              (v == null || v.trim().length < 2) ? 'Enter business name' : null,
          decoration: const InputDecoration(
            labelText: 'Business name',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationStep(BuildContext context) {
    return _StepCard(
      title: 'Where is the business located?',
      subtitle: 'Pincode will auto-fill city and state.',
      child: Form(
        key: _locationFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _pincodeCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              onChanged: _onPincodeChanged,
              validator: (v) => (v == null || v.trim().length != 6)
                  ? 'Enter a 6-digit pincode'
                  : null,
              decoration: InputDecoration(
                labelText: 'Pincode',
                counterText: '',
                prefixIcon: const Icon(Icons.pin_drop_outlined),
                suffixIcon: _fetchingLocation
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityCtrl,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'City required' : null,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stateCtrl,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'State required' : null,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      prefixIcon: Icon(Icons.map_outlined),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionalStep(BuildContext context) {
    return _StepCard(
      title: 'Optional business details',
      subtitle: 'GST and PAN can be added now or later from profile.',
      child: Form(
        key: _optionalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _gstCtrl,
              decoration: const InputDecoration(
                labelText: 'GST number',
                prefixIcon: Icon(Icons.receipt_long_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _panCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'PAN number',
                prefixIcon: Icon(Icons.credit_card_outlined),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: schemeFrom(context).surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: schemeFrom(context).outline),
              ),
            child: const Text(
              'You can skip GST and PAN now. The rest of the business registration will still be saved.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.step,
    required this.total,
    required this.title,
  });

  final int step;
  final int total;
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step ${step + 1} of $total',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface.withValues(alpha: 0.65),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${step + 1}',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(total, (index) {
              final active = index <= step;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index == total - 1 ? 0 : 6),
                  height: 5,
                  decoration: BoxDecoration(
                    color: active ? scheme.primary : scheme.outline,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: scheme.outline),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D0B0B0F),
                  blurRadius: 26,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 22),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

ColorScheme schemeFrom(BuildContext context) => Theme.of(context).colorScheme;
