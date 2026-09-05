import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/app/fraternus_app.dart';
import 'package:fraternus_mobile_app/features/guide/providers/guide_providers.dart';

import 'app_test_harness.dart';

void main() {
  setUp(resetSharedPreferences);

  testWidgets('Guide tab renders the daily reading and completes/undoes it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: testOverrides(), child: const FraternusApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('GUIDE'));
    await tester.pumpAndSettle();

    expect(find.text('HUMILITY'), findsOneWidget);
    expect(find.text('IDENTITY'), findsOneWidget);
    expect(find.text('WISDOM FOR THE DAY'), findsOneWidget);
    expect(find.text('MY SWORD'), findsOneWidget);
    expect(find.text('MY SPADE'), findsOneWidget);
    expect(find.text('EVENING SEAL'), findsOneWidget);
    // Default person ("You") hasn't completed today's reading yet.
    expect(find.text('MARK COMPLETE'), findsOneWidget);

    // Jack has already completed today's reading.
    await tester.tap(find.text('JACK'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('✓ COMPLETED'));
    await tester.pumpAndSettle();
    expect(find.text('✓ COMPLETED'), findsOneWidget);

    // Tapping the completed button undoes it, same as Challenge's rep toggle.
    await tester.tap(find.text('✓ COMPLETED'));
    await tester.pumpAndSettle();
    expect(find.text('MARK COMPLETE'), findsOneWidget);
  });

  testWidgets('More about the virtue pushes the virtue detail screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: testOverrides(), child: const FraternusApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('GUIDE'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('MORE ABOUT HUMILITY'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MORE ABOUT HUMILITY'));
    await tester.pumpAndSettle();

    // The header shows this week's virtue instead of "Guide" — "GUIDE" is
    // just the bottom-tab label now, and the content no longer repeats the
    // virtue as its own heading (redundant with the header's "< HUMILITY").
    expect(find.text('GUIDE'), findsOneWidget);
    expect(find.text('HUMILITY'), findsOneWidget);
    expect(find.text('THE TEMPERAMENTS'), findsOneWidget);
    expect(find.text('PRIMARY'), findsOneWidget);
    expect(find.text('SECONDARY'), findsOneWidget);
  });

  testWidgets('Tapping a temperament card pushes its own detail screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: testOverrides(), child: const FraternusApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('GUIDE'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('MORE ABOUT HUMILITY'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MORE ABOUT HUMILITY'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('CHOLERIC'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CHOLERIC'));
    await tester.pumpAndSettle();

    expect(find.text('GUIDE'), findsWidgets);
    expect(find.text('CHOLERIC'), findsOneWidget);
    expect(find.text('STRENGTHS'), findsOneWidget);
    expect(find.text('GROWTH AREAS'), findsOneWidget);
    expect(find.text('Decisive under pressure'), findsOneWidget);
    expect(find.text("Impatience with others' pace"), findsOneWidget);
  });

  testWidgets(
    'Guide shows the calendar picker with a friendly fallback when no reading exists for the date',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...testOverrides(),
            guideSelectedDateProvider.overrideWith(FarPastGuideDate.new),
          ],
          child: const FraternusApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('GUIDE'));
      await tester.pumpAndSettle();

      expect(find.text('JANUARY 1'), findsOneWidget);
      expect(find.bySemanticsLabel('Pick a date'), findsOneWidget);
      expect(find.text('Nothing to read for this date yet.'), findsOneWidget);
      // None of the daily-reading cards render when there's nothing to read.
      expect(find.text('IDENTITY'), findsNothing);
    },
  );
}
