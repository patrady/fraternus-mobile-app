import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/design_system/tokens/fraternus_colors.dart';
import 'package:fraternus_mobile_app/shared/widgets/frat_night_reading_markdown.dart';

void main() {
  const sample = '''
## Ground Rules

### Rule 1: Squad Time is Always Real.

- Without using names, describe a "faker."
- Can we all agree not to be fake?

## Challenge

Make a large sword to represent your entrance into the battle.
''';

  testWidgets('colors section headings, sub-headings, and question markers distinctly', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: FratNightReadingMarkdown(data: sample),
      ),
    );

    final groundRules = tester.widget<Text>(find.text('Ground Rules'));
    expect(groundRules.textSpan?.style?.color, FraternusColors.accentPrimary);

    final rule1 = tester.widget<Text>(find.textContaining('Rule 1'));
    expect(rule1.textSpan?.style?.color, FraternusColors.forestGreen);

    final daggers = find.text('†');
    expect(daggers, findsNWidgets(2));
    for (final element in daggers.evaluate()) {
      expect((element.widget as Text).style?.color, FraternusColors.accentSecondary);
    }

    final question = tester.widget<Text>(find.text('Without using names, describe a "faker."'));
    expect(question.style?.color, FraternusColors.accentSecondary);

    final challenge = tester.widget<Text>(find.textContaining('Make a large sword'));
    expect(challenge.textSpan?.style?.color, FraternusColors.textOnLight);
  });
}
