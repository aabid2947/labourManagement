// File: lib/core/theme/app_theme.dart
// Purpose: Exposes AppTheme.light — the single ThemeData wired into MaterialApp.
// Used by: lib/app/app.dart.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import 'color_scheme.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: AppColorScheme.light,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          surfaceTintColor: AppColors.surface,
          titleTextStyle: AppTextStyles.appBarTitle,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        textTheme: TextTheme(
          headlineMedium: AppTextStyles.screenTitle,
          titleLarge: AppTextStyles.sectionHeader,
          bodyLarge: AppTextStyles.body,
          bodyMedium: AppTextStyles.body,
          bodySmall: AppTextStyles.caption,
          labelLarge: AppTextStyles.button,
          labelMedium: AppTextStyles.inputLabel,
        ),
        dividerColor: AppColors.divider,
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          hintStyle: AppTextStyles.inputHint,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
}
