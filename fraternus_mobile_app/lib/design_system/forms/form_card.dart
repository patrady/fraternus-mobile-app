import 'package:flutter/widgets.dart';

import '../buttons/button.dart';
import '../buttons/button_group.dart';
import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_spacing.dart';

/// Inline "add child" form panel — wraps a set of labeled fields with a
/// Cancel/Save button row. Ports components-source.jsx `FormCard`.
class FormCard extends StatelessWidget {
  const FormCard({
    super.key,
    required this.child,
    this.onSave,
    this.onCancel,
    required this.canSave,
    this.saveLabel = 'Save',
  });

  final Widget child;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final bool canSave;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FraternusColors.white,
        border: Border.all(color: FraternusColors.borderSubtle),
        borderRadius: BorderRadius.circular(FraternusRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          child,
          const SizedBox(height: 4),
          ButtonGroup(
            children: [
              Button(
                label: 'Cancel',
                variant: ButtonVariant.ghost,
                onPressed: onCancel,
              ),
              Button(
                label: saveLabel,
                onPressed: canSave ? onSave : null,
                disabled: !canSave,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
