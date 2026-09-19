/// A Captain signed up to give the Kings Message for a Frat Night — schema's
/// `Event Frat Night Kings Messenger`, joined to `Member` for display. Like
/// [EventAttendee], this is a cross-household read (any Captain in the
/// chapter can sign up, not just the caller's own household), so it's
/// resolved via the `get_event_kings_messengers` RPC rather than a nested
/// embed — see that RPC's doc for why a plain embed wouldn't work under
/// `members`' own RLS.
class EventKingsMessenger {
  const EventKingsMessenger({
    required this.memberId,
    required this.firstName,
    required this.lastName,
  });

  final String memberId;
  final String firstName;
  final String lastName;

  String get name => '$firstName $lastName';

  /// Computed client-side rather than stored/fetched — same pattern as
  /// `EventAttendee.initials`.
  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Expects `get_event_kings_messengers`' row shape: `member_id`,
  /// `first_name`, `last_name`.
  factory EventKingsMessenger.fromJson(Map<String, dynamic> json) {
    return EventKingsMessenger(
      memberId: json['member_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
    );
  }
}
