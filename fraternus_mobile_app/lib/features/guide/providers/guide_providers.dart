import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/clock_provider.dart';
import '../../../app/supabase_provider.dart';
import '../../profile/models/member.dart';
import '../../profile/providers/profile_providers.dart';
import '../data/guide_repository.dart';
import '../models/field_guide_daily_devotional_member.dart';
import '../models/field_guide_week.dart';
import '../models/guide_household_member.dart';
import '../models/temperament.dart';
import 'temperament_quiz_providers.dart';

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
String? _householdChapterKey(List<Member> members) =>
    members.isEmpty ? null : members.first.chapterKey;

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
  return [
    for (final member in members)
      GuideHouseholdMember(memberId: member.id, label: member.firstName),
  ];
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
  return repository.fetchWeekForDate(
    date: date,
    chapterKey: chapterKey,
    memberIds: [for (final m in members) m.id],
  );
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// The single shared date for the whole Guide screen — switching it
/// applies to every household member, unlike the selected household member
/// (SelectedHouseholdMember, in shared/providers) which is a per-person
/// choice.
@riverpod
class GuideSelectedDate extends _$GuideSelectedDate {
  @override
  DateTime build() => _dateOnly(ref.watch(nowProvider));

  void select(DateTime date) => state = _dateOnly(date);
}

/// Per-person completion rows for one date. Seeded once from
/// [GuideRepository], then every mutation applies an optimistic update to
/// [state] directly — never `ref.invalidate(guideWeekForDateProvider)` —
/// so the UI reflects the change on the same frame, before the network
/// write resolves. Invalidating the upstream week provider would force it
/// (and everything watching it, including this provider's own `build`)
/// through a fresh fetch, which is what caused the old implementation's
/// screen flash/scroll-reset: a real network round trip standing between
/// the tap and any visible feedback, during which `.when()`'s `loading`
/// branches collapse the content. On write failure, the optimistic change
/// is rolled back.
@riverpod
class GuideDevotionalProgress extends _$GuideDevotionalProgress {
  @override
  Future<Map<String, FieldGuideDailyDevotionalMember>> build(
    DateTime date,
  ) async {
    final week = await ref.watch(guideWeekForDateProvider(date).future);
    final devotional = week?.devotionalForDate(date);
    return {
      for (final member in devotional?.members ?? const [])
        member.memberId: member,
    };
  }

  Future<void> setSword(String personKey, String swordText) async {
    final devotionalId = await _dailyDevotionalId();
    if (devotionalId == null) return;
    await _optimisticUpsert(
      personKey: personKey,
      devotionalId: devotionalId,
      apply: (member) => member.copyWith(sword: swordText),
      write: () => ref
          .read(guideRepositoryProvider)
          .upsertDevotionalMember(
            dailyDevotionalId: devotionalId,
            memberId: personKey,
            sword: swordText,
          ),
    );
  }

  /// Called with the field's current text when the user leaves it (not on
  /// every keystroke) — see JournalTextarea's `onFocusLost`.
  Future<void> setSpade(String personKey, String spadeText) async {
    final devotionalId = await _dailyDevotionalId();
    if (devotionalId == null) return;
    await _optimisticUpsert(
      personKey: personKey,
      devotionalId: devotionalId,
      apply: (member) => member.copyWith(spade: spadeText),
      write: () => ref
          .read(guideRepositoryProvider)
          .upsertDevotionalMember(
            dailyDevotionalId: devotionalId,
            memberId: personKey,
            spade: spadeText,
          ),
    );
  }

  /// Marks complete (now) if incomplete, or clears back to incomplete if
  /// already complete — same undo-friendly shape as
  /// ChallengeProgress.toggleRep.
  Future<void> toggleComplete(String personKey) async {
    final devotionalId = await _dailyDevotionalId();
    if (devotionalId == null) return;
    final wasCompleted =
        (state.value ?? const {})[personKey]?.isCompleted ?? false;
    await _optimisticUpsert(
      personKey: personKey,
      devotionalId: devotionalId,
      apply: (member) => member.copyWith(
        completedDate: wasCompleted ? null : DateTime.now(),
        clearCompleted: wasCompleted,
      ),
      write: () => ref
          .read(guideRepositoryProvider)
          .upsertDevotionalMember(
            dailyDevotionalId: devotionalId,
            memberId: personKey,
            completed: !wasCompleted,
          ),
    );
  }

  /// Favorites (or un-favorites) the Identity card, same undo-friendly
  /// shape as [toggleComplete].
  Future<void> toggleIdentityFavorite(String personKey) async {
    final devotionalId = await _dailyDevotionalId();
    if (devotionalId == null) return;
    final wasFavorite =
        (state.value ?? const {})[personKey]?.isIdentityFavorite ?? false;
    await _optimisticUpsert(
      personKey: personKey,
      devotionalId: devotionalId,
      apply: (member) => member.copyWith(isIdentityFavorite: !wasFavorite),
      write: () => ref
          .read(guideRepositoryProvider)
          .upsertDevotionalMember(
            dailyDevotionalId: devotionalId,
            memberId: personKey,
            isIdentityFavorite: !wasFavorite,
          ),
    );
  }

  /// Favorites (or un-favorites) the Wisdom for the Day card, same
  /// undo-friendly shape as [toggleComplete].
  Future<void> toggleWisdomFavorite(String personKey) async {
    final devotionalId = await _dailyDevotionalId();
    if (devotionalId == null) return;
    final wasFavorite =
        (state.value ?? const {})[personKey]?.isWisdomFavorite ?? false;
    await _optimisticUpsert(
      personKey: personKey,
      devotionalId: devotionalId,
      apply: (member) => member.copyWith(isWisdomFavorite: !wasFavorite),
      write: () => ref
          .read(guideRepositoryProvider)
          .upsertDevotionalMember(
            dailyDevotionalId: devotionalId,
            memberId: personKey,
            isWisdomFavorite: !wasFavorite,
          ),
    );
  }

  /// Applies [apply] to [personKey]'s row immediately (creating a
  /// placeholder row first if none exists yet), then runs [write] in the
  /// background and reconciles [state] with its authoritative result —
  /// or rolls back to the pre-optimistic value if [write] throws.
  Future<void> _optimisticUpsert({
    required String personKey,
    required String devotionalId,
    required FieldGuideDailyDevotionalMember Function(
      FieldGuideDailyDevotionalMember current,
    )
    apply,
    required Future<FieldGuideDailyDevotionalMember> Function() write,
  }) async {
    final previous =
        state.value ?? const <String, FieldGuideDailyDevotionalMember>{};
    final baseline =
        previous[personKey] ?? _placeholderMember(devotionalId, personKey);
    state = AsyncData({...previous, personKey: apply(baseline)});
    try {
      final saved = await write();
      state = AsyncData({...(state.value ?? previous), personKey: saved});
    } catch (_) {
      final rolledBack = {...(state.value ?? previous)};
      if (previous.containsKey(personKey)) {
        rolledBack[personKey] = previous[personKey]!;
      } else {
        rolledBack.remove(personKey);
      }
      state = AsyncData(rolledBack);
      rethrow;
    }
  }

  FieldGuideDailyDevotionalMember _placeholderMember(
    String devotionalId,
    String personKey,
  ) {
    final now = DateTime.now();
    return FieldGuideDailyDevotionalMember(
      id: 'optimistic-$devotionalId-$personKey',
      dailyDevotionalId: devotionalId,
      memberId: personKey,
      createdAt: now,
      lastModifiedAt: now,
    );
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
  return repository.fetchStreak(
    memberId: personKey,
    chapterKey: member.chapterKey,
    asOf: date,
  );
}

/// [personKey]'s saved Temperament Quiz result — null means they haven't
/// taken the quiz yet, in which case the UI renders the Find Your
/// Temperament button instead of Primary/Secondary tags. Backed by
/// `Member Temperament Result` (see docs/app_concept.md's Temperaments
/// domain section and supabase/migrations/20260821000000_temperaments.sql).
@riverpod
class GuideTemperamentResult extends _$GuideTemperamentResult {
  @override
  Future<TemperamentResult?> build(String personKey) {
    return ref.watch(temperamentQuizRepositoryProvider).fetchResult(personKey);
  }

  /// [answers] maps each answered question's id to the selected option's
  /// id — see [TemperamentQuizRepository.saveResult]. Applies [result]
  /// optimistically (same shape as GuideQuoteFavorites.toggle) so the
  /// results screen reflects it immediately, rather than waiting on the
  /// round trip.
  Future<void> save(
    TemperamentResult result,
    Map<String, String> answers,
  ) async {
    final previous = state;
    state = AsyncData(result);
    try {
      await ref
          .read(temperamentQuizRepositoryProvider)
          .saveResult(memberId: personKey, result: result, answers: answers);
    } catch (_) {
      state = previous;
      rethrow;
    }
  }
}

/// Per-quote favorite state for every household member on [date]'s week,
/// keyed by '$quoteId:$personKey'. Seeded from the quotes' nested
/// `field_guide_week_quotes_members` (see [FieldGuideWeekQuote.members]),
/// then optimistically updated by [toggle] — same
/// apply-immediately/rollback-on-failure shape as [GuideDevotionalProgress],
/// just without a placeholder-row step since a favorite always starts false.
@riverpod
class GuideQuoteFavorites extends _$GuideQuoteFavorites {
  @override
  Future<Map<String, bool>> build(DateTime date) async {
    final week = await ref.watch(guideWeekForDateProvider(date).future);
    return {
      for (final quote in week?.quotes ?? const [])
        for (final member in quote.members)
          '${quote.id}:${member.memberId}': member.isFavorite,
    };
  }

  bool isFavorite(String quoteId, String personKey) =>
      (state.value ?? const {})['$quoteId:$personKey'] ?? false;

  Future<void> toggle(String personKey, String quoteId) async {
    final key = '$quoteId:$personKey';
    final previous = state.value ?? const <String, bool>{};
    final wasFavorite = previous[key] ?? false;
    state = AsyncData({...previous, key: !wasFavorite});
    try {
      await ref
          .read(guideRepositoryProvider)
          .upsertQuoteMember(
            quoteId: quoteId,
            memberId: personKey,
            isFavorite: !wasFavorite,
          );
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}
