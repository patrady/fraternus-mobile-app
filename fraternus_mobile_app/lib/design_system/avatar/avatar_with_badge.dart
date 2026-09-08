import 'package:flutter/widgets.dart';

import '../tags/tag.dart';
import 'avatar.dart';

/// An [Avatar] with an optional small [Tag] badge overlaid on its
/// bottom-trailing corner — e.g. a Member's top-priority Officer Role.
/// Renders a bare [Avatar] when [badgeLabel] is null.
class AvatarWithBadge extends StatelessWidget {
  const AvatarWithBadge({
    super.key,
    required this.initials,
    this.size = AvatarSize.medium,
    this.badgeLabel,
  });

  final String initials;
  final AvatarSize size;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    final avatar = Avatar(initials: initials, size: size);
    final badgeLabel = this.badgeLabel;
    if (badgeLabel == null) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -4,
          bottom: -6,
          child: Tag(label: badgeLabel, size: TagSize.small),
        ),
      ],
    );
  }
}
