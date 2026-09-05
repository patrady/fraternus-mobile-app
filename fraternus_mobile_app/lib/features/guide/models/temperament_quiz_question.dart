/// One selectable answer on a [TemperamentQuizQuestion] — picking it adds
/// one point toward [temperamentKey] when the quiz is scored, and its [id]
/// is what gets recorded in `Member Temperament Result Answer` on submit.
class TemperamentQuizOption {
  const TemperamentQuizOption({
    required this.id,
    required this.text,
    required this.temperamentKey,
  });

  final String id;
  final String text;
  final String temperamentKey;

  factory TemperamentQuizOption.fromJson(Map<String, dynamic> json) {
    return TemperamentQuizOption(
      id: json['id'] as String,
      text: json['text'] as String,
      temperamentKey: json['temperament_key'] as String,
    );
  }
}

class TemperamentQuizQuestion {
  const TemperamentQuizQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  final String id;
  final String question;
  final List<TemperamentQuizOption> options;

  /// [json]'s nested `temperament_quiz_options` are sorted by their own
  /// `order_number` before being parsed — Postgres doesn't otherwise
  /// guarantee embed ordering, and the quiz screen relies on this list
  /// staying in the choleric/sanguine/melancholic/phlegmatic order the
  /// options were authored in.
  factory TemperamentQuizQuestion.fromJson(Map<String, dynamic> json) {
    final optionsJson =
        (json['temperament_quiz_options'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .toList()
          ..sort(
            (a, b) =>
                (a['order_number'] as int).compareTo(b['order_number'] as int),
          );
    return TemperamentQuizQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options: [
        for (final optionJson in optionsJson)
          TemperamentQuizOption.fromJson(optionJson),
      ],
    );
  }
}
