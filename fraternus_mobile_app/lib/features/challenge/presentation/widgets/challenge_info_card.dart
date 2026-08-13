import 'package:flutter/widgets.dart';

import '../../../../design_system/design_system.dart';
import '../../../../shared/formatting/ordinal_date_formatting.dart';
import '../../models/weekly_challenge.dart';

/// The white card at the top of the Challenge tab — title, "NEW" pill,
/// week label, and a description that expands on tap. Identical across
/// all 3 accept/complete states, so it lives above the state-specific
/// card rather than inside it. Feature-local: nothing in
/// components-source.jsx modeled this shape, and it's only used here.
class ChallengeInfoCard extends StatefulWidget {
  const ChallengeInfoCard({super.key, required this.challenge});

  final WeeklyChallenge challenge;

  @override
  State<ChallengeInfoCard> createState() => _ChallengeInfoCardState();
}

class _ChallengeInfoCardState extends State<ChallengeInfoCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;
    final isNew = DateTime.now().isBefore(challenge.fratNightTemplate.startOfWeekDate.add(const Duration(hours: 48)));

    return Box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(challenge.title, style: FraternusTypography.h4(color: FraternusColors.ink)),
              ),
              if (isNew) ...[
                const SizedBox(width: 8),
                const Tag(label: 'New', color: TagColor.secondary, icon: 'sparkles'),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Week of ${formatOrdinalDate(challenge.fratNightTemplate.startOfWeekDate)}',
            style: FraternusTypography.small(color: FraternusColors.textOnLightMuted),
          ),
          const SizedBox(height: 10),
          PressableBuilder(
            onTap: () => setState(() => _expanded = !_expanded),
            semanticLabel: _expanded ? 'Collapse description' : 'Expand description',
            builder: (context, isPressed) {
              return Opacity(
                opacity: isPressed ? 0.75 : 1,
                child: Text(
                  challenge.description,
                  maxLines: _expanded ? null : 2,
                  overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: FraternusTypography.body(color: FraternusColors.textOnLightMuted),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
