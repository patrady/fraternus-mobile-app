import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/guide/models/temperament_quiz_question.dart';

void main() {
  group('TemperamentQuizQuestion.fromJson', () {
    test('sorts options by order_number regardless of embed order', () {
      final question = TemperamentQuizQuestion.fromJson({
        'id': 'question-1',
        'question': 'Which describes you best?',
        'temperament_quiz_options': [
          {'id': 'option-c', 'text': 'Sanguine trait', 'temperament_key': 'sanguine', 'order_number': 2},
          {'id': 'option-a', 'text': 'Choleric trait', 'temperament_key': 'choleric', 'order_number': 1},
        ],
      });

      expect(question.options.map((o) => o.id), ['option-a', 'option-c']);
    });

    test('defaults options to empty when the embed is absent', () {
      final question = TemperamentQuizQuestion.fromJson({'id': 'question-1', 'question': 'Which describes you best?'});
      expect(question.options, isEmpty);
    });
  });
}
