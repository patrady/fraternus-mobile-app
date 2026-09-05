import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../../shared/formatting/ordinal_date_formatting.dart';
import '../../../shared/providers/selected_household_member_provider.dart';
import '../../../shared/widgets/error_snackbar.dart';
import '../models/weekly_challenge.dart';
import '../providers/challenge_providers.dart';

class PastChallengesScreen extends ConsumerWidget {
  const PastChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedKey = ref.watch(selectedHouseholdMemberProvider);
    final household = ref.watch(challengeHouseholdProvider).value ?? const [];
    // selectedKey defaults to the placeholder 'you' (see
    // SelectedHouseholdMember), which won't match a real household member's
    // id — same reconciliation ChallengeScreen's activeKey does.
    final personKey =
        household.isEmpty || household.any((m) => m.memberId == selectedKey)
        ? selectedKey
        : household.first.memberId;
    final challengesAsync = ref.watch(pastChallengesProvider);

    return ScreenShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'Past Challenges', onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: challengesAsync.when(
              data: (challenges) => _PastChallengesList(
                challenges: challenges,
                personKey: personKey,
              ),
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) => const BodyText(
                'Something went wrong loading past challenges.',
              ),
              skipLoadingOnReload: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _PastChallengesList extends ConsumerWidget {
  const _PastChallengesList({
    required this.challenges,
    required this.personKey,
  });

  final List<WeeklyChallenge> challenges;
  final String personKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final household = ref.watch(challengeHouseholdProvider).value ?? const [];
    String? personLabel;
    for (final member in household) {
      if (member.memberId == personKey) {
        personLabel = member.label;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (personLabel != null) ...[
          const SizedBox(height: 4),
          Text(
            personLabel,
            style: FraternusTypography.body(
              color: FraternusColors.accentPrimary,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
        ],
        const SizedBox(height: 20),
        if (challenges.isEmpty)
          const BodyText('No past challenges yet.')
        else
          for (var i = 0; i < challenges.length; i++) ...[
            _PastChallengeCard(challenge: challenges[i], personKey: personKey),
            if (i != challenges.length - 1) const SizedBox(height: 12),
          ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _PastChallengeCard extends ConsumerWidget {
  const _PastChallengeCard({required this.challenge, required this.personKey});

  final WeeklyChallenge challenge;
  final String personKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(challengeProgressProvider(challenge.id));

    return progressAsync.when(
      data: (progressByPerson) {
        final progress = progressByPerson[personKey];
        if (progress == null) return const SizedBox.shrink();

        return Box(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: FraternusTypography.h4(
                            color: FraternusColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Week of ${formatOrdinalDate(challenge.fratNightDate)}',
                          style: FraternusTypography.small(
                            color: FraternusColors.textOnLightMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FraternusIcon(
                    name: progress.isCompleted
                        ? 'circle-check'
                        : 'circle-dashed',
                    size: 18,
                    tone: progress.isCompleted
                        ? FraternusIconTone.success
                        : FraternusIconTone.terracotta,
                  ),
                ],
              ),
              RepDots(
                reps: challenge.repsTotal,
                doneCount: progress.repsDone,
                editable: true,
                // Any tap toggles the boundary rep (the next incomplete one,
                // or — if tapping inside the already-filled dots — the most
                // recently completed one) so the doneCount-driven dot row
                // always stays consistent with which index actually changed.
                onToggle: (tappedIndex) async {
                  final boundaryIndex = tappedIndex < progress.repsDone
                      ? progress.repsDone - 1
                      : progress.repsDone;
                  try {
                    await ref
                        .read(challengeProgressProvider(challenge.id).notifier)
                        .toggleRep(personKey, boundaryIndex);
                  } catch (_) {
                    if (context.mounted) {
                      showErrorSnackBar(
                        context,
                        'Something went wrong. Please try again.',
                      );
                    }
                  }
                },
              ),
              if (!progress.isCompleted) ...[
                const SizedBox(height: 4),
                Text(
                  'Tap a rep to mark it complete in case you forgot.',
                  style: FraternusTypography.small(
                    color: FraternusColors.textOnLightMuted,
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      skipLoadingOnReload: true,
    );
  }
}
