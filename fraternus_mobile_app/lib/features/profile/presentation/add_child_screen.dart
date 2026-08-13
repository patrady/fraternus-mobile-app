import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../models/member.dart';
import '../providers/profile_providers.dart';
import 'widgets/child_form.dart';

class AddChildScreen extends ConsumerWidget {
  const AddChildScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return ScreenShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'Add Child', onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: currentUserAsync.when(
              data: (currentUser) => ChildForm(
                onSave: ({required firstName, required lastName, required birthday, required email, required chapterId}) {
                  final newMember = Member(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    firstName: firstName,
                    lastName: lastName,
                    role: MemberRole.brother,
                    chapterId: chapterId ?? '',
                    birthday: birthday,
                    email: email,
                  );
                  ref.read(householdMembersProvider.notifier).upsert(newMember);
                  ref
                      .read(householdAssociationsProvider.notifier)
                      .addGuardianAssociation(currentUser.id, newMember.id);
                  context.pop();
                },
              ),
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) => const BodyText('Something went wrong.'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
