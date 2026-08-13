import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../../shared/models/chapter.dart';
import '../../guide/presentation/widgets/fraternus_date_picker.dart';
import '../models/app_user.dart';
import '../models/member.dart';
import '../providers/profile_providers.dart';
import 'widgets/birthday_field.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final selfMemberAsync = ref.watch(selfMemberProvider);

    return ScreenShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'My Profile', onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: userAsync.when(
              data: (user) => selfMemberAsync.when(
                data: (selfMember) =>
                    _EditProfileForm(user: user, selfMember: selfMember),
                loading: () => const SizedBox.shrink(),
                error: (error, stackTrace) => const BodyText(
                  'Something went wrong loading your profile.',
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) =>
                  const BodyText('Something went wrong loading your profile.'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileForm extends ConsumerStatefulWidget {
  const _EditProfileForm({required this.user, required this.selfMember});

  final AppUser user;
  final Member? selfMember;

  @override
  ConsumerState<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<_EditProfileForm> {
  late final _firstNameController = TextEditingController(
    text: widget.user.firstName,
  );
  late final _lastNameController = TextEditingController(
    text: widget.user.lastName,
  );
  late final _emailController = TextEditingController(text: widget.user.email);
  late String? _chapterId = widget.selfMember?.chapterId;
  late DateTime? _birthday = widget.selfMember?.birthday;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showFraternusDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year - 35, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  @override
  Widget build(BuildContext context) {
    final selfMember = widget.selfMember;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        Avatar(initials: widget.user.initials, size: AvatarSize.large),
        const SizedBox(height: 8),
        if (selfMember != null)
          Text(
            selfMember.role.name.toUpperCase(),
            style: FraternusTypography.eyebrow(
              color: FraternusColors.accentPrimary,
            ),
          ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FieldLabel(label: 'First Name'),
                  FormTextField(controller: _firstNameController),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FieldLabel(label: 'Last Name'),
                  FormTextField(controller: _lastNameController),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Align(
          alignment: Alignment.centerLeft,
          child: FieldLabel(label: 'Email'),
        ),
        FormTextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        if (selfMember != null) ...[
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: FieldLabel(label: 'Birthday'),
          ),
          BirthdayField(date: _birthday, onTap: _pickBirthday),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: FieldLabel(label: 'Chapter'),
          ),
          SelectField(
            value: _chapterId,
            options: {
              for (final chapter in seedChapters) chapter.id: chapter.name,
            },
            placeholder: 'Select a chapter',
            onChanged: (value) => setState(() => _chapterId = value),
          ),
        ],
        const SizedBox(height: 24),
        Button(
          label: 'Save',
          fullWidth: true,
          disabled: selfMember != null && _birthday == null,
          onPressed: () {
            ref
                .read(currentUserProvider.notifier)
                .save(
                  widget.user.copyWith(
                    firstName: _firstNameController.text,
                    lastName: _lastNameController.text,
                    email: _emailController.text,
                  ),
                );
            if (selfMember != null && _chapterId != null && _birthday != null) {
              ref
                  .read(householdMembersProvider.notifier)
                  .upsert(
                    selfMember.copyWith(
                      firstName: _firstNameController.text,
                      lastName: _lastNameController.text,
                      birthday: _birthday,
                      chapterId: _chapterId,
                    ),
                  );
            }
            context.pop();
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
