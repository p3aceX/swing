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

    // Titanium & Chrome Palette
    // High-end masculine aesthetic with deep blacks and metallic silvers.
    const Color bg$dark = Color(0xFF050505); // Pitch Black
    const Color surf$dark = Color(0xFF121212); // Charcoal
    const Color card$dark = Color(0xFF181818);
    const Color stroke$dark = Color(0xFF2A2A2A);
    const Color panel$dark = Color(0xFF1F1F1F);

    const Color bg$light = Color(0xFFEEF1F5);    // Slate-tinted bg so cards lift off
    const Color surf$light = Color(0xFFFFFFFF);  // Sheets, drawers — pure white
    const Color card$light = Color(0xFFFFFFFF);  // Cards pop against the bg
    const Color stroke$light = Color(0xFFB8C2CC); // Visible borders and dividers
    const Color panel$light = Color(0xFFDDE2E9); // Tab bar bg, grouped sections

    final bg = isDark ? bg$dark : bg$light;
    final surf = isDark ? surf$dark : surf$light;
    final card = isDark ? card$dark : card$light;
    final stroke = isDark ? stroke$dark : stroke$light;
    final panel = isDark ? panel$dark : panel$light;

    final fg = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF0E1114);
    final fgSub = isDark ? const Color(0xFF888888) : const Color(0xFF52606D);

    // Primary Identity: Liquid Silver / Platinum
    final accent = isDark ? const Color(0xFFE5E4E2) : rankTheme.secondary;
    final accentBg =
        isDark ? const Color(0x1AFFFFFF) : accent.withValues(alpha: 0.14);
    final success = isDark ? const Color(0xFF00FF95) : const Color(0xFF2F7A52);
    final warn = isDark ? const Color(0xFFFFB347) : const Color(0xFFAF7A2A);
    final danger = isDark ? const Color(0xFFFF5252) : const Color(0xFFB45252);
    final gold = isDark ? const Color(0xFFD4AF37) : const Color(0xFFC8922F);
    final sky = isDark ? const Color(0xFF4A90E2) : const Color(0xFF43698F);
    final match = isDark ? const Color(0xFFC0C0C0) : const Color(0xFF357ABD);

    // Dark-on-light CTAs in light mode; platinum on dark.
    final ctaBg = isDark ? accent : const Color(0xFF0A0A0A);
    final ctaFg = isDark ? const Color(0xFF050505) : Colors.white;

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
        elevation: isDark ? 0 : 2.5,
        shadowColor:
            isDark ? Colors.transparent : Colors.black.withValues(alpha: 0.10),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: stroke),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? surf : card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: TextStyle(color: fgSub, fontSize: 14),
        labelStyle: TextStyle(color: fgSub, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ctaBg,
          foregroundColor: ctaFg,
          disabledBackgroundColor: ctaBg.withValues(alpha: 0.55),
          disabledForegroundColor: ctaFg.withValues(alpha: 0.75),
          minimumSize: const Size.fromHeight(48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: isDark ? 0 : 2,
          shadowColor: isDark ? Colors.transparent : ctaBg.withValues(alpha: 0.3),
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          minimumSize: const Size.fromHeight(44),
          side: BorderSide(color: isDark ? stroke : const Color(0xFF8E9BAA), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        backgroundColor: surf, // Use semi-transparent surf for glass effect
        selectedColor: accentBg,
        side: BorderSide(color: stroke),
        labelStyle:
            TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
