// File: lib/features/tasks/presentation/screens/task_vs_achievements_screen.dart
// Purpose: Pixel-matched Task v/s Achievements from page30_img01.jpeg.
//          From/To date filters, headed table, View icon (under each title) opens
//          the Detail screen; Arrow action icon opens the Remarks screen.
// Used by: routes/app_router.dart at RouteNames.taskVsAchievements.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routes/route_names.dart';
import '../../data/task_models.dart';
import '../../providers/task_providers.dart';

class TaskVsAchievementsScreen extends ConsumerWidget {
  const TaskVsAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(taskRangeProvider);
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(RouteNames.dashboard),
        ),
        title: const SizedBox.shrink(),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Task Vs Achievements', style: AppTextStyles.screenTitle),
              SizedBox(height: 16.h),
              _dateFilters(context, ref, range),
              SizedBox(height: 14.h),
              Expanded(
                child: tasksAsync.when(
                  loading: () => const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary)),
                  error: (e, _) => Center(
                      child: Text('Failed to load tasks: $e',
                          style: AppTextStyles.body)),
                  data: (rows) => rows.isEmpty
                      ? Center(
                          child: Text('No tasks in this range.',
                              style: AppTextStyles.body),
                        )
                      : _TaskTable(rows: rows),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateFilters(BuildContext context, WidgetRef ref, TaskRange range) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _DatePill(
              label: 'From Date',
              value: range.from,
              onPick: (d) => ref.read(taskRangeProvider.notifier).setFrom(d),
            ),
          ),
          Container(width: 1, height: 56.h, color: AppColors.divider),
          Expanded(
            child: _DatePill(
              label: 'To Date',
              value: range.to,
              onPick: (d) => ref.read(taskRangeProvider.notifier).setTo(d),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({
    required this.label,
    required this.value,
    required this.onPick,
  });
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime(DateTime.now().year + 5),
        );
        if (picked != null) onPick(picked);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTextStyles.caption),
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 16.sp, color: AppColors.textSecondary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    Formatters.dateFull(value),
                    style: AppTextStyles.bodyBold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 20.sp, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTable extends StatelessWidget {
  const _TaskTable({required this.rows});
  final List<TaskAchievement> rows;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.cardBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _header(),
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0)
                const Divider(height: 1, color: AppColors.divider),
              _row(context, rows[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      color: AppColors.primarySoft,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      child: Row(
        children: [
          _headerCell('Task Date', flex: 24),
          _headerCell('Task Title', flex: 28),
          _headerCell('Aging', flex: 16, center: true),
          _headerCell('Status', flex: 20, center: true),
          _headerCell('Remark', flex: 12, center: true),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {required int flex, bool center = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Text(
          label,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: AppTextStyles.bodyBold.copyWith(fontSize: 12.sp),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, TaskAchievement t) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Task Date column — assigned + due stacked.
          Expanded(
            flex: 24,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(Formatters.dateFull(t.assignedDate),
                      style: AppTextStyles.bodyBold.copyWith(fontSize: 12.sp)),
                  SizedBox(height: 4.h),
                  Text(Formatters.dateFull(t.dueDate),
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.info)),
                ],
              ),
            ),
          ),
          // Task Title — title + tiny "view" icon below.
          Expanded(
            flex: 28,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyBold.copyWith(fontSize: 12.sp),
                  ),
                  SizedBox(height: 6.h),
                  InkWell(
                    onTap: () => context.push(
                      RouteNames.taskDetail,
                      extra: t,
                    ),
                    borderRadius: BorderRadius.circular(6.r),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Icon(Icons.description_outlined,
                          color: AppColors.primary, size: 16.sp),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Aging pill
          Expanded(
            flex: 16,
            child: Center(child: _agingPill(t.agingDays)),
          ),
          // Status pill
          Expanded(
            flex: 20,
            child: Center(child: _statusPill(t.status)),
          ),
          // Action — arrow → remark
          Expanded(
            flex: 12,
            child: Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(20.r),
                onTap: () => context.push(
                  RouteNames.taskRemark,
                  extra: t,
                ),
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.2),
                  ),
                  child: Icon(Icons.chevron_right_rounded,
                      color: AppColors.primary, size: 22.sp),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _agingPill(int days) {
    String label;
    Color bg;
    Color fg;
    if (days <= 0) {
      label = 'On Time';
      bg = const Color(0xFFDFF4DE);
      fg = AppColors.success;
    } else if (days == 1) {
      label = '1D';
      bg = AppColors.primarySoft;
      fg = AppColors.primaryDark;
    } else if (days == 2) {
      label = '2D';
      bg = const Color(0xFFFDE3E3);
      fg = AppColors.error;
    } else {
      label = '${days}D';
      bg = const Color(0xFFFDE3E3);
      fg = AppColors.error;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(label,
          style: AppTextStyles.caption
              .copyWith(color: fg, fontWeight: FontWeight.w700)),
    );
  }

  Widget _statusPill(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'Partial Completed':
        bg = const Color(0xFFE6ECFB);
        fg = AppColors.info;
        break;
      case 'Fully Completed':
        bg = const Color(0xFFDFF4DE);
        fg = AppColors.success;
        break;
      case 'Task Pending':
      default:
        bg = AppColors.primarySoft;
        fg = AppColors.primaryDark;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: AppTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 10.sp,
          height: 1.2,
        ),
      ),
    );
  }
}
