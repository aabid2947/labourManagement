// File: lib/routes/splash_screen.dart
// Purpose: Logo splash. Reads authBootstrapProvider then routes to MPIN Login (returning
//          user) or Login (no stored MPIN). Minimum 500ms display so the logo is visible.
// Used by: routes/app_router.dart.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/asset_paths.dart';
import '../core/theme/text_styles.dart';
import '../features/auth/providers/mpin_providers.dart';
import 'route_names.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _routed = false;

  Future<void> _decide() async {
    if (_routed) return;
    // Wait at least 500ms so the logo is visible, then dispatch by stored-MPIN state.
    final results = await Future.wait([
      ref.read(authBootstrapProvider.future),
      Future<void>.delayed(const Duration(milliseconds: 500)),
    ]);
    final decision = results[0] as AuthBootstrapDecision;
    if (!mounted || _routed) return;
    _routed = true;
    context.go(
      decision == AuthBootstrapDecision.mpinLogin
          ? RouteNames.mpinLogin
          : RouteNames.login,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    AssetPaths.tejGroupLogo,
                    height: 120.h,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    AppStrings.appName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                      letterSpacing: 0.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 12.h,
              left: 0,
              right: 0,
              child: Center(
                child: TextButton(
                  onPressed: () => context.go(RouteNames.themePreview),
                  child: Text('Theme Preview',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textDisabled)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
