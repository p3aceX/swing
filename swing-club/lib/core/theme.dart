import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const deepBlue = Color(0xFF0057C8);
  static const deepNavy = Color(0xFF071B3D);
  static const ivory = Color(0xFFF4F2EB);
  static const white = Color(0xFFFFFFFF);
  static const darkBg = Color(0xFF0F1219);
  static const darkSurface = Color(0xFF171C26);
  static const darkText = Color(0xFFE8ECF7);
  static const darkMuted = Color(0xFF98A2B3);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ivory,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),
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
      titleTextStyle: GoogleFonts.plusJakartaSans(
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
      fillColor: const Color(0xFFECEAE3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
      hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: white,
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
    textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6EA8FF),
      onPrimary: Color(0xFF091A3A),
      secondary: Color(0xFF94B8FF),
      onSecondary: Color(0xFF0B1A35),
      surface: darkSurface,
      onSurface: darkText,
      error: Color(0xFFFF6B6B),
      onError: Colors.black,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: darkText,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: darkText,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2A3140),
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
        borderSide: const BorderSide(color: Color(0xFF6EA8FF), width: 1.5),
      ),
      filled: true,
      fillColor: const Color(0xFF202735),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: const TextStyle(color: darkMuted, fontWeight: FontWeight.w500),
      hintStyle: const TextStyle(color: darkMuted, fontWeight: FontWeight.w400),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: darkSurface,
      indicatorColor: Color(0xFF263551),
      elevation: 0,
      height: 64,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6EA8FF),
        foregroundColor: const Color(0xFF091A3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: const Size(double.infinity, 56),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
      backgroundColor: const Color(0xFF222A38),
      labelStyle: const TextStyle(color: darkText),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF6EA8FF),
      foregroundColor: Color(0xFF091A3A),
      elevation: 0,
    ),
    tabBarTheme: const TabBarThemeData(
      indicatorColor: Color(0xFF6EA8FF),
      labelColor: Color(0xFF6EA8FF),
      unselectedLabelColor: darkMuted,
      dividerColor: Color(0xFF2A3140),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF1F2633),
      contentTextStyle: const TextStyle(color: darkText),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
