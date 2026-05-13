// File: lib/features/auth/presentation/widgets/mpin_keypad.dart
// Purpose: 3x4 numeric keypad used on Set MPIN / Confirm MPIN screens (page04 / page06).
// Used by: set_mpin_screen.dart, confirm_mpin_screen.dart.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

class MpinKeypad extends StatelessWidget {
  const MpinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final cells = <Widget>[];
    for (int i = 1; i <= 9; i++) {
      cells.add(_digit(i));
    }
    cells
      ..add(const SizedBox.shrink())
      ..add(_digit(0))
      ..add(_backspace());

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14.h,
      crossAxisSpacing: 14.w,
      childAspectRatio: 1.9,
      children: cells,
    );
  }

  Widget _digit(int n) {
    return _KeyCell(
      onTap: () => onDigit(n),
      child: Text(
        '$n',
        style: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _backspace() {
    return _KeyCell(
      onTap: onBackspace,
      child: Icon(Icons.backspace_outlined,
          color: AppColors.textPrimary, size: 22.sp),
    );
  }
}

class _KeyCell extends StatelessWidget {
  const _KeyCell({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.cardBorder),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
