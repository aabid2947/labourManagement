// File: lib/features/self_attendance/presentation/screens/attendance_success_screen.dart
// Purpose: Pixel-matched success screen from page16_img01.jpeg.
//          Renders Status / Time / Site card. DONE → back to Self Attendance entry.
// Used by: routes/app_router.dart at RouteNames.selfAttendanceSuccess.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../routes/route_names.dart';
import '../../data/attendance_models.dart';

class AttendanceSuccessScreen extends StatelessWidget {
  const AttendanceSuccessScreen({super.key, required this.result});
  final MarkAttendanceResult result;

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(result.markedAt);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.selfAttendance),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          child: Column(
            children: [
              SizedBox(height: 8.h),
              Container(
                width: 96.w,
                height: 96.w,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded,
                    color: Colors.white, size: 64.sp),
              ),
              SizedBox(height: 14.h),
              Text(
                'Attendance Marked\nSuccessfully!',
                textAlign: TextAlign.center,
                style: AppTextStyles.screenTitle.copyWith(height: 1.2),
              ),
              SizedBox(height: 22.h),
              _detailsCard(timeStr),
              SizedBox(height: 14.h),
              _recordedPill(),
              const Spacer(),
              PrimaryButton(
                label: 'DONE',
                onPressed: () => context.go(RouteNames.selfAttendance),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailsCard(String timeStr) {
    final statusLabel = result.status.label;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      child: Column(
        children: [
          _row(
            icon: Icons.assignment_outlined,
            label: 'Status',
            value: statusLabel,
            valueColor: AppColors.success,
          ),
          const Divider(height: 1, color: AppColors.divider),
          _row(
            icon: Icons.access_time_rounded,
            label: 'Time',
            value: timeStr,
            valueColor: AppColors.success,
          ),
          const Divider(height: 1, color: AppColors.divider),
          _row(
            icon: Icons.location_on_outlined,
            label: 'Site',
            value: result.siteName,
            valueColor: AppColors.textPrimary,
            valueSubtitle: result.siteSubtitle,
          ),
        ],
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    String? valueSubtitle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F4),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 20.sp, color: AppColors.textPrimary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(label, style: AppTextStyles.body),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: AppTextStyles.bodyBold.copyWith(color: valueColor)),
              if (valueSubtitle != null)
                Text(valueSubtitle, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recordedPill() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Your attendance has been recorded.',
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
