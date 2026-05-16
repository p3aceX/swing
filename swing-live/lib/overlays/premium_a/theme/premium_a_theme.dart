import 'package:flutter/material.dart';

/// Brand tokens for the Premium-A overlay pack.
///
/// Palette draws from English-broadcast cricket (Sky Sports, BBC) rather
/// than the saturated Star Sports look — **midnight navy, bone-white,
/// mustard, burgundy, sage**. Warmer, lower-contrast greys for secondary
/// text. Mustard replaces yellow as the emphasis accent. Crimson is
/// pushed into burgundy (#C42531) for boundaries and live indicators.
class PremiumATheme {
  const PremiumATheme._();

  // ── Surfaces ─────────────────────────────────────────────────────────
  /// Midnight navy, fully opaque. We deliberately drop the glass blur on
  /// Android — BackdropFilter against a constantly-repainting camera
  /// surface flickers hard. Solid navy is broadcast-correct anyway.
  static const Color bgDeep   = Color(0xFF0F1B2D);
  static const Color bgFloor  = Color(0xFF05070D);
  /// Hairline between rows — bone at 10% alpha (visually a faint warm line).
  static const Color hairline = Color(0x1AECE6D7);
  /// 1px top trim — mustard, not gold.
  static const Color topTrim  = Color(0xFFE6B544);

  // ── Text — warmer than the v2 pure-white set ─────────────────────────
  static const Color bone     = Color(0xFFECE6D7); // primary text
  static const Color fgMuted  = Color(0xFF9BA1A8); // labels, secondary
  static const Color fgDim    = Color(0xFF5A6168); // hollow rings, dim

  // ── Accents ──────────────────────────────────────────────────────────
  static const Color mustard   = Color(0xFFE6B544); // emphasis values
  static const Color mustardDim = Color(0xFFB8902E);
  static const Color burgundy  = Color(0xFFC42531); // boundary, wicket, live
  static const Color sage      = Color(0xFF76A85D); // run accent
  static const Color liveDot   = Color(0xFFC42531);

  // ── Gradients ────────────────────────────────────────────────────────
  static const LinearGradient surface = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgDeep, bgFloor],
  );

  // ── Typography — tighter sizes for the v3 compact layout ─────────────
  static const List<Shadow> _scoreShadow = [
    Shadow(color: Color(0xB3000000), blurRadius: 3, offset: Offset(0, 1)),
  ];

  static const TextStyle score = TextStyle(
    color: bone,
    fontSize: 19,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.3,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
    shadows: _scoreShadow,
  );
  static const TextStyle teamCode = TextStyle(
    color: bone,
    fontSize: 13,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.6,
    height: 1.0,
  );
  static const TextStyle overs = TextStyle(
    color: fgMuted,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const TextStyle batterName = TextStyle(
    color: bone,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
    height: 1.0,
  );
  static const TextStyle batterRuns = TextStyle(
    color: bone,
    fontSize: 11,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.3,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const TextStyle metaLabel = TextStyle(
    color: fgDim,
    fontSize: 8.5,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.6,
    height: 1.0,
  );
  static const TextStyle metaValue = TextStyle(
    color: mustard,
    fontSize: 11,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.4,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const TextStyle chasePill = TextStyle(
    color: Color(0xFF0F1B2D),
    fontSize: 10,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.0,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const TextStyle liveTag = TextStyle(
    color: bone,
    fontSize: 9,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.4,
    height: 1.0,
  );
}
