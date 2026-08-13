import 'package:flutter/cupertino.dart';

import '../buttons/button.dart';
import '../icons/fraternus_icon.dart';
import '../internal/pressable_builder.dart';
import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_spacing.dart';
import '../tokens/fraternus_typography.dart';

/// Single-selection field — "Select a chapter", etc. Opens the same
/// bottom-sheet wheel picker iOS uses natively ([CupertinoPicker] inside
/// [showCupertinoModalPopup]) rather than Android's Material dropdown
/// menu, since this app is primarily an iOS experience. Keyed by string id
/// (`options` maps id -> display label) so it works for Chapter or any
/// future option set without needing generics.
class SelectField extends StatelessWidget {
  const SelectField({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.placeholder = 'Select an option',
  });

  /// The selected option's key, or null if nothing is selected.
  final String? value;
  final Map<String, String> options;
  final ValueChanged<String?> onChanged;
  final String placeholder;

  Future<void> _openPicker(BuildContext context) async {
    final keys = options.keys.toList();
    final initialIndex = value == null ? 0 : keys.indexOf(value!).clamp(0, keys.length - 1);
    var selectedIndex = initialIndex;

    final picked = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) {
        return Container(
          height: 260,
          decoration: const BoxDecoration(
            color: FraternusColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(FraternusRadii.lg)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: FraternusColors.borderSubtle)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Button(
                      label: 'Cancel',
                      variant: ButtonVariant.underlined,
                      size: ButtonSize.small,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Button(
                      label: 'Done',
                      variant: ButtonVariant.underlined,
                      size: ButtonSize.small,
                      onPressed: () => Navigator.of(context).pop(keys[selectedIndex]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                  onSelectedItemChanged: (index) => selectedIndex = index,
                  children: [
                    for (final key in keys)
                      Center(
                        child: Text(options[key]!, style: FraternusTypography.body().copyWith(fontSize: 17)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final label = value == null ? null : options[value];

    return PressableBuilder(
      onTap: () => _openPicker(context),
      semanticLabel: placeholder,
      builder: (context, isPressed) {
        return Opacity(
          opacity: isPressed ? 0.85 : 1,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: FraternusColors.white,
              border: Border.all(color: FraternusColors.borderSubtle),
              borderRadius: BorderRadius.circular(FraternusRadii.sm),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label ?? placeholder,
                    style: FraternusTypography.body(
                      color: label == null ? FraternusColors.textOnLightMuted : FraternusColors.ink,
                    ).copyWith(fontSize: 15),
                  ),
                ),
                const FraternusIcon(name: 'chevron-down', size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}
