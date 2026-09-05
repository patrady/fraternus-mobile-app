import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../design_system/design_system.dart';
import '../../../shared/providers/selected_household_member_provider.dart';
import '../../../shared/widgets/error_snackbar.dart';
import '../models/person_challenge_progress.dart';
import '../models/weekly_challenge.dart';
import '../providers/challenge_providers.dart';
import 'widgets/challenge_info_card.dart';
import 'widgets/challenge_rep_row.dart';

class ChallengeScreen extends ConsumerWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentChallengeAsync = ref.watch(currentChallengeProvider);

    return ScreenShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Heading('WEEKLY CHALLENGE', level: HeadingLevel.h2),
            const SizedBox(height: 20),
            currentChallengeAsync.when(
              data: (challenge) => challenge == null
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: BodyText(
                        'No challenge yet — check back after the next Frat Night.',
                      ),
                    )
                  : _ChallengeContent(challenge: challenge),
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) =>
                  const BodyText('Something went wrong loading the challenge.'),
              // A background reload (e.g. the accept/toggleRep-triggered
              // challenge feed refresh) should keep showing the previous
              // challenge rather than blanking the whole screen.
              skipLoadingOnReload: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeContent extends ConsumerWidget {
  const _ChallengeContent({required this.challenge});

  final WeeklyChallenge challenge;

  PersonTabStatus _statusFor(PersonChallengeProgress? progress) {
    if (progress == null) return PersonTabStatus.none;
    return progress.isCompleted
        ? PersonTabStatus.done
        : PersonTabStatus.inProgress;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(challengeProgressProvider(challenge.id));
    final householdAsync = ref.watch(challengeHouseholdProvider);
    final selectedKey = ref.watch(selectedHouseholdMemberProvider);
    final household = householdAsync.value ?? const [];
    // selectedKey defaults to the placeholder 'you' (see
    // SelectedHouseholdMember), which won't match a real household member's
    // id — same reconciliation TodayScreen's selectedPerson does, so
    // "Accept Challenge" doesn't try to insert an invalid member id.
    final activeKey =
        household.isEmpty || household.any((m) => m.memberId == selectedKey)
        ? selectedKey
        : household.first.memberId;

    final allChallenges = ref.watch(allChallengesProvider).value ?? const [];
    // The next Frat Night after this Challenge's — i.e. when its week ends
    // — is whichever other Challenge's fratNightDate is soonest after this
    // one's, not just adjacent-in-list, since allChallengesProvider isn't
    // guaranteed contiguous around "now".
    DateTime? nextFratNightDate;
    for (final other in allChallenges) {
      if (!other.fratNightDate.isAfter(challenge.fratNightDate)) continue;
      if (nextFratNightDate == null ||
          other.fratNightDate.isBefore(nextFratNightDate)) {
        nextFratNightDate = other.fratNightDate;
      }
    }

    final pastChallenges = ref.watch(pastChallengesProvider).value ?? const [];
    final hasPastAcceptedChallenge = pastChallenges.any(
      (c) => c.progress.any((p) => p.memberId == activeKey),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChallengeInfoCard(
          challenge: challenge,
          nextFratNightDate: nextFratNightDate,
        ),
        const SizedBox(height: 20),
        householdAsync.when(
          data: (household) => progressAsync.when(
            data: (progressByPerson) => PersonTabs(
              people: [
                for (final m in household)
                  PersonTabItem(
                    key: m.memberId,
                    label: m.label,
                    status: _statusFor(progressByPerson[m.memberId]),
                  ),
              ],
              activeKey: activeKey,
              onChanged: (key) => ref
                  .read(selectedHouseholdMemberProvider.notifier)
                  .select(key),
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
            skipLoadingOnReload: true,
          ),
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),
        _ChallengeStateCard(challenge: challenge, personKey: activeKey),
        if (hasPastAcceptedChallenge) ...[
          const SizedBox(height: 16),
          Button(
            label: 'Past Challenges',
            variant: ButtonVariant.ghost,
            fullWidth: true,
            icon: 'chevron-right',
            iconPosition: ButtonIconPosition.right,
            onPressed: () => context.push(RoutePaths.pastChallenges),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

/// The card below the person tabs — swaps between the not-accepted quote
/// card, the rep-progress list, and the completed celebration card based
/// on that person's live [ChallengeProgress] state. "Show/Hide Reps" is
/// pure view state local to this widget, not a data mutation, so it's a
/// plain [State] field rather than provider state.
class _ChallengeStateCard extends ConsumerStatefulWidget {
  const _ChallengeStateCard({required this.challenge, required this.personKey});

  final WeeklyChallenge challenge;
  final String personKey;

  @override
  ConsumerState<_ChallengeStateCard> createState() =>
      _ChallengeStateCardState();
}

class _ChallengeStateCardState extends ConsumerState<_ChallengeStateCard> {
  bool _showReps = false;

  @override
  void didUpdateWidget(covariant _ChallengeStateCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.personKey != widget.personKey) _showReps = false;
  }

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(
      challengeProgressProvider(widget.challenge.id),
    );

    return progressAsync.when(
      data: (progressByPerson) {
        final progress = progressByPerson[widget.personKey];
        if (progress == null) {
          return _NotAcceptedCard(
            challenge: widget.challenge,
            personKey: widget.personKey,
          );
        }

        if (progress.isCompleted && !_showReps) {
          final streakAsync = ref.watch(
            challengeStreakProvider(widget.personKey),
          );
          final streakLabel = streakAsync.value == null
              ? ''
              : '${streakAsync.value} week streak';
          return SizedBox(
            width: double.infinity,
            child: DarkFeatureCard(
              icon: 'award',
              value: 'Challenge Complete!',
              body: '\u{1F525} $streakLabel \u{1F525}',
              ctaLabel: 'Show Reps',
              onCta: () => setState(() => _showReps = true),
            ),
          );
        }

        final completions = List<DateTime?>.filled(
          widget.challenge.repsTotal,
          null,
        );
        for (final rep in progress.reps) {
          if (rep.number >= 1 && rep.number <= completions.length) {
            completions[rep.number - 1] = rep.createdAt;
          }
        }
        final nextIncompleteIndex = completions.indexWhere(
          (date) => date == null,
        );

        return Box(
          child: Column(
            children: [
              for (var i = 0; i < completions.length; i++) ...[
                ChallengeRepRow(
                  index: i,
                  completedAt: completions[i],
                  isNextIncomplete:
                      !progress.isCompleted && i == nextIncompleteIndex,
                  onMarkComplete: () async {
                    try {
                      await ref
                          .read(
                            challengeProgressProvider(
                              widget.challenge.id,
                            ).notifier,
                          )
                          .toggleRep(widget.personKey, i);
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
                if (i != completions.length - 1) const HairlineDivider(),
              ],
              if (progress.isCompleted) ...[
                const HairlineDivider(),
                Button(
                  label: 'Hide Reps',
                  variant: ButtonVariant.underlined,
                  onPressed: () => setState(() => _showReps = false),
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

class _NotAcceptedCard extends ConsumerWidget {
  const _NotAcceptedCard({required this.challenge, required this.personKey});

  final WeeklyChallenge challenge;
  final String personKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Box(
      child: Column(
        children: [
          const FraternusIcon(
            name: 'mountain',
            size: 32,
            tone: FraternusIconTone.terracotta,
          ),
          const SizedBox(height: 14),
          Text(
            'Every great man had to start with a single decision to be great.',
            textAlign: TextAlign.center,
            style: FraternusTypography.body(
              color: FraternusColors.ink,
            ).copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 18),
          Button(
            label: 'Accept Challenge',
            fullWidth: true,
            onPressed: () async {
              try {
                await ref
                    .read(challengeProgressProvider(challenge.id).notifier)
                    .accept(personKey);
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
        ],
      ),
    );
  }
}
