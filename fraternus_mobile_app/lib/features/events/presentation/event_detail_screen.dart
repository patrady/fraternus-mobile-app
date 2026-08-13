import 'package:add_2_calendar/add_2_calendar.dart' as add2cal;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../../shared/formatting/event_date_formatting.dart';
import '../models/event.dart';
import '../models/event_attendee.dart';
import '../providers/events_providers.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventByIdProvider(eventId));

    return ScreenShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'Events', onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: eventAsync.when(
              data: (event) => event == null
                  ? const BodyText('This event could not be found.')
                  : _EventDetailContent(event: event, eventId: eventId),
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) => const BodyText('Something went wrong loading this event.'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventDetailContent extends ConsumerWidget {
  const _EventDetailContent({required this.event, required this.eventId});

  final Event event;
  final String eventId;

  String get _scopeLabel => switch (event.scope) {
    EventScope.entireChapter => 'Entire Chapter',
    EventScope.captainsOnly => 'Captains Only',
  };

  void _addToDeviceCalendar() {
    final calendarEvent = add2cal.Event(
      title: event.title,
      description: event.description,
      location: event.location,
      startDate: event.startAt,
      endDate: event.endAt,
    );
    add2cal.Add2Calendar.addEvent2Cal(calendarEvent);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cancelled = event.status == EventStatus.cancelled;
    final rsvpAsync = ref.watch(eventRsvpProvider(eventId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Heading(event.title.toUpperCase(), level: HeadingLevel.h2),
        const SizedBox(height: 8),
        Tag(label: _scopeLabel, size: TagSize.small),
        if (cancelled) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: FraternusColors.error,
              borderRadius: BorderRadius.circular(FraternusRadii.md),
            ),
            child: Text(
              'This event has been cancelled.',
              style: FraternusTypography.body(color: FraternusColors.white),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _DetailMetaLine(icon: 'clock', label: formatEventDateRange(event.startAt, event.endAt)),
        const SizedBox(height: 6),
        _DetailMetaLine(icon: 'map-pin', label: event.location),
        const SizedBox(height: 16),
        BodyText(event.description),
        const SizedBox(height: 24),
        const Subheading('RSVP'),
        const SizedBox(height: 12),
        rsvpAsync.when(
          data: (statuses) => Column(
            children: [
              for (var i = 0; i < event.householdRsvps.length; i++) ...[
                _RsvpRow(
                  label: event.householdRsvps[i].label,
                  status: statuses[event.householdRsvps[i].personKey],
                  onChanged: (status) => ref
                      .read(eventRsvpProvider(eventId).notifier)
                      .toggleStatus(event.householdRsvps[i].personKey, status),
                ),
                if (i != event.householdRsvps.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 20),
        Button(
          label: 'Add to Calendar',
          icon: 'calendar-plus',
          variant: ButtonVariant.ghost,
          fullWidth: true,
          disabled: cancelled,
          onPressed: _addToDeviceCalendar,
        ),
        const SizedBox(height: 24),
        const Subheading('Others Attending'),
        const SizedBox(height: 12),
        Column(
          children: [
            for (var i = 0; i < event.othersAttending.length; i++) ...[
              _AttendeeRow(attendee: event.othersAttending[i]),
              if (i != event.othersAttending.length - 1) const HairlineDivider(),
            ],
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _DetailMetaLine extends StatelessWidget {
  const _DetailMetaLine({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FraternusIcon(name: icon, size: 16, tone: FraternusIconTone.terracotta),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: FraternusTypography.body(color: FraternusColors.accentPrimary)),
        ),
      ],
    );
  }
}

class _RsvpRow extends StatelessWidget {
  const _RsvpRow({required this.label, required this.status, required this.onChanged});

  final String label;
  final RsvpStatus? status;
  final ValueChanged<RsvpStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: FraternusTypography.body(color: FraternusColors.ink))),
        RsvpToggle(status: status, onChanged: onChanged),
      ],
    );
  }
}

class _AttendeeRow extends StatelessWidget {
  const _AttendeeRow({required this.attendee});

  final EventAttendee attendee;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Avatar(initials: attendee.initials, size: AvatarSize.small),
          const SizedBox(width: 12),
          Text(attendee.name, style: FraternusTypography.body(color: FraternusColors.ink)),
        ],
      ),
    );
  }
}
