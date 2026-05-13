// File: lib/core/widgets/app_date_picker.dart
// Purpose: DOB / From-Date / To-Date picker — opens material calendar, displays DD-MM-YY.
// Used by: New Labour Induction (DOB), Task vs Achievements (From / To filters).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../theme/text_styles.dart';
import '../utils/formatters.dart';

class AppDatePicker extends StatelessWidget {
  const AppDatePicker({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint = 'Select Date',
    this.firstDate,
    this.lastDate,
    this.required = false,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String hint;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool required;

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
        InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? now,
              firstDate: firstDate ?? DateTime(1950),
              lastDate: lastDate ?? DateTime(now.year + 5),
            );
            if (picked != null) onChanged(picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(Icons.calendar_today_outlined,
                  size: 18.sp, color: AppColors.textSecondary),
            ),
            child: Text(
              value == null ? hint : Formatters.date(value!),
              style: value == null
                  ? AppTextStyles.inputHint
                  : AppTextStyles.inputText,
            ),
          ),
        ),
      ],
    );
  }
}
