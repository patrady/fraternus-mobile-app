import '../../../design_system/design_system.dart' show PersonTabStatus;
import 'today_task.dart';

/// One household member (the logged-in user, or a Brother they're a
/// Guardian/Captain for) as shown in the Today screen's [PersonTabs]
/// switcher, along with their tasks for today.
class HouseholdPerson {
  const HouseholdPerson({
    required this.memberId,
    required this.label,
    required this.status,
    required this.todayTasks,
  });

  final String memberId;
  final String label;

  /// Reuses the design system's own completion-status enum rather than
  /// duplicating it — this is exactly what [PersonTabs] renders.
  final PersonTabStatus status;
  final List<TodayTask> todayTasks;
}
