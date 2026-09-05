import 'package:flutter/widgets.dart';

import '../../../../design_system/design_system.dart';
import '../../../../shared/models/chapter.dart';
import '../../models/member.dart';

/// Shared field layout for Add Child and Edit Child — both mockups use the
/// identical First/Last Name, Email (Optional), Chapter shape, differing
/// only in starting values and whether a Remove Child button appears below.
class ChildForm extends StatefulWidget {
  const ChildForm({
    super.key,
    this.initial,
    this.initialChapterKey,
    required this.chapters,
    required this.onSave,
    this.onRemove,
  });

  /// Null means "new child" — all fields start empty.
  final Member? initial;

  /// Prefill for a brand-new child (e.g. the parent's own chapter) — ignored
  /// when [initial] is set, since an existing child's chapter takes priority.
  final String? initialChapterKey;

  /// Sourced from `chaptersProvider` by the caller (AddChildScreen /
  /// EditChildScreen) — kept plain (not repository-aware) here since this
  /// widget already only talks to its parent via callbacks.
  final List<Chapter> chapters;
  final Future<void> Function({
    required String firstName,
    required String lastName,
    required String? email,
    required String? chapterKey,
  })
  onSave;
  final Future<void> Function()? onRemove;

  @override
  State<ChildForm> createState() => _ChildFormState();
}

class _ChildFormState extends State<ChildForm> {
  late final _firstNameController = TextEditingController(
    text: widget.initial?.firstName,
  );
  late final _lastNameController = TextEditingController(
    text: widget.initial?.lastName,
  );
  late final _emailController = TextEditingController(
    text: widget.initial?.email,
  );
  late String? _chapterKey =
      widget.initial?.chapterKey ?? widget.initialChapterKey;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await widget.onSave(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        chapterKey: _chapterKey,
      );
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleRemove() async {
    final onRemove = widget.onRemove;
    if (onRemove == null) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await onRemove();
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _errorMessage = 'Something went wrong. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FraternusColors.white,
            border: Border.all(color: FraternusColors.borderSubtle),
            borderRadius: BorderRadius.circular(FraternusRadii.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const FieldLabel(label: 'Email (Optional)'),
              FormTextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const FieldLabel(label: 'Chapter'),
              SelectField(
                value: _chapterKey,
                options: {
                  for (final chapter in widget.chapters)
                    chapter.key: chapter.name,
                },
                placeholder: 'Select a chapter',
                onChanged: (value) => setState(() => _chapterKey = value),
              ),
              const SizedBox(height: 16),
              Button(
                label: _isSubmitting ? 'Saving…' : 'Save',
                fullWidth: true,
                disabled: _chapterKey == null || _isSubmitting,
                onPressed: _handleSave,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: FraternusTypography.small(
                    color: FraternusColors.error,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (widget.onRemove != null) ...[
          const SizedBox(height: 16),
          Button(
            label: _isSubmitting ? 'Removing…' : 'Remove Child',
            variant: ButtonVariant.ghost,
            color: ButtonColor.danger,
            fullWidth: true,
            disabled: _isSubmitting,
            onPressed: _handleRemove,
          ),
        ],
      ],
    );
  }
}
