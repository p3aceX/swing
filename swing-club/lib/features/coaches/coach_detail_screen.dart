import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets.dart';
import 'coach_provider.dart';

const _kNavy = Color(0xFF071B3D);
const _kBlue = Color(0xFF0057C8);

const _kRoles = ['Head Coach', 'Batting Coach', 'Bowling Coach', 'Fielding Coach',
    'Wicket-keeping Coach', 'Fitness Coach'];

class CoachDetailScreen extends ConsumerWidget {
  final String coachId;
  const CoachDetailScreen({super.key, required this.coachId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(coachDetailProvider(coachId));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: async.maybeWhen(
          data: (d) => Text(
            (d['user'] as Map?)?.cast<String, dynamic>()?['name'] as String? ?? 'Coach',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
          ),
          orElse: () => const Text('Coach'),
        ),
        actions: [
          if (async.hasValue)
            TextButton(
              onPressed: () => _deactivate(context, ref),
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: async.when(
        loading: loadingBody,
        error: (e, _) => errorBody(e, () => ref.invalidate(coachDetailProvider(coachId))),
        data: (coach) => _Body(coach: coach, coachId: coachId),
      ),
    );
  }

  Future<void> _deactivate(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Coach'),
        content: const Text('Remove this coach from your academy?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref.read(coachesProvider.notifier).updateCoach(coachId, {'isActive': false});
        if (context.mounted) Navigator.pop(context);
      } catch (_) {
        if (context.mounted) showSnack(context, 'Failed to remove coach');
      }
    }
  }
}

class _Body extends ConsumerWidget {
  final Map<String, dynamic> coach;
  final String coachId;
  const _Body({required this.coach, required this.coachId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user    = (coach['user'] as Map?)?.cast<String, dynamic>() ?? {};
    final name    = user['name'] as String? ?? '—';
    final phone   = user['phone'] as String? ?? '';
    final role    = coach['role'] as String? ?? (coach['isHeadCoach'] == true ? 'Head Coach' : 'Coach');
    final salary  = coach['salaryPaise'] as int?;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        // ── Profile header ──────────────────────────────────────────────────
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF0057C8).withValues(alpha: 0.1),
              child: Text(initial,
                  style: const TextStyle(color: _kBlue, fontWeight: FontWeight.w800, fontSize: 22)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: cs.onSurface)),
                  if (phone.isNotEmpty)
                    Text(phone,
                        style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.55))),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Info tiles ──────────────────────────────────────────────────────
        _InfoTile(label: 'Role', value: role),
        _InfoTile(
          label: 'Monthly Salary',
          value: salary != null ? '₹${(salary / 100).toStringAsFixed(0)}' : 'Not set',
        ),
        const SizedBox(height: 24),

        // ── Edit section ────────────────────────────────────────────────────
        Text('Update Details',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: cs.onSurface.withValues(alpha: 0.5), letterSpacing: 0.5)),
        const SizedBox(height: 12),
        _EditForm(coach: coach, coachId: coachId),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(label,
              style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w500))),
          Text(value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface)),
        ],
      ),
    );
  }
}

class _EditForm extends ConsumerStatefulWidget {
  final Map<String, dynamic> coach;
  final String coachId;
  const _EditForm({required this.coach, required this.coachId});

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  late String _role;
  late TextEditingController _salaryCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _role = widget.coach['role'] as String?
        ?? (widget.coach['isHeadCoach'] == true ? 'Head Coach' : _kRoles.first);
    if (!_kRoles.contains(_role)) _role = _kRoles.first;
    final salary = widget.coach['salaryPaise'] as int?;
    _salaryCtrl = TextEditingController(
        text: salary != null ? (salary ~/ 100).toString() : '');
  }

  @override
  void dispose() {
    _salaryCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final salary = int.tryParse(_salaryCtrl.text.trim());
      await ref.read(coachesProvider.notifier).updateCoach(widget.coachId, {
        'role': _role,
        'isHeadCoach': _role == 'Head Coach',
        if (salary != null) 'salaryPaise': salary * 100,
      });
      ref.invalidate(coachDetailProvider(widget.coachId));
      if (mounted) showSnack(context, 'Updated');
    } catch (_) {
      if (mounted) showSnack(context, 'Failed to update');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
          decoration: const InputDecoration(
            labelText: 'Monthly Salary (₹)',
            prefixText: '₹ ',
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save Changes'),
          ),
        ),
      ],
    );
  }
}
