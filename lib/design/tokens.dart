import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Cowboy Redesign — Design Tokens
///
/// Theme: "Desert Dusk" — a warm, modern take on the spaghetti-western look.
/// Leather + sand + burnt-orange sun, with a turquoise southwestern accent.
/// All values here are the single source of truth; widgets read these, never
/// hard-coded hex/sizes. When Figma is connected these map 1:1 to design
/// tokens (color/, type/, space/, radius/).
/// ─────────────────────────────────────────────────────────────────────────

/// Color palette. Names are role-based so screens never reference raw swatches.
class CColors {
  CColors._();

  // Brand / primary — burnt desert sun.
  static const Color primary = Color(0xFFE0683A); // terracotta orange
  static const Color primaryBright = Color(0xFFF4843E); // hover / highlight
  static const Color primaryDeep = Color(0xFFB44A22); // pressed

  // Accent — turquoise (southwestern silver-and-stone jewellery).
  static const Color accent = Color(0xFF3FB6A8);
  static const Color accentDeep = Color(0xFF2C8579);

  // Gold — sheriff badge / reward highlights.
  static const Color gold = Color(0xFFE7B53C);

  // Neutrals — night-leather to bone.
  static const Color ink = Color(0xFF1B1410); // near-black espresso brown
  static const Color surface = Color(0xFF2A201A); // card on dusk
  static const Color surfaceHi = Color(0xFF362A22); // raised card
  static const Color line = Color(0xFF4A3A2E); // hairline borders

  // Background gradient stops (dusk sky over the mesa).
  static const Color bgTop = Color(0xFF241A14);
  static const Color bgBottom = Color(0xFF160F0B);

  // Text on dark.
  static const Color textHi = Color(0xFFF7ECDD); // bone white
  static const Color textMid = Color(0xFFC9B6A2); // sand
  static const Color textLow = Color(0xFF8C7866); // dust

  // Status.
  static const Color danger = Color(0xFFD64A4A);
  static const Color success = Color(0xFF5FB85F);
}

/// Spacing scale — strict 8pt grid (with a 4pt half-step).
class CSpace {
  CSpace._();
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

/// Corner radii.
class CRadius {
  CRadius._();
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 22;
  static const double pill = 999;

  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));
}

/// Elevation / shadow presets.
class CShadow {
  CShadow._();
  static List<BoxShadow> get card => const [
        BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 8)),
      ];
  static List<BoxShadow> glow(Color c) => [
        BoxShadow(color: c.withValues(alpha: 0.45), blurRadius: 22, offset: const Offset(0, 6)),
      ];
}

/// Animation durations.
class CMotion {
  CMotion._();
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration base = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 420);
  static const Curve curve = Curves.easeOutCubic;
}
