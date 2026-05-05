import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../providers/academy_provider.dart';
import '../../shared/widgets.dart';
import 'coach_provider.dart';

const _kRoles = ['Head Coach', 'Batting Coach', 'Bowling Coach', 'Fielding Coach',
    'Wicket-keeping Coach', 'Fitness Coach'];

class InviteCoachSheet extends ConsumerStatefulWidget {
  const InviteCoachSheet({super.key});

  @override
  ConsumerState<InviteCoachSheet> createState() => _InviteCoachSheetState();
}

class _InviteCoachSheetState extends ConsumerState<InviteCoachSheet> {
  final _phoneCtrl  = TextEditingController();
  final _nameCtrl   = TextEditingController();
  final _salaryCtrl = TextEditingController();

  String _role = _kRoles.first;
  bool _searching  = false;
  bool _saving     = false;

  // null = not searched yet, {} = not found, {...} = found
  Map<String, dynamic>? _found;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    _phoneCtrl.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneCtrl.removeListener(_onPhoneChanged);
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    _salaryCtrl.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    if (_found != null || _notFound) {
      setState(() { _found = null; _notFound = false; _nameCtrl.clear(); });
    }
    if (_phoneCtrl.text.trim().length == 10) _search();
  }

  Future<void> _search() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length != 10) return;
    setState(() { _searching = true; _found = null; _notFound = false; });
    try {
      final s = await ref.read(academyProvider.future);
      final res = await ref.read(apiClientProvider)
          .get('/academy/${s.academyId}/coaches', params: {'phone': phone});
      final data = res.data['data'];
      if (data != null) {
        final map = (data as Map).cast<String, dynamic>();
        setState(() {
          _found = map;
          _nameCtrl.text = map['userName'] as String? ?? '';
        });
      } else {
        setState(() => _notFound = true);
      }
    } catch (_) {
      setState(() => _notFound = true);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _add() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length != 10) { showSnack(context, 'Enter a valid 10-digit number'); return; }
    if (_notFound && _nameCtrl.text.trim().isEmpty) {
      showSnack(context, 'Enter coach name'); return;
    }
    setState(() => _saving = true);
    try {
      final salary = int.tryParse(_salaryCtrl.text.trim());
      await ref.read(coachesProvider.notifier).invite({
        'phone': phone,
        if (_nameCtrl.text.trim().isNotEmpty) 'name': _nameCtrl.text.trim(),
        'isHeadCoach': _role == 'Head Coach',
        'role': _role,
        if (salary != null && salary > 0) 'salaryPaise': salary * 100,
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showSnack(context, 'Failed to add coach');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final showDetails = _found != null || _notFound;

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Row(
            children: [
              Text('Add Coach',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: cs.onSurface)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),

          // ── Phone field ──────────────────────────────────────────────────
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: const Icon(Icons.phone_iphone_outlined),
              counterText: '',
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2)))
                  : _found != null
                      ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                      : _notFound
                          ? const Icon(Icons.person_add_outlined, color: Colors.orange)
                          : null,
            ),
          ),

          // ── Result banner ─────────────────────────────────────────────────
          if (_found != null) ...[
            const SizedBox(height: 10),
            _Banner(
              icon: Icons.check_circle_rounded,
              color: Colors.green,
              text: 'Coach found: ${_found!['userName'] ?? ''}',
            ),
          ] else if (_notFound) ...[
            const SizedBox(height: 10),
            _Banner(
              icon: Icons.info_outline_rounded,
              color: Colors.orange,
              text: 'No account found — will create a new one',
            ),
          ],

          // ── Details (shown after search) ──────────────────────────────────
          if (showDetails) ...[
            const SizedBox(height: 12),
            if (_notFound)
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Coach Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
            if (_notFound) const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: _kRoles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setState(() => _role = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _salaryCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Monthly Salary (₹)',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _add,
                child: _saving
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Add Coach'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _Banner({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text,
              style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
