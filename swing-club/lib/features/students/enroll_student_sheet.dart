import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../shared/widgets.dart';
import '../batches/batch_provider.dart';
import 'student_provider.dart';

const _kNavy   = Color(0xFF071B3D);
const _kBlue   = Color(0xFF0057C8);
const _kBorder = Color(0xFFE0DED6);
const _kBg     = Color(0xFFF4F2EB);

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
  bool   _showInitPay = false;
  final _initPayCtrl  = TextEditingController();
  String _payMode     = 'CASH';

  // 4 – extras
  String? _bloodGroup;
  final _aadhaarCtrl    = TextEditingController();
  // parent
  final _parentNameCtrl  = TextEditingController();
  final _parentPhoneCtrl = TextEditingController();
  String? _parentRelation;
  // emergency
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
      _initPayCtrl, _aadhaarCtrl,
      _parentNameCtrl, _parentPhoneCtrl,
      _emergNameCtrl, _emergPhoneCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  // ── Navigation ───────────────────────────────────────────────────────────────

  void _to(int step) {
    if (step == 3 && !_feeSeeded && _batchId != null) {
      _seedFeeFromBatch();
    }
    setState(() => _step = step);
    _pageCtrl.animateToPage(step,
        duration: const Duration(milliseconds: 280), curve: Curves.easeInOut);
  }

  void _seedFeeFromBatch() {
    final batchAsync = ref.read(batchDetailProvider(_batchId!));
    batchAsync.whenData((batch) {
      final fees = (batch['feeStructures'] as List?)
          ?.cast<Map<String, dynamic>>();
      if (fees == null || fees.isEmpty) return;
      final fee          = fees.first;
      final amountPaise  = fee['amountPaise'] as int?;
      final frequency    = fee['frequency'] as String?;
      if (amountPaise != null) {
        _feeCtrl.text = (amountPaise / 100).toStringAsFixed(0);
        _feeSeeded = true;
      }
      if (frequency != null && kFeeFrequencies.contains(frequency)) {
        _frequency = frequency;
      }
    });
  }

  // ── API calls ─────────────────────────────────────────────────────────────────

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
    if (_aadhaarCtrl.text.trim().length != 12) {
      showSnack(context, 'Enter a valid 12-digit Aadhaar number');
      return;
    }
    final phone      = _phoneCtrl.text.trim().replaceAll(RegExp(r'\D'), '');
    final feeRupees  = double.tryParse(_feeCtrl.text.trim()) ?? 0;
    final initRupees = double.tryParse(_initPayCtrl.text.trim()) ?? 0;

    final payload = <String, dynamic>{
      'phone':          phone,
      'isTrial':        _isTrial,
      'feeAmountPaise': (feeRupees * 100).toInt(),
      'feeFrequency':   _frequency,
      if (_isTrial && _trialEndsAt != null)
        'trialEndsAt': _trialEndsAt!.toIso8601String(),
      'name': _userFound == true
          ? (_existingUser?['name'] as String? ?? '')
          : _nameCtrl.text.trim(),
      if (_dob != null)
        'dateOfBirth': '${_dob!.year}-${_dob!.month.toString().padLeft(2,'0')}-${_dob!.day.toString().padLeft(2,'0')}',
      if (_cityCtrl.text.trim().isNotEmpty) 'city': _cityCtrl.text.trim(),
      if (_bloodGroup != null) 'bloodGroup': _bloodGroup,
      'aadhaarNumber': _aadhaarCtrl.text.trim(),
      if (_parentNameCtrl.text.trim().isNotEmpty)
        'parentName': _parentNameCtrl.text.trim(),
      if (_parentPhoneCtrl.text.trim().isNotEmpty)
        'parentPhone': _parentPhoneCtrl.text.trim(),
      if (_parentRelation != null) 'parentRelation': _parentRelation,
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
    final h = MediaQuery.of(context).size.height;
    return SizedBox(
      height: h * 0.92,
      child: Column(
        children: [
          // drag handle
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: _kBorder, borderRadius: BorderRadius.circular(2)),
          ),
          // header row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Row(children: [
              if (_step > 0)
                GestureDetector(
                  onTap: () => _to(_step - 1),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: _kNavy),
                )
              else
                const SizedBox(width: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  const [
                    'Find Student',
                    'Profile',
                    'Enrollment',
                    'Fee Setup',
                    'More Details',
                  ][_step],
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800, color: _kNavy),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close_rounded, color: Colors.grey, size: 22),
              ),
            ]),
          ),
          // 5-segment progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Row(
              children: List.generate(5, (i) => Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i <= _step ? _kNavy : _kBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              )),
            ),
          ),
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

  Widget _buildStep0() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
    children: [
      const Text(
        "Student's phone number",
        style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        autofocus: true,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        style: const TextStyle(
            fontSize: 24, fontWeight: FontWeight.w800,
            color: _kNavy, letterSpacing: 3),
        decoration: InputDecoration(
          prefixText: '+91  ',
          prefixStyle: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
          hintText: '0000000000',
          hintStyle: const TextStyle(
              fontSize: 24, color: Color(0xFFDDDDDD), letterSpacing: 3),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _kBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _kBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _kNavy, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
        onSubmitted: (_) => _lookup(),
      ),
      const SizedBox(height: 28),
      _PrimaryButton(
          label: 'Find Student', loading: _loading, onTap: _lookup),
    ],
  );

  // ── Step 1 — Profile ──────────────────────────────────────────────────────────

  Widget _buildStep1() {
    if (_userFound == true) {
      final u = _existingUser ?? {};
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          _Banner(
            icon: Icons.check_circle_rounded,
            label: 'Student found',
            color: const Color(0xFF2E7D32),
            bg: const Color(0xFFE8F5E9),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBorder),
            ),
            child: Column(children: [
              _InfoTile(Icons.person_rounded, 'Name',
                  u['name'] as String? ?? '—'),
              const Divider(height: 1, indent: 48),
              _InfoTile(Icons.phone_rounded, 'Phone',
                  '+91 ${_phoneCtrl.text.trim()}'),
              if ((u['dateOfBirth'] as String?) != null) ...[
                const Divider(height: 1, indent: 48),
                _InfoTile(Icons.cake_rounded, 'DOB',
                    u['dateOfBirth'] as String),
              ],
              if ((u['city'] as String?) != null) ...[
                const Divider(height: 1, indent: 48),
                _InfoTile(Icons.location_city_rounded, 'City',
                    u['city'] as String),
              ],
            ]),
          ),
          const SizedBox(height: 24),
          _PrimaryButton(label: 'Continue', onTap: () => _to(2)),
        ],
      );
    }

    // ── New user form ──────────────────────────────────────────────────────────
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        _Banner(
          icon: Icons.person_add_rounded,
          label: 'New student — enter details',
          color: const Color(0xFFE65100),
          bg: const Color(0xFFFFF3E0),
        ),
        const SizedBox(height: 20),
        _SectionLabel('FULL NAME *'),
        const SizedBox(height: 6),
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: _inputDec('e.g. Rahul Sharma'),
        ),
        const SizedBox(height: 16),
        _SectionLabel('DATE OF BIRTH (optional)'),
        const SizedBox(height: 6),
        _DateRow(
          value: _dob,
          hint: 'Select date of birth',
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: DateTime(2005),
              firstDate: DateTime(1960),
              lastDate: DateTime.now(),
            );
            if (d != null) setState(() => _dob = d);
          },
        ),
        const SizedBox(height: 16),
        _SectionLabel('CITY (optional)'),
        const SizedBox(height: 6),
        TextField(
          controller: _cityCtrl,
          decoration: _inputDec('e.g. Bhopal'),
        ),
        const SizedBox(height: 28),
        _PrimaryButton(
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
    final batchState = ref.watch(batchesProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        _SectionLabel('BATCH'),
        const SizedBox(height: 8),
        if (widget.batchId != null)
          // Pre-filled pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: Row(children: [
              const Icon(Icons.groups_rounded, color: _kBlue, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.batchName ?? widget.batchId!,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: _kNavy),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Selected',
                    style: TextStyle(
                        fontSize: 10, color: _kBlue,
                        fontWeight: FontWeight.w700)),
              ),
            ]),
          )
        else
          // Batch selector
          batchState.when(
            loading: loadingBody,
            error: (_, __) => const Text('Failed to load batches',
                style: TextStyle(color: Colors.red)),
            data: (batches) => Column(
              children: batches.map((b) {
                final id  = b['id'] as String;
                final sel = _batchId == id;
                return GestureDetector(
                  onTap: () => setState(() => _batchId = id),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: sel ? _kNavy : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: sel ? _kNavy : _kBorder,
                          width: sel ? 0 : 1),
                    ),
                    child: Row(children: [
                      Icon(Icons.groups_rounded,
                          color: sel ? Colors.white : Colors.grey, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b['name'] as String? ?? '',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: sel ? Colors.white : _kNavy),
                            ),
                            if ((b['ageGroup'] as String?) != null)
                              Text(b['ageGroup'] as String,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: sel
                                          ? Colors.white70
                                          : Colors.grey)),
                          ],
                        ),
                      ),
                      if (sel)
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 18),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),

        const SizedBox(height: 24),
        _SectionLabel('ENROLLMENT TYPE'),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: _TypeCard(
              icon: Icons.star_rounded,
              label: 'Full',
              subtitle: 'Regular',
              selected: !_isTrial,
              onTap: () => setState(() => _isTrial = false),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TypeCard(
              icon: Icons.timer_outlined,
              label: 'Trial',
              subtitle: 'Limited period',
              selected: _isTrial,
              onTap: () => setState(() => _isTrial = true),
            ),
          ),
        ]),

        if (_isTrial) ...[
          const SizedBox(height: 16),
          _SectionLabel('TRIAL END DATE (optional)'),
          const SizedBox(height: 6),
          _DateRow(
            value: _trialEndsAt,
            hint: 'Pick trial end date',
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate:
                    DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now()
                    .add(const Duration(days: 365)),
              );
              if (d != null) setState(() => _trialEndsAt = d);
            },
          ),
        ],

        const SizedBox(height: 28),
        _PrimaryButton(
          label: 'Continue',
          onTap: () {
            if (_batchId == null) {
              showSnack(context, 'Select a batch');
              return;
            }
            _to(3);
          },
        ),
      ],
    );
  }

  // ── Step 3 — Fee Setup ────────────────────────────────────────────────────────

  Widget _buildStep3() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
    children: [
      _SectionLabel('FEE AMOUNT'),
      const SizedBox(height: 6),
      TextField(
        controller: _feeCtrl,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
        ],
        style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.w800, color: _kNavy),
        decoration: _inputDec('0').copyWith(
          prefixText: '₹  ',
          prefixStyle: const TextStyle(
              fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w600),
        ),
      ),

      const SizedBox(height: 20),
      _SectionLabel('FREQUENCY'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: kFeeFrequencies.map((f) {
          final sel   = _frequency == f;
          final label = _freqLabels[f] ?? f;
          return GestureDetector(
            onTap: () => setState(() => _frequency = f),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: sel ? _kNavy : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? _kNavy : _kBorder),
              ),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: sel ? Colors.white : Colors.grey)),
            ),
          );
        }).toList(),
      ),

      const SizedBox(height: 20),
      // Initial payment checkbox row
      GestureDetector(
        onTap: () => setState(() => _showInitPay = !_showInitPay),
        child: Row(children: [
          _Checkbox(checked: _showInitPay),
          const SizedBox(width: 10),
          const Text('Record advance payment',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: _kNavy, fontSize: 14)),
        ]),
      ),

      if (_showInitPay) ...[
        const SizedBox(height: 14),
        TextField(
          controller: _initPayCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          decoration: _inputDec('Amount paid').copyWith(
            prefixText: '₹  ',
            prefixStyle:
                const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        _SectionLabel('PAYMENT MODE'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: kPaymentModes.map((m) {
            final sel = _payMode == m;
            return GestureDetector(
              onTap: () => setState(() => _payMode = m),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: sel ? _kBlue : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? _kBlue : _kBorder),
                ),
                child: Text(m,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: sel ? Colors.white : Colors.grey)),
              ),
            );
          }).toList(),
        ),
      ],

      const SizedBox(height: 28),
      _PrimaryButton(label: 'Continue', onTap: () => _to(4)),
      const SizedBox(height: 8),
      Center(
        child: TextButton(
          onPressed: () => _to(4),
          child: const Text('Skip fees for now',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ),
      ),
    ],
  );

  // ── Step 4 — Extra Details ────────────────────────────────────────────────────

  Widget _buildStep4() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
    children: [
      // ── Parent / Guardian ──────────────────────────────────────────────────
      _SectionLabel('PARENT / GUARDIAN'),
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
                color: sel ? _kNavy : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? _kNavy : _kBorder),
              ),
              child: Text(r,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: sel ? Colors.white : Colors.grey)),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _parentNameCtrl,
        textCapitalization: TextCapitalization.words,
        decoration: _inputDec('Parent / Guardian name'),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _parentPhoneCtrl,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        decoration: _inputDec('Parent phone number'),
      ),

      const SizedBox(height: 20),
      // ── Aadhaar ────────────────────────────────────────────────────────────
      _SectionLabel('AADHAAR NUMBER *'),
      const SizedBox(height: 6),
      TextField(
        controller: _aadhaarCtrl,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(12),
        ],
        decoration: _inputDec('12-digit Aadhaar number'),
      ),

      const SizedBox(height: 20),
      _SectionLabel('BLOOD GROUP (optional)'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: _bloodGroups.map((g) {
          final sel = _bloodGroup == g;
          return GestureDetector(
            onTap: () => setState(
                () => _bloodGroup = _bloodGroup == g ? null : g),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFFC62828) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: sel
                        ? const Color(0xFFC62828)
                        : _kBorder),
              ),
              child: Text(g,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: sel ? Colors.white : Colors.grey)),
            ),
          );
        }).toList(),
      ),

      const SizedBox(height: 20),
      GestureDetector(
        onTap: () =>
            setState(() => _showEmergency = !_showEmergency),
        child: Row(children: [
          _Checkbox(checked: _showEmergency),
          const SizedBox(width: 10),
          const Text('Add emergency contact',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: _kNavy, fontSize: 14)),
        ]),
      ),

      if (_showEmergency) ...[
        const SizedBox(height: 14),
        TextField(
          controller: _emergNameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: _inputDec('Contact name'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _emergPhoneCtrl,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _inputDec('Contact phone'),
        ),
      ],

      const SizedBox(height: 32),
      _PrimaryButton(
          label: 'Enroll Student', loading: _loading, onTap: _submit),
      const SizedBox(height: 8),
      Center(
        child: TextButton(
          onPressed: _loading ? null : _submit,
          child: const Text('Skip & Enroll',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ),
      ),
    ],
  );
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

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
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: selected ? _kNavy : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: selected ? _kNavy : _kBorder,
            width: selected ? 0 : 1.5),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: selected ? Colors.white : Colors.grey, size: 26),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: selected ? Colors.white : _kNavy)),
        Text(subtitle,
            style: TextStyle(
                fontSize: 11,
                color: selected ? Colors.white70 : Colors.grey)),
      ]),
    ),
  );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;

  const _InfoTile(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 12),
      SizedBox(
        width: 56,
        child: Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ),
      Expanded(
        child: Text(value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: _kNavy)),
      ),
    ]),
  );
}

class _DateRow extends StatelessWidget {
  final DateTime? value;
  final String hint;
  final VoidCallback onTap;

  const _DateRow({required this.value, required this.hint, required this.onTap});

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2,'0')} / ${d.month.toString().padLeft(2,'0')} / ${d.year}';

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Row(children: [
        const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value == null ? hint : _fmt(value!),
            style: TextStyle(
              fontSize: 14,
              color: value == null ? Colors.grey : _kNavy,
              fontWeight: value == null ? FontWeight.normal : FontWeight.w600,
            ),
          ),
        ),
        const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
      ]),
    ),
  );
}

class _Banner extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, bg;

  const _Banner({required this.icon, required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
    ]),
  );
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onTap;

  const _PrimaryButton({required this.label, this.loading = false, this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 52,
    child: ElevatedButton(
      onPressed: loading ? null : onTap,
      child: loading
          ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
    ),
  );
}

class _Checkbox extends StatelessWidget {
  final bool checked;
  const _Checkbox({required this.checked});

  @override
  Widget build(BuildContext context) => Container(
    width: 22, height: 22,
    decoration: BoxDecoration(
      color: checked ? _kBlue : Colors.white,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: checked ? _kBlue : _kBorder),
    ),
    child: checked
        ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
        : null,
  );
}

Widget _SectionLabel(String text) => Text(
  text,
  style: const TextStyle(
      fontSize: 11, fontWeight: FontWeight.w700,
      color: Colors.grey, letterSpacing: 0.8),
);

InputDecoration _inputDec(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
  border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kBorder)),
  enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kBorder)),
  focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kNavy, width: 1.5)),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
);
