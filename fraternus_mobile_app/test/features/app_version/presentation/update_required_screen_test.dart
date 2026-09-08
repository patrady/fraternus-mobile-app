import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/app_version/models/app_version_status.dart';
import 'package:fraternus_mobile_app/features/app_version/presentation/update_required_screen.dart';
import 'package:fraternus_mobile_app/features/app_version/providers/app_version_providers.dart';

const _genericMessage =
    'This version of the app is no longer supported. Please update to the '
    'latest version.';

Future<void> _pump(WidgetTester tester, AppVersionStatus status) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appVersionStatusProvider.overrideWithValue(status)],
      child: MaterialApp(
        home: const UpdateRequiredScreen(),
        // Mirrors fraternus_app.dart's own builder — the design system's
        // widgets need a Material ancestor.
        builder: (context, child) =>
            Material(type: MaterialType.transparency, child: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the admin-supplied message when present', (tester) async {
    await _pump(
      tester,
      const AppVersionStatus(
        blocked: true,
        reason: 'deprecated',
        message: 'Critical fix, please update.',
      ),
    );

    expect(find.text('UPDATE REQUIRED'), findsOneWidget);
    expect(find.text('Critical fix, please update.'), findsOneWidget);
    expect(find.text(_genericMessage), findsNothing);
  });

  testWidgets('falls back to generic copy when no admin message is set', (
    tester,
  ) async {
    await _pump(
      tester,
      const AppVersionStatus(blocked: true, reason: 'below_minimum'),
    );

    expect(find.text(_genericMessage), findsOneWidget);
  });

  testWidgets('blocks the system/hardware back gesture', (tester) async {
    await _pump(
      tester,
      const AppVersionStatus(blocked: true, reason: 'deprecated'),
    );

    final popScope = tester.widget<PopScope>(find.byType(PopScope));
    expect(popScope.canPop, isFalse);
  });

  testWidgets(
    'has no "Update Now" button when Env\'s store identifiers are unset '
    '(the default in flutter test — no dart-define is passed)',
    (tester) async {
      await _pump(
        tester,
        const AppVersionStatus(blocked: true, reason: 'deprecated'),
      );

      expect(find.text('UPDATE NOW'), findsNothing);
    },
  );
}
