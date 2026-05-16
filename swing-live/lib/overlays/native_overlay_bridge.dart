import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'premium_a/state/ball_event.dart';
import 'premium_a/state/match_feed.dart';
import 'premium_a/state/match_state.dart';

/// Bridges the Dart-side [MatchFeed] to the native broadcast overlay
/// renderer. Replaces the older bitmap-pull approach (Flutter snapshot →
/// PNG → Pedro filter) — that path lost sharpness to upscaling and
/// dropped event-flash frames at slow snapshot rates. Now Dart only
/// sends compact JSON; native paints at full 1920×1080.
class NativeOverlayBridge {
  NativeOverlayBridge._();
  static final NativeOverlayBridge instance = NativeOverlayBridge._();

  static const MethodChannel _channel =
      MethodChannel('com.dhandha.swing/camera');

  MatchFeed? _feed;
  VoidCallback? _stateListener;
  StreamSubscription<OverlayEvent>? _eventSub;
  bool _attached = false;
  MatchState? _lastSent;

  /// Attach a feed and start mirroring its state + events to native.
  /// Idempotent — reattaching with the same feed is a no-op.
  void attach(MatchFeed feed) {
    if (_feed == feed) return;
    detach();
    _feed = feed;
    _channel.invokeMethod('setOverlayActive', {'active': true}).catchError((e) {
      debugPrint('[overlay-bridge] setOverlayActive failed: $e');
    });
    _attached = true;

    // Push current state immediately and on every change.
    _stateListener = () {
      final s = feed.state.value;
      _pushState(s);
    };
    feed.state.addListener(_stateListener!);
    _pushState(feed.state.value);

    _eventSub = feed.events.listen((e) {
      debugPrint('[overlay-bridge] event received: ${e.runtimeType}');
      _pushEvent(e);
    });
  }

  /// Manual flash trigger for debugging — bypasses the feed entirely.
  /// Invoked by the "TEST FLASH" buttons in the settings sheet so we can
  /// verify the native rendering works independently of backend events.
  Future<void> debugFireFlash(String kind) async {
    debugPrint('[overlay-bridge] DEBUG flash → $kind');
    try {
      await _channel.invokeMethod('triggerOverlayEvent', {
        'event': jsonEncode({
          'kind': kind,
          'text': kind,
          'sub': kind == 'OUT' || kind == 'DUCK' ? 'TEST · BOWLED' : '',
        }),
      });
    } catch (e) {
      debugPrint('[overlay-bridge] debug flash failed: $e');
    }
  }

  void detach() {
    if (!_attached && _feed == null) return;
    _eventSub?.cancel();
    _eventSub = null;
    if (_feed != null && _stateListener != null) {
      _feed!.state.removeListener(_stateListener!);
    }
    _stateListener = null;
    _feed = null;
    _lastSent = null;
    if (_attached) {
      _channel.invokeMethod('setOverlayActive', {'active': false}).catchError((e) {
        debugPrint('[overlay-bridge] setOverlayActive(false) failed: $e');
      });
      _attached = false;
    }
  }

  void _pushState(MatchState s) {
    // Skip if nothing meaningful changed. Native renderer is happy to
    // re-render but the channel hop is the costly bit.
    if (_lastSent != null && _equivalent(_lastSent!, s)) return;
    _lastSent = s;

    final battingTeam = s.battingSide == InningsSide.teamA ? s.teamA : s.teamB;
    final bowlingTeam = s.battingSide == InningsSide.teamA ? s.teamB : s.teamA;

    final payload = <String, dynamic>{
      'teamCodeBatting': battingTeam.shortCode,
      'teamCodeBowling': bowlingTeam.shortCode,
      'score': s.score,
      'wickets': s.wickets,
      'oversDisplay': s.oversDisplay,
      'target': s.target,
      'strikerName': s.striker.name,
      'strikerRuns': s.striker.runs,
      'strikerBalls': s.striker.ballsFaced,
      'nonStrikerName': s.nonStriker.name,
      'nonStrikerRuns': s.nonStriker.runs,
      'nonStrikerBalls': s.nonStriker.ballsFaced,
      'bowlerName': s.bowler.name,
      'bowlerOvers': s.bowler.oversDisplay,
      'bowlerRuns': s.bowler.runsConceded,
      'bowlerWickets': s.bowler.wickets,
      'venue': s.groundName,
      'matchLabel': s.matchLabel,
    };

    _channel.invokeMethod('setOverlayState', {
      'state': jsonEncode(payload),
    }).catchError((e) {
      debugPrint('[overlay-bridge] setOverlayState failed: $e');
    });
  }

  void _pushEvent(OverlayEvent e) {
    final payload = switch (e) {
      BallLanded(:final ball) when ball.isSix => {
          'kind': 'SIX',
          'text': 'SIX',
        },
      BallLanded(:final ball) when ball.isBoundary => {
          'kind': 'FOUR',
          'text': 'FOUR',
        },
      WicketTaken(:final dismissed, :final dismissalMethod) =>
        dismissed.runs == 0 && dismissed.ballsFaced <= 1
            ? {
                'kind': 'DUCK',
                'text': 'DUCK',
                'sub': dismissed.name,
              }
            : {
                'kind': 'OUT',
                'text': 'OUT',
                'sub': '${dismissed.name} · $dismissalMethod',
              },
      _ => null,
    };
    if (payload == null) return;
    debugPrint('[overlay-bridge] FLASH → ${payload['kind']}');
    _channel.invokeMethod('triggerOverlayEvent', {
      'event': jsonEncode(payload),
    }).catchError((err) {
      debugPrint('[overlay-bridge] triggerOverlayEvent failed: $err');
    });
  }

  /// Cheap fields-only equality. Skips the per-ball list (which is
  /// rendered by the over-strip and doesn't affect the native scorebar).
  bool _equivalent(MatchState a, MatchState b) {
    return a.score == b.score &&
        a.wickets == b.wickets &&
        a.balls == b.balls &&
        a.target == b.target &&
        a.battingSide == b.battingSide &&
        a.striker.name == b.striker.name &&
        a.striker.runs == b.striker.runs &&
        a.striker.ballsFaced == b.striker.ballsFaced &&
        a.nonStriker.name == b.nonStriker.name &&
        a.nonStriker.runs == b.nonStriker.runs &&
        a.nonStriker.ballsFaced == b.nonStriker.ballsFaced &&
        a.bowler.name == b.bowler.name &&
        a.bowler.legalBallsBowled == b.bowler.legalBallsBowled &&
        a.bowler.runsConceded == b.bowler.runsConceded &&
        a.bowler.wickets == b.bowler.wickets &&
        a.teamA.shortCode == b.teamA.shortCode &&
        a.teamB.shortCode == b.teamB.shortCode &&
        a.groundName == b.groundName &&
        a.matchLabel == b.matchLabel;
  }
}
