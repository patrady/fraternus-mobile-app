import '../../../design_system/design_system.dart' show PersonTabStatus;
import '../models/household_person.dart';
import '../models/today_dashboard.dart';
import '../models/today_task.dart';
import '../models/weekly_focus.dart';

/// Source of the Today dashboard's data. Returning a [Future] here — even
/// though [StaticTodayDashboardRepository] resolves instantly — is the
/// deliberate seam: swapping to a Drift-backed `Stream` query or a real API
/// call later only means changing the implementation, not this interface,
/// the providers that watch it, or the screen.
abstract class TodayDashboardRepository {
  Future<TodayDashboard> fetchDashboard({required DateTime forDate});
}

/// Hardcoded stand-in for real content, matching
/// `design_handoff_components/screenshots/01-today-home.png`.
class StaticTodayDashboardRepository implements TodayDashboardRepository {
  const StaticTodayDashboardRepository();

  @override
  Future<TodayDashboard> fetchDashboard({required DateTime forDate}) async {
    return TodayDashboard(
      date: forDate,
      greetingName: 'John',
      weeklyFocus: const WeeklyFocus(virtue: 'Humility'),
      people: const [
        HouseholdPerson(
          memberId: 'you',
          label: 'You',
          status: PersonTabStatus.none,
          todayTasks: [
            TodayTask(
              id: 'field-guide-reading',
              label: "Today's Field Guide Reading",
              kind: TodayTaskKind.fieldGuideReading,
            ),
            TodayTask(id: 'weekly-challenge', label: 'Weekly Challenge', kind: TodayTaskKind.weeklyChallenge),
            TodayTask(id: 'hawc-night', label: 'HAWC Night', kind: TodayTaskKind.event),
            TodayTask(
              id: 'frat-night',
              label: 'Frat Night — Virtue of Fortitude',
              kind: TodayTaskKind.event,
            ),
          ],
        ),
        HouseholdPerson(
          memberId: 'jack',
          label: 'Jack',
          status: PersonTabStatus.inProgress,
          todayTasks: [
            TodayTask(
              id: 'field-guide-reading',
              label: "Today's Field Guide Reading",
              kind: TodayTaskKind.fieldGuideReading,
            ),
            TodayTask(id: 'weekly-challenge', label: 'Weekly Challenge', kind: TodayTaskKind.weeklyChallenge),
            TodayTask(id: 'hawc-night', label: 'HAWC Night', kind: TodayTaskKind.event),
            TodayTask(
              id: 'frat-night',
              label: 'Frat Night — Virtue of Fortitude',
              kind: TodayTaskKind.event,
            ),
          ],
        ),
        HouseholdPerson(
          memberId: 'thomas',
          label: 'Thomas',
          status: PersonTabStatus.done,
          todayTasks: [
            TodayTask(
              id: 'field-guide-reading',
              label: "Today's Field Guide Reading",
              kind: TodayTaskKind.fieldGuideReading,
            ),
            TodayTask(id: 'weekly-challenge', label: 'Weekly Challenge', kind: TodayTaskKind.weeklyChallenge),
            TodayTask(id: 'hawc-night', label: 'HAWC Night', kind: TodayTaskKind.event),
            TodayTask(
              id: 'frat-night',
              label: 'Frat Night — Virtue of Fortitude',
              kind: TodayTaskKind.event,
            ),
          ],
        ),
      ],
      upcomingEvents: const [],
    );
  }
}
