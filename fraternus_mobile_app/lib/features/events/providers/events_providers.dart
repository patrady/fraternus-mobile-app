import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../design_system/design_system.dart' show RsvpStatus;
import '../data/events_repository.dart';
import '../models/event.dart';

part 'events_providers.g.dart';

/// Swap this provider's implementation to change where Events' data comes
/// from — nothing downstream needs to change.
@riverpod
EventsRepository eventsRepository(Ref ref) {
  return const StaticEventsRepository();
}

/// Events sorted by start date ascending, filtered to those still within
/// 12 hours of their end — a business rule, so it lives here rather than in
/// the repository or the model.
@riverpod
Future<List<Event>> visibleEvents(Ref ref) async {
  final repository = ref.watch(eventsRepositoryProvider);
  final now = DateTime.now();
  final events = await repository.fetchEvents(asOf: now);
  return events.where((event) => now.isBefore(event.endAt.add(const Duration(hours: 12)))).toList()
    ..sort((a, b) => a.startAt.compareTo(b.startAt));
}

@riverpod
Future<Event?> eventById(Ref ref, String eventId) async {
  final events = await ref.watch(visibleEventsProvider.future);
  for (final event in events) {
    if (event.id == eventId) return event;
  }
  return null;
}

/// In-memory RSVP edits for one event's household rows, keyed by person.
/// Seeded from the event's own data, then locally overridden as the user
/// taps [RsvpToggle] — edits reset on app restart, same as
/// [TodaySelectedPerson] living purely in provider state. Absence of a key
/// means no `HouseholdRsvp`/`Event RSVP` row exists yet for that member —
/// a row is only created once they actually respond.
@riverpod
class EventRsvp extends _$EventRsvp {
  @override
  Future<Map<String, RsvpStatus>> build(String eventId) async {
    final event = await ref.watch(eventByIdProvider(eventId).future);
    return {for (final rsvp in event?.householdRsvps ?? const []) rsvp.memberId: rsvp.status};
  }

  /// Tapping the already-selected option clears the RSVP back to
  /// unanswered rather than re-selecting it — matches how a real RSVP
  /// toggle should behave (tap again to undo). "Unanswered" means no row
  /// at all, so that case removes the key instead of nulling it.
  void toggleStatus(String personKey, RsvpStatus status) {
    final current = {...(state.value ?? const {})};
    if (current[personKey] == status) {
      current.remove(personKey);
    } else {
      current[personKey] = status;
    }
    state = AsyncData(current);
  }
}
