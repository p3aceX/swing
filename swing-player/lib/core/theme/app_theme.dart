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
    // Each rank colors the whole environment — bg, panels, borders all breathe
    // the rank's hue. Light = subtle wash; dark = deep atmospheric tint.
    final rankSeed = isDark ? rankTheme.primary : rankTheme.secondary;

    // ── Dark palette — pure blacks for top/bottom navigation ──────────────────
    final bg$dark   = const Color(0xFF000000);
    final surf$dark = const Color(0xFF000000);
    final card$dark = Color.lerp(const Color(0xFF0A0A0A), rankSeed, 0.04)!;
    final stroke$dark = Color.lerp(const Color(0xFF1A1A1A), rankSeed, 0.15)!;
    final panel$dark = Color.lerp(const Color(0xFF0F0F0F), rankSeed, 0.05)!;

    // ── Light palette — rank-tinted clean whites ──────────────────────────────
    final bg$light   = Color.lerp(const Color(0xFFFFFFFF), rankSeed, 0.04)!;
    final surf$light = Color.lerp(const Color(0xFFFFFFFF), rankSeed, 0.02)!;
    final card$light = const Color(0xFFFFFFFF); // cards stay pure white for contrast
    final stroke$light = Color.lerp(const Color(0xFFE0E0E0), rankSeed, 0.18)!;
    final panel$light  = Color.lerp(const Color(0xFFF2F2F2), rankSeed, 0.07)!;

    final bg     = isDark ? bg$dark     : bg$light;
    final surf   = isDark ? surf$dark   : surf$light;
    final card   = isDark ? card$dark   : card$light;
    final stroke = isDark ? stroke$dark : stroke$light;
    final panel  = isDark ? panel$dark  : panel$light;

    final fg = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF0A0A0A);
    final fgSub = isDark
        ? Color.lerp(const Color(0xFF888888), rankTheme.primary, 0.12)!
        : Color.lerp(const Color(0xFF6B6B80), rankTheme.secondary, 0.15)!;

    // Accent is rank-based in both modes — primary (lighter) for dark, secondary (vivid) for light.
    final accent = isDark ? rankTheme.primary : rankTheme.secondary;
    final accentBg = accent.withValues(alpha: isDark ? 0.15 : 0.12);

    final success = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
    final warn = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
    final danger = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
    final gold = isDark ? const Color(0xFFD4AF37) : const Color(0xFFCA8A04);
    final sky = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
    final match = isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4F46E5);

    // CTA bg is rank accent in both modes. Auto-pick fg by luminance so text always pops.
    final ctaBg = accent;
    final ctaFg = accent.computeLuminance() > 0.45
        ? const Color(0xFF0A0A0A)
        : Colors.white;

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
