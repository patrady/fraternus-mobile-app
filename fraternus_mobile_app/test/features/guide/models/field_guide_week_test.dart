import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/guide/models/field_guide_week.dart';

Map<String, dynamic> _devotionalJson(int dayNumber) => {
  'id': 'devotional-$dayNumber',
  'field_guide_week_id': 'week-1',
  'day_number': dayNumber,
  'identity_reading': 'reading',
  'wisdom_quote': 'quote',
  'wisdom_author': 'author',
  'sword_option_1': 'A',
  'sword_option_2': 'B',
  'spade_prompt': 'prompt',
  'closing_prayer': 'prayer',
  'closing_prayer_author': 'prayer author',
  'created_at': '2026-01-05T00:00:00Z',
  'updated_at': '2026-01-05T00:00:00Z',
};

Map<String, dynamic> _weekJson({List<dynamic>? devotionals}) => {
  'id': 'week-1',
  'year_number': 1,
  'week_number': 1,
  'virtue': 'Humility',
  'vice': 'Pride',
  'extreme': 'Servility',
  'reflection': 'reflection text',
  'choleric_application': 'choleric app',
  'choleric_vices': 'choleric vices',
  'sanguine_application': 'sanguine app',
  'sanguine_vices': 'sanguine vices',
  'melancholic_application': 'melancholic app',
  'melancholic_vices': 'melancholic vices',
  'phlegmatic_application': 'phlegmatic app',
  'phlegmatic_vices': 'phlegmatic vices',
  'field_guide_week_quotes': const [],
  'field_guide_daily_devotionals': devotionals,
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
};

void main() {
  group('FieldGuideWeek.fromJson', () {
    test('takes startDate from the argument, not the row', () {
      final startDate = DateTime(2026, 1, 7);
      final week = FieldGuideWeek.fromJson(_weekJson(), startDate: startDate);
      expect(week.startDate, startDate);
    });

    test('defaults quotes and devotionals to empty when embeds are absent', () {
      final week = FieldGuideWeek.fromJson(_weekJson(), startDate: DateTime(2026, 1, 7));
      expect(week.quotes, isEmpty);
      expect(week.devotionals, isEmpty);
    });
  });

  group('FieldGuideWeek.devotionalForDate', () {
    // A Frat Night on a Wednesday: startDate anchors day_number 1, regardless
    // of that date's own weekday — this pins the fix for the bug where
    // day_number was previously derived from date.weekday instead.
    final startDate = DateTime(2026, 1, 7); // a Wednesday
    late FieldGuideWeek week;

    setUp(() {
      week = FieldGuideWeek.fromJson(
        _weekJson(devotionals: [_devotionalJson(1), _devotionalJson(2), _devotionalJson(7)]),
        startDate: startDate,
      );
    });

    test('startDate itself resolves to day 1', () {
      expect(week.devotionalForDate(startDate)?.dayNumber, 1);
    });

    test('the day after startDate resolves to day 2, even though its weekday is Thursday', () {
      final theNextDay = startDate.add(const Duration(days: 1));
      expect(theNextDay.weekday, DateTime.thursday);
      expect(week.devotionalForDate(theNextDay)?.dayNumber, 2);
    });

    test('6 days after startDate resolves to day 7', () {
      expect(week.devotionalForDate(startDate.add(const Duration(days: 6)))?.dayNumber, 7);
    });

    test('a date before startDate has no devotional', () {
      expect(week.devotionalForDate(startDate.subtract(const Duration(days: 1))), isNull);
    });

    test('a date with no matching day_number has no devotional', () {
      expect(week.devotionalForDate(startDate.add(const Duration(days: 3))), isNull);
    });

    test('ignores time-of-day when computing the day number', () {
      final laterSameDay = DateTime(startDate.year, startDate.month, startDate.day, 23, 59);
      expect(week.devotionalForDate(laterSameDay)?.dayNumber, 1);
    });
  });

  group('FieldGuideWeek.applicationFor / vicesFor', () {
    final week = FieldGuideWeek.fromJson(_weekJson(), startDate: DateTime(2026, 1, 7));

    test('resolves each known temperament key', () {
      expect(week.applicationFor('choleric'), 'choleric app');
      expect(week.applicationFor('sanguine'), 'sanguine app');
      expect(week.applicationFor('melancholic'), 'melancholic app');
      expect(week.applicationFor('phlegmatic'), 'phlegmatic app');
      expect(week.vicesFor('choleric'), 'choleric vices');
    });

    test('an unknown temperament key throws', () {
      expect(() => week.applicationFor('unknown'), throwsArgumentError);
      expect(() => week.vicesFor('unknown'), throwsArgumentError);
    });
  });
}
