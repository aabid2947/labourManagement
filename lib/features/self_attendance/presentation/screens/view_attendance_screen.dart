// File: lib/features/self_attendance/presentation/screens/view_attendance_screen.dart
// Purpose: View Attendance — NOT in the PDF; designed by us using the project palette.
//          From-Date / To-Date filter + list of past entries.
// Used by: routes/app_router.dart at RouteNames.viewAttendance.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../../../core/widgets/section_card.dart';
import '../../data/attendance_models.dart';
import '../../providers/self_attendance_providers.dart';

class ViewAttendanceScreen extends ConsumerWidget {
  const ViewAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(attendanceRangeProvider);
    final entriesAsync = ref.watch(myAttendanceProvider);

    return AppScaffold(
      title: 'View Attendance',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppDatePicker(
                  label: 'From',
                  value: range.from,
                  onChanged: (d) => ref
                      .read(attendanceRangeProvider.notifier)
                      .setFrom(d),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AppDatePicker(
                  label: 'To',
                  value: range.to,
                  onChanged: (d) =>
                      ref.read(attendanceRangeProvider.notifier).setTo(d),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: entriesAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(
                child: Text('Failed to load: $e', style: AppTextStyles.body),
              ),
              data: (entries) => entries.isEmpty
                  ? Center(
                      child: Text('No attendance records in this range.',
                          style: AppTextStyles.body),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.only(bottom: 16.h),
                      itemBuilder: (_, i) => _row(entries[i]),
                      separatorBuilder: (_, _) => SizedBox(height: 8.h),
                      itemCount: entries.length,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(AttendanceEntry e) {
    final isPresent = e.status.toLowerCase() == 'present';
    final statusColor = isPresent ? AppColors.success : AppColors.primaryDark;
    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10.r),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(DateFormat('dd').format(e.date),
                    style: AppTextStyles.bodyBold
                        .copyWith(color: AppColors.primaryDark)),
                Text(DateFormat('MMM').format(e.date).toUpperCase(),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.primaryDark, fontSize: 9.sp)),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Formatters.date(e.date), style: AppTextStyles.bodyBold),
                SizedBox(height: 2.h),
                Text(
                  'In ${e.inTime ?? '—'}   •   Out ${e.outTime ?? '—'}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              e.status,
              style: AppTextStyles.caption.copyWith(
                  color: statusColor, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
