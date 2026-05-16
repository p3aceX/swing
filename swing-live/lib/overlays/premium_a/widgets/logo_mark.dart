import 'package:flutter/material.dart';

import '../theme/premium_a_theme.dart';

/// Top-left broadcast logo plate. Renders `assets/logo.png` inside a navy
/// plate with a mustard top hairline (so it reads as a deliberate
/// broadcast graphic instead of a stray image). Persistent — never
/// absorbs taps.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key});

  @override
  Widget build(BuildContext context) {
    return const _BrandPlate(
      asset: 'assets/logo.png',
    );
  }
}

/// Top-right sponsor plate. Mirrors [LogoMark] visually so the two plates
/// frame the broadcast like a TV graphic. Loaded from `assets/sponsor.png`.
class SponsorMark extends StatelessWidget {
  const SponsorMark({super.key});

  @override
  Widget build(BuildContext context) {
    return const _BrandPlate(
      asset: 'assets/sponsor.png',
    );
  }
}

/// Shared brand image — no background plate, no border. Just the asset
/// scaled to a generous height so the logo has presence on the camera
/// feed. Matches the native broadcast_overlay.xml which also drops the
/// plate background and renders the ImageView bare.
class _BrandPlate extends StatelessWidget {
  const _BrandPlate({required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      height: 56,
      fit: BoxFit.contain,
      // Decode straight to ~256px tall so cubic filtering has headroom
      // when the source PNG is rendered into the 1080p encoded frame.
      // Without cacheHeight, the 1MB source is decoded at full res then
      // shader-downscaled, which is slow + visibly blurry.
      cacheHeight: 224,
      filterQuality: FilterQuality.high,
    );
  }
}
