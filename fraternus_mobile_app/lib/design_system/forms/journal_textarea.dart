import 'package:flutter/material.dart';

import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_spacing.dart';
import '../tokens/fraternus_typography.dart';

/// Freeform multi-line entry — the "My Spade" daily reflection field. Not
/// yet a Design System component; should eventually formalize into a DS
/// `Textarea`. Ports components-source.jsx `JournalTextarea`.
class JournalTextarea extends StatefulWidget {
  const JournalTextarea({
    super.key,
    this.controller,
    this.onChanged,
    this.onFocusLost,
    this.placeholder,
    this.rows = 4,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  /// Fires with the field's current text the moment it loses focus (the
  /// user taps away) — the one point a caller should actually persist a
  /// write, rather than on every keystroke via [onChanged].
  final ValueChanged<String>? onFocusLost;
  final String? placeholder;
  final int rows;

  @override
  State<JournalTextarea> createState() => _JournalTextareaState();
}

class _JournalTextareaState extends State<JournalTextarea> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      widget.onFocusLost?.call(widget.controller?.text ?? '');
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

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
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        minLines: widget.rows,
        maxLines: widget.rows,
        style: FraternusTypography.body().copyWith(fontSize: 15),
        decoration: InputDecoration(
          hintText: widget.placeholder,
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
