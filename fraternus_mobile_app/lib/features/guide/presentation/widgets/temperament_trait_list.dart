import 'package:flutter/widgets.dart';

import '../../../../design_system/design_system.dart';

/// A "Strengths"/"Growth Areas" bullet list — one icon+text row per trait.
class TemperamentTraitList extends StatelessWidget {
  const TemperamentTraitList({
    super.key,
    required this.items,
    required this.icon,
    required this.tone,
  });

  final List<String> items;
  final String icon;
  final FraternusIconTone tone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FraternusIcon(name: icon, size: 18, tone: tone),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    items[i],
                    style: FraternusTypography.body(color: FraternusColors.ink),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
