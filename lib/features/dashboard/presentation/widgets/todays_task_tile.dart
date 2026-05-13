// File: lib/features/dashboard/presentation/widgets/todays_task_tile.dart
// Purpose: Yellow TODAY'S TASK banner from page10 with the subtle pulse/glow animation
//          requested by the client (PDF page 11 — "ek highlighter type dikhana hai").
// Used by: features/dashboard/presentation/screens/dashboard_screen.dart.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

class TodaysTaskTile extends StatefulWidget {
  const TodaysTaskTile({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<TodaysTaskTile> createState() => _TodaysTaskTileState();
}

class _TodaysTaskTileState extends State<TodaysTaskTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scale = Tween(begin: 1.0, end: 1.02)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _glow = Tween(begin: 0.18, end: 0.45)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Decorative tick marks like the screenshot's tiny rays.
        _rays(left: true),
        Expanded(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, child) {
              return Transform.scale(scale: _scale.value, child: child);
            },
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(14.r),
                child: AnimatedBuilder(
                  animation: _glow,
                  builder: (_, _) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary
                                .withValues(alpha: _glow.value),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: _content(),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        _rays(left: false),
      ],
    );
  }

  Widget _content() {
    return Row(
      children: [
        Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(Icons.event_note_rounded,
              color: AppColors.primaryDark, size: 22.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "TODAY'S TASK",
                style: AppTextStyles.bodyBold
                    .copyWith(color: AppColors.textOnPrimary),
              ),
              Text(
                'Tap to view your tasks for today',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textOnPrimary),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded,
            color: AppColors.textOnPrimary, size: 24.sp),
      ],
    );
  }

  Widget _rays({required bool left}) {
    return SizedBox(
      width: 12.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 2.h),
            width: 6.w,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
