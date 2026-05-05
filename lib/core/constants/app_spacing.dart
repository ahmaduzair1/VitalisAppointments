import 'package:flutter/material.dart';

/// Design tokens for spacing, radii, and elevation.
class AppSpacing {
  AppSpacing._();

  // ── Spacing ────────────────────────────────────────────────
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // ── Border Radii ───────────────────────────────────────────
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusXxl = 32;
  static const double radiusFull = 100;

  // ── Elevation ──────────────────────────────────────────────
  static const double elevationNone = 0;
  static const double elevationSm = 2;
  static const double elevationMd = 4;
  static const double elevationLg = 8;

  // ── Padding helpers ────────────────────────────────────────
  static const EdgeInsets paddingAllSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingAllMd = EdgeInsets.all(md);
  static const EdgeInsets paddingAllLg = EdgeInsets.all(lg);
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 20);

  // ── Card shadow (light mode) ───────────────────────────────
  static List<BoxShadow> get cardShadowLight => [
        BoxShadow(
          color: const Color(0xFF000000).withAlpha(15), // Neutral soft shadow
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  // ── Card shadow (dark mode — very subtle) ──────────────────
  static List<BoxShadow> get cardShadowDark => [
        BoxShadow(
          color: const Color(0xFF000000).withAlpha(51), // ~20% opacity
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ];
}
