import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

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
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();
  final _gst = TextEditingController();
  final _pan = TextEditingController();

  Timer? _pincodeDebounce;
  bool _saving = false;
  bool _loadingPincode = false;
  String? _loadedKey;

  @override
  void dispose() {
    _pincodeDebounce?.cancel();
    _businessName.dispose();
    _contactName.dispose();
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    _state.dispose();
    _pincode.dispose();
    _gst.dispose();
    _pan.dispose();
    super.dispose();
  }

  void _sync(BizMeResponse me) {
    final key = me.businessAccount?.id ?? 'new:${me.user.id}';
    if (_loadedKey == key) return;
    _loadedKey = key;

    final b = me.businessAccount;
    _businessName.text = b?.businessName ?? '';
    _contactName.text = b?.contactName ?? me.user.name ?? '';
    _phone.text = b?.phone ?? me.user.phone;
    _address.text = b?.address ?? '';
    _city.text = b?.city ?? '';
    _state.text = b?.state ?? '';
    _pincode.text = b?.pincode ?? '';
    _gst.text = b?.gstNumber ?? '';
    _pan.text = b?.panNumber ?? '';
  }

  void _onPincodeChanged(String value) {
    _pincodeDebounce?.cancel();
    final pincode = value.trim();
    if (pincode.length != 6) {
      setState(() => _loadingPincode = false);
      return;
    }
    setState(() => _loadingPincode = true);
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
            _city.text = office['District'] as String? ?? _city.text;
            _state.text = office['State'] as String? ?? _state.text;
          });
        }
      }
    } catch (_) {
      // Manual entry still works.
    } finally {
      if (mounted) setState(() => _loadingPincode = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(hostBizRepositoryProvider).upsertBusinessDetails(
            BusinessDetailsInput(
              businessName: _businessName.text.trim(),
              contactName: _contactName.text.trim().isEmpty
                  ? null
                  : _contactName.text.trim(),
              phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
              address: _address.text.trim().isEmpty ? null : _address.text.trim(),
              city: _city.text.trim().isEmpty ? null : _city.text.trim(),
              state: _state.text.trim().isEmpty ? null : _state.text.trim(),
              pincode: _pincode.text.trim().isEmpty ? null : _pincode.text.trim(),
              gstNumber: _gst.text.trim().isEmpty ? null : _gst.text.trim(),
              panNumber: _pan.text.trim().isEmpty ? null : _pan.text.trim(),
            ),
          );
      ref.invalidate(meProvider);
      if (!mounted) return;
      context.go(AppRoutes.createArena);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save business details: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final meAsync = ref.watch(meProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Business details'),
      ),
      body: meAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (me) {
          if (me == null) return const SizedBox.shrink();
          _sync(me);
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _HeroHeader(
                              title: 'Complete business profile',
                              subtitle:
                                  'Add the business information that your arena will use.',
                            ),
                            const SizedBox(height: 22),
                            const _SectionTitle(
                              index: '1',
                              title: 'Owner',
                              subtitle: 'From your signed-in profile',
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _contactName,
                              decoration: const InputDecoration(
                                labelText: 'Contact person',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                              validator: (v) => (v == null || v.trim().length < 2)
                                  ? 'Enter contact person name'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phone,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Phone number',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const _SectionTitle(
                              index: '2',
                              title: 'Business',
                              subtitle:
                                  'Keep the fields you use for your arena visible to customers',
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _businessName,
                              decoration: const InputDecoration(
                                labelText: 'Business name',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              validator: (v) => (v == null || v.trim().length < 2)
                                  ? 'Business name is required'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _address,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Address',
                                prefixIcon: Icon(Icons.home_outlined),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Address is required'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _pincode,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              onChanged: _onPincodeChanged,
                              decoration: InputDecoration(
                                labelText: 'Pincode',
                                counterText: '',
                                prefixIcon:
                                    const Icon(Icons.pin_drop_outlined),
                                suffixIcon: _loadingPincode
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              validator: (v) => (v == null || v.trim().length != 6)
                                  ? 'Enter a 6-digit pincode'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _city,
                                    decoration: const InputDecoration(
                                      labelText: 'City',
                                      prefixIcon:
                                          Icon(Icons.location_city_outlined),
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'City required'
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _state,
                                    decoration: const InputDecoration(
                                      labelText: 'State',
                                      prefixIcon: Icon(Icons.map_outlined),
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'State required'
                                            : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const _SectionTitle(
                              index: '3',
                              title: 'Optional',
                              subtitle: 'GST and PAN can be added later too',
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _gst,
                              decoration: const InputDecoration(
                                labelText: 'GST number',
                                prefixIcon:
                                    Icon(Icons.receipt_long_outlined),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _pan,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                labelText: 'PAN number',
                                prefixIcon:
                                    Icon(Icons.credit_card_outlined),
                              ),
                            ),
                            const SizedBox(height: 22),
                            FilledButton(
                              onPressed: _saving ? null : _submit,
                              child: _saving
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Save and continue'),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'By continuing, you accept the Terms & Conditions.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(Icons.business_center_rounded, color: scheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.index,
    required this.title,
    required this.subtitle,
  });

  final String index;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            index,
            style: TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
