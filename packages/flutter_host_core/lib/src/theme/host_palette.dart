import 'package:flutter/material.dart';

/// Shared color palette registered as a ThemeExtension.
/// Each host app registers this in its ProviderScope/theme so that all
/// shared widgets from flutter_host_core get the correct semantic colors.
@immutable
class HostPalette extends ThemeExtension<HostPalette> {
  const HostPalette({
    required this.bg,
    required this.surf,
    required this.cardBg,
    required this.stroke,
    required this.panel,
    required this.fg,
    required this.fgSub,
    required this.accent,
    required this.accentBg,
    required this.ctaBg,
    required this.ctaFg,
    required this.success,
    required this.warn,
    required this.danger,
    required this.gold,
    required this.sky,
  });

  final Color bg;
  final Color surf;
  final Color cardBg;
  final Color stroke;
  final Color panel;
  final Color fg;
  final Color fgSub;
  final Color accent;
  final Color accentBg;
  final Color ctaBg;
  final Color ctaFg;
  final Color success;
  final Color warn;
  final Color danger;
  final Color gold;
  final Color sky;

  @override
  HostPalette copyWith({
    Color? bg,
    Color? surf,
    Color? cardBg,
    Color? stroke,
    Color? panel,
    Color? fg,
    Color? fgSub,
    Color? accent,
    Color? accentBg,
    Color? ctaBg,
    Color? ctaFg,
    Color? success,
    Color? warn,
    Color? danger,
    Color? gold,
    Color? sky,
  }) {
    return HostPalette(
      bg: bg ?? this.bg,
      surf: surf ?? this.surf,
      cardBg: cardBg ?? this.cardBg,
      stroke: stroke ?? this.stroke,
      panel: panel ?? this.panel,
      fg: fg ?? this.fg,
      fgSub: fgSub ?? this.fgSub,
      accent: accent ?? this.accent,
      accentBg: accentBg ?? this.accentBg,
      ctaBg: ctaBg ?? this.ctaBg,
      ctaFg: ctaFg ?? this.ctaFg,
      success: success ?? this.success,
      warn: warn ?? this.warn,
      danger: danger ?? this.danger,
      gold: gold ?? this.gold,
      sky: sky ?? this.sky,
    );
  }

  @override
  HostPalette lerp(ThemeExtension<HostPalette>? other, double t) {
    if (other is! HostPalette) return this;
    return HostPalette(
      bg: Color.lerp(bg, other.bg, t)!,
      surf: Color.lerp(surf, other.surf, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      stroke: Color.lerp(stroke, other.stroke, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      fg: Color.lerp(fg, other.fg, t)!,
      fgSub: Color.lerp(fgSub, other.fgSub, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentBg: Color.lerp(accentBg, other.accentBg, t)!,
      ctaBg: Color.lerp(ctaBg, other.ctaBg, t)!,
      ctaFg: Color.lerp(ctaFg, other.ctaFg, t)!,
      success: Color.lerp(success, other.success, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      sky: Color.lerp(sky, other.sky, t)!,
    );
  }
}
