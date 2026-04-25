import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../repositories/host_match_repository.dart';
import '../../../theme/host_colors.dart';
import '../../go_live/presentation/go_live_screen.dart';

// ══════════════════════════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════════════════════════

/// Animated coin-toss screen that records the winner + their bat/bowl
/// decision against `POST /matches/:id/toss`. Host-agnostic — each app
/// supplies its own routing on success via [onCompleted].
class TossScreen extends ConsumerStatefulWidget {
  const TossScreen({
    super.key,
    required this.matchId,
    required this.teamAName,
    required this.teamBName,
    this.onCompleted,
    this.onBack,
  });

  final String matchId;
  final String teamAName;
  final String teamBName;

  /// Fires after a successful POST. Hosts use this to route into their
  /// scoring screen. If omitted, the screen pops itself.
  final void Function(BuildContext context, String matchId)? onCompleted;

  /// Custom back-button behaviour. Defaults to `Navigator.pop`.
  final VoidCallback? onBack;

  @override
  ConsumerState<TossScreen> createState() => _TossScreenState();
}

class _TossScreenState extends ConsumerState<TossScreen>
    with SingleTickerProviderStateMixin {
  // Coin state
  bool _hasFlipped = false;
  bool _resultHeads = true;

  // One controller coordinates the whole toss sequence. Phases live as
  // separate CurvedAnimations with Interval bounds.
  late final AnimationController _coinCtrl;
  late final Animation<double> _anticipation; // crouch before launch
  late final Animation<double> _flip; // spin + arc lift
  late final Animation<double> _land; // squash on impact + ripple
  late final Animation<double> _settle; // bounce back to rest
  bool _impactBuzzed = false;

  // Outcome
  String? _winnerSide; // 'A' or 'B'
  String? _decision; // 'BAT' or 'BOWL'

  bool _submitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _coinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _anticipation = CurvedAnimation(
      parent: _coinCtrl,
      curve: const Interval(0.00, 0.14, curve: Curves.easeOutCubic),
    );
    _flip = CurvedAnimation(
      parent: _coinCtrl,
      curve: const Interval(0.14, 0.82, curve: Curves.easeInOutCubic),
    );
    _land = CurvedAnimation(
      parent: _coinCtrl,
      curve: const Interval(0.82, 0.95, curve: Curves.easeOutCubic),
    );
    _settle = CurvedAnimation(
      parent: _coinCtrl,
      curve: const Interval(0.95, 1.00, curve: Curves.easeOutBack),
    );

    // Fire haptic once per flip, the instant the coin hits the ground.
    _coinCtrl.addListener(() {
      if (!_impactBuzzed && _coinCtrl.value >= 0.82) {
        _impactBuzzed = true;
        HapticFeedback.mediumImpact();
      }
    });
  }

  @override
  void dispose() {
    _coinCtrl.dispose();
    super.dispose();
  }

  // ── Derived ─────────────────────────────────────────────────────────────

  String? get _winnerName {
    if (_winnerSide == null) return null;
    return _winnerSide == 'A' ? widget.teamAName : widget.teamBName;
  }

  bool get _canSubmit =>
      !_submitting && _winnerSide != null && _decision != null;

  // ── Actions ─────────────────────────────────────────────────────────────

  Future<void> _flipCoin() async {
    if (_coinCtrl.isAnimating) return;
    HapticFeedback.selectionClick();
    setState(() {
      _resultHeads = math.Random().nextBool();
      _hasFlipped = false;
      _impactBuzzed = false;
    });
    await _coinCtrl.forward(from: 0);
    if (!mounted) return;
    setState(() => _hasFlipped = true);
  }

  Future<void> _submit() async {
    if (_winnerSide == null || _decision == null) return;
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      await ref.read(hostMatchRepositoryProvider).recordToss(
            widget.matchId,
            tossWonBy: _winnerSide!,
            tossDecision: _decision!,
          );
      if (!mounted) return;
      // Always push the GoLive step — the host can skip it instantly if they
      // don't want to broadcast. GoLive will call onCompleted (or pop) once
      // the user taps "Start Scoring".
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => GoLiveScreen(
            matchId: widget.matchId,
            teamAName: widget.teamAName,
            teamBName: widget.teamBName,
            onCompleted: widget.onCompleted,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitError = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            final onBack = widget.onBack;
            if (onBack != null) {
              onBack();
            } else {
              Navigator.of(context).maybePop();
            }
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.fg, size: 18),
        ),
        title: Text(
          'Toss',
          style: TextStyle(
            color: context.fg,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
        children: [
          _MatchupCard(
            teamAName: widget.teamAName,
            teamBName: widget.teamBName,
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 300,
            child: _AnimatedCoin(
              controller: _coinCtrl,
              anticipation: _anticipation,
              flip: _flip,
              land: _land,
              settle: _settle,
              resultHeads: _resultHeads,
              onTap: _flipCoin,
              settled: _hasFlipped,
            ),
          ),
          const SizedBox(height: 6),
          _CoinCaption(
            hasFlipped: _hasFlipped,
            isAnimating: _coinCtrl.isAnimating,
            animation: _coinCtrl,
            resultHeads: _resultHeads,
          ),
          const SizedBox(height: 22),
          _TossResultPanel(
            teamAName: widget.teamAName,
            teamBName: widget.teamBName,
            winnerSide: _winnerSide,
            decision: _decision,
            winnerName: _winnerName,
            onWinnerChanged: (side) => setState(() {
              _winnerSide = side;
              // changing the winner invalidates a previous decision, since
              // the prompt text is bound to the winner name
              _decision = null;
            }),
            onDecisionChanged: (d) => setState(() => _decision = d),
          ),
          if (_hasFlipped) ...[
            const SizedBox(height: 14),
            Center(
              child: TextButton.icon(
                onPressed: _flipCoin,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Flip again'),
                style: TextButton.styleFrom(
                  foregroundColor: context.fgSub,
                  textStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_submitError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _submitError!,
                  style: TextStyle(color: context.danger, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            _PrimaryCta(
              label: _submitting ? 'Saving toss…' : 'Start match',
              enabled: _canSubmit,
              onTap: _submit,
            ),
          ],
        ),
      ),
    );
  }

}

// ══════════════════════════════════════════════════════════════════════════════
// MATCHUP CARD
// ══════════════════════════════════════════════════════════════════════════════

class _MatchupCard extends StatelessWidget {
  const _MatchupCard({required this.teamAName, required this.teamBName});
  final String teamAName;
  final String teamBName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SideName(name: teamAName, align: TextAlign.start),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'vs',
            style: TextStyle(
              color: context.fgSub.withValues(alpha: 0.55),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
            ),
          ),
        ),
        Expanded(
          child: _SideName(name: teamBName, align: TextAlign.end),
        ),
      ],
    );
  }
}

class _SideName extends StatelessWidget {
  const _SideName({required this.name, required this.align});
  final String name;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      textAlign: align,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: context.fg,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// COIN CAPTION + RESULT PANEL
// ══════════════════════════════════════════════════════════════════════════════

/// Small, animated strap-line underneath the coin.
class _CoinCaption extends StatelessWidget {
  const _CoinCaption({
    required this.hasFlipped,
    required this.isAnimating,
    required this.animation,
    required this.resultHeads,
  });

  final bool hasFlipped;
  final bool isAnimating;
  final Animation<double> animation;
  final bool resultHeads;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final Widget child;
        if (hasFlipped) {
          final face = resultHeads ? 'HEADS' : 'TAILS';
          final color = resultHeads ? context.gold : const Color(0xFFB4C0CC);
          child = Column(
            key: const ValueKey('settled'),
            children: [
              Text(
                '$face CAME UP',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pick the winner below',
                style: TextStyle(
                  color: context.fgSub.withValues(alpha: 0.8),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        } else if (isAnimating) {
          child = Text(
            'Flipping…',
            key: const ValueKey('flipping'),
            style: TextStyle(
              color: context.fgSub,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          );
        } else {
          child = Text(
            'Tap the coin to toss',
            key: const ValueKey('idle'),
            style: TextStyle(
              color: context.fgSub.withValues(alpha: 0.75),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          );
        }
        return Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: child,
          ),
        );
      },
    );
  }
}

/// Two-step picker: pick the team that won the toss, then their decision.
class _TossResultPanel extends StatelessWidget {
  const _TossResultPanel({
    required this.teamAName,
    required this.teamBName,
    required this.winnerSide,
    required this.decision,
    required this.winnerName,
    required this.onWinnerChanged,
    required this.onDecisionChanged,
  });

  final String teamAName;
  final String teamBName;
  final String? winnerSide;
  final String? decision;
  final String? winnerName;
  final ValueChanged<String> onWinnerChanged;
  final ValueChanged<String> onDecisionChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TossHeader(label: 'WHO WON THE TOSS?'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _TeamChoiceCard(
                name: teamAName,
                selected: winnerSide == 'A',
                onTap: () => onWinnerChanged('A'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TeamChoiceCard(
                name: teamBName,
                selected: winnerSide == 'B',
                onTap: () => onWinnerChanged('B'),
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          alignment: Alignment.topCenter,
          curve: Curves.easeOutCubic,
          child: winnerSide == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TossHeader(
                        label:
                            '${(winnerName ?? '').toUpperCase()} DECIDES TO',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _DecisionCard(
                              icon: Icons.sports_cricket_rounded,
                              label: 'Bat',
                              selected: decision == 'BAT',
                              onTap: () => onDecisionChanged('BAT'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DecisionCard(
                              icon: Icons.sports_baseball_rounded,
                              label: 'Bowl',
                              selected: decision == 'BOWL',
                              onTap: () => onDecisionChanged('BOWL'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _TossHeader extends StatelessWidget {
  const _TossHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        label,
        style: TextStyle(
          color: context.fgSub.withValues(alpha: 0.7),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}

class _TeamChoiceCard extends StatelessWidget {
  const _TeamChoiceCard({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.accent;
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color:
            selected ? accent.withValues(alpha: 0.14) : context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected
              ? accent.withValues(alpha: 0.55)
              : context.stroke.withValues(alpha: 0.5),
          width: selected ? 1.4 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.22),
                  blurRadius: 18,
                  spreadRadius: 0.5,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: selected ? 0.2 : 0.1),
                  ),
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: selected ? accent : context.fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? context.fg : context.fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                AnimatedScale(
                  duration: const Duration(milliseconds: 180),
                  scale: selected ? 1 : 0,
                  child: Icon(Icons.check_circle_rounded,
                      color: accent, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.accent;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color:
            selected ? accent.withValues(alpha: 0.14) : context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected
              ? accent.withValues(alpha: 0.55)
              : context.stroke.withValues(alpha: 0.5),
          width: selected ? 1.4 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: selected ? accent : context.fgSub, size: 24),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? accent : context.fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// COIN
// ══════════════════════════════════════════════════════════════════════════════

class _AnimatedCoin extends StatelessWidget {
  const _AnimatedCoin({
    required this.controller,
    required this.anticipation,
    required this.flip,
    required this.land,
    required this.settle,
    required this.resultHeads,
    required this.onTap,
    required this.settled,
  });

  final AnimationController controller;
  final Animation<double> anticipation;
  final Animation<double> flip;
  final Animation<double> land;
  final Animation<double> settle;
  final bool resultHeads;
  final VoidCallback onTap;
  final bool settled;

  // Coin dimensions + arc peak used throughout.
  static const double _coinSize = 172;
  static const double _peakLift = 150;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          // ── Rotation — total half-turns chosen so the correct face lands up.
          // 10 half-turns (5 full) for heads, 11 for tails — coin starts
          // showing heads.
          final targetHalfTurns = resultHeads ? 10 : 11;
          final angle = flip.value * targetHalfTurns * math.pi;

          // After the flip phase, `flip` stays at 1, so angle is locked and
          // the correct face is facing us. During flip it rotates smoothly.
          final normalizedMod = angle % (2 * math.pi);
          final facing = normalizedMod < math.pi / 2 ||
              normalizedMod > 3 * math.pi / 2;
          // The coin is a physical disc: heads is always on the "front" of
          // it and tails is always on the "back". Which face the viewer
          // sees depends solely on rotation. The *result* is encoded in
          // `targetHalfTurns`: 10 half-turns end with the front (heads) up,
          // 11 half-turns end with the back (tails) up. Combined with the
          // inner π counter-rotation on the back half, the correct label
          // reads upright in either case.
          final faceIsHeads = facing;

          // ── Vertical lift: crouch, arc up, crouch on impact, spring back.
          final crouch = 6 * math.sin(anticipation.value * math.pi);
          final arcHeight =
              -_peakLift * (4 * flip.value * (1 - flip.value));
          final impactPress = 4 * land.value * (1 - settle.value);
          final verticalOffset = crouch + arcHeight + impactPress;

          // ── Squash + stretch: tiny squeeze during anticipation, stronger
          // squash on impact, spring-back from settle.
          final antSquash = 0.05 * math.sin(anticipation.value * math.pi);
          final impactSquash = 0.18 * land.value * (1 - settle.value);
          final scaleY = 1 - antSquash - impactSquash;
          final scaleX = 1 - antSquash + impactSquash * 0.8;

          // ── Ground shadow: bigger/softer/paler when coin is high, tighter
          // and darker when it lands.
          final relativeLift = (-arcHeight / _peakLift).clamp(0.0, 1.0);
          final shadowScale = 1.0 + relativeLift * 0.55;
          final shadowOpacity = 0.42 * (1 - relativeLift * 0.65);
          final shadowBlur = 16.0 + relativeLift * 18.0;

          // ── Ripple: two staggered rings spawn on impact.
          final rippleT = land.value * (1 - settle.value);

          return Stack(
            alignment: Alignment.center,
            children: [
              // Ground zone — shadow and ripple pinned to the bottom.
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: _GroundShadow(
                    width: _coinSize * 0.9,
                    scale: shadowScale,
                    opacity: shadowOpacity,
                    blur: shadowBlur,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CustomPaint(
                    size: Size(_coinSize * 1.6, 32),
                    painter: _RipplePainter(
                      progress: rippleT,
                      color: resultHeads
                          ? const Color(0xFFE0B94B)
                          : const Color(0xFFB4C0CC),
                    ),
                  ),
                ),
              ),

              // Coin itself — translate, then a single 3D transform for Y
              // rotation, slight forward tilt (X), and squash/stretch scale.
              // The inner content is counter-rotated by π on the back half so
              // the label ("HEADS" / "TAILS") is never mirrored.
              Transform.translate(
                offset: Offset(0, verticalOffset),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0022)
                    ..rotateX(-0.12) // a touch of forward tilt so it feels 3D
                    ..rotateY(angle)
                    ..scaleByDouble(scaleX, scaleY, 1.0, 1.0),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: facing
                        ? Matrix4.identity()
                        : (Matrix4.identity()..rotateY(math.pi)),
                    child: _CoinFace(
                      heads: faceIsHeads,
                      size: _coinSize,
                      glow: (settled && !controller.isAnimating) ? 1.0 : 0.55,
                      spinBlur: flip.value > 0.1 && flip.value < 0.9
                          ? (1 - (flip.value - 0.5).abs() * 2)
                          : 0,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Ground shadow ───────────────────────────────────────────────────────────

class _GroundShadow extends StatelessWidget {
  const _GroundShadow({
    required this.width,
    required this.scale,
    required this.opacity,
    required this.blur,
  });

  final double width;
  final double scale;
  final double opacity;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: scale,
      scaleY: 0.7 / scale.clamp(0.6, 2.0),
      child: Container(
        width: width,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: opacity.clamp(0.0, 0.55)),
              blurRadius: blur,
              spreadRadius: 2,
            ),
          ],
          color: Colors.black.withValues(alpha: opacity * 0.6),
        ),
      ),
    );
  }
}

// ── Ripple rings on impact ──────────────────────────────────────────────────

class _RipplePainter extends CustomPainter {
  _RipplePainter({required this.progress, required this.color});
  final double progress; // 0..1
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final center = Offset(size.width / 2, size.height * 0.75);
    final maxRadius = size.width * 0.45;

    void drawRing(double offsetT) {
      final t = (progress - offsetT).clamp(0.0, 1.0);
      if (t <= 0) return;
      final radius = maxRadius * t;
      final opacity = (0.55 * (1 - t)).clamp(0.0, 0.55);
      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2 * (1 - t * 0.4);
      final rect = Rect.fromCenter(
        center: center,
        width: radius * 2,
        height: radius * 0.75,
      );
      canvas.drawOval(rect, paint);
    }

    drawRing(0);
    drawRing(0.18);
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

// ── Coin face ───────────────────────────────────────────────────────────────

class _CoinFace extends StatelessWidget {
  const _CoinFace({
    required this.heads,
    required this.size,
    required this.glow,
    required this.spinBlur,
  });

  final bool heads;
  final double size;
  final double glow; // 0..1, multiplier on glow intensity
  final double spinBlur; // 0..1, extra glow during mid-flip

  // ── Palettes ────────────────────────────────────────────────────────────
  // Heads — warm gold.
  static const List<Color> _goldRim = [
    Color(0xFFFFE9A3),
    Color(0xFFE0B94B),
    Color(0xFF8E6B1E),
    Color(0xFFE0B94B),
    Color(0xFFFFE9A3),
    Color(0xFFE0B94B),
    Color(0xFFFFE9A3),
  ];
  static const List<Color> _goldBevel = [
    Color(0xFFF6D26E),
    Color(0xFFC79A36),
    Color(0xFF7B5B16),
  ];
  static const Color _goldGlow = Color(0xFFE0B94B);
  static const Color _goldEdge = Color(0xFF5B3F08);
  static const Color _goldLabel = Color(0xFF3B2A05);

  // Tails — dark silver.
  static const List<Color> _silverRim = [
    Color(0xFFE8EDF2),
    Color(0xFFB4BCC5),
    Color(0xFF5C6570),
    Color(0xFFA0AAB4),
    Color(0xFFE8EDF2),
    Color(0xFF9AA4AE),
    Color(0xFFDDE3EA),
  ];
  static const List<Color> _silverBevel = [
    Color(0xFFD8DFE6),
    Color(0xFF8892A0),
    Color(0xFF3A4450),
  ];
  static const Color _silverGlow = Color(0xFFB4C0CC);
  static const Color _silverEdge = Color(0xFF161A20);
  static const Color _silverLabel = Color(0xFF12171D);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Sweep gradient imitates a brushed-metal rim. Different palette
        // for heads (gold) and tails (dark silver).
        gradient: SweepGradient(
          startAngle: -math.pi / 2,
          colors: heads ? _goldRim : _silverRim,
          stops: const [0.0, 0.2, 0.4, 0.55, 0.72, 0.88, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: (heads ? _goldGlow : _silverGlow).withValues(
              alpha: (0.3 + 0.25 * glow + 0.15 * spinBlur).clamp(0.0, 0.75),
            ),
            blurRadius: 26 + 14 * glow + 10 * spinBlur,
            spreadRadius: 1 + 1.5 * glow,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Highlight sheen — brighter arc on the upper-left
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment(-0.35, -0.45),
                  radius: 0.75,
                  colors: [
                    Color(0x55FFFFFF),
                    Color(0x00FFFFFF),
                  ],
                ),
              ),
            ),
          ),
          // Inner bevel ring
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(size * 0.06),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.1, -0.1),
                    radius: 0.95,
                    colors: heads ? _goldBevel : _silverBevel,
                    stops: const [0.0, 0.6, 1.0],
                  ),
                  border: Border.all(
                    color: (heads ? _goldEdge : _silverEdge)
                        .withValues(alpha: heads ? 0.55 : 0.75),
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
          // Emblem + label
          Padding(
            padding: EdgeInsets.all(size * 0.16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  heads
                      ? Icons.sports_cricket_rounded
                      : Icons.sports_baseball_rounded,
                  size: size * 0.34,
                  color: heads ? _goldLabel : _silverLabel,
                ),
                SizedBox(height: size * 0.015),
                Text(
                  heads ? 'HEADS' : 'TAILS',
                  style: TextStyle(
                    color: heads ? _goldLabel : _silverLabel,
                    fontSize: size * 0.08,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CTA
// ══════════════════════════════════════════════════════════════════════════════

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final ctaBg = context.ctaBg;
    final ctaFg = context.ctaFg;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: enabled ? ctaBg : ctaBg.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: ctaBg.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: enabled ? onTap : null,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: enabled ? ctaFg : ctaFg.withValues(alpha: 0.55),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
