// File: lib/features/labour/presentation/screens/labour_list_screen.dart
// Purpose: Pixel-matched Labour Induction list from page18_img01.jpeg.
//          Contractor dropdown, Total Labour Added pill, list of LabourRow, yellow FAB.
// Used by: routes/app_router.dart at RouteNames.labourList.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../routes/route_names.dart';
import '../../data/labour_models.dart';
import '../../providers/labour_providers.dart';
import '../widgets/labour_row.dart';

class LabourListScreen extends ConsumerWidget {
  const LabourListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractorsAsync = ref.watch(contractorsProvider);
    final selected = ref.watch(selectedContractorProvider);
    final countAsync = ref.watch(labourCountProvider);
    final labourAsync = ref.watch(labourListProvider);

    // Auto-select first contractor once the list arrives.
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
        title: Text('Labour Induction', style: AppTextStyles.appBarTitle),
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
                data: (contractors) => AppDropdown<Contractor>(
                  label: 'Select Contractor',
                  hint: 'Select Contractor',
                  required: true,
                  value: selected,
                  items: contractors,
                  itemLabel: (c) => c.name,
                  onChanged: (c) {
                    if (c != null) {
                      ref.read(selectedContractorProvider.notifier).select(c);
                    }
                  },
                ),
              ),
              SizedBox(height: 12.h),
              _totalPill(countAsync),
              SizedBox(height: 12.h),
              Expanded(
                child: labourAsync.when(
                  loading: () => const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary)),
                  error: (e, _) => Center(
                    child: Text('Failed to load labour: $e',
                        style: AppTextStyles.body),
                  ),
                  data: (list) => list.isEmpty
                      ? Center(
                          child: Text('No labour added yet.',
                              style: AppTextStyles.body),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.only(bottom: 80.h),
                          itemCount: list.length,
                          separatorBuilder: (_, _) => SizedBox(height: 10.h),
                          itemBuilder: (_, i) => LabourRow(
                            labour: list[i],
                            onActiveChanged: (val) async {
                              await ref
                                  .read(labourRepositoryProvider)
                                  .setActive(id: list[i].id, active: val);
                              ref.invalidate(labourListProvider);
                            },
                            onViewDocument: () => context.push(
                              RouteNames.labourDocuments,
                              extra: list[i],
                            ),
                            onEdit: () => context.push(
                              RouteNames.labourEdit,
                              extra: list[i],
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        shape: const CircleBorder(),
        onPressed: () => context.push(RouteNames.labourInduction),
        child: Icon(Icons.add_rounded, size: 28.sp),
      ),
    );
  }

  Widget _totalPill(AsyncValue<int> countAsync) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F4),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(Icons.groups_rounded, color: AppColors.primary, size: 20.sp),
          SizedBox(width: 8.w),
          Text('Total Labour Added: ', style: AppTextStyles.bodyBold),
          Text(
            countAsync.maybeWhen(data: (n) => '$n', orElse: () => '—'),
            style: AppTextStyles.bodyBold.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
