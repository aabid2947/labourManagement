// File: lib/features/auth/presentation/widgets/brand_header.dart
// Purpose: "TEJ GROUP | S-Square Manpower Services" header strip rendered with the
//          real logo asset. Reused by Login, Set MPIN, Confirm MPIN, MPIN Login.
// Used by: login_screen, set_mpin, confirm_mpin, mpin_login.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/text_styles.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.companyName = 'S-Square Manpower Services'});
  final String companyName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            AssetPaths.tejGroupLogo,
            height: 44.h,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          SizedBox(width: 10.w),
          Container(width: 1, height: 32.h, color: AppColors.divider),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              companyName,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
                height: 1.15,
              ),
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_none_rounded,
                  size: 26.sp, color: AppColors.textPrimary),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FooterCopyright extends StatelessWidget {
  const FooterCopyright({super.key, this.version = 'v1.0.0'});
  final String version;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('© 2024 S-Square Manpower Services. All rights reserved.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center),
        SizedBox(height: 2.h),
        Text(version,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textDisabled)),
      ],
    );
  }
}
