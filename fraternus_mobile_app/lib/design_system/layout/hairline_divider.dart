import 'package:flutter/widgets.dart';

import '../tokens/fraternus_colors.dart';

/// A single 1px horizontal rule in [FraternusColors.borderSubtle] —
/// separates stacked sections/rows (e.g. between the weekly focus card and
/// the today list, or between rows grouped inside a [Box]).
class HairlineDivider extends StatelessWidget {
  const HairlineDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: FraternusColors.borderSubtle);
  }
}
