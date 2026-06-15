import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Typography + ThemeData for the "Desert Dusk" system.
///
/// Type pairing:
///   • Wordmark / hero    → Rye    (classic wood-type western letterpress)
///   • Headings / numbers → Bitter (warm modern slab serif)
///   • Body / UI          → Inter  (clean, neutral, highly legible)
/// ─────────────────────────────────────────────────────────────────────────

class CType {
  CType._();

  static TextStyle wordmark({double size = 40, Color color = CColors.textHi}) =>
      GoogleFonts.rye(fontSize: size, color: color, letterSpacing: 1.0, height: 1.05);

  static TextStyle display({double size = 34, Color color = CColors.textHi}) =>
      GoogleFonts.bitter(fontSize: size, color: color, fontWeight: FontWeight.w800, height: 1.1);

  static TextStyle heading({double size = 22, Color color = CColors.textHi}) =>
      GoogleFonts.bitter(fontSize: size, color: color, fontWeight: FontWeight.w700, height: 1.2);

  static TextStyle title({double size = 17, Color color = CColors.textHi}) =>
      GoogleFonts.inter(fontSize: size, color: color, fontWeight: FontWeight.w700, height: 1.25);

  static TextStyle body({double size = 15, Color color = CColors.textMid}) =>
      GoogleFonts.inter(fontSize: size, color: color, fontWeight: FontWeight.w500, height: 1.45);

  static TextStyle label({double size = 13, Color color = CColors.textMid}) => GoogleFonts.inter(
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
      height: 1.2);

  static TextStyle button({double size = 16, Color color = CColors.textHi}) =>
      GoogleFonts.inter(fontSize: size, color: color, fontWeight: FontWeight.w800, letterSpacing: 0.4);

  /// Numeric stat readout (tabular figures via slab serif).
  static TextStyle stat({double size = 28, Color color = CColors.textHi}) => GoogleFonts.bitter(
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w800,
      fontFeatures: const [FontFeature.tabularFigures()]);
}

ThemeData buildCowboyTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final scheme = const ColorScheme.dark(
    primary: CColors.primary,
    secondary: CColors.accent,
    surface: CColors.surface,
    error: CColors.danger,
    onPrimary: CColors.textHi,
    onSecondary: CColors.ink,
    onSurface: CColors.textHi,
  );

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: CColors.bgBottom,
    splashColor: CColors.primary.withValues(alpha: 0.12),
    highlightColor: CColors.primary.withValues(alpha: 0.06),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: CColors.textHi,
      displayColor: CColors.textHi,
    ),
    dividerColor: CColors.line,
    iconTheme: const IconThemeData(color: CColors.textMid),
  );
}
