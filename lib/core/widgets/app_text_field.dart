// File: lib/core/widgets/app_text_field.dart
// Purpose: Labeled text field matching the USER ID / PASSWORD / SELECT SITE blocks in screenshots.
// Used by: every form in the app.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../theme/text_styles.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.prefixIcon,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.maxLength,
    this.enabled = true,
    this.textInputAction,
    this.required = false,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool enabled;
  final TextInputAction? textInputAction;
  final bool required;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.label.toUpperCase(),
            style: AppTextStyles.inputLabel,
            children: [
              if (widget.required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onChanged: widget.onChanged,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: widget.hint,
            counterText: '',
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon,
                    color: AppColors.textSecondary, size: 20.sp),
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _obscured ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                      size: 20.sp,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
