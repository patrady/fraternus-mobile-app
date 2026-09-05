import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/challenge/data/challenge_repository.dart';
import 'package:fraternus_mobile_app/features/challenge/models/challenge_member_rep.dart';
import 'package:fraternus_mobile_app/features/challenge/providers/challenge_providers.dart';
import 'package:fraternus_mobile_app/features/profile/data/profile_repository.dart';
import 'package:fraternus_mobile_app/features/profile/providers/profile_providers.dart';

/// Wraps a real [StaticChallengeRepository], letting [toggleChallengeRep] be
/// made to fail on demand — StaticChallengeRepository itself never fails,
/// but ChallengeProgress.toggleRep's rollback branch needs something that
/// does.
class _TestChallengeRepository implements ChallengeRepository {
  _TestChallengeRepository(this._inner);

  final StaticChallengeRepository _inner;
  bool shouldFailToggle = false;

  @override
  Future<ChallengeFeed> fetchChallenges({
    required DateTime asOf,
    required String chapterKey,
    required Map<String, String> memberLabels,
  }) => _inner.fetchChallenges(asOf: asOf, chapterKey: chapterKey, memberLabels: memberLabels);

  @override
  Future<void> acceptChallenge({required String memberId, required String challengeId}) =>
      _inner.acceptChallenge(memberId: memberId, challengeId: challengeId);

  @override
  Future<ChallengeMemberRep?> toggleChallengeRep({
    required String challengeMemberId,
    required int repNumber,
  }) async {
    if (shouldFailToggle) throw StateError('toggleChallengeRep failed');
    return _inner.toggleChallengeRep(challengeMemberId: challengeMemberId, repNumber: repNumber);
  }
}

void main() {
  ProviderContainer makeContainer({_TestChallengeRepository? repository}) {
    return ProviderContainer(
      overrides: [
        challengeRepositoryProvider.overrideWithValue(
          repository ?? _TestChallengeRepository(StaticChallengeRepository()),
        ),
        profileRepositoryProvider.overrideWithValue(StaticProfileRepository()),
      ],
    );
  }

  test('challengeHousehold lists every household member by first name', () async {
    final container = makeContainer();
    addTearDown(container.dispose);

    final household = await container.read(challengeHouseholdProvider.future);

    expect(household.map((m) => m.memberId).toSet(), {'you', 'jack', 'thomas'});
  });

  group('allChallenges / currentChallenge / pastChallenges', () {
    test('currentChallenge is the one the feed marks current; pastChallenges excludes it', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final all = await container.read(allChallengesProvider.future);
      final current = await container.read(currentChallengeProvider.future);
      final past = await container.read(pastChallengesProvider.future);

      expect(current?.id, 'cold-shower-challenge');
      expect(all, hasLength(4));
      expect(past.map((c) => c.id), isNot(contains('cold-shower-challenge')));
      expect(past, hasLength(3));
    });
  });

  test('challengeById resolves an existing id and returns null for an unknown one', () async {
    final container = makeContainer();
    addTearDown(container.dispose);

    expect((await container.read(challengeByIdProvider('cold-shower-challenge').future))?.id, 'cold-shower-challenge');
    expect(await container.read(challengeByIdProvider('does-not-exist').future), isNull);
  });

  group('challengeStreak', () {
    test('is 0 when even the most recent challenge is not completed', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      // you: no progress row at all for cold-shower-challenge.
      expect(await container.read(challengeStreakProvider('you').future), 0);

      // jack: has a progress row for cold-shower-challenge but only 1 of
      // its 3 required reps, so it isn't completed either.
      expect(await container.read(challengeStreakProvider('jack').future), 0);
    });

    test('counts consecutive completed challenges and stops at the first incomplete one', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      // thomas: cold-shower-challenge (most recent) is fully completed
      // (3/3 reps), but morning-silence (next most recent) only has 1 of
      // its 3 reps — so the streak counts the first and stops there,
      // even though the two older challenges are also fully completed.
      expect(await container.read(challengeStreakProvider('thomas').future), 1);
    });
  });

  group('ChallengeProgress', () {
    test('accept() creates a progress row and invalidates the feed', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(challengeProgressProvider('cold-shower-challenge').future);
      await container.read(challengeProgressProvider('cold-shower-challenge').notifier).accept('you');
      // accept() only invalidates the shared feed, not this provider's own
      // state directly — re-reading .future lets that invalidation
      // propagate through challengeById/allChallenges before asserting.
      final progress = await container.read(challengeProgressProvider('cold-shower-challenge').future);
      expect(progress.containsKey('you'), isTrue);
    });

    test('accept() is a no-op if the member already has a row', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(challengeProgressProvider('cold-shower-challenge').future);
      // jack already has progress seeded.
      await container.read(challengeProgressProvider('cold-shower-challenge').notifier).accept('jack');

      final progress = container.read(challengeProgressProvider('cold-shower-challenge')).value!;
      expect(progress['jack']!.reps, isNotEmpty);
    });

    test('toggleRep applies optimistically then reconciles, marking completion at repsTotal', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(challengeProgressProvider('cold-shower-challenge').future);
      final notifier = container.read(challengeProgressProvider('cold-shower-challenge').notifier);
      await notifier.accept('you');
      // Same propagation gap as the accept() test above — the notifier's
      // own state doesn't pick up 'you' until re-read after invalidation.
      await container.read(challengeProgressProvider('cold-shower-challenge').future);

      await notifier.toggleRep('you', 0);
      await notifier.toggleRep('you', 1);
      await notifier.toggleRep('you', 2);

      final progress = container.read(challengeProgressProvider('cold-shower-challenge')).value!['you']!;
      expect(progress.reps, hasLength(3));
      expect(progress.isCompleted, isTrue);
    });

    test('toggleRep is a no-op for a personKey with no existing progress row', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(challengeProgressProvider('cold-shower-challenge').future);
      final before = container.read(challengeProgressProvider('cold-shower-challenge')).value!;

      // "you" has not accepted the challenge, so there is no row to toggle.
      await container.read(challengeProgressProvider('cold-shower-challenge').notifier).toggleRep('you', 0);

      final after = container.read(challengeProgressProvider('cold-shower-challenge')).value!;
      expect(after, before);
    });

    test('a failed write rolls the optimistic rep back and rethrows', () async {
      final repo = _TestChallengeRepository(StaticChallengeRepository());
      final container = makeContainer(repository: repo);
      addTearDown(container.dispose);

      await container.read(challengeProgressProvider('cold-shower-challenge').future);
      final notifier = container.read(challengeProgressProvider('cold-shower-challenge').notifier);
      await notifier.accept('you');
      final before = await container.read(challengeProgressProvider('cold-shower-challenge').future);
      repo.shouldFailToggle = true;

      await expectLater(notifier.toggleRep('you', 0), throwsA(isA<StateError>()));

      final after = container.read(challengeProgressProvider('cold-shower-challenge')).value!;
      expect(after['you']!.reps, before['you']!.reps);
    });
  });
}
