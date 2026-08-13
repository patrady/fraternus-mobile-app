import 'package:intl/intl.dart';

final _month = DateFormat('MMMM');

/// "July 19th" — month name plus the day with its ordinal suffix.
String formatOrdinalDate(DateTime date) {
  return '${_month.format(date)} ${date.day}${_ordinalSuffix(date.day)}';
}

String _ordinalSuffix(int day) {
  if (day >= 11 && day <= 13) return 'th';
  return switch (day % 10) {
    1 => 'st',
    2 => 'nd',
    3 => 'rd',
    _ => 'th',
  };
}
