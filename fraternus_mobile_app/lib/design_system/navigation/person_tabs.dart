import 'package:flutter/widgets.dart';

import '../icons/fraternus_icon.dart';
import '../internal/pressable_builder.dart';
import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_typography.dart';

enum PersonTabStatus { none, done, inProgress }

class PersonTabItem {
  const PersonTabItem({required this.key, required this.label, this.status = PersonTabStatus.none});

  final String key;
  final String label;
  final PersonTabStatus status;
}

/// Segmented text-tab switcher for the household member in view (You /
/// Jack / Thomas) — appears on Today, Guide, and Challenges. Distinct from
/// [BottomTabBar]: underline indicator instead of icon+color, plus a
/// per-person completion status icon. Ports components-source.jsx
/// `PersonTabs`.
class PersonTabs extends StatelessWidget {
  const PersonTabs({
    super.key,
    required this.people,
    required this.activeKey,
    required this.onChanged,
  });

  final List<PersonTabItem> people;
  final String activeKey;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: FraternusColors.borderSubtle)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final p in people) ...[
            _PersonTab(item: p, active: p.key == activeKey, onTap: () => onChanged(p.key)),
            if (p != people.last) const SizedBox(width: 22),
          ],
        ],
      ),
    );
  }
}

class _PersonTab extends StatelessWidget {
  const _PersonTab({required this.item, required this.active, required this.onTap});

  final PersonTabItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableBuilder(
      onTap: onTap,
      semanticLabel: item.label,
      builder: (context, isPressed) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
          constraints: const BoxConstraints(minHeight: 44),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? FraternusColors.accentPrimary : const Color(0x00000000),
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.label.toUpperCase(),
                style: FraternusTypography.button(
                  fontSize: 14,
                  color: active ? FraternusColors.forestGreen : FraternusColors.textOnLightMuted,
                ),
              ),
              if (item.status == PersonTabStatus.done) ...[
                const SizedBox(width: 5),
                const FraternusIcon(name: 'circle-check', size: 14, tone: FraternusIconTone.success),
              ],
              if (item.status == PersonTabStatus.inProgress) ...[
                const SizedBox(width: 5),
                const FraternusIcon(name: 'circle-dashed', size: 14, tone: FraternusIconTone.terracotta),
              ],
            ],
          ),
        );
      },
    );
  }
}
