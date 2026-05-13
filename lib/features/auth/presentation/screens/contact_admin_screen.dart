// File: lib/features/auth/presentation/screens/contact_admin_screen.dart
// Purpose: "Contact Admin" form — opened from the Login screen's footer link.
// Used by: login_screen.dart.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/success_dialog.dart';
import '../../providers/auth_providers.dart';

class ContactAdminSheet extends ConsumerStatefulWidget {
  const ContactAdminSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const ContactAdminSheet(),
    );
  }

  @override
  ConsumerState<ContactAdminSheet> createState() => _ContactAdminSheetState();
}

class _ContactAdminSheetState extends ConsumerState<ContactAdminSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final repo = ref.read(authRepositoryProvider);
    final ok = await repo.contactAdmin(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.of(context).pop();
    if (ok) {
      await SuccessDialog.show(
        context,
        title: 'Request Sent',
        message: 'Admin has been notified. They will reach out shortly.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text('Contact Admin', style: AppTextStyles.screenTitle),
                SizedBox(height: 4.h),
                Text(
                  'Share your details and the admin will get in touch.',
                  style: AppTextStyles.caption,
                ),
                SizedBox(height: 20.h),
                AppTextField(
                  label: 'Name',
                  hint: 'Enter your name',
                  required: true,
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.required(v, field: 'Name'),
                ),
                SizedBox(height: 16.h),
                AppTextField(
                  label: 'Email',
                  hint: 'name@example.com',
                  required: true,
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: Validators.email,
                ),
                SizedBox(height: 24.h),
                PrimaryButton(
                  label: AppStrings.submit,
                  loading: _submitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
