import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_host_core/flutter_host_core.dart';

import '../../features/profile/domain/rank_visual_theme.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData darkTheme([RankVisualTheme? rankTheme]) =>
      _build(Brightness.dark, rankTheme ?? resolveRankVisualTheme(null));
  static ThemeData lightTheme([RankVisualTheme? rankTheme]) =>
      _build(Brightness.light, rankTheme ?? resolveRankVisualTheme(null));

  static ThemeData _build(Brightness brightness, RankVisualTheme rankTheme) {
    final isDark = brightness == Brightness.dark;

    // ── Rank tint seeds ───────────────────────────────────────────────────────
    final rankSeed = isDark ? rankTheme.primary : rankTheme.secondary;

    // ── Dark palette — deep navy base ──────────────────────────────────────────
    final bg$dark   = const Color(0xFF071B3D); // Brand Navy
    final surf$dark = const Color(0xFF0A234D); // Slightly lighter navy
    final card$dark = Color.lerp(const Color(0xFF0D2B59), rankSeed, 0.05)!;
    final stroke$dark = Color.lerp(const Color(0xFF1A3D66), rankSeed, 0.15)!;
    final panel$dark = Color.lerp(const Color(0xFF0F2E52), rankSeed, 0.05)!;

    // ── Light palette — ivory base ────────────────────────────────────────────
    final bg$light   = const Color(0xFFF4F2EB); // Brand Ivory
    final surf$light = const Color(0xFFFFFFFF); // White highlights
    final card$light = const Color(0xFFFFFFFF);
    final stroke$light = Color.lerp(const Color(0xFFE5E2D9), rankSeed, 0.12)!;
    final panel$light  = Color.lerp(const Color(0xFFF9F8F5), rankSeed, 0.05)!;

    final bg     = isDark ? bg$dark     : bg$light;
    final surf   = isDark ? surf$dark   : surf$light;
    final card   = isDark ? card$dark   : card$light;
    final stroke = isDark ? stroke$dark : stroke$light;
    final panel  = isDark ? panel$dark  : panel$light;

    final fg = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF071B3D); // Brand Navy for light text
    final fgSub = isDark
        ? Color.lerp(const Color(0xFFB0BCC7), rankTheme.primary, 0.12)!
        : Color.lerp(const Color(0xFF5C6E82), rankTheme.secondary, 0.15)!;

    // Brand Palette Overrides
    final success = const Color(0xFF72C86A); // Field green
    final warn = const Color(0xFFFF8A00);    // Orange accent
    final danger = const Color(0xFFD9281E);  // Cricket ball red
    final gold = const Color(0xFF8BD622);    // Sport green accent (per instructions)
    final sky = const Color(0xFF00A8F5);     // Electric blue
    final match = const Color(0xFF18C8E8);   // Fresh cyan

    // Base Brand Blue Accent
    final brandBlue = const Color(0xFF0057C8);
    final accent = isDark ? Color.lerp(brandBlue, rankTheme.primary, 0.4)! : Color.lerp(brandBlue, rankTheme.secondary, 0.3)!;
    final accentBg = accent.withValues(alpha: isDark ? 0.15 : 0.12);

    // CTA bg is brand blue or rank accent.
    final ctaBg = accent;
    final ctaFg = Colors.white;

    final palette = SwingPalette(
      bg: bg,
      surf: surf,
      cardBg: card,
      stroke: stroke,
      panel: panel,
      fg: fg,
      fgSub: fgSub,
      accent: accent,
      accentBg: accentBg,
      success: success,
      warn: warn,
      danger: danger,
      gold: gold,
      sky: sky,
      match: match,
      ctaBg: ctaBg,
      ctaFg: ctaFg,
    );

    final base = isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: accent,
        onPrimary: Colors.white,
        secondary: accent,
        onSecondary: Colors.white,
        error: isDark ? const Color(0xFFCC7A7A) : const Color(0xFFB45252),
        onError: Colors.white,
        surface: surf,
        onSurface: fg,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
                .copyWith(statusBarColor: Colors.transparent)
            : SystemUiOverlayStyle.dark
                .copyWith(statusBarColor: Colors.transparent),
        titleTextStyle: TextStyle(
          color: fg,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: stroke, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? surf : panel,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent, width: 2),
        ),
        hintStyle: TextStyle(color: fgSub, fontSize: 15),
        labelStyle: TextStyle(color: fgSub, fontSize: 15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ctaBg,
          foregroundColor: ctaFg,
          disabledBackgroundColor: ctaBg.withValues(alpha: 0.45),
          disabledForegroundColor: ctaFg.withValues(alpha: 0.6),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isDark ? 12 : 16)),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? fg : accent,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(
              color: isDark ? stroke : accent.withValues(alpha: 0.5),
              width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isDark ? 8 : 14)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.1),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: accent,
        labelColor: accent,
        unselectedLabelColor: fgSub,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent, // Clean SpaceX look
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? surf : panel,
        selectedColor: accentBg,
        side: BorderSide(color: stroke, width: 1),
        labelStyle:
            TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accent : fgSub,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? accent.withValues(alpha: 0.3)
              : stroke,
        ),
      ),
      dividerTheme: DividerThemeData(color: stroke, thickness: 0.5, space: 0),
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        textColor: fg,
        iconColor: fgSub,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      ),
      extensions: <ThemeExtension<dynamic>>[
        palette,
        HostPalette(
          bg: bg,
          surf: surf,
          cardBg: card,
          stroke: stroke,
          panel: panel,
          fg: fg,
          fgSub: fgSub,
          accent: accent,
          accentBg: accentBg,
          ctaBg: ctaBg,
          ctaFg: ctaFg,
          success: success,
          warn: warn,
          danger: danger,
          gold: gold,
          sky: sky,
        ),
      ],
      textTheme: TextTheme(
        displayLarge: TextStyle(
            color: fg,
            fontSize: 48,
            fontWeight: FontWeight.w800,
            letterSpacing: -2),
        displayMedium: TextStyle(
            color: fg,
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.2),
        displaySmall: TextStyle(
            color: fg,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -1),
        headlineMedium: TextStyle(
            color: fg,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5),
        headlineSmall: TextStyle(
            color: fg,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3),
        titleLarge:
            TextStyle(color: fg, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium:
            TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: fg, fontSize: 15, height: 1.5),
        bodyMedium: TextStyle(color: fgSub, fontSize: 13),
        labelLarge: TextStyle(
            color: fg,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3),
        labelSmall: TextStyle(
            color: fgSub,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5),
      ),
    );
  }
}
