import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../repositories/host_tournament_repository.dart';
import '../../../theme/host_colors.dart';
import '../../create_match/presentation/form_widgets.dart';
import 'tournament_detail_screen.dart';

typedef HostTournamentCreated = void Function(
  BuildContext context,
  Map<String, dynamic> tournament,
);

class HostCreateTournamentScreen extends ConsumerStatefulWidget {
  const HostCreateTournamentScreen({
    super.key,
    this.onTournamentCreated,
    this.title = 'Create Tournament',
  });

  final HostTournamentCreated? onTournamentCreated;
  final String title;

  @override
  ConsumerState<HostCreateTournamentScreen> createState() =>
      _HostCreateTournamentScreenState();
}

class _HostCreateTournamentScreenState
    extends ConsumerState<HostCreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _venueController = TextEditingController();
  final _maxTeamsController = TextEditingController(text: '8');
  final _entryFeeController = TextEditingController();
  final _earlyBirdFeeController = TextEditingController();
  final _prizePoolController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _seriesMatchCountController = TextEditingController(text: '3');
  final _organiserNameController = TextEditingController();
  final _organiserPhoneController = TextEditingController();

  String _format = 'T20';
  String _tournamentFormat = 'LEAGUE';
  String _ballType = 'LEATHER';
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime? _endDate;
  DateTime? _earlyBirdDeadline;
  bool _isPublic = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _venueController.dispose();
    _maxTeamsController.dispose();
    _entryFeeController.dispose();
    _earlyBirdFeeController.dispose();
    _prizePoolController.dispose();
    _descriptionController.dispose();
    _seriesMatchCountController.dispose();
    _organiserNameController.dispose();
    _organiserPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked == null || !mounted) return;
    onSelected(picked);
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final tournament =
          await ref.read(hostTournamentRepositoryProvider).createTournament(
                name: _nameController.text,
                format: _format,
                tournamentFormat: _tournamentFormat,
                startDate: _startDate,
                endDate: _endDate,
                city: _cityController.text,
                venueName: _venueController.text,
                maxTeams: int.tryParse(_maxTeamsController.text.trim()),
                entryFee: int.tryParse(_entryFeeController.text.trim()),
                prizePool: _prizePoolController.text,
                description: _descriptionController.text,
                isPublic: _isPublic,
                seriesMatchCount: _tournamentFormat == 'SERIES'
                    ? int.tryParse(_seriesMatchCountController.text.trim())
                    : null,
                ballType: _ballType,
                earlyBirdDeadline: _earlyBirdDeadline,
                earlyBirdFee: int.tryParse(_earlyBirdFeeController.text.trim()),
                organiserName: _organiserNameController.text,
                organiserPhone: _organiserPhoneController.text,
              );
      if (!mounted) return;
      widget.onTournamentCreated?.call(context, tournament);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HostTournamentDetailScreen(
            tournamentId: '${tournament['id'] ?? ''}',
            initialData: tournament,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            HostFormSection(
              title: 'Basics',
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: 'Tournament name'),
                    validator: (value) {
                      if ((value ?? '').trim().length < 2) {
                        return 'Enter a valid tournament name.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _format,
                    decoration:
                        const InputDecoration(labelText: 'Match format'),
                    items: const [
                      DropdownMenuItem(value: 'T10', child: Text('T10')),
                      DropdownMenuItem(value: 'T20', child: Text('T20')),
                      DropdownMenuItem(
                          value: 'ONE_DAY', child: Text('One Day')),
                      DropdownMenuItem(
                        value: 'TWO_INNINGS',
                        child: Text('Two Innings'),
                      ),
                      DropdownMenuItem(
                        value: 'BOX_CRICKET',
                        child: Text('Box Cricket'),
                      ),
                      DropdownMenuItem(value: 'CUSTOM', child: Text('Custom')),
                    ],
                    onChanged: (value) =>
                        setState(() => _format = value ?? 'T20'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _tournamentFormat,
                    decoration:
                        const InputDecoration(labelText: 'Tournament format'),
                    items: const [
                      DropdownMenuItem(value: 'LEAGUE', child: Text('League')),
                      DropdownMenuItem(
                          value: 'KNOCKOUT', child: Text('Knockout')),
                      DropdownMenuItem(
                        value: 'GROUP_STAGE_KNOCKOUT',
                        child: Text('Group Stage + Knockout'),
                      ),
                      DropdownMenuItem(
                        value: 'DOUBLE_ELIMINATION',
                        child: Text('Double Elimination'),
                      ),
                      DropdownMenuItem(
                          value: 'SUPER_LEAGUE', child: Text('Super League')),
                      DropdownMenuItem(value: 'SERIES', child: Text('Series')),
                    ],
                    onChanged: (value) =>
                        setState(() => _tournamentFormat = value ?? 'LEAGUE'),
                  ),
                  if (_tournamentFormat == 'SERIES') ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _seriesMatchCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Series match count',
                      ),
                      validator: (value) {
                        if (_tournamentFormat != 'SERIES') return null;
                        final parsed = int.tryParse((value ?? '').trim());
                        if (parsed == null || parsed < 1 || parsed > 15) {
                          return 'Enter a value between 1 and 15.';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            HostFormSection(
              title: 'Schedule',
              child: Column(
                children: [
                  _ActionFieldRow(
                    label: 'Start date',
                    value: DateFormat('dd MMM yyyy').format(_startDate),
                    actions: [
                      OutlinedButton(
                        onPressed: () => _pickDate(
                          initialDate: _startDate,
                          firstDate:
                              DateTime.now().subtract(const Duration(days: 1)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 730)),
                          onSelected: (value) => setState(() {
                            _startDate =
                                DateTime(value.year, value.month, value.day, 9);
                            if (_endDate != null &&
                                _endDate!.isBefore(_startDate)) {
                              _endDate = _startDate;
                            }
                          }),
                        ),
                        child: const Text('Pick'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ActionFieldRow(
                    label: 'End date',
                    value: _endDate == null
                        ? 'Optional'
                        : DateFormat('dd MMM yyyy').format(_endDate!),
                    actions: [
                      if (_endDate != null)
                        TextButton(
                          onPressed: () => setState(() => _endDate = null),
                          child: const Text('Clear'),
                        ),
                      OutlinedButton(
                        onPressed: () => _pickDate(
                          initialDate: _endDate ?? _startDate,
                          firstDate: _startDate,
                          lastDate:
                              DateTime.now().add(const Duration(days: 730)),
                          onSelected: (value) => setState(() {
                            _endDate = DateTime(
                                value.year, value.month, value.day, 18);
                          }),
                        ),
                        child: const Text('Pick'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            HostFormSection(
              title: 'Venue',
              child: Column(
                children: [
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _venueController,
                    decoration: const InputDecoration(labelText: 'Venue name'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            HostFormSection(
              title: 'Competition Setup',
              child: Column(
                children: [
                  TextFormField(
                    controller: _maxTeamsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Max teams'),
                    validator: (value) {
                      final parsed = int.tryParse((value ?? '').trim());
                      if (parsed == null || parsed < 2) {
                        return 'Minimum 2 teams required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _ballType,
                    decoration: const InputDecoration(labelText: 'Ball type'),
                    items: const [
                      DropdownMenuItem(
                          value: 'LEATHER', child: Text('Leather')),
                      DropdownMenuItem(value: 'TENNIS', child: Text('Tennis')),
                      DropdownMenuItem(value: 'SEASON', child: Text('Season')),
                      DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                    ],
                    onChanged: (value) =>
                        setState(() => _ballType = value ?? 'LEATHER'),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _isPublic,
                    onChanged: (value) => setState(() => _isPublic = value),
                    title: const Text('Public tournament'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            HostFormSection(
              title: 'Fees & Prize',
              child: Column(
                children: [
                  TextFormField(
                    controller: _entryFeeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Entry fee'),
                  ),
                  const SizedBox(height: 12),
                  _ActionFieldRow(
                    label: 'Early bird deadline',
                    value: _earlyBirdDeadline == null
                        ? 'Optional'
                        : DateFormat('dd MMM yyyy').format(_earlyBirdDeadline!),
                    actions: [
                      if (_earlyBirdDeadline != null)
                        TextButton(
                          onPressed: () =>
                              setState(() => _earlyBirdDeadline = null),
                          child: const Text('Clear'),
                        ),
                      OutlinedButton(
                        onPressed: () => _pickDate(
                          initialDate: _earlyBirdDeadline ??
                              _startDate.subtract(const Duration(days: 7)),
                          firstDate:
                              DateTime.now().subtract(const Duration(days: 1)),
                          lastDate: _startDate,
                          onSelected: (value) => setState(() {
                            _earlyBirdDeadline = DateTime(
                              value.year,
                              value.month,
                              value.day,
                              23,
                              59,
                            );
                          }),
                        ),
                        child: const Text('Pick'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _earlyBirdFeeController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Early bird fee'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _prizePoolController,
                    decoration: const InputDecoration(labelText: 'Prize pool'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            HostFormSection(
              title: 'Organiser',
              child: Column(
                children: [
                  TextFormField(
                    controller: _organiserNameController,
                    decoration:
                        const InputDecoration(labelText: 'Organiser name'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _organiserPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration:
                        const InputDecoration(labelText: 'Organiser phone'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            HostFormSection(
              title: 'Description',
              child: TextFormField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 7,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            if ((_error ?? '').isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: context.danger),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: Text(
                _isSubmitting ? 'Creating...' : 'Create tournament',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionFieldRow extends StatelessWidget {
  const _ActionFieldRow({
    required this.label,
    required this.value,
    required this.actions,
  });

  final String label;
  final String value;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.stroke),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.fg,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: context.fgSub),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: actions,
          ),
        ],
      ),
    );
  }
}
