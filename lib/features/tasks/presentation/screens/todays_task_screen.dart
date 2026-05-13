// File: lib/features/tasks/presentation/screens/todays_task_screen.dart
// Purpose: Pixel-matched Today's Task list from page40_img01.jpeg.
//          Date / day at top from device clock, list from API, each row routes
//          to the Today's Task detail page (designed by us).
// Used by: routes/app_router.dart at RouteNames.todaysTask.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../routes/route_names.dart';
import '../../data/todays_task_models.dart';
import '../../providers/todays_task_providers.dart';

class TodaysTaskScreen extends ConsumerWidget {
  const TodaysTaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(todaysTaskListProvider);
    final now = DateTime.now();
    final dateStr = DateFormat('dd MMM yyyy').format(now);
    final dayStr = DateFormat('EEEE').format(now);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(RouteNames.dashboard),
        ),
        title: Text("Today's Task", style: AppTextStyles.appBarTitle),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.event_available_outlined,
                  color: AppColors.primaryDark, size: 20.sp),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _dateCard(dateStr, dayStr, listAsync.value?.length ?? 0),
              SizedBox(height: 16.h),
              Text('Task List', style: AppTextStyles.sectionHeader),
              SizedBox(height: 8.h),
              Expanded(
                child: listAsync.when(
                  loading: () => const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary)),
                  error: (e, _) => Center(
                    child: Text('Failed to load tasks: $e',
                        style: AppTextStyles.body),
                  ),
                  data: (rows) => rows.isEmpty
                      ? Center(
                          child: Text('No tasks for today.',
                              style: AppTextStyles.body),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.only(bottom: 12.h),
                          itemCount: rows.length,
                          separatorBuilder: (_, _) => SizedBox(height: 10.h),
                          itemBuilder: (_, i) => _TodayRow(
                            task: rows[i],
                            onTap: () => context.push(
                              RouteNames.todaysTaskDetail,
                              extra: rows[i],
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateCard(String date, String day, int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.event_available_outlined,
                color: AppColors.primaryDark, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(date,
                    style: AppTextStyles.bodyBold
                        .copyWith(fontSize: 16.sp)),
                SizedBox(height: 2.h),
                Text(day, style: AppTextStyles.caption),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$count ${count == 1 ? 'Task' : 'Tasks'}',
              style: AppTextStyles.bodyBold.copyWith(
                color: AppColors.primaryDark,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayRow extends StatelessWidget {
  const _TodayRow({required this.task, required this.onTap});
  final TodayTask task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.cardBorder),
          ),
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
          child: Row(
            children: [
              // Yellow left accent.
              Container(
                width: 3.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(task.title,
                        style: AppTextStyles.bodyBold
                            .copyWith(fontSize: 15.sp)),
                    SizedBox(height: 4.h),
                    Text(task.summary,
                        style: AppTextStyles.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 1.2),
                ),
                child: Icon(Icons.chevron_right_rounded,
                    color: AppColors.primaryDark, size: 22.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
