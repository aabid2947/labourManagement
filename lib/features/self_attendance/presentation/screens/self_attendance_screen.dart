// File: lib/features/self_attendance/presentation/screens/self_attendance_screen.dart
// Purpose: Pixel-matched Self Attendance entry from page12_img01.jpeg.
//          Per brief (PDF page 13): SWAP the screenshot order — Self Attendance LEFT,
//          View Attendance RIGHT.
// Used by: routes/app_router.dart at RouteNames.selfAttendance.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../routes/route_names.dart';
import '../../data/attendance_models.dart';
import '../../providers/self_attendance_providers.dart';

class SelfAttendanceScreen extends ConsumerWidget {
  const SelfAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(attendanceStatusProvider);
    final inMarkedTodayAsync = ref.watch(inMarkedTodayProvider);
    final inMarked = inMarkedTodayAsync.maybeWhen(
      data: (v) => v,
      orElse: () => false,
    );

    // If the user picked OUT earlier today and then IN wasn't marked (e.g.
    // fresh launch), bounce the selector back to IN so they can't reach FACE
    // SCAN in a disabled-OUT state.
    if (!inMarked && status == AttendanceStatus.outStatus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(attendanceStatusProvider.notifier)
            .set(AttendanceStatus.inStatus);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(RouteNames.dashboard),
        ),
        title: Text('Self Attendance', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'View Attendance',
            onPressed: () => context.push(RouteNames.viewAttendance),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dateHeader(),
              SizedBox(height: 10.h),
              _topToggle(context),
              SizedBox(height: 18.h),
              _statusPanel(context, ref, status, inMarked: inMarked),
              SizedBox(height: 16.h),
              _takeAttendanceCard(),
              const Spacer(),
              PrimaryButton(
                label: 'FACE SCAN',
                icon: Icons.face_retouching_natural,
                onPressed: () => context.push(
                  RouteNames.selfAttendanceScan,
                  extra: status,
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Left-aligned date label rendered above the View/Self Attendance toggle.
  /// Bug fix pass 4 — client wanted "aaj ki date" visible somewhere on this
  /// screen, sitting above the toggle row (left, not centered above the View
  /// Attendance tile).
  Widget _dateHeader() {
    final now = DateTime.now();
    final dateStr = DateFormat('dd MMM yyyy').format(now);
    final dayStr = DateFormat('EEEE').format(now);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(dateStr, style: AppTextStyles.bodyBold),
        SizedBox(height: 2.h),
        Text(dayStr, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _topToggle(BuildContext context) {
    // SELF ATTENDANCE on LEFT, VIEW ATTENDANCE on RIGHT (swap from screenshot per brief).
    return Row(
      children: [
        Expanded(
          child: _toggleTile(
            label: 'SELF ATTENDANCE',
            icon: Icons.center_focus_strong_rounded,
            highlight: true,
            onTap: null, // already here
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _toggleTile(
            label: 'VIEW ATTENDANCE',
            icon: Icons.assignment_outlined,
            highlight: false,
            onTap: () => context.push(RouteNames.viewAttendance),
          ),
        ),
      ],
    );
  }

  Widget _toggleTile({
    required String label,
    required IconData icon,
    required bool highlight,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: highlight ? AppColors.primarySoft : AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: highlight ? AppColors.primary : AppColors.cardBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 20.sp,
                  color: highlight
                      ? AppColors.primaryDark
                      : AppColors.textSecondary),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.bodyBold.copyWith(
                    fontSize: 12.sp,
                    color: highlight
                        ? AppColors.primaryDark
                        : AppColors.textPrimary,
                    letterSpacing: 0.4,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusPanel(
    BuildContext context,
    WidgetRef ref,
    AttendanceStatus status, {
    required bool inMarked,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Status', style: AppTextStyles.bodyBold),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _statusPill(
                  label: 'IN',
                  icon: Icons.login_rounded,
                  selected: status == AttendanceStatus.inStatus,
                  enabled: true,
                  onTap: () => ref
                      .read(attendanceStatusProvider.notifier)
                      .set(AttendanceStatus.inStatus),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _statusPill(
                  label: 'OUT',
                  icon: Icons.logout_rounded,
                  selected: status == AttendanceStatus.outStatus,
                  // OUT stays locked until the user has successfully marked IN
                  // for today (Bug fix pass 4).
                  enabled: inMarked,
                  onTap: inMarked
                      ? () => ref
                          .read(attendanceStatusProvider.notifier)
                          .set(AttendanceStatus.outStatus)
                      : () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Mark IN first to enable OUT'),
                            ),
                          ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusPill({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    final disabled = !enabled;
    final bg = disabled
        ? AppColors.divider
        : (selected ? AppColors.primary : AppColors.background);
    final borderColor = disabled
        ? AppColors.divider
        : (selected ? AppColors.primary : AppColors.cardBorder);
    final fg = disabled
        ? AppColors.textDisabled
        : (selected ? AppColors.textOnPrimary : AppColors.textPrimary);

    return Opacity(
      opacity: disabled ? 0.6 : 1.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTap: onTap,
        child: Container(
          height: 52.h,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20.sp, color: fg),
              SizedBox(width: 8.w),
              Text(
                label,
                style: AppTextStyles.bodyBold.copyWith(
                  color: fg,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _takeAttendanceCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.center_focus_strong_rounded,
                color: AppColors.primaryDark, size: 26.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Take your attendance', style: AppTextStyles.bodyBold),
                SizedBox(height: 4.h),
                Text(
                  'Click the button below to open camera and mark your attendance',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
