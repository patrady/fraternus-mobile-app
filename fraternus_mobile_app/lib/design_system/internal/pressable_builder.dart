import 'package:flutter/widgets.dart';

typedef PressableWidgetBuilder = Widget Function(BuildContext context, bool isPressed);

/// Shared tap-state tracker for controls that need a simple pressed/unpressed
/// visual (color darken or opacity dim) instead of Material's ripple —
/// matching the brand rule of "no hover-lift/shadow, only a color or
/// opacity change on press".
class PressableBuilder extends StatefulWidget {
  const PressableBuilder({
    super.key,
    required this.builder,
    this.onTap,
    this.disabled = false,
    this.semanticLabel,
  });

  final PressableWidgetBuilder builder;
  final VoidCallback? onTap;
  final bool disabled;
  final String? semanticLabel;

  @override
  State<PressableBuilder> createState() => _PressableBuilderState();
}

class _PressableBuilderState extends State<PressableBuilder> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !widget.disabled && widget.onTap != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Semantics(
        button: true,
        label: widget.semanticLabel,
        enabled: enabled,
        child: GestureDetector(
          onTap: enabled ? widget.onTap : null,
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapUp: enabled ? (_) => _setPressed(false) : null,
          onTapCancel: enabled ? () => _setPressed(false) : null,
          behavior: HitTestBehavior.opaque,
          child: ExcludeSemantics(child: widget.builder(context, _pressed && enabled)),
        ),
      ),
    );
  }
}
