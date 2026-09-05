import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/guide/models/field_guide_week_quote.dart';

Map<String, dynamic> _json({List<dynamic>? members}) => {
  'id': 'quote-1',
  'field_guide_week_id': 'week-1',
  'quote': 'A quote',
  'author': 'An author',
  'field_guide_week_quotes_members': members,
  'created_at': '2026-01-05T00:00:00Z',
  'updated_at': '2026-01-05T00:00:00Z',
};

void main() {
  group('FieldGuideWeekQuote.fromJson', () {
    test('defaults members to empty when the embed is absent', () {
      expect(FieldGuideWeekQuote.fromJson(_json()).members, isEmpty);
    });
  });

  group('FieldGuideWeekQuote.isFavoriteFor', () {
    test('returns the matching member row favorite state', () {
      final quote = FieldGuideWeekQuote.fromJson(
        _json(
          members: [
            {
              'id': 'row-1',
              'field_guide_week_quotes_id': 'quote-1',
              'member_id': 'member-1',
              'is_favorite': true,
              'created_at': '2026-01-05T00:00:00Z',
              'updated_at': '2026-01-05T00:00:00Z',
            },
          ],
        ),
      );

      expect(quote.isFavoriteFor('member-1'), isTrue);
    });

    test('a member with no row is not a favorite', () {
      final quote = FieldGuideWeekQuote.fromJson(_json());
      expect(quote.isFavoriteFor('member-1'), isFalse);
    });
  });
}
