import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../design_system/design_system.dart';
import '../../challenge/providers/challenge_providers.dart';
import '../../guide/providers/guide_providers.dart';
import '../models/household_person.dart';
import '../models/today_dashboard.dart';
import '../models/today_task.dart';
import '../providers/today_providers.dart';
import 'widgets/today_header.dart';

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(todayDashboardProvider);
    final selectedKey = ref.watch(todaySelectedPersonProvider);

    return ScreenShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: dashboardAsync.when(
          data: (dashboard) => _TodayContent(dashboard: dashboard, selectedKey: selectedKey),
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const BodyText('Something went wrong loading today.'),
        ),
      ),
    );
  }
}

class _TodayContent extends ConsumerWidget {
  const _TodayContent({required this.dashboard, required this.selectedKey});

  final TodayDashboard dashboard;
  final String selectedKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPerson = dashboard.people.firstWhere((person) => person.key == selectedKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        TodayHeader(
          date: dashboard.date,
          greetingName: dashboard.greetingName,
          onProfileTap: () => context.push(RoutePaths.todayProfile),
        ),
        const SizedBox(height: 20),
        DarkSummaryCard(
          eyebrow: "This Week's Focus",
          title: dashboard.weeklyFocus.virtue,
          onPressed: () => context.push(RoutePaths.guideVirtue),
        ),
        const SizedBox(height: 20),
        const HairlineDivider(),
        const SizedBox(height: 16),
        const Subheading('Today'),
        const SizedBox(height: 4),
        PersonTabs(
          people: dashboard.people
              .map((person) => PersonTabItem(key: person.key, label: person.label, status: person.status))
              .toList(),
          activeKey: selectedKey,
          onChanged: (key) => ref.read(todaySelectedPersonProvider.notifier).select(key),
        ),
        const SizedBox(height: 16),
        _TodayTaskCard(person: selectedPerson),
        const SizedBox(height: 20),
        const HairlineDivider(),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: Subheading('Events later this week')),
            _SeeAllLink(onPressed: () => context.push(RoutePaths.events)),
          ],
        ),
        const SizedBox(height: 8),
        if (dashboard.upcomingEvents.isEmpty)
          const BodyText('Nothing else on the calendar this week.')
        else
          for (final event in dashboard.upcomingEvents)
            ListRow(label: event.title, sublabel: event.dateLabel, bordered: false),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _TodayTaskCard extends ConsumerWidget {
  const _TodayTaskCard({required this.person});

  final HouseholdPerson person;

  Widget _leadingFor(TodayTaskKind kind, bool isComplete) {
    return switch (kind) {
      TodayTaskKind.fieldGuideReading || TodayTaskKind.weeklyChallenge => isComplete
          ? const FraternusIcon(name: 'circle-check', size: 22, tone: FraternusIconTone.success)
          : const FraternusIcon(name: 'circle', size: 22, opacity: 0.4),
      TodayTaskKind.event => const FraternusIcon(name: 'calendar', size: 20),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Events have no completion state of their own — only the two
    // actionable task kinds check against their own feature's real data.
    final isFieldGuideComplete =
        ref.watch(guideDevotionalProgressProvider(_dateOnly(DateTime.now()))).value?[person.key]?.isCompleted ??
        false;
    final currentChallenge = ref.watch(currentChallengeProvider).value;
    final isChallengeComplete = currentChallenge == null
        ? false
        : ref.watch(challengeProgressProvider(currentChallenge.id)).value?[person.key]?.isCompleted ?? false;

    final tasks = person.todayTasks;
    return Box(
      child: Column(
        children: [
          for (var i = 0; i < tasks.length; i++) ...[
            ListRow(
              leading: _leadingFor(
                tasks[i].kind,
                switch (tasks[i].kind) {
                  TodayTaskKind.fieldGuideReading => isFieldGuideComplete,
                  TodayTaskKind.weeklyChallenge => isChallengeComplete,
                  TodayTaskKind.event => false,
                },
              ),
              label: tasks[i].label,
              bordered: false,
              onPressed: switch (tasks[i].kind) {
                // An event task's id doubles as its event id in the Events
                // feature's own data — see StaticEventsRepository.
                TodayTaskKind.event => () => context.push(RoutePaths.eventDetail(tasks[i].id)),
                TodayTaskKind.weeklyChallenge => () => context.push(RoutePaths.challenge),
                TodayTaskKind.fieldGuideReading => () => context.push(RoutePaths.guide),
              },
            ),
            if (i != tasks.length - 1) const HairlineDivider(),
          ],
        ],
      ),
    );
  }
}

class _SeeAllLink extends StatelessWidget {
  const _SeeAllLink({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return PressableBuilder(
      onTap: onPressed,
      semanticLabel: 'See all',
      builder: (context, isPressed) {
        return Opacity(
          opacity: isPressed ? 0.75 : 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SEE ALL',
                style: FraternusTypography.button(fontSize: 13, color: FraternusColors.forestGreen)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const FraternusIcon(name: 'chevron-right', size: 16),
            ],
          ),
        );
      },
    );
  }
}
