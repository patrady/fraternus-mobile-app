import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/challenge/models/challenge_member_rep.dart';

void main() {
  group('ChallengeMemberRep.fromJson', () {
    test('parses every field', () {
      final rep = ChallengeMemberRep.fromJson({
        'id': 'rep-1',
        'challenge_member_id': 'member-1',
        'completed_by_user_id': 'user-1',
        'number': 2,
        'created_at': '2026-01-05T12:00:00Z',
      });

      expect(rep.id, 'rep-1');
      expect(rep.challengeMemberId, 'member-1');
      expect(rep.completedByUserId, 'user-1');
      expect(rep.number, 2);
      expect(rep.createdAt, DateTime.parse('2026-01-05T12:00:00Z'));
    });

    test('defaults completedByUserId to empty string when absent', () {
      final rep = ChallengeMemberRep.fromJson({
        'id': 'rep-1',
        'challenge_member_id': 'member-1',
        'completed_by_user_id': null,
        'number': 1,
        'created_at': '2026-01-05T12:00:00Z',
      });

      expect(rep.completedByUserId, '');
    });
  });
}
