import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/guide_repository.dart';
import '../models/field_guide_daily_devotional_member.dart';
import '../models/field_guide_week.dart';
import '../models/temperament.dart';

part 'guide_providers.g.dart';

@riverpod
GuideRepository guideRepository(Ref ref) {
  return const StaticGuideRepository();
}

/// [date] must already be truncated to year/month/day — see
/// [GuideSelectedDate] — since DateTime equality (Riverpod's family-arg
/// cache key) would otherwise cache-miss on time-of-day noise.
@riverpod
Future<FieldGuideWeek?> guideWeekForDate(Ref ref, DateTime date) async {
  final repository = ref.watch(guideRepositoryProvider);
  return repository.fetchWeekForDate(date: date);
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// The single shared date for the whole Guide screen — switching it
/// applies to every household member, unlike [GuideSelectedPerson] which
/// stays independent per feature (matching TodaySelectedPerson/
/// ChallengeSelectedPerson).
@riverpod
class GuideSelectedDate extends _$GuideSelectedDate {
  @override
  DateTime build() => _dateOnly(DateTime.now());

  void select(DateTime date) => state = _dateOnly(date);
}

/// Which household member's tab is active on the Guide tab — same shape
/// as TodaySelectedPerson/ChallengeSelectedPerson, kept independent per
/// feature by established convention.
@riverpod
class GuideSelectedPerson extends _$GuideSelectedPerson {
  @override
  String build() => 'you';

  void select(String key) => state = key;
}

/// In-memory sword/spade/completed edits for one date's per-person rows,
/// keyed by date. Seeded from the fetched week's devotional-for-that-date,
/// then locally overridden — edits reset on app restart, same as
/// ChallengeProgress/EventRsvp.
@riverpod
class GuideDevotionalProgress extends _$GuideDevotionalProgress {
  @override
  Future<Map<String, FieldGuideDailyDevotionalMember>> build(DateTime date) async {
    final week = await ref.watch(guideWeekForDateProvider(date).future);
    final devotional = week?.devotionalForDate(date);
    return {for (final member in devotional?.members ?? const []) member.personKey: member};
  }

  void setSword(String personKey, String swordText) {
    final current = state.value ?? const {};
    final existing = current[personKey];
    if (existing == null) return;
    state = AsyncData({...current, personKey: existing.copyWith(sword: swordText)});
  }

  void setSpade(String personKey, String spadeText) {
    final current = state.value ?? const {};
    final existing = current[personKey];
    if (existing == null) return;
    state = AsyncData({...current, personKey: existing.copyWith(spade: spadeText)});
  }

  /// Marks complete (now) if incomplete, or clears back to incomplete if
  /// already complete — same undo-friendly shape as
  /// ChallengeProgress.toggleRep.
  void toggleComplete(String personKey) {
    final current = state.value ?? const {};
    final existing = current[personKey];
    if (existing == null) return;
    final updated = existing.isCompleted
        ? existing.copyWith(clearCompleted: true)
        : existing.copyWith(completedDate: DateTime.now());
    state = AsyncData({...current, personKey: updated});
  }
}

/// Consecutive-day streak for [personKey] as of the currently selected
/// date, NOT counting the selected date itself — the screen adds +1 live
/// when that person's selected-date row is completed.
@riverpod
Future<int> guideBaseStreak(Ref ref, String personKey) async {
  final repository = ref.watch(guideRepositoryProvider);
  final date = ref.watch(guideSelectedDateProvider);
  return repository.fetchStreak(personKey: personKey, asOf: date);
}

/// Fake temperament-quiz-result seed — see models/temperament.dart. Only
/// 'you' has "taken the quiz" for now; everyone else renders the Find Your
/// Temperament button instead of Primary/Secondary tags, until [save] is
/// called with a freshly-scored result from TemperamentQuizScreen. In-memory
/// only, same as ChallengeProgress/EventRsvp — resets on app restart.
@riverpod
class GuideTemperamentResult extends _$GuideTemperamentResult {
  @override
  TemperamentResult? build(String personKey) {
    return switch (personKey) {
      'you' => const TemperamentResult(primaryKey: 'choleric', secondaryKey: 'melancholic'),
      _ => null,
    };
  }

  void save(TemperamentResult result) => state = result;
}

/// In-memory-only liked/favorited items (Identity, Wisdom, and quote
/// cards). Entries are composite '$personKey:$itemId' strings. Not
/// persisted — no favorite field exists anywhere in the Field Guide
/// schema, so this is a visual affordance only, resetting on restart.
@riverpod
class GuideLikedItems extends _$GuideLikedItems {
  @override
  Set<String> build() => {};

  void toggle(String personKey, String itemId) {
    final key = '$personKey:$itemId';
    state = state.contains(key) ? ({...state}..remove(key)) : {...state, key};
  }

  bool isLiked(String personKey, String itemId) => state.contains('$personKey:$itemId');
}
