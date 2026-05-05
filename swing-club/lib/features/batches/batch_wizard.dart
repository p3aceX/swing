import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets.dart';
import 'batch_provider.dart';
import '../coaches/coach_provider.dart';

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
  final _regFeeCtrl    = TextEditingController();
  final _monthlyCtrl   = TextEditingController();
  final _yearlyCtrl    = TextEditingController();
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadSchedules();
        _loadCoaches();
        _loadFees();
      });
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
      } else if (freq == 'REGISTRATION') {
        _regFeeCtrl.text = '$amount';
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

  Future<void> _loadCoaches() async {
    try {
      final batch = await ref.read(batchDetailProvider(widget.batchId!).future);
      if (!mounted) return;
      final rawCoaches = (batch['coaches'] as List? ?? []).cast<Map<String, dynamic>>();
      if (rawCoaches.isEmpty) return;
      setState(() {
        _coaches.clear();
        for (final c in rawCoaches) {
          final user = (c['user'] as Map?)?.cast<String, dynamic>() ?? {};
          _coaches.add(_CoachEntry(
            phone:          user['phone'] as String? ?? '',
            name:           user['name']  as String? ?? '',
            role:           c['isHeadCoach'] == true ? 'Head Coach' : 'Batting Coach',
            isExisting:     true,
            coachProfileId: c['coachProfileId'] as String? ?? c['id'] as String?,
          ));
        }
      });
    } catch (_) {}
  }

  Future<void> _loadFees() async {
    try {
      final batch = await ref.read(batchDetailProvider(widget.batchId!).future);
      if (!mounted) return;
      final fees = (batch['feeStructures'] as List? ?? []).cast<Map<String, dynamic>>();
      if (fees.isEmpty) return;
      setState(() {
        for (final f in fees) {
          final freq   = f['frequency'] as String? ?? '';
          final amount = ((f['amountPaise'] as num? ?? 0) / 100).round();
          if (freq == 'MONTHLY') {
            _monthlyCtrl.text = '$amount';
            _dueDay = (f['dueDayOfMonth'] as num?)?.toInt() ?? 1;
          } else if (freq == 'ANNUAL') {
            _yearlyCtrl.text = '$amount';
          } else if (freq == 'REGISTRATION') {
            _regFeeCtrl.text = '$amount';
          }
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _page.dispose();
    _nameCtrl.dispose();    _descCtrl.dispose();
    _regFeeCtrl.dispose();
    _monthlyCtrl.dispose(); _yearlyCtrl.dispose();
    _trialDaysCtrl.dispose();
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
    } catch (e, st) {
      debugPrint('[Batch] finish error: $e\n$st');
      if (mounted) showSnack(context, 'Failed: ${e.toString().replaceAll('Exception:', '').trim()}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _finishCreate() async {
    final batchPayload = {
      'name':        _nameCtrl.text.trim(),
      'sport':       'CRICKET',
      if (_ageGroup != null) 'ageGroup': _ageGroup,
      'maxStudents': _maxStudents,
      if (_descCtrl.text.trim().isNotEmpty) 'description': _descCtrl.text.trim(),
    };
    debugPrint('[Batch] create payload: $batchPayload');

    final batchId = await ref.read(batchesProvider.notifier).create(batchPayload);
    debugPrint('[Batch] created id: $batchId');

    for (final slot in _slots) {
      final sp = slot.toMap();
      debugPrint('[Batch] schedule payload: $sp');
      await ref.read(batchesProvider.notifier).addSchedule(batchId, sp);
    }

    final regFee = int.tryParse(_regFeeCtrl.text.trim());
    if (regFee != null && regFee > 0) {
      final fp = {'name': 'Registration Fee', 'amountPaise': regFee * 100, 'frequency': 'REGISTRATION'};
      debugPrint('[Batch] fee payload: $fp');
      await ref.read(batchesProvider.notifier).createFeeStructure(batchId, fp);
    }
    final monthly = int.tryParse(_monthlyCtrl.text.trim());
    if (monthly != null && monthly > 0) {
      final fp = {'name': 'Monthly Fee', 'amountPaise': monthly * 100, 'frequency': 'MONTHLY', 'dueDayOfMonth': _dueDay};
      debugPrint('[Batch] fee payload: $fp');
      await ref.read(batchesProvider.notifier).createFeeStructure(batchId, fp);
    }
    final yearly = int.tryParse(_yearlyCtrl.text.trim());
    if (yearly != null && yearly > 0) {
      final fp = {'name': 'Yearly Fee', 'amountPaise': yearly * 100, 'frequency': 'ANNUAL'};
      debugPrint('[Batch] fee payload: $fp');
      await ref.read(batchesProvider.notifier).createFeeStructure(batchId, fp);
    }

    debugPrint('[Batch] coaches: ${_coaches.map((c) => "phone=${c.phone} name=${c.name} role=${c.role} existing=${c.isExisting}").toList()}');
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  regFeeCtrl: _regFeeCtrl,
                  monthlyCtrl: _monthlyCtrl, yearlyCtrl: _yearlyCtrl,
                  trialDaysCtrl: _trialDaysCtrl,
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
    final cs = Theme.of(context).colorScheme;
    final divColor = cs.outlineVariant;
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
                  Expanded(child: Container(height: 2, color: done ? cs.onSurface : divColor)),
                Column(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (active || done) ? cs.onSurface : divColor,
                      ),
                      child: Center(
                        child: done
                            ? Icon(Icons.check_rounded, size: 14, color: cs.surface)
                            : Text('${i + 1}',
                                style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700,
                                  color: active ? cs.surface : cs.onSurface.withValues(alpha: 0.4),
                                )),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(_labels[i],
                        style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w600,
                          color: active ? cs.onSurface : cs.onSurface.withValues(alpha: 0.45),
                        )),
                  ],
                ),
                if (i < _labels.length - 1)
                  Expanded(child: Container(height: 2, color: done ? cs.onSurface : divColor)),
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
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                minimumSize: const Size(0, 52),
              ),
              child: Text(step == 0 ? 'Cancel' : 'Back',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w700)),
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('$maxStudents',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface)),
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
    // For end picker: if _end is before _start, open picker at start+90min so
    // the correct AM/PM period is pre-selected (e.g. start=6pm → end opens at 7:30pm)
    TimeOfDay initial;
    if (isStart) {
      initial = _start;
    } else {
      final sm = _start.hour * 60 + _start.minute;
      final em = _end.hour   * 60 + _end.minute;
      if (em <= sm) {
        final s = sm + 90;
        initial = TimeOfDay(hour: (s ~/ 60) % 24, minute: s % 60);
      } else {
        initial = _end;
      }
    }

    final t = await showTimePicker(context: context, initialTime: initial);
    if (t == null) return;

    setState(() {
      if (isStart) {
        _start = t;
        // Auto-push end time if it's now before or equal to start
        final sm = t.hour * 60 + t.minute;
        final em = _end.hour * 60 + _end.minute;
        if (em <= sm) {
          final s = sm + 90;
          _end = TimeOfDay(hour: (s ~/ 60) % 24, minute: s % 60);
        }
      } else {
        _end = t;
      }
    });
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
                      color: sel
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: sel ? null : Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Text(_kDays[i],
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                            color: sel
                                ? Theme.of(context).colorScheme.surface
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
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
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('$h:$m $period', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }
}

// ── Step 3: Fees ──────────────────────────────────────────────────────────────

class _Step3Fees extends StatelessWidget {
  final TextEditingController regFeeCtrl, monthlyCtrl, yearlyCtrl, trialDaysCtrl;
  final int dueDay;
  final ValueChanged<int> onDueDay;

  const _Step3Fees({
    required this.regFeeCtrl,
    required this.monthlyCtrl, required this.yearlyCtrl,
    required this.trialDaysCtrl,
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

        _sectionLabel('Registration Fee'),
        const SizedBox(height: 4),
        const Text('One-time fee charged on admission',
            style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 8),
        _rupeeField(regFeeCtrl, 'Amount (one-time)'),

        const SizedBox(height: 20),
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
        const SizedBox(height: 4),
        const Text('Trials are free — just set how many days',
            style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: trialDaysCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            prefixText: '  ',
            hintText: 'Trial duration in days (e.g. 7)',
            suffixText: 'days',
          ),
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
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _role = 'Head Coach';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _addCoach(Map<String, dynamic> academyCoach) {
    final user = (academyCoach['user'] as Map?)?.cast<String, dynamic>() ?? {};
    final phone = user['phone'] as String? ?? '';
    final name  = user['name']  as String? ?? '';
    final cpId  = academyCoach['coachProfileId'] as String?
        ?? academyCoach['coachId'] as String?
        ?? academyCoach['id'] as String?;

    if (widget.coaches.any((c) =>
        (phone.isNotEmpty && c.phone.isNotEmpty && c.phone.endsWith(phone.length >= 10 ? phone.substring(phone.length - 10) : phone)) ||
        (cpId != null && c.coachProfileId == cpId))) {
      showSnack(context, 'Already added');
      return;
    }

    widget.onAdd(_CoachEntry(
      phone:          phone,
      name:           name,
      role:           _role,
      isExisting:     false,
      coachProfileId: cpId,
      foundCoach:     {'userName': name, 'coachProfileId': cpId},
    ));
    _searchCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final allCoaches = ref.watch(coachesProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text('Assign coaches from your academy. Optional — add more later.',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),

        // ── Assigned coaches ───────────────────────────────────────────────
        if (widget.coaches.isNotEmpty) ...[
          _sectionLabel('Assigned  (${widget.coaches.length})'),
          ...List.generate(widget.coaches.length, (i) {
            final c = widget.coaches[i];
            final initial = c.name.isNotEmpty ? c.name[0].toUpperCase() : '?';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
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
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cs.onSurface)),
                        Text(c.role,
                            style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.55))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 18, color: Colors.red.shade400),
                    onPressed: () => widget.onRemove(i),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
        ],

        // ── Role for next addition ─────────────────────────────────────────
        _sectionLabel('Role'),
        DropdownButtonFormField<String>(
          value: _role,
          items: _kRoles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
          onChanged: (v) => setState(() => _role = v!),
          decoration: const InputDecoration(isDense: true),
        ),
        const SizedBox(height: 16),

        // ── Search academy coaches ─────────────────────────────────────────
        _sectionLabel('Add from Academy'),
        TextField(
          controller: _searchCtrl,
          decoration: const InputDecoration(
            hintText: 'Search by name or phone',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 8),

        allCoaches.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (coaches) {
            final active = coaches.where((c) => c['isActive'] != false).toList();
            final assignedIds = widget.coaches
                .map((c) => c.coachProfileId)
                .whereType<String>()
                .toSet();

            final filtered = active.where((c) {
              final cpId = c['coachProfileId'] as String?
                  ?? c['coachId'] as String?
                  ?? c['id'] as String?;
              if (cpId != null && assignedIds.contains(cpId)) return false;
              if (_query.isEmpty) return true;
              final user  = (c['user'] as Map?)?.cast<String, dynamic>() ?? {};
              final name  = (user['name']  as String? ?? '').toLowerCase();
              final phone = (user['phone'] as String? ?? '').toLowerCase();
              return name.contains(_query) || phone.contains(_query);
            }).toList();

            if (active.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No coaches in your academy yet. Add them from the Coaches screen.',
                    style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5))),
              );
            }
            if (filtered.isEmpty && _query.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No match found.',
                    style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5))),
              );
            }
            return Column(
              children: filtered.map((c) {
                final user    = (c['user'] as Map?)?.cast<String, dynamic>() ?? {};
                final name    = user['name']  as String? ?? '—';
                final phone   = user['phone'] as String? ?? '';
                final role    = c['role'] as String?
                    ?? (c['isHeadCoach'] == true ? 'Head Coach' : 'Coach');
                final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
                return GestureDetector(
                  onTap: () => _addCoach(c),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: _kBlue.withValues(alpha: 0.1),
                          child: Text(initial,
                              style: const TextStyle(fontWeight: FontWeight.w800,
                                  color: _kBlue, fontSize: 14)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: TextStyle(fontWeight: FontWeight.w700,
                                  fontSize: 14, color: cs.onSurface)),
                              Text(role, style: TextStyle(fontSize: 12,
                                  color: cs.onSurface.withValues(alpha: 0.55))),
                              if (phone.isNotEmpty)
                                Text(phone, style: TextStyle(fontSize: 11,
                                    color: cs.onSurface.withValues(alpha: 0.4))),
                            ],
                          ),
                        ),
                        Icon(Icons.add_circle_outline_rounded,
                            size: 22, color: _kBlue.withValues(alpha: 0.8)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
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
