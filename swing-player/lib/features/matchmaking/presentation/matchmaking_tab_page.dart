import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/matchmaking_models.dart';
import 'matchmaking_page.dart' show MatchFormat;
import 'matchmaking_providers.dart';

// ignore: avoid_print
void _mmLog(String msg) => debugPrint('[MM:page] $msg');

// ── Ball type helpers ─────────────────────────────────────────────────────────

Color _ballTypeColor(String bt) => switch (bt) {
      'LEATHER' => const Color(0xFFB91C1C),
      'TENNIS'  => const Color(0xFF65A30D),
      'TAPE'    => const Color(0xFF374151),
      'RUBBER'  => const Color(0xFFEA580C),
      _         => const Color(0xFF6B7280),
    };

String _ballTypeLabel(String bt) => switch (bt) {
      'LEATHER' => 'Leather',
      'TENNIS' => 'Tennis',
      'TAPE' => 'Tape Ball',
      'RUBBER' => 'Rubber',
      _ => bt,
    };

String? _formatOversHint(MatchFormat f) => switch (f) {
      MatchFormat.t10 => '10 overs',
      MatchFormat.t20 => '20 overs',
      MatchFormat.odi => '50 overs',
      _ => null,
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

enum _LobbyState { idle, entering, searching, matched, confirming, waitingOpponent, confirmed }

// ── Tab page ──────────────────────────────────────────────────────────────────

class MatchmakingTabPage extends ConsumerStatefulWidget {
  const MatchmakingTabPage({super.key, this.onFindMatch});
  final VoidCallback? onFindMatch;

  @override
  ConsumerState<MatchmakingTabPage> createState() =>
      _MatchmakingTabPageState();
}

class _MatchmakingTabPageState extends ConsumerState<MatchmakingTabPage> {
  int _tab = 1; // 0=Open  1=Find  2=Challenge  3=Matches

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
  List<MmLobbyStatusPick> _restoredPicks = []; // from active lobby on restart
  bool _lobbyRestored = false; // guard against double-restore

  // Payment
  late final Razorpay _razorpay;

  bool get _isActive =>
      _lobbyState != _LobbyState.idle && _lobbyState != _LobbyState.entering;

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_date);

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreActiveLobby());
  }

  Future<void> _restoreActiveLobby() async {
    if (_lobbyRestored) { _mmLog('_restoreActiveLobby → skipped (already ran)'); return; }
    _lobbyRestored = true;
    _mmLog('_restoreActiveLobby → start');
    try {
      final repo = ref.read(matchmakingRepositoryProvider);
      final active = await repo.getActiveLobby();
      if (active == null || !mounted) {
        _mmLog('_restoreActiveLobby → no active lobby (or unmounted)');
        return;
      }
      _mmLog('_restoreActiveLobby → found lobbyId=${active.lobbyId} status=${active.status} '
          'format=${active.format} date=${active.date} team=${active.teamName} picks=${active.picks.length}');

      // Restore format and date from the lobby so _SearchingFind shows correct info
      MatchFormat restoredFormat = _format;
      DateTime restoredDate = _date;
      if (active.format != null) {
        restoredFormat = MatchFormat.values.firstWhere(
          (f) => f.apiValue == active.format,
          orElse: () => MatchFormat.t20,
        );
      }
      if (active.date != null) {
        restoredDate = DateTime.tryParse(active.date!) ?? _date;
      }
      // Restore team name if we don't have it yet (best-effort from teams provider)
      MmTeam? restoredTeam = _team;
      if (restoredTeam == null && active.teamId != null && active.teamName != null) {
        restoredTeam = MmTeam(id: active.teamId!, name: active.teamName!, ageGroupLabel: '');
      }

      setState(() {
        _lobbyId = active.lobbyId;
        _format = restoredFormat;
        _date = restoredDate;
        if (restoredTeam != null) _team = restoredTeam;
        _restoredPicks = active.picks;
        if (active.status == 'matched' && active.match != null) {
          _matchSummary = active.match;
          _lobbyState = active.match!.myTeamConfirmed
              ? _LobbyState.waitingOpponent
              : _LobbyState.matched;
        } else if (active.status == 'confirmed') {
          _lobbyState = _LobbyState.confirmed;
        } else {
          _lobbyState = _LobbyState.searching;
        }
      });
      _mmLog('_restoreActiveLobby → setState done, lobbyState=$_lobbyState team=${_team?.name} format=${_format.apiValue} date=$_dateStr');
      if (_lobbyState == _LobbyState.searching || _lobbyState == _LobbyState.waitingOpponent) _startPolling();
    } catch (e, st) {
      _mmLog('_restoreActiveLobby ERROR: $e\n$st');
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _razorpay.clear();
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
        final match = status.match!;
        _pollTimer?.cancel();
        // If we're waiting for opponent and both confirmed → done
        if (_lobbyState == _LobbyState.waitingOpponent &&
            match.myTeamConfirmed && match.opponentConfirmed) {
          setState(() => _lobbyState = _LobbyState.confirmed);
          return;
        }
        setState(() {
          _matchSummary = match;
          _lobbyState = match.myTeamConfirmed
              ? _LobbyState.waitingOpponent
              : _LobbyState.matched;
        });
      } else if (status.status == 'confirmed') {
        _pollTimer?.cancel();
        setState(() => _lobbyState = _LobbyState.confirmed);
      } else if (status.status == 'expired' || status.status == 'cancelled') {
        _pollTimer?.cancel();
        setState(() {
          _matchSummary = null;
          _lobbyState = _LobbyState.idle;
        });
      }
    } catch (_) {}
  }

  Future<void> _instantChallenge(MmOpenLobby lobby, {MmTeam? withTeam}) async {
    final team = withTeam ?? _team;
    _mmLog('_instantChallenge → lobbyId=${lobby.lobbyId} team=${team?.id} teamName=${team?.name}');
    if (team == null) {
      _mmLog('_instantChallenge → aborted: team is null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a team first')),
      );
      return;
    }
    // If already searching with an old lobby, cancel it first so we don't leave orphans
    final oldLobbyId = _lobbyId;
    if (oldLobbyId != null && _lobbyState == _LobbyState.searching) {
      _mmLog('_instantChallenge → leaving old lobby $oldLobbyId before joining');
      _pollTimer?.cancel();
      try {
        await ref.read(matchmakingRepositoryProvider).leaveLobby(oldLobbyId);
      } catch (e) {
        _mmLog('_instantChallenge → leave old lobby error (ignored): $e');
      }
    }
    setState(() { _lobbyState = _LobbyState.entering; _error = null; });
    try {
      final repo = ref.read(matchmakingRepositoryProvider);
      final result = await repo.joinLobby(lobby.lobbyId, team.id);
      _mmLog('_instantChallenge → join success lobbyId=${result.lobbyId} status=${result.status} match=${result.match?.matchId}');
      if (!mounted) return;
      setState(() {
        _lobbyId = result.lobbyId;
        _team = team;
        _matchSummary = result.match;
        _lobbyState = _LobbyState.matched;
        _restoredPicks = [];
        _tab = 1;
      });
      ref.invalidate(mmOpenLobbiesProvider((date: null, format: null)));
    } catch (e, st) {
      _mmLog('_instantChallenge ERROR: $e\n$st');
      if (!mounted) return;
      final msg = _parseError(e);
      setState(() { _lobbyState = _LobbyState.idle; _error = msg; _tab = 1; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
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
    setState(() { _lobbyState = _LobbyState.confirming; _error = null; });
    try {
      final repo = ref.read(matchmakingRepositoryProvider);
      final result = await repo.confirmMatch(matchId, lobbyId);
      if (!mounted) return;
      if (result.status == 'confirmed') {
        setState(() => _lobbyState = _LobbyState.confirmed);
      } else {
        setState(() => _lobbyState = _LobbyState.waitingOpponent);
        _startPolling();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _lobbyState = _LobbyState.matched; _error = _parseError(e); });
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final repo = ref.read(matchmakingRepositoryProvider);
      await repo.verifyMatchPayment(
        razorpayPaymentId: response.paymentId ?? '',
        razorpayOrderId: response.orderId ?? '',
        razorpaySignature: response.signature ?? '',
      );
      if (!mounted) return;
      // Refresh match summary to get latest paid flags
      final lobbyId = _lobbyId;
      if (lobbyId != null) {
        try {
          final status = await repo.getLobbyStatus(lobbyId);
          if (mounted && status.match != null) {
            final match = status.match!;
            if (match.myTeamPaid && match.opponentPaid) {
              setState(() => _lobbyState = _LobbyState.confirmed);
              return;
            }
            setState(() {
              _matchSummary = match;
              _lobbyState = _LobbyState.waitingOpponent;
            });
            _startPolling();
            return;
          }
        } catch (_) {}
      }
      setState(() => _lobbyState = _LobbyState.waitingOpponent);
      _startPolling();
    } catch (e) {
      if (!mounted) return;
      setState(() { _lobbyState = _LobbyState.matched; _error = 'Payment done but confirmation failed. Contact support.'; });
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() { _lobbyState = _LobbyState.matched; _error = response.message ?? 'Payment was not completed.'; });
  }

  // Back arrow — cancel silently and return to Open tab, preserving form state
  Future<void> _goBackFromMatch() async {
    final matchId = _matchSummary?.matchId;
    final lobbyId = _lobbyId;
    _pollTimer?.cancel();
    final repo = ref.read(matchmakingRepositoryProvider);
    if (matchId != null && lobbyId != null) {
      try { await repo.declineMatch(matchId, lobbyId); } catch (_) {}
      try { await repo.leaveLobby(lobbyId); } catch (_) {}
    }
    if (!mounted) return;
    ref.invalidate(mmOpenLobbiesProvider((date: null, format: null)));
    setState(() {
      _lobbyId = null;
      _matchSummary = null;
      _lobbyState = _LobbyState.idle;
      _tab = 0;
      // intentionally keep _picks, _team, _format, _date, _ballType
    });
  }

  Future<void> _declineMatch() async {
    final matchId = _matchSummary?.matchId;
    final lobbyId = _lobbyId;
    if (matchId == null || lobbyId == null) return;
    _pollTimer?.cancel();
    final repo = ref.read(matchmakingRepositoryProvider);
    try { await repo.declineMatch(matchId, lobbyId); } catch (_) {}
    try { await repo.leaveLobby(lobbyId); } catch (_) {}
    if (!mounted) return;
    setState(() {
      _lobbyId = null;
      _matchSummary = null;
      _lobbyState = _LobbyState.idle;
      _tab = 0;
      // intentionally keep _picks, _team, _format, _date, _ballType
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
                    'Matchup',
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
                              ? 'My Matchup'
                              : _lobbyState == _LobbyState.waitingOpponent
                                  ? 'Waiting…'
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
                const SizedBox(width: 24),
                _TabLabel(
                  label: 'Matches',
                  active: _tab == 3,
                  onTap: () => setState(() => _tab = 3),
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
                  ownLobbyId: _lobbyId,
                  onCounter: (lobby) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _PlayConfirmSheet(
                        lobby: lobby,
                        initialTeam: _team,
                        onConfirm: (team) {
                          Navigator.pop(context);
                          _instantChallenge(lobby, withTeam: team);
                        },
                      ),
                    );
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
                  restoredPicks: _restoredPicks,
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
                  onInstantChallenge: _instantChallenge,
                  onLeave: _leaveLobby,
                  onConfirm: _confirmMatch,
                  onDecline: _declineMatch,
                  onBack: _goBackFromMatch,
                  onDone: _resetToIdle,
                ),
                // Tab 2: Challenge
                const _ChallengeTab(),
                // Tab 3: Matches
                const _MatchesTab(),
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
    this.ownLobbyId,
  });
  final MmLobbiesQuery query;
  final ValueChanged<MmOpenLobby> onCounter;
  final String? ownLobbyId;

  @override
  ConsumerState<_OpenTab> createState() => _OpenTabState();
}

class _OpenTabState extends ConsumerState<_OpenTab> {
  String? _selectedDate;
  String? _ballTypeFilter;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Refresh immediately on mount so stale cached data is replaced right away
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.invalidate(mmOpenLobbiesProvider(widget.query));
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      ref.invalidate(mmOpenLobbiesProvider(widget.query));
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  bool _isSlotPast(MmOpenLobby l) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (l.date != todayStr) return false;
    if (l.slotTime.isEmpty) return false;
    final parts = l.slotTime.split(':');
    if (parts.length < 2) return false;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final now = DateTime.now().toUtc();
    final nowIst = now.add(const Duration(hours: 5, minutes: 30));
    return (h * 60 + m) <= (nowIst.hour * 60 + nowIst.minute);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(mmOpenLobbiesProvider(widget.query));
    // While refreshing in the background, show previous data instead of a blank spinner
    final lobbiesSnapshot = async.valueOrNull;
    if (async.isLoading && lobbiesSnapshot == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 1.5));
    }
    if (async.hasError && lobbiesSnapshot == null) {
      return Center(
        child: Text('Could not load open games', style: TextStyle(color: context.fgSub, fontSize: 13)),
      );
    }
    return _buildLobbiesList(context, lobbiesSnapshot ?? []);
  }

  Widget _buildLobbiesList(BuildContext context, List<MmOpenLobby> lobbies) {
        final others = lobbies
            .where((l) => !_isSlotPast(l))
            .where((l) => widget.ownLobbyId == null || l.lobbyId != widget.ownLobbyId)
            .toList();

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
                child: filtered.isEmpty
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
                          for (final lobby in filtered)
                            _OpenLobbyCard(
                              lobby: lobby,
                              onCounter: () => widget.onCounter(lobby),
                            ),
                        ],
                      ),
              ),
            ),
          ],
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
              _MiniChip(label: lobby.format, context: context),
            ],
          ),
          const SizedBox(height: 10),
          // ── Info rows ─────────────────────────────────────────────────
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
          if (lobby.ballType != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: _ballTypeColor(lobby.ballType!),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  _ballTypeLabel(lobby.ballType!),
                  style: TextStyle(color: context.fgSub, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
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
                child: const Text(
                  'Matchup',
                  style: TextStyle(
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

// ── Play confirmation sheet ───────────────────────────────────────────────────

class _PlayConfirmSheet extends ConsumerStatefulWidget {
  const _PlayConfirmSheet({
    required this.lobby,
    required this.initialTeam,
    required this.onConfirm,
  });

  final MmOpenLobby lobby;
  final MmTeam? initialTeam;
  final ValueChanged<MmTeam> onConfirm;

  @override
  ConsumerState<_PlayConfirmSheet> createState() => _PlayConfirmSheetState();
}

class _PlayConfirmSheetState extends ConsumerState<_PlayConfirmSheet> {
  MmTeam? _selected;
  bool _onConfirmPage = false; // false = details, true = review & confirm

  @override
  void initState() {
    super.initState();
    _selected = widget.initialTeam;
  }

  int get _groundFeeRupees => widget.lobby.pricePerTeamPaise ~/ 100;
  int get _depositRupees => 500;
  int get _balanceRupees =>
      ((widget.lobby.pricePerTeamPaise - 50000).clamp(0, 999999999) ~/ 100);

  @override
  Widget build(BuildContext context) {
    final teamsAsync = ref.watch(mmTeamsProvider);
    final teams = teamsAsync.valueOrNull ?? [];
    if (_selected == null && teams.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selected == null) setState(() => _selected = teams.first);
      });
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) {
        final offset = child.key == const ValueKey('confirm')
            ? const Offset(1, 0)
            : const Offset(-1, 0);
        return SlideTransition(
          position: Tween<Offset>(begin: offset, end: Offset.zero).animate(anim),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      child: _onConfirmPage
          ? _ConfirmPage(
              key: const ValueKey('confirm'),
              lobby: widget.lobby,
              team: _selected,
              groundFeeRupees: _groundFeeRupees,
              depositRupees: _depositRupees,
              balanceRupees: _balanceRupees,
              onBack: () => setState(() => _onConfirmPage = false),
              onConfirm: () => widget.onConfirm(_selected!),
            )
          : _DetailsPage(
              key: const ValueKey('details'),
              lobby: widget.lobby,
              teams: teams,
              teamsLoading: teamsAsync.isLoading,
              selected: _selected,
              groundFeeRupees: _groundFeeRupees,
              depositRupees: _depositRupees,
              balanceRupees: _balanceRupees,
              onSelectTeam: (t) => setState(() => _selected = t),
              onReview: () => setState(() => _onConfirmPage = true),
            ),
    );
  }
}

// ── Page 1: Details + fee breakdown ──────────────────────────────────────────

class _DetailsPage extends StatelessWidget {
  const _DetailsPage({
    super.key,
    required this.lobby,
    required this.teams,
    required this.teamsLoading,
    required this.selected,
    required this.groundFeeRupees,
    required this.depositRupees,
    required this.balanceRupees,
    required this.onSelectTeam,
    required this.onReview,
  });

  final MmOpenLobby lobby;
  final List<MmTeam> teams;
  final bool teamsLoading;
  final MmTeam? selected;
  final int groundFeeRupees;
  final int depositRupees;
  final int balanceRupees;
  final ValueChanged<MmTeam> onSelectTeam;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final canReview = selected != null;
    final myTeamName = selected?.name ?? 'Your team';
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: context.stroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Hero: opponent ───────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MATCHUP INVITE',
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                lobby.teamName,
                                style: TextStyle(
                                  color: context.fg,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  lobby.dateLabel,
                                  style: TextStyle(
                                    color: context.fg,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  lobby.displaySlot,
                                  style: TextStyle(
                                    color: context.fgSub,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _MiniChip(label: lobby.format, context: context),
                            if (lobby.ballType != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 7, height: 7,
                                decoration: BoxDecoration(
                                  color: _ballTypeColor(lobby.ballType!),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _ballTypeLabel(lobby.ballType!),
                                style: TextStyle(
                                  color: context.fgSub,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            if (lobby.ageGroup.isNotEmpty && lobby.ageGroup != 'Open') ...[
                              const SizedBox(width: 6),
                              _MiniChip(label: lobby.ageGroup, context: context),
                            ],
                          ],
                        ),
                        if (lobby.arenaName.isNotEmpty || lobby.groundName.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.stadium_rounded, size: 12, color: context.accent),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  lobby.arenaName.isNotEmpty
                                      ? lobby.arenaName
                                      : lobby.groundName,
                                  style: TextStyle(
                                    color: context.accent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── Total booking fee + split ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: Text(
                                'TOTAL BOOKING FEE',
                                style: TextStyle(
                                  color: context.fgSub,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            Text(
                              '₹${groundFeeRupees * 2}',
                              style: TextStyle(
                                color: context.fg,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // ── Team split ──────────────────────────────────
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: context.panel,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lobby.teamName,
                                        style: TextStyle(
                                          color: context.fgSub,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹$groundFeeRupees',
                                        style: TextStyle(
                                          color: context.fg,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'their share',
                                        style: TextStyle(
                                          color: context.fgSub.withValues(alpha: 0.45),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(width: 1, color: context.stroke),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: context.accent.withValues(alpha: 0.08),
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        myTeamName,
                                        style: TextStyle(
                                          color: context.accent.withValues(alpha: 0.7),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹$groundFeeRupees',
                                        style: TextStyle(
                                          color: context.accent,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'your share',
                                        style: TextStyle(
                                          color: context.accent.withValues(alpha: 0.45),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // ── Pay schedule ────────────────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PAY NOW',
                                    style: TextStyle(
                                      color: context.accent,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '₹$depositRupees',
                                    style: TextStyle(
                                      color: context.fg,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'refundable deposit',
                                    style: TextStyle(
                                      color: context.success,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 56,
                              color: context.stroke.withValues(alpha: 0.4),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AT GROUND',
                                      style: TextStyle(
                                        color: context.fgSub,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '₹$balanceRupees',
                                      style: TextStyle(
                                        color: context.fg,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'balance due',
                                      style: TextStyle(
                                        color: context.fgSub.withValues(alpha: 0.45),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(height: 1, color: context.stroke.withValues(alpha: 0.4)),
                        const SizedBox(height: 10),
                        Text(
                          'Deposit auto-refunded if opponent doesn\'t confirm within 4 hours.',
                          style: TextStyle(
                            color: context.fgSub.withValues(alpha: 0.5),
                            fontSize: 11,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Playing as ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: Text(
                      'PLAYING AS',
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  if (teamsLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: LinearProgressIndicator(minHeight: 1),
                    )
                  else if (teams.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Text(
                        'No teams found. Create a team first.',
                        style: TextStyle(color: context.fgSub, fontSize: 13),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      itemCount: teams.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: context.stroke.withValues(alpha: 0.4)),
                      itemBuilder: (_, i) {
                        final team = teams[i];
                        final sel = selected?.id == team.id;
                        return GestureDetector(
                          onTap: () => onSelectTeam(team),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: context.panel,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: team.logoUrl != null && team.logoUrl!.isNotEmpty
                                      ? Image.network(team.logoUrl!, fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _TeamInitials(team.name))
                                      : _TeamInitials(team.name),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        team.name,
                                        style: TextStyle(
                                          color: context.fg,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      Text(
                                        '${team.ageGroupLabel}  ·  ${team.memberCount} members',
                                        style: TextStyle(color: context.fgSub, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 140),
                                  width: 20, height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: sel ? context.accent : Colors.transparent,
                                    border: Border.all(
                                      color: sel ? context.accent : context.stroke,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: sel
                                      ? const Icon(Icons.check_rounded,
                                          color: Colors.white, size: 12)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  // ── CTA ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: GestureDetector(
                      onTap: canReview ? onReview : null,
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        height: 52,
                        decoration: BoxDecoration(
                          color: canReview ? context.ctaBg : context.panel,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              canReview ? 'Review & Confirm' : 'Select your team',
                              style: TextStyle(
                                color: canReview ? context.ctaFg : context.fgSub,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (canReview) ...[
                              const SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded,
                                  color: context.ctaFg.withValues(alpha: 0.7), size: 16),
                            ],
                          ],
                        ),
                      ),
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

// ── Page 2: Review & confirm ──────────────────────────────────────────────────

class _ConfirmPage extends StatelessWidget {
  const _ConfirmPage({
    super.key,
    required this.lobby,
    required this.team,
    required this.groundFeeRupees,
    required this.depositRupees,
    required this.balanceRupees,
    required this.onBack,
    required this.onConfirm,
  });

  final MmOpenLobby lobby;
  final MmTeam? team;
  final int groundFeeRupees;
  final int depositRupees;
  final int balanceRupees;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final teamName = team?.name ?? 'Your team';
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: context.stroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // ── Back ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 20, 0),
            child: GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: context.fgSub),
                    const SizedBox(width: 4),
                    Text(
                      'Back',
                      style: TextStyle(
                          color: context.fgSub,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONFIRM MATCHUP',
                      style: TextStyle(
                        color: context.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── VS row ──────────────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            teamName,
                            style: TextStyle(
                              color: context.fg,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'vs',
                            style: TextStyle(
                              color: context.fgSub,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            lobby.teamName,
                            style: TextStyle(
                              color: context.fg,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        lobby.arenaName.isNotEmpty ? lobby.arenaName : lobby.groundName,
                        lobby.format,
                        lobby.displaySlot,
                        lobby.dateLabel,
                      ].where((s) => s.isNotEmpty).join('  ·  '),
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // ── Booking summary ─────────────────────────────────
                    const SizedBox(height: 28),
                    Text(
                      'BOOKING SUMMARY',
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Total booking fee
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Booking Fee',
                                style: TextStyle(
                                  color: context.fgSub,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$teamName & ${lobby.teamName} · equal split',
                                style: TextStyle(
                                  color: context.fgSub.withValues(alpha: 0.45),
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${groundFeeRupees * 2}',
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Your share panel
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: context.panel,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'YOUR SHARE',
                                  style: TextStyle(
                                    color: context.fgSub,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  teamName,
                                  style: TextStyle(
                                    color: context.fgSub,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹$groundFeeRupees',
                            style: TextStyle(
                              color: context.fg,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Pay schedule
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PAY NOW',
                                style: TextStyle(
                                  color: context.accent,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '₹$depositRupees',
                                style: TextStyle(
                                  color: context.fg,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'deposit · refundable',
                                style: TextStyle(
                                  color: context.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 58,
                          color: context.stroke.withValues(alpha: 0.4),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AT GROUND',
                                  style: TextStyle(
                                    color: context.fgSub,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '₹$balanceRupees',
                                  style: TextStyle(
                                    color: context.fg,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'balance due',
                                  style: TextStyle(
                                    color: context.fgSub.withValues(alpha: 0.45),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ── T&C ─────────────────────────────────────────────
                    const SizedBox(height: 20),
                    Divider(height: 1, color: context.stroke.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    Text(
                      'By paying you agree: the ₹$depositRupees deposit is non-refundable once both teams have confirmed. If the opponent does not pay within 4 hours, your deposit is fully refunded automatically.',
                      style: TextStyle(
                        color: context.fgSub.withValues(alpha: 0.5),
                        fontSize: 11,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),

          // ── Final CTA ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: GestureDetector(
              onTap: onConfirm,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: context.ctaBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Pay ₹$depositRupees  →  Lock Slot',
                  style: TextStyle(
                    color: context.ctaFg,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
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

// ── Tab 1: Find ───────────────────────────────────────────────────────────────

class _FindTab extends StatelessWidget {
  const _FindTab({
    required this.lobbyState,
    required this.team,
    required this.format,
    required this.ballType,
    required this.date,
    required this.picks,
    required this.restoredPicks,
    required this.matchSummary,
    required this.error,
    required this.onTeam,
    required this.onFormat,
    required this.onBallType,
    required this.onDate,
    required this.onAddPick,
    required this.onRemovePick,
    required this.onEnter,
    required this.onInstantChallenge,
    required this.onLeave,
    required this.onConfirm,
    required this.onDecline,
    required this.onBack,
    required this.onDone,
  });

  final _LobbyState lobbyState;
  final MmTeam? team;
  final MatchFormat format;
  final String? ballType;
  final DateTime date;
  final List<MmGroundSlotPick> picks;
  final List<MmLobbyStatusPick> restoredPicks;
  final MmMatchSummary? matchSummary;
  final String? error;
  final ValueChanged<MmTeam> onTeam;
  final ValueChanged<MatchFormat> onFormat;
  final ValueChanged<String?> onBallType;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<MmGroundSlotPick> onAddPick;
  final ValueChanged<MmGroundSlotPick> onRemovePick;
  final VoidCallback onEnter;
  final ValueChanged<MmOpenLobby> onInstantChallenge;
  final VoidCallback onLeave;
  final VoidCallback onConfirm;
  final VoidCallback onDecline;
  final VoidCallback onBack;
  final VoidCallback onDone;

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
            onInstantChallenge: onInstantChallenge,
          ),
        _LobbyState.searching => _SearchingFind(
            key: const ValueKey('searching'),
            team: team,
            format: format,
            ballType: ballType,
            date: date,
            picks: picks,
            restoredPicks: restoredPicks,
            onLeave: onLeave,
            onInstantChallenge: onInstantChallenge,
          ),
        _LobbyState.matched || _LobbyState.confirming || _LobbyState.waitingOpponent => _MatchedFind(
            key: const ValueKey('matched'),
            team: team,
            format: format,
            date: date,
            matchSummary: matchSummary,
            confirming: lobbyState == _LobbyState.confirming,
            waitingOpponent: lobbyState == _LobbyState.waitingOpponent,
            onConfirm: onConfirm,
            onDecline: onDecline,
            onBack: onBack,
          ),
        _LobbyState.confirmed => _ConfirmedFind(
            key: const ValueKey('confirmed'),
            matchSummary: matchSummary,
            team: team,
            onDone: onDone,
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
    required this.onInstantChallenge,
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
  final ValueChanged<MmOpenLobby> onInstantChallenge;

  @override
  ConsumerState<_IdleFind> createState() => _IdleFindState();
}

class _IdleFindState extends ConsumerState<_IdleFind> {
  // 0=team  1=format  2=ball  3=date  4=ground
  int _step = 0;
  int _maxStep = 0;
  int _customOvers = 20;

  static const _sectionLabels = ['YOUR TEAM', 'FORMAT', 'BALL TYPE', 'DATE', 'GROUND & SLOT'];

  @override
  void initState() {
    super.initState();
    // Restore to ground section if state was pre-filled (e.g. returning from search)
    if (widget.team != null) {
      _step = 4;
      _maxStep = 4;
    }
  }

  void _advance() {
    if (!mounted) return;
    final next = (_step + 1).clamp(0, 4);
    setState(() {
      _step = next;
      if (next > _maxStep) _maxStep = next;
    });
  }

  void _jumpTo(int s) => setState(() => _step = s);

  String _dateLabel(DateTime d) {
    final today = DateTime.now();
    final t = DateTime(today.year, today.month, today.day);
    final dd = DateTime(d.year, d.month, d.day);
    if (dd == t) return 'Today';
    if (dd == t.add(const Duration(days: 1))) return 'Tomorrow';
    return DateFormat('MMM d').format(d);
  }

  String _summaryFor(int i) => switch (i) {
        0 => widget.team?.name ?? '—',
        1 => widget.format == MatchFormat.custom
            ? 'Custom · $_customOvers ov'
            : widget.format.label,
        2 => widget.ballType != null ? _ballTypeLabel(widget.ballType!) : '—',
        3 => _dateLabel(widget.date),
        _ => widget.picks.isEmpty
            ? 'No slots added'
            : '${widget.picks.length} slot${widget.picks.length > 1 ? "s" : ""}',
      };

  void _openGroundSheet() {
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.date);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddGroundSheet(
        query: (
          date: dateStr,
          format: widget.format.apiValue,
          teamId: widget.team?.id,
          overs: widget.format == MatchFormat.custom ? _customOvers : null,
        ),
        existingPicks: widget.picks,
        onPick: widget.onAddPick,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teamsAsync = ref.watch(mmTeamsProvider);
    final canEnter = widget.picks.isNotEmpty &&
        widget.team != null &&
        widget.ballType != null &&
        !widget.loading;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Tagline ─────────────────────────────────────────
                Text(
                  'Set your preferences — we\'ll find you a rival.',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),

                // ── 5 sections (each revealed progressively) ─────────
                for (int i = 0; i <= 4; i++)
                  _AnimatedSection(
                    visible: i <= _maxStep,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (i > 0) const SizedBox(height: 4),
                        if (i == _step) ...[
                          // Active: show full picker
                          if (i > 0 && _step > 0) ...[
                            Divider(
                                height: 1,
                                color: context.stroke.withValues(alpha: 0.3)),
                            const SizedBox(height: 20),
                          ],
                          Text(
                            _sectionLabels[i],
                            style: TextStyle(
                              color: context.fg,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildPicker(context, i, teamsAsync),
                        ] else if (i < _maxStep || (i <= _maxStep && i != _step)) ...[
                          // Completed: show compact summary row
                          _buildSummaryRow(context, i),
                          const SizedBox(height: 2),
                        ],
                      ],
                    ),
                  ),

                // ── Error ────────────────────────────────────────────
                if (widget.error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    widget.error!,
                    style: TextStyle(
                      color: context.danger,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // ── CTA ──────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(
              20, 8, 20, 16 + MediaQuery.of(context).padding.bottom),
          child: GestureDetector(
            onTap: canEnter ? widget.onEnter : null,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 56,
              decoration: BoxDecoration(
                color: canEnter ? context.ctaBg : context.panel,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: widget.loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: context.ctaFg),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.radar_rounded,
                            color: canEnter ? context.ctaFg : context.fgSub,
                            size: 19),
                        const SizedBox(width: 9),
                        Text(
                          canEnter
                              ? 'Find Matchup'
                              : 'Add ground & slot to continue',
                          style: TextStyle(
                            color: canEnter ? context.ctaFg : context.fgSub,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (canEnter) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded,
                              color: context.ctaFg.withValues(alpha: 0.7),
                              size: 16),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, int i) {
    return GestureDetector(
      onTap: () => _jumpTo(i),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Text(
              _sectionLabels[i],
              style: TextStyle(
                color: context.fgSub,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(width: 12),
            if (i == 2 && widget.ballType != null) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _ballTypeColor(widget.ballType!),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Expanded(
              child: Text(
                _summaryFor(i),
                style: TextStyle(
                  color: context.fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              'Edit',
              style: TextStyle(
                color: context.accent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPicker(BuildContext context, int i,
      AsyncValue<List<MmTeam>> teamsAsync) {
    return switch (i) {
      0 => _buildTeamPicker(context, teamsAsync),
      1 => _buildFormatPicker(context),
      2 => _buildBallPicker(context),
      3 => _buildDatePicker(context),
      _ => _buildGroundPicker(context),
    };
  }

  Widget _buildTeamPicker(
      BuildContext context, AsyncValue<List<MmTeam>> teamsAsync) {
    return teamsAsync.when(
      loading: () => const LinearProgressIndicator(minHeight: 1),
      error: (_, __) => Text('Could not load teams',
          style: TextStyle(color: context.fgSub, fontSize: 13)),
      data: (teams) {
        if (teams.isEmpty) {
          return Text('No teams yet. Create one first.',
              style: TextStyle(color: context.fgSub, fontSize: 13));
        }
        return Column(
          children: teams.map((t) {
            final sel = widget.team?.id == t.id;
            return GestureDetector(
              onTap: () {
                widget.onTeam(t);
                _advance();
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
                decoration: BoxDecoration(
                  color: sel ? context.ctaBg : context.panel,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: sel
                            ? context.ctaFg.withValues(alpha: 0.15)
                            : context.bg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: t.logoUrl != null && t.logoUrl!.isNotEmpty
                          ? Image.network(t.logoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _TeamInitials(t.name))
                          : _TeamInitials(t.name),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.name,
                            style: TextStyle(
                              color: sel ? context.ctaFg : context.fg,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            '${t.memberCount} members',
                            style: TextStyle(
                              color: sel
                                  ? context.ctaFg.withValues(alpha: 0.6)
                                  : context.fgSub,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (sel)
                      Icon(Icons.check_circle_rounded,
                          color: context.ctaFg, size: 18),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFormatPicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MatchFormat.values.map((f) {
            final sel = widget.format == f;
            final hint = _formatOversHint(f);
            return GestureDetector(
              onTap: () {
                widget.onFormat(f);
                if (f != MatchFormat.custom) _advance();
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? context.ctaBg : context.panel,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      f.label,
                      style: TextStyle(
                        color: sel ? context.ctaFg : context.fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (hint != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        hint,
                        style: TextStyle(
                          color: sel
                              ? context.ctaFg.withValues(alpha: 0.65)
                              : context.fgSub,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (widget.format == MatchFormat.custom) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Overs',
                  style: TextStyle(
                      color: context.fgSub,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              _OversButton(
                  icon: Icons.remove,
                  onTap: _customOvers > 1
                      ? () => setState(() => _customOvers--)
                      : null),
              const SizedBox(width: 12),
              Text('$_customOvers',
                  style: TextStyle(
                      color: context.fg,
                      fontSize: 20,
                      fontWeight: FontWeight.w900)),
              const SizedBox(width: 12),
              _OversButton(
                  icon: Icons.add,
                  onTap: _customOvers < 100
                      ? () => setState(() => _customOvers++)
                      : null),
              const Spacer(),
              GestureDetector(
                onTap: _advance,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: context.ctaBg,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('Next →',
                      style: TextStyle(
                          color: context.ctaFg,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBallPicker(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: ['LEATHER', 'TENNIS', 'TAPE', 'RUBBER'].map((bt) {
        final sel = widget.ballType == bt;
        final ballColor = _ballTypeColor(bt);
        return GestureDetector(
          onTap: () {
            widget.onBallType(bt);
            _advance();
          },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
            decoration: BoxDecoration(
              color: sel ? ballColor.withValues(alpha: 0.12) : context.panel,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: sel ? ballColor : Colors.transparent, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                        color: ballColor, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(_ballTypeLabel(bt),
                    style: TextStyle(
                        color: sel ? ballColor : context.fg,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return _DateStrip(
      selected: widget.date,
      onSelect: (d) {
        widget.onDate(d);
        _advance();
      },
    );
  }

  Widget _buildGroundPicker(BuildContext context) {
    return _Step4Content(
      date: widget.date,
      format: widget.format,
      ballType: widget.ballType,
      ownTeam: widget.team,
      picks: widget.picks,
      onAddPick: widget.onAddPick,
      onRemovePick: widget.onRemovePick,
      onInstantChallenge: widget.onInstantChallenge,
      onOpenGroundSheet: _openGroundSheet,
    );
  }
}

// ── Animated section reveal ───────────────────────────────────────────────────

class _AnimatedSection extends StatelessWidget {
  const _AnimatedSection({required this.visible, required this.child});
  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 260),
        child: visible ? child : const SizedBox(width: double.infinity),
      ),
    );
  }
}

// ── Step 4 content: instant lobbies + manual ground picker ───────────────────

class _Step4Content extends ConsumerStatefulWidget {
  const _Step4Content({
    required this.date,
    required this.format,
    required this.ballType,
    required this.ownTeam,
    required this.picks,
    required this.onAddPick,
    required this.onRemovePick,
    required this.onInstantChallenge,
    required this.onOpenGroundSheet,
  });

  final DateTime date;
  final MatchFormat format;
  final String? ballType;
  final MmTeam? ownTeam;
  final List<MmGroundSlotPick> picks;
  final ValueChanged<MmGroundSlotPick> onAddPick;
  final ValueChanged<MmGroundSlotPick> onRemovePick;
  final ValueChanged<MmOpenLobby> onInstantChallenge;
  final VoidCallback onOpenGroundSheet;

  @override
  ConsumerState<_Step4Content> createState() => _Step4ContentState();
}

class _Step4ContentState extends ConsumerState<_Step4Content>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _glow;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.25, end: 0.85).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    _refreshTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      if (!mounted) return;
      final dateStr = DateFormat('yyyy-MM-dd').format(widget.date);
      ref.invalidate(
          mmOpenLobbiesProvider((date: dateStr, format: widget.format.apiValue)));
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.date);
    final lobbiesAsync = ref.watch(
      mmOpenLobbiesProvider((date: dateStr, format: widget.format.apiValue)),
    );

    final allLobbies = lobbiesAsync.valueOrNull
            ?.where((l) =>
                (widget.ownTeam == null ||
                    l.teamName != widget.ownTeam!.name) &&
                (widget.ballType == null ||
                    l.ballType == null ||
                    l.ballType == widget.ballType))
            .toList() ??
        [];

    // Split: lobbies that share a ground+slot with the user's picks vs everything else
    for (final l in allLobbies) {
      _mmLog('lobby unitId=${l.unitId} slotTime=${l.slotTime} ground=${l.groundName} arena=${l.arenaName}');
    }
    for (final p in widget.picks) {
      _mmLog('pick unitId=${p.slot.unitId} time=${p.slot.time} ground=${p.ground.name}');
    }
    final directMatches = allLobbies
        .where((l) => widget.picks.any((p) =>
            l.unitId != null &&
            p.slot.unitId.isNotEmpty &&
            p.slot.unitId == l.unitId &&
            p.slot.time == l.slotTime))
        .toList();
    _mmLog('directMatches=${directMatches.length} others=${allLobbies.length - directMatches.length}');
    final otherLobbies = allLobbies
        .where((l) => !directMatches.contains(l))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Direct matchup found (same pick) ──────────────────────────
        if (directMatches.isNotEmpty) ...[
          AnimatedBuilder(
            animation: _glow,
            builder: (context, _) => Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF16A34A)
                      .withValues(alpha: _glow.value * 0.75),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MATCHUP FOUND',
                          style: const TextStyle(
                            color: Color(0xFF16A34A),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'A team wants the same ground & slot as you',
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...directMatches.map((lobby) => _InstantLobbyRow(
                lobby: lobby,
                pulseAnim: _glow,
                highlight: true,
                onChallenge: () => widget.onInstantChallenge(lobby),
              )),
          const SizedBox(height: 14),
        ],

        // ── Other available lobbies (different ground/slot) ────────────
        if (otherLobbies.isNotEmpty) ...[
          AnimatedBuilder(
            animation: _glow,
            builder: (context, _) => Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
              decoration: BoxDecoration(
                color: context.accent.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.accent.withValues(alpha: _glow.value * 0.7),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MATCH AVAILABLE',
                          style: TextStyle(
                            color: context.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Grab it before someone else does',
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...otherLobbies.map((lobby) => _InstantLobbyRow(
                lobby: lobby,
                pulseAnim: _glow,
                onChallenge: () => widget.onInstantChallenge(lobby),
              )),
          const SizedBox(height: 14),
        ],

        if (allLobbies.isNotEmpty) ...[
          Row(
            children: [
              Expanded(child: Divider(color: context.stroke.withValues(alpha: 0.5))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or add your own picks',
                  style: TextStyle(color: context.fgSub, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(child: Divider(color: context.stroke.withValues(alpha: 0.5))),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // ── Manual ground picks ────────────────────────────────────────
        if (widget.picks.isEmpty)
          GestureDetector(
            onTap: widget.onOpenGroundSheet,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: context.panel,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.stroke.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: context.fgSub, size: 16),
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
          ...widget.picks.map((p) => _PickRow(
                pick: p,
                onRemove: () => widget.onRemovePick(p),
              )),
          if (widget.picks.length < 3)
            GestureDetector(
              onTap: widget.onOpenGroundSheet,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.add_rounded, color: context.fgSub, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Add another  ${widget.picks.length}/3',
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
      ],
    );
  }
}

class _InstantLobbyRow extends StatelessWidget {
  const _InstantLobbyRow({
    required this.lobby,
    required this.onChallenge,
    required this.pulseAnim,
    this.highlight = false,
  });
  final MmOpenLobby lobby;
  final VoidCallback onChallenge;
  final Animation<double> pulseAnim;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final arenaLabel = lobby.arenaName.isNotEmpty
        ? lobby.arenaName
        : lobby.groundName;
    final dateLabel = lobby.daysFromNow == 0
        ? 'Today'
        : lobby.daysFromNow == 1
            ? 'Tomorrow'
            : DateFormat('MMM d').format(DateTime.tryParse(lobby.date) ?? DateTime.now());
    final venueLine = [
      if (arenaLabel.isNotEmpty) arenaLabel,
      dateLabel,
      lobby.displaySlot,
    ].where((s) => s.isNotEmpty).join('  ·  ');

    final accentColor =
        highlight ? const Color(0xFF16A34A) : context.accent;

    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (context, _) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: highlight
              ? const Color(0xFF16A34A).withValues(alpha: 0.06)
              : context.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: accentColor.withValues(alpha: pulseAnim.value * 0.55),
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onChallenge,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lobby.isArenaLobby
                              ? (lobby.arenaName.isNotEmpty
                                  ? lobby.arenaName
                                  : 'Arena Open Slot')
                              : lobby.teamName,
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor
                              .withValues(alpha: pulseAnim.value * 0.15 + 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          highlight
                              ? 'SAME PICK'
                              : (lobby.isArenaLobby ? 'ARENA SLOT' : 'OPEN TEAM'),
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (venueLine.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      venueLine,
                      style: TextStyle(
                        color: highlight ? accentColor : context.fgSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              highlight ? 'CONFIRM MATCHUP' : 'LOCK SLOT',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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

class _SearchingFind extends ConsumerStatefulWidget {
  const _SearchingFind({
    super.key,
    required this.team,
    required this.format,
    this.ballType,
    required this.date,
    required this.picks,
    required this.restoredPicks,
    required this.onLeave,
    required this.onInstantChallenge,
  });

  final MmTeam? team;
  final MatchFormat format;
  final String? ballType;
  final DateTime date;
  final List<MmGroundSlotPick> picks;
  final List<MmLobbyStatusPick> restoredPicks;
  final VoidCallback onLeave;
  final ValueChanged<MmOpenLobby> onInstantChallenge;

  @override
  ConsumerState<_SearchingFind> createState() => _SearchingFindState();
}

class _SearchingFindState extends ConsumerState<_SearchingFind>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _glow;
  late final AnimationController _radar;
  Timer? _refreshTimer;
  Timer? _msgTimer;
  int _msgIndex = 0;

  static const _messages = [
    'Scanning for matchup...',
    'Looking at nearby grounds & slots...',
    'Finding teams in your area...',
    'Checking availability...',
    'Almost there...',
  ];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.2, end: 1.0)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _radar = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _msgTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() => _msgIndex = (_msgIndex + 1) % _messages.length);
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      if (!mounted) return;
      final dateStr = DateFormat('yyyy-MM-dd').format(widget.date);
      ref.invalidate(mmOpenLobbiesProvider(
          (date: dateStr, format: widget.format.apiValue)));
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    _radar.dispose();
    _msgTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  String _fmtSlot(String t) {
    final parts = t.split(':');
    if (parts.length < 2) return t;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final suffix = h < 12 ? 'AM' : 'PM';
    final dh = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$dh:${m.toString().padLeft(2, '0')} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.date);
    final lobbiesAsync = ref.watch(
        mmOpenLobbiesProvider((date: dateStr, format: widget.format.apiValue)));

    final pickUnitSlots = [
      ...widget.picks.map((p) => (unitId: p.slot.unitId, slotTime: p.slot.time)),
      ...widget.restoredPicks.map((p) => (unitId: p.groundId, slotTime: p.slotTime)),
    ];

    final allOpenLobbies = lobbiesAsync.valueOrNull ?? [];
    final matchedLobbies = allOpenLobbies.where((l) =>
        l.unitId != null &&
        pickUnitSlots.any((ps) =>
            ps.unitId.isNotEmpty &&
            ps.unitId == l.unitId &&
            ps.slotTime == l.slotTime)).toList();

    for (final ps in pickUnitSlots) {
      _mmLog('_SearchingFind pick: unitId=${ps.unitId} slotTime=${ps.slotTime}');
    }
    for (final l in allOpenLobbies) {
      _mmLog('_SearchingFind open: unitId=${l.unitId} slotTime=${l.slotTime}');
    }
    _mmLog('_SearchingFind: pickUnitSlots=${pickUnitSlots.length} openLobbies=${allOpenLobbies.length} matched=${matchedLobbies.length}');

    final dateLabel = () {
      final n = DateTime.now();
      final today = DateTime(n.year, n.month, n.day);
      final t = DateTime(widget.date.year, widget.date.month, widget.date.day);
      if (t == today) return 'Today';
      if (t == today.add(const Duration(days: 1))) return 'Tomorrow';
      return DateFormat('MMM d').format(widget.date);
    }();

    final hasRichPicks = widget.picks.isNotEmpty;
    final hasAnyPicks = hasRichPicks || widget.restoredPicks.isNotEmpty;
    final hasMatches = matchedLobbies.isNotEmpty;

    final bottom = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 28, 20, 24 + bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ────────────────────────────────────────────────
          Text(
            hasMatches ? 'RIVAL FOUND' : 'SEARCHING',
            style: TextStyle(
              color: hasMatches ? const Color(0xFF16A34A) : context.accent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.team?.name ?? 'Your team',
            style: TextStyle(
              color: context.fg,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'is looking for a rival',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),

          // ── Radar / spinner ────────────────────────────────────────
          if (!hasMatches) ...[
            AnimatedBuilder(
              animation: Listenable.merge([_radar, _glow]),
              builder: (context, _) {
                return SizedBox(
                  height: 96,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Ripple rings
                      for (int i = 0; i < 3; i++)
                        _RadarRing(
                          progress: (_radar.value + i / 3) % 1.0,
                          color: context.accent,
                        ),
                      // Center dot
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: context.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Cycling message label
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.25),
                                end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          ),
                          child: Text(
                            _messages[_msgIndex],
                            key: ValueKey(_msgIndex),
                            style: TextStyle(
                              color: context.accent
                                  .withValues(alpha: 0.5 + _glow.value * 0.5),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],

          // ── Match found rows ───────────────────────────────────────
          if (hasMatches) ...[
            AnimatedBuilder(
              animation: _glow,
              builder: (context, _) => Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF16A34A)
                        .withValues(alpha: _glow.value * 0.6),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'A team wants the same slot — claim it now',
                            style: TextStyle(
                              color: Color(0xFF16A34A),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...matchedLobbies.map((lobby) => _InstantLobbyRow(
                  lobby: lobby,
                  pulseAnim: _glow,
                  highlight: true,
                  onChallenge: () => widget.onInstantChallenge(lobby),
                )),
            const SizedBox(height: 20),
          ],

          // ── Request summary ────────────────────────────────────────
          _Divider(),
          const SizedBox(height: 20),

          // Meta rows: label left, value right
          _RequestRow(label: 'TEAM', value: widget.team?.name ?? '—'),
          if (widget.team?.ageGroupLabel != null &&
              widget.team!.ageGroupLabel.isNotEmpty)
            _RequestRow(label: 'AGE GROUP', value: widget.team!.ageGroupLabel),
          _RequestRow(label: 'FORMAT', value: widget.format.label),
          if (widget.ballType != null)
            _RequestRow(
              label: 'BALL',
              value: widget.ballType![0].toUpperCase() +
                  widget.ballType!.substring(1),
              valueDot: widget.ballType == 'leather'
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF16A34A),
            ),
          _RequestRow(label: 'DATE', value: dateLabel),

          // Ground picks
          if (hasAnyPicks) ...[
            const SizedBox(height: 4),
            _Divider(),
            const SizedBox(height: 14),
            _MiniLabel('GROUND PREFERENCES'),
            const SizedBox(height: 12),
            if (hasRichPicks)
              ...widget.picks.map((p) {
                final hot = p.slot.hasOpponent;
                return _SearchPickRow(
                  icon: hot ? '⚡' : null,
                  iconWidget: hot
                      ? null
                      : Icon(Icons.location_on_outlined,
                          color: context.fgSub, size: 13),
                  label: '${p.ground.name}  ·  ${p.slot.displayTime}',
                  labelColor: hot ? context.accent : context.fg,
                  trailing: '₹${p.slot.priceRupees}',
                );
              })
            else
              ...widget.restoredPicks.map((p) => _SearchPickRow(
                    iconWidget: Icon(Icons.location_on_outlined,
                        color: context.fgSub, size: 13),
                    label: [
                      if (p.groundName != null && p.groundName!.isNotEmpty)
                        p.groundName!,
                      _fmtSlot(p.slotTime),
                    ].join('  ·  '),
                    labelColor: context.fg,
                  )),
          ],

          const SizedBox(height: 32),

          // ── Actions ────────────────────────────────────────────────
          GestureDetector(
            onTap: widget.onLeave,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: context.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Edit Request',
                  style: TextStyle(
                    color: context.accent,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: widget.onLeave,
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Cancel Search',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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

// Radar ring painter used by _SearchingFind
class _RadarRing extends StatelessWidget {
  const _RadarRing({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(96, 96),
      painter: _RadarRingPainter(progress: progress, color: color),
    );
  }
}

class _RadarRingPainter extends CustomPainter {
  _RadarRingPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = progress * (size.width / 2);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color.withValues(alpha: opacity * 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(0, size.height / 2), radius, paint);
  }

  @override
  bool shouldRepaint(_RadarRingPainter old) =>
      old.progress != progress || old.color != color;
}

// Pick row used in searching page
class _SearchPickRow extends StatelessWidget {
  const _SearchPickRow({
    required this.label,
    required this.labelColor,
    this.icon,
    this.iconWidget,
    this.trailing,
  });
  final String label;
  final Color labelColor;
  final String? icon;
  final Widget? iconWidget;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(icon!, style: const TextStyle(fontSize: 13)),
            )
          else if (iconWidget != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: iconWidget!,
            ),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

// Label/value row for request summary
class _RequestRow extends StatelessWidget {
  const _RequestRow({
    required this.label,
    required this.value,
    this.valueDot,
  });
  final String label;
  final String value;
  final Color? valueDot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
          if (valueDot != null) ...[
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: 6),
              decoration:
                  BoxDecoration(color: valueDot, shape: BoxShape.circle),
            ),
          ],
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: context.fg,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
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
    required this.onBack,
    this.waitingOpponent = false,
  });

  final MmTeam? team;
  final MatchFormat format;
  final DateTime date;
  final MmMatchSummary? matchSummary;
  final bool confirming;
  final bool waitingOpponent;
  final VoidCallback onConfirm;
  final VoidCallback onDecline;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final confirmFee = matchSummary?.confirmationFeeRupees ?? 500;
    final groundName = matchSummary?.groundName ?? '—';
    final groundArea = matchSummary?.groundArea ?? '';
    final slotDisplay = matchSummary?.displaySlot ?? '';
    final opponent = matchSummary?.opponentTeamName ?? 'Opponent';
    final remainingRupees = matchSummary?.remainingFeeRupees ?? 0;
    final deadline = matchSummary?.confirmDeadline;
    final dateLabel = () {
      final n = DateTime.now();
      if (DateTime(date.year, date.month, date.day) ==
          DateTime(n.year, n.month, n.day)) { return 'Today'; }
      return DateFormat('MMM d').format(date);
    }();

    final locked = confirming || waitingOpponent;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Back row ──────────────────────────────────────────────────
          GestureDetector(
            onTap: (confirming || waitingOpponent) ? null : onBack,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 14,
                    color: (confirming || waitingOpponent)
                        ? context.fgSub.withValues(alpha: 0.3)
                        : context.fgSub,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Back',
                    style: TextStyle(
                      color: (confirming || waitingOpponent)
                          ? context.fgSub.withValues(alpha: 0.3)
                          : context.fgSub,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            waitingOpponent ? 'DEPOSIT PAID — WAITING' : 'MATCHUP FOUND',
            style: TextStyle(
              color: waitingOpponent ? const Color(0xFF16A34A) : context.accent,
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
          // Fee display
          if (!waitingOpponent) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹$confirmFee',
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
                    'deposit to lock slot',
                    style: TextStyle(
                        color: context.fgSub,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            if (remainingRupees > 0) ...[
              const SizedBox(height: 4),
              Text(
                '₹$remainingRupees remaining due at ground',
                style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ] else ...[
            // Waiting state: show 4h countdown
            if (deadline != null)
              _CountdownTimer(deadline: deadline),
            const SizedBox(height: 8),
            Text(
              'Your ₹$confirmFee deposit is confirmed.',
              style: TextStyle(
                  color: context.fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Waiting for $opponent to pay their deposit.',
              style: TextStyle(
                  color: context.fgSub,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
            if (remainingRupees > 0) ...[
              const SizedBox(height: 4),
              Text(
                '₹$remainingRupees remaining will be collected at the ground.',
                style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ],
          const Spacer(),
          if (!waitingOpponent) ...[
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
                          'Confirm Match  →  Lock Slot',
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
                'Both teams pay ₹$confirmFee — slot locked when both confirm',
                style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: locked ? null : onDecline,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Decline matchup',
                    style: TextStyle(
                        color: context.fgSub,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Find: confirmed ───────────────────────────────────────────────────────────

class _ConfirmedFind extends StatelessWidget {
  const _ConfirmedFind({
    super.key,
    required this.matchSummary,
    required this.team,
    required this.onDone,
  });

  final MmMatchSummary? matchSummary;
  final MmTeam? team;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final opponent = matchSummary?.opponentTeamName ?? 'Opponent';
    final groundName = matchSummary?.groundName ?? '—';
    final groundArea = matchSummary?.groundArea ?? '';
    final slotDisplay = matchSummary?.displaySlot ?? '';
    final remainingRupees = matchSummary?.remainingFeeRupees ?? 0;
    final dateStr = matchSummary?.date ?? '';
    final dateLabel = () {
      try {
        final date = DateTime.parse(dateStr);
        final n = DateTime.now();
        if (DateTime(date.year, date.month, date.day) ==
            DateTime(n.year, n.month, n.day)) return 'Today';
        if (DateTime(date.year, date.month, date.day) ==
            DateTime(n.year, n.month, n.day).add(const Duration(days: 1))) {
          return 'Tomorrow';
        }
        return DateFormat('MMM d').format(date);
      } catch (_) {
        return dateStr;
      }
    }();

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'MATCH CONFIRMED',
            style: const TextStyle(
              color: Color(0xFF16A34A),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'vs $opponent',
            style: TextStyle(
              color: context.fg,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            [
              groundName,
              if (groundArea.isNotEmpty) groundArea,
            ].join(', '),
            style: TextStyle(
              color: context.fg,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            [
              if (dateLabel.isNotEmpty) dateLabel,
              if (slotDisplay.isNotEmpty) slotDisplay,
            ].join('  ·  '),
            style: TextStyle(
              color: context.fgSub,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (remainingRupees > 0) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined,
                      size: 18, color: Color(0xFFD97706)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '₹$remainingRupees remaining — pay at ground on match day',
                      style: const TextStyle(
                        color: Color(0xFF92400E),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: GestureDetector(
              onTap: onDone,
              child: Container(
                decoration: BoxDecoration(
                  color: context.ctaBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: context.ctaFg,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
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

class _CountdownTimer extends StatefulWidget {
  const _CountdownTimer({required this.deadline});
  final DateTime deadline;

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  void _update() {
    final r = widget.deadline.difference(DateTime.now());
    setState(() => _remaining = r.isNegative ? Duration.zero : r);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = _remaining.inHours;
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    final expired = _remaining == Duration.zero;
    return Text(
      expired ? 'Expired' : '$h:$m:$s remaining',
      style: TextStyle(
        color: expired ? const Color(0xFFDC2626) : const Color(0xFFF59E0B),
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    );
  }
}

// ── Tab 3: Matches ────────────────────────────────────────────────────────────

class _MyConfirmedMatch {
  const _MyConfirmedMatch({
    required this.matchId,
    required this.myTeamName,
    required this.opponentTeamName,
    required this.groundName,
    required this.arenaName,
    required this.groundArea,
    required this.slotTime,
    required this.date,
    required this.daysFromNow,
    required this.format,
    required this.remainingFeePaise,
  });

  final String matchId;
  final String myTeamName;
  final String opponentTeamName;
  final String groundName;
  final String arenaName;
  final String groundArea;
  final String slotTime;
  final String date;
  final int daysFromNow;
  final String format;
  final int remainingFeePaise;

  int get remainingRupees => remainingFeePaise ~/ 100;

  String get dateLabel {
    if (daysFromNow == 0) return 'Today';
    if (daysFromNow == 1) return 'Tomorrow';
    if (daysFromNow == -1) return 'Yesterday';
    try {
      return DateFormat('MMM d').format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }

  String get displaySlot {
    try {
      final parts = slotTime.split(':');
      final hour = int.parse(parts[0]);
      final min = parts[1];
      final ampm = hour < 12 ? 'AM' : 'PM';
      final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '$h:$min $ampm';
    } catch (_) {
      return slotTime;
    }
  }

  factory _MyConfirmedMatch.fromJson(Map<String, dynamic> j) =>
      _MyConfirmedMatch(
        matchId: (j['matchId'] as String?) ?? '',
        myTeamName: (j['myTeamName'] as String?) ?? 'Your Team',
        opponentTeamName: (j['opponentTeamName'] as String?) ?? 'Opponent',
        groundName: (j['groundName'] as String?) ?? '',
        arenaName: (j['arenaName'] as String?) ?? '',
        groundArea: (j['groundArea'] as String?) ?? '',
        slotTime: (j['slotTime'] as String?) ?? '',
        date: (j['date'] as String?) ?? '',
        daysFromNow: (j['daysFromNow'] as num?)?.toInt() ?? 0,
        format: (j['format'] as String?) ?? '',
        remainingFeePaise: (j['remainingFeePaise'] as num?)?.toInt() ?? 0,
      );
}

final _myMatchesProvider =
    FutureProvider.autoDispose<List<_MyConfirmedMatch>>((ref) async {
  final dio = ApiClient.instance.dio;
  final resp = await dio.get('/matchmaking/matches');
  final body = resp.data;
  final data = (body is Map) ? (body['data'] ?? body) : body;
  final list = (data is Map) ? (data['matches'] as List?) : null;
  return (list ?? [])
      .whereType<Map<String, dynamic>>()
      .map(_MyConfirmedMatch.fromJson)
      .toList();
});

class _MatchesTab extends ConsumerWidget {
  const _MatchesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_myMatchesProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(_myMatchesProvider),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'Could not load matches',
                  style: TextStyle(color: context.fgSub, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
        data: (matches) {
          if (matches.isEmpty) {
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                  child: Column(
                    children: [
                      Icon(Icons.sports_cricket_outlined,
                          size: 48, color: context.fgSub.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'No confirmed matches yet',
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your confirmed matchups will appear here.',
                        style: TextStyle(color: context.fgSub, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          final upcoming = matches.where((m) => m.daysFromNow >= 0).toList();
          final past = matches.where((m) => m.daysFromNow < 0).toList();

          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              if (upcoming.isNotEmpty) ...[
                _sectionLabel(context, 'UPCOMING', upcoming.length),
                ...upcoming.map((m) => _MatchCard(match: m)),
              ],
              if (past.isNotEmpty) ...[
                _sectionLabel(context, 'PAST', past.length),
                ...past.map((m) => _MatchCard(match: m)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});
  final _MyConfirmedMatch match;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'vs ${match.opponentTeamName}',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        match.groundName,
                        if (match.groundArea.isNotEmpty) match.groundArea,
                      ].join(', '),
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        match.format,
                        match.dateLabel,
                        match.displaySlot,
                      ].join('  ·  '),
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (match.remainingRupees > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${match.remainingRupees}',
                        style: const TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text(
                        'due at ground',
                        style: TextStyle(
                          color: Color(0xFFD97706),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: context.stroke.withValues(alpha: 0.4)),
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

// ── Date strip (horizontal scrollable 14-day picker) ─────────────────────────

class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.selected, required this.onSelect});
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(
        21, (i) => DateTime(today.year, today.month, today.day + i));

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final d = days[i];
          final isSel = DateUtils.isSameDay(d, selected);
          final isToday = i == 0;
          final dayOfWeek = d.weekday; // 1=Mon … 7=Sun
          final isWeekend = dayOfWeek == 6 || dayOfWeek == 7;
          final isNewMonth = !isToday && d.month != today.month && d.day == 1;

          return GestureDetector(
            onTap: () => onSelect(d),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: isToday ? 62 : 52,
              decoration: BoxDecoration(
                color: isSel
                    ? context.ctaBg
                    : isWeekend && !isSel
                        ? context.panel.withValues(alpha: 0.7)
                        : context.panel,
                borderRadius: BorderRadius.circular(14),
                border: isSel
                    ? null
                    : isWeekend
                        ? Border.all(
                            color: context.stroke.withValues(alpha: 0.5))
                        : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isToday
                        ? 'Today'
                        : isNewMonth
                            ? DateFormat('MMM').format(d)
                            : DateFormat('EEE').format(d),
                    style: TextStyle(
                      color: isSel
                          ? context.ctaFg.withValues(alpha: 0.75)
                          : context.fgSub,
                      fontSize: isToday ? 9 : 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      color: isSel ? context.ctaFg : context.fg,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
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
