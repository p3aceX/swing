import 'package:flutter/material.dart';

/// Static constants based on the brand palette.
class AppColors {
  AppColors._();

  // Primary Palette
  static const ivory = Color(0xFFF4F2EB);    // Background / base cream
  static const navy = Color(0xFF071B3D);     // Dark outline / text
  static const brandBlue = Color(0xFF0057C8); // Primary brand blue
  static const electricBlue = Color(0xFF00A8F5); // Bright blue highlight
  static const cyan = Color(0xFF18C8E8);     // Cyan accent
  static const grassGreen = Color(0xFF72C86A); // Field green
  static const limeGreen = Color(0xFF8BD622); // Sport green accent
  static const energyOrange = Color(0xFFFF8A00); // Orange accent
  static const actionRed = Color(0xFFD9281E); // Cricket ball red
  static const white = Color(0xFFFFFFFF);    // White highlight

  // Deprecated / Legacy aliases (mapped to new palette for safety)
  static const background = ivory;
  static const primary = navy;
  static const surfaceDark = Color(0xFF051229); // Derived from navy
  static const border = Color(0x1A071B3D);      // Navy with 10% opacity
  static const textPrimary = navy;
  static const textSecondary = Color(0x99071B3D); // Navy with 60% opacity
  static const accent = brandBlue;
  static const gold = energyOrange;
  static const green = grassGreen;
  static const blue = electricBlue;
  static const warning = energyOrange;
  static const danger = actionRed;
  static const match = electricBlue;
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
    required this.ctaBg,
    required this.ctaFg,
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
  final Color ctaBg;
  final Color ctaFg;

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
    Color? ctaBg,
    Color? ctaFg,
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
      ctaBg: ctaBg ?? this.ctaBg,
      ctaFg: ctaFg ?? this.ctaFg,
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
      ctaBg: Color.lerp(ctaBg, other.ctaBg, t)!,
      ctaFg: Color.lerp(ctaFg, other.ctaFg, t)!,
    );
  }
}

/// Theme-aware color extension – use in all redesigned screens.
extension SwingColors on BuildContext {
  SwingPalette get _palette =>
      Theme.of(this).extension<SwingPalette>() ??
      const SwingPalette(
        bg: AppColors.ivory,
        surf: AppColors.white,
        cardBg: AppColors.white,
        stroke: AppColors.border,
        panel: Color(0xFFF9F8F5), // Slightly lighter cream
        fg: AppColors.navy,
        fgSub: AppColors.textSecondary,
        accent: AppColors.brandBlue,
        accentBg: Color(0x1A0057C8),
        success: AppColors.grassGreen,
        warn: AppColors.energyOrange,
        danger: AppColors.actionRed,
        gold: AppColors.limeGreen,
        sky: AppColors.electricBlue,
        match: AppColors.cyan,
        ctaBg: AppColors.brandBlue,
        ctaFg: AppColors.white,
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
  Color get ctaBg => _palette.ctaBg;
  Color get ctaFg => _palette.ctaFg;

  /// True when the current theme is dark — use this to pick dark variants
  /// of hardcoded gradients / decorative colors.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
