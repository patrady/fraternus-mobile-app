import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/profile/data/profile_repository.dart';
import 'package:fraternus_mobile_app/features/profile/models/app_user.dart';
import 'package:fraternus_mobile_app/features/profile/models/member.dart';
import 'package:fraternus_mobile_app/features/profile/models/reminder_setting.dart';
import 'package:fraternus_mobile_app/features/profile/models/user_member_association.dart';
import 'package:fraternus_mobile_app/features/profile/providers/profile_providers.dart';

/// Wraps a real [StaticProfileRepository] but lets a single named write
/// method be made to fail on demand, so rollback branches (every optimistic
/// Notifier in profile_providers.dart) have something to actually roll back
/// from — StaticProfileRepository itself never fails.
class _FlakyProfileRepository implements ProfileRepository {
  _FlakyProfileRepository(this._inner);

  final StaticProfileRepository _inner;
  String? failing;

  void _maybeThrow(String method) {
    if (failing == method) throw StateError('$method failed');
  }

  @override
  Future<AppUser> fetchCurrentUser() => _inner.fetchCurrentUser();
  @override
  Future<List<Member>> fetchMembers() => _inner.fetchMembers();
  @override
  Future<List<UserMemberAssociation>> fetchAssociations() =>
      _inner.fetchAssociations();
  @override
  Future<List<ReminderGroup>> fetchReminders() => _inner.fetchReminders();

  @override
  Future<void> updateProfile(AppUser user) async {
    _maybeThrow('updateProfile');
    return _inner.updateProfile(user);
  }

  @override
  Future<void> updateMember(Member member) async {
    _maybeThrow('updateMember');
    return _inner.updateMember(member);
  }

  @override
  Future<String> createChildMember({
    required String firstName,
    required String lastName,
    required String chapterKey,
    String? email,
  }) => _inner.createChildMember(
    firstName: firstName,
    lastName: lastName,
    chapterKey: chapterKey,
    email: email,
  );

  @override
  Future<String> completeCaptainSignup({
    required String chapterKey,
    required String firstName,
    required String lastName,
  }) => _inner.completeCaptainSignup(
    chapterKey: chapterKey,
    firstName: firstName,
    lastName: lastName,
  );

  @override
  Future<void> deleteMember(String memberId) => _inner.deleteMember(memberId);

  @override
  Future<void> setReminderEnabled(ReminderType type, bool enabled) async {
    _maybeThrow('setReminderEnabled');
    return _inner.setReminderEnabled(type, enabled);
  }

  @override
  Future<void> setRemindersEnabled(bool enabled) async {
    _maybeThrow('setRemindersEnabled');
    return _inner.setRemindersEnabled(enabled);
  }
}

void main() {
  late _FlakyProfileRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FlakyProfileRepository(StaticProfileRepository());
    container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() => container.dispose());

  group('CurrentUser', () {
    test('toggleRemindersEnabled flips optimistically and persists', () async {
      final before = await container.read(currentUserProvider.future);
      expect(before.isRemindersEnabled, isTrue);

      await container.read(currentUserProvider.notifier).toggleRemindersEnabled();

      expect(container.read(currentUserProvider).value!.isRemindersEnabled, isFalse);
      expect((await repository.fetchCurrentUser()).isRemindersEnabled, isFalse);
    });

    test('toggleRemindersEnabled rolls back on a failed write', () async {
      await container.read(currentUserProvider.future);
      repository.failing = 'setRemindersEnabled';

      await expectLater(
        container.read(currentUserProvider.notifier).toggleRemindersEnabled(),
        throwsA(isA<StateError>()),
      );

      expect(container.read(currentUserProvider).value!.isRemindersEnabled, isTrue);
    });
  });

  group('HouseholdMembers', () {
    test('remove invalidates both itself and householdAssociations', () async {
      final members = await container.read(householdMembersProvider.future);
      final jack = members.firstWhere((m) => m.id == 'jack');

      await container.read(householdMembersProvider.notifier).remove(jack.id);

      final afterMembers = await container.read(householdMembersProvider.future);
      final afterAssociations = await container.read(
        householdAssociationsProvider.future,
      );
      expect(afterMembers.any((m) => m.id == jack.id), isFalse);
      expect(afterAssociations.any((a) => a.memberId == jack.id), isFalse);
    });
  });

  test('selfMember resolves the Self-relationship member', () async {
    final self = await container.read(selfMemberProvider.future);

    expect(self?.id, 'you');
  });

  test('guardianMembers resolves every Guardian-relationship member', () async {
    final guardianMembers = await container.read(guardianMembersProvider.future);

    expect(guardianMembers.map((m) => m.id).toSet(), {'jack', 'thomas'});
  });

  group('ProfileReminders.toggle', () {
    test('flips only the targeted reminder and persists it', () async {
      await container.read(profileRemindersProvider.future);

      await container
          .read(profileRemindersProvider.notifier)
          .toggle(ReminderType.event1hr);

      final groups = container.read(profileRemindersProvider).value!;
      final byType = {
        for (final g in groups) for (final r in g.reminders) r.type: r.enabled,
      };
      expect(byType[ReminderType.event1hr], isFalse);
      expect(
        byType.entries.where((e) => e.key != ReminderType.event1hr).every((e) => e.value),
        isTrue,
      );
    });

    test('rolls back if the write fails', () async {
      await container.read(profileRemindersProvider.future);
      repository.failing = 'setReminderEnabled';

      await expectLater(
        container
            .read(profileRemindersProvider.notifier)
            .toggle(ReminderType.event1hr),
        throwsA(isA<StateError>()),
      );

      final groups = container.read(profileRemindersProvider).value!;
      expect(groups.expand((g) => g.reminders).every((r) => r.enabled), isTrue);
    });
  });
}
