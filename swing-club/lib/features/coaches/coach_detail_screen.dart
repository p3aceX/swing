import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/api_client.dart';
import '../../providers/academy_provider.dart';
import '../../shared/widgets.dart';
import 'coach_provider.dart';

class CoachDetailScreen extends ConsumerStatefulWidget {
  final String coachId;

  const CoachDetailScreen({super.key, required this.coachId});

  @override
  ConsumerState<CoachDetailScreen> createState() => _CoachDetailScreenState();
}

class _CoachDetailScreenState extends ConsumerState<CoachDetailScreen> {
  Map<String, dynamic>? _coachData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final academyState = await ref.read(academyProvider.future);
      final res = await ref
          .read(apiClientProvider)
          .get('/academy/${academyState.academyId}/coaches/${widget.coachId}');
      setState(() => _coachData = Map<String, dynamic>.from(res.data['data'] as Map));
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _coachData?['user'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(user['name'] as String? ?? 'Coach'),
        actions: [
          if (_coachData != null)
            TextButton(
              onPressed: _deactivate,
              child: const Text('Deactivate', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: _isLoading
          ? loadingBody()
          : _coachData == null
              ? errorBody(Exception('Failed to load'), _load)
              : _CoachBody(
                  coach: _coachData!,
                  coachId: widget.coachId,
                  onSetupComp: _showCompSheet,
                ),
    );
  }

  Future<void> _deactivate() async {
    try {
      await ref.read(coachesProvider.notifier).updateCoach(widget.coachId, {'isActive': false});
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showSnack(context, 'Failed to deactivate');
    }
  }

  void _showCompSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _CompensationSheet(coachId: widget.coachId),
    );
  }
}

class _CoachBody extends StatelessWidget {
  final Map<String, dynamic> coach;
  final String coachId;
  final VoidCallback onSetupComp;

  const _CoachBody({required this.coach, required this.coachId, required this.onSetupComp});

  @override
  Widget build(BuildContext context) {
    final user = coach['user'] as Map<String, dynamic>? ?? {};
    final batches = (coach['batches'] as List? ?? []).cast<Map<String, dynamic>>();

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user['bio'] != null) ...[
                Text(user['bio'] as String,
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 12),
              ],
              if (user['specializations'] != null)
                Text('Specializations: ${user['specializations']}',
                    style: const TextStyle(fontSize: 14)),
              if (user['experienceYears'] != null) ...[
                const SizedBox(height: 4),
                Text('Experience: ${user['experienceYears']} years',
                    style: const TextStyle(fontSize: 14)),
              ],
              if (coach['isHeadCoach'] == true) ...[
                const SizedBox(height: 8),
                statusBadge('HEAD COACH'),
              ],
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Text('Assigned Batches',
              style: const TextStyle(fontSize: 13, color: Colors.grey,
                  fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        ),
        if (batches.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text('No batches assigned', style: TextStyle(color: Colors.grey)),
          )
        else
          ...batches.map((b) => Column(children: [
                ListTile(
                  dense: true,
                  title: Text(b['name'] as String? ?? '—'),
                ),
                const Divider(),
              ])),
        ListTile(
          title: const Text('Set Up Compensation'),
          leading: const Icon(Icons.payments_outlined),
          trailing: const Icon(Icons.chevron_right, size: 20),
          onTap: onSetupComp,
        ),
      ],
    );
  }
}

class _CompensationSheet extends ConsumerStatefulWidget {
  final String coachId;

  const _CompensationSheet({required this.coachId});

  @override
  ConsumerState<_CompensationSheet> createState() => _CompensationSheetState();
}

class _CompensationSheetState extends ConsumerState<_CompensationSheet> {
  String _compType = kCompensationTypes.first;
  String _payoutCycle = kPayoutCycles.first;
  final _amountCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final academyState = await ref.read(academyProvider.future);
      await ref.read(apiClientProvider).post('/payroll/compensation', data: {
        'coachId': widget.coachId,
        'academyId': academyState.academyId,
        'compensationType': _compType,
        'amount': (double.tryParse(_amountCtrl.text) ?? 0) * 100,
        'payoutCycle': _payoutCycle,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showSnack(context, 'Failed to save compensation');
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Compensation Setup',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _compType,
            decoration: const InputDecoration(labelText: 'Compensation Type'),
            items: kCompensationTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _compType = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount (₹)', prefixText: '₹ '),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _payoutCycle,
            decoration: const InputDecoration(labelText: 'Payout Cycle'),
            items: kPayoutCycles
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _payoutCycle = v!),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _save,
            child: const Text('Save Compensation'),
          ),
        ],
      ),
    );
  }
}
