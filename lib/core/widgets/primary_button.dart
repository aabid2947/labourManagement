// File: lib/core/widgets/primary_button.dart
// Purpose: Filled CTA button styled like LOGIN / CLAIM NOW / SUBMIT in the screenshots.
// Used by: every screen that needs a primary action.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../theme/text_styles.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.fullWidth = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    final button = SizedBox(
      height: 52.h,
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          disabledForegroundColor: AppColors.textOnPrimary.withValues(alpha: 0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
        ),
        child: loading
            ? SizedBox(
                height: 22.h,
                width: 22.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.textOnPrimary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20.sp),
                    SizedBox(width: 8.w),
                  ],
                  Text(label, style: AppTextStyles.button),
                ],
              ),
      ),
    );
    return button;
  }
}
