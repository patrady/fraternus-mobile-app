import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/profile/data/profile_repository.dart';
import 'package:fraternus_mobile_app/features/profile/models/member.dart';
import 'package:fraternus_mobile_app/features/profile/models/reminder_setting.dart';
import 'package:fraternus_mobile_app/features/profile/models/user_member_association.dart';

void main() {
  group('StaticProfileRepository', () {
    late StaticProfileRepository repository;

    setUp(() {
      repository = StaticProfileRepository();
    });

    test('createChildMember adds a Brother Member and a Guardian association', () async {
      final id = await repository.createChildMember(
        firstName: 'Peter',
        lastName: 'Smith',
        chapterKey: 'st_philips_franklin_franklin_tn',
      );

      final members = await repository.fetchMembers();
      final associations = await repository.fetchAssociations();

      final child = members.singleWhere((m) => m.id == id);
      expect(child.firstName, 'Peter');
      expect(child.lastName, 'Smith');
      expect(child.role, MemberRole.brother);
      expect(child.email, isNull);

      final association = associations.singleWhere((a) => a.memberId == id);
      expect(association.relationship, AssociationRelationship.guardian);
    });

    test('createChildMember carries the optional email through when given', () async {
      final id = await repository.createChildMember(
        firstName: 'Paul',
        lastName: 'Smith',
        chapterKey: 'st_philips_franklin_franklin_tn',
        email: 'paul@example.com',
      );

      final members = await repository.fetchMembers();
      expect(members.singleWhere((m) => m.id == id).email, 'paul@example.com');
    });

    test('completeCaptainSignup adds a Captain Member and a Self association', () async {
      final id = await repository.completeCaptainSignup(
        chapterKey: 'sacred_heart_nashville_tn',
        firstName: 'Mark',
        lastName: 'Jones',
      );

      final members = await repository.fetchMembers();
      final associations = await repository.fetchAssociations();

      final self = members.singleWhere((m) => m.id == id);
      expect(self.role, MemberRole.captain);
      // completeCaptainSignup inherits the account's email, not a new one.
      expect(self.email, 'john.smith@example.com');

      final association = associations.singleWhere((a) => a.memberId == id);
      expect(association.relationship, AssociationRelationship.self);
    });

    test(
      'deleteMember removes both the Member and its association (mirrors the '
      'cascading delete ADR 0003 describes server-side)',
      () async {
        final id = await repository.createChildMember(
          firstName: 'Temp',
          lastName: 'Child',
          chapterKey: 'st_philips_franklin_franklin_tn',
        );

        await repository.deleteMember(id);

        final members = await repository.fetchMembers();
        final associations = await repository.fetchAssociations();
        expect(members.any((m) => m.id == id), isFalse);
        expect(associations.any((a) => a.memberId == id), isFalse);
      },
    );

    test('updateMember is a no-op for an id that does not exist', () async {
      final before = await repository.fetchMembers();

      await repository.updateMember(
        Member(
          id: 'does-not-exist',
          firstName: 'Nobody',
          lastName: 'Here',
          role: MemberRole.brother,
          chapterKey: 'st_philips_franklin_franklin_tn',
          createdAt: DateTime(2024),
          lastModifiedAt: DateTime(2024),
        ),
      );

      final after = await repository.fetchMembers();
      expect(after, before);
    });

    test('updateMember replaces the matching member in place', () async {
      final members = await repository.fetchMembers();
      final jack = members.firstWhere((m) => m.id == 'jack');

      await repository.updateMember(
        Member(
          id: jack.id,
          firstName: 'Jackson',
          lastName: jack.lastName,
          role: jack.role,
          chapterKey: jack.chapterKey,
          email: jack.email,
          createdAt: jack.createdAt,
          lastModifiedAt: jack.lastModifiedAt,
        ),
      );

      final updated = (await repository.fetchMembers()).firstWhere((m) => m.id == 'jack');
      expect(updated.firstName, 'Jackson');
    });

    test(
      'fetchReminders defaults every type to enabled until overridden, and '
      'setReminderEnabled only overrides the one type it targets',
      () async {
        final initial = await repository.fetchReminders();
        expect(initial.expand((g) => g.reminders).every((r) => r.enabled), isTrue);

        await repository.setReminderEnabled(ReminderType.challengeMidWeek, false);

        final after = await repository.fetchReminders();
        final settingsByType = {for (final s in after.expand((g) => g.reminders)) s.type: s};
        expect(settingsByType[ReminderType.challengeMidWeek]!.enabled, isFalse);
        expect(
          settingsByType.entries
              .where((e) => e.key != ReminderType.challengeMidWeek)
              .every((e) => e.value.enabled),
          isTrue,
        );
      },
    );

    test('setRemindersEnabled flips the master switch on the current user', () async {
      await repository.setRemindersEnabled(false);

      final user = await repository.fetchCurrentUser();
      expect(user.isRemindersEnabled, isFalse);
    });
  });
}
