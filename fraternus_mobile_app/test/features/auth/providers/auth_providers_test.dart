import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/auth/data/auth_repository.dart';
import 'package:fraternus_mobile_app/features/auth/providers/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AuthState>.broadcast();

  @override
  Stream<AuthState> get authStateChanges => _controller.stream;

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
  Future<void> resetPasswordForEmail(String email) async {}
}

void main() {
  test('authStateChangesProvider forwards events from the repository', () async {
    final fake = _FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);
    addTearDown(fake._controller.close);

    final events = <AuthChangeEvent>[];
    final sub = container.listen(authStateChangesProvider, (previous, next) {
      next.whenData((state) => events.add(state.event));
    });
    addTearDown(sub.close);

    fake._controller.add(AuthState(AuthChangeEvent.signedIn, null));
    await Future<void>.delayed(Duration.zero);

    expect(events, [AuthChangeEvent.signedIn]);
  });

  group('SignUpWizardActive', () {
    test('starts false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(signUpWizardActiveProvider), isFalse);
    });

    test('set() updates the state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(signUpWizardActiveProvider.notifier).set(true);

      expect(container.read(signUpWizardActiveProvider), isTrue);
    });

    test('stays true even once nothing is watching it (keepAlive)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sub = container.listen(signUpWizardActiveProvider, (_, _) {});
      container.read(signUpWizardActiveProvider.notifier).set(true);
      sub.close();

      // Let autoDispose-style teardown (if it were not keepAlive) run.
      await Future<void>.delayed(Duration.zero);

      expect(container.read(signUpWizardActiveProvider), isTrue);
    });
  });
}
