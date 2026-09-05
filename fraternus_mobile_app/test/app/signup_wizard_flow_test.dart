import 'package:flutter/material.dart' show TextField;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/app/fraternus_app.dart';
import 'package:fraternus_mobile_app/design_system/design_system.dart';

import 'app_test_harness.dart';

void main() {
  setUp(resetSharedPreferences);

  testWidgets(
    'Sign-up flow: Brother is blocked, Parent or Volunteer continues to the wizard',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testOverrides(signedIn: false),
          child: const FraternusApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('CREATE ACCOUNT'));
      await tester.pumpAndSettle();

      expect(find.text('Which best describes you?'), findsOneWidget);

      // Continue starts disabled until a role is picked. Selecting Brother
      // and continuing routes to the blocked info screen instead of the
      // wizard. SelectableCard uppercases its title.
      await tester.tap(find.text('BROTHER'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      expect(find.text('WE LOVE THE ENTHUSIASM'), findsOneWidget);

      await tester.tap(find.byIcon(FraternusIcons.resolve('chevron-left')));
      await tester.pumpAndSettle();

      // Switching the selection to Parent or Captain and continuing routes
      // to the wizard instead.
      await tester.tap(find.text('PARENT OR CAPTAIN'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      expect(find.text("WHAT'S YOUR EMAIL?"), findsOneWidget);
    },
  );

  testWidgets(
    'Backing out of the signup wizard twice returns to the welcome screen without crashing',
    (WidgetTester tester) async {
      // Regression test: welcome -> create account -> parent/volunteer ->
      // back -> back used to throw a go_router "nothing to pop" exception.
      await tester.pumpWidget(
        ProviderScope(
          overrides: testOverrides(signedIn: false),
          child: const FraternusApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('CREATE ACCOUNT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PARENT OR CAPTAIN'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      expect(find.text("WHAT'S YOUR EMAIL?"), findsOneWidget);

      // Back from the wizard's first step to the role screen.
      await tester.tap(find.byIcon(FraternusIcons.resolve('chevron-left')));
      await tester.pumpAndSettle();
      expect(find.text('Which best describes you?'), findsOneWidget);

      // Back again from the role screen — this is the step that used to
      // throw, since the wizard previously used `go()` to get here, which
      // wipes the stack this pop needs.
      await tester.tap(find.byIcon(FraternusIcons.resolve('chevron-left')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('CREATE ACCOUNT'), findsOneWidget);
      expect(find.text('Which best describes you?'), findsNothing);
    },
  );

  testWidgets('Resend Code is disabled for 10 seconds after each press', (
    WidgetTester tester,
  ) async {
    final fakeAuth = FakeAuthRepository(signedIn: false);
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(signedIn: false, authRepository: fakeAuth),
        child: const FraternusApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('CREATE ACCOUNT'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PARENT OR CAPTAIN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'jane@example.com');
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    expect(find.text('CHECK YOUR EMAIL'), findsOneWidget);
    expect(fakeAuth.sendEmailOtpCallCount, 1);

    // Ready immediately after arriving on the code step.
    expect(find.text('RESEND CODE'), findsOneWidget);

    await tester.tap(find.text('RESEND CODE'));
    await tester.pump();
    expect(fakeAuth.sendEmailOtpCallCount, 2);

    // Now disabled and counting down — the plain "RESEND CODE" label is
    // gone, and repeated taps on the countdown label don't fire another
    // send since Button.disabled blocks the tap outright.
    expect(find.text('RESEND CODE'), findsNothing);
    expect(find.text('RESEND CODE (10S)'), findsOneWidget);
    await tester.tap(find.text('RESEND CODE (10S)'));
    await tester.pump();
    expect(fakeAuth.sendEmailOtpCallCount, 2);

    // Partway through the cooldown it's still disabled...
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('RESEND CODE (5S)'), findsOneWidget);
    await tester.tap(find.text('RESEND CODE (5S)'));
    await tester.pump();
    expect(fakeAuth.sendEmailOtpCallCount, 2);

    // ...and re-enabled once the full 10 seconds have passed.
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('RESEND CODE'), findsOneWidget);
    await tester.tap(find.text('RESEND CODE'));
    await tester.pump();
    expect(fakeAuth.sendEmailOtpCallCount, 3);
  });

  testWidgets(
    'Completing the signup wizard as a non-attending Guardian redirects to the tab shell',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testOverrides(signedIn: false),
          child: const FraternusApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('CREATE ACCOUNT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PARENT OR CAPTAIN'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      // Email step — verifying establishes the fake session immediately.
      await tester.enterText(find.byType(TextField).first, 'jane@example.com');
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      // Code step.
      expect(find.text('CHECK YOUR EMAIL'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '123456');
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      // Password step.
      expect(find.text('CREATE A PASSWORD'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField).first,
        'correct-horse-battery-staple',
      );
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      // Name step.
      expect(find.text("WHAT'S YOUR NAME?"), findsOneWidget);
      final nameFields = find.byType(TextField);
      await tester.enterText(nameFields.at(0), 'Jane');
      await tester.enterText(nameFields.at(1), 'Doe');
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      // Attendance step — say No, which hides Chapter and skips the Captain
      // Member creation entirely.
      expect(
        find.text('WILL YOU BE ATTENDING WEEKLY FRAT NIGHTS?'),
        findsOneWidget,
      );
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
      expect(find.text('CHAPTER'), findsNothing);
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      // Kids step — skip via "I don't have any kids".
      expect(find.text('ADD YOUR KIDS'), findsOneWidget);
      await tester.tap(find.text("I DON'T HAVE ANY KIDS"));
      await tester.pumpAndSettle();

      expect(find.text("YOU'RE ALL SET"), findsOneWidget);
      await tester.tap(find.text("LET'S GET STARTED"));
      await tester.pumpAndSettle();

      expect(find.text('Which best describes you?'), findsNothing);
      expect(find.text('TODAY'), findsWidgets);
    },
  );

  testWidgets(
    'The finished step shows the user, a divider, then each added kid',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testOverrides(signedIn: false),
          child: const FraternusApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('CREATE ACCOUNT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PARENT OR CAPTAIN'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'jane@example.com');
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '123456');
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        'correct-horse-battery-staple',
      );
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      final nameFields = find.byType(TextField);
      await tester.enterText(nameFields.at(0), 'Jane');
      await tester.enterText(nameFields.at(1), 'Doe');
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      // Kids step — add one child.
      expect(find.text('ADD YOUR KIDS'), findsOneWidget);
      await tester.tap(find.text('ADD CHILD'));
      await tester.pumpAndSettle();

      final childFields = find.byType(TextField);
      await tester.enterText(childFields.at(0), 'Jack');
      await tester.enterText(childFields.at(1), 'Doe');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('ADD'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ADD'));
      await tester.pumpAndSettle();

      expect(find.text('Jack Doe'), findsOneWidget);

      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      // Finished step: the user's own card, then a divider, then the kid.
      expect(find.text("YOU'RE ALL SET"), findsOneWidget);
      expect(find.text('YOU'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.byType(HairlineDivider), findsOneWidget);
      expect(find.text('YOUR KIDS'), findsOneWidget);
      expect(find.text('Jack Doe'), findsOneWidget);
    },
  );
}
