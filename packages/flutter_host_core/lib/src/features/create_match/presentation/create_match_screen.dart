import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../repositories/host_arena_repository.dart';
import '../../../repositories/host_team_repository.dart';
import '../../../theme/host_colors.dart';
import '../../arena_booking/domain/arena_booking_models.dart';
import '../../my_teams/controller/my_teams_controller.dart';
import '../../my_teams/domain/my_teams_models.dart';
import '../../playing_eleven/presentation/playing_eleven_screen.dart';
import '../controller/create_match_controller.dart';

// ══════════════════════════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════════════════════════

/// Premium dark-themed create-match wizard with progressive section reveal,
/// team hero, settings-row pickers, venue search + temporary venue, schedule
/// and impact toggle. Host-agnostic: each app supplies the current user's id
/// (so "my squads" can be split from "playing for") and a callback that fires
/// after a successful toss to navigate into the host's scoring screen.
class CreateMatchScreen extends ConsumerStatefulWidget {
  const CreateMatchScreen({
    super.key,
    this.currentUserId,
    this.onTossCompleted,
    this.onBack,
  });

  /// User id whose owned teams should appear under "Your squads". Pass `null`
  /// to skip ownership detection (e.g. admin tooling); everything will fall
  /// under "playing for" then.
  final String? currentUserId;

  /// Forwarded all the way through Playing 11 → Toss → here. Hosts use it to
  /// route into their scoring screen on toss completion.
  final void Function(BuildContext context, String matchId)? onTossCompleted;

  /// AppBar back action. Defaults to `Navigator.maybePop`.
  final VoidCallback? onBack;

  @override
  ConsumerState<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends ConsumerState<CreateMatchScreen> {
  HostMyTeam? _teamA;
  _OpponentTeam? _teamB;
  _MatchType _matchType = _MatchType.friendly;
  _MatchFormat _format = _MatchFormat.t20;
  _BallKind _ball = _BallKind.leather;
  _VenueChoice? _venue;
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 2));
  bool _scheduleForLater = false;
  bool _hasImpactPlayer = false;
  final _customOversCtrl = TextEditingController(text: '20');

  // Progressive reveal — the page is a single scrollable canvas where each
  // section unlocks once the previous one is satisfied.
  static const int _stepTeams = 0;
  static const int _stepMatch = 1;
  static const int _stepWhere = 2;
  static const int _stepWhen = 3;
  static const int _stepOptions = 4;
  static const int _kStepCount = 5;

  int _step = _stepTeams;
  final ScrollController _scrollCtrl = ScrollController();
  final List<GlobalKey> _stepKeys =
      List.generate(_kStepCount, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    // Kick off the my-teams load right away so the picker has data ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(hostMyTeamsControllerProvider.notifier)
          .load(currentUserId: widget.currentUserId);
    });
  }

  @override
  void dispose() {
    _customOversCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _advance(int next) {
    if (next <= _step) return;
    setState(() => _step = next);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = _stepKeys[next].currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    });
  }

  void _maybeAdvanceFromTeams() {
    if (_step >= _stepMatch) return;
    if (_teamA == null || _teamB == null) return;
    if (_teamA!.id == _teamB!.id) return;
    _advance(_stepMatch);
  }

  @override
  Widget build(BuildContext context) {
    // Watch the my-teams notifier so the picker sheet (a separate route)
    // doesn't see a disposed state when it opens.
    ref.watch(hostMyTeamsControllerProvider);
    final state = ref.watch(hostCreateMatchControllerProvider);

    final teamsConflict =
        _teamA != null && _teamB != null && _teamA!.id == _teamB!.id;
    final dateLabel = _scheduledAt;
    final dateRelative = _relativeDay(dateLabel);
    final timeLabel = DateFormat('h:mm a').format(dateLabel);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            final onBack = widget.onBack;
            if (onBack != null) {
              onBack();
            } else {
              Navigator.of(context).maybePop();
            }
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.fg, size: 18),
        ),
        title: Text(
          'New match',
          style: TextStyle(
            color: context.fg,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
        children: [
          // ── Step 0: Teams ────────────────────────────────────────────────
          KeyedSubtree(
            key: _stepKeys[_stepTeams],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _StepHint(
                  title: 'Pick your squads',
                  subtitle: 'Choose your team and the opponent.',
                ),
                const SizedBox(height: 12),
                _TeamHero(
                  teamA: _teamA,
                  teamB: _teamB,
                  onPickA: _pickTeamA,
                  onPickB: _pickOpponent,
                ),
                if (teamsConflict)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: 4),
                    child: Text(
                      'Opponent must be a different squad.',
                      style: TextStyle(color: context.danger, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          // ── Step 1: Match ─────────────────────────────────────────────────
          _Reveal(
            show: _step >= _stepMatch,
            child: KeyedSubtree(
              key: _stepKeys[_stepMatch],
              child: Padding(
                padding: const EdgeInsets.only(top: 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _StepHint(
                      title: 'Pick the format',
                      subtitle: 'Type, length and ball.',
                    ),
                    const SizedBox(height: 12),
                    _SettingsCard(
                      children: [
                        _SettingsRow(
                          label: 'Type',
                          value: _matchType.label,
                          onTap: () async {
                            final picked = await _showOptionPicker<_MatchType>(
                              title: 'Match type',
                              options: _MatchType.values,
                              selected: _matchType,
                              labelOf: (e) => e.label,
                            );
                            if (picked != null) {
                              setState(() => _matchType = picked);
                            }
                          },
                        ),
                        _SettingsRow(
                          label: 'Format',
                          value: _format.label,
                          onTap: () async {
                            final picked =
                                await _showOptionPicker<_MatchFormat>(
                              title: 'Match format',
                              options: _MatchFormat.values,
                              selected: _format,
                              labelOf: (e) => e.label,
                            );
                            if (picked != null) {
                              setState(() => _format = picked);
                            }
                          },
                        ),
                        _SettingsRow(
                          label: 'Ball',
                          value: _ball.label,
                          onTap: () async {
                            final picked = await _showOptionPicker<_BallKind>(
                              title: 'Ball type',
                              options: _BallKind.values,
                              selected: _ball,
                              labelOf: (e) => e.label,
                            );
                            if (picked != null) setState(() => _ball = picked);
                          },
                          isLast: true,
                        ),
                      ],
                    ),
                    if (_format == _MatchFormat.custom) ...[
                      const SizedBox(height: 16),
                      _CenteredOversInput(
                        controller: _customOversCtrl,
                        onChanged: () => setState(() {}),
                      ),
                    ],
                    const SizedBox(height: 14),
                    _ContinueButton(
                      label: 'Next: pick venue',
                      onTap: _pickVenue,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Step 2: Where ────────────────────────────────────────────────
          _Reveal(
            show: _step >= _stepWhere,
            child: KeyedSubtree(
              key: _stepKeys[_stepWhere],
              child: Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _StepHint(
                      title: 'Pick a venue',
                      subtitle: 'City auto-fills from the venue.',
                    ),
                    const SizedBox(height: 12),
                    _SettingsCard(
                      children: [
                        _SettingsRow(
                          label: 'Venue',
                          value: _venue?.name ?? 'Pick a venue',
                          valueIsPlaceholder: _venue == null,
                          onTap: _pickVenue,
                          isLast: _venue == null,
                        ),
                        if (_venue?.city != null && _venue!.city.isNotEmpty)
                          _SettingsRow(
                            label: 'City',
                            value: _venue!.city,
                            isReadOnly: true,
                            isLast: true,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Step 3: When ─────────────────────────────────────────────────
          _Reveal(
            show: _step >= _stepWhen,
            child: KeyedSubtree(
              key: _stepKeys[_stepWhen],
              child: Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _StepHint(
                      title: 'Schedule the match',
                      subtitle: 'Defaults to two hours from now.',
                    ),
                    const SizedBox(height: 12),
                    _SettingsCard(
                      children: [
                        _SettingsRow(
                          label: 'Date',
                          value: dateRelative,
                          onTap: _pickDate,
                        ),
                        _SettingsRow(
                          label: 'Time',
                          value: timeLabel,
                          onTap: _pickTime,
                        ),
                        _SwitchRow(
                          label: 'Schedule for later',
                          hint: _scheduleForLater
                              ? 'Saved as upcoming until you start'
                              : 'Start scoring right after toss',
                          value: _scheduleForLater,
                          onChanged: (v) => setState(() {
                            _scheduleForLater = v;
                            if (!v) {
                              _scheduledAt =
                                  DateTime.now().add(const Duration(hours: 2));
                            }
                          }),
                          isLast: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Step 4: Options + Submit ─────────────────────────────────────
          _Reveal(
            show: _step >= _stepOptions,
            child: KeyedSubtree(
              key: _stepKeys[_stepOptions],
              child: Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _StepHint(
                      title: 'Final touches',
                      subtitle: 'Tweak optional settings, then create.',
                    ),
                    const SizedBox(height: 12),
                    _SettingsCard(
                      children: [
                        _SwitchRow(
                          label: 'Impact player',
                          hint: 'Allow one tactical swap per innings',
                          value: _hasImpactPlayer,
                          onChanged: (v) =>
                              setState(() => _hasImpactPlayer = v),
                          isLast: true,
                        ),
                      ],
                    ),
                    if ((state.error ?? '').isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: context.danger.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          state.error!,
                          style:
                              TextStyle(color: context.danger, fontSize: 13),
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    _PrimaryCta(
                      label: _scheduleForLater
                          ? 'Schedule match'
                          : 'Create match',
                      isLoading: state.isSubmitting,
                      enabled: _canSubmit,
                      onTap: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<T?> _showOptionPicker<T>({
    required String title,
    required List<T> options,
    required T selected,
    required String Function(T) labelOf,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _OptionPickerSheet<T>(
        title: title,
        options: options,
        selected: selected,
        labelOf: labelOf,
      ),
    );
  }

  String _relativeDay(DateTime when) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(when.year, when.month, when.day);
    final delta = target.difference(today).inDays;
    if (delta == 0) return 'Today';
    if (delta == 1) return 'Tomorrow';
    if (delta == -1) return 'Yesterday';
    if (delta > 1 && delta < 7) return DateFormat('EEEE').format(when);
    return DateFormat('EEE, d MMM').format(when);
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  bool get _canSubmit {
    if (_teamA == null || _teamB == null) return false;
    if (_teamA!.id == _teamB!.id) return false;
    if (_format == _MatchFormat.custom) {
      final overs = int.tryParse(_customOversCtrl.text.trim());
      if (overs == null || overs < 1 || overs > 100) return false;
    }
    return true;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _pickTeamA() async {
    // The sheet watches hostMyTeamsControllerProvider directly, so it shows
    // its own loading / error / empty state. No need to call refresh() here.
    final picked = await showModalBottomSheet<HostMyTeam>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MyTeamsSheet(),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _teamA = picked;
      if (_teamB?.id == picked.id) _teamB = null;
    });
    _maybeAdvanceFromTeams();
  }

  Future<void> _pickOpponent() async {
    final picked = await showModalBottomSheet<_OpponentTeam>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          _OpponentSearchSheet(forbiddenTeamId: _teamA?.id ?? ''),
    );
    if (!mounted || picked == null) return;
    setState(() => _teamB = picked);
    _maybeAdvanceFromTeams();
  }

  Future<void> _pickVenue() async {
    final picked = await showModalBottomSheet<_VenueChoice>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _VenuePickerSheet(),
    );
    if (!mounted || picked == null) return;
    setState(() => _venue = picked);
    // Reveal Schedule + Options together, then land the user in Schedule.
    if (_step < _stepOptions) {
      setState(() => _step = _stepOptions);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = _stepKeys[_stepWhen].currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _scheduledAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _scheduledAt.hour,
        _scheduledAt.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _scheduledAt = DateTime(
        _scheduledAt.year,
        _scheduledAt.month,
        _scheduledAt.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _submit() async {
    final teamA = _teamA!;
    final teamB = _teamB!;
    final overs = _format == _MatchFormat.custom
        ? int.tryParse(_customOversCtrl.text.trim())
        : null;

    final matchId = await ref
        .read(hostCreateMatchControllerProvider.notifier)
        .createMatch(
          teamAName: teamA.name,
          teamBName: teamB.name,
          teamAId: teamA.id,
          teamBId: teamB.id,
          venueName: _venue?.name ?? '',
          venueCity: _venue?.city ?? '',
          scheduledAt: _scheduledAt,
          format: _format.apiValue,
          matchType: _matchType.apiValue,
          customOvers: overs,
          hasImpactPlayer: _hasImpactPlayer,
          ballType: _ball.apiValue,
          facilityId: _venue?.id,
        );

    if (!mounted || matchId == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayingElevenScreen(
          matchId: matchId,
          teamAId: teamA.id,
          teamAName: teamA.name,
          teamBId: teamB.id,
          teamBName: teamB.name,
          hasImpactPlayer: _hasImpactPlayer,
          onTossCompleted: widget.onTossCompleted,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ENUMS
// ══════════════════════════════════════════════════════════════════════════════

enum _MatchType {
  friendly('Friendly', 'FRIENDLY'),
  club('Club', 'RANKED'),
  tournament('Tournament', 'TOURNAMENT'),
  corporate('Corporate', 'CORPORATE'),
  academy('Academy', 'ACADEMY');

  const _MatchType(this.label, this.apiValue);
  final String label;
  final String apiValue;
}

enum _MatchFormat {
  t10('T10', 'T10'),
  t20('T20', 'T20'),
  odi('ODI', 'ONE_DAY'),
  test('Test', 'TEST'),
  box('Box', 'BOX_CRICKET'),
  custom('Custom', 'CUSTOM');

  const _MatchFormat(this.label, this.apiValue);
  final String label;
  final String apiValue;
}

enum _BallKind {
  leather('Leather', 'LEATHER'),
  tennis('Tennis', 'TENNIS'),
  tape('Tape', 'TAPE'),
  rubber('Rubber', 'RUBBER'),
  cork('Cork', 'CORK'),
  other('Other', 'OTHER');

  const _BallKind(this.label, this.apiValue);
  final String label;
  final String apiValue;
}

// ══════════════════════════════════════════════════════════════════════════════
// SMALL MODELS
// ══════════════════════════════════════════════════════════════════════════════

class _OpponentTeam {
  const _OpponentTeam({
    required this.id,
    required this.name,
    this.shortName,
    this.city,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String? shortName;
  final String? city;
  final String? logoUrl;
}

class _VenueChoice {
  const _VenueChoice({
    required this.id,
    required this.name,
    required this.city,
    this.address,
  });

  final String id;
  final String name;
  final String city;
  final String? address;
}

// ══════════════════════════════════════════════════════════════════════════════
// TEAM PICKERS
// ══════════════════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════════════════
// PREMIUM-MINIMAL UI WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

/// Reveals its child with a coordinated size + fade + slide. The first time
/// `show` flips to true the animation runs; subsequent rebuilds are no-ops.
class _Reveal extends StatefulWidget {
  const _Reveal({required this.show, required this.child});

  final bool show;
  final Widget child;

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _curved;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      value: widget.show ? 1 : 0,
    );
    _curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(_curved);
  }

  @override
  void didUpdateWidget(covariant _Reveal old) {
    super.didUpdateWidget(old);
    if (widget.show && !old.show) _ctrl.forward();
    if (!widget.show && old.show) _ctrl.reverse();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _curved,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: _curved,
        child: SlideTransition(
          position: _slide,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Centered hero input shown when the user picks the CUSTOM format. The
/// number takes the focal point of the section instead of being squeezed
/// into a settings-row corner.
class _CenteredOversInput extends StatelessWidget {
  const _CenteredOversInput({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            'OVERS PER INNINGS',
            style: TextStyle(
              color: context.fgSub.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          IntrinsicWidth(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 96),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 3,
                textAlign: TextAlign.center,
                cursorColor: context.accent,
                style: TextStyle(
                  color: context.fg,
                  fontSize: 44,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                ),
                decoration: const InputDecoration(
                  isCollapsed: true,
                  counterText: '',
                  hintText: '20',
                  border: InputBorder.none,
                ),
                onChanged: (_) => onChanged(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 2,
            width: 56,
            decoration: BoxDecoration(
              color: context.accent.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Tap to edit · 1–100 overs',
            style: TextStyle(
              color: context.fgSub.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepHint extends StatelessWidget {
  const _StepHint({required this.title, required this.subtitle});

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
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: context.fgSub.withValues(alpha: 0.75),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Material(
        color: context.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: context.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded,
                    color: context.accent, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamHero extends StatelessWidget {
  const _TeamHero({
    required this.teamA,
    required this.teamB,
    required this.onPickA,
    required this.onPickB,
  });

  final HostMyTeam? teamA;
  final _OpponentTeam? teamB;
  final VoidCallback onPickA;
  final VoidCallback onPickB;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _TeamPlate(
              kicker: 'YOUR SQUAD',
              accent: context.accent,
              name: teamA?.name,
              subtitle: teamA == null
                  ? 'Tap to choose'
                  : [teamA!.shortName, teamA!.city]
                      .whereType<String>()
                      .where((value) => value.isNotEmpty)
                      .join(' · '),
              logoUrl: teamA?.logoUrl,
              onTap: onPickA,
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 28),
            child: Text(
              'vs',
              style: TextStyle(
                color: context.fgSub.withValues(alpha: 0.5),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TeamPlate(
              kicker: 'OPPONENT',
              accent: context.gold,
              name: teamB?.name,
              subtitle: teamB == null
                  ? 'Search to add'
                  : [teamB!.shortName, teamB!.city]
                      .whereType<String>()
                      .where((value) => value.isNotEmpty)
                      .join(' · '),
              logoUrl: teamB?.logoUrl,
              onTap: onPickB,
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamPlate extends StatelessWidget {
  const _TeamPlate({
    required this.kicker,
    required this.accent,
    required this.name,
    required this.subtitle,
    required this.logoUrl,
    required this.onTap,
    this.alignEnd = false,
  });

  final String kicker;
  final Color accent;
  final String? name;
  final String subtitle;
  final String? logoUrl;
  final VoidCallback onTap;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final filled = name != null && name!.isNotEmpty;
    final align =
        alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = alignEnd ? TextAlign.end : TextAlign.start;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: align,
          children: [
            _TeamCrest(
              name: name,
              logoUrl: logoUrl,
              accent: accent,
              filled: filled,
            ),
            const SizedBox(height: 14),
            Text(
              kicker,
              textAlign: textAlign,
              style: TextStyle(
                color: filled
                    ? accent
                    : context.fgSub.withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              filled ? name! : 'Pick',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: textAlign,
              style: TextStyle(
                color: filled
                    ? context.fg
                    : context.fg.withValues(alpha: 0.55),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: textAlign,
              style: TextStyle(
                color: context.fgSub.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamCrest extends StatelessWidget {
  const _TeamCrest({
    required this.name,
    required this.logoUrl,
    required this.accent,
    required this.filled,
  });

  final String? name;
  final String? logoUrl;
  final Color accent;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    if (!filled) {
      return DottedCircle(
        size: 72,
        color: context.fgSub.withValues(alpha: 0.35),
        child: Icon(Icons.add_rounded,
            color: context.fgSub.withValues(alpha: 0.7), size: 26),
      );
    }
    final initial =
        (name == null || name!.trim().isEmpty) ? '?' : name!.trim()[0].toUpperCase();
    return Container(
      width: 72,
      height: 72,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.22),
            accent.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: logoUrl != null && logoUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: logoUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _initials(context, initial),
              placeholder: (_, __) => _initials(context, initial),
            )
          : _initials(context, initial),
    );
  }

  Widget _initials(BuildContext context, String initial) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: accent,
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class DottedCircle extends StatelessWidget {
  const DottedCircle({
    super.key,
    required this.size,
    required this.color,
    required this.child,
  });

  final double size;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedCirclePainter(color: color),
      child: SizedBox(width: size, height: size, child: Center(child: child)),
    );
  }
}

class _DottedCirclePainter extends CustomPainter {
  _DottedCirclePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    const dashCount = 28;
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    const dashAngle = (2 * 3.1415926535) / 28;
    for (var i = 0; i < dashCount; i++) {
      final start = i * dashAngle;
      final end = start + dashAngle * 0.55;
      final path = Path()
        ..addArc(
          Rect.fromCircle(center: center, radius: radius - 1),
          start,
          end - start,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DottedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
    this.valueIsPlaceholder = false,
    this.isReadOnly = false,
    this.isLast = false,
  });

  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool valueIsPlaceholder;
  final bool isReadOnly;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: context.fg,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null)
            trailing!
          else if (value != null) ...[
            Flexible(
              child: Text(
                value!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: valueIsPlaceholder
                      ? context.fgSub.withValues(alpha: 0.6)
                      : context.fg.withValues(alpha: 0.78),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (!isReadOnly) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded,
                  color: context.fgSub.withValues(alpha: 0.6), size: 20),
            ],
          ],
        ],
      ),
    );

    final divider = isLast
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Container(
              height: 0.6,
              color: context.stroke,
            ),
          );

    final tappable = onTap == null || isReadOnly
        ? row
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: row,
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [tappable, divider],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    this.isLast = false,
  });

  final String label;
  final String? hint;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hint != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    hint!,
                    style: TextStyle(
                      color: context.fgSub.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: context.accent,
          ),
        ],
      ),
    );

    final divider = isLast
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Container(
              height: 0.6,
              color: context.stroke,
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [body, divider],
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({
    required this.label,
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final bool isLoading;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final ctaBg = context.ctaBg;
    final ctaFg = context.ctaFg;
    final disabled = !enabled || isLoading;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: disabled ? ctaBg.withValues(alpha: 0.55) : ctaBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: ctaBg.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: disabled ? null : onTap,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: ctaFg,
                      ),
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        color: disabled
                            ? ctaFg.withValues(alpha: 0.6)
                            : ctaFg,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionPickerSheet<T> extends StatelessWidget {
  const _OptionPickerSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.labelOf,
  });

  final String title;
  final List<T> options;
  final T selected;
  final String Function(T) labelOf;

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: title,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
        shrinkWrap: true,
        itemCount: options.length,
        separatorBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Container(
            height: 0.6,
            color: context.stroke,
          ),
        ),
        itemBuilder: (_, i) {
          final option = options[i];
          final isSelected = option == selected;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(option),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        labelOf(option),
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_rounded,
                          color: context.accent, size: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TeamBadge extends StatelessWidget {
  const _TeamBadge({
    required this.name,
    required this.logoUrl,
    required this.fallback,
    this.size = 44,
  });

  final String name;
  final String? logoUrl;
  final Color fallback;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: fallback.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: fallback.withValues(alpha: 0.35)),
      ),
      child: logoUrl != null && logoUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: logoUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _initials(context, initial),
              placeholder: (_, __) => _initials(context, initial),
            )
          : _initials(context, initial),
    );
  }

  Widget _initials(BuildContext context, String initial) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: fallback,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MY TEAMS SHEET
// ══════════════════════════════════════════════════════════════════════════════

class _MyTeamsSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hostMyTeamsControllerProvider);
    final teams = <HostMyTeam>[
      ...?state.data?.mySquads,
      ...?state.data?.playingFor,
    ];

    return _SheetFrame(
      title: 'Pick Your Squad',
      subtitle: 'Only squads you own or play for appear here.',
      child: () {
        if (state.isLoading && teams.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.error != null && teams.isEmpty) {
          return _SheetMessage(
            message: state.error!,
            isError: true,
          );
        }
        if (teams.isEmpty) {
          return const _SheetMessage(
            message:
                'You haven\'t joined any squad yet. Create one from the Teams tab first.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          shrinkWrap: true,
          itemCount: teams.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final t = teams[i];
            final isOwner = t.isOwner;
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(t),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.stroke),
                ),
                child: Row(
                  children: [
                    _TeamBadge(
                      name: t.name,
                      logoUrl: t.logoUrl,
                      fallback: context.accent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  t.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: context.fg,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (isOwner) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        context.gold.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'OWNER',
                                    style: TextStyle(
                                      color: context.gold,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [
                              t.shortName,
                              t.city,
                              '${t.playerCount} players',
                            ]
                                .whereType<String>()
                                .where((value) => value.isNotEmpty)
                                .join(' · '),
                            style: TextStyle(
                                color: context.fgSub, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: context.fgSub, size: 20),
                  ],
                ),
              ),
            );
          },
        );
      }(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// OPPONENT SEARCH SHEET
// ══════════════════════════════════════════════════════════════════════════════

class _OpponentSearchSheet extends ConsumerStatefulWidget {
  const _OpponentSearchSheet({required this.forbiddenTeamId});
  final String forbiddenTeamId;

  @override
  ConsumerState<_OpponentSearchSheet> createState() =>
      _OpponentSearchSheetState();
}

class _OpponentSearchSheetState extends ConsumerState<_OpponentSearchSheet> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _results = const [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () => _run(value));
  }

  Future<void> _run(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _results = const [];
        _loading = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows =
          await ref.read(hostTeamRepositoryProvider).searchTeams(trimmed);
      if (!mounted) return;
      setState(() {
        _results = rows
            .where((row) => '${row['id'] ?? ''}' != widget.forbiddenTeamId)
            .toList();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'Find Opponent',
      subtitle: 'Search any squad on Swing.',
      header: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: context.panel.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: context.fgSub, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  onChanged: _onChanged,
                  cursorColor: context.accent,
                  style: TextStyle(
                      color: context.fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Search by team or city…',
                    hintStyle:
                        TextStyle(color: context.fgSub, fontSize: 14),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
              if (_loading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: context.accent),
                ),
            ],
          ),
        ),
      ),
      child: () {
        if (_error != null) {
          return _SheetMessage(message: _error!, isError: true);
        }
        if (_ctrl.text.trim().isEmpty) {
          return const _SheetMessage(
            message: 'Start typing to find opposition squads.',
          );
        }
        if (!_loading && _results.isEmpty) {
          return _SheetMessage(message: 'No teams matched "${_ctrl.text}".');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          shrinkWrap: true,
          itemCount: _results.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final raw = _results[i];
            final name =
                '${raw['name'] ?? raw['teamName'] ?? 'Unnamed team'}';
            final shortName = '${raw['shortName'] ?? ''}'.trim();
            final city = '${raw['city'] ?? ''}'.trim();
            final logo = '${raw['logoUrl'] ?? ''}'.trim();
            final id = '${raw['id'] ?? raw['teamId'] ?? ''}'.trim();
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pop(_OpponentTeam(
                  id: id,
                  name: name,
                  shortName: shortName.isEmpty ? null : shortName,
                  city: city.isEmpty ? null : city,
                  logoUrl: logo.isEmpty ? null : logo,
                ));
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.stroke),
                ),
                child: Row(
                  children: [
                    _TeamBadge(
                      name: name,
                      logoUrl: logo.isEmpty ? null : logo,
                      fallback: context.gold,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.fg,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (shortName.isNotEmpty || city.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              [shortName, city]
                                  .where((e) => e.isNotEmpty)
                                  .join(' · '),
                              style: TextStyle(
                                  color: context.fgSub, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: context.fgSub, size: 20),
                  ],
                ),
              ),
            );
          },
        );
      }(),
    );
  }
}

class _VenuePickerSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_VenuePickerSheet> createState() => _VenuePickerSheetState();
}

class _VenuePickerSheetState extends ConsumerState<_VenuePickerSheet> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  List<ArenaListing> _arenas = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () => _load(value));
  }

  Future<void> _load(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final trimmed = query.trim();
      final results = await ref
          .read(hostArenaBookingRepositoryProvider)
          .fetchArenas(search: trimmed.isEmpty ? null : trimmed);
      if (!mounted) return;
      setState(() {
        _arenas = results;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'Pick Venue',
      subtitle: 'City is taken from the selected venue.',
      header: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: context.panel.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: context.fgSub, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  onChanged: _onChanged,
                  cursorColor: context.accent,
                  style: TextStyle(
                      color: context.fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Search by venue or city…',
                    hintStyle:
                        TextStyle(color: context.fgSub, fontSize: 14),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
              if (_loading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: context.accent),
                ),
            ],
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildListBody(context)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: _AddTempVenueTile(
              query: _ctrl.text.trim(),
              onTap: _openCreateTempVenue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListBody(BuildContext context) {
    if (_error != null && _arenas.isEmpty) {
      return _SheetMessage(message: _error!, isError: true);
    }
    if (!_loading && _arenas.isEmpty) {
      return _SheetMessage(
        message: _ctrl.text.trim().isEmpty
            ? 'No venues found.'
            : 'No venues match "${_ctrl.text.trim()}".',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      itemCount: _arenas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final a = _arenas[i];
        final city = _cityFromAddress(a.address);
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(_VenueChoice(
            id: a.id,
            name: a.name,
            city: city,
            address: a.address,
          )),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.stroke),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.stadium_rounded,
                      color: context.accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        a.address.isEmpty ? city : a.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(color: context.fgSub, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: context.fgSub, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCreateTempVenue() async {
    final navigator = Navigator.of(context);
    final picked = await showModalBottomSheet<_VenueChoice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TempVenueFormSheet(initialName: _ctrl.text.trim()),
    );
    if (!mounted || picked == null) return;
    navigator.pop(picked);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TEMPORARY VENUE FOOTER + FORM
// ══════════════════════════════════════════════════════════════════════════════

class _AddTempVenueTile extends StatelessWidget {
  const _AddTempVenueTile({required this.query, required this.onTap});
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.accent;
    final label = query.isEmpty
        ? 'Add a temporary venue'
        : 'Add "$query" as temporary venue';
    return Material(
      color: accent.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(Icons.add_location_alt_rounded, color: accent, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Can't find it? Create one just for this match.",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.fgSub.withValues(alpha: 0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: accent, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _TempVenueFormSheet extends StatefulWidget {
  const _TempVenueFormSheet({required this.initialName});
  final String initialName;

  @override
  State<_TempVenueFormSheet> createState() => _TempVenueFormSheetState();
}

class _TempVenueFormSheetState extends State<_TempVenueFormSheet> {
  late final TextEditingController _nameCtrl;
  final _cityCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  void _create() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(_VenueChoice(
      id: '', // empty id marks this as a temporary, non-facility venue
      name: name,
      city: _cityCtrl.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final canCreate = _nameCtrl.text.trim().isNotEmpty;
    return _SheetFrame(
      title: 'Temporary venue',
      subtitle: 'Used only for this match. Nothing is added to the venue list.',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TempField(
              controller: _nameCtrl,
              hint: 'Venue name (e.g. Local School Ground)',
              icon: Icons.stadium_rounded,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            _TempField(
              controller: _cityCtrl,
              hint: 'City (optional)',
              icon: Icons.location_city_rounded,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (canCreate) _create();
              },
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: canCreate
                      ? context.accent
                      : context.accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: canCreate ? _create : null,
                    child: Center(
                      child: Text(
                        'Use this venue',
                        style: TextStyle(
                          color: canCreate
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.55),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TempField extends StatelessWidget {
  const _TempField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.autofocus = false,
    this.onChanged,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          Icon(icon, color: context.fgSub, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              onChanged: onChanged,
              textInputAction: textInputAction,
              onSubmitted: onSubmitted,
              cursorColor: context.accent,
              style: TextStyle(
                color: context.fg,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: context.fgSub.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _cityFromAddress(String address) {
  final parts = address
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts.first;
  // Common format "Street, Area, City, State, PIN" — grab the third-from-last
  // non-numeric segment; fallback to last alpha segment.
  for (var i = parts.length - 1; i >= 0; i--) {
    final segment = parts[i];
    if (!RegExp(r'^\d').hasMatch(segment)) return segment;
  }
  return parts.last;
}

// ══════════════════════════════════════════════════════════════════════════════
// SCHEDULE
class _SheetFrame extends StatelessWidget {
  const _SheetFrame({
    required this.title,
    required this.child,
    this.subtitle,
    this.header,
  });

  final String title;
  final String? subtitle;
  final Widget? header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaBottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: mediaBottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: context.bg,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.stroke.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: context.fg,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(Icons.close_rounded,
                                color: context.fgSub),
                          ),
                        ],
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subtitle!,
                            style: TextStyle(
                                color: context.fgSub, fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ),
                if (header != null) header!,
                Flexible(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetMessage extends StatelessWidget {
  const _SheetMessage({required this.message, this.isError = false});
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isError ? context.danger : context.fgSub,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
