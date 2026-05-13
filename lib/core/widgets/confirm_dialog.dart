// File: lib/core/widgets/confirm_dialog.dart
// Purpose: Yes/No confirmation dialog — used for "Are you sure you want to claim?" etc.
// Used by: expense claim flow (Prompt 11), and any other destructive confirmation.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../theme/text_styles.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.message,
    this.title,
    this.yesLabel = AppStrings.yes,
    this.noLabel = AppStrings.no,
  });

  final String message;
  final String? title;
  final String yesLabel;
  final String noLabel;

  static Future<bool> show(
    BuildContext context, {
    required String message,
    String? title,
    String yesLabel = AppStrings.yes,
    String noLabel = AppStrings.no,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        message: message,
        title: title,
        yesLabel: yesLabel,
        noLabel: noLabel,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
      contentPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
      title: title == null
          ? null
          : Text(title!, style: AppTextStyles.sectionHeader),
      content: Text(message, style: AppTextStyles.body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(noLabel,
              style: AppTextStyles.button
                  .copyWith(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(yesLabel,
              style:
                  AppTextStyles.button.copyWith(color: AppColors.primaryDark)),
        ),
      ],
    );
  }
}
