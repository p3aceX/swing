import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/constants.dart';
import '../../shared/widgets.dart';
import '../batches/batch_provider.dart';
import 'student_provider.dart';

class EnrollStudentSheet extends ConsumerStatefulWidget {
  const EnrollStudentSheet({super.key});

  @override
  ConsumerState<EnrollStudentSheet> createState() => _EnrollStudentSheetState();
}

class _EnrollStudentSheetState extends ConsumerState<EnrollStudentSheet> {
  final _dio = Dio();
  int _step = 0;
  bool _isLoading = false;

  // Step 1
  final _phoneCtrl = TextEditingController();
  String? _studentName;

  // Step 2
  String? _selectedBatchId;
  bool _isTrial = false;
  DateTime? _trialEndsAt;

  // Step 3
  final _feeAmountCtrl = TextEditingController();
  String _feeFrequency = kFeeFrequencies.first;
  final _initialPaymentCtrl = TextEditingController();
  String _paymentMode = kPaymentModes.first;

  // Step 4
  final _bloodGroupCtrl = TextEditingController();
  final _aadhaarCtrl = TextEditingController();
  DateTime? _dob;
  final _cityCtrl = TextEditingController();
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _feeAmountCtrl.dispose();
    _initialPaymentCtrl.dispose();
    _bloodGroupCtrl.dispose();
    _aadhaarCtrl.dispose();
    _cityCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _lookupPhone() async {
    final phone = _phoneCtrl.text.trim().replaceAll(RegExp(r'\D'), '');
    if (phone.length < 10) {
      showSnack(context, 'Enter a valid phone number');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final res = await _dio.post('$kBackendBaseUrl/auth/check-phone', data: {'phone': phone});
      if (res.data['data']['exists'] == true) {
        final userData = res.data['data']['user'] as Map<String, dynamic>?;
        setState(() {
          _studentName = userData?['name'] as String?;
        });
      }
      setState(() => _step = 1);
    } catch (e) {
      showSnack(context, 'Lookup failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedBatchId == null) {
      showSnack(context, 'Select a batch');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final payload = {
        'phone': _phoneCtrl.text.trim().replaceAll(RegExp(r'\D'), ''),
        'isTrial': _isTrial,
        if (_trialEndsAt != null)
          'trialEndsAt': _trialEndsAt!.toIso8601String(),
        'feeAmountPaise': (double.tryParse(_feeAmountCtrl.text) ?? 0) * 100,
        'feeFrequency': _feeFrequency,
        if (_initialPaymentCtrl.text.isNotEmpty)
          'initialPaymentPaise': (double.tryParse(_initialPaymentCtrl.text) ?? 0) * 100,
        'initialPaymentMode': _paymentMode,
        if (_bloodGroupCtrl.text.isNotEmpty) 'bloodGroup': _bloodGroupCtrl.text.trim(),
        if (_aadhaarCtrl.text.isNotEmpty) 'aadhaarLast4': _aadhaarCtrl.text.trim(),
        if (_dob != null) 'dateOfBirth': _dob!.toIso8601String(),
        if (_cityCtrl.text.isNotEmpty) 'city': _cityCtrl.text.trim(),
        if (_emergencyNameCtrl.text.isNotEmpty)
          'emergencyContactName': _emergencyNameCtrl.text.trim(),
        if (_emergencyPhoneCtrl.text.isNotEmpty)
          'emergencyContactPhone': _emergencyPhoneCtrl.text.trim(),
      };
      await ref.read(studentsProvider.notifier).enroll(_selectedBatchId!, payload);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showSnack(context, 'Enrollment failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_step > 0)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    onPressed: () => setState(() => _step--),
                    padding: EdgeInsets.zero,
                  ),
                Text(
                  ['Find Student', 'Batch & Trial', 'Fee Setup', 'Student Details'][_step],
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text('${_step + 1}/4',
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_step == 0) _Step1(),
            if (_step == 1) _Step2(),
            if (_step == 2) _Step3(),
            if (_step == 3) _Step4(),
          ],
        ),
      ),
    );
  }

  Widget _Step1() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Student Phone Number'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _lookupPhone,
            child: const Text('Look Up'),
          ),
        ],
      );

  Widget _Step2() {
    final batchState = ref.watch(batchesProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_studentName != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('Student: $_studentName',
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        batchState.when(
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Text('Failed to load batches'),
          data: (batches) => DropdownButtonFormField<String>(
            value: _selectedBatchId,
            decoration: const InputDecoration(labelText: 'Select Batch *'),
            items: batches
                .map((b) => DropdownMenuItem(
                    value: b['id'] as String, child: Text(b['name'] as String? ?? '')))
                .toList(),
            onChanged: (v) => setState(() => _selectedBatchId = v),
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Trial Enrollment'),
          value: _isTrial,
          onChanged: (v) => setState(() => _isTrial = v),
        ),
        if (_isTrial) ...[
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Trial Ends At'),
            subtitle: Text(_trialEndsAt == null
                ? 'Pick date'
                : '${_trialEndsAt!.day}/${_trialEndsAt!.month}/${_trialEndsAt!.year}'),
            trailing: const Icon(Icons.calendar_today_outlined, size: 18),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (d != null) setState(() => _trialEndsAt = d);
            },
          ),
        ],
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _selectedBatchId == null ? null : () => setState(() => _step = 2),
          child: const Text('Next'),
        ),
      ],
    );
  }

  Widget _Step3() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _feeAmountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Fee Amount (₹)', prefixText: '₹ '),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _feeFrequency,
            decoration: const InputDecoration(labelText: 'Fee Frequency'),
            items: kFeeFrequencies
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (v) => setState(() => _feeFrequency = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _initialPaymentCtrl,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Initial Payment (₹, optional)', prefixText: '₹ '),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _paymentMode,
            decoration: const InputDecoration(labelText: 'Payment Mode'),
            items: kPaymentModes
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (v) => setState(() => _paymentMode = v!),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() => _step = 3),
            child: const Text('Next'),
          ),
        ],
      );

  Widget _Step4() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _bloodGroupCtrl,
            decoration: const InputDecoration(labelText: 'Blood Group (optional)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _aadhaarCtrl,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration:
                const InputDecoration(labelText: 'Aadhaar Last 4 (optional)', counterText: ''),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date of Birth'),
            subtitle: Text(_dob == null
                ? 'Optional'
                : '${_dob!.day}/${_dob!.month}/${_dob!.year}'),
            trailing: const Icon(Icons.calendar_today_outlined, size: 18),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: DateTime(2005),
                firstDate: DateTime(1980),
                lastDate: DateTime.now(),
              );
              if (d != null) setState(() => _dob = d);
            },
          ),
          const Divider(),
          TextField(
            controller: _cityCtrl,
            decoration: const InputDecoration(labelText: 'City (optional)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emergencyNameCtrl,
            decoration:
                const InputDecoration(labelText: 'Emergency Contact Name (optional)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emergencyPhoneCtrl,
            keyboardType: TextInputType.phone,
            decoration:
                const InputDecoration(labelText: 'Emergency Contact Phone (optional)'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Enroll Student'),
          ),
        ],
      );
}
