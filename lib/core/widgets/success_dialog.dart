// File: lib/core/widgets/success_dialog.dart
// Purpose: Single-action success popup — used for attendance / remark / claim confirmations.
// Used by: self-attendance, labour in / out, task remark, add expense flows.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../theme/text_styles.dart';

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({
    super.key,
    required this.message,
    this.title,
    this.okLabel = AppStrings.ok,
  });

  final String message;
  final String? title;
  final String okLabel;

  static Future<void> show(
    BuildContext context, {
    required String message,
    String? title,
    String okLabel = AppStrings.ok,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) =>
          SuccessDialog(message: message, title: title, okLabel: okLabel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 8.h),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 48.sp),
          ),
          SizedBox(height: 16.h),
          if (title != null) ...[
            Text(title!,
                style: AppTextStyles.sectionHeader, textAlign: TextAlign.center),
            SizedBox(height: 8.h),
          ],
          Text(message,
              style: AppTextStyles.body, textAlign: TextAlign.center),
        ],
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(okLabel,
                style: AppTextStyles.button
                    .copyWith(color: AppColors.primaryDark)),
          ),
        ),
      ],
    );
  }
}
