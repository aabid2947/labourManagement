// File: lib/features/expense/presentation/screens/my_expense_screen.dart
// Purpose: Pixel-matched My Expense (Book Expense) from page36_img01.jpeg.
//          Adds an "In Progress" tab between Pending and Approved per the brief.
// Used by: routes/app_router.dart at RouteNames.myExpense.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/success_dialog.dart';
import '../../../../routes/route_names.dart';
import '../../data/expense_models.dart';
import '../../providers/expense_providers.dart';
import '../widgets/expense_row.dart';

class MyExpenseScreen extends ConsumerWidget {
  const MyExpenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(expenseSummaryProvider);
    final tab = ref.watch(selectedExpenseTabProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(RouteNames.dashboard),
        ),
        title: Text('BOOK EXPENSE',
            style: AppTextStyles.appBarTitle
                .copyWith(letterSpacing: 0.6)),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.avatarBg,
              child: Icon(Icons.person,
                  color: AppColors.textSecondary, size: 18.sp),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _summaryCard(summaryAsync),
              SizedBox(height: 16.h),
              _tabBar(ref, tab),
              SizedBox(height: 12.h),
              Expanded(child: _tabBody(ref, context, tab)),
              if (tab == ExpenseStatus.pending) ...[
                SizedBox(height: 10.h),
                _bottomRow(context, ref),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(AsyncValue<ExpenseSummary> async) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Stack(
        children: [
          // Yellow left accent bar.
          Positioned.fill(
            left: -14,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 4.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(4.r)),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TOTAL EXPENSE',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      async.maybeWhen(
                        data: (s) => Formatters.currency(s.total),
                        orElse: () => '—',
                      ),
                      style: AppTextStyles.screenTitle.copyWith(fontSize: 28.sp),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.book_outlined,
                        color: AppColors.textOnPrimary, size: 16.sp),
                    SizedBox(width: 6.w),
                    Text(
                      async.maybeWhen(
                        data: (s) => '${s.pendingCount} PENDING',
                        orElse: () => '— PENDING',
                      ),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabBar(WidgetRef ref, ExpenseStatus current) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final s in kExpenseTabs) ...[
            _tab(s, current == s, () =>
                ref.read(selectedExpenseTabProvider.notifier).select(s)),
            SizedBox(width: 8.w),
          ],
        ],
      ),
    );
  }

  Widget _tab(ExpenseStatus s, bool active, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: active ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              s.label.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                color: active ? AppColors.primaryDark : AppColors.textSecondary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
            if (active) ...[
              SizedBox(height: 4.h),
              Container(
                width: 16.w,
                height: 3.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tabBody(
    WidgetRef ref,
    BuildContext context,
    ExpenseStatus tab,
  ) {
    final async = ref.watch(expenseByStatusProvider(tab));
    final overlay = tab == ExpenseStatus.inProgress
        ? ref.watch(inProgressOverlayProvider)
        : const <Expense>[];
    final selectedIds = ref.watch(pendingSelectionProvider);
    final checkable = tab == ExpenseStatus.pending;

    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, _) => Center(
        child: Text('Failed to load: $e', style: AppTextStyles.body),
      ),
      data: (apiRows) {
        final rows = [...overlay, ...apiRows];
        if (rows.isEmpty) {
          return Center(
            child: Text(
              'No ${tab.label.toLowerCase()} expenses.',
              style: AppTextStyles.body,
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.only(bottom: 12.h),
          itemCount: rows.length,
          separatorBuilder: (_, _) => SizedBox(height: 10.h),
          itemBuilder: (_, i) => ExpenseRow(
            expense: rows[i],
            checkable: checkable,
            checked: selectedIds.contains(rows[i].id),
            onCheckChanged: checkable
                ? (_) => ref
                    .read(pendingSelectionProvider.notifier)
                    .toggle(rows[i].id)
                : null,
            onView: () {
              // TODO(api): wire detail view once GET /expense/{id} lands.
            },
          ),
        );
      },
    );
  }

  Widget _bottomRow(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _PlusButton(
          onTap: () => context.push(RouteNames.addExpense),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: PrimaryButton(
            label: 'CLAIM NOW',
            icon: Icons.send_rounded,
            onPressed: () => _onClaim(context, ref),
          ),
        ),
      ],
    );
  }

  Future<void> _onClaim(BuildContext context, WidgetRef ref) async {
    final selectedIds = ref.read(pendingSelectionProvider);
    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one expense to claim.')),
      );
      return;
    }
    final ok = await ConfirmDialog.show(
      context,
      title: 'Claim Expenses',
      message: AppStrings.claimConfirm,
    );
    if (!ok || !context.mounted) return;

    final pending = ref.read(expenseByStatusProvider(ExpenseStatus.pending)).value ?? [];
    final movers = pending
        .where((e) => selectedIds.contains(e.id))
        .map((e) => Expense(
              id: e.id,
              category: e.category,
              amount: e.amount,
              date: e.date,
              status: ExpenseStatus.inProgress,
              notes: e.notes,
              attachmentUrl: e.attachmentUrl,
            ))
        .toList(growable: false);

    final success = await ref
        .read(expenseRepositoryProvider)
        .claim(ids: selectedIds.toList());
    if (!context.mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Claim failed. Please try again.')),
      );
      return;
    }

    // Move locally: clear selection, add overlay onto In Progress, refresh Pending.
    ref.read(inProgressOverlayProvider.notifier).addAll(movers);
    ref.read(pendingSelectionProvider.notifier).clear();
    ref.invalidate(expenseByStatusProvider(ExpenseStatus.pending));
    ref.invalidate(expenseSummaryProvider);
    ref.read(selectedExpenseTabProvider.notifier).select(ExpenseStatus.inProgress);
  }
}

class _PlusButton extends StatelessWidget {
  const _PlusButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: onTap,
      child: Container(
        width: 52.h,
        height: 52.h,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10.r),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.add_rounded,
            color: AppColors.textOnPrimary, size: 26.sp),
      ),
    );
  }
}

// Unused private helper for SuccessDialog suppressed-import — keeps the dialog
// import available for future success flows on Approved/Rejected tabs.
// ignore: unused_element
Future<void> _showSuccess(BuildContext c, String msg) =>
    SuccessDialog.show(c, message: msg);
