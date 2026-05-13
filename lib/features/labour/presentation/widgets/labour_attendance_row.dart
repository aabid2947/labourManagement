// File: lib/features/labour/presentation/widgets/labour_attendance_row.dart
// Purpose: One row in the Labour In / Out list. Renders either a "TAKE ATTENDANCE"
//          (or "MARK EXIT") yellow button OR a green "IN Marked" / "OUT Marked" pill with time.
// Used by: labour_in_screen.dart, labour_out_screen.dart.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../data/labour_attendance_models.dart';

class LabourAttendanceRow extends StatelessWidget {
  const LabourAttendanceRow({
    super.key,
    required this.item,
    required this.mode,
    required this.onTakeAttendance,
  });

  final LabourAttendanceItem item;
  final LabourAttendanceMode mode;
  final VoidCallback onTakeAttendance;

  String get _ctaLabel => mode == LabourAttendanceMode.inMode
      ? 'TAKE ATTENDANCE'
      : 'MARK EXIT';
  String get _markedLabel =>
      mode == LabourAttendanceMode.inMode ? 'IN Marked' : 'OUT Marked';

  @override
  Widget build(BuildContext context) {
    final isOutMode = mode == LabourAttendanceMode.outMode;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          _avatar(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.name,
                    style: AppTextStyles.bodyBold,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 2.h),
                Text(item.skill,
                    style: AppTextStyles.caption,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          // Right column: action OR marked pill, plus optional IN/OUT subtitle.
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.marked) _markedPill() else _takeAttendanceButton(),
              if (isOutMode) ...[
                SizedBox(height: 4.h),
                _inOutSubtitle(),
              ],
            ],
          ),
          SizedBox(width: 6.w),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary, size: 22.sp),
        ],
      ),
    );
  }

  /// "IN: 08:15 AM   |   OUT: 06:05 PM" — only rendered in out mode.
  Widget _inOutSubtitle() {
    final inStr = item.inTime ?? '--:--';
    final outStr = item.outTime ?? '--:--';
    return RichText(
      text: TextSpan(
        style: AppTextStyles.caption,
        children: [
          TextSpan(
              text: 'IN: ',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
          TextSpan(
              text: inStr,
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          const TextSpan(text: '  |  '),
          TextSpan(
              text: 'OUT: ',
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
          TextSpan(
              text: outStr,
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _avatar() {
    final bg = item.marked
        ? const Color(0xFFE7F5E9)
        : const Color(0xFFF1F2F4);
    final fg = item.marked ? AppColors.success : AppColors.textSecondary;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.person, color: fg, size: 26.sp),
        ),
        if (item.marked)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 16.w,
              height: 16.w,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded,
                  color: Colors.white, size: 12.sp),
            ),
          ),
      ],
    );
  }

  Widget _markedPill() {
    // The pill itself; the marked time renders below ONLY in inMode where the
    // IN/OUT subtitle isn't present. In outMode the time lives in the IN/OUT
    // subtitle line and showing it again here would duplicate.
    final pill = Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F5E9),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 14.sp),
          SizedBox(width: 4.w),
          Text(_markedLabel,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
    if (mode == LabourAttendanceMode.outMode) return pill;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        pill,
        SizedBox(height: 4.h),
        Text(item.markedTime ?? '',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            )),
      ],
    );
  }

  Widget _takeAttendanceButton() {
    return SizedBox(
      height: 36.h,
      child: ElevatedButton(
        onPressed: onTakeAttendance,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          _ctaLabel,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
