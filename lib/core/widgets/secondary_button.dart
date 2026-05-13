// File: lib/core/widgets/secondary_button.dart
// Purpose: Outline button — used where a non-primary action sits next to PrimaryButton.
// Used by: forms with cancel actions, biometric / contact-admin alt actions.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../theme/text_styles.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.h,
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.primary, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20.sp, color: AppColors.primaryDark),
              SizedBox(width: 8.w),
            ],
            Text(
              label,
              style: AppTextStyles.button.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
