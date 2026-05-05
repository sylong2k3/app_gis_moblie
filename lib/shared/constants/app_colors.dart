// shared/constants/app_colors.dart
import 'package:flutter/material.dart';

/// Defines the palette of custom colors for the application.
/// These raw color values are then used by AppTheme to construct ColorScheme
/// and by CustomColorScheme extension for semantic colors.
class AppColors {
  // --- Primary Colors ---
  static const Color primary = Color.fromARGB(
    255,
    21,
    128,
    195,
  ); // A vibrant blue màu cũ là 0xFFEE0033

  static const Color primaryLight = Color.fromARGB(
    255,
    24,
    172,
    246,
  ); // A lighter shade
  static const Color primaryDark = Color.fromARGB(255, 6, 110, 201);

  // --- Secondary Colors ---
  static const Color secondary = Color(0xFFFF9500); // A warm orange
  static const Color secondaryLight = Color(0xFFFFB74D);
  static const Color secondaryDark = Color(0xFFF57C00);

  // --- Accent Colors (Optional, if different from secondary) ---
  // static const Color accent = Color(0xFF34C759); // A distinct green

  // --- Semantic Colors ---
  static const Color success = Color(0xFF34C759); // Green for success
  static const Color successLight = Color(0xFFA5D6A7);
  static const Color successDark = Color(0xFF2E7D32);

  static const Color warning = Color(0xFFFFCC00); // Yellow for warnings
  static const Color warningLight = Color(0xFFFFF59D);
  static const Color warningDark = Color(0xFFFFB300);

  static const Color info = Color(0xFF5AC8FA); // Light blue for info
  static const Color infoLight = Color(0xFFB3E5FC);
  static const Color infoDark = Color(0xFF039BE5);

  static const Color error = Color(0xFFFF3B30); // Red for errors
  static const Color errorLight = Color(0xFFFFCDD2);
  static const Color errorDark = Color(0xFFC62828);

  // toast
  static const Color successToastIcon = Color(0xFF34C759); // Green for success
  static const Color successToastBackground = Color(0xFFF0FDF4);
  static const Color successToastTitle = Color(0xFF166534);
  static const Color successToastContentTxt = Color(0xFF15803D);

  static const Color warningToastIcon = Color(0xFFF59E0B); // Amber
  static const Color warningToastBackground = Color(0xFFFFFBEB);
  static const Color warningToastTitle = Color(0xFFB45309);
  static const Color warningToastContentTxt = Color(0xFF92400E);

  static const Color errorToastIcon = Color(0xFFDC2626);
  static const Color errorToastBackground = Color(0xFFFEF2F2);
  static const Color errorToastTitle = Color(0xFFB91C1C);
  static const Color errorToastContentTxt = Color(0xFF991B1B);

  static const Color infoToastIcon = Color(0xFF3B82F6); // Blue
  static const Color infoToastBackground = Color(0xFFEFF6FF);
  static const Color infoToastTitle = Color(0xFF1E40AF);
  static const Color infoToastContentTxt = Color(0xFF1C51B9);

  // --- Neutral & Background Colors ---
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Light Theme Neutrals
  static const Color lightBackground = Color(0xFFFAFBFC); // Off-white
  static const Color lightSurface = Color(
    0xFFFFFFFF,
  ); // Pure white for cards, dialogs
  static const Color lightBorder = Color(0xFFE5E7EB); // Light grey for borders

  // Dark Theme Neutrals
  static const Color darkBackground = Color(0xFF000000); // True black
  static const Color darkSurface = Color(
    0xFF1C1C1E,
  ); // Very dark grey for cards
  static const Color darkBorder = Color(0xFF3A3A3C); // Dark grey for borders

  // --- Text Colors ---
  // Light Theme Text
  static const Color textLightPrimary = Color(
    0xFF000000,
  ); // Black for main text
  static const Color textLightSecondary = Color(
    0xFF3C3C43,
  ); // Dark grey for subtext
  static const Color textLightDisabled = Color(0xFF3C3C43); // Opacity 0.6
  static const Color textGray = Color(0xFF6B7280);
  static const Color textGrayBorder = Color(0xFF4B5563);
  // Dark Theme Text
  static const Color textDarkPrimary = Color(0xFFFFFFFF);
  static const Color textDarkSecondary = Color(0xFFEBEBF5);

  static const Color textDarkDisabled = Color(0xFFEBEBF5); // Opacity 0.6

  static const Color grey = Color(0xFFB0BEC5);

  static const Color backgroudListItem = Color(0xFFF9FAFB);

  static Color customRadioRedBackground = Color(0xFFFDE6EB);
  static const Color customRadioRed = Colors.red; // Or your specific red

  // Prevent instantiation
  AppColors._();
}
