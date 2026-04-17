import 'package:flutter/material.dart';

extension HostThemeColors on BuildContext {
  Color get bg => Theme.of(this).scaffoldBackgroundColor;
  Color get cardBg => Theme.of(this).cardColor;
  Color get panel => Theme.of(this).colorScheme.surfaceContainerHighest;
  Color get stroke => Theme.of(this).dividerColor.withValues(alpha: 0.75);
  Color get fg => Theme.of(this).colorScheme.onSurface;
  Color get fgSub => Theme.of(this).colorScheme.onSurfaceVariant;
  Color get accent => Theme.of(this).colorScheme.primary;
  Color get accentBg => Theme.of(this).colorScheme.primaryContainer;
  Color get danger => Theme.of(this).colorScheme.error;
  Color get gold => const Color(0xFFE0B94B);
}
