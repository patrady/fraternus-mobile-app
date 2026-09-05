import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/app/fraternus_app.dart';
import 'package:fraternus_mobile_app/design_system/design_system.dart';

import 'app_test_harness.dart';

void main() {
  setUp(resetSharedPreferences);

  testWidgets('Tapping the profile icon opens Profile', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: testOverrides(), child: const FraternusApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('PROFILE'), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('My Kids'), findsOneWidget);
    expect(find.text('Reminders'), findsOneWidget);
  });

  testWidgets('Tapping John Smith opens My Profile with prefilled fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: testOverrides(), child: const FraternusApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('John Smith'));
    await tester.pumpAndSettle();

    expect(find.text('MY PROFILE'), findsOneWidget);
    expect(find.text('CAPTAIN'), findsOneWidget);
    expect(find.text('John'), findsOneWidget);
    expect(find.text('Smith'), findsOneWidget);
    expect(find.text('john.smith@example.com'), findsOneWidget);

    await tester.tap(find.text('TODAY'));
    await tester.pumpAndSettle();
    expect(find.text('HUMILITY'), findsOneWidget);
  });

  testWidgets(
    'My Kids lists both children and Edit -> Remove Child removes one',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: testOverrides(), child: const FraternusApp()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('My Kids'));
      await tester.pumpAndSettle();

      expect(find.text('MY KIDS'), findsOneWidget);
      expect(find.text('Jack Smith'), findsOneWidget);
      expect(find.text('Thomas Smith'), findsOneWidget);
      expect(find.text('EDIT'), findsNWidgets(2));

      await tester.tap(find.text('EDIT').first);
      await tester.pumpAndSettle();

      expect(find.text('EDIT CHILD'), findsOneWidget);
      expect(find.text('Jack'), findsOneWidget);
      expect(find.text('Smith'), findsOneWidget);

      await tester.ensureVisible(find.text('REMOVE CHILD'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('REMOVE CHILD'));
      await tester.pumpAndSettle();

      // docs/adrs/003_coppa_child_data_deletion.md — the confirmation spells
      // out that this is a real data-deletion request, not just a list edit.
      expect(
        find.text(
          "This will permanently delete Jack Smith's data — every reading, "
          'challenge, and RSVP recorded for them. This cannot be undone.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('DELETE'));
      await tester.pumpAndSettle();

      expect(find.text('MY KIDS'), findsOneWidget);
      expect(find.text('Jack Smith'), findsNothing);
      expect(find.text('Thomas Smith'), findsOneWidget);
    },
  );

  testWidgets('Add Child opens the Add Child form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: testOverrides(), child: const FraternusApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Kids'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('ADD CHILD'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ADD CHILD'));
    await tester.pumpAndSettle();

    expect(find.text('ADD CHILD'), findsOneWidget);
    expect(find.text('FIRST NAME'), findsOneWidget);
  });

  testWidgets('Reminders shows the master switch and all 7 grouped toggles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: testOverrides(), child: const FraternusApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reminders'));
    await tester.pumpAndSettle();

    expect(find.text('REMINDERS'), findsOneWidget);
    expect(find.text('All Reminders'), findsOneWidget);
    expect(find.text('FIELD GUIDE'), findsOneWidget);
    expect(find.text('WEEKLY CHALLENGES'), findsOneWidget);
    expect(find.text('EVENTS'), findsWidgets); // also the bottom-tab label

    // All 7 ReminderType values represented — the pre-Supabase static data
    // only had 5 (missing challenge_mid_week and one of the two event
    // types), fixed as part of the Supabase migration.
    expect(find.text('Daily Reading'), findsOneWidget);
    expect(find.text('Evening Seal'), findsOneWidget);
    expect(find.text('Introduction'), findsOneWidget);
    expect(find.text('Midweek Check-In'), findsOneWidget);
    expect(find.text('Last Chance'), findsOneWidget);
    expect(find.text('24 Hours Before'), findsOneWidget);
    expect(find.text('1 Hour Before'), findsOneWidget);

    // Toggling a single reminder calls through to the repository (not just
    // local state) and the new value survives popping this route and
    // pushing it again — proving it's re-fetched, not just a locally-held
    // bool that would reset the moment the widget is disposed.
    expect(
      tester.widget<FraternusSwitch>(find.byType(FraternusSwitch).at(1)).value,
      isTrue,
    );
    await tester.tap(
      find.byType(FraternusSwitch).at(1),
    ); // first reminder row, index 0 is the master switch
    await tester.pumpAndSettle();
    await tester.tap(
      find.bySemanticsLabel('Back'),
    ); // Reminders -> Profile, disposing this screen
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reminders')); // fresh push, fresh fetch
    await tester.pumpAndSettle();
    expect(
      tester.widget<FraternusSwitch>(find.byType(FraternusSwitch).at(1)).value,
      isFalse,
    );

    // The master switch dims (and disables) every individual toggle below
    // it. `.last` — not `.first` — since ListRow itself wraps its content
    // in its own (always opacity: 1 at rest) Opacity for press feedback;
    // the outermost one is _RemindersList's.
    await tester.tap(find.byType(FraternusSwitch).first);
    await tester.pumpAndSettle();
    final opacity = tester.widget<Opacity>(
      find
          .ancestor(
            of: find.text('Daily Reading'),
            matching: find.byType(Opacity),
          )
          .last,
    );
    expect(opacity.opacity, lessThan(1));
  });

  testWidgets(
    'Log Out shows a confirmation dialog and confirming signs out to the welcome screen',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: testOverrides(), child: const FraternusApp()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Profile'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('LOG OUT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('LOG OUT'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to log out?'), findsOneWidget);

      // Two 'LOG OUT' texts now (Button uppercases labels): the profile
      // screen's button underneath and the dialog's confirm button — tap the
      // dialog's (added later, so last in the tree).
      await tester.tap(find.text('LOG OUT').last);
      await tester.pumpAndSettle();

      // Confirming calls AuthRepository.signOut(), which clears the fake's
      // session and emits on authStateChanges — the router's redirect (via
      // refreshListenable) picks that up and lands on sign-in, proving the
      // real wiring, not just that the dialog closed.
      expect(find.text('Are you sure you want to log out?'), findsNothing);
      expect(find.text('HUMILITY'), findsNothing);
      expect(find.text('CREATE ACCOUNT'), findsOneWidget);
    },
  );

  testWidgets('Tapping the Profile screen back button returns to Today', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: testOverrides(), child: const FraternusApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('PROFILE'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();

    expect(find.text('HUMILITY'), findsOneWidget);
  });
}
