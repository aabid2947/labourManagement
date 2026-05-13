// File: lib/core/widgets/section_card.dart
// Purpose: Rounded white card with subtle border — dashboard tiles / labour rows / expense rows.
// Used by: dashboard, expense list, labour list, task list, etc.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.r);
    final card = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? AppColors.cardBorder),
      ),
      padding: padding ?? EdgeInsets.all(14.w),
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: card,
      ),
    );
  }
}
