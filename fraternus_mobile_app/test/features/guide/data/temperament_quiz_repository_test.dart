import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/guide/data/temperament_quiz_repository.dart';
import 'package:fraternus_mobile_app/features/guide/models/temperament.dart';

void main() {
  group('scoreTemperamentQuiz', () {
    test('ranks by count, most-selected first', () {
      final result = scoreTemperamentQuiz([
        'choleric',
        'choleric',
        'choleric',
        'sanguine',
        'sanguine',
        'phlegmatic',
      ]);

      expect(result.primaryKey, 'choleric');
      expect(result.secondaryKey, 'sanguine');
    });

    test('breaks a tie for primary alphabetically', () {
      final result = scoreTemperamentQuiz(['melancholic', 'choleric']);

      // choleric < melancholic alphabetically, so it wins the tie for 1st,
      // pushing melancholic to 2nd even though they're tied on count.
      expect(result.primaryKey, 'choleric');
      expect(result.secondaryKey, 'melancholic');
    });

    test('breaks a tie for every rank, not just first place', () {
      // All four temperaments tied at 0 selections — every rank falls back
      // to alphabetical order: choleric, melancholic, phlegmatic, sanguine.
      final result = scoreTemperamentQuiz(const []);

      expect(result.primaryKey, 'choleric');
      expect(result.secondaryKey, 'melancholic');
    });
  });

  group('StaticTemperamentQuizRepository', () {
    test('fetchQuestions returns all 24 authored questions', () async {
      final repository = StaticTemperamentQuizRepository();

      final questions = await repository.fetchQuestions();

      expect(questions, hasLength(24));
      expect(questions.every((q) => q.options.length == 4), isTrue);
    });

    test('fetchResult returns the pre-seeded result for "you"', () async {
      final repository = StaticTemperamentQuizRepository();

      final result = await repository.fetchResult('you');

      expect(result, const TemperamentResult(primaryKey: 'choleric', secondaryKey: 'melancholic'));
    });

    test('fetchResult returns null for a member who has not taken the quiz', () async {
      final repository = StaticTemperamentQuizRepository();

      expect(await repository.fetchResult('jack'), isNull);
    });

    test('saveResult persists and overwrites on retake', () async {
      final repository = StaticTemperamentQuizRepository();
      const firstAttempt = TemperamentResult(
        primaryKey: 'sanguine',
        secondaryKey: 'phlegmatic',
      );
      const retake = TemperamentResult(
        primaryKey: 'melancholic',
        secondaryKey: 'choleric',
      );

      await repository.saveResult(memberId: 'jack', result: firstAttempt, answers: const {});
      await repository.saveResult(memberId: 'jack', result: retake, answers: const {});

      expect(await repository.fetchResult('jack'), retake);
    });
  });
}
