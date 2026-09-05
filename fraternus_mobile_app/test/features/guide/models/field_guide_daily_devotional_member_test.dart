import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/guide/models/field_guide_daily_devotional_member.dart';

void main() {
  group('FieldGuideDailyDevotionalMember.fromJson', () {
    test('parses a completed row', () {
      final member = FieldGuideDailyDevotionalMember.fromJson({
        'id': 'row-1',
        'daily_devotional_id': 'devotional-1',
        'member_id': 'member-1',
        'submitted_by_user_id': 'user-1',
        'sword': 'Chosen sword option',
        'spade': 'My answer',
        'completed_date': '2026-01-05T00:00:00Z',
        'is_identity_favorite': true,
        'is_wisdom_favorite': false,
        'created_at': '2026-01-05T00:00:00Z',
        'updated_at': '2026-01-05T00:00:00Z',
      });

      expect(member.isCompleted, isTrue);
      expect(member.sword, 'Chosen sword option');
    });

    test('defaults favorite flags to false and completedDate to null when absent', () {
      final member = FieldGuideDailyDevotionalMember.fromJson({
        'id': 'row-1',
        'daily_devotional_id': 'devotional-1',
        'member_id': 'member-1',
        'completed_date': null,
        'created_at': '2026-01-05T00:00:00Z',
        'updated_at': '2026-01-05T00:00:00Z',
      });

      expect(member.isIdentityFavorite, isFalse);
      expect(member.isWisdomFavorite, isFalse);
      expect(member.isCompleted, isFalse);
    });
  });

  group('FieldGuideDailyDevotionalMember.copyWith', () {
    final base = FieldGuideDailyDevotionalMember.fromJson({
      'id': 'row-1',
      'daily_devotional_id': 'devotional-1',
      'member_id': 'member-1',
      'completed_date': '2026-01-05T00:00:00Z',
      'created_at': '2026-01-05T00:00:00Z',
      'updated_at': '2026-01-05T00:00:00Z',
    });

    test('clearCompleted nulls completedDate even though completedDate arg is unset', () {
      final copy = base.copyWith(clearCompleted: true);
      expect(copy.completedDate, isNull);
    });

    test('an explicit sword/spade update leaves other fields untouched', () {
      final copy = base.copyWith(sword: 'New option', spade: 'New answer');
      expect(copy.sword, 'New option');
      expect(copy.spade, 'New answer');
      expect(copy.completedDate, base.completedDate);
      expect(copy.memberId, base.memberId);
    });
  });
}
