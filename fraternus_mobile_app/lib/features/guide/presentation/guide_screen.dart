import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../design_system/design_system.dart';
import '../models/field_guide_daily_devotional.dart';
import '../models/field_guide_daily_devotional_member.dart';
import '../models/field_guide_week.dart';
import '../providers/guide_providers.dart';
import 'widgets/fraternus_date_picker.dart';
import 'widgets/guide_date_header.dart';
import 'widgets/sword_option_list.dart';

/// Labels for the fixed you/jack/thomas household, hardcoded per-feature —
/// same established (if duplicated) pattern as Today/Challenge, which
/// don't share a household-members provider either.
const _personLabels = {'you': 'You', 'jack': 'Jack', 'thomas': 'Thomas'};

bool _isLiked(Set<String> likedItems, String personKey, String itemId) =>
    likedItems.contains('$personKey:$itemId');

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
              virtue: weekAsync.value?.devotionalForDate(date) != null ? weekAsync.value!.virtue : null,
              onCalendarTap: () async {
                final picked = await showFraternusDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
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
                return _GuideContent(date: date, week: week, devotional: devotional);
              },
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) => const BodyText('Something went wrong loading the Guide.'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideContent extends ConsumerWidget {
  const _GuideContent({required this.date, required this.week, required this.devotional});

  final DateTime date;
  final FieldGuideWeek week;
  final FieldGuideDailyDevotional devotional;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedKey = ref.watch(guideSelectedPersonProvider);
    final progressAsync = ref.watch(guideDevotionalProgressProvider(date));
    final likedItems = ref.watch(guideLikedItemsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        progressAsync.when(
          data: (progressByPerson) => PersonTabs(
            people: [
              for (final member in devotional.members)
                PersonTabItem(
                  key: member.memberId,
                  label: _personLabels[member.memberId] ?? member.memberId,
                  status: progressByPerson[member.memberId]?.isCompleted == true
                      ? PersonTabStatus.done
                      : PersonTabStatus.none,
                ),
            ],
            activeKey: selectedKey,
            onChanged: (key) => ref.read(guideSelectedPersonProvider.notifier).select(key),
          ),
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),
        progressAsync.when(
          data: (progressByPerson) => _DailyCards(
            devotional: devotional,
            member: progressByPerson[selectedKey],
            personKey: selectedKey,
            date: date,
            virtue: week.virtue,
            likedItems: likedItems,
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
    required this.likedItems,
  });

  final FieldGuideDailyDevotional devotional;
  final FieldGuideDailyDevotionalMember? member;
  final String personKey;
  final DateTime date;
  final String virtue;
  final Set<String> likedItems;

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
      _spadeController.text = widget.member?.spade ?? '';
    }
  }

  @override
  void dispose() {
    _spadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devotional = widget.devotional;
    final member = widget.member;
    final personKey = widget.personKey;
    final isCompleted = member?.isCompleted == true;
    final notifier = ref.read(guideDevotionalProgressProvider(widget.date).notifier);
    final likedNotifier = ref.read(guideLikedItemsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreakBannerRow(personKey: personKey, isCompletedToday: isCompleted),
        const SizedBox(height: 16),
        ContentCard(
          eyebrow: 'Identity',
          onLike: () => likedNotifier.toggle(personKey, 'identity-${devotional.id}'),
          liked: _isLiked(widget.likedItems, personKey, 'identity-${devotional.id}'),
          child: Text(devotional.identityReading, style: FraternusTypography.body(color: FraternusColors.ink)),
        ),
        ContentCard(
          eyebrow: 'Wisdom for the Day',
          onLike: () => likedNotifier.toggle(personKey, 'wisdom-${devotional.id}'),
          liked: _isLiked(widget.likedItems, personKey, 'wisdom-${devotional.id}'),
          subtitle: devotional.wisdomQuote,
          child: Text(
            '— ${devotional.wisdomAuthor}',
            style: FraternusTypography.body(color: FraternusColors.accentPrimary).copyWith(fontSize: 13),
          ),
        ),
        ContentCard(
          eyebrow: 'My Sword',
          subtitle: 'Where will the battle find me today? Choose which one will be harder for you',
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
            onChanged: (text) => notifier.setSpade(personKey, text),
          ),
        ),
        ContentCard(
          eyebrow: 'Evening Seal',
          child: Text(
            devotional.closingPrayer,
            style: FraternusTypography.body(color: FraternusColors.ink).copyWith(fontStyle: FontStyle.italic),
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
/// number rebuilds off the (separate) base-streak provider.
class StreakBannerRow extends ConsumerWidget {
  const StreakBannerRow({super.key, required this.personKey, required this.isCompletedToday});

  final String personKey;
  final bool isCompletedToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseStreakAsync = ref.watch(guideBaseStreakProvider(personKey));
    return baseStreakAsync.when(
      data: (baseStreak) => SizedBox(
        width: double.infinity,
        child: StreakBanner(count: baseStreak + (isCompletedToday ? 1 : 0)),
      ),
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
