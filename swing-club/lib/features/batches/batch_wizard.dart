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

class _CoachEntry {
  final String phone;
  final String name;
  final String role;
  final Map<String, dynamic>? foundCoach;
  final bool isExisting;
  final String? coachProfileId;

  const _CoachEntry({
    required this.phone,
    required this.name,
    required this.role,
    this.foundCoach,
    this.isExisting = false,
    this.coachProfileId,
  });
}

class BatchCreateWizard extends ConsumerStatefulWidget {
  final String? batchId;
  final Map<String, dynamic>? existing;

  const BatchCreateWizard({super.key, this.batchId, this.existing});

  @override
  ConsumerState<BatchCreateWizard> createState() => _BatchCreateWizardState();
}

class _BatchCreateWizardState extends ConsumerState<BatchCreateWizard> {
  final _page = PageController();
  int _step = 0;

  // Step 1 — Basics
  final _nameCtrl      = TextEditingController();
  final _descCtrl      = TextEditingController();
  String? _ageGroup;
  int _maxStudents = 20;

  // Step 2 — Schedule
  final List<_Slot> _slots = [];
  final List<String> _deletedSlotIds = [];

  // Step 3 — Fees
  final _monthlyCtrl   = TextEditingController();
  final _yearlyCtrl    = TextEditingController();
  final _trialFeeCtrl  = TextEditingController();
  final _trialDaysCtrl = TextEditingController();
  int _dueDay = 1;

  // Step 4 — Coaches
  final List<_CoachEntry> _coaches = [];
  final List<String> _removedCoachProfileIds = [];

  bool _saving = false;

  bool get _isEdit => widget.batchId != null;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) _prefillFromExisting(widget.existing!);
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadSchedules());
    }
  }

  void _prefillFromExisting(Map<String, dynamic> b) {
    _nameCtrl.text = b['name'] as String? ?? '';
    _descCtrl.text = b['description'] as String? ?? '';
    _ageGroup      = b['ageGroup'] as String?;
    _maxStudents   = (b['maxStudents'] as num?)?.toInt() ?? 20;

    for (final raw in (b['coaches'] as List? ?? [])) {
      final c    = raw as Map<String, dynamic>;
      final user = (c['user'] as Map<String, dynamic>?) ?? {};
      _coaches.add(_CoachEntry(
        phone: user['phone'] as String? ?? '',
        name:  user['name']  as String? ?? '',
        role:  c['isHeadCoach'] == true ? 'Head Coach' : 'Batting Coach',
        isExisting:     true,
        coachProfileId: c['coachProfileId'] as String? ?? c['id'] as String?,
      ));
    }

    for (final raw in (b['feeStructures'] as List? ?? [])) {
      final f      = raw as Map<String, dynamic>;
      final freq   = f['frequency'] as String? ?? '';
      final amount = ((f['amountPaise'] as num? ?? 0) / 100).round();
      if (freq == 'MONTHLY') {
        _monthlyCtrl.text = '$amount';
        _dueDay = (f['dueDayOfMonth'] as num?)?.toInt() ?? 1;
      } else if (freq == 'ANNUAL') {
        _yearlyCtrl.text = '$amount';
      } else if (freq == 'ONE_TIME') {
        _trialFeeCtrl.text = '$amount';
      }
    }
  }

  Future<void> _loadSchedules() async {
    try {
      final schedules = await ref.read(batchSchedulesProvider(widget.batchId!).future);
      if (!mounted) return;
      setState(() {
        for (final s in schedules) {
          final st = (s['startTime'] as String? ?? '00:00').split(':');
          final et = (s['endTime']   as String? ?? '00:00').split(':');
          _slots.add(_Slot(
            id:         s['id'] as String?,
            isExisting: true,
            dayOfWeek:  (s['dayOfWeek'] as num?)?.toInt() ?? 0,
            start: TimeOfDay(hour: int.parse(st[0]), minute: int.parse(st[1])),
            end:   TimeOfDay(hour: int.parse(et[0]), minute: int.parse(et[1])),
            groundNote: s['groundNote'] as String? ?? '',
          ));
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _page.dispose();
    _nameCtrl.dispose();    _descCtrl.dispose();
    _monthlyCtrl.dispose(); _yearlyCtrl.dispose();
    _trialFeeCtrl.dispose(); _trialDaysCtrl.dispose();
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

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await _finishEdit();
      } else {
        await _finishCreate();
      }
    } catch (e) {
      if (mounted) showSnack(context, 'Failed: ${e.toString().replaceAll('Exception:', '').trim()}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _finishCreate() async {
    final batchId = await ref.read(batchesProvider.notifier).create({
      'name':        _nameCtrl.text.trim(),
      'sport':       'CRICKET',
      if (_ageGroup != null) 'ageGroup': _ageGroup,
      'maxStudents': _maxStudents,
      if (_descCtrl.text.trim().isNotEmpty) 'description': _descCtrl.text.trim(),
    });

    for (final slot in _slots) {
      await ref.read(batchesProvider.notifier).addSchedule(batchId, slot.toMap());
    }

    final monthly = int.tryParse(_monthlyCtrl.text.trim());
    if (monthly != null && monthly > 0) {
      await ref.read(batchesProvider.notifier).createFeeStructure(batchId, {
        'name': 'Monthly Fee', 'amountPaise': monthly * 100,
        'frequency': 'MONTHLY', 'dueDayOfMonth': _dueDay,
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

    await _saveNewCoaches(batchId);

    if (mounted) {
      context.pop();
      context.push('/batches/$batchId');
    }
  }

  Future<void> _finishEdit() async {
    final batchId = widget.batchId!;

    await ref.read(batchesProvider.notifier).updateBatch(batchId, {
      'name':        _nameCtrl.text.trim(),
      'sport':       'CRICKET',
      if (_ageGroup != null) 'ageGroup': _ageGroup,
      'maxStudents': _maxStudents,
      'description': _descCtrl.text.trim(),
    });

    for (final id in _deletedSlotIds) {
      await ref.read(batchSchedulesProvider(batchId).notifier).remove(id);
    }
    for (final slot in _slots) {
      if (!slot.isExisting) {
        await ref.read(batchesProvider.notifier).addSchedule(batchId, slot.toMap());
      }
    }

    for (final id in _removedCoachProfileIds) {
      await ref.read(batchesProvider.notifier).removeCoachFromBatch(batchId, id);
    }
    await _saveNewCoaches(batchId);

    if (mounted) {
      ref.invalidate(batchDetailProvider(batchId));
      context.pop();
    }
  }

  Future<void> _saveNewCoaches(String batchId) async {
    for (final c in _coaches) {
      if (c.isExisting) continue;
      if (c.phone.length < 10) continue;
      final result = await ref.read(batchesProvider.notifier).inviteAndAssignCoach(
        batchId: batchId,
        phone: c.phone,
        name: c.name.isNotEmpty ? c.name : null,
        isHeadCoach: c.role == 'Head Coach',
      );
      if (result != null) {
        final cpId = result['coachProfileId'] as String?;
        if (cpId != null) {
          await ref.read(batchesProvider.notifier).assignCoachToBatch(batchId, cpId);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kIvory,
      appBar: AppBar(
        backgroundColor: _kIvory,
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: _back),
        title: Text(_isEdit ? 'Edit Batch' : 'New Batch'),
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
                  onAgeGroup:    (v) => setState(() => _ageGroup    = v),
                  onMaxStudents: (v) => setState(() => _maxStudents = v),
                ),
                _Step2Schedule(
                  slots: _slots,
                  onChanged: () => setState(() {}),
                  onDeleteExisting: (id) => _deletedSlotIds.add(id),
                ),
                _Step3Fees(
                  monthlyCtrl: _monthlyCtrl, yearlyCtrl: _yearlyCtrl,
                  trialFeeCtrl: _trialFeeCtrl, trialDaysCtrl: _trialDaysCtrl,
                  dueDay: _dueDay, onDueDay: (v) => setState(() => _dueDay = v),
                ),
                _Step4Coaches(
                  coaches: _coaches,
                  onAdd: (c) => setState(() => _coaches.add(c)),
                  onRemove: (i) {
                    final c = _coaches[i];
                    if (c.isExisting && c.coachProfileId != null) {
                      _removedCoachProfileIds.add(c.coachProfileId!);
                    }
                    setState(() => _coaches.removeAt(i));
                  },
                ),
              ],
            ),
          ),
          _NavBar(
            step: _step, saving: _saving, isEdit: _isEdit,
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

  static const _labels = ['Basics', 'Schedule', 'Fees', 'Coaches'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Row(
        children: List.generate(_labels.length, (i) {
          final done   = i < step;
          final active = i == step;
          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(child: Container(height: 2, color: done ? _kNavy : const Color(0xFFE0DED6))),
                Column(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (active || done) ? _kNavy : const Color(0xFFE0DED6),
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
                  Expanded(child: Container(height: 2, color: done ? _kNavy : const Color(0xFFE0DED6))),
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
  final bool isEdit;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _NavBar({required this.step, required this.saving, required this.isEdit, required this.onBack, required this.onNext});

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
                  : Text(
                      isLast ? (isEdit ? 'Save Changes' : 'Create Batch') : 'Next',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
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
  final String? id;
  final bool isExisting;
  int dayOfWeek;
  TimeOfDay start;
  TimeOfDay end;
  String groundNote;

  _Slot({
    this.id,
    this.isExisting = false,
    required this.dayOfWeek,
    required this.start,
    required this.end,
    this.groundNote = '',
  });

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
  final void Function(String)? onDeleteExisting;

  const _Step2Schedule({required this.slots, required this.onChanged, this.onDeleteExisting});

  @override
  State<_Step2Schedule> createState() => _Step2ScheduleState();
}

class _Step2ScheduleState extends State<_Step2Schedule> {
  final Set<int> _days = {};
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
    if (_days.isEmpty) return;
    final note  = _noteCtrl.text.trim();
    final dupes = <String>[];
    for (final d in _days) {
      final already = widget.slots.any((s) =>
          s.dayOfWeek == d &&
          s.start.hour == _start.hour && s.start.minute == _start.minute &&
          s.end.hour   == _end.hour   && s.end.minute   == _end.minute);
      if (already) {
        dupes.add(_kDays[d]);
      } else {
        widget.slots.add(_Slot(dayOfWeek: d, start: _start, end: _end, groundNote: note));
      }
    }
    if (dupes.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Slot already exists for: ${dupes.join(', ')}'),
        behavior: SnackBarBehavior.floating,
      ));
    }
    _noteCtrl.clear();
    widget.onChanged();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _sectionLabel('Days  (tap to select multiple)'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_kDays.length, (i) {
              final sel = _days.contains(i);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => sel ? _days.remove(i) : _days.add(i)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? _kNavy : const Color(0xFFECEAE3),
                      borderRadius: BorderRadius.circular(12),
                      border: sel ? null : Border.all(color: const Color(0xFFD0CEC7)),
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
          label: Text(_days.isEmpty
              ? 'Select days first'
              : 'Add ${_days.length > 1 ? "${_days.length} slots" : "Slot"}'),
          onPressed: _days.isEmpty ? null : _add,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: _days.isEmpty ? Colors.grey.shade300 : _kBlue),
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
            leading: Icon(
              Icons.schedule_rounded,
              size: 18,
              color: s.isExisting ? Colors.green.shade600 : _kBlue,
            ),
            title: Text(s.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: s.isExisting
                ? Text('existing', style: TextStyle(fontSize: 11, color: Colors.green.shade600))
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
              onPressed: () {
                if (s.id != null) widget.onDeleteExisting?.call(s.id!);
                widget.slots.remove(s);
                widget.onChanged();
                setState(() {});
              },
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
    final h      = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m      = t.minute.toString().padLeft(2, '0');
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

// ── Step 4: Coaches (multi) ───────────────────────────────────────────────────

class _Step4Coaches extends ConsumerStatefulWidget {
  final List<_CoachEntry> coaches;
  final void Function(_CoachEntry) onAdd;
  final void Function(int) onRemove;

  const _Step4Coaches({required this.coaches, required this.onAdd, required this.onRemove});

  @override
  ConsumerState<_Step4Coaches> createState() => _Step4CoachesState();
}

class _Step4CoachesState extends ConsumerState<_Step4Coaches> {
  final _phoneCtrl = TextEditingController();
  final _nameCtrl  = TextEditingController();
  String _role = 'Head Coach';
  Map<String, dynamic>? _foundCoach;
  bool _coachNotFound = false;
  bool _searching     = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 10) { showSnack(context, 'Enter a valid phone number'); return; }
    setState(() { _searching = true; _foundCoach = null; _coachNotFound = false; });
    try {
      final result = await ref.read(batchesProvider.notifier).lookupCoach(phone);
      setState(() {
        if (result != null) {
          _foundCoach        = result;
          _nameCtrl.text     = result['userName'] as String? ?? '';
        } else {
          _coachNotFound = true;
        }
      });
    } catch (_) {
      setState(() => _coachNotFound = true);
    } finally {
      setState(() => _searching = false);
    }
  }

  void _addToList() {
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 10) { showSnack(context, 'Enter and search a phone number first'); return; }
    if (_foundCoach == null && !_coachNotFound) { showSnack(context, 'Tap Search first'); return; }
    if (_coachNotFound && _nameCtrl.text.trim().isEmpty) { showSnack(context, 'Enter coach name'); return; }

    final tail = phone.length >= 10 ? phone.substring(phone.length - 10) : phone;
    if (widget.coaches.any((c) => c.phone.endsWith(tail))) {
      showSnack(context, 'This coach is already added');
      return;
    }

    widget.onAdd(_CoachEntry(
      phone:          phone,
      name:           _nameCtrl.text.trim(),
      role:           _role,
      foundCoach:     _foundCoach,
      coachProfileId: _foundCoach?['coachProfileId'] as String?,
    ));

    setState(() {
      _phoneCtrl.clear();
      _nameCtrl.clear();
      _role          = 'Head Coach';
      _foundCoach    = null;
      _coachNotFound = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text('You can assign multiple coaches. Optional — add more later from batch details.',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),

        // ── Assigned coaches list ──────────────────────────────────────────
        if (widget.coaches.isNotEmpty) ...[
          _sectionLabel('Assigned Coaches  (${widget.coaches.length})'),
          ...List.generate(widget.coaches.length, (i) {
            final c       = widget.coaches[i];
            final initial = c.name.isNotEmpty ? c.name[0].toUpperCase() : '?';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE0DED6)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: _kBlue.withValues(alpha: 0.1),
                    child: Text(initial,
                        style: const TextStyle(fontWeight: FontWeight.w800, color: _kBlue, fontSize: 14)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name.isNotEmpty ? c.name : c.phone,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _kNavy)),
                        Text(c.role, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  if (c.isExisting)
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Assigned',
                          style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.w700)),
                    ),
                  IconButton(
                    icon: Icon(
                      c.isExisting ? Icons.person_remove_outlined : Icons.close_rounded,
                      size: 18, color: Colors.grey,
                    ),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => widget.onRemove(i),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
        ],

        // ── Add coach form ─────────────────────────────────────────────────
        _sectionLabel('Add a Coach'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() { _foundCoach = null; _coachNotFound = false; }),
                decoration: const InputDecoration(
                  hintText: '10-digit mobile number',
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _searching ? null : _search,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _searching
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Search'),
              ),
            ),
          ],
        ),

        if (_foundCoach != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0057C8).withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const CircleAvatar(radius: 18, backgroundColor: _kBlue,
                    child: Icon(Icons.person_rounded, color: Colors.white, size: 18)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_foundCoach!['userName'] as String? ?? 'Coach',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: _kNavy)),
                    Text('Coach found ✓',
                        style: TextStyle(fontSize: 12, color: Colors.green.shade700)),
                  ],
                ),
              ],
            ),
          ),
        ],

        if (_coachNotFound) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Coach not found. Enter their name below to create a new coach account.',
              style: TextStyle(fontSize: 13, color: Colors.orange),
            ),
          ),
          const SizedBox(height: 12),
          _sectionLabel('Coach Name *'),
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Full name'),
          ),
        ],

        if (_foundCoach != null || _coachNotFound) ...[
          const SizedBox(height: 20),
          _sectionLabel('Role'),
          ..._kRoles.map((r) => RadioListTile<String>(
            value: r, groupValue: _role,
            title: Text(r, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            activeColor: _kNavy,
            dense: true,
            onChanged: (v) => setState(() => _role = v!),
          )),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.person_add_rounded),
            label: const Text('Add to List'),
            onPressed: _addToList,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _kBlue),
              foregroundColor: _kBlue,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
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
