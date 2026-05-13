// File: lib/features/auth/presentation/screens/set_mpin_screen.dart
// Purpose: Pixel-matched Set MPIN screen from page04_img01.jpeg.
//          User enters a 4-digit MPIN → routed to Confirm MPIN.
// Used by: routes/app_router.dart at RouteNames.createMpin.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../routes/route_names.dart';
import '../../providers/mpin_providers.dart';
import '../widgets/brand_header.dart';
import '../widgets/mpin_dots.dart';
import '../widgets/mpin_keypad.dart';

class SetMpinScreen extends ConsumerStatefulWidget {
  const SetMpinScreen({super.key});

  @override
  ConsumerState<SetMpinScreen> createState() => _SetMpinScreenState();
}

class _SetMpinScreenState extends ConsumerState<SetMpinScreen> {
  String _entered = '';

  void _onDigit(int d) {
    if (_entered.length >= mpinLength) return;
    setState(() => _entered += d.toString());
    if (_entered.length == mpinLength) {
      // Stash the draft, hand off to Confirm.
      ref.read(mpinDraftProvider.notifier).set(_entered);
      Future<void>.microtask(() {
        if (!mounted) return;
        context.go(RouteNames.confirmMpin);
      });
    }
  }

  void _onBackspace() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const BrandHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Set MPIN', style: AppTextStyles.screenTitle),
                    SizedBox(height: 8.h),
                    Text(
                      'Create a 4-digit MPIN to secure your account',
                      style: AppTextStyles.caption,
                    ),
                    SizedBox(height: 32.h),
                    MpinDots(length: mpinLength, filled: _entered.length),
                    SizedBox(height: 36.h),
                    MpinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
