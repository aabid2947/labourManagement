// File: lib/features/labour/presentation/widgets/labour_row.dart
// Purpose: One row in the Labour Induction list — avatar, name, role, active toggle,
//          "View Document" link, edit pencil. Matches page18.
// Used by: labour_list_screen.dart.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../data/labour_models.dart';

class LabourRow extends StatelessWidget {
  const LabourRow({
    super.key,
    required this.labour,
    required this.onActiveChanged,
    required this.onViewDocument,
    required this.onEdit,
  });

  final Labour labour;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onViewDocument;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: AppColors.avatarBg,
            child: Icon(Icons.person, color: AppColors.textSecondary, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          // Name + skill
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(labour.name,
                    style: AppTextStyles.bodyBold, overflow: TextOverflow.ellipsis),
                SizedBox(height: 2.h),
                Text(labour.skill,
                    style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          // Active / Inactive toggle column
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                labour.active ? 'Active' : 'Inactive',
                style: AppTextStyles.caption.copyWith(
                  color: labour.active
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: labour.active,
                  onChanged: onActiveChanged,
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.primary,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: AppColors.divider,
                ),
              ),
            ],
          ),
          SizedBox(width: 6.w),
          // View Document
          InkWell(
            onTap: onViewDocument,
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.description_outlined,
                      size: 20.sp, color: AppColors.primaryDark),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: 52.w,
                    child: Text(
                      'View\nDocument',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                          fontSize: 10.sp, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 4.w),
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined,
                color: AppColors.textPrimary, size: 22.sp),
            visualDensity: VisualDensity.compact,
            tooltip: 'Edit',
          ),
        ],
      ),
    );
  }
}
