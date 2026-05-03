import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const deepBlue = Color(0xFF0057C8);
  static const deepNavy = Color(0xFF071B3D);
  static const ivory = Color(0xFFF4F2EB);
  static const white = Color(0xFFFFFFFF);

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
      fillColor: const Color(0xFFF0F0F0),
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
}
