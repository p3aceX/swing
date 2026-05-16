import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../shared/widgets.dart';
import '../batches/batch_provider.dart';
import '../fees/fee_provider.dart';
import 'student_provider.dart';

const _bloodGroups = ['A+', 'B+', 'O+', 'AB+', 'A-', 'B-', 'O-', 'AB-'];

const _freqLabels = {
  'MONTHLY':   'Monthly',
  'QUARTERLY': 'Quarterly',
  'ANNUAL':    'Annual',
  'ONE_TIME':  'One Time',
};

// ── Sheet entry point ──────────────────────────────────────────────────────────

class EnrollStudentSheet extends ConsumerStatefulWidget {
  final String? batchId;
  final String? batchName;

  const EnrollStudentSheet({super.key, this.batchId, this.batchName});

  @override
  ConsumerState<EnrollStudentSheet> createState() => _EnrollStudentSheetState();
}

class _EnrollStudentSheetState extends ConsumerState<EnrollStudentSheet> {
  final _pageCtrl = PageController();
  int  _step    = 0;
  bool _loading = false;

  // 0 – phone
  final _phoneCtrl = TextEditingController();

  // 1 – profile
  bool? _userFound;
  Map<String, dynamic>? _existingUser;
  final _nameCtrl = TextEditingController();
  DateTime? _dob;
  final _cityCtrl = TextEditingController();

  // 2 – enrollment
  String? _batchId;
  bool     _isTrial     = false;
  DateTime? _trialEndsAt;

  // 3 – fees
  final _feeCtrl      = TextEditingController();
  String _frequency   = 'MONTHLY';
  bool   _feeSeeded   = false;
  bool   _showRegFee  = false;
  final _regFeeCtrl   = TextEditingController();
  String _regFeeMode  = 'CASH';
  bool   _showInitPay = false;
  final _initPayCtrl  = TextEditingController();
  String _payMode     = 'CASH';
  // Cached fetched amounts per frequency for smart swapping
  int _fetchedMonthlyPaise = 0;
  int _fetchedAnnualPaise  = 0;

  // 4 – extras
  String? _bloodGroup;
  final _aadhaarCtrl     = TextEditingController();
  final _parentNameCtrl  = TextEditingController();
  final _parentPhoneCtrl = TextEditingController();
  String? _parentRelation;
  bool    _showEmergency = false;
  final _emergNameCtrl  = TextEditingController();
  final _emergPhoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _batchId = widget.batchId;
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final c in [
      _phoneCtrl, _nameCtrl, _cityCtrl, _feeCtrl,
      _regFeeCtrl, _initPayCtrl, _aadhaarCtrl,
      _parentNameCtrl, _parentPhoneCtrl,
      _emergNameCtrl, _emergPhoneCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  void _to(int step) {
    if (step == 3 && !_feeSeeded && _batchId != null) _seedFeeFromBatch();
    setState(() => _step = step);
    _pageCtrl.animateToPage(step,
        duration: const Duration(milliseconds: 260), curve: Curves.easeInOut);
  }

  void _seedFeeFromBatch() {
    final batchDetailAsync = ref.read(batchDetailProvider(_batchId!));
    if (batchDetailAsync is AsyncData<Map<String, dynamic>>) {
      if (_tryApplyFees((batchDetailAsync.value['feeStructures'] as List?)
          ?.cast<Map<String, dynamic>>())) return;
    }
    ref.read(batchesProvider).whenData((batches) {
      try {
        final batch = batches.firstWhere((b) => b['id'] == _batchId);
        _tryApplyFees((batch['feeStructures'] as List?)?.cast<Map<String, dynamic>>());
      } catch (_) {}
    });
  }

  bool _tryApplyFees(List<Map<String, dynamic>>? fees) {
    if (fees == null || fees.isEmpty) return false;

    int regPaise      = 0;
    int monthlyPaise  = 0;
    int annualPaise   = 0;

    for (final fee in fees) {
      final paise = (fee['amountPaise'] as num?)?.toInt() ?? 0;
      final freq  = fee['frequency'] as String? ?? '';
      if (paise <= 0) continue;
      if (freq == 'REGISTRATION') regPaise     = paise;
      else if (freq == 'MONTHLY') monthlyPaise = paise;
      else if (freq == 'ANNUAL')  annualPaise  = paise;
    }

    if (regPaise == 0 && monthlyPaise == 0 && annualPaise == 0) return false;

    // Determine default recurring frequency
    final defaultFreq = monthlyPaise > 0 ? 'MONTHLY' : 'ANNUAL';
    final defaultPaise = defaultFreq == 'MONTHLY' ? monthlyPaise : annualPaise;

    setState(() {
      _fetchedMonthlyPaise = monthlyPaise;
      _fetchedAnnualPaise  = annualPaise;
      _frequency           = defaultFreq;
      _feeSeeded           = true;
      if (regPaise > 0) _showRegFee = true;
    });

    // Update controllers outside setState (they notify listeners themselves)
    if (regPaise > 0) _regFeeCtrl.text = (regPaise / 100).toStringAsFixed(0);
    if (defaultPaise > 0) _feeCtrl.text = (defaultPaise / 100).toStringAsFixed(0);

    return true;
  }

  Future<void> _lookup() async {
    final phone = _phoneCtrl.text.trim().replaceAll(RegExp(r'\D'), '');
    if (phone.length < 10) { showSnack(context, 'Enter a 10-digit number'); return; }
    setState(() => _loading = true);
    try {
      final res = await Dio().post(
        '$kBackendBaseUrl/auth/check-phone',
        data: {'phone': phone},
      );
      final d     = res.data['data'] as Map<String, dynamic>? ?? {};
      final found = d['exists'] as bool? ?? false;
      setState(() {
        _userFound    = found;
        _existingUser = found ? (d['user'] as Map<String, dynamic>?) : null;
      });
      _to(1);
    } catch (_) {
      if (mounted) showSnack(context, 'Lookup failed — check connection');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_batchId == null) { showSnack(context, 'Select a batch'); return; }

    final phone      = _phoneCtrl.text.trim().replaceAll(RegExp(r'\D'), '');
    final feeRupees  = double.tryParse(_feeCtrl.text.trim()) ?? 0;
    final initRupees = double.tryParse(_initPayCtrl.text.trim()) ?? 0;
    final regRupees  = _showRegFee ? (double.tryParse(_regFeeCtrl.text.trim()) ?? 0) : 0;
    final aadhaar    = _aadhaarCtrl.text.trim();

    if (aadhaar.isNotEmpty && aadhaar.length != 12) {
      showSnack(context, 'Aadhaar must be 12 digits (or leave blank)');
      return;
    }

    final name = _userFound == true
        ? (_existingUser?['name'] as String? ?? _nameCtrl.text.trim())
        : _nameCtrl.text.trim();
    if (name.trim().length < 2) {
      showSnack(context, 'Student name is required (min 2 chars)');
      return;
    }

    final payload = <String, dynamic>{
      'phone':          phone,
      'name':           name,
      'isTrial':        _isTrial,
      'feeAmountPaise': (feeRupees * 100).toInt(),
      'feeFrequency':   _frequency,
      if (_isTrial && _trialEndsAt != null)
        'trialEndsAt': _trialEndsAt!.toIso8601String(),
      if (_dob != null)
        'dateOfBirth': '${_dob!.year}-${_dob!.month.toString().padLeft(2,'0')}-${_dob!.day.toString().padLeft(2,'0')}',
      if (_cityCtrl.text.trim().isNotEmpty) 'city': _cityCtrl.text.trim(),
      if (_bloodGroup != null) 'bloodGroup': _bloodGroup,
      if (aadhaar.length == 12) 'aadhaarLast4': aadhaar.substring(8),
      if (_parentNameCtrl.text.trim().isNotEmpty)
        'parentName': _parentNameCtrl.text.trim(),
      if (_parentPhoneCtrl.text.trim().isNotEmpty)
        'parentPhone': _parentPhoneCtrl.text.trim(),
      if (_parentRelation != null) 'parentRelation': _parentRelation,
      if (_showRegFee && regRupees > 0) ...<String, dynamic>{
        'registrationFeePaise':    (regRupees * 100).toInt(),
        'registrationPaymentMode': _regFeeMode,
      },
      if (_showInitPay && initRupees > 0) ...<String, dynamic>{
        'initialPaymentPaise': (initRupees * 100).toInt(),
        'initialPaymentMode':  _payMode,
      },
      if (_showEmergency && _emergNameCtrl.text.trim().isNotEmpty)
        'emergencyContactName': _emergNameCtrl.text.trim(),
      if (_showEmergency && _emergPhoneCtrl.text.trim().isNotEmpty)
        'emergencyContactPhone': _emergPhoneCtrl.text.trim(),
    };

    setState(() => _loading = true);
    try {
      await ref.read(studentsProvider.notifier).enroll(_batchId!, payload);
      ref.invalidate(batchDetailProvider(_batchId!));
      ref.invalidate(batchesProvider);
      ref.invalidate(paymentsProvider);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceAll('Exception:', '').trim();
        showSnack(context, msg);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Root build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final h  = MediaQuery.of(context).size.height;

    final stepTitles = const [
      'Find Student', 'Profile', 'Enrollment', 'Fee Setup', 'More Details',
    ];

    return SizedBox(
      height: h * 0.92,
      child: Column(
        children: [
          // drag handle
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Row(children: [
              if (_step > 0)
                GestureDetector(
                  onTap: () => _to(_step - 1),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: cs.onSurface),
                )
              else
                const SizedBox(width: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  stepTitles[_step],
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800,
                      color: cs.onSurface, letterSpacing: -0.3),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: cs.onSurface.withValues(alpha: 0.12)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.close_rounded,
                      color: cs.onSurface.withValues(alpha: 0.6), size: 18),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 14),

          // step progress dots
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Row(
              children: List.generate(5, (i) => Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i <= _step
                        ? cs.onSurface
                        : cs.onSurface.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              )),
            ),
          ),

          const SizedBox(height: 4),

          // pages
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep0(),
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 0 — Phone ────────────────────────────────────────────────────────────

  Widget _buildStep0() {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      children: [
        Text("Student's phone number",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.5), letterSpacing: 0.3)),
        const SizedBox(height: 12),
        _OutlinedField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          autofocus: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
              color: cs.onSurface, letterSpacing: 3),
          prefixText: '+91  ',
          hintText: '0000000000',
          hintStyle: TextStyle(fontSize: 24,
              color: cs.onSurface.withValues(alpha: 0.2), letterSpacing: 3),
          onSubmitted: (_) => _lookup(),
        ),
        const SizedBox(height: 28),
        _PrimaryBtn(label: 'Find Student', loading: _loading, onTap: _lookup),
      ],
    );
  }

  // ── Step 1 — Profile ──────────────────────────────────────────────────────────

  Widget _buildStep1() {
    final cs = Theme.of(context).colorScheme;

    if (_userFound == true) {
      final u = _existingUser ?? {};
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          _StatusBanner(
            icon: Icons.check_circle_rounded,
            label: 'Student found',
            color: const Color(0xFF16A34A),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: cs.onSurface.withValues(alpha: 0.10)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(children: [
              _InfoRow(Icons.person_rounded, 'Name', u['name'] as String? ?? '—'),
              Divider(height: 1, thickness: 0.5,
                  indent: 48, color: cs.onSurface.withValues(alpha: 0.08)),
              _InfoRow(Icons.phone_rounded, 'Phone', '+91 ${_phoneCtrl.text.trim()}'),
              if ((u['dateOfBirth'] as String?) != null) ...[
                Divider(height: 1, thickness: 0.5,
                    indent: 48, color: cs.onSurface.withValues(alpha: 0.08)),
                _InfoRow(Icons.cake_rounded, 'DOB', u['dateOfBirth'] as String),
              ],
              if ((u['city'] as String?) != null) ...[
                Divider(height: 1, thickness: 0.5,
                    indent: 48, color: cs.onSurface.withValues(alpha: 0.08)),
                _InfoRow(Icons.location_city_rounded, 'City', u['city'] as String),
              ],
            ]),
          ),
          const SizedBox(height: 24),
          _PrimaryBtn(label: 'Continue', onTap: () => _to(2)),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        _StatusBanner(
          icon: Icons.person_add_rounded,
          label: 'New student — enter details',
          color: const Color(0xFFE65100),
        ),
        const SizedBox(height: 20),
        _Label('FULL NAME *'),
        const SizedBox(height: 6),
        _OutlinedField(controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            hintText: 'e.g. Rahul Sharma'),
        const SizedBox(height: 16),
        _Label('DATE OF BIRTH (optional)'),
        const SizedBox(height: 6),
        _DateRow(
          value: _dob,
          hint: 'Select date of birth',
          onTap: () async {
            final d = await showDatePicker(
              context: context, initialDate: DateTime(2005),
              firstDate: DateTime(1960), lastDate: DateTime.now(),
            );
            if (d != null) setState(() => _dob = d);
          },
        ),
        const SizedBox(height: 16),
        _Label('CITY (optional)'),
        const SizedBox(height: 6),
        _OutlinedField(controller: _cityCtrl, hintText: 'e.g. Bhopal'),
        const SizedBox(height: 28),
        _PrimaryBtn(
          label: 'Continue',
          onTap: () {
            if (_nameCtrl.text.trim().isEmpty) {
              showSnack(context, 'Name is required for new students');
              return;
            }
            _to(2);
          },
        ),
      ],
    );
  }

  // ── Step 2 — Enrollment ───────────────────────────────────────────────────────

  Widget _buildStep2() {
    final cs         = Theme.of(context).colorScheme;
    final batchState = ref.watch(batchesProvider);

    final borderDec = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: cs.onSurface.withValues(alpha: 0.10)),
    );
    final focusDec = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: cs.onSurface, width: 1.5),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [

        // ── Batch dropdown ─────────────────────────────────────────────────
        _Label('BATCH'),
        const SizedBox(height: 8),

        if (widget.batchId != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: cs.onSurface.withValues(alpha: 0.10)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              Icon(Icons.groups_2_rounded, size: 18,
                  color: cs.onSurface.withValues(alpha: 0.45)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(widget.batchName ?? widget.batchId!,
                    style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Pre-selected',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        color: cs.onSurface.withValues(alpha: 0.5))),
              ),
            ]),
          )
        else
          batchState.when(
            loading: () => Container(
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(color: cs.onSurface.withValues(alpha: 0.10)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))),
            ),
            error: (_, __) => Text('Failed to load batches',
                style: TextStyle(color: cs.error, fontSize: 13)),
            data: (batches) {
              if (batches.length == 1 && _batchId == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _feeCtrl.clear();
                    _regFeeCtrl.clear();
                    setState(() {
                      _batchId             = batches[0]['id'] as String;
                      _feeSeeded           = false;
                      _showRegFee          = false;
                      _frequency           = 'MONTHLY';
                      _fetchedMonthlyPaise = 0;
                      _fetchedAnnualPaise  = 0;
                    });
                    _seedFeeFromBatch();
                  }
                });
              }
              return DropdownButtonFormField<String>(
                value: _batchId,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: cs.onSurface.withValues(alpha: 0.45)),
                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: cs.onSurface),
                decoration: InputDecoration(
                  filled: false,
                  hintText: 'Select a batch',
                  hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400,
                      color: cs.onSurface.withValues(alpha: 0.35)),
                  border: borderDec,
                  enabledBorder: borderDec,
                  focusedBorder: focusDec,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                items: batches.map((b) {
                  final name = b['name'] as String? ?? '';
                  final age  = b['ageGroup'] as String?;
                  final label = age != null ? '$name  ·  $age' : name;
                  return DropdownMenuItem<String>(
                    value: b['id'] as String,
                    child: Text(label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w600,
                            color: cs.onSurface, fontSize: 14)),
                  );
                }).toList(),
                onChanged: (v) {
                  _feeCtrl.clear();
                  _regFeeCtrl.clear();
                  setState(() {
                    _batchId              = v;
                    _feeSeeded            = false;
                    _showRegFee           = false;
                    _frequency            = 'MONTHLY';
                    _fetchedMonthlyPaise  = 0;
                    _fetchedAnnualPaise   = 0;
                  });
                  if (v != null) _seedFeeFromBatch();
                },
              );
            },
          ),

        const SizedBox(height: 28),
        Divider(height: 1, thickness: 0.5,
            color: cs.onSurface.withValues(alpha: 0.08)),
        const SizedBox(height: 24),

        // ── Enrollment type ────────────────────────────────────────────────
        _Label('ENROLLMENT TYPE'),
        const SizedBox(height: 12),

        Row(children: [
          Expanded(
            child: _TypeCard(
              icon: Icons.verified_rounded,
              label: 'Full',
              subtitle: 'Regular enrollment',
              selected: !_isTrial,
              onTap: () => setState(() => _isTrial = false),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TypeCard(
              icon: Icons.timelapse_rounded,
              label: 'Trial',
              subtitle: 'Limited period',
              selected: _isTrial,
              onTap: () => setState(() => _isTrial = true),
            ),
          ),
        ]),

        if (_isTrial) ...[
          const SizedBox(height: 20),
          _Label('TRIAL END DATE (optional)'),
          const SizedBox(height: 8),
          _DateRow(
            value: _trialEndsAt,
            hint: 'Pick trial end date',
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

        const SizedBox(height: 32),
        _PrimaryBtn(
          label: 'Continue',
          onTap: () {
            if (_batchId == null) { showSnack(context, 'Select a batch'); return; }
            _to(3);
          },
        ),
      ],
    );
  }

  // ── Step 3 — Fee Setup ────────────────────────────────────────────────────────

  Widget _buildStep3() {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [

        if (_feeSeeded) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.onSurface.withValues(alpha: 0.08)),
            ),
            child: Row(children: [
              Icon(Icons.auto_awesome_rounded, size: 14,
                  color: cs.onSurface.withValues(alpha: 0.45)),
              const SizedBox(width: 8),
              Text('Fee pre-filled from batch — edit if needed',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                      color: cs.onSurface.withValues(alpha: 0.5))),
            ]),
          ),
          const SizedBox(height: 20),
        ],

        _Label('REGISTRATION / ADMISSION FEE'),
        const SizedBox(height: 4),
        Text('One-time fee charged on admission',
            style: TextStyle(fontSize: 12,
                color: cs.onSurface.withValues(alpha: 0.45))),
        const SizedBox(height: 10),
        _CheckRow(
          checked: _showRegFee,
          label: 'Collect registration fee now',
          onTap: () => setState(() => _showRegFee = !_showRegFee),
        ),
        if (_showRegFee) ...[
          const SizedBox(height: 12),
          _OutlinedField(
            controller: _regFeeCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: cs.onSurface),
            prefixText: '₹  ',
            hintText: '0',
          ),
          const SizedBox(height: 12),
          _Label('PAYMENT MODE'),
          const SizedBox(height: 8),
          _ModeChips(
            modes: kPaymentModes,
            selected: _regFeeMode,
            onSelect: (m) => setState(() => _regFeeMode = m),
          ),
        ],

        const SizedBox(height: 20),
        Divider(height: 1, thickness: 0.5,
            color: cs.onSurface.withValues(alpha: 0.08)),
        const SizedBox(height: 20),

        _Label('RECURRING FEE AMOUNT'),
        const SizedBox(height: 6),
        _OutlinedField(
          controller: _feeCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: cs.onSurface),
          prefixText: '₹  ',
          hintText: '0',
        ),

        const SizedBox(height: 20),
        _Label('FREQUENCY'),
        const SizedBox(height: 8),
        Row(children: [
          _FreqChip(
            label: 'Monthly',
            sublabel: _fetchedMonthlyPaise > 0
                ? '₹${(_fetchedMonthlyPaise / 100).toStringAsFixed(0)}'
                : null,
            selected: _frequency == 'MONTHLY',
            onTap: () => setState(() {
              _frequency = 'MONTHLY';
              if (_fetchedMonthlyPaise > 0) {
                _feeCtrl.text = (_fetchedMonthlyPaise / 100).toStringAsFixed(0);
              }
            }),
          ),
          const SizedBox(width: 10),
          _FreqChip(
            label: 'Yearly',
            sublabel: _fetchedAnnualPaise > 0
                ? '₹${(_fetchedAnnualPaise / 100).toStringAsFixed(0)}'
                : null,
            selected: _frequency == 'ANNUAL',
            onTap: () => setState(() {
              _frequency = 'ANNUAL';
              if (_fetchedAnnualPaise > 0) {
                _feeCtrl.text = (_fetchedAnnualPaise / 100).toStringAsFixed(0);
              }
            }),
          ),
        ]),

        const SizedBox(height: 20),
        _CheckRow(
          checked: _showInitPay,
          label: 'Collect first month fee now',
          onTap: () {
            final nowShowing = !_showInitPay;
            setState(() => _showInitPay = nowShowing);
            if (nowShowing && _initPayCtrl.text.trim().isEmpty) {
              // Auto-fill: recurring fee + registration fee
              final recurringRupees = double.tryParse(_feeCtrl.text.trim()) ?? 0;
              final regRupees       = double.tryParse(_regFeeCtrl.text.trim()) ?? 0;
              final total           = recurringRupees + regRupees;
              if (total > 0) {
                _initPayCtrl.text = total.toStringAsFixed(0);
              }
            }
          },
        ),
        if (_showInitPay) ...[
          const SizedBox(height: 14),
          _OutlinedField(
            controller: _initPayCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
            prefixText: '₹  ',
            hintText: 'Amount paid',
          ),
          const SizedBox(height: 12),
          _Label('PAYMENT MODE'),
          const SizedBox(height: 8),
          _ModeChips(
            modes: kPaymentModes,
            selected: _payMode,
            onSelect: (m) => setState(() => _payMode = m),
          ),
        ],

        const SizedBox(height: 28),
        _PrimaryBtn(label: 'Continue', onTap: () => _to(4)),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => _to(4),
            child: Text('Skip fees for now',
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4),
                    fontSize: 13)),
          ),
        ),
      ],
    );
  }

  // ── Step 4 — Extra Details ────────────────────────────────────────────────────

  Widget _buildStep4() {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        _Label('PARENT / GUARDIAN'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: ['Father', 'Mother', 'Guardian'].map((r) {
            final sel = _parentRelation == r;
            return GestureDetector(
              onTap: () => setState(
                  () => _parentRelation = _parentRelation == r ? null : r),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: sel ? cs.onSurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: sel
                          ? cs.onSurface
                          : cs.onSurface.withValues(alpha: 0.12)),
                ),
                child: Text(r,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                        color: sel ? cs.surface : cs.onSurface)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        _OutlinedField(controller: _parentNameCtrl,
            textCapitalization: TextCapitalization.words,
            hintText: 'Parent / Guardian name'),
        const SizedBox(height: 10),
        _OutlinedField(
          controller: _parentPhoneCtrl,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          hintText: 'Parent phone number',
        ),

        const SizedBox(height: 20),
        _Label('AADHAAR NUMBER (optional)'),
        const SizedBox(height: 6),
        _OutlinedField(
          controller: _aadhaarCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
          hintText: '12-digit Aadhaar (optional)',
        ),

        const SizedBox(height: 20),
        _Label('BLOOD GROUP (optional)'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _bloodGroups.map((g) {
            final sel = _bloodGroup == g;
            return GestureDetector(
              onTap: () => setState(
                  () => _bloodGroup = _bloodGroup == g ? null : g),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFFC62828) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: sel
                          ? const Color(0xFFC62828)
                          : cs.onSurface.withValues(alpha: 0.12)),
                ),
                child: Text(g,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                        color: sel ? Colors.white : cs.onSurface)),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),
        _CheckRow(
          checked: _showEmergency,
          label: 'Add emergency contact',
          onTap: () => setState(() => _showEmergency = !_showEmergency),
        ),
        if (_showEmergency) ...[
          const SizedBox(height: 14),
          _OutlinedField(controller: _emergNameCtrl,
              textCapitalization: TextCapitalization.words,
              hintText: 'Contact name'),
          const SizedBox(height: 10),
          _OutlinedField(
            controller: _emergPhoneCtrl,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            hintText: 'Contact phone',
          ),
        ],

        const SizedBox(height: 32),
        _PrimaryBtn(label: 'Enroll Student', loading: _loading, onTap: _submit),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: _loading ? null : _submit,
            child: Text('Skip & Enroll',
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4),
                    fontSize: 13)),
          ),
        ),
      ],
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _FreqChip extends StatelessWidget {
  final String label;
  final String? sublabel;
  final bool selected;
  final VoidCallback onTap;

  const _FreqChip({required this.label, required this.sublabel,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? cs.onSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? cs.onSurface : cs.onSurface.withValues(alpha: 0.12)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: selected ? cs.surface : cs.onSurface)),
            if (sublabel != null) ...[
              const SizedBox(height: 2),
              Text(sublabel!,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: selected
                          ? cs.surface.withValues(alpha: 0.6)
                          : cs.onSurface.withValues(alpha: 0.45))),
            ],
          ]),
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon, required this.label, required this.subtitle,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? cs.onSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected
                  ? cs.onSurface
                  : cs.onSurface.withValues(alpha: 0.12),
              width: 1),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon,
              color: selected
                  ? cs.surface
                  : cs.onSurface.withValues(alpha: 0.45),
              size: 26),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15,
                  color: selected ? cs.surface : cs.onSurface)),
          Text(subtitle,
              style: TextStyle(fontSize: 11,
                  color: selected
                      ? cs.surface.withValues(alpha: 0.6)
                      : cs.onSurface.withValues(alpha: 0.45))),
        ]),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;

  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, size: 16, color: cs.onSurface.withValues(alpha: 0.4)),
        const SizedBox(width: 12),
        SizedBox(
          width: 56,
          child: Text(label,
              style: TextStyle(fontSize: 13,
                  color: cs.onSurface.withValues(alpha: 0.45))),
        ),
        Expanded(
          child: Text(value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                  color: cs.onSurface)),
        ),
      ]),
    );
  }
}

class _DateRow extends StatelessWidget {
  final DateTime? value;
  final String hint;
  final VoidCallback onTap;

  const _DateRow({required this.value, required this.hint, required this.onTap});

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2,'0')} / ${d.month.toString().padLeft(2,'0')} / ${d.year}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: cs.onSurface.withValues(alpha: 0.10)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(Icons.calendar_today_rounded, size: 16,
              color: cs.onSurface.withValues(alpha: 0.4)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value == null ? hint : _fmt(value!),
              style: TextStyle(
                fontSize: 14,
                color: value == null
                    ? cs.onSurface.withValues(alpha: 0.35)
                    : cs.onSurface,
                fontWeight: value == null ? FontWeight.normal : FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 18,
              color: cs.onSurface.withValues(alpha: 0.3)),
        ]),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusBanner({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withValues(alpha: 0.20)),
    ),
    child: Row(children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700,
          fontSize: 13)),
    ]),
  );
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onTap;

  const _PrimaryBtn({required this.label, this.loading = false, this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 52,
    child: ElevatedButton(
      onPressed: loading ? null : onTap,
      child: loading
          ? const SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
    ),
  );
}

class _CheckRow extends StatelessWidget {
  final bool checked;
  final String label;
  final VoidCallback onTap;

  const _CheckRow({required this.checked, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Row(children: [
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
            color: checked ? cs.onSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: checked
                    ? cs.onSurface
                    : cs.onSurface.withValues(alpha: 0.20)),
          ),
          child: checked
              ? Icon(Icons.check_rounded, color: cs.surface, size: 14)
              : null,
        ),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(fontWeight: FontWeight.w600,
                color: cs.onSurface, fontSize: 14)),
      ]),
    );
  }
}

class _ModeChips extends StatelessWidget {
  final List<String> modes;
  final String selected;
  final ValueChanged<String> onSelect;

  const _ModeChips({required this.modes, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: modes.map((m) {
        final sel = selected == m;
        return GestureDetector(
          onTap: () => onSelect(m),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: sel ? cs.onSurface : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: sel
                      ? cs.onSurface
                      : cs.onSurface.withValues(alpha: 0.12)),
            ),
            child: Text(m,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: sel ? cs.surface : cs.onSurface)),
          ),
        );
      }).toList(),
    );
  }
}

// ── Outlined text field (no fill, themed border) ───────────────────────────────

class _OutlinedField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final String? prefixText;
  final String? hintText;
  final TextStyle? hintStyle;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  const _OutlinedField({
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.prefixText,
    this.hintText,
    this.hintStyle,
    this.autofocus = false,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      autofocus: autofocus,
      style: style ?? TextStyle(fontSize: 15, color: cs.onSurface),
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        prefixText: prefixText,
        prefixStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
            color: cs.onSurface.withValues(alpha: 0.45)),
        hintText: hintText,
        hintStyle: hintStyle ??
            TextStyle(color: cs.onSurface.withValues(alpha: 0.3)),
        filled: false,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: cs.onSurface.withValues(alpha: 0.10))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: cs.onSurface.withValues(alpha: 0.10))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.onSurface, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

Widget _Label(String text) {
  return Builder(builder: (context) {
    final cs = Theme.of(context).colorScheme;
    return Text(text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: cs.onSurface.withValues(alpha: 0.45), letterSpacing: 0.8));
  });
}
