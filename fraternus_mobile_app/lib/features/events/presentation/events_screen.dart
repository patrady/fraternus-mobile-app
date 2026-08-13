import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../design_system/design_system.dart';
import '../models/event.dart';
import '../providers/events_providers.dart';
import 'widgets/event_summary_row.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(visibleEventsProvider);

    return ScreenShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Heading('EVENTS', level: HeadingLevel.h2),
            const SizedBox(height: 20),
            eventsAsync.when(
              data: (events) => _EventsList(events: events),
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) => const BodyText('Something went wrong loading events.'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  const _EventsList({required this.events});

  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const BodyText('No events on the calendar right now.');
    }
    return Column(
      children: [
        for (var i = 0; i < events.length; i++) ...[
          EventSummaryRow(
            event: events[i],
            onPressed: () => context.push(RoutePaths.eventDetail(events[i].id)),
          ),
          if (i != events.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}
