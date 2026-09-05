import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/clock_provider.dart';
import '../../../app/router/route_paths.dart';
import '../../../design_system/design_system.dart';
import '../models/field_guide_daily_devotional.dart';
import '../models/field_guide_daily_devotional_member.dart';
import '../models/field_guide_week.dart';
import '../providers/guide_providers.dart';
import 'widgets/fraternus_date_picker.dart';
import 'widgets/guide_date_header.dart';
import 'widgets/sword_option_list.dart';

class GuideScreen extends ConsumerWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(guideSelectedDateProvider);
    final weekAsync = ref.watch(guideWeekForDateProvider(date));

    return ScreenShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Always visible, even with nothing to read, so the calendar
            // picker — the only way back to a valid date — stays reachable.
            GuideDateHeader(
              date: date,
              virtue: weekAsync.value?.devotionalForDate(date) != null
                  ? weekAsync.value!.virtue
                  : null,
              onCalendarTap: () async {
                final now = ref.read(nowProvider);
                final picked = await showFraternusDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: now.subtract(const Duration(days: 365)),
                  lastDate: now,
                );
                if (picked != null) {
                  ref.read(guideSelectedDateProvider.notifier).select(picked);
                }
              },
            ),
            const SizedBox(height: 20),
            weekAsync.when(
              data: (week) {
                final devotional = week?.devotionalForDate(date);
                if (week == null || devotional == null) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: BodyText('Nothing to read for this date yet.'),
                  );
                }
                return _GuideContent(
                  date: date,
                  week: week,
                  devotional: devotional,
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) =>
                  const BodyText('Something went wrong loading the Guide.'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideContent extends ConsumerWidget {
  const _GuideContent({
    required this.date,
    required this.week,
    required this.devotional,
  });

  final DateTime date;
  final FieldGuideWeek week;
  final FieldGuideDailyDevotional devotional;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedKey = ref.watch(guideSelectedPersonProvider);
    final householdAsync = ref.watch(guideHouseholdProvider);
    final progressAsync = ref.watch(guideDevotionalProgressProvider(date));
    final household = householdAsync.value ?? const [];
    // selectedKey defaults to the placeholder 'you' (see
    // GuideSelectedPerson), which won't match a real household member's
    // id — same reconciliation Challenge/Today do, so Sword/Spade/Mark
    // Complete don't try to write an invalid member id.
    final activeKey =
        household.isEmpty || household.any((m) => m.memberId == selectedKey)
        ? selectedKey
        : household.first.memberId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        householdAsync.when(
          data: (household) => progressAsync.when(
            data: (progressByPerson) => PersonTabs(
              people: [
                for (final member in household)
                  PersonTabItem(
                    key: member.memberId,
                    label: member.label,
                    status:
                        progressByPerson[member.memberId]?.isCompleted == true
                        ? PersonTabStatus.done
                        : PersonTabStatus.none,
                  ),
              ],
              activeKey: activeKey,
              onChanged: (key) =>
                  ref.read(guideSelectedPersonProvider.notifier).select(key),
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),
        progressAsync.when(
          data: (progressByPerson) => _DailyCards(
            devotional: devotional,
            member: progressByPerson[activeKey],
            personKey: activeKey,
            date: date,
            virtue: week.virtue,
          ),
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _DailyCards extends ConsumerStatefulWidget {
  const _DailyCards({
    required this.devotional,
    required this.member,
    required this.personKey,
    required this.date,
    required this.virtue,
  });

  final FieldGuideDailyDevotional devotional;
  final FieldGuideDailyDevotionalMember? member;
  final String personKey;
  final DateTime date;
  final String virtue;

  @override
  ConsumerState<_DailyCards> createState() => _DailyCardsState();
}

class _DailyCardsState extends ConsumerState<_DailyCards> {
  late final TextEditingController _spadeController;

  @override
  void initState() {
    super.initState();
    _spadeController = TextEditingController(text: widget.member?.spade ?? '');
  }

  @override
  void didUpdateWidget(covariant _DailyCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.personKey != widget.personKey) {
      // The field never lost focus (switching person tabs doesn't blur it)
      // — flush any unsaved edit for the outgoing person before swapping
      // the controller's text out from under them, so it isn't silently
      // discarded.
      _flushSpadeIfDirty(
        personKey: oldWidget.personKey,
        savedSpade: oldWidget.member?.spade,
      );
      _spadeController.text = widget.member?.spade ?? '';
    }
  }

  @override
  void dispose() {
    // Same reasoning as didUpdateWidget above — leaving the screen entirely
    // (e.g. switching bottom-nav tabs) doesn't necessarily blur the field
    // either.
    _flushSpadeIfDirty(
      personKey: widget.personKey,
      savedSpade: widget.member?.spade,
    );
    _spadeController.dispose();
    super.dispose();
  }

  void _flushSpadeIfDirty({
    required String personKey,
    required String? savedSpade,
  }) {
    final currentText = _spadeController.text;
    if (currentText != (savedSpade ?? '')) {
      ref
          .read(guideDevotionalProgressProvider(widget.date).notifier)
          .setSpade(personKey, currentText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final devotional = widget.devotional;
    final member = widget.member;
    final personKey = widget.personKey;
    final isCompleted = member?.isCompleted == true;
    final notifier = ref.read(
      guideDevotionalProgressProvider(widget.date).notifier,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreakBannerRow(personKey: personKey, isCompletedToday: isCompleted),
        ContentCard(
          eyebrow: 'Identity',
          onLike: () => notifier.toggleIdentityFavorite(personKey),
          liked: member?.isIdentityFavorite ?? false,
          child: Text(
            devotional.identityReading,
            style: FraternusTypography.body(color: FraternusColors.ink),
          ),
        ),
        ContentCard(
          eyebrow: 'Wisdom for the Day',
          onLike: () => notifier.toggleWisdomFavorite(personKey),
          liked: member?.isWisdomFavorite ?? false,
          subtitle: devotional.wisdomQuote,
          child: Text(
            '— ${devotional.wisdomAuthor}',
            style: FraternusTypography.body(
              color: FraternusColors.accentPrimary,
            ).copyWith(fontSize: 13),
          ),
        ),
        ContentCard(
          eyebrow: 'My Sword',
          subtitle:
              'Where will the battle find me today? Choose which one will be harder for you',
          child: SwordOptionList(
            options: devotional.swordOptions,
            selected: member?.sword,
            onSelect: (text) => notifier.setSword(personKey, text),
          ),
        ),
        ContentCard(
          eyebrow: 'My Spade',
          subtitle: devotional.spadePrompt,
          child: JournalTextarea(
            controller: _spadeController,
            placeholder: 'Write your answer...',
            onFocusLost: (text) => notifier.setSpade(personKey, text),
          ),
        ),
        ContentCard(
          eyebrow: 'Evening Seal',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                devotional.closingPrayer,
                style: FraternusTypography.body(
                  color: FraternusColors.ink,
                ).copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 4),
              Text(
                '— ${devotional.closingPrayerAuthor}',
                style: FraternusTypography.body(
                  color: FraternusColors.accentPrimary,
                ).copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Button(
          label: isCompleted ? '✓ Completed' : 'Mark Complete',
          color: isCompleted ? ButtonColor.success : ButtonColor.primary,
          fullWidth: true,
          onPressed: () => notifier.toggleComplete(personKey),
        ),
        const SizedBox(height: 12),
        Button(
          label: 'More about ${widget.virtue}',
          variant: ButtonVariant.ghost,
          icon: 'book-open',
          fullWidth: true,
          onPressed: () => context.push(RoutePaths.guideVirtue),
        ),
      ],
    );
  }
}

/// Base streak (excludes today) + live +1 the moment today's row is
/// completed — kept as its own small ConsumerWidget so only the streak
/// number rebuilds off the (separate) base-streak provider. Hidden entirely
/// (no banner, no reserved space) unless the resulting streak is at least 1
/// — a "0 Day Streak" banner isn't useful to show.
class StreakBannerRow extends ConsumerWidget {
  const StreakBannerRow({
    super.key,
    required this.personKey,
    required this.isCompletedToday,
  });

  final String personKey;
  final bool isCompletedToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseStreakAsync = ref.watch(guideBaseStreakProvider(personKey));
    return baseStreakAsync.when(
      data: (baseStreak) {
        final streak = baseStreak + (isCompletedToday ? 1 : 0);
        if (streak <= 0) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SizedBox(
            width: double.infinity,
            child: StreakBanner(count: streak),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
