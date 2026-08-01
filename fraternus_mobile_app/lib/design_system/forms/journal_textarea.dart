import 'package:flutter/material.dart';

import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_spacing.dart';
import '../tokens/fraternus_typography.dart';

/// Freeform multi-line entry — the "My Spade" daily reflection field. Not
/// yet a Design System component; should eventually formalize into a DS
/// `Textarea`. Ports components-source.jsx `JournalTextarea`.
class JournalTextarea extends StatelessWidget {
  const JournalTextarea({
    super.key,
    this.controller,
    this.onChanged,
    this.placeholder,
    this.rows = 4,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? placeholder;
  final int rows;

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
        minLines: rows,
        maxLines: rows,
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
