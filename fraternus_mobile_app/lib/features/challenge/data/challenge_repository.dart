import '../../../shared/models/frat_night_template.dart';
import '../../../shared/models/frat_night_virtue.dart';
import '../models/challenge_household_member.dart';
import '../models/challenge_member_rep.dart';
import '../models/person_challenge_progress.dart';
import '../models/weekly_challenge.dart';

/// Source of the Challenge tab's data. Returning a [Future] here — even
/// though [StaticChallengeRepository] resolves instantly — is the
/// deliberate seam: swapping to a Drift-backed query or a real API call
/// later only means changing the implementation, not this interface, the
/// providers that watch it, or the screens.
abstract class ChallengeRepository {
  Future<List<WeeklyChallenge>> fetchChallenges({required DateTime asOf});

  /// The current user's household — every Member is eligible for every
  /// Challenge per the schema, so this is a single household-wide list
  /// rather than something fetched per challenge.
  Future<List<ChallengeHouseholdMember>> fetchHousehold();
}

/// Hardcoded stand-in for real content. All timestamps are computed as
/// offsets from [asOf] rather than literal dates, so the 48h "NEW" window
/// and the current/past split stay meaningful whenever the app actually
/// runs.
class StaticChallengeRepository implements ChallengeRepository {
  const StaticChallengeRepository();

  static const _wholeHousehold = [
    ChallengeHouseholdMember(memberId: 'you', label: 'You'),
    ChallengeHouseholdMember(memberId: 'jack', label: 'Jack'),
    ChallengeHouseholdMember(memberId: 'thomas', label: 'Thomas'),
  ];

  @override
  Future<List<ChallengeHouseholdMember>> fetchHousehold() async => _wholeHousehold;

  static FratNightTemplate _template({
    required String id,
    required String title,
    required String description,
    required String virtueId,
    required String virtueName,
    required DateTime startOfWeekDate,
  }) {
    return FratNightTemplate(
      id: id,
      title: title,
      description: description,
      reading: description,
      liturgicalDay: 'Ordinary Time',
      startOfWeekDate: startOfWeekDate,
      fratNightVirtueId: virtueId,
      virtue: FratNightVirtue(id: virtueId, name: virtueName),
      createdAt: startOfWeekDate,
      lastModifiedAt: startOfWeekDate,
    );
  }

  static ChallengeMemberRep _rep({
    required String challengeMemberId,
    required String completedByUserId,
    required int number,
    required DateTime createdAt,
  }) {
    return ChallengeMemberRep(
      id: '$challengeMemberId-rep-$number',
      challengeMemberId: challengeMemberId,
      completedByUserId: completedByUserId,
      number: number,
      createdAt: createdAt,
    );
  }

  @override
  Future<List<WeeklyChallenge>> fetchChallenges({required DateTime asOf}) async {
    final coldShowerWeekStart = asOf.subtract(const Duration(hours: 20));
    final morningSilenceWeekStart = asOf.subtract(const Duration(days: 28));
    final noComplainingWeekStart = asOf.subtract(const Duration(days: 42));
    final examenWeekStart = asOf.subtract(const Duration(days: 49));

    return [
      WeeklyChallenge(
        id: 'cold-shower-challenge',
        fratNightTemplateId: 'fortitude-week',
        fratNightTemplate: _template(
          id: 'fortitude-week',
          title: 'The Fortitudinous Man Defends His Brothers',
          description:
              'Take a cold shower 3 times this week. Start warm, then finish the last '
              '30–60 seconds fully cold. This trains you to stay calm and decisive under '
              'discomfort — a small, repeatable act of will that carries over into '
              'everything else you do this week.',
          virtueId: 'fortitude',
          virtueName: 'Fortitude',
          startOfWeekDate: coldShowerWeekStart,
        ),
        title: 'Cold Shower Challenge',
        description:
            'Take a cold shower 3 times this week. Start warm, then finish the last '
            '30–60 seconds fully cold. This trains you to stay calm and decisive under '
            'discomfort — a small, repeatable act of will that carries over into '
            'everything else you do this week.',
        repsTotal: 3,
        // "You" hasn't accepted yet — no Challenge Member row exists.
        progress: [
          PersonChallengeProgress(
            id: 'cold-shower-challenge-jack',
            memberId: 'jack',
            challengeId: 'cold-shower-challenge',
            label: 'Jack',
            committedDate: coldShowerWeekStart,
            reps: [
              _rep(
                challengeMemberId: 'cold-shower-challenge-jack',
                completedByUserId: 'user-john',
                number: 1,
                createdAt: asOf.subtract(const Duration(days: 2)),
              ),
            ],
            createdAt: coldShowerWeekStart,
            lastModifiedAt: asOf.subtract(const Duration(days: 2)),
          ),
          PersonChallengeProgress(
            id: 'cold-shower-challenge-thomas',
            memberId: 'thomas',
            challengeId: 'cold-shower-challenge',
            label: 'Thomas',
            committedDate: coldShowerWeekStart,
            completedDate: asOf.subtract(const Duration(days: 2)),
            reps: [
              _rep(
                challengeMemberId: 'cold-shower-challenge-thomas',
                completedByUserId: 'user-john',
                number: 1,
                createdAt: asOf.subtract(const Duration(days: 6)),
              ),
              _rep(
                challengeMemberId: 'cold-shower-challenge-thomas',
                completedByUserId: 'user-john',
                number: 2,
                createdAt: asOf.subtract(const Duration(days: 4)),
              ),
              _rep(
                challengeMemberId: 'cold-shower-challenge-thomas',
                completedByUserId: 'user-john',
                number: 3,
                createdAt: asOf.subtract(const Duration(days: 2)),
              ),
            ],
            createdAt: coldShowerWeekStart,
            lastModifiedAt: asOf.subtract(const Duration(days: 2)),
          ),
        ],
      ),
      WeeklyChallenge(
        id: 'morning-silence',
        fratNightTemplateId: 'prudence-week',
        fratNightTemplate: _template(
          id: 'prudence-week',
          title: 'The Prudent Man Listens Before He Speaks',
          description:
              'Spend the first 10 minutes of your morning in total silence — no phone, '
              'no music, no conversation. Just be present before the day pulls you in '
              'a dozen directions.',
          virtueId: 'prudence',
          virtueName: 'Prudence',
          startOfWeekDate: morningSilenceWeekStart,
        ),
        title: 'Morning Silence',
        description:
            'Spend the first 10 minutes of your morning in total silence — no phone, '
            'no music, no conversation. Just be present before the day pulls you in '
            'a dozen directions.',
        repsTotal: 3,
        // "You" and Jack haven't accepted yet — no rows for them.
        progress: [
          PersonChallengeProgress(
            id: 'morning-silence-thomas',
            memberId: 'thomas',
            challengeId: 'morning-silence',
            label: 'Thomas',
            committedDate: morningSilenceWeekStart,
            reps: [
              _rep(
                challengeMemberId: 'morning-silence-thomas',
                completedByUserId: 'user-john',
                number: 1,
                createdAt: asOf.subtract(const Duration(days: 27)),
              ),
            ],
            createdAt: morningSilenceWeekStart,
            lastModifiedAt: asOf.subtract(const Duration(days: 27)),
          ),
        ],
      ),
      WeeklyChallenge(
        id: 'no-complaining',
        fratNightTemplateId: 'patience-week',
        fratNightTemplate: _template(
          id: 'patience-week',
          title: 'The Patient Man Chooses Gratitude',
          description:
              'Go five full days without complaining — out loud or in your head. Notice '
              'how often the urge shows up, and choose gratitude instead.',
          virtueId: 'patience',
          virtueName: 'Patience',
          startOfWeekDate: noComplainingWeekStart,
        ),
        title: 'No Complaining',
        description:
            'Go five full days without complaining — out loud or in your head. Notice '
            'how often the urge shows up, and choose gratitude instead.',
        repsTotal: 5,
        // "You" and Jack haven't accepted yet — no rows for them.
        progress: [
          PersonChallengeProgress(
            id: 'no-complaining-thomas',
            memberId: 'thomas',
            challengeId: 'no-complaining',
            label: 'Thomas',
            committedDate: noComplainingWeekStart,
            completedDate: asOf.subtract(const Duration(days: 37)),
            reps: [
              for (var i = 0; i < 5; i++)
                _rep(
                  challengeMemberId: 'no-complaining-thomas',
                  completedByUserId: 'user-john',
                  number: i + 1,
                  createdAt: asOf.subtract(Duration(days: 41 - i)),
                ),
            ],
            createdAt: noComplainingWeekStart,
            lastModifiedAt: asOf.subtract(const Duration(days: 37)),
          ),
        ],
      ),
      WeeklyChallenge(
        id: 'examen-before-bed',
        fratNightTemplateId: 'humility-week-frat-night',
        fratNightTemplate: _template(
          id: 'humility-week-frat-night',
          title: 'The Humble Man Examines Himself Honestly',
          description:
              'Close each day with a short examen: where did you see God today, where '
              'did you fall short, and what will you carry into tomorrow.',
          virtueId: 'humility',
          virtueName: 'Humility',
          startOfWeekDate: examenWeekStart,
        ),
        title: 'Examen Before Bed',
        description:
            'Close each day with a short examen: where did you see God today, where '
            'did you fall short, and what will you carry into tomorrow.',
        repsTotal: 7,
        // "You" and Jack haven't accepted yet — no rows for them.
        progress: [
          PersonChallengeProgress(
            id: 'examen-before-bed-thomas',
            memberId: 'thomas',
            challengeId: 'examen-before-bed',
            label: 'Thomas',
            committedDate: examenWeekStart,
            completedDate: asOf.subtract(const Duration(days: 42)),
            reps: [
              for (var i = 0; i < 7; i++)
                _rep(
                  challengeMemberId: 'examen-before-bed-thomas',
                  completedByUserId: 'user-john',
                  number: i + 1,
                  createdAt: asOf.subtract(Duration(days: 48 - i)),
                ),
            ],
            createdAt: examenWeekStart,
            lastModifiedAt: asOf.subtract(const Duration(days: 42)),
          ),
        ],
      ),
    ];
  }
}
