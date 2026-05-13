// File: lib/core/utils/responsive_helper.dart
// Purpose: Breakpoint helpers on top of flutter_screenutil for foldable / small / large screens.
// Used by: any widget that needs to branch layout by screen width.

import 'package:flutter/widgets.dart';

class Responsive {
  static double width(BuildContext c) => MediaQuery.of(c).size.width;
  static double height(BuildContext c) => MediaQuery.of(c).size.height;

  static bool isNarrow(BuildContext c) => width(c) < 320;
  static bool isPhone(BuildContext c) => width(c) >= 320 && width(c) < 600;
  static bool isFoldableOpen(BuildContext c) =>
      width(c) >= 600 && width(c) < 900;
  static bool isTablet(BuildContext c) => width(c) >= 900;
}
