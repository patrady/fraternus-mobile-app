import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../../shared/providers/chapter_providers.dart';
import '../../guide/presentation/widgets/fraternus_date_picker.dart';
import '../../profile/presentation/widgets/birthday_field.dart';
import '../../profile/providers/profile_providers.dart';
import '../providers/auth_providers.dart';

/// app_concept.md's Profile section literally lists Captain signup fields
/// as "first name, last name, email, and chapter" — no birthday. But the
/// Member data model (and the already-built Member Dart model's own doc
/// comment: "Required for every Member regardless of role") requires a
/// birthday for every Member, Captain included. Treating the Data Model as
/// authoritative here (same call as the Day Number convention in
/// docs/adrs — the prose has the bug, not the schema), so birthday is
/// collected here even though the Profile section's prose omits it.
///
/// The User half happens via [AuthRepository.signUp]; the Member/Self
/// association half via `completeCaptainSignup` (the `complete_captain_signup`
/// RPC — docs/adrs/002_supabase_backend_poc.md §5). Chapter options come
/// from [chaptersProvider] — readable pre-auth since chapters are public,
/// non-sensitive directory data (see the "chapters_anon_read" migration).
class SignUpCaptainScreen extends ConsumerStatefulWidget {
  const SignUpCaptainScreen({super.key});

  @override
  ConsumerState<SignUpCaptainScreen> createState() => _SignUpCaptainScreenState();
}

class _SignUpCaptainScreenState extends ConsumerState<SignUpCaptainScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _chapterId;
  DateTime? _birthday;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _firstNameController.text.isNotEmpty &&
      _lastNameController.text.isNotEmpty &&
      _emailController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _chapterId != null &&
      _birthday != null;

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

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
          );
      await ref
          .read(profileRepositoryProvider)
          .completeCaptainSignup(
            chapterId: _chapterId!,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            birthday: _birthday!,
          );
      // The router's redirect (see app/router/app_router.dart) takes over
      // navigation to /today as soon as the session is established.
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Could not create your account. Try again in a moment.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'Captain Sign Up', onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FieldLabel(label: 'First Name'),
                          FormTextField(
                            controller: _firstNameController,
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FieldLabel(label: 'Last Name'),
                          FormTextField(
                            controller: _lastNameController,
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const FieldLabel(label: 'Email'),
                FormTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                const FieldLabel(label: 'Password'),
                FormTextField(
                  controller: _passwordController,
                  obscureText: true,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                const FieldLabel(label: 'Chapter'),
                SelectField(
                  value: _chapterId,
                  options: {
                    for (final chapter in ref.watch(chaptersProvider).value ?? const []) chapter.id: chapter.name,
                  },
                  placeholder: 'Select a chapter',
                  onChanged: (value) => setState(() => _chapterId = value),
                ),
                const SizedBox(height: 16),
                const FieldLabel(label: 'Birthday'),
                BirthdayField(date: _birthday, onTap: _pickBirthday),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(_errorMessage!, style: FraternusTypography.small(color: FraternusColors.error)),
                ],
                const SizedBox(height: 24),
                Button(
                  label: _isSubmitting ? 'Creating Account…' : 'Create Account',
                  fullWidth: true,
                  disabled: _isSubmitting || !_canSubmit,
                  onPressed: _submit,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
