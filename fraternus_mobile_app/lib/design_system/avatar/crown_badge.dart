import 'package:flutter/widgets.dart';

import '../icons/fraternus_icon.dart';
import '../tokens/fraternus_colors.dart';

/// A small gold circle with a crown icon — the Kings Messenger badge, used
/// via `AvatarWithBadge(badge: const CrownBadge())`. Not a [Tag]-based
/// [AvatarWithBadge.badgeLabel] like an Officer Role badge, since this needs
/// an icon rather than text.
class CrownBadge extends StatelessWidget {
  const CrownBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: FraternusColors.tan,
      ),
      alignment: Alignment.center,
      child: const FraternusIcon(
        name: 'crown',
        size: 12,
        tone: FraternusIconTone.white,
      ),
    );
  }
}
