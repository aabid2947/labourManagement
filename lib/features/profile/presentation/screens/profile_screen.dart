// File: lib/features/profile/presentation/screens/profile_screen.dart
// Purpose: Engineer Profile screen built to match bug_images/bug_page28_img01.jpeg.
//          Renders the profile photo (yellow ring + verified badge), name, role,
//          ID pill, divider, and Sign Out Account button on one elevated white card.
// Used by: routes/app_router.dart at RouteNames.profile.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../auth/providers/mpin_providers.dart';
import '../../../../routes/route_names.dart';
import '../../data/profile_models.dart';
import '../../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          tooltip: 'Menu',
          // No drawer on this screen — defer to the dashboard's drawer for
          // navigation. Pop back so the user can open it from there.
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(RouteNames.dashboard),
        ),
        title: Text('Engineer Profile', style: AppTextStyles.appBarTitle),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            // TODO: settings deep-link once the Settings screen lands.
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
          child: profileAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, _) => Center(
              child: Text('Failed to load profile: $e',
                  style: AppTextStyles.body),
            ),
            data: (profile) => _ProfileBody(profile: profile),
          ),
        ),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile});
  final UserProfile profile;

  Future<void> _onSignOut(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    final keepMpin = !(await ConfirmDialog.show(
      context,
      title: 'Sign Out',
      message: 'Also forget your MPIN? Choosing No keeps quick MPIN sign-in.',
      yesLabel: 'Forget MPIN',
      noLabel: 'Keep MPIN',
    ));
    if (!context.mounted) return;

    await ref.read(authRepositoryProvider).logout();
    if (!keepMpin) {
      await ref.read(authStorageProvider).clearMpin();
    }
    if (!context.mounted) return;
    navigator.context;
    context.go(keepMpin ? RouteNames.mpinLogin : RouteNames.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 12.h),
                _profileCard(context, ref),
                SizedBox(height: 24.h),
                _footer(),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileCard(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _profilePhoto()),
          SizedBox(height: 18.h),
          Center(
            child: Text(
              profile.name,
              style: AppTextStyles.screenTitle.copyWith(fontSize: 28.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 4.h),
          Center(
            child: Text(
              profile.role,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary, fontSize: 15.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 14.h),
          Center(child: _idPill()),
          SizedBox(height: 22.h),
          const Divider(color: AppColors.divider, height: 1),
          SizedBox(height: 18.h),
          _signOutButton(context, ref),
        ],
      ),
    );
  }

  Widget _profilePhoto() {
    final size = 140.w;
    final hasUrl =
        profile.avatarUrl != null && profile.avatarUrl!.trim().isNotEmpty;
    return SizedBox(
      width: size + 12,
      height: size + 12,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Outer yellow ring.
          Container(
            width: size + 12,
            height: size + 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
            ),
          ),
          // Photo / icon fallback.
          Positioned(
            left: 6,
            top: 6,
            child: Container(
              width: size,
              height: size,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: AppColors.avatarBg,
                shape: BoxShape.circle,
              ),
              child: hasUrl
                  ? CachedNetworkImage(
                      imageUrl: profile.avatarUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _glyph(size),
                      placeholder: (_, _) => _glyph(size),
                    )
                  : _glyph(size),
            ),
          ),
          // Verified badge — small yellow disc with a white check at bottom-right.
          Positioned(
            right: 4,
            bottom: 8,
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
              child: Icon(Icons.check_rounded,
                  color: AppColors.surface, size: 18.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glyph(double size) => Center(
        child: Icon(Icons.person,
            color: AppColors.primaryDark, size: size * 0.55),
      );

  Widget _idPill() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F4),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.badge_outlined,
              size: 16.sp, color: AppColors.textSecondary),
          SizedBox(width: 8.w),
          Text(
            'ID: #${profile.id}',
            style: AppTextStyles.bodyBold.copyWith(
              fontSize: 13.sp,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _signOutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 52.h,
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => _onSignOut(context, ref),
        icon: Icon(Icons.logout_rounded,
            color: AppColors.textPrimary, size: 20.sp),
        label: Text(
          'Sign Out Account',
          style: AppTextStyles.bodyBold
              .copyWith(color: AppColors.textPrimary, fontSize: 15.sp),
        ),
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFF1F2F4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _footer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.precision_manufacturing_outlined,
            size: 24.sp, color: AppColors.textDisabled),
        SizedBox(height: 4.h),
        Text(
          'INDUSTRIAL SITE MANAGEMENT V2.4',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textDisabled,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
