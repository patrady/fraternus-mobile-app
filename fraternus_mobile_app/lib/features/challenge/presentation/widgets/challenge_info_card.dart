import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/clock_provider.dart';
import '../../../../design_system/design_system.dart';
import '../../../../shared/formatting/ordinal_date_formatting.dart';
import '../../models/weekly_challenge.dart';

/// The white card at the top of the Challenge tab — title, "NEW" pill,
/// week range, and the full description. Identical across all 3
/// accept/complete states, so it lives above the state-specific card
/// rather than inside it. Feature-local: nothing in components-source.jsx
/// modeled this shape, and it's only used here.
class ChallengeInfoCard extends ConsumerWidget {
  const ChallengeInfoCard({
    super.key,
    required this.challenge,
    required this.nextFratNightDate,
  });

  final WeeklyChallenge challenge;

  /// The following Frat Night's start date — i.e. when this Challenge's
  /// week ends — resolved by the caller from the full challenge list since
  /// there's no direct link between one Challenge and the next. Null when
  /// no later Frat Night is scheduled yet, in which case the week label
  /// falls back to just the start date.
  final DateTime? nextFratNightDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNew = ref
        .watch(nowProvider)
        .isBefore(challenge.fratNightDate.add(const Duration(hours: 48)));
    final weekLabel = nextFratNightDate == null
        ? formatOrdinalDate(challenge.fratNightDate)
        : '${formatOrdinalDate(challenge.fratNightDate)} – ${formatOrdinalDate(nextFratNightDate!)}';

    return Box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  challenge.title,
                  style: FraternusTypography.h4(color: FraternusColors.ink),
                ),
              ),
              if (isNew) ...[
                const SizedBox(width: 8),
                const Tag(
                  label: 'New',
                  color: TagColor.secondary,
                  icon: 'sparkles',
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            weekLabel,
            style: FraternusTypography.small(
              color: FraternusColors.textOnLightMuted,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            challenge.description,
            style: FraternusTypography.body(
              color: FraternusColors.textOnLightMuted,
            ),
          ),
        ],
      ),
    );
  }
}
