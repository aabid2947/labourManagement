// File: lib/features/expense/presentation/widgets/expense_row.dart
// Purpose: One row in the My Expense list. Renders left-side checkbox only on the
//          Pending tab; Approved / Rejected / In Progress show the row without it.
// Used by: my_expense_screen.dart.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/expense_models.dart';

class ExpenseRow extends StatelessWidget {
  const ExpenseRow({
    super.key,
    required this.expense,
    required this.checkable,
    this.checked = false,
    this.onCheckChanged,
    this.onView,
  });

  final Expense expense;
  final bool checkable;
  final bool checked;
  final ValueChanged<bool>? onCheckChanged;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('dd MMM yyyy').format(expense.date).toUpperCase();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          if (checkable)
            _Checkbox(
              checked: checked,
              onChanged: onCheckChanged,
            ),
          if (checkable) SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(expense.category,
                    style: AppTextStyles.bodyBold,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 2.h),
                Text(dateStr,
                    style: AppTextStyles.caption,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onView,
            icon: Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: AppColors.primary, width: 1.2),
              ),
              child: Icon(Icons.visibility_outlined,
                  color: AppColors.primary, size: 16.sp),
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            Formatters.currency(expense.amount),
            style: AppTextStyles.bodyBold,
          ),
        ],
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.checked, required this.onChanged});
  final bool checked;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4.r),
      onTap: onChanged == null ? null : () => onChanged!(!checked),
      child: Container(
        width: 22.w,
        height: 22.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: checked ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(
            color: checked ? AppColors.primary : AppColors.divider,
            width: 1.4,
          ),
        ),
        child: checked
            ? Icon(Icons.check_rounded,
                color: AppColors.textOnPrimary, size: 16.sp)
            : null,
      ),
    );
  }
}
