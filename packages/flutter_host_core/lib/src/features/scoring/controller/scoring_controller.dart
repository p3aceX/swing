import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/scoring_repository.dart';
import '../domain/scoring_models.dart';
import '../domain/scoring_rules.dart';
import '../domain/wagon_zone.dart';

class HostScoringState {
  const HostScoringState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.match,
    this.players,
    this.strikerId,
    this.nonStrikerId,
    this.bowlerId,
    this.zone,
    this.isFreeHit = false,
    this.lastCommentaryText,
    this.error,
    this.message,
  });

  final bool isLoading;
  final bool isSubmitting;
  final ScoringMatch? match;
  final ScoringPlayersData? players;
  final String? strikerId;
  final String? nonStrikerId;
  final String? bowlerId;
  final String? zone;
  final bool isFreeHit;
  final String? lastCommentaryText;
  final String? error;
  final String? message;

  HostScoringState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    ScoringMatch? match,
    ScoringPlayersData? players,
    String? strikerId,
    String? nonStrikerId,
    String? bowlerId,
    String? zone,
    bool? isFreeHit,
    String? lastCommentaryText,
    String? error,
    String? message,
    bool clearStrikerId = false,
    bool clearNonStrikerId = false,
    bool clearBowlerId = false,
    bool clearZone = false,
    bool clearLastCommentary = false,
    bool clearMessage = false,
    bool clearError = false,
  }) =>
      HostScoringState(
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        match: match ?? this.match,
        players: players ?? this.players,
        strikerId: clearStrikerId ? null : (strikerId ?? this.strikerId),
        nonStrikerId:
            clearNonStrikerId ? null : (nonStrikerId ?? this.nonStrikerId),
        bowlerId: clearBowlerId ? null : (bowlerId ?? this.bowlerId),
        zone: clearZone ? null : (zone ?? this.zone),
        isFreeHit: isFreeHit ?? this.isFreeHit,
        lastCommentaryText: clearLastCommentary
            ? null
            : (lastCommentaryText ?? this.lastCommentaryText),
        error: clearError ? null : (error ?? this.error),
        message: clearMessage ? null : (message ?? this.message),
      );

  ScoringInnings? get activeInnings => match?.activeInnings;
  List<ScoringBall> get balls => activeInnings?.balls ?? [];

  String _effectiveId(String? raw) => players?.normalizeId(raw) ?? raw ?? '';
  String get effectiveStrikerId =>
      _effectiveId(strikerId ?? activeInnings?.currentStrikerId);
  String get effectiveNonStrikerId =>
      _effectiveId(nonStrikerId ?? activeInnings?.currentNonStrikerId);
  String get effectiveBowlerId =>
      _effectiveId(bowlerId ?? activeInnings?.currentBowlerId);

  bool get canScore =>
      effectiveStrikerId.isNotEmpty &&
      effectiveNonStrikerId.isNotEmpty &&
      effectiveBowlerId.isNotEmpty &&
      activeInnings != null &&
      !(match?.isComplete ?? true) &&
      !inningsOver;

  ScoringMatchPlayer? striker(ScoringPlayersData? p) =>
      p?.findById(effectiveStrikerId);
  ScoringMatchPlayer? nonStriker(ScoringPlayersData? p) =>
      p?.findById(effectiveNonStrikerId);
  ScoringMatchPlayer? bowler(ScoringPlayersData? p) =>
      p?.findById(effectiveBowlerId);

  ({int runs, int balls, int fours, int sixes}) batterStats(String id) {
    final targetId = _effectiveId(id);
    int r = 0, b = 0, fours = 0, sixes = 0;
    for (final ball in balls) {
      if (_effectiveId(ball.batterId) != targetId) continue;
      if (scoringDeliveryIsLegal(
        ball.outcome,
        dismissalType: ball.dismissalType,
      )) {
        b++;
      }
      r += scoringBatterRuns(
        outcome: ball.outcome,
        runs: ball.runs,
      );
      if (ball.outcome == 'FOUR') fours++;
      if (ball.outcome == 'SIX') sixes++;
    }
    return (runs: r, balls: b, fours: fours, sixes: sixes);
  }

  ({String overs, int runs, int wickets, String eco}) bowlerStats(String id) {
    final targetId = _effectiveId(id);
    int legal = 0, runs = 0, wkts = 0;
    for (final ball in balls) {
      if (_effectiveId(ball.bowlerId) != targetId) continue;
      if (scoringDeliveryIsLegal(
        ball.outcome,
        dismissalType: ball.dismissalType,
      )) {
        legal++;
      }
      runs += scoringBowlerRunsConceded(
        outcome: ball.outcome,
        runs: ball.runs,
        extras: ball.extras,
      );
      if (scoringDismissalCountsAsInningsWicket(
            isWicket: ball.isWicket,
            dismissalType: ball.dismissalType,
          ) &&
          scoringDismissalCountsAsBowlerWicket(ball.dismissalType)) {
        wkts++;
      }
    }
    final co = legal ~/ 6;
    final rb = legal % 6;
    final eco = legal > 0 ? (runs / (legal / 6)).toStringAsFixed(1) : '-';
    return (overs: '$co.$rb', runs: runs, wickets: wkts, eco: eco);
  }

  bool get isEndOfOver => (activeInnings?.legalCount ?? 0) > 0 && (activeInnings!.legalCount % 6 == 0);

  bool get inningsOver {
    final inn = activeInnings;
    if (inn == null) return false;
    final chaseTarget = target;

    if (chaseTarget != null && inn.totalRuns >= chaseTarget) {
      if (!(match?.isMultiInnings ?? false)) return true;
      if (inn.inningsNumber >= 4 ||
          ((match?.format ?? '') == 'TWO_INNINGS' && inn.inningsNumber >= 2)) {
        return true;
      }
    }

    final maxOvers = match?.maxOvers ?? 20;
    final isTest = match?.format == 'TEST';
    final legalDeliveries = inn.overNumber * 6 + inn.ballInOver;

    if (inn.totalWickets >= 10) return true;
    if (!isTest && legalDeliveries >= maxOvers * 6) return true;

    return false;
  }

  int? get target {
    final m = match;
    final inn = activeInnings;
    if (m == null || inn == null) return null;

    if (!m.isMultiInnings) {
      final first = m.completedFirstInnings;
      if (first == null || inn.inningsNumber != 2) return null;
      return first.totalRuns + 1;
    }

    if (m.format == 'TEST' && inn.inningsNumber < 4) return null;
    if (m.format == 'TWO_INNINGS' && inn.inningsNumber < 2) return null;

    final battingTeam = inn.battingTeam;
    final opponentInnings = m.innings
        .where((i) => i.isCompleted && i.battingTeam != battingTeam)
        .toList();
    final ownPreviousInnings = m.innings
        .where((i) => i.isCompleted && i.battingTeam == battingTeam)
        .toList();

    if (opponentInnings.isEmpty) return null;
    if (ownPreviousInnings.length >= opponentInnings.length) return null;

    final opponentTotal = opponentInnings.fold(0, (s, i) => s + i.totalRuns);
    final ownTotal = ownPreviousInnings.fold(0, (s, i) => s + i.totalRuns);
    final diff = opponentTotal - ownTotal;
    if (diff < 0) return null;
    return diff + 1;
  }

  int? get toWin {
    final t = target;
    if (t == null) return null;
    final current = activeInnings?.totalRuns ?? 0;
    return t - current;
  }
}

class HostScoringController extends StateNotifier<HostScoringState> {
  HostScoringController(this._service, this._matchId)
      : super(const HostScoringState(isLoading: true)) {
    _init();
  }

  final HostScoringService _service;
  final String _matchId;

  static const _retryDelays = [800, 1500, 2500, 4000];
  static const _coldStartRetryDelays = [5000, 10000, 15000];

  static bool _is503(Object e) =>
      e is DioException && e.response?.statusCode == 503;

  Future<T> _withColdStartRetry<T>(Future<T> Function() fn) async {
    for (int i = 0; i <= _coldStartRetryDelays.length; i++) {
      try {
        return await fn();
      } catch (e) {
        if (_is503(e) && i < _coldStartRetryDelays.length) {
          final delay = _coldStartRetryDelays[i];
          print('[503] server cold-starting, retrying in ${delay ~/ 1000}s… (attempt ${i + 1}/${_coldStartRetryDelays.length})');
          await Future.delayed(Duration(milliseconds: delay));
          continue;
        }
        rethrow;
      }
    }
    throw StateError('unreachable');
  }

  Future<void> _init({int attempt = 0}) async {
    try {
      final results = await Future.wait([
        _service.loadMatch(_matchId),
        _service.loadPlayers(_matchId),
      ]);
      if (!mounted) return;
      final match = results[0] as ScoringMatch;
      final players = results[1] as ScoringPlayersData;
      final innings = match.activeInnings;
      final nextStrikerId = players.normalizeId(innings?.currentStrikerId);
      final nextNonStrikerId =
          players.normalizeId(innings?.currentNonStrikerId);
      final nextBowlerId = players.normalizeId(innings?.currentBowlerId);

      state = state.copyWith(
        isLoading: false,
        isSubmitting: false,
        match: match,
        players: players,
        strikerId: nextStrikerId,
        clearStrikerId: false,
        nonStrikerId: nextNonStrikerId,
        clearNonStrikerId: false,
        bowlerId: nextBowlerId,
        clearBowlerId: false,
        isFreeHit: innings?.isFreeHit ?? false,
        clearError: true,
      );
    } catch (e) {
      _logError('_init(attempt=$attempt)', e);
      final statusCode = e is DioException ? (e.response?.statusCode ?? 0) : 0;
      final isAuthError = statusCode == 401 || statusCode == 403;
      final canRetry = !isAuthError && attempt < _retryDelays.length;

      if (canRetry && mounted) {
        await Future.delayed(Duration(milliseconds: _retryDelays[attempt]));
        if (mounted) return _init(attempt: attempt + 1);
        return;
      }
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          isSubmitting: false,
          error: _msg(e),
        );
      }
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _init();
  }

  Future<bool> startMatch() async {
    print('[scoring] startMatch matchId=$_matchId');
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _service.startMatch(_matchId);
      print('[scoring] startMatch ✓');
      await _init();
      return true;
    } catch (e) {
      _logError('startMatch', e);
      state = state.copyWith(isSubmitting: false, error: _msg(e));
      return false;
    }
  }

  Future<bool> updateMatchOvers(int overs) async {
    if (overs <= 0) {
      state = state.copyWith(error: 'Overs must be greater than 0');
      return false;
    }
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _service.updateMatchOvers(_matchId, overs);
      await _init();
      return true;
    } catch (e) {
      _logError('updateMatchOvers', e);
      state = state.copyWith(isSubmitting: false, error: _msg(e));
      return false;
    }
  }

  Future<bool> updateMatchSchedule(DateTime scheduledAt) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _service.updateMatchSchedule(_matchId, scheduledAt);
      await _init();
      return true;
    } catch (e) {
      _logError('updateMatchSchedule', e);
      state = state.copyWith(isSubmitting: false, error: _msg(e));
      return false;
    }
  }

  Future<bool> recordToss(String tossWonBy, String tossDecision) async {
    print('[scoring] recordToss tossWonBy=$tossWonBy tossDecision=$tossDecision');
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _service.recordToss(_matchId, tossWonBy, tossDecision);
      print('[scoring] recordToss ✓');
      await _init();
      return true;
    } catch (e) {
      _logError('recordToss', e);
      state = state.copyWith(isSubmitting: false, error: _msg(e));
      return false;
    }
  }

  Future<bool> changeScorer(String scorerId) async {
    final normalizedScorerId =
        (state.players?.normalizeId(scorerId) ?? scorerId).trim();
    if (normalizedScorerId.isEmpty) {
      state = state.copyWith(error: 'Select a scorer to continue');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _service.updateScorer(_matchId, normalizedScorerId);
      await _init();
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: _msg(e));
      return false;
    }
  }

  void setStarter({
    required String strikerId,
    required String nonStrikerId,
    required String bowlerId,
  }) {
    final players = state.players;
    final nextStriker = players?.normalizeId(strikerId) ?? strikerId;
    final nextNonStriker = players?.normalizeId(nonStrikerId) ?? nonStrikerId;
    state = state.copyWith(
      strikerId: nextStriker,
      nonStrikerId: nextNonStriker == nextStriker ? null : nextNonStriker,
      bowlerId: players?.normalizeId(bowlerId) ?? bowlerId,
      clearNonStrikerId: nextNonStriker == nextStriker,
    );
  }

  void setZone(String? zone) {
    final canonical = zone == 'INNER' ? 'INNER' : canonicalizeWagonZone(zone);
    state = state.copyWith(zone: canonical, clearZone: canonical == null);
  }

  void swapBatters() {
    final s = state.effectiveStrikerId;
    final ns = state.effectiveNonStrikerId;
    if (s.isEmpty || ns.isEmpty || s == ns) {
      state = state.copyWith(error: 'Select distinct striker and non-striker');
      return;
    }
    state = state.copyWith(strikerId: ns, nonStrikerId: s);
  }

  Future<bool> changeWicketKeeper(String team, String playerId) async {
    print('[scoring] changeWicketKeeper team=$team playerId=$playerId');
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _service.changeWicketKeeper(_matchId, team, playerId);
      print('[scoring] changeWicketKeeper ✓');
      await _init();
      return true;
    } catch (e) {
      _logError('changeWicketKeeper', e);
      state = state.copyWith(isSubmitting: false, error: _msg(e));
      return false;
    }
  }

  void setBowler(String bowlerId) => state = state.copyWith(
        bowlerId: state.players?.normalizeId(bowlerId) ?? bowlerId,
      );

  void setNewBatter(String newBatterId) => state = state.copyWith(
        strikerId: state.players?.normalizeId(newBatterId) ?? newBatterId,
      );

  void setNonStriker(String nonStrikerId) => state = state.copyWith(
        nonStrikerId:
            (state.players?.normalizeId(nonStrikerId) ?? nonStrikerId) ==
                    state.effectiveStrikerId
                ? null
                : state.players?.normalizeId(nonStrikerId) ?? nonStrikerId,
        clearNonStrikerId:
            (state.players?.normalizeId(nonStrikerId) ?? nonStrikerId) ==
                state.effectiveStrikerId,
      );

  Future<bool> recordBall({
    required String outcome,
    required int runs,
    required int extras,
    bool isWicket = false,
    bool isOverthrow = false,
    int overthrowRuns = 0,
    String? dismissalType,
    String? dismissedPlayerId,
    String? fielderId,
    List<String> tags = const [],
  }) async {
    final inn = state.activeInnings;
    if (inn == null) return false;
    final sid = state.effectiveStrikerId;
    final nsid = state.effectiveNonStrikerId;
    final bid = state.effectiveBowlerId;
    if (sid.isEmpty) {
      state = state.copyWith(error: 'Select striker to continue');
      return false;
    }
    if (nsid.isEmpty) {
      state = state.copyWith(error: 'Select non-striker to continue');
      return false;
    }
    if (bid.isEmpty) {
      state = state.copyWith(error: 'Select bowler to continue');
      return false;
    }

    final strikerName = state.striker(state.players)?.name ?? 'Batter';
    final bowlerName = state.bowler(state.players)?.name ?? 'Bowler';
    final wasFreeHit = state.isFreeHit;
    final inningsNonStrikerId =
        state.players?.normalizeId(inn.currentNonStrikerId) ??
            inn.currentNonStrikerId ??
            '';
    // Always include nonBatterId when recording a non-striker dismissal so the
    // backend validation (dismissedPlayerId must match batterId or nonBatterId) passes.
    final isNonStrikerWicket = isWicket && dismissedPlayerId == nsid && nsid.isNotEmpty;
    final nextNonStrikerId = (nsid == inningsNonStrikerId && !isNonStrikerWicket) ? null : nsid;

    state = state.copyWith(isSubmitting: true, clearError: true);
    print('[recordBall] → matchId=$_matchId inn=${inn.inningsNumber} over=${inn.overNumber} ball=${inn.ballInOver + 1} outcome=$outcome runs=$runs extras=$extras isWicket=$isWicket striker=$sid bowler=$bid');
    try {
      await _withColdStartRetry(() => _service.recordBall(
        _matchId,
        inn.inningsNumber,
        batterId: sid,
        nonBatterId: nextNonStrikerId,
        bowlerId: bid,
        overNumber: inn.overNumber,
        ballNumber: inn.ballInOver + 1,
        outcome: outcome,
        runs: runs,
        extras: extras,
        isWicket: isWicket,
        isOverthrow: isOverthrow,
        overthrowRuns: overthrowRuns,
        dismissalType: dismissalType,
        dismissedPlayerId: dismissedPlayerId,
        fielderId: fielderId,
        wagonZone: outcome == 'DOT' ? null : canonicalizeWagonZone(state.zone),
        tags: tags,
      ));
      print('[recordBall] ✓ success — refreshing state');
      await _init();

      final commentary = _buildCommentary(
        outcome,
        runs,
        extras,
        strikerName,
        bowlerName,
        dismissalType,
        wasFreeHit: wasFreeHit,
      );

      state = state.copyWith(
        lastCommentaryText: commentary,
        clearZone: true,
        clearError: true,
      );
      return true;
    } catch (e) {
      if (e is DioException) {
        print('[recordBall] ✗ status=${e.response?.statusCode} body=${e.response?.data}');
        final code = (e.response?.data is Map)
            ? '${(e.response!.data as Map)['error'] is Map ? ((e.response!.data as Map)['error'] as Map)['code'] : ''}'
            : '';
        if (code == 'INNINGS_COMPLETED') {
          await _init();
          state = state.copyWith(
            isSubmitting: false,
            error: 'Innings already completed. State refreshed.',
          );
          return false;
        }
      } else {
        print('[recordBall] ✗ error: $e');
      }
      state = state.copyWith(isSubmitting: false, error: _msg(e));
      return false;
    }
  }

  Future<bool> patchInningsState({
    required int inningsNumber,
    required String strikerId,
    String? nonStrikerId,
    required String bowlerId,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final patchedInnings = await _service.patchInningsState(
        _matchId,
        inningsNumber,
        strikerId: strikerId,
        nonStrikerId: nonStrikerId,
        bowlerId: bowlerId,
      );
      final currentMatch = state.match;
      final players = state.players;
      if (currentMatch == null) {
        await _init();
        return true;
      }

      final updatedInnings = currentMatch.innings
          .map((innings) =>
              innings.inningsNumber == inningsNumber ? patchedInnings : innings)
          .toList();

      final updatedMatch = ScoringMatch(
        id: currentMatch.id,
        status: currentMatch.status,
        teamAName: currentMatch.teamAName,
        teamBName: currentMatch.teamBName,
        format: currentMatch.format,
        innings: updatedInnings,
        customOvers: currentMatch.customOvers,
        tossWonBy: currentMatch.tossWonBy,
        tossDecision: currentMatch.tossDecision,
        winnerId: currentMatch.winnerId,
        winMargin: currentMatch.winMargin,
        matchType: currentMatch.matchType,
        hasImpactPlayer: currentMatch.hasImpactPlayer,
        teamAPlayerIds: currentMatch.teamAPlayerIds,
        teamBPlayerIds: currentMatch.teamBPlayerIds,
        scorerId: currentMatch.scorerId,
      );
      state = state.copyWith(
        isSubmitting: false,
        match: updatedMatch,
        strikerId: players?.normalizeId(patchedInnings.currentStrikerId) ??
            patchedInnings.currentStrikerId,
        clearStrikerId: patchedInnings.currentStrikerId == null,
        nonStrikerId:
            players?.normalizeId(patchedInnings.currentNonStrikerId) ??
                patchedInnings.currentNonStrikerId,
        clearNonStrikerId: patchedInnings.currentNonStrikerId == null,
        bowlerId: players?.normalizeId(patchedInnings.currentBowlerId) ??
            patchedInnings.currentBowlerId,
        clearBowlerId: patchedInnings.currentBowlerId == null,
        isFreeHit: patchedInnings.isFreeHit,
        clearError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: _msg(e));
      return false;
    }
  }

  Future<bool> undoLastBall() async {
    final inn = state.activeInnings;
    if (inn == null) {
      print('[undoLastBall] skipped — no active innings');
      return false;
    }
    print('[undoLastBall] → matchId=$_matchId inn=${inn.inningsNumber} totalBalls=${inn.balls.length} lastBall=${inn.balls.isNotEmpty ? inn.balls.last.outcome : "none"}');
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _withColdStartRetry(() => _service.undoLastBall(_matchId, inn.inningsNumber));
      print('[undoLastBall] ✓ success');
      await _init();
      return true;
    } catch (e) {
      if (e is DioException) {
        print('[undoLastBall] ✗ status=${e.response?.statusCode} body=${e.response?.data}');
      } else {
        print('[undoLastBall] ✗ error: $e');
      }
      state = state.copyWith(isSubmitting: false, error: _msg(e));
      return false;
    }
  }

  Future<bool> completeInnings() async {
    final inn = state.activeInnings;
    print('[completeInnings] inn=$inn inningsNumber=${inn?.inningsNumber} isCompleted=${inn?.isCompleted}');
    if (inn == null) {
      print('[completeInnings] SKIP — no active innings');
      return false;
    }
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _service.completeInnings(_matchId, inn.inningsNumber);
      print('[completeInnings] OK innings=${inn.inningsNumber}');
      await _init();
      return true;
    } catch (e, st) {
      print('[completeInnings] ERROR: $e\n$st');
      state = state.copyWith(isSubmitting: false, error: _msg(e));
      return false;
    }
  }

  Future<bool> continueInnings() async {
    print('[continueInnings] matchId=$_matchId');
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _service.continueInnings(_matchId);
      print('[continueInnings] OK');
      await _init();
      return true;
    } catch (e, st) {
      print('[continueInnings] ERROR: $e\n$st');
      state = state.copyWith(isSubmitting: false, error: _msg(e));
      return false;
    }
  }

  Future<bool> completeMatch(String winnerId, String? winMargin) async {
    print('[completeMatch] winnerId="$winnerId" winMargin="$winMargin" matchStatus=${state.match?.isComplete}');
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _service.completeMatch(_matchId, winnerId, winMargin);
      print('[completeMatch] OK');
      await _init();
      return true;
    } catch (e, st) {
      print('[completeMatch] ERROR: $e\n$st');
      state = state.copyWith(isSubmitting: false, error: _msg(e));
      return false;
    }
  }

  Future<List<ScoringMatchPlayer>> searchPlayers(String query) =>
      _service.searchPlayers(query);

  void clearError() => state = state.copyWith(clearError: true);

  static String _buildCommentary(
    String outcome,
    int runs,
    int extras,
    String batter,
    String bowler,
    String? dismissal, {
    bool wasFreeHit = false,
  }) {
    final freeHitTag = wasFreeHit ? ' [FREE HIT]' : '';
    switch (outcome) {
      case 'DOT':
        return '$bowler beats $batter — dot ball.$freeHitTag';
      case 'SINGLE':
        return '$batter picks up a single off $bowler.$freeHitTag';
      case 'DOUBLE':
        return '$batter drives for 2 runs!$freeHitTag';
      case 'TRIPLE':
        return '$batter and partner run 3!$freeHitTag';
      case 'FOUR':
        return 'FOUR! $batter pierces the gap!$freeHitTag';
      case 'SIX':
        return 'SIX! $batter launches it over the rope!$freeHitTag';
      case 'FIVE':
        return '$batter and partner complete 5 runs!$freeHitTag';
      case 'WIDE':
        return 'Wide! $bowler strays off target. +$extras extras.';
      case 'NO_BALL':
        final batRuns = runs > 0 ? ' $runs off the bat.' : '';
        return 'No Ball! $bowler oversteps.$batRuns FREE HIT next delivery!';
      case 'BYE':
        return 'Bye! $extras run${extras != 1 ? "s" : ""} — keeper can\'t stop it.';
      case 'LEG_BYE':
        return 'Leg bye! $extras run${extras != 1 ? "s" : ""} off the pad.';
      case 'WICKET':
        final how = _dismissalLabel(dismissal ?? '');
        return 'OUT! $batter is dismissed — $how.$freeHitTag';
      default:
        return '$outcome.$freeHitTag';
    }
  }

  static String _dismissalLabel(String type) {
    const map = {
      'BOWLED': 'Bowled',
      'CAUGHT': 'Caught',
      'CAUGHT_BEHIND': 'Caught Behind',
      'CAUGHT_AND_BOWLED': 'Caught and Bowled',
      'LBW': 'LBW',
      'RUN_OUT': 'Run Out',
      'STUMPED': 'Stumped',
      'HIT_WICKET': 'Hit Wicket',
      'OBSTRUCTING_FIELD': 'Obstructing Field',
      'RETIRED_HURT': 'Retired Hurt',
    };
    return map[type] ?? type;
  }

  void _logError(String op, Object e) {
    if (e is DioException) {
      print('[scoring] $op ✗ status=${e.response?.statusCode} url=${e.requestOptions.uri} body=${e.response?.data}');
    } else {
      print('[scoring] $op ✗ $e');
    }
  }

  String _msg(Object e) {
    if (e is DioException) {
      final d = e.response?.data;
      if (d is Map<String, dynamic>) {
        final nested = d['error'];
        if (nested is Map<String, dynamic> && nested['message'] is String) {
          return nested['message'] as String;
        }
        if (d['message'] is String) return d['message'] as String;
      }
      return e.message ?? 'Network error';
    }
    return e.toString();
  }
}

final hostScoringControllerProvider = StateNotifierProvider.autoDispose
    .family<HostScoringController, HostScoringState, String>(
  (ref, matchId) =>
      HostScoringController(ref.watch(hostScoringServiceProvider), matchId),
);
