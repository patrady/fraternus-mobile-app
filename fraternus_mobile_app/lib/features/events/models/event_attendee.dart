/// A non-household person shown in an event's read-only "Others Attending"
/// list — a read-projection of `Event RSVP` joined to `Member`, not a raw
/// schema entity itself.
///
/// Business rule: any authenticated user can see who else has accepted
/// ("Going") an event, whether or not they've RSVP'd themselves — this is
/// intentionally broader than `Event RSVP`'s own RLS, which restricts
/// direct reads to the caller's own household. See the
/// `get_event_attendees` RPC (event_attendees_rpc migration), which is
/// `security definer` specifically to allow this cross-household read
/// without loosening `event_rsvps`'/`members`' own RLS policies.
class EventAttendee {
  const EventAttendee({required this.id, required this.name});

  final String id;
  final String name;

  /// Computed client-side rather than stored/fetched — same pattern as
  /// `Member.initials`/`AppUser.initials`.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Expects `get_event_attendees`' row shape: `member_id`, `first_name`,
  /// `last_name`.
  factory EventAttendee.fromJson(Map<String, dynamic> json) {
    return EventAttendee(
      id: json['member_id'] as String,
      name: '${json['first_name'] as String} ${json['last_name'] as String}',
    );
  }
}
