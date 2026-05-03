import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/secure_storage.dart';
import '../../shared/onboarding_widgets.dart';
import '../../shared/widgets.dart';

class AcademyRegistrationScreen extends ConsumerStatefulWidget {
  const AcademyRegistrationScreen({super.key});

  @override
  ConsumerState<AcademyRegistrationScreen> createState() => _AcademyRegistrationScreenState();
}

class _AcademyRegistrationScreenState extends ConsumerState<AcademyRegistrationScreen> {
  final _formKey  = GlobalKey<FormState>();
  bool _isLoading = false;

  final _name        = TextEditingController();
  final _city        = TextEditingController();
  final _stateCtrl   = TextEditingController();
  final _description = TextEditingController();
  final _tagline     = TextEditingController();
  final _address     = TextEditingController();
  final _pincode     = TextEditingController();
  final _phone       = TextEditingController();
  final _email       = TextEditingController();
  final _website     = TextEditingController();
  final _foundedYear = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _name, _city, _stateCtrl, _description, _tagline,
      _address, _pincode, _phone, _email, _website, _foundedYear,
    ]) {
      c.dispose();
    }
    super.dispose();
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
      addOpt('description', _description.text.trim());
      addOpt('tagline',     _tagline.text.trim());
      addOpt('address',     _address.text.trim());
      addOpt('pincode',     _pincode.text.trim());
      addOpt('phone',       _phone.text.trim());
      addOpt('email',       _email.text.trim());
      addOpt('websiteUrl',  _website.text.trim());
      if (_foundedYear.text.trim().isNotEmpty) {
        body['foundedYear'] = int.tryParse(_foundedYear.text.trim());
      }

      final res = await dio.post('$kBackendBaseUrl/biz/academy', data: body);
      if (!mounted) return;

      if ((res.statusCode ?? 0) >= 200 && (res.statusCode ?? 0) < 300) {
        final data      = res.data['data'] as Map<String, dynamic>;
        final academyId = data['id'] as String?;
        if (academyId != null) {
          await ref.read(secureStorageProvider).saveAcademyId(academyId);
        }
        context.go('/home');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final code = e.response?.data?['code'] as String?;
      if (code == 'BUSINESS_DETAILS_REQUIRED') {
        showSnack(context, 'Please complete business details first');
        context.go('/business-details');
      } else {
        showSnack(context, e.response?.data?['message'] ?? 'Failed to create academy. Try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F2EB),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Academy Setup', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            const OnboardingProgressBar(step: 2),
            const SizedBox(height: 32),
            const OnboardingSectionLabel(label: 'Academy Information', required: true),
            const SizedBox(height: 16),
            OnboardingField(
              controller: _name,
              label: 'Academy Name',
              icon: Icons.sports_cricket_rounded,
              validator: (v) => (v == null || v.trim().length < 2) ? 'Required (min 2 chars)' : null,
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
            OnboardingField(controller: _tagline, label: 'Tagline', icon: Icons.format_quote_rounded),
            OnboardingField(controller: _description, label: 'About Academy', icon: Icons.description_outlined, maxLines: 3),
            const SizedBox(height: 8),
            const OnboardingSectionLabel(label: 'Contact & Location'),
            const SizedBox(height: 16),
            OnboardingField(controller: _address, label: 'Address', icon: Icons.location_on_outlined, maxLines: 2),
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
            OnboardingField(controller: _phone, label: 'Academy Phone', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            OnboardingField(controller: _email, label: 'Academy Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            OnboardingField(controller: _website, label: 'Website URL', icon: Icons.language_rounded, keyboardType: TextInputType.url),
            const SizedBox(height: 40),
            SizedBox(
              height: 58,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF071B3D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Create Academy', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
