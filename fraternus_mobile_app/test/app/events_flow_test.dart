import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/app/fraternus_app.dart';

import 'app_test_harness.dart';

void main() {
  setUp(resetSharedPreferences);

  testWidgets('Events tab lists events and pushes a detail screen on tap', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: testOverrides(), child: const FraternusApp()),
    );
    await tester.pumpAndSettle();

    // Only the bottom-tab label reads "EVENTS" until the tab is active.
    await tester.tap(find.text('EVENTS'));
    await tester.pumpAndSettle();

    expect(find.text('Captain Meeting'), findsOneWidget);
    expect(find.text('CANCELLED'), findsOneWidget);
    expect(find.text('HAWC Night'), findsOneWidget);
    expect(find.text('Frat Night — Virtue of Fortitude'), findsOneWidget);
    expect(find.text('Excursion - Buffalo River'), findsOneWidget);
    expect(find.text('Ranch'), findsOneWidget);

    await tester.tap(find.text('HAWC Night'));
    await tester.pumpAndSettle();

    // "EVENTS" now renders twice: the bottom-tab label and the "< EVENTS"
    // back breadcrumb on the detail screen.
    expect(find.text('EVENTS'), findsNWidgets(2));
    expect(find.text('HAWC NIGHT'), findsOneWidget);
    expect(find.text('RSVP'), findsOneWidget);
    expect(find.text('OTHERS ATTENDING'), findsOneWidget);
  });
}
