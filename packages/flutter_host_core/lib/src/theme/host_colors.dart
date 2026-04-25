import 'package:flutter/material.dart';

import 'host_palette.dart';

extension HostThemeColors on BuildContext {
  HostPalette? get _p => Theme.of(this).extension<HostPalette>();

  // Every getter tries HostPalette first, falls back to colorScheme so the
  // package still works if a host app hasn't registered HostPalette yet.
  Color get bg => _p?.bg ?? Theme.of(this).scaffoldBackgroundColor;
  Color get surf => _p?.surf ?? Theme.of(this).colorScheme.surface;
  Color get cardBg => _p?.cardBg ?? Theme.of(this).cardColor;
  Color get panel => _p?.panel ?? Theme.of(this).colorScheme.surfaceContainerHighest;
  Color get stroke => _p?.stroke ?? Theme.of(this).dividerColor;
  Color get fg => _p?.fg ?? Theme.of(this).colorScheme.onSurface;
  Color get fgSub => _p?.fgSub ?? Theme.of(this).colorScheme.onSurfaceVariant;
  Color get accent => _p?.accent ?? Theme.of(this).colorScheme.primary;
  Color get accentBg => _p?.accentBg ?? Theme.of(this).colorScheme.primary.withValues(alpha: 0.1);
  Color get ctaBg => _p?.ctaBg ?? Theme.of(this).colorScheme.primary;
  Color get ctaFg => _p?.ctaFg ?? Theme.of(this).colorScheme.onPrimary;
  Color get danger => _p?.danger ?? Theme.of(this).colorScheme.error;
  Color get success => _p?.success ?? const Color(0xFF22C55E);
  Color get warn => _p?.warn ?? const Color(0xFFF59E0B);
  Color get gold => _p?.gold ?? const Color(0xFFE0B94B);
  Color get sky => _p?.sky ?? const Color(0xFF38BDF8);
}
