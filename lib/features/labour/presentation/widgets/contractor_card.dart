// File: lib/features/labour/presentation/widgets/contractor_card.dart
// Purpose: Contractor identity card used at the top of Labour In / Labour Out lists.
//          If only ONE contractor is in scope it renders as a static card (matches
//          page22). With multiple it adds a down-arrow that opens a bottom-sheet picker.
// Used by: labour_in_screen.dart, labour_out_screen.dart.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../data/labour_models.dart';

class ContractorCard extends StatelessWidget {
  const ContractorCard({
    super.key,
    required this.contractors,
    required this.selected,
    required this.onSelect,
  });

  final List<Contractor> contractors;
  final Contractor? selected;
  final ValueChanged<Contractor> onSelect;

  bool get _isSwitchable => contractors.length > 1;

  Future<void> _pick(BuildContext context) async {
    final picked = await showModalBottomSheet<Contractor>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 8.h),
            Text('Select Contractor', style: AppTextStyles.sectionHeader),
            SizedBox(height: 8.h),
            for (final c in contractors)
              ListTile(
                leading: const Icon(Icons.business_outlined,
                    color: AppColors.primaryDark),
                title: Text(c.name, style: AppTextStyles.body),
                trailing: selected?.id == c.id
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(c),
              ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
    if (picked != null) onSelect(picked);
  }

  @override
  Widget build(BuildContext context) {
    final name = selected?.name ?? '—';
    final card = Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F4),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.groups_2_outlined,
                color: AppColors.textPrimary, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name,
                    style: AppTextStyles.bodyBold,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 2.h),
                Text(
                  selected == null
                      ? '—'
                      : 'Contractor ID - ${selected!.id.toUpperCase()}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          if (_isSwitchable)
            Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary, size: 24.sp),
        ],
      ),
    );
    if (!_isSwitchable) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => _pick(context),
        child: card,
      ),
    );
  }
}
