import 'package:add_2_calendar/add_2_calendar.dart' as add2cal;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraternus_mobile_app/shared/formatting/date_time_utils.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../../shared/formatting/event_date_formatting.dart';
import '../../../shared/widgets/error_snackbar.dart';
import '../models/event.dart';
import '../models/event_attendee.dart';
import '../models/event_attendees_chapter.dart';
import '../providers/events_providers.dart';
import 'widgets/open_in_maps_dialog.dart';

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
              error: (error, stackTrace) =>
                  const BodyText('Something went wrong loading this event.'),
              // A background reload (e.g. the RSVP-toggle-triggered
              // visibleEventsProvider refresh) should keep showing the
              // previous event rather than blanking the whole screen.
              skipLoadingOnReload: true,
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

  String get _scopeLabel {
    final roles = event.attendeesChapter.map((a) => a.role).toSet();
    if (roles.contains(EventAttendeeChapterRole.chapter)) {
      return 'Entire Chapter';
    }
    if (roles.contains(EventAttendeeChapterRole.captains) &&
        roles.contains(EventAttendeeChapterRole.brothers)) {
      return 'Entire Chapter';
    }
    if (roles.contains(EventAttendeeChapterRole.captains)) {
      return 'Captains Only';
    }
    if (roles.contains(EventAttendeeChapterRole.brothers)) {
      return 'Brothers Only';
    }
    if (event.attendeesSpecific.isNotEmpty) return 'Invited';
    return 'Entire Chapter';
  }

  void _addToDeviceCalendar() {
    final calendarEvent = add2cal.Event(
      title: event.title,
      description: event.description,
      location: event.location?.mapQuery,
      startDate: event.startAt,
      endDate: event.endAt,
    );
    add2cal.Add2Calendar.addEvent2Cal(calendarEvent);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cancelled = event.isCancelled;
    final rsvpAsync = ref.watch(eventRsvpProvider(eventId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Heading(event.title.toUpperCase(), level: HeadingLevel.h3),
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
        if (isSameDay(event.startAt.toLocal(), event.endAt.toLocal()))
          _DetailMetaLine(
            icon: 'clock',
            label: formatEventDateRange(
              event.startAt.toLocal(),
              event.endAt.toLocal(),
            ),
          )
        else ...[
          _DetailMetaLine(
            icon: 'clock',
            label: formatDayTimeLabel(event.startAt.toLocal()),
          ),
          Row(
            children: [
              const SizedBox(width: 20),
              Text(
                "to ",
                style: FraternusTypography.body(
                  color: FraternusColors.accentPrimary,
                ),
              ),
              Expanded(
                child: Text(
                  formatDayTimeLabel(event.endAt.toLocal()),
                  style: FraternusTypography.body(
                    color: FraternusColors.accentPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (event.location case final location?) ...[
          const SizedBox(height: 6),
          PressableBuilder(
            onTap: () => showOpenInMapsPrompt(context, location),
            semanticLabel: 'Open ${location.name} in Maps',
            builder: (context, isPressed) {
              return Opacity(
                opacity: isPressed ? 0.75 : 1,
                child: _DetailMetaLine(icon: 'map-pin', label: location.name),
              );
            },
          ),
        ],
        if (event.description case final description?) ...[
          const SizedBox(height: 16),
          BodyText(description),
        ],
        const SizedBox(height: 24),
        const Subheading('RSVP'),
        const SizedBox(height: 12),
        rsvpAsync.when(
          data: (statuses) => Column(
            children: [
              for (
                var i = 0;
                i < event.eligibleHouseholdMembers.length;
                i++
              ) ...[
                _RsvpRow(
                  label: event.eligibleHouseholdMembers[i].label,
                  status: statuses[event.eligibleHouseholdMembers[i].memberId],
                  onChanged: (status) async {
                    try {
                      await ref
                          .read(eventRsvpProvider(eventId).notifier)
                          .toggleStatus(
                            event.eligibleHouseholdMembers[i].memberId,
                            status,
                          );
                    } catch (_) {
                      if (context.mounted) {
                        showErrorSnackBar(
                          context,
                          'Something went wrong. Please try again.',
                        );
                      }
                    }
                  },
                ),
                if (i != event.eligibleHouseholdMembers.length - 1)
                  const SizedBox(height: 12),
              ],
            ],
          ),
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
          skipLoadingOnReload: true,
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
        if (event.othersAttending.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Subheading('Others Attending'),
          const SizedBox(height: 12),
          Column(
            children: [
              for (var i = 0; i < event.othersAttending.length; i++) ...[
                _AttendeeRow(attendee: event.othersAttending[i]),
                if (i != event.othersAttending.length - 1)
                  const HairlineDivider(),
              ],
            ],
          ),
        ],
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
          child: Text(
            label,
            style: FraternusTypography.body(
              color: FraternusColors.accentPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _RsvpRow extends StatelessWidget {
  const _RsvpRow({
    required this.label,
    required this.status,
    required this.onChanged,
  });

  final String label;
  final RsvpStatus? status;
  final ValueChanged<RsvpStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: FraternusTypography.body(color: FraternusColors.ink),
          ),
        ),
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
          Text(
            attendee.name,
            style: FraternusTypography.body(color: FraternusColors.ink),
          ),
        ],
      ),
    );
  }
}
