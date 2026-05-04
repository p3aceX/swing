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

// ── Ball type helpers ─────────────────────────────────────────────────────────

String _ballTypeLabel(String bt) => switch (bt) {
      'LEATHER' => 'Leather',
      'TENNIS' => 'Tennis',
      'TAPE' => 'Tape Ball',
      'RUBBER' => 'Rubber',
      _ => bt,
    };

// ── Format helpers ────────────────────────────────────────────────────────────

extension _FormatApi on MatchFormat {
  String get apiValue => switch (this) {
        MatchFormat.t10 => 'T10',
        MatchFormat.t20 => 'T20',
        MatchFormat.odi => 'ODI',
        MatchFormat.test => 'Test',
        MatchFormat.custom => 'Custom',
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
  int _tab = 1; // 0=Open  1=Find  2=Challenge

  // Find tab state
  _LobbyState _lobbyState = _LobbyState.idle;
  MmTeam? _team;
  MatchFormat _format = MatchFormat.t20;
  String? _ballType;
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreActiveLobby());
  }

  Future<void> _restoreActiveLobby() async {
    try {
      final repo = ref.read(matchmakingRepositoryProvider);
      final active = await repo.getActiveLobby();
      if (active == null || !mounted) return;
      setState(() {
        _lobbyId = active.lobbyId;
        if (active.status == 'matched' && active.match != null) {
          _matchSummary = active.match;
          _lobbyState = _LobbyState.matched;
        } else {
          _lobbyState = _LobbyState.searching;
        }
      });
      if (_lobbyState == _LobbyState.searching) _startPolling();
    } catch (_) {}
  }

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
        ballType: _ballType,
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
        _error = _parseError(e, isCreate: true);
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

  String _parseError(Object e, {bool isCreate = false}) {
    final msg = e.toString();
    if (msg.contains('401')) return 'Session expired. Please log in again.';
    if (msg.contains('400')) return 'Invalid picks. Please try again.';
    if (msg.contains('404')) return isCreate ? 'Could not create request. Try again.' : 'Request expired or not found.';
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
                  badge: ref.watch(mmOpenLobbiesProvider((date: null, format: null))).valueOrNull?.length,
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
                // Tab 0: Open — no date filter so all upcoming lobbies show
                _OpenTab(
                  query: (date: null, format: null),
                  ownLobby: () {
                    if (_lobbyState != _LobbyState.searching ||
                        _lobbyId == null ||
                        _team == null) return null;
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    return MmOpenLobby(
                      lobbyId: _lobbyId!,
                      teamName: _team!.name,
                      ageGroup: _team!.ageGroupLabel,
                      format: _format.apiValue,
                      ballType: _ballType,
                      groundName: _picks.isNotEmpty
                          ? _picks.first.ground.name
                          : '',
                      slotTime: _picks.isNotEmpty
                          ? _picks.first.slot.time
                          : '',
                      date: _dateStr,
                      daysFromNow:
                          _date.difference(today).inDays,
                    );
                  }(),
                  onLeave: _leaveLobby,
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
                  ballType: _ballType,
                  date: _date,
                  picks: _picks,
                  matchSummary: _matchSummary,
                  error: _error,
                  onTeam: (t) => setState(() => _team = t),
                  onFormat: (f) => setState(() {
                    _format = f;
                    _picks = []; // slot availability changes with format duration
                  }),
                  onBallType: (bt) => setState(() => _ballType = bt),
                  onDate: (d) => setState(() {
                    _date = d;
                    _picks = []; // slots are date-specific — clear stale picks
                  }),
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
    this.badge,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: active ? context.fg : context.fgSub,
                fontSize: 15,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
            if (badge != null && badge! > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: active ? context.accent : context.fgSub.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$badge',
                  style: TextStyle(
                    color: active ? Colors.white : context.fgSub,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Tab 0: Open ───────────────────────────────────────────────────────────────

class _OpenTab extends ConsumerStatefulWidget {
  const _OpenTab({
    required this.query,
    required this.onCounter,
    this.ownLobby,
    this.onLeave,
  });
  final MmLobbiesQuery query;
  final ValueChanged<MmOpenLobby> onCounter;
  final MmOpenLobby? ownLobby;
  final VoidCallback? onLeave;

  @override
  ConsumerState<_OpenTab> createState() => _OpenTabState();
}

class _OpenTabState extends ConsumerState<_OpenTab> {
  String? _selectedDate;
  String? _ballTypeFilter;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(mmOpenLobbiesProvider(widget.query));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      error: (_, __) => Center(
        child: Text('Could not load open games', style: TextStyle(color: context.fgSub, fontSize: 13)),
      ),
      data: (lobbies) {
        final others = widget.ownLobby != null
            ? lobbies.where((l) => l.lobbyId != widget.ownLobby!.lobbyId).toList()
            : lobbies;

        // Group by date
        final Map<String, List<MmOpenLobby>> byDate = {};
        for (final l in others) {
          (byDate[l.date] ??= []).add(l);
        }

        // Only show dates that have lobbies
        final today = DateTime.now();
        final todayStr = DateFormat('yyyy-MM-dd').format(today);
        final sortedDates = (byDate.keys.toList()..sort())
            .where((d) => d.compareTo(todayStr) >= 0)
            .toList();

        // Auto-select first available date; reset if selected date no longer has lobbies
        final autoDate = sortedDates.isNotEmpty ? sortedDates.first : todayStr;
        final selected = (_selectedDate != null && sortedDates.contains(_selectedDate))
            ? _selectedDate!
            : autoDate;
        final filtered = (byDate[selected] ?? [])
            .where((l) => _ballTypeFilter == null || l.ballType == null || l.ballType == _ballTypeFilter)
            .toList();

        final totalCount = others.length;

        return Column(
          children: [
            // ── Date strip ──────────────────────────────────────────────────
            Container(
              color: context.bg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Row(
                      children: ['ALL', 'LEATHER', 'TENNIS', 'TAPE', 'RUBBER'].map((bt) {
                        final isAll = bt == 'ALL';
                        final sel = isAll ? _ballTypeFilter == null : _ballTypeFilter == bt;
                        return GestureDetector(
                          onTap: () => setState(() => _ballTypeFilter = isAll ? null : bt),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 140),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: sel ? context.accent : context.surf,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: sel ? context.accent : context.stroke,
                              ),
                            ),
                            child: Text(
                              isAll ? 'All' : _ballTypeLabel(bt),
                              style: TextStyle(
                                color: sel ? Colors.white : context.fgSub,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (sortedDates.isNotEmpty) ...[
                    SizedBox(
                      height: 62,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        itemCount: sortedDates.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final dateStr = sortedDates[i];
                          final isSelected = dateStr == selected;
                          final count = byDate[dateStr]!.length;
                          final d = DateTime.tryParse(dateStr) ?? today;
                          final isToday = dateStr == todayStr;
                          final dayName = isToday ? 'Today' : DateFormat('EEE').format(d);
                          return GestureDetector(
                            onTap: () => setState(() => _selectedDate = dateStr),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? context.accent : context.surf,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? context.accent : context.accent.withValues(alpha: 0.35),
                                  width: isSelected ? 0 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dayName,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? Colors.white.withValues(alpha: 0.8) : context.fgSub,
                                        ),
                                      ),
                                      Text(
                                        '${d.day} ${DateFormat('MMM').format(d)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: isSelected ? Colors.white : context.fg,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.25)
                                          : context.success,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$count',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Divider(height: 1, color: context.stroke.withValues(alpha: 0.5)),
                  ],
                ],
              ),
            ),

            // ── Lobby list ──────────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: context.accent,
                onRefresh: () async => ref.invalidate(mmOpenLobbiesProvider(widget.query)),
                child: (widget.ownLobby == null && filtered.isEmpty)
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: 260,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sports_cricket_rounded,
                                    color: context.fgSub.withValues(alpha: 0.3), size: 44),
                                const SizedBox(height: 12),
                                Text(
                                  'No open games on this day',
                                  style: TextStyle(color: context.fgSub, fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Try another date',
                                  style: TextStyle(color: context.fgSub.withValues(alpha: 0.5), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        children: [
                          if (widget.ownLobby != null) ...[
                            _OpenSectionLabel(label: 'YOU'),
                            _OwnLobbyRow(lobby: widget.ownLobby!, onLeave: widget.onLeave),
                          ],
                          if (filtered.isNotEmpty) ...[
                            if (widget.ownLobby != null) const SizedBox(height: 16),
                            if (widget.ownLobby != null)
                              _OpenSectionLabel(label: 'OTHERS · ${filtered.length}'),
                            for (final lobby in filtered)
                              _OpenLobbyCard(
                                lobby: lobby,
                                onCounter: () => widget.onCounter(lobby),
                              ),
                          ],
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OpenSectionLabel extends StatelessWidget {
  const _OpenSectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: TextStyle(
          color: context.fgSub.withValues(alpha: 0.5),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _OwnLobbyRow extends StatefulWidget {
  const _OwnLobbyRow({required this.lobby, this.onLeave});
  final MmOpenLobby lobby;
  final VoidCallback? onLeave;

  @override
  State<_OwnLobbyRow> createState() => _OwnLobbyRowState();
}

class _OwnLobbyRowState extends State<_OwnLobbyRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

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
                Row(
                  children: [
                    Text(
                      widget.lobby.teamName,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, __) => Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(
                              alpha: 0.4 + 0.6 * _pulse.value),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.lobby.ageGroup}  ·  ${widget.lobby.format}  ·  ${widget.lobby.groundName}  ·  ${widget.lobby.displaySlot}  ·  ${widget.lobby.dateLabel}',
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
            onTap: widget.onLeave,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: context.panel,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Leave',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenLobbyCard extends StatelessWidget {
  const _OpenLobbyCard({required this.lobby, required this.onCounter});
  final MmOpenLobby lobby;
  final VoidCallback onCounter;

  String get _initials {
    final words = lobby.teamName.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) return '${words[0][0]}${words[1][0]}'.toUpperCase();
    return lobby.teamName.isNotEmpty ? lobby.teamName[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Team row ──────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.panel,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lobby.teamName,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (lobby.ageGroup.isNotEmpty && lobby.ageGroup != 'Open') ...[
                      const SizedBox(height: 1),
                      Text(
                        lobby.ageGroup,
                        style: TextStyle(color: context.fgSub, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
              // Format + ball type chips
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MiniChip(label: lobby.format, context: context),
                  if (lobby.ballType != null) ...[
                    const SizedBox(width: 6),
                    _MiniChip(label: _ballTypeLabel(lobby.ballType!), context: context),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Info row ──────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 13, color: context.fgSub),
              const SizedBox(width: 4),
              Text(
                lobby.displaySlot,
                style: TextStyle(color: context.fgSub, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              if (lobby.groundName.isNotEmpty) ...[
                Text('  ·  ', style: TextStyle(color: context.fgSub.withValues(alpha: 0.4), fontSize: 12)),
                Expanded(
                  child: Text(
                    lobby.groundName,
                    style: TextStyle(color: context.fgSub, fontSize: 12, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else
                const Spacer(),
            ],
          ),
          if (lobby.arenaName.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.stadium_rounded, size: 13, color: context.accent),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    lobby.arenaName,
                    style: TextStyle(color: context.accent, fontSize: 12, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          // ── CTA ───────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 40,
            child: GestureDetector(
              onTap: onCounter,
              child: Container(
                decoration: BoxDecoration(
                  color: context.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  lobby.isArenaLobby ? 'Book' : 'Counter',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.context});
  final String label;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: context.fgSub,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
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
    required this.ballType,
    required this.date,
    required this.picks,
    required this.matchSummary,
    required this.error,
    required this.onTeam,
    required this.onFormat,
    required this.onBallType,
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
  final String? ballType;
  final DateTime date;
  final List<MmGroundSlotPick> picks;
  final MmMatchSummary? matchSummary;
  final String? error;
  final ValueChanged<MmTeam> onTeam;
  final ValueChanged<MatchFormat> onFormat;
  final ValueChanged<String?> onBallType;
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
            ballType: ballType,
            date: date,
            picks: picks,
            error: error,
            loading: lobbyState == _LobbyState.entering,
            onTeam: onTeam,
            onFormat: onFormat,
            onBallType: onBallType,
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

// ── Find: idle (progressive stepper) ─────────────────────────────────────────

class _IdleFind extends ConsumerStatefulWidget {
  const _IdleFind({
    super.key,
    required this.team,
    required this.format,
    required this.ballType,
    required this.date,
    required this.picks,
    required this.error,
    required this.loading,
    required this.onTeam,
    required this.onFormat,
    required this.onBallType,
    required this.onDate,
    required this.onAddPick,
    required this.onRemovePick,
    required this.onEnter,
  });

  final MmTeam? team;
  final MatchFormat format;
  final String? ballType;
  final DateTime date;
  final List<MmGroundSlotPick> picks;
  final String? error;
  final bool loading;
  final ValueChanged<MmTeam> onTeam;
  final ValueChanged<MatchFormat> onFormat;
  final ValueChanged<String?> onBallType;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<MmGroundSlotPick> onAddPick;
  final ValueChanged<MmGroundSlotPick> onRemovePick;
  final VoidCallback onEnter;

  @override
  ConsumerState<_IdleFind> createState() => _IdleFindState();
}

class _IdleFindState extends ConsumerState<_IdleFind> {
  // 1=team  2=format  3=date  4=grounds
  int _activeStep = 1;
  int _customOvers = 20;

  void _goTo(int step) => setState(() => _activeStep = step);

  void _openGroundSheet() {
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.date);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddGroundSheet(
        query: (date: dateStr, format: widget.format.apiValue, teamId: widget.team?.id,
            overs: widget.format == MatchFormat.custom ? _customOvers : null),
        existingPicks: widget.picks,
        onPick: widget.onAddPick,
      ),
    );
  }

  String _dateLabel(DateTime d) {
    final today = DateTime.now();
    final t = DateTime(today.year, today.month, today.day);
    final dd = DateTime(d.year, d.month, d.day);
    if (dd == t) return 'Today';
    if (dd == t.add(const Duration(days: 1))) return 'Tomorrow';
    return DateFormat('MMM d').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final teamsAsync = ref.watch(mmTeamsProvider);
    final canEnter = widget.picks.isNotEmpty && widget.team != null && widget.ballType != null && !widget.loading;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              children: [
                // ── Step 1: Team ──────────────────────────────────────
                _StepCard(
                  step: 1,
                  title: 'Your Team',
                  activeStep: _activeStep,
                  summary: widget.team?.name,
                  summaryIcon: Icons.groups_rounded,
                  onEdit: () => _goTo(1),
                  child: teamsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: LinearProgressIndicator(minHeight: 1),
                    ),
                    error: (_, __) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text('Could not load teams',
                          style: TextStyle(color: context.fgSub, fontSize: 13)),
                    ),
                    data: (teams) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: _TeamDropdown(
                        teams: teams,
                        selected: widget.team,
                        onSelect: (t) {
                          widget.onTeam(t);
                          _goTo(2);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ── Step 2: Format ────────────────────────────────────
                _StepCard(
                  step: 2,
                  title: 'Format',
                  activeStep: _activeStep,
                  locked: widget.team == null,
                  summary: [
                    widget.format == MatchFormat.custom
                        ? 'Custom · $_customOvers overs'
                        : widget.format.label,
                    if (widget.ballType != null) _ballTypeLabel(widget.ballType!),
                  ].join(' · '),
                  summaryIcon: Icons.sports_cricket_rounded,
                  onEdit: () => _goTo(2),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: MatchFormat.values.map((f) {
                            final sel = widget.format == f;
                            return GestureDetector(
                              onTap: () {
                                widget.onFormat(f);
                                if (f != MatchFormat.custom) _goTo(3);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 140),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 10),
                                decoration: BoxDecoration(
                                  color: sel ? context.ctaBg : context.panel,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  f.label,
                                  style: TextStyle(
                                    color: sel ? context.ctaFg : context.fg,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ball Type',
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['LEATHER', 'TENNIS', 'TAPE', 'RUBBER'].map((bt) {
                            final sel = widget.ballType == bt;
                            return GestureDetector(
                              onTap: () => widget.onBallType(bt),
                              behavior: HitTestBehavior.opaque,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 140),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: sel ? context.ctaBg : context.panel,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _ballTypeLabel(bt),
                                  style: TextStyle(
                                    color: sel ? context.ctaFg : context.fg,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (widget.format == MatchFormat.custom) ...[
                          const SizedBox(height: 16),
                          Text(
                            'How many overs?',
                            style: TextStyle(
                              color: context.fgSub,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _OversButton(
                                icon: Icons.remove,
                                onTap: _customOvers > 1
                                    ? () => setState(() => _customOvers--)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '$_customOvers',
                                style: TextStyle(
                                  color: context.fg,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 4, top: 4),
                                child: Text(
                                  'overs',
                                  style: TextStyle(
                                    color: context.fgSub,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              _OversButton(
                                icon: Icons.add,
                                onTap: _customOvers < 100
                                    ? () => setState(() => _customOvers++)
                                    : null,
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => _goTo(3),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: context.ctaBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Confirm',
                                    style: TextStyle(
                                      color: context.ctaFg,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ── Step 3: Date ──────────────────────────────────────
                _StepCard(
                  step: 3,
                  title: 'Date',
                  activeStep: _activeStep,
                  locked: widget.team == null,
                  summary: _dateLabel(widget.date),
                  summaryIcon: Icons.calendar_today_rounded,
                  onEdit: () => _goTo(3),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _CalendarPicker(
                      selected: widget.date,
                      onSelect: (d) {
                        widget.onDate(d);
                        _goTo(4);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ── Step 4: Grounds ───────────────────────────────────
                _StepCard(
                  step: 4,
                  title: 'Ground & Slot',
                  activeStep: _activeStep,
                  locked: widget.team == null,
                  summary: widget.picks.isEmpty
                      ? null
                      : '${widget.picks.length} preference${widget.picks.length > 1 ? 's' : ''}',
                  summaryIcon: Icons.location_on_rounded,
                  onEdit: () => _goTo(4),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.picks.isEmpty)
                          GestureDetector(
                            onTap: _openGroundSheet,
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
                                  Text('Add ground & slot',
                                      style: TextStyle(
                                          color: context.fgSub,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          )
                        else ...[
                          ...widget.picks.map((p) => _PickRow(
                                pick: p,
                                onRemove: () => widget.onRemovePick(p),
                              )),
                          if (widget.picks.length < 3)
                            GestureDetector(
                              onTap: _openGroundSheet,
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2, bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.add_rounded,
                                        color: context.fgSub, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Add another  ${widget.picks.length}/3',
                                      style: TextStyle(
                                          color: context.fgSub,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),

                if (widget.error != null) ...[
                  const SizedBox(height: 12),
                  Text(widget.error!,
                      style: TextStyle(
                          color: context.danger,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              20, 10, 20, 16 + MediaQuery.of(context).padding.bottom),
          child: GestureDetector(
            onTap: canEnter ? widget.onEnter : null,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 52,
              decoration: BoxDecoration(
                color: canEnter ? context.ctaBg : context.panel,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: widget.loading
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
                          canEnter ? 'Find Rivals' : 'Complete setup to continue',
                          style: TextStyle(
                            color: canEnter ? context.ctaFg : context.fgSub,
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

// ── Step card ─────────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.title,
    required this.activeStep,
    required this.child,
    required this.onEdit,
    this.summary,
    this.summaryIcon,
    this.locked = false,
  });

  final int step;
  final String title;
  final int activeStep;
  final Widget child;
  final VoidCallback onEdit;
  final String? summary;
  final IconData? summaryIcon;
  final bool locked;

  bool get _isActive => activeStep == step;
  bool get _isDone => summary != null && activeStep > step;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isActive
              ? context.ctaBg.withValues(alpha: 0.5)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          GestureDetector(
            onTap: (!locked && _isDone) ? onEdit : null,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  // Step indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isDone
                          ? context.success
                          : _isActive
                              ? context.ctaBg
                              : context.stroke.withValues(alpha: 0.4),
                    ),
                    alignment: Alignment.center,
                    child: _isDone
                        ? Icon(Icons.check_rounded,
                            color: Colors.white, size: 14)
                        : Text(
                            '$step',
                            style: TextStyle(
                              color: _isActive
                                  ? context.ctaFg
                                  : context.fgSub,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: locked
                                ? context.fgSub.withValues(alpha: 0.4)
                                : context.fg,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (_isDone && summary != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              if (summaryIcon != null) ...[
                                Icon(summaryIcon,
                                    color: context.accent, size: 11),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                summary!,
                                style: TextStyle(
                                  color: context.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_isDone)
                    Text(
                      'Edit',
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
          // Expanded content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _isActive
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: child,
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ── Pick row ──────────────────────────────────────────────────────────────────

class _OversButton extends StatelessWidget {
  const _OversButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onTap != null ? context.panel : context.panel.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? context.fg : context.fgSub.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

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

  bool _alreadyPicked(MmSlot slot) =>
      widget.existingPicks.any(
          (p) => p.slot.unitId == slot.unitId && p.slot.time == slot.time);

  @override
  Widget build(BuildContext context) {
    final groundsAsync = ref.watch(mmGroundsProvider(widget.query));
    final h = MediaQuery.of(context).size.height;

    return Container(
      height: h * 0.88,
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                    color: context.stroke,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
            child: Row(
              children: [
                if (_selectedGround != null)
                  GestureDetector(
                    onTap: () => setState(() => _selectedGround = null),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.arrow_back_rounded, size: 20),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedGround == null ? 'Choose Ground' : _selectedGround!.name,
                        style: TextStyle(
                          color: context.fg, fontSize: 18,
                          fontWeight: FontWeight.w900, letterSpacing: -0.4,
                        ),
                      ),
                      if (_selectedGround != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(children: [
                            Icon(Icons.location_on_rounded, color: context.fgSub, size: 12),
                            const SizedBox(width: 3),
                            Text(_selectedGround!.area,
                                style: TextStyle(color: context.fgSub, fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Ground list
          if (_selectedGround == null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                    color: context.panel, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search_rounded, color: context.fgSub, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _filterQuery = v),
                      style: TextStyle(color: context.fg, fontSize: 14, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Search ground or area...',
                        hintStyle: TextStyle(color: context.fgSub, fontSize: 14),
                        border: InputBorder.none, isDense: true,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            Expanded(
              child: groundsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
                error: (_, __) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sports_cricket_rounded,
                          size: 40, color: context.fgSub.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text('No slots available on this day',
                          style: TextStyle(
                              color: context.fgSub,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Try a different date',
                          style: TextStyle(
                              color: context.fgSub.withValues(alpha: 0.5),
                              fontSize: 12)),
                    ],
                  ),
                ),
                data: (grounds) {
                  final filtered = _filterQuery.isEmpty
                      ? grounds
                      : grounds.where((g) =>
                          g.name.toLowerCase().contains(_filterQuery.toLowerCase()) ||
                          g.area.toLowerCase().contains(_filterQuery.toLowerCase())).toList();
                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sports_cricket_rounded,
                              size: 40, color: context.fgSub.withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          Text('No slots available on this day',
                              style: TextStyle(
                                  color: context.fgSub,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Try a different date',
                              style: TextStyle(
                                  color: context.fgSub.withValues(alpha: 0.5),
                                  fontSize: 12)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final g = filtered[i];
                      final hotCount = g.slots.where((s) => s.hasOpponent).length;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedGround = g),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: context.panel,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image banner
                              AspectRatio(
                                aspectRatio: 16 / 7,
                                child: g.photoUrl != null && g.photoUrl!.isNotEmpty
                                    ? Image.network(g.photoUrl!, fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _GroundImagePlaceholder())
                                    : _GroundImagePlaceholder(),
                              ),
                              // Info
                              Padding(
                                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(g.name,
                                              style: TextStyle(
                                                color: context.fg, fontSize: 15,
                                                fontWeight: FontWeight.w800, letterSpacing: -0.2,
                                              )),
                                          const SizedBox(height: 4),
                                          Row(children: [
                                            Icon(Icons.location_on_rounded,
                                                color: context.fgSub, size: 12),
                                            const SizedBox(width: 3),
                                            Text(g.area,
                                                style: TextStyle(color: context.fgSub,
                                                    fontSize: 12, fontWeight: FontWeight.w500)),
                                            const SizedBox(width: 10),
                                            Icon(Icons.schedule_rounded,
                                                color: context.fgSub, size: 12),
                                            const SizedBox(width: 3),
                                            Text('${g.slots.length} slots',
                                                style: TextStyle(color: context.fgSub,
                                                    fontSize: 12, fontWeight: FontWeight.w500)),
                                          ]),
                                        ],
                                      ),
                                    ),
                                    if (hotCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: context.accent.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text('⚡ $hotCount rival${hotCount > 1 ? 's' : ''}',
                                            style: TextStyle(color: context.accent,
                                                fontSize: 11, fontWeight: FontWeight.w700)),
                                      ),
                                  ],
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
          ]

          // Slot picker
          else ...[
            // Ground image strip
            if (_selectedGround!.photoUrl != null && _selectedGround!.photoUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 16 / 6,
                    child: Image.network(_selectedGround!.photoUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('Pick a slot',
                  style: TextStyle(color: context.fgSub, fontSize: 12,
                      fontWeight: FontWeight.w700, letterSpacing: 0.8)),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.6,
                ),
                itemCount: _selectedGround!.slots.length,
                itemBuilder: (_, i) {
                  final slot = _selectedGround!.slots[i];
                  final taken = _alreadyPicked(slot);
                  final hot = slot.hasOpponent;
                  return GestureDetector(
                    onTap: taken ? null : () {
                      widget.onPick(MmGroundSlotPick(ground: _selectedGround!, slot: slot));
                      Navigator.pop(context);
                    },
                    child: AnimatedOpacity(
                      opacity: taken ? 0.3 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Container(
                        decoration: BoxDecoration(
                          color: hot
                              ? context.accent.withValues(alpha: 0.10)
                              : context.panel,
                          borderRadius: BorderRadius.circular(12),
                          border: hot
                              ? Border.all(color: context.accent.withValues(alpha: 0.4))
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hot)
                              const Text('⚡', style: TextStyle(fontSize: 10)),
                            if (slot.endTime != null && slot.endTime!.isNotEmpty) ...[
                              Text(slot.startLabel,
                                  style: TextStyle(
                                    color: hot ? context.accent : context.fg,
                                    fontSize: 13, fontWeight: FontWeight.w800,
                                  )),
                              Text('→ ${slot.endLabel}',
                                  style: TextStyle(
                                    color: hot ? context.accent.withValues(alpha: 0.8) : context.fgSub,
                                    fontSize: 11, fontWeight: FontWeight.w700,
                                  )),
                            ] else
                              Text(slot.displayTime,
                                  style: TextStyle(
                                    color: hot ? context.accent : context.fg,
                                    fontSize: 14, fontWeight: FontWeight.w800,
                                  )),
                            const SizedBox(height: 2),
                            Text('₹${slot.priceRupees}',
                                style: TextStyle(color: context.fgSub,
                                    fontSize: 11, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GroundImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.panel,
      child: Center(
        child: Icon(Icons.stadium_rounded,
            color: context.stroke, size: 36),
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
                _CalendarPicker(selected: date, onSelect: onDate),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? context.ctaBg.withValues(alpha: 0.12) : context.panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? context.ctaBg : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Logo / initials avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: context.bg,
              ),
              clipBehavior: Clip.antiAlias,
              child: team.logoUrl != null && team.logoUrl!.isNotEmpty
                  ? Image.network(
                      team.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _TeamInitials(team.name),
                    )
                  : _TeamInitials(team.name),
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
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      _Pill(team.ageGroupLabel),
                      if (team.memberCount > 0) ...[
                        const SizedBox(width: 6),
                        _Pill('${team.memberCount} players'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: context.ctaBg, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Team dropdown ─────────────────────────────────────────────────────────────

class _TeamDropdown extends StatelessWidget {
  const _TeamDropdown({
    required this.teams,
    required this.selected,
    required this.onSelect,
  });
  final List<MmTeam> teams;
  final MmTeam? selected;
  final ValueChanged<MmTeam> onSelect;

  void _open(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TeamPickerSheet(
        teams: teams,
        selected: selected,
        onSelect: (t) {
          onSelect(t);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (selected == null) {
      return GestureDetector(
        onTap: () => _open(context),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: context.panel,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.groups_rounded, color: context.fgSub, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  teams.isEmpty ? 'No teams found' : 'Select your team',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.expand_more_rounded, color: context.fgSub, size: 20),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _open(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.panel,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: context.bg,
              ),
              clipBehavior: Clip.antiAlias,
              child: selected!.logoUrl != null && selected!.logoUrl!.isNotEmpty
                  ? Image.network(
                      selected!.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _TeamInitials(selected!.name),
                    )
                  : _TeamInitials(selected!.name),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selected!.name,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      _Pill(selected!.ageGroupLabel),
                      if (selected!.memberCount > 0) ...[
                        const SizedBox(width: 6),
                        _Pill('${selected!.memberCount} players'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.expand_more_rounded, color: context.fgSub, size: 20),
          ],
        ),
      ),
    );
  }
}

class _TeamPickerSheet extends StatelessWidget {
  const _TeamPickerSheet({
    required this.teams,
    required this.selected,
    required this.onSelect,
  });
  final List<MmTeam> teams;
  final MmTeam? selected;
  final ValueChanged<MmTeam> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 16),
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: context.stroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              'Select Team',
              style: TextStyle(
                color: context.fg,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: teams.length,
              itemBuilder: (_, i) => _TeamRow(
                team: teams[i],
                selected: selected?.id == teams[i].id,
                onTap: () => onSelect(teams[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamInitials extends StatelessWidget {
  const _TeamInitials(this.name);
  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    return Container(
      color: context.accent.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: context.accent,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: context.stroke.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: context.fgSub,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CalendarPicker extends StatefulWidget {
  const _CalendarPicker({required this.selected, required this.onSelect});
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  State<_CalendarPicker> createState() => _CalendarPickerState();
}

class _CalendarPickerState extends State<_CalendarPicker> {
  static const _dn = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _mn = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  late DateTime _month; // first day of displayed month
  final DateTime _today = DateTime.now();
  late final DateTime _maxDate;

  @override
  void initState() {
    super.initState();
    _month = DateTime(_today.year, _today.month, 1);
    _maxDate = DateTime(_today.year, _today.month, _today.day + 60);
  }

  bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isSelectable(DateTime d) =>
      !d.isBefore(DateTime(_today.year, _today.month, _today.day)) &&
      !d.isAfter(_maxDate);

  void _prevMonth() {
    final prev = DateTime(_month.year, _month.month - 1, 1);
    if (!prev.isBefore(DateTime(_today.year, _today.month, 1))) {
      setState(() => _month = prev);
    }
  }

  void _nextMonth() {
    final next = DateTime(_month.year, _month.month + 1, 1);
    if (next.isBefore(DateTime(_maxDate.year, _maxDate.month + 1, 1))) {
      setState(() => _month = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    // days of week offset (Mon=1 → index 0)
    final firstWeekday = _month.weekday; // 1=Mon..7=Sun
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final totalCells = firstWeekday - 1 + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Month nav
        Row(
          children: [
            GestureDetector(
              onTap: _prevMonth,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.chevron_left_rounded,
                    color: context.fgSub, size: 20),
              ),
            ),
            Expanded(
              child: Text(
                '${_mn[_month.month - 1]} ${_month.year}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            GestureDetector(
              onTap: _nextMonth,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.chevron_right_rounded,
                    color: context.fgSub, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Day-of-week headers
        Row(
          children: List.generate(7, (i) => Expanded(
            child: Center(
              child: Text(
                _dn[i],
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          )),
        ),
        const SizedBox(height: 6),
        // Grid
        for (int r = 0; r < rows; r++) ...[
          Row(
            children: List.generate(7, (c) {
              final cell = r * 7 + c;
              final day = cell - (firstWeekday - 2); // 1-based day
              if (day < 1 || day > daysInMonth) {
                return const Expanded(child: SizedBox());
              }
              final d = DateTime(_month.year, _month.month, day);
              final sel = _same(d, widget.selected);
              final isToday = _same(d, _today);
              final selectable = _isSelectable(d);
              return Expanded(
                child: GestureDetector(
                  onTap: selectable ? () => widget.onSelect(d) : null,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      height: 36,
                      decoration: BoxDecoration(
                        color: sel
                            ? context.ctaBg
                            : isToday
                                ? context.accent.withValues(alpha: 0.12)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: sel
                              ? context.ctaFg
                              : selectable
                                  ? (isToday ? context.accent : context.fg)
                                  : context.fgSub.withValues(alpha: 0.3),
                          fontSize: 13,
                          fontWeight: sel || isToday
                              ? FontWeight.w900
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          if (r < rows - 1) const SizedBox(height: 2),
        ],
      ],
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
