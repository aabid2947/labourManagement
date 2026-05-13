// File: lib/features/tasks/presentation/screens/todays_task_detail_screen.dart
// Purpose: Today's Task detail — NOT in the PDF; designed by us using the project palette.
//          Header with title + priority chip, meta card (Assigned to / Site / Due),
//          full description card. Top Back button returns to the Today's Task list.
// Used by: routes/app_router.dart at RouteNames.todaysTaskDetail.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/todays_task_models.dart';
import '../../providers/todays_task_providers.dart';

class TodaysTaskDetailScreen extends ConsumerWidget {
  const TodaysTaskDetailScreen({super.key, required this.task});
  final TodayTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(todaysTaskDetailProvider(task.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text("Task Details", style: AppTextStyles.appBarTitle),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _titleCard(),
              SizedBox(height: 14.h),
              detailAsync.when(
                loading: () => Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary)),
                ),
                error: (e, _) => Text('Failed to load details: $e',
                    style: AppTextStyles.body),
                data: (d) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _metaCard(d),
                    SizedBox(height: 14.h),
                    _descriptionCard(d.description),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Back',
                icon: Icons.arrow_back_rounded,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titleCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 44.h,
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
                    style: AppTextStyles.screenTitle.copyWith(fontSize: 18.sp)),
                SizedBox(height: 4.h),
                Text(task.summary, style: AppTextStyles.caption),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          _priorityChip(task.priority),
        ],
      ),
    );
  }

  Widget _priorityChip(TaskPriority p) {
    Color bg;
    Color fg;
    switch (p) {
      case TaskPriority.high:
        bg = const Color(0xFFFDE3E3);
        fg = AppColors.error;
        break;
      case TaskPriority.medium:
        bg = AppColors.primarySoft;
        fg = AppColors.primaryDark;
        break;
      case TaskPriority.low:
        bg = const Color(0xFFDFF4DE);
        fg = AppColors.success;
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        p.label,
        style: AppTextStyles.caption
            .copyWith(color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _metaCard(TodayTaskDetail d) {
    final dueStr = DateFormat('dd MMM yyyy • hh:mm a').format(d.dueAt);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(
        children: [
          _metaRow(Icons.person_outline, 'Assigned to', d.assignedTo),
          const Divider(height: 1, color: AppColors.divider),
          _metaRow(Icons.location_on_outlined, 'Site', d.site),
          const Divider(height: 1, color: AppColors.divider),
          _metaRow(Icons.schedule_rounded, 'Due', dueStr,
              valueColor: AppColors.error),
        ],
      ),
    );
  }

  Widget _metaRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F4),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 18.sp, color: AppColors.textPrimary),
          ),
          SizedBox(width: 12.w),
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.bodyBold.copyWith(
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _descriptionCard(String description) {
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
          Text('Description', style: AppTextStyles.sectionHeader),
          SizedBox(height: 8.h),
          Text(description, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
