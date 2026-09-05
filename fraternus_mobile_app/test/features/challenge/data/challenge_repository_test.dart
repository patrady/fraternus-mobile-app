import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/challenge/data/challenge_repository.dart';

void main() {
  group('StaticChallengeRepository.fetchChallenges', () {
    test('returns all 4 seeded challenges sorted by Frat Night date descending', () async {
      final repository = StaticChallengeRepository();

      final feed = await repository.fetchChallenges(
        asOf: DateTime.now(),
        chapterKey: 'x',
        memberLabels: const {},
      );

      expect(feed.challenges.map((c) => c.id), [
        'cold-shower-challenge',
        'morning-silence',
        'no-complaining',
        'examen-before-bed',
      ]);
    });

    test('the most recent past Frat Night\'s challenge is current', () async {
      final repository = StaticChallengeRepository();

      final feed = await repository.fetchChallenges(
        asOf: DateTime.now(),
        chapterKey: 'x',
        memberLabels: const {},
      );

      expect(feed.currentChallengeId, 'cold-shower-challenge');
    });

    test('a challenge older than currentChallengeMaxAge is not current', () async {
      final repository = StaticChallengeRepository();

      // Seeded Frat Night dates are fixed offsets from the real wall clock
      // at construction time, so to make even the most recent one
      // (cold-shower-challenge, ~20h old) look stale, asOf has to move far
      // enough into the *future* to push it past the 21-day cutoff.
      final asOf = DateTime.now().add(const Duration(days: 30));

      final feed = await repository.fetchChallenges(
        asOf: asOf,
        chapterKey: 'x',
        memberLabels: const {},
      );

      expect(feed.currentChallengeId, isNull);
    });

    test('progress is resolved only for the given memberLabels, with their display label', () async {
      final repository = StaticChallengeRepository();

      final feed = await repository.fetchChallenges(
        asOf: DateTime.now(),
        chapterKey: 'x',
        memberLabels: const {'jack': 'Jack', 'thomas': 'Thomas'},
      );

      final coldShower = feed.challenges.firstWhere((c) => c.id == 'cold-shower-challenge');
      expect(coldShower.progress.map((p) => p.memberId).toSet(), {'jack', 'thomas'});
      expect(coldShower.progress.firstWhere((p) => p.memberId == 'jack').label, 'Jack');
    });

    test('a member with no accepted-challenge row is simply absent from progress', () async {
      final repository = StaticChallengeRepository();

      final feed = await repository.fetchChallenges(
        asOf: DateTime.now(),
        chapterKey: 'x',
        memberLabels: const {'you': 'John'},
      );

      final coldShower = feed.challenges.firstWhere((c) => c.id == 'cold-shower-challenge');
      expect(coldShower.progress, isEmpty);
    });
  });

  group('StaticChallengeRepository.acceptChallenge', () {
    test('creates a progress row visible on the next fetch', () async {
      final repository = StaticChallengeRepository();

      await repository.acceptChallenge(memberId: 'you', challengeId: 'cold-shower-challenge');

      final feed = await repository.fetchChallenges(
        asOf: DateTime.now(),
        chapterKey: 'x',
        memberLabels: const {'you': 'John'},
      );
      final coldShower = feed.challenges.firstWhere((c) => c.id == 'cold-shower-challenge');
      expect(coldShower.progress.single.memberId, 'you');
      expect(coldShower.progress.single.reps, isEmpty);
    });

    test('is a no-op if the member has already accepted', () async {
      final repository = StaticChallengeRepository();
      await repository.acceptChallenge(memberId: 'you', challengeId: 'cold-shower-challenge');

      // jack already has a rep recorded in the seed data — accepting again
      // must not wipe it back to an empty progress row.
      await repository.acceptChallenge(memberId: 'jack', challengeId: 'cold-shower-challenge');

      final feed = await repository.fetchChallenges(
        asOf: DateTime.now(),
        chapterKey: 'x',
        memberLabels: const {'jack': 'Jack'},
      );
      final coldShower = feed.challenges.firstWhere((c) => c.id == 'cold-shower-challenge');
      expect(coldShower.progress.single.reps, isNotEmpty);
    });
  });

  group('StaticChallengeRepository.toggleChallengeRep', () {
    test('adding a rep returns it and it is visible on the next fetch', () async {
      final repository = StaticChallengeRepository();
      await repository.acceptChallenge(memberId: 'you', challengeId: 'cold-shower-challenge');

      final rep = await repository.toggleChallengeRep(
        challengeMemberId: 'cold-shower-challenge:you',
        repNumber: 1,
      );

      expect(rep, isNotNull);
      expect(rep!.number, 1);
    });

    test('toggling an existing rep number removes it and returns null', () async {
      final repository = StaticChallengeRepository();
      await repository.acceptChallenge(memberId: 'you', challengeId: 'cold-shower-challenge');
      await repository.toggleChallengeRep(
        challengeMemberId: 'cold-shower-challenge:you',
        repNumber: 1,
      );

      final result = await repository.toggleChallengeRep(
        challengeMemberId: 'cold-shower-challenge:you',
        repNumber: 1,
      );

      expect(result, isNull);
    });

    test('completing the final rep marks the challenge completed (repsTotal reached)', () async {
      final repository = StaticChallengeRepository();
      await repository.acceptChallenge(memberId: 'you', challengeId: 'cold-shower-challenge');

      // cold-shower-challenge's repsTotal is 3.
      await repository.toggleChallengeRep(challengeMemberId: 'cold-shower-challenge:you', repNumber: 1);
      await repository.toggleChallengeRep(challengeMemberId: 'cold-shower-challenge:you', repNumber: 2);
      await repository.toggleChallengeRep(challengeMemberId: 'cold-shower-challenge:you', repNumber: 3);

      final feed = await repository.fetchChallenges(
        asOf: DateTime.now(),
        chapterKey: 'x',
        memberLabels: const {'you': 'John'},
      );
      final progress = feed.challenges.firstWhere((c) => c.id == 'cold-shower-challenge').progress.single;
      expect(progress.isCompleted, isTrue);
    });

    test('un-toggling a rep after completion clears completedDate again', () async {
      final repository = StaticChallengeRepository();
      await repository.acceptChallenge(memberId: 'you', challengeId: 'cold-shower-challenge');
      await repository.toggleChallengeRep(challengeMemberId: 'cold-shower-challenge:you', repNumber: 1);
      await repository.toggleChallengeRep(challengeMemberId: 'cold-shower-challenge:you', repNumber: 2);
      await repository.toggleChallengeRep(challengeMemberId: 'cold-shower-challenge:you', repNumber: 3);

      await repository.toggleChallengeRep(challengeMemberId: 'cold-shower-challenge:you', repNumber: 2);

      final feed = await repository.fetchChallenges(
        asOf: DateTime.now(),
        chapterKey: 'x',
        memberLabels: const {'you': 'John'},
      );
      final progress = feed.challenges.firstWhere((c) => c.id == 'cold-shower-challenge').progress.single;
      expect(progress.isCompleted, isFalse);
      expect(progress.reps, hasLength(2));
    });

    test('returns null for a challengeMemberId with no progress row', () async {
      final repository = StaticChallengeRepository();

      final result = await repository.toggleChallengeRep(
        challengeMemberId: 'cold-shower-challenge:stranger',
        repNumber: 1,
      );

      expect(result, isNull);
    });
  });
}
