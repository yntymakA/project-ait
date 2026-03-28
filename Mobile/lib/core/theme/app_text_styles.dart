import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w400,
      );

  // --- Display ---
  static TextStyle get displayLarge => _base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => _base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
      );

  // --- Headlines ---
  static TextStyle get headlineLarge => _base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get headlineMedium => _base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headlineSmall => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  // --- Titles ---
  static TextStyle get titleLarge => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  static TextStyle get titleMedium => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  static TextStyle get titleSmall => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  // --- Body ---
  static TextStyle get bodyLarge => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      );

  static TextStyle get bodyMedium => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      );

  static TextStyle get bodySmall => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      );

  // --- Labels ---
  static TextStyle get labelLarge => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  // --- Helpers ---
  static TextStyle get price => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: -0.25,
      );

  static TextStyle get caption => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      );

  static TextStyle get buttonText => _base.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  // --- TextTheme for MaterialApp ---
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
