import 'dart:async';

import 'package:flutter/material.dart' show TextField;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fraternus_mobile_app/app/fraternus_app.dart';
import 'package:fraternus_mobile_app/app/shared_preferences_provider.dart';
import 'package:fraternus_mobile_app/design_system/design_system.dart';
import 'package:fraternus_mobile_app/features/auth/data/auth_repository.dart';
import 'package:fraternus_mobile_app/features/auth/providers/auth_providers.dart';
import 'package:fraternus_mobile_app/features/challenge/data/challenge_repository.dart';
import 'package:fraternus_mobile_app/features/challenge/providers/challenge_providers.dart';
import 'package:fraternus_mobile_app/features/events/data/events_repository.dart';
import 'package:fraternus_mobile_app/features/events/providers/events_providers.dart';
import 'package:fraternus_mobile_app/features/guide/data/guide_repository.dart';
import 'package:fraternus_mobile_app/features/guide/presentation/widgets/sword_option_list.dart';
import 'package:fraternus_mobile_app/features/guide/providers/guide_providers.dart';
import 'package:fraternus_mobile_app/features/profile/data/profile_repository.dart';
import 'package:fraternus_mobile_app/features/profile/providers/profile_providers.dart';
import 'package:fraternus_mobile_app/shared/data/chapter_repository.dart';
import 'package:fraternus_mobile_app/shared/providers/chapter_providers.dart';

/// A date far outside the single seeded Field Guide week, for exercising
/// the "nothing to read" fallback.
class _FarPastGuideDate extends GuideSelectedDate {
  @override
  DateTime build() => DateTime(2000, 1, 1);
}

/// The auth gate in app/router/app_router.dart redirects to sign-in
/// whenever `AuthRepository.currentSession` is null, and re-evaluates that
/// redirect whenever `authStateChanges` fires (via `refreshListenable`).
/// This fake starts signed in (so most widget tests exercise the
/// authenticated app without touching real Supabase Auth) but stays fully
/// stateful — `signOut`/`signIn`/`signUp` really flip `currentSession` and
/// emit on the stream — so the "Log Out" test below genuinely proves the
/// router's redirect wiring works, not just the button's own UI.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({bool signedIn = true}) {
    if (signedIn) _session = _newSession();
  }

  Session? _session;
  final _controller = StreamController<AuthState>.broadcast();

  static final _user = User(
    id: 'test-user',
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    createdAt: DateTime(2024).toIso8601String(),
  );

  static Session _newSession() => Session(
    accessToken: 'test-access-token',
    tokenType: 'bearer',
    user: _user,
  );

  @override
  Stream<AuthState> get authStateChanges => _controller.stream;

  @override
  Session? get currentSession => _session;

  /// Lets tests assert on how many times Resend Code actually reached the
  /// repository — the cooldown guard lives in SignUpAccountScreen, not
  /// here, so this only proves the guard is doing its job.
  int sendEmailOtpCallCount = 0;

  @override
  Future<void> sendEmailOtp(String email) async {
    sendEmailOtpCallCount++;
  }

  @override
  Future<void> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    _session = _newSession();
    _controller.add(AuthState(AuthChangeEvent.signedIn, _session));
  }

  @override
  Future<void> setPassword(String password) async {}

  @override
  Future<void> signIn({required String email, required String password}) async {
    _session = _newSession();
    _controller.add(AuthState(AuthChangeEvent.signedIn, _session));
  }

  @override
  Future<void> signOut() async {
    _session = null;
    _controller.add(const AuthState(AuthChangeEvent.signedOut, null));
  }

  @override
  Future<void> resetPasswordForEmail(String email) async {}
}

// `Override` isn't part of flutter_riverpod's own public export surface
// (it's curated down via a `show` clause) but riverpod_annotation re-
// exports it, which is already a direct dependency of this app.
// guideRepositoryProvider now defaults to SupabaseGuideRepository (real
// backend) — overridden here with the in-memory fake so these widget tests
// keep running without a live Supabase connection. A fresh
// StaticGuideRepository per call means each test gets its own isolated
// mutable state, same isolation _FakeAuthRepository already gives auth.
//
// sharedPreferencesProvider reads from `_sharedPreferences`, reset to an
// empty mock store by the `setUp` below before every test — AppShell reads
// it (via debugMenuUnlockedProvider) on every render, so leaving it
// unoverridden would throw in every single test, not just ones that
// exercise the Debug tab.
late SharedPreferences _sharedPreferences;

List<Override> _testOverrides({
  bool signedIn = true,
  AuthRepository? authRepository,
}) => [
  authRepositoryProvider.overrideWithValue(
    authRepository ?? _FakeAuthRepository(signedIn: signedIn),
  ),
  guideRepositoryProvider.overrideWithValue(StaticGuideRepository()),
  challengeRepositoryProvider.overrideWithValue(StaticChallengeRepository()),
  profileRepositoryProvider.overrideWithValue(StaticProfileRepository()),
  eventsRepositoryProvider.overrideWithValue(StaticEventsRepository()),
  chapterRepositoryProvider.overrideWithValue(const StaticChapterRepository()),
  sharedPreferencesProvider.overrideWithValue(_sharedPreferences),
];

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    _sharedPreferences = await SharedPreferences.getInstance();
  });

  testWidgets('Today screen renders the weekly focus and tab bar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: _testOverrides(), child: const FraternusApp()),
    );
    await tester.pumpAndSettle();

    // "TODAY" renders twice: the active bottom-tab label and the "Today"
    // section eyebrow above the person tabs.
    expect(find.text('TODAY'), findsNWidgets(2));
    expect(find.text('HUMILITY'), findsOneWidget);
    expect(find.text('GUIDE'), findsOneWidget);
    expect(find.text('CHALLENGE'), findsOneWidget);
    expect(find.text('EVENTS'), findsOneWidget);
  });

  testWidgets('Events tab lists events and pushes a detail screen on tap', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: _testOverrides(), child: const FraternusApp()),
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

    await tester.tap(find.text('HAWC Night'));
    await tester.pumpAndSettle();

    // "EVENTS" now renders twice: the bottom-tab label and the "< EVENTS"
    // back breadcrumb on the detail screen.
    expect(find.text('EVENTS'), findsNWidgets(2));
    expect(find.text('HAWC NIGHT'), findsOneWidget);
    expect(find.text('RSVP'), findsOneWidget);
    expect(find.text('OTHERS ATTENDING'), findsOneWidget);
  });

  testWidgets(
    'Challenge tab renders all 3 states and links to Past Challenges',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: _testOverrides(), child: const FraternusApp()),
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

  testWidgets(
    'Tapping Today in the bottom nav returns to the Today root after a task push',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: _testOverrides(), child: const FraternusApp()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Weekly Challenge'));
      await tester.pumpAndSettle();
      expect(find.text('WEEKLY CHALLENGE'), findsOneWidget);

      await tester.tap(find.text('TODAY'));
      await tester.pumpAndSettle();
      expect(find.text('HUMILITY'), findsOneWidget);
    },
  );

  testWidgets('Guide tab renders the daily reading and completes/undoes it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: _testOverrides(), child: const FraternusApp()),
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
      ProviderScope(overrides: _testOverrides(), child: const FraternusApp()),
    );
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

  testWidgets('Tapping a temperament card pushes its own detail screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: _testOverrides(), child: const FraternusApp()),
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
            ..._testOverrides(),
            guideSelectedDateProvider.overrideWith(_FarPastGuideDate.new),
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

  testWidgets(
    'Tapping Today in the bottom nav returns to the Today root after a Field Guide push',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: _testOverrides(), child: const FraternusApp()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text("Today's Field Guide Reading"));
      await tester.pumpAndSettle();
      expect(find.text('IDENTITY'), findsOneWidget);

      await tester.tap(find.text('TODAY'));
      await tester.pumpAndSettle();
      expect(find.text('HUMILITY'), findsOneWidget);
    },
  );

  testWidgets(
    "Tapping This Week's Focus on Today pushes the same virtue detail screen Guide links to",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: _testOverrides(), child: const FraternusApp()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('HUMILITY'));
      await tester.pumpAndSettle();

      // "GUIDE" renders twice: the bottom-tab label and the "< GUIDE" breadcrumb.
      expect(find.text('GUIDE'), findsNWidgets(2));
      expect(find.text('THE TEMPERAMENTS'), findsOneWidget);

      await tester.tap(find.text('TODAY'));
      await tester.pumpAndSettle();
      expect(find.text('HUMILITY'), findsOneWidget);
    },
  );

  testWidgets('Tapping See All on Today pushes the Events tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: _testOverrides(), child: const FraternusApp()),
    );
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

  testWidgets('Tapping the profile icon opens Profile', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: _testOverrides(), child: const FraternusApp()),
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
      ProviderScope(overrides: _testOverrides(), child: const FraternusApp()),
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

  testWidgets('My Kids lists both children and Edit -> Remove Child removes one', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: _testOverrides(), child: const FraternusApp()),
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
  });

  testWidgets('Add Child opens the Add Child form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: _testOverrides(), child: const FraternusApp()),
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
      ProviderScope(overrides: _testOverrides(), child: const FraternusApp()),
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
        ProviderScope(overrides: _testOverrides(), child: const FraternusApp()),
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
      ProviderScope(overrides: _testOverrides(), child: const FraternusApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('PROFILE'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();

    expect(find.text('HUMILITY'), findsOneWidget);
  });

  testWidgets(
    'Find Your Temperament walks the quiz end to end and saves a result',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: _testOverrides(), child: const FraternusApp()),
      );
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

      // Back on the virtue detail screen, Jack's saved result now shows
      // Primary/Secondary tags instead of the CTA.
      expect(find.text('FIND YOUR TEMPERAMENT'), findsNothing);
      expect(find.text('PRIMARY'), findsOneWidget);
    },
  );

  testWidgets('Take Again on Profile opens the quiz for the current result', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: _testOverrides(), child: const FraternusApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();

    // "You" is pre-seeded with a result, so Profile shows Take Again.
    await tester.tap(find.text('TAKE AGAIN'));
    await tester.pumpAndSettle();

    expect(find.text('THE FOUR TEMPERAMENTS'), findsOneWidget);
  });

  testWidgets(
    'Signed-out app redirects straight to the welcome screen, not the tab shell',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _testOverrides(signedIn: false),
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
          overrides: _testOverrides(signedIn: false),
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
        overrides: _testOverrides(signedIn: false),
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

  testWidgets(
    'Sign-up flow: Brother is blocked, Parent or Volunteer continues to the wizard',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _testOverrides(signedIn: false),
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
          overrides: _testOverrides(signedIn: false),
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
    final fakeAuth = _FakeAuthRepository(signedIn: false);
    await tester.pumpWidget(
      ProviderScope(
        overrides: _testOverrides(signedIn: false, authRepository: fakeAuth),
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
          overrides: _testOverrides(signedIn: false),
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
          overrides: _testOverrides(signedIn: false),
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

      await tester.tap(find.text('Add'));
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
