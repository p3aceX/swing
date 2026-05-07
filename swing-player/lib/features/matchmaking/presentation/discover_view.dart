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

// Time-window enum mirrored from backend (5-bucket model).
enum DiscoverWindow { morning, afternoon, evening, night, lateNight }

extension _DiscoverWindowApi on DiscoverWindow {
  String get apiValue => switch (this) {
        DiscoverWindow.morning => 'MORNING',
        DiscoverWindow.afternoon => 'AFTERNOON',
        DiscoverWindow.evening => 'EVENING',
        DiscoverWindow.night => 'NIGHT',
        DiscoverWindow.lateNight => 'LATE_NIGHT',
      };
  String get label => switch (this) {
        DiscoverWindow.morning => 'Morning',
        DiscoverWindow.afternoon => 'Afternoon',
        DiscoverWindow.evening => 'Evening',
        DiscoverWindow.night => 'Night',
        DiscoverWindow.lateNight => 'Late night',
      };
  String get hint => switch (this) {
        DiscoverWindow.morning => '6:30 AM – 11:30 AM',
        DiscoverWindow.afternoon => '11:30 AM – 4:30 PM',
        DiscoverWindow.evening => '4:30 PM – 8:30 PM',
        DiscoverWindow.night => '8:30 PM – 11:30 PM',
        DiscoverWindow.lateNight => '11:30 PM – 4 AM',
      };
  // Minutes past start-of-day at which this window ends. LATE_NIGHT = 28*60
  // since it bleeds into the next day.
  int get _endMin => switch (this) {
        DiscoverWindow.morning => 11 * 60 + 30,
        DiscoverWindow.afternoon => 16 * 60 + 30,
        DiscoverWindow.evening => 20 * 60 + 30,
        DiscoverWindow.night => 23 * 60 + 30,
        DiscoverWindow.lateNight => 28 * 60,
      };
  bool isPast(DateTime date) {
    final end = DateTime(date.year, date.month, date.day)
        .add(Duration(minutes: _endMin));
    return DateTime.now().isAfter(end);
  }
}

DiscoverWindow? _parseWindow(String? s) => switch (s) {
      'MORNING' => DiscoverWindow.morning,
      'AFTERNOON' => DiscoverWindow.afternoon,
      'EVENING' => DiscoverWindow.evening,
      'NIGHT' => DiscoverWindow.night,
      'LATE_NIGHT' => DiscoverWindow.lateNight,
      _ => null,
    };

// One entry in the preferred-grounds list. Up to 3 of these are stored on
// _Prefs.preferredArenas. Backed by the lobby's preferredArenaIds field.
typedef MmArenaPick = ({String id, String name});

// ── Preferences container ───────────────────────────────────────────────────

class _Prefs {
  _Prefs({
    this.format = MatchFormat.t20,
    this.allFormats = false,
    this.ballType,
    DateTime? date,
    Set<DiscoverWindow>? windows,
    List<MmArenaPick>? preferredArenas,
  })  : date = date ?? DateTime.now(),
        windows = windows ?? <DiscoverWindow>{},
        preferredArenas = preferredArenas ?? <MmArenaPick>[];

  // Team comes from the team-switcher chip on DiscoverView, NOT from prefs.
  MatchFormat format;
  bool allFormats; // true = "All formats" picked; ignore format on search
  String? ballType; // null = "All ball types" picked
  DateTime date;
  Set<DiscoverWindow> windows; // empty = open to any window
  // Up to 3 grounds the team would accept. Empty = "Any nearby ground."
  List<MmArenaPick> preferredArenas;

  // Legacy accessors kept for places (Results header, etc.) that still expect
  // a single ground for display. Returns first picked or null.
  String? get preferredArenaId =>
      preferredArenas.isEmpty ? null : preferredArenas.first.id;
  String? get preferredArenaName =>
      preferredArenas.isEmpty ? null : preferredArenas.first.name;
  List<String> get preferredArenaIdList =>
      preferredArenas.map((a) => a.id).toList();
  String get preferredArenasLabel {
    if (preferredArenas.isEmpty) return 'Any nearby';
    if (preferredArenas.length == 1) return preferredArenas.first.name;
    return '${preferredArenas.first.name} + ${preferredArenas.length - 1} more';
  }

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
      // Single legacy preferredArenaId on the lobby summary becomes a
      // 1-element preferredArenas list when present.
      final hydratedArenas = <MmArenaPick>[];
      if (lobby.preferredArenaId != null && lobby.preferredArenaId!.isNotEmpty) {
        // MmTeamLobbySummary doesn't carry the arena name; placeholder until
        // user re-opens the picker (which fetches names by ID).
        hydratedArenas.add((
          id: lobby.preferredArenaId!,
          name: 'Selected ground',
        ));
      }
      _prefs
        ..date = d ?? _prefs.date
        ..ballType = lobby.ballType
        ..preferredArenas = hydratedArenas
        // Multi-window stored as null on the lobby = "open to any". Single
        // window restores into the set; null leaves the set empty.
        ..windows = (w != null ? {w} : <DiscoverWindow>{})
        ..format = _formatFromApi(lobby.format) ?? _prefs.format
        ..allFormats = lobby.format == 'ANY';
    });
  }

  // Used by the Results page to render an "expired" banner. We deliberately
  // no longer auto-bounce the user back to Intro — that felt like an
  // interrupt. Instead the user sees the banner and chooses Modify or Cancel.
  bool get _hasExpired =>
      _activeLobbyId != null &&
      _isAllWindowsPassed(_prefs.date, _prefs.windows);

  void _maybeExpire() {
    // Lightweight tick to nudge a rebuild so the expired banner shows up
    // exactly when the last window passes (without waiting for user input).
    if (_stage != _Stage.results || _activeLobbyId == null) return;
    if (!_isAllWindowsPassed(_prefs.date, _prefs.windows)) return;
    if (mounted) setState(() {});
  }

  Future<void> _cancelSearch() async {
    if (_activeLobbyId == null) {
      setState(() => _stage = _Stage.intro);
      return;
    }
    final repo = ref.read(matchmakingRepositoryProvider);
    try {
      await repo.leaveLobby(_activeLobbyId!);
    } catch (e) {
      _log('cancelSearch leaveLobby error (ignored): $e');
    }
    if (!mounted) return;
    final tid = _currentTeam?.id;
    setState(() {
      if (tid != null) _teamLobbies.remove(tid);
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
    // Delegates to DiscoverWindow.isPast, which uses the canonical end
    // minutes (matches backend WINDOW_RANGES).
    return windows.every((w) => w.isPast(date));
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
    // Run search + minimum theatre time (4.5s) in parallel. If the API
    // resolves first, we still wait for the cycling-text animation to play
    // through. If the API takes longer, we hold on the last phase.
    await Future.wait([
      _runDiscover(skipCelebrate: true),
      Future<void>.delayed(const Duration(milliseconds: 4500)),
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
        preferredArenaIds: _prefs.preferredArenaIdList,
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
      // Slot-conflict (409) gets a friendly dialog instead of a raw error.
      // Backend response shape: { success:false, error:{ code, message, details } }
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['error'] is Map) {
          final err = data['error'] as Map;
          if (err['code'] == 'SLOT_CONFLICT') {
            setState(() {
              _submitting = false;
              _error = null;
              if (_stage == _Stage.celebrating) _stage = _Stage.setup;
            });
            _showSlotConflictDialog(err);
            return;
          }
        }
      }
      setState(() {
        _submitting = false;
        _error = _extractServerError(e);
        if (_stage == _Stage.celebrating) _stage = _Stage.setup;
      });
    }
  }

  void _showSlotConflictDialog(Map err) {
    final details = (err['details'] is Map) ? err['details'] as Map : const {};
    final opponent = (details['opponentTeamName'] as String?) ?? 'another team';
    final range = (details['conflictRange'] as String?) ?? '';
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.bg,
        title: Text(
          'You\'re already booked',
          style: TextStyle(
            color: ctx.fg,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        content: Text(
          range.isNotEmpty
              ? 'Your team has a match-up $range on this date vs $opponent. Pick another window or open the match-up.'
              : 'Your team already has a match-up on this date vs $opponent.',
          style: TextStyle(color: ctx.fgSub, fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Pick another window',
                style: TextStyle(color: ctx.fg, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  // Surface the actual server reason instead of just "DioException".
  String _extractServerError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        // Backend shape: { error: { code, message, details } }
        if (data['error'] is Map) {
          final err = data['error'] as Map;
          final msg = err['message']?.toString();
          if (msg != null && msg.isNotEmpty) return msg;
        }
        final msg = (data['message'] ?? data['error'])?.toString();
        if (msg != null && msg.isNotEmpty && msg != '{}') return msg;
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
          expired: _hasExpired,
          onSwitchTeam: _switchTeam,
          closest: _closest,
          alternatives: _alternatives,
          alternativeReason: _alternativeReason,
          onModify: _goSetup,
          onRefresh: _runDiscover,
          onCancel: _cancelSearch,
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
        // Team comes from the chip. Format defaults to T20. Ball defaults
        // to null which now means "All ball types" — both are valid out of
        // the box, so the only hard requirement is that a team is picked.
        return widget.team != null;
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

// Smart-window cache. Keyed by (dateApi, sorted arenaIds joined by '|') so the
// same query returns cached results across rebuilds.
typedef _AvailableBucketsKey = ({String date, String arenaKey});
final _availableBucketsProvider = FutureProvider.family
    .autoDispose<Set<DiscoverWindow>, _AvailableBucketsKey>((ref, key) async {
  final repo = ref.read(matchmakingRepositoryProvider);
  final ids = key.arenaKey.isEmpty ? <String>[] : key.arenaKey.split('|');
  final res = await repo.availableBuckets(date: key.date, arenaIds: ids);
  return {
    for (final b in res)
      if (b.arenaCount > 0)
        if (_parseWindow(b.window) != null) _parseWindow(b.window)!,
  };
});

class _WhenStep extends ConsumerWidget {
  const _WhenStep({required this.prefs, required this.onChanged});
  final _Prefs prefs;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch once per (date, arenaIds) combo — refreshes if either changes.
    final sortedIds = [...prefs.preferredArenaIdList]..sort();
    final key = (date: prefs.dateApi, arenaKey: sortedIds.join('|'));
    final availableAsync = ref.watch(_availableBucketsProvider(key));
    // While loading or on error, show all 5 chips (don't punish user for
    // a stale endpoint). Once data arrives, hide buckets with no arenas.
    final available = availableAsync.maybeWhen(
      data: (s) => s,
      orElse: () => DiscoverWindow.values.toSet(),
    );
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
            disabled: w.isPast(prefs.date) || !available.contains(w),
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
    final picks = prefs.preferredArenas;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardGroup(
          children: [
            _SetupRow(
              label: 'PREFERRED GROUNDS',
              value: prefs.preferredArenasLabel,
              placeholder: 'Any nearby',
              icon: Icons.place_rounded,
              tint: context.accent,
              onTap: () async {
                final picked = await _pickArenas(
                  context,
                  ref,
                  prefs.dateApi,
                  prefs.format.apiValue,
                  prefs.preferredArenas,
                );
                if (picked == null) return;
                prefs.preferredArenas = picked;
                onChanged();
              },
            ),
          ],
        ),
        if (picks.isNotEmpty) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in picks)
                  _GroundChip(
                    label: p.name,
                    onRemove: () {
                      prefs.preferredArenas = [
                        for (final x in prefs.preferredArenas)
                          if (x.id != p.id) x,
                      ];
                      onChanged();
                    },
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            picks.isEmpty
                ? 'Leave empty for any nearby ground (most matches). Pick up to 3 grounds you\'d like to play at.'
                : picks.length == 3
                    ? '3 grounds picked — opponents who like any of these will match.'
                    : 'Picked ${picks.length} ground${picks.length == 1 ? '' : 's'}. Tap above to add more (up to 3).',
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

class _GroundChip extends StatelessWidget {
  const _GroundChip({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
      decoration: BoxDecoration(
        color: context.fg.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.fg,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.1,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.close_rounded,
                  size: 14, color: context.fgSub),
            ),
          ),
        ],
      ),
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

// Single expanding ring used by the searching screen. Phase 0..1 → ring grows
// from 0 to its max radius and fades from full opacity to 0.
class _RadarPulse extends StatelessWidget {
  const _RadarPulse({required this.phase, required this.color});
  final double phase;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final size = 96 + 220 * phase;
    final opacity = (1 - phase).clamp(0.0, 1.0) * 0.45;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: opacity), width: 2),
      ),
    );
  }
}

class _DiscoverCelebrate extends StatefulWidget {
  const _DiscoverCelebrate();

  @override
  State<_DiscoverCelebrate> createState() => _DiscoverCelebrateState();
}

class _DiscoverCelebrateState extends State<_DiscoverCelebrate>
    with TickerProviderStateMixin {
  late final AnimationController _entry;     // 0 → 1 over 4.5s, drives lines
  late final AnimationController _radar;     // continuous, drives the rings
  static const _phases = [
    'Posting your match-up…',
    'Looking for grounds…',
    'Analysing slots…',
    'Reading other teams\' availability…',
    'Almost there…',
  ];

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..forward();
    _radar = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _entry.dispose();
    _radar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entry, _radar]),
      builder: (_, __) {
        final t = _entry.value; // 0..1 across 4.5s
        // Phase index — clamp to last phase if API runs longer than theatre.
        final phaseIdx = (t * _phases.length).clamp(0, _phases.length - 1).floor();
        final phaseProgress = (t * _phases.length) - phaseIdx;
        final wash = (t * 4).clamp(0.0, 1.0); // wash fades in across first 25%

        return Stack(
          alignment: Alignment.center,
          children: [
            // Radial wash — atmosphere
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      context.ctaBg.withValues(alpha: 0.18 * wash),
                      context.bg,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),

            // Radar rings — three expanding, repeating
            Positioned.fill(
              child: IgnorePointer(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (int i = 0; i < 3; i++)
                      _RadarPulse(
                        phase: ((_radar.value + i / 3) % 1),
                        color: context.ctaBg,
                      ),
                  ],
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                // Pulsing core
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.ctaBg,
                    boxShadow: [
                      BoxShadow(
                        color: context.ctaBg.withValues(alpha: 0.35),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.radar_rounded,
                    color: context.ctaFg,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 36),
                // Hero label — fixed
                Opacity(
                  opacity: (wash).clamp(0.0, 1.0),
                  child: Text(
                    'Searching',
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Cycling sub-text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, anim) {
                    final slide = Tween<Offset>(
                      begin: const Offset(0, 0.35),
                      end: Offset.zero,
                    ).animate(anim);
                    return FadeTransition(
                      opacity: anim,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: Text(
                    _phases[phaseIdx],
                    key: ValueKey<int>(phaseIdx),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Progress dots
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < _phases.length; i++) ...[
                      Container(
                        width: i == phaseIdx ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i < phaseIdx
                              ? context.ctaBg
                              : i == phaseIdx
                                  ? Color.lerp(
                                      context.stroke.withValues(alpha: 0.5),
                                      context.ctaBg,
                                      phaseProgress,
                                    )
                                  : context.stroke.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      if (i < _phases.length - 1) const SizedBox(width: 6),
                    ],
                  ],
                ),
                ],
              ),
            ),
          ],
        );
      },
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
    required this.expired,
    required this.onSwitchTeam,
    required this.closest,
    required this.alternatives,
    required this.alternativeReason,
    required this.onModify,
    required this.onRefresh,
    required this.onCancel,
    required this.onChallenge,
  });

  final _Prefs prefs;
  final MmTeam? team;
  final List<MmTeam> allTeams;
  final Map<String, MmTeamLobbySummary> teamLobbies;
  final bool expired;
  final ValueChanged<MmTeam> onSwitchTeam;
  final List<MmRankedLobby> closest;
  final List<MmRankedLobby> alternatives;
  final String? alternativeReason;
  final VoidCallback onModify;
  final Future<void> Function({bool skipCelebrate}) onRefresh;
  final VoidCallback onCancel;
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
                _IconPillButton(
                  icon: Icons.tune_rounded,
                  label: 'Modify',
                  onTap: onModify,
                ),
                const SizedBox(width: 8),
                _IconPillButton(
                  icon: Icons.close_rounded,
                  label: 'Cancel',
                  onTap: onCancel,
                  destructive: true,
                ),
              ],
            ),
          ),
        ),
        // Status banner — "Searching" while live, "Expired" once windows pass
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _StatusBanner(expired: expired),
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
                    label: 'EXACT MATCHES',
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
                  const SizedBox(height: 22),
                ] else ...[
                  // No exact matches — make it loud so user understands.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color.alphaBlend(
                          context.warn.withValues(alpha: 0.10),
                          context.bg,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_rounded,
                                  color: context.warn, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'No match available on your preferences',
                                style: TextStyle(
                                  color: context.fg,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            alternatives.isNotEmpty
                                ? 'Showing closest matches below — these are teams whose preferences are near yours.'
                                : 'Your match-up is posted. We\'ll notify you when a team matches.',
                            style: TextStyle(
                              color: context.fgSub,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                if (alternatives.isNotEmpty) ...[
                  _ResultsHeader(
                    label: closest.isEmpty
                        ? 'CLOSEST MATCHES'
                        : 'ALSO AVAILABLE',
                    count: alternatives.length,
                    accent: closest.isEmpty,
                  ),
                  const SizedBox(height: 8),
                  for (final r in alternatives)
                    _LobbyTile(
                      lobby: r.lobby,
                      prominent: closest.isEmpty,
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

class _IconPillButton extends StatelessWidget {
  const _IconPillButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? context.danger : context.fg;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(
            color: destructive
                ? context.danger.withValues(alpha: 0.4)
                : context.stroke.withValues(alpha: 0.6),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Live "we're searching for you" banner with a slow pulsing dot. Flips to
// an "Expired" banner once all selected windows have passed.
class _StatusBanner extends StatefulWidget {
  const _StatusBanner({required this.expired});
  final bool expired;

  @override
  State<_StatusBanner> createState() => _StatusBannerState();
}

class _StatusBannerState extends State<_StatusBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.expired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            context.warn.withValues(alpha: 0.10), context.bg),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule_rounded, color: context.warn, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Search expired — pick another window or cancel',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            context.ctaBg.withValues(alpha: 0.06), context.bg),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: context.ctaBg
                    .withValues(alpha: 0.4 + 0.6 * _pulse.value),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Searching for matches',
              style: TextStyle(
                color: context.fg,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.1,
              ),
            ),
            const Spacer(),
            Text(
              'Live',
              style: TextStyle(
                color: context.ctaBg,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    this.disabled = false,
  });

  final DiscoverWindow window;
  final bool selected;
  final VoidCallback onTap;
  final bool disabled;

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
          icon: Icons.wb_twilight_rounded,
          grad: [
            const Color(0xFFE08A4F),
            const Color(0xFF8E3D5A),
          ],
        ),
      DiscoverWindow.night => (
          icon: Icons.nightlight_round,
          grad: [
            const Color(0xFF6E7CD9),
            const Color(0xFF3D2B6E),
          ],
        ),
      DiscoverWindow.lateNight => (
          icon: Icons.bedtime_rounded,
          grad: [
            const Color(0xFF2B2B5C),
            const Color(0xFF14142B),
          ],
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = _theme(context);
    final iconBg = t.grad[0].withValues(alpha: selected ? 1.0 : 0.18);
    return Opacity(
      opacity: disabled ? 0.45 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onTap,
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
                      Row(
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
                          if (disabled) ...[
                            const SizedBox(width: 8),
                            Text(
                              'PAST',
                              style: TextStyle(
                                color: context.fgSub,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ],
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

  ({String month, String day, String slot}) _dateBits() {
    String month = '';
    String day = '';
    try {
      final d = DateTime.parse(lobby.date);
      const months = [
        '', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
        'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
      ];
      month = months[d.month];
      day = d.day.toString();
    } catch (_) {}
    String slot = '';
    if (lobby.displaySlot.isNotEmpty) {
      // "7:00 AM" → keep AM/PM uppercase
      slot = lobby.displaySlot.toUpperCase();
    } else if (lobby.timeWindow != null) {
      slot = switch (lobby.timeWindow) {
        'MORNING' => 'MORN',
        'AFTERNOON' => 'NOON',
        'EVENING' => 'EVE',
        _ => lobby.timeWindow!,
      };
    }
    return (month: month, day: day, slot: slot);
  }

  @override
  Widget build(BuildContext context) {
    final bits = _dateBits();
    final tileColor = prominent
        ? Color.alphaBlend(context.ctaBg.withValues(alpha: 0.10), context.bg)
        : Color.alphaBlend(context.fg.withValues(alpha: 0.04), context.bg);
    final monthColor = prominent ? context.ctaBg : context.fgSub;
    final dayColor = context.fg;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Date+time hero tile ────────────────────────────────
            Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: prominent
                    ? context.ctaBg
                    : Color.alphaBlend(
                        context.fg.withValues(alpha: 0.08), context.bg),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    bits.month,
                    style: TextStyle(
                      color: prominent ? context.ctaFg : monthColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bits.day,
                    style: TextStyle(
                      color: prominent ? context.ctaFg : dayColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      height: 1.0,
                    ),
                  ),
                  if (bits.slot.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      bits.slot,
                      style: TextStyle(
                        color: prominent
                            ? context.ctaFg.withValues(alpha: 0.85)
                            : context.fgSub,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        height: 1.0,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 14),
            // ── Right side: team / ground / format / price + differs ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                    [
                      lobby.format,
                      if (lobby.arenaName.isNotEmpty)
                        lobby.arenaName
                      else if (lobby.preferredArenaName != null)
                        lobby.preferredArenaName!
                      else
                        'Any ground',
                      '₹${(lobby.pricePerTeamPaise / 100).round()}',
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (differs.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final d in differs)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: context.warn.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'DIFF · ${d.toUpperCase()}',
                              style: TextStyle(
                                color: context.warn,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                color: context.fgSub.withValues(alpha: 0.7), size: 22),
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

// Multi-select picker. Returns the new list (0-3 grounds) or null if user
// dismisses without saving. Empty list = "any nearby ground" (the default).
Future<List<MmArenaPick>?> _pickArenas(
  BuildContext context,
  WidgetRef ref,
  String dateApi,
  String formatApi,
  List<MmArenaPick> initial,
) {
  final query = (
    date: dateApi,
    format: formatApi,
    teamId: null,
    overs: null,
  );
  final selected = <String, String>{
    for (final p in initial) p.id: p.name,
  };
  return showModalBottomSheet<List<MmArenaPick>>(
    context: context,
    backgroundColor: context.bg,
    isScrollControlled: true,
    builder: (sheetCtx) {
      return StatefulBuilder(
        builder: (ctxSB, setSB) {
          return Consumer(
            builder: (consumerCtx, ref, _) {
              final asyncGrounds = ref.watch(mmGroundsProvider(query));
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Choose up to 3 grounds',
                              style: TextStyle(
                                color: context.fg,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                          Text(
                            '${selected.length}/3',
                            style: TextStyle(
                              color: context.fgSub,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                      child: Text(
                        'Empty = any nearby ground (most matches).',
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      color: context.stroke.withValues(alpha: 0.18),
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
                            style: TextStyle(
                                color: context.fgSub, fontSize: 13),
                          ),
                        ),
                        data: (grounds) {
                          final arenas = <String, String>{};
                          for (final g in grounds) {
                            arenas[g.id] = g.name;
                          }
                          final entries = arenas.entries.toList()
                            ..sort((a, b) => a.value.compareTo(b.value));
                          if (entries.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'No grounds for this date.',
                                style: TextStyle(
                                    color: context.fgSub, fontSize: 13),
                              ),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: entries.length,
                            itemBuilder: (_, i) {
                              final e = entries[i];
                              final isSelected = selected.containsKey(e.key);
                              final atCap =
                                  selected.length >= 3 && !isSelected;
                              return GestureDetector(
                                onTap: atCap
                                    ? null
                                    : () {
                                        setSB(() {
                                          if (isSelected) {
                                            selected.remove(e.key);
                                          } else {
                                            selected[e.key] = e.value;
                                          }
                                        });
                                      },
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 14),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.check_box_rounded
                                            : Icons
                                                .check_box_outline_blank_rounded,
                                        size: 22,
                                        color: isSelected
                                            ? context.ctaBg
                                            : (atCap
                                                ? context.fgSub
                                                    .withValues(alpha: 0.4)
                                                : context.fgSub),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          e.value,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: atCap
                                                ? context.fgSub
                                                : context.fg,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      height: 1,
                      color: context.stroke.withValues(alpha: 0.18),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(sheetCtx).pop(),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: context.fgSub,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () => Navigator.of(sheetCtx).pop([
                              for (final entry in selected.entries)
                                (id: entry.key, name: entry.value),
                            ]),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.ctaBg,
                              foregroundColor: context.ctaFg,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 22, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              selected.isEmpty
                                  ? 'Use any nearby'
                                  : 'Save (${selected.length})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

// Old single-select picker (deprecated but kept for any legacy callsites
// that haven't migrated to _pickArenas yet).
// ignore: unused_element
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
