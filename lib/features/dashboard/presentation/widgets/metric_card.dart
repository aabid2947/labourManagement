// File: lib/features/dashboard/presentation/widgets/metric_card.dart
// Purpose: 2x2 dashboard metric tiles (Total Labour, Today Attendance, My Expense, Task v/s Ach).
// Used by: dashboard_screen.dart.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/section_card.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
    this.valueColor,
    this.subtitle,
    this.progress,
    this.progressColor,
    this.onTap,
    this.iconWidget,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final Color? valueColor;
  final String? subtitle;
  final double? progress; // 0..1
  final Color? progressColor;
  final VoidCallback? onTap;
  /// Optional widget rendered in the icon slot in place of the rounded
  /// `iconBg` square + `icon` glyph. Used by the Total Labour Strength tile to
  /// surface the user avatar (Bug fix pass 3).
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      onTap: onTap,
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              iconWidget ??
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(icon, color: iconColor, size: 20.sp),
                  ),
              const Spacer(),
              if (subtitle != null)
                Flexible(
                  child: Text(
                    subtitle!,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyBold.copyWith(
                      color: valueColor ?? AppColors.textPrimary,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.screenTitle.copyWith(
              fontSize: 22.sp,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
          if (progress != null) ...[
            SizedBox(height: 6.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress!.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.divider,
                color: progressColor ?? AppColors.info,
              ),
            ),
          ],
          SizedBox(height: 6.h),
          // Label is the most overflow-prone element on narrow widths. Scale
          // it down with FittedBox so it never wraps awkwardly (e.g. "TOTAL
          // LABOUR STRENGTH" + "TASK VS ACHIEVEMENTS" on a 280-wide foldable).
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              softWrap: false,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
