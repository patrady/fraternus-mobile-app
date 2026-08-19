import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../../shared/models/chapter.dart';
import '../../../shared/providers/chapter_providers.dart';
import '../providers/profile_providers.dart';
import 'widgets/child_form.dart';

class AddChildScreen extends ConsumerWidget {
  const AddChildScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapters = ref.watch(chaptersProvider).value ?? const <Chapter>[];

    return ScreenShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'Add Child', onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ChildForm(
              chapters: chapters,
              onSave: ({required firstName, required lastName, required birthday, required email, required chapterId}) async {
                // create_child_member (see ProfileRepository) atomically
                // creates the Member + Guardian association (+ Pending
                // consent if under 13) — no separate association step here.
                await ref
                    .read(profileRepositoryProvider)
                    .createChildMember(
                      firstName: firstName,
                      lastName: lastName,
                      chapterId: chapterId ?? '',
                      birthday: birthday,
                      email: email,
                    );
                ref.invalidate(householdMembersProvider);
                ref.invalidate(householdAssociationsProvider);
                if (context.mounted) context.pop();
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
