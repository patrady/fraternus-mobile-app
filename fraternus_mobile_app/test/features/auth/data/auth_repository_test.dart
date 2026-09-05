import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/auth/data/auth_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockUserResponse extends Mock implements UserResponse {}

void main() {
  setUpAll(() {
    registerFallbackValue(OtpType.email);
    registerFallbackValue(UserAttributes());
  });

  late _MockSupabaseClient client;
  late _MockGoTrueClient auth;
  late SupabaseAuthRepository repository;

  setUp(() {
    client = _MockSupabaseClient();
    auth = _MockGoTrueClient();
    when(() => client.auth).thenReturn(auth);
    repository = SupabaseAuthRepository(client);
  });

  test('authStateChanges passes through the client auth stream', () async {
    final controller = Stream<AuthState>.fromIterable([
      AuthState(AuthChangeEvent.signedIn, null),
    ]);
    when(() => auth.onAuthStateChange).thenAnswer((_) => controller);

    final event = await repository.authStateChanges.first;

    expect(event.event, AuthChangeEvent.signedIn);
  });

  test('currentSession passes through the client', () {
    when(() => auth.currentSession).thenReturn(null);

    expect(repository.currentSession, isNull);
  });

  test('sendEmailOtp calls signInWithOtp allowing new-user creation', () async {
    when(() => auth.signInWithOtp(email: any(named: 'email'), shouldCreateUser: true))
        .thenAnswer((_) async {});

    await repository.sendEmailOtp('brother@example.com');

    verify(
      () => auth.signInWithOtp(email: 'brother@example.com', shouldCreateUser: true),
    ).called(1);
  });

  test('verifyEmailOtp verifies an email-type OTP', () async {
    when(
      () => auth.verifyOTP(
        type: any(named: 'type'),
        email: any(named: 'email'),
        token: any(named: 'token'),
      ),
    ).thenAnswer((_) async => AuthResponse());

    await repository.verifyEmailOtp(email: 'brother@example.com', token: '123456');

    verify(
      () => auth.verifyOTP(
        type: OtpType.email,
        email: 'brother@example.com',
        token: '123456',
      ),
    ).called(1);
  });

  test('setPassword updates the current user password', () async {
    when(() => auth.updateUser(any())).thenAnswer((_) async => _MockUserResponse());

    await repository.setPassword('s3cr3t-password');

    final captured = verify(() => auth.updateUser(captureAny())).captured;
    expect((captured.single as UserAttributes).password, 's3cr3t-password');
  });

  test('signIn calls signInWithPassword with the given credentials', () async {
    when(
      () => auth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => AuthResponse());

    await repository.signIn(email: 'brother@example.com', password: 'hunter2');

    verify(
      () => auth.signInWithPassword(email: 'brother@example.com', password: 'hunter2'),
    ).called(1);
  });

  test('signIn lets a wrong-credentials failure surface instead of swallowing it', () {
    when(
      () => auth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const AuthException('Invalid login credentials'));

    expect(
      () => repository.signIn(email: 'brother@example.com', password: 'wrong'),
      throwsA(isA<AuthException>()),
    );
  });

  test('signOut delegates to the client', () async {
    when(() => auth.signOut()).thenAnswer((_) async {});

    await repository.signOut();

    verify(() => auth.signOut()).called(1);
  });

  test('resetPasswordForEmail delegates to the client', () async {
    when(() => auth.resetPasswordForEmail(any())).thenAnswer((_) async {});

    await repository.resetPasswordForEmail('brother@example.com');

    verify(() => auth.resetPasswordForEmail('brother@example.com')).called(1);
  });
}
