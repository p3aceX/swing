import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets.dart';
import 'batch_provider.dart';

const _kNavy  = Color(0xFF071B3D);
const _kBlue  = Color(0xFF0057C8);
const _kIvory = Color(0xFFF4F2EB);

const _kDays   = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _kRoles  = ['Head Coach', 'Batting Coach', 'Bowling Coach', 'Fielding Coach', 'Wicket-keeping Coach', 'Fitness Coach'];
const _kGroups = ['Under 10', 'Under 12', 'Under 14', 'Under 16', 'Under 18', 'Under 19', 'Adult', 'Open'];

class BatchCreateWizard extends ConsumerStatefulWidget {
  const BatchCreateWizard({super.key});

  @override
  ConsumerState<BatchCreateWizard> createState() => _BatchCreateWizardState();
}

class _BatchCreateWizardState extends ConsumerState<BatchCreateWizard> {
  final _page = PageController();
  int _step = 0;

  // Step 1 — Basics
  final _nameCtrl     = TextEditingController();
  final _descCtrl     = TextEditingController();
  String? _ageGroup;
  int _maxStudents = 20;

  // Step 2 — Schedule
  final List<_Slot> _slots = [];

  // Step 3 — Fees
  final _monthlyCtrl  = TextEditingController();
  final _yearlyCtrl   = TextEditingController();
  final _trialFeeCtrl = TextEditingController();
  final _trialDaysCtrl= TextEditingController();
  int _dueDay = 1;

  // Step 4 — Coach
  final _coachPhoneCtrl = TextEditingController();
  final _coachNameCtrl  = TextEditingController();
  String _coachRole = 'Head Coach';
  Map<String, dynamic>? _foundCoach;
  bool _searchingCoach = false;
  bool _coachNotFound  = false;

  bool _saving = false;

  @override
  void dispose() {
    _page.dispose();
    _nameCtrl.dispose(); _descCtrl.dispose();
    _monthlyCtrl.dispose(); _yearlyCtrl.dispose();
    _trialFeeCtrl.dispose(); _trialDaysCtrl.dispose();
    _coachPhoneCtrl.dispose(); _coachNameCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 0 && _nameCtrl.text.trim().length < 2) {
      showSnack(context, 'Batch name is required');
      return;
    }
    if (_step < 3) {
      setState(() => _step++);
      _page.animateToPage(_step, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _page.animateToPage(_step, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      context.pop();
    }
  }

  Future<void> _searchCoach() async {
    final phone = _coachPhoneCtrl.text.trim();
    if (phone.length < 10) { showSnack(context, 'Enter a valid phone number'); return; }
    setState(() { _searchingCoach = true; _foundCoach = null; _coachNotFound = false; });
    try {
      final result = await ref.read(batchesProvider.notifier).lookupCoach(phone);
      setState(() {
        if (result != null) {
          _foundCoach = result;
          _coachNameCtrl.text = result['userName'] as String? ?? '';
        } else {
          _coachNotFound = true;
        }
      });
    } catch (_) {
      setState(() => _coachNotFound = true);
    } finally {
      setState(() => _searchingCoach = false);
    }
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      final batchId = await ref.read(batchesProvider.notifier).create({
        'name':        _nameCtrl.text.trim(),
        'sport':       'CRICKET',
        if (_ageGroup != null) 'ageGroup': _ageGroup,
        'maxStudents': _maxStudents,
        if (_descCtrl.text.trim().isNotEmpty) 'description': _descCtrl.text.trim(),
      });

      // Schedules
      for (final slot in _slots) {
        await ref.read(batchesProvider.notifier).addSchedule(batchId, slot.toMap());
      }

      // Fees
      final monthly = int.tryParse(_monthlyCtrl.text.trim());
      if (monthly != null && monthly > 0) {
        await ref.read(batchesProvider.notifier).createFeeStructure(batchId, {
          'name': 'Monthly Fee', 'amountPaise': monthly * 100, 'frequency': 'MONTHLY', 'dueDayOfMonth': _dueDay,
        });
      }
      final yearly = int.tryParse(_yearlyCtrl.text.trim());
      if (yearly != null && yearly > 0) {
        await ref.read(batchesProvider.notifier).createFeeStructure(batchId, {
          'name': 'Yearly Fee', 'amountPaise': yearly * 100, 'frequency': 'ANNUAL',
        });
      }
      final trialFee = int.tryParse(_trialFeeCtrl.text.trim());
      if (trialFee != null && trialFee > 0) {
        await ref.read(batchesProvider.notifier).createFeeStructure(batchId, {
          'name': 'Trial Fee (${_trialDaysCtrl.text.trim().isNotEmpty ? "${_trialDaysCtrl.text.trim()} days" : "trial"})',
          'amountPaise': trialFee * 100, 'frequency': 'ONE_TIME',
        });
      }

      // Coach
      final coachPhone = _coachPhoneCtrl.text.trim();
      if (coachPhone.length >= 10) {
        final isHead = _coachRole == 'Head Coach';
        final coachResult = await ref.read(batchesProvider.notifier).inviteAndAssignCoach(
          batchId: batchId,
          phone: coachPhone,
          name: _coachNameCtrl.text.trim().isNotEmpty ? _coachNameCtrl.text.trim() : null,
          isHeadCoach: isHead,
        );
        if (coachResult != null) {
          final coachProfileId = coachResult['coachProfileId'] as String?;
          if (coachProfileId != null) {
            await ref.read(batchesProvider.notifier).assignCoachToBatch(batchId, coachProfileId);
          }
        }
      }

      if (mounted) {
        context.pop();
        context.push('/batches/$batchId');
      }
    } catch (e) {
      if (mounted) showSnack(context, 'Failed: ${e.toString().replaceAll('Exception:', '').trim()}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kIvory,
      appBar: AppBar(
        backgroundColor: _kIvory,
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: _back),
        title: const Text('New Batch'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${_step + 1} / 4',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _StepBar(step: _step),
          Expanded(
            child: PageView(
              controller: _page,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _Step1Basics(
                  nameCtrl: _nameCtrl, descCtrl: _descCtrl,
                  ageGroup: _ageGroup, maxStudents: _maxStudents,
                  onAgeGroup: (v) => setState(() => _ageGroup = v),
                  onMaxStudents: (v) => setState(() => _maxStudents = v),
                ),
                _Step2Schedule(slots: _slots, onChanged: () => setState(() {})),
                _Step3Fees(
                  monthlyCtrl: _monthlyCtrl, yearlyCtrl: _yearlyCtrl,
                  trialFeeCtrl: _trialFeeCtrl, trialDaysCtrl: _trialDaysCtrl,
                  dueDay: _dueDay, onDueDay: (v) => setState(() => _dueDay = v),
                ),
                _Step4Coach(
                  phoneCtrl: _coachPhoneCtrl, nameCtrl: _coachNameCtrl,
                  role: _coachRole, onRole: (v) => setState(() => _coachRole = v),
                  foundCoach: _foundCoach, coachNotFound: _coachNotFound,
                  searching: _searchingCoach, onSearch: _searchCoach,
                ),
              ],
            ),
          ),
          _NavBar(
            step: _step, saving: _saving,
            onBack: _back, onNext: _step < 3 ? _next : _finish,
          ),
        ],
      ),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────

class _StepBar extends StatelessWidget {
  final int step;
  const _StepBar({required this.step});

  static const _labels = ['Basics', 'Schedule', 'Fees', 'Coach'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Row(
        children: List.generate(_labels.length, (i) {
          final done     = i < step;
          final active   = i == step;
          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: done ? _kNavy : const Color(0xFFE0DED6),
                    ),
                  ),
                Column(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active ? _kNavy : done ? _kNavy : const Color(0xFFE0DED6),
                      ),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                            : Text('${i + 1}',
                                style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700,
                                  color: active ? Colors.white : Colors.grey,
                                )),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(_labels[i],
                        style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w600,
                          color: active ? _kNavy : Colors.grey,
                        )),
                  ],
                ),
                if (i < _labels.length - 1)
                  Expanded(
                    child: Container(height: 2, color: done ? _kNavy : const Color(0xFFE0DED6)),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Nav buttons ───────────────────────────────────────────────────────────────

class _NavBar extends StatelessWidget {
  final int step;
  final bool saving;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _NavBar({required this.step, required this.saving, required this.onBack, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final isLast = step == 3;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F2EB),
        border: Border(top: BorderSide(color: Color(0xFFE0DED6), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE0DED6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                minimumSize: const Size(0, 52),
              ),
              child: Text(step == 0 ? 'Cancel' : 'Back',
                  style: const TextStyle(color: _kNavy, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: saving ? null : onNext,
              child: saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isLast ? 'Create Batch' : 'Next',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 1: Basics ────────────────────────────────────────────────────────────

class _Step1Basics extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final String? ageGroup;
  final int maxStudents;
  final ValueChanged<String?> onAgeGroup;
  final ValueChanged<int> onMaxStudents;

  const _Step1Basics({
    required this.nameCtrl, required this.descCtrl,
    required this.ageGroup, required this.maxStudents,
    required this.onAgeGroup, required this.onMaxStudents,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _sectionLabel('Batch Name *'),
        TextField(
          controller: nameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'e.g. Morning Juniors'),
        ),
        const SizedBox(height: 20),
        _sectionLabel('Age Group'),
        DropdownButtonFormField<String>(
          value: ageGroup,
          hint: const Text('Select age group'),
          decoration: const InputDecoration(),
          items: _kGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: onAgeGroup,
        ),
        const SizedBox(height: 20),
        _sectionLabel('Max Students'),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded),
              onPressed: maxStudents > 5 ? () => onMaxStudents(maxStudents - 5) : null,
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFECEAE3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('$maxStudents',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _kNavy)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: () => onMaxStudents(maxStudents + 5),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _sectionLabel('Description (optional)'),
        TextField(
          controller: descCtrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'What is this batch about?'),
        ),
      ],
    );
  }
}

// ── Step 2: Schedule ──────────────────────────────────────────────────────────

class _Slot {
  int dayOfWeek; // 0=Mon, 6=Sun
  TimeOfDay start;
  TimeOfDay end;
  String groundNote;

  _Slot({required this.dayOfWeek, required this.start, required this.end, this.groundNote = ''});

  Map<String, dynamic> toMap() => {
    'dayOfWeek': dayOfWeek,
    'startTime': '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
    'endTime':   '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}',
    if (groundNote.isNotEmpty) 'groundNote': groundNote,
  };

  String get label {
    String fmt(TimeOfDay t) {
      final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
      final m = t.minute.toString().padLeft(2, '0');
      return '$h:$m ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
    }
    return '${_kDays[dayOfWeek]}  ${fmt(start)} – ${fmt(end)}';
  }
}

class _Step2Schedule extends StatefulWidget {
  final List<_Slot> slots;
  final VoidCallback onChanged;
  const _Step2Schedule({required this.slots, required this.onChanged});

  @override
  State<_Step2Schedule> createState() => _Step2ScheduleState();
}

class _Step2ScheduleState extends State<_Step2Schedule> {
  int _day = 0;
  TimeOfDay _start = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _end   = const TimeOfDay(hour: 7, minute: 30);
  final _noteCtrl  = TextEditingController();

  @override
  void dispose() { _noteCtrl.dispose(); super.dispose(); }

  Future<void> _pickTime(bool isStart) async {
    final t = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (t != null) setState(() => isStart ? _start = t : _end = t);
  }

  void _add() {
    widget.slots.add(_Slot(dayOfWeek: _day, start: _start, end: _end, groundNote: _noteCtrl.text.trim()));
    _noteCtrl.clear();
    widget.onChanged();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _sectionLabel('Day'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_kDays.length, (i) {
              final sel = i == _day;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _day = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? _kNavy : const Color(0xFFECEAE3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(_kDays[i],
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                            color: sel ? Colors.white : Colors.grey)),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _timeTile('Start', _start, () => _pickTime(true))),
            const SizedBox(width: 12),
            Expanded(child: _timeTile('End', _end, () => _pickTime(false))),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _noteCtrl,
          decoration: const InputDecoration(hintText: 'Ground / venue note (optional)'),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Slot'),
          onPressed: _add,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _kBlue),
            foregroundColor: _kBlue,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        if (widget.slots.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionLabel('Added Slots'),
          ...widget.slots.map((s) => ListTile(
            dense: true,
            leading: const Icon(Icons.schedule_rounded, size: 18, color: _kBlue),
            title: Text(s.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            trailing: IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
              onPressed: () { widget.slots.remove(s); widget.onChanged(); setState(() {}); },
            ),
          )),
        ],
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text('You can skip this and add schedule later from batch details.',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _timeTile(String label, TimeOfDay t, VoidCallback onTap) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFECEAE3),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('$h:$m $period', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _kNavy)),
          ],
        ),
      ),
    );
  }
}

// ── Step 3: Fees ──────────────────────────────────────────────────────────────

class _Step3Fees extends StatelessWidget {
  final TextEditingController monthlyCtrl, yearlyCtrl, trialFeeCtrl, trialDaysCtrl;
  final int dueDay;
  final ValueChanged<int> onDueDay;

  const _Step3Fees({
    required this.monthlyCtrl, required this.yearlyCtrl,
    required this.trialFeeCtrl, required this.trialDaysCtrl,
    required this.dueDay, required this.onDueDay,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text('All fields are optional. You can set fees later from batch details.',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        _sectionLabel('Monthly Fee'),
        _rupeeField(monthlyCtrl, 'Amount per month'),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Due on day ', style: TextStyle(fontSize: 13, color: Colors.grey)),
            DropdownButton<int>(
              value: dueDay,
              underline: const SizedBox(),
              items: List.generate(28, (i) => i + 1)
                  .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
                  .toList(),
              onChanged: (v) => onDueDay(v!),
            ),
            const Text(' of month', style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 20),
        _sectionLabel('Yearly Fee'),
        _rupeeField(yearlyCtrl, 'Amount per year'),
        const SizedBox(height: 20),
        _sectionLabel('Trial Period'),
        Row(
          children: [
            Expanded(child: _rupeeField(trialFeeCtrl, 'Trial fee')),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: trialDaysCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(hintText: 'Days (e.g. 7)'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _rupeeField(TextEditingController ctrl, String hint) => TextField(
    controller: ctrl,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    decoration: InputDecoration(prefixText: '₹  ', hintText: hint),
  );
}

// ── Step 4: Coach ─────────────────────────────────────────────────────────────

class _Step4Coach extends StatelessWidget {
  final TextEditingController phoneCtrl, nameCtrl;
  final String role;
  final ValueChanged<String> onRole;
  final Map<String, dynamic>? foundCoach;
  final bool coachNotFound, searching;
  final VoidCallback onSearch;

  const _Step4Coach({
    required this.phoneCtrl, required this.nameCtrl,
    required this.role, required this.onRole,
    required this.foundCoach, required this.coachNotFound,
    required this.searching, required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text('Optional. You can assign a coach later from batch details.',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        _sectionLabel('Coach Phone Number'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(hintText: '10-digit mobile number'),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: searching ? null : onSearch,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: searching
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Search'),
              ),
            ),
          ],
        ),

        if (foundCoach != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0057C8).withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const CircleAvatar(radius: 18, backgroundColor: _kBlue, child: Icon(Icons.person_rounded, color: Colors.white, size: 18)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(foundCoach!['userName'] as String? ?? 'Coach',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: _kNavy)),
                    Text('Coach found ✓', style: TextStyle(fontSize: 12, color: Colors.green.shade700)),
                  ],
                ),
              ],
            ),
          ),
        ],

        if (coachNotFound) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text('Coach not found. Enter their name below to create a new coach account.',
                style: TextStyle(fontSize: 13, color: Colors.orange)),
          ),
          const SizedBox(height: 12),
          _sectionLabel('Coach Name *'),
          TextField(
            controller: nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Full name'),
          ),
        ],

        if (foundCoach != null || coachNotFound) ...[
          const SizedBox(height: 20),
          _sectionLabel('Role'),
          ..._kRoles.map((r) => RadioListTile<String>(
            value: r, groupValue: role,
            title: Text(r, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            activeColor: _kNavy,
            dense: true,
            onChanged: (v) => onRole(v!),
          )),
        ],
      ],
    );
  }
}

// ── helpers ───────────────────────────────────────────────────────────────────

Widget _sectionLabel(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: Text(text.toUpperCase(),
      style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
);
