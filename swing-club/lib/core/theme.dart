import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const deepBlue = Color(0xFF0057C8);
  static const deepNavy = Color(0xFF071B3D);
  static const ivory = Color(0xFFF6F5F3);
  static const white = Color(0xFFFFFFFF);
  static const lightStroke = Color(0xFFE0DED6);
  static const lightMuted = Color(0xFF6B6F7A);
  static const darkBg = Color(0xFF0C0C0D);
  static const darkSurface = Color(0xFF161618);
  static const darkStroke = Color(0xFF27272A);
  static const darkText = Color(0xFFF4F4F5);
  static const darkMuted = Color(0xFF71717A);

  static const _lightPalette = HostPalette(
    bg: ivory,
    surf: ivory,
    cardBg: white,
    stroke: lightStroke,
    panel: Color(0xFFEEEDEB),
    fg: deepNavy,
    fgSub: lightMuted,
    accent: deepBlue,
    accentBg: Color(0x1A0057C8),
    ctaBg: Colors.black,
    ctaFg: white,
    // Map success → brand accent so LIVE/won badges follow the app palette
    // instead of the shared default green.
    success: deepBlue,
    warn: Color(0xFFF59E0B),
    danger: Color(0xFFE11D48),
    gold: Color(0xFFE0B94B),
    sky: deepBlue,
  );

  static const _darkPalette = HostPalette(
    bg: darkBg,
    surf: darkSurface,
    cardBg: darkSurface,
    stroke: darkStroke,
    panel: Color(0xFF1C1C1F),
    fg: darkText,
    fgSub: darkMuted,
    accent: Color(0xFF60A5FA),
    accentBg: Color(0x2060A5FA),
    ctaBg: Color(0xFF60A5FA),
    ctaFg: Color(0xFF0C0C0D),
    success: Color(0xFF4ADE80),
    warn: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
    gold: Color(0xFFE0B94B),
    sky: Color(0xFF60A5FA),
  );

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ivory,
    cardColor: white,
    extensions: const [_lightPalette],
    textTheme: GoogleFonts.interTextTheme(),
    colorScheme: const ColorScheme.light(
      primary: deepBlue,
      onPrimary: white,
      surface: ivory,
      onSurface: deepNavy,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ivory,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Colors.black,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0DED6),
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
      filled: true,
      fillColor: const Color(0xFFEEEDEB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
      hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: ivory,
      indicatorColor: Color(0xFFE8F0FD),
      elevation: 0,
      height: 64,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: const Size(double.infinity, 56),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: deepBlue,
      foregroundColor: white,
      elevation: 0,
    ),
    tabBarTheme: const TabBarThemeData(
      indicatorColor: deepBlue,
      labelColor: deepBlue,
      unselectedLabelColor: Colors.grey,
      dividerColor: Color(0xFFE0DED6),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    cardColor: darkSurface,
    extensions: const [_darkPalette],
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF60A5FA),
      onPrimary: Color(0xFF0C0C0D),
      secondary: Color(0xFF93C5FD),
      onSecondary: Color(0xFF0C0C0D),
      surface: darkSurface,
      onSurface: darkText,
      error: Color(0xFFF87171),
      onError: Colors.black,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: darkText,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        color: darkText,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: darkStroke,
      thickness: 0.5,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF60A5FA), width: 1.5),
      ),
      filled: true,
      fillColor: const Color(0xFF1C1C1F),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: const TextStyle(color: darkMuted, fontWeight: FontWeight.w500),
      hintStyle: const TextStyle(color: darkMuted, fontWeight: FontWeight.w400),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: darkBg,
      indicatorColor: Color(0xFF1E3A5F),
      elevation: 0,
      height: 64,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF60A5FA),
        foregroundColor: const Color(0xFF0C0C0D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: const Size(double.infinity, 56),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
      backgroundColor: const Color(0xFF1C1C1F),
      labelStyle: const TextStyle(color: darkText),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF60A5FA),
      foregroundColor: Color(0xFF0C0C0D),
      elevation: 0,
    ),
    tabBarTheme: const TabBarThemeData(
      indicatorColor: Color(0xFF60A5FA),
      labelColor: Color(0xFF60A5FA),
      unselectedLabelColor: darkMuted,
      dividerColor: darkStroke,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF1C1C1F),
      contentTextStyle: const TextStyle(color: darkText),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
