import 'package:flutter/material.dart';

import '../state/match_state.dart';
import '../theme/premium_a_theme.dart';

/// Premium-A bottom scorebar — mirrors the native broadcast_overlay.xml
/// pixel-for-pixel proportionally. The native version renders at exactly
/// 1920×1080 and is what YouTube viewers see; this Flutter version is
/// the in-app preview, scaled to whatever the screen is. Anything you
/// change here, change in the XML too.
///
/// Layout (left → right):
///   - 12px team accent strip (team colour)
///   - team code slab
///   - vertical hairline divider
///   - score / overs / CRR block
///   - vertical hairline divider
///   - players block (striker highlighted with ★ + non-striker)
///   - vertical hairline divider
///   - bowler block (name + figures + ECO)
///   - target chip (conditional, during a chase)
class PremiumAScorebar extends StatelessWidget {
  const PremiumAScorebar({super.key, required this.state});

  final MatchState state;

  // Native bar is 140px tall at 1080 height = 13% of frame. Map to
  // the same proportion of the in-app preview height.
  static const double _barHeight = 56;

  @override
  Widget build(BuildContext context) {
    final isChasing = state.target != null;
    final battingHex = state.battingTeam.accentColor;

    return RepaintBoundary(
      child: Container(
        height: _barHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xF20F1B2D), Color(0xF80B1422)],
          ),
          border: Border(
            top: BorderSide(color: PremiumATheme.mustard, width: 1.2),
          ),
        ),
        child: Row(
          children: [
            // Team accent strip.
            Container(width: 5, color: Color(battingHex)),
            // Team code slab.
            _TeamCodeSlab(
              // Match native truncation (3 chars). Backend sometimes
              // ships longer shortNames like "SWING G" that wrap the
              // native slab on 2 lines — keep both sides identical.
              code: state.battingTeam.shortCode.length > 3
                  ? state.battingTeam.shortCode.substring(0, 3).toUpperCase()
                  : state.battingTeam.shortCode.toUpperCase(),
            ),
            const _VDivider(),
            _ScoreBlock(state: state),
            const _VDivider(),
            Expanded(child: _PlayersBlock(state: state)),
            const _VDivider(),
            _BowlerBlock(state: state),
            if (isChasing) ...[
              _TargetChip(state: state),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Team code slab ──────────────────────────────────────────────────────
class _TeamCodeSlab extends StatelessWidget {
  const _TeamCodeSlab({required this.code});
  final String code;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: Center(
        child: Text(
          code,
          style: const TextStyle(
            color: PremiumATheme.bone,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.6,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

// ── Score / overs / CRR ─────────────────────────────────────────────────
class _ScoreBlock extends StatelessWidget {
  const _ScoreBlock({required this.state});
  final MatchState state;
  @override
  Widget build(BuildContext context) {
    final crr = state.crr.toStringAsFixed(2);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${state.score}-${state.wickets}',
            style: const TextStyle(
              color: PremiumATheme.bone,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(
                '${state.oversDisplay} OV',
                style: const TextStyle(
                  color: PremiumATheme.mustard,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'CRR $crr',
                style: TextStyle(
                  color: PremiumATheme.bone.withValues(alpha: 0.7),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Players (striker + non-striker stacked) ─────────────────────────────
class _PlayersBlock extends StatelessWidget {
  const _PlayersBlock({required this.state});
  final MatchState state;
  @override
  Widget build(BuildContext context) {
    final s = state.striker;
    final ns = state.nonStriker;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '★',
                style: TextStyle(
                  color: PremiumATheme.mustard,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  s.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PremiumATheme.bone,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${s.runs}(${s.ballsFaced})',
                style: const TextStyle(
                  color: PremiumATheme.mustard,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Opacity(
            opacity: 0.78,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      ns.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: PremiumATheme.bone,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${ns.runs}(${ns.ballsFaced})',
                    style: const TextStyle(
                      color: PremiumATheme.bone,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
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

// ── Bowler block ────────────────────────────────────────────────────────
class _BowlerBlock extends StatelessWidget {
  const _BowlerBlock({required this.state});
  final MatchState state;
  @override
  Widget build(BuildContext context) {
    final b = state.bowler;
    final figures = '${b.oversDisplay}-${b.wickets}-${b.runsConceded}';
    final eco = b.economy.toStringAsFixed(2);
    return SizedBox(
      width: 150,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              b.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: PremiumATheme.bone,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  figures,
                  style: const TextStyle(
                    color: PremiumATheme.mustard,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'ECO $eco',
                  style: TextStyle(
                    color: PremiumATheme.bone.withValues(alpha: 0.7),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Target chip ─────────────────────────────────────────────────────────
class _TargetChip extends StatelessWidget {
  const _TargetChip({required this.state});
  final MatchState state;
  @override
  Widget build(BuildContext context) {
    final need = state.runsNeeded ?? 0;
    final rrr = state.rrr?.toStringAsFixed(2);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            color: PremiumATheme.mustard,
            child: const Text(
              'NEED',
              style: TextStyle(
                color: Color(0xFF0F1B2D),
                fontSize: 7,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '$need',
            style: const TextStyle(
              color: PremiumATheme.mustard,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
          if (rrr != null) ...[
            const SizedBox(height: 1),
            Text(
              'RRR $rrr',
              style: TextStyle(
                color: PremiumATheme.bone.withValues(alpha: 0.7),
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Bits ────────────────────────────────────────────────────────────────
class _VDivider extends StatelessWidget {
  const _VDivider();
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        color: PremiumATheme.bone.withValues(alpha: 0.2),
      );
}
