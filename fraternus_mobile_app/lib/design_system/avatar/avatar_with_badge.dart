import 'package:flutter/widgets.dart';

import '../tags/tag.dart';
import 'avatar.dart';

/// An [Avatar] with an optional small badge overlaid on its bottom-trailing
/// corner — either a text [Tag] via [badgeLabel] (e.g. a Member's
/// top-priority Officer Role) or an arbitrary widget via [badge] (e.g.
/// `CrownBadge`, the Kings Messenger badge). Renders a bare [Avatar] when
/// neither is set. [badge] takes precedence if both are somehow provided.
class AvatarWithBadge extends StatelessWidget {
  const AvatarWithBadge({
    super.key,
    required this.initials,
    this.size = AvatarSize.medium,
    this.badgeLabel,
    this.badge,
  });

  final String initials;
  final AvatarSize size;
  final String? badgeLabel;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final avatar = Avatar(initials: initials, size: size);
    final badge =
        this.badge ??
        (badgeLabel == null
            ? null
            : Tag(label: badgeLabel!, size: TagSize.small));
    if (badge == null) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(right: -4, bottom: -6, child: badge),
      ],
    );
  }
}
