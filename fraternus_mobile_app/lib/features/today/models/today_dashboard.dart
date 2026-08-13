import 'event_summary.dart';
import 'household_person.dart';
import 'weekly_focus.dart';

/// Aggregate root for everything the Today screen renders.
class TodayDashboard {
  const TodayDashboard({
    required this.date,
    required this.greetingName,
    required this.weeklyFocus,
    required this.people,
    required this.upcomingEvents,
  });

  final DateTime date;
  final String greetingName;
  final WeeklyFocus weeklyFocus;
  final List<HouseholdPerson> people;

  /// Empty in the current seed data (matches "Nothing else on the calendar
  /// this week."), but the shape supports a non-empty list once real
  /// content is wired up.
  final List<EventSummary> upcomingEvents;
}
