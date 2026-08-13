/// A non-household person shown in an event's read-only "Others Attending"
/// list.
class EventAttendee {
  const EventAttendee({required this.id, required this.name, required this.initials});

  final String id;
  final String name;
  final String initials;
}
