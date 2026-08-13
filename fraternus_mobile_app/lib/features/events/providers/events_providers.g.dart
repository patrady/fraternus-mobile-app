// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Swap this provider's implementation to change where Events' data comes
/// from — nothing downstream needs to change.

@ProviderFor(eventsRepository)
const eventsRepositoryProvider = EventsRepositoryProvider._();

/// Swap this provider's implementation to change where Events' data comes
/// from — nothing downstream needs to change.

final class EventsRepositoryProvider
    extends
        $FunctionalProvider<
          EventsRepository,
          EventsRepository,
          EventsRepository
        >
    with $Provider<EventsRepository> {
  /// Swap this provider's implementation to change where Events' data comes
  /// from — nothing downstream needs to change.
  const EventsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventsRepositoryHash();

  @$internal
  @override
  $ProviderElement<EventsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EventsRepository create(Ref ref) {
    return eventsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventsRepository>(value),
    );
  }
}

String _$eventsRepositoryHash() => r'48397ba7c2508402834d1f9d899469586d49fe48';

/// Events sorted by start date ascending, filtered to those still within
/// 12 hours of their end — a business rule, so it lives here rather than in
/// the repository or the model.

@ProviderFor(visibleEvents)
const visibleEventsProvider = VisibleEventsProvider._();

/// Events sorted by start date ascending, filtered to those still within
/// 12 hours of their end — a business rule, so it lives here rather than in
/// the repository or the model.

final class VisibleEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Event>>,
          List<Event>,
          FutureOr<List<Event>>
        >
    with $FutureModifier<List<Event>>, $FutureProvider<List<Event>> {
  /// Events sorted by start date ascending, filtered to those still within
  /// 12 hours of their end — a business rule, so it lives here rather than in
  /// the repository or the model.
  const VisibleEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visibleEventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visibleEventsHash();

  @$internal
  @override
  $FutureProviderElement<List<Event>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Event>> create(Ref ref) {
    return visibleEvents(ref);
  }
}

String _$visibleEventsHash() => r'e1c508f93b75df2f7df3dceb24667126d8af571c';

@ProviderFor(eventById)
const eventByIdProvider = EventByIdFamily._();

final class EventByIdProvider
    extends $FunctionalProvider<AsyncValue<Event?>, Event?, FutureOr<Event?>>
    with $FutureModifier<Event?>, $FutureProvider<Event?> {
  const EventByIdProvider._({
    required EventByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventByIdHash();

  @override
  String toString() {
    return r'eventByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Event?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Event?> create(Ref ref) {
    final argument = this.argument as String;
    return eventById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventByIdHash() => r'1f2e58e2636fa9741fef7014ed7e024a5601c754';

final class EventByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Event?>, String> {
  const EventByIdFamily._()
    : super(
        retry: null,
        name: r'eventByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventByIdProvider call(String eventId) =>
      EventByIdProvider._(argument: eventId, from: this);

  @override
  String toString() => r'eventByIdProvider';
}

/// In-memory RSVP edits for one event's household rows, keyed by person.
/// Seeded from the event's own data, then locally overridden as the user
/// taps [RsvpToggle] — edits reset on app restart, same as
/// [TodaySelectedPerson] living purely in provider state. Absence of a key
/// means no `HouseholdRsvp`/`Event RSVP` row exists yet for that member —
/// a row is only created once they actually respond.

@ProviderFor(EventRsvp)
const eventRsvpProvider = EventRsvpFamily._();

/// In-memory RSVP edits for one event's household rows, keyed by person.
/// Seeded from the event's own data, then locally overridden as the user
/// taps [RsvpToggle] — edits reset on app restart, same as
/// [TodaySelectedPerson] living purely in provider state. Absence of a key
/// means no `HouseholdRsvp`/`Event RSVP` row exists yet for that member —
/// a row is only created once they actually respond.
final class EventRsvpProvider
    extends $AsyncNotifierProvider<EventRsvp, Map<String, RsvpStatus>> {
  /// In-memory RSVP edits for one event's household rows, keyed by person.
  /// Seeded from the event's own data, then locally overridden as the user
  /// taps [RsvpToggle] — edits reset on app restart, same as
  /// [TodaySelectedPerson] living purely in provider state. Absence of a key
  /// means no `HouseholdRsvp`/`Event RSVP` row exists yet for that member —
  /// a row is only created once they actually respond.
  const EventRsvpProvider._({
    required EventRsvpFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventRsvpProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventRsvpHash();

  @override
  String toString() {
    return r'eventRsvpProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventRsvp create() => EventRsvp();

  @override
  bool operator ==(Object other) {
    return other is EventRsvpProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventRsvpHash() => r'31d74661e5b5d0f85f91e98eda1d9febb99b7418';

/// In-memory RSVP edits for one event's household rows, keyed by person.
/// Seeded from the event's own data, then locally overridden as the user
/// taps [RsvpToggle] — edits reset on app restart, same as
/// [TodaySelectedPerson] living purely in provider state. Absence of a key
/// means no `HouseholdRsvp`/`Event RSVP` row exists yet for that member —
/// a row is only created once they actually respond.

final class EventRsvpFamily extends $Family
    with
        $ClassFamilyOverride<
          EventRsvp,
          AsyncValue<Map<String, RsvpStatus>>,
          Map<String, RsvpStatus>,
          FutureOr<Map<String, RsvpStatus>>,
          String
        > {
  const EventRsvpFamily._()
    : super(
        retry: null,
        name: r'eventRsvpProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// In-memory RSVP edits for one event's household rows, keyed by person.
  /// Seeded from the event's own data, then locally overridden as the user
  /// taps [RsvpToggle] — edits reset on app restart, same as
  /// [TodaySelectedPerson] living purely in provider state. Absence of a key
  /// means no `HouseholdRsvp`/`Event RSVP` row exists yet for that member —
  /// a row is only created once they actually respond.

  EventRsvpProvider call(String eventId) =>
      EventRsvpProvider._(argument: eventId, from: this);

  @override
  String toString() => r'eventRsvpProvider';
}

/// In-memory RSVP edits for one event's household rows, keyed by person.
/// Seeded from the event's own data, then locally overridden as the user
/// taps [RsvpToggle] — edits reset on app restart, same as
/// [TodaySelectedPerson] living purely in provider state. Absence of a key
/// means no `HouseholdRsvp`/`Event RSVP` row exists yet for that member —
/// a row is only created once they actually respond.

abstract class _$EventRsvp extends $AsyncNotifier<Map<String, RsvpStatus>> {
  late final _$args = ref.$arg as String;
  String get eventId => _$args;

  FutureOr<Map<String, RsvpStatus>> build(String eventId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<String, RsvpStatus>>,
              Map<String, RsvpStatus>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, RsvpStatus>>,
                Map<String, RsvpStatus>
              >,
              AsyncValue<Map<String, RsvpStatus>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
