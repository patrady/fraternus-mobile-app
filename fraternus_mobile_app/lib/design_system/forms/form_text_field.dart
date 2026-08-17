import 'package:flutter/material.dart';

import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_spacing.dart';
import '../tokens/fraternus_typography.dart';

/// Single-line labeled entry — First Name, Last Name, Email, etc. Sibling
/// to [JournalTextarea] (multiline); same container styling, single-line
/// TextField.
class FormTextField extends StatelessWidget {
  const FormTextField({
    super.key,
    this.controller,
    this.onChanged,
    this.placeholder,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? placeholder;
  final TextInputType? keyboardType;

  /// Set for password entry — no other field in this app needs it today.
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: FraternusColors.white,
        border: Border.all(color: FraternusColors.borderSubtle),
        borderRadius: BorderRadius.circular(FraternusRadii.sm),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: FraternusTypography.body().copyWith(fontSize: 15),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: FraternusTypography.body(
            color: FraternusColors.textOnLightMuted,
          ).copyWith(fontSize: 15),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
