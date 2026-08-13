import '../models/temperament.dart';
import '../models/temperament_quiz_question.dart';

abstract class TemperamentQuizRepository {
  Future<List<TemperamentQuizQuestion>> fetchQuestions();
}

/// Hardcoded stand-in for a future Temperament Quiz API — built to the
/// same [TemperamentQuizQuestion] shape an API response would deserialize
/// into, so swapping this for a real HTTP repository later is a
/// drop-in change. Transcribed verbatim from
/// docs/data/temperaments_quiz_questions.md (option lettering dropped —
/// order alone reproduces it — but wording and temperament tags kept exact).
class StaticTemperamentQuizRepository implements TemperamentQuizRepository {
  const StaticTemperamentQuizRepository();

  @override
  Future<List<TemperamentQuizQuestion>> fetchQuestions() async => _questions;
}

TemperamentQuizQuestion _q(String prompt, List<String> options) {
  const keys = ['choleric', 'sanguine', 'melancholic', 'phlegmatic'];
  return TemperamentQuizQuestion(
    prompt: prompt,
    options: [
      for (var i = 0; i < options.length; i++)
        TemperamentQuizOption(text: options[i], temperamentKey: keys[i]),
    ],
  );
}

final _questions = [
  _q("When something goes wrong on a project I'm leading, I usually:", [
    'Take charge immediately and start fixing it.',
    'Make a joke to lighten the mood, then figure it out.',
    'Quietly analyze what went wrong before doing anything.',
    'Wait to see if it resolves itself or someone else steps in.',
  ]),
  _q('In a group conversation, I tend to:', [
    'Do most of the talking and steer the topic.',
    'Bounce energetically between several topics.',
    'Listen closely and speak only when I have something considered to add.',
    'Stay quiet unless directly asked something.',
  ]),
  _q('My natural pace of getting things done is:', [
    "Fast and decisive — I'll adjust course later if needed.",
    'Fast but easily distracted by something more interesting.',
    'Slow and careful — I want it right the first time.',
    'Slow and steady — no rush, no stress.',
  ]),
  _q("When I'm criticized, my first reaction is usually to:", [
    'Push back or defend my position.',
    'Feel bad for a moment, then move on quickly.',
    'Take it hard and think about it for a long time.',
    'Not react much outwardly, even if I mind it inside.',
  ]),
  _q('My room or workspace is usually:', [
    "Organized around whatever project I'm currently driving.",
    'A little chaotic — lots going on at once.',
    'Neat and deliberately arranged.',
    'Simple and uncluttered, not because I planned it that way.',
  ]),
  _q("When I set a goal, I'm most motivated by:", [
    'Winning, achieving, or being the best.',
    'The fun of doing it with other people.',
    'Doing it in a way I can be proud of, meeting a high standard.',
    'Not disrupting my peace too much to get there.',
  ]),
  _q('If a friend is late to meet me, I probably:', [
    'Get annoyed and think about how to avoid this next time.',
    'Barely notice — I got distracted by something else while waiting.',
    "Assume something's wrong and start worrying.",
    'Wait patiently without much thought about it.',
  ]),
  _q('My sense of humor is best described as:', [
    'Sharp, sarcastic, or competitive.',
    'Playful, silly, loves to entertain.',
    'Dry, subtle, or a little dark.',
    'Easygoing — I laugh more than I joke.',
  ]),
  _q('When making a decision, I rely most on:', [
    'My gut, and I move fast.',
    'What feels exciting or fun in the moment.',
    'A careful weighing of pros, cons, and long-term consequences.',
    'Whatever keeps things simple and avoids conflict.',
  ]),
  _q('In a group project, I naturally become:', [
    'The one giving direction, whether asked to or not.',
    'The one keeping morale and energy up.',
    'The one catching mistakes others miss.',
    'The one who does their part without needing recognition.',
  ]),
  _q('My emotions tend to:', [
    'Flare up quickly and burn out fast.',
    "Shift quickly with whatever's happening around me.",
    'Build slowly but last a long time.',
    'Stay level most of the time.',
  ]),
  _q("When I fail at something, I'm most likely to:", [
    'Get frustrated, then immediately try again.',
    'Feel down briefly, then get distracted by something new.',
    'Replay it in my head for days.',
    'Shrug it off without much internal disturbance.',
  ]),
  _q('My ideal weekend involves:', [
    'Accomplishing something significant.',
    'Being around people, doing something spontaneous.',
    'Quiet time to think, read, or work on something meaningful alone.',
    'Relaxing with no particular agenda.',
  ]),
  _q('When someone challenges my opinion, I:', [
    'Argue my case firmly, sometimes bluntly.',
    'Go along with it to keep things friendly, even if I disagree inside.',
    'Get quietly hurt or defensive but stay composed outwardly.',
    "Don't feel much need to defend it either way.",
  ]),
  _q('My friends would probably describe me as:', [
    'Driven, intense, a natural leader.',
    'Fun, outgoing, the life of the group.',
    'Thoughtful, deep, sometimes hard to read.',
    'Calm, easy to get along with, low-drama.',
  ]),
  _q('When I have a lot to do, I:', [
    'Charge through it, sometimes impatient with obstacles.',
    'Get through the fun parts first and put off the boring parts.',
    'Make a careful plan before starting anything.',
    'Do it at a steady pace, no particular urgency.',
  ]),
  _q('In new or unfamiliar situations, I usually feel:', [
    'Eager to take control and figure it out.',
    'Excited and curious to meet new people.',
    'Cautious and want to observe before participating.',
    'Content to follow along and adapt as I go.',
  ]),
  _q("When I'm wronged by someone, forgiveness for me is:", [
    "Quick — I get angry fast but don't hold grudges long.",
    'Easy — I forget about it pretty quickly.',
    'Hard — I tend to relive it and it takes a while to let go.',
    'Simple — it rarely bothers me enough to hold onto.',
  ]),
  _q('My work style is best described as:', [
    'Efficient and results-focused, sometimes impatient with process.',
    'Creative and energetic, but inconsistent with follow-through.',
    'Meticulous and thorough, sometimes slow to finish because I want it perfect.',
    'Reliable and consistent, without much need for excitement.',
  ]),
  _q('When plans change last minute, I:', [
    'Get frustrated but adapt fast and move on.',
    'Roll with it — new plan sounds fun too.',
    'Feel unsettled — I prefer to know what to expect.',
    "Don't mind much either way.",
  ]),
  _q('What I struggle with most is:', [
    'Being too blunt, impatient, or controlling.',
    'Being unreliable, distracted, or overly talkative.',
    'Overthinking, being too critical of myself or others, or melancholy.',
    'Being too passive, indecisive, or unmotivated.',
  ]),
  _q('In prayer or quiet reflection, I tend toward:', [
    'Short, focused, goal-oriented prayer — I want to get back to doing something.',
    "Prayer that's easily distracted unless something engages me emotionally.",
    'Deep, extended reflection — I could sit with it for a long time.',
    'Simple, steady prayer without much internal turbulence.',
  ]),
  _q('When I see someone struggling, my instinct is to:', [
    'Jump in and fix the problem for them.',
    'Cheer them up and distract them from it.',
    'Sit with them and take their pain seriously.',
    'Offer quiet, steady support without making a big deal of it.',
  ]),
  _q("If I'm honest, what drives most of my choices is:", [
    'A desire to achieve, win, or be in control.',
    'A desire for enjoyment, connection, and approval.',
    'A desire to do things well and understand things deeply.',
    'A desire for peace and to avoid unnecessary conflict.',
  ]),
];

/// Tallies one point per [TemperamentQuizOption.temperamentKey] chosen,
/// then ranks by count (descending) with an alphabetical-key tiebreak —
/// per the doc's scoring rules ("if two temperaments tie for primary, the
/// one that comes first alphabetically wins"). Applying the same tiebreak
/// to every rank (not just 1st place) keeps the result deterministic for
/// any tie, which the doc doesn't otherwise specify.
TemperamentResult scoreTemperamentQuiz(List<String> selectedTemperamentKeys) {
  final counts = {for (final key in temperamentOrder) key: 0};
  for (final key in selectedTemperamentKeys) {
    counts[key] = (counts[key] ?? 0) + 1;
  }
  final rankedKeys = temperamentOrder.toList()
    ..sort((a, b) {
      final byCount = counts[b]!.compareTo(counts[a]!);
      return byCount != 0 ? byCount : a.compareTo(b);
    });
  return TemperamentResult(primaryKey: rankedKeys[0], secondaryKey: rankedKeys[1]);
}
