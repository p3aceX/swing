import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../features/arena_booking/domain/arena_booking_models.dart';
import '../../../repositories/host_arena_repository.dart';
import '../../../repositories/host_tournament_repository.dart';
import '../../../theme/host_colors.dart';

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
    extends ConsumerState<HostCreateTournamentScreen>
    with SingleTickerProviderStateMixin {
  // ── Step management ────────────────────────────────────────────────────────
  static const int _totalSteps = 6;
  int _currentStep = 0;
  late final PageController _pageController;

  // ── Form keys per step ─────────────────────────────────────────────────────
  final _step1Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  // ── Field state ────────────────────────────────────────────────────────────
  final _nameController = TextEditingController();
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

  // ── Venue state ────────────────────────────────────────────────────────────
  ArenaListing? _selectedVenue;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
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

  // ── Navigation ─────────────────────────────────────────────────────────────

  bool _validateCurrentStep() {
    if (_currentStep == 0) return _step1Key.currentState?.validate() ?? false;
    if (_currentStep == 3) return _step3Key.currentState?.validate() ?? false;
    return true;
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (!_validateCurrentStep()) return;
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _skipStep() {
    setState(() => _currentStep++);
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final tournament =
          await ref.read(hostTournamentRepositoryProvider).createTournament(
                name: _nameController.text.trim(),
                format: _format,
                tournamentFormat: _tournamentFormat,
                startDate: _startDate,
                endDate: _endDate,
                city: _selectedVenue?.city ?? '',
                venueName: _selectedVenue?.name ?? '',
                maxTeams: int.tryParse(_maxTeamsController.text.trim()),
                entryFee: int.tryParse(_entryFeeController.text.trim()),
                prizePool: _prizePoolController.text.trim(),
                description: _descriptionController.text.trim(),
                isPublic: _isPublic,
                seriesMatchCount: _tournamentFormat == 'SERIES'
                    ? int.tryParse(_seriesMatchCountController.text.trim())
                    : null,
                ballType: _ballType,
                earlyBirdDeadline: _earlyBirdDeadline,
                earlyBirdFee:
                    int.tryParse(_earlyBirdFeeController.text.trim()),
                organiserName: _organiserNameController.text.trim(),
                organiserPhone: _organiserPhoneController.text.trim(),
              );
      if (!mounted) return;
      widget.onTournamentCreated?.call(context, tournament);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Date picker helper ─────────────────────────────────────────────────────

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

  // ── Venue picker helper ────────────────────────────────────────────────────

  Future<void> _pickVenue() async {
    final result = await showModalBottomSheet<ArenaListing?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VenuePickerSheet(ref: ref),
    );
    if (!mounted) return;
    if (result != null) setState(() => _selectedVenue = result);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final steps = [
      _Step1Identity(
        formKey: _step1Key,
        nameController: _nameController,
        format: _format,
        onFormatChanged: (v) => setState(() => _format = v),
      ),
      _Step2Structure(
        tournamentFormat: _tournamentFormat,
        seriesMatchCountController: _seriesMatchCountController,
        onTournamentFormatChanged: (v) => setState(() => _tournamentFormat = v),
      ),
      _Step2Schedule(
        startDate: _startDate,
        endDate: _endDate,
        selectedVenue: _selectedVenue,
        onPickStartDate: () => _pickDate(
          initialDate: _startDate,
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 730)),
          onSelected: (v) => setState(() {
            _startDate = DateTime(v.year, v.month, v.day, 9);
            if (_endDate != null && _endDate!.isBefore(_startDate)) {
              _endDate = _startDate;
            }
          }),
        ),
        onPickEndDate: () => _pickDate(
          initialDate: _endDate ?? _startDate,
          firstDate: _startDate,
          lastDate: DateTime.now().add(const Duration(days: 730)),
          onSelected: (v) => setState(() =>
              _endDate = DateTime(v.year, v.month, v.day, 18)),
        ),
        onClearEndDate: () => setState(() => _endDate = null),
        onPickVenue: _pickVenue,
      ),
      _Step3Teams(
        formKey: _step3Key,
        maxTeamsController: _maxTeamsController,
        ballType: _ballType,
        isPublic: _isPublic,
        onBallTypeChanged: (v) => setState(() => _ballType = v),
        onPublicChanged: (v) => setState(() => _isPublic = v),
      ),
      _Step4Fees(
        entryFeeController: _entryFeeController,
        earlyBirdFeeController: _earlyBirdFeeController,
        prizePoolController: _prizePoolController,
        earlyBirdDeadline: _earlyBirdDeadline,
        onPickEarlyBirdDeadline: () => _pickDate(
          initialDate: _earlyBirdDeadline ??
              _startDate.subtract(const Duration(days: 7)),
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          lastDate: _startDate.add(const Duration(days: 60)),
          onSelected: (v) => setState(() => _earlyBirdDeadline =
              DateTime(v.year, v.month, v.day, 23, 59)),
        ),
        onClearEarlyBirdDeadline: () =>
            setState(() => _earlyBirdDeadline = null),
      ),
      _Step5Organiser(
        organiserNameController: _organiserNameController,
        organiserPhoneController: _organiserPhoneController,
        descriptionController: _descriptionController,
        error: _error,
      ),
    ];

    final stepMeta = [
      (label: 'Identity', icon: Icons.emoji_events_rounded),
      (label: 'Structure', icon: Icons.account_tree_rounded),
      (label: 'Schedule', icon: Icons.calendar_today_rounded),
      (label: 'Teams', icon: Icons.groups_rounded),
      (label: 'Fees', icon: Icons.confirmation_number_rounded),
      (label: 'Organiser', icon: Icons.person_rounded),
    ];

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: context.fg),
          onPressed: _back,
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: context.fg,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Step indicator ────────────────────────────────────────────────
          _StepIndicator(
            steps: stepMeta,
            current: _currentStep,
          ),

          // ── Page content ──────────────────────────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: steps,
            ),
          ),

          // ── Nav row ───────────────────────────────────────────────────────
          _NavRow(
            step: _currentStep,
            totalSteps: _totalSteps,
            isSubmitting: _isSubmitting,
            canSkip: _currentStep == 4,
            onBack: _back,
            onNext: _next,
            onSkip: _skipStep,
          ),
        ],
      ),
    );
  }
}

// ── Step indicator ─────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.steps, required this.current});

  final List<({String label, IconData icon})> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            _StepDot(
              index: i,
              label: steps[i].label,
              icon: steps[i].icon,
              state: i < current
                  ? _DotState.done
                  : i == current
                      ? _DotState.active
                      : _DotState.upcoming,
            ),
            if (i < steps.length - 1)
              Expanded(
                child: Container(
                  height: 1.5,
                  margin: const EdgeInsets.only(bottom: 16),
                  color: i < current
                      ? context.accent
                      : context.stroke,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

enum _DotState { done, active, upcoming }

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.index,
    required this.label,
    required this.icon,
    required this.state,
  });

  final int index;
  final String label;
  final IconData icon;
  final _DotState state;

  @override
  Widget build(BuildContext context) {
    final isDone = state == _DotState.done;
    final isActive = state == _DotState.active;

    final bg = isDone
        ? context.accent
        : isActive
            ? context.accent.withValues(alpha: 0.15)
            : context.stroke.withValues(alpha: 0.4);
    final fg = isDone
        ? context.bg
        : isActive
            ? context.accent
            : context.fgSub;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: isActive
                ? Border.all(color: context.accent, width: 1.5)
                : null,
          ),
          child: Center(
            child: isDone
                ? Icon(Icons.check_rounded, size: 15, color: fg)
                : Icon(icon, size: 15, color: fg),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? context.accent : context.fgSub,
            fontSize: 9,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Nav row ────────────────────────────────────────────────────────────────────

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.step,
    required this.totalSteps,
    required this.isSubmitting,
    required this.canSkip,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
  });

  final int step;
  final int totalSteps;
  final bool isSubmitting;
  final bool canSkip;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final isLast = step == totalSteps - 1;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
      decoration: BoxDecoration(
        color: context.bg,
        border: Border(top: BorderSide(color: context.stroke)),
      ),
      child: Row(
        children: [
          if (step > 0)
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.panel,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: context.fg),
              ),
            )
          else
            const SizedBox(width: 44),
          const SizedBox(width: 12),
          if (canSkip) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: onSkip,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.stroke),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Set later',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: canSkip ? 2 : 1,
            child: GestureDetector(
              onTap: isSubmitting ? null : onNext,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 44,
                decoration: BoxDecoration(
                  color: isSubmitting
                      ? context.accent.withValues(alpha: 0.5)
                      : context.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isSubmitting
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.bg,
                          ),
                        )
                      : Text(
                          isLast ? 'Create Tournament' : 'Continue',
                          style: TextStyle(
                            color: context.bg,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 1: Identity ───────────────────────────────────────────────────────────

class _Step1Identity extends StatelessWidget {
  const _Step1Identity({
    required this.formKey,
    required this.nameController,
    required this.format,
    required this.onFormatChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final String format;
  final ValueChanged<String> onFormatChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _StepHeader(
            title: 'What kind of tournament?',
            subtitle: 'Give it a name and choose how matches will be played.',
          ),
          const SizedBox(height: 24),

          // Name
          _FieldLabel(label: 'Tournament name'),
          const SizedBox(height: 8),
          TextFormField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(
                color: context.fg, fontSize: 15, fontWeight: FontWeight.w600),
            decoration: _inputDecoration(context, hint: 'e.g. Summer Cup 2025'),
            validator: (v) =>
                (v ?? '').trim().length < 2 ? 'Enter a valid name' : null,
          ),
          const SizedBox(height: 24),

          // Match format
          _FieldLabel(label: 'Match format'),
          const SizedBox(height: 10),
          _ChipGrid(
            options: const [
              ('T10', 'T10'),
              ('T20', 'T20'),
              ('ONE_DAY', 'ODI'),
              ('TWO_INNINGS', 'Test'),
              ('BOX_CRICKET', 'Box Cricket'),
              ('CUSTOM', 'Custom'),
            ],
            selected: format,
            onSelected: onFormatChanged,
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Structure preview ──────────────────────────────────────────────────

class _Step2Structure extends StatelessWidget {
  const _Step2Structure({
    required this.tournamentFormat,
    required this.seriesMatchCountController,
    required this.onTournamentFormatChanged,
  });
  final String tournamentFormat;
  final TextEditingController seriesMatchCountController;
  final ValueChanged<String> onTournamentFormatChanged;

  @override
  Widget build(BuildContext context) {
    final info = _formatInfo(tournamentFormat);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _StepHeader(
          title: 'Tournament structure',
          subtitle: 'Pick a format — see how it plays out below.',
        ),
        const SizedBox(height: 20),

        // Format selector
        _ChipGrid(
          options: const [
            ('LEAGUE', 'League'),
            ('KNOCKOUT', 'Knockout'),
            ('GROUP_STAGE_KNOCKOUT', 'Group + KO'),
            ('SERIES', 'Series'),
            ('SUPER_LEAGUE', 'Super League'),
            ('DOUBLE_ELIMINATION', 'Double Elim'),
          ],
          selected: tournamentFormat,
          onSelected: onTournamentFormatChanged,
        ),

        if (tournamentFormat == 'SERIES') ...[
          const SizedBox(height: 20),
          _FieldLabel(label: 'Matches per series'),
          const SizedBox(height: 8),
          TextField(
            controller: seriesMatchCountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
                color: context.fg, fontSize: 15, fontWeight: FontWeight.w600),
            decoration: _inputDecoration(context, hint: '3'),
          ),
        ],

        const SizedBox(height: 28),
        Text(
          info.description,
          style: TextStyle(color: context.fgSub, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 20),
        _buildDiagram(context),
        const SizedBox(height: 28),
        _buildPhaseList(context, info.phases),
      ],
    );
  }

  Widget _buildDiagram(BuildContext context) {
    return switch (tournamentFormat) {
      'LEAGUE'              => _LeagueDiagram(),
      'KNOCKOUT'            => _KnockoutDiagram(),
      'GROUP_STAGE_KNOCKOUT'=> _GroupKnockoutDiagram(),
      'SERIES'              => _SeriesDiagram(),
      'SUPER_LEAGUE'        => _SuperLeagueDiagram(),
      'DOUBLE_ELIMINATION'  => _DoubleEliminationDiagram(),
      _                     => _LeagueDiagram(),
    };
  }

  Widget _buildPhaseList(BuildContext context, List<(String, String)> phases) {
    return Column(
      children: [
        for (var i = 0; i < phases.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: context.accentBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: context.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  if (i < phases.length - 1)
                    Container(width: 1.5, height: 28, color: context.stroke),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phases[i].$1,
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phases[i].$2,
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  ({String description, List<(String, String)> phases}) _formatInfo(String fmt) =>
      switch (fmt) {
        'LEAGUE' => (
          description: 'Every team plays every other team. The best record wins.',
          phases: [
            ('Round Robin', 'All confirmed teams play against each other once.'),
            ('Standings', 'Points are tallied — wins, draws, and run-rate determine rank.'),
            ('Champion', 'Top of the table is crowned the winner.'),
          ],
        ),
        'KNOCKOUT' => (
          description: 'One loss and you\'re out. Highest seeds face off in a bracket.',
          phases: [
            ('Seeding', 'Teams are seeded and slotted into the bracket.'),
            ('Rounds', 'Each round eliminates half the field — QF, SF, Final.'),
            ('Champion', 'The last team standing wins.'),
          ],
        ),
        'GROUP_STAGE_KNOCKOUT' => (
          description: 'Teams compete in groups first, then the top teams advance to a knockout.',
          phases: [
            ('Group Stage', 'Teams are split into groups and play round-robin within each group.'),
            ('Qualification', 'Top teams from each group advance to the knockout rounds.'),
            ('Knockout', 'Single-elimination bracket until the final.'),
            ('Champion', 'The winner of the final is crowned.'),
          ],
        ),
        'SERIES' => (
          description: 'Two teams play a fixed number of matches against each other.',
          phases: [
            ('Matches', 'A set number of games are played between the two sides.'),
            ('Series Result', 'The team with the most wins takes the series.'),
          ],
        ),
        'SUPER_LEAGUE' => (
          description: 'Teams start in groups, top performers form a super league round.',
          phases: [
            ('Group Stage', 'Teams play within their groups to earn points.'),
            ('Super League', 'Top qualifiers from groups play a final league stage.'),
            ('Champion', 'Highest points in the super league wins.'),
          ],
        ),
        'DOUBLE_ELIMINATION' => (
          description: 'Two losses to be eliminated. A losers bracket gives teams a second chance.',
          phases: [
            ('Winners Bracket', 'Teams with no losses compete for the top path.'),
            ('Losers Bracket', 'Teams with one loss get a second chance here.'),
            ('Grand Final', 'Winners bracket champion vs losers bracket champion.'),
            ('Champion', 'Grand final winner takes the title.'),
          ],
        ),
        _ => (
          description: 'Select a tournament format to see how it works.',
          phases: <(String, String)>[],
        ),
      };
}

// ── Structure diagrams ─────────────────────────────────────────────────────────

class _LeagueDiagram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final teams = ['T1', 'T2', 'T3', 'T4', 'TN'];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < teams.length; i++) ...[
              _DiagramBox(label: teams[i], accent: false, context: context),
              if (i < teams.length - 1)
                _DiagramArrow(context: context, bidirectional: true),
            ],
          ],
        ),
        const SizedBox(height: 12),
        _DiagramConnectorDown(context: context),
        const SizedBox(height: 4),
        _DiagramBox(label: 'Standings', accent: false, context: context, wide: true),
        const SizedBox(height: 4),
        _DiagramConnectorDown(context: context),
        const SizedBox(height: 4),
        _TrophyBox(context: context),
      ],
    );
  }
}

class _KnockoutDiagram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(children: [
              _DiagramBox(label: 'T1', accent: false, context: context),
              const SizedBox(height: 6),
              _DiagramBox(label: 'T2', accent: false, context: context),
            ]),
            _DiagramArrow(context: context),
            _DiagramBox(label: 'QF', accent: false, context: context),
            _DiagramArrow(context: context),
            _DiagramBox(label: 'SF', accent: false, context: context),
            _DiagramArrow(context: context),
            _DiagramBox(label: 'Final', accent: true, context: context),
            _DiagramArrow(context: context),
            _TrophyBox(context: context),
          ],
        ),
      ],
    );
  }
}

class _GroupKnockoutDiagram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(children: [
          _DiagramBox(label: 'Grp A', accent: false, context: context),
          const SizedBox(height: 6),
          _DiagramBox(label: 'Grp B', accent: false, context: context),
        ]),
        _DiagramArrow(context: context),
        Column(children: [
          _DiagramBox(label: 'QF', accent: false, context: context),
          const SizedBox(height: 6),
          _DiagramBox(label: 'SF', accent: false, context: context),
        ]),
        _DiagramArrow(context: context),
        _DiagramBox(label: 'Final', accent: true, context: context),
        _DiagramArrow(context: context),
        _TrophyBox(context: context),
      ],
    );
  }
}

class _SeriesDiagram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _DiagramBox(label: 'Team A', accent: false, context: context),
        const SizedBox(width: 8),
        Column(
          children: [
            Text('vs', style: TextStyle(color: context.fgSub, fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Row(children: [
              for (var i = 1; i <= 3; i++) ...[
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: i == 2 ? context.accentBg : context.panel,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('$i',
                        style: TextStyle(
                          color: i == 2 ? context.accent : context.fgSub,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                ),
                if (i < 3) const SizedBox(width: 4),
              ],
            ]),
          ],
        ),
        const SizedBox(width: 8),
        _DiagramBox(label: 'Team B', accent: false, context: context),
        _DiagramArrow(context: context),
        _TrophyBox(context: context),
      ],
    );
  }
}

class _SuperLeagueDiagram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(children: [
          _DiagramBox(label: 'Grp A', accent: false, context: context),
          const SizedBox(height: 6),
          _DiagramBox(label: 'Grp B', accent: false, context: context),
        ]),
        _DiagramArrow(context: context),
        _DiagramBox(label: 'Super\nLeague', accent: true, context: context),
        _DiagramArrow(context: context),
        _TrophyBox(context: context),
      ],
    );
  }
}

class _DoubleEliminationDiagram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(children: [
          _DiagramBox(label: 'Winners\nBracket', accent: false, context: context),
          const SizedBox(height: 6),
          _DiagramBox(label: 'Losers\nBracket', accent: false, context: context),
        ]),
        _DiagramArrow(context: context),
        _DiagramBox(label: 'Grand\nFinal', accent: true, context: context),
        _DiagramArrow(context: context),
        _TrophyBox(context: context),
      ],
    );
  }
}

// ── Diagram shared widgets ─────────────────────────────────────────────────────

class _DiagramBox extends StatelessWidget {
  const _DiagramBox({
    required this.label,
    required this.accent,
    required this.context,
    this.wide = false,
  });
  final String label;
  final bool accent;
  final BuildContext context;
  final bool wide;

  @override
  Widget build(BuildContext _) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: wide ? 20 : 10, vertical: 8),
      decoration: BoxDecoration(
        color: accent ? context.accentBg : context.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: accent
              ? context.accent.withValues(alpha: 0.5)
              : context.stroke,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: accent ? context.accent : context.fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
      ),
    );
  }
}

class _DiagramArrow extends StatelessWidget {
  const _DiagramArrow({required this.context, this.bidirectional = false});
  final BuildContext context;
  final bool bidirectional;

  @override
  Widget build(BuildContext _) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (bidirectional)
            Icon(Icons.arrow_back_ios_rounded, size: 10, color: context.fgSub),
          Container(width: 12, height: 1.5, color: context.stroke),
          Icon(Icons.arrow_forward_ios_rounded, size: 10, color: context.fgSub),
        ],
      ),
    );
  }
}

class _DiagramConnectorDown extends StatelessWidget {
  const _DiagramConnectorDown({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Container(width: 1.5, height: 14, color: context.stroke);
  }
}

class _TrophyBox extends StatelessWidget {
  const _TrophyBox({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: context.accentBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.accent.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Icon(Icons.emoji_events_rounded, color: context.accent, size: 20),
    );
  }
}

// ── Step 3: Schedule & Venue ───────────────────────────────────────────────────

class _Step2Schedule extends StatelessWidget {
  const _Step2Schedule({
    required this.startDate,
    required this.endDate,
    required this.selectedVenue,
    required this.onPickStartDate,
    required this.onPickEndDate,
    required this.onClearEndDate,
    required this.onPickVenue,
  });

  final DateTime startDate;
  final DateTime? endDate;
  final ArenaListing? selectedVenue;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;
  final VoidCallback onClearEndDate;
  final VoidCallback onPickVenue;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE, d MMM yyyy');
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _StepHeader(
          title: 'When and where?',
          subtitle: 'Set the dates and location for your tournament.',
        ),
        const SizedBox(height: 24),

        // Start date
        _FieldLabel(label: 'Start date'),
        const SizedBox(height: 8),
        _DateTile(
          value: fmt.format(startDate),
          icon: Icons.calendar_today_rounded,
          onTap: onPickStartDate,
        ),
        const SizedBox(height: 16),

        // End date
        _FieldLabel(label: 'End date  •  optional'),
        const SizedBox(height: 8),
        _DateTile(
          value: endDate != null ? fmt.format(endDate!) : 'Tap to set',
          icon: Icons.event_rounded,
          placeholder: endDate == null,
          onTap: onPickEndDate,
          trailing: endDate != null
              ? GestureDetector(
                  onTap: onClearEndDate,
                  child: Icon(Icons.close_rounded,
                      size: 16, color: context.fgSub),
                )
              : null,
        ),
        const SizedBox(height: 28),

        // Venue
        _FieldLabel(label: 'Venue'),
        const SizedBox(height: 8),
        _DateTile(
          value: selectedVenue != null
              ? selectedVenue!.name
              : 'Tap to choose a venue',
          icon: Icons.stadium_rounded,
          placeholder: selectedVenue == null,
          onTap: onPickVenue,
          trailing: selectedVenue != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedVenue!.city,
                      style: TextStyle(color: context.fgSub, fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                  ],
                )
              : null,
        ),
      ],
    );
  }
}

// ── Step 3: Teams & Rules ──────────────────────────────────────────────────────

class _Step3Teams extends StatelessWidget {
  const _Step3Teams({
    required this.formKey,
    required this.maxTeamsController,
    required this.ballType,
    required this.isPublic,
    required this.onBallTypeChanged,
    required this.onPublicChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController maxTeamsController;
  final String ballType;
  final bool isPublic;
  final ValueChanged<String> onBallTypeChanged;
  final ValueChanged<bool> onPublicChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _StepHeader(
            title: 'Teams & Rules',
            subtitle: 'How many teams, and what equipment will you use?',
          ),
          const SizedBox(height: 24),

          // Max teams
          _FieldLabel(label: 'Max teams'),
          const SizedBox(height: 8),
          _MaxTeamsStepper(controller: maxTeamsController),
          const SizedBox(height: 24),

          // Ball type
          _FieldLabel(label: 'Ball type'),
          const SizedBox(height: 10),
          _ChipGrid(
            options: const [
              ('LEATHER', '🔴  Leather'),
              ('TENNIS', '🟡  Tennis'),
              ('SEASON', '🟠  Season'),
              ('OTHER', '⚪  Other'),
            ],
            selected: ballType,
            onSelected: onBallTypeChanged,
          ),
          const SizedBox(height: 24),

          // Visibility
          _FieldLabel(label: 'Visibility'),
          const SizedBox(height: 10),
          _VisibilityToggle(
            isPublic: isPublic,
            onChanged: onPublicChanged,
          ),
        ],
      ),
    );
  }
}

// ── Step 4: Fees & Prize ───────────────────────────────────────────────────────

class _Step4Fees extends StatelessWidget {
  const _Step4Fees({
    required this.entryFeeController,
    required this.earlyBirdFeeController,
    required this.prizePoolController,
    required this.earlyBirdDeadline,
    required this.onPickEarlyBirdDeadline,
    required this.onClearEarlyBirdDeadline,
  });

  final TextEditingController entryFeeController;
  final TextEditingController earlyBirdFeeController;
  final TextEditingController prizePoolController;
  final DateTime? earlyBirdDeadline;
  final VoidCallback onPickEarlyBirdDeadline;
  final VoidCallback onClearEarlyBirdDeadline;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE, d MMM yyyy');
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _StepHeader(
          title: 'Fees & Prize',
          subtitle: 'Optional — you can set or update these anytime.',
        ),
        const SizedBox(height: 24),

        // Entry fee
        _FieldLabel(label: 'Entry fee  •  ₹'),
        const SizedBox(height: 8),
        TextField(
          controller: entryFeeController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
              color: context.fg, fontSize: 15, fontWeight: FontWeight.w600),
          decoration:
              _inputDecoration(context, hint: '0 for free entry'),
        ),
        const SizedBox(height: 20),

        // Early bird
        _FieldLabel(label: 'Early bird deadline  •  optional'),
        const SizedBox(height: 8),
        _DateTile(
          value: earlyBirdDeadline != null
              ? fmt.format(earlyBirdDeadline!)
              : 'Tap to set',
          icon: Icons.timer_outlined,
          placeholder: earlyBirdDeadline == null,
          onTap: onPickEarlyBirdDeadline,
          trailing: earlyBirdDeadline != null
              ? GestureDetector(
                  onTap: onClearEarlyBirdDeadline,
                  child: Icon(Icons.close_rounded,
                      size: 16, color: context.fgSub),
                )
              : null,
        ),
        const SizedBox(height: 16),
        _FieldLabel(label: 'Early bird fee  •  ₹'),
        const SizedBox(height: 8),
        TextField(
          controller: earlyBirdFeeController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
              color: context.fg, fontSize: 15, fontWeight: FontWeight.w600),
          decoration: _inputDecoration(context, hint: 'Lower than entry fee'),
        ),
        const SizedBox(height: 20),

        // Prize pool
        _FieldLabel(label: 'Prize pool  •  optional'),
        const SizedBox(height: 8),
        TextField(
          controller: prizePoolController,
          style: TextStyle(
              color: context.fg, fontSize: 15, fontWeight: FontWeight.w600),
          decoration: _inputDecoration(
              context, hint: 'e.g. {"winner": 5000, "runnerUp": 2000}'),
        ),
      ],
    );
  }
}

// ── Step 5: Organiser ──────────────────────────────────────────────────────────

class _Step5Organiser extends StatelessWidget {
  const _Step5Organiser({
    required this.organiserNameController,
    required this.organiserPhoneController,
    required this.descriptionController,
    this.error,
  });

  final TextEditingController organiserNameController;
  final TextEditingController organiserPhoneController;
  final TextEditingController descriptionController;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _StepHeader(
          title: 'About the organiser',
          subtitle: 'So players know who to contact.',
        ),
        const SizedBox(height: 24),

        _FieldLabel(label: 'Organiser name'),
        const SizedBox(height: 8),
        TextField(
          controller: organiserNameController,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(
              color: context.fg, fontSize: 15, fontWeight: FontWeight.w600),
          decoration: _inputDecoration(context, hint: 'Your name or club name'),
        ),
        const SizedBox(height: 16),

        _FieldLabel(label: 'Phone number  •  optional'),
        const SizedBox(height: 8),
        TextField(
          controller: organiserPhoneController,
          keyboardType: TextInputType.phone,
          style: TextStyle(
              color: context.fg, fontSize: 15, fontWeight: FontWeight.w600),
          decoration: _inputDecoration(context, hint: '+91 98765 43210'),
        ),
        const SizedBox(height: 20),

        _FieldLabel(label: 'Description  •  optional'),
        const SizedBox(height: 8),
        TextField(
          controller: descriptionController,
          minLines: 4,
          maxLines: 8,
          style: TextStyle(
              color: context.fg, fontSize: 14, height: 1.5),
          decoration: _inputDecoration(
            context,
            hint: 'Rules, eligibility, special conditions…',
          ),
        ),

        if ((error ?? '').isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.danger.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded,
                    color: context.danger, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error!,
                    style:
                        TextStyle(color: context.danger, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Venue picker sheet ─────────────────────────────────────────────────────────

class _VenuePickerSheet extends ConsumerStatefulWidget {
  const _VenuePickerSheet({required this.ref});

  // We accept the outer WidgetRef so we can read providers without needing
  // an extra Consumer wrapper. The inner ref from ConsumerState is used below.
  // ignore: unused_field
  final WidgetRef ref;

  @override
  ConsumerState<_VenuePickerSheet> createState() => _VenuePickerSheetState();
}

class _VenuePickerSheetState extends ConsumerState<_VenuePickerSheet> {
  List<ArenaListing> _arenas = [];
  bool _loading = true;
  String? _fetchError;

  @override
  void initState() {
    super.initState();
    _loadArenas();
  }

  Future<void> _loadArenas() async {
    try {
      final arenas =
          await ref.read(hostArenaBookingRepositoryProvider).fetchOwnedArenas();
      if (!mounted) return;
      setState(() {
        _arenas = arenas;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _fetchError = e.toString();
        _loading = false;
      });
    }
  }

  void _onCreateNew() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Go to Arenas to add a new one')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.stroke,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Choose Venue',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Content
          if (_loading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.accent,
                  ),
                ),
              ),
            )
          else if (_fetchError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Text(
                'Failed to load venues: $_fetchError',
                style: TextStyle(color: context.danger, fontSize: 13),
              ),
            )
          else if (_arenas.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No venues found. Create one in the Arenas section.',
                    style: TextStyle(color: context.fgSub, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _onCreateNew,
                    child: Text(
                      'Go to Arenas',
                      style: TextStyle(
                        color: context.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _arenas.length,
                itemBuilder: (context, index) {
                  final arena = _arenas[index];
                  return InkWell(
                    onTap: () => Navigator.pop(context, arena),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  arena.name,
                                  style: TextStyle(
                                    color: context.fg,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (arena.address.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    arena.address,
                                    style: TextStyle(
                                      color: context.fgSub,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              size: 18, color: context.fgSub),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Divider
          Divider(height: 1, color: context.stroke),

          // Create new venue row
          InkWell(
            onTap: _onCreateNew,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline_rounded,
                      size: 18, color: context.accent),
                  const SizedBox(width: 10),
                  Text(
                    'Create new venue',
                    style: TextStyle(
                      color: context.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared components ─────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.fg,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: context.fgSub, fontSize: 13, height: 1.4),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: context.fgSub,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _ChipGrid extends StatelessWidget {
  const _ChipGrid({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<(String value, String label)> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = opt.$1 == selected;
        return GestureDetector(
          onTap: () => onSelected(opt.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.accent.withValues(alpha: 0.12)
                  : context.panel,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? context.accent.withValues(alpha: 0.6)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              opt.$2,
              style: TextStyle(
                color: isSelected ? context.accent : context.fgSub,
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.value,
    required this.icon,
    required this.onTap,
    this.placeholder = false,
    this.trailing,
  });

  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final bool placeholder;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: context.panel,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: context.fgSub),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: placeholder ? context.fgSub : context.fg,
                  fontSize: 14,
                  fontWeight:
                      placeholder ? FontWeight.w400 : FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _MaxTeamsStepper extends StatelessWidget {
  const _MaxTeamsStepper({required this.controller});
  final TextEditingController controller;

  int get _value => int.tryParse(controller.text) ?? 8;

  void _adjust(int delta) {
    final next = (_value + delta).clamp(2, 64);
    controller.text = '$next';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepperBtn(
          icon: Icons.remove_rounded,
          onTap: () => _adjust(-1),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              color: context.fg,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            decoration: _inputDecoration(context, hint: '8'),
            validator: (v) {
              final n = int.tryParse((v ?? '').trim());
              if (n == null || n < 2) return 'Minimum 2 teams';
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        _StepperBtn(
          icon: Icons.add_rounded,
          onTap: () => _adjust(1),
        ),
      ],
    );
  }
}

class _StepperBtn extends StatelessWidget {
  const _StepperBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: context.panel,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: context.fg, size: 20),
      ),
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle(
      {required this.isPublic, required this.onChanged});
  final bool isPublic;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _VisibilityOption(
          label: 'Public',
          sublabel: 'Anyone can find & join',
          icon: Icons.public_rounded,
          selected: isPublic,
          onTap: () => onChanged(true),
        ),
        const SizedBox(width: 10),
        _VisibilityOption(
          label: 'Private',
          sublabel: 'Invite-only',
          icon: Icons.lock_outline_rounded,
          selected: !isPublic,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}

class _VisibilityOption extends StatelessWidget {
  const _VisibilityOption({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? context.accent.withValues(alpha: 0.1)
                : context.panel,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? context.accent.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 18,
                  color: selected ? context.accent : context.fgSub),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: selected ? context.accent : context.fg,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      sublabel,
                      style: TextStyle(
                          color: context.fgSub, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Input decoration helper ────────────────────────────────────────────────────

InputDecoration _inputDecoration(BuildContext context,
    {required String hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: context.fgSub, fontSize: 14),
    filled: true,
    fillColor: context.panel,
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.accent, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.danger, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.danger, width: 1.5),
    ),
  );
}
