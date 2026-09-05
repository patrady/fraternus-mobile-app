import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/guide/data/guide_repository.dart';

void main() {
  group('StaticGuideRepository.fetchWeekForDate', () {
    late StaticGuideRepository repository;

    setUp(() {
      repository = StaticGuideRepository();
    });

    test('returns the authored week for today', () async {
      final week = await repository.fetchWeekForDate(
        date: DateTime.now(),
        chapterKey: 'st_philips_franklin_franklin_tn',
        memberIds: const ['you', 'jack', 'thomas'],
      );

      expect(week, isNotNull);
      expect(week!.id, 'humility-week');
    });

    test('returns null more than 6 days after the authored week start', () async {
      final now = DateTime.now();
      final farFuture = now.add(const Duration(days: 8));

      final week = await repository.fetchWeekForDate(
        date: farFuture,
        chapterKey: 'st_philips_franklin_franklin_tn',
        memberIds: const ['you'],
      );

      expect(week, isNull);
    });

    test('returns null before the authored week start', () async {
      final now = DateTime.now();
      final before = now.subtract(Duration(days: now.weekday + 1));

      final week = await repository.fetchWeekForDate(
        date: before,
        chapterKey: 'st_philips_franklin_franklin_tn',
        memberIds: const ['you'],
      );

      expect(week, isNull);
    });
  });

  group('StaticGuideRepository.fetchStreak', () {
    late StaticGuideRepository repository;

    setUp(() {
      repository = StaticGuideRepository();
    });

    test('returns each seeded member\'s fixed streak', () async {
      expect(
        await repository.fetchStreak(
          memberId: 'you',
          chapterKey: 'x',
          asOf: DateTime.now(),
        ),
        3,
      );
      expect(
        await repository.fetchStreak(
          memberId: 'jack',
          chapterKey: 'x',
          asOf: DateTime.now(),
        ),
        8,
      );
      expect(
        await repository.fetchStreak(
          memberId: 'thomas',
          chapterKey: 'x',
          asOf: DateTime.now(),
        ),
        12,
      );
    });

    test('returns 0 for a member outside the seeded household', () async {
      expect(
        await repository.fetchStreak(
          memberId: 'stranger',
          chapterKey: 'x',
          asOf: DateTime.now(),
        ),
        0,
      );
    });
  });

  group('StaticGuideRepository.upsertDevotionalMember', () {
    late StaticGuideRepository repository;

    setUp(() {
      repository = StaticGuideRepository();
    });

    test('marks a member complete and visible on the next fetch', () async {
      final updated = await repository.upsertDevotionalMember(
        dailyDevotionalId: 'humility-day-1',
        memberId: 'you',
        completed: true,
      );

      expect(updated.isCompleted, isTrue);

      final week = await repository.fetchWeekForDate(
        date: DateTime.now(),
        chapterKey: 'x',
        memberIds: const ['you'],
      );
      final devotional = week!.devotionals.firstWhere((d) => d.dayNumber == 1);
      final member = devotional.members.firstWhere((m) => m.memberId == 'you');
      expect(member.isCompleted, isTrue);
    });

    test('setting sword leaves a previously-set spade untouched', () async {
      await repository.upsertDevotionalMember(
        dailyDevotionalId: 'humility-day-2',
        memberId: 'you',
        spade: 'my reflection',
      );

      final updated = await repository.upsertDevotionalMember(
        dailyDevotionalId: 'humility-day-2',
        memberId: 'you',
        sword: 'my sword pick',
      );

      expect(updated.sword, 'my sword pick');
      expect(updated.spade, 'my reflection');
    });

    test('completed: false clears a previously-completed row', () async {
      await repository.upsertDevotionalMember(
        dailyDevotionalId: 'humility-day-3',
        memberId: 'you',
        completed: true,
      );

      final updated = await repository.upsertDevotionalMember(
        dailyDevotionalId: 'humility-day-3',
        memberId: 'you',
        completed: false,
      );

      expect(updated.isCompleted, isFalse);
    });
  });

  group('StaticGuideRepository.upsertQuoteMember', () {
    test('favoriting a quote is visible on the next fetch', () async {
      final repository = StaticGuideRepository();

      await repository.upsertQuoteMember(
        quoteId: 'humility-quote-1',
        memberId: 'you',
        isFavorite: true,
      );

      final week = await repository.fetchWeekForDate(
        date: DateTime.now(),
        chapterKey: 'x',
        memberIds: const ['you'],
      );
      final quote = week!.quotes.firstWhere((q) => q.id == 'humility-quote-1');
      expect(quote.members.firstWhere((m) => m.memberId == 'you').isFavorite, isTrue);
    });
  });
}
