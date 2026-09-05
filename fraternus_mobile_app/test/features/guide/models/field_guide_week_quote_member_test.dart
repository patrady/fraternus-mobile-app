import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/guide/models/field_guide_week_quote_member.dart';

void main() {
  test('FieldGuideWeekQuoteMember.fromJson maps every field', () {
    final member = FieldGuideWeekQuoteMember.fromJson({
      'id': 'row-1',
      'field_guide_week_quotes_id': 'quote-1',
      'member_id': 'member-1',
      'is_favorite': true,
      'created_at': '2026-01-05T00:00:00Z',
      'updated_at': '2026-01-05T00:00:00Z',
    });

    expect(member.fieldGuideWeekQuotesId, 'quote-1');
    expect(member.memberId, 'member-1');
    expect(member.isFavorite, isTrue);
  });
}
