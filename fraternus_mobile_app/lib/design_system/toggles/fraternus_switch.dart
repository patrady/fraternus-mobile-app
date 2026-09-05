import 'package:flutter/widgets.dart';

import '../tokens/fraternus_colors.dart';

/// A real boolean on/off switch — reminder toggles, etc. Distinct from
/// [RsvpToggle] (a two-label pill) and [RepDots] (an editable dot row).
/// Built as a custom pill+thumb rather than Material `Switch`/
/// `CupertinoSwitch` — this codebase never uses either, consistently
/// building its own themed primitives instead (see [PressableBuilder] over
/// `InkWell`).
class FraternusSwitch extends StatelessWidget {
  const FraternusSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  static const _width = 46.0;
  static const _height = 26.0;
  static const _thumbSize = 20.0;
  static const _animationDuration = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: _animationDuration,
        width: _width,
        height: _height,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? FraternusColors.accentPrimary : FraternusColors.border,
          borderRadius: BorderRadius.circular(_height / 2),
        ),
        child: AnimatedAlign(
          duration: _animationDuration,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: _thumbSize,
            height: _thumbSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: FraternusColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
