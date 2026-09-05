import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/clock_provider.dart';
import '../../../app/router/route_paths.dart';
import '../../../design_system/design_system.dart';
import '../../../shared/formatting/event_date_formatting.dart';
import '../models/event.dart';
import '../providers/events_providers.dart';
import 'widgets/event_summary_row.dart';
import 'widgets/event_type_filter_dialog.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(visibleEventsProvider);
    final typeFilter = ref.watch(eventTypeFilterProvider);
    final now = ref.watch(nowProvider);

    return ScreenShell(
      // A plain Column (ScreenShell's default SingleChildScrollView body)
      // can't host slivers, and pinned sliver headers are what give the
      // month labels below their "stick to the top until the next month
      // scrolls in" behavior — so this screen manages its own scrolling.
      scrollable: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  const Expanded(
                    child: Heading('EVENTS', level: HeadingLevel.h2),
                  ),
                  PressableBuilder(
                    onTap: () => showEventTypeFilterDialog(context),
                    semanticLabel: 'Filter events',
                    builder: (context, isPressed) {
                      return Opacity(
                        opacity: isPressed ? 0.75 : 1,
                        child: SizedBox(
                          height: 44,
                          width: 32,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const FraternusIcon(
                                name: 'sliders-horizontal',
                                size: 22,
                              ),
                              if (typeFilter.isNotEmpty)
                                Positioned(
                                  top: 8,
                                  right: 4,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: FraternusColors.terracotta,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          ...eventsAsync.when(
            data: (events) {
              final filtered = typeFilter.isEmpty
                  ? events
                  : events
                        .where((event) => typeFilter.contains(event.type))
                        .toList();
              return _eventSlivers(
                context,
                events: filtered,
                filtered: typeFilter.isNotEmpty,
                now: now,
              );
            },
            loading: () => const [SliverToBoxAdapter(child: SizedBox.shrink())],
            error: (error, stackTrace) => const [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: BodyText('Something went wrong loading events.'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

List<Widget> _eventSlivers(
  BuildContext context, {
  required List<Event> events,
  required bool filtered,
  required DateTime now,
}) {
  if (events.isEmpty) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BodyText(
            // Whether a type filter is currently narrowing events — swaps
            // the empty-state copy so "no events match this filter" doesn't
            // read as "nothing on the calendar at all."
            filtered
                ? 'No events match the selected filters.'
                : 'No events on the calendar right now.',
          ),
        ),
      ),
    ];
  }

  // events arrives sorted by startAt ascending, so each new (year, month)
  // pair starts a fresh group without needing to re-sort or bucket up
  // front. Each group becomes its own pinned SliverPersistentHeader +
  // eagerly-built row Column, spliced directly into the CustomScrollView's
  // own sliver list (not nested inside another group) — that's what makes
  // the header stick to the top of the viewport until the next group's
  // header pushes it off.
  final monthSlivers = <Widget>[];
  List<Event> currentGroup = [];
  for (final event in events) {
    if (currentGroup.isNotEmpty &&
        (event.startAt.year != currentGroup.first.startAt.year ||
            event.startAt.month != currentGroup.first.startAt.month)) {
      monthSlivers.add(_monthSliver(context, currentGroup, now: now));
      currentGroup = [];
    }
    currentGroup.add(event);
  }
  monthSlivers.add(_monthSliver(context, currentGroup, now: now));

  return monthSlivers;
}

Widget _monthSliver(
  BuildContext context,
  List<Event> monthEvents, {
  required DateTime now,
}) {
  return SliverMainAxisGroup(
    slivers: [
      SliverPersistentHeader(
        pinned: true,
        delegate: _MonthHeaderDelegate(
          formatEventMonthLabel(monthEvents.first.startAt, now),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        // A plain (eagerly-built) Column rather than a SliverList — this is
        // always a small, bounded set of rows (a chapter's near-term
        // events), never worth lazy-building, and SliverList only realizes
        // children within its cache extent, which left rows past the
        // initial viewport silently un-built even with a large
        // scrollCacheExtent set.
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final event in monthEvents) ...[
                EventSummaryRow(
                  event: event,
                  onPressed: () =>
                      context.push(RoutePaths.eventDetail(event.id)),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    ],
  );
}

/// Pinned month-label band behind each group of [EventSummaryRow]s —
/// filled with the same background [ScreenShell] paints so a row scrolling
/// underneath a pinned header doesn't show through it.
class _MonthHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _MonthHeaderDelegate(this.label);

  final String label;

  static const _height = 44.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: FraternusColors.surfaceCardDim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Heading(label, level: .h3),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _MonthHeaderDelegate oldDelegate) =>
      label != oldDelegate.label;
}
