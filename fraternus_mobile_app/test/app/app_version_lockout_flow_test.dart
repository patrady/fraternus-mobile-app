import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/app/fraternus_app.dart';
import 'package:fraternus_mobile_app/features/app_version/models/app_version_status.dart';

import 'app_test_harness.dart';

const _blocked = AppVersionStatus(
  blocked: true,
  reason: 'deprecated',
  message: 'This build has a critical bug — please update.',
);

void main() {
  setUp(resetSharedPreferences);

  testWidgets(
    'A blocked version forces the update screen even when signed out, '
    'never reaching the welcome screen',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testOverrides(signedIn: false, appVersionStatus: _blocked),
          child: const FraternusApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('UPDATE REQUIRED'), findsOneWidget);
      expect(
        find.text('This build has a critical bug — please update.'),
        findsOneWidget,
      );
      expect(find.text('CREATE ACCOUNT'), findsNothing);
    },
  );

  testWidgets('A blocked version forces the update screen even when signed in, '
      'never reaching the tab shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(signedIn: true, appVersionStatus: _blocked),
        child: const FraternusApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('UPDATE REQUIRED'), findsOneWidget);
    expect(find.text('TODAY'), findsNothing);
  });

  testWidgets(
    'An unblocked version reaches the normal signed-out flow, not the '
    'update screen',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testOverrides(signedIn: false),
          child: const FraternusApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('UPDATE REQUIRED'), findsNothing);
      expect(find.text('CREATE ACCOUNT'), findsOneWidget);
    },
  );
}
