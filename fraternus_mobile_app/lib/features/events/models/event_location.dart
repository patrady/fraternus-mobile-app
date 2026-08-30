/// Adapted from docs/app_concept.md's `Event Location` table — referenced by
/// `Event.eventLocationId`. Street/city/state/zip are all nullable in the
/// schema (a location can be just a name, e.g. while address details are
/// still being filled in), so [address] and [mapQuery] degrade gracefully
/// when some or all of them are missing.
class EventLocation {
  const EventLocation({
    required this.id,
    required this.name,
    this.description,
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.notes,
  });

  final String id;
  final String name;
  final String? description;
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? notes;

  /// "Street, City, State Zip" — only the parts that are present, comma
  /// joined. Empty when no address fields are set.
  String get address {
    final cityStateZip = [
      city,
      if (state != null || zipCode != null) [state, zipCode].nonNulls.join(' '),
    ].nonNulls.where((part) => part.isNotEmpty).join(', ');
    return [
      street,
      cityStateZip,
    ].nonNulls.where((part) => part.isNotEmpty).join(', ');
  }

  /// "Name, Street, City, State Zip" — what gets handed to Google/Apple Maps
  /// as a search query, since a plain address can be ambiguous for a place
  /// like a state park or camp that has no exact street number.
  String get mapQuery =>
      [name, address].where((part) => part.isNotEmpty).join(', ');

  factory EventLocation.fromJson(Map<String, dynamic> json) {
    return EventLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zip_code'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
