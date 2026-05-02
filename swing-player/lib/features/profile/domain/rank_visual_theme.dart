import 'package:flutter/material.dart';

class RankVisualTheme {
  const RankVisualTheme({
    required this.primary,
    required this.secondary,
    required this.deep,
    required this.glow,
    required this.border,
  });

  final Color primary;   // lighter — used in dark mode & on dark surfaces
  final Color secondary; // vivid/deep — used in light mode CTAs & tints
  final Color deep;      // near-black tinted for rank deep backgrounds
  final Color glow;      // very light — glow / highlight
  final Color border;    // mid-tone border
}

RankVisualTheme resolveRankVisualTheme(String? rank) {
  switch ((rank ?? '').trim().toLowerCase()) {
    case 'rookie':
      // Badge: silver-grey metallic
      return const RankVisualTheme(
        primary:   Color(0xFFC2C8CF),
        secondary: Color(0xFF747A82),
        deep:      Color(0xFF0D0D0F),
        glow:      Color(0xFFE3E7EB),
        border:    Color(0xFFAEB6BF),
      );
    case 'striker':
      // Badge: vivid green
      return const RankVisualTheme(
        primary:   Color(0xFF5DCE88),
        secondary: Color(0xFF248049),
        deep:      Color(0xFF04150A),
        glow:      Color(0xFFB0F3C8),
        border:    Color(0xFF48BD76),
      );
    case 'vanguard':
      // Badge: electric blue
      return const RankVisualTheme(
        primary:   Color(0xFF588FF0),
        secondary: Color(0xFF244BA1),
        deep:      Color(0xFF060E22),
        glow:      Color(0xFFABCAFF),
        border:    Color(0xFF457AE3),
      );
    case 'dominion':
      // Badge: orange-amber
      return const RankVisualTheme(
        primary:   Color(0xFFE29E47),
        secondary: Color(0xFF995C1B),
        deep:      Color(0xFF1A0E06),
        glow:      Color(0xFFFFD8A4),
        border:    Color(0xFFD78D37),
      );
    case 'ascendant':
      // Badge: bright cyan
      return const RankVisualTheme(
        primary:   Color(0xFF6BE2F2),
        secondary: Color(0xFF2B97A6),
        deep:      Color(0xFF061518),
        glow:      Color(0xFFC3F8FF),
        border:    Color(0xFF54D5E7),
      );
    case 'immortal':
      // Badge: hot pink / magenta
      return const RankVisualTheme(
        primary:   Color(0xFFDC4EAC),
        secondary: Color(0xFF8C276A),
        deep:      Color(0xFF180810),
        glow:      Color(0xFFFFA6DE),
        border:    Color(0xFFCC429D),
      );
    case 'phantom':
      // Badge: deep violet-purple
      return const RankVisualTheme(
        primary:   Color(0xFF9D5BF3),
        secondary: Color(0xFF5D2EA9),
        deep:      Color(0xFF0D0618),
        glow:      Color(0xFFD1ADFF),
        border:    Color(0xFF8D4CEA),
      );
    case 'apex':
      // Badge: rich gold
      return const RankVisualTheme(
        primary:   Color(0xFFDEC379),
        secondary: Color(0xFF8C6A21),
        deep:      Color(0xFF18140A),
        glow:      Color(0xFFFFF4D1),
        border:    Color(0xFFCDAA55),
      );
    default:
      // Unranked — neutral indigo, no badge clash
      return const RankVisualTheme(
        primary:   Color(0xFF818CF8),
        secondary: Color(0xFF4338CA),
        deep:      Color(0xFF08081A),
        glow:      Color(0xFFC7D2FE),
        border:    Color(0xFF6366F1),
      );
  }
}
