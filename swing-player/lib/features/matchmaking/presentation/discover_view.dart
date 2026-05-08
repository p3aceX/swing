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
import 'package:flutter_host_core/flutter_host_core.dart' show HostArenaRatingBadge;
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
    List<DateTime>? dates,
    List<DiscoverWindow>? windowsRanked,
    List<MmArenaPick>? preferredArenas,
  })  : date = date ?? DateTime.now(),
        dates = dates ?? <DateTime>[date ?? DateTime.now()],
        windowsRanked = windowsRanked ?? <DiscoverWindow>[],
        preferredArenas = preferredArenas ?? <MmArenaPick>[];

  // Team comes from the team-switcher chip on DiscoverView, NOT from prefs.
  MatchFormat format;
  bool allFormats; // true = "All formats" picked; ignore format on search
  String? ballType; // null = "All ball types" picked
  // V2: the wizard supports picking N dates in one go. The legacy [date]
  // singular remains as the "active" date used for headers / results paging
  // and stays in sync with [dates.first] after submission.
  DateTime date;
  List<DateTime> dates;
  // Ordered list of preferred windows (order = rank; first = strongest).
  List<DiscoverWindow> windowsRanked;
  // Up to 3 grounds the team would accept (ordered = rank). Empty = any.
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

  // Wizard completeness: needs at least one date AND at least one window.
  bool get isComplete => windowsRanked.isNotEmpty && dates.isNotEmpty;

  String get dateApi => DateFormat('yyyy-MM-dd').format(date);
  List<String> get datesApi =>
      dates.map((d) => DateFormat('yyyy-MM-dd').format(d)).toList();

  String get formatLabel => allFormats ? 'All formats' : format.label;
  String get ballLabel =>
      ballType == null ? 'All ball types' : _ballLabel(ballType!);

  String get windowsLabel {
    if (windowsRanked.isEmpty) return 'Any time';
    return windowsRanked.map((w) => w.label).join(' · ');
  }

  List<String> get windowsApi =>
      windowsRanked.map((w) => w.apiValue).toList();
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
  List<MmRankedLobby> _primary = [];
  List<MmRankedLobby> _alternatives = [];
  String? _alternativeReason;
  String? _error;
  bool _submitting = false;
  Timer? _expiryTicker;
  // Edit-aware Setup. True when the wizard is opened on top of an existing
  // (team, date, format, ballType) lobby. Drives Submit copy ("Save changes"
  // vs "Find a match") and skips creating a brand new lobby on submit.
  bool _isEditing = false;
  // Multi-date submission: lobby ids returned by each per-date discover call,
  // kept so Results can offer a "switch date" strip across submitted lobbies.
  List<({String date, String lobbyId})> _submittedLobbies =
      const <({String date, String lobbyId})>[];

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
        if (_prefs.windowsRanked.isEmpty) return;
        // Fully-matched lobby: render last-known results without re-hitting
        // /discover. A re-fire would 409 SLOT_CONFLICT and surface as the
        // "you're already booked" dialog every time the tab opens.
        final fullyMatched = active.status == 'matched' ||
            (active.windowsRanked.isNotEmpty &&
                active.windowsMatched.length >= active.windowsRanked.length);
        if (fullyMatched) {
          if (!mounted) return;
          setState(() {
            _activeLobbyId = active.lobbyId;
            _stage = _Stage.results;
          });
          return;
        }
        // Partial match: narrow windowsRanked to the still-unmatched subset
        // so the next /discover doesn't conflict with already-consumed slots.
        if (active.windowsMatched.isNotEmpty) {
          final remaining = _prefs.windowsRanked
              .where((w) => !active.windowsMatched.contains(w.apiValue))
              .toList();
          if (remaining.isEmpty) {
            if (!mounted) return;
            setState(() {
              _activeLobbyId = active.lobbyId;
              _stage = _Stage.results;
            });
            return;
          }
          setState(() => _prefs.windowsRanked = remaining);
        }
        await _runDiscover(skipCelebrate: true, silent: true);
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
    // V2 ranked windows come straight from the lobby. Legacy single-window
    // lobbies fall back to the singular [timeWindow] string.
    final hydratedWindows = <DiscoverWindow>[];
    if (lobby.windowsRanked.isNotEmpty) {
      for (final s in lobby.windowsRanked) {
        final w = _parseWindow(s);
        if (w != null && !hydratedWindows.contains(w)) {
          hydratedWindows.add(w);
        }
      }
    } else {
      final w = _parseWindow(lobby.timeWindow);
      if (w != null) hydratedWindows.add(w);
    }
    setState(() {
      _activeLobbyId = lobby.lobbyId;
      _isEditing = true;
      // Hydrate ranked grounds. The summary doesn't carry arena names, so we
      // use a placeholder that the picker overwrites when re-opened.
      final hydratedArenas = <MmArenaPick>[];
      if (lobby.groundsRanked.isNotEmpty) {
        for (final id in lobby.groundsRanked) {
          if (id.isEmpty) continue;
          hydratedArenas.add((id: id, name: 'Selected ground'));
        }
      } else if (lobby.preferredArenaId != null &&
          lobby.preferredArenaId!.isNotEmpty) {
        hydratedArenas.add((
          id: lobby.preferredArenaId!,
          name: 'Selected ground',
        ));
      }
      final hydratedDate = d ?? _prefs.date;
      _prefs
        ..date = hydratedDate
        ..dates = [hydratedDate]
        ..ballType = lobby.ballType
        ..preferredArenas = hydratedArenas
        ..windowsRanked = hydratedWindows
        ..format = _formatFromApi(lobby.format) ?? _prefs.format
        ..allFormats = lobby.format == 'ANY';
    });
  }

  // Used by the Results page to render an "expired" banner. We deliberately
  // no longer auto-bounce the user back to Intro — that felt like an
  // interrupt. Instead the user sees the banner and chooses Modify or Cancel.
  bool get _hasExpired =>
      _activeLobbyId != null &&
      _isAllWindowsPassed(_prefs.date, _prefs.windowsRanked.toSet());

  void _maybeExpire() {
    // Lightweight tick to nudge a rebuild so the expired banner shows up
    // exactly when the last window passes (without waiting for user input).
    if (_stage != _Stage.results || _activeLobbyId == null) return;
    if (!_isAllWindowsPassed(_prefs.date, _prefs.windowsRanked.toSet())) return;
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
      _primary = [];
      _alternatives = [];
      _alternativeReason = null;
      _isEditing = false;
      _submittedLobbies = const [];
      _stage = _Stage.intro;
    });
    // Tell the rest of the app (My Match-Up tab, lobby lists) to refresh.
    bumpMatchmakingState(ref);
  }

  // True if every selected window has ended on the lobby's date. Empty set
  // (open to any) → never auto-expires from this rule (the lobby's
  // expiresAt on the server handles that).
  bool _isAllWindowsPassed(DateTime date, Set<DiscoverWindow> windows) {
    if (windows.isEmpty) return false;
    // Delegates to DiscoverWindow.isPast, which uses the canonical end
    // minutes (matches backend WINDOW_RANGES).
    return windows.every((w) => w.isPast(date));
  }

  // ── Stage transitions ──────────────────────────────────────────────────────

  void _goSetup() {
    setState(() {
      // Edit-aware Setup: if there's an active lobby for the current team
      // matching (date, format, ballType), the wizard pre-fills from it and
      // the Submit copy reads "Save changes" instead of "Find a match".
      _isEditing = _activeLobbyId != null;
      _stage = _Stage.setup;
    });
  }
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
      _runDiscoverForAllDates(),
      Future<void>.delayed(const Duration(milliseconds: 4500)),
    ]);
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _stage = _Stage.results;
    });
  }

  // Submits one POST /matchmaking/discover per selected date (multi-date
  // wizard support). The first date's response drives the visible Results
  // screen; the rest just kick off lobbies in the background.
  //
  // Multi-date UX simplification (v1): we display the first submitted date's
  // results immediately. The user can re-enter the wizard / use the
  // team-switcher to inspect other submitted dates' lobbies.
  Future<void> _runDiscoverForAllDates() async {
    if (_currentTeam == null) return;
    final dates = List<DateTime>.from(_prefs.dates);
    if (dates.isEmpty) return;
    // First date drives the visible UI.
    final first = dates.first;
    _prefs.date = first;
    final submitted = <({String date, String lobbyId})>[];
    // Sequential — keeps backend log lines in order and avoids burst limits.
    for (var i = 0; i < dates.length; i++) {
      final d = dates[i];
      final isFirst = i == 0;
      final dateApi = DateFormat('yyyy-MM-dd').format(d);
      final ok = await _runDiscoverForDate(
        d,
        recordResponse: isFirst,
      );
      if (!ok) {
        // First-date error already surfaced through _runDiscoverForDate.
        // Continue trying later dates — they may still succeed and the user
        // can switch to them from the Results "other dates" strip.
        continue;
      }
      if (_activeLobbyId != null && isFirst) {
        submitted.add((date: dateApi, lobbyId: _activeLobbyId!));
      } else if (!isFirst && _lastBackgroundLobbyId != null) {
        submitted.add((date: dateApi, lobbyId: _lastBackgroundLobbyId!));
      }
    }
    if (!mounted) return;
    setState(() => _submittedLobbies = submitted);
  }

  // Holds the lobbyId of the most recent background per-date discover call so
  // [_runDiscoverForAllDates] can record it into [_submittedLobbies].
  String? _lastBackgroundLobbyId;

  Future<bool> _runDiscoverForDate(
    DateTime date, {
    required bool recordResponse,
  }) async {
    if (_currentTeam == null) return false;
    final repo = ref.read(matchmakingRepositoryProvider);
    final dateApi = DateFormat('yyyy-MM-dd').format(date);
    try {
      final res = await repo.discoverLobbies(
        teamId: _currentTeam!.id,
        date: dateApi,
        format: _prefs.allFormats ? 'ANY' : _prefs.format.apiValue,
        ballType: _prefs.ballType,
        windowsRanked: _prefs.windowsApi,
        groundsRanked: _prefs.preferredArenaIdList,
      );
      if (!mounted) return false;
      if (recordResponse) {
        setState(() {
          _activeLobbyId = res.yourLobbyId;
          _primary = res.primary;
          _alternatives = res.alternatives;
          _alternativeReason = res.alternativeReason;
          // Refresh team-lobbies map so chip reflects this newly-active lobby.
          _teamLobbies[_currentTeam!.id] = MmTeamLobbySummary(
            lobbyId: res.yourLobbyId,
            teamId: _currentTeam!.id,
            teamName: _currentTeam!.name,
            status: 'searching',
            date: dateApi,
            format: _prefs.allFormats ? 'ANY' : _prefs.format.apiValue,
            ballType: _prefs.ballType,
            windowsRanked: _prefs.windowsApi,
            groundsRanked: _prefs.preferredArenaIdList,
          );
        });
      } else {
        _lastBackgroundLobbyId = res.yourLobbyId;
      }
      return true;
    } catch (e) {
      _log('runDiscoverForDate error ($dateApi): $e');
      if (!mounted) return false;
      // Only surface errors for the first-date (visible) call; background
      // failures stay silent — the user can re-enter the wizard for them.
      if (recordResponse) {
        _handleDiscoverError(e);
      }
      return false;
    }
  }

  // Calls /matchmaking/discover for the currently-selected single date. Used
  // by Results-screen pull-to-refresh and by team-switcher hydration. Multi-
  // date submission goes through [_runDiscoverForAllDates] instead.
  //
  // [silent] swallows mapped error dialogs (SLOT_CONFLICT / TEAM_BANNED /
  // NO_AVAILABLE_SLOT) — used by auto-bootstrap so opening the tab on an
  // already-matched lobby doesn't surface alerts the user didn't ask for.
  Future<void> _runDiscover({
    bool skipCelebrate = false,
    bool silent = false,
  }) async {
    if (_currentTeam == null) return;
    final repo = ref.read(matchmakingRepositoryProvider);
    try {
      final res = await repo.discoverLobbies(
        teamId: _currentTeam!.id,
        date: _prefs.dateApi,
        format: _prefs.allFormats ? 'ANY' : _prefs.format.apiValue,
        ballType: _prefs.ballType,
        windowsRanked: _prefs.windowsApi,
        groundsRanked: _prefs.preferredArenaIdList,
      );
      if (!mounted) return;
      setState(() {
        _activeLobbyId = res.yourLobbyId;
        _primary = res.primary;
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
          windowsRanked: _prefs.windowsApi,
          groundsRanked: _prefs.preferredArenaIdList,
        );
        if (!skipCelebrate && _stage != _Stage.celebrating) {
          _stage = _Stage.results;
        }
      });
    } catch (e) {
      _log('runDiscover error: $e');
      if (!mounted) return;
      if (silent) return;
      _handleDiscoverError(e);
    }
  }

  // Surfaces a discover-flow error to the user. Maps the known backend codes
  // (SLOT_CONFLICT / TEAM_BANNED / NO_AVAILABLE_SLOT) to a friendly dialog
  // or banner; everything else falls back to the raw server message.
  void _handleDiscoverError(Object e) {
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
        if (err['code'] == 'TEAM_BANNED') {
          setState(() {
            _submitting = false;
            _error = null;
            if (_stage == _Stage.celebrating) _stage = _Stage.setup;
          });
          _showTeamBannedDialog(err);
          return;
        }
        if (err['code'] == 'NO_AVAILABLE_SLOT') {
          setState(() {
            _submitting = false;
            _error = (err['message'] as String?) ??
                'No available slot for these grounds. Pick different grounds.';
            if (_stage == _Stage.celebrating) _stage = _Stage.setup;
          });
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

  void _showTeamBannedDialog(Map err) {
    final details = (err['details'] is Map) ? err['details'] as Map : const {};
    String? until;
    final raw = details['banUntil'];
    if (raw is String) {
      try {
        final dt = DateTime.parse(raw).toLocal();
        until = DateFormat('EEE d MMM').format(dt);
      } catch (_) {}
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.bg,
        title: Text(
          'Match-ups paused',
          style: TextStyle(
            color: ctx.fg,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        content: Text(
          until != null
              ? 'Your team is paused from match-ups until $until due to recent cancellations. Try again after the cooldown.'
              : 'Your team is paused from match-ups due to recent cancellations. Try again after the cooldown.',
          style: TextStyle(color: ctx.fgSub, fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK',
                style: TextStyle(color: ctx.fg, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
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
      _primary = [];
      _alternatives = [];
      _alternativeReason = null;
      _isEditing = false;
      _submittedLobbies = const [];
    });
    final active = _teamLobbies[team.id];
    if (active != null) {
      _hydratePrefsFromLobby(active);
      if (_prefs.windowsRanked.isEmpty) {
        setState(() => _stage = _Stage.results);
        return;
      }
      // Skip /discover for already-matched lobbies — same reason as bootstrap.
      final fullyMatched = active.status == 'matched' ||
          (active.windowsRanked.isNotEmpty &&
              active.windowsMatched.length >= active.windowsRanked.length);
      if (fullyMatched) {
        setState(() {
          _activeLobbyId = active.lobbyId;
          _stage = _Stage.results;
        });
        return;
      }
      if (active.windowsMatched.isNotEmpty) {
        final remaining = _prefs.windowsRanked
            .where((w) => !active.windowsMatched.contains(w.apiValue))
            .toList();
        if (remaining.isEmpty) {
          setState(() {
            _activeLobbyId = active.lobbyId;
            _stage = _Stage.results;
          });
          return;
        }
        setState(() => _prefs.windowsRanked = remaining);
      }
      await _runDiscover(skipCelebrate: true, silent: true);
      if (!mounted) return;
      setState(() => _stage = _Stage.results);
    } else {
      setState(() => _stage = _Stage.intro);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // External signal that some matchmaking-state-changed event happened
    // outside this view (cancel from My Match-Up tab, payment confirmation,
    // etc.). Re-run bootstrap so we pick up the now-canonical lobby state.
    ref.listen<int>(mmRefreshTickProvider, (prev, next) {
      if (prev == next) return;
      _bootstrap();
    });
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
          isEditing: _isEditing,
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
          primary: _primary,
          alternatives: _alternatives,
          alternativeReason: _alternativeReason,
          submittedLobbies: _submittedLobbies,
          onModify: _goSetup,
          onRefresh: _runDiscover,
          onCancel: _cancelSearch,
          onChallenge: (lobby) => widget.onChallenge(lobby, _currentTeam),
          onSwitchDate: (newDateApi) async {
            // Move active results to the picked date and re-run discover.
            DateTime? d;
            try {
              d = DateTime.parse(newDateApi);
            } catch (_) {}
            if (d == null) return;
            setState(() {
              _prefs.date = d!;
              if (_prefs.dates.isNotEmpty &&
                  !_prefs.dates.any(
                      (x) => x.toIso8601String().startsWith(newDateApi))) {
                _prefs.dates = [..._prefs.dates, d!];
              }
              // Clear current results while the new date loads.
              _primary = const [];
              _alternatives = const [];
            });
            await _runDiscover(skipCelebrate: true);
          },
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
    required this.isEditing,
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
  // True when the wizard is editing an existing lobby. Drives Submit copy.
  final bool isEditing;
  final VoidCallback onChanged;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  ConsumerState<_DiscoverSetup> createState() => _DiscoverSetupState();
}

class _DiscoverSetupState extends ConsumerState<_DiscoverSetup> {
  // V2 step order: Match-type → Where (grounds) → Dates → Windows.
  // Picking grounds first lets the smart-window scanner filter chips by the
  // user's chosen grounds × dates instead of guessing.
  // 0 = Match details (format + ball type)
  // 1 = Where (ranked grounds, 0–3)
  // 2 = Dates (multi-select, today..+14d)
  // 3 = Windows (ranked, 5 buckets)
  int _step = 0;

  static const _stepLabels = ['Match details', 'Where', 'Dates', 'Windows'];

  bool _stepReady() {
    switch (_step) {
      case 0:
        // Team comes from the chip. Format defaults to T20. Ball defaults
        // to null which now means "All ball types" — both are valid out of
        // the box, so the only hard requirement is that a team is picked.
        return widget.team != null;
      case 1:
        return true; // grounds are optional
      case 2:
        return widget.prefs.dates.isNotEmpty;
      case 3:
        return widget.prefs.windowsRanked.isNotEmpty;
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
              1 => _WhereStep(
                  prefs: p,
                  onChanged: () => setState(() {}),
                  ref: ref,
                ),
              2 => _WhenDatesStep(
                  prefs: p,
                  onChanged: () => setState(() {}),
                ),
              _ => _WhenWindowsStep(
                  prefs: p,
                  onChanged: () => setState(() {}),
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
                              ? (widget.isEditing
                                  ? 'Save changes'
                                  : 'Find a match')
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
                              ? (widget.isEditing
                                  ? Icons.check_rounded
                                  : Icons.search_rounded)
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

// Smart-window cache. Keyed by (dateApi, sorted arenaIds joined by '|', format)
// so the cache busts when any input changes — including format, since duration
// (T20 = 4hr vs ODI = 8hr) determines whether a bucket can host a viable slot.
typedef _AvailableBucketsKey = ({
  String date,
  String arenaKey,
  String format,
});
final _availableBucketsProvider = FutureProvider.family
    .autoDispose<Set<DiscoverWindow>, _AvailableBucketsKey>((ref, key) async {
  final repo = ref.read(matchmakingRepositoryProvider);
  final ids = key.arenaKey.isEmpty ? <String>[] : key.arenaKey.split('|');
  final res = await repo.availableBuckets(
    date: key.date,
    arenaIds: ids,
    format: key.format,
  );
  return {
    for (final b in res)
      if (b.arenaCount > 0)
        if (_parseWindow(b.window) != null) _parseWindow(b.window)!,
  };
});

// Multi-date picker — chip strip for the next 14 days. Multi-select.
// At least one date required to advance the wizard.
class _WhenDatesStep extends StatelessWidget {
  const _WhenDatesStep({required this.prefs, required this.onChanged});
  final _Prefs prefs;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
          child: Row(
            children: [
              Text(
                'PICK THE DATES YOU WANT TO PLAY',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'next 14 days',
                style: TextStyle(
                  color: context.fgSub.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            prefs.dates.isEmpty
                ? 'Tap one or more dates. We\'ll find a match-up on each.'
                : '${prefs.dates.length} date${prefs.dates.length == 1 ? '' : 's'} picked.',
            style: TextStyle(
              color: prefs.dates.isEmpty ? context.fgSub : context.fg,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: _MultiDateStrip(
            selected: prefs.dates,
            onToggle: (d) {
              final idx = prefs.dates
                  .indexWhere((x) => DateUtils.isSameDay(x, d));
              if (idx >= 0) {
                prefs.dates.removeAt(idx);
              } else {
                prefs.dates.add(d);
              }
              // Keep dates sorted ascending so submission order is predictable.
              prefs.dates.sort((a, b) => a.compareTo(b));
              // Mirror the first selected date into singular [date] field so
              // legacy result headers stay accurate.
              if (prefs.dates.isNotEmpty) {
                prefs.date = prefs.dates.first;
              }
              onChanged();
            },
          ),
        ),
      ],
    );
  }
}

// Ranked windows picker. Tap order = preference; first tap = rank-1. Re-tap
// removes and renumbers. Past windows + no-arena windows are disabled. The
// scanner is scoped to (dates × groundsRanked) — picks the union of all
// selected dates' available windows.
class _WhenWindowsStep extends ConsumerWidget {
  const _WhenWindowsStep({required this.prefs, required this.onChanged});
  final _Prefs prefs;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For each selected date, run the smart-window scanner with the chosen
    // grounds. A window is enabled if it's available on at least one of the
    // selected dates. Falls back to all 5 buckets while loading.
    final sortedIds = [...prefs.preferredArenaIdList]..sort();
    final arenaKey = sortedIds.join('|');
    final dates = prefs.dates.isEmpty ? [prefs.date] : prefs.dates;
    final available = <DiscoverWindow>{};
    var anyData = false;
    for (final d in dates) {
      final dateApi = DateFormat('yyyy-MM-dd').format(d);
      final res = ref
          .watch(_availableBucketsProvider((
        date: dateApi,
        arenaKey: arenaKey,
        format: prefs.format.apiValue,
      )));
      res.whenData((s) {
        anyData = true;
        available.addAll(s);
      });
    }
    final effectiveAvailable =
        anyData ? available : DiscoverWindow.values.toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
          child: Row(
            children: [
              Text(
                'PICK YOUR TIME WINDOWS IN ORDER',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'first is most preferred',
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
          Builder(builder: (ctx) {
            final rankIdx = prefs.windowsRanked.indexOf(w);
            final isSelected = rankIdx >= 0;
            // Past on ALL selected dates → disabled.
            final pastOnAll = dates.every((d) => w.isPast(d));
            return _WindowCard(
              window: w,
              selected: isSelected,
              rank: isSelected ? rankIdx + 1 : null,
              disabled: pastOnAll || !effectiveAvailable.contains(w),
              onTap: () {
                if (isSelected) {
                  prefs.windowsRanked.removeAt(rankIdx);
                } else {
                  prefs.windowsRanked.add(w);
                }
                onChanged();
              },
            );
          }),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

// Multi-select chip strip. Same visual as [_DateStripSimple] but supports
// many selected dates with an order-agnostic toggle.
class _MultiDateStrip extends StatelessWidget {
  const _MultiDateStrip({required this.selected, required this.onToggle});
  final List<DateTime> selected;
  final ValueChanged<DateTime> onToggle;

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
          final sel =
              selected.any((x) => DateUtils.isSameDay(x, d));
          return GestureDetector(
            onTap: () => onToggle(d),
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
                    i == 0
                        ? 'TODAY'
                        : DateFormat('EEE').format(d).toUpperCase(),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
          child: Text(
            'PICK UP TO 3 GROUNDS — ORDER MATTERS, FIRST IS MOST PREFERRED',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
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
                for (var i = 0; i < picks.length; i++)
                  _GroundChip(
                    label: picks[i].name,
                    rank: i + 1,
                    onRemove: () {
                      prefs.preferredArenas = [
                        for (final x in prefs.preferredArenas)
                          if (x.id != picks[i].id) x,
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
                ? 'Leave empty for any nearby ground (most matches). Pick up to 3 grounds you\'d like to play at — order matters.'
                : picks.length == 3
                    ? '3 grounds picked — opponents who like any of these will match. First = most preferred.'
                    : 'Picked ${picks.length} ground${picks.length == 1 ? '' : 's'}. Tap above to add more (up to 3). First = most preferred.',
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
  const _GroundChip({
    required this.label,
    required this.onRemove,
    this.rank,
  });
  final String label;
  final VoidCallback onRemove;
  // 1-based rank badge ("1", "2", "3"). When null, no badge is rendered.
  final int? rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
      decoration: BoxDecoration(
        color: context.fg.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (rank != null) ...[
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: context.ctaBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$rank',
                style: TextStyle(
                  color: context.ctaFg,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ] else
            const SizedBox(width: 4),
          // Bound the label width so a long ground name doesn't push the
          // chip past the Wrap's row. Flexible inside Row(mainAxisSize.min)
          // is a Flutter layout footgun (it has no leftover space to flex
          // into) and triggers the "RenderBox was not laid out" cascade —
          // ConstrainedBox + plain Text + ellipsis is the safe pattern.
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
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
    required this.primary,
    required this.alternatives,
    required this.alternativeReason,
    required this.submittedLobbies,
    required this.onModify,
    required this.onRefresh,
    required this.onCancel,
    required this.onChallenge,
    required this.onSwitchDate,
  });

  final _Prefs prefs;
  final MmTeam? team;
  final List<MmTeam> allTeams;
  final Map<String, MmTeamLobbySummary> teamLobbies;
  final bool expired;
  final ValueChanged<MmTeam> onSwitchTeam;
  // V2 wire shape: lobbies whose rank-1 window+ground both intersect the
  // caller's. Backend field name: `primary`.
  final List<MmRankedLobby> primary;
  final List<MmRankedLobby> alternatives;
  final String? alternativeReason;
  // Lobby ids submitted via multi-date wizard, in date order. Drives the
  // "Other dates" strip at the top of Results.
  final List<({String date, String lobbyId})> submittedLobbies;
  final VoidCallback onModify;
  final Future<void> Function({bool skipCelebrate}) onRefresh;
  final VoidCallback onCancel;
  final ValueChanged<MmOpenLobby> onChallenge;
  // Tap a date in the submitted-dates strip → switch active results to
  // that date. Caller flips _prefs.date and re-runs discover.
  final ValueChanged<String> onSwitchDate;

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
        // Date strip — only dates the user submitted (multi-date) or the
        // active date if there was no multi-date submission. Active is
        // highlighted; tap = re-run discover for that date.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _MatchDateStrip(
            submitted: submittedLobbies,
            activeDateApi: prefs.dateApi,
            onSelect: onSwitchDate,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => onRefresh(skipCelebrate: true),
            child: _MatchTimeline(
              prefs: prefs,
              primary: primary,
              alternatives: alternatives,
              alternativeReason: alternativeReason,
              onChallenge: onChallenge,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Calendar-timeline (Discover Results) ──────────────────────────────────

// Horizontal date chips spanning 14 days from today.
//   • Active (the date currently rendered in the timeline) → gold fill.
//   • Has matches (date the user searched, i.e. in submittedLobbies) →
//     light-blue fill (sky tint). Tap to switch the timeline to that date.
//   • No matches yet → white fill with a subtle border. Tap = run a fresh
//     discover for that date so the user can extend the search range.
class _MatchDateStrip extends StatelessWidget {
  const _MatchDateStrip({
    required this.submitted,
    required this.activeDateApi,
    required this.onSelect,
  });

  final List<({String date, String lobbyId})> submitted;
  final String activeDateApi;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    // 14-day forward strip — covers the lobby-expiry window. The active
    // date may be in the past during dev / fixture data; ensure it's
    // surfaced regardless.
    final range = <String>{
      for (var i = 0; i < 14; i++)
        DateFormat('yyyy-MM-dd').format(start.add(Duration(days: i))),
      activeDateApi,
      for (final s in submitted) s.date,
    }.toList()..sort();
    if (range.isEmpty) return const SizedBox.shrink();
    final submittedDates = {for (final s in submitted) s.date};
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: range.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final api = range[i];
          DateTime? d;
          try { d = DateTime.parse(api); } catch (_) {}
          if (d == null) return const SizedBox.shrink();
          final isActive = api == activeDateApi;
          final hasMatches = submittedDates.contains(api) || api == activeDateApi;
          // Color rule (per the user's design call):
          //   active        → gold
          //   has matches   → light blue (sky)
          //   no matches    → white with a faint border
          final bgColor = isActive
              ? context.gold
              : hasMatches
                  ? context.sky.withValues(alpha: 0.18)
                  : context.bg;
          final borderColor = isActive
              ? Colors.transparent
              : hasMatches
                  ? context.sky.withValues(alpha: 0.45)
                  : context.fg.withValues(alpha: 0.10);
          final fgColor = isActive
              ? Colors.black
              : hasMatches
                  ? context.sky
                  : context.fg;
          final fgSubColor = isActive
              ? Colors.black54
              : hasMatches
                  ? context.sky.withValues(alpha: 0.75)
                  : context.fgSub;
          const monthNames = ['', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
              'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
          const dowNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          return GestureDetector(
            onTap: isActive ? null : () => onSelect(api),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    monthNames[d.month],
                    style: TextStyle(
                      color: fgSubColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      color: fgColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dowNames[d.weekday],
                    style: TextStyle(
                      color: fgSubColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
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

// Vertical timeline. Hour gutter on the left; each match renders inline at
// its slot hour. Empty hours are collapsed (we don't render rows of
// nothingness — the date strip already tells the user which date they're
// looking at).
class _MatchTimeline extends StatelessWidget {
  const _MatchTimeline({
    required this.prefs,
    required this.primary,
    required this.alternatives,
    required this.alternativeReason,
    required this.onChallenge,
  });

  final _Prefs prefs;
  final List<MmRankedLobby> primary;
  final List<MmRankedLobby> alternatives;
  final String? alternativeReason;
  final ValueChanged<MmOpenLobby> onChallenge;

  // Pulls a starting hour for the timeline placement. Uses the lobby's
  // concrete slotTime when present (arena listings + locked picks); falls
  // back to the bucket-start of windowsRanked[0] for pure-preference lobbies.
  static int _hourOf(MmOpenLobby lobby) {
    if (lobby.slotTime.isNotEmpty) {
      final h = int.tryParse(lobby.slotTime.split(':').first);
      if (h != null) return h;
    }
    if (lobby.windowsRanked.isNotEmpty) {
      return switch (lobby.windowsRanked.first) {
        'MORNING' => 7,
        'AFTERNOON' => 12,
        'EVENING' => 17,
        'NIGHT' => 21,
        'LATE_NIGHT' => 0,
        _ => 9,
      };
    }
    return 9;
  }

  static String _hourLabel(int h) {
    final ampm = h < 12 ? 'AM' : 'PM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12 $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final entries = <({MmRankedLobby ranked, bool isPrimary, int hour})>[
      for (final r in primary)
        (ranked: r, isPrimary: true, hour: _hourOf(r.lobby)),
      for (final r in alternatives)
        (ranked: r, isPrimary: false, hour: _hourOf(r.lobby)),
    ]..sort((a, b) => a.hour.compareTo(b.hour));

    if (entries.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Container(
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
                Row(children: [
                  Icon(Icons.info_rounded, color: context.warn, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'No matches on this date yet',
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                ]),
                const SizedBox(height: 6),
                Text(
                  alternativeReason == 'no_exact_matches'
                      ? "Your match-up is posted. We'll notify you when a team matches."
                      : "Your match-up is searching. Switch dates above or modify preferences.",
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
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final e = entries[i];
        return _TimelineRow(
          hourLabel: _hourLabel(e.hour),
          isPrimary: e.isPrimary,
          ranked: e.ranked,
          callerWindowsRanked: prefs.windowsApi,
          callerGroundsRanked: prefs.preferredArenaIdList,
          onTap: () => onChallenge(e.ranked.lobby),
        );
      },
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.hourLabel,
    required this.isPrimary,
    required this.ranked,
    required this.callerWindowsRanked,
    required this.callerGroundsRanked,
    required this.onTap,
  });

  final String hourLabel;
  final bool isPrimary;
  final MmRankedLobby ranked;
  final List<String> callerWindowsRanked;
  final List<String> callerGroundsRanked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hour gutter: tiny right-aligned label + a dash beneath it.
          SizedBox(
            width: 56,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hourLabel,
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 1,
                    width: 14,
                    color: context.fgSub.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TimelineCard(
              isPrimary: isPrimary,
              ranked: ranked,
              callerWindowsRanked: callerWindowsRanked,
              callerGroundsRanked: callerGroundsRanked,
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.isPrimary,
    required this.ranked,
    required this.callerWindowsRanked,
    required this.callerGroundsRanked,
    required this.onTap,
  });

  final bool isPrimary;
  final MmRankedLobby ranked;
  final List<String> callerWindowsRanked;
  final List<String> callerGroundsRanked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lobby = ranked.lobby;
    // Primary cards: solid filled (the "team meeting" look from the
    // reference). Alternative cards: striped surface.
    final cardBg = isPrimary
        ? context.ctaBg
        : Color.alphaBlend(context.fg.withValues(alpha: 0.05), context.bg);
    final fg = isPrimary ? context.ctaFg : context.fg;
    final fgSub = isPrimary ? context.ctaFg.withValues(alpha: 0.75) : context.fgSub;
    final caveat = _differsLabel(ranked.differs);
    final groundLine = lobby.arenaName.isNotEmpty
        ? lobby.arenaName
        : (lobby.preferredArenaName ?? 'Any ground');
    final priceLine =
        '${lobby.isTentativePricing ? "≈ " : ""}₹${(lobby.pricePerTeamPaise / 100).round()}';

    final inner = Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  lobby.teamName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (lobby.matchRatingCount != null)
                _RatingPill(
                  isPrimary: isPrimary,
                  average: lobby.matchRatingAvg,
                  count: lobby.matchRatingCount,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            lobby.slotLabel ?? lobby.displaySlot,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fg,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${lobby.format} · $groundLine · $priceLine',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fgSub,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (caveat != null) ...[
            const SizedBox(height: 6),
            Text(
              caveat,
              style: TextStyle(
                color: isPrimary ? context.ctaFg.withValues(alpha: 0.85) : context.warn,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ],
      ),
    );

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: isPrimary
              ? null
              : Border.all(
                  color: context.fg.withValues(alpha: 0.10),
                  width: 1,
                ),
        ),
        child: isPrimary
            ? inner
            : CustomPaint(
                painter: _DiagonalStripePainter(
                  color: context.fg.withValues(alpha: 0.04),
                ),
                child: inner,
              ),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({
    required this.isPrimary,
    required this.average,
    required this.count,
  });
  final bool isPrimary;
  final double? average;
  final int? count;

  @override
  Widget build(BuildContext context) {
    if (count == null || count! < 3) {
      // Mirrors HostArenaRatingBadge's "NEW GROUND" treatment but tightened
      // for the timeline card header.
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: (isPrimary ? context.ctaFg : context.sky).withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'NEW',
          style: TextStyle(
            color: isPrimary ? context.ctaFg : context.sky,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
      );
    }
    final avg = (average ?? 0).clamp(0, 5);
    final fg = isPrimary ? context.ctaFg : context.fg;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: 13, color: isPrimary ? context.gold : context.gold),
        const SizedBox(width: 2),
        Text(
          avg.toStringAsFixed(1),
          style: TextStyle(
            color: fg,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DiagonalStripePainter extends CustomPainter {
  _DiagonalStripePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    const spacing = 10.0;
    // Diagonal lines from bottom-left toward top-right.
    final start = -size.height;
    for (var x = start; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DiagonalStripePainter old) => old.color != color;
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

// Strip listing every date the user submitted via the multi-date wizard.
// Highlights the active date; tap any other to switch results to that date.
class _OtherDatesStrip extends StatelessWidget {
  const _OtherDatesStrip({
    required this.submitted,
    required this.activeDateApi,
    required this.onSelect,
  });
  final List<({String date, String lobbyId})> submitted;
  final String activeDateApi;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: submitted.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final s = submitted[i];
          final active = s.date == activeDateApi;
          DateTime? dt;
          try {
            dt = DateTime.parse(s.date);
          } catch (_) {}
          final label = dt != null ? _dateLabel(dt) : s.date;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: active ? null : () => onSelect(s.date),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? context.ctaBg
                    : Color.alphaBlend(
                        context.fg.withValues(alpha: 0.06),
                        context.bg,
                      ),
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: active ? context.ctaFg : context.fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          );
        },
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

// Maps the backend's semantic differs[] tags to a single user-facing caveat
// line. Returns null when there's nothing to flag (primary match — clean).
//
// Tag set from backend scoreRankedCandidate:
//   ground_other / ground_rank_2 / ground_rank_3
//   window_other / window_rank_2 / window_rank_3
//   date_other (alternatives across dates)
String? _differsLabel(List<String> differs) {
  if (differs.isEmpty) return null;
  final hasGround = differs.any((d) => d.startsWith('ground_'));
  final hasWindow = differs.any((d) => d.startsWith('window_'));
  final hasDate = differs.any((d) => d.startsWith('date_'));
  if (hasGround && hasWindow) return 'Match found — different ground & time';
  if (hasGround) return 'Match found — different ground';
  if (hasWindow) return 'Match found — different time horizon';
  if (hasDate) return 'Match found — different date';
  return null;
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
    this.rank,
  });

  final DiscoverWindow window;
  final bool selected;
  final VoidCallback onTap;
  final bool disabled;
  // 1-based rank for the numbered badge on selected chips. Null when the
  // chip is unselected or rendered without a rank (legacy callers).
  final int? rank;

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
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: t.grad,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: rank != null
                        ? Text(
                            '$rank',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          )
                        : const Icon(Icons.check_rounded,
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

// Single-select date strip. No longer used by the V2 multi-date Setup wizard
// (replaced by [_MultiDateStrip]); retained in case any modal flow still
// needs a single-date picker. Kept private — analyzer may flag it as unused.
// ignore: unused_element
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
    this.callerWindowsRanked = const [],
    this.callerGroundsRanked = const [],
  });
  final MmOpenLobby lobby;
  final bool prominent;
  final VoidCallback onTap;
  final double? score;
  final List<String> matchedOn;
  final List<String> differs;
  // Caller's ranked preferences. Used to derive the matched window/ground
  // when the response doesn't include explicit fields.
  final List<String> callerWindowsRanked;
  final List<String> callerGroundsRanked;

  // The window where matching actually happened. Reads `matchedOn` first, and
  // if absent falls back to the first overlap of caller/lobby ranked windows.
  String? get _matchedWindow {
    const windowKeys = {
      'MORNING',
      'AFTERNOON',
      'EVENING',
      'NIGHT',
      'LATE_NIGHT',
    };
    // matchedOn might be ['date', 'window:MORNING', 'ground:foo'] — try the
    // 'window:' prefix shape first.
    for (final m in matchedOn) {
      if (m.startsWith('window:')) {
        return m.substring(7);
      }
      if (windowKeys.contains(m)) return m;
    }
    // Fallback: first window present in BOTH ranked arrays.
    for (final w in callerWindowsRanked) {
      if (lobby.windowsRanked.contains(w)) return w;
    }
    return null;
  }

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
    } else {
      // Prefer the actually-matched window over the lobby's legacy single-
      // window field. matchedOn is the source of truth for what the backend
      // matched on; falling back to overlap is a v2-shape best-effort.
      final win = _matchedWindow ?? lobby.timeWindow;
      if (win != null) {
        slot = switch (win) {
          'MORNING' => 'MORN',
          'AFTERNOON' => 'NOON',
          'EVENING' => 'EVE',
          'NIGHT' => 'NIGHT',
          'LATE_NIGHT' => 'L.NITE',
          _ => win,
        };
      }
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
                      // Prefix with "≈" when the backend marked the price
                      // as tentative — pairing has no locked ground yet,
                      // so price is sourced from the would-be allocation.
                      '${lobby.isTentativePricing ? "≈ " : ""}₹${(lobby.pricePerTeamPaise / 100).round()}',
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (lobby.slotLabel != null && lobby.slotLabel!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      lobby.slotLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                  if (lobby.matchRatingCount != null) ...[
                    const SizedBox(height: 4),
                    HostArenaRatingBadge(
                      average: lobby.matchRatingAvg,
                      count: lobby.matchRatingCount,
                    ),
                  ],
                  if (_differsLabel(differs) != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _differsLabel(differs)!,
                      style: TextStyle(
                        color: context.warn,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                      ),
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

// Multi-select picker with RANKED tap order. Tapping an unselected ground
// appends it to the list; the visible numbered badge ("1"/"2"/"3") reflects
// position. Re-tapping a selected ground removes it AND re-numbers the rest.
// Returns the new list (0-3 grounds) or null if user dismisses without
// saving. Empty list = "any nearby ground" (the default).
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
  // LinkedHashMap-style insertion order is preserved by Dart's default Map.
  // We rely on that to keep the rank order across rebuilds inside the sheet.
  final selected = <String, String>{
    for (final p in initial) p.id: p.name,
  };
  return showModalBottomSheet<List<MmArenaPick>>(
    context: context,
    backgroundColor: context.bg,
    isScrollControlled: true,
    builder: (sheetCtx) {
      // With isScrollControlled, the modal sheet does NOT bound the
      // body's width/height — the body has to do that itself. SizedBox
      // pins the width to the screen so the Row/Spacer at the bottom
      // (Cancel + Save buttons) gets a finite max-width to flex against.
      // ConstrainedBox(maxHeight:…) gives the Flexible/ListView a finite
      // vertical space to occupy.
      final size = MediaQuery.of(sheetCtx).size;
      final maxHeight = size.height * 0.85;
      return StatefulBuilder(
        builder: (ctxSB, setSB) {
          return Consumer(
            builder: (consumerCtx, ref, _) {
              final asyncGrounds = ref.watch(mmGroundsProvider(query));
              return SafeArea(
                child: SizedBox(
                  width: size.width,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxHeight),
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
                              // Rank = 1-based position in the insertion-order
                              // map. Re-tap removes & the next render renumbers.
                              final rank = isSelected
                                  ? selected.keys.toList().indexOf(e.key) + 1
                                  : null;
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
                                      // Numbered badge for selected; empty
                                      // square for unselected. Reflects rank.
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? context.ctaBg
                                              : Colors.transparent,
                                          shape: BoxShape.circle,
                                          border: isSelected
                                              ? null
                                              : Border.all(
                                                  color: (atCap
                                                          ? context.fgSub
                                                              .withValues(
                                                                  alpha: 0.4)
                                                          : context.fgSub)
                                                      .withValues(alpha: 0.6),
                                                  width: 1.4,
                                                ),
                                        ),
                                        alignment: Alignment.center,
                                        child: isSelected
                                            ? Text(
                                                '$rank',
                                                style: TextStyle(
                                                  color: context.ctaFg,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w900,
                                                  height: 1,
                                                ),
                                              )
                                            : null,
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
                      // Custom button row built from GestureDetector +
                      // Container instead of Material's TextButton /
                      // ElevatedButton + Spacer. The Material buttons pass
                      // `BoxConstraints(w=Infinity)` to their inner shape
                      // when their parent Row has unbounded main-axis (which
                      // is the default Row behaviour for non-flex children),
                      // triggering "BoxConstraints forces an infinite width".
                      // GestureDetector + Container has no such surprise.
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => Navigator.of(sheetCtx).pop(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: context.fgSub,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => Navigator.of(sheetCtx).pop([
                              for (final entry in selected.entries)
                                (id: entry.key, name: entry.value),
                            ]),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 22, vertical: 12),
                              decoration: BoxDecoration(
                                color: context.ctaBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                selected.isEmpty
                                    ? 'Use any nearby'
                                    : 'Save (${selected.length})',
                                style: TextStyle(
                                  color: context.ctaFg,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
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
