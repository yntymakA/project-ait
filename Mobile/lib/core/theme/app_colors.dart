import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Primary ---
  static const Color primary = Color(0xFF3D5AFE);
  static const Color primaryLight = Color(0xFF8187FF);
  static const Color primaryDark = Color(0xFF0031CA);

  // --- Secondary / Accent ---
  static const Color secondary = Color(0xFFFFB300);
  static const Color secondaryLight = Color(0xFFFFE54C);
  static const Color secondaryDark = Color(0xFFC68400);

  // --- Backgrounds ---
  static const Color background = Color(0xFFF5F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF0F8);

  // --- Text ---
  static const Color textPrimary = Color(0xFF1A1D2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFFB0B7C3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFF1A1D2E);

  // --- Status ---
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color success = Color(0xFF43A047);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFB8C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF039BE5);
  static const Color infoLight = Color(0xFFE1F5FE);

  // --- Borders & Dividers ---
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF0F1F5);

  // --- Grey scale ---
  static const Color grey50 = Color(0xFFFAFAFC);
  static const Color grey100 = Color(0xFFF5F6FA);
  static const Color grey200 = Color(0xFFEEF0F8);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // --- Transparent helpers ---
  static const Color transparent = Colors.transparent;
  static Color primaryWithOpacity(double opacity) =>
      primary.withValues(alpha: opacity);
  static Color blackWithOpacity(double opacity) =>
      Colors.black.withValues(alpha: opacity);
}
