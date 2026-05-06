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
import '../domain/matchmaking_models.dart' show MatchFormat;
import 'matchmaking_providers.dart';
import 'my_matchup_detail_sheet.dart';

// ignore: avoid_print
void _mmLog(String msg) => debugPrint('[MM:page] $msg');

// ── Ball type helpers ─────────────────────────────────────────────────────────

Color _ballTypeColor(String bt) => switch (bt) {
      'LEATHER' => const Color(0xFFB91C1C),
      'TENNIS' => const Color(0xFF65A30D),
      'TAPE' => const Color(0xFF374151),
      'RUBBER' => const Color(0xFFEA580C),
      _ => const Color(0xFF6B7280),
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

enum _LobbyState {
  idle,
  entering,
  scanning,
  searching,
  matched,
  confirming,
  waitingOpponent,
  confirmed
}

// ── Tab page ──────────────────────────────────────────────────────────────────

class MatchmakingTabPage extends ConsumerStatefulWidget {
  const MatchmakingTabPage({super.key, this.onFindMatch});
  final VoidCallback? onFindMatch;

  @override
  ConsumerState<MatchmakingTabPage> createState() => _MatchmakingTabPageState();
}

class _MatchmakingTabPageState extends ConsumerState<MatchmakingTabPage> {
  int _tab = 0; // 0=Discover  1=Create  2=My MatchUps

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
  Timer? _scanTimer;
  Timer? _scanPulseTimer;
  List<MmLobbyStatusPick> _restoredPicks = []; // from active lobby on restart
  bool _lobbyRestored = false; // guard against double-restore
  int _scanStep = 0;
  String? _scanStatus;

  // Payment
  late final Razorpay _razorpay;

  // Plan B / V2 — first-to-pay state. When set, _onPaymentSuccess routes
  // through verifyInterestPayment instead of the legacy confirmMatch path.
  String? _activeInterestId;
  String? _activeInterestLobbyId;
  String? _activeInterestRazorpayOrderId;

  bool get _isActive =>
      _lobbyState != _LobbyState.idle && _lobbyState != _LobbyState.entering;

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_date);

  List<({String unitId, String slotTime})> _currentPickSlots() => _picks
      .map((p) => (unitId: p.slot.unitId, slotTime: p.slot.time))
      .toList();

  bool _matchesCurrentPicks(MmOpenLobby lobby) {
    final pickSlots = _currentPickSlots();
    return lobby.unitId != null &&
        pickSlots.any((pick) =>
            pick.unitId.isNotEmpty &&
            pick.unitId == lobby.unitId &&
            pick.slotTime == lobby.slotTime);
  }

  Future<MmOpenLobby?> _findSameSlotLobby() async {
    final repo = ref.read(matchmakingRepositoryProvider);
    final openLobbies = await repo.listOpenLobbies(
      date: _dateStr,
      format: _format.apiValue,
    );
    for (final lobby in openLobbies) {
      if (_matchesCurrentPicks(lobby)) return lobby;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreActiveLobby());
  }

  Future<void> _restoreActiveLobby() async {
    if (_lobbyRestored) {
      _mmLog('_restoreActiveLobby → skipped (already ran)');
      return;
    }
    _lobbyRestored = true;
    _mmLog('_restoreActiveLobby → start');
    try {
      final repo = ref.read(matchmakingRepositoryProvider);
      final active = await repo.getActiveLobby();
      if (active == null || !mounted) {
        _mmLog('_restoreActiveLobby → no active lobby (or unmounted)');
        return;
      }
      _mmLog(
          '_restoreActiveLobby → found lobbyId=${active.lobbyId} status=${active.status} '
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
      if (restoredTeam == null &&
          active.teamId != null &&
          active.teamName != null) {
        restoredTeam = MmTeam(
            id: active.teamId!, name: active.teamName!, ageGroupLabel: '');
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
      _mmLog(
          '_restoreActiveLobby → setState done, lobbyState=$_lobbyState team=${_team?.name} format=${_format.apiValue} date=$_dateStr');
      if (_lobbyState == _LobbyState.searching ||
          _lobbyState == _LobbyState.waitingOpponent) _startPolling();
    } catch (e, st) {
      _mmLog('_restoreActiveLobby ERROR: $e\n$st');
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _scanTimer?.cancel();
    _scanPulseTimer?.cancel();
    _razorpay.clear();
    super.dispose();
  }

  // ── Lobby lifecycle ────────────────────────────────────────────────────────

  Future<void> _enterLobby() async {
    if (_picks.isEmpty || _team == null) return;
    _pollTimer?.cancel();
    _scanTimer?.cancel();
    _scanPulseTimer?.cancel();
    setState(() {
      _lobbyState = _LobbyState.scanning;
      _error = null;
      _scanStep = 0;
      _scanStatus = null;
    });
    _scanPulseTimer = Timer.periodic(const Duration(milliseconds: 850), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_scanStep >= 3) {
        t.cancel();
        return;
      }
      setState(() => _scanStep += 1);
    });
    _scanTimer = Timer(const Duration(milliseconds: 3300), () {
      if (!mounted) return;
      _scanPulseTimer?.cancel();
      _resolveEntryAfterScan();
    });
  }

  Future<void> _resolveEntryAfterScan() async {
    try {
      _mmLog(
          '_resolveEntryAfterScan → picks=${_picks.length} team=${_team?.id} format=${_format.apiValue} date=$_dateStr');
      final sameSlotLobby = await _findSameSlotLobby();
      if (!mounted) return;
      _mmLog(
          '_resolveEntryAfterScan → sameSlot=${sameSlotLobby?.lobbyId ?? 'none'}');

      if (sameSlotLobby != null) {
        setState(() => _scanStatus = 'Found a direct match. Opening it now.');
        await Future<void>.delayed(const Duration(milliseconds: 700));
        setState(() {
          _lobbyState = _LobbyState.entering;
          _error = null;
        });
        await _instantChallenge(sameSlotLobby, withTeam: _team);
        return;
      }

      setState(() => _scanStatus =
          'No direct match found. Creating a lobby for this slot.');
      await Future<void>.delayed(const Duration(milliseconds: 850));
      setState(() {
        _lobbyState = _LobbyState.entering;
        _error = null;
      });
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
        _scanStatus = null;
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
            match.myTeamConfirmed &&
            match.opponentConfirmed) {
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
    _mmLog(
        '_instantChallenge → lobbyId=${lobby.lobbyId} team=${team?.id} teamName=${team?.name}');
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
      _mmLog(
          '_instantChallenge → leaving old lobby $oldLobbyId before joining');
      _pollTimer?.cancel();
      try {
        await ref.read(matchmakingRepositoryProvider).leaveLobby(oldLobbyId);
      } catch (e) {
        _mmLog('_instantChallenge → leave old lobby error (ignored): $e');
      }
    }
    setState(() {
      _lobbyState = _LobbyState.entering;
      _error = null;
      _team = team;
      _tab = 1;
    });
    try {
      final repo = ref.read(matchmakingRepositoryProvider);

      // V2 first-to-pay flow:
      //   1. Express interest (no match yet, just intent)
      //   2. Try to acquire 120s lock + Razorpay order
      //   3. Open Razorpay; payment-success handler routes through
      //      verifyInterestPayment via the _activeInterest* fields below.
      // Throws LOCK_TAKEN (409) if another team is currently paying.
      final interest = await repo.expressInterest(lobby.lobbyId, team.id);
      _mmLog('_instantChallenge → interest expressed id=${interest.interestId}');
      final lock = await repo.lockAndPay(interest.interestId);
      _mmLog(
          '_instantChallenge → lock acquired order=${lock.razorpayOrderId} '
          'amount=${lock.amountPaise} expires=${lock.lockExpiresAt}');
      if (!mounted) return;
      _activeInterestId = interest.interestId;
      _activeInterestLobbyId = lobby.lobbyId;
      _activeInterestRazorpayOrderId = lock.razorpayOrderId;
      _razorpay.open({
        'key': lock.razorpayKey,
        'amount': lock.amountPaise,
        'currency': lock.currency,
        'name': 'Swing',
        'description': 'Match-Up advance — locks the slot if you pay first',
        'order_id': lock.razorpayOrderId,
      });
      ref.invalidate(mmOpenLobbiesProvider((date: null, format: null)));
    } catch (e, st) {
      _mmLog('_instantChallenge ERROR: $e\n$st');
      if (!mounted) return;
      final msg = _parseError(e);
      // LOCK_TAKEN (409) → another team is currently paying. Their lock will
      // expire in <=120s; the player can retry then. Their interest row
      // already exists, so the system also notifies them if the slot reopens.
      final isLockRace = msg.toLowerCase().contains('lock_taken') ||
          msg.toLowerCase().contains('slot was taken') ||
          msg.toLowerCase().contains('paying right now');
      setState(() {
        _lobbyState = _LobbyState.idle;
        _error = isLockRace
            ? 'Another team is paying for this slot — try again in a minute.'
            : msg;
        _tab = 1;
        _activeInterestId = null;
        _activeInterestLobbyId = null;
        _activeInterestRazorpayOrderId = null;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_error ?? msg)));
    }
  }

  Future<void> _leaveLobby() async {
    _pollTimer?.cancel();
    _scanTimer?.cancel();
    _scanPulseTimer?.cancel();
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
    setState(() {
      _lobbyState = _LobbyState.confirming;
      _error = null;
    });
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
      setState(() {
        _lobbyState = _LobbyState.matched;
        _error = _parseError(e);
      });
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    final repo = ref.read(matchmakingRepositoryProvider);

    // Plan B / V2 — first-to-pay flow. If an interest is active, this payment
    // came from the express-interest → lock-and-pay path. Verify via the
    // interest endpoint (creates the Match if won; reports SLOT_TAKEN if
    // another team won concurrently).
    final interestId = _activeInterestId;
    final interestOrderId = _activeInterestRazorpayOrderId;
    if (interestId != null && interestOrderId != null) {
      try {
        final result = await repo.verifyInterestPayment(
          interestId: interestId,
          razorpayOrderId: response.orderId ?? interestOrderId,
          razorpayPaymentId: response.paymentId ?? '',
          razorpaySignature: response.signature ?? '',
        );
        if (!mounted) return;
        if (result.matchId != null) {
          ref.invalidate(mmOpenLobbiesProvider((date: null, format: null)));
          setState(() {
            _lobbyId = _activeInterestLobbyId;
            _lobbyState = _LobbyState.confirmed;
            _activeInterestId = null;
            _activeInterestLobbyId = null;
            _activeInterestRazorpayOrderId = null;
          });
        } else {
          setState(() {
            _lobbyState = _LobbyState.idle;
            _error = 'Slot was taken by another team. Refund will be issued.';
            _activeInterestId = null;
            _activeInterestLobbyId = null;
            _activeInterestRazorpayOrderId = null;
          });
        }
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _lobbyState = _LobbyState.idle;
          _error = "Payment done but couldn't lock the slot. Contact support.";
          _activeInterestId = null;
          _activeInterestLobbyId = null;
          _activeInterestRazorpayOrderId = null;
        });
      }
      return;
    }

    // Legacy joinLobby → verifyMatchPayment flow.
    try {
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
      setState(() {
        _lobbyState = _LobbyState.matched;
        _error = 'Payment done but confirmation failed. Contact support.';
      });
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() {
      _lobbyState = _LobbyState.matched;
      _error = response.message ?? 'Payment was not completed.';
    });
  }

  // Back arrow — cancel silently and return to Open tab, preserving form state
  Future<void> _goBackFromMatch() async {
    final matchId = _matchSummary?.matchId;
    final lobbyId = _lobbyId;
    _pollTimer?.cancel();
    _scanTimer?.cancel();
    _scanPulseTimer?.cancel();
    final repo = ref.read(matchmakingRepositoryProvider);
    if (matchId != null && lobbyId != null) {
      try {
        await repo.declineMatch(matchId, lobbyId);
      } catch (_) {}
      try {
        await repo.leaveLobby(lobbyId);
      } catch (_) {}
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
    _scanTimer?.cancel();
    _scanPulseTimer?.cancel();
    final repo = ref.read(matchmakingRepositoryProvider);
    try {
      await repo.declineMatch(matchId, lobbyId);
    } catch (_) {}
    try {
      await repo.leaveLobby(lobbyId);
    } catch (_) {}
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
    _scanTimer?.cancel();
    _scanPulseTimer?.cancel();
    setState(() {
      _lobbyId = null;
      _matchSummary = null;
      _lobbyState = _LobbyState.idle;
      _picks = [];
    });
  }

  void _addPick(MmGroundSlotPick pick) {
    if (_picks.length >= 3) return;
    if (_picks.any((p) =>
        p.slot.unitId == pick.slot.unitId && p.slot.time == pick.slot.time)) {
      return;
    }
    setState(() => _picks.add(pick));
  }

  void _removePick(MmGroundSlotPick pick) {
    setState(() => _picks.removeWhere((p) =>
        p.slot.unitId == pick.slot.unitId && p.slot.time == pick.slot.time));
  }

  String _parseError(Object e, {bool isCreate = false}) {
    final msg = e.toString();
    if (msg.contains('401')) return 'Session expired. Please log in again.';
    if (msg.contains('400')) return 'Invalid picks. Please try again.';
    if (msg.contains('404'))
      return isCreate
          ? 'Could not create request. Try again.'
          : 'Request expired or not found.';
    return isCreate
        ? 'No direct match found. Creating a lobby for this slot.'
        : 'Something went wrong. Try again.';
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
                    'MatchUp',
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                              ? 'Found'
                              : _lobbyState == _LobbyState.waitingOpponent
                                  ? 'Waiting'
                                  : 'Searching',
                          style: TextStyle(
                            color: context.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Tab bar ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.panel,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: context.stroke.withValues(alpha: 0.65)),
              ),
              child: Row(
                children: [
                  _TabLabel(
                    label: 'Discover',
                    active: _tab == 0,
                    onTap: () => setState(() => _tab = 0),
                    badge: ref
                        .watch(
                            mmOpenLobbiesProvider((date: null, format: null)))
                        .valueOrNull
                        ?.length,
                  ),
                  _TabLabel(
                    label: 'Create',
                    active: _tab == 1,
                    onTap: () => setState(() => _tab = 1),
                  ),
                  _TabLabel(
                    label: 'My MatchUps',
                    active: _tab == 2,
                    onTap: () => setState(() => _tab = 2),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
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
                  scanStep: _scanStep,
                  scanStatus: _scanStatus,
                  onTeam: (t) => setState(() => _team = t),
                  onFormat: (f) => setState(() {
                    _format = f;
                    _picks =
                        []; // slot availability changes with format duration
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: active ? context.ctaBg : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: active ? context.ctaFg : context.fgSub,
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              if (badge != null && badge! > 0) ...[
                const SizedBox(width: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: active
                        ? context.ctaFg
                        : context.fgSub.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$badge',
                    style: TextStyle(
                      color: active ? context.ctaBg : context.fgSub,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
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
  String? _formatFilter;
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
        child: Text('Could not load open games',
            style: TextStyle(color: context.fgSub, fontSize: 13)),
      );
    }
    return _buildLobbiesList(context, lobbiesSnapshot ?? []);
  }

  Widget _buildLobbiesList(BuildContext context, List<MmOpenLobby> lobbies) {
    final others = lobbies
        .where((l) => !_isSlotPast(l))
        .where(
            (l) => widget.ownLobbyId == null || l.lobbyId != widget.ownLobbyId)
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
    final selected =
        (_selectedDate != null && sortedDates.contains(_selectedDate))
            ? _selectedDate!
            : autoDate;
    final filtered = (byDate[selected] ?? [])
        .where((l) =>
            _ballTypeFilter == null ||
            l.ballType == null ||
            l.ballType == _ballTypeFilter)
        .where((l) => _formatFilter == null || l.format == _formatFilter)
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _FilterDropdown(
                        label: 'Format',
                        value: _formatFilter,
                        options: const [
                          (value: null, label: 'Any format'),
                          (value: 'T10', label: 'T10'),
                          (value: 'T20', label: 'T20'),
                          (value: 'ODI', label: 'ODI'),
                          (value: 'Test', label: 'Test'),
                          (value: 'Custom', label: 'Custom'),
                        ],
                        onChanged: (value) =>
                            setState(() => _formatFilter = value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _FilterDropdown(
                        label: 'Ball',
                        value: _ballTypeFilter,
                        options: const [
                          (value: null, label: 'Any ball'),
                          (value: 'LEATHER', label: 'Leather'),
                          (value: 'TENNIS', label: 'Tennis'),
                          (value: 'TAPE', label: 'Tape Ball'),
                          (value: 'RUBBER', label: 'Rubber'),
                        ],
                        onChanged: (value) =>
                            setState(() => _ballTypeFilter = value),
                      ),
                    ),
                  ],
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
                      final dayName =
                          isToday ? 'Today' : DateFormat('EEE').format(d);
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDate = dateStr),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? context.accent : context.surf,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? context.accent
                                  : context.accent.withValues(alpha: 0.35),
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
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.8)
                                          : context.fgSub,
                                    ),
                                  ),
                                  Text(
                                    '${d.day} ${DateFormat('MMM').format(d)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? Colors.white
                                          : context.fg,
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
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white),
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
                Divider(
                    height: 1, color: context.stroke.withValues(alpha: 0.5)),
              ],
            ],
          ),
        ),

        // ── Lobby list ──────────────────────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            color: context.accent,
            onRefresh: () async =>
                ref.invalidate(mmOpenLobbiesProvider(widget.query)),
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
                                color: context.fgSub.withValues(alpha: 0.3),
                                size: 44),
                            const SizedBox(height: 12),
                            Text(
                              'No open games on this day',
                              style: TextStyle(
                                  color: context.fgSub,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try another date',
                              style: TextStyle(
                                  color: context.fgSub.withValues(alpha: 0.5),
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
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
  const _OpenLobbyCard({
    required this.lobby,
    required this.onCounter,
  });
  final MmOpenLobby lobby;
  final VoidCallback onCounter;

  @override
  Widget build(BuildContext context) {
    final ball = lobby.ballType;
    final price = lobby.pricePerTeamPaise ~/ 100;
    final venue = lobby.arenaName.isNotEmpty
        ? lobby.arenaName
        : (lobby.groundName.isNotEmpty ? lobby.groundName : 'Arena slot');
    final age = lobby.ageGroup.isNotEmpty ? lobby.ageGroup : 'Open';
    final meta = [
      lobby.format,
      if (ball != null) _ballTypeLabel(ball),
      age,
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  lobby.teamName,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.25,
                    height: 1.05,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: context.panel,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: context.stroke.withValues(alpha: 0.55),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  lobby.dateLabel,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Text(
                  meta,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '₹$price / team',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: context.stroke.withValues(alpha: 0.42)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        color: context.fgSub, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      lobby.displaySlot,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        venue,
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onCounter,
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: context.ctaBg,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Match',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
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

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<({String? value, String label})> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final option in options)
          PopupMenuItem<String?>(
            value: option.value,
            child: Text(option.label),
          ),
      ],
      offset: const Offset(0, 46),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: context.surf,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.stroke.withValues(alpha: 0.85)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    options
                        .firstWhere(
                          (option) => option.value == value,
                          orElse: () => options.first,
                        )
                        .label,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: context.fgSub, size: 20),
          ],
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
        if (mounted && _selected == null)
          setState(() => _selected = teams.first);
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
          position:
              Tween<Offset>(begin: offset, end: Offset.zero).animate(anim),
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
    final venue = lobby.arenaName.isNotEmpty
        ? lobby.arenaName
        : (lobby.groundName.isNotEmpty ? lobby.groundName : 'Ground');
    final ballLabel =
        lobby.ballType == null ? null : _ballTypeLabel(lobby.ballType!);
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
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.stroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Play this team?',
                      style: TextStyle(
                          color: context.fg,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('Check the match details and choose your team.',
                      style: TextStyle(
                          color: context.fgSub,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 18),
                  _PlainInfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SimpleLine(
                          icon: Icons.groups_rounded,
                          title: 'Opponent',
                          value: lobby.teamName,
                        ),
                        const SizedBox(height: 14),
                        _SimpleLine(
                          icon: Icons.stadium_rounded,
                          title: 'Place',
                          value: venue,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _SimpleLine(
                                icon: Icons.calendar_today_rounded,
                                title: 'Date',
                                value: lobby.dateLabel,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _SimpleLine(
                                icon: Icons.access_time_rounded,
                                title: 'Time',
                                value: lobby.displaySlot,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _SimplePill(
                                label: lobby.format,
                                icon: Icons.sports_cricket_rounded,
                              ),
                            ),
                            if (ballLabel != null) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: _SimplePill(
                                  label: ballLabel,
                                  icon: Icons.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.accent.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: context.accent.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Confirm match with advance',
                                  style: TextStyle(
                                      color: context.accent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text(
                                balanceRupees > 0
                                    ? 'Pay balance ₹$balanceRupees at ground'
                                    : 'No balance shown for ground',
                                style: TextStyle(
                                    color: context.fgSub,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('₹$depositRupees',
                            style: TextStyle(
                                color: context.fg,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.8)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('Choose your team',
                      style: TextStyle(
                          color: context.fg,
                          fontSize: 15,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  if (teamsLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: LinearProgressIndicator(minHeight: 1),
                    )
                  else if (teams.isEmpty)
                    Text('No teams found. Create a team first.',
                        style: TextStyle(color: context.fgSub, fontSize: 13))
                  else
                    PopupMenuButton<MmTeam>(
                      initialValue: selected,
                      onSelected: onSelectTeam,
                      itemBuilder: (_) => [
                        for (final team in teams)
                          PopupMenuItem<MmTeam>(
                            value: team,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(team.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                Text(
                                  '${team.ageGroupLabel} · ${team.memberCount} players',
                                  style: TextStyle(
                                      color: context.fgSub, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                      ],
                      offset: const Offset(0, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: context.surf,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected != null
                                ? context.accent
                                : context.stroke,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                selected?.name ?? 'Select team',
                                style: TextStyle(
                                    color: selected != null
                                        ? context.fg
                                        : context.fgSub,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down_rounded,
                                color: context.fgSub, size: 22),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: canReview ? onReview : null,
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      height: 54,
                      decoration: BoxDecoration(
                        color: canReview ? context.ctaBg : context.panel,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        canReview
                            ? 'Confirm Match · ₹$depositRupees Advance'
                            : 'Select your team',
                        style: TextStyle(
                          color: canReview ? context.ctaFg : context.fgSub,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
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

class _PlainInfoCard extends StatelessWidget {
  const _PlainInfoCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.stroke.withValues(alpha: 0.75)),
      ),
      child: child,
    );
  }
}

class _SimpleLine extends StatelessWidget {
  const _SimpleLine({
    required this.icon,
    required this.title,
    required this.value,
  });
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: context.fgSub, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      color: context.fgSub,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      color: context.fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w900),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _SimplePill extends StatelessWidget {
  const _SimplePill({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: context.fgSub, size: 14),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: Text(
              label,
              style: TextStyle(
                color: context.fg,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.value,
    required this.label,
    this.accent = false,
  });

  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: accent ? context.accent : context.fg,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: context.fgSub,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _DotSep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          color: context.fgSub.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hasValue ? value! : placeholder,
                    style: TextStyle(
                      color: hasValue ? context.fg : context.fgSub,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: context.fgSub, size: 24),
          ],
        ),
      ),
    );
  }
}

class _TeamOptionRow extends StatelessWidget {
  const _TeamOptionRow({
    required this.team,
    required this.selected,
    required this.showDivider,
    required this.onTap,
  });

  final MmTeam team;
  final bool selected;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: selected ? context.ctaBg : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                team.logoUrl != null && team.logoUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Image.network(
                          team.logoUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _TeamInitials(team.name),
                        ),
                      )
                    : _TeamInitials(team.name),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? context.ctaFg : context.fg,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${team.memberCount} member${team.memberCount == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: selected
                              ? context.ctaFg.withValues(alpha: 0.75)
                              : context.fgSub,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_rounded, color: context.ctaFg, size: 22),
              ],
            ),
          ),
        ),
        if (showDivider && !selected)
          Divider(
            height: 1,
            color: context.stroke.withValues(alpha: 0.14),
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}

class _FlowRow extends StatelessWidget {
  const _FlowRow({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.leading,
    this.trailing,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? context.ctaFg : context.fg;
    final fgSub =
        selected ? context.ctaFg.withValues(alpha: 0.75) : context.fgSub;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: selected ? context.ctaBg : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fg,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fgSub,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (selected)
              Icon(Icons.check_rounded, color: context.ctaFg, size: 20)
            else if (trailing != null)
              trailing!,
          ],
        ),
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
                width: 36,
                height: 4,
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
                        lobby.arenaName.isNotEmpty
                            ? lobby.arenaName
                            : lobby.groundName,
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
                                    color:
                                        context.fgSub.withValues(alpha: 0.45),
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
                    Divider(
                        height: 1,
                        color: context.stroke.withValues(alpha: 0.4)),
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
    required this.scanStep,
    required this.scanStatus,
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
  final int scanStep;
  final String? scanStatus;
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
        _LobbyState.scanning => _ScanningFind(
            key: const ValueKey('scanning'),
            team: team,
            format: format,
            date: date,
            picks: picks,
            scanStep: scanStep,
            scanStatus: scanStatus,
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
        _LobbyState.matched ||
        _LobbyState.confirming ||
        _LobbyState.waitingOpponent =>
          _MatchedFind(
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
  // 0=team+format+ball  1=date  2=arena  3=slot
  int _step = 0;
  int _maxStep = 0;
  int _customOvers = 20;
  MmGround? _selectedArena;

  static const _sectionLabels = [
    'Match details',
    'Choose date',
    'Pick arena',
    'Pick slots',
  ];

  @override
  void initState() {
    super.initState();
    // Restore to ground section if state was pre-filled (e.g. returning from search)
    if (widget.team != null) {
      _step = 2;
      _maxStep = 2;
    }
  }

  void _advance() {
    if (!mounted) return;
    final next = (_step + 1).clamp(0, _sectionLabels.length);
    setState(() {
      _step = next;
      if (next > _maxStep) _maxStep = next;
    });
  }

  void _back() {
    if (!mounted || _step == 0) return;
    setState(() => _step -= 1);
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
        0 => () {
            final t = widget.team?.name;
            final f = widget.format == MatchFormat.custom
                ? 'Custom $_customOvers ov'
                : widget.format.label;
            final b = widget.ballType != null
                ? _ballTypeLabel(widget.ballType!)
                : null;
            if (t == null) return '—';
            final parts = [t, f, if (b != null) b];
            return parts.join(' · ');
          }(),
        1 => _dateLabel(widget.date),
        2 => _selectedArena?.name ?? '—',
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
          teamId: null,
          overs: widget.format == MatchFormat.custom ? _customOvers : null,
        ),
        existingPicks: widget.picks,
        onPick: widget.onAddPick,
      ),
    ).then((_) {
      if (!mounted) return;
      if (widget.picks.isNotEmpty) {
        setState(() {
          _step = 5;
          if (_maxStep < 5) _maxStep = 5;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final teamsAsync = ref.watch(mmTeamsProvider);
    final canEnter = widget.picks.isNotEmpty &&
        widget.team != null &&
        widget.ballType != null &&
        !widget.loading;
    final isReview = _step >= _sectionLabels.length;
    final stepReady = switch (_step) {
      0 => widget.team != null && widget.ballType != null,
      1 => true,
      2 => _selectedArena != null,
      3 => widget.picks.isNotEmpty,
      _ => canEnter,
    };

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildFlowHeader(context),
                ),
                const SizedBox(height: 26),
                _step < _sectionLabels.length
                    ? _buildStepShell(context, teamsAsync)
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildReviewPanel(context),
                      ),

                // ── Error ────────────────────────────────────────────
                if (widget.error != null) ...[
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      widget.error!,
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

        // ── CTA ──────────────────────────────────────────────────────
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
          child: Row(
            children: [
              if (_step > 0)
                GestureDetector(
                  onTap: _back,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 44,
                    height: 52,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 20,
                      color: context.fg,
                    ),
                  ),
                ),
              Expanded(
                child: GestureDetector(
                  onTap: isReview
                      ? (canEnter ? widget.onEnter : null)
                      : (stepReady ? _advance : null),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: isReview
                          ? (canEnter ? context.ctaBg : context.stroke.withValues(alpha: 0.18))
                          : (stepReady ? context.fg : context.stroke.withValues(alpha: 0.18)),
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
                              Text(
                                isReview ? 'Find Matchup' : 'Continue',
                                style: TextStyle(
                                  color: isReview
                                      ? (canEnter ? context.ctaFg : context.fgSub)
                                      : (stepReady ? context.bg : context.fgSub),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.2,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                isReview
                                    ? Icons.radar_rounded
                                    : Icons.arrow_forward_rounded,
                                color: isReview
                                    ? (canEnter ? context.ctaFg : context.fgSub)
                                    : (stepReady ? context.bg : context.fgSub),
                                size: 17,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlowHeader(BuildContext context) {
    final totalSteps = _sectionLabels.length;
    final isReview = _step >= totalSteps;
    final stepNumber =
        isReview ? totalSteps : (_step.clamp(0, totalSteps - 1)) + 1;
    final eyebrow = isReview
        ? 'FINAL REVIEW'
        : 'STEP ${stepNumber.toString().padLeft(2, '0')} OF 0$totalSteps';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: TextStyle(
            color: context.fgSub,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Match Setup',
          style: TextStyle(
            color: context.fg,
            fontSize: 40,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.6,
            height: 0.95,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 4,
          width: 64,
          decoration: BoxDecoration(
            color: context.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            for (int i = 0; i < totalSteps; i++) ...[
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: i < _step || isReview
                        ? context.accent
                        : i == _step
                            ? context.fg
                            : context.stroke.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              if (i < totalSteps - 1) const SizedBox(width: 6),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStepShell(
      BuildContext context, AsyncValue<List<MmTeam>> teamsAsync) {
    return KeyedSubtree(
      key: ValueKey<int>(_step),
      child: _buildPicker(context, _step, teamsAsync),
    );
  }

  Widget _buildReviewPanel(BuildContext context) {
    return Column(
      key: const ValueKey<String>('review'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _sectionLabels.length; i++) ...[
          InkWell(
            onTap: () => _jumpTo(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    child: Text(
                      '0${i + 1}',
                      style: TextStyle(
                        color: i < _step
                            ? context.accent
                            : context.fgSub.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _sectionLabels[i],
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _summaryFor(i),
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.edit_rounded,
                      size: 15, color: context.fgSub.withValues(alpha: 0.7)),
                ],
              ),
            ),
          ),
          if (i < _sectionLabels.length - 1)
            Divider(
              height: 1,
              color: context.stroke.withValues(alpha: 0.14),
            ),
        ],
        const SizedBox(height: 18),
        Text(
          widget.picks.isEmpty
              ? 'Add a slot to continue'
              : '${widget.picks.length} slot${widget.picks.length > 1 ? "s" : ""} ready · tap any row to edit',
          style: TextStyle(
            color: context.fgSub,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPicker(
      BuildContext context, int i, AsyncValue<List<MmTeam>> teamsAsync) {
    return switch (i) {
      0 => _buildTeamFormatPicker(context, teamsAsync),
      1 => _buildDatePicker(context),
      2 => _buildArenaPicker(context),
      _ => _buildSlotPicker(context),
    };
  }

  Widget _buildTeamFormatPicker(
      BuildContext context, AsyncValue<List<MmTeam>> teamsAsync) {
    return teamsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: LinearProgressIndicator(minHeight: 1),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Text(
          'Could not load teams',
          style: TextStyle(color: context.fgSub, fontSize: 13),
        ),
      ),
      data: (teams) {
        if (teams.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Text(
              'No teams yet. Create one first.',
              style: TextStyle(color: context.fgSub, fontSize: 13),
            ),
          );
        }
        final formatLabel = widget.format == MatchFormat.custom
            ? 'Custom · $_customOvers overs'
            : widget.format.label;
        return Column(
          children: [
            _DropdownField(
              label: 'Choose Team',
              value: widget.team?.name,
              placeholder: 'Tap to select team',
              onTap: () => _openTeamSheet(teams),
            ),
            Divider(
              height: 1,
              color: context.stroke.withValues(alpha: 0.18),
            ),
            _DropdownField(
              label: 'Choose Format',
              value: formatLabel,
              placeholder: 'Tap to select format',
              onTap: _openFormatSheet,
            ),
            Divider(
              height: 1,
              color: context.stroke.withValues(alpha: 0.18),
            ),
            _DropdownField(
              label: 'Choose Ball Type',
              value: widget.ballType != null
                  ? _ballTypeLabel(widget.ballType!)
                  : null,
              placeholder: 'Tap to select ball type',
              onTap: _openBallSheet,
            ),
            if (widget.format == MatchFormat.custom) ...[
              Divider(
                height: 1,
                color: context.stroke.withValues(alpha: 0.18),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: [
                    Text(
                      'Overs',
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 14),
                    _OversButton(
                      icon: Icons.remove,
                      onTap: _customOvers > 1
                          ? () => setState(() => _customOvers--)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$_customOvers',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _OversButton(
                      icon: Icons.add,
                      onTap: _customOvers < 100
                          ? () => setState(() => _customOvers++)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _openTeamSheet(List<MmTeam> teams) {
    showModalBottomSheet<void>(
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
                  'Choose Team',
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
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: teams.length,
                  itemBuilder: (_, i) {
                    final t = teams[i];
                    final selected = widget.team?.id == t.id;
                    return _TeamOptionRow(
                      team: t,
                      selected: selected,
                      showDivider: i < teams.length - 1,
                      onTap: () {
                        widget.onTeam(t);
                        Navigator.of(sheetCtx).pop();
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
  }

  void _openFormatSheet() {
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
              for (int i = 0; i < MatchFormat.values.length; i++) ...[
                Builder(builder: (_) {
                  final f = MatchFormat.values[i];
                  final selected = widget.format == f;
                  return GestureDetector(
                    onTap: () {
                      widget.onFormat(f);
                      Navigator.of(sheetCtx).pop();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: selected ? context.ctaBg : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  f.label,
                                  style: TextStyle(
                                    color: selected
                                        ? context.ctaFg
                                        : context.fg,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (_formatOversHint(f) != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatOversHint(f)!,
                                    style: TextStyle(
                                      color: selected
                                          ? context.ctaFg
                                              .withValues(alpha: 0.75)
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
                            Icon(Icons.check_rounded,
                                color: context.ctaFg, size: 20),
                        ],
                      ),
                    ),
                  );
                }),
                if (i < MatchFormat.values.length - 1)
                  Divider(
                    height: 1,
                    color: context.stroke.withValues(alpha: 0.14),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _openBallSheet() {
    const balls = ['LEATHER', 'TENNIS', 'TAPE', 'RUBBER'];
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
              for (int i = 0; i < balls.length; i++) ...[
                Builder(builder: (_) {
                  final bt = balls[i];
                  final selected = widget.ballType == bt;
                  return GestureDetector(
                    onTap: () {
                      widget.onBallType(bt);
                      Navigator.of(sheetCtx).pop();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: selected ? context.ctaBg : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _ballTypeColor(bt),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _ballTypeLabel(bt),
                              style: TextStyle(
                                color: selected ? context.ctaFg : context.fg,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (selected)
                            Icon(Icons.check_rounded,
                                color: context.ctaFg, size: 20),
                        ],
                      ),
                    ),
                  );
                }),
                if (i < balls.length - 1)
                  Divider(
                    height: 1,
                    color: context.stroke.withValues(alpha: 0.14),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildArenaPicker(BuildContext context) {
    return _ArenaPickerStep(
      date: widget.date,
      format: widget.format,
      customOvers: _customOvers,
      selectedArena: _selectedArena,
      onPickArena: (g) {
        setState(() => _selectedArena = g);
        _advance();
      },
    );
  }

  Widget _buildSlotPicker(BuildContext context) {
    final arena = _selectedArena;
    if (arena == null) {
      // shouldn't normally happen — guardrail. Send user back.
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: GestureDetector(
          onTap: () => _jumpTo(2),
          behavior: HitTestBehavior.opaque,
          child: Text(
            'Pick an arena first →',
            style: TextStyle(
              color: context.accent,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }
    return _SlotStep(
      arena: arena,
      picks: widget.picks,
      onAddPick: widget.onAddPick,
      onRemovePick: widget.onRemovePick,
      onChangeArena: () => _jumpTo(2),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.date);
    final groundsAsync = ref.watch(
      mmGroundsProvider((
        date: dateStr,
        format: widget.format.apiValue,
        teamId: null,
        overs: widget.format == MatchFormat.custom ? _customOvers : null,
      )),
    );
    final grounds = groundsAsync.valueOrNull ?? [];
    final totalSlots = grounds.fold<int>(0, (sum, g) => sum + g.slots.length);
    final hotSlots = grounds.fold<int>(
        0, (sum, g) => sum + g.slots.where((s) => s.hasOpponent).length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: _DateStrip(
            selected: widget.date,
            onSelect: (d) {
              widget.onDate(d);
              _advance();
            },
          ),
        ),
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _MetricCell(
                value: grounds.length.toString(),
                label: 'grounds',
              ),
              _DotSep(),
              _MetricCell(
                value: totalSlots.toString(),
                label: 'slots',
              ),
              _DotSep(),
              _MetricCell(
                value: hotSlots.toString(),
                label: 'matchups',
                accent: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            grounds.isEmpty
                ? 'No availability — try another date'
                : 'Availability updates as you slide the date',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

}

// ── Step 4: Arena picker ─────────────────────────────────────────────────────

class _ArenaPickerStep extends ConsumerStatefulWidget {
  const _ArenaPickerStep({
    required this.date,
    required this.format,
    required this.customOvers,
    required this.selectedArena,
    required this.onPickArena,
  });

  final DateTime date;
  final MatchFormat format;
  final int customOvers;
  final MmGround? selectedArena;
  final ValueChanged<MmGround> onPickArena;

  @override
  ConsumerState<_ArenaPickerStep> createState() => _ArenaPickerStepState();
}

class _ArenaPickerStepState extends ConsumerState<_ArenaPickerStep> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.date);
    final groundsAsync = ref.watch(
      mmGroundsProvider((
        date: dateStr,
        format: widget.format.apiValue,
        teamId: null,
        overs: widget.format == MatchFormat.custom ? widget.customOvers : null,
      )),
    );

    return groundsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: LinearProgressIndicator(minHeight: 1.5),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Text(
          'Could not load arenas for this date.',
          style: TextStyle(
            color: context.fgSub,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      data: (grounds) {
        if (grounds.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No arenas on this date',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose another date or adjust your format.',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        final filtered = _query.isEmpty
            ? grounds
            : grounds.where((g) {
                final q = _query.toLowerCase();
                return g.name.toLowerCase().contains(q) ||
                    g.area.toLowerCase().contains(q);
              }).toList();

        final totalSlots =
            grounds.fold<int>(0, (sum, g) => sum + g.slots.length);
        final hotSlots = grounds.fold<int>(0,
            (sum, g) => sum + g.slots.where((s) => s.hasOpponent).length);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepSearchBar(
              hint: 'Search arena or area',
              value: _query,
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _MetricCell(
                    value: grounds.length.toString(),
                    label: 'arenas',
                  ),
                  _DotSep(),
                  _MetricCell(
                    value: totalSlots.toString(),
                    label: 'slots',
                  ),
                  _DotSep(),
                  _MetricCell(
                    value: hotSlots.toString(),
                    label: 'match-ready',
                    accent: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 18),
                child: Text(
                  'No arenas match "$_query".',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              ...filtered.map((g) {
                final hot = g.slots.where((s) => s.hasOpponent).length;
                return _ArenaPickRow(
                  arena: g,
                  matchReadyCount: hot,
                  selected: widget.selectedArena?.id == g.id,
                  onTap: () => widget.onPickArena(g),
                );
              }),
          ],
        );
      },
    );
  }
}

class _ArenaPickRow extends StatelessWidget {
  const _ArenaPickRow({
    required this.arena,
    required this.matchReadyCount,
    required this.selected,
    required this.onTap,
  });

  final MmGround arena;
  final int matchReadyCount;
  final bool selected;
  final VoidCallback onTap;

  String _pretty(String value) {
    return value
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .map((p) =>
            p[0].toUpperCase() + (p.length > 1 ? p.substring(1).toLowerCase() : ''))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final fg = selected ? context.ctaFg : context.fg;
    final fgSub =
        selected ? context.ctaFg.withValues(alpha: 0.75) : context.fgSub;
    final hasMatch = matchReadyCount > 0;
    final accentBar = selected
        ? context.ctaFg
        : hasMatch
            ? context.match
            : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: selected ? context.ctaBg : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 3,
              height: 70,
              color: accentBar,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _pretty(arena.name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fg,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            arena.area.isNotEmpty
                                ? _pretty(arena.area)
                                : 'Cricket arena',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: fgSub,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: fgSub.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${arena.slots.length} SLOT${arena.slots.length == 1 ? '' : 'S'}',
                          style: TextStyle(
                            color: fgSub,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                        if (hasMatch && !selected) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: context.match,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$matchReadyCount READY',
                            style: TextStyle(
                              color: context.match,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            selected
                ? Icon(Icons.check_rounded, color: context.ctaFg, size: 22)
                : Icon(Icons.arrow_forward_rounded,
                    color: context.fgSub, size: 18),
            const SizedBox(width: 18),
          ],
        ),
      ),
    );
  }
}

// ── Step 5: Slot picker (slots for one arena) ────────────────────────────────

class _SlotStep extends ConsumerStatefulWidget {
  const _SlotStep({
    required this.arena,
    required this.picks,
    required this.onAddPick,
    required this.onRemovePick,
    required this.onChangeArena,
  });

  final MmGround arena;
  final List<MmGroundSlotPick> picks;
  final ValueChanged<MmGroundSlotPick> onAddPick;
  final ValueChanged<MmGroundSlotPick> onRemovePick;
  final VoidCallback onChangeArena;

  @override
  ConsumerState<_SlotStep> createState() => _SlotStepState();
}

class _SlotStepState extends ConsumerState<_SlotStep> {
  String _pretty(String value) {
    return value
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .map((p) =>
            p[0].toUpperCase() + (p.length > 1 ? p.substring(1).toLowerCase() : ''))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final arena = widget.arena;
    final slots = [...arena.slots]
      ..sort((a, b) => a.time.compareTo(b.time));
    final matchReady = slots.where((s) => s.hasOpponent).toList();
    final others = slots.where((s) => !s.hasOpponent).toList();
    final pickedHere = widget.picks
        .where((p) => p.ground.id == arena.id)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Arena bar ──────────────────────────────────────────────
        GestureDetector(
          onTap: widget.onChangeArena,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.stadium_rounded,
                    size: 16, color: context.fgSub),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pretty(arena.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.1,
                          height: 1.1,
                        ),
                      ),
                      if (arena.area.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          _pretty(arena.area),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'CHANGE',
                  style: TextStyle(
                    color: context.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    size: 16, color: context.accent),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          color: context.stroke.withValues(alpha: 0.18),
        ),
        const SizedBox(height: 18),

        // ── Stats ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _MetricCell(
                value: slots.length.toString(),
                label: 'slots',
              ),
              _DotSep(),
              _MetricCell(
                value: matchReady.length.toString(),
                label: 'match-ready',
                accent: matchReady.isNotEmpty,
              ),
              _DotSep(),
              _MetricCell(
                value: pickedHere.toString(),
                label: 'picked',
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        if (slots.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 18),
            child: Text(
              'No slots at this arena. Pick another →',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        if (matchReady.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SlotSectionHeader(
              label: 'MATCH READY',
              count: matchReady.length,
              color: context.match,
              hint: 'Opponents waiting · pick fast',
            ),
          ),
          const SizedBox(height: 6),
          ...matchReady.map((s) => _SlotPickRow(
                ground: arena,
                slot: s,
                matchReady: true,
                picked: widget.picks.any((p) =>
                    p.slot.unitId == s.unitId && p.slot.time == s.time),
                onTap: () => widget.onAddPick(
                  MmGroundSlotPick(ground: arena, slot: s),
                ),
                showGround: false,
              )),
          const SizedBox(height: 28),
        ],
        if (others.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SlotSectionHeader(
              label: matchReady.isEmpty ? 'AVAILABLE' : 'OTHER SLOTS',
              count: others.length,
              color: context.fgSub,
              hint: 'No opponent yet · be first',
            ),
          ),
          const SizedBox(height: 6),
          ...others.map((s) => _SlotPickRow(
                ground: arena,
                slot: s,
                matchReady: false,
                picked: widget.picks.any((p) =>
                    p.slot.unitId == s.unitId && p.slot.time == s.time),
                onTap: () => widget.onAddPick(
                  MmGroundSlotPick(ground: arena, slot: s),
                ),
                showGround: false,
              )),
        ],
      ],
    );
  }
}

class _StepSearchBar extends StatelessWidget {
  const _StepSearchBar({
    required this.hint,
    required this.value,
    required this.onChanged,
  });
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 18, color: context.fgSub),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  onChanged: (v) => onChanged(v.trim()),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: context.fgSub,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (value.isNotEmpty)
                GestureDetector(
                  onTap: () => onChanged(''),
                  behavior: HitTestBehavior.opaque,
                  child: Icon(Icons.close_rounded,
                      size: 18, color: context.fgSub),
                ),
            ],
          ),
        ),
        Container(
          height: 1,
          color: context.stroke.withValues(alpha: 0.18),
        ),
      ],
    );
  }
}

class _SlotSectionHeader extends StatelessWidget {
  const _SlotSectionHeader({
    required this.label,
    required this.count,
    required this.color,
    required this.hint,
  });
  final String label;
  final int count;
  final Color color;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(
          color: color, shape: BoxShape.circle,
        )),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.6,
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
        const Spacer(),
        Text(
          hint,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.fgSub.withValues(alpha: 0.75),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _SlotPickRow extends StatelessWidget {
  const _SlotPickRow({
    required this.ground,
    required this.slot,
    required this.matchReady,
    required this.picked,
    required this.onTap,
    this.showGround = true,
  });

  final MmGround ground;
  final MmSlot slot;
  final bool matchReady;
  final bool picked;
  final VoidCallback onTap;
  final bool showGround;

  String _prettyLabel(String value) {
    return value
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .map((p) =>
            p[0].toUpperCase() + (p.length > 1 ? p.substring(1).toLowerCase() : ''))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final groundName = _prettyLabel(ground.name);
    final area =
        ground.area.isNotEmpty ? _prettyLabel(ground.area) : 'Cricket ground';
    final price = slot.priceRupees > 0 ? '₹${slot.priceRupees}' : '';

    final fg = picked ? context.ctaFg : context.fg;
    final fgSub = picked
        ? context.ctaFg.withValues(alpha: 0.75)
        : context.fgSub;

    return GestureDetector(
      onTap: picked ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: picked ? context.ctaBg : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // accent bar (cyan = match-ready, transparent otherwise)
            Container(
              width: 3,
              height: 70,
              color: picked
                  ? context.ctaFg
                  : matchReady
                      ? context.match
                      : Colors.transparent,
            ),
            const SizedBox(width: 13),
            // Time block
            SizedBox(
              width: 88,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    slot.startLabel,
                    style: TextStyle(
                      color: fg,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                      height: 1.0,
                    ),
                  ),
                  if (slot.endLabel.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '→ ${slot.endLabel}',
                      style: TextStyle(
                        color: fgSub,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Ground/secondary info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showGround) ...[
                      Text(
                        groundName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: fg,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.1,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                    ],
                    Row(
                      children: [
                        if (showGround)
                          Flexible(
                            child: Text(
                              area,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: fgSub,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        else
                          Text(
                            slot.displayTime,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: fgSub,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (matchReady && !picked) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: context.match,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'TEAM WAITING',
                            style: TextStyle(
                              color: context.match,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Right side: price + action
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (price.isNotEmpty)
                  Text(
                    price,
                    style: TextStyle(
                      color: fgSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (price.isNotEmpty) const SizedBox(height: 2),
                Text(
                  '/team',
                  style: TextStyle(
                    color: fgSub.withValues(alpha: 0.6),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            picked
                ? Icon(Icons.check_rounded, color: context.ctaFg, size: 22)
                : Icon(Icons.add_rounded, color: context.fgSub, size: 20),
            const SizedBox(width: 18),
          ],
        ),
      ),
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
    final arenaLabel =
        lobby.arenaName.isNotEmpty ? lobby.arenaName : lobby.groundName;
    final dateLabel = lobby.daysFromNow == 0
        ? 'Today'
        : lobby.daysFromNow == 1
            ? 'Tomorrow'
            : DateFormat('MMM d')
                .format(DateTime.tryParse(lobby.date) ?? DateTime.now());
    final venueLine = [
      if (arenaLabel.isNotEmpty) arenaLabel,
      dateLabel,
      lobby.displaySlot,
    ].where((s) => s.isNotEmpty).join('  ·  ');

    final accentColor = highlight ? const Color(0xFF16A34A) : context.accent;

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
                          color: accentColor.withValues(
                              alpha: pulseAnim.value * 0.15 + 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          highlight
                              ? 'SAME PICK'
                              : (lobby.isArenaLobby
                                  ? 'ARENA SLOT'
                                  : 'OPEN TEAM'),
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
          color: onTap != null
              ? context.panel
              : context.panel.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color:
              onTap != null ? context.fg : context.fgSub.withValues(alpha: 0.3),
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
          color: hot ? context.accent.withValues(alpha: 0.07) : context.panel,
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
                child:
                    Icon(Icons.close_rounded, color: context.fgSub, size: 16),
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

  bool _alreadyPicked(MmSlot slot) => widget.existingPicks
      .any((p) => p.slot.unitId == slot.unitId && p.slot.time == slot.time);

  @override
  void initState() {
    super.initState();
    _mmLog(
        '_AddGroundSheet:init date=${widget.query.date} format=${widget.query.format} teamId=${widget.query.teamId} overs=${widget.query.overs} picks=${widget.existingPicks.length}');
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          final repo = ref.read(matchmakingRepositoryProvider);
          final result = await repo.searchGrounds(
            date: widget.query.date,
            format: widget.query.format,
            overs: widget.query.overs,
          );
          _mmLog(
              '_AddGroundSheet:probe result=${result.length} date=${widget.query.date} format=${widget.query.format}');
          for (final g in result.take(10)) {
            _mmLog(
                '  probeGround: id=${g.id} name=${g.name} area=${g.area} slots=${g.slots.length}');
          }
        } catch (e, st) {
          _mmLog('_AddGroundSheet:probe ERROR: $e\n$st');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final groundsAsync = ref.watch(mmGroundsProvider(widget.query));
    final h = MediaQuery.of(context).size.height;
    _mmLog(
        '_AddGroundSheet:build selected=${_selectedGround?.name ?? 'none'} filter=${_filterQuery.isEmpty ? 'none' : _filterQuery}');

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
                width: 36,
                height: 4,
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
                        _selectedGround == null
                            ? 'Choose Ground'
                            : _selectedGround!.name,
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      if (_selectedGround != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(children: [
                            Icon(Icons.location_on_rounded,
                                color: context.fgSub, size: 12),
                            const SizedBox(width: 3),
                            Text(_selectedGround!.area,
                                style: TextStyle(
                                    color: context.fgSub,
                                    fontSize: 12,
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
                    color: context.panel,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search_rounded, color: context.fgSub, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _filterQuery = v),
                      style: TextStyle(
                          color: context.fg,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Search ground or area...',
                        hintStyle:
                            TextStyle(color: context.fgSub, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            Expanded(
              child: groundsAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 1.5)),
                error: (_, __) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sports_cricket_rounded,
                          size: 40,
                          color: context.fgSub.withValues(alpha: 0.3)),
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
                      : grounds
                          .where((g) =>
                              g.name
                                  .toLowerCase()
                                  .contains(_filterQuery.toLowerCase()) ||
                              g.area
                                  .toLowerCase()
                                  .contains(_filterQuery.toLowerCase()))
                          .toList();
                  _mmLog(
                      '_AddGroundSheet:data raw=${grounds.length} filtered=${filtered.length} selected=${_selectedGround?.name ?? 'none'}');
                  for (final g in filtered.take(10)) {
                    _mmLog(
                        '  filteredGround: id=${g.id} name=${g.name} area=${g.area} slots=${g.slots.length}');
                  }
                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sports_cricket_rounded,
                              size: 40,
                              color: context.fgSub.withValues(alpha: 0.3)),
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
                      final hotCount =
                          g.slots.where((s) => s.hasOpponent).length;
                      return GestureDetector(
                        onTap: () {
                          _mmLog(
                              '_AddGroundSheet:selectGround id=${g.id} name=${g.name} area=${g.area} slots=${g.slots.length}');
                          setState(() => _selectedGround = g);
                        },
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
                                child:
                                    g.photoUrl != null && g.photoUrl!.isNotEmpty
                                        ? Image.network(g.photoUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _GroundImagePlaceholder())
                                        : _GroundImagePlaceholder(),
                              ),
                              // Info
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(14, 12, 14, 14),
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
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.2,
                                              )),
                                          const SizedBox(height: 4),
                                          Row(children: [
                                            Icon(Icons.location_on_rounded,
                                                color: context.fgSub, size: 12),
                                            const SizedBox(width: 3),
                                            Text(g.area,
                                                style: TextStyle(
                                                    color: context.fgSub,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            const SizedBox(width: 10),
                                            Icon(Icons.schedule_rounded,
                                                color: context.fgSub, size: 12),
                                            const SizedBox(width: 3),
                                            Text('${g.slots.length} slots',
                                                style: TextStyle(
                                                    color: context.fgSub,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ]),
                                        ],
                                      ),
                                    ),
                                    if (hotCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: context.accent
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                            '⚡ $hotCount rival${hotCount > 1 ? 's' : ''}',
                                            style: TextStyle(
                                                color: context.accent,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700)),
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
            if (_selectedGround!.photoUrl != null &&
                _selectedGround!.photoUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 16 / 6,
                    child: Image.network(_selectedGround!.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('Pick a slot',
                  style: TextStyle(
                      color: context.fgSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8)),
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
                    onTap: taken
                        ? null
                        : () {
                            _mmLog(
                                '_AddGroundSheet:pickSlot ground=${_selectedGround!.name} unitId=${slot.unitId} time=${slot.time} end=${slot.endTime ?? 'null'} taken=$taken hot=$hot');
                            widget.onPick(MmGroundSlotPick(
                                ground: _selectedGround!, slot: slot));
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
                              ? Border.all(
                                  color: context.accent.withValues(alpha: 0.4))
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hot)
                              const Text('⚡', style: TextStyle(fontSize: 10)),
                            if (slot.endTime != null &&
                                slot.endTime!.isNotEmpty) ...[
                              Text(slot.startLabel,
                                  style: TextStyle(
                                    color: hot ? context.accent : context.fg,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  )),
                              Text('→ ${slot.endLabel}',
                                  style: TextStyle(
                                    color: hot
                                        ? context.accent.withValues(alpha: 0.8)
                                        : context.fgSub,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ] else
                              Text(slot.displayTime,
                                  style: TextStyle(
                                    color: hot ? context.accent : context.fg,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  )),
                            const SizedBox(height: 2),
                            Text('₹${slot.priceRupees}',
                                style: TextStyle(
                                    color: context.fgSub,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500)),
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
        child: Icon(Icons.stadium_rounded, color: context.stroke, size: 36),
      ),
    );
  }
}

// ── Find: scanning ────────────────────────────────────────────────────────────

class _ScanningFind extends StatefulWidget {
  const _ScanningFind({
    super.key,
    required this.team,
    required this.format,
    required this.date,
    required this.picks,
    required this.scanStep,
    required this.scanStatus,
  });

  final MmTeam? team;
  final MatchFormat format;
  final DateTime date;
  final List<MmGroundSlotPick> picks;
  final int scanStep;
  final String? scanStatus;

  @override
  State<_ScanningFind> createState() => _ScanningFindState();
}

class _ScanningFindState extends State<_ScanningFind>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _wave;

  static const _phases = [
    ('Finding match', 'Reading your request'),
    ('Searching nearby requests', 'Looking for active lobbies'),
    ('Analysing available grounds', 'Checking the ground and slot list'),
    ('Checking same ground, different slots', 'Looking for a closer fit'),
  ];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phase = widget.scanStep.clamp(0, _phases.length - 1);
    final phaseTitle = _phases[phase].$1;
    final phaseSubtitle = _phases[phase].$2;
    final dateLabel = DateFormat('MMM d').format(widget.date);
    final picksLabel = widget.picks.isEmpty
        ? 'No slots chosen'
        : '${widget.picks.length} slot${widget.picks.length > 1 ? 's' : ''} selected';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FINDING MATCHUP',
            style: TextStyle(
              color: context.accent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.team?.name ?? 'Your team',
            style: TextStyle(
              color: context.fg,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'is being matched against live slot availability',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: Listenable.merge([_pulse, _wave]),
            builder: (context, _) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.panel,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: context.stroke.withValues(alpha: 0.75),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          for (int i = 0; i < 3; i++)
                            _RadarRing(
                              progress: (_wave.value + i / 3) % 1.0,
                              color: context.accent,
                            ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: context.accent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: context.accent.withValues(alpha: 0.3),
                                  blurRadius: 18,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            child: AnimatedOpacity(
                              opacity: 0.75 + (_pulse.value * 0.25),
                              duration: const Duration(milliseconds: 120),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: context.accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  phaseTitle,
                                  style: TextStyle(
                                    color: context.accent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Column(
                        key: ValueKey(phase),
                        children: [
                          Text(
                            phaseSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.fg,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$dateLabel  ·  $picksLabel',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.fgSub,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: List.generate(_phases.length, (i) {
                        final active = i == phase;
                        final done = i < phase;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: active
                                  ? context.accent.withValues(alpha: 0.08)
                                  : context.bg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: active
                                    ? context.accent.withValues(alpha: 0.35)
                                    : context.stroke.withValues(alpha: 0.55),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: done
                                        ? const Color(0xFF16A34A)
                                        : active
                                            ? context.accent
                                            : context.fgSub
                                                .withValues(alpha: 0.35),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _phases[i].$1,
                                    style: TextStyle(
                                      color: active || done
                                          ? context.fg
                                          : context.fgSub,
                                      fontSize: 13,
                                      fontWeight: active
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (done)
                                  Icon(Icons.check_rounded,
                                      size: 14, color: const Color(0xFF16A34A))
                                else if (active)
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.7,
                                      color: context.accent,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'We will not jump to a result until the scan finishes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Text(
            'We will show a result only after we finish the scan.',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
      ...widget.picks
          .map((p) => (unitId: p.slot.unitId, slotTime: p.slot.time)),
      ...widget.restoredPicks
          .map((p) => (unitId: p.groundId, slotTime: p.slotTime)),
    ];

    final allOpenLobbies = lobbiesAsync.valueOrNull ?? [];
    final matchedLobbies = allOpenLobbies
        .where((l) =>
            l.unitId != null &&
            pickUnitSlots.any((ps) =>
                ps.unitId.isNotEmpty &&
                ps.unitId == l.unitId &&
                ps.slotTime == l.slotTime))
        .toList();
    final sameGroundLobbies = allOpenLobbies
        .where((l) =>
            l.unitId != null &&
            pickUnitSlots.any((ps) =>
                ps.unitId.isNotEmpty &&
                ps.unitId == l.unitId &&
                ps.slotTime != l.slotTime))
        .toList();

    for (final ps in pickUnitSlots) {
      _mmLog(
          '_SearchingFind pick: unitId=${ps.unitId} slotTime=${ps.slotTime}');
    }
    for (final l in allOpenLobbies) {
      _mmLog('_SearchingFind open: unitId=${l.unitId} slotTime=${l.slotTime}');
    }
    _mmLog(
        '_SearchingFind: pickUnitSlots=${pickUnitSlots.length} openLobbies=${allOpenLobbies.length} matched=${matchedLobbies.length} sameGround=${sameGroundLobbies.length}');

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
    final hasSameGround = sameGroundLobbies.isNotEmpty;

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
                      for (int i = 0; i < 3; i++)
                        _RadarRing(
                          progress: (_radar.value + i / 3) % 1.0,
                          color: context.accent,
                        ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: context.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
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

          if (hasSameGround) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: context.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: context.accent.withValues(alpha: 0.32),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.sports_cricket_rounded,
                      color: context.accent, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Same ground has an active matchup in another slot',
                      style: TextStyle(
                        color: context.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ...sameGroundLobbies.map((lobby) => _InstantLobbyRow(
                  lobby: lobby,
                  pulseAnim: _glow,
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
          DateTime(n.year, n.month, n.day)) {
        return 'Today';
      }
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
            team?.name ?? 'Your team',
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
              groundName,
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
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: context.panel,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.stroke.withValues(alpha: 0.55)),
            ),
            child: Row(
              children: [
                Icon(Icons.sports_cricket_rounded,
                    color: context.accent, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    waitingOpponent
                        ? 'Same slot is locked. Waiting on the opponent.'
                        : 'Same slot found. Confirm to lock it.',
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
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
            if (deadline != null) _CountdownTimer(deadline: deadline),
            const SizedBox(height: 8),
            Text(
              'Your ₹$confirmFee deposit is confirmed.',
              style: TextStyle(
                  color: context.fg, fontSize: 15, fontWeight: FontWeight.w700),
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
    this.myLobbyId,
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
    this.status = 'confirmed',
    this.myTeamPaid = true,
    this.opponentPaid = true,
    this.confirmationFeePaise = 0,
  });

  final String matchId;
  final String? myLobbyId;
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
  final String status; // pending_payment | confirmed | setup | started
  final bool myTeamPaid;
  final bool opponentPaid;
  final int confirmationFeePaise;

  int get remainingRupees => remainingFeePaise ~/ 100;
  int get confirmationRupees => confirmationFeePaise ~/ 100;
  bool get isPaymentPending => !myTeamPaid;
  bool get isAwaitingOpponent => myTeamPaid && !opponentPaid;
  bool get isFullyConfirmed =>
      myTeamPaid && opponentPaid && status != 'pending_payment';

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
        myLobbyId: j['myLobbyId'] as String?,
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
        status: (j['status'] as String?) ?? 'confirmed',
        myTeamPaid: (j['myTeamPaid'] as bool?) ?? true,
        opponentPaid: (j['opponentPaid'] as bool?) ?? true,
        confirmationFeePaise:
            (j['confirmationFeePaise'] as num?)?.toInt() ?? 0,
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
                          size: 48,
                          color: context.fgSub.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'No matchups yet',
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your matchups will appear here once you join one or an arena owner pairs you in.',
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

class _MatchCard extends ConsumerWidget {
  const _MatchCard({required this.match});
  final _MyConfirmedMatch match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => MyMatchupDetailSheet(
          matchId: match.matchId,
          myLobbyId: match.myLobbyId,
          opponentTeamName: match.opponentTeamName,
          groundName: match.groundName,
          arenaName: match.arenaName,
          groundArea: match.groundArea,
          dateLabel: match.dateLabel,
          displaySlot: match.displaySlot,
          format: match.format,
          confirmationRupees: match.confirmationRupees,
          remainingRupees: match.remainingRupees,
          myTeamPaid: match.myTeamPaid,
          opponentPaid: match.opponentPaid,
          status: match.status,
          onRefresh: () => ref.invalidate(_myMatchesProvider),
        ),
      ),
      child: _MatchCardBody(match: match),
    );
  }
}

class _MatchCardBody extends StatelessWidget {
  const _MatchCardBody({required this.match});
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
              _CardStatusPill(match: match),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: context.stroke.withValues(alpha: 0.4)),
        ],
      ),
    );
  }
}

/// Trailing pill on the My MatchUp card. Shows the most actionable thing the
/// player needs to know about this match at a glance:
///   • myTeamPaid=false                    → "Pay ₹500" (coral) — tap card to pay
///   • myTeamPaid && !opponentPaid         → "Awaiting opponent" (muted)
///   • both paid && remaining ground fee   → "₹X due at ground" (amber)
///   • both paid && no remaining           → no pill
class _CardStatusPill extends StatelessWidget {
  const _CardStatusPill({required this.match});
  final _MyConfirmedMatch match;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Pay-due — most actionable, gets coral.
    if (match.isPaymentPending) {
      final amount = match.confirmationRupees;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount > 0 ? 'Pay ₹$amount' : 'Pay advance',
              style: TextStyle(
                color: colors.onPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'tap to pay',
              style: TextStyle(
                color: colors.onPrimary.withValues(alpha: 0.85),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Paid but waiting for opponent.
    if (match.isAwaitingOpponent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: context.fgSub.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Awaiting',
              style: TextStyle(
                color: context.fg,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'opponent\'s pay',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Confirmed + remaining ground fee.
    if (match.remainingRupees > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
      );
    }

    return const SizedBox.shrink();
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
    _debounce =
        Timer(const Duration(milliseconds: 400), () => _search(q.trim()));
  }

  Future<void> _search(String q) async {
    setState(() => _loading = true);
    try {
      final resp = await ApiClient.instance.dio.get(
        ApiEndpoints.searchTeams,
        queryParameters: {'q': q, 'limit': 20},
      );
      final data =
          resp.data is Map ? (resp.data['data'] ?? resp.data) : resp.data;
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
                      hintStyle: TextStyle(color: context.fgSub, fontSize: 15),
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
              ? const Center(child: CircularProgressIndicator(strokeWidth: 1.5))
              : !_searched
                  ? _EmptyChallenge()
                  : _results.isEmpty
                      ? Center(
                          child: Text(
                            'No teams found',
                            style:
                                TextStyle(color: context.fgSub, fontSize: 14),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => Container(
                              height: 1,
                              color: context.stroke.withValues(alpha: 0.3)),
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
                                  _expandedId = expanded ? null : team.id),
                              onFormat: (f) =>
                                  setState(() => _challengeFormat = f),
                              onDate: (d) => setState(() => _challengeDate = d),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
          crossFadeState:
              expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
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
            child: Container(
              width: isToday ? 64 : 56,
              decoration: BoxDecoration(
                color: isSel ? context.ctaBg : Colors.transparent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isToday
                        ? 'TODAY'
                        : isNewMonth
                            ? DateFormat('MMM').format(d).toUpperCase()
                            : DateFormat('EEE').format(d).toUpperCase(),
                    style: TextStyle(
                      color: isSel
                          ? context.ctaFg
                          : isWeekend
                              ? context.fgSub.withValues(alpha: 0.85)
                              : context.fgSub,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      color: isSel ? context.ctaFg : context.fg,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 3,
                    width: isSel ? 28 : 12,
                    decoration: BoxDecoration(
                      color: isSel
                          ? context.ctaFg
                          : context.stroke.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(999),
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
  static const _mn = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

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
          children: List.generate(
              7,
              (i) => Expanded(
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
