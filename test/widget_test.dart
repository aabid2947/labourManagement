// File: test/widget_test.dart
// Purpose: Smoke test — verifies the root app builds and renders the splash brand.
//          (Routing past splash depends on flutter_secure_storage which isn't available
//          in widget tests — covered by integration tests in Prompt 13.)
// Used by: flutter test.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:labour_management/app/app.dart';

void main() {
  testWidgets('App boots and shows the brand on splash',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: LabourManagementApp()),
    );
    await tester.pump();
    expect(find.text('S-Square Manpower Services'), findsOneWidget);
    // Drain the splash's 500ms delay + any settled rebuilds so no timers leak.
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });
}
