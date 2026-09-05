import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/field_guide_daily_devotional.dart';
import '../models/field_guide_daily_devotional_member.dart';
import '../models/field_guide_week.dart';
import '../models/field_guide_week_quote.dart';

/// Source of the Guide tab's data. Same seam as ChallengeRepository/
/// TodayDashboardRepository — swap the implementation later, nothing
/// downstream (providers, screens) needs to change.
abstract class GuideRepository {
  /// The devotional-selection algorithm from docs/app_concept.md: finds
  /// [chapterKey]'s most recent past (non-cancelled) Frat Night Event,
  /// computes `dayNumber` as an offset from that Event's `startDate` (day 1
  /// = the Event's own date), and returns the `FieldGuideWeek` tied to that
  /// Frat Night Template containing that day (with each devotional's
  /// `members` filtered to [memberIds]) — null if that Frat Night Template
  /// has no Field Guide Week (e.g. a Rush Night), [date] is more than 6
  /// days past the Event, or there's no past Frat Night Event at all (the
  /// UI shows a "nothing to read"/"completed" fallback either way).
  Future<FieldGuideWeek?> fetchWeekForDate({
    required DateTime date,
    required String chapterKey,
    required List<String> memberIds,
  });

  /// Consecutive completed days for [memberId] ending the day *before*
  /// [asOf] — deliberately excludes [asOf] itself, so the UI can add +1
  /// live the moment that day's row is marked complete/undone, without a
  /// repository round trip on every toggle.
  Future<int> fetchStreak({
    required String memberId,
    required String chapterKey,
    required DateTime asOf,
  });

  /// Creates or updates [memberId]'s row for [dailyDevotionalId]. Each of
  /// [sword]/[spade]/[completed] is applied only when non-null — passing
  /// null for a field leaves it unchanged, matching how the Guide screen
  /// calls this once per field as the user edits (sword pick, spade text,
  /// complete toggle) rather than resubmitting the whole row every time.
  Future<FieldGuideDailyDevotionalMember> upsertDevotionalMember({
    required String dailyDevotionalId,
    required String memberId,
    String? sword,
    String? spade,
    bool? completed,
  });
}

/// In-memory stand-in for real content — a genuine mutable fake, not just a
/// fixed return, since [upsertDevotionalMember] has to actually be visible
/// on the next [fetchWeekForDate] for GuideDevotionalProgress's
/// write-then-invalidate pattern (see guide_providers.dart) to have
/// anything to show. Used as the default in tests (see test/widget_test.dart)
/// since there's no live Supabase connection in that environment.
///
/// Only one week of content is authored ("humility-week"). [_fratNightStartDate]
/// anchors day 1 to the current week's Monday (standing in for "the
/// chapter's most recent past Frat Night Event start date") so the real
/// algorithm in [fetchWeekForDate] resolves to that authored week
/// regardless of which day the app happens to launch on. Ignores the real
/// [chapterKey]/[memberIds] passed in — this fake only ever knows about
/// 'st_philips_franklin_franklin_tn' and the fixed you/jack/thomas trio,
/// same simplification the pre-Supabase version made.
class StaticGuideRepository implements GuideRepository {
  StaticGuideRepository() : _completions = _seedCompletions(DateTime.now());

  static const _authoredYearNumber = 1;
  static const _authoredWeekNumber = 12;
  static const _memberIds = ['you', 'jack', 'thomas'];

  static const _identityReading =
      "By God's grace, I am a man who is humble, avoiding both pride and self loading";
  static const _wisdomQuote =
      'The saints that are highest in the sight of God are the least in their own eyes';
  static const _wisdomAuthor = 'Thomas à Kempis';
  static const _swordOption1 = 'I will acknowledge how much I need others';
  static const _swordOption2 = 'I will answer the call to serve instead';
  static const _spadePrompt =
      'Where did I notice pride or humility at work in me today?';
  static const _closingPrayer =
      'God, always the same, let me know myself, let me know You. Let me know You, O Lord, '
      'who know me; let me know You, as I am known. Amen.';
  static const _closingPrayerAuthor = 'St. Augustine';

  /// Keyed by '$dailyDevotionalId:$memberId'. Seeded once at construction
  /// with a believable demo state, then mutated by [upsertDevotionalMember]
  /// — this is what makes "mark complete" visible on the next fetch.
  final Map<String, FieldGuideDailyDevotionalMember> _completions;

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime _weekStart(DateTime date) {
    final dateOnly = _dateOnly(date);
    return dateOnly.subtract(Duration(days: dateOnly.weekday - 1));
  }

  static Map<String, FieldGuideDailyDevotionalMember> _seedCompletions(
    DateTime asOf,
  ) {
    final weekStart = _weekStart(asOf);
    final today = _dateOnly(asOf);
    final completions = <String, FieldGuideDailyDevotionalMember>{};

    for (var i = 0; i < 7; i++) {
      final dayNumber = i + 1;
      final dailyDevotionalId = 'humility-day-$dayNumber';
      final isToday = dayNumber == asOf.weekday;
      final dayDate = weekStart.add(Duration(days: i));

      completions['$dailyDevotionalId:you'] = FieldGuideDailyDevotionalMember(
        id: '$dailyDevotionalId-you',
        dailyDevotionalId: dailyDevotionalId,
        memberId: 'you',
        submittedByUserId: 'user-john',
        // "You" hasn't finished today's reading yet — everything before
        // today is left complete so the streak badge has a believable run
        // leading up to today's incomplete state.
        completedDate: isToday
            ? null
            : (dayDate.isBefore(today) ? dayDate : null),
        createdAt: dayDate,
        lastModifiedAt: dayDate,
      );
      completions['$dailyDevotionalId:jack'] = FieldGuideDailyDevotionalMember(
        id: '$dailyDevotionalId-jack',
        dailyDevotionalId: dailyDevotionalId,
        memberId: 'jack',
        submittedByUserId: 'jack',
        sword: _swordOption1,
        spade:
            'I caught myself wanting credit for something small — let it go instead.',
        completedDate: dayDate.isAfter(today) ? null : dayDate,
        createdAt: dayDate,
        lastModifiedAt: dayDate,
      );
      completions['$dailyDevotionalId:thomas'] =
          FieldGuideDailyDevotionalMember(
            id: '$dailyDevotionalId-thomas',
            dailyDevotionalId: dailyDevotionalId,
            memberId: 'thomas',
            // Thomas is under 13 — completed on his behalf by his Guardian.
            submittedByUserId: 'user-john',
            sword: _swordOption2,
            spade:
                'Stayed quiet in a meeting instead of jumping in to be right.',
            completedDate: dayDate.isAfter(today) ? null : dayDate,
            createdAt: dayDate,
            lastModifiedAt: dayDate,
          );
    }
    return completions;
  }

  /// Day 1 of the authored week — stands in for "the chapter's most recent
  /// past Frat Night Event start date" (see [GuideRepository.fetchWeekForDate]'s
  /// doc comment). Monday-anchored purely so the fake has a stable,
  /// deterministic date to build devotionals against; a real chapter's Frat
  /// Night can fall on any day of the week.
  static DateTime _fratNightStartDate(DateTime asOf) => _weekStart(asOf);

  FieldGuideWeek _authoredWeek(DateTime asOf) {
    final weekStart = _weekStart(asOf);

    final devotionals = List.generate(7, (i) {
      final dayNumber = i + 1;
      final dailyDevotionalId = 'humility-day-$dayNumber';

      return FieldGuideDailyDevotional(
        id: dailyDevotionalId,
        fieldGuideWeekId: 'humility-week',
        dayNumber: dayNumber,
        identityReading: _identityReading,
        wisdomQuote: _wisdomQuote,
        wisdomAuthor: _wisdomAuthor,
        swordOption1: _swordOption1,
        swordOption2: _swordOption2,
        spadePrompt: _spadePrompt,
        closingPrayer: _closingPrayer,
        closingPrayerAuthor: _closingPrayerAuthor,
        createdAt: weekStart,
        lastModifiedAt: weekStart,
        members: [
          for (final memberId in _memberIds)
            ?_completions['$dailyDevotionalId:$memberId'],
        ],
      );
    });

    return FieldGuideWeek(
      id: 'humility-week',
      yearNumber: _authoredYearNumber,
      weekNumber: _authoredWeekNumber,
      virtue: 'Humility',
      vice: 'Pride',
      extreme: 'Self-Loathing',
      reflection:
          'Pride has a deep root. Every vice grows from it. This week, through **humility**, '
          'you will take note of how often you want to be *right*, to be *seen*, to be *above '
          'others*.\n\n'
          'Watch for pride in these forms:\n'
          '- The need to have the last word\n'
          '- Correcting others when it isn\'t asked for\n'
          '- Feeling threatened when someone else succeeds\n\n'
          '*"Whoever exalts himself will be humbled, and whoever humbles himself will be '
          'exalted."* — Matthew 23:12',
      cholericApplication:
          'Struggles most with humility. Their natural drive is to lead and dominate makes '
          'submission feel like defeat.',
      cholericVices: 'Arrogance, contempt for weakness, need to be right.',
      sanguineApplication:
          'Craves attention and approval, making hidden service deeply uncomfortable.',
      sanguineVices: 'Vanity, name-dropping, exaggerating accomplishments.',
      melancholicApplication:
          'Can mistake self-criticism for humility. True humility requires accepting '
          'imperfection without despair.',
      melancholicVices:
          'Intellectual pride, perfectionism disguised as high standards.',
      phlegmaticApplication:
          'Appears humble but may simply be avoiding conflict. Genuine humility requires '
          'active surrender.',
      phlegmaticVices:
          'False modesty, using humility as an excuse for inaction.',
      quotes: [
        FieldGuideWeekQuote(
          id: 'humility-quote-1',
          fieldGuideWeekId: 'humility-week',
          quote: 'It is the humble man whom God protects and liberates',
          author: 'Thomas à Kempis',
          createdAt: weekStart,
          lastModifiedAt: weekStart,
        ),
        FieldGuideWeekQuote(
          id: 'humility-quote-2',
          fieldGuideWeekId: 'humility-week',
          quote:
              'Many people try to escape temptations, only to fall more deeply.',
          author: 'Thomas à Kempis',
          createdAt: weekStart,
          lastModifiedAt: weekStart,
        ),
        FieldGuideWeekQuote(
          id: 'humility-quote-3',
          fieldGuideWeekId: 'humility-week',
          quote:
              'Do not think that you have made any progress unless you esteem yourself the least of all.',
          author: 'Thomas à Kempis',
          createdAt: weekStart,
          lastModifiedAt: weekStart,
        ),
        FieldGuideWeekQuote(
          id: 'humility-quote-4',
          fieldGuideWeekId: 'humility-week',
          quote: 'Humility is the solid foundation of all the virtues.',
          author: 'Confucius',
          createdAt: weekStart,
          lastModifiedAt: weekStart,
        ),
      ],
      devotionals: devotionals,
      createdAt: weekStart,
      lastModifiedAt: weekStart,
    );
  }

  @override
  Future<FieldGuideWeek?> fetchWeekForDate({
    required DateTime date,
    required String chapterKey,
    required List<String> memberIds,
  }) async {
    final asOf = DateTime.now();
    final dateOnly = _dateOnly(date);
    final daysSinceStart = dateOnly
        .difference(_fratNightStartDate(asOf))
        .inDays;
    if (daysSinceStart < 0 || daysSinceStart > 6) return null;
    return _authoredWeek(asOf);
  }

  @override
  Future<int> fetchStreak({
    required String memberId,
    required String chapterKey,
    required DateTime asOf,
  }) async {
    return switch (memberId) {
      'you' => 3,
      'jack' => 8,
      'thomas' => 12,
      _ => 0,
    };
  }

  @override
  Future<FieldGuideDailyDevotionalMember> upsertDevotionalMember({
    required String dailyDevotionalId,
    required String memberId,
    String? sword,
    String? spade,
    bool? completed,
  }) async {
    final key = '$dailyDevotionalId:$memberId';
    final now = DateTime.now();
    final existing =
        _completions[key] ??
        FieldGuideDailyDevotionalMember(
          id: key,
          dailyDevotionalId: dailyDevotionalId,
          memberId: memberId,
          createdAt: now,
          lastModifiedAt: now,
        );
    final updated = existing.copyWith(
      sword: sword,
      spade: spade,
      completedDate: completed == true ? now : null,
      clearCompleted: completed == false,
    );
    _completions[key] = updated;
    return updated;
  }
}

/// Supabase-backed implementation. RLS (see supabase/migrations) enforces
/// that the caller can only read/write rows for Members they have a Self or
/// Guardian association with — this repository doesn't re-check that
/// client-side, it just makes the calls and lets the database reject
/// anything out of scope.
class SupabaseGuideRepository implements GuideRepository {
  SupabaseGuideRepository(this._client);

  final SupabaseClient _client;

  static String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Future<FieldGuideWeek?> fetchWeekForDate({
    required DateTime date,
    required String chapterKey,
    required List<String> memberIds,
  }) async {
    // RPC #1: resolves which devotional/week apply via the Frat-Night-Event-
    // anchored algorithm — the one place that logic is allowed to live (see
    // supabase/migrations/..._field_guide_frat_night_rpcs.sql).
    final resolvedRows = await _client.rpc(
      'get_field_guide_devotional_for_date',
      params: {'p_chapter_key': chapterKey, 'p_date': _isoDate(date)},
    );
    if (resolvedRows is! List || resolvedRows.isEmpty) return null;
    final resolved = resolvedRows.first as Map<String, dynamic>;
    final fieldGuideWeekId = resolved['field_guide_week_id'] as String?;
    if (fieldGuideWeekId == null) return null;

    // Plain PostgREST nested embed for the rest of the shape — no logic
    // here, just a join.
    final weekJson = await _client
        .from('field_guide_weeks')
        .select(
          '*, field_guide_week_quotes(*), '
          'field_guide_daily_devotionals(*, field_guide_daily_devotional_members(*))',
        )
        .eq('id', fieldGuideWeekId)
        .single();

    // [memberIds] isn't applied as a client-side filter here — RLS on
    // field_guide_daily_devotional_members (see the field_guide migration)
    // already scopes the embedded rows to exactly the caller's own
    // household before they ever leave the database, so there's nothing
    // left to filter. [memberIds] exists on the interface because
    // StaticGuideRepository (no RLS to lean on) needs it explicitly.
    return FieldGuideWeek.fromJson(weekJson);
  }

  @override
  Future<int> fetchStreak({
    required String memberId,
    required String chapterKey,
    required DateTime asOf,
  }) async {
    final result = await _client.rpc(
      'get_field_guide_streak',
      params: {
        'p_member_id': memberId,
        'p_chapter_key': chapterKey,
        'p_as_of': _isoDate(asOf),
      },
    );
    return (result as num).toInt();
  }

  @override
  Future<FieldGuideDailyDevotionalMember> upsertDevotionalMember({
    required String dailyDevotionalId,
    required String memberId,
    String? sword,
    String? spade,
    bool? completed,
  }) async {
    // submitted_by_user_id is deliberately absent — a database trigger sets
    // it from auth.uid() server-side (see the field_guide migration), so no
    // repository caller can pass an arbitrary attribution.
    final row = await _client
        .from('field_guide_daily_devotional_members')
        .upsert({
          'daily_devotional_id': dailyDevotionalId,
          'member_id': memberId,
          if (sword != null) 'sword': sword,
          if (spade != null) 'spade': spade,
          if (completed != null)
            'completed_date': completed ? _isoDate(DateTime.now()) : null,
        }, onConflict: 'daily_devotional_id,member_id')
        .select()
        .single();
    return FieldGuideDailyDevotionalMember.fromJson(row);
  }
}
