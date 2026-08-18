import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/frat_night_template.dart';
import '../../../shared/models/frat_night_virtue.dart';
import '../models/challenge_member_rep.dart';
import '../models/person_challenge_progress.dart';
import '../models/weekly_challenge.dart';

/// Source of the Challenge tab's data. Same seam as every other
/// XRepository — swap the implementation, nothing downstream needs to
/// change.
abstract class ChallengeRepository {
  /// Every challenge the chapter has ever had, current one first (resolved
  /// per app_concept.md: "the most recent past (non-cancelled) Frat
  /// Night"), the rest by template date descending. [memberLabels] resolves
  /// each progress row's display name (not a schema field) from the
  /// household member list — fetched separately, passed in rather than
  /// re-queried here.
  Future<List<WeeklyChallenge>> fetchChallenges({
    required DateTime asOf,
    required String chapterId,
    required Map<String, String> memberLabels,
  });

  /// Creates the Challenge Member row — this is what "accepting" a
  /// challenge means (mirrors Event RSVP's "no row until submitted" rule).
  Future<void> acceptChallenge({required String memberId, required String challengeId});

  /// Insert/delete toggle — a rep row only exists once completed. Returns
  /// the new rep row, or null if this call removed it (un-toggled).
  Future<ChallengeMemberRep?> toggleChallengeRep({required String challengeMemberId, required int repNumber});
}

/// In-memory mutable fake — [acceptChallenge]/[toggleChallengeRep] actually
/// mutate this instance's state, same reasoning as StaticGuideRepository/
/// StaticProfileRepository. Used as the default in tests since there's no
/// live Supabase connection in that environment. All timestamps are
/// computed as offsets from [DateTime.now()] (captured once at
/// construction) rather than literal dates, so the 48h "NEW" window and
/// the current/past split stay meaningful whenever the app runs.
class StaticChallengeRepository implements ChallengeRepository {
  StaticChallengeRepository() : _now = DateTime.now() {
    _seed();
  }

  final DateTime _now;

  /// Keyed by challenge id.
  final Map<String, _SeedChallenge> _challenges = {};

  /// Keyed by '$challengeId:$memberId'.
  final Map<String, PersonChallengeProgress> _progress = {};

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

  void _addChallenge({
    required String id,
    required String templateId,
    required String templateTitle,
    // The Challenge's own title (e.g. "Cold Shower Challenge") is distinct
    // from the Frat Night Template's title (e.g. "The Fortitudinous Man
    // Defends His Brothers") — collapsing these into one was a real bug
    // caught by "Cold Shower Challenge" no longer being findable in tests.
    required String title,
    required String description,
    required String virtueId,
    required String virtueName,
    required DateTime startOfWeekDate,
    required int repsTotal,
  }) {
    _challenges[id] = _SeedChallenge(
      id: id,
      template: FratNightTemplate(
        id: templateId,
        title: templateTitle,
        description: description,
        reading: description,
        liturgicalDay: 'Ordinary Time',
        startOfWeekDate: startOfWeekDate,
        fratNightVirtueId: virtueId,
        virtue: FratNightVirtue(id: virtueId, name: virtueName),
        createdAt: startOfWeekDate,
        lastModifiedAt: startOfWeekDate,
      ),
      title: title,
      description: description,
      repsTotal: repsTotal,
    );
  }

  void _seedProgress({
    required String challengeId,
    required String memberId,
    required DateTime committedDate,
    DateTime? completedDate,
    required List<ChallengeMemberRep> reps,
  }) {
    // id uses the same 'challengeId:memberId' format as this map's own
    // keys — toggleChallengeRep's challengeMemberId param is this id, so
    // the two must match or the lookup silently misses.
    _progress['$challengeId:$memberId'] = PersonChallengeProgress(
      id: '$challengeId:$memberId',
      memberId: memberId,
      challengeId: challengeId,
      label: '', // overwritten with the real label at fetch time
      committedDate: committedDate,
      completedDate: completedDate,
      reps: reps,
      createdAt: committedDate,
      lastModifiedAt: completedDate ?? committedDate,
    );
  }

  void _seed() {
    final coldShowerWeekStart = _now.subtract(const Duration(hours: 20));
    _addChallenge(
      id: 'cold-shower-challenge',
      templateId: 'fortitude-week',
      templateTitle: 'The Fortitudinous Man Defends His Brothers',
      title: 'Cold Shower Challenge',
      description:
          'Take a cold shower 3 times this week. Start warm, then finish the last '
          '30–60 seconds fully cold. This trains you to stay calm and decisive under '
          'discomfort — a small, repeatable act of will that carries over into '
          'everything else you do this week.',
      virtueId: 'fortitude',
      virtueName: 'Fortitude',
      startOfWeekDate: coldShowerWeekStart,
      repsTotal: 3,
    );
    // "You" hasn't accepted yet — no Challenge Member row.
    _seedProgress(
      challengeId: 'cold-shower-challenge',
      memberId: 'jack',
      committedDate: coldShowerWeekStart,
      reps: [
        _rep(
          challengeMemberId: 'cold-shower-challenge-jack',
          completedByUserId: 'user-john',
          number: 1,
          createdAt: _now.subtract(const Duration(days: 2)),
        ),
      ],
    );
    _seedProgress(
      challengeId: 'cold-shower-challenge',
      memberId: 'thomas',
      committedDate: coldShowerWeekStart,
      completedDate: _now.subtract(const Duration(days: 2)),
      reps: [
        for (var i = 1; i <= 3; i++)
          _rep(
            challengeMemberId: 'cold-shower-challenge-thomas',
            completedByUserId: 'user-john',
            number: i,
            createdAt: _now.subtract(Duration(days: 8 - 2 * i)),
          ),
      ],
    );

    final morningSilenceWeekStart = _now.subtract(const Duration(days: 28));
    _addChallenge(
      id: 'morning-silence',
      templateId: 'prudence-week',
      templateTitle: 'The Prudent Man Listens Before He Speaks',
      title: 'Morning Silence',
      description:
          'Spend the first 10 minutes of your morning in total silence — no phone, '
          'no music, no conversation. Just be present before the day pulls you in '
          'a dozen directions.',
      virtueId: 'prudence',
      virtueName: 'Prudence',
      startOfWeekDate: morningSilenceWeekStart,
      repsTotal: 3,
    );
    _seedProgress(
      challengeId: 'morning-silence',
      memberId: 'thomas',
      committedDate: morningSilenceWeekStart,
      reps: [
        _rep(
          challengeMemberId: 'morning-silence-thomas',
          completedByUserId: 'user-john',
          number: 1,
          createdAt: _now.subtract(const Duration(days: 27)),
        ),
      ],
    );

    final noComplainingWeekStart = _now.subtract(const Duration(days: 42));
    _addChallenge(
      id: 'no-complaining',
      templateId: 'patience-week',
      templateTitle: 'The Patient Man Chooses Gratitude',
      title: 'No Complaining',
      description:
          'Go five full days without complaining — out loud or in your head. Notice '
          'how often the urge shows up, and choose gratitude instead.',
      virtueId: 'patience',
      virtueName: 'Patience',
      startOfWeekDate: noComplainingWeekStart,
      repsTotal: 5,
    );
    _seedProgress(
      challengeId: 'no-complaining',
      memberId: 'thomas',
      committedDate: noComplainingWeekStart,
      completedDate: _now.subtract(const Duration(days: 37)),
      reps: [
        for (var i = 1; i <= 5; i++)
          _rep(
            challengeMemberId: 'no-complaining-thomas',
            completedByUserId: 'user-john',
            number: i,
            createdAt: _now.subtract(Duration(days: 42 - i)),
          ),
      ],
    );

    final examenWeekStart = _now.subtract(const Duration(days: 49));
    _addChallenge(
      id: 'examen-before-bed',
      templateId: 'humility-week-frat-night',
      templateTitle: 'The Humble Man Examines Himself Honestly',
      title: 'Examen Before Bed',
      description:
          'Close each day with a short examen: where did you see God today, where '
          'did you fall short, and what will you carry into tomorrow.',
      virtueId: 'humility',
      virtueName: 'Humility',
      startOfWeekDate: examenWeekStart,
      repsTotal: 7,
    );
    _seedProgress(
      challengeId: 'examen-before-bed',
      memberId: 'thomas',
      committedDate: examenWeekStart,
      completedDate: _now.subtract(const Duration(days: 42)),
      reps: [
        for (var i = 1; i <= 7; i++)
          _rep(
            challengeMemberId: 'examen-before-bed-thomas',
            completedByUserId: 'user-john',
            number: i,
            createdAt: _now.subtract(Duration(days: 49 - i)),
          ),
      ],
    );
  }

  @override
  Future<List<WeeklyChallenge>> fetchChallenges({
    required DateTime asOf,
    required String chapterId,
    required Map<String, String> memberLabels,
  }) async {
    final challenges = _challenges.values.toList()
      ..sort((a, b) => b.template.startOfWeekDate.compareTo(a.template.startOfWeekDate));

    return [
      for (final challenge in challenges)
        WeeklyChallenge(
          id: challenge.id,
          fratNightTemplateId: challenge.template.id,
          fratNightTemplate: challenge.template,
          title: challenge.title,
          description: challenge.description,
          repsTotal: challenge.repsTotal,
          progress: [
            for (final memberId in memberLabels.keys)
              if (_progress['${challenge.id}:$memberId'] case final progress?)
                PersonChallengeProgress(
                  id: progress.id,
                  memberId: progress.memberId,
                  challengeId: progress.challengeId,
                  label: memberLabels[memberId] ?? '',
                  committedDate: progress.committedDate,
                  completedDate: progress.completedDate,
                  reps: progress.reps,
                  createdAt: progress.createdAt,
                  lastModifiedAt: progress.lastModifiedAt,
                ),
          ],
        ),
    ];
  }

  @override
  Future<void> acceptChallenge({required String memberId, required String challengeId}) async {
    final key = '$challengeId:$memberId';
    if (_progress.containsKey(key)) return;
    _seedProgress(challengeId: challengeId, memberId: memberId, committedDate: DateTime.now(), reps: const []);
  }

  @override
  Future<ChallengeMemberRep?> toggleChallengeRep({
    required String challengeMemberId,
    required int repNumber,
  }) async {
    // challengeMemberId here is really '$challengeId:$memberId' (this fake's
    // own progress key) since there's no separate Challenge Member id
    // concept in the seed data — the real repository uses the actual
    // challenge_members.id.
    final progress = _progress[challengeMemberId];
    if (progress == null) return null;

    final hasRep = progress.reps.any((rep) => rep.number == repNumber);
    ChallengeMemberRep? result;
    final List<ChallengeMemberRep> reps;
    if (hasRep) {
      reps = progress.reps.where((rep) => rep.number != repNumber).toList();
      result = null;
    } else {
      result = _rep(
        challengeMemberId: challengeMemberId,
        completedByUserId: 'user-john',
        number: repNumber,
        createdAt: DateTime.now(),
      );
      reps = [...progress.reps, result];
    }

    final repsTotal = _challenges[progress.challengeId]?.repsTotal;
    final isNowComplete = repsTotal != null && reps.length == repsTotal;
    _progress[challengeMemberId] = progress.copyWith(
      reps: reps,
      completedDate: isNowComplete ? DateTime.now() : null,
      clearCompletedDate: !isNowComplete,
    );
    return result;
  }
}

class _SeedChallenge {
  const _SeedChallenge({
    required this.id,
    required this.template,
    required this.title,
    required this.description,
    required this.repsTotal,
  });

  final String id;
  final FratNightTemplate template;
  final String title;
  final String description;
  final int repsTotal;
}

/// Supabase-backed implementation. RLS (see supabase/migrations) enforces
/// that the caller can only read/write progress for Members they have a
/// Self or Guardian association with.
class SupabaseChallengeRepository implements ChallengeRepository {
  SupabaseChallengeRepository(this._client);

  final SupabaseClient _client;

  static String _isoTimestamp(DateTime date) => date.toUtc().toIso8601String();

  @override
  Future<List<WeeklyChallenge>> fetchChallenges({
    required DateTime asOf,
    required String chapterId,
    required Map<String, String> memberLabels,
  }) async {
    final currentChallengeId = await _client.rpc(
      'get_current_challenge',
      params: {'p_chapter_id': chapterId, 'p_as_of': _isoTimestamp(asOf)},
    );

    final rows = await _client
        .from('challenges')
        .select('*, frat_night_templates(*, frat_night_virtues(*)), challenge_members(*, challenge_member_reps(*))');

    final challenges = [
      for (final row in rows) WeeklyChallenge.fromJson(row, memberLabels: memberLabels),
    ]..sort((a, b) => b.fratNightTemplate.startOfWeekDate.compareTo(a.fratNightTemplate.startOfWeekDate));

    if (currentChallengeId == null) return challenges;
    final currentIndex = challenges.indexWhere((c) => c.id == currentChallengeId);
    if (currentIndex <= 0) return challenges;

    final current = challenges.removeAt(currentIndex);
    return [current, ...challenges];
  }

  @override
  Future<void> acceptChallenge({required String memberId, required String challengeId}) async {
    await _client.from('challenge_members').insert({'member_id': memberId, 'challenge_id': challengeId});
  }

  @override
  Future<ChallengeMemberRep?> toggleChallengeRep({
    required String challengeMemberId,
    required int repNumber,
  }) async {
    final result = await _client.rpc(
      'toggle_challenge_rep',
      params: {'p_challenge_member_id': challengeMemberId, 'p_rep_number': repNumber},
    );
    if (result == null) return null;
    final row = result as Map<String, dynamic>;
    if (row['id'] == null) return null; // un-toggled — the RPC returns an all-null row, not absent
    return ChallengeMemberRep.fromJson(row);
  }
}
