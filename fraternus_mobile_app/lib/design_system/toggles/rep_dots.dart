import 'package:flutter/widgets.dart';

import '../internal/pressable_builder.dart';
import '../tokens/fraternus_colors.dart';

/// Small circular indicators showing which reps of a weekly challenge are
/// complete. Ports components-source.jsx `RepDots`.
class RepDots extends StatelessWidget {
  const RepDots({
    super.key,
    required this.reps,
    required this.doneCount,
    this.editable = false,
    this.onToggle,
  });

  final int reps;
  final int doneCount;
  final bool editable;
  final ValueChanged<int>? onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(reps, (i) {
          final done = i < doneCount;
          return Padding(
            padding: EdgeInsets.only(right: i == reps - 1 ? 0 : 6),
            child: editable ? _editableDot(done, i) : _staticDot(done),
          );
        }),
      ),
    );
  }

  Widget _staticDot(bool done) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done
            ? FraternusColors.forestGreen
            : FraternusColors.borderSubtle,
      ),
    );
  }

  Widget _editableDot(bool done, int index) {
    return PressableBuilder(
      onTap: () => onToggle?.call(index),
      builder: (context, isPressed) {
        return Opacity(
          opacity: isPressed ? 0.75 : 1,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? FraternusColors.forestGreen : FraternusColors.white,
              border: done
                  ? null
                  : Border.all(color: FraternusColors.borderSubtle),
            ),
          ),
        );
      },
    );
  }
}
