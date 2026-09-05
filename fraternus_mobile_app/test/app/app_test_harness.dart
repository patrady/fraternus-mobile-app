import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fraternus_mobile_app/app/shared_preferences_provider.dart';
import 'package:fraternus_mobile_app/features/auth/data/auth_repository.dart';
import 'package:fraternus_mobile_app/features/auth/providers/auth_providers.dart';
import 'package:fraternus_mobile_app/features/challenge/data/challenge_repository.dart';
import 'package:fraternus_mobile_app/features/challenge/providers/challenge_providers.dart';
import 'package:fraternus_mobile_app/features/events/data/events_repository.dart';
import 'package:fraternus_mobile_app/features/events/providers/events_providers.dart';
import 'package:fraternus_mobile_app/features/guide/data/guide_repository.dart';
import 'package:fraternus_mobile_app/features/guide/data/temperament_quiz_repository.dart';
import 'package:fraternus_mobile_app/features/guide/providers/guide_providers.dart';
import 'package:fraternus_mobile_app/features/guide/providers/temperament_quiz_providers.dart';
import 'package:fraternus_mobile_app/features/profile/data/profile_repository.dart';
import 'package:fraternus_mobile_app/features/profile/providers/profile_providers.dart';
import 'package:fraternus_mobile_app/shared/data/chapter_repository.dart';
import 'package:fraternus_mobile_app/shared/providers/chapter_providers.dart';

/// Shared setup for the full-app (`FraternusApp`) widget tests under
/// test/app/ — split out of what was originally one large widget_test.dart
/// so each flow's tests can live in their own file while still sharing one
/// fake auth repository, one set of Static*Repository overrides, and one
/// SharedPreferences reset.

/// A date far outside the single seeded Field Guide week, for exercising
/// the "nothing to read" fallback.
class FarPastGuideDate extends GuideSelectedDate {
  @override
  DateTime build() => DateTime(2000, 1, 1);
}

/// The auth gate in app/router/app_router.dart redirects to sign-in
/// whenever `AuthRepository.currentSession` is null, and re-evaluates that
/// redirect whenever `authStateChanges` fires (via `refreshListenable`).
/// This fake starts signed in (so most widget tests exercise the
/// authenticated app without touching real Supabase Auth) but stays fully
/// stateful — `signOut`/`signIn`/`signUp` really flip `currentSession` and
/// emit on the stream — so a "Log Out" test genuinely proves the router's
/// redirect wiring works, not just the button's own UI.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({bool signedIn = true}) {
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
// mutable state, same isolation FakeAuthRepository already gives auth.
//
// sharedPreferencesProvider reads from the mock store `resetSharedPreferences`
// resets before every test — AppShell reads it (via
// debugMenuUnlockedProvider) on every render, so leaving it unoverridden
// would throw in every single test, not just ones that exercise the Debug
// tab.
late SharedPreferences _sharedPreferences;

/// Call from each flow file's own `setUp` before pumping `FraternusApp`.
Future<void> resetSharedPreferences() async {
  SharedPreferences.setMockInitialValues({});
  _sharedPreferences = await SharedPreferences.getInstance();
}

List<Override> testOverrides({
  bool signedIn = true,
  AuthRepository? authRepository,
}) => [
  authRepositoryProvider.overrideWithValue(
    authRepository ?? FakeAuthRepository(signedIn: signedIn),
  ),
  guideRepositoryProvider.overrideWithValue(StaticGuideRepository()),
  temperamentQuizRepositoryProvider.overrideWithValue(
    StaticTemperamentQuizRepository(),
  ),
  challengeRepositoryProvider.overrideWithValue(StaticChallengeRepository()),
  profileRepositoryProvider.overrideWithValue(StaticProfileRepository()),
  eventsRepositoryProvider.overrideWithValue(StaticEventsRepository()),
  chapterRepositoryProvider.overrideWithValue(const StaticChapterRepository()),
  sharedPreferencesProvider.overrideWithValue(_sharedPreferences),
];
