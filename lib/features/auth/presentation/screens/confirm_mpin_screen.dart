// File: lib/features/auth/presentation/screens/confirm_mpin_screen.dart
// Purpose: Pixel-matched Confirm MPIN screen from page06_img01.jpeg.
//          User re-enters the MPIN; on match it is hashed + stored, then routed to Dashboard.
// Used by: routes/app_router.dart at RouteNames.confirmMpin.

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

class ConfirmMpinScreen extends ConsumerStatefulWidget {
  const ConfirmMpinScreen({super.key});

  @override
  ConsumerState<ConfirmMpinScreen> createState() => _ConfirmMpinScreenState();
}

class _ConfirmMpinScreenState extends ConsumerState<ConfirmMpinScreen> {
  String _entered = '';
  String? _error;
  bool _saving = false;

  void _onDigit(int d) {
    if (_saving) return;
    if (_entered.length >= mpinLength) return;
    setState(() {
      _entered += d.toString();
      _error = null;
    });
    if (_entered.length == mpinLength) _attemptConfirm();
  }

  void _onBackspace() {
    if (_saving) return;
    if (_entered.isEmpty) return;
    setState(() {
      _entered = _entered.substring(0, _entered.length - 1);
      _error = null;
    });
  }

  Future<void> _attemptConfirm() async {
    final draft = ref.read(mpinDraftProvider);
    if (draft == null) {
      // Someone deep-linked here without setting first — bounce them back.
      if (!mounted) return;
      context.go(RouteNames.createMpin);
      return;
    }
    if (draft.value != _entered) {
      setState(() {
        _error = 'MPINs do not match. Please try again.';
        _entered = '';
      });
      return;
    }
    setState(() => _saving = true);
    await ref.read(authStorageProvider).writeMpin(_entered);
    ref.read(mpinDraftProvider.notifier).clear();
    if (!mounted) return;
    context.go(RouteNames.dashboard);
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
                    Text('Confirm MPIN', style: AppTextStyles.screenTitle),
                    SizedBox(height: 8.h),
                    Text(
                      'Re-enter your 4-digit MPIN to confirm',
                      style: AppTextStyles.caption,
                    ),
                    SizedBox(height: 32.h),
                    MpinDots(length: mpinLength, filled: _entered.length),
                    SizedBox(height: 12.h),
                    if (_error != null)
                      Center(
                        child: Text(_error!, style: AppTextStyles.errorText),
                      ),
                    SizedBox(height: 24.h),
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
