// File: lib/features/labour/presentation/screens/labour_out_screen.dart
// Purpose: Pixel-matched Labour Out list from page26_img01.jpeg.
//          Heading is "Labour Out" (the screenshot says "Exit Attendance"; brief on
//          PDF page 27 explicitly demands the heading change AND that the "Exit
//          Attendance" label be removed entirely).
// Used by: routes/app_router.dart at RouteNames.labourOut.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../routes/route_names.dart';
import '../../data/labour_attendance_models.dart';
import '../../providers/labour_attendance_providers.dart';
import '../../providers/labour_providers.dart';
import '../widgets/contractor_card.dart';
import '../widgets/labour_attendance_row.dart';
import 'labour_scan_args.dart';

class LabourOutScreen extends ConsumerWidget {
  const LabourOutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractorsAsync = ref.watch(contractorsProvider);
    final selected = ref.watch(selectedContractorProvider);
    final summaryAsync =
        ref.watch(labourAttendanceListProvider(LabourAttendanceMode.outMode));

    contractorsAsync.whenData((list) {
      if (selected == null && list.isNotEmpty) {
        Future.microtask(() =>
            ref.read(selectedContractorProvider.notifier).select(list.first));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(RouteNames.dashboard),
        ),
        title: Text('Labour Out', style: AppTextStyles.appBarTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              contractorsAsync.when(
                loading: () => const LinearProgressIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.divider),
                error: (e, _) => Text('Failed to load contractors: $e',
                    style: AppTextStyles.body),
                data: (list) => ContractorCard(
                  contractors: list,
                  selected: selected,
                  onSelect: (c) {
                    ref.read(selectedContractorProvider.notifier).select(c);
                  },
                ),
              ),
              SizedBox(height: 12.h),
              summaryAsync.when(
                loading: () => SizedBox(height: 64.h),
                error: (e, _) => SizedBox(height: 64.h),
                data: (s) =>
                    _progressPill(marked: s.markedCount, total: s.total),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: summaryAsync.when(
                  loading: () => const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary)),
                  error: (e, _) => Center(
                    child: Text('Failed to load list: $e',
                        style: AppTextStyles.body),
                  ),
                  data: (s) => s.items.isEmpty
                      ? Center(
                          child: Text('No labour to mark out.',
                              style: AppTextStyles.body),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14.r),
                            border:
                                Border.all(color: AppColors.cardBorder),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: s.items.length,
                            itemBuilder: (_, i) {
                              final item = s.items[i];
                              return LabourAttendanceRow(
                                item: item,
                                mode: LabourAttendanceMode.outMode,
                                onTakeAttendance: () => context.push(
                                  RouteNames.labourOutScan,
                                  extra: LabourScanArgs(
                                    item: item,
                                    mode: LabourAttendanceMode.outMode,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
              SizedBox(height: 10.h),
              _hintBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressPill({required int marked, required int total}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F5E9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyBold,
                    children: [
                      const TextSpan(text: 'Out Marked: '),
                      TextSpan(
                        text: '$marked',
                        style: AppTextStyles.bodyBold
                            .copyWith(color: AppColors.success),
                      ),
                      TextSpan(text: ' out of $total Labour'),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Text('Tap on any labour to mark exit attendance.',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: const Color(0xFFCDEAD2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.logout_rounded,
                color: AppColors.success, size: 20.sp),
          ),
        ],
      ),
    );
  }

  Widget _hintBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: AppColors.primaryDark, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Tap on any labour to mark exit attendance.',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}
