import 'package:flutter/widgets.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../design_system/design_system.dart';
import '../../../shared/providers/selected_household_member_provider.dart';
import '../../../shared/widgets/error_snackbar.dart';
import '../models/field_guide_week.dart';
import '../models/temperament.dart';
import '../providers/guide_providers.dart';
import 'widgets/temperament_card.dart';

/// Pushed from Guide's "More about [virtue]" button. Re-reads the shared
/// selected date/week itself rather than taking a route param — Guide only
/// ever has one "current" week in view, unlike EventDetailScreen's
/// per-event `:eventId`.
class VirtueDetailScreen extends ConsumerWidget {
  const VirtueDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(guideSelectedDateProvider);
    final weekAsync = ref.watch(guideWeekForDateProvider(date));

    return ScreenShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'Guide', onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: weekAsync.when(
              data: (week) => week == null
                  ? const BodyText('Nothing to show for this date yet.')
                  : _VirtueDetailContent(date: date, week: week),
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) =>
                  const BodyText('Something went wrong loading this virtue.'),
            ),
          ),
        ],
      ),
    );
  }
}

class _VirtueDetailContent extends ConsumerWidget {
  const _VirtueDetailContent({required this.date, required this.week});

  final DateTime date;
  final FieldGuideWeek week;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedKey = ref.watch(selectedHouseholdMemberProvider);
    final quoteFavorites =
        ref.watch(guideQuoteFavoritesProvider(date)).value ?? const {};
    final quoteFavoritesNotifier = ref.read(
      guideQuoteFavoritesProvider(date).notifier,
    );
    final temperamentResult = ref
        .watch(guideTemperamentResultProvider(selectedKey))
        .value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Heading(week.virtue.toUpperCase(), level: HeadingLevel.h2),
        const SizedBox(height: 4),
        Text(
          'Vice: ${week.vice} | Extreme: ${week.extreme}',
          style: FraternusTypography.body(
            color: FraternusColors.textOnLightMuted,
          ),
        ),
        const SizedBox(height: 20),
        for (final quote in week.quotes)
          ContentCard(
            subtitle: quote.quote,
            onLike: () async {
              try {
                await quoteFavoritesNotifier.toggle(selectedKey, quote.id);
              } catch (_) {
                if (context.mounted) {
                  showErrorSnackBar(
                    context,
                    'Something went wrong. Please try again.',
                  );
                }
              }
            },
            liked: quoteFavorites['${quote.id}:$selectedKey'] ?? false,
            child: Text(
              '— ${quote.author}',
              style: FraternusTypography.body(
                color: FraternusColors.accentPrimary,
              ).copyWith(fontSize: 13),
            ),
          ),
        ContentCard(
          eyebrow: 'Reflection',
          child: MarkdownBody(data: week.reflection),
        ),
        const SizedBox(height: 8),
        const Heading('THE TEMPERAMENTS', level: HeadingLevel.h3),
        const SizedBox(height: 14),
        if (temperamentResult == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Button(
              label: 'Find Your Temperament',
              fullWidth: true,
              onPressed: () =>
                  context.push(RoutePaths.temperamentQuiz(selectedKey)),
            ),
          ),
        for (final key in temperamentOrder)
          TemperamentCard(
            name: temperamentDisplayNames[key]!,
            application: week.applicationFor(key),
            vices: week.vicesFor(key),
            tagLabel: temperamentResult == null
                ? null
                : key == temperamentResult.primaryKey
                ? 'Primary'
                : key == temperamentResult.secondaryKey
                ? 'Secondary'
                : null,
            onTap: () => context.push(RoutePaths.guideTemperament(key)),
          ),
      ],
    );
  }
}
