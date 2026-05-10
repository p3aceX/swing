import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../animations/burst_animation.dart';
import '../../animations/duck_animation.dart';
import '../../models/overlay_models.dart';
import '../overlay_pack.dart';

/// Basic pack — LANDSCAPE (slim lower-third strip, glass).
///
/// Two thin rows pinned to the bottom edge — total ~76px:
///   • Top strip (~22px) — LIVE · tournament · last 6 balls · chase
///   • Main row (~54px)  — TEAM A score | VS | TEAM B score | striker | bowler | CRR
class BasicLandscape extends OverlayPackLayout {
  const BasicLandscape({
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
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: _Strip(bootstrap: bootstrap, tick: tick),
          ),
        ),
        _EffectLayer(effects: effects),
      ],
    );
  }
}

// ─── Strip (the whole lower-third) ───────────────────────────────────────────

class _Strip extends StatelessWidget {
  const _Strip({required this.bootstrap, required this.tick});
  final OverlayBootstrap bootstrap;
  final OverlayTick? tick;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xC0080808), Color(0xE6000000)],
            ),
            border: Border(
              top: BorderSide(color: Color(0x33FFFFFF), width: 0.6),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(bootstrap: bootstrap, tick: tick),
              Container(height: 0.5, color: const Color(0x14FFFFFF)),
              _MainRow(bootstrap: bootstrap, tick: tick),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header (slim, ~22px) ────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.bootstrap, required this.tick});
  final OverlayBootstrap bootstrap;
  final OverlayTick? tick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          const _LiveDot(),
          const SizedBox(width: 5),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Color(0xFFE53935),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
              height: 1,
            ),
          ),
          if (bootstrap.tournament != null) ...[
            const SizedBox(width: 6),
            Container(
              width: 2,
              height: 2,
              color: const Color(0x55FFFFFF),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                bootstrap.tournament!.name.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  height: 1,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (tick != null) _LastBallsStrip(balls: tick!.lastBalls),
          if (tick?.chase != null) ...[
            const SizedBox(width: 6),
            _ChasePill(chase: tick!.chase!),
          ],
        ],
      ),
    );
  }
}

// ─── Main row (~54px, the hero) ──────────────────────────────────────────────

class _MainRow extends StatelessWidget {
  const _MainRow({required this.bootstrap, required this.tick});
  final OverlayBootstrap bootstrap;
  final OverlayTick? tick;

  @override
  Widget build(BuildContext context) {
    final current = tick?.current;
    final battingSide = current?.battingTeam ?? 'A';
    final battingInnings = _inningsForTeam(tick, battingSide);
    final bowlingInnings =
        _inningsForTeam(tick, battingSide == 'A' ? 'B' : 'A');
    final aIsBatting = battingSide == 'A';
    final aInnings = aIsBatting ? battingInnings : bowlingInnings;
    final bInnings = aIsBatting ? bowlingInnings : battingInnings;

    final striker = _findPlayer(bootstrap, current?.striker?.playerId);
    final bowler = _findPlayer(bootstrap, current?.bowler?.playerId);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // TEAM A
          Expanded(
            flex: 3,
            child: _TeamCell(
              team: bootstrap.teamA,
              innings: aInnings,
              isBatting: aIsBatting,
              alignEnd: false,
            ),
          ),
          const SizedBox(width: 6),
          const _VsChip(),
          const SizedBox(width: 6),
          // TEAM B
          Expanded(
            flex: 3,
            child: _TeamCell(
              team: bootstrap.teamB,
              innings: bInnings,
              isBatting: !aIsBatting,
              alignEnd: true,
            ),
          ),
          // Live players + CRR — only when there's a current innings.
          if (current != null) ...[
            const _Pipe(),
            if (striker != null && current.striker != null)
              Flexible(
                flex: 2,
                child: _MiniPlayer(
                  player: striker,
                  primary:
                      '${current.striker!.runs}(${current.striker!.balls})',
                  label: 'STR',
                  accent: const Color(0xFFFFB300),
                ),
              ),
            if (bowler != null && current.bowler != null) ...[
              const SizedBox(width: 8),
              Flexible(
                flex: 2,
                child: _MiniPlayer(
                  player: bowler,
                  primary:
                      '${current.bowler!.wickets}-${current.bowler!.runsConceded}',
                  label: 'BWL',
                  accent: const Color(0xFFE53935),
                ),
              ),
            ],
            const _Pipe(),
            _CrrChip(current: current),
          ],
        ],
      ),
    );
  }
}

// ─── Team cell ───────────────────────────────────────────────────────────────

class _TeamCell extends StatelessWidget {
  const _TeamCell({
    required this.team,
    required this.innings,
    required this.isBatting,
    required this.alignEnd,
  });
  final TeamInfo team;
  final InningsSummary? innings;
  final bool isBatting;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final logo = _TeamLogo(team: team, isBatting: isBatting);
    final body = Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            (team.shortName ?? team.name).toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: alignEnd ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              color: isBatting ? Colors.white : Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          if (innings != null)
            RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: alignEnd ? TextAlign.right : TextAlign.left,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${innings!.runs}',
                    style: TextStyle(
                      color: isBatting ? Colors.white : Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: -0.3,
                    ),
                  ),
                  TextSpan(
                    text: '/${innings!.wickets}',
                    style: TextStyle(
                      color: isBatting
                          ? const Color(0xFFFFB300)
                          : Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  TextSpan(
                    text: '  ${innings!.overs.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              isBatting ? 'YET TO BAT' : '—',
              textAlign: alignEnd ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
        ],
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignEnd
          ? [body, const SizedBox(width: 6), logo]
          : [logo, const SizedBox(width: 6), body],
    );
  }
}

class _TeamLogo extends StatelessWidget {
  const _TeamLogo({required this.team, required this.isBatting});
  final TeamInfo team;
  final bool isBatting;
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
          colors: [Color(0xFF252525), Color(0xFF050505)],
        ),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isBatting
              ? const Color(0xFFE53935)
              : const Color(0x33FFFFFF),
          width: isBatting ? 1 : 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
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
        child: Text(
          s,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      );
}

class _VsChip extends StatelessWidget {
  const _VsChip();
  @override
  Widget build(BuildContext context) => const Text(
        'VS',
        style: TextStyle(
          color: Color(0xFFFFB300),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
          height: 1,
        ),
      );
}

class _Pipe extends StatelessWidget {
  const _Pipe();
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 22,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x00FFFFFF),
              Color(0x33FFFFFF),
              Color(0x00FFFFFF),
            ],
          ),
        ),
      );
}

// ─── Mini player tile (compact, fits inline) ─────────────────────────────────

class _MiniPlayer extends StatelessWidget {
  const _MiniPlayer({
    required this.player,
    required this.primary,
    required this.label,
    required this.accent,
  });
  final PlayerInfo player;
  final String primary;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: accent,
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            height: 1,
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _short(player.name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                primary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CrrChip extends StatelessWidget {
  const _CrrChip({required this.current});
  final CurrentInnings current;
  @override
  Widget build(BuildContext context) {
    final crr = current.overs > 0 ? current.runs / current.overs : 0.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'CRR',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 7,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          crr.toStringAsFixed(2),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

// ─── LIVE dot (pulsing) ──────────────────────────────────────────────────────

class _LiveDot extends StatefulWidget {
  const _LiveDot();
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: const Color(0xFFE53935),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE53935).withAlpha(((_c.value) * 180).round()),
              blurRadius: 5 + 3 * _c.value,
              spreadRadius: 1 * _c.value,
            ),
          ],
        ),
      ),
    );
  }
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
                padding: const EdgeInsets.only(left: 2),
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
      bg = ball.runs == 0
          ? const Color(0x18FFFFFF)
          : const Color(0x33FFFFFF);
      label = '${ball.runs}';
    }
    return Container(
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(2.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 9,
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
        borderRadius: BorderRadius.circular(2.5),
      ),
      child: Text(
        'NEED ${chase.runsNeeded}',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
          height: 1,
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

InningsSummary? _inningsForTeam(OverlayTick? tick, String side) {
  if (tick == null) return null;
  for (final i in tick.inningsSummary) {
    if (i.battingTeam == side) return i;
  }
  return null;
}

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
