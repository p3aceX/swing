import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  APEX Design System — Next-gen mission control aesthetic
// ─────────────────────────────────────────────────────────────────────────────

abstract final class ApexColors {
  static const background  = Color(0xFF080A0F);
  static const surface     = Color(0xFF0F1219);
  static const surfaceHigh = Color(0xFF161A24);
  static const border      = Color(0x14FFFFFF); // white 8%
  static const borderMid   = Color(0x1FFFFFFF); // white 12%

  static const textPrimary = Color(0xFFF0F2F8);
  static const textMuted   = Color(0xFF5A6478);
  static const textDim     = Color(0xFF2E3547);

  static const accentAim      = Color(0xFF3B8BEB);
  static const accentProgress = Color(0xFF2DB86A);
  static const accentEvaluate = Color(0xFFF5A623);
  static const accentXlerate  = Color(0xFFE8522A);

  static const statusOnTrack    = Color(0xFF2DB86A);
  static const statusSlightlyOff = Color(0xFFF5A623);
  static const statusAtRisk     = Color(0xFFE87A3A);
  static const statusDeviated   = Color(0xFFE8522A);

  static const shimmerBase      = Color(0xFF141820);
  static const shimmerHighlight = Color(0xFF1C2230);

  static const gridLine = Color(0xFF0D1018);
}

abstract final class ApexTextStyles {
  static const headingLarge = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w700,
    color: ApexColors.textPrimary, letterSpacing: -0.5,
  );
  static const headingMedium = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w600,
    color: ApexColors.textPrimary, letterSpacing: -0.3,
  );
  static const headingSmall = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600,
    color: ApexColors.textPrimary,
  );
  static const labelMuted = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: ApexColors.textMuted,
  );
  static const kpiNumber = TextStyle(
    fontSize: 40, fontWeight: FontWeight.w800,
    color: ApexColors.textPrimary, letterSpacing: -2.0,
    height: 1.0,
  );
  static const bodyText = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: ApexColors.textPrimary, height: 1.5,
  );
  static const labelCaps = TextStyle(
    fontSize: 9, fontWeight: FontWeight.w800,
    color: ApexColors.textMuted, letterSpacing: 1.8,
  );
  static const mono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 13, fontWeight: FontWeight.w600,
    color: ApexColors.textPrimary,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  ApexCard — glass surface. Supports colored left accent WITHOUT crashing.
//  Flutter requires uniform border colors when combined with borderRadius.
//  We use a Stack overlay to paint the left accent separately.
// ─────────────────────────────────────────────────────────────────────────────

class ApexCard extends StatelessWidget {
  const ApexCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.leftAccentColor,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? leftAccentColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? ApexColors.surface;

    final content = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ApexColors.border, width: 0.5),
      ),
      child: Padding(
        padding: leftAccentColor != null
            ? padding.copyWith(left: (padding.left + 3).clamp(0, 999).toDouble())
            : padding,
        child: child,
      ),
    );

    if (leftAccentColor == null) return content;

    // Stack the left accent bar on top without touching border colors
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          content,
          Positioned(
            left: 0, top: 0, bottom: 0,
            child: Container(
              width: 3,
              color: leftAccentColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Status badge
// ─────────────────────────────────────────────────────────────────────────────

class ApexStatusBadge extends StatelessWidget {
  const ApexStatusBadge({super.key, required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 9,
              fontWeight: FontWeight.w800, letterSpacing: 1.2)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Blinking status dot
// ─────────────────────────────────────────────────────────────────────────────

class ApexLiveDot extends StatefulWidget {
  const ApexLiveDot({super.key, this.color = ApexColors.accentProgress, this.size = 6});
  final Color color;
  final double size;

  @override
  State<ApexLiveDot> createState() => _ApexLiveDotState();
}

class _ApexLiveDotState extends State<ApexLiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.3 + 0.7 * _anim.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shimmer placeholder
// ─────────────────────────────────────────────────────────────────────────────

class ApexShimmerBox extends StatefulWidget {
  const ApexShimmerBox({super.key, this.width, this.height = 16, this.radius = 8});
  final double? width;
  final double height, radius;

  @override
  State<ApexShimmerBox> createState() => _ApexShimmerBoxState();
}

class _ApexShimmerBoxState extends State<ApexShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          color: Color.lerp(
              ApexColors.shimmerBase, ApexColors.shimmerHighlight, _anim.value),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Section divider row
// ─────────────────────────────────────────────────────────────────────────────

class ApexSectionHeader extends StatelessWidget {
  const ApexSectionHeader({super.key, required this.label, this.trailing});
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label, style: ApexTextStyles.labelCaps),
      const SizedBox(width: 10),
      Expanded(
        child: Container(height: 0.5, color: ApexColors.border),
      ),
      if (trailing != null) ...[
        const SizedBox(width: 10),
        trailing!,
      ],
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Error widget
// ─────────────────────────────────────────────────────────────────────────────

class ApexErrorWidget extends StatelessWidget {
  const ApexErrorWidget({super.key, required this.onRetry, this.message});
  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.warning_amber_rounded,
            color: ApexColors.textDim, size: 28),
        const SizedBox(height: 12),
        Text(message ?? 'Sync failed',
            style: ApexTextStyles.labelMuted, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: ApexColors.borderMid),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('RETRY',
                style: TextStyle(
                    color: ApexColors.textPrimary, fontSize: 10,
                    fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  AIM not set empty state
// ─────────────────────────────────────────────────────────────────────────────

class ApexAimNotSetWidget extends StatelessWidget {
  const ApexAimNotSetWidget({super.key, required this.onSetMission});
  final VoidCallback? onSetMission;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ApexColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('NO MISSION\nDEFINED.',
                style: const TextStyle(
                  color: ApexColors.textPrimary, fontSize: 36,
                  fontWeight: FontWeight.w900, letterSpacing: -2, height: 0.95,
                )),
            const SizedBox(height: 16),
            const Text(
              'Define your AIM first to unlock\nthis section of the system.',
              style: TextStyle(
                  color: ApexColors.textMuted, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 32),
            if (onSetMission != null)
              GestureDetector(
                onTap: onSetMission,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('SET MISSION',
                      style: TextStyle(
                          color: ApexColors.accentAim, fontSize: 12,
                          fontWeight: FontWeight.w800, letterSpacing: 2)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded,
                      color: ApexColors.accentAim, size: 16),
                ]),
              ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Thin horizontal rule
// ─────────────────────────────────────────────────────────────────────────────

class ApexRule extends StatelessWidget {
  const ApexRule({super.key});
  @override
  Widget build(BuildContext context) =>
      Container(height: 0.5, color: ApexColors.border);
}
