import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/guide/models/field_guide_daily_devotional.dart';

Map<String, dynamic> _json({List<dynamic>? members}) => {
  'id': 'devotional-1',
  'field_guide_week_id': 'week-1',
  'day_number': 1,
  'identity_reading': 'reading text',
  'wisdom_quote': 'quote text',
  'wisdom_author': 'author',
  'sword_option_1': 'Option A',
  'sword_option_2': 'Option B',
  'spade_prompt': 'prompt text',
  'closing_prayer': 'prayer text',
  'closing_prayer_author': 'prayer author',
  'field_guide_daily_devotional_members': members,
  'created_at': '2026-01-05T00:00:00Z',
  'updated_at': '2026-01-05T00:00:00Z',
};

void main() {
  group('FieldGuideDailyDevotional.fromJson', () {
    test('defaults members to empty when the embed is absent', () {
      final devotional = FieldGuideDailyDevotional.fromJson(_json());
      expect(devotional.members, isEmpty);
    });

    test('parses the nested members embed', () {
      final devotional = FieldGuideDailyDevotional.fromJson(
        _json(
          members: [
            {
              'id': 'member-row-1',
              'daily_devotional_id': 'devotional-1',
              'member_id': 'member-1',
              'created_at': '2026-01-05T00:00:00Z',
              'updated_at': '2026-01-05T00:00:00Z',
            },
          ],
        ),
      );

      expect(devotional.members, hasLength(1));
      expect(devotional.members.single.memberId, 'member-1');
    });
  });

  group('FieldGuideDailyDevotional.swordOptions', () {
    test('collects both options into a list, in order', () {
      final devotional = FieldGuideDailyDevotional.fromJson(_json());
      expect(devotional.swordOptions, ['Option A', 'Option B']);
    });
  });
}
