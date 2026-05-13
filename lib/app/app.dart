// File: lib/app/app.dart
// Purpose: Root widget — wires ScreenUtilInit, MaterialApp.router, theme, and GoRouter.
// Used by: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/theme/app_theme.dart';
import '../routes/app_router.dart';

class LabourManagementApp extends StatelessWidget {
  const LabourManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Labour Management',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
