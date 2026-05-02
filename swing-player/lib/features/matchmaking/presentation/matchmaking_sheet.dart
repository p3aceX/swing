import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum MatchType { team, individual }

enum MatchTiming {
  morning('Morning', '6am – 12pm', Icons.wb_sunny_outlined),
  afternoon('Afternoon', '12pm – 4pm', Icons.wb_cloudy_outlined),
  evening('Evening', '4pm – 8pm', Icons.wb_twilight_outlined),
  night('Night', '8pm onwards', Icons.nights_stay_outlined);

  const MatchTiming(this.label, this.range, this.icon);
  final String label;
  final String range;
  final IconData icon;
}

enum _Step { timing, finding, matched }

void showMatchmakingSheet(BuildContext context, MatchType type) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _MatchmakingSheet(type: type),
  );
}

class _MatchmakingSheet extends StatefulWidget {
  const _MatchmakingSheet({required this.type});
  final MatchType type;

  @override
  State<_MatchmakingSheet> createState() => _MatchmakingSheetState();
}

class _MatchmakingSheetState extends State<_MatchmakingSheet> {
  _Step _step = _Step.timing;
  MatchTiming? _timing;
  MatchTiming? _nudge;

  void _selectTiming(MatchTiming t) {
    setState(() {
      _timing = t;
      _step = _Step.finding;
      // In production: fire queue API, listen for nudge from server
      _nudge = t == MatchTiming.evening ? MatchTiming.night : null;
    });
  }

  void _switchToNudge(MatchTiming t) {
    setState(() {
      _timing = t;
      _nudge = null;
      _step = _Step.matched;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: switch (_step) {
          _Step.timing => _TimingStep(
              key: const ValueKey('timing'),
              type: widget.type,
              onSelect: _selectTiming,
            ),
          _Step.finding => _FindingStep(
              key: const ValueKey('finding'),
              type: widget.type,
              timing: _timing!,
              nudge: _nudge,
              onSwitch: _switchToNudge,
            ),
          _Step.matched => _MatchedStep(
              key: const ValueKey('matched'),
              timing: _timing!,
              onConfirm: () => Navigator.pop(context),
            ),
        },
      ),
    );
  }
}

// ── Step 1: When do you want to play? ────────────────────────────────────────

class _TimingStep extends StatelessWidget {
  const _TimingStep({super.key, required this.type, required this.onSelect});
  final MatchType type;
  final ValueChanged<MatchTiming> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Handle(),
          const SizedBox(height: 24),
          Text(
            type == MatchType.team ? 'Team Match' : 'Play Solo',
            style: TextStyle(
              color: context.accent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'When do you want to play?',
            style: TextStyle(
              color: context.fg,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 28),
          ...MatchTiming.values.map(
            (t) => _TimingRow(timing: t, onTap: () => onSelect(t)),
          ),
        ],
      ),
    );
  }
}

class _TimingRow extends StatelessWidget {
  const _TimingRow({required this.timing, required this.onTap});
  final MatchTiming timing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(timing.icon, color: context.fg, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                timing.label,
                style: TextStyle(
                  color: context.fg,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Text(
              timing.range,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                color: context.fgSub.withValues(alpha: 0.4), size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Step 2: Finding opponent ──────────────────────────────────────────────────

class _FindingStep extends StatelessWidget {
  const _FindingStep({
    super.key,
    required this.type,
    required this.timing,
    required this.nudge,
    required this.onSwitch,
  });
  final MatchType type;
  final MatchTiming timing;
  final MatchTiming? nudge;
  final ValueChanged<MatchTiming> onSwitch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Handle(),
          const SizedBox(height: 36),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.accent,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Finding opponent...',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              timing.label,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (nudge != null) ...[
            const SizedBox(height: 36),
            Container(height: 1, color: context.stroke.withValues(alpha: 0.4)),
            const SizedBox(height: 28),
            Text(
              'Team waiting for ${nudge!.label}',
              style: TextStyle(
                color: context.fg,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Switch and match instantly',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => onSwitch(nudge!),
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Play ${nudge!.label}',
                    style: TextStyle(
                      color: context.accent,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded,
                      color: context.accent, size: 16),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ── Step 3: Match confirmed ───────────────────────────────────────────────────

class _MatchedStep extends StatelessWidget {
  const _MatchedStep({super.key, required this.timing, required this.onConfirm});
  final MatchTiming timing;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Handle(),
          const SizedBox(height: 24),
          Text(
            'MATCH FOUND',
            style: TextStyle(
              color: context.accent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cheetah Cricket Ground',
            style: TextStyle(
              color: context.fg,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Koramangala  ·  ${timing.label}',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 36),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹900',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'your share  ·  ground fee ÷ 2',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: GestureDetector(
              onTap: onConfirm,
              child: Container(
                decoration: BoxDecoration(
                  color: context.ctaBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Confirm & Pay  ₹900',
                  style: TextStyle(
                    color: context.ctaFg,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Opponent has 15 min to confirm',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: context.stroke.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
