import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../design_system/design_system.dart';
import '../../../shared/models/chapter.dart';
import '../../../shared/providers/chapter_providers.dart';
import '../models/member.dart';
import '../providers/profile_providers.dart';

class MyKidsScreen extends ConsumerWidget {
  const MyKidsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(guardianMembersProvider);
    final chapters = ref.watch(chaptersProvider).value ?? const <Chapter>[];

    return ScreenShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'My Kids', onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: childrenAsync.when(
              data: (children) => _MyKidsList(children: children, chapters: chapters),
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) => const BodyText('Something went wrong loading your kids.'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyKidsList extends StatelessWidget {
  const _MyKidsList({required this.children, required this.chapters});

  final List<Member> children;
  final List<Chapter> chapters;

  String _chapterName(String chapterId) {
    for (final chapter in chapters) {
      if (chapter.id == chapterId) return chapter.name;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final child in children)
          ListRow(
            leading: Avatar(initials: child.initials, size: AvatarSize.small),
            label: child.fullName,
            sublabel: _chapterName(child.chapterId),
            trailing: Button(
              label: 'Edit',
              variant: ButtonVariant.ghost,
              size: ButtonSize.small,
              onPressed: () => context.push(RoutePaths.todayProfileKidsEdit(child.id)),
            ),
          ),
        _AddChildRow(onTap: () => context.push(RoutePaths.todayProfileKidsAdd)),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// The reference screenshot centers this row's content unlike [ListRow]'s
/// left-aligned shape — copies ListRow's bordered-card decoration with a
/// centered icon+label instead. One call site, so feature-local rather than
/// design-system-promoted.
class _AddChildRow extends StatelessWidget {
  const _AddChildRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableBuilder(
      onTap: onTap,
      semanticLabel: 'Add child',
      builder: (context, isPressed) {
        return Opacity(
          opacity: isPressed ? 0.9 : 1,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            constraints: const BoxConstraints(minHeight: FraternusSpacing.tapTargetMin),
            decoration: BoxDecoration(
              color: FraternusColors.white,
              border: Border.all(color: FraternusColors.borderSubtle),
              borderRadius: BorderRadius.circular(FraternusRadii.lg),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FraternusIcon(name: 'plus', size: 16),
                const SizedBox(width: 8),
                Text(
                  'ADD CHILD',
                  style: FraternusTypography.button(fontSize: 14, color: FraternusColors.ink).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
