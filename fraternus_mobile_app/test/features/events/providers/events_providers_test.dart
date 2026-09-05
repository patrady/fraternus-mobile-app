import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/design_system/design_system.dart' show RsvpStatus;
import 'package:fraternus_mobile_app/features/events/data/events_repository.dart';
import 'package:fraternus_mobile_app/features/events/models/event.dart';
import 'package:fraternus_mobile_app/features/events/models/household_rsvp.dart';
import 'package:fraternus_mobile_app/features/events/providers/events_providers.dart';
import 'package:fraternus_mobile_app/features/profile/data/profile_repository.dart';
import 'package:fraternus_mobile_app/features/profile/providers/profile_providers.dart';

/// Wraps a real [StaticEventsRepository], letting [submitRsvp] be made to
/// fail on demand — StaticEventsRepository itself never fails, but
/// EventRsvp.toggleStatus's rollback branch needs something that does.
class _TestEventsRepository implements EventsRepository {
  _TestEventsRepository(this._inner);

  final StaticEventsRepository _inner;
  bool shouldFailSubmit = false;

  @override
  Future<List<Event>> fetchEvents({
    required DateTime asOf,
    required Map<String, String> memberLabels,
  }) => _inner.fetchEvents(asOf: asOf, memberLabels: memberLabels);

  @override
  Future<HouseholdRsvp?> submitRsvp({
    required String eventId,
    required String memberId,
    required RsvpStatus status,
  }) async {
    if (shouldFailSubmit) throw StateError('submitRsvp failed');
    return _inner.submitRsvp(eventId: eventId, memberId: memberId, status: status);
  }
}

void main() {
  group('visibleEvents', () {
    test('filters out events more than 12 hours past their end time', () async {
      final container = ProviderContainer(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(_TestEventsRepository(StaticEventsRepository())),
          profileRepositoryProvider.overrideWithValue(StaticProfileRepository()),
        ],
      );
      addTearDown(container.dispose);

      final events = await container.read(visibleEventsProvider.future);

      // captain-meeting ended 5 hours before "now" in the seed data, well
      // within the 12-hour visibility window, so it should still show.
      expect(events.any((e) => e.id == 'captain-meeting'), isTrue);
    });

    test('sorts by start date ascending', () async {
      final container = ProviderContainer(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(_TestEventsRepository(StaticEventsRepository())),
          profileRepositoryProvider.overrideWithValue(StaticProfileRepository()),
        ],
      );
      addTearDown(container.dispose);

      final events = await container.read(visibleEventsProvider.future);

      final startTimes = events.map((e) => e.startAt).toList();
      expect(startTimes, [...startTimes]..sort());
    });
  });

  group('EventTypeFilter', () {
    test('toggle adds and removes a type; clear empties it', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(eventTypeFilterProvider.notifier);

      notifier.toggle(EventType.fratNight);
      expect(container.read(eventTypeFilterProvider), {EventType.fratNight});

      notifier.toggle(EventType.excursion);
      expect(container.read(eventTypeFilterProvider), {EventType.fratNight, EventType.excursion});

      notifier.toggle(EventType.fratNight);
      expect(container.read(eventTypeFilterProvider), {EventType.excursion});

      notifier.clear();
      expect(container.read(eventTypeFilterProvider), isEmpty);
    });
  });

  group('eventById', () {
    test('resolves an event that is currently visible', () async {
      final container = ProviderContainer(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(_TestEventsRepository(StaticEventsRepository())),
          profileRepositoryProvider.overrideWithValue(StaticProfileRepository()),
        ],
      );
      addTearDown(container.dispose);

      final event = await container.read(eventByIdProvider('frat-night').future);

      expect(event?.id, 'frat-night');
    });

    test('returns null for an id that does not exist', () async {
      final container = ProviderContainer(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(_TestEventsRepository(StaticEventsRepository())),
          profileRepositoryProvider.overrideWithValue(StaticProfileRepository()),
        ],
      );
      addTearDown(container.dispose);

      final event = await container.read(eventByIdProvider('does-not-exist').future);

      expect(event, isNull);
    });
  });

  group('EventRsvp', () {
    test('build() reflects the event\'s existing household RSVPs', () async {
      final container = ProviderContainer(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(_TestEventsRepository(StaticEventsRepository())),
          profileRepositoryProvider.overrideWithValue(StaticProfileRepository()),
        ],
      );
      addTearDown(container.dispose);

      final rsvps = await container.read(eventRsvpProvider('captain-meeting').future);

      expect(rsvps['you'], RsvpStatus.yes);
    });

    test('toggleStatus applies optimistically and persists', () async {
      final container = ProviderContainer(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(_TestEventsRepository(StaticEventsRepository())),
          profileRepositoryProvider.overrideWithValue(StaticProfileRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(eventRsvpProvider('excursion-buffalo-river').future);
      await container
          .read(eventRsvpProvider('excursion-buffalo-river').notifier)
          .toggleStatus('you', RsvpStatus.yes);

      final state = container.read(eventRsvpProvider('excursion-buffalo-river')).value!;
      expect(state['you'], RsvpStatus.yes);
    });

    test('toggling the already-selected status clears it', () async {
      final container = ProviderContainer(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(_TestEventsRepository(StaticEventsRepository())),
          profileRepositoryProvider.overrideWithValue(StaticProfileRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(eventRsvpProvider('captain-meeting').future);
      await container
          .read(eventRsvpProvider('captain-meeting').notifier)
          .toggleStatus('you', RsvpStatus.yes);

      final state = container.read(eventRsvpProvider('captain-meeting')).value!;
      expect(state.containsKey('you'), isFalse);
    });

    test('a failed write rolls the optimistic update back and rethrows', () async {
      final repo = _TestEventsRepository(StaticEventsRepository());
      final container = ProviderContainer(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(repo),
          profileRepositoryProvider.overrideWithValue(StaticProfileRepository()),
        ],
      );
      addTearDown(container.dispose);

      final before = await container.read(eventRsvpProvider('excursion-buffalo-river').future);
      repo.shouldFailSubmit = true;

      await expectLater(
        container
            .read(eventRsvpProvider('excursion-buffalo-river').notifier)
            .toggleStatus('you', RsvpStatus.yes),
        throwsA(isA<StateError>()),
      );

      final after = container.read(eventRsvpProvider('excursion-buffalo-river')).value!;
      expect(after, before);
    });
  });
}
