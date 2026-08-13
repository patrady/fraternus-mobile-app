import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fraternus_mobile_app/app/fraternus_app.dart';
import 'package:fraternus_mobile_app/features/guide/presentation/widgets/sword_option_list.dart';
import 'package:fraternus_mobile_app/features/guide/providers/guide_providers.dart';

/// A date far outside the single seeded Field Guide week, for exercising
/// the "nothing to read" fallback.
class _FarPastGuideDate extends GuideSelectedDate {
  @override
  DateTime build() => DateTime(2000, 1, 1);
}

void main() {
  testWidgets('Today screen renders the weekly focus and tab bar', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FraternusApp()));
    await tester.pumpAndSettle();

    // "TODAY" renders twice: the active bottom-tab label and the "Today"
    // section eyebrow above the person tabs.
    expect(find.text('TODAY'), findsNWidgets(2));
    expect(find.text('HUMILITY'), findsOneWidget);
    expect(find.text('GUIDE'), findsOneWidget);
    expect(find.text('CHALLENGE'), findsOneWidget);
    expect(find.text('EVENTS'), findsOneWidget);
  });

  testWidgets('Events tab lists events and pushes a detail screen on tap', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FraternusApp()));
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

    await tester.tap(find.text('HAWC Night'));
    await tester.pumpAndSettle();

    // "EVENTS" now renders twice: the bottom-tab label and the "< EVENTS"
    // back breadcrumb on the detail screen.
    expect(find.text('EVENTS'), findsNWidgets(2));
    expect(find.text('HAWC NIGHT'), findsOneWidget);
    expect(find.text('RSVP'), findsOneWidget);
    expect(find.text('OTHERS ATTENDING'), findsOneWidget);
  });

  testWidgets('Challenge tab renders all 3 states and links to Past Challenges', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: FraternusApp()));
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

    // "BACK" now renders once (the "< BACK" breadcrumb) and this Past
    // Challenges list is scoped to Thomas, the tab active before the push.
    expect(find.text('BACK'), findsOneWidget);
    expect(find.text('Thomas'), findsOneWidget);
    expect(find.text('Morning Silence'), findsOneWidget);
    expect(find.text('No Complaining'), findsOneWidget);
    expect(find.text('Examen Before Bed'), findsOneWidget);
    expect(find.text('Tap a rep to mark it complete in case you forgot.'), findsOneWidget);
  });

  testWidgets('Tapping Today in the bottom nav returns to the Today root after a task push', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: FraternusApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Weekly Challenge'));
    await tester.pumpAndSettle();
    expect(find.text('WEEKLY CHALLENGE'), findsOneWidget);

    await tester.tap(find.text('TODAY'));
    await tester.pumpAndSettle();
    expect(find.text('HUMILITY'), findsOneWidget);
  });

  testWidgets('Guide tab renders the daily reading and completes/undoes it', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FraternusApp()));
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

  testWidgets('More about the virtue pushes the virtue detail screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FraternusApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('GUIDE'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('MORE ABOUT HUMILITY'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MORE ABOUT HUMILITY'));
    await tester.pumpAndSettle();

    // "GUIDE" renders twice: the bottom-tab label and the "< GUIDE" breadcrumb.
    expect(find.text('GUIDE'), findsNWidgets(2));
    expect(find.text('THE TEMPERAMENTS'), findsOneWidget);
    expect(find.text('PRIMARY'), findsOneWidget);
    expect(find.text('SECONDARY'), findsOneWidget);
  });

  testWidgets('Tapping a temperament card pushes its own detail screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FraternusApp()));
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

    expect(find.text('BACK'), findsOneWidget);
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
          overrides: [guideSelectedDateProvider.overrideWith(_FarPastGuideDate.new)],
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

  testWidgets('Tapping Today in the bottom nav returns to the Today root after a Field Guide push', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: FraternusApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Today's Field Guide Reading"));
    await tester.pumpAndSettle();
    expect(find.text('IDENTITY'), findsOneWidget);

    await tester.tap(find.text('TODAY'));
    await tester.pumpAndSettle();
    expect(find.text('HUMILITY'), findsOneWidget);
  });

  testWidgets("Tapping This Week's Focus on Today pushes the same virtue detail screen Guide links to", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: FraternusApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('HUMILITY'));
    await tester.pumpAndSettle();

    // "GUIDE" renders twice: the bottom-tab label and the "< GUIDE" breadcrumb.
    expect(find.text('GUIDE'), findsNWidgets(2));
    expect(find.text('THE TEMPERAMENTS'), findsOneWidget);

    await tester.tap(find.text('TODAY'));
    await tester.pumpAndSettle();
    expect(find.text('HUMILITY'), findsOneWidget);
  });

  testWidgets('Tapping See All on Today pushes the Events tab', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FraternusApp()));
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

  testWidgets('Tapping the profile icon opens Profile', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FraternusApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('PROFILE'), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('My Kids'), findsOneWidget);
    expect(find.text('Reminders'), findsOneWidget);
  });

  testWidgets('Tapping John Smith opens My Profile with prefilled fields', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FraternusApp()));
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

  testWidgets('My Kids lists both children and Edit -> Remove Child removes one', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FraternusApp()));
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

    expect(find.text('Are you sure you want to remove Jack Smith? This cannot be undone.'), findsOneWidget);

    await tester.tap(find.text('REMOVE'));
    await tester.pumpAndSettle();

    expect(find.text('MY KIDS'), findsOneWidget);
    expect(find.text('Jack Smith'), findsNothing);
    expect(find.text('Thomas Smith'), findsOneWidget);
  });

  testWidgets('Add Child opens the Add Child form', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FraternusApp()));
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
    expect(find.text('BIRTHDAY'), findsOneWidget);
  });

  testWidgets('Reminders shows the grouped toggles', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FraternusApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reminders'));
    await tester.pumpAndSettle();

    expect(find.text('REMINDERS'), findsOneWidget);
    expect(find.text('Daily Reading'), findsOneWidget);
    expect(find.text('7:00 AM'), findsOneWidget);
  });

  testWidgets('Log Out shows a confirmation dialog and confirming returns to Today', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: FraternusApp()));
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

    expect(find.text('Are you sure you want to log out?'), findsNothing);
    expect(find.text('HUMILITY'), findsOneWidget);
  });

  testWidgets('Tapping the Profile screen back button returns to Today', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FraternusApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('PROFILE'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();

    expect(find.text('HUMILITY'), findsOneWidget);
  });

  testWidgets('Find Your Temperament walks the quiz end to end and saves a result', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: FraternusApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('GUIDE'));
    await tester.pumpAndSettle();

    // Jack has no temperament result yet, so his virtue detail screen shows
    // the CTA (unlike the default "You" tab, which is pre-seeded).
    await tester.tap(find.text('JACK'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('MORE ABOUT HUMILITY'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MORE ABOUT HUMILITY'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('FIND YOUR TEMPERAMENT'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('FIND YOUR TEMPERAMENT'));
    await tester.pumpAndSettle();

    expect(find.text('THE FOUR TEMPERAMENTS'), findsOneWidget);
    expect(find.text('10 minutes'), findsOneWidget);
    await tester.tap(find.text('BEGIN QUIZ'));
    await tester.pumpAndSettle();

    // Exiting mid-quiz prompts for confirmation; cancelling stays put.
    await tester.tap(find.text('EXIT'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to exit? Your progress will be lost.'), findsOneWidget);
    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to exit? Your progress will be lost.'), findsNothing);

    // Next starts disabled until an option is picked.
    expect(find.text('NEXT'), findsOneWidget);

    // Always pick the first (Choleric) option on every question.
    for (var i = 0; i < 24; i++) {
      final firstOption = find
          .descendant(of: find.byType(SwordOptionList), matching: find.byType(GestureDetector))
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

    // Back on the virtue detail screen, Jack's saved result now shows
    // Primary/Secondary tags instead of the CTA.
    expect(find.text('FIND YOUR TEMPERAMENT'), findsNothing);
    expect(find.text('PRIMARY'), findsOneWidget);
  });

  testWidgets('Take Again on Profile opens the quiz for the current result', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: FraternusApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();

    // "You" is pre-seeded with a result, so Profile shows Take Again.
    await tester.tap(find.text('TAKE AGAIN'));
    await tester.pumpAndSettle();

    expect(find.text('THE FOUR TEMPERAMENTS'), findsOneWidget);
  });
}
