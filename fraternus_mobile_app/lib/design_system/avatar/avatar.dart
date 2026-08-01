import 'package:flutter/widgets.dart';

import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_typography.dart';

enum AvatarSize { small, medium, large }

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.initials,
    this.size = AvatarSize.medium,
  });

  final String initials;
  final AvatarSize size;

  double get _size => switch (size) {
    AvatarSize.small => 34,
    AvatarSize.medium => 60,
    AvatarSize.large => 72,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: FraternusColors.forestGreen,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: FraternusTypography.button(
          fontSize: (_size * 0.36).roundToDouble(),
          color: FraternusColors.white,
        ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0),
      ),
    );
  }
}
