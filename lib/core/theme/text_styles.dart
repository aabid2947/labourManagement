// File: lib/core/theme/text_styles.dart
// Purpose: Centralized TextStyle definitions aligned to the client's screenshots.
// Used by: core/theme/app_theme.dart and shared widgets.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

class AppTextStyles {
  static TextStyle get appBarTitle => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.2,
      );

  static TextStyle get screenTitle => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get sectionHeader => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => TextStyle(
        fontSize: 14.sp,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get bodyBold => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get caption => TextStyle(
        fontSize: 12.sp,
        color: AppColors.textSecondary,
      );

  // Buttons — dark text on yellow background to match LOGIN / CLAIM NOW screenshots.
  static TextStyle get button => TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textOnPrimary,
        letterSpacing: 0.4,
      );

  static TextStyle get inputLabel => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.6,
      );

  static TextStyle get inputText => TextStyle(
        fontSize: 15.sp,
        color: AppColors.textPrimary,
      );

  static TextStyle get inputHint => TextStyle(
        fontSize: 15.sp,
        color: AppColors.textSecondary,
      );

  static TextStyle get errorText => TextStyle(
        fontSize: 12.sp,
        color: AppColors.error,
      );

  static TextStyle get linkText => TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryDark,
        decoration: TextDecoration.underline,
      );
}
