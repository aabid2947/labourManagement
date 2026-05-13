// File: lib/features/tasks/presentation/screens/task_detail_screen.dart
// Purpose: Pixel-matched Task Details from page32_img01.jpeg.
//          Title + read-only Description + yellow Back button at the bottom.
// Used by: routes/app_router.dart at RouteNames.taskDetail.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/task_models.dart';
import '../../providers/task_providers.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.task});
  final TaskAchievement task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(taskDetailProvider(task.id));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Task Details', style: AppTextStyles.appBarTitle),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 8.h),
              Text('Task Title', style: AppTextStyles.sectionHeader),
              SizedBox(height: 8.h),
              _readOnlyBox(task.title),
              SizedBox(height: 18.h),
              Text('Task Description', style: AppTextStyles.sectionHeader),
              SizedBox(height: 8.h),
              detailAsync.when(
                loading: () => _readOnlyBox(
                  'Loading…',
                  isMultiline: true,
                  italic: true,
                ),
                error: (e, _) => _readOnlyBox(
                  'Failed to load description: $e',
                  isMultiline: true,
                ),
                data: (d) => _readOnlyBox(d.description, isMultiline: true),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Back',
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _readOnlyBox(String text,
      {bool isMultiline = false, bool italic = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      constraints: BoxConstraints(minHeight: isMultiline ? 140.h : 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          fontWeight: isMultiline ? FontWeight.w400 : FontWeight.w700,
        ),
      ),
    );
  }
}
