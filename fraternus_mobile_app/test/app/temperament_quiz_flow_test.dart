import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/app/fraternus_app.dart';
import 'package:fraternus_mobile_app/features/guide/presentation/widgets/sword_option_list.dart';

import 'app_test_harness.dart';

void main() {
  setUp(resetSharedPreferences);

  testWidgets(
    'Find Your Temperament walks the quiz end to end and saves a result',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: testOverrides(), child: const FraternusApp()),
      );
      await tester.pumpAndSettle();

      // Jack has no temperament result yet, so his Today list shows the
      // recurring "Find Your Temperament" task (unlike the default "You"
      // tab, which is pre-seeded and has no such task).
      await tester.tap(find.text('JACK'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Find Your Temperament'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Find Your Temperament'));
      await tester.pumpAndSettle();

      expect(find.text('THE FOUR TEMPERAMENTS'), findsOneWidget);
      expect(find.text('10 minutes'), findsOneWidget);
      await tester.tap(find.text('BEGIN QUIZ'));
      await tester.pumpAndSettle();

      // Exiting mid-quiz prompts for confirmation; cancelling stays put.
      await tester.tap(find.text('EXIT'));
      await tester.pumpAndSettle();
      expect(
        find.text('Are you sure you want to exit? Your progress will be lost.'),
        findsOneWidget,
      );
      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();
      expect(
        find.text('Are you sure you want to exit? Your progress will be lost.'),
        findsNothing,
      );

      // Next starts disabled until an option is picked.
      expect(find.text('NEXT'), findsOneWidget);

      // Always pick the first (Choleric) option on every question.
      for (var i = 0; i < 24; i++) {
        final firstOption = find
            .descendant(
              of: find.byType(SwordOptionList),
              matching: find.byType(GestureDetector),
            )
            .first;
        await tester.tap(firstOption);
        await tester.pumpAndSettle();
        await tester.tap(find.text(i == 23 ? 'FINISH' : 'NEXT'));
        await tester.pumpAndSettle();
      }

      expect(find.text('YOUR TEMPERAMENT'), findsOneWidget);
      expect(find.text('CHOLERIC'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Back on Today, Jack's task list no longer shows the quiz task now
      // that he has a saved result.
      expect(find.text('Find Your Temperament'), findsNothing);

      // His virtue detail screen now shows Primary/Secondary tags too.
      await tester.tap(find.text('GUIDE'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('MORE ABOUT HUMILITY'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('MORE ABOUT HUMILITY'));
      await tester.pumpAndSettle();
      expect(find.text('PRIMARY'), findsOneWidget);
    },
  );

  testWidgets('Take Again on Profile opens the quiz for the current result', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: testOverrides(), child: const FraternusApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();

    // "You" is pre-seeded with a result, so Profile shows Take Again.
    await tester.tap(find.text('TAKE AGAIN'));
    await tester.pumpAndSettle();

    expect(find.text('THE FOUR TEMPERAMENTS'), findsOneWidget);
  });
}
