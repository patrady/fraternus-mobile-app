import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/supabase_provider.dart';
import '../../profile/models/member.dart';
import '../../profile/providers/profile_providers.dart';
import '../data/guide_repository.dart';
import '../models/field_guide_daily_devotional_member.dart';
import '../models/field_guide_week.dart';
import '../models/guide_household_member.dart';
import '../models/temperament.dart';

part 'guide_providers.g.dart';

@riverpod
GuideRepository guideRepository(Ref ref) {
  return SupabaseGuideRepository(ref.watch(supabaseClientProvider));
}

/// Every household Member's own chapter should in practice be the same one
/// (app_concept.md doesn't describe a multi-chapter-household UI), so the
/// first household member's chapter stands in for "the household's
/// chapter" when resolving shared Field Guide content. Returns null for an
/// empty household (no data to show either way).
String? _householdChapterKey(List<Member> members) => members.isEmpty ? null : members.first.chapterKey;

Member? _memberById(List<Member> members, String memberId) {
  for (final member in members) {
    if (member.id == memberId) return member;
  }
  return null;
}

/// The current user's household, for the Guide tab's person tabs — same
/// shape and reasoning as Challenge's `challengeHouseholdProvider`.
@riverpod
Future<List<GuideHouseholdMember>> guideHousehold(Ref ref) async {
  final members = await ref.watch(householdMembersProvider.future);
  return [for (final member in members) GuideHouseholdMember(memberId: member.id, label: member.firstName)];
}

/// [date] must already be truncated to year/month/day — see
/// [GuideSelectedDate] — since DateTime equality (Riverpod's family-arg
/// cache key) would otherwise cache-miss on time-of-day noise.
@riverpod
Future<FieldGuideWeek?> guideWeekForDate(Ref ref, DateTime date) async {
  final repository = ref.watch(guideRepositoryProvider);
  final members = await ref.watch(householdMembersProvider.future);
  final chapterKey = _householdChapterKey(members);
  if (chapterKey == null) return null;
  return repository.fetchWeekForDate(date: date, chapterKey: chapterKey, memberIds: [for (final m in members) m.id]);
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

/// Per-person completion rows for one date, read straight through from
/// [GuideRepository] — no local edit buffer. Every mutation method here
/// calls the repository (a real write against Supabase, or a mutation of
/// StaticGuideRepository's in-memory map in tests) and then invalidates
/// this provider so the UI reflects whatever the repository now reports,
/// rather than optimistically guessing at the new state itself.
@riverpod
class GuideDevotionalProgress extends _$GuideDevotionalProgress {
  @override
  Future<Map<String, FieldGuideDailyDevotionalMember>> build(DateTime date) async {
    final week = await ref.watch(guideWeekForDateProvider(date).future);
    final devotional = week?.devotionalForDate(date);
    return {for (final member in devotional?.members ?? const []) member.memberId: member};
  }

  Future<void> setSword(String personKey, String swordText) async {
    final devotionalId = await _dailyDevotionalId();
    if (devotionalId == null) return;
    await ref.read(guideRepositoryProvider).upsertDevotionalMember(
      dailyDevotionalId: devotionalId,
      memberId: personKey,
      sword: swordText,
    );
    // Invalidating guideWeekForDateProvider — not just this notifier — is
    // what actually surfaces the write: build() derives its data from that
    // provider's cached result, which a bare invalidateSelf() wouldn't
    // touch (nothing about `date` or the household changed, so it'd stay
    // cached and this notifier would just re-read the same stale value).
    ref.invalidate(guideWeekForDateProvider(date));
  }

  Future<void> setSpade(String personKey, String spadeText) async {
    final devotionalId = await _dailyDevotionalId();
    if (devotionalId == null) return;
    await ref.read(guideRepositoryProvider).upsertDevotionalMember(
      dailyDevotionalId: devotionalId,
      memberId: personKey,
      spade: spadeText,
    );
    // Invalidating guideWeekForDateProvider — not just this notifier — is
    // what actually surfaces the write: build() derives its data from that
    // provider's cached result, which a bare invalidateSelf() wouldn't
    // touch (nothing about `date` or the household changed, so it'd stay
    // cached and this notifier would just re-read the same stale value).
    ref.invalidate(guideWeekForDateProvider(date));
  }

  /// Marks complete (now) if incomplete, or clears back to incomplete if
  /// already complete — same undo-friendly shape as
  /// ChallengeProgress.toggleRep.
  Future<void> toggleComplete(String personKey) async {
    final devotionalId = await _dailyDevotionalId();
    if (devotionalId == null) return;
    final current = state.value ?? const {};
    final wasCompleted = current[personKey]?.isCompleted ?? false;
    await ref.read(guideRepositoryProvider).upsertDevotionalMember(
      dailyDevotionalId: devotionalId,
      memberId: personKey,
      completed: !wasCompleted,
    );
    // Invalidating guideWeekForDateProvider — not just this notifier — is
    // what actually surfaces the write: build() derives its data from that
    // provider's cached result, which a bare invalidateSelf() wouldn't
    // touch (nothing about `date` or the household changed, so it'd stay
    // cached and this notifier would just re-read the same stale value).
    ref.invalidate(guideWeekForDateProvider(date));
  }

  Future<String?> _dailyDevotionalId() async {
    final week = await ref.read(guideWeekForDateProvider(date).future);
    return week?.devotionalForDate(date)?.id;
  }
}

/// Consecutive-day streak for [personKey] as of the currently selected
/// date, NOT counting the selected date itself — the screen adds +1 live
/// when that person's selected-date row is completed.
@riverpod
Future<int> guideBaseStreak(Ref ref, String personKey) async {
  final repository = ref.watch(guideRepositoryProvider);
  final date = ref.watch(guideSelectedDateProvider);
  final members = await ref.watch(householdMembersProvider.future);
  final member = _memberById(members, personKey);
  if (member == null) return 0;
  return repository.fetchStreak(memberId: personKey, chapterKey: member.chapterKey, asOf: date);
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
