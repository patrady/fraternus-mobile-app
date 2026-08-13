import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../models/temperament.dart';
import 'widgets/temperament_trait_list.dart';

/// One temperament's own personality profile — pushed from a temperament
/// card on [VirtueDetailScreen]. Purely static content (no provider):
/// unlike Application/Vices, a temperament's own description/strengths/
/// growth-areas don't vary per virtue-week.
class TemperamentDetailScreen extends StatelessWidget {
  const TemperamentDetailScreen({super.key, required this.temperamentKey});

  final String temperamentKey;

  @override
  Widget build(BuildContext context) {
    final profile = temperamentProfiles[temperamentKey]!;
    final name = temperamentDisplayNames[temperamentKey] ?? temperamentKey;

    return ScreenShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'Back', onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Heading(name.toUpperCase(), level: HeadingLevel.h3),
                const SizedBox(height: 16),
                ContentCard(
                  child: Text(profile.description, style: FraternusTypography.body(color: FraternusColors.ink)),
                ),
                ContentCard(
                  eyebrow: 'Strengths',
                  child: TemperamentTraitList(
                    items: profile.strengths,
                    icon: 'circle-check',
                    tone: FraternusIconTone.success,
                  ),
                ),
                ContentCard(
                  eyebrow: 'Growth Areas',
                  child: TemperamentTraitList(
                    items: profile.growthAreas,
                    icon: 'triangle-alert',
                    tone: FraternusIconTone.terracotta,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
