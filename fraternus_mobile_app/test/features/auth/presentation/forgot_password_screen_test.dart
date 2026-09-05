import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/auth/data/auth_repository.dart';
import 'package:fraternus_mobile_app/features/auth/presentation/forgot_password_screen.dart';
import 'package:fraternus_mobile_app/features/auth/providers/auth_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.shouldFail = false, this.delay});

  final bool shouldFail;

  /// When set, resetPasswordForEmail waits on this before resolving — lets
  /// a test observe the in-flight "SENDING…" state deterministically
  /// instead of racing a same-microtask-resolving fake.
  final Completer<void>? delay;
  String? requestedEmail;

  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();
  @override
  Session? get currentSession => null;
  @override
  Future<void> sendEmailOtp(String email) async {}
  @override
  Future<void> verifyEmailOtp({required String email, required String token}) async {}
  @override
  Future<void> setPassword(String password) async {}
  @override
  Future<void> signIn({required String email, required String password}) async {}
  @override
  Future<void> signOut() async {}

  @override
  Future<void> resetPasswordForEmail(String email) async {
    requestedEmail = email;
    if (delay != null) await delay!.future;
    if (shouldFail) throw const AuthException('boom');
  }
}

Future<void> _pump(WidgetTester tester, AuthRepository repository) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const Placeholder()),
      GoRoute(path: '/forgot', builder: (_, _) => const ForgotPasswordScreen()),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(
        routerConfig: router,
        // Mirrors fraternus_app.dart's own builder — this app's design
        // system widgets (FormTextField -> TextField) need a Material
        // ancestor that MaterialApp.router doesn't provide by itself.
        builder: (context, child) => Material(type: MaterialType.transparency, child: child),
      ),
    ),
  );
  router.push('/forgot');
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sends a trimmed email and shows the confirmation copy on success', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    await _pump(tester, repository);

    await tester.enterText(find.byType(TextField), '  brother@example.com  ');
    await tester.tap(find.text('SEND RESET LINK'));
    await tester.pump();

    expect(repository.requestedEmail, 'brother@example.com');
    await tester.pumpAndSettle();
    expect(
      find.text(
        "If an account exists for that email, we've sent a link to reset your password.",
      ),
      findsOneWidget,
    );
    expect(find.text('SEND RESET LINK'), findsNothing);
  });

  testWidgets('shows an error message and stays on the form when the request fails', (
    tester,
  ) async {
    await _pump(tester, _FakeAuthRepository(shouldFail: true));

    await tester.enterText(find.byType(TextField), 'brother@example.com');
    await tester.tap(find.text('SEND RESET LINK'));
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong. Try again in a moment.'), findsOneWidget);
    expect(find.text('SEND RESET LINK'), findsOneWidget);
  });

  testWidgets('shows a sending label on the frame between tap and completion', (
    tester,
  ) async {
    final delay = Completer<void>();
    await _pump(tester, _FakeAuthRepository(delay: delay));

    await tester.enterText(find.byType(TextField), 'brother@example.com');
    await tester.tap(find.text('SEND RESET LINK'));
    await tester.pump();

    expect(find.text('SENDING…'), findsOneWidget);

    delay.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('the back button pops the route', (tester) async {
    await _pump(tester, _FakeAuthRepository());

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(ForgotPasswordScreen), findsNothing);
  });
}
