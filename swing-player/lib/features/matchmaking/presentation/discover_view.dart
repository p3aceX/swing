// Discover redesign — single-tab flow that replaces Create + old Discover.
//
//   Intro → Setup (preferences) → Celebrate → Results
//
// Each sub-page lives in its own widget below. Preferences are held by
// DiscoverViewState so Modify-search pre-fills smoothly. State auto-resets
// to Intro when the active preference-lobby's window has passed.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/matchmaking_models.dart';
import 'matchmaking_providers.dart';

// ignore: avoid_print
void _log(String msg) => debugPrint('[Discover] $msg');

// ── Stage machine ───────────────────────────────────────────────────────────

enum _Stage { intro, setup, celebrating, results }

// Time-window enum mirrored from backend.
enum DiscoverWindow { morning, afternoon, evening }

extension _DiscoverWindowApi on DiscoverWindow {
  String get apiValue => switch (this) {
        DiscoverWindow.morning => 'MORNING',
        DiscoverWindow.afternoon => 'AFTERNOON',
        DiscoverWindow.evening => 'EVENING',
      };
  String get label => switch (this) {
        DiscoverWindow.morning => 'Morning',
        DiscoverWindow.afternoon => 'Afternoon',
        DiscoverWindow.evening => 'Evening',
      };
  String get hint => switch (this) {
        DiscoverWindow.morning => '6 AM – 12 PM',
        DiscoverWindow.afternoon => '12 PM – 6 PM',
        DiscoverWindow.evening => '6 PM onwards',
      };
}

DiscoverWindow? _parseWindow(String? s) => switch (s) {
      'MORNING' => DiscoverWindow.morning,
      'AFTERNOON' => DiscoverWindow.afternoon,
      'EVENING' => DiscoverWindow.evening,
      _ => null,
    };

// ── Preferences container ───────────────────────────────────────────────────

class _Prefs {
  _Prefs({
    this.team,
    this.format = MatchFormat.t20,
    this.ballType,
    DateTime? date,
    this.window,
    this.preferredArenaId,
    this.preferredArenaName,
  }) : date = date ?? DateTime.now();

  MmTeam? team;
  MatchFormat format;
  String? ballType;
  DateTime date;
  DiscoverWindow? window;
  String? preferredArenaId;
  String? preferredArenaName;

  bool get isComplete =>
      team != null && ballType != null && window != null;

  String get dateApi => DateFormat('yyyy-MM-dd').format(date);
}

// ── Top-level widget ────────────────────────────────────────────────────────

class DiscoverView extends ConsumerStatefulWidget {
  const DiscoverView({super.key, required this.onChallenge});

  /// Fires when the user taps a lobby tile in Results. Caller wires this to
  /// the existing express-interest → lock-and-pay → Razorpay flow.
  final void Function(MmOpenLobby lobby, MmTeam? withTeam) onChallenge;

  @override
  ConsumerState<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends ConsumerState<DiscoverView> {
  _Stage _stage = _Stage.intro;
  final _Prefs _prefs = _Prefs();

  String? _activeLobbyId;
  List<MmOpenLobby> _matches = [];
  List<MmOpenLobby> _alsoAvailable = [];
  String? _error;
  bool _submitting = false;
  Timer? _expiryTicker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreActive());
    // Re-check expiry every 60s when on results page so an expired lobby
    // bounces the user back to Intro automatically.
    _expiryTicker =
        Timer.periodic(const Duration(seconds: 60), (_) => _maybeExpire());
  }

  @override
  void dispose() {
    _expiryTicker?.cancel();
    super.dispose();
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  Future<void> _restoreActive() async {
    try {
      final repo = ref.read(matchmakingRepositoryProvider);
      final active = await repo.getActiveLobby();
      if (!mounted || active == null) return;
      // Only auto-restore preference-lobbies — slot-precise lobbies belong to
      // the legacy flow which we'll let stay on Intro.
      final w = _parseWindow(active.timeWindow);
      if (w == null) return;
      // Restore prefs from active lobby for Modify pre-fill.
      DateTime? d;
      try {
        if (active.date != null) d = DateTime.parse(active.date!);
      } catch (_) {}
      setState(() {
        _activeLobbyId = active.lobbyId;
        _prefs
          ..window = w
          ..date = d ?? _prefs.date
          ..preferredArenaId = active.preferredArenaId
          ..preferredArenaName = active.preferredArenaName
          ..ballType = active.ballType ?? _prefs.ballType
          ..format = _formatFromApi(active.format) ?? _prefs.format;
        _stage = _Stage.results;
      });
      await _refreshResults();
    } catch (e) {
      _log('restoreActive error: $e');
    }
  }

  void _maybeExpire() {
    if (_stage != _Stage.results || _activeLobbyId == null) return;
    if (!_isWindowPassed(_prefs.date, _prefs.window)) return;
    _log('window passed → reset to intro');
    setState(() {
      _activeLobbyId = null;
      _matches = [];
      _alsoAvailable = [];
      _stage = _Stage.intro;
    });
  }

  bool _isWindowPassed(DateTime date, DiscoverWindow? w) {
    if (w == null) return false;
    final endHour = switch (w) {
      DiscoverWindow.morning => 12,
      DiscoverWindow.afternoon => 18,
      DiscoverWindow.evening => 28, // next day 04:00
    };
    final end = DateTime(date.year, date.month, date.day, endHour ~/ 24 == 0 ? endHour : endHour - 24)
        .add(endHour >= 24 ? const Duration(days: 1) : Duration.zero);
    return DateTime.now().isAfter(end);
  }

  // ── Stage transitions ──────────────────────────────────────────────────────

  void _goSetup() => setState(() => _stage = _Stage.setup);
  void _goIntro() => setState(() => _stage = _Stage.intro);

  Future<void> _submit() async {
    if (!_prefs.isComplete) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final repo = ref.read(matchmakingRepositoryProvider);
      // If we already have a lobby (Modify path), drop it before posting fresh.
      if (_activeLobbyId != null) {
        try {
          await repo.leaveLobby(_activeLobbyId!);
        } catch (e) {
          _log('leaveLobby (modify) error: $e');
        }
        _activeLobbyId = null;
      }
      final created = await repo.createLobby(
        teamId: _prefs.team!.id,
        format: _prefs.format.apiValue,
        ballType: _prefs.ballType,
        date: _prefs.dateApi,
        picks: const [],
        timeWindow: _prefs.window!.apiValue,
        preferredArenaId: _prefs.preferredArenaId,
      );
      _activeLobbyId = created.lobbyId;
      // Cinematic celebrate then results.
      setState(() {
        _submitting = false;
        _stage = _Stage.celebrating;
      });
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      await _refreshResults();
      if (!mounted) return;
      setState(() => _stage = _Stage.results);
    } catch (e) {
      _log('submit error: $e');
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = '$e';
      });
    }
  }

  Future<void> _refreshResults() async {
    final repo = ref.read(matchmakingRepositoryProvider);
    try {
      // Lobbies that match preferences exactly (window + ground if pinned)
      final matches = await repo.listOpenLobbies(
        date: _prefs.dateApi,
        format: _prefs.format.apiValue,
        timeWindow: _prefs.window!.apiValue,
        preferredArenaId: _prefs.preferredArenaId,
      );
      // Also-available: same date+format, any window/arena → minus the matches
      final all = await repo.listOpenLobbies(
        date: _prefs.dateApi,
        format: _prefs.format.apiValue,
      );
      final matchIds = matches.map((l) => l.lobbyId).toSet();
      final others = all.where((l) => !matchIds.contains(l.lobbyId)).toList();
      if (!mounted) return;
      setState(() {
        _matches = matches;
        _alsoAvailable = others;
      });
    } catch (e) {
      _log('refreshResults error: $e');
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return switch (_stage) {
      _Stage.intro => _DiscoverIntro(onStart: _goSetup),
      _Stage.setup => _DiscoverSetup(
          prefs: _prefs,
          submitting: _submitting,
          error: _error,
          onChanged: () => setState(() {}),
          onCancel: _activeLobbyId != null
              ? () => setState(() => _stage = _Stage.results)
              : _goIntro,
          onSubmit: _submit,
        ),
      _Stage.celebrating => const _DiscoverCelebrate(),
      _Stage.results => _DiscoverResults(
          prefs: _prefs,
          matches: _matches,
          alsoAvailable: _alsoAvailable,
          onModify: _goSetup,
          onRefresh: _refreshResults,
          onChallenge: (lobby) => widget.onChallenge(lobby, _prefs.team),
        ),
    };
  }
}

MatchFormat? _formatFromApi(String? s) => switch (s) {
      'T10' => MatchFormat.t10,
      'T20' => MatchFormat.t20,
      'ODI' => MatchFormat.odi,
      'Test' => MatchFormat.test,
      'Custom' => MatchFormat.custom,
      _ => null,
    };

extension _FormatApi on MatchFormat {
  String get apiValue => switch (this) {
        MatchFormat.t10 => 'T10',
        MatchFormat.t20 => 'T20',
        MatchFormat.odi => 'ODI',
        MatchFormat.test => 'Test',
        MatchFormat.custom => 'Custom',
      };
}

// ─── INTRO ──────────────────────────────────────────────────────────────────

class _DiscoverIntro extends StatelessWidget {
  const _DiscoverIntro({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find your\nmatch-up.',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2.4,
                    height: 0.95,
                  ),
                ),
                const SizedBox(height: 22),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: 'Skip the group chat.\n'),
                        TextSpan(
                          text: 'Pick a window',
                          style: TextStyle(
                            color: context.fg,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const TextSpan(
                            text:
                                ' — we\'ll match you with a team that wants the same one.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
              20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
          child: GestureDetector(
            onTap: onStart,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: context.ctaBg),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Get started',
                    style: TextStyle(
                      color: context.ctaFg,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded,
                      color: context.ctaFg, size: 18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── SETUP ──────────────────────────────────────────────────────────────────

class _DiscoverSetup extends ConsumerWidget {
  const _DiscoverSetup({
    required this.prefs,
    required this.submitting,
    required this.error,
    required this.onChanged,
    required this.onCancel,
    required this.onSubmit,
  });

  final _Prefs prefs;
  final bool submitting;
  final String? error;
  final VoidCallback onChanged;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(mmTeamsProvider);
    return Column(
      children: [
        // ── Header ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: onCancel,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(Icons.arrow_back_rounded,
                      size: 22, color: context.fg),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Match Setup',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel('Team'),
                _SetupRow(
                  label: prefs.team?.name ?? 'Pick a team',
                  hasValue: prefs.team != null,
                  onTap: () async {
                    final teams = teamsAsync.valueOrNull ?? const <MmTeam>[];
                    final picked = await _pickTeam(context, teams);
                    if (picked != null) {
                      prefs.team = picked;
                      onChanged();
                    }
                  },
                ),
                const SizedBox(height: 18),
                _SectionLabel('Format'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final f in MatchFormat.values)
                        _Chip(
                          label: f.label,
                          selected: prefs.format == f,
                          onTap: () {
                            prefs.format = f;
                            onChanged();
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SectionLabel('Ball'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final bt in const ['LEATHER', 'TENNIS', 'TAPE', 'RUBBER'])
                        _Chip(
                          label: _ballLabel(bt),
                          selected: prefs.ballType == bt,
                          onTap: () {
                            prefs.ballType = bt;
                            onChanged();
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _SectionLabel('When'),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: _DateStripSimple(
                    selected: prefs.date,
                    onSelect: (d) {
                      prefs.date = d;
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final w in DiscoverWindow.values)
                        _Chip(
                          label: w.label,
                          subLabel: w.hint,
                          selected: prefs.window == w,
                          onTap: () {
                            prefs.window = w;
                            onChanged();
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _SectionLabel('Where'),
                _SetupRow(
                  label: prefs.preferredArenaName ?? 'Any nearby ground',
                  hasValue: prefs.preferredArenaName != null,
                  onTap: () async {
                    final picked = await _pickArena(
                      context,
                      ref,
                      prefs.dateApi,
                      prefs.format.apiValue,
                    );
                    if (picked == null) return;
                    if (picked.id == '') {
                      // sentinel for "Any nearby"
                      prefs.preferredArenaId = null;
                      prefs.preferredArenaName = null;
                    } else {
                      prefs.preferredArenaId = picked.id;
                      prefs.preferredArenaName = picked.name;
                    }
                    onChanged();
                  },
                ),
                if (prefs.preferredArenaId != null) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Filtering by ground reduces match chances.',
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                if (error != null) ...[
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: context.danger,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        // ── CTA ────────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: context.stroke.withValues(alpha: 0.14),
                width: 1,
              ),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
              20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
          child: GestureDetector(
            onTap: prefs.isComplete && !submitting ? onSubmit : null,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: prefs.isComplete && !submitting
                    ? context.ctaBg
                    : context.stroke.withValues(alpha: 0.18),
              ),
              child: submitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: context.ctaFg),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Find matches',
                          style: TextStyle(
                            color: prefs.isComplete
                                ? context.ctaFg
                                : context.fgSub,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded,
                            color: prefs.isComplete
                                ? context.ctaFg
                                : context.fgSub,
                            size: 17),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

String _ballLabel(String bt) => switch (bt) {
      'LEATHER' => 'Leather',
      'TENNIS' => 'Tennis',
      'TAPE' => 'Tape',
      'RUBBER' => 'Rubber',
      _ => bt,
    };

// ─── CELEBRATE ──────────────────────────────────────────────────────────────

class _DiscoverCelebrate extends StatefulWidget {
  const _DiscoverCelebrate();

  @override
  State<_DiscoverCelebrate> createState() => _DiscoverCelebrateState();
}

class _DiscoverCelebrateState extends State<_DiscoverCelebrate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Animation<double> _slice(double a, double b, {Curve curve = Curves.easeOutCubic}) =>
      CurvedAnimation(parent: _c, curve: Interval(a, b, curve: curve));

  @override
  Widget build(BuildContext context) {
    final wash = _slice(0.0, 0.30);
    final check = _slice(0.30, 0.80, curve: Curves.elasticOut);
    final text = _slice(0.50, 1.0);

    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          // Radial wash
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    context.ctaBg.withValues(alpha: 0.30 * wash.value),
                    context.bg,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: 0.4 + 0.6 * check.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.ctaBg,
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.check_rounded,
                      color: context.ctaFg, size: 64),
                ),
              ),
              const SizedBox(height: 24),
              Opacity(
                opacity: text.value,
                child: Text(
                  'Match-up posted',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Opacity(
                opacity: text.value,
                child: Text(
                  'Looking for teams…',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── RESULTS ────────────────────────────────────────────────────────────────

class _DiscoverResults extends StatelessWidget {
  const _DiscoverResults({
    required this.prefs,
    required this.matches,
    required this.alsoAvailable,
    required this.onModify,
    required this.onRefresh,
    required this.onChallenge,
  });

  final _Prefs prefs;
  final List<MmOpenLobby> matches;
  final List<MmOpenLobby> alsoAvailable;
  final VoidCallback onModify;
  final Future<void> Function() onRefresh;
  final ValueChanged<MmOpenLobby> onChallenge;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
        children: [
          // ── Preferences chip strip + Modify button ─────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${prefs.team?.name ?? '—'} · ${prefs.format.label}${prefs.ballType != null ? ' · ${_ballLabel(prefs.ballType!)}' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_dateLabel(prefs.date)} · ${prefs.window?.label ?? ''} · ${prefs.preferredArenaName ?? 'Any ground'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onModify,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.stroke.withValues(alpha: 0.6),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tune_rounded, size: 14, color: context.fg),
                        const SizedBox(width: 6),
                        Text(
                          'Modify',
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            color: context.stroke.withValues(alpha: 0.18),
          ),
          const SizedBox(height: 18),

          // ── Matches your preferences ───────────────────────────────
          if (matches.isNotEmpty) ...[
            _ResultsHeader(
              label: 'MATCHES YOUR PREFERENCES',
              count: matches.length,
              accent: true,
            ),
            const SizedBox(height: 8),
            for (final l in matches)
              _LobbyTile(
                  lobby: l, prominent: true, onTap: () => onChallenge(l)),
            const SizedBox(height: 18),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              child: Text(
                'No teams want this window yet. Your match-up is posted — we\'ll ping you when one shows up.',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
          if (alsoAvailable.isNotEmpty) ...[
            _ResultsHeader(
              label: 'ALSO AVAILABLE',
              count: alsoAvailable.length,
              accent: false,
            ),
            const SizedBox(height: 8),
            for (final l in alsoAvailable)
              _LobbyTile(
                  lobby: l, prominent: false, onTap: () => onChallenge(l)),
          ],
        ],
      ),
    );
  }
}

String _dateLabel(DateTime d) {
  final today = DateTime.now();
  final t = DateTime(today.year, today.month, today.day);
  final dd = DateTime(d.year, d.month, d.day);
  if (dd == t) return 'Today';
  if (dd == t.add(const Duration(days: 1))) return 'Tomorrow';
  return DateFormat('EEE MMM d').format(d);
}

// ─── Shared sub-widgets ─────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: context.fgSub,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _SetupRow extends StatelessWidget {
  const _SetupRow({
    required this.label,
    required this.hasValue,
    required this.onTap,
  });
  final String label;
  final bool hasValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: context.stroke.withValues(alpha: 0.6),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: hasValue ? context.fg : context.fgSub,
                  fontSize: 15,
                  fontWeight: hasValue ? FontWeight.w800 : FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: context.fgSub, size: 22),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    this.subLabel,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final String? subLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? context.ctaBg : Colors.transparent,
          border: Border.all(
            color:
                selected ? context.ctaBg : context.stroke.withValues(alpha: 0.6),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? context.ctaFg : context.fg,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.1,
                height: 1.0,
              ),
            ),
            if (subLabel != null) ...[
              const SizedBox(height: 2),
              Text(
                subLabel!,
                style: TextStyle(
                  color: selected
                      ? context.ctaFg.withValues(alpha: 0.75)
                      : context.fgSub,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DateStripSimple extends StatelessWidget {
  const _DateStripSimple({required this.selected, required this.onSelect});
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(
        14, (i) => DateTime(today.year, today.month, today.day + i));
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final d = days[i];
          final sel = DateUtils.isSameDay(d, selected);
          return GestureDetector(
            onTap: () => onSelect(d),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 56,
              decoration: BoxDecoration(
                color: sel ? context.ctaBg : Colors.transparent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    i == 0 ? 'TODAY' : DateFormat('EEE').format(d).toUpperCase(),
                    style: TextStyle(
                      color: sel ? context.ctaFg : context.fgSub,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      color: sel ? context.ctaFg : context.fg,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({
    required this.label,
    required this.count,
    required this.accent,
  });
  final String label;
  final int count;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (accent) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: context.match,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: accent ? context.match : context.fgSub,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            count.toString(),
            style: TextStyle(
              color: context.fg,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _LobbyTile extends StatelessWidget {
  const _LobbyTile({
    required this.lobby,
    required this.prominent,
    required this.onTap,
  });
  final MmOpenLobby lobby;
  final bool prominent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            if (prominent) ...[
              Container(
                width: 3,
                height: 48,
                color: context.match,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lobby.teamName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${lobby.dateLabel} · ${lobby.displaySlot.isNotEmpty ? lobby.displaySlot : (lobby.timeWindow ?? '')} · ${lobby.arenaName.isNotEmpty ? lobby.arenaName : (lobby.preferredArenaName ?? 'Any ground')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '₹${(lobby.pricePerTeamPaise / 100).round()}',
              style: TextStyle(
                color: context.fg,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_rounded, size: 18, color: context.fgSub),
          ],
        ),
      ),
    );
  }
}

// ─── Pickers (inline modal sheets) ──────────────────────────────────────────

Future<MmTeam?> _pickTeam(BuildContext context, List<MmTeam> teams) {
  return showModalBottomSheet<MmTeam>(
    context: context,
    backgroundColor: context.bg,
    isScrollControlled: true,
    builder: (sheetCtx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                'Choose team',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            Container(
              height: 1,
              color: context.stroke.withValues(alpha: 0.18),
            ),
            if (teams.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No teams yet. Create one first.',
                  style: TextStyle(color: context.fgSub, fontSize: 13),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: teams.length,
                  itemBuilder: (_, i) {
                    final t = teams[i];
                    return GestureDetector(
                      onTap: () => Navigator.of(sheetCtx).pop(t),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
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
                            Text(
                              '${t.memberCount} member${t.memberCount == 1 ? '' : 's'}',
                              style: TextStyle(
                                color: context.fgSub,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    },
  );
}

Future<({String id, String name})?> _pickArena(
  BuildContext context,
  WidgetRef ref,
  String dateApi,
  String formatApi,
) {
  final query = (
    date: dateApi,
    format: formatApi,
    teamId: null,
    overs: null,
  );
  return showModalBottomSheet<({String id, String name})>(
    context: context,
    backgroundColor: context.bg,
    isScrollControlled: true,
    builder: (sheetCtx) {
      return Consumer(
        builder: (consumerCtx, ref, _) {
          final asyncGrounds = ref.watch(mmGroundsProvider(query));
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Text(
                    'Choose ground',
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  color: context.stroke.withValues(alpha: 0.18),
                ),
                GestureDetector(
                  onTap: () =>
                      Navigator.of(sheetCtx).pop((id: '', name: 'Any nearby')),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    child: Text(
                      'Any nearby ground',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  color: context.stroke.withValues(alpha: 0.14),
                ),
                Flexible(
                  child: asyncGrounds.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(
                          child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.2))),
                    ),
                    error: (_, __) => Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Could not load grounds.',
                        style: TextStyle(color: context.fgSub, fontSize: 13),
                      ),
                    ),
                    data: (grounds) {
                      final arenas = <String, String>{};
                      for (final g in grounds) {
                        // Each ground maps to its arena via the ground's name as
                        // a fallback; `MmGround` includes id+name. We treat
                        // ground.id as arena key for now.
                        arenas[g.id] = g.name;
                      }
                      final entries = arenas.entries.toList()
                        ..sort((a, b) => a.value.compareTo(b.value));
                      if (entries.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'No grounds for this date.',
                            style:
                                TextStyle(color: context.fgSub, fontSize: 13),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: entries.length,
                        itemBuilder: (_, i) {
                          final e = entries[i];
                          return GestureDetector(
                            onTap: () => Navigator.of(sheetCtx).pop(
                                (id: e.key, name: e.value)),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              child: Text(
                                e.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.fg,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
