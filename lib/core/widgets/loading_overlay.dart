// File: lib/core/widgets/loading_overlay.dart
// Purpose: Full-screen blocking spinner overlay for in-progress operations.
// Used by: any screen waiting on an API call.

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.child,
    required this.loading,
  });

  final Widget child;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (loading)
          const ColoredBox(
            color: Color(0x66000000),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}
