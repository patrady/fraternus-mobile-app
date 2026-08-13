import 'package:flutter/widgets.dart';

import '../../../../design_system/design_system.dart';
import '../../../../shared/formatting/ordinal_date_formatting.dart';

/// One "Rep N" row in the accepted-challenge rep list — done (checkmark +
/// completion date), the single next actionable rep (a "Mark Complete"
/// button), or a later rep that isn't reachable yet (nothing). Feature-
/// local: only used here, and enforces sequential completion for the
/// current challenge, unlike Past Challenges' any-order [RepDots] taps.
class ChallengeRepRow extends StatelessWidget {
  const ChallengeRepRow({
    super.key,
    required this.index,
    required this.completedAt,
    this.isNextIncomplete = false,
    this.onMarkComplete,
  });

  final int index;
  final DateTime? completedAt;
  final bool isNextIncomplete;
  final VoidCallback? onMarkComplete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Tall enough to comfortably frame the "Mark Complete" button, which
      // has a fixed 44pt tap-target-min height regardless of its own
      // padding — a shorter row here would look cramped against it.
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text('Rep ${index + 1}', style: FraternusTypography.body(color: FraternusColors.ink)),
          ),
          if (completedAt != null) ...[
            const FraternusIcon(name: 'circle-check', size: 16, tone: FraternusIconTone.success),
            const SizedBox(width: 6),
            Text(
              formatOrdinalDate(completedAt!),
              style: FraternusTypography.small(color: FraternusColors.textOnLightMuted),
            ),
          ] else if (isNextIncomplete)
            Button(label: 'Mark Complete', size: ButtonSize.small, onPressed: onMarkComplete),
        ],
      ),
    );
  }
}
