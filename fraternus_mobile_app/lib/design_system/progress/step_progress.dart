import 'package:flutter/widgets.dart';

import '../tokens/fraternus_colors.dart';

/// Segmented progress bar at the top of each wizard step. Ports
/// components-source.jsx `StepProgress`.
class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Row(
        children: List.generate(total, (i) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
              height: 4,
              decoration: BoxDecoration(
                color: i < step
                    ? FraternusColors.accentPrimary
                    : FraternusColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
