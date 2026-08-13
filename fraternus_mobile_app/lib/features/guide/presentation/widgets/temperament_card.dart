import 'package:flutter/widgets.dart';

import '../../../../design_system/design_system.dart';

/// One temperament's application/vices copy for the current week, with an
/// optional Primary/Secondary tag when it matches the viewer's (fake,
/// seeded) quiz result. Tapping the card (chevron included) opens that
/// temperament's own detail screen — a static personality profile, not
/// the (still out-of-scope) quiz.
class TemperamentCard extends StatelessWidget {
  const TemperamentCard({
    super.key,
    required this.name,
    required this.application,
    required this.vices,
    this.tagLabel,
    this.onTap,
  });

  final String name;
  final String application;
  final String vices;
  final String? tagLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: PressableBuilder(
        onTap: onTap,
        semanticLabel: name,
        builder: (context, isPressed) {
          return Opacity(
            opacity: isPressed ? 0.75 : 1,
            child: Box(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name.toUpperCase(),
                              style: FraternusTypography.eyebrow(color: FraternusColors.accentPrimary),
                            ),
                            const FraternusIcon(name: 'chevron-right', size: 16),
                          ],
                        ),
                      ),
                      if (tagLabel != null)
                        Tag(
                          label: tagLabel!,
                          color: tagLabel == 'Primary' ? TagColor.primary : TagColor.secondary,
                          size: TagSize.small,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(application, style: FraternusTypography.body(color: FraternusColors.ink)),
                  const SizedBox(height: 8),
                  Text(
                    'Common vices: $vices',
                    style: FraternusTypography.body(color: FraternusColors.textOnLightMuted)
                        .copyWith(fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
