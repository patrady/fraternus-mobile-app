import '../models/chapter_field_guide_details.dart';
import '../models/field_guide_daily_devotional.dart';
import '../models/field_guide_daily_devotional_member.dart';
import '../models/field_guide_week.dart';
import '../models/field_guide_week_quote.dart';

/// Source of the Guide tab's data. Same seam as ChallengeRepository/
/// TodayDashboardRepository — swap the implementation later, nothing
/// downstream (providers, screens) needs to change.
abstract class GuideRepository {
  /// The devotional-selection algorithm from docs/app_concept.md: finds the
  /// `Chapter Field Guide Details` row covering [date], computes
  /// `weekNumber`/`dayNumber` as an offset from that row's
  /// `fieldGuideStartDate`, and returns the `FieldGuideWeek` containing that
  /// week — null if [date] falls outside the school year, or past the last
  /// authored week (the UI shows a "nothing to read"/"completed" fallback
  /// either way).
  Future<FieldGuideWeek?> fetchWeekForDate({required DateTime date});

  /// Consecutive completed days for [memberId] ending the day *before*
  /// [asOf] — deliberately excludes [asOf] itself, so the UI can add +1
  /// live the moment that day's row is marked complete/undone, without a
  /// repository round trip on every toggle.
  Future<int> fetchStreak({required String memberId, required DateTime asOf});
}

/// Hardcoded stand-in for real content. All timestamps are computed as
/// offsets from "now" rather than literal dates, same convention as
/// StaticChallengeRepository/StaticTodayDashboardRepository.
///
/// Only one week of content is authored ("humility-week", Week Number 12).
/// [_chapterFieldGuideDetails] anchors `fieldGuideStartDate` 12 weeks before
/// the current week's Monday so the real algorithm in [fetchWeekForDate]
/// resolves to that authored week regardless of which day the app runs on —
/// same "meaningful whenever it runs" convention the rest of this repository
/// already uses, just driven through the real lookup instead of a hardcoded
/// return.
class StaticGuideRepository implements GuideRepository {
  const StaticGuideRepository();

  static const _chapterId = 'st-philips-franklin';
  static const _authoredWeekNumber = 12;

  static const _identityReading =
      "By God's grace, I am a man who is humble, avoiding both pride and self loading";
  static const _wisdomQuote = 'The saints that are highest in the sight of God are the least in their own eyes';
  static const _wisdomAuthor = 'Thomas à Kempis';
  static const _swordOption1 = 'I will acknowledge how much I need others';
  static const _swordOption2 = 'I will answer the call to serve instead';
  static const _spadePrompt = 'Where did I notice pride or humility at work in me today?';
  static const _closingPrayer =
      'God, always the same, let me know myself, let me know You. Let me know You, O Lord, '
      'who know me; let me know You, as I am known. Amen.';

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  static DateTime _weekStart(DateTime date) {
    final dateOnly = _dateOnly(date);
    return dateOnly.subtract(Duration(days: dateOnly.weekday - 1));
  }

  ChapterFieldGuideDetails _chapterFieldGuideDetails(DateTime asOf) {
    // Monday-anchored so the mod-7 day number always lines up with
    // DateTime.weekday, same as FieldGuideWeek.devotionalForDate expects.
    final fieldGuideStartDate = _weekStart(asOf).subtract(Duration(days: _authoredWeekNumber * 7));
    return ChapterFieldGuideDetails(
      id: 'cfgd-$_chapterId',
      chapterId: _chapterId,
      schoolYearStartDate: fieldGuideStartDate.subtract(const Duration(days: 14)),
      schoolYearEndDate: fieldGuideStartDate.add(const Duration(days: 300)),
      fieldGuideStartDate: fieldGuideStartDate,
      createdAt: fieldGuideStartDate,
      lastModifiedAt: fieldGuideStartDate,
    );
  }

  FieldGuideWeek _authoredWeek(DateTime asOf) {
    final weekStart = _weekStart(asOf);

    final devotionals = List.generate(7, (i) {
      final dayNumber = i + 1;
      final isToday = dayNumber == asOf.weekday;
      final dayDate = weekStart.add(Duration(days: i));

      return FieldGuideDailyDevotional(
        id: 'humility-day-$dayNumber',
        fieldGuideWeekId: 'humility-week',
        dayNumber: dayNumber,
        identityReading: _identityReading,
        wisdomQuote: _wisdomQuote,
        wisdomAuthor: _wisdomAuthor,
        swordOption1: _swordOption1,
        swordOption2: _swordOption2,
        spadePrompt: _spadePrompt,
        closingPrayer: _closingPrayer,
        createdAt: weekStart,
        lastModifiedAt: weekStart,
        members: [
          FieldGuideDailyDevotionalMember(
            id: 'humility-day-$dayNumber-you',
            dailyDevotionalId: 'humility-day-$dayNumber',
            memberId: 'you',
            submittedByUserId: 'user-john',
            // "You" hasn't finished today's reading yet — everything
            // before today is left complete so the streak badge has a
            // believable run leading up to today's incomplete state.
            completedDate: isToday ? null : (dayDate.isBefore(DateTime(asOf.year, asOf.month, asOf.day)) ? dayDate : null),
            createdAt: dayDate,
            lastModifiedAt: dayDate,
          ),
          FieldGuideDailyDevotionalMember(
            id: 'humility-day-$dayNumber-jack',
            dailyDevotionalId: 'humility-day-$dayNumber',
            memberId: 'jack',
            submittedByUserId: 'jack',
            sword: _swordOption1,
            spade: 'I caught myself wanting credit for something small — let it go instead.',
            completedDate: dayDate.isAfter(DateTime(asOf.year, asOf.month, asOf.day)) ? null : dayDate,
            createdAt: dayDate,
            lastModifiedAt: dayDate,
          ),
          FieldGuideDailyDevotionalMember(
            id: 'humility-day-$dayNumber-thomas',
            dailyDevotionalId: 'humility-day-$dayNumber',
            memberId: 'thomas',
            // Thomas is under 13 — completed on his behalf by his Guardian.
            submittedByUserId: 'user-john',
            sword: _swordOption2,
            spade: 'Stayed quiet in a meeting instead of jumping in to be right.',
            completedDate: dayDate.isAfter(DateTime(asOf.year, asOf.month, asOf.day)) ? null : dayDate,
            createdAt: dayDate,
            lastModifiedAt: dayDate,
          ),
        ],
      );
    });

    return FieldGuideWeek(
      id: 'humility-week',
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
      sanguineApplication: 'Craves attention and approval, making hidden service deeply uncomfortable.',
      sanguineVices: 'Vanity, name-dropping, exaggerating accomplishments.',
      melancholicApplication:
          'Can mistake self-criticism for humility. True humility requires accepting '
          'imperfection without despair.',
      melancholicVices: 'Intellectual pride, perfectionism disguised as high standards.',
      phlegmaticApplication:
          'Appears humble but may simply be avoiding conflict. Genuine humility requires '
          'active surrender.',
      phlegmaticVices: 'False modesty, using humility as an excuse for inaction.',
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
          quote: 'Many people try to escape temptations, only to fall more deeply.',
          author: 'Thomas à Kempis',
          createdAt: weekStart,
          lastModifiedAt: weekStart,
        ),
        FieldGuideWeekQuote(
          id: 'humility-quote-3',
          fieldGuideWeekId: 'humility-week',
          quote: 'Do not think that you have made any progress unless you esteem yourself the least of all.',
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
  Future<FieldGuideWeek?> fetchWeekForDate({required DateTime date}) async {
    final asOf = DateTime.now();
    final details = _chapterFieldGuideDetails(asOf);

    final dateOnly = _dateOnly(date);
    final schoolYearStart = _dateOnly(details.schoolYearStartDate);
    final schoolYearEnd = _dateOnly(details.schoolYearEndDate);
    if (dateOnly.isBefore(schoolYearStart) || dateOnly.isAfter(schoolYearEnd)) return null;

    final daysSinceStart = dateOnly.difference(_dateOnly(details.fieldGuideStartDate)).inDays;
    if (daysSinceStart < 0) return null;
    final weekNumber = daysSinceStart ~/ 7;

    // Only one week is authored in this seed — a real repository would
    // query `Field Guide Week` by weekNumber instead of this early-out.
    if (weekNumber != _authoredWeekNumber) return null;
    return _authoredWeek(asOf);
  }

  @override
  Future<int> fetchStreak({required String memberId, required DateTime asOf}) async {
    return switch (memberId) {
      'you' => 3,
      'jack' => 8,
      'thomas' => 12,
      _ => 0,
    };
  }
}
