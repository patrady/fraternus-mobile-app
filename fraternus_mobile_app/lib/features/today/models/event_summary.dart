/// A calendar entry shown under "Events later this week" — deliberately
/// thin (just enough for the Today dashboard's summary row); the Events
/// tab's own richer event model is out of scope here.
class EventSummary {
  const EventSummary({required this.id, required this.title, required this.dateLabel});

  final String id;
  final String title;
  final String dateLabel;
}
