import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../coaches/coach_provider.dart';
import '../fees/fee_provider.dart';
import 'batch_provider.dart';

class CreateBatchFlow extends ConsumerStatefulWidget {
  const CreateBatchFlow({super.key});

  @override
  ConsumerState<CreateBatchFlow> createState() => _CreateBatchFlowState();
}

class _CreateBatchFlowState extends ConsumerState<CreateBatchFlow> {
  ThemeData get theme => Theme.of(context);
  final _pageController = PageController();
  int _step = 0;
  bool _isLoading = false;

  // Step 1: Batch Info
  final _batchFormKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _maxCtrl = TextEditingController(text: '20');
  final _descCtrl = TextEditingController();
  final String _sport = 'CRICKET';

  // Step 2: Coach
  final _coachPhoneCtrl = TextEditingController();
  final _coachNameCtrl = TextEditingController();
  String _coachDesignation = kCoachDesignations.first;
  Map<String, dynamic>? _selectedCoach;
  bool _isCoachLookupLoading = false;

  // Step 3: Fees
  final _feeFormKey = GlobalKey<FormState>();
  final _feeNameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _frequency = 'MONTHLY';

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _maxCtrl.dispose();
    _descCtrl.dispose();
    _coachPhoneCtrl.dispose();
    _coachNameCtrl.dispose();
    _feeNameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 0 && !_batchFormKey.currentState!.validate()) return;
    if (_step == 2 && !_feeFormKey.currentState!.validate()) return;

    if (_step < 2) {
      setState(() => _step++);
      _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _prev() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      // 1. Create Batch
      final batchRes = await ref.read(batchesProvider.notifier).create({
        'name': _nameCtrl.text.trim(),
        'ageGroup': _ageCtrl.text.trim(),
        'sport': _sport,
        'maxStudents': int.tryParse(_maxCtrl.text) ?? 20,
        'description': _descCtrl.text.trim(),
      });

      final batchId = batchRes['id'] as String;

      // 2. Find/Create and assign coach (if phone provided)
      final coachPhone = _coachPhoneCtrl.text.trim().replaceAll(RegExp(r'\D'), '');
      if (coachPhone.isNotEmpty) {
        Map<String, dynamic>? coach = _selectedCoach;
        coach ??= await ref.read(coachesProvider.notifier).ensureAcademyCoachByPhone(
              coachPhone,
              isHeadCoach: _coachDesignation == 'HEAD_COACH',
            );
        coach ??= await ref.read(coachesProvider.notifier).invite({
          'phone': coachPhone,
          'isHeadCoach': _coachDesignation == 'HEAD_COACH',
        });

        final coachId = (coach['id'] ?? coach['coachId']) as String?;
        if (coachId != null && coachId.isNotEmpty) {
          await ref.read(batchesProvider.notifier).assignCoach(batchId, coachId);
        }
      }

      // 3. Create Fee Structure
      final amount = double.tryParse(_amountCtrl.text) ?? 0;
      await ref.read(feeStructuresProvider.notifier).create({
        'name': _feeNameCtrl.text.isEmpty ? '${_nameCtrl.text} Fee' : _feeNameCtrl.text,
        'amountPaise': (amount * 100).toInt(),
        'frequency': _frequency,
        'batchId': batchId,
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showSnack(context, 'Error creating batch: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(['Batch Details', 'Assign Coach', 'Set Pricing'][_step]),
        leading: _step > 0 
          ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _prev)
          : IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: (_step + 1) / 3,
            backgroundColor: theme.dividerColor.withOpacity(0.05),
            minHeight: 2,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBatchInfoStep(),
                _buildCoachStep(),
                _buildFeeStep(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildBatchInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _batchFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('The Basics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Start by giving your batch a name and choosing the sport.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Batch Name', hintText: 'e.g. U-14 Advanced'),
              validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageCtrl,
                    decoration: const InputDecoration(labelText: 'Age Group', hintText: 'e.g. U-14'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxCtrl,
                    decoration: const InputDecoration(labelText: 'Max Students'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              initialValue: 'CRICKET',
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Sport'),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description', hintText: 'What will this batch focus on?'),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoachStep() {
    final selectedUser = _selectedCoach?['user'] as Map<String, dynamic>? ?? {};
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Assign a Coach', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Find an existing coach by mobile number. If not found, enter name and designation to create one.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _coachPhoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Coach Mobile Number'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isCoachLookupLoading ? null : _lookupCoach,
              child: _isCoachLookupLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Find Coach'),
            ),
          ),
          if (_selectedCoach != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.deepBlue.withOpacity(0.03),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.deepBlue.withOpacity(0.1),
                    child: Text(((selectedUser['name'] ?? '?').toString().isNotEmpty)
                        ? (selectedUser['name'] ?? '?').toString()[0]
                        : '?'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(selectedUser['name']?.toString() ?? 'Unknown'),
                        Text(selectedUser['phone']?.toString() ?? '',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _coachNameCtrl,
              decoration: const InputDecoration(labelText: 'Coach Name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _coachDesignation,
              decoration: const InputDecoration(labelText: 'Designation'),
              items: kCoachDesignations
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => _coachDesignation = v!),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _lookupCoach() async {
    final phone = _coachPhoneCtrl.text.trim().replaceAll(RegExp(r'\D'), '');
    if (phone.length < 10) {
      showSnack(context, 'Enter a valid phone number');
      return;
    }
    setState(() => _isCoachLookupLoading = true);
    try {
      final coach = await ref.read(coachesProvider.notifier).ensureAcademyCoachByPhone(
            phone,
            isHeadCoach: _coachDesignation == 'HEAD_COACH',
          );
      if (!mounted) return;
      setState(() => _selectedCoach = coach);
      if (coach == null) {
        showSnack(context, 'Coach not found. Enter name and designation to add.');
      } else {
        final user = coach['user'] as Map<String, dynamic>? ?? {};
        if (_coachNameCtrl.text.trim().isEmpty && (user['name'] as String?) != null) {
          _coachNameCtrl.text = user['name'] as String;
        }
        showSnack(context, 'Coach found.');
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      final code = (body is Map ? body['code']?.toString() : null) ?? '';
      final message = (body is Map ? body['message']?.toString() : null) ?? '';
      if (mounted) {
        showSnack(
          context,
          'Coach fetch failed (${status ?? 'no-status'}) ${code.isNotEmpty ? code : message}',
        );
      }
    } catch (e) {
      if (mounted) showSnack(context, 'Failed to fetch coach: $e');
    } finally {
      if (mounted) setState(() => _isCoachLookupLoading = false);
    }
  }

  Widget _buildFeeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _feeFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Set Pricing', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('How much should students in this batch pay?', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            TextFormField(
              controller: _feeNameCtrl,
              decoration: InputDecoration(
                labelText: 'Fee Structure Name',
                hintText: 'e.g. ${_nameCtrl.text} Standard',
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(
                labelText: 'Amount (₹)',
                prefixText: '₹ ',
                hintText: '2500',
              ),
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: const InputDecoration(labelText: 'Frequency'),
              items: ['MONTHLY', 'QUARTERLY', 'ANNUAL', 'ONE_TIME']
                .map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              onChanged: (v) => setState(() => _frequency = v!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: TextButton(
                onPressed: _prev,
                child: const Text('Back'),
              ),
            ),
          if (_step > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: _isLoading ? null : _next,
              child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_step == 2 ? 'Launch Batch' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
