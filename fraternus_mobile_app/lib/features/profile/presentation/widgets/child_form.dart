import 'package:flutter/widgets.dart';

import '../../../../design_system/design_system.dart';
import '../../../../shared/models/chapter.dart';
import '../../../guide/presentation/widgets/fraternus_date_picker.dart';
import '../../models/member.dart';
import 'birthday_field.dart';

/// Shared field layout for Add Child and Edit Child — both mockups use the
/// identical First/Last Name, Birthday, Email (Optional), Chapter shape,
/// differing only in starting values and whether a Remove Child button
/// appears below.
class ChildForm extends StatefulWidget {
  const ChildForm({
    super.key,
    this.initial,
    required this.onSave,
    this.onRemove,
  });

  /// Null means "new child" — all fields start empty.
  final Member? initial;
  final void Function({
    required String firstName,
    required String lastName,
    required DateTime? birthday,
    required String? email,
    required String? chapterId,
  })
  onSave;
  final VoidCallback? onRemove;

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
  late DateTime? _birthday = widget.initial?.birthday;
  late String? _chapterId = widget.initial?.chapterId;

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
      initialDate: _birthday ?? DateTime(now.year - 10, now.month, now.day),
      firstDate: DateTime(now.year - 25),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthday = picked);
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
              const FieldLabel(label: 'Birthday'),
              BirthdayField(date: _birthday, onTap: _pickBirthday),
              const SizedBox(height: 16),
              const FieldLabel(label: 'Email (Optional)'),
              FormTextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const FieldLabel(label: 'Chapter'),
              SelectField(
                value: _chapterId,
                options: {
                  for (final chapter in seedChapters) chapter.id: chapter.name,
                },
                placeholder: 'Select a chapter',
                onChanged: (value) => setState(() => _chapterId = value),
              ),
              const SizedBox(height: 16),
              Button(
                label: 'Save',
                fullWidth: true,
                onPressed: () => widget.onSave(
                  firstName: _firstNameController.text,
                  lastName: _lastNameController.text,
                  birthday: _birthday,
                  email: _emailController.text.isEmpty
                      ? null
                      : _emailController.text,
                  chapterId: _chapterId,
                ),
              ),
            ],
          ),
        ),
        if (widget.onRemove != null) ...[
          const SizedBox(height: 16),
          Button(
            label: 'Remove Child',
            variant: ButtonVariant.ghost,
            color: ButtonColor.danger,
            fullWidth: true,
            onPressed: widget.onRemove,
          ),
        ],
      ],
    );
  }
}
