import 'event_attendee.dart';
import 'event_attendees_chapter.dart';
import 'event_attendees_specific.dart';
import 'event_eligible_member.dart';
import 'event_excursion_details.dart';
import 'event_frat_night_details.dart';
import 'event_location.dart';
import 'event_ranch_details.dart';
import 'household_rsvp.dart';

enum EventType { fratNight, excursion, ranch, custom, commitmentCeremony, ceremony }

extension EventTypeIcon on EventType {
  /// Lucide icon name shown on the event's card — [EventType.custom]
  /// doubles as the fallback for an [Event._typeFromDb] value the backend
  /// sends that this client doesn't recognize yet.
  String get iconName => switch (this) {
    EventType.fratNight => 'users',
    EventType.excursion => 'tent',
    EventType.ranch => 'backpack',
    EventType.custom => 'shapes',
    EventType.commitmentCeremony => 'sword',
    EventType.ceremony => 'award',
  };
}

/// A single chapter event — richer than `today/models/event_summary.dart`'s
/// `EventSummary`, which is deliberately thin and stays scoped to the Today
/// dashboard's own preview list.
class Event {
  const Event({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.location,
    required this.startAt,
    required this.endAt,
    this.cancellationDate,
    required this.createdAt,
    required this.lastModifiedAt,
    required this.attendeesChapter,
    required this.attendeesSpecific,
    this.fratNightDetails,
    this.excursionDetails,
    this.ranchDetails,
    required this.eligibleHouseholdMembers,
    required this.householdRsvps,
    required this.othersAttending,
  });

  final String id;
  final EventType type;
  final String title;
  final String? description;
  final EventLocation? location;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime? cancellationDate;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  /// Chapter-wide eligibility rows (Captains / Brothers / entire Chapter) —
  /// schema's `Event Attendees Chapter`.
  final List<EventAttendeesChapter> attendeesChapter;

  /// Individually-invited eligibility rows — schema's
  /// `Event Attendees Specific`.
  final List<EventAttendeesSpecific> attendeesSpecific;

  /// Populated only when [type] is [EventType.fratNight].
  final EventFratNightDetails? fratNightDetails;

  /// Populated only when [type] is [EventType.excursion].
  final EventExcursionDetails? excursionDetails;

  /// Populated only when [type] is [EventType.ranch].
  final EventRanchDetails? ranchDetails;

  /// Which household members can RSVP — not a schema entity itself, see
  /// [EventEligibleMember]. Independent of [householdRsvps], which only
  /// contains members who have actually responded.
  final List<EventEligibleMember> eligibleHouseholdMembers;

  /// Only the household members who have actually submitted a response —
  /// an `Event RSVP` row doesn't exist until then.
  final List<HouseholdRsvp> householdRsvps;
  final List<EventAttendee> othersAttending;

  /// The UI only needs cancelled-or-not, not when it was cancelled.
  bool get isCancelled => cancellationDate != null;

  /// Falls back to [EventType.custom] for a value this client doesn't
  /// recognize yet, since `event_type` is backend-defined and new values
  /// can ship there before this client knows about them.
  static EventType _typeFromDb(String value) => switch (value) {
    'frat_night' => EventType.fratNight,
    'excursion' => EventType.excursion,
    'ranch' => EventType.ranch,
    'commitment_ceremony' => EventType.commitmentCeremony,
    'ceremony' => EventType.ceremony,
    _ => EventType.custom,
  };

  /// Expects the nested-embed shape `*, event_locations(*),
  /// event_frat_night_details(*), event_excursion_details(*),
  /// event_ranch_details(*), event_attendees_chapter(*),
  /// event_attendees_specific(*), event_rsvps(*)` — see
  /// SupabaseEventsRepository. `event_locations` comes back as a single
  /// object (or null), not a list, since `event_location_id` is a to-one FK
  /// on `events` rather than a child table keyed by `event_id`. RLS already
  /// scopes the embedded `event_rsvps`/`event_attendees_specific` rows to
  /// the caller's own household, so [householdRsvps] needs no further
  /// filtering here.
  ///
  /// [eligibleMemberIds] and [memberLabels] resolve [eligibleHouseholdMembers]
  /// — not a schema entity, so it isn't part of the embed — from a separate
  /// `get_event_eligible_members` RPC call and the household member list,
  /// both fetched by the repository, not this factory. [othersAttending] is
  /// resolved the same way, from a separate `get_event_attendees` RPC call
  /// — see EventAttendee's doc for why that's its own cross-household RPC
  /// rather than part of this embed.
  factory Event.fromJson(
    Map<String, dynamic> json, {
    required Map<String, String> memberLabels,
    required List<String> eligibleMemberIds,
    required List<EventAttendee> othersAttending,
  }) {
    final attendeesChapterJson =
        json['event_attendees_chapter'] as List<dynamic>? ?? const [];
    final attendeesSpecificJson =
        json['event_attendees_specific'] as List<dynamic>? ?? const [];
    final rsvpsJson = json['event_rsvps'] as List<dynamic>? ?? const [];
    final fratNightDetailsJson =
        json['event_frat_night_details'] as Map<String, dynamic>?;
    final excursionDetailsJson =
        json['event_excursion_details'] as Map<String, dynamic>?;
    final ranchDetailsJson =
        json['event_ranch_details'] as Map<String, dynamic>?;
    final locationJson = json['event_locations'] as Map<String, dynamic>?;

    return Event(
      id: json['id'] as String,
      type: _typeFromDb(json['type'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      location: locationJson == null
          ? null
          : EventLocation.fromJson(locationJson),
      startAt: DateTime.parse(json['start_date'] as String),
      endAt: DateTime.parse(json['end_date'] as String),
      cancellationDate: (json['cancellation_date'] as String?) == null
          ? null
          : DateTime.parse(json['cancellation_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      lastModifiedAt: DateTime.parse(json['updated_at'] as String),
      attendeesChapter: [
        for (final row in attendeesChapterJson)
          EventAttendeesChapter.fromJson(row as Map<String, dynamic>),
      ],
      attendeesSpecific: [
        for (final row in attendeesSpecificJson)
          EventAttendeesSpecific.fromJson(row as Map<String, dynamic>),
      ],
      fratNightDetails: fratNightDetailsJson == null
          ? null
          : EventFratNightDetails.fromJson(fratNightDetailsJson),
      excursionDetails: excursionDetailsJson == null
          ? null
          : EventExcursionDetails.fromJson(excursionDetailsJson),
      ranchDetails: ranchDetailsJson == null
          ? null
          : EventRanchDetails.fromJson(ranchDetailsJson),
      eligibleHouseholdMembers: [
        for (final memberId in eligibleMemberIds)
          if (memberLabels[memberId] case final label?)
            EventEligibleMember(memberId: memberId, label: label),
      ],
      householdRsvps: [
        for (final row in rsvpsJson)
          HouseholdRsvp.fromJson(row as Map<String, dynamic>),
      ],
      othersAttending: othersAttending,
    );
  }
}
