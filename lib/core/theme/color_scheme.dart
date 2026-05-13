// File: lib/core/theme/color_scheme.dart
// Purpose: Material ColorScheme built from AppColors tokens.
// Used by: core/theme/app_theme.dart.

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppColorScheme {
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.textOnPrimary,
    primaryContainer: AppColors.primarySoft,
    onPrimaryContainer: AppColors.textPrimary,
    secondary: AppColors.primaryDark,
    onSecondary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.background,
    outline: AppColors.divider,
    outlineVariant: AppColors.cardBorder,
  );
}
