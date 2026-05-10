import 'dart:async';

import 'package:flutter/material.dart';

import 'api/overlay_api_client.dart';
import 'models/overlay_models.dart';
import 'packs/basic/basic_pack.dart';
import 'packs/overlay_pack.dart';

/// Top-level overlay widget. Drop this on top of your camera/preview stack:
///
/// ```dart
/// Stack(children: [
///   CameraPreview(...),
///   const OverlayView(liveCode: 'SW-001', pin: 'PASS123'),
/// ])
/// ```
///
/// Lifecycle:
///   1. POST /live/validate-match → overlayToken
///   2. GET /live/matches/:id/bootstrap (heavy, once)
///   3. SSE /live/matches/:id/tick (live)
///   4. Compares ticks to emit one-shot effects (duck, six, four, wicket)
///   5. Picks portrait vs landscape based on MediaQuery orientation
class OverlayView extends StatefulWidget {
  const OverlayView({
    super.key,
    required this.liveCode,
    required this.pin,
    this.pack,
    this.apiBaseUrl,
  });

  final String liveCode;
  final String pin;

  /// Defaults to [basicOverlayPack]. Pass a different pack to swap layouts.
  final OverlayPack? pack;

  final String? apiBaseUrl;

  @override
  State<OverlayView> createState() => _OverlayViewState();
}

class _OverlayViewState extends State<OverlayView> {
  late final OverlayApiClient _api =
      OverlayApiClient(baseUrl: widget.apiBaseUrl);
  final StreamController<OverlayEffect> _effects =
      StreamController<OverlayEffect>.broadcast();

  OverlayBootstrap? _bootstrap;
  OverlayTick? _tick;
  StreamSubscription<OverlayTick>? _tickSub;
  String? _error;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    try {
      final v = await _api.validateMatch(
        liveCode: widget.liveCode,
        pin: widget.pin,
      );

      final b = await _api.fetchBootstrap(
        matchId: v.matchDbId,
        overlayToken: v.overlayToken,
      );
      if (!mounted) return;
      setState(() => _bootstrap = b);

      _tickSub = _api
          .tickStream(matchId: v.matchDbId, overlayToken: v.overlayToken)
          .listen(_onTick, onError: (e) {
        // Auto-reconnect handled in client; surface only persistent errors.
        debugPrint('[OverlayView] tick error: $e');
      });
    } on OverlayApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = '${e.code}: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  void _onTick(OverlayTick t) {
    final prev = _tick;
    setState(() => _tick = t);
    _detectEffects(prev, t);
  }

  // Compare consecutive ticks to fire one-shot animated effects.
  void _detectEffects(OverlayTick? prev, OverlayTick now) {
    final newest = now.lastBalls.isNotEmpty ? now.lastBalls.last : null;
    final prevNewest = prev?.lastBalls.isNotEmpty == true ? prev!.lastBalls.last : null;
    if (newest == null) return;
    // Only fire on a *new* ball event (id changed).
    if (prevNewest != null && prevNewest.id == newest.id) return;

    if (newest.isWicket) {
      // Duck = striker dismissed for 0 in their innings.
      // Heuristic: previous tick's striker (the one now dismissed) had runs == 0.
      final dismissedRunsBefore =
          prev?.current?.striker?.playerId == newest.batterId
              ? prev?.current?.striker?.runs
              : prev?.current?.nonStriker?.playerId == newest.batterId
                  ? prev?.current?.nonStriker?.runs
                  : null;
      final isDuck = (dismissedRunsBefore == 0) && newest.runs == 0;
      _effects.add(isDuck ? OverlayEffect.duck : OverlayEffect.wicket);
      return;
    }
    if (newest.runs == 6) {
      _effects.add(OverlayEffect.six);
    } else if (newest.runs == 4) {
      _effects.add(OverlayEffect.four);
    }
  }

  @override
  void dispose() {
    _tickSub?.cancel();
    _effects.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          color: Colors.red.shade900,
          padding: const EdgeInsets.all(8),
          child: Text(
            'Overlay error: $_error',
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_bootstrap == null) return const SizedBox.shrink();

    final pack = widget.pack ?? basicOverlayPack;
    final orientation = MediaQuery.of(context).orientation;
    final builder = orientation == Orientation.portrait
        ? pack.portraitBuilder
        : pack.landscapeBuilder;

    return builder(
      bootstrap: _bootstrap!,
      tick: _tick,
      effects: _effects.stream,
    );
  }
}
