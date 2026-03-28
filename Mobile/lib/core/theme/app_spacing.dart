import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  // --- Spacing scale ---
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // --- Border Radii ---
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 28.0;
  static const double radiusFull = 999.0;

  // --- Common Border Radius objects ---
  static const BorderRadius rounded = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius roundedFull = BorderRadius.all(Radius.circular(radiusFull));

  // --- Common EdgeInsets ---
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: md, vertical: md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(horizontal: md, vertical: sm);

  // --- Icon sizes ---
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;

  // --- Button height ---
  static const double buttonHeight = 52.0;
  static const double buttonHeightSm = 40.0;

  // --- Input height ---
  static const double inputHeight = 56.0;

  // --- App bar height ---
  static const double appBarHeight = 56.0;
}
