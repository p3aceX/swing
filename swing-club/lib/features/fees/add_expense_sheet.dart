import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../shared/widgets.dart';
import '../coaches/coach_provider.dart';
import '../staff/staff_provider.dart';
import 'fee_provider.dart';

// category meta: label, icon, color
const _kCatMeta = <String, (String, IconData, Color)>{
  'SALARY':         ('Salary',         Icons.person_outline_rounded,    Color(0xFFDD925A)),
  'EQUIPMENT':      ('Equipment',      Icons.sports_cricket_outlined,   Color(0xFF2563EB)),
  'MAINTENANCE':    ('Maintenance',    Icons.build_outlined,            Color(0xFF795548)),
  'INFRASTRUCTURE': ('Infrastructure', Icons.domain_outlined,           Color(0xFF16A34A)),
  'MARKETING':      ('Marketing',      Icons.campaign_outlined,         Color(0xFF7C3AED)),
  'UTILITIES':      ('Utilities',      Icons.bolt_outlined,             Color(0xFF0891B2)),
  'OTHER':          ('Other',          Icons.receipt_long_outlined,     Color(0xFF6B7280)),
};

class AddExpenseSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existing;
  const AddExpenseSheet({super.key, this.existing});

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final _descCtrl   = TextEditingController();
  final _amountCtrl = TextEditingController();
  String   _category    = kExpenseCategories.first;
  DateTime _date        = DateTime.now();
  bool     _isLoading   = false;

  // salary linking
  String? _linkedStaffId;
  String? _linkedCoachLinkId;
  String? _linkedName;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _category          = e['category']    as String? ?? kExpenseCategories.first;
      _descCtrl.text     = e['description'] as String? ?? '';
      _linkedStaffId     = e['staffId']     as String?;
      _linkedCoachLinkId = e['coachLinkId'] as String?;
      _linkedName        = e['payee']       as String?;
      final paise = e['amountPaise'];
      if (paise != null) _amountCtrl.text = (paise / 100).toStringAsFixed(0);
      final dateStr = e['date'] as String?;
      if (dateStr != null) {
        try { _date = DateTime.parse(dateStr).toLocal(); } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _pickPerson({
    required String name,
    required int salaryPaise,
    String? staffId,
    String? coachLinkId,
  }) {
    setState(() {
      _linkedStaffId     = staffId;
      _linkedCoachLinkId = coachLinkId;
      _linkedName        = name;
      _amountCtrl.text   = (salaryPaise / 100).toStringAsFixed(0);
      _descCtrl.text     = 'Monthly Salary – $name';
    });
  }

  void _clearPerson() => setState(() {
    _linkedStaffId     = null;
    _linkedCoachLinkId = null;
    _linkedName        = null;
  });

  Future<void> _save() async {
    if (_descCtrl.text.isEmpty) { showSnack(context, 'Description is required'); return; }
    if (_amountCtrl.text.isEmpty) { showSnack(context, 'Amount is required'); return; }
    setState(() => _isLoading = true);
    try {
      final payload = {
        'category':    _category,
        'description': _descCtrl.text.trim(),
        'amountPaise': ((double.tryParse(_amountCtrl.text) ?? 0) * 100).round(),
        'date':        _date.toIso8601String(),
        if (_linkedName != null)           'payee':       _linkedName,
        if (_linkedStaffId != null)        'staffId':     _linkedStaffId,
        if (_linkedCoachLinkId != null)    'coachLinkId': _linkedCoachLinkId,
      };
      final e = widget.existing;
      if (e != null) {
        await ref.read(expensesProvider.notifier).edit(e['id'] as String, payload);
      } else {
        await ref.read(expensesProvider.notifier).create(payload);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) showSnack(context, 'Failed to save expense');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final cs     = Theme.of(context).colorScheme;
    final meta   = _kCatMeta[_category]!;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Handle + title ───────────────────────────────────────────────
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(children: [
              Text(isEdit ? 'Edit Expense' : 'Add Expense',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: cs.onSurface)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close_rounded, color: cs.onSurface.withValues(alpha: 0.45)),
              ),
            ]),
            const SizedBox(height: 20),

            // ── Category chips ───────────────────────────────────────────────
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: kExpenseCategories.map((cat) {
                  final m       = _kCatMeta[cat]!;
                  final sel     = cat == _category;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _category = cat;
                      if (cat != 'SALARY') {
                        _linkedStaffId = null;
                        _linkedCoachLinkId = null;
                        _linkedName = null;
                      }
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? m.$3.withValues(alpha: 0.15) : cs.surface,
                        border: Border.all(
                          color: sel ? m.$3 : cs.onSurface.withValues(alpha: 0.12),
                          width: sel ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(m.$2, size: 14, color: sel ? m.$3 : cs.onSurface.withValues(alpha: 0.45)),
                        const SizedBox(width: 5),
                        Text(m.$1,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                              color: sel ? m.$3 : cs.onSurface.withValues(alpha: 0.6),
                            )),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // ── Inline person list for SALARY ────────────────────────────────
            if (_category == 'SALARY')
              _InlinePersonList(
                linkedStaffId:     _linkedStaffId,
                linkedCoachLinkId: _linkedCoachLinkId,
                onPick:  _pickPerson,
                onClear: _clearPerson,
              ),

            // ── Description ──────────────────────────────────────────────────
            _FieldLabel('Description'),
            TextField(
              controller: _descCtrl,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              decoration: _inputDeco(cs, hint: 'e.g. Monthly Salary – Rahul'),
            ),
            const SizedBox(height: 16),

            // ── Amount + Date row ─────────────────────────────────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _FieldLabel('Amount'),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    decoration: _inputDeco(cs, prefix: '₹ ', hint: '0'),
                  ),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _FieldLabel('Date'),
                  GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                      );
                      if (d != null) setState(() => _date = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        border: Border.all(color: cs.onSurface.withValues(alpha: 0.12)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        Icon(Icons.calendar_today_outlined, size: 15,
                            color: cs.onSurface.withValues(alpha: 0.5)),
                        const SizedBox(width: 7),
                        Text(DateFormat('d MMM').format(_date),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                                color: cs.onSurface)),
                      ]),
                    ),
                  ),
                ]),
              ),
            ]),
            const SizedBox(height: 24),

            // ── Save button ───────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(isEdit ? 'Update' : 'Save Expense',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Inline person list ────────────────────────────────────────────────────────

class _InlinePersonList extends ConsumerWidget {
  final String? linkedStaffId;
  final String? linkedCoachLinkId;
  final void Function({
    required String name,
    required int salaryPaise,
    String? staffId,
    String? coachLinkId,
  }) onPick;
  final VoidCallback onClear;

  const _InlinePersonList({
    required this.linkedStaffId,
    required this.linkedCoachLinkId,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffList  = ref.watch(staffProvider).valueOrNull  ?? [];
    final coachList  = (ref.watch(coachesProvider).valueOrNull ?? [])
        .where((c) => c['isActive'] != false).toList();
    final cs = Theme.of(context).colorScheme;

    if (staffList.isEmpty && coachList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Icon(Icons.info_outline_rounded, size: 16, color: cs.onSurface.withValues(alpha: 0.4)),
            const SizedBox(width: 10),
            Expanded(child: Text(
              'Add staff or coaches first to link salary expenses.',
              style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5)),
            )),
          ]),
        ),
      );
    }

    // Build unified list with type tag
    final people = <Map<String, dynamic>>[
      ...staffList.map((s) => {...s, '_type': 'STAFF'}),
      ...coachList.map((c) {
        final user = (c['user'] as Map?)?.cast<String, dynamic>() ?? {};
        return {
          ...c,
          '_type':        'COACH',
          '_displayName': user['name'] as String? ?? '—',
        };
      }),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel('Select Person'),
        const SizedBox(height: 6),
        ...people.map((p) {
          final type    = p['_type'] as String;
          final name    = type == 'COACH'
              ? p['_displayName'] as String? ?? '—'
              : p['name'] as String? ?? '—';
          final role    = p['role'] as String?
              ?? (p['isHeadCoach'] == true ? 'Head Coach' : 'Coach');
          final salary  = p['salaryPaise'] as int? ?? 0;
          final id      = p['id'] as String;
          final isSelected = type == 'STAFF'
              ? linkedStaffId == id
              : linkedCoachLinkId == id;
          final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

          return GestureDetector(
            onTap: () {
              if (isSelected) {
                onClear();
              } else {
                onPick(
                  name: name,
                  salaryPaise: salary,
                  staffId:     type == 'STAFF' ? id : null,
                  coachLinkId: type == 'COACH' ? id : null,
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? cs.primary.withValues(alpha: 0.08)
                    : cs.surface,
                border: Border.all(
                  color: isSelected
                      ? cs.primary.withValues(alpha: 0.4)
                      : cs.onSurface.withValues(alpha: 0.1),
                  width: isSelected ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isSelected
                      ? cs.primary.withValues(alpha: 0.15)
                      : cs.onSurface.withValues(alpha: 0.07),
                  child: Text(initial,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? cs.primary : cs.onSurface.withValues(alpha: 0.55),
                      )),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: cs.onSurface,
                        )),
                    Text(role,
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        )),
                  ],
                )),
                if (salary > 0)
                  Text('₹${(salary / 100).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isSelected ? cs.primary : Colors.green.shade700,
                      )),
                const SizedBox(width: 8),
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                  size: 18,
                  color: isSelected ? cs.primary : cs.onSurface.withValues(alpha: 0.25),
                ),
              ]),
            ),
          );
        }),
        const SizedBox(height: 12),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _FieldLabel(String label) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
          color: Color(0x99000000), letterSpacing: 0.2)),
);

InputDecoration _inputDeco(ColorScheme cs, {String? hint, String? prefix}) =>
    InputDecoration(
      hintText: hint,
      prefixText: prefix,
      filled: true,
      fillColor: cs.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.onSurface.withValues(alpha: 0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.onSurface.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
    );
