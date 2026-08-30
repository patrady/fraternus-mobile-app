/// Whether [a] and [b] fall on the same calendar day — compares year/month/day
/// fields directly, so callers must first normalize both to the same
/// timezone (e.g. via `.toLocal()`) when comparing values from different
/// sources.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
