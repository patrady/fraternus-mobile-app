import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/challenge/models/weekly_challenge.dart';

void main() {
  group('WeeklyChallenge.fromJson', () {
    test('resolves nested template, progress rows, and member labels', () {
      final fratNightDate = DateTime.parse('2026-01-07T19:00:00Z');
      final challenge = WeeklyChallenge.fromJson(
        {
          'id': 'challenge-1',
          'frat_night_template_key': 'week-1',
          'title': 'Push-ups',
          'description': 'Do push-ups every day',
          'reps': 21,
          'frat_night_templates': {
            'id': 'template-1',
            'key': 'week-1',
            'title': 'Humility',
            'description': 'Week 1',
            'reading': 'reading text',
            'created_at': '2026-01-01T00:00:00Z',
            'updated_at': '2026-01-01T00:00:00Z',
          },
          'challenge_members': [
            {
              'id': 'progress-1',
              'member_id': 'member-1',
              'challenge_id': 'challenge-1',
              'committed_date': '2026-01-07T00:00:00Z',
              'completed_date': null,
              'created_at': '2026-01-07T00:00:00Z',
              'updated_at': '2026-01-07T00:00:00Z',
            },
          ],
        },
        memberLabels: {'member-1': 'John Smith'},
        fratNightDate: fratNightDate,
      );

      expect(challenge.id, 'challenge-1');
      expect(challenge.fratNightTemplate.title, 'Humility');
      expect(challenge.fratNightDate, fratNightDate);
      expect(challenge.repsTotal, 21);
      expect(challenge.progress, hasLength(1));
      expect(challenge.progress.single.label, 'John Smith');
    });

    test('unresolved member label falls back to empty string, not a lookup crash', () {
      final challenge = WeeklyChallenge.fromJson(
        {
          'id': 'challenge-1',
          'frat_night_template_key': 'week-1',
          'title': 'Push-ups',
          'description': 'Do push-ups every day',
          'reps': 21,
          'frat_night_templates': {
            'id': 'template-1',
            'key': 'week-1',
            'title': 'Humility',
            'description': 'Week 1',
            'reading': 'reading text',
            'created_at': '2026-01-01T00:00:00Z',
            'updated_at': '2026-01-01T00:00:00Z',
          },
          'challenge_members': [
            {
              'id': 'progress-1',
              'member_id': 'unknown-member',
              'challenge_id': 'challenge-1',
              'committed_date': '2026-01-07T00:00:00Z',
              'created_at': '2026-01-07T00:00:00Z',
              'updated_at': '2026-01-07T00:00:00Z',
            },
          ],
        },
        memberLabels: const {},
        fratNightDate: DateTime.parse('2026-01-07T19:00:00Z'),
      );

      expect(challenge.progress.single.label, '');
    });

    test('missing challenge_members embed defaults to no progress', () {
      final challenge = WeeklyChallenge.fromJson(
        {
          'id': 'challenge-1',
          'frat_night_template_key': 'week-1',
          'title': 'Push-ups',
          'description': 'Do push-ups every day',
          'reps': 21,
          'frat_night_templates': {
            'id': 'template-1',
            'key': 'week-1',
            'title': 'Humility',
            'description': 'Week 1',
            'reading': 'reading text',
            'created_at': '2026-01-01T00:00:00Z',
            'updated_at': '2026-01-01T00:00:00Z',
          },
        },
        memberLabels: const {},
        fratNightDate: DateTime.parse('2026-01-07T19:00:00Z'),
      );

      expect(challenge.progress, isEmpty);
    });
  });
}
