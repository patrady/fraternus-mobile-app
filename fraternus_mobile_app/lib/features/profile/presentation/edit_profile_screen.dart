import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../../shared/models/chapter.dart';
import '../../../shared/providers/chapter_providers.dart';
import '../../guide/presentation/widgets/fraternus_date_picker.dart';
import '../models/app_user.dart';
import '../models/member.dart';
import '../providers/profile_providers.dart';
import 'widgets/birthday_field.dart';

/// A ConsumerStatefulWidget (not the split ConsumerWidget+ConsumerStatefulWidget
/// shape used before) so the Save button can live in [ScreenShell]'s pinned
/// `footer` slot — that button needs the same field state (controllers,
/// `_chapterKey`, `_birthday`) that builds the form body, and only this
/// widget's State has both in scope at once.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  TextEditingController? _firstNameController;
  TextEditingController? _lastNameController;
  TextEditingController? _emailController;
  String? _chapterKey;
  DateTime? _birthday;

  AppUser? _user;
  Member? _selfMember;
  bool _initialized = false;

  /// Runs once, the first time `user`/`selfMember` actually resolve —
  /// [build] re-runs on every provider change, but the controllers/fields
  /// below are local edit state that shouldn't be clobbered by, say, a
  /// refetch after Save.
  void _initFrom(AppUser user, Member? selfMember) {
    if (_initialized) return;
    _initialized = true;
    _user = user;
    _selfMember = selfMember;
    _firstNameController = TextEditingController(text: user.firstName);
    _lastNameController = TextEditingController(text: user.lastName);
    _emailController = TextEditingController(text: user.email);
    _chapterKey = selfMember?.chapterKey;
    _birthday = selfMember?.birthday;
  }

  @override
  void dispose() {
    _firstNameController?.dispose();
    _lastNameController?.dispose();
    _emailController?.dispose();
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

  Future<void> _save() async {
    final user = _user!;
    final selfMember = _selfMember;
    await ref
        .read(currentUserProvider.notifier)
        .save(user.copyWith(firstName: _firstNameController!.text, lastName: _lastNameController!.text));
    if (selfMember != null && _chapterKey != null && _birthday != null) {
      await ref
          .read(householdMembersProvider.notifier)
          .updateMember(
            selfMember.copyWith(
              firstName: _firstNameController!.text,
              lastName: _lastNameController!.text,
              birthday: _birthday,
              chapterKey: _chapterKey,
            ),
          );
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final selfMemberAsync = ref.watch(selfMemberProvider);
    final chapters = ref.watch(chaptersProvider).value ?? const <Chapter>[];

    final (body, footer) = userAsync.when(
      data: (user) => selfMemberAsync.when(
        data: (selfMember) {
          _initFrom(user, selfMember);
          return (_buildFields(selfMember, chapters), _buildFooter(selfMember));
        },
        loading: () => (const SizedBox.shrink(), null),
        error: (error, stackTrace) => (const BodyText('Something went wrong loading your profile.'), null),
      ),
      loading: () => (const SizedBox.shrink(), null),
      error: (error, stackTrace) => (const BodyText('Something went wrong loading your profile.'), null),
    );

    return ScreenShell(
      footer: footer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'My Profile', onBack: () => context.pop()),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: body),
        ],
      ),
    );
  }

  Widget _buildFields(Member? selfMember, List<Chapter> chapters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        Avatar(initials: _user!.initials, size: AvatarSize.large),
        const SizedBox(height: 8),
        if (selfMember != null)
          Text(
            selfMember.role.name.toUpperCase(),
            style: FraternusTypography.eyebrow(color: FraternusColors.accentPrimary),
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
        const Align(alignment: Alignment.centerLeft, child: FieldLabel(label: 'Email')),
        FormTextField(controller: _emailController, keyboardType: TextInputType.emailAddress, readOnly: true),
        if (selfMember != null) ...[
          const SizedBox(height: 16),
          const Align(alignment: Alignment.centerLeft, child: FieldLabel(label: 'Birthday')),
          BirthdayField(date: _birthday, onTap: _pickBirthday),
          const SizedBox(height: 16),
          const Align(alignment: Alignment.centerLeft, child: FieldLabel(label: 'Chapter')),
          SelectField(
            value: _chapterKey,
            options: {for (final chapter in chapters) chapter.key: chapter.name},
            placeholder: 'Select a chapter',
            onChanged: (value) => setState(() => _chapterKey = value),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFooter(Member? selfMember) {
    return Button(
      label: 'Save',
      fullWidth: true,
      disabled: selfMember != null && _birthday == null,
      onPressed: _save,
    );
  }
}
