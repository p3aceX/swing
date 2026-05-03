import 'package:flutter/material.dart';

class AppTheme {
  static const deepBlue = Color(0xFF0057C8);
  static const deepNavy = Color(0xFF071B3D);
  static const ivory = Color(0xFFF4F2EB);
  static const white = Color(0xFFFFFFFF);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ivory,
    colorScheme: const ColorScheme.light(
      primary: deepBlue,
      onPrimary: white,
      surface: ivory,
      onSurface: deepNavy,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ivory,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: deepNavy,
      titleTextStyle: TextStyle(
        color: deepNavy,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0DED6),
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        backgroundColor: deepBlue,
        foregroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 52),
        elevation: 0,
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
