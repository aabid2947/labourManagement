// File: test/viewport_test.dart
// Purpose: Responsive guard — pumps a representative set of pure screens at the
//          narrowest (foldable folded) and small-phone viewports to surface
//          RenderFlex overflow errors before they ship.
// Used by: flutter test.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:labour_management/core/theme/app_theme.dart';
import 'package:labour_management/features/expense/presentation/screens/my_expense_screen.dart';
import 'package:labour_management/features/labour/presentation/screens/labour_in_screen.dart';
import 'package:labour_management/features/labour/presentation/screens/labour_out_screen.dart';
import 'package:labour_management/features/tasks/presentation/screens/task_vs_achievements_screen.dart';
import 'package:labour_management/features/tasks/presentation/screens/todays_task_screen.dart';

const _viewports = <(String, Size)>[
  ('foldable folded (narrow)', Size(280, 720)),
  ('small Android', Size(360, 640)),
  ('iPhone X (baseline)', Size(375, 812)),
  ('Pixel 5', Size(412, 915)),
  ('tablet portrait', Size(768, 1024)),
];

Widget _wrap(Widget child) {
  return ProviderScope(
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => MaterialApp(
        theme: AppTheme.light,
        home: child,
      ),
    ),
  );
}

Future<void> _pump(WidgetTester tester, Widget screen, Size size) async {
  tester.view.physicalSize = size * tester.view.devicePixelRatio;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_wrap(screen));
  await tester.pump(); // first frame
  await tester.pump(const Duration(milliseconds: 300)); // async providers
}

void main() {
  for (final (label, size) in _viewports) {
    group('viewport: $label (${size.width.toInt()}×${size.height.toInt()})', () {
      testWidgets('My Expense', (tester) async {
        await _pump(tester, const MyExpenseScreen(), size);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Labour In', (tester) async {
        await _pump(tester, const LabourInScreen(), size);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Labour Out', (tester) async {
        await _pump(tester, const LabourOutScreen(), size);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Task v/s Achievements', (tester) async {
        await _pump(tester, const TaskVsAchievementsScreen(), size);
        expect(tester.takeException(), isNull);
      });

      testWidgets("Today's Task", (tester) async {
        await _pump(tester, const TodaysTaskScreen(), size);
        expect(tester.takeException(), isNull);
      });
    });
  }
}
