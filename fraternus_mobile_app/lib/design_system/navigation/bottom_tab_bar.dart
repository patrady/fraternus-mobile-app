import 'package:flutter/widgets.dart';

import '../icons/fraternus_icon.dart';
import '../internal/pressable_builder.dart';
import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_typography.dart';

class BottomTabItem {
  const BottomTabItem({required this.key, required this.label, required this.icon});

  final String key;
  final String label;
  final String icon;
}

/// Primary 4-item app navigation (Today / Guide / Challenge / Events),
/// pinned to the bottom of every authenticated screen. Ports
/// components-source.jsx `BottomTabBar`.
class BottomTabBar extends StatelessWidget {
  const BottomTabBar({
    super.key,
    required this.tabs,
    required this.activeKey,
    required this.onChanged,
  });

  final List<BottomTabItem> tabs;
  final String activeKey;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 30),
      decoration: const BoxDecoration(
        color: FraternusColors.surfaceDark,
        border: Border(top: BorderSide(color: FraternusColors.borderOnDark)),
      ),
      child: Row(
        children: tabs.map((tab) {
          final active = tab.key == activeKey;
          return Expanded(
            child: PressableBuilder(
              onTap: () => onChanged(tab.key),
              semanticLabel: tab.label,
              builder: (context, isPressed) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FraternusIcon(
                        name: tab.icon,
                        size: 24,
                        tone: active ? FraternusIconTone.terracotta : FraternusIconTone.white,
                        opacity: active ? 1 : 0.62,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        tab.label.toUpperCase(),
                        style: FraternusTypography.button(
                          fontSize: 11,
                          color: active ? FraternusColors.accentPrimary : const Color(0x9ECDDAD5),
                        ).copyWith(letterSpacing: 11 * 0.04),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
