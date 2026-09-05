import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/profile/models/member.dart';

Map<String, dynamic> _json({String? email}) => {
  'id': 'member-1',
  'first_name': 'Tommy',
  'last_name': 'Smith',
  'role': 'brother',
  'chapter_key': 'chapter-1',
  'email': email,
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-02T00:00:00Z',
};

void main() {
  group('Member.fromJson', () {
    test('maps every field, including a present email', () {
      final member = Member.fromJson(_json(email: 'tommy@example.com'));

      expect(member.id, 'member-1');
      expect(member.role, MemberRole.brother);
      expect(member.chapterKey, 'chapter-1');
      expect(member.email, 'tommy@example.com');
    });

    test('a Brother with no email parses to null, not a crash', () {
      final member = Member.fromJson(_json());
      expect(member.email, isNull);
    });

    test('parses every known role', () {
      for (final role in MemberRole.values) {
        final member = Member.fromJson({..._json(), 'role': role.name});
        expect(member.role, role);
      }
    });
  });

  group('Member getters', () {
    test('fullName and initials derive from first/last name', () {
      final member = Member.fromJson(_json());
      expect(member.fullName, 'Tommy Smith');
      expect(member.initials, 'TS');
    });
  });

  group('Member.copyWith', () {
    final base = Member.fromJson(_json(email: 'tommy@example.com'));

    test('leaves fields untouched when no argument given', () {
      final copy = base.copyWith();
      expect(copy.email, base.email);
      expect(copy.firstName, base.firstName);
    });

    test('clearEmail nulls email even though the email arg is unset', () {
      final copy = base.copyWith(clearEmail: true);
      expect(copy.email, isNull);
    });

    test('an explicit email wins over clearEmail default', () {
      final copy = base.copyWith(email: 'new@example.com');
      expect(copy.email, 'new@example.com');
    });
  });
}
