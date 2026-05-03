import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../shared/onboarding_widgets.dart';
import '../../shared/widgets.dart';

class AcademyRegistrationScreen extends ConsumerStatefulWidget {
  const AcademyRegistrationScreen({super.key});

  @override
  ConsumerState<AcademyRegistrationScreen> createState() => _AcademyRegistrationScreenState();
}

class _AcademyRegistrationScreenState extends ConsumerState<AcademyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _name        = TextEditingController();
  final _tagline     = TextEditingController();
  final _description = TextEditingController();
  final _address     = TextEditingController();
  final _city        = TextEditingController();
  final _stateCtrl   = TextEditingController();
  final _pincode     = TextEditingController();
  final _phone       = TextEditingController();
  final _email       = TextEditingController();
  final _website     = TextEditingController();
  final _foundedYear = TextEditingController();

  double? _lat;
  double? _lng;

  @override
  void dispose() {
    for (final c in [_name, _tagline, _description, _address, _city, _stateCtrl, _pincode, _phone, _email, _website, _foundedYear]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onPlaceSelected({
    required String address,
    required String city,
    required String state,
    required String pincode,
    double? lat,
    double? lng,
  }) {
    setState(() {
      _address.text  = address;
      _city.text     = city;
      _stateCtrl.text = state;
      _pincode.text  = pincode;
      _lat = lat;
      _lng = lng;
    });
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final token = ref.read(secureStorageProvider).cachedAccessToken;
      final dio   = Dio(BaseOptions(headers: {'Authorization': 'Bearer $token'}));

      final body = <String, dynamic>{
        'name':  _name.text.trim(),
        'city':  _city.text.trim(),
        'state': _stateCtrl.text.trim(),
      };

      void addOpt(String k, String v) { if (v.isNotEmpty) body[k] = v; }
      addOpt('tagline',     _tagline.text.trim());
      addOpt('description', _description.text.trim());
      addOpt('address',     _address.text.trim());
      addOpt('pincode',     _pincode.text.trim());
      addOpt('phone',       _phone.text.trim());
      addOpt('email',       _email.text.trim());
      addOpt('websiteUrl',  _website.text.trim());
      if (_foundedYear.text.trim().isNotEmpty) {
        body['foundedYear'] = int.tryParse(_foundedYear.text.trim());
      }
      if (_lat != null) body['latitude']  = _lat;
      if (_lng != null) body['longitude'] = _lng;

      final res = await dio.post('$kBackendBaseUrl/biz/academy', data: body);
      if (!mounted) return;

      if ((res.statusCode ?? 0) >= 200 && (res.statusCode ?? 0) < 300) {
        final data      = res.data['data'] as Map<String, dynamic>;
        final academyId = data['id'] as String?;
        if (academyId != null) {
          await ref.read(secureStorageProvider).saveAcademyId(academyId);
        }
        if (!mounted) return;
        // ignore: use_build_context_synchronously
        context.go('/home');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final code    = e.response?.data?['code'] as String?;
      final message = e.response?.data?['message'] as String? ?? 'Failed to create academy. Try again.';
      if (code == 'BUSINESS_DETAILS_REQUIRED') {
        // ignore: use_build_context_synchronously
        showSnack(context, 'Please complete business details first');
        // ignore: use_build_context_synchronously
        context.go('/business-details');
      } else {
        // ignore: use_build_context_synchronously
        showSnack(context, message);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academy Setup')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            const OnboardingProgressBar(step: 2),
            const SizedBox(height: 32),

            // ── Academy Info ──────────────────────────────────────────────────
            const OnboardingSectionLabel(label: 'Academy Information', required: true),
            const SizedBox(height: 16),
            OnboardingField(
              controller: _name,
              label: 'Academy Name',
              icon: Icons.sports_cricket_rounded,
              validator: (v) => (v == null || v.trim().length < 2) ? 'Required (min 2 chars)' : null,
            ),
            OnboardingField(
              controller: _tagline,
              label: 'Tagline',
              icon: Icons.format_quote_rounded,
            ),
            OnboardingField(
              controller: _description,
              label: 'About Academy',
              icon: Icons.description_outlined,
              maxLines: 3,
            ),

            const SizedBox(height: 8),

            // ── Contact & Location ────────────────────────────────────────────
            const OnboardingSectionLabel(label: 'Contact & Location'),
            const SizedBox(height: 16),

            PlacesSearchField(onPlaceSelected: _onPlaceSelected),

            OnboardingField(
              controller: _address,
              label: 'Address',
              icon: Icons.location_on_outlined,
              maxLines: 2,
            ),
            Row(children: [
              Expanded(
                child: OnboardingField(
                  controller: _city,
                  label: 'City',
                  icon: Icons.location_city_rounded,
                  validator: (v) => (v == null || v.trim().length < 2) ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OnboardingField(
                  controller: _stateCtrl,
                  label: 'State',
                  icon: Icons.map_outlined,
                  validator: (v) => (v == null || v.trim().length < 2) ? 'Required' : null,
                ),
              ),
            ]),
            Row(children: [
              Expanded(
                child: OnboardingField(
                  controller: _pincode,
                  label: 'Pincode',
                  icon: Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OnboardingField(
                  controller: _foundedYear,
                  label: 'Founded Year',
                  icon: Icons.calendar_today_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final yr = int.tryParse(v);
                    if (yr == null || yr < 1800 || yr > 2100) return 'Invalid year';
                    return null;
                  },
                ),
              ),
            ]),
            OnboardingField(
              controller: _phone,
              label: 'Academy Phone',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            OnboardingField(
              controller: _email,
              label: 'Academy Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            OnboardingField(
              controller: _website,
              label: 'Website URL',
              icon: Icons.language_rounded,
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleCreate,
              child: _isLoading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text('Create Academy'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
