// Discover redesign — single-tab flow that replaces Create + old Discover.
//
//   Intro → Setup (preferences) → Celebrate → Results
//
// Each sub-page lives in its own widget below. Preferences are held by
// DiscoverViewState so Modify-search pre-fills smoothly. State auto-resets
// to Intro when the active preference-lobby's window has passed.

import 'dart:async';

import 'package:dio/dio.dart';
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
    this.format = MatchFormat.t20,
    this.allFormats = false,
    this.ballType,
    DateTime? date,
    Set<DiscoverWindow>? windows,
    this.preferredArenaId,
    this.preferredArenaName,
  })  : date = date ?? DateTime.now(),
        windows = windows ?? <DiscoverWindow>{};

  // Team comes from the team-switcher chip on DiscoverView, NOT from prefs.
  MatchFormat format;
  bool allFormats; // true = "All formats" picked; ignore format on search
  String? ballType; // null = "All ball types" picked
  DateTime date;
  Set<DiscoverWindow> windows; // empty = open to any window
  String? preferredArenaId;
  String? preferredArenaName;

  // Multi-window: at least one window picked OR user is open to any (empty
  // also OK — empty means "any window"). For now require at least one to
  // keep the user explicit; can relax to allow "any" via a separate toggle.
  bool get isComplete => windows.isNotEmpty;

  String get dateApi => DateFormat('yyyy-MM-dd').format(date);

  String get formatLabel => allFormats ? 'All formats' : format.label;
  String get ballLabel =>
      ballType == null ? 'All ball types' : _ballLabel(ballType!);

  String get windowsLabel {
    if (windows.isEmpty) return 'Any time';
    final all = DiscoverWindow.values.toSet();
    if (windows.length == all.length) return 'Anytime';
    return windows.map((w) => w.label).join(' · ');
  }

  List<String> get windowsApi => windows.map((w) => w.apiValue).toList();
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

  // Team-switcher state
  MmTeam? _currentTeam;
  // teamId → its active lobby summary (one per team)
  final Map<String, MmTeamLobbySummary> _teamLobbies = {};

  String? _activeLobbyId;
  List<MmRankedLobby> _closest = [];
  List<MmRankedLobby> _alternatives = [];
  String? _alternativeReason;
  String? _error;
  bool _submitting = false;
  Timer? _expiryTicker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
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

  // Loads the user's teams + per-team active lobbies. Picks a default
  // currentTeam (most-recent team with an active lobby, else first team).
  // If currentTeam has an active lobby, restores prefs and jumps to Results.
  Future<void> _bootstrap() async {
    try {
      final repo = ref.read(matchmakingRepositoryProvider);
      final res = await repo.getActiveLobbiesAll();
      if (!mounted) return;
      _teamLobbies.clear();
      for (final l in res.lobbies) {
        _teamLobbies[l.teamId] = l;
      }
      MmTeam? chosen;
      // Prefer a team with an active lobby
      if (res.lobbies.isNotEmpty) {
        final activeTeamId = res.lobbies.first.teamId;
        final activeRaw = res.teams.firstWhere(
          (t) => t.id == activeTeamId,
          orElse: () => (
            id: activeTeamId,
            name: res.lobbies.first.teamName ?? 'Team',
            logoUrl: null,
          ),
        );
        chosen = MmTeam(
          id: activeRaw.id,
          name: activeRaw.name,
          ageGroupLabel: 'Open',
          logoUrl: activeRaw.logoUrl,
        );
      } else if (res.teams.isNotEmpty) {
        final t = res.teams.first;
        chosen = MmTeam(
          id: t.id,
          name: t.name,
          ageGroupLabel: 'Open',
          logoUrl: t.logoUrl,
        );
      }
      if (!mounted) return;
      setState(() => _currentTeam = chosen);
      // If the chosen team has an active lobby, hydrate prefs + jump to results.
      final active = chosen != null ? _teamLobbies[chosen.id] : null;
      if (active != null) {
        _hydratePrefsFromLobby(active);
        await _runDiscover(skipCelebrate: true);
      }
    } catch (e) {
      _log('bootstrap error: $e');
    }
  }

  void _hydratePrefsFromLobby(MmTeamLobbySummary lobby) {
    DateTime? d;
    try {
      d = DateTime.parse(lobby.date);
    } catch (_) {}
    final w = _parseWindow(lobby.timeWindow);
    setState(() {
      _activeLobbyId = lobby.lobbyId;
      _prefs
        ..date = d ?? _prefs.date
        ..ballType = lobby.ballType
        ..preferredArenaId = lobby.preferredArenaId
        // Multi-window stored as null on the lobby = "open to any". Single
        // window restores into the set; null leaves the set empty.
        ..windows = (w != null ? {w} : <DiscoverWindow>{})
        ..format = _formatFromApi(lobby.format) ?? _prefs.format
        ..allFormats = lobby.format == 'ANY';
    });
  }

  void _maybeExpire() {
    if (_stage != _Stage.results || _activeLobbyId == null) return;
    if (!_isAllWindowsPassed(_prefs.date, _prefs.windows)) return;
    _log('all windows passed → reset to intro');
    setState(() {
      _activeLobbyId = null;
      _closest = [];
      _alternatives = [];
      _alternativeReason = null;
      _stage = _Stage.intro;
    });
  }

  // True if every selected window has ended on the lobby's date. Empty set
  // (open to any) → never auto-expires from this rule (the lobby's
  // expiresAt on the server handles that).
  bool _isAllWindowsPassed(DateTime date, Set<DiscoverWindow> windows) {
    if (windows.isEmpty) return false;
    final now = DateTime.now();
    return windows.every((w) {
      final endHour = switch (w) {
        DiscoverWindow.morning => 12,
        DiscoverWindow.afternoon => 18,
        DiscoverWindow.evening => 28,
      };
      final end = DateTime(date.year, date.month, date.day)
          .add(Duration(hours: endHour));
      return now.isAfter(end);
    });
  }

  // ── Stage transitions ──────────────────────────────────────────────────────

  void _goSetup() => setState(() => _stage = _Stage.setup);
  void _goIntro() => setState(() => _stage = _Stage.intro);

  Future<void> _submit() async {
    if (_currentTeam == null) {
      setState(() => _error = 'Pick a team first.');
      return;
    }
    if (!_prefs.isComplete) return;
    setState(() {
      _submitting = true;
      _error = null;
      _stage = _Stage.celebrating;
    });
    // Run search + minimum theatre time in parallel.
    await Future.wait([
      _runDiscover(skipCelebrate: true),
      Future<void>.delayed(const Duration(milliseconds: 1200)),
    ]);
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _stage = _Stage.results;
    });
  }

  // Calls /matchmaking/discover. Handles both first submit and Modify-search
  // (the backend service does find/update/create internally based on
  // teamId).
  Future<void> _runDiscover({bool skipCelebrate = false}) async {
    if (_currentTeam == null) return;
    final repo = ref.read(matchmakingRepositoryProvider);
    try {
      final res = await repo.discoverLobbies(
        teamId: _currentTeam!.id,
        date: _prefs.dateApi,
        format: _prefs.allFormats ? 'ANY' : _prefs.format.apiValue,
        ballType: _prefs.ballType,
        timeWindows: _prefs.windowsApi,
        preferredArenaId: _prefs.preferredArenaId,
      );
      if (!mounted) return;
      setState(() {
        _activeLobbyId = res.yourLobbyId;
        _closest = res.closest;
        _alternatives = res.alternatives;
        _alternativeReason = res.alternativeReason;
        // Refresh team-lobbies map so chip reflects this newly-active lobby.
        _teamLobbies[_currentTeam!.id] = MmTeamLobbySummary(
          lobbyId: res.yourLobbyId,
          teamId: _currentTeam!.id,
          teamName: _currentTeam!.name,
          status: 'searching',
          date: _prefs.dateApi,
          format: _prefs.allFormats ? 'ANY' : _prefs.format.apiValue,
          ballType: _prefs.ballType,
          timeWindow: _prefs.windows.length == 1
              ? _prefs.windows.first.apiValue
              : null,
          preferredArenaId: _prefs.preferredArenaId,
        );
        if (!skipCelebrate && _stage != _Stage.celebrating) {
          _stage = _Stage.results;
        }
      });
    } catch (e) {
      _log('runDiscover error: $e');
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = _extractServerError(e);
        // If we were celebrating, fall back to setup so the user sees the error.
        if (_stage == _Stage.celebrating) _stage = _Stage.setup;
      });
    }
  }

  // Surface the actual server reason instead of just "DioException".
  String _extractServerError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final msg = (data['error'] ?? data['message'])?.toString();
        if (msg != null && msg.isNotEmpty) return msg;
      }
      final code = e.response?.statusCode;
      if (code != null) return 'Request failed ($code).';
    }
    return e.toString();
  }

  // Switch to a different team. If that team has an active lobby, hydrate
  // prefs from it and jump to results. Else go to Intro for that team.
  Future<void> _switchTeam(MmTeam team) async {
    if (team.id == _currentTeam?.id) return;
    setState(() {
      _currentTeam = team;
      _activeLobbyId = null;
      _closest = [];
      _alternatives = [];
      _alternativeReason = null;
    });
    final active = _teamLobbies[team.id];
    if (active != null) {
      _hydratePrefsFromLobby(active);
      await _runDiscover(skipCelebrate: true);
      if (!mounted) return;
      setState(() => _stage = _Stage.results);
    } else {
      setState(() => _stage = _Stage.intro);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final teamsAsync = ref.watch(mmTeamsProvider);
    final allTeams = teamsAsync.valueOrNull ?? const <MmTeam>[];
    return switch (_stage) {
      _Stage.intro => _DiscoverIntro(
          team: _currentTeam,
          allTeams: allTeams,
          teamLobbies: _teamLobbies,
          onSwitchTeam: _switchTeam,
          onStart: _goSetup,
        ),
      _Stage.setup => _DiscoverSetup(
          prefs: _prefs,
          team: _currentTeam,
          allTeams: allTeams,
          teamLobbies: _teamLobbies,
          onSwitchTeam: _switchTeam,
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
          team: _currentTeam,
          allTeams: allTeams,
          teamLobbies: _teamLobbies,
          onSwitchTeam: _switchTeam,
          closest: _closest,
          alternatives: _alternatives,
          alternativeReason: _alternativeReason,
          onModify: _goSetup,
          onRefresh: _runDiscover,
          onChallenge: (lobby) => widget.onChallenge(lobby, _currentTeam),
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
  const _DiscoverIntro({
    required this.team,
    required this.allTeams,
    required this.teamLobbies,
    required this.onSwitchTeam,
    required this.onStart,
  });
  final MmTeam? team;
  final List<MmTeam> allTeams;
  final Map<String, MmTeamLobbySummary> teamLobbies;
  final ValueChanged<MmTeam> onSwitchTeam;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                _TeamChip(
                  team: team,
                  allTeams: allTeams,
                  teamLobbies: teamLobbies,
                  onSwitch: onSwitchTeam,
                ),
              ],
            ),
          ),
        ),
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
            onTap: team == null ? null : onStart,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: team == null
                    ? context.stroke.withValues(alpha: 0.18)
                    : context.ctaBg,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    team == null ? 'Pick a team to start' : 'Get started',
                    style: TextStyle(
                      color: team == null ? context.fgSub : context.ctaFg,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded,
                      color: team == null ? context.fgSub : context.ctaFg,
                      size: 18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── TEAM CHIP ──────────────────────────────────────────────────────────────

class _TeamChip extends StatelessWidget {
  const _TeamChip({
    required this.team,
    required this.allTeams,
    required this.teamLobbies,
    required this.onSwitch,
  });
  final MmTeam? team;
  final List<MmTeam> allTeams;
  final Map<String, MmTeamLobbySummary> teamLobbies;
  final ValueChanged<MmTeam> onSwitch;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: allTeams.isEmpty ? null : () => _open(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            context.fg.withValues(alpha: 0.05),
            context.bg,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: context.ctaBg.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.groups_rounded,
                  color: context.ctaBg, size: 12),
            ),
            const SizedBox(width: 8),
            Text(
              team?.name ?? 'Pick a team',
              style: TextStyle(
                color: context.fg,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: context.fgSub, size: 18),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.bg,
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  'Switch team',
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
              for (final t in allTeams)
                _PickerRow(
                  label: t.name,
                  subtitle: teamLobbies.containsKey(t.id)
                      ? '● Searching now'
                      : '${t.memberCount} member${t.memberCount == 1 ? '' : 's'}',
                  selected: team?.id == t.id,
                  onTap: () {
                    Navigator.of(sheetCtx).pop();
                    onSwitch(t);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─── SETUP ──────────────────────────────────────────────────────────────────

class _DiscoverSetup extends ConsumerStatefulWidget {
  const _DiscoverSetup({
    required this.prefs,
    required this.team,
    required this.allTeams,
    required this.teamLobbies,
    required this.onSwitchTeam,
    required this.submitting,
    required this.error,
    required this.onChanged,
    required this.onCancel,
    required this.onSubmit,
  });

  final _Prefs prefs;
  final MmTeam? team;
  final List<MmTeam> allTeams;
  final Map<String, MmTeamLobbySummary> teamLobbies;
  final ValueChanged<MmTeam> onSwitchTeam;
  final bool submitting;
  final String? error;
  final VoidCallback onChanged;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  ConsumerState<_DiscoverSetup> createState() => _DiscoverSetupState();
}

class _DiscoverSetupState extends ConsumerState<_DiscoverSetup> {
  // 0 = Match details (team/format/ball)
  // 1 = When (date + window)
  // 2 = Where (optional ground)
  int _step = 0;

  static const _stepLabels = ['Match details', 'When', 'Where'];

  bool _stepReady() {
    switch (_step) {
      case 0:
        // Team is now picked via the chip (handled in DiscoverView). Step 1
        // gates on ball type — format always has a default.
        return widget.team != null && widget.prefs.ballType != null;
      case 1:
        return widget.prefs.windows.isNotEmpty;
      case 2:
        return true; // ground is optional
    }
    return false;
  }

  void _next() {
    if (_step < _stepLabels.length - 1) {
      setState(() => _step += 1);
    } else {
      widget.onSubmit();
    }
  }

  void _back() {
    if (_step == 0) {
      widget.onCancel();
    } else {
      setState(() => _step -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.prefs;
    return Column(
      children: [
        // ── Top bar — back chevron + team chip + slim progress ─────
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _back,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: context.fg),
                  ),
                ),
                _TeamChip(
                  team: widget.team,
                  allTeams: widget.allTeams,
                  teamLobbies: widget.teamLobbies,
                  onSwitch: widget.onSwitchTeam,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      for (int i = 0; i < _stepLabels.length; i++) ...[
                        Expanded(
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: i <= _step
                                  ? context.ctaBg
                                  : context.stroke.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        if (i < _stepLabels.length - 1)
                          const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        // ── Poster header per step ─────────────────────────────────
        Align(
          alignment: Alignment.centerLeft,
          child: _PosterHeader(
            eyebrow: 'Step 0${_step + 1} of 0${_stepLabels.length}',
            title: _stepLabels[_step],
          ),
        ),
        // ── Body ───────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
            child: switch (_step) {
              0 => _DetailsStep(prefs: p, onChanged: () => setState(() {})),
              1 => _WhenStep(prefs: p, onChanged: () => setState(() {})),
              _ => _WhereStep(
                  prefs: p,
                  onChanged: () => setState(() {}),
                  ref: ref,
                ),
            },
          ),
        ),
        // ── Error ──────────────────────────────────────────────────
        if (widget.error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              widget.error!,
              style: TextStyle(
                color: context.danger,
                fontSize: 12,
                fontWeight: FontWeight.w500,
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
            onTap: _stepReady() && !widget.submitting ? _next : null,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _stepReady() && !widget.submitting
                    ? context.ctaBg
                    : context.stroke.withValues(alpha: 0.18),
              ),
              child: widget.submitting
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
                          _step == _stepLabels.length - 1
                              ? 'Find matches'
                              : 'Continue',
                          style: TextStyle(
                            color: _stepReady()
                                ? context.ctaFg
                                : context.fgSub,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          _step == _stepLabels.length - 1
                              ? Icons.search_rounded
                              : Icons.arrow_forward_rounded,
                          color:
                              _stepReady() ? context.ctaFg : context.fgSub,
                          size: 17,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Setup sub-steps ────────────────────────────────────────────────────────

class _DetailsStep extends StatelessWidget {
  const _DetailsStep({required this.prefs, required this.onChanged});
  final _Prefs prefs;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardGroup(
          children: [
            _SetupRow(
              label: 'FORMAT',
              value: prefs.formatLabel,
              placeholder: 'Tap to choose format',
              icon: Icons.sports_cricket_rounded,
              tint: context.match,
              onTap: () async {
                final r = await _pickFormat(context,
                    allSelected: prefs.allFormats, current: prefs.format);
                if (r == null) return;
                prefs.allFormats = r.all;
                if (r.format != null) prefs.format = r.format!;
                onChanged();
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        _CardGroup(
          children: [
            _SetupRow(
              label: 'BALL TYPE',
              value: prefs.ballLabel,
              placeholder: 'Tap to pick ball type',
              icon: Icons.circle,
              tint: context.warn,
              onTap: () async {
                final r = await _pickBallType(context, prefs.ballType);
                if (r == null) return;
                prefs.ballType = r.all ? null : r.value;
                onChanged();
              },
            ),
          ],
        ),
      ],
    );
  }
}

// Picker result types. `null` from the picker = dismissed without choice.
typedef _FormatPick = ({bool all, MatchFormat? format});
typedef _BallPick = ({bool all, String? value});

class _WhenStep extends StatelessWidget {
  const _WhenStep({required this.prefs, required this.onChanged});
  final _Prefs prefs;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GroupHeading('Choose date'),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: _DateStripSimple(
            selected: prefs.date,
            onSelect: (d) {
              prefs.date = d;
              onChanged();
            },
          ),
        ),
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
          child: Row(
            children: [
              Text(
                'TIME WINDOW',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'pick one or more',
                style: TextStyle(
                  color: context.fgSub.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        for (final w in DiscoverWindow.values) ...[
          _WindowCard(
            window: w,
            selected: prefs.windows.contains(w),
            onTap: () {
              if (prefs.windows.contains(w)) {
                prefs.windows.remove(w);
              } else {
                prefs.windows.add(w);
              }
              onChanged();
            },
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _WhereStep extends StatelessWidget {
  const _WhereStep({
    required this.prefs,
    required this.onChanged,
    required this.ref,
  });
  final _Prefs prefs;
  final VoidCallback onChanged;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardGroup(
          children: [
            _SetupRow(
              label: 'PREFERRED GROUND',
              value: prefs.preferredArenaName ?? 'Any nearby',
              placeholder: 'Any nearby',
              icon: Icons.place_rounded,
              tint: context.accent,
              onTap: () async {
                final picked = await _pickArena(
                  context,
                  ref,
                  prefs.dateApi,
                  prefs.format.apiValue,
                );
                if (picked == null) return;
                if (picked.id == '') {
                  prefs.preferredArenaId = null;
                  prefs.preferredArenaName = null;
                } else {
                  prefs.preferredArenaId = picked.id;
                  prefs.preferredArenaName = picked.name;
                }
                onChanged();
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            prefs.preferredArenaId != null
                ? 'Filtering by ground reduces match chances.'
                : 'Leave as "Any nearby" for the most matches. Pick a ground only if you must play there.',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.4,
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
    required this.team,
    required this.allTeams,
    required this.teamLobbies,
    required this.onSwitchTeam,
    required this.closest,
    required this.alternatives,
    required this.alternativeReason,
    required this.onModify,
    required this.onRefresh,
    required this.onChallenge,
  });

  final _Prefs prefs;
  final MmTeam? team;
  final List<MmTeam> allTeams;
  final Map<String, MmTeamLobbySummary> teamLobbies;
  final ValueChanged<MmTeam> onSwitchTeam;
  final List<MmRankedLobby> closest;
  final List<MmRankedLobby> alternatives;
  final String? alternativeReason;
  final VoidCallback onModify;
  final Future<void> Function({bool skipCelebrate}) onRefresh;
  final ValueChanged<MmOpenLobby> onChallenge;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                _TeamChip(
                  team: team,
                  allTeams: allTeams,
                  teamLobbies: teamLobbies,
                  onSwitch: onSwitchTeam,
                ),
                const Spacer(),
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
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => onRefresh(skipCelebrate: true),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${prefs.formatLabel} · ${_ballLabelFor(prefs)}',
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
                        '${_dateLabel(prefs.date)} · ${prefs.windowsLabel} · ${prefs.preferredArenaName ?? 'Any ground'}',
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
                const SizedBox(height: 14),
                Container(
                  height: 1,
                  color: context.stroke.withValues(alpha: 0.18),
                ),
                const SizedBox(height: 18),

                if (closest.isNotEmpty) ...[
                  _ResultsHeader(
                    label: 'CLOSEST MATCHES',
                    count: closest.length,
                    accent: true,
                  ),
                  const SizedBox(height: 8),
                  for (final r in closest)
                    _LobbyTile(
                      lobby: r.lobby,
                      prominent: true,
                      score: r.score,
                      matchedOn: r.matchedOn,
                      differs: r.differs,
                      onTap: () => onChallenge(r.lobby),
                    ),
                  const SizedBox(height: 18),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Text(
                      _emptyClosestText(alternativeReason, alternatives.isNotEmpty),
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],

                if (alternatives.isNotEmpty) ...[
                  _ResultsHeader(
                    label: alternativeReason == 'no_exact_matches'
                        ? 'OTHER MATCHES NEAR YOU'
                        : 'ALSO AVAILABLE',
                    count: alternatives.length,
                    accent: false,
                  ),
                  const SizedBox(height: 8),
                  for (final r in alternatives)
                    _LobbyTile(
                      lobby: r.lobby,
                      prominent: false,
                      score: r.score,
                      matchedOn: r.matchedOn,
                      differs: r.differs,
                      onTap: () => onChallenge(r.lobby),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _ballLabelFor(_Prefs p) =>
    p.ballType == null ? 'Any ball' : _ballLabel(p.ballType!);

String _emptyClosestText(String? reason, bool hasAlts) {
  if (reason == 'no_exact_matches') {
    return hasAlts
        ? 'No exact matches yet. Here are the closest alternatives:'
        : 'No teams want these prefs yet. Your match-up is posted — we\'ll notify you when one shows up.';
  }
  return 'No exact matches yet. Your match-up is posted — we\'ll notify you when one shows up.';
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

// ─── Apple Settings-style components ────────────────────────────────────────

class _CardGroup extends StatelessWidget {
  const _CardGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          context.fg.withValues(alpha: 0.04),
          context.bg,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                Padding(
                  // Inset the divider so it starts after the icon column —
                  // matches iOS Settings exactly.
                  padding: const EdgeInsets.only(left: 64),
                  child: Container(
                    height: 0.5,
                    color: context.stroke.withValues(alpha: 0.18),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SetupRow extends StatelessWidget {
  const _SetupRow({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final String? value;
  final String placeholder;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: tint.withValues(alpha: 0.06),
        highlightColor: tint.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Leading icon tile
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: tint, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasValue ? value! : placeholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasValue ? context.fg : context.fgSub,
                        fontSize: 16,
                        fontWeight:
                            hasValue ? FontWeight.w700 : FontWeight.w500,
                        letterSpacing: -0.2,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.chevron_right_rounded,
                  color: context.fgSub.withValues(alpha: 0.6), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PosterHeader extends StatelessWidget {
  const _PosterHeader({required this.eyebrow, required this.title});
  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: TextStyle(
              color: context.fgSub,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: context.fg,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupHeading extends StatelessWidget {
  const _GroupHeading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: context.fgSub,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _WindowCard extends StatelessWidget {
  const _WindowCard({
    required this.window,
    required this.selected,
    required this.onTap,
  });

  final DiscoverWindow window;
  final bool selected;
  final VoidCallback onTap;

  ({IconData icon, List<Color> grad}) _theme(BuildContext context) {
    return switch (window) {
      DiscoverWindow.morning => (
          icon: Icons.wb_sunny_rounded,
          grad: [
            const Color(0xFFFFB857),
            const Color(0xFFFF8A4C),
          ],
        ),
      DiscoverWindow.afternoon => (
          icon: Icons.wb_cloudy_rounded,
          grad: [
            const Color(0xFF5DBBE8),
            const Color(0xFF3C8DCB),
          ],
        ),
      DiscoverWindow.evening => (
          icon: Icons.nightlight_round,
          grad: [
            const Color(0xFF6E7CD9),
            const Color(0xFF3D2B6E),
          ],
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = _theme(context);
    final iconBg = t.grad[0].withValues(alpha: selected ? 1.0 : 0.18);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: selected
                ? Color.alphaBlend(
                    t.grad[0].withValues(alpha: 0.12), context.bg)
                : Color.alphaBlend(
                    context.fg.withValues(alpha: 0.04), context.bg),
            borderRadius: BorderRadius.circular(14),
            border: selected
                ? Border.all(
                    color: t.grad[1].withValues(alpha: 0.4), width: 1.4)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: selected
                      ? LinearGradient(
                          colors: t.grad,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: selected ? null : iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  t.icon,
                  color: selected ? Colors.white : t.grad[1],
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      window.label,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      window.hint,
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: t.grad,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 14),
                ),
            ],
          ),
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
    this.score,
    this.matchedOn = const [],
    this.differs = const [],
  });
  final MmOpenLobby lobby;
  final bool prominent;
  final VoidCallback onTap;
  final double? score;
  final List<String> matchedOn;
  final List<String> differs;

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
                  if (differs.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'differs: ${differs.join(', ')}',
                      style: TextStyle(
                        color: context.warn,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
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

Future<_FormatPick?> _pickFormat(
  BuildContext context, {
  required bool allSelected,
  required MatchFormat current,
}) {
  return showModalBottomSheet<_FormatPick>(
    context: context,
    backgroundColor: context.bg,
    builder: (sheetCtx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                'Choose Format',
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
            // "All formats" — first option, with subtitle to clarify
            _PickerRow(
              label: 'All formats',
              subtitle: 'Match teams playing any format',
              selected: allSelected,
              onTap: () => Navigator.of(sheetCtx)
                  .pop((all: true, format: null)),
            ),
            Container(
              height: 1,
              color: context.stroke.withValues(alpha: 0.14),
              margin: const EdgeInsets.symmetric(horizontal: 20),
            ),
            for (final f in MatchFormat.values)
              _PickerRow(
                label: f.label,
                selected: !allSelected && f == current,
                onTap: () => Navigator.of(sheetCtx)
                    .pop((all: false, format: f)),
              ),
          ],
        ),
      );
    },
  );
}

Future<_BallPick?> _pickBallType(
    BuildContext context, String? current) {
  const balls = ['LEATHER', 'TENNIS', 'TAPE', 'RUBBER'];
  return showModalBottomSheet<_BallPick>(
    context: context,
    backgroundColor: context.bg,
    builder: (sheetCtx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                'Choose Ball Type',
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
            _PickerRow(
              label: 'All ball types',
              subtitle: 'Match teams using any ball',
              selected: current == null,
              onTap: () => Navigator.of(sheetCtx)
                  .pop((all: true, value: null)),
            ),
            Container(
              height: 1,
              color: context.stroke.withValues(alpha: 0.14),
              margin: const EdgeInsets.symmetric(horizontal: 20),
            ),
            for (final bt in balls)
              _PickerRow(
                label: _ballLabel(bt),
                selected: bt == current,
                onTap: () => Navigator.of(sheetCtx)
                    .pop((all: false, value: bt)),
              ),
          ],
        ),
      );
    },
  );
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: selected ? context.ctaBg : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? context.ctaFg : context.fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: selected
                            ? context.ctaFg.withValues(alpha: 0.75)
                            : context.fgSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, color: context.ctaFg, size: 20),
          ],
        ),
      ),
    );
  }
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
