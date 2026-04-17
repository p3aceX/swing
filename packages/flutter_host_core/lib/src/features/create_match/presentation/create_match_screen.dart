import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/create_match_controller.dart';
import 'toss_screen.dart';

class CreateMatchScreen extends ConsumerStatefulWidget {
  const CreateMatchScreen({
    super.key,
    this.existingMatchId,
    this.existingTeamAName,
    this.existingTeamBName,
  });

  final String? existingMatchId;
  final String? existingTeamAName;
  final String? existingTeamBName;

  @override
  ConsumerState<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends ConsumerState<CreateMatchScreen> {
  late final TextEditingController _teamACtrl;
  late final TextEditingController _teamBCtrl;
  final _venueCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _customOversCtrl = TextEditingController();
  String _format = 'T20';
  String _matchType = 'FRIENDLY';
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 2));
  bool _hasImpactPlayer = false;

  @override
  void initState() {
    super.initState();
    _teamACtrl = TextEditingController(text: widget.existingTeamAName ?? '');
    _teamBCtrl = TextEditingController(text: widget.existingTeamBName ?? '');
  }

  @override
  void dispose() {
    _teamACtrl.dispose();
    _teamBCtrl.dispose();
    _venueCtrl.dispose();
    _cityCtrl.dispose();
    _customOversCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _scheduledAt,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null || !mounted) return;
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    final matchId =
        await ref.read(hostCreateMatchControllerProvider.notifier).createMatch(
              teamAName: _teamACtrl.text,
              teamBName: _teamBCtrl.text,
              venueName: _venueCtrl.text,
              venueCity: _cityCtrl.text,
              scheduledAt: _scheduledAt,
              format: _format,
              matchType: _matchType,
              customOvers: _format == 'CUSTOM'
                  ? int.tryParse(_customOversCtrl.text.trim())
                  : null,
              hasImpactPlayer: _hasImpactPlayer,
            );
    if (!mounted || matchId == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TossScreen(
          matchId: matchId,
          teamAName: _teamACtrl.text.trim().isEmpty
              ? 'Team A'
              : _teamACtrl.text.trim(),
          teamBName: _teamBCtrl.text.trim().isEmpty
              ? 'Team B'
              : _teamBCtrl.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hostCreateMatchControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Match')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _teamACtrl,
            decoration: const InputDecoration(labelText: 'Team A'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _teamBCtrl,
            decoration: const InputDecoration(labelText: 'Team B'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _format,
            decoration: const InputDecoration(labelText: 'Format'),
            items: const [
              DropdownMenuItem(value: 'T10', child: Text('T10')),
              DropdownMenuItem(value: 'T20', child: Text('T20')),
              DropdownMenuItem(value: 'ONE_DAY', child: Text('One Day')),
              DropdownMenuItem(value: 'TEST', child: Text('Test')),
              DropdownMenuItem(value: 'CUSTOM', child: Text('Custom')),
            ],
            onChanged: (value) => setState(() => _format = value ?? 'T20'),
          ),
          if (_format == 'CUSTOM') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _customOversCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Custom overs'),
            ),
          ],
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _matchType,
            decoration: const InputDecoration(labelText: 'Match type'),
            items: const [
              DropdownMenuItem(value: 'FRIENDLY', child: Text('Friendly')),
              DropdownMenuItem(value: 'TOURNAMENT', child: Text('Tournament')),
              DropdownMenuItem(value: 'CORPORATE', child: Text('Corporate')),
              DropdownMenuItem(value: 'ACADEMY', child: Text('Academy')),
            ],
            onChanged: (value) =>
                setState(() => _matchType = value ?? 'FRIENDLY'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _venueCtrl,
            decoration: const InputDecoration(labelText: 'Venue'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cityCtrl,
            decoration: const InputDecoration(labelText: 'City'),
          ),
          const SizedBox(height: 12),
          _ScheduleRow(
            label: 'Scheduled at',
            value: _scheduledAt.toLocal().toString(),
            action: OutlinedButton(
              onPressed: _pickDateTime,
              child: const Text('Pick'),
            ),
          ),
          SwitchListTile(
            value: _hasImpactPlayer,
            onChanged: (value) => setState(() => _hasImpactPlayer = value),
            title: const Text('Impact player enabled'),
            contentPadding: EdgeInsets.zero,
          ),
          if ((state.error ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                state.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          FilledButton(
            onPressed: state.isSubmitting ? null : _submit,
            child: Text(state.isSubmitting ? 'Creating...' : 'Create match'),
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.label,
    required this.value,
    required this.action,
  });

  final String label;
  final String value;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        action,
      ],
    );
  }
}
