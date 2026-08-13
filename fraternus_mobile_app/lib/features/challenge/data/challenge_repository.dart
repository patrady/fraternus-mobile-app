import '../models/person_challenge_progress.dart';
import '../models/weekly_challenge.dart';

/// Source of the Challenge tab's data. Returning a [Future] here — even
/// though [StaticChallengeRepository] resolves instantly — is the
/// deliberate seam: swapping to a Drift-backed query or a real API call
/// later only means changing the implementation, not this interface, the
/// providers that watch it, or the screens.
abstract class ChallengeRepository {
  Future<List<WeeklyChallenge>> fetchChallenges({required DateTime asOf});
}

/// Hardcoded stand-in for real content. All timestamps are computed as
/// offsets from [asOf] rather than literal dates, so the 48h "NEW" window
/// and the current/past split stay meaningful whenever the app actually
/// runs.
class StaticChallengeRepository implements ChallengeRepository {
  const StaticChallengeRepository();

  @override
  Future<List<WeeklyChallenge>> fetchChallenges({required DateTime asOf}) async {
    return [
      WeeklyChallenge(
        id: 'cold-shower-challenge',
        title: 'Cold Shower Challenge',
        startAt: asOf.subtract(const Duration(hours: 20)),
        description:
            'Take a cold shower 3 times this week. Start warm, then finish the last '
            '30–60 seconds fully cold. This trains you to stay calm and decisive under '
            'discomfort — a small, repeatable act of will that carries over into '
            'everything else you do this week.',
        quote:
            'Consistency, not intensity, is what forms a man. Show up for this one, '
            'every time, and let it become who you are.',
        repsTotal: 3,
        progress: [
          const PersonChallengeProgress(
            personKey: 'you',
            label: 'You',
            accepted: false,
            repCompletions: [null, null, null],
          ),
          PersonChallengeProgress(
            personKey: 'jack',
            label: 'Jack',
            accepted: true,
            repCompletions: [asOf.subtract(const Duration(days: 2)), null, null],
          ),
          PersonChallengeProgress(
            personKey: 'thomas',
            label: 'Thomas',
            accepted: true,
            repCompletions: [
              asOf.subtract(const Duration(days: 6)),
              asOf.subtract(const Duration(days: 4)),
              asOf.subtract(const Duration(days: 2)),
            ],
            streakCount: 3,
          ),
        ],
      ),
      WeeklyChallenge(
        id: 'morning-silence',
        title: 'Morning Silence',
        startAt: asOf.subtract(const Duration(days: 28)),
        description:
            'Spend the first 10 minutes of your morning in total silence — no phone, '
            'no music, no conversation. Just be present before the day pulls you in '
            'a dozen directions.',
        quote: 'Silence is where a man hears what noise has been drowning out.',
        repsTotal: 3,
        progress: [
          const PersonChallengeProgress(
            personKey: 'you',
            label: 'You',
            accepted: false,
            repCompletions: [null, null, null],
          ),
          const PersonChallengeProgress(
            personKey: 'jack',
            label: 'Jack',
            accepted: false,
            repCompletions: [null, null, null],
          ),
          PersonChallengeProgress(
            personKey: 'thomas',
            label: 'Thomas',
            accepted: true,
            repCompletions: [asOf.subtract(const Duration(days: 27)), null, null],
          ),
        ],
      ),
      WeeklyChallenge(
        id: 'no-complaining',
        title: 'No Complaining',
        startAt: asOf.subtract(const Duration(days: 42)),
        description:
            'Go five full days without complaining — out loud or in your head. Notice '
            'how often the urge shows up, and choose gratitude instead.',
        quote: 'Gratitude and complaint cannot occupy the same heart at the same time.',
        repsTotal: 5,
        progress: [
          const PersonChallengeProgress(
            personKey: 'you',
            label: 'You',
            accepted: false,
            repCompletions: [null, null, null, null, null],
          ),
          const PersonChallengeProgress(
            personKey: 'jack',
            label: 'Jack',
            accepted: false,
            repCompletions: [null, null, null, null, null],
          ),
          PersonChallengeProgress(
            personKey: 'thomas',
            label: 'Thomas',
            accepted: true,
            repCompletions: [
              asOf.subtract(const Duration(days: 41)),
              asOf.subtract(const Duration(days: 40)),
              asOf.subtract(const Duration(days: 39)),
              asOf.subtract(const Duration(days: 38)),
              asOf.subtract(const Duration(days: 37)),
            ],
          ),
        ],
      ),
      WeeklyChallenge(
        id: 'examen-before-bed',
        title: 'Examen Before Bed',
        startAt: asOf.subtract(const Duration(days: 49)),
        description:
            'Close each day with a short examen: where did you see God today, where '
            'did you fall short, and what will you carry into tomorrow.',
        quote: 'A day examined is a day that actually teaches you something.',
        repsTotal: 7,
        progress: [
          const PersonChallengeProgress(
            personKey: 'you',
            label: 'You',
            accepted: false,
            repCompletions: [null, null, null, null, null, null, null],
          ),
          const PersonChallengeProgress(
            personKey: 'jack',
            label: 'Jack',
            accepted: false,
            repCompletions: [null, null, null, null, null, null, null],
          ),
          PersonChallengeProgress(
            personKey: 'thomas',
            label: 'Thomas',
            accepted: true,
            repCompletions: [
              asOf.subtract(const Duration(days: 48)),
              asOf.subtract(const Duration(days: 47)),
              asOf.subtract(const Duration(days: 46)),
              asOf.subtract(const Duration(days: 45)),
              asOf.subtract(const Duration(days: 44)),
              asOf.subtract(const Duration(days: 43)),
              asOf.subtract(const Duration(days: 42)),
            ],
          ),
        ],
      ),
    ];
  }
}
