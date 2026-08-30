import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/design_system.dart';
import '../../models/event.dart';
import '../../providers/events_providers.dart';

const _filterOptions = [
  (type: EventType.fratNight, label: 'Frat Night'),
  (type: EventType.excursion, label: 'Excursions'),
  (type: EventType.ranch, label: 'Ranch'),
  (type: EventType.custom, label: 'Other'),
];

/// Filter-by-type sheet for the Events list. Reads/writes
/// [eventTypeFilterProvider] directly rather than round-tripping a result
/// through the caller, so each tap live-updates the list underneath —
/// matches [showFraternusConfirmDialog]'s "themed Dialog" shape, but with
/// no Apply step since there's nothing to commit.
Future<void> showEventTypeFilterDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: const Color(0x66000000),
    builder: (context) {
      return Dialog(
        backgroundColor: FraternusColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(FraternusRadii.lg)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Consumer(
            builder: (context, ref, _) {
              final selected = ref.watch(eventTypeFilterProvider);
              final notifier = ref.read(eventTypeFilterProvider.notifier);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Heading('FILTER EVENTS', level: HeadingLevel.h3),
                      ),
                      PressableBuilder(
                        onTap: () => Navigator.of(context).pop(),
                        semanticLabel: 'Close',
                        builder: (context, isPressed) {
                          return Opacity(
                            opacity: isPressed ? 0.75 : 1,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: FraternusColors.surfaceCardDim,
                              ),
                              alignment: Alignment.center,
                              child: const FraternusIcon(name: 'x', size: 14),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final option in _filterOptions)
                    ListRow(
                      label: option.label,
                      bordered: false,
                      chevron: false,
                      trailing: FraternusIcon(
                        name: selected.contains(option.type)
                            ? 'circle-check'
                            : 'circle',
                        size: 20,
                        tone: selected.contains(option.type)
                            ? FraternusIconTone.terracotta
                            : FraternusIconTone.ink,
                        opacity: selected.contains(option.type) ? 1 : 0.4,
                      ),
                      onPressed: () => notifier.toggle(option.type),
                    ),
                  const SizedBox(height: 12),
                  ButtonGroup(
                    children: [
                      Button(
                        label: 'Clear',
                        variant: ButtonVariant.ghost,
                        onPressed: selected.isEmpty ? null : notifier.clear,
                      ),
                      Button(
                        label: 'Done',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}
