import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/challenge/models/person_challenge_progress.dart';

void main() {
  group('PersonChallengeProgress.fromJson', () {
    test('parses reps embed and a null completedDate', () {
      final progress = PersonChallengeProgress.fromJson({
        'id': 'progress-1',
        'member_id': 'member-1',
        'challenge_id': 'challenge-1',
        'committed_date': '2026-01-01T00:00:00Z',
        'completed_date': null,
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-02T00:00:00Z',
        'challenge_member_reps': [
          {
            'id': 'rep-1',
            'challenge_member_id': 'progress-1',
            'completed_by_user_id': 'user-1',
            'number': 1,
            'created_at': '2026-01-01T00:00:00Z',
          },
        ],
      }, label: 'John Smith');

      expect(progress.label, 'John Smith');
      expect(progress.committedDate, DateTime.parse('2026-01-01T00:00:00Z'));
      expect(progress.completedDate, isNull);
      expect(progress.reps, hasLength(1));
      expect(progress.reps.single.id, 'rep-1');
      expect(progress.repsDone, 1);
      expect(progress.isCompleted, isFalse);
    });

    test('parses a non-null completedDate and defaults reps to empty', () {
      final progress = PersonChallengeProgress.fromJson({
        'id': 'progress-1',
        'member_id': 'member-1',
        'challenge_id': 'challenge-1',
        'committed_date': '2026-01-01T00:00:00Z',
        'completed_date': '2026-01-08T00:00:00Z',
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-02T00:00:00Z',
      }, label: 'Jane Doe');

      expect(progress.completedDate, DateTime.parse('2026-01-08T00:00:00Z'));
      expect(progress.isCompleted, isTrue);
      expect(progress.reps, isEmpty);
    });
  });

  group('PersonChallengeProgress.copyWith', () {
    final base = PersonChallengeProgress(
      id: 'progress-1',
      memberId: 'member-1',
      challengeId: 'challenge-1',
      label: 'John Smith',
      committedDate: DateTime.parse('2026-01-01T00:00:00Z'),
      completedDate: DateTime.parse('2026-01-08T00:00:00Z'),
      reps: const [],
      createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
      lastModifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
    );

    test('leaves fields untouched when no argument given', () {
      final copy = base.copyWith();
      expect(copy.completedDate, base.completedDate);
      expect(copy.reps, base.reps);
    });

    test('clearCompletedDate nulls completedDate even though completedDate arg is unset', () {
      final copy = base.copyWith(clearCompletedDate: true);
      expect(copy.completedDate, isNull);
    });

    test('an explicit completedDate wins over clearCompletedDate default', () {
      final newDate = DateTime.parse('2026-02-01T00:00:00Z');
      final copy = base.copyWith(completedDate: newDate);
      expect(copy.completedDate, newDate);
    });
  });
}
