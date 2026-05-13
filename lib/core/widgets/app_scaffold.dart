// File: lib/core/widgets/app_scaffold.dart
// Purpose: Consistent Scaffold wrapper — app bar, SafeArea, bottom padding for all screens.
// Used by: every feature screen.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../theme/text_styles.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.leading,
    this.actions,
    this.showBack = true,
    this.bottom,
    this.floatingActionButton,
    this.padding,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? bottom;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: title == null && leading == null && (actions?.isEmpty ?? true)
          ? null
          : AppBar(
              leading: leading ??
                  (showBack && Navigator.of(context).canPop()
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).maybePop(),
                        )
                      : null),
              automaticallyImplyLeading: false,
              title:
                  title == null ? null : Text(title!, style: AppTextStyles.appBarTitle),
              actions: actions,
              centerTitle: true,
            ),
      body: SafeArea(
        child: Padding(
          padding: padding ?? EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
          child: body,
        ),
      ),
      bottomNavigationBar: bottom,
      floatingActionButton: floatingActionButton,
    );
  }
}
