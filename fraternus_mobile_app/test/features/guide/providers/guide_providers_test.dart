import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/app/clock_provider.dart';
import 'package:fraternus_mobile_app/features/guide/data/guide_repository.dart';
import 'package:fraternus_mobile_app/features/guide/data/temperament_quiz_repository.dart';
import 'package:fraternus_mobile_app/features/guide/models/field_guide_daily_devotional_member.dart';
import 'package:fraternus_mobile_app/features/guide/models/field_guide_week.dart';
import 'package:fraternus_mobile_app/features/guide/models/field_guide_week_quote_member.dart';
import 'package:fraternus_mobile_app/features/guide/models/temperament.dart';
import 'package:fraternus_mobile_app/features/guide/models/temperament_quiz_question.dart';
import 'package:fraternus_mobile_app/features/guide/providers/guide_providers.dart';
import 'package:fraternus_mobile_app/features/guide/providers/temperament_quiz_providers.dart';
import 'package:fraternus_mobile_app/features/profile/data/profile_repository.dart';
import 'package:fraternus_mobile_app/features/profile/providers/profile_providers.dart';

/// Wraps a real [StaticGuideRepository], counting fetches and optionally
/// throwing on one named write — same shape as the profile-provider tests'
/// flaky wrapper, needed since StaticGuideRepository itself never fails and
/// never reports how many times it was called.
class _TestGuideRepository implements GuideRepository {
  _TestGuideRepository(this._inner);

  final StaticGuideRepository _inner;
  int fetchWeekCallCount = 0;
  String? failing;

  void _maybeThrow(String method) {
    if (failing == method) throw StateError('$method failed');
  }

  @override
  Future<FieldGuideWeek?> fetchWeekForDate({
    required DateTime date,
    required String chapterKey,
    required List<String> memberIds,
  }) {
    fetchWeekCallCount++;
    return _inner.fetchWeekForDate(
      date: date,
      chapterKey: chapterKey,
      memberIds: memberIds,
    );
  }

  @override
  Future<int> fetchStreak({
    required String memberId,
    required String chapterKey,
    required DateTime asOf,
  }) => _inner.fetchStreak(memberId: memberId, chapterKey: chapterKey, asOf: asOf);

  @override
  Future<FieldGuideDailyDevotionalMember> upsertDevotionalMember({
    required String dailyDevotionalId,
    required String memberId,
    String? sword,
    String? spade,
    bool? completed,
    bool? isIdentityFavorite,
    bool? isWisdomFavorite,
  }) async {
    _maybeThrow('upsertDevotionalMember');
    return _inner.upsertDevotionalMember(
      dailyDevotionalId: dailyDevotionalId,
      memberId: memberId,
      sword: sword,
      spade: spade,
      completed: completed,
      isIdentityFavorite: isIdentityFavorite,
      isWisdomFavorite: isWisdomFavorite,
    );
  }

  @override
  Future<FieldGuideWeekQuoteMember> upsertQuoteMember({
    required String quoteId,
    required String memberId,
    required bool isFavorite,
  }) async {
    _maybeThrow('upsertQuoteMember');
    return _inner.upsertQuoteMember(quoteId: quoteId, memberId: memberId, isFavorite: isFavorite);
  }
}

class _TestTemperamentQuizRepository implements TemperamentQuizRepository {
  _TestTemperamentQuizRepository(this._inner);

  final StaticTemperamentQuizRepository _inner;
  bool shouldFailSave = false;

  @override
  Future<List<TemperamentQuizQuestion>> fetchQuestions() => _inner.fetchQuestions();

  @override
  Future<TemperamentResult?> fetchResult(String memberId) => _inner.fetchResult(memberId);

  @override
  Future<TemperamentResult> saveResult({
    required String memberId,
    required TemperamentResult result,
    required Map<String, String> answers,
  }) async {
    if (shouldFailSave) throw StateError('saveResult failed');
    return _inner.saveResult(memberId: memberId, result: result, answers: answers);
  }
}

void main() {
  group('GuideSelectedDate', () {
    test('build() truncates the current time down to a bare date', () {
      final container = ProviderContainer(
        overrides: [nowProvider.overrideWithValue(DateTime(2026, 1, 15, 14, 30))],
      );
      addTearDown(container.dispose);

      expect(container.read(guideSelectedDateProvider), DateTime(2026, 1, 15));
    });

    test('select() truncates whatever date it is given', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(guideSelectedDateProvider.notifier).select(DateTime(2026, 2, 3, 9, 45));

      expect(container.read(guideSelectedDateProvider), DateTime(2026, 2, 3));
    });
  });

  group('guideWeekForDateProvider family cache key', () {
    test(
      'two DateTimes for the same day but different times of day are '
      'different family keys and each trigger their own fetch — the exact '
      'reason GuideSelectedDate always truncates before this is called',
      () async {
        final repo = _TestGuideRepository(StaticGuideRepository());
        final container = ProviderContainer(
          overrides: [
            guideRepositoryProvider.overrideWithValue(repo),
            profileRepositoryProvider.overrideWithValue(StaticProfileRepository()),
          ],
        );
        addTearDown(container.dispose);

        await Future.wait([
          container.read(guideWeekForDateProvider(DateTime(2026, 1, 15, 9)).future),
          container.read(guideWeekForDateProvider(DateTime(2026, 1, 15, 14)).future),
        ]);

        expect(repo.fetchWeekCallCount, 2);
      },
    );

    test('two equal (already-truncated) DateTimes share a single fetch', () async {
      final repo = _TestGuideRepository(StaticGuideRepository());
      final container = ProviderContainer(
        overrides: [
          guideRepositoryProvider.overrideWithValue(repo),
          profileRepositoryProvider.overrideWithValue(StaticProfileRepository()),
        ],
      );
      addTearDown(container.dispose);

      await Future.wait([
        container.read(guideWeekForDateProvider(DateTime(2026, 1, 15)).future),
        container.read(guideWeekForDateProvider(DateTime(2026, 1, 15)).future),
      ]);

      expect(repo.fetchWeekCallCount, 1);
    });
  });

  group('guideBaseStreak', () {
    test('returns 0 for a personKey outside the current household', () async {
      final container = ProviderContainer(
        overrides: [
          guideRepositoryProvider.overrideWithValue(_TestGuideRepository(StaticGuideRepository())),
          profileRepositoryProvider.overrideWithValue(StaticProfileRepository()),
        ],
      );
      addTearDown(container.dispose);

      expect(await container.read(guideBaseStreakProvider('not-in-household').future), 0);
    });

    test('returns the repository streak for a known household member', () async {
      final container = ProviderContainer(
        overrides: [
          guideRepositoryProvider.overrideWithValue(_TestGuideRepository(StaticGuideRepository())),
          profileRepositoryProvider.overrideWithValue(StaticProfileRepository()),
        ],
      );
      addTearDown(container.dispose);

      expect(await container.read(guideBaseStreakProvider('jack').future), 8);
    });
  });

  group('GuideDevotionalProgress', () {
    late DateTime today;
    late _TestGuideRepository repo;
    late ProviderContainer container;

    setUp(() {
      final now = DateTime.now();
      today = DateTime(now.year, now.month, now.day);
      repo = _TestGuideRepository(StaticGuideRepository());
      container = ProviderContainer(
        overrides: [
          guideRepositoryProvider.overrideWithValue(repo),
          profileRepositoryProvider.overrideWithValue(StaticProfileRepository()),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('setSword applies optimistically then reconciles with the write result', () async {
      await container.read(guideDevotionalProgressProvider(today).future);

      await container.read(guideDevotionalProgressProvider(today).notifier).setSword(
        'you',
        'my sword pick',
      );

      final state = container.read(guideDevotionalProgressProvider(today)).value!;
      expect(state['you']!.sword, 'my sword pick');
    });

    test('toggleComplete flips an incomplete row to complete and back', () async {
      await container.read(guideDevotionalProgressProvider(today).future);
      final notifier = container.read(guideDevotionalProgressProvider(today).notifier);

      await notifier.toggleComplete('jack');
      final afterFirstToggle =
          container.read(guideDevotionalProgressProvider(today)).value!['jack']!;

      await notifier.toggleComplete('jack');
      final afterSecondToggle =
          container.read(guideDevotionalProgressProvider(today)).value!['jack']!;

      expect(afterFirstToggle.isCompleted, !afterSecondToggle.isCompleted);
    });

    test('a failed write rolls the optimistic update back and rethrows', () async {
      await container.read(guideDevotionalProgressProvider(today).future);
      final before = container.read(guideDevotionalProgressProvider(today)).value!;
      repo.failing = 'upsertDevotionalMember';

      await expectLater(
        container.read(guideDevotionalProgressProvider(today).notifier).setSword('you', 'x'),
        throwsA(isA<StateError>()),
      );

      final after = container.read(guideDevotionalProgressProvider(today)).value!;
      expect(after['you']?.sword, before['you']?.sword);
    });
  });

  group('GuideQuoteFavorites', () {
    test('toggle flips a favorite optimistically then persists it', () async {
      final repo = _TestGuideRepository(StaticGuideRepository());
      final container = ProviderContainer(
        overrides: [
          guideRepositoryProvider.overrideWithValue(repo),
          profileRepositoryProvider.overrideWithValue(StaticProfileRepository()),
        ],
      );
      addTearDown(container.dispose);
      final today = DateTime.now();
      final date = DateTime(today.year, today.month, today.day);

      await container.read(guideQuoteFavoritesProvider(date).future);
      final notifier = container.read(guideQuoteFavoritesProvider(date).notifier);
      expect(notifier.isFavorite('humility-quote-1', 'you'), isFalse);

      await notifier.toggle('you', 'humility-quote-1');

      expect(notifier.isFavorite('humility-quote-1', 'you'), isTrue);
    });

    test('a failed write rolls the favorite back and rethrows', () async {
      final repo = _TestGuideRepository(StaticGuideRepository());
      final container = ProviderContainer(
        overrides: [
          guideRepositoryProvider.overrideWithValue(repo),
          profileRepositoryProvider.overrideWithValue(StaticProfileRepository()),
        ],
      );
      addTearDown(container.dispose);
      final today = DateTime.now();
      final date = DateTime(today.year, today.month, today.day);

      await container.read(guideQuoteFavoritesProvider(date).future);
      final notifier = container.read(guideQuoteFavoritesProvider(date).notifier);
      repo.failing = 'upsertQuoteMember';

      await expectLater(
        notifier.toggle('you', 'humility-quote-1'),
        throwsA(isA<StateError>()),
      );

      expect(notifier.isFavorite('humility-quote-1', 'you'), isFalse);
    });
  });

  test('temperamentQuizQuestionsProvider forwards the repository questions', () async {
    final container = ProviderContainer(
      overrides: [
        temperamentQuizRepositoryProvider.overrideWithValue(
          _TestTemperamentQuizRepository(StaticTemperamentQuizRepository()),
        ),
      ],
    );
    addTearDown(container.dispose);

    final questions = await container.read(temperamentQuizQuestionsProvider.future);

    expect(questions, hasLength(24));
  });

  group('GuideTemperamentResult', () {
    test('save applies the result optimistically then persists it', () async {
      final repo = _TestTemperamentQuizRepository(StaticTemperamentQuizRepository());
      final container = ProviderContainer(
        overrides: [temperamentQuizRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      const result = TemperamentResult(primaryKey: 'sanguine', secondaryKey: 'phlegmatic');

      await container.read(guideTemperamentResultProvider('jack').future);
      await container.read(guideTemperamentResultProvider('jack').notifier).save(result, const {});

      expect(container.read(guideTemperamentResultProvider('jack')).value, result);
      expect(await repo.fetchResult('jack'), result);
    });

    test('a failed save rolls the result back to what it was and rethrows', () async {
      final repo = _TestTemperamentQuizRepository(StaticTemperamentQuizRepository());
      final container = ProviderContainer(
        overrides: [temperamentQuizRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final before = await container.read(guideTemperamentResultProvider('you').future);
      repo.shouldFailSave = true;

      await expectLater(
        container
            .read(guideTemperamentResultProvider('you').notifier)
            .save(const TemperamentResult(primaryKey: 'phlegmatic', secondaryKey: 'sanguine'), const {}),
        throwsA(isA<StateError>()),
      );

      expect(container.read(guideTemperamentResultProvider('you')).value, before);
    });
  });
}
