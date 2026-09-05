import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/clock_provider.dart';
import '../../../design_system/design_system.dart' show PersonTabStatus;
import '../../../shared/formatting/date_time_utils.dart';
import '../../../shared/formatting/event_date_formatting.dart';
import '../../challenge/models/person_challenge_progress.dart';
import '../../challenge/models/weekly_challenge.dart';
import '../../challenge/providers/challenge_providers.dart';
import '../../events/models/event.dart';
import '../../events/providers/events_providers.dart';
import '../../guide/models/field_guide_daily_devotional_member.dart';
import '../../guide/models/field_guide_week.dart';
import '../../guide/providers/guide_providers.dart';
import '../../profile/models/member.dart';
import '../../profile/providers/profile_providers.dart';
import '../models/event_summary.dart';
import '../models/household_person.dart';
import '../models/today_dashboard.dart';
import '../models/today_task.dart';
import '../models/weekly_focus.dart';

part 'today_providers.g.dart';

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

HouseholdPerson _buildPerson({
  required Member member,
  required FieldGuideWeek? week,
  required DateTime today,
  required WeeklyChallenge? currentChallenge,
  required Map<String, FieldGuideDailyDevotionalMember> guideProgress,
  required Map<String, PersonChallengeProgress> challengeProgress,
  required bool hasTemperamentResult,
  required List<Event> todaysEvents,
}) {
  final devotional = week?.devotionalForDate(today);
  final isFieldGuideComplete = guideProgress[member.id]?.isCompleted ?? false;
  final isChallengeComplete =
      challengeProgress[member.id]?.isCompleted ?? false;

  final tasks = [
    if (devotional != null)
      const TodayTask(
        id: 'field-guide-reading',
        label: "Today's Field Guide Reading",
        kind: TodayTaskKind.fieldGuideReading,
      ),
    if (currentChallenge != null)
      const TodayTask(
        id: 'weekly-challenge',
        label: 'Weekly Challenge',
        kind: TodayTaskKind.weeklyChallenge,
      ),
    // Recurs every day until this member takes the quiz once — unlike the
    // two tasks above, it has no per-day state and simply disappears for
    // good once GuideTemperamentResult resolves non-null (see
    // profile_screen.dart, which used to be the only entry point for this).
    if (!hasTemperamentResult)
      const TodayTask(
        id: 'temperament-quiz',
        label: 'Find Your Temperament',
        kind: TodayTaskKind.temperamentQuiz,
      ),
    // Only events this member is actually eligible for — a Brother
    // shouldn't see a Captains-only meeting on their own Today list.
    for (final event in todaysEvents)
      if (event.eligibleHouseholdMembers.any(
        (eligible) => eligible.memberId == member.id,
      ))
        TodayTask(id: event.id, label: event.title, kind: TodayTaskKind.event),
  ];

  // Status reflects the two actionable tasks only — events are purely
  // informational and have no completion state of their own (matches
  // _TodayTaskCard's own leading-icon logic in today_screen.dart).
  final completableCount =
      (devotional != null ? 1 : 0) + (currentChallenge != null ? 1 : 0);
  final completedCount =
      (devotional != null && isFieldGuideComplete ? 1 : 0) +
      (currentChallenge != null && isChallengeComplete ? 1 : 0);
  final status = completedCount == 0
      ? PersonTabStatus.none
      : completedCount == completableCount
      ? PersonTabStatus.done
      : PersonTabStatus.inProgress;

  return HouseholdPerson(
    memberId: member.id,
    label: member.firstName,
    status: status,
    todayTasks: tasks,
  );
}

/// Composed client-side from Guide/Challenge/Events/Profile's own providers
/// rather than a dedicated backend aggregator — reuses each tab's
/// already-migrated logic (Field Guide week/devotional resolution, current
/// challenge resolution, event visibility filtering) instead of duplicating
/// it in SQL. See the migration plan's decision notes.
@riverpod
Future<TodayDashboard> todayDashboard(Ref ref) async {
  final now = ref.watch(nowProvider);
  final today = _dateOnly(now);

  final members = await ref.watch(householdMembersProvider.future);
  final week = await ref.watch(guideWeekForDateProvider(today).future);
  final currentChallenge = await ref.watch(currentChallengeProvider.future);
  final guideProgress = await ref.watch(
    guideDevotionalProgressProvider(today).future,
  );
  final challengeProgress = currentChallenge == null
      ? const <String, PersonChallengeProgress>{}
      : await ref.watch(challengeProgressProvider(currentChallenge.id).future);
  final events = await ref.watch(visibleEventsProvider.future);
  final temperamentResults = await Future.wait([
    for (final member in members)
      ref.watch(guideTemperamentResultProvider(member.id).future),
  ]);
  final hasTemperamentResultByMemberId = {
    for (var i = 0; i < members.length; i++)
      members[i].id: temperamentResults[i] != null,
  };

  final todaysEvents = [
    for (final event in events)
      if (isSameDay(event.startAt.toLocal(), today)) event,
  ];
  // "Events later this week" — a simple rolling 7-day window past today,
  // since nothing else in this app defines a calendar-week boundary to
  // anchor to (Field Guide weeks are a different, unrelated concept).
  final laterEvents = [
    for (final event in events)
      if (!isSameDay(event.startAt.toLocal(), today) &&
          event.startAt.isBefore(today.add(const Duration(days: 7))))
        event,
  ];

  // The "This Week's Focus" card is about today's reading specifically —
  // hidden whenever today itself has no devotional, not just when no week
  // resolves at all (a week can resolve but not cover every day).
  final hasTodaysReading = week?.devotionalForDate(today) != null;

  return TodayDashboard(
    date: today,
    weeklyFocus: hasTodaysReading ? WeeklyFocus(virtue: week!.virtue) : null,
    people: [
      for (final member in members)
        _buildPerson(
          member: member,
          week: week,
          today: today,
          currentChallenge: currentChallenge,
          guideProgress: guideProgress,
          challengeProgress: challengeProgress,
          hasTemperamentResult:
              hasTemperamentResultByMemberId[member.id] ?? false,
          todaysEvents: todaysEvents,
        ),
    ],
    upcomingEvents: [
      for (final event in laterEvents)
        EventSummary(
          id: event.id,
          title: event.title,
          dateLabel: formatEventDayLabel(event.startAt.toLocal()),
        ),
    ],
  );
}
