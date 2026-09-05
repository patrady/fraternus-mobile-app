import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../data/temperament_quiz_repository.dart';
import '../models/temperament.dart';
import '../models/temperament_quiz_question.dart';
import '../providers/guide_providers.dart';
import '../providers/temperament_quiz_providers.dart';
import 'widgets/sword_option_list.dart';

enum _QuizPhase { intro, question, results }

/// Pushed from "Find Your Temperament" (Guide's virtue detail screen, or
/// Profile) / "Take Again" (Profile, once a result exists). Kept as one
/// screen with internal phase/step state rather than three separate routes
/// — nothing here needs to be deep-linkable mid-quiz, and it keeps
/// exit/back semantics (see [_QuizPhase]) simple to reason about.
class TemperamentQuizScreen extends ConsumerStatefulWidget {
  const TemperamentQuizScreen({super.key, required this.personKey});

  final String personKey;

  @override
  ConsumerState<TemperamentQuizScreen> createState() =>
      _TemperamentQuizScreenState();
}

class _TemperamentQuizScreenState extends ConsumerState<TemperamentQuizScreen> {
  _QuizPhase _phase = _QuizPhase.intro;
  int _questionIndex = 0;

  /// Question index -> the selected option's own text, matching how
  /// [SwordOptionList] (this quiz's radio-row widget) already identifies a
  /// selection by its label rather than by index.
  final Map<int, String> _answers = {};
  TemperamentResult? _result;

  Future<void> _confirmExit() async {
    final confirmed = await showFraternusConfirmDialog(
      context: context,
      title: 'Exit Quiz',
      message: 'Are you sure you want to exit? Your progress will be lost.',
      confirmLabel: 'Exit',
    );
    if (confirmed && mounted) context.pop();
  }

  void _goBack() {
    if (_questionIndex == 0) {
      setState(() => _phase = _QuizPhase.intro);
    } else {
      setState(() => _questionIndex -= 1);
    }
  }

  void _goNext(List<TemperamentQuizQuestion> questions) {
    if (_questionIndex < questions.length - 1) {
      setState(() => _questionIndex += 1);
      return;
    }

    final selectedKeys = <String>[];
    for (var i = 0; i < questions.length; i++) {
      final selectedText = _answers[i];
      for (final option in questions[i].options) {
        if (option.text == selectedText)
          selectedKeys.add(option.temperamentKey);
      }
    }

    final result = scoreTemperamentQuiz(selectedKeys);
    ref
        .read(guideTemperamentResultProvider(widget.personKey).notifier)
        .save(result);
    setState(() {
      _result = result;
      _phase = _QuizPhase.results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(temperamentQuizQuestionsProvider);

    return questionsAsync.when(
      data: (questions) => switch (_phase) {
        _QuizPhase.intro => _IntroScreen(
          onBegin: () => setState(() => _phase = _QuizPhase.question),
        ),
        _QuizPhase.question => _QuestionScreen(
          question: questions[_questionIndex],
          index: _questionIndex,
          total: questions.length,
          selected: _answers[_questionIndex],
          onSelect: (text) => setState(() => _answers[_questionIndex] = text),
          onExit: _confirmExit,
          onBack: _goBack,
          onNext: () => _goNext(questions),
        ),
        _QuizPhase.results => _ResultsScreen(
          result: _result!,
          onOk: () => context.pop(),
        ),
      },
      loading: () => const ScreenShell(child: SizedBox.shrink()),
      error: (error, stackTrace) => const ScreenShell(
        child: BodyText('Something went wrong loading the quiz.'),
      ),
    );
  }
}

class _IntroScreen extends StatelessWidget {
  const _IntroScreen({required this.onBegin});

  final VoidCallback onBegin;

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      footer: Button(label: 'Begin Quiz', fullWidth: true, onPressed: onBegin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'Back', onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Heading('THE FOUR TEMPERAMENTS', level: HeadingLevel.h2),
                const SizedBox(height: 6),
                const Subheading('Quiz'),
                const SizedBox(height: 16),
                const BodyText(
                  'Every man is wired with a natural temperament — Choleric, Sanguine, '
                  'Melancholic, or Phlegmatic. Knowing yours helps you see where your virtue '
                  'battle will be hardest.',
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const FraternusIcon(
                      name: 'clock',
                      size: 18,
                      tone: FraternusIconTone.ink,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '10 minutes',
                      style: FraternusTypography.body(
                        color: FraternusColors.textOnLightMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionScreen extends StatelessWidget {
  const _QuestionScreen({
    required this.question,
    required this.index,
    required this.total,
    required this.selected,
    required this.onSelect,
    required this.onExit,
    required this.onBack,
    required this.onNext,
  });

  final TemperamentQuizQuestion question;
  final int index;
  final int total;
  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onExit;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isLastQuestion = index == total - 1;

    return ScreenShell(
      footer: ButtonGroup(
        children: [
          Button(
            label: 'Back',
            variant: ButtonVariant.ghost,
            icon: 'chevron-left',
            onPressed: onBack,
          ),
          Button(
            label: isLastQuestion ? 'Finish' : 'Next',
            icon: 'chevron-right',
            iconPosition: ButtonIconPosition.right,
            disabled: selected == null,
            onPressed: onNext,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PressableBuilder(
                  onTap: onExit,
                  semanticLabel: 'Exit',
                  builder: (context, isPressed) {
                    return Opacity(
                      opacity: isPressed ? 0.75 : 1,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FraternusIcon(name: 'x', size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'EXIT',
                            style: FraternusTypography.button(
                              fontSize: 13,
                              color: FraternusColors.ink,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ContinuousProgressBar(index: index, total: total),
            const SizedBox(height: 20),
            Heading(question.prompt, level: HeadingLevel.h4),
            const SizedBox(height: 16),
            SwordOptionList(
              options: [for (final option in question.options) option.text],
              selected: selected,
              onSelect: onSelect,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsScreen extends StatelessWidget {
  const _ResultsScreen({required this.result, required this.onOk});

  final TemperamentResult result;
  final VoidCallback onOk;

  @override
  Widget build(BuildContext context) {
    final name =
        temperamentDisplayNames[result.primaryKey] ?? result.primaryKey;
    final profile = temperamentProfiles[result.primaryKey];

    return ScreenShell(
      footer: Button(label: 'OK', fullWidth: true, onPressed: onOk),
      child: Padding(
        // Fixed top offset (rather than a Center, which SingleChildScrollView
        // gives unbounded height and can't vertically center against) to
        // roughly match the reference screenshot's vertically-centered look.
        padding: const EdgeInsets.fromLTRB(32, 140, 32, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'YOUR TEMPERAMENT',
              textAlign: TextAlign.center,
              style: FraternusTypography.eyebrow(
                color: FraternusColors.textOnLightMuted,
              ),
            ),
            const SizedBox(height: 8),
            Heading(
              name.toUpperCase(),
              level: HeadingLevel.h2,
              align: TextAlign.center,
            ),
            if (profile != null) ...[
              const SizedBox(height: 16),
              BodyText(profile.description, align: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
