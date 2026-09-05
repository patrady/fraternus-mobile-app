import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/app/fraternus_app.dart';

import 'app_test_harness.dart';

void main() {
  setUp(resetSharedPreferences);

  testWidgets('Today screen renders the weekly focus and tab bar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: testOverrides(), child: const FraternusApp()),
    );
    await tester.pumpAndSettle();

    // "TODAY" renders twice: the active bottom-tab label and the "Today"
    // section eyebrow above the person tabs.
    expect(find.text('TODAY'), findsNWidgets(2));
    expect(find.text('HUMILITY'), findsOneWidget);
    expect(find.text('GUIDE'), findsOneWidget);
    expect(find.text('CHALLENGE'), findsOneWidget);
    expect(find.text('EVENTS'), findsOneWidget);
  });

  testWidgets(
    'Tapping Today in the bottom nav returns to the Today root after a task push',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: testOverrides(), child: const FraternusApp()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Weekly Challenge'));
      await tester.pumpAndSettle();
      expect(find.text('WEEKLY CHALLENGE'), findsOneWidget);

      await tester.tap(find.text('TODAY'));
      await tester.pumpAndSettle();
      expect(find.text('HUMILITY'), findsOneWidget);
    },
  );

  testWidgets(
    'Tapping Today in the bottom nav returns to the Today root after a Field Guide push',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: testOverrides(), child: const FraternusApp()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text("Today's Field Guide Reading"));
      await tester.pumpAndSettle();
      expect(find.text('IDENTITY'), findsOneWidget);

      await tester.tap(find.text('TODAY'));
      await tester.pumpAndSettle();
      expect(find.text('HUMILITY'), findsOneWidget);
    },
  );

  testWidgets(
    "Tapping This Week's Focus on Today pushes the same virtue detail screen Guide links to",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: testOverrides(), child: const FraternusApp()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('HUMILITY'));
      await tester.pumpAndSettle();

      // The header shows this week's virtue instead of "Guide" — "GUIDE" is
      // just the bottom-tab label now, and the content no longer repeats the
      // virtue as its own heading (redundant with the header's "< HUMILITY").
      expect(find.text('GUIDE'), findsOneWidget);
      expect(find.text('HUMILITY'), findsOneWidget);
      expect(find.text('THE TEMPERAMENTS'), findsOneWidget);

      await tester.tap(find.text('TODAY'));
      await tester.pumpAndSettle();
      expect(find.text('HUMILITY'), findsOneWidget);
    },
  );

  testWidgets('Tapping See All on Today pushes the Events tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: testOverrides(), child: const FraternusApp()),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('SEE ALL'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SEE ALL'));
    await tester.pumpAndSettle();

    // "EVENTS" renders twice: the bottom-tab label and the pushed screen's heading.
    expect(find.text('EVENTS'), findsNWidgets(2));
    expect(find.text('Captain Meeting'), findsOneWidget);

    await tester.tap(find.text('TODAY'));
    await tester.pumpAndSettle();
    expect(find.text('HUMILITY'), findsOneWidget);
  });
}
