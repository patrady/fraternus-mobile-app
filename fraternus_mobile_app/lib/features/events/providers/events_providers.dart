import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/clock_provider.dart';
import '../../../app/supabase_provider.dart';
import '../../../design_system/design_system.dart' show RsvpStatus;
import '../../profile/providers/profile_providers.dart';
import '../data/events_repository.dart';
import '../models/event.dart';

part 'events_providers.g.dart';

/// Swap this provider's implementation to change where Events' data comes
/// from — nothing downstream needs to change.
@riverpod
EventsRepository eventsRepository(Ref ref) {
  return SupabaseEventsRepository(ref.watch(supabaseClientProvider));
}

/// Events sorted by start date ascending, filtered to those still within
/// 12 hours of their end — a business rule, so it lives here rather than in
/// the repository or the model.
@riverpod
Future<List<Event>> visibleEvents(Ref ref) async {
  final repository = ref.watch(eventsRepositoryProvider);
  final members = await ref.watch(householdMembersProvider.future);
  final now = ref.watch(nowProvider);
  final events = await repository.fetchEvents(
    asOf: now,
    memberLabels: {for (final member in members) member.id: member.firstName},
  );
  return events
      .where(
        (event) => now.isBefore(event.endAt.add(const Duration(hours: 12))),
      )
      .toList()
    ..sort((a, b) => a.startAt.compareTo(b.startAt));
}

/// Which [EventType]s the Events list is filtered to — empty means "show
/// everything," matching how the filter button reads with nothing toggled
/// on. Purely local UI state, not persisted.
@riverpod
class EventTypeFilter extends _$EventTypeFilter {
  @override
  Set<EventType> build() => const {};

  void toggle(EventType type) {
    state = state.contains(type)
        ? ({...state}..remove(type))
        : {...state, type};
  }

  void clear() => state = const {};
}

@riverpod
Future<Event?> eventById(Ref ref, String eventId) async {
  final events = await ref.watch(visibleEventsProvider.future);
  for (final event in events) {
    if (event.id == eventId) return event;
  }
  return null;
}

/// Per-event household RSVP state, read straight through from
/// [EventsRepository] — no local edit buffer, same reasoning as
/// ChallengeProgress. Absence of a key means no `HouseholdRsvp`/`Event
/// RSVP` row exists yet for that member — a row is only created once they
/// actually respond.
@riverpod
class EventRsvp extends _$EventRsvp {
  @override
  Future<Map<String, RsvpStatus>> build(String eventId) async {
    final event = await ref.watch(eventByIdProvider(eventId).future);
    return {
      for (final rsvp in event?.householdRsvps ?? const [])
        rsvp.memberId: rsvp.status,
    };
  }

  /// Tapping the already-selected option clears the RSVP back to
  /// unanswered rather than re-selecting it — matches how a real RSVP
  /// toggle should behave (tap again to undo); the repository's
  /// submitRsvp implements that toggle-to-delete semantics.
  ///
  /// Updates [state] optimistically so the toggle flips instantly instead
  /// of waiting on the round trip, rolling back on failure. Still
  /// invalidates [visibleEventsProvider] afterwards so [Event.householdRsvps]
  /// doesn't go stale in the cache the Events list screen keeps alive — but
  /// only once the write has already landed, so the resulting reload
  /// resolves to the same data this state already shows (paired with
  /// `skipLoadingOnReload: true` in the screen's `.when()`, that reload is
  /// invisible rather than a blank-then-repaint flash).
  Future<void> toggleStatus(String personKey, RsvpStatus status) async {
    final previous = state;
    final current = <String, RsvpStatus>{...?state.value};
    if (current[personKey] == status) {
      current.remove(personKey);
    } else {
      current[personKey] = status;
    }
    state = AsyncData(current);

    try {
      await ref
          .read(eventsRepositoryProvider)
          .submitRsvp(eventId: eventId, memberId: personKey, status: status);
    } catch (_) {
      state = previous;
      rethrow;
    }
    ref.invalidate(visibleEventsProvider);
  }
}
