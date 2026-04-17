import 'package:flutter/material.dart';

class RankVisualTheme {
  const RankVisualTheme({
    required this.primary,
    required this.secondary,
    required this.deep,
    required this.glow,
    required this.border,
  });

  final Color primary;
  final Color secondary;
  final Color deep;
  final Color glow;
  final Color border;
}

RankVisualTheme resolveRankVisualTheme(String? rank) {
  switch ((rank ?? '').trim().toLowerCase()) {
    case 'rookie':
      return const RankVisualTheme(
        primary: Color(0xFFD8DDE3),
        secondary: Color(0xFF98A1AB),
        deep: Color(0xFF050608),
        glow: Color(0xFFF2F4F7),
        border: Color(0xFFBBC3CC),
      );
    case 'striker':
      return const RankVisualTheme(
        primary: Color(0xFF76E39E),
        secondary: Color(0xFF2FA860),
        deep: Color(0xFF0C1712),
        glow: Color(0xFF9FF0BC),
        border: Color(0xFF63D488),
      );
    case 'vanguard':
      return const RankVisualTheme(
        primary: Color(0xFF6EA6FF),
        secondary: Color(0xFF2F63D4),
        deep: Color(0xFF0C1422),
        glow: Color(0xFF99BEFF),
        border: Color(0xFF5A8FF2),
      );
    case 'phantom':
      return const RankVisualTheme(
        primary: Color(0xFFB06BFF),
        secondary: Color(0xFF7A3CDE),
        deep: Color(0xFF160E25),
        glow: Color(0xFFC79BFF),
        border: Color(0xFF9A5BEE),
      );
    case 'dominion':
      return const RankVisualTheme(
        primary: Color(0xFFF0B25A),
        secondary: Color(0xFFC97924),
        deep: Color(0xFF1D140C),
        glow: Color(0xFFFFD090),
        border: Color(0xFFE39A49),
      );
    case 'ascendant':
      return const RankVisualTheme(
        primary: Color(0xFF86F0FF),
        secondary: Color(0xFF39C7DA),
        deep: Color(0xFF0B1A20),
        glow: Color(0xFFB6F7FF),
        border: Color(0xFF67E0F0),
      );
    case 'immortal':
      return const RankVisualTheme(
        primary: Color(0xFFF05DBD),
        secondary: Color(0xFFB8338C),
        deep: Color(0xFF1E0D19),
        glow: Color(0xFFFF92D7),
        border: Color(0xFFE14DAE),
      );
    case 'apex':
      return const RankVisualTheme(
        primary: Color(0xFFF3E1A2),
        secondary: Color(0xFFB88C2C),
        deep: Color(0xFF17140C),
        glow: Color(0xFFFFF1C7),
        border: Color(0xFFD6B45B),
      );
    default:
      return const RankVisualTheme(
        primary: Color(0xFFD8DDE3),
        secondary: Color(0xFF98A1AB),
        deep: Color(0xFF050608),
        glow: Color(0xFFF2F4F7),
        border: Color(0xFFBBC3CC),
      );
  }
}
