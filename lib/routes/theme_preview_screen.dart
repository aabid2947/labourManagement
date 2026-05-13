// File: lib/routes/theme_preview_screen.dart
// Purpose: Debug-only gallery rendering every shared widget for visual QA against screenshots.
// Used by: routes/app_router.dart at path RouteNames.themePreview.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/text_styles.dart';
import '../core/utils/validators.dart';
import '../core/widgets/app_date_picker.dart';
import '../core/widgets/app_dropdown.dart';
import '../core/widgets/app_scaffold.dart';
import '../core/widgets/app_text_field.dart';
import '../core/widgets/confirm_dialog.dart';
import '../core/widgets/loading_overlay.dart';
import '../core/widgets/primary_button.dart';
import '../core/widgets/secondary_button.dart';
import '../core/widgets/section_card.dart';
import '../core/widgets/success_dialog.dart';

class ThemePreviewScreen extends StatefulWidget {
  const ThemePreviewScreen({super.key});

  @override
  State<ThemePreviewScreen> createState() => _ThemePreviewScreenState();
}

class _ThemePreviewScreenState extends State<ThemePreviewScreen> {
  final _userIdCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _site;
  DateTime? _dob;
  bool _loading = false;

  @override
  void dispose() {
    _userIdCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final swatches = <_Swatch>[
      _Swatch('primary', AppColors.primary),
      _Swatch('primaryDark', AppColors.primaryDark),
      _Swatch('primarySoft', AppColors.primarySoft),
      _Swatch('background', AppColors.background),
      _Swatch('surface', AppColors.surface),
      _Swatch('success', AppColors.success),
      _Swatch('info', AppColors.info),
      _Swatch('error', AppColors.error),
      _Swatch('divider', AppColors.divider),
      _Swatch('textPrimary', AppColors.textPrimary),
      _Swatch('textSecondary', AppColors.textSecondary),
      _Swatch('textDisabled', AppColors.textDisabled),
    ];

    return AppScaffold(
      title: 'Theme Preview',
      body: LoadingOverlay(
        loading: _loading,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Palette', style: AppTextStyles.screenTitle),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: swatches.map(_swatchTile).toList(),
                ),
                SizedBox(height: 24.h),
                Text('Typography', style: AppTextStyles.screenTitle),
                SizedBox(height: 8.h),
                Text('Screen title', style: AppTextStyles.screenTitle),
                Text('Section header', style: AppTextStyles.sectionHeader),
                Text('Body text — the quick brown fox',
                    style: AppTextStyles.body),
                Text('Body bold', style: AppTextStyles.bodyBold),
                Text('Caption / secondary', style: AppTextStyles.caption),
                Text('Error text', style: AppTextStyles.errorText),
                SizedBox(height: 24.h),
                Text('Buttons', style: AppTextStyles.screenTitle),
                SizedBox(height: 12.h),
                PrimaryButton(label: 'LOGIN', onPressed: () {}),
                SizedBox(height: 12.h),
                PrimaryButton(
                  label: 'LOADING',
                  loading: true,
                  onPressed: () {},
                ),
                SizedBox(height: 12.h),
                const PrimaryButton(label: 'DISABLED', onPressed: null),
                SizedBox(height: 12.h),
                SecondaryButton(
                  label: 'Biometric',
                  icon: Icons.fingerprint,
                  onPressed: () {},
                ),
                SizedBox(height: 24.h),
                Text('Inputs', style: AppTextStyles.screenTitle),
                SizedBox(height: 12.h),
                AppTextField(
                  label: 'User ID',
                  hint: 'Enter User ID',
                  prefixIcon: Icons.person_outline,
                  required: true,
                  controller: _userIdCtrl,
                  validator: (v) => Validators.required(v, field: 'User ID'),
                ),
                SizedBox(height: 16.h),
                AppTextField(
                  label: 'Password',
                  hint: 'Enter Password',
                  prefixIcon: Icons.lock_outline,
                  obscure: true,
                  required: true,
                  controller: _pwdCtrl,
                  validator: (v) =>
                      Validators.minLength(v, 6, field: 'Password'),
                ),
                SizedBox(height: 16.h),
                AppDropdown<String>(
                  label: 'Select Site',
                  hint: 'Select Site',
                  prefixIcon: Icons.location_on_outlined,
                  required: true,
                  value: _site,
                  items: const ['Project Alpha', 'Project Beta', 'Project Gamma'],
                  itemLabel: (s) => s,
                  onChanged: (s) => setState(() => _site = s),
                ),
                SizedBox(height: 16.h),
                AppDatePicker(
                  label: 'DOB',
                  value: _dob,
                  required: true,
                  onChanged: (d) => setState(() => _dob = d),
                ),
                SizedBox(height: 24.h),
                Text('Cards', style: AppTextStyles.screenTitle),
                SizedBox(height: 12.h),
                SectionCard(
                  onTap: () {},
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: const Icon(Icons.people_alt_outlined,
                            color: AppColors.primaryDark),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('48', style: AppTextStyles.screenTitle),
                            Text('TOTAL LABOUR STRENGTH',
                                style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Text('Dialogs', style: AppTextStyles.screenTitle),
                SizedBox(height: 12.h),
                SecondaryButton(
                  label: 'Show ConfirmDialog',
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final ok = await ConfirmDialog.show(
                      context,
                      message: AppStrings.claimConfirm,
                    );
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(content: Text('Confirmed: $ok')),
                    );
                  },
                ),
                SizedBox(height: 12.h),
                SecondaryButton(
                  label: 'Show SuccessDialog',
                  onPressed: () => SuccessDialog.show(
                    context,
                    message: AppStrings.attendanceSuccess,
                  ),
                ),
                SizedBox(height: 12.h),
                SecondaryButton(
                  label: 'Toggle LoadingOverlay (1.5s)',
                  onPressed: () async {
                    setState(() => _loading = true);
                    await Future<void>.delayed(const Duration(milliseconds: 1500));
                    if (mounted) setState(() => _loading = false);
                  },
                ),
                SizedBox(height: 24.h),
                PrimaryButton(
                  label: 'Validate Form',
                  onPressed: () => _formKey.currentState?.validate(),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _swatchTile(_Swatch s) {
    return Container(
      width: 96.w,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36.h,
            decoration: BoxDecoration(
              color: s.color,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: AppColors.divider),
            ),
          ),
          SizedBox(height: 4.h),
          Text(s.name, style: AppTextStyles.caption, maxLines: 1),
          Text(
            '#${s.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
            style: AppTextStyles.caption.copyWith(fontSize: 10.sp),
          ),
        ],
      ),
    );
  }
}

class _Swatch {
  const _Swatch(this.name, this.color);
  final String name;
  final Color color;
}
