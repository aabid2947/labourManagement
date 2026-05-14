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
    // ScreenUtil's `.sp` already scales by design size, and every text widget
    // below is wrapped in FittedBox(scaleDown) so it adapts to narrow tiles
    // anyway — no `LayoutBuilder` needed here. (Subtrees that contain a
    // LayoutBuilder can't compute intrinsic dimensions, which crashes the
    // dashboard's IntrinsicHeight row.)
    final valueSize = 22.sp;
    final subtitleSize = 13.sp;
    return SectionCard(
      onTap: onTap,
      padding: EdgeInsets.all(10.w),
      // Two-group column with `spaceBetween` so the label pins to the
      // bottom and any spare height (from the dashboard's IntrinsicHeight
      // row) flows between the value block and the label.
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      iconWidget ??
                          Container(
                            width: 32.w,
                            height: 32.w,
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child:
                                Icon(icon, color: iconColor, size: 18.sp),
                          ),
                      SizedBox(width: 6.w),
                      if (subtitle != null)
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              subtitle!,
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              softWrap: false,
                              style: AppTextStyles.bodyBold.copyWith(
                                color: valueColor ?? AppColors.textPrimary,
                                fontSize: subtitleSize,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      maxLines: 1,
                      softWrap: false,
                      style: AppTextStyles.screenTitle.copyWith(
                        fontSize: valueSize,
                        color: valueColor ?? AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (progress != null) ...[
                    SizedBox(height: 6.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress!.clamp(0.0, 1.0),
                        minHeight: 5,
                        backgroundColor: AppColors.divider,
                        color: progressColor ?? AppColors.info,
                      ),
                    ),
                  ],
                ],
              ),
              // Label is the most overflow-prone element on narrow widths.
              // FittedBox scales it down so "TOTAL LABOUR STRENGTH" and
              // "TASK VS ACHIEVEMENTS" never wrap or clip on small phones.
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
