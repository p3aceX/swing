import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../animations/burst_animation.dart';
import '../../animations/duck_animation.dart';
import '../../models/overlay_models.dart';
import '../overlay_pack.dart';

/// Basic pack — PORTRAIT (minimal, glass aesthetic).
///
/// Bottom glass card:
///   • Row 1: tournament chip · last-6 balls · chase pill
///   • Row 2: teams + scores (compact)
///   • Row 3: striker · bowler   (single line — minimal)
class BasicPortrait extends OverlayPackLayout {
  const BasicPortrait({
    super.key,
    required super.bootstrap,
    required super.tick,
    required super.effects,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false,
            child: _Scoreboard(bootstrap: bootstrap, tick: tick),
          ),
        ),
        _EffectLayer(effects: effects),
      ],
    );
  }
}

// ─── Glass primitives (shared style) ─────────────────────────────────────────

class _Glass extends StatelessWidget {
  const _Glass({required this.child, this.padding = const EdgeInsets.all(12)});
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: const BoxDecoration(
            color: Color(0xCC0A0A0A),
            border: Border(
              top: BorderSide(color: Color(0x22FFFFFF), width: 0.5),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Scoreboard ──────────────────────────────────────────────────────────────

class _Scoreboard extends StatelessWidget {
  const _Scoreboard({required this.bootstrap, required this.tick});
  final OverlayBootstrap bootstrap;
  final OverlayTick? tick;

  @override
  Widget build(BuildContext context) {
    final current = tick?.current;
    final battingSide = current?.battingTeam ?? 'A';
    final batting = battingSide == 'B' ? bootstrap.teamB : bootstrap.teamA;
    final bowling = battingSide == 'B' ? bootstrap.teamA : bootstrap.teamB;
    final battingInnings = _inningsForTeam(tick, battingSide);
    final bowlingInnings =
        _inningsForTeam(tick, battingSide == 'A' ? 'B' : 'A');

    final striker = _findPlayer(bootstrap, current?.striker?.playerId);
    final nonStriker = _findPlayer(bootstrap, current?.nonStriker?.playerId);
    final bowler = _findPlayer(bootstrap, current?.bowler?.playerId);

    return _Glass(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Strap row: tournament + last balls + chase
          Row(
            children: [
              if (bootstrap.tournament != null)
                Flexible(
                  child: Text(
                    bootstrap.tournament!.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              if (tick != null) _LastBallsStrip(balls: tick!.lastBalls),
              if (tick?.chase != null) ...[
                const SizedBox(width: 6),
                _ChasePill(chase: tick!.chase!),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Teams + scores
          Row(
            children: [
              Expanded(
                child: _TeamScoreRow(
                  team: batting,
                  innings: battingInnings,
                  isBatting: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TeamScoreRow(
                  team: bowling,
                  innings: bowlingInnings,
                  isBatting: false,
                ),
              ),
            ],
          ),
          if (current != null) ...[
            const SizedBox(height: 8),
            Container(height: 1, color: const Color(0x14FFFFFF)),
            const SizedBox(height: 8),
            // Batters row: striker + non-striker side-by-side.
            Row(
              children: [
                Expanded(
                  child: striker != null && current.striker != null
                      ? _PlayerLine(
                          player: striker,
                          line:
                              '${current.striker!.runs}(${current.striker!.balls})',
                          accent: const Color(0xFFFFC107),
                          accentLabel: '★',
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: nonStriker != null && current.nonStriker != null
                      ? _PlayerLine(
                          player: nonStriker,
                          line:
                              '${current.nonStriker!.runs}(${current.nonStriker!.balls})',
                          accent: Colors.white54,
                          accentLabel: '·',
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            // Bowler row — full stats on its own line so they're readable.
            if (bowler != null && current.bowler != null) ...[
              const SizedBox(height: 6),
              _BowlerLine(player: bowler, state: current.bowler!),
            ],
          ],
        ],
      ),
    );
  }
}

InningsSummary? _inningsForTeam(OverlayTick? tick, String side) {
  if (tick == null) return null;
  for (final i in tick.inningsSummary) {
    if (i.battingTeam == side) return i;
  }
  return null;
}

class _TeamScoreRow extends StatelessWidget {
  const _TeamScoreRow({
    required this.team,
    required this.innings,
    required this.isBatting,
  });
  final TeamInfo team;
  final InningsSummary? innings;
  final bool isBatting;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TeamLogo(team: team),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      (team.shortName ?? team.name).toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isBatting ? Colors.white : Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  if (isBatting) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              if (innings != null)
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${innings!.runs}',
                        style: TextStyle(
                          color: isBatting ? Colors.white : Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      TextSpan(
                        text: '/${innings!.wickets}',
                        style: TextStyle(
                          color: isBatting ? Colors.white60 : Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                      TextSpan(
                        text: '  ${innings!.overs.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  isBatting ? 'YET TO BAT' : '—',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BowlerLine extends StatelessWidget {
  const _BowlerLine({required this.player, required this.state});
  final PlayerInfo player;
  final BowlerState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFE53935).withAlpha(40),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: const Color(0xFFE53935).withAlpha(150),
              width: 0.5,
            ),
          ),
          child: const Text(
            'BOWL',
            style: TextStyle(
              color: Color(0xFFE53935),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            _short(player.name),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${state.wickets}-${state.runsConceded}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${state.oversBowled.toStringAsFixed(1)} ov',
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Eco ${state.economy.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _PlayerLine extends StatelessWidget {
  const _PlayerLine({
    required this.player,
    required this.line,
    required this.accent,
    required this.accentLabel,
  });
  final PlayerInfo player;
  final String line;
  final Color accent;
  final String accentLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          accentLabel,
          style: TextStyle(
            color: accent,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            _short(player.name),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          line,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _TeamLogo extends StatelessWidget {
  const _TeamLogo({required this.team});
  final TeamInfo team;
  @override
  Widget build(BuildContext context) {
    final initial =
        (team.shortName ?? team.name).characters.firstOrNull?.toUpperCase() ??
            '?';
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F1F1F), Color(0xFF000000)],
        ),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0x33FFFFFF), width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: (team.logoUrl ?? '').isNotEmpty
            ? Image.network(
                team.logoUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => _initial(initial),
              )
            : _initial(initial),
      ),
    );
  }

  Widget _initial(String s) => Center(
        child: Text(s,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            )),
      );
}

class _LastBallsStrip extends StatelessWidget {
  const _LastBallsStrip({required this.balls});
  final List<BallEvent> balls;
  @override
  Widget build(BuildContext context) {
    if (balls.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: balls
          .take(6)
          .map((b) => Padding(
                padding: const EdgeInsets.only(left: 3),
                child: _BallChip(ball: b),
              ))
          .toList(),
    );
  }
}

class _BallChip extends StatelessWidget {
  const _BallChip({required this.ball});
  final BallEvent ball;
  @override
  Widget build(BuildContext context) {
    Color bg;
    String label;
    if (ball.isWicket) {
      bg = const Color(0xFFE53935);
      label = 'W';
    } else if (ball.runs == 6) {
      bg = const Color(0xFF1E88E5);
      label = '6';
    } else if (ball.runs == 4) {
      bg = const Color(0xFF26A69A);
      label = '4';
    } else if (ball.extras > 0 && ball.runs == 0) {
      bg = const Color(0x33FFFFFF);
      label = ball.outcome.startsWith('W') ? 'wd' : 'nb';
    } else {
      bg = ball.runs == 0 ? const Color(0x22FFFFFF) : const Color(0x44FFFFFF);
      label = '${ball.runs}';
    }
    return Container(
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 8,
        ),
      ),
    );
  }
}

class _ChasePill extends StatelessWidget {
  const _ChasePill({required this.chase});
  final ChaseState chase;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        'NEED ${chase.runsNeeded}',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ─── Effects ─────────────────────────────────────────────────────────────────

class _EffectLayer extends StatefulWidget {
  const _EffectLayer({required this.effects});
  final Stream<OverlayEffect> effects;
  @override
  State<_EffectLayer> createState() => _EffectLayerState();
}

class _EffectLayerState extends State<_EffectLayer> {
  Widget? _active;
  StreamSubscription<OverlayEffect>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.effects.listen(_play);
  }

  void _play(OverlayEffect e) {
    void clear() {
      if (mounted) setState(() => _active = null);
    }
    setState(() {
      switch (e) {
        case OverlayEffect.duck:
          _active = DuckAnimation(onComplete: clear);
          break;
        case OverlayEffect.six:
          _active = BurstAnimation(
            text: 'SIX!',
            color: const Color(0xFF1E88E5),
            emoji: '💥',
            onComplete: clear,
          );
          break;
        case OverlayEffect.four:
          _active = BurstAnimation(
            text: 'FOUR!',
            color: const Color(0xFF26A69A),
            onComplete: clear,
          );
          break;
        case OverlayEffect.wicket:
          _active = BurstAnimation(
            text: 'WICKET!',
            color: const Color(0xFFE53935),
            emoji: '🎯',
            onComplete: clear,
          );
          break;
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _active == null ? const SizedBox.shrink() : Positioned.fill(child: _active!);
}

// ─── helpers ─────────────────────────────────────────────────────────────────

PlayerInfo? _findPlayer(OverlayBootstrap b, String? id) {
  if (id == null) return null;
  for (final p in b.teamA.playingXi) {
    if (p.id == id) return p;
  }
  for (final p in b.teamB.playingXi) {
    if (p.id == id) return p;
  }
  return null;
}

String _short(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) return parts.first;
  return '${parts.first.characters.first}. ${parts.last}';
}
