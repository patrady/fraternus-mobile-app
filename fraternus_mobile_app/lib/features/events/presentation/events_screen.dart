import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../design_system/design_system.dart';
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

    return ScreenShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            const SizedBox(height: 20),
            eventsAsync.when(
              data: (events) {
                final filtered = typeFilter.isEmpty
                    ? events
                    : events
                          .where((event) => typeFilter.contains(event.type))
                          .toList();
                return _EventsList(
                  events: filtered,
                  filtered: typeFilter.isNotEmpty,
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) =>
                  const BodyText('Something went wrong loading events.'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  const _EventsList({required this.events, required this.filtered});

  final List<Event> events;

  /// Whether a type filter is currently narrowing [events] — swaps the
  /// empty-state copy so "no events match this filter" doesn't read as
  /// "nothing on the calendar at all."
  final bool filtered;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return BodyText(
        filtered
            ? 'No events match the selected filters.'
            : 'No events on the calendar right now.',
      );
    }
    return Column(
      children: [
        for (var i = 0; i < events.length; i++) ...[
          EventSummaryRow(
            event: events[i],
            onPressed: () => context.push(RoutePaths.eventDetail(events[i].id)),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
