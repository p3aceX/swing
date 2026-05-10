import 'package:flutter/widgets.dart';

import '../models/overlay_models.dart';

/// Triggered animations the orchestrator emits onto an overlay pack.
///
/// Packs decide which to render and how. Currently produced:
///   - duck:   striker dismissed for 0
///   - six:    last ball was a six
///   - four:   last ball was a four
///   - wicket: any wicket (not a duck)
enum OverlayEffect { duck, six, four, wicket }

/// Implemented by every concrete pack file (e.g. `BasicPortrait`,
/// `BasicLandscape`). Each pack is one ConsumerWidget-style class:
/// it gets the latest [bootstrap] + [tick] + a stream of one-shot
/// [OverlayEffect]s and renders the overlay.
abstract class OverlayPackLayout extends StatelessWidget {
  const OverlayPackLayout({
    super.key,
    required this.bootstrap,
    required this.tick,
    required this.effects,
  });

  final OverlayBootstrap bootstrap;
  final OverlayTick? tick;
  final Stream<OverlayEffect> effects;
}

/// Manifest for a pack — pairs a portrait + landscape layout.
class OverlayPack {
  const OverlayPack({
    required this.id,
    required this.name,
    required this.portraitBuilder,
    required this.landscapeBuilder,
  });

  final String id;
  final String name;
  final OverlayPackLayout Function({
    Key? key,
    required OverlayBootstrap bootstrap,
    required OverlayTick? tick,
    required Stream<OverlayEffect> effects,
  }) portraitBuilder;
  final OverlayPackLayout Function({
    Key? key,
    required OverlayBootstrap bootstrap,
    required OverlayTick? tick,
    required Stream<OverlayEffect> effects,
  }) landscapeBuilder;
}
