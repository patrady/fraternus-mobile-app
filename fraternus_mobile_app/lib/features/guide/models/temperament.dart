/// Universal temperament labels and display order — fixed across every
/// week and every user, unlike the per-week Application/Vices copy that
/// lives on [FieldGuideWeek].
const temperamentOrder = ['choleric', 'sanguine', 'melancholic', 'phlegmatic'];

const temperamentDisplayNames = {
  'choleric': 'Choleric',
  'sanguine': 'Sanguine',
  'melancholic': 'Melancholic',
  'phlegmatic': 'Phlegmatic',
};

/// Fake stand-in for a not-yet-built temperament-quiz-result table/API —
/// no such entity exists in the Field Guide schema. `null` (surfaced via a
/// nullable provider) means "hasn't taken the quiz".
class TemperamentResult {
  const TemperamentResult({
    required this.primaryKey,
    required this.secondaryKey,
  });

  final String primaryKey;
  final String secondaryKey;
}

/// A temperament's own personality profile — describes the archetype
/// itself, so (unlike [FieldGuideWeek]'s Application/Vices copy) it's the
/// same regardless of which virtue-week is currently open. Also not part
/// of the given schema; hardcoded here as static seed content for the
/// temperament detail screens.
class TemperamentProfile {
  const TemperamentProfile({
    required this.description,
    required this.strengths,
    required this.growthAreas,
  });

  final String description;
  final List<String> strengths;
  final List<String> growthAreas;
}

const temperamentProfiles = {
  'choleric': TemperamentProfile(
    description:
        'The Choleric is driven, decisive, and built for action. He is a natural leader who '
        'thrives on challenge and gets impatient with excuses.',
    strengths: [
      'Decisive under pressure',
      'Natural leadership',
      'Relentless follow-through',
      'Comfortable with confrontation',
    ],
    growthAreas: [
      "Impatience with others' pace",
      'Dominating conversations',
      'Difficulty admitting fault',
      'Running over people to reach a goal',
    ],
  ),
  'sanguine': TemperamentProfile(
    description:
        'The Sanguine is warm, expressive, and energized by people. He brings life to a room '
        'and connects easily, but can struggle to finish what he starts.',
    strengths: [
      'Natural charisma',
      'Quick to connect with others',
      'Optimistic under pressure',
      'Generous with encouragement',
    ],
    growthAreas: [
      'Difficulty with follow-through',
      'Distractibility',
      'Avoiding hard conversations for the sake of harmony',
      'Overpromising',
    ],
  ),
  'melancholic': TemperamentProfile(
    description:
        'The Melancholic is thoughtful, precise, and deeply loyal. He notices what others miss '
        'and holds himself to a high standard, sometimes too high.',
    strengths: [
      'Deep thinking and discernment',
      'High personal standards',
      'Loyalty and follow-through',
      "Sensitivity to others' needs",
    ],
    growthAreas: [
      'Perfectionism',
      'Withdrawing under stress',
      'Dwelling on past mistakes',
      'Slow to trust',
    ],
  ),
  'phlegmatic': TemperamentProfile(
    description:
        'The Phlegmatic is steady, patient, and easygoing. He brings calm to chaos and rarely '
        'reacts rashly, but can drift toward passivity.',
    strengths: [
      'Even temper under pressure',
      'Natural peacemaker',
      'Reliable and consistent',
      'Good listener',
    ],
    growthAreas: [
      'Avoiding necessary conflict',
      'Passivity in the face of challenge',
      'Procrastination',
      'Difficulty asserting his own needs',
    ],
  ),
};
