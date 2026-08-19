import 'package:intl/intl.dart';

final _weekdayMonthDay = DateFormat('EEE, MMM d');
final _time = DateFormat.jm();

/// "Fri, Jul 24 · 8:30 PM – 9:00 PM" for a same-day event, or
/// "Thu, Jul 8 · 9:00 AM – Mon, Jul 12 · 3:00 PM" once it spans days.
String formatEventDateRange(DateTime start, DateTime end) {
  final sameDay = start.year == end.year && start.month == end.month && start.day == end.day;
  final startLabel = '${_weekdayMonthDay.format(start)} · ${_time.format(start)}';
  final endLabel = sameDay
      ? _time.format(end)
      : '${_weekdayMonthDay.format(end)} · ${_time.format(end)}';
  return '$startLabel – $endLabel';
}

/// "Fri, Jul 24" — a single-date label, for contexts (like the Today
/// dashboard's "Events later this week" rows) that show a date without a
/// time range.
String formatEventDayLabel(DateTime date) => _weekdayMonthDay.format(date);

/// A countdown badge label ("IN 30 MINUTES", "IN 2 HOURS") for an event
/// starting soon, or null once it's more than [within] away (or already
/// started) — callers treat null as "show no badge".
String? formatStartingSoonLabel(DateTime now, DateTime start, {Duration within = const Duration(hours: 6)}) {
  final until = start.difference(now);
  if (until.isNegative || until > within) return null;

  if (until.inMinutes < 60) {
    final minutes = until.inMinutes < 1 ? 1 : until.inMinutes;
    return 'IN $minutes MINUTE${minutes == 1 ? '' : 'S'}';
  }
  final hours = (until.inMinutes / 60).round();
  return 'IN $hours HOUR${hours == 1 ? '' : 'S'}';
}
