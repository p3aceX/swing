import 'dart:async';

import 'package:flutter/material.dart';

import '../models/overlay_models.dart';
import '../packs/basic/basic_pack.dart';
import '../packs/overlay_pack.dart';
import 'mock_data.dart';

/// Live preview of an overlay pack — renders the portrait + landscape
/// layouts on top of a fake "field" backdrop with mock data, plus buttons
/// to manually trigger the animated effects.
///
/// Open from Setup → "PREVIEW OVERLAY PACK" button.
class OverlayPackPreviewPage extends StatefulWidget {
  const OverlayPackPreviewPage({super.key, this.pack});

  final OverlayPack? pack;

  @override
  State<OverlayPackPreviewPage> createState() => _OverlayPackPreviewPageState();
}

class _OverlayPackPreviewPageState extends State<OverlayPackPreviewPage> {
  late final OverlayPack _pack = widget.pack ?? basicOverlayPack;
  final OverlayBootstrap _bootstrap = mockBootstrap();
  final StreamController<OverlayEffect> _effects =
      StreamController<OverlayEffect>.broadcast();

  Orientation _layoutOrientation = Orientation.landscape;
  OverlayTick _tick = mockTick();

  @override
  void dispose() {
    _effects.close();
    super.dispose();
  }

  void _trigger(OverlayEffect e) {
    // Mutate the tick to match the effect, so the score / last-ball strip
    // also updates — the effect on its own would feel disconnected.
    setState(() {
      switch (e) {
        case OverlayEffect.duck:
          _tick = mockTick(
            wickets: _tick.current!.wickets + 1,
            runs: _tick.current!.runs,
            overs: _tick.current!.overs,
            lastBallWicket: true,
            lastBallRuns: 0,
          );
          break;
        case OverlayEffect.wicket:
          _tick = mockTick(
            wickets: _tick.current!.wickets + 1,
            runs: _tick.current!.runs,
            overs: _tick.current!.overs,
            lastBallWicket: true,
            lastBallRuns: 0,
          );
          break;
        case OverlayEffect.six:
          _tick = mockTick(
            wickets: _tick.current!.wickets,
            runs: _tick.current!.runs + 6,
            overs: _tick.current!.overs,
            lastBallRuns: 6,
          );
          break;
        case OverlayEffect.four:
          _tick = mockTick(
            wickets: _tick.current!.wickets,
            runs: _tick.current!.runs + 4,
            overs: _tick.current!.overs,
            lastBallRuns: 4,
          );
          break;
      }
    });
    _effects.add(e);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '${_pack.name.toUpperCase()} PACK',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          _OrientationToggle(
            value: _layoutOrientation,
            onChanged: (o) => setState(() => _layoutOrientation = o),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(child: _buildPreviewFrame()),
            ),
          ),
          _EffectButtons(onTrigger: _trigger),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPreviewFrame() {
    final aspect = _layoutOrientation == Orientation.portrait ? 9 / 16 : 16 / 9;
    return AspectRatio(
      aspectRatio: aspect,
      child: ClipRect(
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: Size(
              _layoutOrientation == Orientation.portrait ? 360 : 720,
              _layoutOrientation == Orientation.portrait ? 640 : 405,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _FieldBackdrop(),
              _layoutOrientation == Orientation.portrait
                  ? _pack.portraitBuilder(
                      bootstrap: _bootstrap,
                      tick: _tick,
                      effects: _effects.stream,
                    )
                  : _pack.landscapeBuilder(
                      bootstrap: _bootstrap,
                      tick: _tick,
                      effects: _effects.stream,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrientationToggle extends StatelessWidget {
  const _OrientationToggle({required this.value, required this.onChanged});
  final Orientation value;
  final ValueChanged<Orientation> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _seg('PORTRAIT', value == Orientation.portrait,
            () => onChanged(Orientation.portrait)),
        _seg('LANDSCAPE', value == Orientation.landscape,
            () => onChanged(Orientation.landscape)),
      ],
    );
  }

  Widget _seg(String label, bool selected, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: selected ? Colors.white : Colors.transparent,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      );
}

class _FieldBackdrop extends StatelessWidget {
  const _FieldBackdrop();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0E5132),
            Color(0xFF1B7A4D),
            Color(0xFF0E5132),
          ],
        ),
      ),
      child: const Center(
        child: Text(
          'CAMERA PREVIEW',
          style: TextStyle(
            color: Colors.white12,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }
}

class _EffectButtons extends StatelessWidget {
  const _EffectButtons({required this.onTrigger});
  final void Function(OverlayEffect) onTrigger;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _btn(
            label: 'DUCK',
            emoji: '🦆',
            color: const Color(0xFFFFC107),
            onTap: () => onTrigger(OverlayEffect.duck),
          ),
          const SizedBox(width: 8),
          _btn(
            label: 'SIX',
            emoji: '💥',
            color: const Color(0xFF1976D2),
            onTap: () => onTrigger(OverlayEffect.six),
          ),
          const SizedBox(width: 8),
          _btn(
            label: 'FOUR',
            emoji: '4️⃣',
            color: const Color(0xFF00897B),
            onTap: () => onTrigger(OverlayEffect.four),
          ),
          const SizedBox(width: 8),
          _btn(
            label: 'WICKET',
            emoji: '🎯',
            color: const Color(0xFFD32F2F),
            onTap: () => onTrigger(OverlayEffect.wicket),
          ),
        ],
      ),
    );
  }

  Widget _btn({
    required String label,
    required String emoji,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          color: color,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
