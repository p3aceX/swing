import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/secure_storage.dart';
import '../../providers/auth_provider.dart';
import '../../shared/onboarding_widgets.dart';
import '../../shared/widgets.dart';

class BusinessDetailsScreen extends ConsumerStatefulWidget {
  const BusinessDetailsScreen({super.key});

  @override
  ConsumerState<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends ConsumerState<BusinessDetailsScreen> {
  final _formKey    = GlobalKey<FormState>();
  bool _isLoading   = false;
  bool _showBanking = false;

  // Section A
  final _businessName = TextEditingController();
  final _contactName  = TextEditingController();
  final _phone        = TextEditingController();
  final _email        = TextEditingController();
  final _city         = TextEditingController();
  final _stateCtrl    = TextEditingController();
  final _address      = TextEditingController();
  final _pincode      = TextEditingController();

  // Section B
  final _gstNumber       = TextEditingController();
  final _panNumber       = TextEditingController();
  final _beneficiaryName = TextEditingController();
  final _accountNumber   = TextEditingController();
  final _ifscCode        = TextEditingController();
  final _upiId           = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _businessName, _contactName, _phone, _email, _city, _stateCtrl,
      _address, _pincode, _gstNumber, _panNumber, _beneficiaryName,
      _accountNumber, _ifscCode, _upiId,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final token = ref.read(secureStorageProvider).cachedAccessToken;
      final dio   = Dio(BaseOptions(headers: {'Authorization': 'Bearer $token'}));

      final body = <String, dynamic>{'businessName': _businessName.text.trim()};
      void addOpt(String k, String v) { if (v.isNotEmpty) body[k] = v; }
      addOpt('contactName', _contactName.text.trim());
      addOpt('phone',       _phone.text.trim());
      addOpt('email',       _email.text.trim());
      addOpt('city',        _city.text.trim());
      addOpt('state',       _stateCtrl.text.trim());
      addOpt('address',     _address.text.trim());
      addOpt('pincode',     _pincode.text.trim());
      addOpt('gstNumber',   _gstNumber.text.trim().toUpperCase());
      addOpt('panNumber',   _panNumber.text.trim().toUpperCase());
      addOpt('beneficiaryName', _beneficiaryName.text.trim());
      addOpt('accountNumber',   _accountNumber.text.trim());
      addOpt('ifscCode',        _ifscCode.text.trim().toUpperCase());
      addOpt('upiId',           _upiId.text.trim());

      await dio.put('$kBackendBaseUrl/biz/business-details', data: body);
      if (!mounted) return;
      context.go('/academy-setup');
    } on DioException catch (e) {
      if (mounted) showSnack(context, e.response?.data?['message'] ?? 'Failed to save. Try again.');
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
        title: const Text('Business Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            const OnboardingProgressBar(step: 1),
            const SizedBox(height: 32),
            const OnboardingSectionLabel(label: 'Basic Information', required: true),
            const SizedBox(height: 16),
            OnboardingField(
              controller: _businessName,
              label: 'Business / Academy Name',
              icon: Icons.business_rounded,
              validator: (v) => (v == null || v.trim().length < 2) ? 'Required (min 2 chars)' : null,
            ),
            OnboardingField(controller: _contactName, label: 'Contact Person Name', icon: Icons.person_outline_rounded),
            OnboardingField(controller: _phone, label: 'Contact Phone', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            OnboardingField(controller: _email, label: 'Contact Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            Row(children: [
              Expanded(child: OnboardingField(controller: _city, label: 'City', icon: Icons.location_city_rounded)),
              const SizedBox(width: 12),
              Expanded(child: OnboardingField(controller: _stateCtrl, label: 'State', icon: Icons.map_outlined)),
            ]),
            OnboardingField(controller: _address, label: 'Address', icon: Icons.location_on_outlined, maxLines: 2),
            OnboardingField(
              controller: _pincode,
              label: 'Pincode',
              icon: Icons.pin_drop_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            // Banking collapsible
            GestureDetector(
              onTap: () => setState(() => _showBanking = !_showBanking),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0DED6)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0057C8).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.account_balance_rounded, color: Color(0xFF0057C8), size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tax & Banking Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          Text('GST, PAN, Bank Account (optional)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(
                      _showBanking ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            if (_showBanking) ...[
              const SizedBox(height: 12),
              OnboardingField(controller: _gstNumber, label: 'GST Number', icon: Icons.receipt_rounded, uppercase: true),
              OnboardingField(controller: _panNumber, label: 'PAN Number', icon: Icons.credit_card_rounded, uppercase: true),
              OnboardingField(controller: _beneficiaryName, label: 'Account Holder Name', icon: Icons.person_outline_rounded),
              OnboardingField(
                controller: _accountNumber,
                label: 'Bank Account Number',
                icon: Icons.account_balance_wallet_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              OnboardingField(controller: _ifscCode, label: 'IFSC Code', icon: Icons.code_rounded, uppercase: true),
              OnboardingField(controller: _upiId, label: 'UPI ID', icon: Icons.payments_outlined),
            ],
            const SizedBox(height: 40),
            SizedBox(
              height: 58,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF071B3D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Save & Continue', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
