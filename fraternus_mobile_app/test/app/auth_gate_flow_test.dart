import 'package:flutter/material.dart' show TextField;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/app/fraternus_app.dart';
import 'package:fraternus_mobile_app/design_system/design_system.dart';

import 'app_test_harness.dart';

void main() {
  setUp(resetSharedPreferences);

  testWidgets(
    'Signed-out app redirects straight to the welcome screen, not the tab shell',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testOverrides(signedIn: false),
          child: const FraternusApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CREATE ACCOUNT'), findsOneWidget);
      expect(find.text('TODAY'), findsNothing);
    },
  );

  testWidgets(
    'Sign-in redirects to the tab shell once the fake session succeeds',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testOverrides(signedIn: false),
          child: const FraternusApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        'guardian@example.com',
      );
      await tester.enterText(
        find.byType(TextField).last,
        'correct-horse-battery-staple',
      );
      // "SIGN IN" now also renders as this screen's ScreenHeader title
      // (see the back-button addition below), so the submit button is
      // disambiguated by taking the last match.
      await tester.tap(find.text('SIGN IN').last);
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsNothing);
      expect(find.text('TODAY'), findsWidgets);
    },
  );

  testWidgets('Sign In has a back button that returns to the welcome screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(signedIn: false),
        child: const FraternusApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('SIGN IN'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);

    await tester.tap(find.byIcon(FraternusIcons.resolve('chevron-left')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Welcome Back'), findsNothing);
    expect(find.text('CREATE ACCOUNT'), findsOneWidget);
  });
}
