// File: lib/features/dashboard/presentation/widgets/management_tile.dart
// Purpose: Square action tile in the "MANAGEMENT ACTIONS" row (Self Attendance / Labour In / Out).
// Used by: dashboard_screen.dart.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

class ManagementTile extends StatelessWidget {
  const ManagementTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.primary : AppColors.surface;
    final fg = selected ? AppColors.textOnPrimary : AppColors.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Container(
          height: 96.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg, size: 30.sp),
              SizedBox(height: 8.h),
              Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyBold.copyWith(
                  fontSize: 11.sp,
                  color: fg,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
