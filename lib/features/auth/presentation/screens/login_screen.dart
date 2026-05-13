// File: lib/features/auth/presentation/screens/login_screen.dart
// Purpose: Pixel-matched Login screen from page02_img01.jpeg — username + password + site +
//          biometric (tap-only) + Contact Admin link. Routes to Set MPIN on success.
// Used by: routes/app_router.dart at RouteNames.login.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../routes/route_names.dart';
import '../../providers/auth_providers.dart';
import '../widgets/brand_header.dart';
import 'contact_admin_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  String? _site;

  // Hardcoded placeholder list — real list comes from `GET /sites` later.
  static const _sites = <String>[
    'Project Alpha',
    'Project Beta',
    'Project Gamma',
  ];

  @override
  void dispose() {
    _userIdCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(loginControllerProvider.notifier);
    final result = await controller.login(
      username: _userIdCtrl.text.trim(),
      password: _pwdCtrl.text,
      siteId: _site!,
    );
    if (!mounted || result == null) return;
    // Successful login → Set MPIN (real bootstrap arrives in Prompt 4).
    context.go(RouteNames.createMpin);
  }

  Future<void> _onBiometric() async {
    // The brief is explicit: biometric setup / prompt fires ONLY on tap.
    final svc = ref.read(biometricServiceProvider);
    final available = await svc.isAvailable();
    if (!mounted) return;
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometric is not set up on this device.'),
        ),
      );
      return;
    }
    final ok = await svc.authenticate(reason: 'Sign in with biometric');
    if (!mounted || !ok) return;
    // After a successful biometric, if a stored MPIN exists Prompt 4 will route to dashboard.
    // For Prompt 3 we just bounce to the MPIN flow.
    context.go(RouteNames.createMpin);
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LoadingOverlay(
        loading: loginState.loading,
        child: SafeArea(
          child: Column(
            children: [
              const BrandHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Welcome User!', style: AppTextStyles.screenTitle),
                          SizedBox(height: 6.h),
                          Text(
                            'Sign in to continue to your account',
                            style: AppTextStyles.caption,
                          ),
                          SizedBox(height: 24.h),
                          AppTextField(
                            label: 'User ID',
                            hint: 'Enter User ID',
                            prefixIcon: Icons.person_outline,
                            controller: _userIdCtrl,
                            textInputAction: TextInputAction.next,
                            validator: (v) =>
                                Validators.required(v, field: 'User ID'),
                          ),
                          SizedBox(height: 16.h),
                          AppTextField(
                            label: 'Password',
                            hint: 'Enter Password',
                            prefixIcon: Icons.lock_outline,
                            obscure: true,
                            controller: _pwdCtrl,
                            textInputAction: TextInputAction.next,
                            validator: (v) => Validators.minLength(v, 4,
                                field: 'Password'),
                          ),
                          SizedBox(height: 16.h),
                          AppDropdown<String>(
                            label: 'Select Site',
                            hint: 'Select Site',
                            prefixIcon: Icons.location_on_outlined,
                            value: _site,
                            items: _sites,
                            itemLabel: (s) => s,
                            onChanged: (s) => setState(() => _site = s),
                            validator: (v) =>
                                v == null ? 'Please select a site' : null,
                          ),
                          SizedBox(height: 24.h),
                          PrimaryButton(label: 'LOGIN', onPressed: _onLogin),
                          SizedBox(height: 18.h),
                          _orDivider(),
                          SizedBox(height: 18.h),
                          _biometricButton(),
                          SizedBox(height: 24.h),
                          Center(child: _contactAdminLink()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: const FooterCopyright(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text('OR LOGIN WITH', style: AppTextStyles.caption),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }

  Widget _biometricButton() {
    return InkWell(
      onTap: _onBiometric,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.fingerprint,
                  color: AppColors.primaryDark, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Text('Biometric', style: AppTextStyles.bodyBold),
          ],
        ),
      ),
    );
  }

  Widget _contactAdminLink() {
    return RichText(
      text: TextSpan(
        text: "Don't have an account? ",
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => ContactAdminSheet.show(context),
              child: Text(
                'Contact Admin',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
