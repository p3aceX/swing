import 'package:flutter/foundation.dart';

import 'ball_event.dart';
import 'match_state.dart';

/// Source-of-truth interface for the overlay's data. Two implementations
/// today: a `DummyMatchRunner` for design demos, and a `LiveMatchFeed`
/// that talks to the backend's validate-match → bootstrap → tick SSE
/// pipeline. The overlay widgets don't know or care which one is wired.
abstract class MatchFeed {
  ValueNotifier<MatchState> get state;

  /// Transient events the flashes react to (BallLanded, WicketTaken, …).
  Stream<OverlayEvent> get events;

  /// Optional human-readable status for the producer (e.g. "Connecting…",
  /// "Live", "Disconnected — retrying in 3s"). UI can render in a tag.
  ValueNotifier<MatchFeedStatus> get status;

  void start();
  void stop();
  void dispose();
}

@immutable
class MatchFeedStatus {
  final MatchFeedKind kind;
  final String label;
  final String? error;
  const MatchFeedStatus(this.kind, this.label, {this.error});

  static const demo =
      MatchFeedStatus(MatchFeedKind.demo, 'DEMO');
  static const connecting =
      MatchFeedStatus(MatchFeedKind.connecting, 'CONNECTING…');
  static const live =
      MatchFeedStatus(MatchFeedKind.live, 'LIVE');
  static const disconnected =
      MatchFeedStatus(MatchFeedKind.disconnected, 'DISCONNECTED');
  static MatchFeedStatus failed(String e) =>
      MatchFeedStatus(MatchFeedKind.failed, 'FAILED', error: e);
}

enum MatchFeedKind { demo, connecting, live, disconnected, failed }
