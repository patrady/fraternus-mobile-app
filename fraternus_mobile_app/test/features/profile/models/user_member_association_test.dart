import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/profile/models/user_member_association.dart';

void main() {
  group('UserMemberAssociation.fromJson', () {
    test('maps every field', () {
      final association = UserMemberAssociation.fromJson({
        'id': 'assoc-1',
        'user_id': 'user-1',
        'member_id': 'member-1',
        'relationship': 'guardian',
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-02T00:00:00Z',
      });

      expect(association.userId, 'user-1');
      expect(association.memberId, 'member-1');
      expect(association.relationship, AssociationRelationship.guardian);
    });

    test('parses every known relationship', () {
      for (final relationship in AssociationRelationship.values) {
        final association = UserMemberAssociation.fromJson({
          'id': 'assoc-1',
          'user_id': 'user-1',
          'member_id': 'member-1',
          'relationship': relationship.name,
          'created_at': '2026-01-01T00:00:00Z',
          'updated_at': '2026-01-02T00:00:00Z',
        });
        expect(association.relationship, relationship);
      }
    });

    test('an unrecognized relationship throws rather than silently defaulting', () {
      expect(
        () => UserMemberAssociation.fromJson({
          'id': 'assoc-1',
          'user_id': 'user-1',
          'member_id': 'member-1',
          'relationship': 'stranger',
          'created_at': '2026-01-01T00:00:00Z',
          'updated_at': '2026-01-02T00:00:00Z',
        }),
        throwsArgumentError,
      );
    });
  });
}
