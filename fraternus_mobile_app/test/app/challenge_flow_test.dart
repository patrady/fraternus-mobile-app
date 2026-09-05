import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/app/fraternus_app.dart';

import 'app_test_harness.dart';

void main() {
  setUp(resetSharedPreferences);

  testWidgets(
    'Challenge tab renders all 3 states and links to Past Challenges',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: testOverrides(), child: const FraternusApp()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('CHALLENGE'));
      await tester.pumpAndSettle();

      // Default person ("You") hasn't accepted the current challenge yet.
      expect(find.text('Cold Shower Challenge'), findsOneWidget);
      expect(find.text('NEW'), findsOneWidget);
      expect(find.text('ACCEPT CHALLENGE'), findsOneWidget);

      // Jack accepted but hasn't finished — his next rep is actionable.
      await tester.tap(find.text('JACK'));
      await tester.pumpAndSettle();
      expect(find.text('Rep 1'), findsOneWidget);
      expect(find.text('MARK COMPLETE'), findsOneWidget);

      // Thomas has completed every rep.
      await tester.tap(find.text('THOMAS'));
      await tester.pumpAndSettle();
      expect(find.text('CHALLENGE COMPLETE!'), findsOneWidget);
      expect(find.text('SHOW REPS'), findsOneWidget);

      await tester.ensureVisible(find.text('PAST CHALLENGES'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PAST CHALLENGES'));
      await tester.pumpAndSettle();

      // "PAST CHALLENGES" is the ScreenHeader title, and this Past
      // Challenges list is scoped to Thomas, the tab active before the push.
      expect(find.text('PAST CHALLENGES'), findsOneWidget);
      expect(find.text('Thomas'), findsOneWidget);
      expect(find.text('Morning Silence'), findsOneWidget);
      expect(find.text('No Complaining'), findsOneWidget);
      expect(find.text('Examen Before Bed'), findsOneWidget);
      expect(
        find.text('Tap a rep to mark it complete in case you forgot.'),
        findsOneWidget,
      );
    },
  );
}
