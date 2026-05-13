// File: lib/features/auth/presentation/screens/mpin_login_screen.dart
// Purpose: Returning-user MPIN login. Header uses the shared BrandHeader (new logo
//          + S-Square Manpower Services + bell). Shield illustration sits over a
//          subtle peach/cream gradient. Reference: bug_images/bug_page16_img01.jpeg.
//          5 wrong attempts triggers a 30-second lockout (frontend-only).
// Used by: routes/app_router.dart at RouteNames.mpinLogin.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../routes/route_names.dart';
import '../../providers/auth_providers.dart';
import '../../providers/mpin_providers.dart';
import '../widgets/brand_header.dart';
import '../widgets/mpin_dots.dart';

class MpinLoginScreen extends ConsumerStatefulWidget {
  const MpinLoginScreen({super.key});

  @override
  ConsumerState<MpinLoginScreen> createState() => _MpinLoginScreenState();
}

class _MpinLoginScreenState extends ConsumerState<MpinLoginScreen> {
  // TODO(api): GET /sites — response: [{id, name}]
  static const _sites = <String>[
    'Project Alpha',
    'Project Beta',
    'Project Gamma',
  ];
  String? _site = _sites.first;

  final _focusNode = FocusNode();
  final _hiddenCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _hiddenCtrl.dispose();
    super.dispose();
  }

  Future<void> _onChanged(String value) async {
    final notifier = ref.read(mpinLoginControllerProvider.notifier);
    final state = ref.read(mpinLoginControllerProvider);
    if (state.isLocked) {
      _hiddenCtrl.text = '';
      return;
    }
    // Sync hidden field length with controller state for backspace handling.
    if (value.length < state.entered.length) {
      notifier.backspace();
    } else if (value.length > state.entered.length && value.isNotEmpty) {
      final ch = value.characters.last;
      final digit = int.tryParse(ch);
      if (digit != null) notifier.appendDigit(digit);
    }
    final next = ref.read(mpinLoginControllerProvider);
    if (next.entered.length == mpinLength) {
      final ok = await notifier.verify();
      if (!mounted) return;
      _hiddenCtrl.text = '';
      if (ok) context.go(RouteNames.dashboard);
    }
  }

  Future<void> _onFingerprint() async {
    final svc = ref.read(biometricServiceProvider);
    final available = await svc.isAvailable();
    if (!mounted) return;
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric is not set up on this device.')),
      );
      return;
    }
    final ok = await svc.authenticate(reason: 'Sign in with fingerprint');
    if (!mounted || !ok) return;
    context.go(RouteNames.dashboard);
  }

  void _onForgotMpin() {
    // Per brief: route back to the username + password Login screen.
    ref.read(mpinLoginControllerProvider.notifier).resetEntered();
    context.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mpinLoginControllerProvider);
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const BrandHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 8.h),
                    _shieldWithBackdrop(),
                    SizedBox(height: 12.h),
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: AppTextStyles.screenTitle,
                          children: [
                            const TextSpan(text: 'Welcome\n'),
                            TextSpan(
                              text: 'USER',
                              style: AppTextStyles.screenTitle.copyWith(
                                color: AppColors.primary,
                                fontSize: 28.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    AppDropdown<String>(
                      label: 'Select Site',
                      hint: 'Select Site',
                      prefixIcon: Icons.location_on_outlined,
                      value: _site,
                      items: _sites,
                      itemLabel: (s) => s,
                      onChanged: (s) => setState(() => _site = s),
                    ),
                    SizedBox(height: 24.h),
                    Text('Please enter your MPIN',
                        style: AppTextStyles.bodyBold,
                        textAlign: TextAlign.start),
                    SizedBox(height: 12.h),
                    GestureDetector(
                      onTap: () => FocusScope.of(context).requestFocus(_focusNode),
                      child: MpinBoxes(
                        length: mpinLength,
                        filled: state.entered.length,
                      ),
                    ),
                    // Hidden field captures keystrokes so the OS keyboard does the typing.
                    SizedBox(
                      height: 0,
                      child: Opacity(
                        opacity: 0,
                        child: TextField(
                          controller: _hiddenCtrl,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.number,
                          maxLength: mpinLength,
                          enabled: !state.isLocked && !state.verifying,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(mpinLength),
                          ],
                          onChanged: _onChanged,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (state.error != null)
                      Center(
                        child: Text(state.error!, style: AppTextStyles.errorText),
                      ),
                    if (state.isLocked)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Center(
                          child: Text(
                            'Locked. Retry in ${state.secondsRemaining}s.',
                            style: AppTextStyles.caption,
                          ),
                        ),
                      ),
                    SizedBox(height: 12.h),
                    Center(
                      child: GestureDetector(
                        onTap: _onForgotMpin,
                        child: Text('Forgot MPIN?', style: AppTextStyles.linkText),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.divider)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Text('Or', style: AppTextStyles.caption),
                        ),
                        const Expanded(child: Divider(color: AppColors.divider)),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _fingerprintButton(),
                    SizedBox(height: 16.h),
                    Center(
                      child: Text('Version 1.0.0',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textDisabled)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shield illustration over a subtle peach/cream backdrop.
  /// Matches `bug_page16_img01.jpeg` — the shield silhouette is the icon itself
  /// (no surrounding green square) and the warm tint behind it reads as a
  /// gentle "sunrise" rather than a filled rectangle.
  Widget _shieldWithBackdrop() {
    return SizedBox(
      height: 200.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft peach/cream wash — surface -> primary-soft -> surface.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.surface,
                    AppColors.primarySoft.withValues(alpha: 0.55),
                    AppColors.surface,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          // Shield silhouette — Material's shield-with-check icon, no wrapper box.
          Icon(
            Icons.verified_user_rounded,
            size: 150.sp,
            color: AppColors.success,
            shadows: [
              Shadow(
                color: AppColors.success.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fingerprintButton() {
    return InkWell(
      onTap: _onFingerprint,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.primary, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.fingerprint,
                  color: AppColors.textOnPrimary, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Text(
              'Login with your Fingerprint',
              style: AppTextStyles.bodyBold.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
