import 'package:flutter/material.dart';

/// Centralized color palette for Vitalis Appointments.
///
/// Use [AppColors.of(context)] to automatically resolve colors
/// based on the current theme brightness (light / dark).
class AppColors {
  // ── Light Palette ──────────────────────────────────────────
  static const Color primaryLight = Color(0xFF2563EB); // Vibrant modern blue
  static const Color primaryVariantLight = Color(0xFF1D4ED8);
  static const Color secondaryLight = Color(0xFF14B8A6); // Brighter teal
  static const Color accentLight = Color(0xFFF59E0B);
  static const Color backgroundLight = Color(0xFFF4F7FF); // Soft airy blue-tinted background
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1E293B); // Slightly softer rich dark
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color inputFillLight = Color(0xFFEAEFFF); // Very subtle blue for inputs
  static const Color successLight = Color(0xFF10B981);
  static const Color warningLight = Color(0xFFF59E0B);
  static const Color errorLight = Color(0xFFEF4444);
  static const Color infoLight = Color(0xFF3B82F6);
  static const Color shimmerBaseLight = Color(0xFFE2E8F0);
  static const Color shimmerHighlightLight = Color(0xFFF8FAFC);

  // ── Dark Palette ───────────────────────────────────────────
  static const Color primaryDark = Color(0xFF42A5F5);
  static const Color primaryVariantDark = Color(0xFF1E88E5);
  static const Color secondaryDark = Color(0xFF2DD4BF);
  static const Color accentDark = Color(0xFFFBBF24);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFE2E8F0);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color dividerDark = Color(0xFF334155);
  static const Color inputFillDark = Color(0xFF1E293B);
  static const Color successDark = Color(0xFF34D399);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color errorDark = Color(0xFFF87171);
  static const Color infoDark = Color(0xFF60A5FA);
  static const Color shimmerBaseDark = Color(0xFF1E293B);
  static const Color shimmerHighlightDark = Color(0xFF334155);

  // ── Convenience accessor ───────────────────────────────────
  static AppColorSet of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? _dark : _light;
  }

  static const _light = AppColorSet(
    primary: primaryLight,
    primaryVariant: primaryVariantLight,
    secondary: secondaryLight,
    accent: accentLight,
    background: backgroundLight,
    surface: surfaceLight,
    card: cardLight,
    textPrimary: textPrimaryLight,
    textSecondary: textSecondaryLight,
    divider: dividerLight,
    inputFill: inputFillLight,
    success: successLight,
    warning: warningLight,
    error: errorLight,
    info: infoLight,
    shimmerBase: shimmerBaseLight,
    shimmerHighlight: shimmerHighlightLight,
  );

  static const _dark = AppColorSet(
    primary: primaryDark,
    primaryVariant: primaryVariantDark,
    secondary: secondaryDark,
    accent: accentDark,
    background: backgroundDark,
    surface: surfaceDark,
    card: cardDark,
    textPrimary: textPrimaryDark,
    textSecondary: textSecondaryDark,
    divider: dividerDark,
    inputFill: inputFillDark,
    success: successDark,
    warning: warningDark,
    error: errorDark,
    info: infoDark,
    shimmerBase: shimmerBaseDark,
    shimmerHighlight: shimmerHighlightDark,
  );
}

/// Typed colour set so every screen can do `AppColors.of(context).primary`.
class AppColorSet {
  final Color primary;
  final Color primaryVariant;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final Color inputFill;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color shimmerBase;
  final Color shimmerHighlight;

  const AppColorSet({
    required this.primary,
    required this.primaryVariant,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.inputFill,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });
}
