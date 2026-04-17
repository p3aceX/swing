import 'package:flutter/material.dart';

/// Static constants – kept for auth / live-scoring screens.
class AppColors {
  AppColors._();

  static const background = Color(0xFF050505); // Pitch Black
  static const primary = Color(0xFF121212); // Charcoal
  static const surfaceDark = Color(0xFF1A1A1A); 
  static const border = Color(0xFF2A2A2A);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF888888);
  static const accent = Color(0xFFE5E4E2); // Platinum / Silver
  static const gold = Color(0xFFD4AF37); // Metallic Gold
  static const green = Color(0xFF00FF95);
  static const blue = Color(0xFF4A90E2);
  static const warning = Color(0xFFFFB347);
  static const danger = Color(0xFFFF5252);
  static const match = Color(0xFFC0C0C0); // Chrome Silver

  // Titanium/Chrome depth
  static const glassSurface = Color(0xFF121212); 
  static const glassCard = Color(0xFF181818);
  static const glassBorder = Color(0xFF333333);
  static const glassPanel = Color(0xFF1F1F1F);
}

@immutable
class SwingPalette extends ThemeExtension<SwingPalette> {
  const SwingPalette({
    required this.bg,
    required this.surf,
    required this.cardBg,
    required this.stroke,
    required this.panel,
    required this.fg,
    required this.fgSub,
    required this.accent,
    required this.accentBg,
    required this.success,
    required this.warn,
    required this.danger,
    required this.gold,
    required this.sky,
    required this.match,
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
  final Color success;
  final Color warn;
  final Color danger;
  final Color gold;
  final Color sky;
  final Color match;

  @override
  SwingPalette copyWith({
    Color? bg,
    Color? surf,
    Color? cardBg,
    Color? stroke,
    Color? panel,
    Color? fg,
    Color? fgSub,
    Color? accent,
    Color? accentBg,
    Color? success,
    Color? warn,
    Color? danger,
    Color? gold,
    Color? sky,
    Color? match,
  }) {
    return SwingPalette(
      bg: bg ?? this.bg,
      surf: surf ?? this.surf,
      cardBg: cardBg ?? this.cardBg,
      stroke: stroke ?? this.stroke,
      panel: panel ?? this.panel,
      fg: fg ?? this.fg,
      fgSub: fgSub ?? this.fgSub,
      accent: accent ?? this.accent,
      accentBg: accentBg ?? this.accentBg,
      success: success ?? this.success,
      warn: warn ?? this.warn,
      danger: danger ?? this.danger,
      gold: gold ?? this.gold,
      sky: sky ?? this.sky,
      match: match ?? this.match,
    );
  }

  @override
  SwingPalette lerp(ThemeExtension<SwingPalette>? other, double t) {
    if (other is! SwingPalette) return this;
    return SwingPalette(
      bg: Color.lerp(bg, other.bg, t)!,
      surf: Color.lerp(surf, other.surf, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      stroke: Color.lerp(stroke, other.stroke, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      fg: Color.lerp(fg, other.fg, t)!,
      fgSub: Color.lerp(fgSub, other.fgSub, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentBg: Color.lerp(accentBg, other.accentBg, t)!,
      success: Color.lerp(success, other.success, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      sky: Color.lerp(sky, other.sky, t)!,
      match: Color.lerp(match, other.match, t)!,
    );
  }
}

/// Theme-aware color extension – use in all redesigned screens.
extension SwingColors on BuildContext {
  SwingPalette get _palette =>
      Theme.of(this).extension<SwingPalette>() ??
      const SwingPalette(
        bg: AppColors.background,
        surf: AppColors.primary,
        cardBg: AppColors.surfaceDark,
        stroke: AppColors.border,
        panel: Color(0xFF1F1F1F),
        fg: AppColors.textPrimary,
        fgSub: AppColors.textSecondary,
        accent: AppColors.accent,
        accentBg: Color(0x1AFFFFFF),
        success: AppColors.green,
        warn: AppColors.warning,
        danger: AppColors.danger,
        gold: AppColors.gold,
        sky: AppColors.blue,
        match: AppColors.match,
      );

  Color get bg => _palette.bg;
  Color get surf => _palette.surf;
  Color get cardBg => _palette.cardBg;
  Color get stroke => _palette.stroke;
  Color get panel => _palette.panel;
  Color get fg => _palette.fg;
  Color get fgSub => _palette.fgSub;
  Color get accent => _palette.accent;
  Color get accentBg => _palette.accentBg;
  Color get success => _palette.success;
  Color get warn => _palette.warn;
  Color get danger => _palette.danger;
  Color get gold => _palette.gold;
  Color get sky => _palette.sky;
  Color get match => _palette.match;
}
