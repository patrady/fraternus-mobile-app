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

    // Per StaticEventsRepository's seed data: Captain Meeting (1 accepted
    // household RSVP + 4 others attending) and Ranch (0 + 5) both land on
    // 5; HAWC Night and Frat Night both have no household RSVPs seeded,
    // just the same 4 others attending each; Excursion has 2 accepted
    // household RSVPs (Jack, Thomas) + 5 others.
    expect(find.text('5 registered'), findsNWidgets(2));
    expect(find.text('4 registered'), findsNWidgets(2));
    expect(find.text('7 registered'), findsOneWidget);

    await tester.tap(find.text('HAWC Night'));
    await tester.pumpAndSettle();

    // "EVENTS" now renders twice: the bottom-tab label and the "< EVENTS"
    // back breadcrumb on the detail screen.
    expect(find.text('EVENTS'), findsNWidgets(2));
    expect(find.text('HAWC NIGHT'), findsOneWidget);
    expect(find.text('RSVP'), findsOneWidget);
    expect(find.text('OTHERS ATTENDING'), findsOneWidget);

    // Not a Frat Night — no Kings Message section at all.
    expect(find.text('KINGS MESSAGE'), findsNothing);
  });

  testWidgets(
    'Kings Message section only appears on Frat Night, and supports sign-up/un-register',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: testOverrides(), child: const FraternusApp()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('EVENTS'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Frat Night — Virtue of Fortitude'));
      await tester.pumpAndSettle();

      expect(find.text('KINGS MESSAGE'), findsOneWidget);
      expect(find.text('No one has signed up yet.'), findsOneWidget);
      expect(find.text('SIGN UP AS KINGS MESSENGER'), findsOneWidget);

      await tester.ensureVisible(find.text('SIGN UP AS KINGS MESSENGER'));
      await tester.tap(find.text('SIGN UP AS KINGS MESSENGER'));
      await tester.pumpAndSettle();

      expect(find.text('No one has signed up yet.'), findsNothing);
      expect(find.text('John Smith'), findsOneWidget);
      expect(find.text('SIGN UP AS KINGS MESSENGER'), findsNothing);

      final unregisterButton = find.bySemanticsLabel(
        'Un-register as Kings Messenger',
      );
      await tester.ensureVisible(unregisterButton);
      await tester.tap(unregisterButton);
      await tester.pumpAndSettle();
      // Confirm dialog — Button always uppercases its label.
      await tester.tap(find.text('UN-REGISTER'));
      await tester.pumpAndSettle();

      expect(find.text('No one has signed up yet.'), findsOneWidget);
      expect(find.text('SIGN UP AS KINGS MESSENGER'), findsOneWidget);
    },
  );
}
