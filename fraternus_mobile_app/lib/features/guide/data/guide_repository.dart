import '../models/field_guide_daily_devotional.dart';
import '../models/field_guide_daily_devotional_member.dart';
import '../models/field_guide_week.dart';
import '../models/field_guide_week_quote.dart';

/// Source of the Guide tab's data. Same seam as ChallengeRepository/
/// TodayDashboardRepository — swap the implementation later, nothing
/// downstream (providers, screens) needs to change.
abstract class GuideRepository {
  /// The week covering [date]. Returns null if no seeded week covers that
  /// date — the UI shows a "nothing to read" fallback in that case.
  Future<FieldGuideWeek?> fetchWeekForDate({required DateTime date});

  /// Consecutive completed days for [personKey] ending the day *before*
  /// [asOf] — deliberately excludes [asOf] itself, so the UI can add +1
  /// live the moment that day's row is marked complete/undone, without a
  /// repository round trip on every toggle.
  Future<int> fetchStreak({required String personKey, required DateTime asOf});
}

/// Hardcoded stand-in for real content. All timestamps are computed as
/// offsets from "now" rather than literal dates, same convention as
/// StaticChallengeRepository/StaticTodayDashboardRepository.
class StaticGuideRepository implements GuideRepository {
  const StaticGuideRepository();

  static const _identityReading =
      "By God's grace, I am a man who is humble, avoiding both pride and self loading";
  static const _wisdomQuote = 'The saints that are highest in the sight of God are the least in their own eyes';
  static const _wisdomAuthor = 'Thomas à Kempis';
  static const _swordOptions = ['I will acknowledge how much I need others', 'I will answer the call to serve instead'];
  static const _spadePrompt = 'Where did I notice pride or humility at work in me today?';
  static const _closingPrayer =
      'God, always the same, let me know myself, let me know You. Let me know You, O Lord, '
      'who know me; let me know You, as I am known. Amen.';

  static DateTime _weekStart(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.subtract(Duration(days: dateOnly.weekday - 1));
  }

  FieldGuideWeek _currentWeek(DateTime asOf) {
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
        swordOptions: _swordOptions,
        spadePrompt: _spadePrompt,
        closingPrayer: _closingPrayer,
        createdAt: weekStart,
        lastModifiedAt: weekStart,
        members: [
          FieldGuideDailyDevotionalMember(
            id: 'humility-day-$dayNumber-you',
            dailyDevotionalId: 'humility-day-$dayNumber',
            personKey: 'you',
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
            personKey: 'jack',
            sword: _swordOptions.first,
            spade: 'I caught myself wanting credit for something small — let it go instead.',
            completedDate: dayDate.isAfter(DateTime(asOf.year, asOf.month, asOf.day)) ? null : dayDate,
            createdAt: dayDate,
            lastModifiedAt: dayDate,
          ),
          FieldGuideDailyDevotionalMember(
            id: 'humility-day-$dayNumber-thomas',
            dailyDevotionalId: 'humility-day-$dayNumber',
            personKey: 'thomas',
            sword: _swordOptions.last,
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
      weekNumber: 12,
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
    final week = _currentWeek(DateTime.now());
    final start = _weekStart(DateTime.now());
    final end = start.add(const Duration(days: 6));
    final dateOnly = DateTime(date.year, date.month, date.day);
    if (dateOnly.isBefore(start) || dateOnly.isAfter(end)) return null;
    return week;
  }

  @override
  Future<int> fetchStreak({required String personKey, required DateTime asOf}) async {
    return switch (personKey) {
      'you' => 3,
      'jack' => 8,
      'thomas' => 12,
      _ => 0,
    };
  }
}
