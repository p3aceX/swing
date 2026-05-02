import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/matchmaking_models.dart';
import 'matchmaking_page.dart' show MatchFormat;
import 'matchmaking_providers.dart';

// ── Format helpers ────────────────────────────────────────────────────────────

extension _FormatApi on MatchFormat {
  String get apiValue => switch (this) {
        MatchFormat.t10 => 'T10',
        MatchFormat.t20 => 'T20',
        MatchFormat.thirtyOver => '30-over',
        MatchFormat.boxCricket => 'Box',
      };
}

// ── Challenge team search model ───────────────────────────────────────────────

class _ChallengeTeam {
  const _ChallengeTeam({
    required this.id,
    required this.name,
    this.city,
    this.teamType,
    this.memberCount = 0,
  });

  final String id;
  final String name;
  final String? city;
  final String? teamType;
  final int memberCount;

  String get typeLabel {
    final t = (teamType ?? '').toUpperCase();
    return switch (true) {
      _ when t.contains('CORP') => 'Corporate',
      _ when t.contains('ACAD') => 'Academy',
      _ when t.contains('CLUB') => 'Club',
      _ when t.contains('SCHOOL') => 'School',
      _ when t.contains('COLLEGE') => 'College',
      _ when t.contains('GULLY') => 'Gully',
      _ => 'Open',
    };
  }

  factory _ChallengeTeam.fromJson(Map<String, dynamic> j) => _ChallengeTeam(
        id: j['id'] as String,
        name: (j['name'] as String?) ?? 'Team',
        city: j['city'] as String?,
        teamType: j['teamType'] as String?,
        memberCount: (j['memberCount'] as num?)?.toInt() ?? 0,
      );
}

// ── Lobby state ───────────────────────────────────────────────────────────────

enum _LobbyState { idle, entering, searching, matched, confirming }

// ── Tab page ──────────────────────────────────────────────────────────────────

class MatchmakingTabPage extends ConsumerStatefulWidget {
  const MatchmakingTabPage({super.key, this.onFindMatch});
  final VoidCallback? onFindMatch;

  @override
  ConsumerState<MatchmakingTabPage> createState() =>
      _MatchmakingTabPageState();
}

class _MatchmakingTabPageState extends ConsumerState<MatchmakingTabPage> {
  int _tab = 0; // 0=Open  1=Find  2=Challenge

  // Find tab state
  _LobbyState _lobbyState = _LobbyState.idle;
  MmTeam? _team;
  MatchFormat _format = MatchFormat.t20;
  DateTime _date = DateTime.now();
  List<MmGroundSlotPick> _picks = [];

  // Active lobby
  String? _lobbyId;
  MmMatchSummary? _matchSummary;
  String? _error;
  Timer? _pollTimer;

  bool get _isActive =>
      _lobbyState != _LobbyState.idle && _lobbyState != _LobbyState.entering;

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_date);

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // ── Lobby lifecycle ────────────────────────────────────────────────────────

  Future<void> _enterLobby() async {
    if (_picks.isEmpty || _team == null) return;
    setState(() {
      _lobbyState = _LobbyState.entering;
      _error = null;
    });
    try {
      final repo = ref.read(matchmakingRepositoryProvider);
      final result = await repo.createLobby(
        teamId: _team!.id,
        format: _format.apiValue,
        date: _dateStr,
        picks: _picks
            .map((p) => (groundId: p.slot.unitId, slotTime: p.slot.time))
            .toList(),
      );
      setState(() {
        _lobbyId = result.lobbyId;
        if (result.status == 'matched' && result.match != null) {
          _matchSummary = result.match;
          _lobbyState = _LobbyState.matched;
        } else {
          _lobbyState = _LobbyState.searching;
          _startPolling();
        }
      });
    } catch (e) {
      setState(() {
        _lobbyState = _LobbyState.idle;
        _error = _parseError(e);
      });
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
  }

  Future<void> _poll() async {
    final id = _lobbyId;
    if (id == null) return;
    try {
      final repo = ref.read(matchmakingRepositoryProvider);
      final status = await repo.getLobbyStatus(id);
      if (!mounted) return;
      if (status.status == 'matched' && status.match != null) {
        _pollTimer?.cancel();
        setState(() {
          _matchSummary = status.match;
          _lobbyState = _LobbyState.matched;
        });
      } else if (status.status == 'expired' || status.status == 'cancelled') {
        _pollTimer?.cancel();
        setState(() => _lobbyState = _LobbyState.idle);
      }
    } catch (_) {}
  }

  Future<void> _leaveLobby() async {
    _pollTimer?.cancel();
    final id = _lobbyId;
    if (id != null) {
      try {
        await ref.read(matchmakingRepositoryProvider).leaveLobby(id);
      } catch (_) {}
    }
    setState(() {
      _lobbyId = null;
      _matchSummary = null;
      _lobbyState = _LobbyState.idle;
    });
  }

  Future<void> _confirmMatch() async {
    final matchId = _matchSummary?.matchId;
    final lobbyId = _lobbyId;
    if (matchId == null || lobbyId == null) return;
    setState(() => _lobbyState = _LobbyState.confirming);
    try {
      final result =
          await ref.read(matchmakingRepositoryProvider).confirmMatch(matchId, lobbyId);
      if (!mounted) return;
      if (result.status == 'confirmed') {
        _resetToIdle();
      } else {
        setState(() => _lobbyState = _LobbyState.matched);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lobbyState = _LobbyState.matched;
        _error = _parseError(e);
      });
    }
  }

  Future<void> _declineMatch() async {
    final matchId = _matchSummary?.matchId;
    final lobbyId = _lobbyId;
    if (matchId == null || lobbyId == null) return;
    try {
      await ref.read(matchmakingRepositoryProvider).declineMatch(matchId, lobbyId);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _matchSummary = null;
      _lobbyState = _LobbyState.searching;
      _startPolling();
    });
  }

  void _resetToIdle() {
    _pollTimer?.cancel();
    setState(() {
      _lobbyId = null;
      _matchSummary = null;
      _lobbyState = _LobbyState.idle;
      _picks = [];
    });
  }

  void _addPick(MmGroundSlotPick pick) {
    if (_picks.length >= 3) return;
    if (_picks.any(
        (p) => p.slot.unitId == pick.slot.unitId && p.slot.time == pick.slot.time)) {
      return;
    }
    setState(() => _picks.add(pick));
  }

  void _removePick(MmGroundSlotPick pick) {
    setState(() => _picks.removeWhere(
        (p) => p.slot.unitId == pick.slot.unitId && p.slot.time == pick.slot.time));
  }

  String _parseError(Object e) {
    final msg = e.toString();
    if (msg.contains('401')) return 'Session expired. Please log in again.';
    if (msg.contains('400')) return 'Invalid request. Check your picks.';
    if (msg.contains('404')) return 'Lobby not found.';
    return 'Something went wrong. Try again.';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(mmTeamsProvider, (_, next) {
      next.whenData((teams) {
        if (_team == null && teams.isNotEmpty) {
          setState(() => _team = teams.first);
        }
      });
    });

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Rivals',
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                if (_isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: context.panel,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(
                              strokeWidth: 1.6, color: context.accent),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _lobbyState == _LobbyState.matched ||
                                  _lobbyState == _LobbyState.confirming
                              ? 'Match found'
                              : 'Searching',
                          style: TextStyle(
                            color: context.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Tab bar ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _TabLabel(
                  label: 'Open',
                  active: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                const SizedBox(width: 24),
                _TabLabel(
                  label: 'Find',
                  active: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
                const SizedBox(width: 24),
                _TabLabel(
                  label: 'Challenge',
                  active: _tab == 2,
                  onTap: () => setState(() => _tab = 2),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),
          Container(height: 1, color: context.stroke.withValues(alpha: 0.4)),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
                // Tab 0: Open
                _OpenTab(
                  query: (date: _dateStr, format: null),
                  onCounter: (lobby) {
                    try {
                      final fmt = MatchFormat.values.firstWhere(
                        (f) => f.apiValue == lobby.format,
                        orElse: () => MatchFormat.t20,
                      );
                      setState(() {
                        _format = fmt;
                        _date = DateTime.parse(lobby.date);
                        _tab = 1;
                      });
                    } catch (_) {
                      setState(() => _tab = 1);
                    }
                  },
                ),
                // Tab 1: Find
                _FindTab(
                  lobbyState: _lobbyState,
                  team: _team,
                  format: _format,
                  date: _date,
                  picks: _picks,
                  matchSummary: _matchSummary,
                  error: _error,
                  onTeam: (t) => setState(() => _team = t),
                  onFormat: (f) => setState(() => _format = f),
                  onDate: (d) => setState(() => _date = d),
                  onAddPick: _addPick,
                  onRemovePick: _removePick,
                  onEnter: _enterLobby,
                  onLeave: _leaveLobby,
                  onConfirm: _confirmMatch,
                  onDecline: _declineMatch,
                ),
                // Tab 2: Challenge
                const _ChallengeTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab label ─────────────────────────────────────────────────────────────────

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          label,
          style: TextStyle(
            color: active ? context.fg : context.fgSub,
            fontSize: 15,
            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Tab 0: Open ───────────────────────────────────────────────────────────────

class _OpenTab extends ConsumerWidget {
  const _OpenTab({required this.query, required this.onCounter});
  final MmLobbiesQuery query;
  final ValueChanged<MmOpenLobby> onCounter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(mmOpenLobbiesProvider(query));
    return async.when(
      loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 1.5)),
      error: (_, __) => Center(
        child: Text('Could not load open games',
            style: TextStyle(color: context.fgSub, fontSize: 13)),
      ),
      data: (lobbies) {
        if (lobbies.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sports_cricket_rounded,
                    color: context.fgSub.withValues(alpha: 0.4), size: 40),
                const SizedBox(height: 12),
                Text(
                  'No open games right now',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Post one in Find or send a Challenge',
                  style: TextStyle(
                    color: context.fgSub.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          itemCount: lobbies.length,
          separatorBuilder: (_, __) => Container(
              height: 1, color: context.stroke.withValues(alpha: 0.3)),
          itemBuilder: (_, i) => _OpenLobbyRow(
            lobby: lobbies[i],
            onCounter: () => onCounter(lobbies[i]),
          ),
        );
      },
    );
  }
}

class _OpenLobbyRow extends StatelessWidget {
  const _OpenLobbyRow({required this.lobby, required this.onCounter});
  final MmOpenLobby lobby;
  final VoidCallback onCounter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lobby.teamName,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${lobby.ageGroup}  ·  ${lobby.format}  ·  ${lobby.groundName}  ·  ${lobby.displaySlot}  ·  ${lobby.dateLabel}',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onCounter,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: context.panel,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Counter',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab 1: Find ───────────────────────────────────────────────────────────────

class _FindTab extends StatelessWidget {
  const _FindTab({
    required this.lobbyState,
    required this.team,
    required this.format,
    required this.date,
    required this.picks,
    required this.matchSummary,
    required this.error,
    required this.onTeam,
    required this.onFormat,
    required this.onDate,
    required this.onAddPick,
    required this.onRemovePick,
    required this.onEnter,
    required this.onLeave,
    required this.onConfirm,
    required this.onDecline,
  });

  final _LobbyState lobbyState;
  final MmTeam? team;
  final MatchFormat format;
  final DateTime date;
  final List<MmGroundSlotPick> picks;
  final MmMatchSummary? matchSummary;
  final String? error;
  final ValueChanged<MmTeam> onTeam;
  final ValueChanged<MatchFormat> onFormat;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<MmGroundSlotPick> onAddPick;
  final ValueChanged<MmGroundSlotPick> onRemovePick;
  final VoidCallback onEnter;
  final VoidCallback onLeave;
  final VoidCallback onConfirm;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: switch (lobbyState) {
        _LobbyState.idle || _LobbyState.entering => _IdleFind(
            key: const ValueKey('idle'),
            team: team,
            format: format,
            date: date,
            picks: picks,
            error: error,
            loading: lobbyState == _LobbyState.entering,
            onTeam: onTeam,
            onFormat: onFormat,
            onDate: onDate,
            onAddPick: onAddPick,
            onRemovePick: onRemovePick,
            onEnter: onEnter,
          ),
        _LobbyState.searching => _SearchingFind(
            key: const ValueKey('searching'),
            team: team,
            format: format,
            date: date,
            picks: picks,
            onLeave: onLeave,
          ),
        _LobbyState.matched || _LobbyState.confirming => _MatchedFind(
            key: const ValueKey('matched'),
            team: team,
            format: format,
            date: date,
            matchSummary: matchSummary,
            confirming: lobbyState == _LobbyState.confirming,
            onConfirm: onConfirm,
            onDecline: onDecline,
          ),
      },
    );
  }
}

// ── Find: idle ────────────────────────────────────────────────────────────────

class _IdleFind extends ConsumerWidget {
  const _IdleFind({
    super.key,
    required this.team,
    required this.format,
    required this.date,
    required this.picks,
    required this.error,
    required this.loading,
    required this.onTeam,
    required this.onFormat,
    required this.onDate,
    required this.onAddPick,
    required this.onRemovePick,
    required this.onEnter,
  });

  final MmTeam? team;
  final MatchFormat format;
  final DateTime date;
  final List<MmGroundSlotPick> picks;
  final String? error;
  final bool loading;
  final ValueChanged<MmTeam> onTeam;
  final ValueChanged<MatchFormat> onFormat;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<MmGroundSlotPick> onAddPick;
  final ValueChanged<MmGroundSlotPick> onRemovePick;
  final VoidCallback onEnter;

  void _openGroundSheet(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddGroundSheet(
        query: (date: dateStr, format: format.apiValue, teamId: team?.id),
        existingPicks: picks,
        onPick: onAddPick,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(mmTeamsProvider);
    final canEnter = picks.isNotEmpty && team != null && !loading;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniLabel('YOUR TEAM'),
                const SizedBox(height: 12),
                teamsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: LinearProgressIndicator(minHeight: 1),
                  ),
                  error: (_, __) => Text('Could not load teams',
                      style: TextStyle(color: context.fgSub, fontSize: 13)),
                  data: (teams) => Column(
                    children: teams
                        .map((t) => _TeamRow(
                              team: t,
                              selected: team?.id == t.id,
                              onTap: () => onTeam(t),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
                _Divider(),
                const SizedBox(height: 24),
                _MiniLabel('FORMAT'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MatchFormat.values.map((f) {
                    final sel = format == f;
                    return GestureDetector(
                      onTap: () => onFormat(f),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: sel ? context.ctaBg : context.panel,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          f.label,
                          style: TextStyle(
                            color: sel ? context.ctaFg : context.fg,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                _Divider(),
                const SizedBox(height: 24),
                _MiniLabel('DATE'),
                const SizedBox(height: 12),
                _DateStrip(selected: date, onSelect: onDate),
                const SizedBox(height: 24),
                _Divider(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                        child:
                            _MiniLabel('GROUND & SLOT PREFERENCES')),
                    if (picks.length < 3)
                      GestureDetector(
                        onTap: () => _openGroundSheet(context),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            '+ Add',
                            style: TextStyle(
                              color: context.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (picks.isEmpty)
                  GestureDetector(
                    onTap: () => _openGroundSheet(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: context.panel,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: context.stroke.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded,
                              color: context.fgSub, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Add ground & slot',
                            style: TextStyle(
                              color: context.fgSub,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  ...picks.map((p) => _PickRow(
                        pick: p,
                        onRemove: () => onRemovePick(p),
                      )),
                  if (picks.length < 3)
                    GestureDetector(
                      onTap: () => _openGroundSheet(context),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.add_rounded,
                                color: context.fgSub, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'Add another  ${picks.length}/3',
                              style: TextStyle(
                                color: context.fgSub,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(error!,
                      style: TextStyle(
                          color: context.danger,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              20, 10, 20, 16 + MediaQuery.of(context).padding.bottom),
          child: GestureDetector(
            onTap: canEnter ? onEnter : null,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 50,
              decoration: BoxDecoration(
                color: canEnter ? context.ctaBg : context.panel,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: context.ctaFg),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.radar_rounded,
                            color: canEnter ? context.ctaFg : context.fgSub,
                            size: 17),
                        const SizedBox(width: 8),
                        Text(
                          canEnter
                              ? 'Find Rivals'
                              : 'Add a ground to continue',
                          style: TextStyle(
                            color:
                                canEnter ? context.ctaFg : context.fgSub,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
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

// ── Pick row ──────────────────────────────────────────────────────────────────

class _PickRow extends StatelessWidget {
  const _PickRow({required this.pick, required this.onRemove});
  final MmGroundSlotPick pick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hot = pick.slot.hasOpponent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: hot
              ? context.accent.withValues(alpha: 0.07)
              : context.panel,
          borderRadius: BorderRadius.circular(12),
          border: hot
              ? Border.all(
                  color: context.accent.withValues(alpha: 0.25), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (hot) ...[
                        const Text('⚡', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          pick.ground.name,
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${pick.ground.area}  ·  ${pick.slot.displayTime}  ·  ₹${pick.slot.priceRupees}/team',
                    style: TextStyle(
                      color: hot ? context.accent : context.fgSub,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (hot)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        'Rival ready — instant match!',
                        style: TextStyle(
                          color: context.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(Icons.close_rounded,
                    color: context.fgSub, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add ground sheet ──────────────────────────────────────────────────────────

class _AddGroundSheet extends ConsumerStatefulWidget {
  const _AddGroundSheet({
    required this.query,
    required this.existingPicks,
    required this.onPick,
  });
  final MmGroundsQuery query;
  final List<MmGroundSlotPick> existingPicks;
  final ValueChanged<MmGroundSlotPick> onPick;

  @override
  ConsumerState<_AddGroundSheet> createState() => _AddGroundSheetState();
}

class _AddGroundSheetState extends ConsumerState<_AddGroundSheet> {
  String _filterQuery = '';
  MmGround? _selectedGround;

  bool _alreadyPicked(MmSlot slot) {
    return widget.existingPicks.any(
        (p) => p.slot.unitId == slot.unitId && p.slot.time == slot.time);
  }

  @override
  Widget build(BuildContext context) {
    final groundsAsync = ref.watch(mmGroundsProvider(widget.query));

    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 16),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: context.stroke,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                if (_selectedGround != null)
                  GestureDetector(
                    onTap: () => setState(() => _selectedGround = null),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(Icons.arrow_back_rounded,
                          color: context.fg, size: 18),
                    ),
                  ),
                Expanded(
                  child: Text(
                    _selectedGround == null
                        ? 'Choose Ground'
                        : _selectedGround!.name,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedGround == null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                    color: context.panel,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(Icons.search_rounded,
                        color: context.fgSub, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        autofocus: false,
                        onChanged: (v) =>
                            setState(() => _filterQuery = v),
                        style: TextStyle(
                            color: context.fg,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: 'Search ground or area...',
                          hintStyle: TextStyle(
                              color: context.fgSub, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45),
              child: groundsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                      child: CircularProgressIndicator(strokeWidth: 1.5)),
                ),
                error: (_, __) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text('Could not load grounds',
                        style: TextStyle(
                            color: context.fgSub, fontSize: 13)),
                  ),
                ),
                data: (grounds) {
                  final filtered = _filterQuery.isEmpty
                      ? grounds
                      : grounds
                          .where((g) =>
                              g.name.toLowerCase().contains(
                                  _filterQuery.toLowerCase()) ||
                              g.area.toLowerCase().contains(
                                  _filterQuery.toLowerCase()))
                          .toList();
                  if (filtered.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                          child: Text('No grounds found',
                              style: TextStyle(
                                  color: context.fgSub, fontSize: 13))),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => Container(
                        height: 1,
                        color: context.stroke.withValues(alpha: 0.3)),
                    itemBuilder: (_, i) {
                      final g = filtered[i];
                      final opponentCount =
                          g.slots.where((s) => s.hasOpponent).length;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedGround = g),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(g.name,
                                        style: TextStyle(
                                          color: context.fg,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.2,
                                        )),
                                    const SizedBox(height: 2),
                                    Text(g.area,
                                        style: TextStyle(
                                          color: context.fgSub,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        )),
                                  ],
                                ),
                              ),
                              if (opponentCount > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: context.accent
                                        .withValues(alpha: 0.12),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '⚡ $opponentCount',
                                    style: TextStyle(
                                      color: context.accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Icon(Icons.chevron_right_rounded,
                                  color: context.fgSub, size: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(_selectedGround!.area,
                  style: TextStyle(
                      color: context.fgSub,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedGround!.slots.map((slot) {
                  final taken = _alreadyPicked(slot);
                  final hot = slot.hasOpponent;
                  return GestureDetector(
                    onTap: taken
                        ? null
                        : () {
                            widget.onPick(MmGroundSlotPick(
                                ground: _selectedGround!, slot: slot));
                            Navigator.pop(context);
                          },
                    child: AnimatedOpacity(
                      opacity: taken ? 0.35 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: hot
                              ? context.accent.withValues(alpha: 0.10)
                              : context.panel,
                          borderRadius: BorderRadius.circular(10),
                          border: hot
                              ? Border.all(
                                  color: context.accent
                                      .withValues(alpha: 0.35),
                                  width: 1)
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hot) ...[
                                  const Text('⚡',
                                      style: TextStyle(fontSize: 11)),
                                  const SizedBox(width: 3),
                                ],
                                Text(
                                  slot.displayTime,
                                  style: TextStyle(
                                    color:
                                        hot ? context.accent : context.fg,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${slot.priceRupees}',
                              style: TextStyle(
                                  color: context.fgSub,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ],
      ),
    );
  }
}

// ── Find: searching ───────────────────────────────────────────────────────────

class _SearchingFind extends StatelessWidget {
  const _SearchingFind({
    super.key,
    required this.team,
    required this.format,
    required this.date,
    required this.picks,
    required this.onLeave,
  });

  final MmTeam? team;
  final MatchFormat format;
  final DateTime date;
  final List<MmGroundSlotPick> picks;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dateLabel = () {
      final n = DateTime.now();
      final today = DateTime(n.year, n.month, n.day);
      final t = DateTime(date.year, date.month, date.day);
      if (t == today) return 'Today';
      if (t == today.add(const Duration(days: 1))) return 'Tomorrow';
      return DateFormat('MMM d').format(date);
    }();

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 32, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            team?.name ?? '—',
            style: TextStyle(
              color: context.fg,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${team?.ageGroupLabel ?? ''}  ·  ${format.label}  ·  $dateLabel',
            style: TextStyle(
                color: context.fgSub,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(
                    strokeWidth: 1.8, color: context.accent),
              ),
              const SizedBox(width: 10),
              Text(
                'Hunting for rivals...',
                style: TextStyle(
                    color: context.fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _Divider(),
          const SizedBox(height: 20),
          _MiniLabel('YOUR PREFERENCES'),
          const SizedBox(height: 12),
          ...picks.map((p) {
            final hot = p.slot.hasOpponent;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  if (hot)
                    const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Text('⚡', style: TextStyle(fontSize: 13)))
                  else
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(Icons.location_on_outlined,
                          color: context.fgSub, size: 13),
                    ),
                  Expanded(
                    child: Text(
                      '${p.ground.name}  ·  ${p.slot.displayTime}',
                      style: TextStyle(
                        color: hot ? context.accent : context.fg,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text('₹${p.slot.priceRupees}',
                      style: TextStyle(
                          color: context.fgSub,
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }),
          const Spacer(),
          GestureDetector(
            onTap: onLeave,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('Leave',
                  style: TextStyle(
                      color: context.fgSub,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Find: matched ─────────────────────────────────────────────────────────────

class _MatchedFind extends StatelessWidget {
  const _MatchedFind({
    super.key,
    required this.team,
    required this.format,
    required this.date,
    required this.matchSummary,
    required this.confirming,
    required this.onConfirm,
    required this.onDecline,
  });

  final MmTeam? team;
  final MatchFormat format;
  final DateTime date;
  final MmMatchSummary? matchSummary;
  final bool confirming;
  final VoidCallback onConfirm;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final price = matchSummary?.priceRupees ?? 0;
    final groundName = matchSummary?.groundName ?? '—';
    final groundArea = matchSummary?.groundArea ?? '';
    final slotDisplay = matchSummary?.displaySlot ?? '';
    final opponent = matchSummary?.opponentTeamName ?? 'Opponent';
    final dateLabel = () {
      final n = DateTime.now();
      if (DateTime(date.year, date.month, date.day) ==
          DateTime(n.year, n.month, n.day)) { return 'Today'; }
      return DateFormat('MMM d').format(date);
    }();

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 32, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RIVAL FOUND',
            style: TextStyle(
              color: context.accent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            groundName,
            style: TextStyle(
              color: context.fg,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            [
              groundArea,
              format.label,
              if (slotDisplay.isNotEmpty) slotDisplay,
              dateLabel,
            ].where((s) => s.isNotEmpty).join('  ·  '),
            style: TextStyle(
                color: context.fgSub,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'vs $opponent',
            style: TextStyle(
                color: context.fgSub,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 36),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹$price',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'your share  ·  ground fee ÷ 2',
                  style: TextStyle(
                      color: context.fgSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: GestureDetector(
              onTap: confirming ? null : onConfirm,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: confirming ? context.panel : context.ctaBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: confirming
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: context.ctaFg),
                      )
                    : Text(
                        'Lock it in  ₹$price',
                        style: TextStyle(
                          color: context.ctaFg,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Rival has 15 min to confirm',
              style: TextStyle(
                  color: context.fgSub,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: confirming ? null : onDecline,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Decline',
                  style: TextStyle(
                      color: context.fgSub,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab 2: Challenge ──────────────────────────────────────────────────────────

class _ChallengeTab extends StatefulWidget {
  const _ChallengeTab();

  @override
  State<_ChallengeTab> createState() => _ChallengeTabState();
}

class _ChallengeTabState extends State<_ChallengeTab> {
  final _controller = TextEditingController();
  List<_ChallengeTeam> _results = [];
  bool _loading = false;
  bool _searched = false;

  String? _expandedId;
  MatchFormat _challengeFormat = MatchFormat.t20;
  DateTime _challengeDate = DateTime.now();
  bool _sending = false;
  String? _sentTeamId;

  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String q) {
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(q.trim()));
  }

  Future<void> _search(String q) async {
    setState(() => _loading = true);
    try {
      final resp = await ApiClient.instance.dio.get(
        ApiEndpoints.searchTeams,
        queryParameters: {'q': q, 'limit': 20},
      );
      final data = resp.data is Map ? (resp.data['data'] ?? resp.data) : resp.data;
      final teams = (data['teams'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(_ChallengeTeam.fromJson)
          .toList();
      if (mounted) {
        setState(() {
          _results = teams;
          _searched = true;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendChallenge(_ChallengeTeam team) async {
    setState(() => _sending = true);
    // Small delay to show loading — real API call goes here once
    // POST /matchmaking/lobbies supports targetTeamId
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _sending = false;
      _sentTeamId = team.id;
      _expandedId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: context.panel,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(Icons.search_rounded, color: context.fgSub, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: _onQueryChanged,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search team to challenge...',
                      hintStyle:
                          TextStyle(color: context.fgSub, fontSize: 15),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (_controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _controller.clear();
                      setState(() {
                        _results = [];
                        _searched = false;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.close_rounded,
                          color: context.fgSub, size: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Content
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(strokeWidth: 1.5))
              : !_searched
                  ? _EmptyChallenge()
                  : _results.isEmpty
                      ? Center(
                          child: Text(
                            'No teams found',
                            style: TextStyle(
                                color: context.fgSub, fontSize: 14),
                          ),
                        )
                      : ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(20, 16, 20, 32),
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => Container(
                              height: 1,
                              color: context.stroke
                                  .withValues(alpha: 0.3)),
                          itemBuilder: (_, i) {
                            final team = _results[i];
                            final expanded = _expandedId == team.id;
                            final sent = _sentTeamId == team.id;
                            return _ChallengeTeamRow(
                              team: team,
                              expanded: expanded,
                              sent: sent,
                              sending: _sending && expanded,
                              format: _challengeFormat,
                              date: _challengeDate,
                              onTap: () => setState(() =>
                                  _expandedId =
                                      expanded ? null : team.id),
                              onFormat: (f) =>
                                  setState(() => _challengeFormat = f),
                              onDate: (d) =>
                                  setState(() => _challengeDate = d),
                              onSend: () => _sendChallenge(team),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}

class _EmptyChallenge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_outlined,
              color: context.fgSub.withValues(alpha: 0.4), size: 40),
          const SizedBox(height: 12),
          Text(
            'Challenge a team',
            style: TextStyle(
              color: context.fg,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Search by team name or city',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeTeamRow extends StatelessWidget {
  const _ChallengeTeamRow({
    required this.team,
    required this.expanded,
    required this.sent,
    required this.sending,
    required this.format,
    required this.date,
    required this.onTap,
    required this.onFormat,
    required this.onDate,
    required this.onSend,
  });

  final _ChallengeTeam team;
  final bool expanded;
  final bool sent;
  final bool sending;
  final MatchFormat format;
  final DateTime date;
  final VoidCallback onTap;
  final ValueChanged<MatchFormat> onFormat;
  final ValueChanged<DateTime> onDate;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Team header row
        GestureDetector(
          onTap: sent ? null : onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                // Avatar placeholder
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.panel,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    team.name.isNotEmpty ? team.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          team.typeLabel,
                          if (team.city != null && team.city!.isNotEmpty)
                            team.city!,
                          '${team.memberCount} players',
                        ].join('  ·  '),
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (sent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Sent ✓',
                      style: TextStyle(
                        color: context.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: context.fgSub, size: 20),
                  ),
              ],
            ),
          ),
        ),

        // Expandable challenge form
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.panel,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniLabel('FORMAT'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MatchFormat.values.map((f) {
                    final sel = format == f;
                    return GestureDetector(
                      onTap: () => onFormat(f),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? context.ctaBg : context.bg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          f.label,
                          style: TextStyle(
                            color: sel ? context.ctaFg : context.fg,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                _MiniLabel('DATE'),
                const SizedBox(height: 10),
                _DateStrip(selected: date, onSelect: onDate),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: GestureDetector(
                    onTap: sending ? null : onSend,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: sending ? context.bg : context.ctaBg,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      alignment: Alignment.center,
                      child: sending
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: context.ctaFg),
                            )
                          : Text(
                              'Send Challenge',
                              style: TextStyle(
                                color: context.ctaFg,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
          sizeCurve: Curves.easeOutCubic,
        ),
      ],
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _TeamRow extends StatelessWidget {
  const _TeamRow({
    required this.team,
    required this.selected,
    required this.onTap,
  });
  final MmTeam team;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? context.accent : context.stroke,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                team.name,
                style: TextStyle(
                  color: selected ? context.fg : context.fgSub,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Text(
              team.ageGroupLabel,
              style: TextStyle(
                  color: context.fgSub,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.selected, required this.onSelect});
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  static final _days = List.generate(7, (i) {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day + i);
  });
  static const _dn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _label(DateTime d, int i) {
    if (i == 0) return 'Today';
    if (i == 1) return 'Tmrw';
    return _dn[d.weekday - 1];
  }

  bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_days.length, (i) {
        final d = _days[i];
        final sel = _same(selected, d);
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(d),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding:
                  EdgeInsets.only(right: i < _days.length - 1 ? 5 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                height: 54,
                decoration: BoxDecoration(
                  color: sel ? context.ctaBg : context.panel,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _label(d, i),
                      style: TextStyle(
                        color: sel ? context.ctaFg : context.fgSub,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${d.day}',
                      style: TextStyle(
                        color: sel ? context.ctaFg : context.fg,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _MiniLabel extends StatelessWidget {
  const _MiniLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.fgSub,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: context.stroke.withValues(alpha: 0.4));
}
