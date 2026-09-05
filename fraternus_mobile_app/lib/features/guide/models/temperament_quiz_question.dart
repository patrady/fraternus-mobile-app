/// One selectable answer on a [TemperamentQuizQuestion] — picking it adds
/// one point toward [temperamentKey] when the quiz is scored.
class TemperamentQuizOption {
  const TemperamentQuizOption({
    required this.text,
    required this.temperamentKey,
  });

  final String text;
  final String temperamentKey;
}

class TemperamentQuizQuestion {
  const TemperamentQuizQuestion({required this.prompt, required this.options});

  final String prompt;
  final List<TemperamentQuizOption> options;
}
