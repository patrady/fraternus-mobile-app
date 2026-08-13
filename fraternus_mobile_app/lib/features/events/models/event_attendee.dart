/// A non-household person shown in an event's read-only "Others Attending"
/// list — a read-projection of `Event RSVP` joined to `Member`, not a raw
/// schema entity itself.
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
}
