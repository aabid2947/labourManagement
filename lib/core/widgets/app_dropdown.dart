// File: lib/core/widgets/app_dropdown.dart
// Purpose: Generic dropdown styled like SELECT SITE / Select Contractor in screenshots.
// Used by: Login, Dashboard, Labour list, New Labour Induction.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../theme/text_styles.dart';

class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.hint,
    this.prefixIcon,
    this.required = false,
    this.validator,
  });

  final String label;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final T? value;
  final String? hint;
  final IconData? prefixIcon;
  final bool required;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.toUpperCase(),
            style: AppTextStyles.inputLabel,
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary, size: 22.sp),
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, color: AppColors.textSecondary, size: 20.sp),
          ),
          validator: validator,
          items: items
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(itemLabel(e), style: AppTextStyles.inputText),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
