import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../theme/host_colors.dart';
import '../controller/match_detail_controller.dart';
import '../domain/match_models.dart';

// ══════════════════════════════════════════════════════════════════════════════
// ENTRY POINT
// ══════════════════════════════════════════════════════════════════════════════

// ── Callbacks ────────────────────────────────────────────────────────────────

class MatchDetailCallbacks {
  const MatchDetailCallbacks({
    this.onScoreMatch,
    this.onNavigateToPlayer,
    this.onNavigateToTeam,
    this.onNavigateBack,
    this.onEditMatch,
  });

  final void Function(BuildContext ctx, String matchId)? onScoreMatch;
  final void Function(BuildContext ctx, String playerId)? onNavigateToPlayer;
  final void Function(BuildContext ctx, String teamId)? onNavigateToTeam;
  final void Function(BuildContext ctx)? onNavigateBack;

  /// Open the create-match form pre-populated for editing (e.g. to change overs).
  /// Only shown for SCHEDULED matches where canScore is true.
  final void Function(BuildContext ctx, String matchId, String teamAName, String teamBName)? onEditMatch;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class HostMatchDetailScreen extends ConsumerStatefulWidget {
  const HostMatchDetailScreen({
    super.key,
    required this.matchId,
    this.currentUserId,
    this.initialMatch,
    this.callbacks,
  });

  final String matchId;
  final String? currentUserId;
  final PlayerMatch? initialMatch;
  final MatchDetailCallbacks? callbacks;

  @override
  ConsumerState<HostMatchDetailScreen> createState() => _HostMatchDetailScreenState();
}

class _HostMatchDetailScreenState extends ConsumerState<HostMatchDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  StreamSubscription<String>? _overlayStreamSub;
  Timer? _fallbackRefreshTimer;
  bool _liveSyncEnabled = false;
  bool _overlayConnecting = false;
  bool _overlayReconnectScheduled = false;
  String? _lastOverlayPayload;
  DateTime? _lastOverlaySignalAt;
  DateTime? _lastLiveRefreshAt;
  bool _isInlineVideoVisible = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 7, vsync: this);
    // Kick off live-sync once data is available. Can't call ref here, so
    // defer to the first frame where the provider state is accessible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(matchDetailControllerProvider(widget.matchId));
      final fallback = widget.initialMatch != null
          ? _makeFallback(widget.initialMatch!)
          : null;
      _syncPolling((state.matchCenter ?? fallback)?.lifecycle);
    });
  }

  @override
  void dispose() {
    _stopLiveSync();
    _tabs.dispose();
    super.dispose();
  }

  void _syncPolling(MatchLifecycle? lifecycle) {
    final shouldEnableLiveSync = lifecycle == MatchLifecycle.live;
    if (shouldEnableLiveSync) {
      _liveSyncEnabled = true;
      _ensureLiveSync();
      return;
    }

    _liveSyncEnabled = false;
    _stopLiveSync();
  }

  void _ensureLiveSync() {
    _ensureFallbackRefresh();
    if (_overlayStreamSub != null || _overlayConnecting) {
      return;
    }

    _overlayConnecting = true;
    _overlayStreamSub = ref
        .read(matchDetailControllerProvider(widget.matchId).notifier)
        .watchLiveOverlay()
        .listen(
      (payload) {
        _overlayConnecting = false;
        _overlayReconnectScheduled = false;
        _lastOverlaySignalAt = DateTime.now();
        if (payload == _lastOverlayPayload) {
          return;
        }
        _lastOverlayPayload = payload;
        // Only refresh the lightweight score provider — not the full page.
        if (mounted) {
          ref.invalidate(matchLiveScoreProvider(widget.matchId));
        }
      },
      onError: (_, __) {
        _overlayConnecting = false;
        _scheduleLiveSyncReconnect();
      },
      onDone: () {
        _overlayConnecting = false;
        _scheduleLiveSyncReconnect();
      },
    );
  }

  void _ensureFallbackRefresh() {
    if (_fallbackRefreshTimer != null) {
      return;
    }

    _fallbackRefreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!_liveSyncEnabled || !mounted) {
        return;
      }

      // SSE stream is connected and alive — trust it to push updates.
      // Only poll when the stream itself is gone or truly stale (>15 s).
      final streamConnected =
          _overlayStreamSub != null && !_overlayConnecting;
      final lastSignalAt = _lastOverlaySignalAt;
      final signalAge = lastSignalAt == null
          ? null
          : DateTime.now().difference(lastSignalAt);
      final streamIsStale =
          !streamConnected || (signalAge != null && signalAge > const Duration(seconds: 15));

      if (streamIsStale) {
        if (mounted) ref.invalidate(matchLiveScoreProvider(widget.matchId));
        if (_overlayStreamSub == null && !_overlayConnecting) {
          _ensureLiveSync();
        }
      }
    });
  }

  void _scheduleLiveSyncReconnect() {
    _overlayStreamSub?.cancel();
    _overlayStreamSub = null;

    if (!_liveSyncEnabled || !mounted || _overlayReconnectScheduled) {
      return;
    }

    _overlayReconnectScheduled = true;
    Future<void>.delayed(const Duration(seconds: 1), () {
      _overlayReconnectScheduled = false;
      if (!_liveSyncEnabled || !mounted) {
        return;
      }
      _ensureLiveSync();
    });
  }

  void _refreshLiveProviders({bool force = false}) {
    if (!mounted) {
      return;
    }

    final now = DateTime.now();
    if (!force &&
        _lastLiveRefreshAt != null &&
        now.difference(_lastLiveRefreshAt!) <
            const Duration(milliseconds: 800)) {
      return;
    }

    _lastLiveRefreshAt = now;
    // refresh() updates state on the EXISTING controller without dispose +
    // recreate, so we get one rebuild (data) instead of two (loading → data).
    ref
        .read(matchDetailControllerProvider(widget.matchId).notifier)
        .refresh();
  }

  void _stopLiveSync() {
    _overlayStreamSub?.cancel();
    _overlayStreamSub = null;
    _fallbackRefreshTimer?.cancel();
    _fallbackRefreshTimer = null;
    _overlayConnecting = false;
    _overlayReconnectScheduled = false;
    _lastOverlayPayload = null;
    _lastOverlaySignalAt = null;
    _lastLiveRefreshAt = null;
  }

  @override
  Widget build(BuildContext context) {
    final fallback = widget.initialMatch == null
        ? null
        : _makeFallback(widget.initialMatch!);

    // React to lifecycle changes outside of build (listener fires after build).
    ref.listen<MatchDetailState>(
      matchDetailControllerProvider(widget.matchId),
      (_, next) {
        final fb = widget.initialMatch != null
            ? _makeFallback(widget.initialMatch!)
            : null;
        _syncPolling((next.matchCenter ?? fb)?.lifecycle);
      },
    );

    final ctrl = ref.watch(matchDetailControllerProvider(widget.matchId));
    final center = ctrl.matchCenter ?? fallback;
    final isLoading = ctrl.isLoading;

    // Loading state (no fallback yet)
    if (center == null) {
      return Scaffold(
        backgroundColor: context.bg,
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorBody(context),
      );
    }

    final centerRole = center.myRole;
    final centerCanScore = centerRole == 'owner' ||
        centerRole == 'manager' ||
        centerRole == 'scorer' ||
        centerRole == 'captain-A' ||
        centerRole == 'captain-B';
    final canScore =
        widget.initialMatch?.canScoreNow() == true || centerCanScore;
    final isLiveOrUpcoming = center.lifecycle == MatchLifecycle.live ||
        center.lifecycle == MatchLifecycle.upcoming;
    assert(() {
      debugPrint(
        '[MatchDetail] id=${widget.matchId} lifecycle=${center.lifecycle.name} '
        'initRole=${widget.initialMatch?.myRole} '
        'centerRole=$centerRole '
        'showResume=${canScore && isLiveOrUpcoming}',
      );
      return true;
    }());


    return Scaffold(
      backgroundColor: context.bg,
      body: Column(
        children: [
          // ── Fixed hero header ──────────────────────────────────────
          _HeroHeader(
            center: center,
            isInlineVideoVisible: _isInlineVideoVisible,
            onBack: widget.callbacks?.onNavigateBack != null
                ? () => widget.callbacks!.onNavigateBack!(context)
                : null,
            onWatchTap: () {
              if (_has(center.youtubeUrl)) {
                setState(() => _isInlineVideoVisible = true);
                return;
              }
              _handleWatchTap(context, center);
            },
            onCloseInlineVideo: () {
              setState(() => _isInlineVideoVisible = false);
            },
          ),

          // ── Fixed tab bar ──────────────────────────────────────────
          _MatchTabBar(controller: _tabs),

          // ── Scrollable tab content ─────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _OverviewTab(
                    matchId: widget.matchId,
                    center: center,
                    fallback: widget.initialMatch,
                    isLoading: isLoading),
                _ScorecardTab(center: center),
                _Playing11Tab(center: center),
                _AnalysisTab(center: center, matchId: widget.matchId),
                _MvpTab(center: center),
                _CommentaryTab(matchId: widget.matchId, center: center),
                _InfoTab(center: center),
              ],
            ),
          ),

          // ── Resume Scoring bar (only for player-created live matches) ──
          if (canScore && isLiveOrUpcoming)
            _ResumeScoringBar(
              matchId: widget.matchId,
              isLive: center.lifecycle == MatchLifecycle.live,
              teamAName: center.teamAName,
              teamBName: center.teamBName,
              callbacks: widget.callbacks,
            ),
        ],
      ),
    );
  }

  Widget _errorBody(BuildContext context) => Center(
        child: Text(
          'Match details unavailable.',
          style: TextStyle(color: context.fgSub, fontSize: 15),
        ),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// RESUME SCORING BAR
// ══════════════════════════════════════════════════════════════════════════════

class _ResumeScoringBar extends StatelessWidget {
  const _ResumeScoringBar({
    required this.matchId,
    required this.isLive,
    required this.teamAName,
    required this.teamBName,
    this.callbacks,
  });
  final String matchId;
  final bool isLive;
  final String teamAName;
  final String teamBName;
  final MatchDetailCallbacks? callbacks;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final screenWidth = MediaQuery.of(context).size.width;
    final canEdit = !isLive && callbacks?.onEditMatch != null;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth ? constraints.maxWidth : screenWidth;
        return Container(
          width: width,
          padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottom),
          decoration: BoxDecoration(
            color: context.surf,
            border: Border(top: BorderSide(color: context.stroke)),
          ),
          child: Row(
            children: [
              if (canEdit) ...[
                IntrinsicWidth(
                  child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        callbacks!.onEditMatch!(context, matchId, teamAName, teamBName),
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Edit',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.fgSub,
                      side: BorderSide(color: context.stroke),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (callbacks?.onScoreMatch != null) {
                        callbacks!.onScoreMatch!(context, matchId);
                      }
                    },
                    icon: const Icon(Icons.sports_cricket_rounded, size: 18),
                    label: Text(
                      isLive ? 'Resume Scoring' : 'Start Scoring',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.accent,
                      foregroundColor: context.fg,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HERO HEADER
// ══════════════════════════════════════════════════════════════════════════════

class _HeroHeader extends ConsumerWidget {
  const _HeroHeader({
    required this.center,
    required this.isInlineVideoVisible,
    required this.onWatchTap,
    required this.onCloseInlineVideo,
    this.onBack,
  });
  final MatchCenter center;
  final bool isInlineVideoVisible;
  final VoidCallback onWatchTap;
  final VoidCallback onCloseInlineVideo;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLive = center.lifecycle == MatchLifecycle.live;
    final colA = _teamColor(context, center.teamAName);
    final colB = _teamColor(context, center.teamBName);
    final hasYoutube = _has(center.youtubeUrl);

    // For live matches, watch the lightweight score provider so only this
    // widget rebuilds on each ball — not the entire match detail page.
    final liveScore = isLive
        ? ref.watch(matchLiveScoreProvider(center.id))
        : null;
    final effectiveTeamAScore =
        liveScore?.valueOrNull?.teamAScore ?? center.teamAScore;
    final effectiveTeamBScore =
        liveScore?.valueOrNull?.teamBScore ?? center.teamBScore;
    final live = liveScore?.valueOrNull?.liveState ?? center.liveState;
    final effectiveInnings =
        liveScore?.valueOrNull?.innings ?? center.innings;

    // Batting-first team always on left
    final firstBattingTeam = effectiveInnings
        .where((i) => !i.isSuperOver)
        .firstOrNull
        ?.battingTeamName;
    final leftIsA =
        firstBattingTeam == null || firstBattingTeam == center.teamAName;
    final leftName = leftIsA ? center.teamAName : center.teamBName;
    final rightName = leftIsA ? center.teamBName : center.teamAName;
    final leftShort = leftIsA ? center.teamAShortName : center.teamBShortName;
    final rightShort = leftIsA ? center.teamBShortName : center.teamAShortName;
    final leftLogo = leftIsA ? center.teamALogoUrl : center.teamBLogoUrl;
    final rightLogo = leftIsA ? center.teamBLogoUrl : center.teamALogoUrl;
    final leftColor = leftIsA ? colA : colB;
    final rightColor = leftIsA ? colB : colA;
    final leftScore = leftIsA ? effectiveTeamAScore : effectiveTeamBScore;
    final rightScore = leftIsA ? effectiveTeamBScore : effectiveTeamAScore;
    final showInlinePlayer = isInlineVideoVisible && hasYoutube;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.bg,
            context.bg,
            context.bg,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── App bar ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: context.fg.withValues(alpha: 0.6)),
                    onPressed: onBack ??
                        () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                  ),
                  Expanded(
                    child: Text(
                      center.competitionLabel ?? 'Match',
                      style: TextStyle(
                          color: context.fg.withValues(alpha: 0.54),
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Watch / Scoreboard button
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: context.danger.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color:
                              context.danger.withValues(alpha: 0.28)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap:
                            showInlinePlayer ? onCloseInlineVideo : onWatchTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                showInlinePlayer
                                    ? Icons.scoreboard_rounded
                                    : Icons.live_tv_rounded,
                                size: 15,
                                color: context.danger,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                showInlinePlayer ? 'Scoreboard' : 'Watch',
                                style: TextStyle(
                                    color: context.danger,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            if (showInlinePlayer) ...[
              _InlineYoutubePlayer(
                youtubeUrl: center.youtubeUrl!,
              ),
              const SizedBox(height: 14),
            ],

            // ── Status pills (LIVE, format, venue, match type) ─────
            if (!showInlinePlayer) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (isLive) const _LivePill() else _StatusPill(center),
                      if (_has(center.formatLabel)) ...[
                        const SizedBox(width: 6),
                        _GlassPill(center.formatLabel!),
                      ],
                      if (_has(center.venueLabel)) ...[
                        const SizedBox(width: 6),
                        _GlassIconPill(Icons.location_on_rounded,
                            _truncate(center.venueLabel!, 18)),
                      ],
                      if (_has(center.matchType)) ...[
                        const SizedBox(width: 6),
                        _GlassPill(center.matchType!),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Teams row ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left team (batting first)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TeamCrest(
                            name: leftName,
                            shortName: leftShort,
                            logoUrl: leftLogo,
                            color: leftColor,
                            size: 56,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            leftShort ?? leftName,
                            style: TextStyle(
                                color: context.fg,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            leftScore.isEmpty ? 'Yet to bat' : leftScore,
                            style: TextStyle(
                              color: leftScore.isEmpty
                                  ? context.fg.withValues(alpha: 0.3)
                                  : context.fg,
                              fontSize: leftScore.isEmpty ? 13 : 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // VS + toss chip
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 14, left: 8, right: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'vs',
                            style: TextStyle(
                                color: context.fg.withValues(alpha: 0.20),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1),
                          ),
                          if (_has(center.tossSummary)) ...[
                            const SizedBox(height: 8),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 88),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: context.fg.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color:
                                        context.fg.withValues(alpha: 0.10)),
                              ),
                              child: Text(
                                center.tossSummary!,
                                style: TextStyle(
                                    color: context.fg.withValues(alpha: 0.54),
                                    fontSize: 9,
                                    height: 1.4,
                                    fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Right team (batting second)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: _TeamCrest(
                              name: rightName,
                              shortName: rightShort,
                              logoUrl: rightLogo,
                              color: rightColor,
                              size: 56,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            rightShort ?? rightName,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: context.fg,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rightScore.isEmpty ? 'Yet to bat' : rightScore,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: rightScore.isEmpty
                                  ? context.fg.withValues(alpha: 0.3)
                                  : context.fg,
                              fontSize: rightScore.isEmpty ? 13 : 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Over balls row + CRR inline ────────────────────────
              if (isLive &&
                  live != null &&
                  live.currentOverBalls.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Over ${live.currentOverNumber}',
                        style: TextStyle(
                            color: context.fgSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: live.currentOverBalls
                                .map((b) => Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: _BallDot(label: b),
                                    ))
                                .toList(growable: false),
                          ),
                        ),
                      ),
                      if (_has(live.currentRunRate))
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _RateChip('CRR', live.currentRunRate!),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],

              // ── Target / Need / RRR chips ──────────────────────────
              if (isLive &&
                  live != null &&
                  (live.target != null ||
                      live.toWin != null ||
                      _has(live.requiredRunRate))) ...[
                Builder(builder: (ctx) {
                  final chips = <Widget>[];
                  if (live.target != null) {
                    chips.add(
                        _RateChip('Target', '${live.target}', highlight: true));
                  }
                  if (live.toWin != null && live.ballsRemaining != null) {
                    final ovs = live.ballsRemaining! ~/ 6;
                    final bls = live.ballsRemaining! % 6;
                    chips.add(_RateChip('Need',
                        '${live.toWin} off ${ovs > 0 ? '$ovs.$bls ov' : '${bls}b'}'));
                  }
                  if (_has(live.requiredRunRate)) {
                    chips.add(_RateChip('RRR', live.requiredRunRate!));
                  }
                  if (chips.isEmpty) return const SizedBox.shrink();
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: chips
                          .map((c) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: c))
                          .toList(),
                    ),
                  );
                }),
                const SizedBox(height: 6),
              ],
            ],

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

void _handleWatchTap(BuildContext context, MatchCenter center) {
  if (center.overlayLoaded) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This match is not live.')),
    );
  }
}

class _InlineYoutubePlayer extends StatefulWidget {
  const _InlineYoutubePlayer({
    required this.youtubeUrl,
  });

  final String youtubeUrl;

  @override
  State<_InlineYoutubePlayer> createState() => _InlineYoutubePlayerState();
}

class _InlineYoutubePlayerState extends State<_InlineYoutubePlayer> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(context.bg)
      ..setUserAgent(_mobileYoutubeUserAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            _trimYoutubeChrome();
          },
        ),
      )
      ..loadRequest(Uri.parse(_youtubeWatchUrl(widget.youtubeUrl)));
  }

  Future<void> _trimYoutubeChrome() async {
    try {
      await _controller.runJavaScript(_youtubeWatchCleanupScript);
    } catch (_) {
      // Ignore cleanup failures; the video page can still render.
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 8.6,
      child: ColoredBox(
        color: context.bg,
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}

// ── Team crest ────────────────────────────────────────────────────────────────

class _TeamCrest extends StatelessWidget {
  const _TeamCrest({
    required this.name,
    required this.color,
    required this.size,
    this.shortName,
    this.logoUrl,
  });
  final String name;
  final String? shortName;
  final String? logoUrl;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final abbr = shortName?.isNotEmpty == true
        ? shortName!.substring(0, shortName!.length.clamp(0, 4)).toUpperCase()
        : _teamAbbr(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          colors: [
            color.withValues(alpha: 0.35),
            color.withValues(alpha: 0.08),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.55), width: 2),
      ),
      child: ClipOval(
        child: logoUrl != null && logoUrl!.isNotEmpty
            ? Image.network(
                logoUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : _Abbr(abbr: abbr, color: color, size: size),
                errorBuilder: (_, __, ___) =>
                    _Abbr(abbr: abbr, color: color, size: size),
              )
            : _Abbr(abbr: abbr, color: color, size: size),
      ),
    );
  }
}

class _Abbr extends StatelessWidget {
  const _Abbr({required this.abbr, required this.color, required this.size});
  final String abbr;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          abbr,
          style: TextStyle(
            color: color,
            fontSize: abbr.length > 2 ? size * 0.25 : size * 0.33,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      );
}

// ── Pills ─────────────────────────────────────────────────────────────────────

class _LivePill extends StatefulWidget {
  const _LivePill();

  @override
  State<_LivePill> createState() => _LivePillState();
}

class _LivePillState extends State<_LivePill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _fade = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: context.danger.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: context.danger.withValues(alpha: 0.30), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(color: context.danger),
            SizedBox(width: 5),
            Text('LIVE',
                style: TextStyle(
                    color: context.danger,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0)),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.center);
  final MatchCenter center;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (center.lifecycle) {
      MatchLifecycle.upcoming => ('Upcoming', context.warn),
      MatchLifecycle.past => ('Completed', context.fgSub),
      MatchLifecycle.live => ('Live', context.danger),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.fg.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: context.fg.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label,
            style: TextStyle(
                color: context.fg.withValues(alpha: 0.54),
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      );
}

class _GlassIconPill extends StatelessWidget {
  const _GlassIconPill(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: context.fg.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: context.fgSub),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: context.fg.withValues(alpha: 0.54),
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _BallDot extends StatelessWidget {
  const _BallDot({required this.label});
  final String label;

  static Color _bg(BuildContext context, String l) => switch (l) {
        'W' => context.danger,
        '4' => context.success,
        '6' => context.sky,
        'WD' || 'NB' => context.warn,
        _ => context.fg.withValues(alpha: 0.12),
      };

  static Color _fg(BuildContext context, String l) => switch (l) {
        'WD' || 'NB' => context.bg,
        _ => context.fg,
      };

  @override
  Widget build(BuildContext context) => Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(color: _bg(context, label), shape: BoxShape.circle),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: _fg(context, label),
              fontSize: label.length > 1 ? 8 : 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
}

class _RateChip extends StatelessWidget {
  const _RateChip(this.label, this.value, {this.highlight = false});
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: highlight
              ? context.fg.withValues(alpha: 0.12)
              : context.fg.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(999),
          border: highlight
              ? Border.all(color: context.fg.withValues(alpha: 0.18))
              : null,
        ),
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: '$label  ',
                style: TextStyle(
                    color: context.fgSub,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4)),
            TextSpan(
                text: value,
                style: TextStyle(
                    color: highlight ? context.fg : context.fg.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2)),
          ]),
        ),
      );
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB BAR
// ══════════════════════════════════════════════════════════════════════════════

class _MatchTabBar extends StatelessWidget {
  const _MatchTabBar({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.bg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            controller: controller,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            indicatorColor: context.accent,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: context.accent,
            unselectedLabelColor: context.fgSub,
            labelStyle: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: -0.1),
            unselectedLabelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Scorecard'),
              Tab(text: 'Playing XI'),
              Tab(text: 'Analysis'),
              Tab(text: 'MVP'),
              Tab(text: 'Commentary'),
              Tab(text: 'Info'),
            ],
          ),
          Divider(height: 1, color: context.stroke),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// OVERVIEW TAB
// ══════════════════════════════════════════════════════════════════════════════

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({
    required this.matchId,
    required this.center,
    required this.fallback,
    required this.isLoading,
  });
  final String matchId;
  final MatchCenter center;
  final PlayerMatch? fallback;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLive = center.lifecycle == MatchLifecycle.live;
    final isPast = center.lifecycle == MatchLifecycle.past;
    final live = center.liveState;
    final topBatter = _topBatterOf(center.innings);
    final topBowler = _topBowlerOf(center.innings);
    final mvp = center.competitive?.mvp;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        // Loading bar
        if (isLoading) ...[
          LinearProgressIndicator(
            minHeight: 2,
            color: context.accent,
            backgroundColor: context.panel,
          ),
          const SizedBox(height: 12),
        ],

        // ── Score summary (completed) ─────────────────────────────
        if (isPast) ...[
          _ScoreSummaryCard(center: center, fallback: fallback),
          const SizedBox(height: 12),
        ],

        // ── Live batting ──────────────────────────────────────────
        if (isLive &&
            live != null &&
            (live.striker != null || live.nonStriker != null)) ...[
          _LiveBattingTableCard(liveState: live),
          const SizedBox(height: 12),
        ],

        // ── Live bowling ──────────────────────────────────────────
        if (isLive && live != null) ...[
          _LiveInningsBowlingCard(center: center),
          const SizedBox(height: 12),
        ],

        // ── Key performances (completed only) ─────────────────────
        if (isPast && (topBatter != null || topBowler != null)) ...[
          _KeyPerformancesCard(topBatter: topBatter, topBowler: topBowler),
          const SizedBox(height: 12),
        ],

        // ── Player of the Match ───────────────────────────────────
        if (isPast && mvp != null) ...[
          _MvpCard(entry: mvp),
          const SizedBox(height: 12),
        ],

        // ── Your performance ──────────────────────────────────────
        if (_hasImpact(fallback)) ...[
          _YourPerformanceCard(match: fallback!),
          const SizedBox(height: 12),
        ],

        // ── Match details ─────────────────────────────────────────
        if (_has(center.competitionLabel) ||
            _has(center.formatLabel) ||
            _has(center.venueLabel) ||
            _has(center.tossSummary)) ...[
          const SizedBox(height: 12),
          _MatchDetailsCard(center: center),
        ],
      ],
    );
  }
}

// ── Live batting card ─────────────────────────────────────────────────────────

class _LiveBattingTableCard extends StatelessWidget {
  const _LiveBattingTableCard({required this.liveState});
  final MatchLiveState liveState;

  @override
  Widget build(BuildContext context) {
    final batters = [
      if (liveState.striker != null) liveState.striker!,
      if (liveState.nonStriker != null) liveState.nonStriker!,
    ];
    return _SectionCard(
      title: 'At the Crease',
      icon: Icons.sports_cricket_rounded,
      child: Container(
        decoration: BoxDecoration(
          color: context.panel,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.stroke.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 7),
              child: Row(children: [
                _Ch('BATTER', flex: 5),
                _Ch('R', flex: 2),
                _Ch('B', flex: 2),
                _Ch('4s', flex: 2),
                _Ch('6s', flex: 2),
                _Ch('SR', flex: 3),
              ]),
            ),
            Divider(color: context.stroke.withValues(alpha: 0.5), height: 1),
            ...batters.asMap().entries.map((e) {
              final b = e.value;
              final isLast = e.key == batters.length - 1;
              return Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Row(children: [
                    Expanded(
                      flex: 5,
                      child: Row(children: [
                        Flexible(
                          child: Text(
                            b.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: context.fg),
                          ),
                        ),
                        if (b.isStriker) ...[
                          const SizedBox(width: 4),
                          _Dot(color: context.success),
                        ],
                      ]),
                    ),
                    _dataCell('${b.runs}', context,
                        bold: true, color: context.accent, flex: 2),
                    _dataCell('${b.balls}', context, flex: 2),
                    _dataCell('${b.fours}', context, flex: 2),
                    _dataCell('${b.sixes}', context, flex: 2),
                    _dataCell(b.strikeRate, context, flex: 3),
                  ]),
                ),
                if (!isLast)
                  Divider(
                      color: context.stroke.withValues(alpha: 0.5), height: 1),
              ]);
            }),
          ],
        ),
      ),
    );
  }
}

// ── Live bowling card (shows all bowlers in active innings) ──────────────────

class _LiveInningsBowlingCard extends StatelessWidget {
  const _LiveInningsBowlingCard({required this.center});
  final MatchCenter center;

  @override
  Widget build(BuildContext context) {
    final innings = center.innings.firstWhere(
      (i) => !i.isCompleted,
      orElse: () => center.innings.isNotEmpty
          ? center.innings.last
          : const MatchInnings(
              title: '',
              score: '',
              battingTeamName: '',
              batting: [],
              bowling: []),
    );

    final bowlers = innings.bowling;
    if (bowlers.isEmpty) return const SizedBox.shrink();

    final currentBowlerName = center.liveState?.currentBowler?.name;

    return _SectionCard(
      title: 'Bowling',
      icon: Icons.offline_bolt_rounded,
      child: Container(
        decoration: BoxDecoration(
          color: context.panel,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.stroke.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 7),
              child: Row(children: [
                _Ch('BOWLER', flex: 5),
                _Ch('O', flex: 2),
                _Ch('R', flex: 2),
                _Ch('W', flex: 2),
                _Ch('ECO', flex: 3),
              ]),
            ),
            Divider(color: context.stroke.withValues(alpha: 0.5), height: 1),
            ...bowlers.asMap().entries.map((e) {
              final b = e.value;
              final isCurrent = b.name == currentBowlerName;
              final isLast = e.key == bowlers.length - 1;

              return Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Row(children: [
                    Expanded(
                      flex: 5,
                      child: Row(children: [
                        Flexible(
                          child: Text(
                            b.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: isCurrent
                                      ? FontWeight.w900
                                      : FontWeight.w700,
                                  color:
                                      isCurrent ? context.accent : context.fg,
                                ),
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(width: 6),
                          _Dot(color: context.success),
                        ],
                      ]),
                    ),
                    _dataCell(b.overs, context,
                        bold: isCurrent,
                        color: isCurrent ? context.fg : null,
                        flex: 2),
                    _dataCell('${b.runs}', context,
                        bold: isCurrent,
                        color: isCurrent ? context.fg : null,
                        flex: 2),
                    _dataCell('${b.wickets}', context,
                        bold: b.wickets > 0 || isCurrent,
                        color: b.wickets > 0 ? context.accent : null,
                        flex: 2),
                    _dataCell(b.economy, context,
                        bold: isCurrent,
                        color: isCurrent ? context.fg : null,
                        flex: 3),
                  ]),
                ),
                if (!isLast)
                  Divider(
                      color: context.stroke.withValues(alpha: 0.5), height: 1),
              ]);
            }),
          ],
        ),
      ),
    );
  }
}

// ── Shared cards/chips ────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard(
      {required this.title, required this.icon, required this.child});
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.stroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: context.fgSub),
                const SizedBox(width: 7),
                Text(title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800, letterSpacing: 0.1)),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );
}

// ── Score summary card (completed matches) ────────────────────────────────────

class _ScoreSummaryCard extends StatelessWidget {
  const _ScoreSummaryCard({required this.center, required this.fallback});
  final MatchCenter center;
  final PlayerMatch? fallback;

  @override
  Widget build(BuildContext context) {
    final firstBatting = center.innings
        .where((i) => !i.isSuperOver)
        .firstOrNull
        ?.battingTeamName;
    final leftIsA = firstBatting == null || firstBatting == center.teamAName;
    final leftName = leftIsA ? center.teamAName : center.teamBName;
    final rightName = leftIsA ? center.teamBName : center.teamAName;
    final leftScore = leftIsA ? center.teamAScore : center.teamBScore;
    final rightScore = leftIsA ? center.teamBScore : center.teamAScore;
    final leftColor = _teamColor(context, leftName);
    final rightColor = _teamColor(context, rightName);
    final winner = center.winnerTeamName;
    final resultLine = center.resultSummary ?? fallback?.scoreSummary ?? '';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Teams row
          Row(
            children: [
              // Left team
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (winner == leftName)
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Icon(Icons.emoji_events_rounded,
                                size: 14, color: context.gold),
                          ),
                        Expanded(
                          child: Text(
                            leftName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: leftColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      leftScore,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ],
                ),
              ),
              // VS divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'vs',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Right team
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            rightName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: rightColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (winner == rightName)
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Icon(Icons.emoji_events_rounded,
                                size: 14, color: context.gold),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rightScore,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_has(resultLine)) ...[
            const SizedBox(height: 12),
            Divider(color: context.stroke, height: 1),
            const SizedBox(height: 10),
            Text(
              resultLine,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Key performances card ─────────────────────────────────────────────────────

class _KeyPerformancesCard extends StatelessWidget {
  const _KeyPerformancesCard(
      {required this.topBatter, required this.topBowler});
  final ({String name, int runs, int balls})? topBatter;
  final ({String name, int wickets, int runs, String overs})? topBowler;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Key Performances',
      icon: Icons.star_rounded,
      child: Row(
        children: [
          if (topBatter != null)
            Expanded(
              child: _PerfTile(
                label: 'Top Bat',
                name: topBatter!.name,
                stat: '${topBatter!.runs} runs',
                detail: '${topBatter!.balls}b',
                color: context.sky,
                icon: Icons.sports_cricket_rounded,
              ),
            ),
          if (topBatter != null && topBowler != null) const SizedBox(width: 10),
          if (topBowler != null)
            Expanded(
              child: _PerfTile(
                label: 'Top Bowl',
                name: topBowler!.name,
                stat: '${topBowler!.wickets}/${topBowler!.runs}',
                detail: '${topBowler!.overs} ov',
                color: context.accent,
                icon: Icons.sports_baseball_rounded,
              ),
            ),
        ],
      ),
    );
  }
}

class _PerfTile extends StatelessWidget {
  const _PerfTile({
    required this.label,
    required this.name,
    required this.stat,
    required this.detail,
    required this.color,
    required this.icon,
  });
  final String label;
  final String name;
  final String stat;
  final String detail;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 5),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.fg,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                stat,
                style: TextStyle(
                  color: context.fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                detail,
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── MVP card ──────────────────────────────────────────────────────────────────

class _MvpCard extends StatelessWidget {
  const _MvpCard({required this.entry});
  final MatchCompetitiveEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.gold.withValues(alpha: 0.14),
            context.gold.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.gold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.military_tech_rounded,
                size: 22, color: context.gold),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Player of the Match',
                  style: TextStyle(
                    color: context.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  entry.playerName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                ),
                if (_has(entry.teamName))
                  Text(
                    entry.teamName,
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 11,
                    ),
                  ),
                if (_has(entry.summary)) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.summary,
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: context.gold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${entry.impactPoints.toStringAsFixed(0)} IP',
              style: TextStyle(
                color: context.gold,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Your performance card ─────────────────────────────────────────────────────

class _YourPerformanceCard extends StatelessWidget {
  const _YourPerformanceCard({required this.match});
  final PlayerMatch match;

  @override
  Widget build(BuildContext context) {
    final metrics = <({String label, String value, Color color})>[
      if (match.playerRuns != null)
        (
          label: 'Runs',
          value: match.playerBalls != null
              ? '${match.playerRuns} (${match.playerBalls}b)'
              : '${match.playerRuns}',
          color: context.sky,
        ),
      if (match.playerWickets != null && match.playerWickets! > 0)
        (
          label: 'Wickets',
          value: '${match.playerWickets}',
          color: context.accent,
        ),
      if (match.playerCatches != null && match.playerCatches! > 0)
        (
          label: 'Catches',
          value: '${match.playerCatches}',
          color: context.success,
        ),
    ];

    return _SectionCard(
      title: 'Your Performance',
      icon: Icons.person_rounded,
      child: Row(
        children: [
          for (int i = 0; i < metrics.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: metrics[i].color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: metrics[i].color.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metrics[i].label.toUpperCase(),
                      style: TextStyle(
                        color: metrics[i].color,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      metrics[i].value,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Match details card ────────────────────────────────────────────────────────

class _MatchDetailsCard extends StatelessWidget {
  const _MatchDetailsCard({required this.center});
  final MatchCenter center;

  @override
  Widget build(BuildContext context) {
    final rows = <({IconData icon, String label, String value})>[
      if (_has(center.competitionLabel))
        (
          icon: Icons.emoji_events_outlined,
          label: 'Competition',
          value: center.competitionLabel!,
        ),
      if (_has(center.formatLabel))
        (
          icon: Icons.format_list_bulleted_rounded,
          label: 'Format',
          value: center.formatLabel!,
        ),
      if (_has(center.venueLabel))
        (
          icon: Icons.location_on_outlined,
          label: 'Venue',
          value: center.venueLabel!,
        ),
      if (_has(center.tossSummary))
        (
          icon: Icons.swap_horiz_rounded,
          label: 'Toss',
          value: center.tossSummary!,
        ),
    ];

    return _SectionCard(
      title: 'Match Details',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 18, color: context.stroke),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(rows[i].icon, size: 14, color: context.fgSub),
                const SizedBox(width: 10),
                SizedBox(
                  width: 80,
                  child: Text(
                    rows[i].label,
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    rows[i].value,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Top performer helpers ─────────────────────────────────────────────────────

({String name, int runs, int balls})? _topBatterOf(List<MatchInnings> innings) {
  final batMap = <String, ({int runs, int balls})>{};
  for (final inn in innings) {
    if (inn.isSuperOver) continue;
    for (final b in inn.batting) {
      batMap[b.name] = (
        runs: (batMap[b.name]?.runs ?? 0) + b.runs,
        balls: (batMap[b.name]?.balls ?? 0) + b.balls,
      );
    }
  }
  if (batMap.isEmpty) return null;
  final top =
      batMap.entries.reduce((a, b) => a.value.runs >= b.value.runs ? a : b);
  if (top.value.runs == 0) return null;
  return (name: top.key, runs: top.value.runs, balls: top.value.balls);
}

({String name, int wickets, int runs, String overs})? _topBowlerOf(
    List<MatchInnings> innings) {
  final bowlMap = <String, ({int wickets, int runs, String overs})>{};
  for (final inn in innings) {
    if (inn.isSuperOver) continue;
    for (final b in inn.bowling) {
      bowlMap[b.name] = (
        wickets: (bowlMap[b.name]?.wickets ?? 0) + b.wickets,
        runs: (bowlMap[b.name]?.runs ?? 0) + b.runs,
        overs: b.overs,
      );
    }
  }
  if (bowlMap.isEmpty) return null;
  final top = bowlMap.entries.reduce((a, b) => a.value.wickets >
              b.value.wickets ||
          (a.value.wickets == b.value.wickets && a.value.runs <= b.value.runs)
      ? a
      : b);
  if (top.value.wickets == 0) return null;
  return (
    name: top.key,
    wickets: top.value.wickets,
    runs: top.value.runs,
    overs: top.value.overs,
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _CompletedOverviewCard extends StatelessWidget {
  const _CompletedOverviewCard({
    required this.center,
    required this.fallback,
  });

  final MatchCenter center;
  final PlayerMatch? fallback;

  @override
  Widget build(BuildContext context) {
    final summary = _buildCompletedOverview(center, fallback);
    final winnerColor = summary.winnerTeam == center.teamAName
        ? _teamColor(context, center.teamAName)
        : summary.winnerTeam == center.teamBName
            ? _teamColor(context, center.teamBName)
            : context.gold;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.gold.withValues(alpha: 0.16),
            context.accent.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.gold.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, size: 18, color: context.gold),
              const SizedBox(width: 8),
              Text(
                'Match Overview',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            summary.headline,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
          ),
          if (_has(summary.resultLine)) ...[
            const SizedBox(height: 6),
            Text(
              summary.resultLine!,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _CompletedStatTile(
                  label: 'Winner',
                  value: summary.winnerLabel,
                  subtitle: summary.winnerDetail,
                  color: winnerColor,
                  icon: Icons.workspace_premium_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CompletedStatTile(
                  label: 'MVP',
                  value: summary.mvp?.name ?? 'TBD',
                  subtitle: summary.mvp?.detail ?? 'Awaiting score impact',
                  color: context.accent,
                  icon: Icons.military_tech_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletedStatTile extends StatelessWidget {
  const _CompletedStatTile({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.bg.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.stroke.withValues(alpha: 0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: context.fgSub,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: context.stroke),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: context.fgSub),
            const SizedBox(width: 6),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// SCORECARD TAB
// ══════════════════════════════════════════════════════════════════════════════

class _ScorecardTab extends StatefulWidget {
  const _ScorecardTab({required this.center});
  final MatchCenter center;

  @override
  State<_ScorecardTab> createState() => _ScorecardTabState();
}

class _ScorecardTabState extends State<_ScorecardTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<MatchInnings> _inningsFor(String teamName) => widget.center.innings
      .where((i) => !i.isSuperOver && i.battingTeamName == teamName)
      .toList();

  String _scoreFor(String teamName) {
    final inns = _inningsFor(teamName);
    if (inns.isEmpty) return '';
    return inns.map((i) => i.score).join(' & ');
  }

  @override
  Widget build(BuildContext context) {
    final teamA = widget.center.teamAName;
    final teamB = widget.center.teamBName;

    // Always show the batting-first team on the left tab
    final firstBattingTeam = widget.center.innings
        .where((i) => !i.isSuperOver)
        .firstOrNull
        ?.battingTeamName;
    final leftIsA = firstBattingTeam == null || firstBattingTeam == teamA;
    final leftTeam = leftIsA ? teamA : teamB;
    final rightTeam = leftIsA ? teamB : teamA;
    final abbrLeft = leftIsA
        ? (widget.center.teamAShortName ?? _teamAbbr(teamA))
        : (widget.center.teamBShortName ?? _teamAbbr(teamB));
    final abbrRight = leftIsA
        ? (widget.center.teamBShortName ?? _teamAbbr(teamB))
        : (widget.center.teamAShortName ?? _teamAbbr(teamA));

    if (widget.center.innings.where((i) => !i.isSuperOver).isEmpty) {
      return const _EmptyState('Scorecard will appear once innings begin.',
          Icons.sports_cricket_rounded);
    }

    return Column(
      children: [
        // ── Team tabs ───────────────────────────────────────────────
        Container(
          color: context.cardBg,
          child: TabBar(
            controller: _tabCtrl,
            dividerColor: context.stroke,
            indicatorColor: context.accent,
            indicatorWeight: 3,
            labelColor: context.accent,
            unselectedLabelColor: context.fgSub,
            tabs: [
              _TeamScoreTab(abbr: abbrLeft, score: _scoreFor(leftTeam)),
              _TeamScoreTab(abbr: abbrRight, score: _scoreFor(rightTeam)),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _TeamScorecardPage(battingInnings: _inningsFor(leftTeam)),
              _TeamScorecardPage(battingInnings: _inningsFor(rightTeam)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamScoreTab extends StatelessWidget {
  const _TeamScoreTab({required this.abbr, required this.score});
  final String abbr;
  final String score;

  @override
  Widget build(BuildContext context) => Tab(
        height: 54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(abbr,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            if (score.isNotEmpty)
              Text(score,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

// ── Team scorecard page: collapsible BATTING / BOWLING / FoW ─────────────────

class _TeamScorecardPage extends StatefulWidget {
  const _TeamScorecardPage({required this.battingInnings});
  final List<MatchInnings> battingInnings;

  @override
  State<_TeamScorecardPage> createState() => _TeamScorecardPageState();
}

class _TeamScorecardPageState extends State<_TeamScorecardPage> {
  bool _batExpanded = true;
  bool _bowlExpanded = true;
  bool _fowExpanded = true;

  @override
  Widget build(BuildContext context) {
    final allBatting = widget.battingInnings.expand((i) => i.batting).toList();
    // bowling rows live in the same innings object (opposing bowlers who bowled against this team)
    final allBowling = widget.battingInnings.expand((i) => i.bowling).toList();
    final allExtras = widget.battingInnings.fold(0, (s, i) => s + i.extras);
    final allFow =
        widget.battingInnings.expand((i) => i.fallOfWickets).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 48),
      children: [
        // ── BATTING ──────────────────────────────────────────────
        _ScCollapsible(
          label: 'BATTING',
          expanded: _batExpanded,
          onToggle: () => setState(() => _batExpanded = !_batExpanded),
          child: allBatting.isEmpty
              ? const _ScEmptyRow('No batting data yet.')
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _BattingTable(rows: allBatting, extras: allExtras),
                ),
        ),

        const SizedBox(height: 4),

        // ── BOWLING ───────────────────────────────────────────────
        _ScCollapsible(
          label: 'BOWLING',
          expanded: _bowlExpanded,
          onToggle: () => setState(() => _bowlExpanded = !_bowlExpanded),
          child: allBowling.isEmpty
              ? const _ScEmptyRow('No bowling data yet.')
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _BowlingTable(rows: allBowling),
                ),
        ),

        const SizedBox(height: 4),

        // ── FALL OF WICKETS ───────────────────────────────────────
        _ScCollapsible(
          label: 'FALL OF WICKETS',
          expanded: _fowExpanded,
          onToggle: () => setState(() => _fowExpanded = !_fowExpanded),
          child: allFow.isEmpty
              ? const _ScEmptyRow('No wickets fallen yet.')
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: _FowTable(wickets: allFow),
                ),
        ),
      ],
    );
  }
}

class _ScCollapsible extends StatelessWidget {
  const _ScCollapsible({
    required this.label,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });
  final String label;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: context.fgSub,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            Divider(height: 1, color: context.stroke.withValues(alpha: 0.5)),
            child,
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

// ── Fall of wickets table ─────────────────────────────────────────────────────

class _FowTable extends StatelessWidget {
  const _FowTable({required this.wickets});
  final List<FallOfWicket> wickets;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: wickets.map((w) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: context.accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('${w.wicket}',
                      style: TextStyle(
                          color: context.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                w.score,
                style: TextStyle(
                    color: context.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()]),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  w.player,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'ov ${w.over}',
                style: TextStyle(
                    color: context.fgSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ScEmptyRow extends StatelessWidget {
  const _ScEmptyRow(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.stroke),
        ),
        child: Center(
          child: Text(message,
              style: TextStyle(color: context.fgSub, fontSize: 13)),
        ),
      );
}

// ── Batting table ─────────────────────────────────────────────────────────────

class _BattingTable extends StatelessWidget {
  const _BattingTable({required this.rows, required this.extras});
  final List<MatchBatsmanRow> rows;
  final int extras;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
            decoration: BoxDecoration(
              color: context.panel,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: const Row(children: [
              _Ch('BATTER', flex: 5),
              _Ch('R', flex: 2),
              _Ch('B', flex: 2),
              _Ch('4s', flex: 2),
              _Ch('6s', flex: 2),
              _Ch('SR', flex: 3),
            ]),
          ),
          // Batter rows
          ...rows.asMap().entries.map((e) {
            final b = e.value;
            final isLast = e.key == rows.length - 1 && extras == 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 5,
                        child: InkWell(
                          onTap: b.playerId != null
                              ? null
                              : null,
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  b.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: b.playerId != null
                                              ? context.accent
                                              : context.fg),
                                ),
                              ),
                              if (!b.isOut)
                                Text(' *',
                                    style: TextStyle(
                                        color: context.accent,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                      _dataCell('${b.runs}', context,
                          bold: true, color: context.accent, flex: 2),
                      _dataCell('${b.balls}', context, flex: 2),
                      _dataCell('${b.fours}', context, flex: 2),
                      _dataCell('${b.sixes}', context, flex: 2),
                      _dataCell(b.strikeRate, context, flex: 3),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Text(
                    b.isOut ? b.dismissal ?? '' : 'not out',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              b.isOut ? context.fgSub : context.success,
                          fontStyle:
                              b.isOut ? FontStyle.normal : FontStyle.italic,
                        ),
                  ),
                ),
                if (!isLast)
                  Divider(
                      color: context.stroke.withValues(alpha: 0.5), height: 1),
              ],
            );
          }),
          // Extras row
          if (extras > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text('Extras',
                        style: TextStyle(
                            color: context.fgSub,
                            fontSize: 12,
                            fontStyle: FontStyle.italic)),
                  ),
                  _dataCell('$extras', context, flex: 2),
                  _dataCell('', context, flex: 2),
                  _dataCell('', context, flex: 2),
                  _dataCell('', context, flex: 2),
                  _dataCell('', context, flex: 3),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Bowling table ─────────────────────────────────────────────────────────────

class _BowlingTable extends StatelessWidget {
  const _BowlingTable({required this.rows});
  final List<MatchBowlerRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
            decoration: BoxDecoration(
              color: context.panel,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: const Row(children: [
              _Ch('BOWLER', flex: 5),
              _Ch('O', flex: 2),
              _Ch('R', flex: 2),
              _Ch('W', flex: 2),
              _Ch('ECO', flex: 3),
            ]),
          ),
          ...rows.asMap().entries.map((e) {
            final b = e.value;
            final isLast = e.key == rows.length - 1;
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: InkWell(
                          onTap: b.playerId != null
                              ? null
                              : null,
                          child: Text(b.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: b.playerId != null
                                          ? context.accent
                                          : context.fg)),
                        ),
                      ),
                      _dataCell(b.overs, context, flex: 2),
                      _dataCell('${b.runs}', context, flex: 2),
                      _dataCell('${b.wickets}', context,
                          bold: b.wickets > 0,
                          color: b.wickets > 0 ? context.accent : null,
                          flex: 2),
                      _dataCell(b.economy, context, flex: 3),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                      color: context.stroke.withValues(alpha: 0.4), height: 1),
              ],
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Table helpers ─────────────────────────────────────────────────────────────

class _Ch extends StatelessWidget {
  const _Ch(this.label, {this.flex = 1});
  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) => Expanded(
        flex: flex,
        child: Text(
          label,
          textAlign: (label == 'BATTER' || label == 'BOWLER')
              ? TextAlign.start
              : TextAlign.end,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: context.fgSub,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
        ),
      );
}

Widget _dataCell(String value, BuildContext context,
        {bool bold = false, Color? color, int flex = 1}) =>
    Expanded(
      flex: flex,
      child: Text(
        value,
        textAlign: TextAlign.end,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: color ?? context.fgSub,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );

// ══════════════════════════════════════════════════════════════════════════════
// PLAYING XI TAB
// ══════════════════════════════════════════════════════════════════════════════

class _Playing11Tab extends StatefulWidget {
  const _Playing11Tab({required this.center});
  final MatchCenter center;

  @override
  State<_Playing11Tab> createState() => _Playing11TabState();
}

class _Playing11TabState extends State<_Playing11Tab>
    with SingleTickerProviderStateMixin {
  late TabController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TabController(
        length: widget.center.squads.length.clamp(1, 2), vsync: this);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final squads = widget.center.squads;

    if (squads.isEmpty) {
      return const _EmptyState('Playing XI will be announced before the match.',
          Icons.people_outline_rounded);
    }

    return Column(
      children: [
        // Team tabs
        Container(
          color: context.bg,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Container(
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.stroke),
            ),
            padding: const EdgeInsets.all(4),
            child: TabBar(
              controller: _ctrl,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: context.accent,
                borderRadius: BorderRadius.circular(9),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: context.fg,
              unselectedLabelColor: context.fgSub,
              labelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: squads
                  .map((s) => Tab(
                        child: Text(
                          s.teamName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _ctrl,
            children: squads.map((squad) {
              final color = _teamColor(context, squad.teamName);
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(squad.teamName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700, color: context.fgSub)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.stroke),
                    ),
                    child: Column(
                      children: squad.players.asMap().entries.map((e) {
                        final i = e.key;
                        final p = e.value;
                        final isLast = i == squad.players.length - 1;
                        return InkWell(
                          onTap: p.playerId != null
                              ? null
                              : null,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(14, 12, 14, 12),
                                child: Row(
                                  children: [
                                    // jersey number
                                    SizedBox(
                                      width: 24,
                                      child: Text('${i + 1}',
                                          style: TextStyle(
                                              color: context.fgSub,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    // avatar
                                    _PlayerAvatar(
                                        player: p, color: color, size: 42),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(p.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: p.playerId != null
                                                          ? context.accent
                                                          : context.fg)),
                                          if (_has(p.roleLabel))
                                            Text(p.roleLabel!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                        color: context.fgSub)),
                                        ],
                                      ),
                                    ),
                                    // badges
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (p.isCaptain)
                                          _Badge('C', context.gold),
                                        if (p.isViceCaptain)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 4),
                                            child: _Badge(
                                                'VC',
                                                context.gold
                                                    .withValues(alpha: 0.7)),
                                          ),
                                        if (p.isWicketKeeper)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 4),
                                            child: _Badge('WK', context.sky),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast)
                                Divider(
                                  color: context.stroke.withValues(alpha: 0.4),
                                  height: 1,
                                  indent: 50,
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar(
      {required this.player, required this.color, required this.size});
  final MatchSquadPlayer player;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        ),
        child: ClipOval(
          child: player.avatarUrl != null && player.avatarUrl!.isNotEmpty
              ? Image.network(
                  player.avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _NameInitial(name: player.name, color: color, size: size),
                )
              : _NameInitial(name: player.name, color: color, size: size),
        ),
      );
}

class _NameInitial extends StatelessWidget {
  const _NameInitial(
      {required this.name, required this.color, required this.size});
  final String name;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
          style: TextStyle(
              color: color, fontSize: size * 0.38, fontWeight: FontWeight.w800),
        ),
      );
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3)),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// ANALYSIS TAB
// ══════════════════════════════════════════════════════════════════════════════

class _AnalysisTab extends StatefulWidget {
  const _AnalysisTab({required this.center, required this.matchId});
  final MatchCenter center;
  final String matchId;

  @override
  State<_AnalysisTab> createState() => _AnalysisTabState();
}

class _AnalysisTabState extends State<_AnalysisTab>
    with SingleTickerProviderStateMixin {
  late TabController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: context.bg,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Container(
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.stroke),
            ),
            padding: const EdgeInsets.all(4),
            child: TabBar(
              controller: _ctrl,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: context.accentBg,
                borderRadius: BorderRadius.circular(9),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: context.accent,
              unselectedLabelColor: context.fgSub,
              labelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: 'Batting'),
                Tab(text: 'Bowling'),
                Tab(text: 'Partnerships'),
                Tab(text: 'Charts'),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _ctrl,
            children: [
              _BattingAnalysis(center: widget.center),
              _BowlingAnalysis(center: widget.center),
              _PartnershipAnalysis(center: widget.center),
              _ChartsAnalysis(matchId: widget.matchId, center: widget.center),
            ],
          ),
        ),
      ],
    );
  }
}

class _BattingAnalysis extends StatelessWidget {
  const _BattingAnalysis({required this.center});
  final MatchCenter center;

  @override
  Widget build(BuildContext context) {
    final batters =
        <String, ({int runs, int balls, int fours, int sixes, String sr})>{};
    for (final inn in center.innings) {
      if (inn.isSuperOver) continue;
      for (final b in inn.batting) {
        batters[b.name] = (
          runs: (batters[b.name]?.runs ?? 0) + b.runs,
          balls: (batters[b.name]?.balls ?? 0) + b.balls,
          fours: (batters[b.name]?.fours ?? 0) + b.fours,
          sixes: (batters[b.name]?.sixes ?? 0) + b.sixes,
          sr: b.strikeRate,
        );
      }
    }

    final sorted = batters.entries.toList()
      ..sort((a, b) => b.value.runs.compareTo(a.value.runs));

    if (sorted.isEmpty) {
      return const _EmptyState(
          'No batting data yet.', Icons.sports_cricket_rounded);
    }

    final maxRuns = sorted.first.value.runs.toDouble();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      children: [
        _analysisHeader(context, 'TOP SCORERS'),
        Container(
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.stroke),
          ),
          child: Column(
            children: sorted.asMap().entries.map((e) {
              final name = e.value.key;
              final s = e.value.value;
              final isLast = e.key == sorted.length - 1;
              final frac = maxRuns > 0 ? s.runs / maxRuns : 0.0;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                            ),
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text: '${s.runs}',
                                    style: TextStyle(
                                        color: context.accent,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures()
                                        ])),
                                TextSpan(
                                    text: ' (${s.balls}b)',
                                    style: TextStyle(
                                        color: context.fgSub, fontSize: 12)),
                              ]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: frac,
                                  minHeight: 5,
                                  backgroundColor: context.panel,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      context.accent.withValues(alpha: 0.7)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${s.fours}×4  ${s.sixes}×6  SR ${s.sr}',
                              style: TextStyle(
                                  color: context.fgSub,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                        color: context.stroke.withValues(alpha: 0.5),
                        height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _BowlingAnalysis extends StatelessWidget {
  const _BowlingAnalysis({required this.center});
  final MatchCenter center;

  @override
  Widget build(BuildContext context) {
    final bowlers =
        <String, ({int wkts, int runs, String overs, String eco})>{};
    for (final inn in center.innings) {
      if (inn.isSuperOver) continue;
      for (final b in inn.bowling) {
        bowlers[b.name] = (
          wkts: (bowlers[b.name]?.wkts ?? 0) + b.wickets,
          runs: (bowlers[b.name]?.runs ?? 0) + b.runs,
          overs: b.overs,
          eco: b.economy,
        );
      }
    }

    final sorted = bowlers.entries.toList()
      ..sort((a, b) {
        if (b.value.wkts != a.value.wkts) {
          return b.value.wkts.compareTo(a.value.wkts);
        }
        return a.value.runs.compareTo(b.value.runs);
      });

    if (sorted.isEmpty) {
      return const _EmptyState(
          'No bowling data yet.', Icons.sports_cricket_rounded);
    }

    final maxW = sorted.first.value.wkts.toDouble();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      children: [
        _analysisHeader(context, 'WICKET TAKERS'),
        Container(
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.stroke),
          ),
          child: Column(
            children: sorted.asMap().entries.map((e) {
              final name = e.value.key;
              final s = e.value.value;
              final isLast = e.key == sorted.length - 1;
              final frac = maxW > 0 ? s.wkts / maxW : 0.0;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                            ),
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text: '${s.wkts}',
                                    style: TextStyle(
                                        color: context.accent,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures()
                                        ])),
                                TextSpan(
                                    text: ' wkts',
                                    style: TextStyle(
                                        color: context.fgSub, fontSize: 12)),
                              ]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: frac,
                                  minHeight: 5,
                                  backgroundColor: context.panel,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      context.accent.withValues(alpha: 0.7)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${s.overs} ov  ${s.runs}r  ECO ${s.eco}',
                              style: TextStyle(
                                  color: context.fgSub,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                        color: context.stroke.withValues(alpha: 0.5),
                        height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

Widget _analysisHeader(BuildContext context, String t) => Padding(
      padding: const EdgeInsets.fromLTRB(2, 10, 0, 8),
      child: Text(t,
          style: TextStyle(
              color: context.fgSub,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8)),
    );

// ── Partnership analysis ───────────────────────────────────────────────────────

class _PartnershipAnalysis extends StatelessWidget {
  const _PartnershipAnalysis({required this.center});
  final MatchCenter center;

  @override
  Widget build(BuildContext context) {
    // Collect all partnerships across non-super-over innings, tagged with team
    final items = <({String teamName, MatchPartnership p})>[];
    for (final inn in center.innings) {
      if (inn.isSuperOver) continue;
      for (final p in inn.partnerships) {
        if (p.runs > 0 || p.balls > 0) {
          items.add((teamName: inn.battingTeamName, p: p));
        }
      }
    }

    if (items.isEmpty) {
      return const _EmptyState(
          'Partnership data will appear once innings begin.',
          Icons.people_alt_outlined);
    }

    final maxRuns =
        items.map((i) => i.p.runs).fold(0, (a, b) => a > b ? a : b).toDouble();

    // Group by team
    final teams = items.map((i) => i.teamName).toSet().toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
      children: [
        for (final team in teams) ...[
          _analysisHeader(context, team.toUpperCase()),
          Container(
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.stroke),
            ),
            child: Column(
              children: items
                  .asMap()
                  .entries
                  .where((e) => e.value.teamName == team)
                  .map((e) {
                final p = e.value.p;
                final idx = items
                    .where((i) => i.teamName == team)
                    .toList()
                    .indexOf(e.value);
                final isLast =
                    idx == items.where((i) => i.teamName == team).length - 1;
                final frac = maxRuns > 0 ? p.runs / maxRuns : 0.0;
                final sr = p.balls > 0
                    ? (p.runs * 100 / p.balls).toStringAsFixed(1)
                    : '-';

                return Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(children: [
                      Row(children: [
                        Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: context.accent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('${idx + 1}',
                                style: TextStyle(
                                    color: context.accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.batter1,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              Text('& ${p.batter2}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: context.fgSub, fontSize: 12)),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: '${p.runs}',
                                style: TextStyle(
                                    color: context.accent,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ])),
                            TextSpan(
                                text: ' (${p.balls}b)',
                                style: TextStyle(
                                    color: context.fgSub, fontSize: 12)),
                          ]),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: frac,
                              minHeight: 6,
                              backgroundColor: context.panel,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  context.accent.withValues(alpha: 0.65)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('SR $sr',
                            style: TextStyle(
                                color: context.fgSub,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ]),
                  ),
                  if (!isLast)
                    Divider(
                        color: context.stroke.withValues(alpha: 0.5),
                        height: 1),
                ]);
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CHARTS ANALYSIS TAB
// ══════════════════════════════════════════════════════════════════════════════

class _ChartsAnalysis extends ConsumerWidget {
  const _ChartsAnalysis({required this.matchId, required this.center});
  final String matchId;
  final MatchCenter center;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(matchAnalysisProvider(matchId));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, size: 40, color: context.fgSub),
            const SizedBox(height: 12),
            Text('Could not load charts',
                style: TextStyle(
                    color: context.fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Pull down to refresh',
                style: TextStyle(color: context.fgSub, fontSize: 13)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(matchAnalysisProvider(matchId)),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (analysis) {
        if (analysis.innings.isEmpty) {
          return const _EmptyState('No data yet.', Icons.bar_chart);
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 48),
          children: [
            for (final inn in analysis.innings) ...[
              _analysisHeader(
                  context, '${inn.battingTeam.toUpperCase()} — RUNS PER OVER'),
              _ManhattanChart(innings: inn),
              const SizedBox(height: 16),
              _analysisHeader(
                  context, '${inn.battingTeam.toUpperCase()} — WAGON WHEEL'),
              _WagonWheelCard(innings: inn),
              const SizedBox(height: 20),
            ],
          ],
        );
      },
    );
  }
}

// ── Manhattan chart (runs per over bars) ──────────────────────────────────────

class _ManhattanChart extends StatelessWidget {
  const _ManhattanChart({required this.innings});
  final MatchAnalysisInnings innings;

  @override
  Widget build(BuildContext context) {
    final overs = innings.overStats;
    if (overs.isEmpty) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.stroke),
        ),
        child: const Center(child: Text('No over data yet.')),
      );
    }

    final maxRuns = overs.map((o) => o.runs).fold(0, (a, b) => a > b ? a : b);
    final accent = context.accent;
    final wicketColor = context.danger;

    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.stroke),
      ),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxRuns + 4).toDouble(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                'Ov ${group.x + 1}\n${rod.toY.toInt()} runs',
                TextStyle(
                    color: context.fg,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: math.max(1, (overs.length / 5).floor()).toDouble(),
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= overs.length) return const SizedBox();
                  return Text(
                    '${overs[idx].over}',
                    style: TextStyle(color: context.fgSub, fontSize: 10),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            drawHorizontalLine: true,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (v) => FlLine(
                color: context.stroke.withValues(alpha: 0.4), strokeWidth: 0.8),
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          barGroups: overs.asMap().entries.map((e) {
            final idx = e.key;
            final o = e.value;
            final hasWicket = o.wickets > 0;
            return BarChartGroupData(
              x: idx,
              barRods: [
                BarChartRodData(
                  toY: o.runs.toDouble(),
                  color: hasWicket ? wicketColor : accent,
                  width: math.max(4.0, 280.0 / overs.length - 2),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(3)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: (maxRuns + 4).toDouble(),
                    color: context.panel.withValues(alpha: 0.3),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Wagon Wheel ───────────────────────────────────────────────────────────────

class _WagonWheelCard extends StatefulWidget {
  const _WagonWheelCard({required this.innings});
  final MatchAnalysisInnings innings;

  @override
  State<_WagonWheelCard> createState() => _WagonWheelCardState();
}

class _WagonWheelCardState extends State<_WagonWheelCard> {
  String? _selectedBatter;

  @override
  Widget build(BuildContext context) {
    final balls =
        widget.innings.wagonWheel.where((b) => b.zone != null).toList();

    final batters = balls.map((b) => b.batter).toSet().toList()..sort();
    final filtered = _selectedBatter == null
        ? balls
        : balls.where((b) => b.batter == _selectedBatter).toList();

    // Shot stats from filtered balls
    final dots = filtered.where((b) => b.runs == 0 && !b.isWicket).length;
    final singles = filtered.where((b) => b.runs >= 1 && b.runs <= 3).length;
    final fours = filtered.where((b) => b.runs == 4).length;
    final sixes = filtered.where((b) => b.runs == 6).length;
    final wickets = filtered.where((b) => b.isWicket).length;

    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.stroke),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // Batter filter chips
          if (batters.isNotEmpty)
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _selectedBatter == null,
                    onTap: () => setState(() => _selectedBatter = null),
                  ),
                  ...batters.map((b) => _FilterChip(
                        label: b,
                        selected: _selectedBatter == b,
                        onTap: () => setState(() =>
                            _selectedBatter = _selectedBatter == b ? null : b),
                      )),
                ],
              ),
            ),
          const SizedBox(height: 12),
          // Shot stats row
          if (filtered.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _WwStat(
                    label: 'Dots',
                    value: '$dots',
                    color: context.fgSub),
                _WwStat(
                    label: '1-3',
                    value: '$singles',
                    color: context.sky),
                _WwStat(
                    label: '4s',
                    value: '$fours',
                    color: context.success),
                _WwStat(
                    label: '6s',
                    value: '$sixes',
                    color: context.warn),
                _WwStat(
                    label: 'Wkts',
                    value: '$wickets',
                    color: context.danger),
              ],
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 320,
            child: balls.isEmpty
                ? Center(
                    child: Text('No zone data available.',
                        style: TextStyle(color: context.fgSub, fontSize: 13)),
                  )
                : CustomPaint(
                    size: const Size(double.infinity, 320),
                    painter: _WagonWheelPainter(
                      balls: filtered,
                      bgColor: context.bg,
                      lineColor: context.stroke,
                      fgColor: context.fg,
                      dangerColor: context.danger,
                      warnColor: context.warn,
                      successColor: context.success,
                      skyColor: context.sky,
                      subColor: context.fgSub,
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _WwLegend(color: context.fgSub, label: 'Dot'),
              _WwLegend(color: context.sky, label: '1–3'),
              _WwLegend(color: context.success, label: '4'),
              _WwLegend(color: context.warn, label: '6'),
              _WwLegend(color: context.danger, label: 'Wicket'),
            ],
          ),
        ],
      ),
    );
  }
}

class _WwStat extends StatelessWidget {
  const _WwStat(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
                color: context.fgSub,
                fontSize: 11,
                fontWeight: FontWeight.w500),
          ),
        ],
      );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? context.accent.withValues(alpha: 0.15)
                : context.panel,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? context.accent : context.stroke,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? context.accent : context.fgSub,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
}

class _WwLegend extends StatelessWidget {
  const _WwLegend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: context.fgSub, fontSize: 11)),
        ],
      );
}

class _WagonWheelPainter extends CustomPainter {
  const _WagonWheelPainter({
    required this.balls,
    required this.bgColor,
    required this.lineColor,
    required this.fgColor,
    required this.dangerColor,
    required this.warnColor,
    required this.successColor,
    required this.skyColor,
    required this.subColor,
  });

  final List<WagonWheelBall> balls;
  final Color bgColor, lineColor, fgColor;
  final Color dangerColor, warnColor, successColor, skyColor, subColor;

  // Canonical wagon-wheel zone id → angle in degrees.
  static const _zoneAngles = <String, double>{
    'straight': 0.0,
    // Orientation tuned to match cricket field expectation in app UI:
    // long-on (left) ↔ straight (top) ↔ long-off (right).
    'long_on': 330.0,
    'long_off': 30.0,
    'cover': 65.0,
    'point': 100.0,
    'third_man': 140.0,
    'fine_leg': 210.0,
    'square_leg': 250.0,
    'mid_wicket': 295.0,
  };

  static const _zoneAliases = <String, String>{
    'third-man': 'third_man',
    'third man': 'third_man',
    '3rd man': 'third_man',
    'slip': 'third_man',
    'gully': 'third_man',
    'backward-point': 'point',
    'backward point': 'point',
    'deep-point': 'point',
    'deep point': 'point',
    'extra-cover': 'cover',
    'extra cover': 'cover',
    'deep-cover': 'cover',
    'deep cover': 'cover',
    'deep-extra-cover': 'cover',
    'deep extra cover': 'cover',
    'mid-off': 'long_off',
    'mid off': 'long_off',
    'long-off': 'long_off',
    'long off': 'long_off',
    'straight': 'straight',
    'straight-drive': 'straight',
    'straight drive': 'straight',
    'mid-on': 'long_on',
    'mid on': 'long_on',
    'long-on': 'long_on',
    'long on': 'long_on',
    'deep-mid-wicket': 'mid_wicket',
    'deep mid wicket': 'mid_wicket',
    'mid-wicket': 'mid_wicket',
    'mid wicket': 'mid_wicket',
    'square-leg': 'square_leg',
    'square leg': 'square_leg',
    'deep-square-leg': 'square_leg',
    'deep square leg': 'square_leg',
    'fine-leg': 'fine_leg',
    'fine leg': 'fine_leg',
    'deep-fine-leg': 'fine_leg',
    'deep fine leg': 'fine_leg',
  };

  Color _colorForBall(WagonWheelBall b) {
    if (b.isWicket) return dangerColor;
    if (b.runs == 6) return warnColor;
    if (b.runs == 4) return successColor;
    if (b.runs >= 1) return skyColor;
    return subColor;
  }

  String? _canonicalZone(String rawZone) {
    var normalized = rawZone.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    if (normalized.endsWith('-in')) {
      normalized = normalized.substring(0, normalized.length - 3);
    }
    if (normalized.endsWith('_in')) {
      normalized = normalized.substring(0, normalized.length - 3);
    }
    normalized = normalized
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    if (_zoneAngles.containsKey(normalized)) return normalized;
    final hyphen = normalized.replaceAll('_', '-');
    final spaced = normalized.replaceAll('_', ' ');
    return _zoneAliases[normalized] ??
        _zoneAliases[hyphen] ??
        _zoneAliases[spaced];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final fieldR = math.min(cx, cy) * 0.92;
    final innerR = fieldR * 0.55; // 30-yard circle

    // ── Field background
    canvas.drawCircle(
      Offset(cx, cy),
      fieldR,
      Paint()..color = const Color(0xFF1A3D1A),
    );

    // ── 30-yard circle
    canvas.drawCircle(
      Offset(cx, cy),
      innerR,
      Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = fgColor.withValues(alpha: 0.15),
    );

    // ── Boundary
    canvas.drawCircle(
      Offset(cx, cy),
      fieldR,
      Paint()
        ..color = fgColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // ── Pitch rectangle
    final pitchPaint = Paint()..color = const Color(0xFF8B7355);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, cy),
            width: fieldR * 0.06,
            height: fieldR * 0.26),
        const Radius.circular(2),
      ),
      pitchPaint,
    );

    // ── Crease lines
    final creasePaint = Paint()
      ..color = fgColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(cx - fieldR * 0.04, cy - fieldR * 0.13),
        Offset(cx + fieldR * 0.04, cy - fieldR * 0.13), creasePaint);
    canvas.drawLine(Offset(cx - fieldR * 0.04, cy + fieldR * 0.13),
        Offset(cx + fieldR * 0.04, cy + fieldR * 0.13), creasePaint);

    // ── Ball shots
    for (final ball in balls) {
      final zone = ball.zone!;
      final canonical = _canonicalZone(zone);
      if (canonical == null) continue;
      final angleDeg = _zoneAngles[canonical] ?? 0.0;
      final angleRad = (angleDeg - 90) * (math.pi / 180);
      final r = fieldR * 0.82;

      final tx = cx + r * math.cos(angleRad);
      final ty = cy + r * math.sin(angleRad);
      final color = _colorForBall(ball);
      final linePaint = Paint()
        ..color = color.withValues(alpha: 0.72)
        ..strokeWidth = ball.runs >= 4 || ball.isWicket ? 2.0 : 1.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (ball.runs == 6) {
        // High parabolic arc for sixes
        final cpX = (cx + tx) / 2;
        final cpY = (cy + ty) / 2 - fieldR * 0.38;
        final path = Path()
          ..moveTo(cx, cy)
          ..quadraticBezierTo(cpX, cpY, tx, ty);
        canvas.drawPath(path, linePaint..strokeWidth = 2.2);
      } else if (ball.runs == 4) {
        // Gentle arc for fours
        final cpX = (cx + tx) / 2;
        final cpY = (cy + ty) / 2 - fieldR * 0.12;
        final path = Path()
          ..moveTo(cx, cy)
          ..quadraticBezierTo(cpX, cpY, tx, ty);
        canvas.drawPath(path, linePaint..strokeWidth = 1.9);
      } else {
        canvas.drawLine(Offset(cx, cy), Offset(tx, ty), linePaint);
      }

      // Endpoint dot
      canvas.drawCircle(
        Offset(tx, ty),
        ball.runs == 6
            ? 5.0
            : ball.runs == 4 || ball.isWicket
                ? 4.0
                : 3.0,
        Paint()..color = color,
      );
    }

    // ── Center dot (batsman position)
    canvas.drawCircle(
      Offset(cx, cy),
      4.5,
      Paint()..color = fgColor,
    );
  }

  @override
  bool shouldRepaint(_WagonWheelPainter old) => old.balls != balls;
}

// ══════════════════════════════════════════════════════════════════════════════
// MVP TAB
// ══════════════════════════════════════════════════════════════════════════════

class _MvpTab extends StatefulWidget {
  const _MvpTab({required this.center});
  final MatchCenter center;

  @override
  State<_MvpTab> createState() => _MvpTabState();
}

class _MvpTabState extends State<_MvpTab> {
  MatchCenter? _snapshotCenter;
  int? _lastCompletedOverSnapshot;

  @override
  void initState() {
    super.initState();
    _syncSnapshot(force: true);
  }

  @override
  void didUpdateWidget(covariant _MvpTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSnapshot();
  }

  bool _isLiveProvisional(MatchCenter center) {
    final competitive = center.competitive;
    return center.lifecycle == MatchLifecycle.live &&
        (competitive == null || !competitive.isOfficial);
  }

  int _completedOvers(MatchCenter center) =>
      center.liveState?.currentOverNumber ?? 0;

  bool _hasCompetitiveData(MatchCenter? center) {
    final competitive = center?.competitive;
    if (competitive == null) return false;
    return competitive.mvp != null || competitive.leaderboard.isNotEmpty;
  }

  void _syncSnapshot({bool force = false}) {
    final center = widget.center;
    final completedOvers = _completedOvers(center);

    if (!_isLiveProvisional(center)) {
      _snapshotCenter = center;
      _lastCompletedOverSnapshot = completedOvers;
      return;
    }

    final shouldSeedSnapshot = _snapshotCenter == null;
    final shouldAdvanceSnapshot =
        _snapshotCenter != null && completedOvers != _lastCompletedOverSnapshot;
    final shouldFillCompetitiveGap = _snapshotCenter != null &&
        !_hasCompetitiveData(_snapshotCenter) &&
        _hasCompetitiveData(center);

    if (shouldSeedSnapshot ||
        shouldAdvanceSnapshot ||
        shouldFillCompetitiveGap) {
      _snapshotCenter = center;
      _lastCompletedOverSnapshot = completedOvers;
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveOverBasedUpdates = _isLiveProvisional(widget.center);
    final center = _snapshotCenter;
    final effectiveCenter = center ?? widget.center;
    final competitive = effectiveCenter.competitive;
    if (competitive != null) {
      final leader = competitive.mvp;
      final leaderboard = competitive.leaderboard;
      final heroLabel =
          competitive.isOfficial ? 'MATCH MVP' : 'PROVISIONAL MVP';
      final leaderboardLabel =
          competitive.isOfficial ? 'MATCH IMPACT POINTS' : 'LIVE IMPACT POINTS';
      final sourceLabel = competitive.isOfficial ? 'OFFICIAL' : 'LIVE';
      final helperText = competitive.isOfficial
          ? 'Impact Points are locked from the verified match result.'
          : liveOverBasedUpdates
              ? 'Live Impact Points refresh after each completed over and can change until the match is verified.'
              : 'Impact Points are estimated from the live scorecard and can change until the match is verified.';

      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
        children: [
          if (leader != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.accent.withValues(alpha: 0.20),
                    context.accent.withValues(alpha: 0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: context.accent.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            size: 16,
                            color: context.gold,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            heroLabel,
                            style: TextStyle(
                              color: context.gold,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.bg,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: context.stroke.withValues(alpha: 0.8),
                          ),
                        ),
                        child: Text(
                          sourceLabel,
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: context.accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.accent.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        leader.playerName.trim().isEmpty
                            ? '?'
                            : leader.playerName.trim()[0].toUpperCase(),
                        style: TextStyle(
                          color: context.accent,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    leader.playerName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    leader.teamName,
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: context.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${leader.impactPoints} IP',
                          style: TextStyle(
                            color: context.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: context.bg,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: context.stroke),
                        ),
                        child: Text(
                          'Score ${leader.performanceScore.toStringAsFixed(1)}',
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (leader.summary.trim().isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      leader.summary,
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 12,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: context.stroke),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: context.accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.insights_rounded,
                      color: context.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Provisional MVP is building',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Live Impact Points will appear as soon as the first meaningful contributions are recorded.',
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.stroke),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  competitive.isOfficial
                      ? Icons.verified_rounded
                      : Icons.bolt_rounded,
                  color: competitive.isOfficial ? context.gold : context.accent,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        helperText,
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap any player row to see the full IP breakdown.',
                        style: TextStyle(
                          color: context.fgSub.withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showImpactInfoSheet(context, competitive),
                  icon: Icon(
                    Icons.info_outline_rounded,
                    color: context.fgSub,
                    size: 20,
                  ),
                  tooltip: 'How Impact Points work',
                  visualDensity: VisualDensity.compact,
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _analysisHeader(context, leaderboardLabel),
          if (leaderboard.isEmpty)
            const _EmptyState(
              'Impact Points will appear once live score data is available.',
              Icons.query_stats_rounded,
            )
          else
            Container(
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.stroke),
              ),
              child: Column(
                children: leaderboard.asMap().entries.map((item) {
                  final index = item.key;
                  final entry = item.value;
                  final isLast = index == leaderboard.length - 1;
                  final isLeader = entry.isMvp ||
                      (leader != null && entry.playerId == leader.playerId);
                  final teamColor = _teamColor(context, entry.teamName);

                  return Column(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () =>
                              _showImpactBreakdownSheet(context, entry),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isLeader
                                        ? context.gold.withValues(alpha: 0.16)
                                        : context.bg,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isLeader
                                          ? context.gold.withValues(alpha: 0.5)
                                          : context.stroke,
                                    ),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: isLeader
                                          ? context.gold
                                          : context.fgSub,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 8,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: teamColor.withValues(alpha: 0.78),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              entry.playerName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                          if (isLeader) ...[
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.emoji_events_rounded,
                                              size: 15,
                                              color: context.gold,
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        entry.teamName,
                                        style: TextStyle(
                                          color: context.fgSub,
                                          fontSize: 11,
                                        ),
                                      ),
                                      if (entry.summary.trim().isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          entry.summary,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: context.fgSub,
                                            fontSize: 11,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${entry.impactPoints}',
                                            style: TextStyle(
                                              color: isLeader
                                                  ? context.gold
                                                  : context.accent,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' IP',
                                            style: TextStyle(
                                              color: context.fgSub,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap for breakdown',
                                      style: TextStyle(
                                        color: context.fgSub,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          color: context.stroke.withValues(alpha: 0.5),
                          height: 1,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      );
    }

    // Aggregate batter stats across all innings
    final batMap = <String,
        ({
      int runs,
      int balls,
      int fours,
      int sixes,
      String sr,
      String team
    })>{};
    final bowlMap = <String,
        ({int wkts, int runs, String overs, String eco, String team})>{};

    for (final inn in effectiveCenter.innings) {
      if (inn.isSuperOver) continue;
      final battingTeam = inn.battingTeamName;
      final bowlingTeam = battingTeam == effectiveCenter.teamAName
          ? effectiveCenter.teamBName
          : effectiveCenter.teamAName;

      for (final b in inn.batting) {
        batMap[b.name] = (
          runs: (batMap[b.name]?.runs ?? 0) + b.runs,
          balls: (batMap[b.name]?.balls ?? 0) + b.balls,
          fours: (batMap[b.name]?.fours ?? 0) + b.fours,
          sixes: (batMap[b.name]?.sixes ?? 0) + b.sixes,
          sr: b.strikeRate,
          team: battingTeam,
        );
      }
      for (final b in inn.bowling) {
        bowlMap[b.name] = (
          wkts: (bowlMap[b.name]?.wkts ?? 0) + b.wickets,
          runs: (bowlMap[b.name]?.runs ?? 0) + b.runs,
          overs: b.overs,
          eco: b.economy,
          team: bowlingTeam,
        );
      }
    }

    if (batMap.isEmpty && bowlMap.isEmpty) {
      return const _EmptyState('MVP will be determined once the match begins.',
          Icons.emoji_events_rounded);
    }

    // Score: runs + wickets*25
    String? mvpName;
    int mvpScore = -1;
    String mvpTeam = '';
    String mvpStat = '';

    for (final e in batMap.entries) {
      final score = e.value.runs + (bowlMap[e.key]?.wkts ?? 0) * 25;
      if (score > mvpScore) {
        mvpScore = score;
        mvpName = e.key;
        mvpTeam = e.value.team;
        mvpStat = '${e.value.runs} runs · SR ${e.value.sr}';
      }
    }
    for (final e in bowlMap.entries) {
      if (batMap.containsKey(e.key)) continue;
      final score = e.value.runs + e.value.wkts * 25;
      if (score > mvpScore) {
        mvpScore = score;
        mvpName = e.key;
        mvpTeam = e.value.team;
        mvpStat = '${e.value.wkts} wkts · ECO ${e.value.eco}';
      }
    }

    // Sort top performers
    final topBatters = batMap.entries.toList()
      ..sort((a, b) => b.value.runs.compareTo(a.value.runs));
    final topBowlers = bowlMap.entries.toList()
      ..sort((a, b) {
        if (b.value.wkts != a.value.wkts) {
          return b.value.wkts.compareTo(a.value.wkts);
        }
        return a.value.runs.compareTo(b.value.runs);
      });

    final colA = _teamColor(context, effectiveCenter.teamAName);
    final colB = _teamColor(context, effectiveCenter.teamBName);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
      children: [
        // ── MVP Hero card ─────────────────────────────────────────
        if (mvpName != null) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.accent.withValues(alpha: 0.20),
                  context.accent.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: context.accent.withValues(alpha: 0.35), width: 1.5),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events_rounded,
                        size: 16, color: context.gold),
                    const SizedBox(width: 6),
                    Text('MATCH MVP',
                        style: TextStyle(
                            color: context.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: context.accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: context.accent.withValues(alpha: 0.4), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      mvpName.trim().isEmpty
                          ? '?'
                          : mvpName.trim()[0].toUpperCase(),
                      style: TextStyle(
                          color: context.accent,
                          fontSize: 28,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  mvpName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800, letterSpacing: -0.3),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  mvpTeam,
                  style: TextStyle(
                      color: context.fgSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    mvpStat,
                    style: TextStyle(
                        color: context.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // ── Top batters ───────────────────────────────────────────
        if (topBatters.isNotEmpty) ...[
          _analysisHeader(context, 'TOP BATTERS'),
          Container(
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.stroke),
            ),
            child: Column(
              children: topBatters.take(5).toList().asMap().entries.map((e) {
                final nm = e.value.key;
                final s = e.value.value;
                final isLast = e.key == topBatters.take(5).length - 1;
                final teamColor =
                    s.team == effectiveCenter.teamAName ? colA : colB;
                return Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
                    child: Row(children: [
                      Container(
                        width: 8,
                        height: 36,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: teamColor.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nm,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            Text(s.team,
                                style: TextStyle(
                                    color: context.fgSub, fontSize: 11)),
                          ],
                        ),
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text: '${s.runs}',
                                    style: TextStyle(
                                        color: context.accent,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures()
                                        ])),
                                TextSpan(
                                    text: ' (${s.balls}b)',
                                    style: TextStyle(
                                        color: context.fgSub, fontSize: 11)),
                              ]),
                            ),
                            Text(
                              '${s.fours}×4  ${s.sixes}×6  SR ${s.sr}',
                              style: TextStyle(
                                  color: context.fgSub,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500),
                            ),
                          ]),
                    ]),
                  ),
                  if (!isLast)
                    Divider(
                        color: context.stroke.withValues(alpha: 0.5),
                        height: 1),
                ]);
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Top bowlers ───────────────────────────────────────────
        if (topBowlers.isNotEmpty) ...[
          _analysisHeader(context, 'TOP BOWLERS'),
          Container(
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.stroke),
            ),
            child: Column(
              children: topBowlers.take(5).toList().asMap().entries.map((e) {
                final nm = e.value.key;
                final s = e.value.value;
                final isLast = e.key == topBowlers.take(5).length - 1;
                final teamColor =
                    s.team == effectiveCenter.teamAName ? colA : colB;
                return Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
                    child: Row(children: [
                      Container(
                        width: 8,
                        height: 36,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: teamColor.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nm,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            Text(s.team,
                                style: TextStyle(
                                    color: context.fgSub, fontSize: 11)),
                          ],
                        ),
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text: '${s.wkts}',
                                    style: TextStyle(
                                        color: context.accent,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures()
                                        ])),
                                TextSpan(
                                    text: ' wkts',
                                    style: TextStyle(
                                        color: context.fgSub, fontSize: 11)),
                              ]),
                            ),
                            Text(
                              '${s.overs} ov · ${s.runs}r · ECO ${s.eco}',
                              style: TextStyle(
                                  color: context.fgSub,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500),
                            ),
                          ]),
                    ]),
                  ),
                  if (!isLast)
                    Divider(
                        color: context.stroke.withValues(alpha: 0.5),
                        height: 1),
                ]);
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

void _showImpactInfoSheet(
  BuildContext context,
  MatchCompetitiveSummary competitive,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.cardBg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                competitive.info.title,
                style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              ...competitive.info.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 7),
                        decoration: BoxDecoration(
                          color: context.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showImpactBreakdownSheet(
    BuildContext context, MatchCompetitiveEntry entry) {
  final breakdown = entry.breakdown;

  Widget section(List<({String label, int value})> rows) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        children: rows.asMap().entries.map((item) {
          final isLast = item.key == rows.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.value.label,
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      _signedPoints(item.value.value),
                      style: TextStyle(
                        color: item.value.value >= 0
                            ? context.accent
                            : context.danger,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  color: context.stroke.withValues(alpha: 0.55),
                  height: 1,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.cardBg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.playerName,
                style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.teamName,
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.stroke),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total Impact Points',
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${breakdown.totalImpactPoints} IP',
                      style: TextStyle(
                        color: context.accent,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _analysisHeader(context, 'PLAYING'),
              section([
                (label: 'Playing XI points', value: breakdown.playingPoints),
              ]),
              const SizedBox(height: 14),
              _analysisHeader(context, 'BATTING'),
              section([
                (
                  label: 'Runs',
                  value: breakdown.battingDetails.runsPoints,
                ),
                (
                  label: 'Boundary bonus',
                  value: breakdown.battingDetails.boundaryBonusPoints,
                ),
                (
                  label: 'Strike-rate adjustment',
                  value: breakdown.battingDetails.strikeRateBonusPoints,
                ),
                (
                  label: 'Contribution bonus',
                  value: breakdown.battingDetails.contributionBonusPoints,
                ),
              ]),
              const SizedBox(height: 14),
              _analysisHeader(context, 'BOWLING'),
              section([
                (
                  label: 'Wickets',
                  value: breakdown.bowlingDetails.wicketPoints,
                ),
                (
                  label: 'Dot balls',
                  value: breakdown.bowlingDetails.dotBallPoints,
                ),
                (
                  label: 'Maidens',
                  value: breakdown.bowlingDetails.maidenPoints,
                ),
                (
                  label: 'Economy adjustment',
                  value: breakdown.bowlingDetails.economyBonusPoints,
                ),
              ]),
              const SizedBox(height: 14),
              _analysisHeader(context, 'FIELDING'),
              section([
                (
                  label: 'Catches',
                  value: breakdown.fieldingDetails.catchPoints,
                ),
                (
                  label: 'Run-outs',
                  value: breakdown.fieldingDetails.runOutPoints,
                ),
                (
                  label: 'Stumpings',
                  value: breakdown.fieldingDetails.stumpingPoints,
                ),
              ]),
              const SizedBox(height: 14),
              _analysisHeader(context, 'BONUSES'),
              section([
                (label: 'Team win bonus', value: breakdown.winBonusPoints),
                (label: 'MVP bonus', value: breakdown.mvpBonusPoints),
              ]),
            ],
          ),
        ),
      );
    },
  );
}

String _signedPoints(int value) => value > 0 ? '+$value' : '$value';

// ══════════════════════════════════════════════════════════════════════════════
// COMMENTARY INLINE (used in overview Match Update card)
// ══════════════════════════════════════════════════════════════════════════════

class _CommentaryInline extends StatelessWidget {
  const _CommentaryInline({required this.entry});
  final MatchCommentaryEntry entry;

  Color _color(BuildContext context) {
    if (entry.isWicket) return context.danger;
    if (entry.outcome == 'SIX') return context.accent;
    if (entry.outcome == 'FOUR') return context.sky;
    return context.fgSub;
  }

  String get _label {
    if (entry.isWicket) return 'OUT';
    return switch (entry.outcome) {
      'SIX' => '6',
      'FOUR' => '4',
      'DOT' => '•',
      'WIDE' => 'WD',
      'NO_BALL' => 'NB',
      _ => '${entry.runs}',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          padding: const EdgeInsets.symmetric(vertical: 5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _color(context).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_label,
                  style: TextStyle(
                      color: _color(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w900)),
              Text(entry.over,
                  style: TextStyle(
                      color: context.fgSub,
                      fontSize: 9,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            entry.text,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: context.fg, height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// COMMENTARY TAB — per-over collapsible groups
// ══════════════════════════════════════════════════════════════════════════════

class _CommentaryTab extends ConsumerStatefulWidget {
  const _CommentaryTab({required this.matchId, required this.center});
  final String matchId;
  final MatchCenter center;

  @override
  ConsumerState<_CommentaryTab> createState() => _CommentaryTabState();
}

class _CommentaryTabState extends ConsumerState<_CommentaryTab> {
  int _selectedInnings = 1;

  @override
  void initState() {
    super.initState();
    // Default to the latest innings that has data.
    final inns = widget.center.innings;
    if (inns.isNotEmpty) {
      // Pick the last innings (most recent).
      _selectedInnings = inns.last.title.contains('2') ? 2 : 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final innings = widget.center.innings;

    // Build innings tab labels: use battingTeamName if available.
    final inningsTabs = innings.isEmpty
        ? [_InningsTab(label: 'Innings 1', number: 1)]
        : innings.map((inn) {
            final num = inn.title.contains('2') ? 2 : 1;
            return _InningsTab(label: inn.battingTeamName, number: num);
          }).toList();

    // If no innings data yet (live match just started), show single tab.
    final tabs = inningsTabs.isEmpty
        ? [_InningsTab(label: 'Innings 1', number: 1)]
        : inningsTabs;

    // Clamp selected to available tabs.
    final validNumbers = tabs.map((t) => t.number).toSet();
    if (!validNumbers.contains(_selectedInnings)) {
      _selectedInnings = tabs.first.number;
    }

    final async = ref.watch(matchCommentaryProvider(
        (matchId: widget.matchId, inningsNum: _selectedInnings)));

    return Column(
      children: [
        // ── Innings sub-tabs ─────────────────────────────────────────────
        if (tabs.length > 1) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: tabs.map((tab) {
                final isSelected = tab.number == _selectedInnings;
                return GestureDetector(
                  onTap: () => setState(() => _selectedInnings = tab.number),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tab.label,
                          style: TextStyle(
                            color: isSelected ? context.accent : context.fgSub,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: 2,
                          width: 28,
                          color: isSelected ? context.accent : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Divider(height: 1, color: context.stroke),
        ],

        // ── Commentary list ──────────────────────────────────────────────
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const _EmptyState(
                'Commentary unavailable.', Icons.chat_bubble_outline_rounded),
            data: (entries) {
              if (entries.isEmpty) {
                return const _EmptyState(
                    'No commentary for this innings yet.',
                    Icons.sports_cricket_rounded);
              }

              // Group by overNumber, newest-first.
              final byOver = <int, List<MatchCommentaryEntry>>{};
              for (final e in entries) {
                byOver.putIfAbsent(e.overNumber, () => []).add(e);
              }
              final sortedOvers = byOver.keys.toList()
                ..sort((a, b) => b.compareTo(a));

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 48),
                itemCount: sortedOvers.length,
                itemBuilder: (context, i) {
                  final over = sortedOvers[i];
                  final balls = byOver[over]!;
                  return _OverGroup(
                    overKey: (inn: _selectedInnings, over: over),
                    balls: balls,
                    initiallyExpanded: i == 0,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InningsTab {
  const _InningsTab({required this.label, required this.number});
  final String label;
  final int number;
}

class _OverGroup extends StatefulWidget {
  const _OverGroup({
    required this.overKey,
    required this.balls,
    required this.initiallyExpanded,
  });
  final ({int inn, int over}) overKey;
  final List<MatchCommentaryEntry> balls;
  final bool initiallyExpanded;

  @override
  State<_OverGroup> createState() => _OverGroupState();
}

class _OverGroupState extends State<_OverGroup> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  String get _bowlerName {
    final last = widget.balls
        .lastWhere((b) => b.bowler.isNotEmpty, orElse: () => widget.balls.last);
    return last.bowler;
  }

  int get _totalRuns => widget.balls.fold(0, (s, b) => s + b.runs);

  bool get _hasWicket => widget.balls.any((b) => b.isWicket);
  bool get _hasBoundary =>
      widget.balls.any((b) => b.outcome == 'FOUR' || b.outcome == 'SIX');

  String _ballLabel(MatchCommentaryEntry e) {
    if (e.isWicket) return 'W';
    return switch (e.outcome) {
      'SIX' => '6',
      'FOUR' => '4',
      'DOT' => '0',
      'WIDE' => 'WD',
      'NO_BALL' => 'NB',
      _ => '${e.runs}',
    };
  }

  Color _ballColor(MatchCommentaryEntry e) {
    if (e.isWicket) return context.danger;
    if (e.outcome == 'SIX') return context.accent;
    if (e.outcome == 'FOUR') return context.sky;
    if (e.outcome == 'WIDE' || e.outcome == 'NO_BALL') {
      return context.warn;
    }
    return context.fgSub;
  }

  @override
  Widget build(BuildContext context) {
    final overDisplay = widget.overKey.over + 1;
    final headerAccent = _hasWicket
        ? context.danger
        : _hasBoundary
            ? context.sky
            : context.fgSub;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              _expanded ? headerAccent.withValues(alpha: 0.30) : context.stroke,
        ),
      ),
      child: Column(
        children: [
          // ── Over header ──────────────────────────────────────────
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Row(
                children: [
                  // Over number badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: headerAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      'Over $overDisplay',
                      style: TextStyle(
                          color: headerAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _bowlerName.isEmpty
                          ? 'Over $overDisplay'
                          : _expanded
                              ? '$_bowlerName came to bowl'
                              : _bowlerName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600, color: context.fg),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Mini ball dots
                  ...widget.balls.take(6).map((b) => Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(left: 3),
                        decoration: BoxDecoration(
                          color: _ballColor(b).withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _ballLabel(b),
                            style: TextStyle(
                                color: context.fg,
                                fontSize: 8,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      )),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: context.fgSub,
                  ),
                ],
              ),
            ),
          ),

          // ── Over summary (collapsed) ─────────────────────────────
          if (!_expanded) ...[
            Divider(height: 1, color: context.stroke.withValues(alpha: 0.5)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: Row(
                children: [
                  Text(
                    '$_totalRuns run${_totalRuns == 1 ? '' : 's'} this over',
                    style: TextStyle(
                        color: context.fgSub,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                  if (_hasWicket) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.danger.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('WICKET',
                          style: TextStyle(
                              color: context.danger,
                              fontSize: 9,
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // ── Ball-by-ball commentary (expanded) ───────────────────
          if (_expanded) ...[
            Divider(height: 1, color: context.stroke.withValues(alpha: 0.5)),
            ...widget.balls.map((e) => _BallRow(entry: e)),
            // Over end summary
            Container(
              margin: const EdgeInsets.fromLTRB(12, 4, 12, 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.panel,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.summarize_outlined,
                      size: 12, color: context.fgSub),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'End of over $overDisplay  ·  $_bowlerName  ·  $_totalRuns run${_totalRuns == 1 ? '' : 's'}',
                      style: TextStyle(
                          color: context.fgSub,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BallRow extends StatelessWidget {
  const _BallRow({required this.entry});
  final MatchCommentaryEntry entry;

  Color _color(BuildContext context) {
    if (entry.isWicket) return context.danger;
    if (entry.outcome == 'SIX') return context.accent;
    if (entry.outcome == 'FOUR') return context.sky;
    return context.fgSub;
  }

  String get _label {
    if (entry.isWicket) return 'W';
    return switch (entry.outcome) {
      'SIX' => '6',
      'FOUR' => '4',
      'DOT' => '0',
      'WIDE' => 'WD',
      'NO_BALL' => 'NB',
      _ => '${entry.runs}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isKey =
        entry.isWicket || entry.outcome == 'SIX' || entry.outcome == 'FOUR';

    return Container(
      color:
          isKey ? _color(context).withValues(alpha: 0.06) : Colors.transparent,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ball outcome dot
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _color(context).withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: _color(context).withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                _label,
                style: TextStyle(
                    color: _color(context),
                    fontSize: _label.length > 1 ? 8 : 12,
                    fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.over}  ${entry.batter} v ${entry.bowler}',
                  style: TextStyle(
                      color: context.fgSub,
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  entry.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.fg,
                        fontWeight: isKey ? FontWeight.w600 : FontWeight.w400,
                        height: 1.4,
                      ),
                ),
                if (entry.scoreAfterBall != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    entry.scoreAfterBall!,
                    style: TextStyle(
                        color: _color(context),
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// INFO TAB
// ══════════════════════════════════════════════════════════════════════════════

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.center});
  final MatchCenter center;

  @override
  Widget build(BuildContext context) {
    final date = center.scheduledAt == null
        ? null
        : DateFormat('EEEE, d MMMM y  ·  h:mm a').format(center.scheduledAt!);

    final rows = <_IR>[
      if (_has(center.venueLabel))
        _IR(Icons.location_on_outlined, 'Venue', center.venueLabel!),
      if (_has(center.formatLabel))
        _IR(Icons.timer_outlined, 'Format', center.formatLabel!),
      if (date != null) _IR(Icons.calendar_month_outlined, 'Date & Time', date),
      if (_has(center.tossSummary))
        _IR(Icons.flip_outlined, 'Toss', center.tossSummary!),
      if (_has(center.resultSummary))
        _IR(Icons.emoji_events_outlined, 'Result', center.resultSummary!),
      if (_has(center.competitionLabel))
        _IR(Icons.sports_outlined, 'Competition', center.competitionLabel!),
    ];

    if (rows.isEmpty) {
      return const _EmptyState(
          'No match info available.', Icons.info_outline_rounded);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        Container(
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.stroke),
          ),
          child: Column(
            children: rows.asMap().entries.map((e) {
              final row = e.value;
              final isLast = e.key == rows.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: context.panel,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(row.icon, size: 17, color: context.fgSub),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(row.label.toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                          color: context.fgSub,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.6)),
                              const SizedBox(height: 3),
                              Text(row.value,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast) Divider(color: context.stroke, height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _IR {
  const _IR(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
}

// ══════════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ══════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState(this.message, this.icon);
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: context.fgSub.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(message,
                  style: TextStyle(color: context.fgSub, fontSize: 14),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

class _CompletedOverviewData {
  const _CompletedOverviewData({
    required this.headline,
    required this.winnerLabel,
    required this.winnerDetail,
    this.resultLine,
    this.winnerTeam,
    this.mvp,
  });

  final String headline;
  final String winnerLabel;
  final String winnerDetail;
  final String? resultLine;
  final String? winnerTeam;
  final _CompletedMvpData? mvp;
}

class _CompletedMvpData {
  const _CompletedMvpData({
    required this.name,
    required this.team,
    required this.detail,
  });

  final String name;
  final String team;
  final String detail;
}

// ══════════════════════════════════════════════════════════════════════════════
// UTILITIES
// ══════════════════════════════════════════════════════════════════════════════

MatchCenter _makeFallback(PlayerMatch m) => MatchCenter(
      id: m.id,
      title: m.title,
      sectionType: m.sectionType,
      lifecycle: m.lifecycle,
      statusLabel: m.statusLabel,
      teamAName: m.playerTeamName.isEmpty ? 'Team A' : m.playerTeamName,
      teamBName: m.opponentTeamName.isEmpty ? 'Team B' : m.opponentTeamName,
      teamAScore: '',
      teamBScore: '',
      scheduledAt: m.scheduledAt,
      competitionLabel: m.competitionLabel,
      venueLabel: m.venueLabel,
      formatLabel: m.formatLabel,
      resultSummary: m.scoreSummary,
      winnerTeamName: null,
      winMargin: null,
      tossSummary: null,
      currentRunRate: null,
      requiredRunRate: null,
      matchType: null,
      liveState: null,
      teamALogoUrl: null,
      teamBLogoUrl: null,
      teamAShortName: null,
      teamBShortName: null,
      overlayLoaded: false,
      youtubeUrl: null,
      innings: const [],
      squads: const [],
      myRole: m.myRole,
    );

Color _teamColor(BuildContext context, String name) {
  final palette = [
    context.success,
    context.sky,
    context.warn,
    Color(0xFFCC7A7A),
    context.accent,
    Color(0xFF34B8A0),
    Color(0xFFE07B45),
  ];
  if (name.isEmpty) return palette[0];
  return palette[name.codeUnits.fold(0, (a, b) => a + b) % palette.length];
}

String _teamAbbr(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  final words = trimmed.split(RegExp(r'\s+'));
  if (words.length >= 2) {
    return words.take(3).map((w) => w[0].toUpperCase()).join();
  }
  // Short single-word names (≤6 chars) look better shown as-is
  if (trimmed.length <= 6) return trimmed;
  return trimmed.substring(0, 4).toUpperCase();
}

String _truncate(String s, int max) =>
    s.length <= max ? s : '${s.substring(0, max - 1)}…';

bool _has(String? v) => v != null && v.trim().isNotEmpty;

bool _hasImpact(PlayerMatch? m) =>
    m != null &&
    ((m.playerRuns != null && m.playerRuns! > 0) ||
        (m.playerWickets != null && m.playerWickets! > 0) ||
        (m.playerCatches != null && m.playerCatches! > 0));

List<String> _impactBadges(PlayerMatch m) => [
      if (m.playerRuns != null)
        m.playerBalls != null
            ? '${m.playerRuns} runs (${m.playerBalls}b)'
            : '${m.playerRuns} runs',
      if (m.playerWickets != null && m.playerWickets! > 0)
        '${m.playerWickets} wkts',
      if (m.playerCatches != null && m.playerCatches! > 0)
        '${m.playerCatches} catches',
    ];

String? _youtubeVideoId(String rawUrl) {
  final uri = Uri.tryParse(rawUrl);
  if (uri == null) return null;

  String? videoId;
  final host = uri.host.toLowerCase();
  if (host.contains('youtu.be')) {
    final segments = uri.pathSegments;
    if (segments.isNotEmpty) videoId = segments.first;
  } else if (host.contains('youtube.com')) {
    videoId = uri.queryParameters['v'];
    if ((videoId == null || videoId.isEmpty) && uri.pathSegments.isNotEmpty) {
      final segments = uri.pathSegments;
      final liveIndex = segments.indexOf('live');
      final embedIndex = segments.indexOf('embed');
      final shortsIndex = segments.indexOf('shorts');
      if (liveIndex != -1 && liveIndex + 1 < segments.length) {
        videoId = segments[liveIndex + 1];
      } else if (embedIndex != -1 && embedIndex + 1 < segments.length) {
        videoId = segments[embedIndex + 1];
      } else if (shortsIndex != -1 && shortsIndex + 1 < segments.length) {
        videoId = segments[shortsIndex + 1];
      }
    }
  }

  if (videoId == null || videoId.trim().isEmpty) return null;
  return videoId.trim();
}

String _youtubeWatchUrl(String rawUrl) {
  final videoId = _youtubeVideoId(rawUrl);
  if (videoId == null) {
    return rawUrl;
  }
  return 'https://m.youtube.com/watch?v=$videoId&playsinline=1&app=m';
}

const String _mobileYoutubeUserAgent =
    'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36';

const String _youtubeWatchCleanupScript = '''
(() => {
  const selectors = [
    'header',
    'ytm-mobile-topbar-renderer',
    'ytm-app-header',
    'ytm-watch-metadata',
    'ytm-video-metadata-view-model',
    'ytm-video-description-header-renderer',
    'ytm-expandable-video-description-body-renderer',
    'ytm-slim-video-metadata-section-renderer',
    '.slim-video-information-title',
    '.slim-video-action-bar-actions',
    '.slim-owner-renderer',
    '.watch-below-the-player'
  ];
  for (const selector of selectors) {
    document.querySelectorAll(selector).forEach((node) => {
      node.style.display = 'none';
      node.style.height = '0';
      node.style.minHeight = '0';
      node.style.maxHeight = '0';
      node.style.margin = '0';
      node.style.padding = '0';
      node.style.visibility = 'hidden';
    });
  }
  document.body.style.background = '#000';
  document.body.style.margin = '0';
  document.body.style.padding = '0';
  document.documentElement.style.background = '#000';
  document.documentElement.style.margin = '0';
  document.documentElement.style.padding = '0';
  window.scrollTo(0, 0);
})();
''';

_CompletedOverviewData _buildCompletedOverview(
  MatchCenter center,
  PlayerMatch? fallback,
) {
  final resultLine = center.resultSummary ?? fallback?.scoreSummary;
  final normalizedResult = (resultLine ?? '').toLowerCase();
  final winnerTeam =
      center.winnerTeamName ?? _deriveWinnerTeam(center, resultLine);
  final winningMargin =
      center.winMargin ?? _extractWinningMargin(resultLine, winnerTeam);
  final mvp = _deriveCompletedMvp(center);

  if (winnerTeam != null) {
    return _CompletedOverviewData(
      headline: winningMargin != null
          ? '$winnerTeam won $winningMargin'
          : '$winnerTeam won',
      winnerLabel: winnerTeam,
      winnerDetail: winningMargin != null
          ? 'Won $winningMargin'
          : _winningDetail(resultLine),
      resultLine: resultLine,
      winnerTeam: winnerTeam,
      mvp: mvp,
    );
  }

  if (normalizedResult.contains('draw')) {
    return _CompletedOverviewData(
      headline: 'Match drawn',
      winnerLabel: 'Draw',
      winnerDetail: 'No team separated the match result.',
      resultLine: resultLine,
      mvp: mvp,
    );
  }

  if (normalizedResult.contains('tie')) {
    return _CompletedOverviewData(
      headline: 'Match tied',
      winnerLabel: 'Tie',
      winnerDetail: 'Both teams finished level.',
      resultLine: resultLine,
      mvp: mvp,
    );
  }

  if (normalizedResult.contains('abandon')) {
    return _CompletedOverviewData(
      headline: 'Match abandoned',
      winnerLabel: 'No result',
      winnerDetail: 'The match ended without a winner.',
      resultLine: resultLine,
      mvp: mvp,
    );
  }

  return _CompletedOverviewData(
    headline: 'Match completed',
    winnerLabel: 'Completed',
    winnerDetail: _winningDetail(resultLine),
    resultLine: resultLine,
    mvp: mvp,
  );
}

String? _deriveWinnerTeam(MatchCenter center, String? resultLine) {
  final summary = resultLine?.trim() ?? '';
  if (summary.isEmpty) return null;
  final normalized = summary.toLowerCase();

  if (normalized.contains(center.teamAName.toLowerCase()) &&
      normalized.contains('won')) {
    return center.teamAName;
  }
  if (normalized.contains(center.teamBName.toLowerCase()) &&
      normalized.contains('won')) {
    return center.teamBName;
  }

  return null;
}

String _winningDetail(String? resultLine) {
  if (_has(resultLine)) return resultLine!;
  return 'Final result verified.';
}

String? _extractWinningMargin(String? resultLine, String? winnerTeam) {
  if (!_has(resultLine)) return null;

  final summary = resultLine!.trim();
  final lower = summary.toLowerCase();
  final wonByIndex = lower.indexOf('won by ');
  if (wonByIndex != -1) {
    return summary.substring(wonByIndex + 3).trim();
  }

  if (winnerTeam != null) {
    final winnerLower = winnerTeam.toLowerCase();
    if (lower.startsWith(winnerLower)) {
      final remainder = summary.substring(winnerTeam.length).trimLeft();
      if (remainder.isNotEmpty) {
        return remainder[0].toUpperCase() + remainder.substring(1);
      }
    }
  }

  return null;
}

_CompletedMvpData? _deriveCompletedMvp(MatchCenter center) {
  final competitiveMvp = center.competitive?.mvp;
  if (competitiveMvp != null) {
    final detail = competitiveMvp.summary.trim().isNotEmpty
        ? competitiveMvp.summary
        : '${competitiveMvp.impactPoints} IP · Score ${competitiveMvp.performanceScore.toStringAsFixed(1)}';
    return _CompletedMvpData(
      name: competitiveMvp.playerName,
      team: competitiveMvp.teamName,
      detail: detail,
    );
  }

  final batMap = <String,
      ({
    int runs,
    int balls,
    int fours,
    int sixes,
    String sr,
    String team,
  })>{};
  final bowlMap = <String,
      ({
    int wkts,
    int runs,
    String overs,
    String eco,
    String team,
  })>{};

  for (final inn in center.innings) {
    if (inn.isSuperOver) continue;
    final battingTeam = inn.battingTeamName;
    final bowlingTeam =
        battingTeam == center.teamAName ? center.teamBName : center.teamAName;

    for (final b in inn.batting) {
      batMap[b.name] = (
        runs: (batMap[b.name]?.runs ?? 0) + b.runs,
        balls: (batMap[b.name]?.balls ?? 0) + b.balls,
        fours: (batMap[b.name]?.fours ?? 0) + b.fours,
        sixes: (batMap[b.name]?.sixes ?? 0) + b.sixes,
        sr: b.strikeRate,
        team: battingTeam,
      );
    }
    for (final b in inn.bowling) {
      bowlMap[b.name] = (
        wkts: (bowlMap[b.name]?.wkts ?? 0) + b.wickets,
        runs: (bowlMap[b.name]?.runs ?? 0) + b.runs,
        overs: b.overs,
        eco: b.economy,
        team: bowlingTeam,
      );
    }
  }

  String? bestName;
  String? bestTeam;
  String? bestDetail;
  int bestScore = -1;

  for (final entry in batMap.entries) {
    final wickets = bowlMap[entry.key]?.wkts ?? 0;
    final score = entry.value.runs + wickets * 25;
    if (score > bestScore) {
      bestScore = score;
      bestName = entry.key;
      bestTeam = entry.value.team;
      bestDetail = wickets > 0
          ? '${entry.value.runs} runs · $wickets wkts'
          : '${entry.value.runs} runs · SR ${entry.value.sr}';
    }
  }

  for (final entry in bowlMap.entries) {
    if (batMap.containsKey(entry.key)) continue;
    final score = entry.value.wkts * 25 - entry.value.runs;
    if (score > bestScore) {
      bestScore = score;
      bestName = entry.key;
      bestTeam = entry.value.team;
      bestDetail = '${entry.value.wkts} wkts · ECO ${entry.value.eco}';
    }
  }

  if (bestName == null || bestTeam == null || bestDetail == null) {
    return null;
  }

  return _CompletedMvpData(
    name: bestName,
    team: bestTeam,
    detail: bestDetail,
  );
}
