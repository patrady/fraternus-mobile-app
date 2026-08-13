import 'package:flutter/widgets.dart';

import '../../../../design_system/design_system.dart';

/// Plain single-select radio list for "My Sword" — no bordered card per
/// option, just a circle indicator + label row, since no DS radio/
/// checkbox component exists yet and none of the existing selectable
/// cards match this bare-row look.
class SwordOptionList extends StatelessWidget {
  const SwordOptionList({super.key, required this.options, this.selected, required this.onSelect});

  final List<String> options;

  /// The selected option's own text (matching how the schema stores the
  /// picked Sword text, not an index) — or null if nothing picked yet.
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final option in options)
          PressableBuilder(
            onTap: () => onSelect(option),
            semanticLabel: option,
            builder: (context, isPressed) {
              final isSelected = option == selected;
              return Opacity(
                opacity: isPressed ? 0.75 : 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? FraternusColors.accentPrimary : null,
                          border: Border.all(
                            color: isSelected ? FraternusColors.accentPrimary : FraternusColors.borderSubtle,
                            width: isSelected ? 6 : 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(option, style: FraternusTypography.body(color: FraternusColors.ink)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
