// File: lib/features/auth/presentation/widgets/mpin_dots.dart
// Purpose: 4-circle MPIN indicator used on Set MPIN + Confirm MPIN (page04 / page06).
// Used by: set_mpin_screen.dart, confirm_mpin_screen.dart.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

class MpinDots extends StatelessWidget {
  const MpinDots({
    super.key,
    required this.length,
    required this.filled,
    this.size = 22,
    this.spacing = 28,
  });

  final int length;
  final int filled;
  final double size;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final isFilled = i < filled;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: (spacing / 2).w),
          child: Container(
            width: size.w,
            height: size.w,
            decoration: BoxDecoration(
              color: isFilled ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.6),
            ),
          ),
        );
      }),
    );
  }
}

/// 4 outlined squares — matches the MPIN entry boxes on page08 (MPIN Login).
class MpinBoxes extends StatelessWidget {
  const MpinBoxes({
    super.key,
    required this.length,
    required this.filled,
    this.size = 56,
    this.spacing = 12,
  });

  final int length;
  final int filled;
  final double size;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final isFilled = i < filled;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: (spacing / 2).w),
          child: Container(
            width: size.w,
            height: size.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.primary, width: 1.4),
            ),
            child: isFilled
                ? Text(
                    '•',
                    style: TextStyle(
                      fontSize: 32.sp,
                      color: AppColors.textPrimary,
                      height: 0.7,
                    ),
                  )
                : null,
          ),
        );
      }),
    );
  }
}
