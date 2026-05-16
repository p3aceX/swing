import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../streaming/stream_controller.dart';
import '../native_overlay_bridge.dart';
import '../overlay_capturer.dart';
import 'state/dummy_match_runner.dart';
import 'state/live_match_feed.dart';
import 'state/match_credentials.dart';
import 'state/match_feed.dart';
import 'widgets/event_flashes.dart';
import 'widgets/logo_mark.dart';
import 'widgets/scorebar.dart';

/// Premium-A overlay pack. Loads saved [MatchCredentials] on mount — if
/// present, uses [LiveMatchFeed] (backend SSE); otherwise falls back to
/// [DummyMatchRunner] for design demos.
///
/// Surface widgets ([PremiumAScorebar], [EventFlashLayer], [LogoMark])
/// don't know which feed they're rendering — they consume the
/// [MatchFeed] interface.
class PremiumAOverlay extends StatefulWidget {
  const PremiumAOverlay({super.key, this.previewMode = false});

  /// If true, forces rendering even if the stream is live. Used by the
  /// 'Visibility' icon in the UI to let the producer check the overlay.
  final bool previewMode;

  @override
  State<PremiumAOverlay> createState() => PremiumAOverlayState();
}

class PremiumAOverlayState extends State<PremiumAOverlay> {
  MatchFeed? _feed;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _initFeed();
  }

  Future<void> _initFeed() async {
    final creds = await MatchCredentials.load();
    if (!mounted) return;
    final feed =
        creds != null && creds.isComplete ? LiveMatchFeed(creds) : DummyMatchRunner();
    feed.start();
    // Push state + flash events to the native overlay renderer. The
    // local Flutter overlay tree below still renders so the in-app
    // preview matches what YouTube sees.
    NativeOverlayBridge.instance.attach(feed);
    setState(() {
      _feed = feed;
      _loaded = true;
    });
  }

  /// Re-init the feed — call from the settings sheet after credentials
  /// have been saved or cleared. Tears down the old feed cleanly.
  Future<void> reload() async {
    final old = _feed;
    setState(() => _feed = null);
    NativeOverlayBridge.instance.detach();
    old?.dispose();
    await _initFeed();
  }

  @override
  void dispose() {
    NativeOverlayBridge.instance.detach();
    _feed?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = _feed;
    if (!_loaded || feed == null) {
      return const SizedBox.shrink();
    }

    // HEAT OPTIMIZATION:
    // If we're live, we don't need to render the Flutter widgets — the 
    // Pedro engine is already baking them into the native stream via the 
    // JSON bridge. Rendering them here would just burn battery.
    // We only render if we're pre-stream OR the user explicitly toggled 
    // the 'Preview' mode to check alignment.
    final ctrl = context.watch<StreamController>();
    final isLive = ctrl.phase == StreamPhase.live;
    final shouldHide = isLive && !widget.previewMode;

    if (shouldHide) {
      return const SizedBox.shrink();
    }

    // RepaintBoundary scopes the snapshot target to JUST the overlay
    // subtree (not the camera preview underneath). The OverlayCapturer
    // reads back the boundary's recorded layer at ~3fps and pushes it
    // to native for compositing into the YouTube stream.
    return IgnorePointer(
      child: RepaintBoundary(
        key: OverlayCapturer.instance.captureKey,
        child: Stack(
          children: [
            EventFlashLayer(events: feed.events),
            const Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                bottom: false,
                right: false,
                child: LogoMark(),
              ),
            ),
            const Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                bottom: false,
                left: false,
                child: SponsorMark(),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                left: false,
                right: false,
                child: ValueListenableBuilder(
                  valueListenable: feed.state,
                  builder: (_, state, child) => PremiumAScorebar(state: state),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

